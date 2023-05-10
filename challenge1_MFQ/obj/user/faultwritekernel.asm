
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
  800049:	e8 d1 00 00 00       	call   80011f <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800059:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005e:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800063:	85 db                	test   %ebx,%ebx
  800065:	7e 07                	jle    80006e <libmain+0x30>
		binaryname = argv[0];
  800067:	8b 06                	mov    (%esi),%eax
  800069:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006e:	83 ec 08             	sub    $0x8,%esp
  800071:	56                   	push   %esi
  800072:	53                   	push   %ebx
  800073:	e8 bb ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800078:	e8 0a 00 00 00       	call   800087 <exit>
}
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800083:	5b                   	pop    %ebx
  800084:	5e                   	pop    %esi
  800085:	5d                   	pop    %ebp
  800086:	c3                   	ret    

00800087 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800087:	55                   	push   %ebp
  800088:	89 e5                	mov    %esp,%ebp
  80008a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008d:	e8 ee 04 00 00       	call   800580 <close_all>
	sys_env_destroy(0);
  800092:	83 ec 0c             	sub    $0xc,%esp
  800095:	6a 00                	push   $0x0
  800097:	e8 42 00 00 00       	call   8000de <sys_env_destroy>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	c9                   	leave  
  8000a0:	c3                   	ret    

008000a1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	57                   	push   %edi
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b2:	89 c3                	mov    %eax,%ebx
  8000b4:	89 c7                	mov    %eax,%edi
  8000b6:	89 c6                	mov    %eax,%esi
  8000b8:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ba:	5b                   	pop    %ebx
  8000bb:	5e                   	pop    %esi
  8000bc:	5f                   	pop    %edi
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    

008000bf <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	57                   	push   %edi
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cf:	89 d1                	mov    %edx,%ecx
  8000d1:	89 d3                	mov    %edx,%ebx
  8000d3:	89 d7                	mov    %edx,%edi
  8000d5:	89 d6                	mov    %edx,%esi
  8000d7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	57                   	push   %edi
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ef:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f4:	89 cb                	mov    %ecx,%ebx
  8000f6:	89 cf                	mov    %ecx,%edi
  8000f8:	89 ce                	mov    %ecx,%esi
  8000fa:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000fc:	85 c0                	test   %eax,%eax
  8000fe:	7f 08                	jg     800108 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800100:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	5f                   	pop    %edi
  800106:	5d                   	pop    %ebp
  800107:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800108:	83 ec 0c             	sub    $0xc,%esp
  80010b:	50                   	push   %eax
  80010c:	6a 03                	push   $0x3
  80010e:	68 4a 22 80 00       	push   $0x80224a
  800113:	6a 2a                	push   $0x2a
  800115:	68 67 22 80 00       	push   $0x802267
  80011a:	e8 9e 13 00 00       	call   8014bd <_panic>

