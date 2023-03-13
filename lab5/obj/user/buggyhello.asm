
obj/user/buggyhello.debug：     文件格式 elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 88 04 00 00       	call   800520 <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7f 08                	jg     80010e <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800106:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800109:	5b                   	pop    %ebx
  80010a:	5e                   	pop    %esi
  80010b:	5f                   	pop    %edi
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	6a 03                	push   $0x3
  800114:	68 6a 1d 80 00       	push   $0x801d6a
  800119:	6a 2a                	push   $0x2a
  80011b:	68 87 1d 80 00       	push   $0x801d87
  800120:	e8 d0 0e 00 00       	call   800ff5 <_panic>

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	8b 55 08             	mov    0x8(%ebp),%edx
  800174:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800177:	b8 04 00 00 00       	mov    $0x4,%eax
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7f 08                	jg     80018f <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800187:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018a:	5b                   	pop    %ebx
  80018b:	5e                   	pop    %esi
  80018c:	5f                   	pop    %edi
  80018d:	5d                   	pop    %ebp
  80018e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	50                   	push   %eax
  800193:	6a 04                	push   $0x4
  800195:	68 6a 1d 80 00       	push   $0x801d6a
  80019a:	6a 2a                	push   $0x2a
  80019c:	68 87 1d 80 00       	push   $0x801d87
  8001a1:	e8 4f 0e 00 00       	call   800ff5 <_panic>

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001af:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7f 08                	jg     8001d1 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cc:	5b                   	pop    %ebx
  8001cd:	5e                   	pop    %esi
  8001ce:	5f                   	pop    %edi
  8001cf:	5d                   	pop    %ebp
  8001d0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d1:	83 ec 0c             	sub    $0xc,%esp
  8001d4:	50                   	push   %eax
  8001d5:	6a 05                	push   $0x5
  8001d7:	68 6a 1d 80 00       	push   $0x801d6a
  8001dc:	6a 2a                	push   $0x2a
  8001de:	68 87 1d 80 00       	push   $0x801d87
  8001e3:	e8 0d 0e 00 00       	call   800ff5 <_panic>

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fc:	b8 06 00 00 00       	mov    $0x6,%eax
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7f 08                	jg     800213 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020e:	5b                   	pop    %ebx
  80020f:	5e                   	pop    %esi
  800210:	5f                   	pop    %edi
  800211:	5d                   	pop    %ebp
  800212:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800213:	83 ec 0c             	sub    $0xc,%esp
  800216:	50                   	push   %eax
  800217:	6a 06                	push   $0x6
  800219:	68 6a 1d 80 00       	push   $0x801d6a
  80021e:	6a 2a                	push   $0x2a
  800220:	68 87 1d 80 00       	push   $0x801d87
  800225:	e8 cb 0d 00 00       	call   800ff5 <_panic>

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	8b 55 08             	mov    0x8(%ebp),%edx
  80023b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023e:	b8 08 00 00 00       	mov    $0x8,%eax
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7f 08                	jg     800255 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800250:	5b                   	pop    %ebx
  800251:	5e                   	pop    %esi
  800252:	5f                   	pop    %edi
  800253:	5d                   	pop    %ebp
  800254:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800255:	83 ec 0c             	sub    $0xc,%esp
  800258:	50                   	push   %eax
  800259:	6a 08                	push   $0x8
  80025b:	68 6a 1d 80 00       	push   $0x801d6a
  800260:	6a 2a                	push   $0x2a
  800262:	68 87 1d 80 00       	push   $0x801d87
  800267:	e8 89 0d 00 00       	call   800ff5 <_panic>

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	8b 55 08             	mov    0x8(%ebp),%edx
  80027d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800280:	b8 09 00 00 00       	mov    $0x9,%eax
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7f 08                	jg     800297 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80028f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800292:	5b                   	pop    %ebx
  800293:	5e                   	pop    %esi
  800294:	5f                   	pop    %edi
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800297:	83 ec 0c             	sub    $0xc,%esp
  80029a:	50                   	push   %eax
  80029b:	6a 09                	push   $0x9
  80029d:	68 6a 1d 80 00       	push   $0x801d6a
  8002a2:	6a 2a                	push   $0x2a
  8002a4:	68 87 1d 80 00       	push   $0x801d87
  8002a9:	e8 47 0d 00 00       	call   800ff5 <_panic>

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7f 08                	jg     8002d9 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d4:	5b                   	pop    %ebx
  8002d5:	5e                   	pop    %esi
  8002d6:	5f                   	pop    %edi
  8002d7:	5d                   	pop    %ebp
  8002d8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d9:	83 ec 0c             	sub    $0xc,%esp
  8002dc:	50                   	push   %eax
  8002dd:	6a 0a                	push   $0xa
  8002df:	68 6a 1d 80 00       	push   $0x801d6a
  8002e4:	6a 2a                	push   $0x2a
  8002e6:	68 87 1d 80 00       	push   $0x801d87
  8002eb:	e8 05 0d 00 00       	call   800ff5 <_panic>

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800301:	be 00 00 00 00       	mov    $0x0,%esi
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	b8 0d 00 00 00       	mov    $0xd,%eax
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7f 08                	jg     80033d <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800335:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800338:	5b                   	pop    %ebx
  800339:	5e                   	pop    %esi
  80033a:	5f                   	pop    %edi
  80033b:	5d                   	pop    %ebp
  80033c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80033d:	83 ec 0c             	sub    $0xc,%esp
  800340:	50                   	push   %eax
  800341:	6a 0d                	push   $0xd
  800343:	68 6a 1d 80 00       	push   $0x801d6a
  800348:	6a 2a                	push   $0x2a
  80034a:	68 87 1d 80 00       	push   $0x801d87
  80034f:	e8 a1 0c 00 00       	call   800ff5 <_panic>

00800354 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	05 00 00 00 30       	add    $0x30000000,%eax
  80035f:	c1 e8 0c             	shr    $0xc,%eax
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80036f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800374:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800383:	89 c2                	mov    %eax,%edx
  800385:	c1 ea 16             	shr    $0x16,%edx
  800388:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80038f:	f6 c2 01             	test   $0x1,%dl
  800392:	74 29                	je     8003bd <fd_alloc+0x42>
  800394:	89 c2                	mov    %eax,%edx
  800396:	c1 ea 0c             	shr    $0xc,%edx
  800399:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a0:	f6 c2 01             	test   $0x1,%dl
  8003a3:	74 18                	je     8003bd <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8003a5:	05 00 10 00 00       	add    $0x1000,%eax
  8003aa:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003af:	75 d2                	jne    800383 <fd_alloc+0x8>
  8003b1:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8003b6:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8003bb:	eb 05                	jmp    8003c2 <fd_alloc+0x47>
			return 0;
  8003bd:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8003c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c5:	89 02                	mov    %eax,(%edx)
}
  8003c7:	89 c8                	mov    %ecx,%eax
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    

008003cb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d1:	83 f8 1f             	cmp    $0x1f,%eax
  8003d4:	77 30                	ja     800406 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d6:	c1 e0 0c             	shl    $0xc,%eax
  8003d9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003de:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003e4:	f6 c2 01             	test   $0x1,%dl
  8003e7:	74 24                	je     80040d <fd_lookup+0x42>
  8003e9:	89 c2                	mov    %eax,%edx
  8003eb:	c1 ea 0c             	shr    $0xc,%edx
  8003ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f5:	f6 c2 01             	test   $0x1,%dl
  8003f8:	74 1a                	je     800414 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fd:	89 02                	mov    %eax,(%edx)
	return 0;
  8003ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800404:	5d                   	pop    %ebp
  800405:	c3                   	ret    
		return -E_INVAL;
  800406:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040b:	eb f7                	jmp    800404 <fd_lookup+0x39>
		return -E_INVAL;
  80040d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800412:	eb f0                	jmp    800404 <fd_lookup+0x39>
  800414:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800419:	eb e9                	jmp    800404 <fd_lookup+0x39>

0080041b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	53                   	push   %ebx
  80041f:	83 ec 04             	sub    $0x4,%esp
  800422:	8b 55 08             	mov    0x8(%ebp),%edx
  800425:	b8 14 1e 80 00       	mov    $0x801e14,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  80042a:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80042f:	39 13                	cmp    %edx,(%ebx)
  800431:	74 32                	je     800465 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800433:	83 c0 04             	add    $0x4,%eax
  800436:	8b 18                	mov    (%eax),%ebx
  800438:	85 db                	test   %ebx,%ebx
  80043a:	75 f3                	jne    80042f <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043c:	a1 00 40 80 00       	mov    0x804000,%eax
  800441:	8b 40 48             	mov    0x48(%eax),%eax
  800444:	83 ec 04             	sub    $0x4,%esp
  800447:	52                   	push   %edx
  800448:	50                   	push   %eax
  800449:	68 98 1d 80 00       	push   $0x801d98
  80044e:	e8 7d 0c 00 00       	call   8010d0 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800453:	83 c4 10             	add    $0x10,%esp
  800456:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  80045b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80045e:	89 1a                	mov    %ebx,(%edx)
}
  800460:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800463:	c9                   	leave  
  800464:	c3                   	ret    
			return 0;
  800465:	b8 00 00 00 00       	mov    $0x0,%eax
  80046a:	eb ef                	jmp    80045b <dev_lookup+0x40>

0080046c <fd_close>:
{
  80046c:	55                   	push   %ebp
  80046d:	89 e5                	mov    %esp,%ebp
  80046f:	57                   	push   %edi
  800470:	56                   	push   %esi
  800471:	53                   	push   %ebx
  800472:	83 ec 24             	sub    $0x24,%esp
  800475:	8b 75 08             	mov    0x8(%ebp),%esi
  800478:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80047b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80047e:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80047f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800485:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800488:	50                   	push   %eax
  800489:	e8 3d ff ff ff       	call   8003cb <fd_lookup>
  80048e:	89 c3                	mov    %eax,%ebx
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	85 c0                	test   %eax,%eax
  800495:	78 05                	js     80049c <fd_close+0x30>
	    || fd != fd2)
  800497:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80049a:	74 16                	je     8004b2 <fd_close+0x46>
		return (must_exist ? r : 0);
  80049c:	89 f8                	mov    %edi,%eax
  80049e:	84 c0                	test   %al,%al
  8004a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a5:	0f 44 d8             	cmove  %eax,%ebx
}
  8004a8:	89 d8                	mov    %ebx,%eax
  8004aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ad:	5b                   	pop    %ebx
  8004ae:	5e                   	pop    %esi
  8004af:	5f                   	pop    %edi
  8004b0:	5d                   	pop    %ebp
  8004b1:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004b8:	50                   	push   %eax
  8004b9:	ff 36                	push   (%esi)
  8004bb:	e8 5b ff ff ff       	call   80041b <dev_lookup>
  8004c0:	89 c3                	mov    %eax,%ebx
  8004c2:	83 c4 10             	add    $0x10,%esp
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	78 1a                	js     8004e3 <fd_close+0x77>
		if (dev->dev_close)
  8004c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004cc:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8004cf:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	74 0b                	je     8004e3 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8004d8:	83 ec 0c             	sub    $0xc,%esp
  8004db:	56                   	push   %esi
  8004dc:	ff d0                	call   *%eax
  8004de:	89 c3                	mov    %eax,%ebx
  8004e0:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	56                   	push   %esi
  8004e7:	6a 00                	push   $0x0
  8004e9:	e8 fa fc ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  8004ee:	83 c4 10             	add    $0x10,%esp
  8004f1:	eb b5                	jmp    8004a8 <fd_close+0x3c>

008004f3 <close>:

int
close(int fdnum)
{
  8004f3:	55                   	push   %ebp
  8004f4:	89 e5                	mov    %esp,%ebp
  8004f6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fc:	50                   	push   %eax
  8004fd:	ff 75 08             	push   0x8(%ebp)
  800500:	e8 c6 fe ff ff       	call   8003cb <fd_lookup>
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	85 c0                	test   %eax,%eax
  80050a:	79 02                	jns    80050e <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80050c:	c9                   	leave  
  80050d:	c3                   	ret    
		return fd_close(fd, 1);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	6a 01                	push   $0x1
  800513:	ff 75 f4             	push   -0xc(%ebp)
  800516:	e8 51 ff ff ff       	call   80046c <fd_close>
  80051b:	83 c4 10             	add    $0x10,%esp
  80051e:	eb ec                	jmp    80050c <close+0x19>

00800520 <close_all>:

void
close_all(void)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
  800523:	53                   	push   %ebx
  800524:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800527:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052c:	83 ec 0c             	sub    $0xc,%esp
  80052f:	53                   	push   %ebx
  800530:	e8 be ff ff ff       	call   8004f3 <close>
	for (i = 0; i < MAXFD; i++)
  800535:	83 c3 01             	add    $0x1,%ebx
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	83 fb 20             	cmp    $0x20,%ebx
  80053e:	75 ec                	jne    80052c <close_all+0xc>
}
  800540:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800543:	c9                   	leave  
  800544:	c3                   	ret    