0080011f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	57                   	push   %edi
  800123:	56                   	push   %esi
  800124:	53                   	push   %ebx
	asm volatile("int %1\n"
  800125:	ba 00 00 00 00       	mov    $0x0,%edx
  80012a:	b8 02 00 00 00       	mov    $0x2,%eax
  80012f:	89 d1                	mov    %edx,%ecx
  800131:	89 d3                	mov    %edx,%ebx
  800133:	89 d7                	mov    %edx,%edi
  800135:	89 d6                	mov    %edx,%esi
  800137:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800139:	5b                   	pop    %ebx
  80013a:	5e                   	pop    %esi
  80013b:	5f                   	pop    %edi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <sys_yield>:

void
sys_yield(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	57                   	push   %edi
  800142:	56                   	push   %esi
  800143:	53                   	push   %ebx
	asm volatile("int %1\n"
  800144:	ba 00 00 00 00       	mov    $0x0,%edx
  800149:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014e:	89 d1                	mov    %edx,%ecx
  800150:	89 d3                	mov    %edx,%ebx
  800152:	89 d7                	mov    %edx,%edi
  800154:	89 d6                	mov    %edx,%esi
  800156:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800158:	5b                   	pop    %ebx
  800159:	5e                   	pop    %esi
  80015a:	5f                   	pop    %edi
  80015b:	5d                   	pop    %ebp
  80015c:	c3                   	ret    

0080015d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	57                   	push   %edi
  800161:	56                   	push   %esi
  800162:	53                   	push   %ebx
  800163:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800166:	be 00 00 00 00       	mov    $0x0,%esi
  80016b:	8b 55 08             	mov    0x8(%ebp),%edx
  80016e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800179:	89 f7                	mov    %esi,%edi
  80017b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80017d:	85 c0                	test   %eax,%eax
  80017f:	7f 08                	jg     800189 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800181:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800184:	5b                   	pop    %ebx
  800185:	5e                   	pop    %esi
  800186:	5f                   	pop    %edi
  800187:	5d                   	pop    %ebp
  800188:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800189:	83 ec 0c             	sub    $0xc,%esp
  80018c:	50                   	push   %eax
  80018d:	6a 04                	push   $0x4
  80018f:	68 4a 22 80 00       	push   $0x80224a
  800194:	6a 2a                	push   $0x2a
  800196:	68 67 22 80 00       	push   $0x802267
  80019b:	e8 1d 13 00 00       	call   8014bd <_panic>

008001a0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001af:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ba:	8b 75 18             	mov    0x18(%ebp),%esi
  8001bd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001bf:	85 c0                	test   %eax,%eax
  8001c1:	7f 08                	jg     8001cb <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c6:	5b                   	pop    %ebx
  8001c7:	5e                   	pop    %esi
  8001c8:	5f                   	pop    %edi
  8001c9:	5d                   	pop    %ebp
  8001ca:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cb:	83 ec 0c             	sub    $0xc,%esp
  8001ce:	50                   	push   %eax
  8001cf:	6a 05                	push   $0x5
  8001d1:	68 4a 22 80 00       	push   $0x80224a
  8001d6:	6a 2a                	push   $0x2a
  8001d8:	68 67 22 80 00       	push   $0x802267
  8001dd:	e8 db 12 00 00       	call   8014bd <_panic>

008001e2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	57                   	push   %edi
  8001e6:	56                   	push   %esi
  8001e7:	53                   	push   %ebx
  8001e8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	89 df                	mov    %ebx,%edi
  8001fd:	89 de                	mov    %ebx,%esi
  8001ff:	cd 30                	int    $0x30
	if(check && ret > 0)
  800201:	85 c0                	test   %eax,%eax
  800203:	7f 08                	jg     80020d <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800205:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800208:	5b                   	pop    %ebx
  800209:	5e                   	pop    %esi
  80020a:	5f                   	pop    %edi
  80020b:	5d                   	pop    %ebp
  80020c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80020d:	83 ec 0c             	sub    $0xc,%esp
  800210:	50                   	push   %eax
  800211:	6a 06                	push   $0x6
  800213:	68 4a 22 80 00       	push   $0x80224a
  800218:	6a 2a                	push   $0x2a
  80021a:	68 67 22 80 00       	push   $0x802267
  80021f:	e8 99 12 00 00       	call   8014bd <_panic>

00800224 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	57                   	push   %edi
  800228:	56                   	push   %esi
  800229:	53                   	push   %ebx
  80022a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80022d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	89 df                	mov    %ebx,%edi
  80023f:	89 de                	mov    %ebx,%esi
  800241:	cd 30                	int    $0x30
	if(check && ret > 0)
  800243:	85 c0                	test   %eax,%eax
  800245:	7f 08                	jg     80024f <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800247:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5f                   	pop    %edi
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80024f:	83 ec 0c             	sub    $0xc,%esp
  800252:	50                   	push   %eax
  800253:	6a 08                	push   $0x8
  800255:	68 4a 22 80 00       	push   $0x80224a
  80025a:	6a 2a                	push   $0x2a
  80025c:	68 67 22 80 00       	push   $0x802267
  800261:	e8 57 12 00 00       	call   8014bd <_panic>

00800266 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	57                   	push   %edi
  80026a:	56                   	push   %esi
  80026b:	53                   	push   %ebx
  80026c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80026f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800274:	8b 55 08             	mov    0x8(%ebp),%edx
  800277:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027a:	b8 09 00 00 00       	mov    $0x9,%eax
  80027f:	89 df                	mov    %ebx,%edi
  800281:	89 de                	mov    %ebx,%esi
  800283:	cd 30                	int    $0x30
	if(check && ret > 0)
  800285:	85 c0                	test   %eax,%eax
  800287:	7f 08                	jg     800291 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800289:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028c:	5b                   	pop    %ebx
  80028d:	5e                   	pop    %esi
  80028e:	5f                   	pop    %edi
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800291:	83 ec 0c             	sub    $0xc,%esp
  800294:	50                   	push   %eax
  800295:	6a 09                	push   $0x9
  800297:	68 4a 22 80 00       	push   $0x80224a
  80029c:	6a 2a                	push   $0x2a
  80029e:	68 67 22 80 00       	push   $0x802267
  8002a3:	e8 15 12 00 00       	call   8014bd <_panic>

008002a8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	57                   	push   %edi
  8002ac:	56                   	push   %esi
  8002ad:	53                   	push   %ebx
  8002ae:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c1:	89 df                	mov    %ebx,%edi
  8002c3:	89 de                	mov    %ebx,%esi
  8002c5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c7:	85 c0                	test   %eax,%eax
  8002c9:	7f 08                	jg     8002d3 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ce:	5b                   	pop    %ebx
  8002cf:	5e                   	pop    %esi
  8002d0:	5f                   	pop    %edi
  8002d1:	5d                   	pop    %ebp
  8002d2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d3:	83 ec 0c             	sub    $0xc,%esp
  8002d6:	50                   	push   %eax
  8002d7:	6a 0a                	push   $0xa
  8002d9:	68 4a 22 80 00       	push   $0x80224a
  8002de:	6a 2a                	push   $0x2a
  8002e0:	68 67 22 80 00       	push   $0x802267
  8002e5:	e8 d3 11 00 00       	call   8014bd <_panic>

008002ea <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	57                   	push   %edi
  8002ee:	56                   	push   %esi
  8002ef:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fb:	be 00 00 00 00       	mov    $0x0,%esi
  800300:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800303:	8b 7d 14             	mov    0x14(%ebp),%edi
  800306:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800308:	5b                   	pop    %ebx
  800309:	5e                   	pop    %esi
  80030a:	5f                   	pop    %edi
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	57                   	push   %edi
  800311:	56                   	push   %esi
  800312:	53                   	push   %ebx
  800313:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800316:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031b:	8b 55 08             	mov    0x8(%ebp),%edx
  80031e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800323:	89 cb                	mov    %ecx,%ebx
  800325:	89 cf                	mov    %ecx,%edi
  800327:	89 ce                	mov    %ecx,%esi
  800329:	cd 30                	int    $0x30
	if(check && ret > 0)
  80032b:	85 c0                	test   %eax,%eax
  80032d:	7f 08                	jg     800337 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80032f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800332:	5b                   	pop    %ebx
  800333:	5e                   	pop    %esi
  800334:	5f                   	pop    %edi
  800335:	5d                   	pop    %ebp
  800336:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800337:	83 ec 0c             	sub    $0xc,%esp
  80033a:	50                   	push   %eax
  80033b:	6a 0d                	push   $0xd
  80033d:	68 4a 22 80 00       	push   $0x80224a
  800342:	6a 2a                	push   $0x2a
  800344:	68 67 22 80 00       	push   $0x802267
  800349:	e8 6f 11 00 00       	call   8014bd <_panic>

0080034e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	57                   	push   %edi
  800352:	56                   	push   %esi
  800353:	53                   	push   %ebx
	asm volatile("int %1\n"
  800354:	ba 00 00 00 00       	mov    $0x0,%edx
  800359:	b8 0e 00 00 00       	mov    $0xe,%eax
  80035e:	89 d1                	mov    %edx,%ecx
  800360:	89 d3                	mov    %edx,%ebx
  800362:	89 d7                	mov    %edx,%edi
  800364:	89 d6                	mov    %edx,%esi
  800366:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800368:	5b                   	pop    %ebx
  800369:	5e                   	pop    %esi
  80036a:	5f                   	pop    %edi
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	57                   	push   %edi
  800371:	56                   	push   %esi
  800372:	53                   	push   %ebx
	asm volatile("int %1\n"
  800373:	bb 00 00 00 00       	mov    $0x0,%ebx
  800378:	8b 55 08             	mov    0x8(%ebp),%edx
  80037b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80037e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800383:	89 df                	mov    %ebx,%edi
  800385:	89 de                	mov    %ebx,%esi
  800387:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800389:	5b                   	pop    %ebx
  80038a:	5e                   	pop    %esi
  80038b:	5f                   	pop    %edi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	57                   	push   %edi
  800392:	56                   	push   %esi
  800393:	53                   	push   %ebx
	asm volatile("int %1\n"
  800394:	bb 00 00 00 00       	mov    $0x0,%ebx
  800399:	8b 55 08             	mov    0x8(%ebp),%edx
  80039c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80039f:	b8 10 00 00 00       	mov    $0x10,%eax
  8003a4:	89 df                	mov    %ebx,%edi
  8003a6:	89 de                	mov    %ebx,%esi
  8003a8:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8003aa:	5b                   	pop    %ebx
  8003ab:	5e                   	pop    %esi
  8003ac:	5f                   	pop    %edi
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b5:	05 00 00 00 30       	add    $0x30000000,%eax
  8003ba:	c1 e8 0c             	shr    $0xc,%eax
}
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    

008003bf <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c5:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003ca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003cf:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003d4:	5d                   	pop    %ebp
  8003d5:	c3                   	ret    

008003d6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
  8003d9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003de:	89 c2                	mov    %eax,%edx
  8003e0:	c1 ea 16             	shr    $0x16,%edx
  8003e3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ea:	f6 c2 01             	test   $0x1,%dl
  8003ed:	74 29                	je     800418 <fd_alloc+0x42>
  8003ef:	89 c2                	mov    %eax,%edx
  8003f1:	c1 ea 0c             	shr    $0xc,%edx
  8003f4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fb:	f6 c2 01             	test   $0x1,%dl
  8003fe:	74 18                	je     800418 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800400:	05 00 10 00 00       	add    $0x1000,%eax
  800405:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80040a:	75 d2                	jne    8003de <fd_alloc+0x8>
  80040c:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800411:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800416:	eb 05                	jmp    80041d <fd_alloc+0x47>
			return 0;
  800418:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80041d:	8b 55 08             	mov    0x8(%ebp),%edx
  800420:	89 02                	mov    %eax,(%edx)
}
  800422:	89 c8                	mov    %ecx,%eax
  800424:	5d                   	pop    %ebp
  800425:	c3                   	ret    

00800426 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800426:	55                   	push   %ebp
  800427:	89 e5                	mov    %esp,%ebp
  800429:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80042c:	83 f8 1f             	cmp    $0x1f,%eax
  80042f:	77 30                	ja     800461 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800431:	c1 e0 0c             	shl    $0xc,%eax
  800434:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800439:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80043f:	f6 c2 01             	test   $0x1,%dl
  800442:	74 24                	je     800468 <fd_lookup+0x42>
  800444:	89 c2                	mov    %eax,%edx
  800446:	c1 ea 0c             	shr    $0xc,%edx
  800449:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800450:	f6 c2 01             	test   $0x1,%dl
  800453:	74 1a                	je     80046f <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800455:	8b 55 0c             	mov    0xc(%ebp),%edx
  800458:	89 02                	mov    %eax,(%edx)
	return 0;
  80045a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80045f:	5d                   	pop    %ebp
  800460:	c3                   	ret    
		return -E_INVAL;
  800461:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800466:	eb f7                	jmp    80045f <fd_lookup+0x39>
		return -E_INVAL;
  800468:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80046d:	eb f0                	jmp    80045f <fd_lookup+0x39>
  80046f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800474:	eb e9                	jmp    80045f <fd_lookup+0x39>

00800476 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	53                   	push   %ebx
  80047a:	83 ec 04             	sub    $0x4,%esp
  80047d:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800480:	b8 00 00 00 00       	mov    $0x0,%eax
  800485:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80048a:	39 13                	cmp    %edx,(%ebx)
  80048c:	74 37                	je     8004c5 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  80048e:	83 c0 01             	add    $0x1,%eax
  800491:	8b 1c 85 f4 22 80 00 	mov    0x8022f4(,%eax,4),%ebx
  800498:	85 db                	test   %ebx,%ebx
  80049a:	75 ee                	jne    80048a <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80049c:	a1 00 40 80 00       	mov    0x804000,%eax
  8004a1:	8b 40 58             	mov    0x58(%eax),%eax
  8004a4:	83 ec 04             	sub    $0x4,%esp
  8004a7:	52                   	push   %edx
  8004a8:	50                   	push   %eax
  8004a9:	68 78 22 80 00       	push   $0x802278
  8004ae:	e8 e5 10 00 00       	call   801598 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8004bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004be:	89 1a                	mov    %ebx,(%edx)
}
  8004c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004c3:	c9                   	leave  
  8004c4:	c3                   	ret    
			return 0;
  8004c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ca:	eb ef                	jmp    8004bb <dev_lookup+0x45>

008004cc <fd_close>:
{
  8004cc:	55                   	push   %ebp
  8004cd:	89 e5                	mov    %esp,%ebp
  8004cf:	57                   	push   %edi
  8004d0:	56                   	push   %esi
  8004d1:	53                   	push   %ebx
  8004d2:	83 ec 24             	sub    $0x24,%esp
  8004d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004db:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004de:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004df:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004e5:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e8:	50                   	push   %eax
  8004e9:	e8 38 ff ff ff       	call   800426 <fd_lookup>
  8004ee:	89 c3                	mov    %eax,%ebx
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	85 c0                	test   %eax,%eax
  8004f5:	78 05                	js     8004fc <fd_close+0x30>
	    || fd != fd2)
  8004f7:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004fa:	74 16                	je     800512 <fd_close+0x46>
		return (must_exist ? r : 0);
  8004fc:	89 f8                	mov    %edi,%eax
  8004fe:	84 c0                	test   %al,%al
  800500:	b8 00 00 00 00       	mov    $0x0,%eax
  800505:	0f 44 d8             	cmove  %eax,%ebx
}
  800508:	89 d8                	mov    %ebx,%eax
  80050a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80050d:	5b                   	pop    %ebx
  80050e:	5e                   	pop    %esi
  80050f:	5f                   	pop    %edi
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800512:	83 ec 08             	sub    $0x8,%esp
  800515:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800518:	50                   	push   %eax
  800519:	ff 36                	push   (%esi)
  80051b:	e8 56 ff ff ff       	call   800476 <dev_lookup>
  800520:	89 c3                	mov    %eax,%ebx
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	85 c0                	test   %eax,%eax
  800527:	78 1a                	js     800543 <fd_close+0x77>
		if (dev->dev_close)
  800529:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052c:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80052f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800534:	85 c0                	test   %eax,%eax
  800536:	74 0b                	je     800543 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800538:	83 ec 0c             	sub    $0xc,%esp
  80053b:	56                   	push   %esi
  80053c:	ff d0                	call   *%eax
  80053e:	89 c3                	mov    %eax,%ebx
  800540:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	56                   	push   %esi
  800547:	6a 00                	push   $0x0
  800549:	e8 94 fc ff ff       	call   8001e2 <sys_page_unmap>
	return r;
  80054e:	83 c4 10             	add    $0x10,%esp
  800551:	eb b5                	jmp    800508 <fd_close+0x3c>

00800553 <close>:

int
close(int fdnum)
{
  800553:	55                   	push   %ebp
  800554:	89 e5                	mov    %esp,%ebp
  800556:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800559:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80055c:	50                   	push   %eax
  80055d:	ff 75 08             	push   0x8(%ebp)
  800560:	e8 c1 fe ff ff       	call   800426 <fd_lookup>
  800565:	83 c4 10             	add    $0x10,%esp
  800568:	85 c0                	test   %eax,%eax
  80056a:	79 02                	jns    80056e <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80056c:	c9                   	leave  
  80056d:	c3                   	ret    
		return fd_close(fd, 1);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	6a 01                	push   $0x1
  800573:	ff 75 f4             	push   -0xc(%ebp)
  800576:	e8 51 ff ff ff       	call   8004cc <fd_close>
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	eb ec                	jmp    80056c <close+0x19>

00800580 <close_all>:

void
close_all(void)
{
  800580:	55                   	push   %ebp
  800581:	89 e5                	mov    %esp,%ebp
  800583:	53                   	push   %ebx
  800584:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800587:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80058c:	83 ec 0c             	sub    $0xc,%esp
  80058f:	53                   	push   %ebx
  800590:	e8 be ff ff ff       	call   800553 <close>
	for (i = 0; i < MAXFD; i++)
  800595:	83 c3 01             	add    $0x1,%ebx
  800598:	83 c4 10             	add    $0x10,%esp
  80059b:	83 fb 20             	cmp    $0x20,%ebx
  80059e:	75 ec                	jne    80058c <close_all+0xc>
}
  8005a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005a3:	c9                   	leave  
  8005a4:	c3                   	ret    

008005a5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005a5:	55                   	push   %ebp
  8005a6:	89 e5                	mov    %esp,%ebp
  8005a8:	57                   	push   %edi
  8005a9:	56                   	push   %esi
  8005aa:	53                   	push   %ebx
  8005ab:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005ae:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005b1:	50                   	push   %eax
  8005b2:	ff 75 08             	push   0x8(%ebp)
  8005b5:	e8 6c fe ff ff       	call   800426 <fd_lookup>
  8005ba:	89 c3                	mov    %eax,%ebx
  8005bc:	83 c4 10             	add    $0x10,%esp
  8005bf:	85 c0                	test   %eax,%eax
  8005c1:	78 7f                	js     800642 <dup+0x9d>
		return r;
	close(newfdnum);
  8005c3:	83 ec 0c             	sub    $0xc,%esp
  8005c6:	ff 75 0c             	push   0xc(%ebp)
  8005c9:	e8 85 ff ff ff       	call   800553 <close>

	newfd = INDEX2FD(newfdnum);
  8005ce:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005d1:	c1 e6 0c             	shl    $0xc,%esi
  8005d4:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005dd:	89 3c 24             	mov    %edi,(%esp)
  8005e0:	e8 da fd ff ff       	call   8003bf <fd2data>
  8005e5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005e7:	89 34 24             	mov    %esi,(%esp)
  8005ea:	e8 d0 fd ff ff       	call   8003bf <fd2data>
  8005ef:	83 c4 10             	add    $0x10,%esp
  8005f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005f5:	89 d8                	mov    %ebx,%eax
  8005f7:	c1 e8 16             	shr    $0x16,%eax
  8005fa:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800601:	a8 01                	test   $0x1,%al
  800603:	74 11                	je     800616 <dup+0x71>
  800605:	89 d8                	mov    %ebx,%eax
  800607:	c1 e8 0c             	shr    $0xc,%eax
  80060a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800611:	f6 c2 01             	test   $0x1,%dl
  800614:	75 36                	jne    80064c <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800616:	89 f8                	mov    %edi,%eax
  800618:	c1 e8 0c             	shr    $0xc,%eax
  80061b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800622:	83 ec 0c             	sub    $0xc,%esp
  800625:	25 07 0e 00 00       	and    $0xe07,%eax
  80062a:	50                   	push   %eax
  80062b:	56                   	push   %esi
  80062c:	6a 00                	push   $0x0
  80062e:	57                   	push   %edi
  80062f:	6a 00                	push   $0x0
  800631:	e8 6a fb ff ff       	call   8001a0 <sys_page_map>
  800636:	89 c3                	mov    %eax,%ebx
  800638:	83 c4 20             	add    $0x20,%esp
  80063b:	85 c0                	test   %eax,%eax
  80063d:	78 33                	js     800672 <dup+0xcd>
		goto err;

	return newfdnum;
  80063f:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800642:	89 d8                	mov    %ebx,%eax
  800644:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800647:	5b                   	pop    %ebx
  800648:	5e                   	pop    %esi
  800649:	5f                   	pop    %edi
  80064a:	5d                   	pop    %ebp
  80064b:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80064c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800653:	83 ec 0c             	sub    $0xc,%esp
  800656:	25 07 0e 00 00       	and    $0xe07,%eax
  80065b:	50                   	push   %eax
  80065c:	ff 75 d4             	push   -0x2c(%ebp)
  80065f:	6a 00                	push   $0x0
  800661:	53                   	push   %ebx
  800662:	6a 00                	push   $0x0
  800664:	e8 37 fb ff ff       	call   8001a0 <sys_page_map>
  800669:	89 c3                	mov    %eax,%ebx
  80066b:	83 c4 20             	add    $0x20,%esp
  80066e:	85 c0                	test   %eax,%eax
  800670:	79 a4                	jns    800616 <dup+0x71>
	sys_page_unmap(0, newfd);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	56                   	push   %esi
  800676:	6a 00                	push   $0x0
  800678:	e8 65 fb ff ff       	call   8001e2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80067d:	83 c4 08             	add    $0x8,%esp
  800680:	ff 75 d4             	push   -0x2c(%ebp)
  800683:	6a 00                	push   $0x0
  800685:	e8 58 fb ff ff       	call   8001e2 <sys_page_unmap>
	return r;
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	eb b3                	jmp    800642 <dup+0x9d>

0080068f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80068f:	55                   	push   %ebp
  800690:	89 e5                	mov    %esp,%ebp
  800692:	56                   	push   %esi
  800693:	53                   	push   %ebx
  800694:	83 ec 18             	sub    $0x18,%esp
  800697:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80069a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80069d:	50                   	push   %eax
  80069e:	56                   	push   %esi
  80069f:	e8 82 fd ff ff       	call   800426 <fd_lookup>
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	85 c0                	test   %eax,%eax
  8006a9:	78 3c                	js     8006e7 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ab:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006b4:	50                   	push   %eax
  8006b5:	ff 33                	push   (%ebx)
  8006b7:	e8 ba fd ff ff       	call   800476 <dev_lookup>
  8006bc:	83 c4 10             	add    $0x10,%esp
  8006bf:	85 c0                	test   %eax,%eax
  8006c1:	78 24                	js     8006e7 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006c3:	8b 43 08             	mov    0x8(%ebx),%eax
  8006c6:	83 e0 03             	and    $0x3,%eax
  8006c9:	83 f8 01             	cmp    $0x1,%eax
  8006cc:	74 20                	je     8006ee <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d1:	8b 40 08             	mov    0x8(%eax),%eax
  8006d4:	85 c0                	test   %eax,%eax
  8006d6:	74 37                	je     80070f <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006d8:	83 ec 04             	sub    $0x4,%esp
  8006db:	ff 75 10             	push   0x10(%ebp)
  8006de:	ff 75 0c             	push   0xc(%ebp)
  8006e1:	53                   	push   %ebx
  8006e2:	ff d0                	call   *%eax
  8006e4:	83 c4 10             	add    $0x10,%esp
}
  8006e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006ea:	5b                   	pop    %ebx
  8006eb:	5e                   	pop    %esi
  8006ec:	5d                   	pop    %ebp
  8006ed:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006ee:	a1 00 40 80 00       	mov    0x804000,%eax
  8006f3:	8b 40 58             	mov    0x58(%eax),%eax
  8006f6:	83 ec 04             	sub    $0x4,%esp
  8006f9:	56                   	push   %esi
  8006fa:	50                   	push   %eax
  8006fb:	68 b9 22 80 00       	push   $0x8022b9
  800700:	e8 93 0e 00 00       	call   801598 <cprintf>
		return -E_INVAL;
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80070d:	eb d8                	jmp    8006e7 <read+0x58>
		return -E_NOT_SUPP;
  80070f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800714:	eb d1                	jmp    8006e7 <read+0x58>

00800716 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	57                   	push   %edi
  80071a:	56                   	push   %esi
  80071b:	53                   	push   %ebx
  80071c:	83 ec 0c             	sub    $0xc,%esp
  80071f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800722:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800725:	bb 00 00 00 00       	mov    $0x0,%ebx
  80072a:	eb 02                	jmp    80072e <readn+0x18>
  80072c:	01 c3                	add    %eax,%ebx
  80072e:	39 f3                	cmp    %esi,%ebx
  800730:	73 21                	jae    800753 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800732:	83 ec 04             	sub    $0x4,%esp
  800735:	89 f0                	mov    %esi,%eax
  800737:	29 d8                	sub    %ebx,%eax
  800739:	50                   	push   %eax
  80073a:	89 d8                	mov    %ebx,%eax
  80073c:	03 45 0c             	add    0xc(%ebp),%eax
  80073f:	50                   	push   %eax
  800740:	57                   	push   %edi
  800741:	e8 49 ff ff ff       	call   80068f <read>
		if (m < 0)
  800746:	83 c4 10             	add    $0x10,%esp
  800749:	85 c0                	test   %eax,%eax
  80074b:	78 04                	js     800751 <readn+0x3b>
			return m;
		if (m == 0)
  80074d:	75 dd                	jne    80072c <readn+0x16>
  80074f:	eb 02                	jmp    800753 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800751:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800753:	89 d8                	mov    %ebx,%eax
  800755:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800758:	5b                   	pop    %ebx
  800759:	5e                   	pop    %esi
  80075a:	5f                   	pop    %edi
  80075b:	5d                   	pop    %ebp
  80075c:	c3                   	ret    

0080075d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	56                   	push   %esi
  800761:	53                   	push   %ebx
  800762:	83 ec 18             	sub    $0x18,%esp
  800765:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800768:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80076b:	50                   	push   %eax
  80076c:	53                   	push   %ebx
  80076d:	e8 b4 fc ff ff       	call   800426 <fd_lookup>
  800772:	83 c4 10             	add    $0x10,%esp
  800775:	85 c0                	test   %eax,%eax
  800777:	78 37                	js     8007b0 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800779:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800782:	50                   	push   %eax
  800783:	ff 36                	push   (%esi)
  800785:	e8 ec fc ff ff       	call   800476 <dev_lookup>
  80078a:	83 c4 10             	add    $0x10,%esp
  80078d:	85 c0                	test   %eax,%eax
  80078f:	78 1f                	js     8007b0 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800791:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800795:	74 20                	je     8007b7 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800797:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079a:	8b 40 0c             	mov    0xc(%eax),%eax
  80079d:	85 c0                	test   %eax,%eax
  80079f:	74 37                	je     8007d8 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007a1:	83 ec 04             	sub    $0x4,%esp
  8007a4:	ff 75 10             	push   0x10(%ebp)
  8007a7:	ff 75 0c             	push   0xc(%ebp)
  8007aa:	56                   	push   %esi
  8007ab:	ff d0                	call   *%eax
  8007ad:	83 c4 10             	add    $0x10,%esp
}
  8007b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007b3:	5b                   	pop    %ebx
  8007b4:	5e                   	pop    %esi
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007b7:	a1 00 40 80 00       	mov    0x804000,%eax
  8007bc:	8b 40 58             	mov    0x58(%eax),%eax
  8007bf:	83 ec 04             	sub    $0x4,%esp
  8007c2:	53                   	push   %ebx
  8007c3:	50                   	push   %eax
  8007c4:	68 d5 22 80 00       	push   $0x8022d5
  8007c9:	e8 ca 0d 00 00       	call   801598 <cprintf>
		return -E_INVAL;
  8007ce:	83 c4 10             	add    $0x10,%esp
  8007d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d6:	eb d8                	jmp    8007b0 <write+0x53>
		return -E_NOT_SUPP;
  8007d8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007dd:	eb d1                	jmp    8007b0 <write+0x53>

008007df <seek>:

int
seek(int fdnum, off_t offset)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e8:	50                   	push   %eax
  8007e9:	ff 75 08             	push   0x8(%ebp)
  8007ec:	e8 35 fc ff ff       	call   800426 <fd_lookup>
  8007f1:	83 c4 10             	add    $0x10,%esp
  8007f4:	85 c0                	test   %eax,%eax
  8007f6:	78 0e                	js     800806 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007fe:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800801:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800806:	c9                   	leave  
  800807:	c3                   	ret    

00800808 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	56                   	push   %esi
  80080c:	53                   	push   %ebx
  80080d:	83 ec 18             	sub    $0x18,%esp
  800810:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800813:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800816:	50                   	push   %eax
  800817:	53                   	push   %ebx
  800818:	e8 09 fc ff ff       	call   800426 <fd_lookup>
  80081d:	83 c4 10             	add    $0x10,%esp
  800820:	85 c0                	test   %eax,%eax
  800822:	78 34                	js     800858 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800824:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800827:	83 ec 08             	sub    $0x8,%esp
  80082a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80082d:	50                   	push   %eax
  80082e:	ff 36                	push   (%esi)
  800830:	e8 41 fc ff ff       	call   800476 <dev_lookup>
  800835:	83 c4 10             	add    $0x10,%esp
  800838:	85 c0                	test   %eax,%eax
  80083a:	78 1c                	js     800858 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80083c:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800840:	74 1d                	je     80085f <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800842:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800845:	8b 40 18             	mov    0x18(%eax),%eax
  800848:	85 c0                	test   %eax,%eax
  80084a:	74 34                	je     800880 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80084c:	83 ec 08             	sub    $0x8,%esp
  80084f:	ff 75 0c             	push   0xc(%ebp)
  800852:	56                   	push   %esi
  800853:	ff d0                	call   *%eax
  800855:	83 c4 10             	add    $0x10,%esp
}
  800858:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    
			thisenv->env_id, fdnum);
  80085f:	a1 00 40 80 00       	mov    0x804000,%eax
  800864:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800867:	83 ec 04             	sub    $0x4,%esp
  80086a:	53                   	push   %ebx
  80086b:	50                   	push   %eax
  80086c:	68 98 22 80 00       	push   $0x802298
  800871:	e8 22 0d 00 00       	call   801598 <cprintf>
		return -E_INVAL;
  800876:	83 c4 10             	add    $0x10,%esp
  800879:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80087e:	eb d8                	jmp    800858 <ftruncate+0x50>
		return -E_NOT_SUPP;
  800880:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800885:	eb d1                	jmp    800858 <ftruncate+0x50>

00800887 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	56                   	push   %esi
  80088b:	53                   	push   %ebx
  80088c:	83 ec 18             	sub    $0x18,%esp
  80088f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800892:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800895:	50                   	push   %eax
  800896:	ff 75 08             	push   0x8(%ebp)
  800899:	e8 88 fb ff ff       	call   800426 <fd_lookup>
  80089e:	83 c4 10             	add    $0x10,%esp
  8008a1:	85 c0                	test   %eax,%eax
  8008a3:	78 49                	js     8008ee <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a5:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ae:	50                   	push   %eax
  8008af:	ff 36                	push   (%esi)
  8008b1:	e8 c0 fb ff ff       	call   800476 <dev_lookup>
  8008b6:	83 c4 10             	add    $0x10,%esp
  8008b9:	85 c0                	test   %eax,%eax
  8008bb:	78 31                	js     8008ee <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8008bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c4:	74 2f                	je     8008f5 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008d0:	00 00 00 
	stat->st_isdir = 0;
  8008d3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008da:	00 00 00 
	stat->st_dev = dev;
  8008dd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008e3:	83 ec 08             	sub    $0x8,%esp
  8008e6:	53                   	push   %ebx
  8008e7:	56                   	push   %esi
  8008e8:	ff 50 14             	call   *0x14(%eax)
  8008eb:	83 c4 10             	add    $0x10,%esp
}
  8008ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f1:	5b                   	pop    %ebx
  8008f2:	5e                   	pop    %esi
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    
		return -E_NOT_SUPP;
  8008f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008fa:	eb f2                	jmp    8008ee <fstat+0x67>