00800545 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800545:	55                   	push   %ebp
  800546:	89 e5                	mov    %esp,%ebp
  800548:	57                   	push   %edi
  800549:	56                   	push   %esi
  80054a:	53                   	push   %ebx
  80054b:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80054e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800551:	50                   	push   %eax
  800552:	ff 75 08             	push   0x8(%ebp)
  800555:	e8 71 fe ff ff       	call   8003cb <fd_lookup>
  80055a:	89 c3                	mov    %eax,%ebx
  80055c:	83 c4 10             	add    $0x10,%esp
  80055f:	85 c0                	test   %eax,%eax
  800561:	78 7f                	js     8005e2 <dup+0x9d>
		return r;
	close(newfdnum);
  800563:	83 ec 0c             	sub    $0xc,%esp
  800566:	ff 75 0c             	push   0xc(%ebp)
  800569:	e8 85 ff ff ff       	call   8004f3 <close>

	newfd = INDEX2FD(newfdnum);
  80056e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800571:	c1 e6 0c             	shl    $0xc,%esi
  800574:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80057a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80057d:	89 3c 24             	mov    %edi,(%esp)
  800580:	e8 df fd ff ff       	call   800364 <fd2data>
  800585:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800587:	89 34 24             	mov    %esi,(%esp)
  80058a:	e8 d5 fd ff ff       	call   800364 <fd2data>
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800595:	89 d8                	mov    %ebx,%eax
  800597:	c1 e8 16             	shr    $0x16,%eax
  80059a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a1:	a8 01                	test   $0x1,%al
  8005a3:	74 11                	je     8005b6 <dup+0x71>
  8005a5:	89 d8                	mov    %ebx,%eax
  8005a7:	c1 e8 0c             	shr    $0xc,%eax
  8005aa:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b1:	f6 c2 01             	test   $0x1,%dl
  8005b4:	75 36                	jne    8005ec <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005b6:	89 f8                	mov    %edi,%eax
  8005b8:	c1 e8 0c             	shr    $0xc,%eax
  8005bb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c2:	83 ec 0c             	sub    $0xc,%esp
  8005c5:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ca:	50                   	push   %eax
  8005cb:	56                   	push   %esi
  8005cc:	6a 00                	push   $0x0
  8005ce:	57                   	push   %edi
  8005cf:	6a 00                	push   $0x0
  8005d1:	e8 d0 fb ff ff       	call   8001a6 <sys_page_map>
  8005d6:	89 c3                	mov    %eax,%ebx
  8005d8:	83 c4 20             	add    $0x20,%esp
  8005db:	85 c0                	test   %eax,%eax
  8005dd:	78 33                	js     800612 <dup+0xcd>
		goto err;

	return newfdnum;
  8005df:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005e2:	89 d8                	mov    %ebx,%eax
  8005e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005e7:	5b                   	pop    %ebx
  8005e8:	5e                   	pop    %esi
  8005e9:	5f                   	pop    %edi
  8005ea:	5d                   	pop    %ebp
  8005eb:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f3:	83 ec 0c             	sub    $0xc,%esp
  8005f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fb:	50                   	push   %eax
  8005fc:	ff 75 d4             	push   -0x2c(%ebp)
  8005ff:	6a 00                	push   $0x0
  800601:	53                   	push   %ebx
  800602:	6a 00                	push   $0x0
  800604:	e8 9d fb ff ff       	call   8001a6 <sys_page_map>
  800609:	89 c3                	mov    %eax,%ebx
  80060b:	83 c4 20             	add    $0x20,%esp
  80060e:	85 c0                	test   %eax,%eax
  800610:	79 a4                	jns    8005b6 <dup+0x71>
	sys_page_unmap(0, newfd);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	56                   	push   %esi
  800616:	6a 00                	push   $0x0
  800618:	e8 cb fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80061d:	83 c4 08             	add    $0x8,%esp
  800620:	ff 75 d4             	push   -0x2c(%ebp)
  800623:	6a 00                	push   $0x0
  800625:	e8 be fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	eb b3                	jmp    8005e2 <dup+0x9d>

0080062f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
  800632:	56                   	push   %esi
  800633:	53                   	push   %ebx
  800634:	83 ec 18             	sub    $0x18,%esp
  800637:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063d:	50                   	push   %eax
  80063e:	56                   	push   %esi
  80063f:	e8 87 fd ff ff       	call   8003cb <fd_lookup>
  800644:	83 c4 10             	add    $0x10,%esp
  800647:	85 c0                	test   %eax,%eax
  800649:	78 3c                	js     800687 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80064b:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800654:	50                   	push   %eax
  800655:	ff 33                	push   (%ebx)
  800657:	e8 bf fd ff ff       	call   80041b <dev_lookup>
  80065c:	83 c4 10             	add    $0x10,%esp
  80065f:	85 c0                	test   %eax,%eax
  800661:	78 24                	js     800687 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800663:	8b 43 08             	mov    0x8(%ebx),%eax
  800666:	83 e0 03             	and    $0x3,%eax
  800669:	83 f8 01             	cmp    $0x1,%eax
  80066c:	74 20                	je     80068e <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80066e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800671:	8b 40 08             	mov    0x8(%eax),%eax
  800674:	85 c0                	test   %eax,%eax
  800676:	74 37                	je     8006af <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800678:	83 ec 04             	sub    $0x4,%esp
  80067b:	ff 75 10             	push   0x10(%ebp)
  80067e:	ff 75 0c             	push   0xc(%ebp)
  800681:	53                   	push   %ebx
  800682:	ff d0                	call   *%eax
  800684:	83 c4 10             	add    $0x10,%esp
}
  800687:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80068a:	5b                   	pop    %ebx
  80068b:	5e                   	pop    %esi
  80068c:	5d                   	pop    %ebp
  80068d:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80068e:	a1 00 40 80 00       	mov    0x804000,%eax
  800693:	8b 40 48             	mov    0x48(%eax),%eax
  800696:	83 ec 04             	sub    $0x4,%esp
  800699:	56                   	push   %esi
  80069a:	50                   	push   %eax
  80069b:	68 d9 1d 80 00       	push   $0x801dd9
  8006a0:	e8 2b 0a 00 00       	call   8010d0 <cprintf>
		return -E_INVAL;
  8006a5:	83 c4 10             	add    $0x10,%esp
  8006a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ad:	eb d8                	jmp    800687 <read+0x58>
		return -E_NOT_SUPP;
  8006af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006b4:	eb d1                	jmp    800687 <read+0x58>

008006b6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b6:	55                   	push   %ebp
  8006b7:	89 e5                	mov    %esp,%ebp
  8006b9:	57                   	push   %edi
  8006ba:	56                   	push   %esi
  8006bb:	53                   	push   %ebx
  8006bc:	83 ec 0c             	sub    $0xc,%esp
  8006bf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ca:	eb 02                	jmp    8006ce <readn+0x18>
  8006cc:	01 c3                	add    %eax,%ebx
  8006ce:	39 f3                	cmp    %esi,%ebx
  8006d0:	73 21                	jae    8006f3 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	89 f0                	mov    %esi,%eax
  8006d7:	29 d8                	sub    %ebx,%eax
  8006d9:	50                   	push   %eax
  8006da:	89 d8                	mov    %ebx,%eax
  8006dc:	03 45 0c             	add    0xc(%ebp),%eax
  8006df:	50                   	push   %eax
  8006e0:	57                   	push   %edi
  8006e1:	e8 49 ff ff ff       	call   80062f <read>
		if (m < 0)
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	78 04                	js     8006f1 <readn+0x3b>
			return m;
		if (m == 0)
  8006ed:	75 dd                	jne    8006cc <readn+0x16>
  8006ef:	eb 02                	jmp    8006f3 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f1:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006f3:	89 d8                	mov    %ebx,%eax
  8006f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f8:	5b                   	pop    %ebx
  8006f9:	5e                   	pop    %esi
  8006fa:	5f                   	pop    %edi
  8006fb:	5d                   	pop    %ebp
  8006fc:	c3                   	ret    

008006fd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	56                   	push   %esi
  800701:	53                   	push   %ebx
  800702:	83 ec 18             	sub    $0x18,%esp
  800705:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800708:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070b:	50                   	push   %eax
  80070c:	53                   	push   %ebx
  80070d:	e8 b9 fc ff ff       	call   8003cb <fd_lookup>
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	85 c0                	test   %eax,%eax
  800717:	78 37                	js     800750 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800719:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800722:	50                   	push   %eax
  800723:	ff 36                	push   (%esi)
  800725:	e8 f1 fc ff ff       	call   80041b <dev_lookup>
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	78 1f                	js     800750 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800731:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800735:	74 20                	je     800757 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800737:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073a:	8b 40 0c             	mov    0xc(%eax),%eax
  80073d:	85 c0                	test   %eax,%eax
  80073f:	74 37                	je     800778 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800741:	83 ec 04             	sub    $0x4,%esp
  800744:	ff 75 10             	push   0x10(%ebp)
  800747:	ff 75 0c             	push   0xc(%ebp)
  80074a:	56                   	push   %esi
  80074b:	ff d0                	call   *%eax
  80074d:	83 c4 10             	add    $0x10,%esp
}
  800750:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800753:	5b                   	pop    %ebx
  800754:	5e                   	pop    %esi
  800755:	5d                   	pop    %ebp
  800756:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800757:	a1 00 40 80 00       	mov    0x804000,%eax
  80075c:	8b 40 48             	mov    0x48(%eax),%eax
  80075f:	83 ec 04             	sub    $0x4,%esp
  800762:	53                   	push   %ebx
  800763:	50                   	push   %eax
  800764:	68 f5 1d 80 00       	push   $0x801df5
  800769:	e8 62 09 00 00       	call   8010d0 <cprintf>
		return -E_INVAL;
  80076e:	83 c4 10             	add    $0x10,%esp
  800771:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800776:	eb d8                	jmp    800750 <write+0x53>
		return -E_NOT_SUPP;
  800778:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80077d:	eb d1                	jmp    800750 <write+0x53>

0080077f <seek>:

int
seek(int fdnum, off_t offset)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800785:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800788:	50                   	push   %eax
  800789:	ff 75 08             	push   0x8(%ebp)
  80078c:	e8 3a fc ff ff       	call   8003cb <fd_lookup>
  800791:	83 c4 10             	add    $0x10,%esp
  800794:	85 c0                	test   %eax,%eax
  800796:	78 0e                	js     8007a6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800798:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	56                   	push   %esi
  8007ac:	53                   	push   %ebx
  8007ad:	83 ec 18             	sub    $0x18,%esp
  8007b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b6:	50                   	push   %eax
  8007b7:	53                   	push   %ebx
  8007b8:	e8 0e fc ff ff       	call   8003cb <fd_lookup>
  8007bd:	83 c4 10             	add    $0x10,%esp
  8007c0:	85 c0                	test   %eax,%eax
  8007c2:	78 34                	js     8007f8 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c4:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8007c7:	83 ec 08             	sub    $0x8,%esp
  8007ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007cd:	50                   	push   %eax
  8007ce:	ff 36                	push   (%esi)
  8007d0:	e8 46 fc ff ff       	call   80041b <dev_lookup>
  8007d5:	83 c4 10             	add    $0x10,%esp
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	78 1c                	js     8007f8 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007dc:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8007e0:	74 1d                	je     8007ff <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e5:	8b 40 18             	mov    0x18(%eax),%eax
  8007e8:	85 c0                	test   %eax,%eax
  8007ea:	74 34                	je     800820 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007ec:	83 ec 08             	sub    $0x8,%esp
  8007ef:	ff 75 0c             	push   0xc(%ebp)
  8007f2:	56                   	push   %esi
  8007f3:	ff d0                	call   *%eax
  8007f5:	83 c4 10             	add    $0x10,%esp
}
  8007f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007fb:	5b                   	pop    %ebx
  8007fc:	5e                   	pop    %esi
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007ff:	a1 00 40 80 00       	mov    0x804000,%eax
  800804:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800807:	83 ec 04             	sub    $0x4,%esp
  80080a:	53                   	push   %ebx
  80080b:	50                   	push   %eax
  80080c:	68 b8 1d 80 00       	push   $0x801db8
  800811:	e8 ba 08 00 00       	call   8010d0 <cprintf>
		return -E_INVAL;
  800816:	83 c4 10             	add    $0x10,%esp
  800819:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081e:	eb d8                	jmp    8007f8 <ftruncate+0x50>
		return -E_NOT_SUPP;
  800820:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800825:	eb d1                	jmp    8007f8 <ftruncate+0x50>