008008fc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	56                   	push   %esi
  800900:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800901:	83 ec 08             	sub    $0x8,%esp
  800904:	6a 00                	push   $0x0
  800906:	ff 75 08             	push   0x8(%ebp)
  800909:	e8 e4 01 00 00       	call   800af2 <open>
  80090e:	89 c3                	mov    %eax,%ebx
  800910:	83 c4 10             	add    $0x10,%esp
  800913:	85 c0                	test   %eax,%eax
  800915:	78 1b                	js     800932 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800917:	83 ec 08             	sub    $0x8,%esp
  80091a:	ff 75 0c             	push   0xc(%ebp)
  80091d:	50                   	push   %eax
  80091e:	e8 64 ff ff ff       	call   800887 <fstat>
  800923:	89 c6                	mov    %eax,%esi
	close(fd);
  800925:	89 1c 24             	mov    %ebx,(%esp)
  800928:	e8 26 fc ff ff       	call   800553 <close>
	return r;
  80092d:	83 c4 10             	add    $0x10,%esp
  800930:	89 f3                	mov    %esi,%ebx
}
  800932:	89 d8                	mov    %ebx,%eax
  800934:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800937:	5b                   	pop    %ebx
  800938:	5e                   	pop    %esi
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	56                   	push   %esi
  80093f:	53                   	push   %ebx
  800940:	89 c6                	mov    %eax,%esi
  800942:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800944:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80094b:	74 27                	je     800974 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80094d:	6a 07                	push   $0x7
  80094f:	68 00 50 80 00       	push   $0x805000
  800954:	56                   	push   %esi
  800955:	ff 35 00 60 80 00    	push   0x806000
  80095b:	e8 c2 15 00 00       	call   801f22 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800960:	83 c4 0c             	add    $0xc,%esp
  800963:	6a 00                	push   $0x0
  800965:	53                   	push   %ebx
  800966:	6a 00                	push   $0x0
  800968:	e8 45 15 00 00       	call   801eb2 <ipc_recv>
}
  80096d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800974:	83 ec 0c             	sub    $0xc,%esp
  800977:	6a 01                	push   $0x1
  800979:	e8 f8 15 00 00       	call   801f76 <ipc_find_env>
  80097e:	a3 00 60 80 00       	mov    %eax,0x806000
  800983:	83 c4 10             	add    $0x10,%esp
  800986:	eb c5                	jmp    80094d <fsipc+0x12>

00800988 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	8b 40 0c             	mov    0xc(%eax),%eax
  800994:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800999:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a6:	b8 02 00 00 00       	mov    $0x2,%eax
  8009ab:	e8 8b ff ff ff       	call   80093b <fsipc>
}
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <devfile_flush>:
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8009be:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c8:	b8 06 00 00 00       	mov    $0x6,%eax
  8009cd:	e8 69 ff ff ff       	call   80093b <fsipc>
}
  8009d2:	c9                   	leave  
  8009d3:	c3                   	ret    

008009d4 <devfile_stat>:
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	53                   	push   %ebx
  8009d8:	83 ec 04             	sub    $0x4,%esp
  8009db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8009f3:	e8 43 ff ff ff       	call   80093b <fsipc>
  8009f8:	85 c0                	test   %eax,%eax
  8009fa:	78 2c                	js     800a28 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009fc:	83 ec 08             	sub    $0x8,%esp
  8009ff:	68 00 50 80 00       	push   $0x805000
  800a04:	53                   	push   %ebx
  800a05:	e8 68 11 00 00       	call   801b72 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a0a:	a1 80 50 80 00       	mov    0x805080,%eax
  800a0f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a15:	a1 84 50 80 00       	mov    0x805084,%eax
  800a1a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a20:	83 c4 10             	add    $0x10,%esp
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2b:	c9                   	leave  
  800a2c:	c3                   	ret    

00800a2d <devfile_write>:
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	83 ec 0c             	sub    $0xc,%esp
  800a33:	8b 45 10             	mov    0x10(%ebp),%eax
  800a36:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a3b:	39 d0                	cmp    %edx,%eax
  800a3d:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a40:	8b 55 08             	mov    0x8(%ebp),%edx
  800a43:	8b 52 0c             	mov    0xc(%edx),%edx
  800a46:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a4c:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a51:	50                   	push   %eax
  800a52:	ff 75 0c             	push   0xc(%ebp)
  800a55:	68 08 50 80 00       	push   $0x805008
  800a5a:	e8 a9 12 00 00       	call   801d08 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a64:	b8 04 00 00 00       	mov    $0x4,%eax
  800a69:	e8 cd fe ff ff       	call   80093b <fsipc>
}
  800a6e:	c9                   	leave  
  800a6f:	c3                   	ret    

00800a70 <devfile_read>:
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
  800a75:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a7e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a83:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a89:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8e:	b8 03 00 00 00       	mov    $0x3,%eax
  800a93:	e8 a3 fe ff ff       	call   80093b <fsipc>
  800a98:	89 c3                	mov    %eax,%ebx
  800a9a:	85 c0                	test   %eax,%eax
  800a9c:	78 1f                	js     800abd <devfile_read+0x4d>
	assert(r <= n);
  800a9e:	39 f0                	cmp    %esi,%eax
  800aa0:	77 24                	ja     800ac6 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800aa2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aa7:	7f 33                	jg     800adc <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aa9:	83 ec 04             	sub    $0x4,%esp
  800aac:	50                   	push   %eax
  800aad:	68 00 50 80 00       	push   $0x805000
  800ab2:	ff 75 0c             	push   0xc(%ebp)
  800ab5:	e8 4e 12 00 00       	call   801d08 <memmove>
	return r;
  800aba:	83 c4 10             	add    $0x10,%esp
}
  800abd:	89 d8                	mov    %ebx,%eax
  800abf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    
	assert(r <= n);
  800ac6:	68 08 23 80 00       	push   $0x802308
  800acb:	68 0f 23 80 00       	push   $0x80230f
  800ad0:	6a 7c                	push   $0x7c
  800ad2:	68 24 23 80 00       	push   $0x802324
  800ad7:	e8 e1 09 00 00       	call   8014bd <_panic>
	assert(r <= PGSIZE);
  800adc:	68 2f 23 80 00       	push   $0x80232f
  800ae1:	68 0f 23 80 00       	push   $0x80230f
  800ae6:	6a 7d                	push   $0x7d
  800ae8:	68 24 23 80 00       	push   $0x802324
  800aed:	e8 cb 09 00 00       	call   8014bd <_panic>

00800af2 <open>:
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	56                   	push   %esi
  800af6:	53                   	push   %ebx
  800af7:	83 ec 1c             	sub    $0x1c,%esp
  800afa:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800afd:	56                   	push   %esi
  800afe:	e8 34 10 00 00       	call   801b37 <strlen>
  800b03:	83 c4 10             	add    $0x10,%esp
  800b06:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b0b:	7f 6c                	jg     800b79 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800b0d:	83 ec 0c             	sub    $0xc,%esp
  800b10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b13:	50                   	push   %eax
  800b14:	e8 bd f8 ff ff       	call   8003d6 <fd_alloc>
  800b19:	89 c3                	mov    %eax,%ebx
  800b1b:	83 c4 10             	add    $0x10,%esp
  800b1e:	85 c0                	test   %eax,%eax
  800b20:	78 3c                	js     800b5e <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800b22:	83 ec 08             	sub    $0x8,%esp
  800b25:	56                   	push   %esi
  800b26:	68 00 50 80 00       	push   $0x805000
  800b2b:	e8 42 10 00 00       	call   801b72 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b33:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b38:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b3b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b40:	e8 f6 fd ff ff       	call   80093b <fsipc>
  800b45:	89 c3                	mov    %eax,%ebx
  800b47:	83 c4 10             	add    $0x10,%esp
  800b4a:	85 c0                	test   %eax,%eax
  800b4c:	78 19                	js     800b67 <open+0x75>
	return fd2num(fd);
  800b4e:	83 ec 0c             	sub    $0xc,%esp
  800b51:	ff 75 f4             	push   -0xc(%ebp)
  800b54:	e8 56 f8 ff ff       	call   8003af <fd2num>
  800b59:	89 c3                	mov    %eax,%ebx
  800b5b:	83 c4 10             	add    $0x10,%esp
}
  800b5e:	89 d8                	mov    %ebx,%eax
  800b60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b63:	5b                   	pop    %ebx
  800b64:	5e                   	pop    %esi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    
		fd_close(fd, 0);
  800b67:	83 ec 08             	sub    $0x8,%esp
  800b6a:	6a 00                	push   $0x0
  800b6c:	ff 75 f4             	push   -0xc(%ebp)
  800b6f:	e8 58 f9 ff ff       	call   8004cc <fd_close>
		return r;
  800b74:	83 c4 10             	add    $0x10,%esp
  800b77:	eb e5                	jmp    800b5e <open+0x6c>
		return -E_BAD_PATH;
  800b79:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b7e:	eb de                	jmp    800b5e <open+0x6c>

00800b80 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b86:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8b:	b8 08 00 00 00       	mov    $0x8,%eax
  800b90:	e8 a6 fd ff ff       	call   80093b <fsipc>
}
  800b95:	c9                   	leave  
  800b96:	c3                   	ret    

00800b97 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b9d:	68 3b 23 80 00       	push   $0x80233b
  800ba2:	ff 75 0c             	push   0xc(%ebp)
  800ba5:	e8 c8 0f 00 00       	call   801b72 <strcpy>
	return 0;
}
  800baa:	b8 00 00 00 00       	mov    $0x0,%eax
  800baf:	c9                   	leave  
  800bb0:	c3                   	ret    

00800bb1 <devsock_close>:
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	53                   	push   %ebx
  800bb5:	83 ec 10             	sub    $0x10,%esp
  800bb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bbb:	53                   	push   %ebx
  800bbc:	e8 f4 13 00 00       	call   801fb5 <pageref>
  800bc1:	89 c2                	mov    %eax,%edx
  800bc3:	83 c4 10             	add    $0x10,%esp
		return 0;
  800bc6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800bcb:	83 fa 01             	cmp    $0x1,%edx
  800bce:	74 05                	je     800bd5 <devsock_close+0x24>
}
  800bd0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd3:	c9                   	leave  
  800bd4:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800bd5:	83 ec 0c             	sub    $0xc,%esp
  800bd8:	ff 73 0c             	push   0xc(%ebx)
  800bdb:	e8 b7 02 00 00       	call   800e97 <nsipc_close>
  800be0:	83 c4 10             	add    $0x10,%esp
  800be3:	eb eb                	jmp    800bd0 <devsock_close+0x1f>

00800be5 <devsock_write>:
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800beb:	6a 00                	push   $0x0
  800bed:	ff 75 10             	push   0x10(%ebp)
  800bf0:	ff 75 0c             	push   0xc(%ebp)
  800bf3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf6:	ff 70 0c             	push   0xc(%eax)
  800bf9:	e8 79 03 00 00       	call   800f77 <nsipc_send>
}
  800bfe:	c9                   	leave  
  800bff:	c3                   	ret    

00800c00 <devsock_read>:
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c06:	6a 00                	push   $0x0
  800c08:	ff 75 10             	push   0x10(%ebp)
  800c0b:	ff 75 0c             	push   0xc(%ebp)
  800c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c11:	ff 70 0c             	push   0xc(%eax)
  800c14:	e8 ef 02 00 00       	call   800f08 <nsipc_recv>
}
  800c19:	c9                   	leave  
  800c1a:	c3                   	ret    

00800c1b <fd2sockid>:
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c21:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c24:	52                   	push   %edx
  800c25:	50                   	push   %eax
  800c26:	e8 fb f7 ff ff       	call   800426 <fd_lookup>
  800c2b:	83 c4 10             	add    $0x10,%esp
  800c2e:	85 c0                	test   %eax,%eax
  800c30:	78 10                	js     800c42 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c35:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c3b:	39 08                	cmp    %ecx,(%eax)
  800c3d:	75 05                	jne    800c44 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c3f:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c42:	c9                   	leave  
  800c43:	c3                   	ret    
		return -E_NOT_SUPP;
  800c44:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c49:	eb f7                	jmp    800c42 <fd2sockid+0x27>

00800c4b <alloc_sockfd>:
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 1c             	sub    $0x1c,%esp
  800c53:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c58:	50                   	push   %eax
  800c59:	e8 78 f7 ff ff       	call   8003d6 <fd_alloc>
  800c5e:	89 c3                	mov    %eax,%ebx
  800c60:	83 c4 10             	add    $0x10,%esp
  800c63:	85 c0                	test   %eax,%eax
  800c65:	78 43                	js     800caa <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c67:	83 ec 04             	sub    $0x4,%esp
  800c6a:	68 07 04 00 00       	push   $0x407
  800c6f:	ff 75 f4             	push   -0xc(%ebp)
  800c72:	6a 00                	push   $0x0
  800c74:	e8 e4 f4 ff ff       	call   80015d <sys_page_alloc>
  800c79:	89 c3                	mov    %eax,%ebx
  800c7b:	83 c4 10             	add    $0x10,%esp
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	78 28                	js     800caa <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c85:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c8b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c90:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c97:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c9a:	83 ec 0c             	sub    $0xc,%esp
  800c9d:	50                   	push   %eax
  800c9e:	e8 0c f7 ff ff       	call   8003af <fd2num>
  800ca3:	89 c3                	mov    %eax,%ebx
  800ca5:	83 c4 10             	add    $0x10,%esp
  800ca8:	eb 0c                	jmp    800cb6 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	56                   	push   %esi
  800cae:	e8 e4 01 00 00       	call   800e97 <nsipc_close>
		return r;
  800cb3:	83 c4 10             	add    $0x10,%esp
}
  800cb6:	89 d8                	mov    %ebx,%eax
  800cb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <accept>:
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc8:	e8 4e ff ff ff       	call   800c1b <fd2sockid>
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	78 1b                	js     800cec <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cd1:	83 ec 04             	sub    $0x4,%esp
  800cd4:	ff 75 10             	push   0x10(%ebp)
  800cd7:	ff 75 0c             	push   0xc(%ebp)
  800cda:	50                   	push   %eax
  800cdb:	e8 0e 01 00 00       	call   800dee <nsipc_accept>
  800ce0:	83 c4 10             	add    $0x10,%esp
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	78 05                	js     800cec <accept+0x2d>
	return alloc_sockfd(r);
  800ce7:	e8 5f ff ff ff       	call   800c4b <alloc_sockfd>
}
  800cec:	c9                   	leave  
  800ced:	c3                   	ret    

00800cee <bind>:
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	e8 1f ff ff ff       	call   800c1b <fd2sockid>
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	78 12                	js     800d12 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  800d00:	83 ec 04             	sub    $0x4,%esp
  800d03:	ff 75 10             	push   0x10(%ebp)
  800d06:	ff 75 0c             	push   0xc(%ebp)
  800d09:	50                   	push   %eax
  800d0a:	e8 31 01 00 00       	call   800e40 <nsipc_bind>
  800d0f:	83 c4 10             	add    $0x10,%esp
}
  800d12:	c9                   	leave  
  800d13:	c3                   	ret    

00800d14 <shutdown>:
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1d:	e8 f9 fe ff ff       	call   800c1b <fd2sockid>
  800d22:	85 c0                	test   %eax,%eax
  800d24:	78 0f                	js     800d35 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  800d26:	83 ec 08             	sub    $0x8,%esp
  800d29:	ff 75 0c             	push   0xc(%ebp)
  800d2c:	50                   	push   %eax
  800d2d:	e8 43 01 00 00       	call   800e75 <nsipc_shutdown>
  800d32:	83 c4 10             	add    $0x10,%esp
}
  800d35:	c9                   	leave  
  800d36:	c3                   	ret    

00800d37 <connect>:
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d40:	e8 d6 fe ff ff       	call   800c1b <fd2sockid>
  800d45:	85 c0                	test   %eax,%eax
  800d47:	78 12                	js     800d5b <connect+0x24>
	return nsipc_connect(r, name, namelen);
  800d49:	83 ec 04             	sub    $0x4,%esp
  800d4c:	ff 75 10             	push   0x10(%ebp)
  800d4f:	ff 75 0c             	push   0xc(%ebp)
  800d52:	50                   	push   %eax
  800d53:	e8 59 01 00 00       	call   800eb1 <nsipc_connect>
  800d58:	83 c4 10             	add    $0x10,%esp
}
  800d5b:	c9                   	leave  
  800d5c:	c3                   	ret    

00800d5d <listen>:
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d63:	8b 45 08             	mov    0x8(%ebp),%eax
  800d66:	e8 b0 fe ff ff       	call   800c1b <fd2sockid>
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	78 0f                	js     800d7e <listen+0x21>
	return nsipc_listen(r, backlog);
  800d6f:	83 ec 08             	sub    $0x8,%esp
  800d72:	ff 75 0c             	push   0xc(%ebp)
  800d75:	50                   	push   %eax
  800d76:	e8 6b 01 00 00       	call   800ee6 <nsipc_listen>
  800d7b:	83 c4 10             	add    $0x10,%esp
}
  800d7e:	c9                   	leave  
  800d7f:	c3                   	ret    

00800d80 <socket>:

int
socket(int domain, int type, int protocol)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d86:	ff 75 10             	push   0x10(%ebp)
  800d89:	ff 75 0c             	push   0xc(%ebp)
  800d8c:	ff 75 08             	push   0x8(%ebp)
  800d8f:	e8 41 02 00 00       	call   800fd5 <nsipc_socket>
  800d94:	83 c4 10             	add    $0x10,%esp
  800d97:	85 c0                	test   %eax,%eax
  800d99:	78 05                	js     800da0 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800d9b:	e8 ab fe ff ff       	call   800c4b <alloc_sockfd>
}
  800da0:	c9                   	leave  
  800da1:	c3                   	ret    

00800da2 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	53                   	push   %ebx
  800da6:	83 ec 04             	sub    $0x4,%esp
  800da9:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dab:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  800db2:	74 26                	je     800dda <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800db4:	6a 07                	push   $0x7
  800db6:	68 00 70 80 00       	push   $0x807000
  800dbb:	53                   	push   %ebx
  800dbc:	ff 35 00 80 80 00    	push   0x808000
  800dc2:	e8 5b 11 00 00       	call   801f22 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dc7:	83 c4 0c             	add    $0xc,%esp
  800dca:	6a 00                	push   $0x0
  800dcc:	6a 00                	push   $0x0
  800dce:	6a 00                	push   $0x0
  800dd0:	e8 dd 10 00 00       	call   801eb2 <ipc_recv>
}
  800dd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dd8:	c9                   	leave  
  800dd9:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dda:	83 ec 0c             	sub    $0xc,%esp
  800ddd:	6a 02                	push   $0x2
  800ddf:	e8 92 11 00 00       	call   801f76 <ipc_find_env>
  800de4:	a3 00 80 80 00       	mov    %eax,0x808000
  800de9:	83 c4 10             	add    $0x10,%esp
  800dec:	eb c6                	jmp    800db4 <nsipc+0x12>

00800dee <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
  800df3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800df6:	8b 45 08             	mov    0x8(%ebp),%eax
  800df9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800dfe:	8b 06                	mov    (%esi),%eax
  800e00:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e05:	b8 01 00 00 00       	mov    $0x1,%eax
  800e0a:	e8 93 ff ff ff       	call   800da2 <nsipc>
  800e0f:	89 c3                	mov    %eax,%ebx
  800e11:	85 c0                	test   %eax,%eax
  800e13:	79 09                	jns    800e1e <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800e15:	89 d8                	mov    %ebx,%eax
  800e17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e1a:	5b                   	pop    %ebx
  800e1b:	5e                   	pop    %esi
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e1e:	83 ec 04             	sub    $0x4,%esp
  800e21:	ff 35 10 70 80 00    	push   0x807010
  800e27:	68 00 70 80 00       	push   $0x807000
  800e2c:	ff 75 0c             	push   0xc(%ebp)
  800e2f:	e8 d4 0e 00 00       	call   801d08 <memmove>
		*addrlen = ret->ret_addrlen;
  800e34:	a1 10 70 80 00       	mov    0x807010,%eax
  800e39:	89 06                	mov    %eax,(%esi)
  800e3b:	83 c4 10             	add    $0x10,%esp
	return r;
  800e3e:	eb d5                	jmp    800e15 <nsipc_accept+0x27>

00800e40 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	53                   	push   %ebx
  800e44:	83 ec 08             	sub    $0x8,%esp
  800e47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e52:	53                   	push   %ebx
  800e53:	ff 75 0c             	push   0xc(%ebp)
  800e56:	68 04 70 80 00       	push   $0x807004
  800e5b:	e8 a8 0e 00 00       	call   801d08 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e60:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  800e66:	b8 02 00 00 00       	mov    $0x2,%eax
  800e6b:	e8 32 ff ff ff       	call   800da2 <nsipc>
}
  800e70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e73:	c9                   	leave  
  800e74:	c3                   	ret    

00800e75 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  800e83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e86:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  800e8b:	b8 03 00 00 00       	mov    $0x3,%eax
  800e90:	e8 0d ff ff ff       	call   800da2 <nsipc>
}
  800e95:	c9                   	leave  
  800e96:	c3                   	ret    

00800e97 <nsipc_close>:

int
nsipc_close(int s)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea0:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  800ea5:	b8 04 00 00 00       	mov    $0x4,%eax
  800eaa:	e8 f3 fe ff ff       	call   800da2 <nsipc>
}
  800eaf:	c9                   	leave  
  800eb0:	c3                   	ret    

00800eb1 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	53                   	push   %ebx
  800eb5:	83 ec 08             	sub    $0x8,%esp
  800eb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebe:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ec3:	53                   	push   %ebx
  800ec4:	ff 75 0c             	push   0xc(%ebp)
  800ec7:	68 04 70 80 00       	push   $0x807004
  800ecc:	e8 37 0e 00 00       	call   801d08 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ed1:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  800ed7:	b8 05 00 00 00       	mov    $0x5,%eax
  800edc:	e8 c1 fe ff ff       	call   800da2 <nsipc>
}
  800ee1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee4:	c9                   	leave  
  800ee5:	c3                   	ret    

00800ee6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800eec:	8b 45 08             	mov    0x8(%ebp),%eax
  800eef:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  800ef4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef7:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  800efc:	b8 06 00 00 00       	mov    $0x6,%eax
  800f01:	e8 9c fe ff ff       	call   800da2 <nsipc>
}
  800f06:	c9                   	leave  
  800f07:	c3                   	ret    

00800f08 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	56                   	push   %esi
  800f0c:	53                   	push   %ebx
  800f0d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f10:	8b 45 08             	mov    0x8(%ebp),%eax
  800f13:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  800f18:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  800f1e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f21:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f26:	b8 07 00 00 00       	mov    $0x7,%eax
  800f2b:	e8 72 fe ff ff       	call   800da2 <nsipc>
  800f30:	89 c3                	mov    %eax,%ebx
  800f32:	85 c0                	test   %eax,%eax
  800f34:	78 22                	js     800f58 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  800f36:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f3b:	39 c6                	cmp    %eax,%esi
  800f3d:	0f 4e c6             	cmovle %esi,%eax
  800f40:	39 c3                	cmp    %eax,%ebx
  800f42:	7f 1d                	jg     800f61 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f44:	83 ec 04             	sub    $0x4,%esp
  800f47:	53                   	push   %ebx
  800f48:	68 00 70 80 00       	push   $0x807000
  800f4d:	ff 75 0c             	push   0xc(%ebp)
  800f50:	e8 b3 0d 00 00       	call   801d08 <memmove>
  800f55:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f58:	89 d8                	mov    %ebx,%eax
  800f5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f5d:	5b                   	pop    %ebx
  800f5e:	5e                   	pop    %esi
  800f5f:	5d                   	pop    %ebp
  800f60:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f61:	68 47 23 80 00       	push   $0x802347
  800f66:	68 0f 23 80 00       	push   $0x80230f
  800f6b:	6a 62                	push   $0x62
  800f6d:	68 5c 23 80 00       	push   $0x80235c
  800f72:	e8 46 05 00 00       	call   8014bd <_panic>

00800f77 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	53                   	push   %ebx
  800f7b:	83 ec 04             	sub    $0x4,%esp
  800f7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f81:	8b 45 08             	mov    0x8(%ebp),%eax
  800f84:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  800f89:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f8f:	7f 2e                	jg     800fbf <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f91:	83 ec 04             	sub    $0x4,%esp
  800f94:	53                   	push   %ebx
  800f95:	ff 75 0c             	push   0xc(%ebp)
  800f98:	68 0c 70 80 00       	push   $0x80700c
  800f9d:	e8 66 0d 00 00       	call   801d08 <memmove>
	nsipcbuf.send.req_size = size;
  800fa2:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  800fa8:	8b 45 14             	mov    0x14(%ebp),%eax
  800fab:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  800fb0:	b8 08 00 00 00       	mov    $0x8,%eax
  800fb5:	e8 e8 fd ff ff       	call   800da2 <nsipc>
}
  800fba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fbd:	c9                   	leave  
  800fbe:	c3                   	ret    
	assert(size < 1600);
  800fbf:	68 68 23 80 00       	push   $0x802368
  800fc4:	68 0f 23 80 00       	push   $0x80230f
  800fc9:	6a 6d                	push   $0x6d
  800fcb:	68 5c 23 80 00       	push   $0x80235c
  800fd0:	e8 e8 04 00 00       	call   8014bd <_panic>

00800fd5 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fde:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  800fe3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe6:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  800feb:	8b 45 10             	mov    0x10(%ebp),%eax
  800fee:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  800ff3:	b8 09 00 00 00       	mov    $0x9,%eax
  800ff8:	e8 a5 fd ff ff       	call   800da2 <nsipc>
}
  800ffd:	c9                   	leave  
  800ffe:	c3                   	ret    

00800fff <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	56                   	push   %esi
  801003:	53                   	push   %ebx
  801004:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	ff 75 08             	push   0x8(%ebp)
  80100d:	e8 ad f3 ff ff       	call   8003bf <fd2data>
  801012:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801014:	83 c4 08             	add    $0x8,%esp
  801017:	68 74 23 80 00       	push   $0x802374
  80101c:	53                   	push   %ebx
  80101d:	e8 50 0b 00 00       	call   801b72 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801022:	8b 46 04             	mov    0x4(%esi),%eax
  801025:	2b 06                	sub    (%esi),%eax
  801027:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80102d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801034:	00 00 00 
	stat->st_dev = &devpipe;
  801037:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80103e:	30 80 00 
	return 0;
}
  801041:	b8 00 00 00 00       	mov    $0x0,%eax
  801046:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801049:	5b                   	pop    %ebx
  80104a:	5e                   	pop    %esi
  80104b:	5d                   	pop    %ebp
  80104c:	c3                   	ret    

0080104d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	53                   	push   %ebx
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801057:	53                   	push   %ebx
  801058:	6a 00                	push   $0x0
  80105a:	e8 83 f1 ff ff       	call   8001e2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80105f:	89 1c 24             	mov    %ebx,(%esp)
  801062:	e8 58 f3 ff ff       	call   8003bf <fd2data>
  801067:	83 c4 08             	add    $0x8,%esp
  80106a:	50                   	push   %eax
  80106b:	6a 00                	push   $0x0
  80106d:	e8 70 f1 ff ff       	call   8001e2 <sys_page_unmap>
}
  801072:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801075:	c9                   	leave  
  801076:	c3                   	ret    

00801077 <_pipeisclosed>:
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	57                   	push   %edi
  80107b:	56                   	push   %esi
  80107c:	53                   	push   %ebx
  80107d:	83 ec 1c             	sub    $0x1c,%esp
  801080:	89 c7                	mov    %eax,%edi
  801082:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801084:	a1 00 40 80 00       	mov    0x804000,%eax
  801089:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80108c:	83 ec 0c             	sub    $0xc,%esp
  80108f:	57                   	push   %edi
  801090:	e8 20 0f 00 00       	call   801fb5 <pageref>
  801095:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801098:	89 34 24             	mov    %esi,(%esp)
  80109b:	e8 15 0f 00 00       	call   801fb5 <pageref>
		nn = thisenv->env_runs;
  8010a0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8010a6:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  8010a9:	83 c4 10             	add    $0x10,%esp
  8010ac:	39 cb                	cmp    %ecx,%ebx
  8010ae:	74 1b                	je     8010cb <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010b0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010b3:	75 cf                	jne    801084 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010b5:	8b 42 68             	mov    0x68(%edx),%eax
  8010b8:	6a 01                	push   $0x1
  8010ba:	50                   	push   %eax
  8010bb:	53                   	push   %ebx
  8010bc:	68 7b 23 80 00       	push   $0x80237b
  8010c1:	e8 d2 04 00 00       	call   801598 <cprintf>
  8010c6:	83 c4 10             	add    $0x10,%esp
  8010c9:	eb b9                	jmp    801084 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010cb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010ce:	0f 94 c0             	sete   %al
  8010d1:	0f b6 c0             	movzbl %al,%eax
}
  8010d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5f                   	pop    %edi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <devpipe_write>:
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	57                   	push   %edi
  8010e0:	56                   	push   %esi
  8010e1:	53                   	push   %ebx
  8010e2:	83 ec 28             	sub    $0x28,%esp
  8010e5:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8010e8:	56                   	push   %esi
  8010e9:	e8 d1 f2 ff ff       	call   8003bf <fd2data>
  8010ee:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	bf 00 00 00 00       	mov    $0x0,%edi
  8010f8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8010fb:	75 09                	jne    801106 <devpipe_write+0x2a>
	return i;
  8010fd:	89 f8                	mov    %edi,%eax
  8010ff:	eb 23                	jmp    801124 <devpipe_write+0x48>
			sys_yield();
  801101:	e8 38 f0 ff ff       	call   80013e <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801106:	8b 43 04             	mov    0x4(%ebx),%eax
  801109:	8b 0b                	mov    (%ebx),%ecx
  80110b:	8d 51 20             	lea    0x20(%ecx),%edx
  80110e:	39 d0                	cmp    %edx,%eax
  801110:	72 1a                	jb     80112c <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801112:	89 da                	mov    %ebx,%edx
  801114:	89 f0                	mov    %esi,%eax
  801116:	e8 5c ff ff ff       	call   801077 <_pipeisclosed>
  80111b:	85 c0                	test   %eax,%eax
  80111d:	74 e2                	je     801101 <devpipe_write+0x25>
				return 0;
  80111f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801127:	5b                   	pop    %ebx
  801128:	5e                   	pop    %esi
  801129:	5f                   	pop    %edi
  80112a:	5d                   	pop    %ebp
  80112b:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80112c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801133:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801136:	89 c2                	mov    %eax,%edx
  801138:	c1 fa 1f             	sar    $0x1f,%edx
  80113b:	89 d1                	mov    %edx,%ecx
  80113d:	c1 e9 1b             	shr    $0x1b,%ecx
  801140:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801143:	83 e2 1f             	and    $0x1f,%edx
  801146:	29 ca                	sub    %ecx,%edx
  801148:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80114c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801150:	83 c0 01             	add    $0x1,%eax
  801153:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801156:	83 c7 01             	add    $0x1,%edi
  801159:	eb 9d                	jmp    8010f8 <devpipe_write+0x1c>

0080115b <devpipe_read>:
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	57                   	push   %edi
  80115f:	56                   	push   %esi
  801160:	53                   	push   %ebx
  801161:	83 ec 18             	sub    $0x18,%esp
  801164:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801167:	57                   	push   %edi
  801168:	e8 52 f2 ff ff       	call   8003bf <fd2data>
  80116d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80116f:	83 c4 10             	add    $0x10,%esp
  801172:	be 00 00 00 00       	mov    $0x0,%esi
  801177:	3b 75 10             	cmp    0x10(%ebp),%esi
  80117a:	75 13                	jne    80118f <devpipe_read+0x34>
	return i;
  80117c:	89 f0                	mov    %esi,%eax
  80117e:	eb 02                	jmp    801182 <devpipe_read+0x27>
				return i;
  801180:	89 f0                	mov    %esi,%eax
}
  801182:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801185:	5b                   	pop    %ebx
  801186:	5e                   	pop    %esi
  801187:	5f                   	pop    %edi
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    
			sys_yield();
  80118a:	e8 af ef ff ff       	call   80013e <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80118f:	8b 03                	mov    (%ebx),%eax
  801191:	3b 43 04             	cmp    0x4(%ebx),%eax
  801194:	75 18                	jne    8011ae <devpipe_read+0x53>
			if (i > 0)
  801196:	85 f6                	test   %esi,%esi
  801198:	75 e6                	jne    801180 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  80119a:	89 da                	mov    %ebx,%edx
  80119c:	89 f8                	mov    %edi,%eax
  80119e:	e8 d4 fe ff ff       	call   801077 <_pipeisclosed>
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	74 e3                	je     80118a <devpipe_read+0x2f>
				return 0;
  8011a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ac:	eb d4                	jmp    801182 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011ae:	99                   	cltd   
  8011af:	c1 ea 1b             	shr    $0x1b,%edx
  8011b2:	01 d0                	add    %edx,%eax
  8011b4:	83 e0 1f             	and    $0x1f,%eax
  8011b7:	29 d0                	sub    %edx,%eax
  8011b9:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c1:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011c4:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011c7:	83 c6 01             	add    $0x1,%esi
  8011ca:	eb ab                	jmp    801177 <devpipe_read+0x1c>