00800827 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	56                   	push   %esi
  80082b:	53                   	push   %ebx
  80082c:	83 ec 18             	sub    $0x18,%esp
  80082f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800832:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800835:	50                   	push   %eax
  800836:	ff 75 08             	push   0x8(%ebp)
  800839:	e8 8d fb ff ff       	call   8003cb <fd_lookup>
  80083e:	83 c4 10             	add    $0x10,%esp
  800841:	85 c0                	test   %eax,%eax
  800843:	78 49                	js     80088e <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800845:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800848:	83 ec 08             	sub    $0x8,%esp
  80084b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80084e:	50                   	push   %eax
  80084f:	ff 36                	push   (%esi)
  800851:	e8 c5 fb ff ff       	call   80041b <dev_lookup>
  800856:	83 c4 10             	add    $0x10,%esp
  800859:	85 c0                	test   %eax,%eax
  80085b:	78 31                	js     80088e <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80085d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800860:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800864:	74 2f                	je     800895 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800866:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800869:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800870:	00 00 00 
	stat->st_isdir = 0;
  800873:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80087a:	00 00 00 
	stat->st_dev = dev;
  80087d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800883:	83 ec 08             	sub    $0x8,%esp
  800886:	53                   	push   %ebx
  800887:	56                   	push   %esi
  800888:	ff 50 14             	call   *0x14(%eax)
  80088b:	83 c4 10             	add    $0x10,%esp
}
  80088e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800891:	5b                   	pop    %ebx
  800892:	5e                   	pop    %esi
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    
		return -E_NOT_SUPP;
  800895:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80089a:	eb f2                	jmp    80088e <fstat+0x67>

0080089c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	56                   	push   %esi
  8008a0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008a1:	83 ec 08             	sub    $0x8,%esp
  8008a4:	6a 00                	push   $0x0
  8008a6:	ff 75 08             	push   0x8(%ebp)
  8008a9:	e8 e4 01 00 00       	call   800a92 <open>
  8008ae:	89 c3                	mov    %eax,%ebx
  8008b0:	83 c4 10             	add    $0x10,%esp
  8008b3:	85 c0                	test   %eax,%eax
  8008b5:	78 1b                	js     8008d2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008b7:	83 ec 08             	sub    $0x8,%esp
  8008ba:	ff 75 0c             	push   0xc(%ebp)
  8008bd:	50                   	push   %eax
  8008be:	e8 64 ff ff ff       	call   800827 <fstat>
  8008c3:	89 c6                	mov    %eax,%esi
	close(fd);
  8008c5:	89 1c 24             	mov    %ebx,(%esp)
  8008c8:	e8 26 fc ff ff       	call   8004f3 <close>
	return r;
  8008cd:	83 c4 10             	add    $0x10,%esp
  8008d0:	89 f3                	mov    %esi,%ebx
}
  8008d2:	89 d8                	mov    %ebx,%eax
  8008d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008d7:	5b                   	pop    %ebx
  8008d8:	5e                   	pop    %esi
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
  8008e0:	89 c6                	mov    %eax,%esi
  8008e2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008e4:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8008eb:	74 27                	je     800914 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008ed:	6a 07                	push   $0x7
  8008ef:	68 00 50 80 00       	push   $0x805000
  8008f4:	56                   	push   %esi
  8008f5:	ff 35 00 60 80 00    	push   0x806000
  8008fb:	e8 51 11 00 00       	call   801a51 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800900:	83 c4 0c             	add    $0xc,%esp
  800903:	6a 00                	push   $0x0
  800905:	53                   	push   %ebx
  800906:	6a 00                	push   $0x0
  800908:	e8 dd 10 00 00       	call   8019ea <ipc_recv>
}
  80090d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800910:	5b                   	pop    %ebx
  800911:	5e                   	pop    %esi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800914:	83 ec 0c             	sub    $0xc,%esp
  800917:	6a 01                	push   $0x1
  800919:	e8 87 11 00 00       	call   801aa5 <ipc_find_env>
  80091e:	a3 00 60 80 00       	mov    %eax,0x806000
  800923:	83 c4 10             	add    $0x10,%esp
  800926:	eb c5                	jmp    8008ed <fsipc+0x12>

00800928 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8b 40 0c             	mov    0xc(%eax),%eax
  800934:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800939:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800941:	ba 00 00 00 00       	mov    $0x0,%edx
  800946:	b8 02 00 00 00       	mov    $0x2,%eax
  80094b:	e8 8b ff ff ff       	call   8008db <fsipc>
}
  800950:	c9                   	leave  
  800951:	c3                   	ret    

00800952 <devfile_flush>:
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	8b 40 0c             	mov    0xc(%eax),%eax
  80095e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800963:	ba 00 00 00 00       	mov    $0x0,%edx
  800968:	b8 06 00 00 00       	mov    $0x6,%eax
  80096d:	e8 69 ff ff ff       	call   8008db <fsipc>
}
  800972:	c9                   	leave  
  800973:	c3                   	ret    

00800974 <devfile_stat>:
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	53                   	push   %ebx
  800978:	83 ec 04             	sub    $0x4,%esp
  80097b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 40 0c             	mov    0xc(%eax),%eax
  800984:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
  80098e:	b8 05 00 00 00       	mov    $0x5,%eax
  800993:	e8 43 ff ff ff       	call   8008db <fsipc>
  800998:	85 c0                	test   %eax,%eax
  80099a:	78 2c                	js     8009c8 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80099c:	83 ec 08             	sub    $0x8,%esp
  80099f:	68 00 50 80 00       	push   $0x805000
  8009a4:	53                   	push   %ebx
  8009a5:	e8 00 0d 00 00       	call   8016aa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009aa:	a1 80 50 80 00       	mov    0x805080,%eax
  8009af:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b5:	a1 84 50 80 00       	mov    0x805084,%eax
  8009ba:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009c0:	83 c4 10             	add    $0x10,%esp
  8009c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <devfile_write>:
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	83 ec 0c             	sub    $0xc,%esp
  8009d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8009d6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009db:	39 d0                	cmp    %edx,%eax
  8009dd:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e3:	8b 52 0c             	mov    0xc(%edx),%edx
  8009e6:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009ec:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8009f1:	50                   	push   %eax
  8009f2:	ff 75 0c             	push   0xc(%ebp)
  8009f5:	68 08 50 80 00       	push   $0x805008
  8009fa:	e8 41 0e 00 00       	call   801840 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8009ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800a04:	b8 04 00 00 00       	mov    $0x4,%eax
  800a09:	e8 cd fe ff ff       	call   8008db <fsipc>
}
  800a0e:	c9                   	leave  
  800a0f:	c3                   	ret    

00800a10 <devfile_read>:
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a23:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a29:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2e:	b8 03 00 00 00       	mov    $0x3,%eax
  800a33:	e8 a3 fe ff ff       	call   8008db <fsipc>
  800a38:	89 c3                	mov    %eax,%ebx
  800a3a:	85 c0                	test   %eax,%eax
  800a3c:	78 1f                	js     800a5d <devfile_read+0x4d>
	assert(r <= n);
  800a3e:	39 f0                	cmp    %esi,%eax
  800a40:	77 24                	ja     800a66 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a42:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a47:	7f 33                	jg     800a7c <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a49:	83 ec 04             	sub    $0x4,%esp
  800a4c:	50                   	push   %eax
  800a4d:	68 00 50 80 00       	push   $0x805000
  800a52:	ff 75 0c             	push   0xc(%ebp)
  800a55:	e8 e6 0d 00 00       	call   801840 <memmove>
	return r;
  800a5a:	83 c4 10             	add    $0x10,%esp
}
  800a5d:	89 d8                	mov    %ebx,%eax
  800a5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    
	assert(r <= n);
  800a66:	68 24 1e 80 00       	push   $0x801e24
  800a6b:	68 2b 1e 80 00       	push   $0x801e2b
  800a70:	6a 7c                	push   $0x7c
  800a72:	68 40 1e 80 00       	push   $0x801e40
  800a77:	e8 79 05 00 00       	call   800ff5 <_panic>
	assert(r <= PGSIZE);
  800a7c:	68 4b 1e 80 00       	push   $0x801e4b
  800a81:	68 2b 1e 80 00       	push   $0x801e2b
  800a86:	6a 7d                	push   $0x7d
  800a88:	68 40 1e 80 00       	push   $0x801e40
  800a8d:	e8 63 05 00 00       	call   800ff5 <_panic>

00800a92 <open>:
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	56                   	push   %esi
  800a96:	53                   	push   %ebx
  800a97:	83 ec 1c             	sub    $0x1c,%esp
  800a9a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800a9d:	56                   	push   %esi
  800a9e:	e8 cc 0b 00 00       	call   80166f <strlen>
  800aa3:	83 c4 10             	add    $0x10,%esp
  800aa6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aab:	7f 6c                	jg     800b19 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800aad:	83 ec 0c             	sub    $0xc,%esp
  800ab0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab3:	50                   	push   %eax
  800ab4:	e8 c2 f8 ff ff       	call   80037b <fd_alloc>
  800ab9:	89 c3                	mov    %eax,%ebx
  800abb:	83 c4 10             	add    $0x10,%esp
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	78 3c                	js     800afe <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800ac2:	83 ec 08             	sub    $0x8,%esp
  800ac5:	56                   	push   %esi
  800ac6:	68 00 50 80 00       	push   $0x805000
  800acb:	e8 da 0b 00 00       	call   8016aa <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ad8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800adb:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae0:	e8 f6 fd ff ff       	call   8008db <fsipc>
  800ae5:	89 c3                	mov    %eax,%ebx
  800ae7:	83 c4 10             	add    $0x10,%esp
  800aea:	85 c0                	test   %eax,%eax
  800aec:	78 19                	js     800b07 <open+0x75>
	return fd2num(fd);
  800aee:	83 ec 0c             	sub    $0xc,%esp
  800af1:	ff 75 f4             	push   -0xc(%ebp)
  800af4:	e8 5b f8 ff ff       	call   800354 <fd2num>
  800af9:	89 c3                	mov    %eax,%ebx
  800afb:	83 c4 10             	add    $0x10,%esp
}
  800afe:	89 d8                	mov    %ebx,%eax
  800b00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    
		fd_close(fd, 0);
  800b07:	83 ec 08             	sub    $0x8,%esp
  800b0a:	6a 00                	push   $0x0
  800b0c:	ff 75 f4             	push   -0xc(%ebp)
  800b0f:	e8 58 f9 ff ff       	call   80046c <fd_close>
		return r;
  800b14:	83 c4 10             	add    $0x10,%esp
  800b17:	eb e5                	jmp    800afe <open+0x6c>
		return -E_BAD_PATH;
  800b19:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b1e:	eb de                	jmp    800afe <open+0x6c>

00800b20 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b26:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2b:	b8 08 00 00 00       	mov    $0x8,%eax
  800b30:	e8 a6 fd ff ff       	call   8008db <fsipc>
}
  800b35:	c9                   	leave  
  800b36:	c3                   	ret    

00800b37 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
  800b3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b3f:	83 ec 0c             	sub    $0xc,%esp
  800b42:	ff 75 08             	push   0x8(%ebp)
  800b45:	e8 1a f8 ff ff       	call   800364 <fd2data>
  800b4a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b4c:	83 c4 08             	add    $0x8,%esp
  800b4f:	68 57 1e 80 00       	push   $0x801e57
  800b54:	53                   	push   %ebx
  800b55:	e8 50 0b 00 00       	call   8016aa <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b5a:	8b 46 04             	mov    0x4(%esi),%eax
  800b5d:	2b 06                	sub    (%esi),%eax
  800b5f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b65:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b6c:	00 00 00 
	stat->st_dev = &devpipe;
  800b6f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b76:	30 80 00 
	return 0;
}
  800b79:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	53                   	push   %ebx
  800b89:	83 ec 0c             	sub    $0xc,%esp
  800b8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b8f:	53                   	push   %ebx
  800b90:	6a 00                	push   $0x0
  800b92:	e8 51 f6 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b97:	89 1c 24             	mov    %ebx,(%esp)
  800b9a:	e8 c5 f7 ff ff       	call   800364 <fd2data>
  800b9f:	83 c4 08             	add    $0x8,%esp
  800ba2:	50                   	push   %eax
  800ba3:	6a 00                	push   $0x0
  800ba5:	e8 3e f6 ff ff       	call   8001e8 <sys_page_unmap>
}
  800baa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bad:	c9                   	leave  
  800bae:	c3                   	ret    