008011cc <pipe>:
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	56                   	push   %esi
  8011d0:	53                   	push   %ebx
  8011d1:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d7:	50                   	push   %eax
  8011d8:	e8 f9 f1 ff ff       	call   8003d6 <fd_alloc>
  8011dd:	89 c3                	mov    %eax,%ebx
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	0f 88 23 01 00 00    	js     80130d <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011ea:	83 ec 04             	sub    $0x4,%esp
  8011ed:	68 07 04 00 00       	push   $0x407
  8011f2:	ff 75 f4             	push   -0xc(%ebp)
  8011f5:	6a 00                	push   $0x0
  8011f7:	e8 61 ef ff ff       	call   80015d <sys_page_alloc>
  8011fc:	89 c3                	mov    %eax,%ebx
  8011fe:	83 c4 10             	add    $0x10,%esp
  801201:	85 c0                	test   %eax,%eax
  801203:	0f 88 04 01 00 00    	js     80130d <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801209:	83 ec 0c             	sub    $0xc,%esp
  80120c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120f:	50                   	push   %eax
  801210:	e8 c1 f1 ff ff       	call   8003d6 <fd_alloc>
  801215:	89 c3                	mov    %eax,%ebx
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	85 c0                	test   %eax,%eax
  80121c:	0f 88 db 00 00 00    	js     8012fd <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801222:	83 ec 04             	sub    $0x4,%esp
  801225:	68 07 04 00 00       	push   $0x407
  80122a:	ff 75 f0             	push   -0x10(%ebp)
  80122d:	6a 00                	push   $0x0
  80122f:	e8 29 ef ff ff       	call   80015d <sys_page_alloc>
  801234:	89 c3                	mov    %eax,%ebx
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	85 c0                	test   %eax,%eax
  80123b:	0f 88 bc 00 00 00    	js     8012fd <pipe+0x131>
	va = fd2data(fd0);
  801241:	83 ec 0c             	sub    $0xc,%esp
  801244:	ff 75 f4             	push   -0xc(%ebp)
  801247:	e8 73 f1 ff ff       	call   8003bf <fd2data>
  80124c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80124e:	83 c4 0c             	add    $0xc,%esp
  801251:	68 07 04 00 00       	push   $0x407
  801256:	50                   	push   %eax
  801257:	6a 00                	push   $0x0
  801259:	e8 ff ee ff ff       	call   80015d <sys_page_alloc>
  80125e:	89 c3                	mov    %eax,%ebx
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	85 c0                	test   %eax,%eax
  801265:	0f 88 82 00 00 00    	js     8012ed <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80126b:	83 ec 0c             	sub    $0xc,%esp
  80126e:	ff 75 f0             	push   -0x10(%ebp)
  801271:	e8 49 f1 ff ff       	call   8003bf <fd2data>
  801276:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80127d:	50                   	push   %eax
  80127e:	6a 00                	push   $0x0
  801280:	56                   	push   %esi
  801281:	6a 00                	push   $0x0
  801283:	e8 18 ef ff ff       	call   8001a0 <sys_page_map>
  801288:	89 c3                	mov    %eax,%ebx
  80128a:	83 c4 20             	add    $0x20,%esp
  80128d:	85 c0                	test   %eax,%eax
  80128f:	78 4e                	js     8012df <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801291:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801296:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801299:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80129b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80129e:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012a8:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ad:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012b4:	83 ec 0c             	sub    $0xc,%esp
  8012b7:	ff 75 f4             	push   -0xc(%ebp)
  8012ba:	e8 f0 f0 ff ff       	call   8003af <fd2num>
  8012bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012c4:	83 c4 04             	add    $0x4,%esp
  8012c7:	ff 75 f0             	push   -0x10(%ebp)
  8012ca:	e8 e0 f0 ff ff       	call   8003af <fd2num>
  8012cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012d5:	83 c4 10             	add    $0x10,%esp
  8012d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012dd:	eb 2e                	jmp    80130d <pipe+0x141>
	sys_page_unmap(0, va);
  8012df:	83 ec 08             	sub    $0x8,%esp
  8012e2:	56                   	push   %esi
  8012e3:	6a 00                	push   $0x0
  8012e5:	e8 f8 ee ff ff       	call   8001e2 <sys_page_unmap>
  8012ea:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8012ed:	83 ec 08             	sub    $0x8,%esp
  8012f0:	ff 75 f0             	push   -0x10(%ebp)
  8012f3:	6a 00                	push   $0x0
  8012f5:	e8 e8 ee ff ff       	call   8001e2 <sys_page_unmap>
  8012fa:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8012fd:	83 ec 08             	sub    $0x8,%esp
  801300:	ff 75 f4             	push   -0xc(%ebp)
  801303:	6a 00                	push   $0x0
  801305:	e8 d8 ee ff ff       	call   8001e2 <sys_page_unmap>
  80130a:	83 c4 10             	add    $0x10,%esp
}
  80130d:	89 d8                	mov    %ebx,%eax
  80130f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801312:	5b                   	pop    %ebx
  801313:	5e                   	pop    %esi
  801314:	5d                   	pop    %ebp
  801315:	c3                   	ret    

00801316 <pipeisclosed>:
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80131c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131f:	50                   	push   %eax
  801320:	ff 75 08             	push   0x8(%ebp)
  801323:	e8 fe f0 ff ff       	call   800426 <fd_lookup>
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	85 c0                	test   %eax,%eax
  80132d:	78 18                	js     801347 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80132f:	83 ec 0c             	sub    $0xc,%esp
  801332:	ff 75 f4             	push   -0xc(%ebp)
  801335:	e8 85 f0 ff ff       	call   8003bf <fd2data>
  80133a:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80133c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133f:	e8 33 fd ff ff       	call   801077 <_pipeisclosed>
  801344:	83 c4 10             	add    $0x10,%esp
}
  801347:	c9                   	leave  
  801348:	c3                   	ret    

00801349 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801349:	b8 00 00 00 00       	mov    $0x0,%eax
  80134e:	c3                   	ret    

0080134f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801355:	68 93 23 80 00       	push   $0x802393
  80135a:	ff 75 0c             	push   0xc(%ebp)
  80135d:	e8 10 08 00 00       	call   801b72 <strcpy>
	return 0;
}
  801362:	b8 00 00 00 00       	mov    $0x0,%eax
  801367:	c9                   	leave  
  801368:	c3                   	ret    

00801369 <devcons_write>:
{
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
  80136c:	57                   	push   %edi
  80136d:	56                   	push   %esi
  80136e:	53                   	push   %ebx
  80136f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801375:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80137a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801380:	eb 2e                	jmp    8013b0 <devcons_write+0x47>
		m = n - tot;
  801382:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801385:	29 f3                	sub    %esi,%ebx
  801387:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80138c:	39 c3                	cmp    %eax,%ebx
  80138e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801391:	83 ec 04             	sub    $0x4,%esp
  801394:	53                   	push   %ebx
  801395:	89 f0                	mov    %esi,%eax
  801397:	03 45 0c             	add    0xc(%ebp),%eax
  80139a:	50                   	push   %eax
  80139b:	57                   	push   %edi
  80139c:	e8 67 09 00 00       	call   801d08 <memmove>
		sys_cputs(buf, m);
  8013a1:	83 c4 08             	add    $0x8,%esp
  8013a4:	53                   	push   %ebx
  8013a5:	57                   	push   %edi
  8013a6:	e8 f6 ec ff ff       	call   8000a1 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013ab:	01 de                	add    %ebx,%esi
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013b3:	72 cd                	jb     801382 <devcons_write+0x19>
}
  8013b5:	89 f0                	mov    %esi,%eax
  8013b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ba:	5b                   	pop    %ebx
  8013bb:	5e                   	pop    %esi
  8013bc:	5f                   	pop    %edi
  8013bd:	5d                   	pop    %ebp
  8013be:	c3                   	ret    

008013bf <devcons_read>:
{
  8013bf:	55                   	push   %ebp
  8013c0:	89 e5                	mov    %esp,%ebp
  8013c2:	83 ec 08             	sub    $0x8,%esp
  8013c5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013ce:	75 07                	jne    8013d7 <devcons_read+0x18>
  8013d0:	eb 1f                	jmp    8013f1 <devcons_read+0x32>
		sys_yield();
  8013d2:	e8 67 ed ff ff       	call   80013e <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8013d7:	e8 e3 ec ff ff       	call   8000bf <sys_cgetc>
  8013dc:	85 c0                	test   %eax,%eax
  8013de:	74 f2                	je     8013d2 <devcons_read+0x13>
	if (c < 0)
  8013e0:	78 0f                	js     8013f1 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8013e2:	83 f8 04             	cmp    $0x4,%eax
  8013e5:	74 0c                	je     8013f3 <devcons_read+0x34>
	*(char*)vbuf = c;
  8013e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ea:	88 02                	mov    %al,(%edx)
	return 1;
  8013ec:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8013f1:	c9                   	leave  
  8013f2:	c3                   	ret    
		return 0;
  8013f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f8:	eb f7                	jmp    8013f1 <devcons_read+0x32>

008013fa <cputchar>:
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801400:	8b 45 08             	mov    0x8(%ebp),%eax
  801403:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801406:	6a 01                	push   $0x1
  801408:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80140b:	50                   	push   %eax
  80140c:	e8 90 ec ff ff       	call   8000a1 <sys_cputs>
}
  801411:	83 c4 10             	add    $0x10,%esp
  801414:	c9                   	leave  
  801415:	c3                   	ret    

00801416 <getchar>:
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80141c:	6a 01                	push   $0x1
  80141e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801421:	50                   	push   %eax
  801422:	6a 00                	push   $0x0
  801424:	e8 66 f2 ff ff       	call   80068f <read>
	if (r < 0)
  801429:	83 c4 10             	add    $0x10,%esp
  80142c:	85 c0                	test   %eax,%eax
  80142e:	78 06                	js     801436 <getchar+0x20>
	if (r < 1)
  801430:	74 06                	je     801438 <getchar+0x22>
	return c;
  801432:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801436:	c9                   	leave  
  801437:	c3                   	ret    
		return -E_EOF;
  801438:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80143d:	eb f7                	jmp    801436 <getchar+0x20>

0080143f <iscons>:
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801445:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801448:	50                   	push   %eax
  801449:	ff 75 08             	push   0x8(%ebp)
  80144c:	e8 d5 ef ff ff       	call   800426 <fd_lookup>
  801451:	83 c4 10             	add    $0x10,%esp
  801454:	85 c0                	test   %eax,%eax
  801456:	78 11                	js     801469 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801458:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801461:	39 10                	cmp    %edx,(%eax)
  801463:	0f 94 c0             	sete   %al
  801466:	0f b6 c0             	movzbl %al,%eax
}
  801469:	c9                   	leave  
  80146a:	c3                   	ret    

0080146b <opencons>:
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801471:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801474:	50                   	push   %eax
  801475:	e8 5c ef ff ff       	call   8003d6 <fd_alloc>
  80147a:	83 c4 10             	add    $0x10,%esp
  80147d:	85 c0                	test   %eax,%eax
  80147f:	78 3a                	js     8014bb <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801481:	83 ec 04             	sub    $0x4,%esp
  801484:	68 07 04 00 00       	push   $0x407
  801489:	ff 75 f4             	push   -0xc(%ebp)
  80148c:	6a 00                	push   $0x0
  80148e:	e8 ca ec ff ff       	call   80015d <sys_page_alloc>
  801493:	83 c4 10             	add    $0x10,%esp
  801496:	85 c0                	test   %eax,%eax
  801498:	78 21                	js     8014bb <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80149a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149d:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014a3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014af:	83 ec 0c             	sub    $0xc,%esp
  8014b2:	50                   	push   %eax
  8014b3:	e8 f7 ee ff ff       	call   8003af <fd2num>
  8014b8:	83 c4 10             	add    $0x10,%esp
}
  8014bb:	c9                   	leave  
  8014bc:	c3                   	ret    

008014bd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
  8014c0:	56                   	push   %esi
  8014c1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014c2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014c5:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014cb:	e8 4f ec ff ff       	call   80011f <sys_getenvid>
  8014d0:	83 ec 0c             	sub    $0xc,%esp
  8014d3:	ff 75 0c             	push   0xc(%ebp)
  8014d6:	ff 75 08             	push   0x8(%ebp)
  8014d9:	56                   	push   %esi
  8014da:	50                   	push   %eax
  8014db:	68 a0 23 80 00       	push   $0x8023a0
  8014e0:	e8 b3 00 00 00       	call   801598 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014e5:	83 c4 18             	add    $0x18,%esp
  8014e8:	53                   	push   %ebx
  8014e9:	ff 75 10             	push   0x10(%ebp)
  8014ec:	e8 56 00 00 00       	call   801547 <vcprintf>
	cprintf("\n");
  8014f1:	c7 04 24 8c 23 80 00 	movl   $0x80238c,(%esp)
  8014f8:	e8 9b 00 00 00       	call   801598 <cprintf>
  8014fd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801500:	cc                   	int3   
  801501:	eb fd                	jmp    801500 <_panic+0x43>

00801503 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	53                   	push   %ebx
  801507:	83 ec 04             	sub    $0x4,%esp
  80150a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80150d:	8b 13                	mov    (%ebx),%edx
  80150f:	8d 42 01             	lea    0x1(%edx),%eax
  801512:	89 03                	mov    %eax,(%ebx)
  801514:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801517:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80151b:	3d ff 00 00 00       	cmp    $0xff,%eax
  801520:	74 09                	je     80152b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801522:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801526:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801529:	c9                   	leave  
  80152a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80152b:	83 ec 08             	sub    $0x8,%esp
  80152e:	68 ff 00 00 00       	push   $0xff
  801533:	8d 43 08             	lea    0x8(%ebx),%eax
  801536:	50                   	push   %eax
  801537:	e8 65 eb ff ff       	call   8000a1 <sys_cputs>
		b->idx = 0;
  80153c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801542:	83 c4 10             	add    $0x10,%esp
  801545:	eb db                	jmp    801522 <putch+0x1f>

00801547 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801547:	55                   	push   %ebp
  801548:	89 e5                	mov    %esp,%ebp
  80154a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801550:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801557:	00 00 00 
	b.cnt = 0;
  80155a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801561:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801564:	ff 75 0c             	push   0xc(%ebp)
  801567:	ff 75 08             	push   0x8(%ebp)
  80156a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801570:	50                   	push   %eax
  801571:	68 03 15 80 00       	push   $0x801503
  801576:	e8 14 01 00 00       	call   80168f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80157b:	83 c4 08             	add    $0x8,%esp
  80157e:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  801584:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80158a:	50                   	push   %eax
  80158b:	e8 11 eb ff ff       	call   8000a1 <sys_cputs>

	return b.cnt;
}
  801590:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801596:	c9                   	leave  
  801597:	c3                   	ret    

00801598 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80159e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015a1:	50                   	push   %eax
  8015a2:	ff 75 08             	push   0x8(%ebp)
  8015a5:	e8 9d ff ff ff       	call   801547 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015aa:	c9                   	leave  
  8015ab:	c3                   	ret    

008015ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	57                   	push   %edi
  8015b0:	56                   	push   %esi
  8015b1:	53                   	push   %ebx
  8015b2:	83 ec 1c             	sub    $0x1c,%esp
  8015b5:	89 c7                	mov    %eax,%edi
  8015b7:	89 d6                	mov    %edx,%esi
  8015b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015bf:	89 d1                	mov    %edx,%ecx
  8015c1:	89 c2                	mov    %eax,%edx
  8015c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015c6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8015cc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015d2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8015d9:	39 c2                	cmp    %eax,%edx
  8015db:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8015de:	72 3e                	jb     80161e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015e0:	83 ec 0c             	sub    $0xc,%esp
  8015e3:	ff 75 18             	push   0x18(%ebp)
  8015e6:	83 eb 01             	sub    $0x1,%ebx
  8015e9:	53                   	push   %ebx
  8015ea:	50                   	push   %eax
  8015eb:	83 ec 08             	sub    $0x8,%esp
  8015ee:	ff 75 e4             	push   -0x1c(%ebp)
  8015f1:	ff 75 e0             	push   -0x20(%ebp)
  8015f4:	ff 75 dc             	push   -0x24(%ebp)
  8015f7:	ff 75 d8             	push   -0x28(%ebp)
  8015fa:	e8 01 0a 00 00       	call   802000 <__udivdi3>
  8015ff:	83 c4 18             	add    $0x18,%esp
  801602:	52                   	push   %edx
  801603:	50                   	push   %eax
  801604:	89 f2                	mov    %esi,%edx
  801606:	89 f8                	mov    %edi,%eax
  801608:	e8 9f ff ff ff       	call   8015ac <printnum>
  80160d:	83 c4 20             	add    $0x20,%esp
  801610:	eb 13                	jmp    801625 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	56                   	push   %esi
  801616:	ff 75 18             	push   0x18(%ebp)
  801619:	ff d7                	call   *%edi
  80161b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80161e:	83 eb 01             	sub    $0x1,%ebx
  801621:	85 db                	test   %ebx,%ebx
  801623:	7f ed                	jg     801612 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	56                   	push   %esi
  801629:	83 ec 04             	sub    $0x4,%esp
  80162c:	ff 75 e4             	push   -0x1c(%ebp)
  80162f:	ff 75 e0             	push   -0x20(%ebp)
  801632:	ff 75 dc             	push   -0x24(%ebp)
  801635:	ff 75 d8             	push   -0x28(%ebp)
  801638:	e8 e3 0a 00 00       	call   802120 <__umoddi3>
  80163d:	83 c4 14             	add    $0x14,%esp
  801640:	0f be 80 c3 23 80 00 	movsbl 0x8023c3(%eax),%eax
  801647:	50                   	push   %eax
  801648:	ff d7                	call   *%edi
}
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801650:	5b                   	pop    %ebx
  801651:	5e                   	pop    %esi
  801652:	5f                   	pop    %edi
  801653:	5d                   	pop    %ebp
  801654:	c3                   	ret    

00801655 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80165b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80165f:	8b 10                	mov    (%eax),%edx
  801661:	3b 50 04             	cmp    0x4(%eax),%edx
  801664:	73 0a                	jae    801670 <sprintputch+0x1b>
		*b->buf++ = ch;
  801666:	8d 4a 01             	lea    0x1(%edx),%ecx
  801669:	89 08                	mov    %ecx,(%eax)
  80166b:	8b 45 08             	mov    0x8(%ebp),%eax
  80166e:	88 02                	mov    %al,(%edx)
}
  801670:	5d                   	pop    %ebp
  801671:	c3                   	ret    

00801672 <printfmt>:
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801678:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80167b:	50                   	push   %eax
  80167c:	ff 75 10             	push   0x10(%ebp)
  80167f:	ff 75 0c             	push   0xc(%ebp)
  801682:	ff 75 08             	push   0x8(%ebp)
  801685:	e8 05 00 00 00       	call   80168f <vprintfmt>
}
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	c9                   	leave  
  80168e:	c3                   	ret    

0080168f <vprintfmt>:
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	57                   	push   %edi
  801693:	56                   	push   %esi
  801694:	53                   	push   %ebx
  801695:	83 ec 3c             	sub    $0x3c,%esp
  801698:	8b 75 08             	mov    0x8(%ebp),%esi
  80169b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80169e:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016a1:	eb 0a                	jmp    8016ad <vprintfmt+0x1e>
			putch(ch, putdat);
  8016a3:	83 ec 08             	sub    $0x8,%esp
  8016a6:	53                   	push   %ebx
  8016a7:	50                   	push   %eax
  8016a8:	ff d6                	call   *%esi
  8016aa:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016ad:	83 c7 01             	add    $0x1,%edi
  8016b0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016b4:	83 f8 25             	cmp    $0x25,%eax
  8016b7:	74 0c                	je     8016c5 <vprintfmt+0x36>
			if (ch == '\0')
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	75 e6                	jne    8016a3 <vprintfmt+0x14>
}
  8016bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c0:	5b                   	pop    %ebx
  8016c1:	5e                   	pop    %esi
  8016c2:	5f                   	pop    %edi
  8016c3:	5d                   	pop    %ebp
  8016c4:	c3                   	ret    
		padc = ' ';
  8016c5:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8016c9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8016d0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8016d7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8016de:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8016e3:	8d 47 01             	lea    0x1(%edi),%eax
  8016e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016e9:	0f b6 17             	movzbl (%edi),%edx
  8016ec:	8d 42 dd             	lea    -0x23(%edx),%eax
  8016ef:	3c 55                	cmp    $0x55,%al
  8016f1:	0f 87 bb 03 00 00    	ja     801ab2 <vprintfmt+0x423>
  8016f7:	0f b6 c0             	movzbl %al,%eax
  8016fa:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
  801701:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801704:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801708:	eb d9                	jmp    8016e3 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80170a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80170d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801711:	eb d0                	jmp    8016e3 <vprintfmt+0x54>
  801713:	0f b6 d2             	movzbl %dl,%edx
  801716:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801719:	b8 00 00 00 00       	mov    $0x0,%eax
  80171e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801721:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801724:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801728:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80172b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80172e:	83 f9 09             	cmp    $0x9,%ecx
  801731:	77 55                	ja     801788 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  801733:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801736:	eb e9                	jmp    801721 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801738:	8b 45 14             	mov    0x14(%ebp),%eax
  80173b:	8b 00                	mov    (%eax),%eax
  80173d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801740:	8b 45 14             	mov    0x14(%ebp),%eax
  801743:	8d 40 04             	lea    0x4(%eax),%eax
  801746:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801749:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80174c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801750:	79 91                	jns    8016e3 <vprintfmt+0x54>
				width = precision, precision = -1;
  801752:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801755:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801758:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80175f:	eb 82                	jmp    8016e3 <vprintfmt+0x54>
  801761:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801764:	85 d2                	test   %edx,%edx
  801766:	b8 00 00 00 00       	mov    $0x0,%eax
  80176b:	0f 49 c2             	cmovns %edx,%eax
  80176e:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801771:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801774:	e9 6a ff ff ff       	jmp    8016e3 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801779:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80177c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801783:	e9 5b ff ff ff       	jmp    8016e3 <vprintfmt+0x54>
  801788:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80178b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80178e:	eb bc                	jmp    80174c <vprintfmt+0xbd>
			lflag++;
  801790:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801793:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801796:	e9 48 ff ff ff       	jmp    8016e3 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80179b:	8b 45 14             	mov    0x14(%ebp),%eax
  80179e:	8d 78 04             	lea    0x4(%eax),%edi
  8017a1:	83 ec 08             	sub    $0x8,%esp
  8017a4:	53                   	push   %ebx
  8017a5:	ff 30                	push   (%eax)
  8017a7:	ff d6                	call   *%esi
			break;
  8017a9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017ac:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017af:	e9 9d 02 00 00       	jmp    801a51 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8017b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8017b7:	8d 78 04             	lea    0x4(%eax),%edi
  8017ba:	8b 10                	mov    (%eax),%edx
  8017bc:	89 d0                	mov    %edx,%eax
  8017be:	f7 d8                	neg    %eax
  8017c0:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017c3:	83 f8 0f             	cmp    $0xf,%eax
  8017c6:	7f 23                	jg     8017eb <vprintfmt+0x15c>
  8017c8:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  8017cf:	85 d2                	test   %edx,%edx
  8017d1:	74 18                	je     8017eb <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8017d3:	52                   	push   %edx
  8017d4:	68 21 23 80 00       	push   $0x802321
  8017d9:	53                   	push   %ebx
  8017da:	56                   	push   %esi
  8017db:	e8 92 fe ff ff       	call   801672 <printfmt>
  8017e0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017e3:	89 7d 14             	mov    %edi,0x14(%ebp)
  8017e6:	e9 66 02 00 00       	jmp    801a51 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8017eb:	50                   	push   %eax
  8017ec:	68 db 23 80 00       	push   $0x8023db
  8017f1:	53                   	push   %ebx
  8017f2:	56                   	push   %esi
  8017f3:	e8 7a fe ff ff       	call   801672 <printfmt>
  8017f8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017fb:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8017fe:	e9 4e 02 00 00       	jmp    801a51 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  801803:	8b 45 14             	mov    0x14(%ebp),%eax
  801806:	83 c0 04             	add    $0x4,%eax
  801809:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80180c:	8b 45 14             	mov    0x14(%ebp),%eax
  80180f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801811:	85 d2                	test   %edx,%edx
  801813:	b8 d4 23 80 00       	mov    $0x8023d4,%eax
  801818:	0f 45 c2             	cmovne %edx,%eax
  80181b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80181e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801822:	7e 06                	jle    80182a <vprintfmt+0x19b>
  801824:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801828:	75 0d                	jne    801837 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80182a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80182d:	89 c7                	mov    %eax,%edi
  80182f:	03 45 e0             	add    -0x20(%ebp),%eax
  801832:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801835:	eb 55                	jmp    80188c <vprintfmt+0x1fd>
  801837:	83 ec 08             	sub    $0x8,%esp
  80183a:	ff 75 d8             	push   -0x28(%ebp)
  80183d:	ff 75 cc             	push   -0x34(%ebp)
  801840:	e8 0a 03 00 00       	call   801b4f <strnlen>
  801845:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801848:	29 c1                	sub    %eax,%ecx
  80184a:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80184d:	83 c4 10             	add    $0x10,%esp
  801850:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  801852:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801856:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801859:	eb 0f                	jmp    80186a <vprintfmt+0x1db>
					putch(padc, putdat);
  80185b:	83 ec 08             	sub    $0x8,%esp
  80185e:	53                   	push   %ebx
  80185f:	ff 75 e0             	push   -0x20(%ebp)
  801862:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801864:	83 ef 01             	sub    $0x1,%edi
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	85 ff                	test   %edi,%edi
  80186c:	7f ed                	jg     80185b <vprintfmt+0x1cc>
  80186e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801871:	85 d2                	test   %edx,%edx
  801873:	b8 00 00 00 00       	mov    $0x0,%eax
  801878:	0f 49 c2             	cmovns %edx,%eax
  80187b:	29 c2                	sub    %eax,%edx
  80187d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801880:	eb a8                	jmp    80182a <vprintfmt+0x19b>
					putch(ch, putdat);
  801882:	83 ec 08             	sub    $0x8,%esp
  801885:	53                   	push   %ebx
  801886:	52                   	push   %edx
  801887:	ff d6                	call   *%esi
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80188f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801891:	83 c7 01             	add    $0x1,%edi
  801894:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801898:	0f be d0             	movsbl %al,%edx
  80189b:	85 d2                	test   %edx,%edx
  80189d:	74 4b                	je     8018ea <vprintfmt+0x25b>
  80189f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018a3:	78 06                	js     8018ab <vprintfmt+0x21c>
  8018a5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018a9:	78 1e                	js     8018c9 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8018ab:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018af:	74 d1                	je     801882 <vprintfmt+0x1f3>
  8018b1:	0f be c0             	movsbl %al,%eax
  8018b4:	83 e8 20             	sub    $0x20,%eax
  8018b7:	83 f8 5e             	cmp    $0x5e,%eax
  8018ba:	76 c6                	jbe    801882 <vprintfmt+0x1f3>
					putch('?', putdat);
  8018bc:	83 ec 08             	sub    $0x8,%esp
  8018bf:	53                   	push   %ebx
  8018c0:	6a 3f                	push   $0x3f
  8018c2:	ff d6                	call   *%esi
  8018c4:	83 c4 10             	add    $0x10,%esp
  8018c7:	eb c3                	jmp    80188c <vprintfmt+0x1fd>
  8018c9:	89 cf                	mov    %ecx,%edi
  8018cb:	eb 0e                	jmp    8018db <vprintfmt+0x24c>
				putch(' ', putdat);
  8018cd:	83 ec 08             	sub    $0x8,%esp
  8018d0:	53                   	push   %ebx
  8018d1:	6a 20                	push   $0x20
  8018d3:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8018d5:	83 ef 01             	sub    $0x1,%edi
  8018d8:	83 c4 10             	add    $0x10,%esp
  8018db:	85 ff                	test   %edi,%edi
  8018dd:	7f ee                	jg     8018cd <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8018df:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8018e2:	89 45 14             	mov    %eax,0x14(%ebp)
  8018e5:	e9 67 01 00 00       	jmp    801a51 <vprintfmt+0x3c2>
  8018ea:	89 cf                	mov    %ecx,%edi
  8018ec:	eb ed                	jmp    8018db <vprintfmt+0x24c>
	if (lflag >= 2)
  8018ee:	83 f9 01             	cmp    $0x1,%ecx
  8018f1:	7f 1b                	jg     80190e <vprintfmt+0x27f>
	else if (lflag)
  8018f3:	85 c9                	test   %ecx,%ecx
  8018f5:	74 63                	je     80195a <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8018f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8018fa:	8b 00                	mov    (%eax),%eax
  8018fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018ff:	99                   	cltd   
  801900:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801903:	8b 45 14             	mov    0x14(%ebp),%eax
  801906:	8d 40 04             	lea    0x4(%eax),%eax
  801909:	89 45 14             	mov    %eax,0x14(%ebp)
  80190c:	eb 17                	jmp    801925 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80190e:	8b 45 14             	mov    0x14(%ebp),%eax
  801911:	8b 50 04             	mov    0x4(%eax),%edx
  801914:	8b 00                	mov    (%eax),%eax
  801916:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801919:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80191c:	8b 45 14             	mov    0x14(%ebp),%eax
  80191f:	8d 40 08             	lea    0x8(%eax),%eax
  801922:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801925:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801928:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80192b:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801930:	85 c9                	test   %ecx,%ecx
  801932:	0f 89 ff 00 00 00    	jns    801a37 <vprintfmt+0x3a8>
				putch('-', putdat);
  801938:	83 ec 08             	sub    $0x8,%esp
  80193b:	53                   	push   %ebx
  80193c:	6a 2d                	push   $0x2d
  80193e:	ff d6                	call   *%esi
				num = -(long long) num;
  801940:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801943:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801946:	f7 da                	neg    %edx
  801948:	83 d1 00             	adc    $0x0,%ecx
  80194b:	f7 d9                	neg    %ecx
  80194d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801950:	bf 0a 00 00 00       	mov    $0xa,%edi
  801955:	e9 dd 00 00 00       	jmp    801a37 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80195a:	8b 45 14             	mov    0x14(%ebp),%eax
  80195d:	8b 00                	mov    (%eax),%eax
  80195f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801962:	99                   	cltd   
  801963:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801966:	8b 45 14             	mov    0x14(%ebp),%eax
  801969:	8d 40 04             	lea    0x4(%eax),%eax
  80196c:	89 45 14             	mov    %eax,0x14(%ebp)
  80196f:	eb b4                	jmp    801925 <vprintfmt+0x296>
	if (lflag >= 2)
  801971:	83 f9 01             	cmp    $0x1,%ecx
  801974:	7f 1e                	jg     801994 <vprintfmt+0x305>
	else if (lflag)
  801976:	85 c9                	test   %ecx,%ecx
  801978:	74 32                	je     8019ac <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80197a:	8b 45 14             	mov    0x14(%ebp),%eax
  80197d:	8b 10                	mov    (%eax),%edx
  80197f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801984:	8d 40 04             	lea    0x4(%eax),%eax
  801987:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80198a:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80198f:	e9 a3 00 00 00       	jmp    801a37 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801994:	8b 45 14             	mov    0x14(%ebp),%eax
  801997:	8b 10                	mov    (%eax),%edx
  801999:	8b 48 04             	mov    0x4(%eax),%ecx
  80199c:	8d 40 08             	lea    0x8(%eax),%eax
  80199f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019a2:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8019a7:	e9 8b 00 00 00       	jmp    801a37 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8019af:	8b 10                	mov    (%eax),%edx
  8019b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019b6:	8d 40 04             	lea    0x4(%eax),%eax
  8019b9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019bc:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8019c1:	eb 74                	jmp    801a37 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8019c3:	83 f9 01             	cmp    $0x1,%ecx
  8019c6:	7f 1b                	jg     8019e3 <vprintfmt+0x354>
	else if (lflag)
  8019c8:	85 c9                	test   %ecx,%ecx
  8019ca:	74 2c                	je     8019f8 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8019cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8019cf:	8b 10                	mov    (%eax),%edx
  8019d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019d6:	8d 40 04             	lea    0x4(%eax),%eax
  8019d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019dc:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8019e1:	eb 54                	jmp    801a37 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e6:	8b 10                	mov    (%eax),%edx
  8019e8:	8b 48 04             	mov    0x4(%eax),%ecx
  8019eb:	8d 40 08             	lea    0x8(%eax),%eax
  8019ee:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019f1:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8019f6:	eb 3f                	jmp    801a37 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019fb:	8b 10                	mov    (%eax),%edx
  8019fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a02:	8d 40 04             	lea    0x4(%eax),%eax
  801a05:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a08:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801a0d:	eb 28                	jmp    801a37 <vprintfmt+0x3a8>
			putch('0', putdat);
  801a0f:	83 ec 08             	sub    $0x8,%esp
  801a12:	53                   	push   %ebx
  801a13:	6a 30                	push   $0x30
  801a15:	ff d6                	call   *%esi
			putch('x', putdat);
  801a17:	83 c4 08             	add    $0x8,%esp
  801a1a:	53                   	push   %ebx
  801a1b:	6a 78                	push   $0x78
  801a1d:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a1f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a22:	8b 10                	mov    (%eax),%edx
  801a24:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a29:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a2c:	8d 40 04             	lea    0x4(%eax),%eax
  801a2f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a32:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801a37:	83 ec 0c             	sub    $0xc,%esp
  801a3a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801a3e:	50                   	push   %eax
  801a3f:	ff 75 e0             	push   -0x20(%ebp)
  801a42:	57                   	push   %edi
  801a43:	51                   	push   %ecx
  801a44:	52                   	push   %edx
  801a45:	89 da                	mov    %ebx,%edx
  801a47:	89 f0                	mov    %esi,%eax
  801a49:	e8 5e fb ff ff       	call   8015ac <printnum>
			break;
  801a4e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801a51:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a54:	e9 54 fc ff ff       	jmp    8016ad <vprintfmt+0x1e>
	if (lflag >= 2)
  801a59:	83 f9 01             	cmp    $0x1,%ecx
  801a5c:	7f 1b                	jg     801a79 <vprintfmt+0x3ea>
	else if (lflag)
  801a5e:	85 c9                	test   %ecx,%ecx
  801a60:	74 2c                	je     801a8e <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801a62:	8b 45 14             	mov    0x14(%ebp),%eax
  801a65:	8b 10                	mov    (%eax),%edx
  801a67:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a6c:	8d 40 04             	lea    0x4(%eax),%eax
  801a6f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a72:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801a77:	eb be                	jmp    801a37 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801a79:	8b 45 14             	mov    0x14(%ebp),%eax
  801a7c:	8b 10                	mov    (%eax),%edx
  801a7e:	8b 48 04             	mov    0x4(%eax),%ecx
  801a81:	8d 40 08             	lea    0x8(%eax),%eax
  801a84:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a87:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  801a8c:	eb a9                	jmp    801a37 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a8e:	8b 45 14             	mov    0x14(%ebp),%eax
  801a91:	8b 10                	mov    (%eax),%edx
  801a93:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a98:	8d 40 04             	lea    0x4(%eax),%eax
  801a9b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a9e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  801aa3:	eb 92                	jmp    801a37 <vprintfmt+0x3a8>
			putch(ch, putdat);
  801aa5:	83 ec 08             	sub    $0x8,%esp
  801aa8:	53                   	push   %ebx
  801aa9:	6a 25                	push   $0x25
  801aab:	ff d6                	call   *%esi
			break;
  801aad:	83 c4 10             	add    $0x10,%esp
  801ab0:	eb 9f                	jmp    801a51 <vprintfmt+0x3c2>
			putch('%', putdat);
  801ab2:	83 ec 08             	sub    $0x8,%esp
  801ab5:	53                   	push   %ebx
  801ab6:	6a 25                	push   $0x25
  801ab8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	89 f8                	mov    %edi,%eax
  801abf:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801ac3:	74 05                	je     801aca <vprintfmt+0x43b>
  801ac5:	83 e8 01             	sub    $0x1,%eax
  801ac8:	eb f5                	jmp    801abf <vprintfmt+0x430>
  801aca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801acd:	eb 82                	jmp    801a51 <vprintfmt+0x3c2>

00801acf <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	83 ec 18             	sub    $0x18,%esp
  801ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801adb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ade:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ae2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ae5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801aec:	85 c0                	test   %eax,%eax
  801aee:	74 26                	je     801b16 <vsnprintf+0x47>
  801af0:	85 d2                	test   %edx,%edx
  801af2:	7e 22                	jle    801b16 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801af4:	ff 75 14             	push   0x14(%ebp)
  801af7:	ff 75 10             	push   0x10(%ebp)
  801afa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801afd:	50                   	push   %eax
  801afe:	68 55 16 80 00       	push   $0x801655
  801b03:	e8 87 fb ff ff       	call   80168f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b08:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b0b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b11:	83 c4 10             	add    $0x10,%esp
}
  801b14:	c9                   	leave  
  801b15:	c3                   	ret    
		return -E_INVAL;
  801b16:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b1b:	eb f7                	jmp    801b14 <vsnprintf+0x45>