00800baf <_pipeisclosed>:
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
  800bb5:	83 ec 1c             	sub    $0x1c,%esp
  800bb8:	89 c7                	mov    %eax,%edi
  800bba:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bbc:	a1 00 40 80 00       	mov    0x804000,%eax
  800bc1:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bc4:	83 ec 0c             	sub    $0xc,%esp
  800bc7:	57                   	push   %edi
  800bc8:	e8 11 0f 00 00       	call   801ade <pageref>
  800bcd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bd0:	89 34 24             	mov    %esi,(%esp)
  800bd3:	e8 06 0f 00 00       	call   801ade <pageref>
		nn = thisenv->env_runs;
  800bd8:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800bde:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800be1:	83 c4 10             	add    $0x10,%esp
  800be4:	39 cb                	cmp    %ecx,%ebx
  800be6:	74 1b                	je     800c03 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800be8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800beb:	75 cf                	jne    800bbc <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bed:	8b 42 58             	mov    0x58(%edx),%eax
  800bf0:	6a 01                	push   $0x1
  800bf2:	50                   	push   %eax
  800bf3:	53                   	push   %ebx
  800bf4:	68 5e 1e 80 00       	push   $0x801e5e
  800bf9:	e8 d2 04 00 00       	call   8010d0 <cprintf>
  800bfe:	83 c4 10             	add    $0x10,%esp
  800c01:	eb b9                	jmp    800bbc <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c03:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c06:	0f 94 c0             	sete   %al
  800c09:	0f b6 c0             	movzbl %al,%eax
}
  800c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <devpipe_write>:
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 28             	sub    $0x28,%esp
  800c1d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c20:	56                   	push   %esi
  800c21:	e8 3e f7 ff ff       	call   800364 <fd2data>
  800c26:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c28:	83 c4 10             	add    $0x10,%esp
  800c2b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c30:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c33:	75 09                	jne    800c3e <devpipe_write+0x2a>
	return i;
  800c35:	89 f8                	mov    %edi,%eax
  800c37:	eb 23                	jmp    800c5c <devpipe_write+0x48>
			sys_yield();
  800c39:	e8 06 f5 ff ff       	call   800144 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c3e:	8b 43 04             	mov    0x4(%ebx),%eax
  800c41:	8b 0b                	mov    (%ebx),%ecx
  800c43:	8d 51 20             	lea    0x20(%ecx),%edx
  800c46:	39 d0                	cmp    %edx,%eax
  800c48:	72 1a                	jb     800c64 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  800c4a:	89 da                	mov    %ebx,%edx
  800c4c:	89 f0                	mov    %esi,%eax
  800c4e:	e8 5c ff ff ff       	call   800baf <_pipeisclosed>
  800c53:	85 c0                	test   %eax,%eax
  800c55:	74 e2                	je     800c39 <devpipe_write+0x25>
				return 0;
  800c57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c6b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c6e:	89 c2                	mov    %eax,%edx
  800c70:	c1 fa 1f             	sar    $0x1f,%edx
  800c73:	89 d1                	mov    %edx,%ecx
  800c75:	c1 e9 1b             	shr    $0x1b,%ecx
  800c78:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c7b:	83 e2 1f             	and    $0x1f,%edx
  800c7e:	29 ca                	sub    %ecx,%edx
  800c80:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c84:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c88:	83 c0 01             	add    $0x1,%eax
  800c8b:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c8e:	83 c7 01             	add    $0x1,%edi
  800c91:	eb 9d                	jmp    800c30 <devpipe_write+0x1c>

00800c93 <devpipe_read>:
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 18             	sub    $0x18,%esp
  800c9c:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800c9f:	57                   	push   %edi
  800ca0:	e8 bf f6 ff ff       	call   800364 <fd2data>
  800ca5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800ca7:	83 c4 10             	add    $0x10,%esp
  800caa:	be 00 00 00 00       	mov    $0x0,%esi
  800caf:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cb2:	75 13                	jne    800cc7 <devpipe_read+0x34>
	return i;
  800cb4:	89 f0                	mov    %esi,%eax
  800cb6:	eb 02                	jmp    800cba <devpipe_read+0x27>
				return i;
  800cb8:	89 f0                	mov    %esi,%eax
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    
			sys_yield();
  800cc2:	e8 7d f4 ff ff       	call   800144 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800cc7:	8b 03                	mov    (%ebx),%eax
  800cc9:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ccc:	75 18                	jne    800ce6 <devpipe_read+0x53>
			if (i > 0)
  800cce:	85 f6                	test   %esi,%esi
  800cd0:	75 e6                	jne    800cb8 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  800cd2:	89 da                	mov    %ebx,%edx
  800cd4:	89 f8                	mov    %edi,%eax
  800cd6:	e8 d4 fe ff ff       	call   800baf <_pipeisclosed>
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	74 e3                	je     800cc2 <devpipe_read+0x2f>
				return 0;
  800cdf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce4:	eb d4                	jmp    800cba <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800ce6:	99                   	cltd   
  800ce7:	c1 ea 1b             	shr    $0x1b,%edx
  800cea:	01 d0                	add    %edx,%eax
  800cec:	83 e0 1f             	and    $0x1f,%eax
  800cef:	29 d0                	sub    %edx,%eax
  800cf1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800cfc:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800cff:	83 c6 01             	add    $0x1,%esi
  800d02:	eb ab                	jmp    800caf <devpipe_read+0x1c>

00800d04 <pipe>:
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d0f:	50                   	push   %eax
  800d10:	e8 66 f6 ff ff       	call   80037b <fd_alloc>
  800d15:	89 c3                	mov    %eax,%ebx
  800d17:	83 c4 10             	add    $0x10,%esp
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	0f 88 23 01 00 00    	js     800e45 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d22:	83 ec 04             	sub    $0x4,%esp
  800d25:	68 07 04 00 00       	push   $0x407
  800d2a:	ff 75 f4             	push   -0xc(%ebp)
  800d2d:	6a 00                	push   $0x0
  800d2f:	e8 2f f4 ff ff       	call   800163 <sys_page_alloc>
  800d34:	89 c3                	mov    %eax,%ebx
  800d36:	83 c4 10             	add    $0x10,%esp
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	0f 88 04 01 00 00    	js     800e45 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  800d41:	83 ec 0c             	sub    $0xc,%esp
  800d44:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d47:	50                   	push   %eax
  800d48:	e8 2e f6 ff ff       	call   80037b <fd_alloc>
  800d4d:	89 c3                	mov    %eax,%ebx
  800d4f:	83 c4 10             	add    $0x10,%esp
  800d52:	85 c0                	test   %eax,%eax
  800d54:	0f 88 db 00 00 00    	js     800e35 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d5a:	83 ec 04             	sub    $0x4,%esp
  800d5d:	68 07 04 00 00       	push   $0x407
  800d62:	ff 75 f0             	push   -0x10(%ebp)
  800d65:	6a 00                	push   $0x0
  800d67:	e8 f7 f3 ff ff       	call   800163 <sys_page_alloc>
  800d6c:	89 c3                	mov    %eax,%ebx
  800d6e:	83 c4 10             	add    $0x10,%esp
  800d71:	85 c0                	test   %eax,%eax
  800d73:	0f 88 bc 00 00 00    	js     800e35 <pipe+0x131>
	va = fd2data(fd0);
  800d79:	83 ec 0c             	sub    $0xc,%esp
  800d7c:	ff 75 f4             	push   -0xc(%ebp)
  800d7f:	e8 e0 f5 ff ff       	call   800364 <fd2data>
  800d84:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d86:	83 c4 0c             	add    $0xc,%esp
  800d89:	68 07 04 00 00       	push   $0x407
  800d8e:	50                   	push   %eax
  800d8f:	6a 00                	push   $0x0
  800d91:	e8 cd f3 ff ff       	call   800163 <sys_page_alloc>
  800d96:	89 c3                	mov    %eax,%ebx
  800d98:	83 c4 10             	add    $0x10,%esp
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	0f 88 82 00 00 00    	js     800e25 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da3:	83 ec 0c             	sub    $0xc,%esp
  800da6:	ff 75 f0             	push   -0x10(%ebp)
  800da9:	e8 b6 f5 ff ff       	call   800364 <fd2data>
  800dae:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800db5:	50                   	push   %eax
  800db6:	6a 00                	push   $0x0
  800db8:	56                   	push   %esi
  800db9:	6a 00                	push   $0x0
  800dbb:	e8 e6 f3 ff ff       	call   8001a6 <sys_page_map>
  800dc0:	89 c3                	mov    %eax,%ebx
  800dc2:	83 c4 20             	add    $0x20,%esp
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	78 4e                	js     800e17 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  800dc9:	a1 20 30 80 00       	mov    0x803020,%eax
  800dce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dd1:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800dd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dd6:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800ddd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800de0:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800de2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800dec:	83 ec 0c             	sub    $0xc,%esp
  800def:	ff 75 f4             	push   -0xc(%ebp)
  800df2:	e8 5d f5 ff ff       	call   800354 <fd2num>
  800df7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfa:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800dfc:	83 c4 04             	add    $0x4,%esp
  800dff:	ff 75 f0             	push   -0x10(%ebp)
  800e02:	e8 4d f5 ff ff       	call   800354 <fd2num>
  800e07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e0d:	83 c4 10             	add    $0x10,%esp
  800e10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e15:	eb 2e                	jmp    800e45 <pipe+0x141>
	sys_page_unmap(0, va);
  800e17:	83 ec 08             	sub    $0x8,%esp
  800e1a:	56                   	push   %esi
  800e1b:	6a 00                	push   $0x0
  800e1d:	e8 c6 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e22:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e25:	83 ec 08             	sub    $0x8,%esp
  800e28:	ff 75 f0             	push   -0x10(%ebp)
  800e2b:	6a 00                	push   $0x0
  800e2d:	e8 b6 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e32:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e35:	83 ec 08             	sub    $0x8,%esp
  800e38:	ff 75 f4             	push   -0xc(%ebp)
  800e3b:	6a 00                	push   $0x0
  800e3d:	e8 a6 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e42:	83 c4 10             	add    $0x10,%esp
}
  800e45:	89 d8                	mov    %ebx,%eax
  800e47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e4a:	5b                   	pop    %ebx
  800e4b:	5e                   	pop    %esi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <pipeisclosed>:
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e57:	50                   	push   %eax
  800e58:	ff 75 08             	push   0x8(%ebp)
  800e5b:	e8 6b f5 ff ff       	call   8003cb <fd_lookup>
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	85 c0                	test   %eax,%eax
  800e65:	78 18                	js     800e7f <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e67:	83 ec 0c             	sub    $0xc,%esp
  800e6a:	ff 75 f4             	push   -0xc(%ebp)
  800e6d:	e8 f2 f4 ff ff       	call   800364 <fd2data>
  800e72:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e77:	e8 33 fd ff ff       	call   800baf <_pipeisclosed>
  800e7c:	83 c4 10             	add    $0x10,%esp
}
  800e7f:	c9                   	leave  
  800e80:	c3                   	ret    

00800e81 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  800e81:	b8 00 00 00 00       	mov    $0x0,%eax
  800e86:	c3                   	ret    

00800e87 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e8d:	68 76 1e 80 00       	push   $0x801e76
  800e92:	ff 75 0c             	push   0xc(%ebp)
  800e95:	e8 10 08 00 00       	call   8016aa <strcpy>
	return 0;
}
  800e9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9f:	c9                   	leave  
  800ea0:	c3                   	ret    

00800ea1 <devcons_write>:
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	57                   	push   %edi
  800ea5:	56                   	push   %esi
  800ea6:	53                   	push   %ebx
  800ea7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ead:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800eb2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800eb8:	eb 2e                	jmp    800ee8 <devcons_write+0x47>
		m = n - tot;
  800eba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebd:	29 f3                	sub    %esi,%ebx
  800ebf:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800ec4:	39 c3                	cmp    %eax,%ebx
  800ec6:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ec9:	83 ec 04             	sub    $0x4,%esp
  800ecc:	53                   	push   %ebx
  800ecd:	89 f0                	mov    %esi,%eax
  800ecf:	03 45 0c             	add    0xc(%ebp),%eax
  800ed2:	50                   	push   %eax
  800ed3:	57                   	push   %edi
  800ed4:	e8 67 09 00 00       	call   801840 <memmove>
		sys_cputs(buf, m);
  800ed9:	83 c4 08             	add    $0x8,%esp
  800edc:	53                   	push   %ebx
  800edd:	57                   	push   %edi
  800ede:	e8 c4 f1 ff ff       	call   8000a7 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800ee3:	01 de                	add    %ebx,%esi
  800ee5:	83 c4 10             	add    $0x10,%esp
  800ee8:	3b 75 10             	cmp    0x10(%ebp),%esi
  800eeb:	72 cd                	jb     800eba <devcons_write+0x19>
}
  800eed:	89 f0                	mov    %esi,%eax
  800eef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef2:	5b                   	pop    %ebx
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <devcons_read>:
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	83 ec 08             	sub    $0x8,%esp
  800efd:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f02:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f06:	75 07                	jne    800f0f <devcons_read+0x18>
  800f08:	eb 1f                	jmp    800f29 <devcons_read+0x32>
		sys_yield();
  800f0a:	e8 35 f2 ff ff       	call   800144 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f0f:	e8 b1 f1 ff ff       	call   8000c5 <sys_cgetc>
  800f14:	85 c0                	test   %eax,%eax
  800f16:	74 f2                	je     800f0a <devcons_read+0x13>
	if (c < 0)
  800f18:	78 0f                	js     800f29 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  800f1a:	83 f8 04             	cmp    $0x4,%eax
  800f1d:	74 0c                	je     800f2b <devcons_read+0x34>
	*(char*)vbuf = c;
  800f1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f22:	88 02                	mov    %al,(%edx)
	return 1;
  800f24:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f29:	c9                   	leave  
  800f2a:	c3                   	ret    
		return 0;
  800f2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f30:	eb f7                	jmp    800f29 <devcons_read+0x32>

00800f32 <cputchar>:
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f38:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3b:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f3e:	6a 01                	push   $0x1
  800f40:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f43:	50                   	push   %eax
  800f44:	e8 5e f1 ff ff       	call   8000a7 <sys_cputs>
}
  800f49:	83 c4 10             	add    $0x10,%esp
  800f4c:	c9                   	leave  
  800f4d:	c3                   	ret    

00800f4e <getchar>:
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f54:	6a 01                	push   $0x1
  800f56:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f59:	50                   	push   %eax
  800f5a:	6a 00                	push   $0x0
  800f5c:	e8 ce f6 ff ff       	call   80062f <read>
	if (r < 0)
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	85 c0                	test   %eax,%eax
  800f66:	78 06                	js     800f6e <getchar+0x20>
	if (r < 1)
  800f68:	74 06                	je     800f70 <getchar+0x22>
	return c;
  800f6a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f6e:	c9                   	leave  
  800f6f:	c3                   	ret    
		return -E_EOF;
  800f70:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800f75:	eb f7                	jmp    800f6e <getchar+0x20>

00800f77 <iscons>:
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f80:	50                   	push   %eax
  800f81:	ff 75 08             	push   0x8(%ebp)
  800f84:	e8 42 f4 ff ff       	call   8003cb <fd_lookup>
  800f89:	83 c4 10             	add    $0x10,%esp
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	78 11                	js     800fa1 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800f90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f93:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f99:	39 10                	cmp    %edx,(%eax)
  800f9b:	0f 94 c0             	sete   %al
  800f9e:	0f b6 c0             	movzbl %al,%eax
}
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    

00800fa3 <opencons>:
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fa9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fac:	50                   	push   %eax
  800fad:	e8 c9 f3 ff ff       	call   80037b <fd_alloc>
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	78 3a                	js     800ff3 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fb9:	83 ec 04             	sub    $0x4,%esp
  800fbc:	68 07 04 00 00       	push   $0x407
  800fc1:	ff 75 f4             	push   -0xc(%ebp)
  800fc4:	6a 00                	push   $0x0
  800fc6:	e8 98 f1 ff ff       	call   800163 <sys_page_alloc>
  800fcb:	83 c4 10             	add    $0x10,%esp
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	78 21                	js     800ff3 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fdb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fe7:	83 ec 0c             	sub    $0xc,%esp
  800fea:	50                   	push   %eax
  800feb:	e8 64 f3 ff ff       	call   800354 <fd2num>
  800ff0:	83 c4 10             	add    $0x10,%esp
}
  800ff3:	c9                   	leave  
  800ff4:	c3                   	ret    

00800ff5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	56                   	push   %esi
  800ff9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ffa:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ffd:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801003:	e8 1d f1 ff ff       	call   800125 <sys_getenvid>
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	ff 75 0c             	push   0xc(%ebp)
  80100e:	ff 75 08             	push   0x8(%ebp)
  801011:	56                   	push   %esi
  801012:	50                   	push   %eax
  801013:	68 84 1e 80 00       	push   $0x801e84
  801018:	e8 b3 00 00 00       	call   8010d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80101d:	83 c4 18             	add    $0x18,%esp
  801020:	53                   	push   %ebx
  801021:	ff 75 10             	push   0x10(%ebp)
  801024:	e8 56 00 00 00       	call   80107f <vcprintf>
	cprintf("\n");
  801029:	c7 04 24 6f 1e 80 00 	movl   $0x801e6f,(%esp)
  801030:	e8 9b 00 00 00       	call   8010d0 <cprintf>
  801035:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801038:	cc                   	int3   
  801039:	eb fd                	jmp    801038 <_panic+0x43>

0080103b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	53                   	push   %ebx
  80103f:	83 ec 04             	sub    $0x4,%esp
  801042:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801045:	8b 13                	mov    (%ebx),%edx
  801047:	8d 42 01             	lea    0x1(%edx),%eax
  80104a:	89 03                	mov    %eax,(%ebx)
  80104c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80104f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801053:	3d ff 00 00 00       	cmp    $0xff,%eax
  801058:	74 09                	je     801063 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80105a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80105e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801061:	c9                   	leave  
  801062:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801063:	83 ec 08             	sub    $0x8,%esp
  801066:	68 ff 00 00 00       	push   $0xff
  80106b:	8d 43 08             	lea    0x8(%ebx),%eax
  80106e:	50                   	push   %eax
  80106f:	e8 33 f0 ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  801074:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80107a:	83 c4 10             	add    $0x10,%esp
  80107d:	eb db                	jmp    80105a <putch+0x1f>

0080107f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801088:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80108f:	00 00 00 
	b.cnt = 0;
  801092:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801099:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80109c:	ff 75 0c             	push   0xc(%ebp)
  80109f:	ff 75 08             	push   0x8(%ebp)
  8010a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010a8:	50                   	push   %eax
  8010a9:	68 3b 10 80 00       	push   $0x80103b
  8010ae:	e8 14 01 00 00       	call   8011c7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010b3:	83 c4 08             	add    $0x8,%esp
  8010b6:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8010bc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010c2:	50                   	push   %eax
  8010c3:	e8 df ef ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  8010c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010ce:	c9                   	leave  
  8010cf:	c3                   	ret    

008010d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010d9:	50                   	push   %eax
  8010da:	ff 75 08             	push   0x8(%ebp)
  8010dd:	e8 9d ff ff ff       	call   80107f <vcprintf>
	va_end(ap);

	return cnt;
}
  8010e2:	c9                   	leave  
  8010e3:	c3                   	ret    

008010e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	57                   	push   %edi
  8010e8:	56                   	push   %esi
  8010e9:	53                   	push   %ebx
  8010ea:	83 ec 1c             	sub    $0x1c,%esp
  8010ed:	89 c7                	mov    %eax,%edi
  8010ef:	89 d6                	mov    %edx,%esi
  8010f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f7:	89 d1                	mov    %edx,%ecx
  8010f9:	89 c2                	mov    %eax,%edx
  8010fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010fe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801101:	8b 45 10             	mov    0x10(%ebp),%eax
  801104:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801107:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80110a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801111:	39 c2                	cmp    %eax,%edx
  801113:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801116:	72 3e                	jb     801156 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801118:	83 ec 0c             	sub    $0xc,%esp
  80111b:	ff 75 18             	push   0x18(%ebp)
  80111e:	83 eb 01             	sub    $0x1,%ebx
  801121:	53                   	push   %ebx
  801122:	50                   	push   %eax
  801123:	83 ec 08             	sub    $0x8,%esp
  801126:	ff 75 e4             	push   -0x1c(%ebp)
  801129:	ff 75 e0             	push   -0x20(%ebp)
  80112c:	ff 75 dc             	push   -0x24(%ebp)
  80112f:	ff 75 d8             	push   -0x28(%ebp)
  801132:	e8 e9 09 00 00       	call   801b20 <__udivdi3>
  801137:	83 c4 18             	add    $0x18,%esp
  80113a:	52                   	push   %edx
  80113b:	50                   	push   %eax
  80113c:	89 f2                	mov    %esi,%edx
  80113e:	89 f8                	mov    %edi,%eax
  801140:	e8 9f ff ff ff       	call   8010e4 <printnum>
  801145:	83 c4 20             	add    $0x20,%esp
  801148:	eb 13                	jmp    80115d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80114a:	83 ec 08             	sub    $0x8,%esp
  80114d:	56                   	push   %esi
  80114e:	ff 75 18             	push   0x18(%ebp)
  801151:	ff d7                	call   *%edi
  801153:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801156:	83 eb 01             	sub    $0x1,%ebx
  801159:	85 db                	test   %ebx,%ebx
  80115b:	7f ed                	jg     80114a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80115d:	83 ec 08             	sub    $0x8,%esp
  801160:	56                   	push   %esi
  801161:	83 ec 04             	sub    $0x4,%esp
  801164:	ff 75 e4             	push   -0x1c(%ebp)
  801167:	ff 75 e0             	push   -0x20(%ebp)
  80116a:	ff 75 dc             	push   -0x24(%ebp)
  80116d:	ff 75 d8             	push   -0x28(%ebp)
  801170:	e8 cb 0a 00 00       	call   801c40 <__umoddi3>
  801175:	83 c4 14             	add    $0x14,%esp
  801178:	0f be 80 a7 1e 80 00 	movsbl 0x801ea7(%eax),%eax
  80117f:	50                   	push   %eax
  801180:	ff d7                	call   *%edi
}
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801188:	5b                   	pop    %ebx
  801189:	5e                   	pop    %esi
  80118a:	5f                   	pop    %edi
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    

0080118d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
  801190:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801193:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801197:	8b 10                	mov    (%eax),%edx
  801199:	3b 50 04             	cmp    0x4(%eax),%edx
  80119c:	73 0a                	jae    8011a8 <sprintputch+0x1b>
		*b->buf++ = ch;
  80119e:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011a1:	89 08                	mov    %ecx,(%eax)
  8011a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a6:	88 02                	mov    %al,(%edx)
}
  8011a8:	5d                   	pop    %ebp
  8011a9:	c3                   	ret    

008011aa <printfmt>:
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011b3:	50                   	push   %eax
  8011b4:	ff 75 10             	push   0x10(%ebp)
  8011b7:	ff 75 0c             	push   0xc(%ebp)
  8011ba:	ff 75 08             	push   0x8(%ebp)
  8011bd:	e8 05 00 00 00       	call   8011c7 <vprintfmt>
}
  8011c2:	83 c4 10             	add    $0x10,%esp
  8011c5:	c9                   	leave  
  8011c6:	c3                   	ret    