00801b1d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b23:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b26:	50                   	push   %eax
  801b27:	ff 75 10             	push   0x10(%ebp)
  801b2a:	ff 75 0c             	push   0xc(%ebp)
  801b2d:	ff 75 08             	push   0x8(%ebp)
  801b30:	e8 9a ff ff ff       	call   801acf <vsnprintf>
	va_end(ap);

	return rc;
}
  801b35:	c9                   	leave  
  801b36:	c3                   	ret    

00801b37 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b37:	55                   	push   %ebp
  801b38:	89 e5                	mov    %esp,%ebp
  801b3a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b42:	eb 03                	jmp    801b47 <strlen+0x10>
		n++;
  801b44:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801b47:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b4b:	75 f7                	jne    801b44 <strlen+0xd>
	return n;
}
  801b4d:	5d                   	pop    %ebp
  801b4e:	c3                   	ret    

00801b4f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b55:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b58:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5d:	eb 03                	jmp    801b62 <strnlen+0x13>
		n++;
  801b5f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b62:	39 d0                	cmp    %edx,%eax
  801b64:	74 08                	je     801b6e <strnlen+0x1f>
  801b66:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801b6a:	75 f3                	jne    801b5f <strnlen+0x10>
  801b6c:	89 c2                	mov    %eax,%edx
	return n;
}
  801b6e:	89 d0                	mov    %edx,%eax
  801b70:	5d                   	pop    %ebp
  801b71:	c3                   	ret    

00801b72 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	53                   	push   %ebx
  801b76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b79:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b7c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b81:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801b85:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801b88:	83 c0 01             	add    $0x1,%eax
  801b8b:	84 d2                	test   %dl,%dl
  801b8d:	75 f2                	jne    801b81 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801b8f:	89 c8                	mov    %ecx,%eax
  801b91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b94:	c9                   	leave  
  801b95:	c3                   	ret    

00801b96 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	53                   	push   %ebx
  801b9a:	83 ec 10             	sub    $0x10,%esp
  801b9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801ba0:	53                   	push   %ebx
  801ba1:	e8 91 ff ff ff       	call   801b37 <strlen>
  801ba6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801ba9:	ff 75 0c             	push   0xc(%ebp)
  801bac:	01 d8                	add    %ebx,%eax
  801bae:	50                   	push   %eax
  801baf:	e8 be ff ff ff       	call   801b72 <strcpy>
	return dst;
}
  801bb4:	89 d8                	mov    %ebx,%eax
  801bb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb9:	c9                   	leave  
  801bba:	c3                   	ret    

00801bbb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	56                   	push   %esi
  801bbf:	53                   	push   %ebx
  801bc0:	8b 75 08             	mov    0x8(%ebp),%esi
  801bc3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bc6:	89 f3                	mov    %esi,%ebx
  801bc8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bcb:	89 f0                	mov    %esi,%eax
  801bcd:	eb 0f                	jmp    801bde <strncpy+0x23>
		*dst++ = *src;
  801bcf:	83 c0 01             	add    $0x1,%eax
  801bd2:	0f b6 0a             	movzbl (%edx),%ecx
  801bd5:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bd8:	80 f9 01             	cmp    $0x1,%cl
  801bdb:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801bde:	39 d8                	cmp    %ebx,%eax
  801be0:	75 ed                	jne    801bcf <strncpy+0x14>
	}
	return ret;
}
  801be2:	89 f0                	mov    %esi,%eax
  801be4:	5b                   	pop    %ebx
  801be5:	5e                   	pop    %esi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    

00801be8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	56                   	push   %esi
  801bec:	53                   	push   %ebx
  801bed:	8b 75 08             	mov    0x8(%ebp),%esi
  801bf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bf3:	8b 55 10             	mov    0x10(%ebp),%edx
  801bf6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bf8:	85 d2                	test   %edx,%edx
  801bfa:	74 21                	je     801c1d <strlcpy+0x35>
  801bfc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c00:	89 f2                	mov    %esi,%edx
  801c02:	eb 09                	jmp    801c0d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c04:	83 c1 01             	add    $0x1,%ecx
  801c07:	83 c2 01             	add    $0x1,%edx
  801c0a:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801c0d:	39 c2                	cmp    %eax,%edx
  801c0f:	74 09                	je     801c1a <strlcpy+0x32>
  801c11:	0f b6 19             	movzbl (%ecx),%ebx
  801c14:	84 db                	test   %bl,%bl
  801c16:	75 ec                	jne    801c04 <strlcpy+0x1c>
  801c18:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c1a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c1d:	29 f0                	sub    %esi,%eax
}
  801c1f:	5b                   	pop    %ebx
  801c20:	5e                   	pop    %esi
  801c21:	5d                   	pop    %ebp
  801c22:	c3                   	ret    

00801c23 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c29:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c2c:	eb 06                	jmp    801c34 <strcmp+0x11>
		p++, q++;
  801c2e:	83 c1 01             	add    $0x1,%ecx
  801c31:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801c34:	0f b6 01             	movzbl (%ecx),%eax
  801c37:	84 c0                	test   %al,%al
  801c39:	74 04                	je     801c3f <strcmp+0x1c>
  801c3b:	3a 02                	cmp    (%edx),%al
  801c3d:	74 ef                	je     801c2e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c3f:	0f b6 c0             	movzbl %al,%eax
  801c42:	0f b6 12             	movzbl (%edx),%edx
  801c45:	29 d0                	sub    %edx,%eax
}
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    

00801c49 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c49:	55                   	push   %ebp
  801c4a:	89 e5                	mov    %esp,%ebp
  801c4c:	53                   	push   %ebx
  801c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c50:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c53:	89 c3                	mov    %eax,%ebx
  801c55:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c58:	eb 06                	jmp    801c60 <strncmp+0x17>
		n--, p++, q++;
  801c5a:	83 c0 01             	add    $0x1,%eax
  801c5d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801c60:	39 d8                	cmp    %ebx,%eax
  801c62:	74 18                	je     801c7c <strncmp+0x33>
  801c64:	0f b6 08             	movzbl (%eax),%ecx
  801c67:	84 c9                	test   %cl,%cl
  801c69:	74 04                	je     801c6f <strncmp+0x26>
  801c6b:	3a 0a                	cmp    (%edx),%cl
  801c6d:	74 eb                	je     801c5a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c6f:	0f b6 00             	movzbl (%eax),%eax
  801c72:	0f b6 12             	movzbl (%edx),%edx
  801c75:	29 d0                	sub    %edx,%eax
}
  801c77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c7a:	c9                   	leave  
  801c7b:	c3                   	ret    
		return 0;
  801c7c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c81:	eb f4                	jmp    801c77 <strncmp+0x2e>

00801c83 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	8b 45 08             	mov    0x8(%ebp),%eax
  801c89:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c8d:	eb 03                	jmp    801c92 <strchr+0xf>
  801c8f:	83 c0 01             	add    $0x1,%eax
  801c92:	0f b6 10             	movzbl (%eax),%edx
  801c95:	84 d2                	test   %dl,%dl
  801c97:	74 06                	je     801c9f <strchr+0x1c>
		if (*s == c)
  801c99:	38 ca                	cmp    %cl,%dl
  801c9b:	75 f2                	jne    801c8f <strchr+0xc>
  801c9d:	eb 05                	jmp    801ca4 <strchr+0x21>
			return (char *) s;
	return 0;
  801c9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ca4:	5d                   	pop    %ebp
  801ca5:	c3                   	ret    

00801ca6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cb0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cb3:	38 ca                	cmp    %cl,%dl
  801cb5:	74 09                	je     801cc0 <strfind+0x1a>
  801cb7:	84 d2                	test   %dl,%dl
  801cb9:	74 05                	je     801cc0 <strfind+0x1a>
	for (; *s; s++)
  801cbb:	83 c0 01             	add    $0x1,%eax
  801cbe:	eb f0                	jmp    801cb0 <strfind+0xa>
			break;
	return (char *) s;
}
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    

00801cc2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	57                   	push   %edi
  801cc6:	56                   	push   %esi
  801cc7:	53                   	push   %ebx
  801cc8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ccb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cce:	85 c9                	test   %ecx,%ecx
  801cd0:	74 2f                	je     801d01 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cd2:	89 f8                	mov    %edi,%eax
  801cd4:	09 c8                	or     %ecx,%eax
  801cd6:	a8 03                	test   $0x3,%al
  801cd8:	75 21                	jne    801cfb <memset+0x39>
		c &= 0xFF;
  801cda:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cde:	89 d0                	mov    %edx,%eax
  801ce0:	c1 e0 08             	shl    $0x8,%eax
  801ce3:	89 d3                	mov    %edx,%ebx
  801ce5:	c1 e3 18             	shl    $0x18,%ebx
  801ce8:	89 d6                	mov    %edx,%esi
  801cea:	c1 e6 10             	shl    $0x10,%esi
  801ced:	09 f3                	or     %esi,%ebx
  801cef:	09 da                	or     %ebx,%edx
  801cf1:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801cf3:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801cf6:	fc                   	cld    
  801cf7:	f3 ab                	rep stos %eax,%es:(%edi)
  801cf9:	eb 06                	jmp    801d01 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cfe:	fc                   	cld    
  801cff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d01:	89 f8                	mov    %edi,%eax
  801d03:	5b                   	pop    %ebx
  801d04:	5e                   	pop    %esi
  801d05:	5f                   	pop    %edi
  801d06:	5d                   	pop    %ebp
  801d07:	c3                   	ret    

00801d08 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	57                   	push   %edi
  801d0c:	56                   	push   %esi
  801d0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d10:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d13:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d16:	39 c6                	cmp    %eax,%esi
  801d18:	73 32                	jae    801d4c <memmove+0x44>
  801d1a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d1d:	39 c2                	cmp    %eax,%edx
  801d1f:	76 2b                	jbe    801d4c <memmove+0x44>
		s += n;
		d += n;
  801d21:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d24:	89 d6                	mov    %edx,%esi
  801d26:	09 fe                	or     %edi,%esi
  801d28:	09 ce                	or     %ecx,%esi
  801d2a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d30:	75 0e                	jne    801d40 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d32:	83 ef 04             	sub    $0x4,%edi
  801d35:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d38:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801d3b:	fd                   	std    
  801d3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d3e:	eb 09                	jmp    801d49 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d40:	83 ef 01             	sub    $0x1,%edi
  801d43:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801d46:	fd                   	std    
  801d47:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d49:	fc                   	cld    
  801d4a:	eb 1a                	jmp    801d66 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d4c:	89 f2                	mov    %esi,%edx
  801d4e:	09 c2                	or     %eax,%edx
  801d50:	09 ca                	or     %ecx,%edx
  801d52:	f6 c2 03             	test   $0x3,%dl
  801d55:	75 0a                	jne    801d61 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d57:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801d5a:	89 c7                	mov    %eax,%edi
  801d5c:	fc                   	cld    
  801d5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d5f:	eb 05                	jmp    801d66 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801d61:	89 c7                	mov    %eax,%edi
  801d63:	fc                   	cld    
  801d64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d66:	5e                   	pop    %esi
  801d67:	5f                   	pop    %edi
  801d68:	5d                   	pop    %ebp
  801d69:	c3                   	ret    

00801d6a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d70:	ff 75 10             	push   0x10(%ebp)
  801d73:	ff 75 0c             	push   0xc(%ebp)
  801d76:	ff 75 08             	push   0x8(%ebp)
  801d79:	e8 8a ff ff ff       	call   801d08 <memmove>
}
  801d7e:	c9                   	leave  
  801d7f:	c3                   	ret    

00801d80 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	56                   	push   %esi
  801d84:	53                   	push   %ebx
  801d85:	8b 45 08             	mov    0x8(%ebp),%eax
  801d88:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d8b:	89 c6                	mov    %eax,%esi
  801d8d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d90:	eb 06                	jmp    801d98 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801d92:	83 c0 01             	add    $0x1,%eax
  801d95:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801d98:	39 f0                	cmp    %esi,%eax
  801d9a:	74 14                	je     801db0 <memcmp+0x30>
		if (*s1 != *s2)
  801d9c:	0f b6 08             	movzbl (%eax),%ecx
  801d9f:	0f b6 1a             	movzbl (%edx),%ebx
  801da2:	38 d9                	cmp    %bl,%cl
  801da4:	74 ec                	je     801d92 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801da6:	0f b6 c1             	movzbl %cl,%eax
  801da9:	0f b6 db             	movzbl %bl,%ebx
  801dac:	29 d8                	sub    %ebx,%eax
  801dae:	eb 05                	jmp    801db5 <memcmp+0x35>
	}

	return 0;
  801db0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801db5:	5b                   	pop    %ebx
  801db6:	5e                   	pop    %esi
  801db7:	5d                   	pop    %ebp
  801db8:	c3                   	ret    

00801db9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801dc2:	89 c2                	mov    %eax,%edx
  801dc4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801dc7:	eb 03                	jmp    801dcc <memfind+0x13>
  801dc9:	83 c0 01             	add    $0x1,%eax
  801dcc:	39 d0                	cmp    %edx,%eax
  801dce:	73 04                	jae    801dd4 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dd0:	38 08                	cmp    %cl,(%eax)
  801dd2:	75 f5                	jne    801dc9 <memfind+0x10>
			break;
	return (void *) s;
}
  801dd4:	5d                   	pop    %ebp
  801dd5:	c3                   	ret    

00801dd6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	57                   	push   %edi
  801dda:	56                   	push   %esi
  801ddb:	53                   	push   %ebx
  801ddc:	8b 55 08             	mov    0x8(%ebp),%edx
  801ddf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801de2:	eb 03                	jmp    801de7 <strtol+0x11>
		s++;
  801de4:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801de7:	0f b6 02             	movzbl (%edx),%eax
  801dea:	3c 20                	cmp    $0x20,%al
  801dec:	74 f6                	je     801de4 <strtol+0xe>
  801dee:	3c 09                	cmp    $0x9,%al
  801df0:	74 f2                	je     801de4 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801df2:	3c 2b                	cmp    $0x2b,%al
  801df4:	74 2a                	je     801e20 <strtol+0x4a>
	int neg = 0;
  801df6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801dfb:	3c 2d                	cmp    $0x2d,%al
  801dfd:	74 2b                	je     801e2a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801dff:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e05:	75 0f                	jne    801e16 <strtol+0x40>
  801e07:	80 3a 30             	cmpb   $0x30,(%edx)
  801e0a:	74 28                	je     801e34 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e0c:	85 db                	test   %ebx,%ebx
  801e0e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e13:	0f 44 d8             	cmove  %eax,%ebx
  801e16:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e1b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801e1e:	eb 46                	jmp    801e66 <strtol+0x90>
		s++;
  801e20:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801e23:	bf 00 00 00 00       	mov    $0x0,%edi
  801e28:	eb d5                	jmp    801dff <strtol+0x29>
		s++, neg = 1;
  801e2a:	83 c2 01             	add    $0x1,%edx
  801e2d:	bf 01 00 00 00       	mov    $0x1,%edi
  801e32:	eb cb                	jmp    801dff <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e34:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e38:	74 0e                	je     801e48 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801e3a:	85 db                	test   %ebx,%ebx
  801e3c:	75 d8                	jne    801e16 <strtol+0x40>
		s++, base = 8;
  801e3e:	83 c2 01             	add    $0x1,%edx
  801e41:	bb 08 00 00 00       	mov    $0x8,%ebx
  801e46:	eb ce                	jmp    801e16 <strtol+0x40>
		s += 2, base = 16;
  801e48:	83 c2 02             	add    $0x2,%edx
  801e4b:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e50:	eb c4                	jmp    801e16 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801e52:	0f be c0             	movsbl %al,%eax
  801e55:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801e58:	3b 45 10             	cmp    0x10(%ebp),%eax
  801e5b:	7d 3a                	jge    801e97 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801e5d:	83 c2 01             	add    $0x1,%edx
  801e60:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801e64:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801e66:	0f b6 02             	movzbl (%edx),%eax
  801e69:	8d 70 d0             	lea    -0x30(%eax),%esi
  801e6c:	89 f3                	mov    %esi,%ebx
  801e6e:	80 fb 09             	cmp    $0x9,%bl
  801e71:	76 df                	jbe    801e52 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801e73:	8d 70 9f             	lea    -0x61(%eax),%esi
  801e76:	89 f3                	mov    %esi,%ebx
  801e78:	80 fb 19             	cmp    $0x19,%bl
  801e7b:	77 08                	ja     801e85 <strtol+0xaf>
			dig = *s - 'a' + 10;
  801e7d:	0f be c0             	movsbl %al,%eax
  801e80:	83 e8 57             	sub    $0x57,%eax
  801e83:	eb d3                	jmp    801e58 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801e85:	8d 70 bf             	lea    -0x41(%eax),%esi
  801e88:	89 f3                	mov    %esi,%ebx
  801e8a:	80 fb 19             	cmp    $0x19,%bl
  801e8d:	77 08                	ja     801e97 <strtol+0xc1>
			dig = *s - 'A' + 10;
  801e8f:	0f be c0             	movsbl %al,%eax
  801e92:	83 e8 37             	sub    $0x37,%eax
  801e95:	eb c1                	jmp    801e58 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801e97:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e9b:	74 05                	je     801ea2 <strtol+0xcc>
		*endptr = (char *) s;
  801e9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea0:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801ea2:	89 c8                	mov    %ecx,%eax
  801ea4:	f7 d8                	neg    %eax
  801ea6:	85 ff                	test   %edi,%edi
  801ea8:	0f 45 c8             	cmovne %eax,%ecx
}
  801eab:	89 c8                	mov    %ecx,%eax
  801ead:	5b                   	pop    %ebx
  801eae:	5e                   	pop    %esi
  801eaf:	5f                   	pop    %edi
  801eb0:	5d                   	pop    %ebp
  801eb1:	c3                   	ret    

00801eb2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eb2:	55                   	push   %ebp
  801eb3:	89 e5                	mov    %esp,%ebp
  801eb5:	56                   	push   %esi
  801eb6:	53                   	push   %ebx
  801eb7:	8b 75 08             	mov    0x8(%ebp),%esi
  801eba:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ebd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801ec0:	85 c0                	test   %eax,%eax
  801ec2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ec7:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801eca:	83 ec 0c             	sub    $0xc,%esp
  801ecd:	50                   	push   %eax
  801ece:	e8 3a e4 ff ff       	call   80030d <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ed3:	83 c4 10             	add    $0x10,%esp
  801ed6:	85 f6                	test   %esi,%esi
  801ed8:	74 17                	je     801ef1 <ipc_recv+0x3f>
  801eda:	ba 00 00 00 00       	mov    $0x0,%edx
  801edf:	85 c0                	test   %eax,%eax
  801ee1:	78 0c                	js     801eef <ipc_recv+0x3d>
  801ee3:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ee9:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801eef:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801ef1:	85 db                	test   %ebx,%ebx
  801ef3:	74 17                	je     801f0c <ipc_recv+0x5a>
  801ef5:	ba 00 00 00 00       	mov    $0x0,%edx
  801efa:	85 c0                	test   %eax,%eax
  801efc:	78 0c                	js     801f0a <ipc_recv+0x58>
  801efe:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f04:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801f0a:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f0c:	85 c0                	test   %eax,%eax
  801f0e:	78 0b                	js     801f1b <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801f10:	a1 00 40 80 00       	mov    0x804000,%eax
  801f15:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801f1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f1e:	5b                   	pop    %ebx
  801f1f:	5e                   	pop    %esi
  801f20:	5d                   	pop    %ebp
  801f21:	c3                   	ret    

00801f22 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f22:	55                   	push   %ebp
  801f23:	89 e5                	mov    %esp,%ebp
  801f25:	57                   	push   %edi
  801f26:	56                   	push   %esi
  801f27:	53                   	push   %ebx
  801f28:	83 ec 0c             	sub    $0xc,%esp
  801f2b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f34:	85 db                	test   %ebx,%ebx
  801f36:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f3b:	0f 44 d8             	cmove  %eax,%ebx
  801f3e:	eb 05                	jmp    801f45 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f40:	e8 f9 e1 ff ff       	call   80013e <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f45:	ff 75 14             	push   0x14(%ebp)
  801f48:	53                   	push   %ebx
  801f49:	56                   	push   %esi
  801f4a:	57                   	push   %edi
  801f4b:	e8 9a e3 ff ff       	call   8002ea <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f50:	83 c4 10             	add    $0x10,%esp
  801f53:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f56:	74 e8                	je     801f40 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f58:	85 c0                	test   %eax,%eax
  801f5a:	78 08                	js     801f64 <ipc_send+0x42>
	}while (r<0);

}
  801f5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5f:	5b                   	pop    %ebx
  801f60:	5e                   	pop    %esi
  801f61:	5f                   	pop    %edi
  801f62:	5d                   	pop    %ebp
  801f63:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f64:	50                   	push   %eax
  801f65:	68 bf 26 80 00       	push   $0x8026bf
  801f6a:	6a 3d                	push   $0x3d
  801f6c:	68 d3 26 80 00       	push   $0x8026d3
  801f71:	e8 47 f5 ff ff       	call   8014bd <_panic>

00801f76 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f76:	55                   	push   %ebp
  801f77:	89 e5                	mov    %esp,%ebp
  801f79:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f7c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f81:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  801f87:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f8d:	8b 52 60             	mov    0x60(%edx),%edx
  801f90:	39 ca                	cmp    %ecx,%edx
  801f92:	74 11                	je     801fa5 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  801f94:	83 c0 01             	add    $0x1,%eax
  801f97:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f9c:	75 e3                	jne    801f81 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f9e:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa3:	eb 0e                	jmp    801fb3 <ipc_find_env+0x3d>
			return envs[i].env_id;
  801fa5:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801fab:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fb0:	8b 40 58             	mov    0x58(%eax),%eax
}
  801fb3:	5d                   	pop    %ebp
  801fb4:	c3                   	ret    

00801fb5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fb5:	55                   	push   %ebp
  801fb6:	89 e5                	mov    %esp,%ebp
  801fb8:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fbb:	89 c2                	mov    %eax,%edx
  801fbd:	c1 ea 16             	shr    $0x16,%edx
  801fc0:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fc7:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fcc:	f6 c1 01             	test   $0x1,%cl
  801fcf:	74 1c                	je     801fed <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801fd1:	c1 e8 0c             	shr    $0xc,%eax
  801fd4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fdb:	a8 01                	test   $0x1,%al
  801fdd:	74 0e                	je     801fed <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fdf:	c1 e8 0c             	shr    $0xc,%eax
  801fe2:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801fe9:	ef 
  801fea:	0f b7 d2             	movzwl %dx,%edx
}
  801fed:	89 d0                	mov    %edx,%eax
  801fef:	5d                   	pop    %ebp
  801ff0:	c3                   	ret    
  801ff1:	66 90                	xchg   %ax,%ax
  801ff3:	66 90                	xchg   %ax,%ax
  801ff5:	66 90                	xchg   %ax,%ax
  801ff7:	66 90                	xchg   %ax,%ax
  801ff9:	66 90                	xchg   %ax,%ax
  801ffb:	66 90                	xchg   %ax,%ax
  801ffd:	66 90                	xchg   %ax,%ax
  801fff:	90                   	nop

00802000 <__udivdi3>:
  802000:	f3 0f 1e fb          	endbr32 
  802004:	55                   	push   %ebp
  802005:	57                   	push   %edi
  802006:	56                   	push   %esi
  802007:	53                   	push   %ebx
  802008:	83 ec 1c             	sub    $0x1c,%esp
  80200b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80200f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802013:	8b 74 24 34          	mov    0x34(%esp),%esi
  802017:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80201b:	85 c0                	test   %eax,%eax
  80201d:	75 19                	jne    802038 <__udivdi3+0x38>
  80201f:	39 f3                	cmp    %esi,%ebx
  802021:	76 4d                	jbe    802070 <__udivdi3+0x70>
  802023:	31 ff                	xor    %edi,%edi
  802025:	89 e8                	mov    %ebp,%eax
  802027:	89 f2                	mov    %esi,%edx
  802029:	f7 f3                	div    %ebx
  80202b:	89 fa                	mov    %edi,%edx
  80202d:	83 c4 1c             	add    $0x1c,%esp
  802030:	5b                   	pop    %ebx
  802031:	5e                   	pop    %esi
  802032:	5f                   	pop    %edi
  802033:	5d                   	pop    %ebp
  802034:	c3                   	ret    
  802035:	8d 76 00             	lea    0x0(%esi),%esi
  802038:	39 f0                	cmp    %esi,%eax
  80203a:	76 14                	jbe    802050 <__udivdi3+0x50>
  80203c:	31 ff                	xor    %edi,%edi
  80203e:	31 c0                	xor    %eax,%eax
  802040:	89 fa                	mov    %edi,%edx
  802042:	83 c4 1c             	add    $0x1c,%esp
  802045:	5b                   	pop    %ebx
  802046:	5e                   	pop    %esi
  802047:	5f                   	pop    %edi
  802048:	5d                   	pop    %ebp
  802049:	c3                   	ret    
  80204a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802050:	0f bd f8             	bsr    %eax,%edi
  802053:	83 f7 1f             	xor    $0x1f,%edi
  802056:	75 48                	jne    8020a0 <__udivdi3+0xa0>
  802058:	39 f0                	cmp    %esi,%eax
  80205a:	72 06                	jb     802062 <__udivdi3+0x62>
  80205c:	31 c0                	xor    %eax,%eax
  80205e:	39 eb                	cmp    %ebp,%ebx
  802060:	77 de                	ja     802040 <__udivdi3+0x40>
  802062:	b8 01 00 00 00       	mov    $0x1,%eax
  802067:	eb d7                	jmp    802040 <__udivdi3+0x40>
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	89 d9                	mov    %ebx,%ecx
  802072:	85 db                	test   %ebx,%ebx
  802074:	75 0b                	jne    802081 <__udivdi3+0x81>
  802076:	b8 01 00 00 00       	mov    $0x1,%eax
  80207b:	31 d2                	xor    %edx,%edx
  80207d:	f7 f3                	div    %ebx
  80207f:	89 c1                	mov    %eax,%ecx
  802081:	31 d2                	xor    %edx,%edx
  802083:	89 f0                	mov    %esi,%eax
  802085:	f7 f1                	div    %ecx
  802087:	89 c6                	mov    %eax,%esi
  802089:	89 e8                	mov    %ebp,%eax
  80208b:	89 f7                	mov    %esi,%edi
  80208d:	f7 f1                	div    %ecx
  80208f:	89 fa                	mov    %edi,%edx
  802091:	83 c4 1c             	add    $0x1c,%esp
  802094:	5b                   	pop    %ebx
  802095:	5e                   	pop    %esi
  802096:	5f                   	pop    %edi
  802097:	5d                   	pop    %ebp
  802098:	c3                   	ret    
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	89 f9                	mov    %edi,%ecx
  8020a2:	ba 20 00 00 00       	mov    $0x20,%edx
  8020a7:	29 fa                	sub    %edi,%edx
  8020a9:	d3 e0                	shl    %cl,%eax
  8020ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020af:	89 d1                	mov    %edx,%ecx
  8020b1:	89 d8                	mov    %ebx,%eax
  8020b3:	d3 e8                	shr    %cl,%eax
  8020b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020b9:	09 c1                	or     %eax,%ecx
  8020bb:	89 f0                	mov    %esi,%eax
  8020bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020c1:	89 f9                	mov    %edi,%ecx
  8020c3:	d3 e3                	shl    %cl,%ebx
  8020c5:	89 d1                	mov    %edx,%ecx
  8020c7:	d3 e8                	shr    %cl,%eax
  8020c9:	89 f9                	mov    %edi,%ecx
  8020cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020cf:	89 eb                	mov    %ebp,%ebx
  8020d1:	d3 e6                	shl    %cl,%esi
  8020d3:	89 d1                	mov    %edx,%ecx
  8020d5:	d3 eb                	shr    %cl,%ebx
  8020d7:	09 f3                	or     %esi,%ebx
  8020d9:	89 c6                	mov    %eax,%esi
  8020db:	89 f2                	mov    %esi,%edx
  8020dd:	89 d8                	mov    %ebx,%eax
  8020df:	f7 74 24 08          	divl   0x8(%esp)
  8020e3:	89 d6                	mov    %edx,%esi
  8020e5:	89 c3                	mov    %eax,%ebx
  8020e7:	f7 64 24 0c          	mull   0xc(%esp)
  8020eb:	39 d6                	cmp    %edx,%esi
  8020ed:	72 19                	jb     802108 <__udivdi3+0x108>
  8020ef:	89 f9                	mov    %edi,%ecx
  8020f1:	d3 e5                	shl    %cl,%ebp
  8020f3:	39 c5                	cmp    %eax,%ebp
  8020f5:	73 04                	jae    8020fb <__udivdi3+0xfb>
  8020f7:	39 d6                	cmp    %edx,%esi
  8020f9:	74 0d                	je     802108 <__udivdi3+0x108>
  8020fb:	89 d8                	mov    %ebx,%eax
  8020fd:	31 ff                	xor    %edi,%edi
  8020ff:	e9 3c ff ff ff       	jmp    802040 <__udivdi3+0x40>
  802104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802108:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80210b:	31 ff                	xor    %edi,%edi
  80210d:	e9 2e ff ff ff       	jmp    802040 <__udivdi3+0x40>
  802112:	66 90                	xchg   %ax,%ax
  802114:	66 90                	xchg   %ax,%ax
  802116:	66 90                	xchg   %ax,%ax
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__umoddi3>:
  802120:	f3 0f 1e fb          	endbr32 
  802124:	55                   	push   %ebp
  802125:	57                   	push   %edi
  802126:	56                   	push   %esi
  802127:	53                   	push   %ebx
  802128:	83 ec 1c             	sub    $0x1c,%esp
  80212b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80212f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802133:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802137:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80213b:	89 f0                	mov    %esi,%eax
  80213d:	89 da                	mov    %ebx,%edx
  80213f:	85 ff                	test   %edi,%edi
  802141:	75 15                	jne    802158 <__umoddi3+0x38>
  802143:	39 dd                	cmp    %ebx,%ebp
  802145:	76 39                	jbe    802180 <__umoddi3+0x60>
  802147:	f7 f5                	div    %ebp
  802149:	89 d0                	mov    %edx,%eax
  80214b:	31 d2                	xor    %edx,%edx
  80214d:	83 c4 1c             	add    $0x1c,%esp
  802150:	5b                   	pop    %ebx
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    
  802155:	8d 76 00             	lea    0x0(%esi),%esi
  802158:	39 df                	cmp    %ebx,%edi
  80215a:	77 f1                	ja     80214d <__umoddi3+0x2d>
  80215c:	0f bd cf             	bsr    %edi,%ecx
  80215f:	83 f1 1f             	xor    $0x1f,%ecx
  802162:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802166:	75 40                	jne    8021a8 <__umoddi3+0x88>
  802168:	39 df                	cmp    %ebx,%edi
  80216a:	72 04                	jb     802170 <__umoddi3+0x50>
  80216c:	39 f5                	cmp    %esi,%ebp
  80216e:	77 dd                	ja     80214d <__umoddi3+0x2d>
  802170:	89 da                	mov    %ebx,%edx
  802172:	89 f0                	mov    %esi,%eax
  802174:	29 e8                	sub    %ebp,%eax
  802176:	19 fa                	sbb    %edi,%edx
  802178:	eb d3                	jmp    80214d <__umoddi3+0x2d>
  80217a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802180:	89 e9                	mov    %ebp,%ecx
  802182:	85 ed                	test   %ebp,%ebp
  802184:	75 0b                	jne    802191 <__umoddi3+0x71>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f5                	div    %ebp
  80218f:	89 c1                	mov    %eax,%ecx
  802191:	89 d8                	mov    %ebx,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f1                	div    %ecx
  802197:	89 f0                	mov    %esi,%eax
  802199:	f7 f1                	div    %ecx
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	31 d2                	xor    %edx,%edx
  80219f:	eb ac                	jmp    80214d <__umoddi3+0x2d>
  8021a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021ac:	ba 20 00 00 00       	mov    $0x20,%edx
  8021b1:	29 c2                	sub    %eax,%edx
  8021b3:	89 c1                	mov    %eax,%ecx
  8021b5:	89 e8                	mov    %ebp,%eax
  8021b7:	d3 e7                	shl    %cl,%edi
  8021b9:	89 d1                	mov    %edx,%ecx
  8021bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021bf:	d3 e8                	shr    %cl,%eax
  8021c1:	89 c1                	mov    %eax,%ecx
  8021c3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021c7:	09 f9                	or     %edi,%ecx
  8021c9:	89 df                	mov    %ebx,%edi
  8021cb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021cf:	89 c1                	mov    %eax,%ecx
  8021d1:	d3 e5                	shl    %cl,%ebp
  8021d3:	89 d1                	mov    %edx,%ecx
  8021d5:	d3 ef                	shr    %cl,%edi
  8021d7:	89 c1                	mov    %eax,%ecx
  8021d9:	89 f0                	mov    %esi,%eax
  8021db:	d3 e3                	shl    %cl,%ebx
  8021dd:	89 d1                	mov    %edx,%ecx
  8021df:	89 fa                	mov    %edi,%edx
  8021e1:	d3 e8                	shr    %cl,%eax
  8021e3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021e8:	09 d8                	or     %ebx,%eax
  8021ea:	f7 74 24 08          	divl   0x8(%esp)
  8021ee:	89 d3                	mov    %edx,%ebx
  8021f0:	d3 e6                	shl    %cl,%esi
  8021f2:	f7 e5                	mul    %ebp
  8021f4:	89 c7                	mov    %eax,%edi
  8021f6:	89 d1                	mov    %edx,%ecx
  8021f8:	39 d3                	cmp    %edx,%ebx
  8021fa:	72 06                	jb     802202 <__umoddi3+0xe2>
  8021fc:	75 0e                	jne    80220c <__umoddi3+0xec>
  8021fe:	39 c6                	cmp    %eax,%esi
  802200:	73 0a                	jae    80220c <__umoddi3+0xec>
  802202:	29 e8                	sub    %ebp,%eax
  802204:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802208:	89 d1                	mov    %edx,%ecx
  80220a:	89 c7                	mov    %eax,%edi
  80220c:	89 f5                	mov    %esi,%ebp
  80220e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802212:	29 fd                	sub    %edi,%ebp
  802214:	19 cb                	sbb    %ecx,%ebx
  802216:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80221b:	89 d8                	mov    %ebx,%eax
  80221d:	d3 e0                	shl    %cl,%eax
  80221f:	89 f1                	mov    %esi,%ecx
  802221:	d3 ed                	shr    %cl,%ebp
  802223:	d3 eb                	shr    %cl,%ebx
  802225:	09 e8                	or     %ebp,%eax
  802227:	89 da                	mov    %ebx,%edx
  802229:	83 c4 1c             	add    $0x1c,%esp
  80222c:	5b                   	pop    %ebx
  80222d:	5e                   	pop    %esi
  80222e:	5f                   	pop    %edi
  80222f:	5d                   	pop    %ebp
  802230:	c3                   	ret    