008011c7 <vprintfmt>:
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	57                   	push   %edi
  8011cb:	56                   	push   %esi
  8011cc:	53                   	push   %ebx
  8011cd:	83 ec 3c             	sub    $0x3c,%esp
  8011d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011d6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011d9:	eb 0a                	jmp    8011e5 <vprintfmt+0x1e>
			putch(ch, putdat);
  8011db:	83 ec 08             	sub    $0x8,%esp
  8011de:	53                   	push   %ebx
  8011df:	50                   	push   %eax
  8011e0:	ff d6                	call   *%esi
  8011e2:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8011e5:	83 c7 01             	add    $0x1,%edi
  8011e8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8011ec:	83 f8 25             	cmp    $0x25,%eax
  8011ef:	74 0c                	je     8011fd <vprintfmt+0x36>
			if (ch == '\0')
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	75 e6                	jne    8011db <vprintfmt+0x14>
}
  8011f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f8:	5b                   	pop    %ebx
  8011f9:	5e                   	pop    %esi
  8011fa:	5f                   	pop    %edi
  8011fb:	5d                   	pop    %ebp
  8011fc:	c3                   	ret    
		padc = ' ';
  8011fd:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801201:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801208:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80120f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801216:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80121b:	8d 47 01             	lea    0x1(%edi),%eax
  80121e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801221:	0f b6 17             	movzbl (%edi),%edx
  801224:	8d 42 dd             	lea    -0x23(%edx),%eax
  801227:	3c 55                	cmp    $0x55,%al
  801229:	0f 87 bb 03 00 00    	ja     8015ea <vprintfmt+0x423>
  80122f:	0f b6 c0             	movzbl %al,%eax
  801232:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  801239:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80123c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801240:	eb d9                	jmp    80121b <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801242:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801245:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801249:	eb d0                	jmp    80121b <vprintfmt+0x54>
  80124b:	0f b6 d2             	movzbl %dl,%edx
  80124e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801251:	b8 00 00 00 00       	mov    $0x0,%eax
  801256:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801259:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80125c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801260:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801263:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801266:	83 f9 09             	cmp    $0x9,%ecx
  801269:	77 55                	ja     8012c0 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80126b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80126e:	eb e9                	jmp    801259 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801270:	8b 45 14             	mov    0x14(%ebp),%eax
  801273:	8b 00                	mov    (%eax),%eax
  801275:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801278:	8b 45 14             	mov    0x14(%ebp),%eax
  80127b:	8d 40 04             	lea    0x4(%eax),%eax
  80127e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801281:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801284:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801288:	79 91                	jns    80121b <vprintfmt+0x54>
				width = precision, precision = -1;
  80128a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80128d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801290:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801297:	eb 82                	jmp    80121b <vprintfmt+0x54>
  801299:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80129c:	85 d2                	test   %edx,%edx
  80129e:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a3:	0f 49 c2             	cmovns %edx,%eax
  8012a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012ac:	e9 6a ff ff ff       	jmp    80121b <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8012b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012b4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8012bb:	e9 5b ff ff ff       	jmp    80121b <vprintfmt+0x54>
  8012c0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012c6:	eb bc                	jmp    801284 <vprintfmt+0xbd>
			lflag++;
  8012c8:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012ce:	e9 48 ff ff ff       	jmp    80121b <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8012d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8012d6:	8d 78 04             	lea    0x4(%eax),%edi
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	53                   	push   %ebx
  8012dd:	ff 30                	push   (%eax)
  8012df:	ff d6                	call   *%esi
			break;
  8012e1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8012e4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8012e7:	e9 9d 02 00 00       	jmp    801589 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8012ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ef:	8d 78 04             	lea    0x4(%eax),%edi
  8012f2:	8b 10                	mov    (%eax),%edx
  8012f4:	89 d0                	mov    %edx,%eax
  8012f6:	f7 d8                	neg    %eax
  8012f8:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8012fb:	83 f8 0f             	cmp    $0xf,%eax
  8012fe:	7f 23                	jg     801323 <vprintfmt+0x15c>
  801300:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  801307:	85 d2                	test   %edx,%edx
  801309:	74 18                	je     801323 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80130b:	52                   	push   %edx
  80130c:	68 3d 1e 80 00       	push   $0x801e3d
  801311:	53                   	push   %ebx
  801312:	56                   	push   %esi
  801313:	e8 92 fe ff ff       	call   8011aa <printfmt>
  801318:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80131b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80131e:	e9 66 02 00 00       	jmp    801589 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  801323:	50                   	push   %eax
  801324:	68 bf 1e 80 00       	push   $0x801ebf
  801329:	53                   	push   %ebx
  80132a:	56                   	push   %esi
  80132b:	e8 7a fe ff ff       	call   8011aa <printfmt>
  801330:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801333:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801336:	e9 4e 02 00 00       	jmp    801589 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80133b:	8b 45 14             	mov    0x14(%ebp),%eax
  80133e:	83 c0 04             	add    $0x4,%eax
  801341:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801344:	8b 45 14             	mov    0x14(%ebp),%eax
  801347:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801349:	85 d2                	test   %edx,%edx
  80134b:	b8 b8 1e 80 00       	mov    $0x801eb8,%eax
  801350:	0f 45 c2             	cmovne %edx,%eax
  801353:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801356:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80135a:	7e 06                	jle    801362 <vprintfmt+0x19b>
  80135c:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801360:	75 0d                	jne    80136f <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801362:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801365:	89 c7                	mov    %eax,%edi
  801367:	03 45 e0             	add    -0x20(%ebp),%eax
  80136a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80136d:	eb 55                	jmp    8013c4 <vprintfmt+0x1fd>
  80136f:	83 ec 08             	sub    $0x8,%esp
  801372:	ff 75 d8             	push   -0x28(%ebp)
  801375:	ff 75 cc             	push   -0x34(%ebp)
  801378:	e8 0a 03 00 00       	call   801687 <strnlen>
  80137d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801380:	29 c1                	sub    %eax,%ecx
  801382:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80138a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80138e:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801391:	eb 0f                	jmp    8013a2 <vprintfmt+0x1db>
					putch(padc, putdat);
  801393:	83 ec 08             	sub    $0x8,%esp
  801396:	53                   	push   %ebx
  801397:	ff 75 e0             	push   -0x20(%ebp)
  80139a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80139c:	83 ef 01             	sub    $0x1,%edi
  80139f:	83 c4 10             	add    $0x10,%esp
  8013a2:	85 ff                	test   %edi,%edi
  8013a4:	7f ed                	jg     801393 <vprintfmt+0x1cc>
  8013a6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8013a9:	85 d2                	test   %edx,%edx
  8013ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b0:	0f 49 c2             	cmovns %edx,%eax
  8013b3:	29 c2                	sub    %eax,%edx
  8013b5:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8013b8:	eb a8                	jmp    801362 <vprintfmt+0x19b>
					putch(ch, putdat);
  8013ba:	83 ec 08             	sub    $0x8,%esp
  8013bd:	53                   	push   %ebx
  8013be:	52                   	push   %edx
  8013bf:	ff d6                	call   *%esi
  8013c1:	83 c4 10             	add    $0x10,%esp
  8013c4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013c7:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013c9:	83 c7 01             	add    $0x1,%edi
  8013cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8013d0:	0f be d0             	movsbl %al,%edx
  8013d3:	85 d2                	test   %edx,%edx
  8013d5:	74 4b                	je     801422 <vprintfmt+0x25b>
  8013d7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013db:	78 06                	js     8013e3 <vprintfmt+0x21c>
  8013dd:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8013e1:	78 1e                	js     801401 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8013e3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8013e7:	74 d1                	je     8013ba <vprintfmt+0x1f3>
  8013e9:	0f be c0             	movsbl %al,%eax
  8013ec:	83 e8 20             	sub    $0x20,%eax
  8013ef:	83 f8 5e             	cmp    $0x5e,%eax
  8013f2:	76 c6                	jbe    8013ba <vprintfmt+0x1f3>
					putch('?', putdat);
  8013f4:	83 ec 08             	sub    $0x8,%esp
  8013f7:	53                   	push   %ebx
  8013f8:	6a 3f                	push   $0x3f
  8013fa:	ff d6                	call   *%esi
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	eb c3                	jmp    8013c4 <vprintfmt+0x1fd>
  801401:	89 cf                	mov    %ecx,%edi
  801403:	eb 0e                	jmp    801413 <vprintfmt+0x24c>
				putch(' ', putdat);
  801405:	83 ec 08             	sub    $0x8,%esp
  801408:	53                   	push   %ebx
  801409:	6a 20                	push   $0x20
  80140b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80140d:	83 ef 01             	sub    $0x1,%edi
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	85 ff                	test   %edi,%edi
  801415:	7f ee                	jg     801405 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  801417:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80141a:	89 45 14             	mov    %eax,0x14(%ebp)
  80141d:	e9 67 01 00 00       	jmp    801589 <vprintfmt+0x3c2>
  801422:	89 cf                	mov    %ecx,%edi
  801424:	eb ed                	jmp    801413 <vprintfmt+0x24c>
	if (lflag >= 2)
  801426:	83 f9 01             	cmp    $0x1,%ecx
  801429:	7f 1b                	jg     801446 <vprintfmt+0x27f>
	else if (lflag)
  80142b:	85 c9                	test   %ecx,%ecx
  80142d:	74 63                	je     801492 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80142f:	8b 45 14             	mov    0x14(%ebp),%eax
  801432:	8b 00                	mov    (%eax),%eax
  801434:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801437:	99                   	cltd   
  801438:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80143b:	8b 45 14             	mov    0x14(%ebp),%eax
  80143e:	8d 40 04             	lea    0x4(%eax),%eax
  801441:	89 45 14             	mov    %eax,0x14(%ebp)
  801444:	eb 17                	jmp    80145d <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801446:	8b 45 14             	mov    0x14(%ebp),%eax
  801449:	8b 50 04             	mov    0x4(%eax),%edx
  80144c:	8b 00                	mov    (%eax),%eax
  80144e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801451:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801454:	8b 45 14             	mov    0x14(%ebp),%eax
  801457:	8d 40 08             	lea    0x8(%eax),%eax
  80145a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80145d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801460:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801463:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801468:	85 c9                	test   %ecx,%ecx
  80146a:	0f 89 ff 00 00 00    	jns    80156f <vprintfmt+0x3a8>
				putch('-', putdat);
  801470:	83 ec 08             	sub    $0x8,%esp
  801473:	53                   	push   %ebx
  801474:	6a 2d                	push   $0x2d
  801476:	ff d6                	call   *%esi
				num = -(long long) num;
  801478:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80147b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80147e:	f7 da                	neg    %edx
  801480:	83 d1 00             	adc    $0x0,%ecx
  801483:	f7 d9                	neg    %ecx
  801485:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801488:	bf 0a 00 00 00       	mov    $0xa,%edi
  80148d:	e9 dd 00 00 00       	jmp    80156f <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801492:	8b 45 14             	mov    0x14(%ebp),%eax
  801495:	8b 00                	mov    (%eax),%eax
  801497:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80149a:	99                   	cltd   
  80149b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80149e:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a1:	8d 40 04             	lea    0x4(%eax),%eax
  8014a4:	89 45 14             	mov    %eax,0x14(%ebp)
  8014a7:	eb b4                	jmp    80145d <vprintfmt+0x296>
	if (lflag >= 2)
  8014a9:	83 f9 01             	cmp    $0x1,%ecx
  8014ac:	7f 1e                	jg     8014cc <vprintfmt+0x305>
	else if (lflag)
  8014ae:	85 c9                	test   %ecx,%ecx
  8014b0:	74 32                	je     8014e4 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8014b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b5:	8b 10                	mov    (%eax),%edx
  8014b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014bc:	8d 40 04             	lea    0x4(%eax),%eax
  8014bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014c2:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8014c7:	e9 a3 00 00 00       	jmp    80156f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8014cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014cf:	8b 10                	mov    (%eax),%edx
  8014d1:	8b 48 04             	mov    0x4(%eax),%ecx
  8014d4:	8d 40 08             	lea    0x8(%eax),%eax
  8014d7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014da:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8014df:	e9 8b 00 00 00       	jmp    80156f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8014e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e7:	8b 10                	mov    (%eax),%edx
  8014e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014ee:	8d 40 04             	lea    0x4(%eax),%eax
  8014f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014f4:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8014f9:	eb 74                	jmp    80156f <vprintfmt+0x3a8>
	if (lflag >= 2)
  8014fb:	83 f9 01             	cmp    $0x1,%ecx
  8014fe:	7f 1b                	jg     80151b <vprintfmt+0x354>
	else if (lflag)
  801500:	85 c9                	test   %ecx,%ecx
  801502:	74 2c                	je     801530 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  801504:	8b 45 14             	mov    0x14(%ebp),%eax
  801507:	8b 10                	mov    (%eax),%edx
  801509:	b9 00 00 00 00       	mov    $0x0,%ecx
  80150e:	8d 40 04             	lea    0x4(%eax),%eax
  801511:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801514:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  801519:	eb 54                	jmp    80156f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80151b:	8b 45 14             	mov    0x14(%ebp),%eax
  80151e:	8b 10                	mov    (%eax),%edx
  801520:	8b 48 04             	mov    0x4(%eax),%ecx
  801523:	8d 40 08             	lea    0x8(%eax),%eax
  801526:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801529:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80152e:	eb 3f                	jmp    80156f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801530:	8b 45 14             	mov    0x14(%ebp),%eax
  801533:	8b 10                	mov    (%eax),%edx
  801535:	b9 00 00 00 00       	mov    $0x0,%ecx
  80153a:	8d 40 04             	lea    0x4(%eax),%eax
  80153d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801540:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801545:	eb 28                	jmp    80156f <vprintfmt+0x3a8>
			putch('0', putdat);
  801547:	83 ec 08             	sub    $0x8,%esp
  80154a:	53                   	push   %ebx
  80154b:	6a 30                	push   $0x30
  80154d:	ff d6                	call   *%esi
			putch('x', putdat);
  80154f:	83 c4 08             	add    $0x8,%esp
  801552:	53                   	push   %ebx
  801553:	6a 78                	push   $0x78
  801555:	ff d6                	call   *%esi
			num = (unsigned long long)
  801557:	8b 45 14             	mov    0x14(%ebp),%eax
  80155a:	8b 10                	mov    (%eax),%edx
  80155c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801561:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801564:	8d 40 04             	lea    0x4(%eax),%eax
  801567:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80156a:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80156f:	83 ec 0c             	sub    $0xc,%esp
  801572:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801576:	50                   	push   %eax
  801577:	ff 75 e0             	push   -0x20(%ebp)
  80157a:	57                   	push   %edi
  80157b:	51                   	push   %ecx
  80157c:	52                   	push   %edx
  80157d:	89 da                	mov    %ebx,%edx
  80157f:	89 f0                	mov    %esi,%eax
  801581:	e8 5e fb ff ff       	call   8010e4 <printnum>
			break;
  801586:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801589:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80158c:	e9 54 fc ff ff       	jmp    8011e5 <vprintfmt+0x1e>
	if (lflag >= 2)
  801591:	83 f9 01             	cmp    $0x1,%ecx
  801594:	7f 1b                	jg     8015b1 <vprintfmt+0x3ea>
	else if (lflag)
  801596:	85 c9                	test   %ecx,%ecx
  801598:	74 2c                	je     8015c6 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80159a:	8b 45 14             	mov    0x14(%ebp),%eax
  80159d:	8b 10                	mov    (%eax),%edx
  80159f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015a4:	8d 40 04             	lea    0x4(%eax),%eax
  8015a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015aa:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8015af:	eb be                	jmp    80156f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8015b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b4:	8b 10                	mov    (%eax),%edx
  8015b6:	8b 48 04             	mov    0x4(%eax),%ecx
  8015b9:	8d 40 08             	lea    0x8(%eax),%eax
  8015bc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015bf:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8015c4:	eb a9                	jmp    80156f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8015c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c9:	8b 10                	mov    (%eax),%edx
  8015cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015d0:	8d 40 04             	lea    0x4(%eax),%eax
  8015d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015d6:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8015db:	eb 92                	jmp    80156f <vprintfmt+0x3a8>
			putch(ch, putdat);
  8015dd:	83 ec 08             	sub    $0x8,%esp
  8015e0:	53                   	push   %ebx
  8015e1:	6a 25                	push   $0x25
  8015e3:	ff d6                	call   *%esi
			break;
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	eb 9f                	jmp    801589 <vprintfmt+0x3c2>
			putch('%', putdat);
  8015ea:	83 ec 08             	sub    $0x8,%esp
  8015ed:	53                   	push   %ebx
  8015ee:	6a 25                	push   $0x25
  8015f0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	89 f8                	mov    %edi,%eax
  8015f7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8015fb:	74 05                	je     801602 <vprintfmt+0x43b>
  8015fd:	83 e8 01             	sub    $0x1,%eax
  801600:	eb f5                	jmp    8015f7 <vprintfmt+0x430>
  801602:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801605:	eb 82                	jmp    801589 <vprintfmt+0x3c2>

00801607 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	83 ec 18             	sub    $0x18,%esp
  80160d:	8b 45 08             	mov    0x8(%ebp),%eax
  801610:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801613:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801616:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80161a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80161d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801624:	85 c0                	test   %eax,%eax
  801626:	74 26                	je     80164e <vsnprintf+0x47>
  801628:	85 d2                	test   %edx,%edx
  80162a:	7e 22                	jle    80164e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80162c:	ff 75 14             	push   0x14(%ebp)
  80162f:	ff 75 10             	push   0x10(%ebp)
  801632:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801635:	50                   	push   %eax
  801636:	68 8d 11 80 00       	push   $0x80118d
  80163b:	e8 87 fb ff ff       	call   8011c7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801640:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801643:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801646:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801649:	83 c4 10             	add    $0x10,%esp
}
  80164c:	c9                   	leave  
  80164d:	c3                   	ret    
		return -E_INVAL;
  80164e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801653:	eb f7                	jmp    80164c <vsnprintf+0x45>

00801655 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80165b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80165e:	50                   	push   %eax
  80165f:	ff 75 10             	push   0x10(%ebp)
  801662:	ff 75 0c             	push   0xc(%ebp)
  801665:	ff 75 08             	push   0x8(%ebp)
  801668:	e8 9a ff ff ff       	call   801607 <vsnprintf>
	va_end(ap);

	return rc;
}
  80166d:	c9                   	leave  
  80166e:	c3                   	ret    

0080166f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801675:	b8 00 00 00 00       	mov    $0x0,%eax
  80167a:	eb 03                	jmp    80167f <strlen+0x10>
		n++;
  80167c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80167f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801683:	75 f7                	jne    80167c <strlen+0xd>
	return n;
}
  801685:	5d                   	pop    %ebp
  801686:	c3                   	ret    

00801687 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80168d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801690:	b8 00 00 00 00       	mov    $0x0,%eax
  801695:	eb 03                	jmp    80169a <strnlen+0x13>
		n++;
  801697:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80169a:	39 d0                	cmp    %edx,%eax
  80169c:	74 08                	je     8016a6 <strnlen+0x1f>
  80169e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016a2:	75 f3                	jne    801697 <strnlen+0x10>
  8016a4:	89 c2                	mov    %eax,%edx
	return n;
}
  8016a6:	89 d0                	mov    %edx,%eax
  8016a8:	5d                   	pop    %ebp
  8016a9:	c3                   	ret    

008016aa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	53                   	push   %ebx
  8016ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b9:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016bd:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016c0:	83 c0 01             	add    $0x1,%eax
  8016c3:	84 d2                	test   %dl,%dl
  8016c5:	75 f2                	jne    8016b9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8016c7:	89 c8                	mov    %ecx,%eax
  8016c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cc:	c9                   	leave  
  8016cd:	c3                   	ret    

008016ce <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	53                   	push   %ebx
  8016d2:	83 ec 10             	sub    $0x10,%esp
  8016d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016d8:	53                   	push   %ebx
  8016d9:	e8 91 ff ff ff       	call   80166f <strlen>
  8016de:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8016e1:	ff 75 0c             	push   0xc(%ebp)
  8016e4:	01 d8                	add    %ebx,%eax
  8016e6:	50                   	push   %eax
  8016e7:	e8 be ff ff ff       	call   8016aa <strcpy>
	return dst;
}
  8016ec:	89 d8                	mov    %ebx,%eax
  8016ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f1:	c9                   	leave  
  8016f2:	c3                   	ret    

008016f3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	56                   	push   %esi
  8016f7:	53                   	push   %ebx
  8016f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8016fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016fe:	89 f3                	mov    %esi,%ebx
  801700:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801703:	89 f0                	mov    %esi,%eax
  801705:	eb 0f                	jmp    801716 <strncpy+0x23>
		*dst++ = *src;
  801707:	83 c0 01             	add    $0x1,%eax
  80170a:	0f b6 0a             	movzbl (%edx),%ecx
  80170d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801710:	80 f9 01             	cmp    $0x1,%cl
  801713:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801716:	39 d8                	cmp    %ebx,%eax
  801718:	75 ed                	jne    801707 <strncpy+0x14>
	}
	return ret;
}
  80171a:	89 f0                	mov    %esi,%eax
  80171c:	5b                   	pop    %ebx
  80171d:	5e                   	pop    %esi
  80171e:	5d                   	pop    %ebp
  80171f:	c3                   	ret    

00801720 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	56                   	push   %esi
  801724:	53                   	push   %ebx
  801725:	8b 75 08             	mov    0x8(%ebp),%esi
  801728:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172b:	8b 55 10             	mov    0x10(%ebp),%edx
  80172e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801730:	85 d2                	test   %edx,%edx
  801732:	74 21                	je     801755 <strlcpy+0x35>
  801734:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801738:	89 f2                	mov    %esi,%edx
  80173a:	eb 09                	jmp    801745 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80173c:	83 c1 01             	add    $0x1,%ecx
  80173f:	83 c2 01             	add    $0x1,%edx
  801742:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801745:	39 c2                	cmp    %eax,%edx
  801747:	74 09                	je     801752 <strlcpy+0x32>
  801749:	0f b6 19             	movzbl (%ecx),%ebx
  80174c:	84 db                	test   %bl,%bl
  80174e:	75 ec                	jne    80173c <strlcpy+0x1c>
  801750:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801752:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801755:	29 f0                	sub    %esi,%eax
}
  801757:	5b                   	pop    %ebx
  801758:	5e                   	pop    %esi
  801759:	5d                   	pop    %ebp
  80175a:	c3                   	ret    

0080175b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801761:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801764:	eb 06                	jmp    80176c <strcmp+0x11>
		p++, q++;
  801766:	83 c1 01             	add    $0x1,%ecx
  801769:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80176c:	0f b6 01             	movzbl (%ecx),%eax
  80176f:	84 c0                	test   %al,%al
  801771:	74 04                	je     801777 <strcmp+0x1c>
  801773:	3a 02                	cmp    (%edx),%al
  801775:	74 ef                	je     801766 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801777:	0f b6 c0             	movzbl %al,%eax
  80177a:	0f b6 12             	movzbl (%edx),%edx
  80177d:	29 d0                	sub    %edx,%eax
}
  80177f:	5d                   	pop    %ebp
  801780:	c3                   	ret    

00801781 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	53                   	push   %ebx
  801785:	8b 45 08             	mov    0x8(%ebp),%eax
  801788:	8b 55 0c             	mov    0xc(%ebp),%edx
  80178b:	89 c3                	mov    %eax,%ebx
  80178d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801790:	eb 06                	jmp    801798 <strncmp+0x17>
		n--, p++, q++;
  801792:	83 c0 01             	add    $0x1,%eax
  801795:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801798:	39 d8                	cmp    %ebx,%eax
  80179a:	74 18                	je     8017b4 <strncmp+0x33>
  80179c:	0f b6 08             	movzbl (%eax),%ecx
  80179f:	84 c9                	test   %cl,%cl
  8017a1:	74 04                	je     8017a7 <strncmp+0x26>
  8017a3:	3a 0a                	cmp    (%edx),%cl
  8017a5:	74 eb                	je     801792 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a7:	0f b6 00             	movzbl (%eax),%eax
  8017aa:	0f b6 12             	movzbl (%edx),%edx
  8017ad:	29 d0                	sub    %edx,%eax
}
  8017af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b2:	c9                   	leave  
  8017b3:	c3                   	ret    
		return 0;
  8017b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b9:	eb f4                	jmp    8017af <strncmp+0x2e>

008017bb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017c5:	eb 03                	jmp    8017ca <strchr+0xf>
  8017c7:	83 c0 01             	add    $0x1,%eax
  8017ca:	0f b6 10             	movzbl (%eax),%edx
  8017cd:	84 d2                	test   %dl,%dl
  8017cf:	74 06                	je     8017d7 <strchr+0x1c>
		if (*s == c)
  8017d1:	38 ca                	cmp    %cl,%dl
  8017d3:	75 f2                	jne    8017c7 <strchr+0xc>
  8017d5:	eb 05                	jmp    8017dc <strchr+0x21>
			return (char *) s;
	return 0;
  8017d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017dc:	5d                   	pop    %ebp
  8017dd:	c3                   	ret    

008017de <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017e8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017eb:	38 ca                	cmp    %cl,%dl
  8017ed:	74 09                	je     8017f8 <strfind+0x1a>
  8017ef:	84 d2                	test   %dl,%dl
  8017f1:	74 05                	je     8017f8 <strfind+0x1a>
	for (; *s; s++)
  8017f3:	83 c0 01             	add    $0x1,%eax
  8017f6:	eb f0                	jmp    8017e8 <strfind+0xa>
			break;
	return (char *) s;
}
  8017f8:	5d                   	pop    %ebp
  8017f9:	c3                   	ret    

008017fa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	57                   	push   %edi
  8017fe:	56                   	push   %esi
  8017ff:	53                   	push   %ebx
  801800:	8b 7d 08             	mov    0x8(%ebp),%edi
  801803:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801806:	85 c9                	test   %ecx,%ecx
  801808:	74 2f                	je     801839 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80180a:	89 f8                	mov    %edi,%eax
  80180c:	09 c8                	or     %ecx,%eax
  80180e:	a8 03                	test   $0x3,%al
  801810:	75 21                	jne    801833 <memset+0x39>
		c &= 0xFF;
  801812:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801816:	89 d0                	mov    %edx,%eax
  801818:	c1 e0 08             	shl    $0x8,%eax
  80181b:	89 d3                	mov    %edx,%ebx
  80181d:	c1 e3 18             	shl    $0x18,%ebx
  801820:	89 d6                	mov    %edx,%esi
  801822:	c1 e6 10             	shl    $0x10,%esi
  801825:	09 f3                	or     %esi,%ebx
  801827:	09 da                	or     %ebx,%edx
  801829:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80182b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80182e:	fc                   	cld    
  80182f:	f3 ab                	rep stos %eax,%es:(%edi)
  801831:	eb 06                	jmp    801839 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801833:	8b 45 0c             	mov    0xc(%ebp),%eax
  801836:	fc                   	cld    
  801837:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801839:	89 f8                	mov    %edi,%eax
  80183b:	5b                   	pop    %ebx
  80183c:	5e                   	pop    %esi
  80183d:	5f                   	pop    %edi
  80183e:	5d                   	pop    %ebp
  80183f:	c3                   	ret    

00801840 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	57                   	push   %edi
  801844:	56                   	push   %esi
  801845:	8b 45 08             	mov    0x8(%ebp),%eax
  801848:	8b 75 0c             	mov    0xc(%ebp),%esi
  80184b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80184e:	39 c6                	cmp    %eax,%esi
  801850:	73 32                	jae    801884 <memmove+0x44>
  801852:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801855:	39 c2                	cmp    %eax,%edx
  801857:	76 2b                	jbe    801884 <memmove+0x44>
		s += n;
		d += n;
  801859:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80185c:	89 d6                	mov    %edx,%esi
  80185e:	09 fe                	or     %edi,%esi
  801860:	09 ce                	or     %ecx,%esi
  801862:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801868:	75 0e                	jne    801878 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80186a:	83 ef 04             	sub    $0x4,%edi
  80186d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801870:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801873:	fd                   	std    
  801874:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801876:	eb 09                	jmp    801881 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801878:	83 ef 01             	sub    $0x1,%edi
  80187b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80187e:	fd                   	std    
  80187f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801881:	fc                   	cld    
  801882:	eb 1a                	jmp    80189e <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801884:	89 f2                	mov    %esi,%edx
  801886:	09 c2                	or     %eax,%edx
  801888:	09 ca                	or     %ecx,%edx
  80188a:	f6 c2 03             	test   $0x3,%dl
  80188d:	75 0a                	jne    801899 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80188f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801892:	89 c7                	mov    %eax,%edi
  801894:	fc                   	cld    
  801895:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801897:	eb 05                	jmp    80189e <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801899:	89 c7                	mov    %eax,%edi
  80189b:	fc                   	cld    
  80189c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80189e:	5e                   	pop    %esi
  80189f:	5f                   	pop    %edi
  8018a0:	5d                   	pop    %ebp
  8018a1:	c3                   	ret    

008018a2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018a8:	ff 75 10             	push   0x10(%ebp)
  8018ab:	ff 75 0c             	push   0xc(%ebp)
  8018ae:	ff 75 08             	push   0x8(%ebp)
  8018b1:	e8 8a ff ff ff       	call   801840 <memmove>
}
  8018b6:	c9                   	leave  
  8018b7:	c3                   	ret    

008018b8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	56                   	push   %esi
  8018bc:	53                   	push   %ebx
  8018bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018c3:	89 c6                	mov    %eax,%esi
  8018c5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018c8:	eb 06                	jmp    8018d0 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8018ca:	83 c0 01             	add    $0x1,%eax
  8018cd:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8018d0:	39 f0                	cmp    %esi,%eax
  8018d2:	74 14                	je     8018e8 <memcmp+0x30>
		if (*s1 != *s2)
  8018d4:	0f b6 08             	movzbl (%eax),%ecx
  8018d7:	0f b6 1a             	movzbl (%edx),%ebx
  8018da:	38 d9                	cmp    %bl,%cl
  8018dc:	74 ec                	je     8018ca <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8018de:	0f b6 c1             	movzbl %cl,%eax
  8018e1:	0f b6 db             	movzbl %bl,%ebx
  8018e4:	29 d8                	sub    %ebx,%eax
  8018e6:	eb 05                	jmp    8018ed <memcmp+0x35>
	}

	return 0;
  8018e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ed:	5b                   	pop    %ebx
  8018ee:	5e                   	pop    %esi
  8018ef:	5d                   	pop    %ebp
  8018f0:	c3                   	ret    

008018f1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018f1:	55                   	push   %ebp
  8018f2:	89 e5                	mov    %esp,%ebp
  8018f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8018fa:	89 c2                	mov    %eax,%edx
  8018fc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018ff:	eb 03                	jmp    801904 <memfind+0x13>
  801901:	83 c0 01             	add    $0x1,%eax
  801904:	39 d0                	cmp    %edx,%eax
  801906:	73 04                	jae    80190c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801908:	38 08                	cmp    %cl,(%eax)
  80190a:	75 f5                	jne    801901 <memfind+0x10>
			break;
	return (void *) s;
}
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    

0080190e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	57                   	push   %edi
  801912:	56                   	push   %esi
  801913:	53                   	push   %ebx
  801914:	8b 55 08             	mov    0x8(%ebp),%edx
  801917:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80191a:	eb 03                	jmp    80191f <strtol+0x11>
		s++;
  80191c:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  80191f:	0f b6 02             	movzbl (%edx),%eax
  801922:	3c 20                	cmp    $0x20,%al
  801924:	74 f6                	je     80191c <strtol+0xe>
  801926:	3c 09                	cmp    $0x9,%al
  801928:	74 f2                	je     80191c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  80192a:	3c 2b                	cmp    $0x2b,%al
  80192c:	74 2a                	je     801958 <strtol+0x4a>
	int neg = 0;
  80192e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801933:	3c 2d                	cmp    $0x2d,%al
  801935:	74 2b                	je     801962 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801937:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80193d:	75 0f                	jne    80194e <strtol+0x40>
  80193f:	80 3a 30             	cmpb   $0x30,(%edx)
  801942:	74 28                	je     80196c <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801944:	85 db                	test   %ebx,%ebx
  801946:	b8 0a 00 00 00       	mov    $0xa,%eax
  80194b:	0f 44 d8             	cmove  %eax,%ebx
  80194e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801953:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801956:	eb 46                	jmp    80199e <strtol+0x90>
		s++;
  801958:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  80195b:	bf 00 00 00 00       	mov    $0x0,%edi
  801960:	eb d5                	jmp    801937 <strtol+0x29>
		s++, neg = 1;
  801962:	83 c2 01             	add    $0x1,%edx
  801965:	bf 01 00 00 00       	mov    $0x1,%edi
  80196a:	eb cb                	jmp    801937 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80196c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801970:	74 0e                	je     801980 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801972:	85 db                	test   %ebx,%ebx
  801974:	75 d8                	jne    80194e <strtol+0x40>
		s++, base = 8;
  801976:	83 c2 01             	add    $0x1,%edx
  801979:	bb 08 00 00 00       	mov    $0x8,%ebx
  80197e:	eb ce                	jmp    80194e <strtol+0x40>
		s += 2, base = 16;
  801980:	83 c2 02             	add    $0x2,%edx
  801983:	bb 10 00 00 00       	mov    $0x10,%ebx
  801988:	eb c4                	jmp    80194e <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  80198a:	0f be c0             	movsbl %al,%eax
  80198d:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801990:	3b 45 10             	cmp    0x10(%ebp),%eax
  801993:	7d 3a                	jge    8019cf <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801995:	83 c2 01             	add    $0x1,%edx
  801998:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  80199c:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  80199e:	0f b6 02             	movzbl (%edx),%eax
  8019a1:	8d 70 d0             	lea    -0x30(%eax),%esi
  8019a4:	89 f3                	mov    %esi,%ebx
  8019a6:	80 fb 09             	cmp    $0x9,%bl
  8019a9:	76 df                	jbe    80198a <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  8019ab:	8d 70 9f             	lea    -0x61(%eax),%esi
  8019ae:	89 f3                	mov    %esi,%ebx
  8019b0:	80 fb 19             	cmp    $0x19,%bl
  8019b3:	77 08                	ja     8019bd <strtol+0xaf>
			dig = *s - 'a' + 10;
  8019b5:	0f be c0             	movsbl %al,%eax
  8019b8:	83 e8 57             	sub    $0x57,%eax
  8019bb:	eb d3                	jmp    801990 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8019bd:	8d 70 bf             	lea    -0x41(%eax),%esi
  8019c0:	89 f3                	mov    %esi,%ebx
  8019c2:	80 fb 19             	cmp    $0x19,%bl
  8019c5:	77 08                	ja     8019cf <strtol+0xc1>
			dig = *s - 'A' + 10;
  8019c7:	0f be c0             	movsbl %al,%eax
  8019ca:	83 e8 37             	sub    $0x37,%eax
  8019cd:	eb c1                	jmp    801990 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8019cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019d3:	74 05                	je     8019da <strtol+0xcc>
		*endptr = (char *) s;
  8019d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d8:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8019da:	89 c8                	mov    %ecx,%eax
  8019dc:	f7 d8                	neg    %eax
  8019de:	85 ff                	test   %edi,%edi
  8019e0:	0f 45 c8             	cmovne %eax,%ecx
}
  8019e3:	89 c8                	mov    %ecx,%eax
  8019e5:	5b                   	pop    %ebx
  8019e6:	5e                   	pop    %esi
  8019e7:	5f                   	pop    %edi
  8019e8:	5d                   	pop    %ebp
  8019e9:	c3                   	ret    

008019ea <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	56                   	push   %esi
  8019ee:	53                   	push   %ebx
  8019ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8019f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8019f8:	85 c0                	test   %eax,%eax
  8019fa:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019ff:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801a02:	83 ec 0c             	sub    $0xc,%esp
  801a05:	50                   	push   %eax
  801a06:	e8 08 e9 ff ff       	call   800313 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801a0b:	83 c4 10             	add    $0x10,%esp
  801a0e:	85 f6                	test   %esi,%esi
  801a10:	74 14                	je     801a26 <ipc_recv+0x3c>
  801a12:	ba 00 00 00 00       	mov    $0x0,%edx
  801a17:	85 c0                	test   %eax,%eax
  801a19:	78 09                	js     801a24 <ipc_recv+0x3a>
  801a1b:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a21:	8b 52 74             	mov    0x74(%edx),%edx
  801a24:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801a26:	85 db                	test   %ebx,%ebx
  801a28:	74 14                	je     801a3e <ipc_recv+0x54>
  801a2a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	78 09                	js     801a3c <ipc_recv+0x52>
  801a33:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a39:	8b 52 78             	mov    0x78(%edx),%edx
  801a3c:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801a3e:	85 c0                	test   %eax,%eax
  801a40:	78 08                	js     801a4a <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801a42:	a1 00 40 80 00       	mov    0x804000,%eax
  801a47:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4d:	5b                   	pop    %ebx
  801a4e:	5e                   	pop    %esi
  801a4f:	5d                   	pop    %ebp
  801a50:	c3                   	ret    

00801a51 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a51:	55                   	push   %ebp
  801a52:	89 e5                	mov    %esp,%ebp
  801a54:	57                   	push   %edi
  801a55:	56                   	push   %esi
  801a56:	53                   	push   %ebx
  801a57:	83 ec 0c             	sub    $0xc,%esp
  801a5a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a5d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801a63:	85 db                	test   %ebx,%ebx
  801a65:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a6a:	0f 44 d8             	cmove  %eax,%ebx
  801a6d:	eb 05                	jmp    801a74 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a6f:	e8 d0 e6 ff ff       	call   800144 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801a74:	ff 75 14             	push   0x14(%ebp)
  801a77:	53                   	push   %ebx
  801a78:	56                   	push   %esi
  801a79:	57                   	push   %edi
  801a7a:	e8 71 e8 ff ff       	call   8002f0 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a7f:	83 c4 10             	add    $0x10,%esp
  801a82:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a85:	74 e8                	je     801a6f <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801a87:	85 c0                	test   %eax,%eax
  801a89:	78 08                	js     801a93 <ipc_send+0x42>
	}while (r<0);

}
  801a8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a8e:	5b                   	pop    %ebx
  801a8f:	5e                   	pop    %esi
  801a90:	5f                   	pop    %edi
  801a91:	5d                   	pop    %ebp
  801a92:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801a93:	50                   	push   %eax
  801a94:	68 9f 21 80 00       	push   $0x80219f
  801a99:	6a 3d                	push   $0x3d
  801a9b:	68 b3 21 80 00       	push   $0x8021b3
  801aa0:	e8 50 f5 ff ff       	call   800ff5 <_panic>

00801aa5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801aab:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ab0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ab3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ab9:	8b 52 50             	mov    0x50(%edx),%edx
  801abc:	39 ca                	cmp    %ecx,%edx
  801abe:	74 11                	je     801ad1 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801ac0:	83 c0 01             	add    $0x1,%eax
  801ac3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ac8:	75 e6                	jne    801ab0 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801aca:	b8 00 00 00 00       	mov    $0x0,%eax
  801acf:	eb 0b                	jmp    801adc <ipc_find_env+0x37>
			return envs[i].env_id;
  801ad1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ad4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ad9:	8b 40 48             	mov    0x48(%eax),%eax
}
  801adc:	5d                   	pop    %ebp
  801add:	c3                   	ret    

00801ade <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ae4:	89 c2                	mov    %eax,%edx
  801ae6:	c1 ea 16             	shr    $0x16,%edx
  801ae9:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801af0:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801af5:	f6 c1 01             	test   $0x1,%cl
  801af8:	74 1c                	je     801b16 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801afa:	c1 e8 0c             	shr    $0xc,%eax
  801afd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b04:	a8 01                	test   $0x1,%al
  801b06:	74 0e                	je     801b16 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b08:	c1 e8 0c             	shr    $0xc,%eax
  801b0b:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b12:	ef 
  801b13:	0f b7 d2             	movzwl %dx,%edx
}
  801b16:	89 d0                	mov    %edx,%eax
  801b18:	5d                   	pop    %ebp
  801b19:	c3                   	ret    
  801b1a:	66 90                	xchg   %ax,%ax
  801b1c:	66 90                	xchg   %ax,%ax
  801b1e:	66 90                	xchg   %ax,%ax

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
