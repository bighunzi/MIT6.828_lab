
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
  800093:	e8 ee 04 00 00       	call   800586 <close_all>
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
  800114:	68 4a 22 80 00       	push   $0x80224a
  800119:	6a 2a                	push   $0x2a
  80011b:	68 67 22 80 00       	push   $0x802267
  800120:	e8 9e 13 00 00       	call   8014c3 <_panic>

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
  800195:	68 4a 22 80 00       	push   $0x80224a
  80019a:	6a 2a                	push   $0x2a
  80019c:	68 67 22 80 00       	push   $0x802267
  8001a1:	e8 1d 13 00 00       	call   8014c3 <_panic>

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
  8001d7:	68 4a 22 80 00       	push   $0x80224a
  8001dc:	6a 2a                	push   $0x2a
  8001de:	68 67 22 80 00       	push   $0x802267
  8001e3:	e8 db 12 00 00       	call   8014c3 <_panic>

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
  800219:	68 4a 22 80 00       	push   $0x80224a
  80021e:	6a 2a                	push   $0x2a
  800220:	68 67 22 80 00       	push   $0x802267
  800225:	e8 99 12 00 00       	call   8014c3 <_panic>

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
  80025b:	68 4a 22 80 00       	push   $0x80224a
  800260:	6a 2a                	push   $0x2a
  800262:	68 67 22 80 00       	push   $0x802267
  800267:	e8 57 12 00 00       	call   8014c3 <_panic>

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
  80029d:	68 4a 22 80 00       	push   $0x80224a
  8002a2:	6a 2a                	push   $0x2a
  8002a4:	68 67 22 80 00       	push   $0x802267
  8002a9:	e8 15 12 00 00       	call   8014c3 <_panic>

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
  8002df:	68 4a 22 80 00       	push   $0x80224a
  8002e4:	6a 2a                	push   $0x2a
  8002e6:	68 67 22 80 00       	push   $0x802267
  8002eb:	e8 d3 11 00 00       	call   8014c3 <_panic>

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
  800343:	68 4a 22 80 00       	push   $0x80224a
  800348:	6a 2a                	push   $0x2a
  80034a:	68 67 22 80 00       	push   $0x802267
  80034f:	e8 6f 11 00 00       	call   8014c3 <_panic>

00800354 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
	asm volatile("int %1\n"
  80035a:	ba 00 00 00 00       	mov    $0x0,%edx
  80035f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800364:	89 d1                	mov    %edx,%ecx
  800366:	89 d3                	mov    %edx,%ebx
  800368:	89 d7                	mov    %edx,%edi
  80036a:	89 d6                	mov    %edx,%esi
  80036c:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80036e:	5b                   	pop    %ebx
  80036f:	5e                   	pop    %esi
  800370:	5f                   	pop    %edi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	57                   	push   %edi
  800377:	56                   	push   %esi
  800378:	53                   	push   %ebx
	asm volatile("int %1\n"
  800379:	bb 00 00 00 00       	mov    $0x0,%ebx
  80037e:	8b 55 08             	mov    0x8(%ebp),%edx
  800381:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800384:	b8 0f 00 00 00       	mov    $0xf,%eax
  800389:	89 df                	mov    %ebx,%edi
  80038b:	89 de                	mov    %ebx,%esi
  80038d:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  80038f:	5b                   	pop    %ebx
  800390:	5e                   	pop    %esi
  800391:	5f                   	pop    %edi
  800392:	5d                   	pop    %ebp
  800393:	c3                   	ret    

00800394 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	57                   	push   %edi
  800398:	56                   	push   %esi
  800399:	53                   	push   %ebx
	asm volatile("int %1\n"
  80039a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80039f:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a5:	b8 10 00 00 00       	mov    $0x10,%eax
  8003aa:	89 df                	mov    %ebx,%edi
  8003ac:	89 de                	mov    %ebx,%esi
  8003ae:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8003b0:	5b                   	pop    %ebx
  8003b1:	5e                   	pop    %esi
  8003b2:	5f                   	pop    %edi
  8003b3:	5d                   	pop    %ebp
  8003b4:	c3                   	ret    

008003b5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bb:	05 00 00 00 30       	add    $0x30000000,%eax
  8003c0:	c1 e8 0c             	shr    $0xc,%eax
}
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cb:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003d5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003da:	5d                   	pop    %ebp
  8003db:	c3                   	ret    

008003dc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003e4:	89 c2                	mov    %eax,%edx
  8003e6:	c1 ea 16             	shr    $0x16,%edx
  8003e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003f0:	f6 c2 01             	test   $0x1,%dl
  8003f3:	74 29                	je     80041e <fd_alloc+0x42>
  8003f5:	89 c2                	mov    %eax,%edx
  8003f7:	c1 ea 0c             	shr    $0xc,%edx
  8003fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800401:	f6 c2 01             	test   $0x1,%dl
  800404:	74 18                	je     80041e <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800406:	05 00 10 00 00       	add    $0x1000,%eax
  80040b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800410:	75 d2                	jne    8003e4 <fd_alloc+0x8>
  800412:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800417:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80041c:	eb 05                	jmp    800423 <fd_alloc+0x47>
			return 0;
  80041e:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800423:	8b 55 08             	mov    0x8(%ebp),%edx
  800426:	89 02                	mov    %eax,(%edx)
}
  800428:	89 c8                	mov    %ecx,%eax
  80042a:	5d                   	pop    %ebp
  80042b:	c3                   	ret    

0080042c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800432:	83 f8 1f             	cmp    $0x1f,%eax
  800435:	77 30                	ja     800467 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800437:	c1 e0 0c             	shl    $0xc,%eax
  80043a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80043f:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800445:	f6 c2 01             	test   $0x1,%dl
  800448:	74 24                	je     80046e <fd_lookup+0x42>
  80044a:	89 c2                	mov    %eax,%edx
  80044c:	c1 ea 0c             	shr    $0xc,%edx
  80044f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800456:	f6 c2 01             	test   $0x1,%dl
  800459:	74 1a                	je     800475 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80045b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80045e:	89 02                	mov    %eax,(%edx)
	return 0;
  800460:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800465:	5d                   	pop    %ebp
  800466:	c3                   	ret    
		return -E_INVAL;
  800467:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80046c:	eb f7                	jmp    800465 <fd_lookup+0x39>
		return -E_INVAL;
  80046e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800473:	eb f0                	jmp    800465 <fd_lookup+0x39>
  800475:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80047a:	eb e9                	jmp    800465 <fd_lookup+0x39>

0080047c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80047c:	55                   	push   %ebp
  80047d:	89 e5                	mov    %esp,%ebp
  80047f:	53                   	push   %ebx
  800480:	83 ec 04             	sub    $0x4,%esp
  800483:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800486:	b8 00 00 00 00       	mov    $0x0,%eax
  80048b:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800490:	39 13                	cmp    %edx,(%ebx)
  800492:	74 37                	je     8004cb <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800494:	83 c0 01             	add    $0x1,%eax
  800497:	8b 1c 85 f4 22 80 00 	mov    0x8022f4(,%eax,4),%ebx
  80049e:	85 db                	test   %ebx,%ebx
  8004a0:	75 ee                	jne    800490 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004a2:	a1 00 40 80 00       	mov    0x804000,%eax
  8004a7:	8b 40 48             	mov    0x48(%eax),%eax
  8004aa:	83 ec 04             	sub    $0x4,%esp
  8004ad:	52                   	push   %edx
  8004ae:	50                   	push   %eax
  8004af:	68 78 22 80 00       	push   $0x802278
  8004b4:	e8 e5 10 00 00       	call   80159e <cprintf>
	*dev = 0;
	return -E_INVAL;
  8004b9:	83 c4 10             	add    $0x10,%esp
  8004bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8004c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004c4:	89 1a                	mov    %ebx,(%edx)
}
  8004c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004c9:	c9                   	leave  
  8004ca:	c3                   	ret    
			return 0;
  8004cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d0:	eb ef                	jmp    8004c1 <dev_lookup+0x45>

008004d2 <fd_close>:
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	57                   	push   %edi
  8004d6:	56                   	push   %esi
  8004d7:	53                   	push   %ebx
  8004d8:	83 ec 24             	sub    $0x24,%esp
  8004db:	8b 75 08             	mov    0x8(%ebp),%esi
  8004de:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004e4:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004e5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004eb:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004ee:	50                   	push   %eax
  8004ef:	e8 38 ff ff ff       	call   80042c <fd_lookup>
  8004f4:	89 c3                	mov    %eax,%ebx
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	85 c0                	test   %eax,%eax
  8004fb:	78 05                	js     800502 <fd_close+0x30>
	    || fd != fd2)
  8004fd:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800500:	74 16                	je     800518 <fd_close+0x46>
		return (must_exist ? r : 0);
  800502:	89 f8                	mov    %edi,%eax
  800504:	84 c0                	test   %al,%al
  800506:	b8 00 00 00 00       	mov    $0x0,%eax
  80050b:	0f 44 d8             	cmove  %eax,%ebx
}
  80050e:	89 d8                	mov    %ebx,%eax
  800510:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800513:	5b                   	pop    %ebx
  800514:	5e                   	pop    %esi
  800515:	5f                   	pop    %edi
  800516:	5d                   	pop    %ebp
  800517:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80051e:	50                   	push   %eax
  80051f:	ff 36                	push   (%esi)
  800521:	e8 56 ff ff ff       	call   80047c <dev_lookup>
  800526:	89 c3                	mov    %eax,%ebx
  800528:	83 c4 10             	add    $0x10,%esp
  80052b:	85 c0                	test   %eax,%eax
  80052d:	78 1a                	js     800549 <fd_close+0x77>
		if (dev->dev_close)
  80052f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800532:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800535:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80053a:	85 c0                	test   %eax,%eax
  80053c:	74 0b                	je     800549 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80053e:	83 ec 0c             	sub    $0xc,%esp
  800541:	56                   	push   %esi
  800542:	ff d0                	call   *%eax
  800544:	89 c3                	mov    %eax,%ebx
  800546:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	56                   	push   %esi
  80054d:	6a 00                	push   $0x0
  80054f:	e8 94 fc ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800554:	83 c4 10             	add    $0x10,%esp
  800557:	eb b5                	jmp    80050e <fd_close+0x3c>

00800559 <close>:

int
close(int fdnum)
{
  800559:	55                   	push   %ebp
  80055a:	89 e5                	mov    %esp,%ebp
  80055c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80055f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800562:	50                   	push   %eax
  800563:	ff 75 08             	push   0x8(%ebp)
  800566:	e8 c1 fe ff ff       	call   80042c <fd_lookup>
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	85 c0                	test   %eax,%eax
  800570:	79 02                	jns    800574 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800572:	c9                   	leave  
  800573:	c3                   	ret    
		return fd_close(fd, 1);
  800574:	83 ec 08             	sub    $0x8,%esp
  800577:	6a 01                	push   $0x1
  800579:	ff 75 f4             	push   -0xc(%ebp)
  80057c:	e8 51 ff ff ff       	call   8004d2 <fd_close>
  800581:	83 c4 10             	add    $0x10,%esp
  800584:	eb ec                	jmp    800572 <close+0x19>

00800586 <close_all>:

void
close_all(void)
{
  800586:	55                   	push   %ebp
  800587:	89 e5                	mov    %esp,%ebp
  800589:	53                   	push   %ebx
  80058a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80058d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800592:	83 ec 0c             	sub    $0xc,%esp
  800595:	53                   	push   %ebx
  800596:	e8 be ff ff ff       	call   800559 <close>
	for (i = 0; i < MAXFD; i++)
  80059b:	83 c3 01             	add    $0x1,%ebx
  80059e:	83 c4 10             	add    $0x10,%esp
  8005a1:	83 fb 20             	cmp    $0x20,%ebx
  8005a4:	75 ec                	jne    800592 <close_all+0xc>
}
  8005a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005a9:	c9                   	leave  
  8005aa:	c3                   	ret    

008005ab <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005ab:	55                   	push   %ebp
  8005ac:	89 e5                	mov    %esp,%ebp
  8005ae:	57                   	push   %edi
  8005af:	56                   	push   %esi
  8005b0:	53                   	push   %ebx
  8005b1:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005b7:	50                   	push   %eax
  8005b8:	ff 75 08             	push   0x8(%ebp)
  8005bb:	e8 6c fe ff ff       	call   80042c <fd_lookup>
  8005c0:	89 c3                	mov    %eax,%ebx
  8005c2:	83 c4 10             	add    $0x10,%esp
  8005c5:	85 c0                	test   %eax,%eax
  8005c7:	78 7f                	js     800648 <dup+0x9d>
		return r;
	close(newfdnum);
  8005c9:	83 ec 0c             	sub    $0xc,%esp
  8005cc:	ff 75 0c             	push   0xc(%ebp)
  8005cf:	e8 85 ff ff ff       	call   800559 <close>

	newfd = INDEX2FD(newfdnum);
  8005d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005d7:	c1 e6 0c             	shl    $0xc,%esi
  8005da:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e3:	89 3c 24             	mov    %edi,(%esp)
  8005e6:	e8 da fd ff ff       	call   8003c5 <fd2data>
  8005eb:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005ed:	89 34 24             	mov    %esi,(%esp)
  8005f0:	e8 d0 fd ff ff       	call   8003c5 <fd2data>
  8005f5:	83 c4 10             	add    $0x10,%esp
  8005f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005fb:	89 d8                	mov    %ebx,%eax
  8005fd:	c1 e8 16             	shr    $0x16,%eax
  800600:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800607:	a8 01                	test   $0x1,%al
  800609:	74 11                	je     80061c <dup+0x71>
  80060b:	89 d8                	mov    %ebx,%eax
  80060d:	c1 e8 0c             	shr    $0xc,%eax
  800610:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800617:	f6 c2 01             	test   $0x1,%dl
  80061a:	75 36                	jne    800652 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061c:	89 f8                	mov    %edi,%eax
  80061e:	c1 e8 0c             	shr    $0xc,%eax
  800621:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800628:	83 ec 0c             	sub    $0xc,%esp
  80062b:	25 07 0e 00 00       	and    $0xe07,%eax
  800630:	50                   	push   %eax
  800631:	56                   	push   %esi
  800632:	6a 00                	push   $0x0
  800634:	57                   	push   %edi
  800635:	6a 00                	push   $0x0
  800637:	e8 6a fb ff ff       	call   8001a6 <sys_page_map>
  80063c:	89 c3                	mov    %eax,%ebx
  80063e:	83 c4 20             	add    $0x20,%esp
  800641:	85 c0                	test   %eax,%eax
  800643:	78 33                	js     800678 <dup+0xcd>
		goto err;

	return newfdnum;
  800645:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800648:	89 d8                	mov    %ebx,%eax
  80064a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80064d:	5b                   	pop    %ebx
  80064e:	5e                   	pop    %esi
  80064f:	5f                   	pop    %edi
  800650:	5d                   	pop    %ebp
  800651:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800652:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800659:	83 ec 0c             	sub    $0xc,%esp
  80065c:	25 07 0e 00 00       	and    $0xe07,%eax
  800661:	50                   	push   %eax
  800662:	ff 75 d4             	push   -0x2c(%ebp)
  800665:	6a 00                	push   $0x0
  800667:	53                   	push   %ebx
  800668:	6a 00                	push   $0x0
  80066a:	e8 37 fb ff ff       	call   8001a6 <sys_page_map>
  80066f:	89 c3                	mov    %eax,%ebx
  800671:	83 c4 20             	add    $0x20,%esp
  800674:	85 c0                	test   %eax,%eax
  800676:	79 a4                	jns    80061c <dup+0x71>
	sys_page_unmap(0, newfd);
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	56                   	push   %esi
  80067c:	6a 00                	push   $0x0
  80067e:	e8 65 fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800683:	83 c4 08             	add    $0x8,%esp
  800686:	ff 75 d4             	push   -0x2c(%ebp)
  800689:	6a 00                	push   $0x0
  80068b:	e8 58 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800690:	83 c4 10             	add    $0x10,%esp
  800693:	eb b3                	jmp    800648 <dup+0x9d>

00800695 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800695:	55                   	push   %ebp
  800696:	89 e5                	mov    %esp,%ebp
  800698:	56                   	push   %esi
  800699:	53                   	push   %ebx
  80069a:	83 ec 18             	sub    $0x18,%esp
  80069d:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006a3:	50                   	push   %eax
  8006a4:	56                   	push   %esi
  8006a5:	e8 82 fd ff ff       	call   80042c <fd_lookup>
  8006aa:	83 c4 10             	add    $0x10,%esp
  8006ad:	85 c0                	test   %eax,%eax
  8006af:	78 3c                	js     8006ed <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b1:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006ba:	50                   	push   %eax
  8006bb:	ff 33                	push   (%ebx)
  8006bd:	e8 ba fd ff ff       	call   80047c <dev_lookup>
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	85 c0                	test   %eax,%eax
  8006c7:	78 24                	js     8006ed <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006c9:	8b 43 08             	mov    0x8(%ebx),%eax
  8006cc:	83 e0 03             	and    $0x3,%eax
  8006cf:	83 f8 01             	cmp    $0x1,%eax
  8006d2:	74 20                	je     8006f4 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d7:	8b 40 08             	mov    0x8(%eax),%eax
  8006da:	85 c0                	test   %eax,%eax
  8006dc:	74 37                	je     800715 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006de:	83 ec 04             	sub    $0x4,%esp
  8006e1:	ff 75 10             	push   0x10(%ebp)
  8006e4:	ff 75 0c             	push   0xc(%ebp)
  8006e7:	53                   	push   %ebx
  8006e8:	ff d0                	call   *%eax
  8006ea:	83 c4 10             	add    $0x10,%esp
}
  8006ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006f0:	5b                   	pop    %ebx
  8006f1:	5e                   	pop    %esi
  8006f2:	5d                   	pop    %ebp
  8006f3:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006f4:	a1 00 40 80 00       	mov    0x804000,%eax
  8006f9:	8b 40 48             	mov    0x48(%eax),%eax
  8006fc:	83 ec 04             	sub    $0x4,%esp
  8006ff:	56                   	push   %esi
  800700:	50                   	push   %eax
  800701:	68 b9 22 80 00       	push   $0x8022b9
  800706:	e8 93 0e 00 00       	call   80159e <cprintf>
		return -E_INVAL;
  80070b:	83 c4 10             	add    $0x10,%esp
  80070e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800713:	eb d8                	jmp    8006ed <read+0x58>
		return -E_NOT_SUPP;
  800715:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80071a:	eb d1                	jmp    8006ed <read+0x58>

0080071c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	57                   	push   %edi
  800720:	56                   	push   %esi
  800721:	53                   	push   %ebx
  800722:	83 ec 0c             	sub    $0xc,%esp
  800725:	8b 7d 08             	mov    0x8(%ebp),%edi
  800728:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80072b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800730:	eb 02                	jmp    800734 <readn+0x18>
  800732:	01 c3                	add    %eax,%ebx
  800734:	39 f3                	cmp    %esi,%ebx
  800736:	73 21                	jae    800759 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800738:	83 ec 04             	sub    $0x4,%esp
  80073b:	89 f0                	mov    %esi,%eax
  80073d:	29 d8                	sub    %ebx,%eax
  80073f:	50                   	push   %eax
  800740:	89 d8                	mov    %ebx,%eax
  800742:	03 45 0c             	add    0xc(%ebp),%eax
  800745:	50                   	push   %eax
  800746:	57                   	push   %edi
  800747:	e8 49 ff ff ff       	call   800695 <read>
		if (m < 0)
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	85 c0                	test   %eax,%eax
  800751:	78 04                	js     800757 <readn+0x3b>
			return m;
		if (m == 0)
  800753:	75 dd                	jne    800732 <readn+0x16>
  800755:	eb 02                	jmp    800759 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800757:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800759:	89 d8                	mov    %ebx,%eax
  80075b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80075e:	5b                   	pop    %ebx
  80075f:	5e                   	pop    %esi
  800760:	5f                   	pop    %edi
  800761:	5d                   	pop    %ebp
  800762:	c3                   	ret    

00800763 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	56                   	push   %esi
  800767:	53                   	push   %ebx
  800768:	83 ec 18             	sub    $0x18,%esp
  80076b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80076e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800771:	50                   	push   %eax
  800772:	53                   	push   %ebx
  800773:	e8 b4 fc ff ff       	call   80042c <fd_lookup>
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	85 c0                	test   %eax,%eax
  80077d:	78 37                	js     8007b6 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80077f:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800782:	83 ec 08             	sub    $0x8,%esp
  800785:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800788:	50                   	push   %eax
  800789:	ff 36                	push   (%esi)
  80078b:	e8 ec fc ff ff       	call   80047c <dev_lookup>
  800790:	83 c4 10             	add    $0x10,%esp
  800793:	85 c0                	test   %eax,%eax
  800795:	78 1f                	js     8007b6 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800797:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80079b:	74 20                	je     8007bd <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80079d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8007a3:	85 c0                	test   %eax,%eax
  8007a5:	74 37                	je     8007de <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007a7:	83 ec 04             	sub    $0x4,%esp
  8007aa:	ff 75 10             	push   0x10(%ebp)
  8007ad:	ff 75 0c             	push   0xc(%ebp)
  8007b0:	56                   	push   %esi
  8007b1:	ff d0                	call   *%eax
  8007b3:	83 c4 10             	add    $0x10,%esp
}
  8007b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007b9:	5b                   	pop    %ebx
  8007ba:	5e                   	pop    %esi
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007bd:	a1 00 40 80 00       	mov    0x804000,%eax
  8007c2:	8b 40 48             	mov    0x48(%eax),%eax
  8007c5:	83 ec 04             	sub    $0x4,%esp
  8007c8:	53                   	push   %ebx
  8007c9:	50                   	push   %eax
  8007ca:	68 d5 22 80 00       	push   $0x8022d5
  8007cf:	e8 ca 0d 00 00       	call   80159e <cprintf>
		return -E_INVAL;
  8007d4:	83 c4 10             	add    $0x10,%esp
  8007d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007dc:	eb d8                	jmp    8007b6 <write+0x53>
		return -E_NOT_SUPP;
  8007de:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007e3:	eb d1                	jmp    8007b6 <write+0x53>

008007e5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007ee:	50                   	push   %eax
  8007ef:	ff 75 08             	push   0x8(%ebp)
  8007f2:	e8 35 fc ff ff       	call   80042c <fd_lookup>
  8007f7:	83 c4 10             	add    $0x10,%esp
  8007fa:	85 c0                	test   %eax,%eax
  8007fc:	78 0e                	js     80080c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800801:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800804:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800807:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80080c:	c9                   	leave  
  80080d:	c3                   	ret    

0080080e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	56                   	push   %esi
  800812:	53                   	push   %ebx
  800813:	83 ec 18             	sub    $0x18,%esp
  800816:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800819:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80081c:	50                   	push   %eax
  80081d:	53                   	push   %ebx
  80081e:	e8 09 fc ff ff       	call   80042c <fd_lookup>
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	85 c0                	test   %eax,%eax
  800828:	78 34                	js     80085e <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80082d:	83 ec 08             	sub    $0x8,%esp
  800830:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800833:	50                   	push   %eax
  800834:	ff 36                	push   (%esi)
  800836:	e8 41 fc ff ff       	call   80047c <dev_lookup>
  80083b:	83 c4 10             	add    $0x10,%esp
  80083e:	85 c0                	test   %eax,%eax
  800840:	78 1c                	js     80085e <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800842:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800846:	74 1d                	je     800865 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800848:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084b:	8b 40 18             	mov    0x18(%eax),%eax
  80084e:	85 c0                	test   %eax,%eax
  800850:	74 34                	je     800886 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800852:	83 ec 08             	sub    $0x8,%esp
  800855:	ff 75 0c             	push   0xc(%ebp)
  800858:	56                   	push   %esi
  800859:	ff d0                	call   *%eax
  80085b:	83 c4 10             	add    $0x10,%esp
}
  80085e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800861:	5b                   	pop    %ebx
  800862:	5e                   	pop    %esi
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    
			thisenv->env_id, fdnum);
  800865:	a1 00 40 80 00       	mov    0x804000,%eax
  80086a:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80086d:	83 ec 04             	sub    $0x4,%esp
  800870:	53                   	push   %ebx
  800871:	50                   	push   %eax
  800872:	68 98 22 80 00       	push   $0x802298
  800877:	e8 22 0d 00 00       	call   80159e <cprintf>
		return -E_INVAL;
  80087c:	83 c4 10             	add    $0x10,%esp
  80087f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800884:	eb d8                	jmp    80085e <ftruncate+0x50>
		return -E_NOT_SUPP;
  800886:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80088b:	eb d1                	jmp    80085e <ftruncate+0x50>

0080088d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	56                   	push   %esi
  800891:	53                   	push   %ebx
  800892:	83 ec 18             	sub    $0x18,%esp
  800895:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800898:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80089b:	50                   	push   %eax
  80089c:	ff 75 08             	push   0x8(%ebp)
  80089f:	e8 88 fb ff ff       	call   80042c <fd_lookup>
  8008a4:	83 c4 10             	add    $0x10,%esp
  8008a7:	85 c0                	test   %eax,%eax
  8008a9:	78 49                	js     8008f4 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ab:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b4:	50                   	push   %eax
  8008b5:	ff 36                	push   (%esi)
  8008b7:	e8 c0 fb ff ff       	call   80047c <dev_lookup>
  8008bc:	83 c4 10             	add    $0x10,%esp
  8008bf:	85 c0                	test   %eax,%eax
  8008c1:	78 31                	js     8008f4 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8008c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008ca:	74 2f                	je     8008fb <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008cc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008cf:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008d6:	00 00 00 
	stat->st_isdir = 0;
  8008d9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008e0:	00 00 00 
	stat->st_dev = dev;
  8008e3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	53                   	push   %ebx
  8008ed:	56                   	push   %esi
  8008ee:	ff 50 14             	call   *0x14(%eax)
  8008f1:	83 c4 10             	add    $0x10,%esp
}
  8008f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f7:	5b                   	pop    %ebx
  8008f8:	5e                   	pop    %esi
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    
		return -E_NOT_SUPP;
  8008fb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800900:	eb f2                	jmp    8008f4 <fstat+0x67>

00800902 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	56                   	push   %esi
  800906:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800907:	83 ec 08             	sub    $0x8,%esp
  80090a:	6a 00                	push   $0x0
  80090c:	ff 75 08             	push   0x8(%ebp)
  80090f:	e8 e4 01 00 00       	call   800af8 <open>
  800914:	89 c3                	mov    %eax,%ebx
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	85 c0                	test   %eax,%eax
  80091b:	78 1b                	js     800938 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80091d:	83 ec 08             	sub    $0x8,%esp
  800920:	ff 75 0c             	push   0xc(%ebp)
  800923:	50                   	push   %eax
  800924:	e8 64 ff ff ff       	call   80088d <fstat>
  800929:	89 c6                	mov    %eax,%esi
	close(fd);
  80092b:	89 1c 24             	mov    %ebx,(%esp)
  80092e:	e8 26 fc ff ff       	call   800559 <close>
	return r;
  800933:	83 c4 10             	add    $0x10,%esp
  800936:	89 f3                	mov    %esi,%ebx
}
  800938:	89 d8                	mov    %ebx,%eax
  80093a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093d:	5b                   	pop    %ebx
  80093e:	5e                   	pop    %esi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	56                   	push   %esi
  800945:	53                   	push   %ebx
  800946:	89 c6                	mov    %eax,%esi
  800948:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80094a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800951:	74 27                	je     80097a <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800953:	6a 07                	push   $0x7
  800955:	68 00 50 80 00       	push   $0x805000
  80095a:	56                   	push   %esi
  80095b:	ff 35 00 60 80 00    	push   0x806000
  800961:	e8 b9 15 00 00       	call   801f1f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800966:	83 c4 0c             	add    $0xc,%esp
  800969:	6a 00                	push   $0x0
  80096b:	53                   	push   %ebx
  80096c:	6a 00                	push   $0x0
  80096e:	e8 45 15 00 00       	call   801eb8 <ipc_recv>
}
  800973:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800976:	5b                   	pop    %ebx
  800977:	5e                   	pop    %esi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80097a:	83 ec 0c             	sub    $0xc,%esp
  80097d:	6a 01                	push   $0x1
  80097f:	e8 ef 15 00 00       	call   801f73 <ipc_find_env>
  800984:	a3 00 60 80 00       	mov    %eax,0x806000
  800989:	83 c4 10             	add    $0x10,%esp
  80098c:	eb c5                	jmp    800953 <fsipc+0x12>

0080098e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 40 0c             	mov    0xc(%eax),%eax
  80099a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80099f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ac:	b8 02 00 00 00       	mov    $0x2,%eax
  8009b1:	e8 8b ff ff ff       	call   800941 <fsipc>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <devfile_flush>:
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ce:	b8 06 00 00 00       	mov    $0x6,%eax
  8009d3:	e8 69 ff ff ff       	call   800941 <fsipc>
}
  8009d8:	c9                   	leave  
  8009d9:	c3                   	ret    

008009da <devfile_stat>:
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	53                   	push   %ebx
  8009de:	83 ec 04             	sub    $0x4,%esp
  8009e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ea:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f4:	b8 05 00 00 00       	mov    $0x5,%eax
  8009f9:	e8 43 ff ff ff       	call   800941 <fsipc>
  8009fe:	85 c0                	test   %eax,%eax
  800a00:	78 2c                	js     800a2e <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a02:	83 ec 08             	sub    $0x8,%esp
  800a05:	68 00 50 80 00       	push   $0x805000
  800a0a:	53                   	push   %ebx
  800a0b:	e8 68 11 00 00       	call   801b78 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a10:	a1 80 50 80 00       	mov    0x805080,%eax
  800a15:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a1b:	a1 84 50 80 00       	mov    0x805084,%eax
  800a20:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a26:	83 c4 10             	add    $0x10,%esp
  800a29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a31:	c9                   	leave  
  800a32:	c3                   	ret    

00800a33 <devfile_write>:
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	83 ec 0c             	sub    $0xc,%esp
  800a39:	8b 45 10             	mov    0x10(%ebp),%eax
  800a3c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a41:	39 d0                	cmp    %edx,%eax
  800a43:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a46:	8b 55 08             	mov    0x8(%ebp),%edx
  800a49:	8b 52 0c             	mov    0xc(%edx),%edx
  800a4c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a52:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a57:	50                   	push   %eax
  800a58:	ff 75 0c             	push   0xc(%ebp)
  800a5b:	68 08 50 80 00       	push   $0x805008
  800a60:	e8 a9 12 00 00       	call   801d0e <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a65:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6a:	b8 04 00 00 00       	mov    $0x4,%eax
  800a6f:	e8 cd fe ff ff       	call   800941 <fsipc>
}
  800a74:	c9                   	leave  
  800a75:	c3                   	ret    

00800a76 <devfile_read>:
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	56                   	push   %esi
  800a7a:	53                   	push   %ebx
  800a7b:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	8b 40 0c             	mov    0xc(%eax),%eax
  800a84:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a89:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a94:	b8 03 00 00 00       	mov    $0x3,%eax
  800a99:	e8 a3 fe ff ff       	call   800941 <fsipc>
  800a9e:	89 c3                	mov    %eax,%ebx
  800aa0:	85 c0                	test   %eax,%eax
  800aa2:	78 1f                	js     800ac3 <devfile_read+0x4d>
	assert(r <= n);
  800aa4:	39 f0                	cmp    %esi,%eax
  800aa6:	77 24                	ja     800acc <devfile_read+0x56>
	assert(r <= PGSIZE);
  800aa8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aad:	7f 33                	jg     800ae2 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aaf:	83 ec 04             	sub    $0x4,%esp
  800ab2:	50                   	push   %eax
  800ab3:	68 00 50 80 00       	push   $0x805000
  800ab8:	ff 75 0c             	push   0xc(%ebp)
  800abb:	e8 4e 12 00 00       	call   801d0e <memmove>
	return r;
  800ac0:	83 c4 10             	add    $0x10,%esp
}
  800ac3:	89 d8                	mov    %ebx,%eax
  800ac5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    
	assert(r <= n);
  800acc:	68 08 23 80 00       	push   $0x802308
  800ad1:	68 0f 23 80 00       	push   $0x80230f
  800ad6:	6a 7c                	push   $0x7c
  800ad8:	68 24 23 80 00       	push   $0x802324
  800add:	e8 e1 09 00 00       	call   8014c3 <_panic>
	assert(r <= PGSIZE);
  800ae2:	68 2f 23 80 00       	push   $0x80232f
  800ae7:	68 0f 23 80 00       	push   $0x80230f
  800aec:	6a 7d                	push   $0x7d
  800aee:	68 24 23 80 00       	push   $0x802324
  800af3:	e8 cb 09 00 00       	call   8014c3 <_panic>

00800af8 <open>:
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	83 ec 1c             	sub    $0x1c,%esp
  800b00:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b03:	56                   	push   %esi
  800b04:	e8 34 10 00 00       	call   801b3d <strlen>
  800b09:	83 c4 10             	add    $0x10,%esp
  800b0c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b11:	7f 6c                	jg     800b7f <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800b13:	83 ec 0c             	sub    $0xc,%esp
  800b16:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b19:	50                   	push   %eax
  800b1a:	e8 bd f8 ff ff       	call   8003dc <fd_alloc>
  800b1f:	89 c3                	mov    %eax,%ebx
  800b21:	83 c4 10             	add    $0x10,%esp
  800b24:	85 c0                	test   %eax,%eax
  800b26:	78 3c                	js     800b64 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800b28:	83 ec 08             	sub    $0x8,%esp
  800b2b:	56                   	push   %esi
  800b2c:	68 00 50 80 00       	push   $0x805000
  800b31:	e8 42 10 00 00       	call   801b78 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b39:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b41:	b8 01 00 00 00       	mov    $0x1,%eax
  800b46:	e8 f6 fd ff ff       	call   800941 <fsipc>
  800b4b:	89 c3                	mov    %eax,%ebx
  800b4d:	83 c4 10             	add    $0x10,%esp
  800b50:	85 c0                	test   %eax,%eax
  800b52:	78 19                	js     800b6d <open+0x75>
	return fd2num(fd);
  800b54:	83 ec 0c             	sub    $0xc,%esp
  800b57:	ff 75 f4             	push   -0xc(%ebp)
  800b5a:	e8 56 f8 ff ff       	call   8003b5 <fd2num>
  800b5f:	89 c3                	mov    %eax,%ebx
  800b61:	83 c4 10             	add    $0x10,%esp
}
  800b64:	89 d8                	mov    %ebx,%eax
  800b66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    
		fd_close(fd, 0);
  800b6d:	83 ec 08             	sub    $0x8,%esp
  800b70:	6a 00                	push   $0x0
  800b72:	ff 75 f4             	push   -0xc(%ebp)
  800b75:	e8 58 f9 ff ff       	call   8004d2 <fd_close>
		return r;
  800b7a:	83 c4 10             	add    $0x10,%esp
  800b7d:	eb e5                	jmp    800b64 <open+0x6c>
		return -E_BAD_PATH;
  800b7f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b84:	eb de                	jmp    800b64 <open+0x6c>

00800b86 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b91:	b8 08 00 00 00       	mov    $0x8,%eax
  800b96:	e8 a6 fd ff ff       	call   800941 <fsipc>
}
  800b9b:	c9                   	leave  
  800b9c:	c3                   	ret    

00800b9d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800ba3:	68 3b 23 80 00       	push   $0x80233b
  800ba8:	ff 75 0c             	push   0xc(%ebp)
  800bab:	e8 c8 0f 00 00       	call   801b78 <strcpy>
	return 0;
}
  800bb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb5:	c9                   	leave  
  800bb6:	c3                   	ret    

00800bb7 <devsock_close>:
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	53                   	push   %ebx
  800bbb:	83 ec 10             	sub    $0x10,%esp
  800bbe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bc1:	53                   	push   %ebx
  800bc2:	e8 e5 13 00 00       	call   801fac <pageref>
  800bc7:	89 c2                	mov    %eax,%edx
  800bc9:	83 c4 10             	add    $0x10,%esp
		return 0;
  800bcc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800bd1:	83 fa 01             	cmp    $0x1,%edx
  800bd4:	74 05                	je     800bdb <devsock_close+0x24>
}
  800bd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd9:	c9                   	leave  
  800bda:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800bdb:	83 ec 0c             	sub    $0xc,%esp
  800bde:	ff 73 0c             	push   0xc(%ebx)
  800be1:	e8 b7 02 00 00       	call   800e9d <nsipc_close>
  800be6:	83 c4 10             	add    $0x10,%esp
  800be9:	eb eb                	jmp    800bd6 <devsock_close+0x1f>

00800beb <devsock_write>:
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bf1:	6a 00                	push   $0x0
  800bf3:	ff 75 10             	push   0x10(%ebp)
  800bf6:	ff 75 0c             	push   0xc(%ebp)
  800bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfc:	ff 70 0c             	push   0xc(%eax)
  800bff:	e8 79 03 00 00       	call   800f7d <nsipc_send>
}
  800c04:	c9                   	leave  
  800c05:	c3                   	ret    

00800c06 <devsock_read>:
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c0c:	6a 00                	push   $0x0
  800c0e:	ff 75 10             	push   0x10(%ebp)
  800c11:	ff 75 0c             	push   0xc(%ebp)
  800c14:	8b 45 08             	mov    0x8(%ebp),%eax
  800c17:	ff 70 0c             	push   0xc(%eax)
  800c1a:	e8 ef 02 00 00       	call   800f0e <nsipc_recv>
}
  800c1f:	c9                   	leave  
  800c20:	c3                   	ret    

00800c21 <fd2sockid>:
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c27:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c2a:	52                   	push   %edx
  800c2b:	50                   	push   %eax
  800c2c:	e8 fb f7 ff ff       	call   80042c <fd_lookup>
  800c31:	83 c4 10             	add    $0x10,%esp
  800c34:	85 c0                	test   %eax,%eax
  800c36:	78 10                	js     800c48 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c3b:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c41:	39 08                	cmp    %ecx,(%eax)
  800c43:	75 05                	jne    800c4a <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c45:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c48:	c9                   	leave  
  800c49:	c3                   	ret    
		return -E_NOT_SUPP;
  800c4a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c4f:	eb f7                	jmp    800c48 <fd2sockid+0x27>

00800c51 <alloc_sockfd>:
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	56                   	push   %esi
  800c55:	53                   	push   %ebx
  800c56:	83 ec 1c             	sub    $0x1c,%esp
  800c59:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c5e:	50                   	push   %eax
  800c5f:	e8 78 f7 ff ff       	call   8003dc <fd_alloc>
  800c64:	89 c3                	mov    %eax,%ebx
  800c66:	83 c4 10             	add    $0x10,%esp
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	78 43                	js     800cb0 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c6d:	83 ec 04             	sub    $0x4,%esp
  800c70:	68 07 04 00 00       	push   $0x407
  800c75:	ff 75 f4             	push   -0xc(%ebp)
  800c78:	6a 00                	push   $0x0
  800c7a:	e8 e4 f4 ff ff       	call   800163 <sys_page_alloc>
  800c7f:	89 c3                	mov    %eax,%ebx
  800c81:	83 c4 10             	add    $0x10,%esp
  800c84:	85 c0                	test   %eax,%eax
  800c86:	78 28                	js     800cb0 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c8b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c91:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c96:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c9d:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	e8 0c f7 ff ff       	call   8003b5 <fd2num>
  800ca9:	89 c3                	mov    %eax,%ebx
  800cab:	83 c4 10             	add    $0x10,%esp
  800cae:	eb 0c                	jmp    800cbc <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800cb0:	83 ec 0c             	sub    $0xc,%esp
  800cb3:	56                   	push   %esi
  800cb4:	e8 e4 01 00 00       	call   800e9d <nsipc_close>
		return r;
  800cb9:	83 c4 10             	add    $0x10,%esp
}
  800cbc:	89 d8                	mov    %ebx,%eax
  800cbe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <accept>:
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cce:	e8 4e ff ff ff       	call   800c21 <fd2sockid>
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	78 1b                	js     800cf2 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cd7:	83 ec 04             	sub    $0x4,%esp
  800cda:	ff 75 10             	push   0x10(%ebp)
  800cdd:	ff 75 0c             	push   0xc(%ebp)
  800ce0:	50                   	push   %eax
  800ce1:	e8 0e 01 00 00       	call   800df4 <nsipc_accept>
  800ce6:	83 c4 10             	add    $0x10,%esp
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	78 05                	js     800cf2 <accept+0x2d>
	return alloc_sockfd(r);
  800ced:	e8 5f ff ff ff       	call   800c51 <alloc_sockfd>
}
  800cf2:	c9                   	leave  
  800cf3:	c3                   	ret    

00800cf4 <bind>:
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfd:	e8 1f ff ff ff       	call   800c21 <fd2sockid>
  800d02:	85 c0                	test   %eax,%eax
  800d04:	78 12                	js     800d18 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  800d06:	83 ec 04             	sub    $0x4,%esp
  800d09:	ff 75 10             	push   0x10(%ebp)
  800d0c:	ff 75 0c             	push   0xc(%ebp)
  800d0f:	50                   	push   %eax
  800d10:	e8 31 01 00 00       	call   800e46 <nsipc_bind>
  800d15:	83 c4 10             	add    $0x10,%esp
}
  800d18:	c9                   	leave  
  800d19:	c3                   	ret    

00800d1a <shutdown>:
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d20:	8b 45 08             	mov    0x8(%ebp),%eax
  800d23:	e8 f9 fe ff ff       	call   800c21 <fd2sockid>
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	78 0f                	js     800d3b <shutdown+0x21>
	return nsipc_shutdown(r, how);
  800d2c:	83 ec 08             	sub    $0x8,%esp
  800d2f:	ff 75 0c             	push   0xc(%ebp)
  800d32:	50                   	push   %eax
  800d33:	e8 43 01 00 00       	call   800e7b <nsipc_shutdown>
  800d38:	83 c4 10             	add    $0x10,%esp
}
  800d3b:	c9                   	leave  
  800d3c:	c3                   	ret    

00800d3d <connect>:
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d43:	8b 45 08             	mov    0x8(%ebp),%eax
  800d46:	e8 d6 fe ff ff       	call   800c21 <fd2sockid>
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	78 12                	js     800d61 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  800d4f:	83 ec 04             	sub    $0x4,%esp
  800d52:	ff 75 10             	push   0x10(%ebp)
  800d55:	ff 75 0c             	push   0xc(%ebp)
  800d58:	50                   	push   %eax
  800d59:	e8 59 01 00 00       	call   800eb7 <nsipc_connect>
  800d5e:	83 c4 10             	add    $0x10,%esp
}
  800d61:	c9                   	leave  
  800d62:	c3                   	ret    

00800d63 <listen>:
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d69:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6c:	e8 b0 fe ff ff       	call   800c21 <fd2sockid>
  800d71:	85 c0                	test   %eax,%eax
  800d73:	78 0f                	js     800d84 <listen+0x21>
	return nsipc_listen(r, backlog);
  800d75:	83 ec 08             	sub    $0x8,%esp
  800d78:	ff 75 0c             	push   0xc(%ebp)
  800d7b:	50                   	push   %eax
  800d7c:	e8 6b 01 00 00       	call   800eec <nsipc_listen>
  800d81:	83 c4 10             	add    $0x10,%esp
}
  800d84:	c9                   	leave  
  800d85:	c3                   	ret    

00800d86 <socket>:

int
socket(int domain, int type, int protocol)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d8c:	ff 75 10             	push   0x10(%ebp)
  800d8f:	ff 75 0c             	push   0xc(%ebp)
  800d92:	ff 75 08             	push   0x8(%ebp)
  800d95:	e8 41 02 00 00       	call   800fdb <nsipc_socket>
  800d9a:	83 c4 10             	add    $0x10,%esp
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	78 05                	js     800da6 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800da1:	e8 ab fe ff ff       	call   800c51 <alloc_sockfd>
}
  800da6:	c9                   	leave  
  800da7:	c3                   	ret    

00800da8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	53                   	push   %ebx
  800dac:	83 ec 04             	sub    $0x4,%esp
  800daf:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800db1:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  800db8:	74 26                	je     800de0 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dba:	6a 07                	push   $0x7
  800dbc:	68 00 70 80 00       	push   $0x807000
  800dc1:	53                   	push   %ebx
  800dc2:	ff 35 00 80 80 00    	push   0x808000
  800dc8:	e8 52 11 00 00       	call   801f1f <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dcd:	83 c4 0c             	add    $0xc,%esp
  800dd0:	6a 00                	push   $0x0
  800dd2:	6a 00                	push   $0x0
  800dd4:	6a 00                	push   $0x0
  800dd6:	e8 dd 10 00 00       	call   801eb8 <ipc_recv>
}
  800ddb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dde:	c9                   	leave  
  800ddf:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800de0:	83 ec 0c             	sub    $0xc,%esp
  800de3:	6a 02                	push   $0x2
  800de5:	e8 89 11 00 00       	call   801f73 <ipc_find_env>
  800dea:	a3 00 80 80 00       	mov    %eax,0x808000
  800def:	83 c4 10             	add    $0x10,%esp
  800df2:	eb c6                	jmp    800dba <nsipc+0x12>

00800df4 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
  800df9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dff:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e04:	8b 06                	mov    (%esi),%eax
  800e06:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e0b:	b8 01 00 00 00       	mov    $0x1,%eax
  800e10:	e8 93 ff ff ff       	call   800da8 <nsipc>
  800e15:	89 c3                	mov    %eax,%ebx
  800e17:	85 c0                	test   %eax,%eax
  800e19:	79 09                	jns    800e24 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800e1b:	89 d8                	mov    %ebx,%eax
  800e1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e24:	83 ec 04             	sub    $0x4,%esp
  800e27:	ff 35 10 70 80 00    	push   0x807010
  800e2d:	68 00 70 80 00       	push   $0x807000
  800e32:	ff 75 0c             	push   0xc(%ebp)
  800e35:	e8 d4 0e 00 00       	call   801d0e <memmove>
		*addrlen = ret->ret_addrlen;
  800e3a:	a1 10 70 80 00       	mov    0x807010,%eax
  800e3f:	89 06                	mov    %eax,(%esi)
  800e41:	83 c4 10             	add    $0x10,%esp
	return r;
  800e44:	eb d5                	jmp    800e1b <nsipc_accept+0x27>

00800e46 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	53                   	push   %ebx
  800e4a:	83 ec 08             	sub    $0x8,%esp
  800e4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e50:	8b 45 08             	mov    0x8(%ebp),%eax
  800e53:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e58:	53                   	push   %ebx
  800e59:	ff 75 0c             	push   0xc(%ebp)
  800e5c:	68 04 70 80 00       	push   $0x807004
  800e61:	e8 a8 0e 00 00       	call   801d0e <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e66:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  800e6c:	b8 02 00 00 00       	mov    $0x2,%eax
  800e71:	e8 32 ff ff ff       	call   800da8 <nsipc>
}
  800e76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e79:	c9                   	leave  
  800e7a:	c3                   	ret    

00800e7b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e81:	8b 45 08             	mov    0x8(%ebp),%eax
  800e84:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  800e89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8c:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  800e91:	b8 03 00 00 00       	mov    $0x3,%eax
  800e96:	e8 0d ff ff ff       	call   800da8 <nsipc>
}
  800e9b:	c9                   	leave  
  800e9c:	c3                   	ret    

00800e9d <nsipc_close>:

int
nsipc_close(int s)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ea3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea6:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  800eab:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb0:	e8 f3 fe ff ff       	call   800da8 <nsipc>
}
  800eb5:	c9                   	leave  
  800eb6:	c3                   	ret    

00800eb7 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	53                   	push   %ebx
  800ebb:	83 ec 08             	sub    $0x8,%esp
  800ebe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ec1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec4:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ec9:	53                   	push   %ebx
  800eca:	ff 75 0c             	push   0xc(%ebp)
  800ecd:	68 04 70 80 00       	push   $0x807004
  800ed2:	e8 37 0e 00 00       	call   801d0e <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ed7:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  800edd:	b8 05 00 00 00       	mov    $0x5,%eax
  800ee2:	e8 c1 fe ff ff       	call   800da8 <nsipc>
}
  800ee7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eea:	c9                   	leave  
  800eeb:	c3                   	ret    

00800eec <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ef2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  800efa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efd:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  800f02:	b8 06 00 00 00       	mov    $0x6,%eax
  800f07:	e8 9c fe ff ff       	call   800da8 <nsipc>
}
  800f0c:	c9                   	leave  
  800f0d:	c3                   	ret    

00800f0e <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	56                   	push   %esi
  800f12:	53                   	push   %ebx
  800f13:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f16:	8b 45 08             	mov    0x8(%ebp),%eax
  800f19:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  800f1e:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  800f24:	8b 45 14             	mov    0x14(%ebp),%eax
  800f27:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f2c:	b8 07 00 00 00       	mov    $0x7,%eax
  800f31:	e8 72 fe ff ff       	call   800da8 <nsipc>
  800f36:	89 c3                	mov    %eax,%ebx
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	78 22                	js     800f5e <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  800f3c:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f41:	39 c6                	cmp    %eax,%esi
  800f43:	0f 4e c6             	cmovle %esi,%eax
  800f46:	39 c3                	cmp    %eax,%ebx
  800f48:	7f 1d                	jg     800f67 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f4a:	83 ec 04             	sub    $0x4,%esp
  800f4d:	53                   	push   %ebx
  800f4e:	68 00 70 80 00       	push   $0x807000
  800f53:	ff 75 0c             	push   0xc(%ebp)
  800f56:	e8 b3 0d 00 00       	call   801d0e <memmove>
  800f5b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f5e:	89 d8                	mov    %ebx,%eax
  800f60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f63:	5b                   	pop    %ebx
  800f64:	5e                   	pop    %esi
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f67:	68 47 23 80 00       	push   $0x802347
  800f6c:	68 0f 23 80 00       	push   $0x80230f
  800f71:	6a 62                	push   $0x62
  800f73:	68 5c 23 80 00       	push   $0x80235c
  800f78:	e8 46 05 00 00       	call   8014c3 <_panic>

00800f7d <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	53                   	push   %ebx
  800f81:	83 ec 04             	sub    $0x4,%esp
  800f84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f87:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8a:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  800f8f:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f95:	7f 2e                	jg     800fc5 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f97:	83 ec 04             	sub    $0x4,%esp
  800f9a:	53                   	push   %ebx
  800f9b:	ff 75 0c             	push   0xc(%ebp)
  800f9e:	68 0c 70 80 00       	push   $0x80700c
  800fa3:	e8 66 0d 00 00       	call   801d0e <memmove>
	nsipcbuf.send.req_size = size;
  800fa8:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  800fae:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb1:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  800fb6:	b8 08 00 00 00       	mov    $0x8,%eax
  800fbb:	e8 e8 fd ff ff       	call   800da8 <nsipc>
}
  800fc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc3:	c9                   	leave  
  800fc4:	c3                   	ret    
	assert(size < 1600);
  800fc5:	68 68 23 80 00       	push   $0x802368
  800fca:	68 0f 23 80 00       	push   $0x80230f
  800fcf:	6a 6d                	push   $0x6d
  800fd1:	68 5c 23 80 00       	push   $0x80235c
  800fd6:	e8 e8 04 00 00       	call   8014c3 <_panic>

00800fdb <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fe1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  800fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fec:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  800ff1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff4:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  800ff9:	b8 09 00 00 00       	mov    $0x9,%eax
  800ffe:	e8 a5 fd ff ff       	call   800da8 <nsipc>
}
  801003:	c9                   	leave  
  801004:	c3                   	ret    

00801005 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	56                   	push   %esi
  801009:	53                   	push   %ebx
  80100a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80100d:	83 ec 0c             	sub    $0xc,%esp
  801010:	ff 75 08             	push   0x8(%ebp)
  801013:	e8 ad f3 ff ff       	call   8003c5 <fd2data>
  801018:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80101a:	83 c4 08             	add    $0x8,%esp
  80101d:	68 74 23 80 00       	push   $0x802374
  801022:	53                   	push   %ebx
  801023:	e8 50 0b 00 00       	call   801b78 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801028:	8b 46 04             	mov    0x4(%esi),%eax
  80102b:	2b 06                	sub    (%esi),%eax
  80102d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801033:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80103a:	00 00 00 
	stat->st_dev = &devpipe;
  80103d:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801044:	30 80 00 
	return 0;
}
  801047:	b8 00 00 00 00       	mov    $0x0,%eax
  80104c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80104f:	5b                   	pop    %ebx
  801050:	5e                   	pop    %esi
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	53                   	push   %ebx
  801057:	83 ec 0c             	sub    $0xc,%esp
  80105a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80105d:	53                   	push   %ebx
  80105e:	6a 00                	push   $0x0
  801060:	e8 83 f1 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801065:	89 1c 24             	mov    %ebx,(%esp)
  801068:	e8 58 f3 ff ff       	call   8003c5 <fd2data>
  80106d:	83 c4 08             	add    $0x8,%esp
  801070:	50                   	push   %eax
  801071:	6a 00                	push   $0x0
  801073:	e8 70 f1 ff ff       	call   8001e8 <sys_page_unmap>
}
  801078:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107b:	c9                   	leave  
  80107c:	c3                   	ret    

0080107d <_pipeisclosed>:
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	57                   	push   %edi
  801081:	56                   	push   %esi
  801082:	53                   	push   %ebx
  801083:	83 ec 1c             	sub    $0x1c,%esp
  801086:	89 c7                	mov    %eax,%edi
  801088:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80108a:	a1 00 40 80 00       	mov    0x804000,%eax
  80108f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801092:	83 ec 0c             	sub    $0xc,%esp
  801095:	57                   	push   %edi
  801096:	e8 11 0f 00 00       	call   801fac <pageref>
  80109b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80109e:	89 34 24             	mov    %esi,(%esp)
  8010a1:	e8 06 0f 00 00       	call   801fac <pageref>
		nn = thisenv->env_runs;
  8010a6:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8010ac:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010af:	83 c4 10             	add    $0x10,%esp
  8010b2:	39 cb                	cmp    %ecx,%ebx
  8010b4:	74 1b                	je     8010d1 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010b6:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010b9:	75 cf                	jne    80108a <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010bb:	8b 42 58             	mov    0x58(%edx),%eax
  8010be:	6a 01                	push   $0x1
  8010c0:	50                   	push   %eax
  8010c1:	53                   	push   %ebx
  8010c2:	68 7b 23 80 00       	push   $0x80237b
  8010c7:	e8 d2 04 00 00       	call   80159e <cprintf>
  8010cc:	83 c4 10             	add    $0x10,%esp
  8010cf:	eb b9                	jmp    80108a <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010d1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010d4:	0f 94 c0             	sete   %al
  8010d7:	0f b6 c0             	movzbl %al,%eax
}
  8010da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010dd:	5b                   	pop    %ebx
  8010de:	5e                   	pop    %esi
  8010df:	5f                   	pop    %edi
  8010e0:	5d                   	pop    %ebp
  8010e1:	c3                   	ret    

008010e2 <devpipe_write>:
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	57                   	push   %edi
  8010e6:	56                   	push   %esi
  8010e7:	53                   	push   %ebx
  8010e8:	83 ec 28             	sub    $0x28,%esp
  8010eb:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8010ee:	56                   	push   %esi
  8010ef:	e8 d1 f2 ff ff       	call   8003c5 <fd2data>
  8010f4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8010f6:	83 c4 10             	add    $0x10,%esp
  8010f9:	bf 00 00 00 00       	mov    $0x0,%edi
  8010fe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801101:	75 09                	jne    80110c <devpipe_write+0x2a>
	return i;
  801103:	89 f8                	mov    %edi,%eax
  801105:	eb 23                	jmp    80112a <devpipe_write+0x48>
			sys_yield();
  801107:	e8 38 f0 ff ff       	call   800144 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80110c:	8b 43 04             	mov    0x4(%ebx),%eax
  80110f:	8b 0b                	mov    (%ebx),%ecx
  801111:	8d 51 20             	lea    0x20(%ecx),%edx
  801114:	39 d0                	cmp    %edx,%eax
  801116:	72 1a                	jb     801132 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801118:	89 da                	mov    %ebx,%edx
  80111a:	89 f0                	mov    %esi,%eax
  80111c:	e8 5c ff ff ff       	call   80107d <_pipeisclosed>
  801121:	85 c0                	test   %eax,%eax
  801123:	74 e2                	je     801107 <devpipe_write+0x25>
				return 0;
  801125:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80112a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112d:	5b                   	pop    %ebx
  80112e:	5e                   	pop    %esi
  80112f:	5f                   	pop    %edi
  801130:	5d                   	pop    %ebp
  801131:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801132:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801135:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801139:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80113c:	89 c2                	mov    %eax,%edx
  80113e:	c1 fa 1f             	sar    $0x1f,%edx
  801141:	89 d1                	mov    %edx,%ecx
  801143:	c1 e9 1b             	shr    $0x1b,%ecx
  801146:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801149:	83 e2 1f             	and    $0x1f,%edx
  80114c:	29 ca                	sub    %ecx,%edx
  80114e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801152:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801156:	83 c0 01             	add    $0x1,%eax
  801159:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80115c:	83 c7 01             	add    $0x1,%edi
  80115f:	eb 9d                	jmp    8010fe <devpipe_write+0x1c>

00801161 <devpipe_read>:
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	57                   	push   %edi
  801165:	56                   	push   %esi
  801166:	53                   	push   %ebx
  801167:	83 ec 18             	sub    $0x18,%esp
  80116a:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80116d:	57                   	push   %edi
  80116e:	e8 52 f2 ff ff       	call   8003c5 <fd2data>
  801173:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801175:	83 c4 10             	add    $0x10,%esp
  801178:	be 00 00 00 00       	mov    $0x0,%esi
  80117d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801180:	75 13                	jne    801195 <devpipe_read+0x34>
	return i;
  801182:	89 f0                	mov    %esi,%eax
  801184:	eb 02                	jmp    801188 <devpipe_read+0x27>
				return i;
  801186:	89 f0                	mov    %esi,%eax
}
  801188:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118b:	5b                   	pop    %ebx
  80118c:	5e                   	pop    %esi
  80118d:	5f                   	pop    %edi
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    
			sys_yield();
  801190:	e8 af ef ff ff       	call   800144 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801195:	8b 03                	mov    (%ebx),%eax
  801197:	3b 43 04             	cmp    0x4(%ebx),%eax
  80119a:	75 18                	jne    8011b4 <devpipe_read+0x53>
			if (i > 0)
  80119c:	85 f6                	test   %esi,%esi
  80119e:	75 e6                	jne    801186 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8011a0:	89 da                	mov    %ebx,%edx
  8011a2:	89 f8                	mov    %edi,%eax
  8011a4:	e8 d4 fe ff ff       	call   80107d <_pipeisclosed>
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	74 e3                	je     801190 <devpipe_read+0x2f>
				return 0;
  8011ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b2:	eb d4                	jmp    801188 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011b4:	99                   	cltd   
  8011b5:	c1 ea 1b             	shr    $0x1b,%edx
  8011b8:	01 d0                	add    %edx,%eax
  8011ba:	83 e0 1f             	and    $0x1f,%eax
  8011bd:	29 d0                	sub    %edx,%eax
  8011bf:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c7:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011ca:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011cd:	83 c6 01             	add    $0x1,%esi
  8011d0:	eb ab                	jmp    80117d <devpipe_read+0x1c>

008011d2 <pipe>:
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	56                   	push   %esi
  8011d6:	53                   	push   %ebx
  8011d7:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011dd:	50                   	push   %eax
  8011de:	e8 f9 f1 ff ff       	call   8003dc <fd_alloc>
  8011e3:	89 c3                	mov    %eax,%ebx
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	0f 88 23 01 00 00    	js     801313 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011f0:	83 ec 04             	sub    $0x4,%esp
  8011f3:	68 07 04 00 00       	push   $0x407
  8011f8:	ff 75 f4             	push   -0xc(%ebp)
  8011fb:	6a 00                	push   $0x0
  8011fd:	e8 61 ef ff ff       	call   800163 <sys_page_alloc>
  801202:	89 c3                	mov    %eax,%ebx
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	85 c0                	test   %eax,%eax
  801209:	0f 88 04 01 00 00    	js     801313 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  80120f:	83 ec 0c             	sub    $0xc,%esp
  801212:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801215:	50                   	push   %eax
  801216:	e8 c1 f1 ff ff       	call   8003dc <fd_alloc>
  80121b:	89 c3                	mov    %eax,%ebx
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	85 c0                	test   %eax,%eax
  801222:	0f 88 db 00 00 00    	js     801303 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801228:	83 ec 04             	sub    $0x4,%esp
  80122b:	68 07 04 00 00       	push   $0x407
  801230:	ff 75 f0             	push   -0x10(%ebp)
  801233:	6a 00                	push   $0x0
  801235:	e8 29 ef ff ff       	call   800163 <sys_page_alloc>
  80123a:	89 c3                	mov    %eax,%ebx
  80123c:	83 c4 10             	add    $0x10,%esp
  80123f:	85 c0                	test   %eax,%eax
  801241:	0f 88 bc 00 00 00    	js     801303 <pipe+0x131>
	va = fd2data(fd0);
  801247:	83 ec 0c             	sub    $0xc,%esp
  80124a:	ff 75 f4             	push   -0xc(%ebp)
  80124d:	e8 73 f1 ff ff       	call   8003c5 <fd2data>
  801252:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801254:	83 c4 0c             	add    $0xc,%esp
  801257:	68 07 04 00 00       	push   $0x407
  80125c:	50                   	push   %eax
  80125d:	6a 00                	push   $0x0
  80125f:	e8 ff ee ff ff       	call   800163 <sys_page_alloc>
  801264:	89 c3                	mov    %eax,%ebx
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	85 c0                	test   %eax,%eax
  80126b:	0f 88 82 00 00 00    	js     8012f3 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801271:	83 ec 0c             	sub    $0xc,%esp
  801274:	ff 75 f0             	push   -0x10(%ebp)
  801277:	e8 49 f1 ff ff       	call   8003c5 <fd2data>
  80127c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801283:	50                   	push   %eax
  801284:	6a 00                	push   $0x0
  801286:	56                   	push   %esi
  801287:	6a 00                	push   $0x0
  801289:	e8 18 ef ff ff       	call   8001a6 <sys_page_map>
  80128e:	89 c3                	mov    %eax,%ebx
  801290:	83 c4 20             	add    $0x20,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	78 4e                	js     8012e5 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801297:	a1 3c 30 80 00       	mov    0x80303c,%eax
  80129c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80129f:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8012a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a4:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012ae:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012ba:	83 ec 0c             	sub    $0xc,%esp
  8012bd:	ff 75 f4             	push   -0xc(%ebp)
  8012c0:	e8 f0 f0 ff ff       	call   8003b5 <fd2num>
  8012c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012ca:	83 c4 04             	add    $0x4,%esp
  8012cd:	ff 75 f0             	push   -0x10(%ebp)
  8012d0:	e8 e0 f0 ff ff       	call   8003b5 <fd2num>
  8012d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012db:	83 c4 10             	add    $0x10,%esp
  8012de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e3:	eb 2e                	jmp    801313 <pipe+0x141>
	sys_page_unmap(0, va);
  8012e5:	83 ec 08             	sub    $0x8,%esp
  8012e8:	56                   	push   %esi
  8012e9:	6a 00                	push   $0x0
  8012eb:	e8 f8 ee ff ff       	call   8001e8 <sys_page_unmap>
  8012f0:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8012f3:	83 ec 08             	sub    $0x8,%esp
  8012f6:	ff 75 f0             	push   -0x10(%ebp)
  8012f9:	6a 00                	push   $0x0
  8012fb:	e8 e8 ee ff ff       	call   8001e8 <sys_page_unmap>
  801300:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801303:	83 ec 08             	sub    $0x8,%esp
  801306:	ff 75 f4             	push   -0xc(%ebp)
  801309:	6a 00                	push   $0x0
  80130b:	e8 d8 ee ff ff       	call   8001e8 <sys_page_unmap>
  801310:	83 c4 10             	add    $0x10,%esp
}
  801313:	89 d8                	mov    %ebx,%eax
  801315:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801318:	5b                   	pop    %ebx
  801319:	5e                   	pop    %esi
  80131a:	5d                   	pop    %ebp
  80131b:	c3                   	ret    

0080131c <pipeisclosed>:
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801322:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801325:	50                   	push   %eax
  801326:	ff 75 08             	push   0x8(%ebp)
  801329:	e8 fe f0 ff ff       	call   80042c <fd_lookup>
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	85 c0                	test   %eax,%eax
  801333:	78 18                	js     80134d <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801335:	83 ec 0c             	sub    $0xc,%esp
  801338:	ff 75 f4             	push   -0xc(%ebp)
  80133b:	e8 85 f0 ff ff       	call   8003c5 <fd2data>
  801340:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801342:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801345:	e8 33 fd ff ff       	call   80107d <_pipeisclosed>
  80134a:	83 c4 10             	add    $0x10,%esp
}
  80134d:	c9                   	leave  
  80134e:	c3                   	ret    

0080134f <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80134f:	b8 00 00 00 00       	mov    $0x0,%eax
  801354:	c3                   	ret    

00801355 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801355:	55                   	push   %ebp
  801356:	89 e5                	mov    %esp,%ebp
  801358:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80135b:	68 93 23 80 00       	push   $0x802393
  801360:	ff 75 0c             	push   0xc(%ebp)
  801363:	e8 10 08 00 00       	call   801b78 <strcpy>
	return 0;
}
  801368:	b8 00 00 00 00       	mov    $0x0,%eax
  80136d:	c9                   	leave  
  80136e:	c3                   	ret    

0080136f <devcons_write>:
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	57                   	push   %edi
  801373:	56                   	push   %esi
  801374:	53                   	push   %ebx
  801375:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80137b:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801380:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801386:	eb 2e                	jmp    8013b6 <devcons_write+0x47>
		m = n - tot;
  801388:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80138b:	29 f3                	sub    %esi,%ebx
  80138d:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801392:	39 c3                	cmp    %eax,%ebx
  801394:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801397:	83 ec 04             	sub    $0x4,%esp
  80139a:	53                   	push   %ebx
  80139b:	89 f0                	mov    %esi,%eax
  80139d:	03 45 0c             	add    0xc(%ebp),%eax
  8013a0:	50                   	push   %eax
  8013a1:	57                   	push   %edi
  8013a2:	e8 67 09 00 00       	call   801d0e <memmove>
		sys_cputs(buf, m);
  8013a7:	83 c4 08             	add    $0x8,%esp
  8013aa:	53                   	push   %ebx
  8013ab:	57                   	push   %edi
  8013ac:	e8 f6 ec ff ff       	call   8000a7 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013b1:	01 de                	add    %ebx,%esi
  8013b3:	83 c4 10             	add    $0x10,%esp
  8013b6:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013b9:	72 cd                	jb     801388 <devcons_write+0x19>
}
  8013bb:	89 f0                	mov    %esi,%eax
  8013bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c0:	5b                   	pop    %ebx
  8013c1:	5e                   	pop    %esi
  8013c2:	5f                   	pop    %edi
  8013c3:	5d                   	pop    %ebp
  8013c4:	c3                   	ret    

008013c5 <devcons_read>:
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	83 ec 08             	sub    $0x8,%esp
  8013cb:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013d0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013d4:	75 07                	jne    8013dd <devcons_read+0x18>
  8013d6:	eb 1f                	jmp    8013f7 <devcons_read+0x32>
		sys_yield();
  8013d8:	e8 67 ed ff ff       	call   800144 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8013dd:	e8 e3 ec ff ff       	call   8000c5 <sys_cgetc>
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	74 f2                	je     8013d8 <devcons_read+0x13>
	if (c < 0)
  8013e6:	78 0f                	js     8013f7 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8013e8:	83 f8 04             	cmp    $0x4,%eax
  8013eb:	74 0c                	je     8013f9 <devcons_read+0x34>
	*(char*)vbuf = c;
  8013ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013f0:	88 02                	mov    %al,(%edx)
	return 1;
  8013f2:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8013f7:	c9                   	leave  
  8013f8:	c3                   	ret    
		return 0;
  8013f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fe:	eb f7                	jmp    8013f7 <devcons_read+0x32>

00801400 <cputchar>:
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801406:	8b 45 08             	mov    0x8(%ebp),%eax
  801409:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80140c:	6a 01                	push   $0x1
  80140e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801411:	50                   	push   %eax
  801412:	e8 90 ec ff ff       	call   8000a7 <sys_cputs>
}
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	c9                   	leave  
  80141b:	c3                   	ret    

0080141c <getchar>:
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801422:	6a 01                	push   $0x1
  801424:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801427:	50                   	push   %eax
  801428:	6a 00                	push   $0x0
  80142a:	e8 66 f2 ff ff       	call   800695 <read>
	if (r < 0)
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	85 c0                	test   %eax,%eax
  801434:	78 06                	js     80143c <getchar+0x20>
	if (r < 1)
  801436:	74 06                	je     80143e <getchar+0x22>
	return c;
  801438:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80143c:	c9                   	leave  
  80143d:	c3                   	ret    
		return -E_EOF;
  80143e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801443:	eb f7                	jmp    80143c <getchar+0x20>

00801445 <iscons>:
{
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80144b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144e:	50                   	push   %eax
  80144f:	ff 75 08             	push   0x8(%ebp)
  801452:	e8 d5 ef ff ff       	call   80042c <fd_lookup>
  801457:	83 c4 10             	add    $0x10,%esp
  80145a:	85 c0                	test   %eax,%eax
  80145c:	78 11                	js     80146f <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80145e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801461:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801467:	39 10                	cmp    %edx,(%eax)
  801469:	0f 94 c0             	sete   %al
  80146c:	0f b6 c0             	movzbl %al,%eax
}
  80146f:	c9                   	leave  
  801470:	c3                   	ret    

00801471 <opencons>:
{
  801471:	55                   	push   %ebp
  801472:	89 e5                	mov    %esp,%ebp
  801474:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801477:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	e8 5c ef ff ff       	call   8003dc <fd_alloc>
  801480:	83 c4 10             	add    $0x10,%esp
  801483:	85 c0                	test   %eax,%eax
  801485:	78 3a                	js     8014c1 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801487:	83 ec 04             	sub    $0x4,%esp
  80148a:	68 07 04 00 00       	push   $0x407
  80148f:	ff 75 f4             	push   -0xc(%ebp)
  801492:	6a 00                	push   $0x0
  801494:	e8 ca ec ff ff       	call   800163 <sys_page_alloc>
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	85 c0                	test   %eax,%eax
  80149e:	78 21                	js     8014c1 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8014a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014a9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ae:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014b5:	83 ec 0c             	sub    $0xc,%esp
  8014b8:	50                   	push   %eax
  8014b9:	e8 f7 ee ff ff       	call   8003b5 <fd2num>
  8014be:	83 c4 10             	add    $0x10,%esp
}
  8014c1:	c9                   	leave  
  8014c2:	c3                   	ret    

008014c3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014c3:	55                   	push   %ebp
  8014c4:	89 e5                	mov    %esp,%ebp
  8014c6:	56                   	push   %esi
  8014c7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014c8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014cb:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014d1:	e8 4f ec ff ff       	call   800125 <sys_getenvid>
  8014d6:	83 ec 0c             	sub    $0xc,%esp
  8014d9:	ff 75 0c             	push   0xc(%ebp)
  8014dc:	ff 75 08             	push   0x8(%ebp)
  8014df:	56                   	push   %esi
  8014e0:	50                   	push   %eax
  8014e1:	68 a0 23 80 00       	push   $0x8023a0
  8014e6:	e8 b3 00 00 00       	call   80159e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014eb:	83 c4 18             	add    $0x18,%esp
  8014ee:	53                   	push   %ebx
  8014ef:	ff 75 10             	push   0x10(%ebp)
  8014f2:	e8 56 00 00 00       	call   80154d <vcprintf>
	cprintf("\n");
  8014f7:	c7 04 24 8c 23 80 00 	movl   $0x80238c,(%esp)
  8014fe:	e8 9b 00 00 00       	call   80159e <cprintf>
  801503:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801506:	cc                   	int3   
  801507:	eb fd                	jmp    801506 <_panic+0x43>

00801509 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	53                   	push   %ebx
  80150d:	83 ec 04             	sub    $0x4,%esp
  801510:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801513:	8b 13                	mov    (%ebx),%edx
  801515:	8d 42 01             	lea    0x1(%edx),%eax
  801518:	89 03                	mov    %eax,(%ebx)
  80151a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80151d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801521:	3d ff 00 00 00       	cmp    $0xff,%eax
  801526:	74 09                	je     801531 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801528:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80152c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152f:	c9                   	leave  
  801530:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801531:	83 ec 08             	sub    $0x8,%esp
  801534:	68 ff 00 00 00       	push   $0xff
  801539:	8d 43 08             	lea    0x8(%ebx),%eax
  80153c:	50                   	push   %eax
  80153d:	e8 65 eb ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  801542:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	eb db                	jmp    801528 <putch+0x1f>

0080154d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801556:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80155d:	00 00 00 
	b.cnt = 0;
  801560:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801567:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80156a:	ff 75 0c             	push   0xc(%ebp)
  80156d:	ff 75 08             	push   0x8(%ebp)
  801570:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801576:	50                   	push   %eax
  801577:	68 09 15 80 00       	push   $0x801509
  80157c:	e8 14 01 00 00       	call   801695 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801581:	83 c4 08             	add    $0x8,%esp
  801584:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80158a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801590:	50                   	push   %eax
  801591:	e8 11 eb ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  801596:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80159c:	c9                   	leave  
  80159d:	c3                   	ret    

0080159e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80159e:	55                   	push   %ebp
  80159f:	89 e5                	mov    %esp,%ebp
  8015a1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015a4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015a7:	50                   	push   %eax
  8015a8:	ff 75 08             	push   0x8(%ebp)
  8015ab:	e8 9d ff ff ff       	call   80154d <vcprintf>
	va_end(ap);

	return cnt;
}
  8015b0:	c9                   	leave  
  8015b1:	c3                   	ret    

008015b2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	57                   	push   %edi
  8015b6:	56                   	push   %esi
  8015b7:	53                   	push   %ebx
  8015b8:	83 ec 1c             	sub    $0x1c,%esp
  8015bb:	89 c7                	mov    %eax,%edi
  8015bd:	89 d6                	mov    %edx,%esi
  8015bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c5:	89 d1                	mov    %edx,%ecx
  8015c7:	89 c2                	mov    %eax,%edx
  8015c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015cc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8015d2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015d8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8015df:	39 c2                	cmp    %eax,%edx
  8015e1:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8015e4:	72 3e                	jb     801624 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015e6:	83 ec 0c             	sub    $0xc,%esp
  8015e9:	ff 75 18             	push   0x18(%ebp)
  8015ec:	83 eb 01             	sub    $0x1,%ebx
  8015ef:	53                   	push   %ebx
  8015f0:	50                   	push   %eax
  8015f1:	83 ec 08             	sub    $0x8,%esp
  8015f4:	ff 75 e4             	push   -0x1c(%ebp)
  8015f7:	ff 75 e0             	push   -0x20(%ebp)
  8015fa:	ff 75 dc             	push   -0x24(%ebp)
  8015fd:	ff 75 d8             	push   -0x28(%ebp)
  801600:	e8 eb 09 00 00       	call   801ff0 <__udivdi3>
  801605:	83 c4 18             	add    $0x18,%esp
  801608:	52                   	push   %edx
  801609:	50                   	push   %eax
  80160a:	89 f2                	mov    %esi,%edx
  80160c:	89 f8                	mov    %edi,%eax
  80160e:	e8 9f ff ff ff       	call   8015b2 <printnum>
  801613:	83 c4 20             	add    $0x20,%esp
  801616:	eb 13                	jmp    80162b <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801618:	83 ec 08             	sub    $0x8,%esp
  80161b:	56                   	push   %esi
  80161c:	ff 75 18             	push   0x18(%ebp)
  80161f:	ff d7                	call   *%edi
  801621:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801624:	83 eb 01             	sub    $0x1,%ebx
  801627:	85 db                	test   %ebx,%ebx
  801629:	7f ed                	jg     801618 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80162b:	83 ec 08             	sub    $0x8,%esp
  80162e:	56                   	push   %esi
  80162f:	83 ec 04             	sub    $0x4,%esp
  801632:	ff 75 e4             	push   -0x1c(%ebp)
  801635:	ff 75 e0             	push   -0x20(%ebp)
  801638:	ff 75 dc             	push   -0x24(%ebp)
  80163b:	ff 75 d8             	push   -0x28(%ebp)
  80163e:	e8 cd 0a 00 00       	call   802110 <__umoddi3>
  801643:	83 c4 14             	add    $0x14,%esp
  801646:	0f be 80 c3 23 80 00 	movsbl 0x8023c3(%eax),%eax
  80164d:	50                   	push   %eax
  80164e:	ff d7                	call   *%edi
}
  801650:	83 c4 10             	add    $0x10,%esp
  801653:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801656:	5b                   	pop    %ebx
  801657:	5e                   	pop    %esi
  801658:	5f                   	pop    %edi
  801659:	5d                   	pop    %ebp
  80165a:	c3                   	ret    

0080165b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801661:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801665:	8b 10                	mov    (%eax),%edx
  801667:	3b 50 04             	cmp    0x4(%eax),%edx
  80166a:	73 0a                	jae    801676 <sprintputch+0x1b>
		*b->buf++ = ch;
  80166c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80166f:	89 08                	mov    %ecx,(%eax)
  801671:	8b 45 08             	mov    0x8(%ebp),%eax
  801674:	88 02                	mov    %al,(%edx)
}
  801676:	5d                   	pop    %ebp
  801677:	c3                   	ret    

00801678 <printfmt>:
{
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80167e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801681:	50                   	push   %eax
  801682:	ff 75 10             	push   0x10(%ebp)
  801685:	ff 75 0c             	push   0xc(%ebp)
  801688:	ff 75 08             	push   0x8(%ebp)
  80168b:	e8 05 00 00 00       	call   801695 <vprintfmt>
}
  801690:	83 c4 10             	add    $0x10,%esp
  801693:	c9                   	leave  
  801694:	c3                   	ret    

00801695 <vprintfmt>:
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	57                   	push   %edi
  801699:	56                   	push   %esi
  80169a:	53                   	push   %ebx
  80169b:	83 ec 3c             	sub    $0x3c,%esp
  80169e:	8b 75 08             	mov    0x8(%ebp),%esi
  8016a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016a4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016a7:	eb 0a                	jmp    8016b3 <vprintfmt+0x1e>
			putch(ch, putdat);
  8016a9:	83 ec 08             	sub    $0x8,%esp
  8016ac:	53                   	push   %ebx
  8016ad:	50                   	push   %eax
  8016ae:	ff d6                	call   *%esi
  8016b0:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016b3:	83 c7 01             	add    $0x1,%edi
  8016b6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016ba:	83 f8 25             	cmp    $0x25,%eax
  8016bd:	74 0c                	je     8016cb <vprintfmt+0x36>
			if (ch == '\0')
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	75 e6                	jne    8016a9 <vprintfmt+0x14>
}
  8016c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c6:	5b                   	pop    %ebx
  8016c7:	5e                   	pop    %esi
  8016c8:	5f                   	pop    %edi
  8016c9:	5d                   	pop    %ebp
  8016ca:	c3                   	ret    
		padc = ' ';
  8016cb:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8016cf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8016d6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8016dd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8016e4:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8016e9:	8d 47 01             	lea    0x1(%edi),%eax
  8016ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016ef:	0f b6 17             	movzbl (%edi),%edx
  8016f2:	8d 42 dd             	lea    -0x23(%edx),%eax
  8016f5:	3c 55                	cmp    $0x55,%al
  8016f7:	0f 87 bb 03 00 00    	ja     801ab8 <vprintfmt+0x423>
  8016fd:	0f b6 c0             	movzbl %al,%eax
  801700:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
  801707:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80170a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80170e:	eb d9                	jmp    8016e9 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801710:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801713:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801717:	eb d0                	jmp    8016e9 <vprintfmt+0x54>
  801719:	0f b6 d2             	movzbl %dl,%edx
  80171c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80171f:	b8 00 00 00 00       	mov    $0x0,%eax
  801724:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801727:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80172a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80172e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801731:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801734:	83 f9 09             	cmp    $0x9,%ecx
  801737:	77 55                	ja     80178e <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  801739:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80173c:	eb e9                	jmp    801727 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80173e:	8b 45 14             	mov    0x14(%ebp),%eax
  801741:	8b 00                	mov    (%eax),%eax
  801743:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801746:	8b 45 14             	mov    0x14(%ebp),%eax
  801749:	8d 40 04             	lea    0x4(%eax),%eax
  80174c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80174f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801752:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801756:	79 91                	jns    8016e9 <vprintfmt+0x54>
				width = precision, precision = -1;
  801758:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80175b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80175e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801765:	eb 82                	jmp    8016e9 <vprintfmt+0x54>
  801767:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80176a:	85 d2                	test   %edx,%edx
  80176c:	b8 00 00 00 00       	mov    $0x0,%eax
  801771:	0f 49 c2             	cmovns %edx,%eax
  801774:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80177a:	e9 6a ff ff ff       	jmp    8016e9 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80177f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801782:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801789:	e9 5b ff ff ff       	jmp    8016e9 <vprintfmt+0x54>
  80178e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801791:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801794:	eb bc                	jmp    801752 <vprintfmt+0xbd>
			lflag++;
  801796:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801799:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80179c:	e9 48 ff ff ff       	jmp    8016e9 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8017a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8017a4:	8d 78 04             	lea    0x4(%eax),%edi
  8017a7:	83 ec 08             	sub    $0x8,%esp
  8017aa:	53                   	push   %ebx
  8017ab:	ff 30                	push   (%eax)
  8017ad:	ff d6                	call   *%esi
			break;
  8017af:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017b2:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017b5:	e9 9d 02 00 00       	jmp    801a57 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8017ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8017bd:	8d 78 04             	lea    0x4(%eax),%edi
  8017c0:	8b 10                	mov    (%eax),%edx
  8017c2:	89 d0                	mov    %edx,%eax
  8017c4:	f7 d8                	neg    %eax
  8017c6:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017c9:	83 f8 0f             	cmp    $0xf,%eax
  8017cc:	7f 23                	jg     8017f1 <vprintfmt+0x15c>
  8017ce:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  8017d5:	85 d2                	test   %edx,%edx
  8017d7:	74 18                	je     8017f1 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8017d9:	52                   	push   %edx
  8017da:	68 21 23 80 00       	push   $0x802321
  8017df:	53                   	push   %ebx
  8017e0:	56                   	push   %esi
  8017e1:	e8 92 fe ff ff       	call   801678 <printfmt>
  8017e6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017e9:	89 7d 14             	mov    %edi,0x14(%ebp)
  8017ec:	e9 66 02 00 00       	jmp    801a57 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8017f1:	50                   	push   %eax
  8017f2:	68 db 23 80 00       	push   $0x8023db
  8017f7:	53                   	push   %ebx
  8017f8:	56                   	push   %esi
  8017f9:	e8 7a fe ff ff       	call   801678 <printfmt>
  8017fe:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801801:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801804:	e9 4e 02 00 00       	jmp    801a57 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  801809:	8b 45 14             	mov    0x14(%ebp),%eax
  80180c:	83 c0 04             	add    $0x4,%eax
  80180f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801812:	8b 45 14             	mov    0x14(%ebp),%eax
  801815:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801817:	85 d2                	test   %edx,%edx
  801819:	b8 d4 23 80 00       	mov    $0x8023d4,%eax
  80181e:	0f 45 c2             	cmovne %edx,%eax
  801821:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801824:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801828:	7e 06                	jle    801830 <vprintfmt+0x19b>
  80182a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80182e:	75 0d                	jne    80183d <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801830:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801833:	89 c7                	mov    %eax,%edi
  801835:	03 45 e0             	add    -0x20(%ebp),%eax
  801838:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80183b:	eb 55                	jmp    801892 <vprintfmt+0x1fd>
  80183d:	83 ec 08             	sub    $0x8,%esp
  801840:	ff 75 d8             	push   -0x28(%ebp)
  801843:	ff 75 cc             	push   -0x34(%ebp)
  801846:	e8 0a 03 00 00       	call   801b55 <strnlen>
  80184b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80184e:	29 c1                	sub    %eax,%ecx
  801850:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801853:	83 c4 10             	add    $0x10,%esp
  801856:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  801858:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80185c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80185f:	eb 0f                	jmp    801870 <vprintfmt+0x1db>
					putch(padc, putdat);
  801861:	83 ec 08             	sub    $0x8,%esp
  801864:	53                   	push   %ebx
  801865:	ff 75 e0             	push   -0x20(%ebp)
  801868:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80186a:	83 ef 01             	sub    $0x1,%edi
  80186d:	83 c4 10             	add    $0x10,%esp
  801870:	85 ff                	test   %edi,%edi
  801872:	7f ed                	jg     801861 <vprintfmt+0x1cc>
  801874:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801877:	85 d2                	test   %edx,%edx
  801879:	b8 00 00 00 00       	mov    $0x0,%eax
  80187e:	0f 49 c2             	cmovns %edx,%eax
  801881:	29 c2                	sub    %eax,%edx
  801883:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801886:	eb a8                	jmp    801830 <vprintfmt+0x19b>
					putch(ch, putdat);
  801888:	83 ec 08             	sub    $0x8,%esp
  80188b:	53                   	push   %ebx
  80188c:	52                   	push   %edx
  80188d:	ff d6                	call   *%esi
  80188f:	83 c4 10             	add    $0x10,%esp
  801892:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801895:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801897:	83 c7 01             	add    $0x1,%edi
  80189a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80189e:	0f be d0             	movsbl %al,%edx
  8018a1:	85 d2                	test   %edx,%edx
  8018a3:	74 4b                	je     8018f0 <vprintfmt+0x25b>
  8018a5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018a9:	78 06                	js     8018b1 <vprintfmt+0x21c>
  8018ab:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018af:	78 1e                	js     8018cf <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8018b1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018b5:	74 d1                	je     801888 <vprintfmt+0x1f3>
  8018b7:	0f be c0             	movsbl %al,%eax
  8018ba:	83 e8 20             	sub    $0x20,%eax
  8018bd:	83 f8 5e             	cmp    $0x5e,%eax
  8018c0:	76 c6                	jbe    801888 <vprintfmt+0x1f3>
					putch('?', putdat);
  8018c2:	83 ec 08             	sub    $0x8,%esp
  8018c5:	53                   	push   %ebx
  8018c6:	6a 3f                	push   $0x3f
  8018c8:	ff d6                	call   *%esi
  8018ca:	83 c4 10             	add    $0x10,%esp
  8018cd:	eb c3                	jmp    801892 <vprintfmt+0x1fd>
  8018cf:	89 cf                	mov    %ecx,%edi
  8018d1:	eb 0e                	jmp    8018e1 <vprintfmt+0x24c>
				putch(' ', putdat);
  8018d3:	83 ec 08             	sub    $0x8,%esp
  8018d6:	53                   	push   %ebx
  8018d7:	6a 20                	push   $0x20
  8018d9:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8018db:	83 ef 01             	sub    $0x1,%edi
  8018de:	83 c4 10             	add    $0x10,%esp
  8018e1:	85 ff                	test   %edi,%edi
  8018e3:	7f ee                	jg     8018d3 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8018e5:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8018e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8018eb:	e9 67 01 00 00       	jmp    801a57 <vprintfmt+0x3c2>
  8018f0:	89 cf                	mov    %ecx,%edi
  8018f2:	eb ed                	jmp    8018e1 <vprintfmt+0x24c>
	if (lflag >= 2)
  8018f4:	83 f9 01             	cmp    $0x1,%ecx
  8018f7:	7f 1b                	jg     801914 <vprintfmt+0x27f>
	else if (lflag)
  8018f9:	85 c9                	test   %ecx,%ecx
  8018fb:	74 63                	je     801960 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8018fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801900:	8b 00                	mov    (%eax),%eax
  801902:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801905:	99                   	cltd   
  801906:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801909:	8b 45 14             	mov    0x14(%ebp),%eax
  80190c:	8d 40 04             	lea    0x4(%eax),%eax
  80190f:	89 45 14             	mov    %eax,0x14(%ebp)
  801912:	eb 17                	jmp    80192b <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801914:	8b 45 14             	mov    0x14(%ebp),%eax
  801917:	8b 50 04             	mov    0x4(%eax),%edx
  80191a:	8b 00                	mov    (%eax),%eax
  80191c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80191f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801922:	8b 45 14             	mov    0x14(%ebp),%eax
  801925:	8d 40 08             	lea    0x8(%eax),%eax
  801928:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80192b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80192e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801931:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801936:	85 c9                	test   %ecx,%ecx
  801938:	0f 89 ff 00 00 00    	jns    801a3d <vprintfmt+0x3a8>
				putch('-', putdat);
  80193e:	83 ec 08             	sub    $0x8,%esp
  801941:	53                   	push   %ebx
  801942:	6a 2d                	push   $0x2d
  801944:	ff d6                	call   *%esi
				num = -(long long) num;
  801946:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801949:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80194c:	f7 da                	neg    %edx
  80194e:	83 d1 00             	adc    $0x0,%ecx
  801951:	f7 d9                	neg    %ecx
  801953:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801956:	bf 0a 00 00 00       	mov    $0xa,%edi
  80195b:	e9 dd 00 00 00       	jmp    801a3d <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801960:	8b 45 14             	mov    0x14(%ebp),%eax
  801963:	8b 00                	mov    (%eax),%eax
  801965:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801968:	99                   	cltd   
  801969:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80196c:	8b 45 14             	mov    0x14(%ebp),%eax
  80196f:	8d 40 04             	lea    0x4(%eax),%eax
  801972:	89 45 14             	mov    %eax,0x14(%ebp)
  801975:	eb b4                	jmp    80192b <vprintfmt+0x296>
	if (lflag >= 2)
  801977:	83 f9 01             	cmp    $0x1,%ecx
  80197a:	7f 1e                	jg     80199a <vprintfmt+0x305>
	else if (lflag)
  80197c:	85 c9                	test   %ecx,%ecx
  80197e:	74 32                	je     8019b2 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  801980:	8b 45 14             	mov    0x14(%ebp),%eax
  801983:	8b 10                	mov    (%eax),%edx
  801985:	b9 00 00 00 00       	mov    $0x0,%ecx
  80198a:	8d 40 04             	lea    0x4(%eax),%eax
  80198d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801990:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  801995:	e9 a3 00 00 00       	jmp    801a3d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80199a:	8b 45 14             	mov    0x14(%ebp),%eax
  80199d:	8b 10                	mov    (%eax),%edx
  80199f:	8b 48 04             	mov    0x4(%eax),%ecx
  8019a2:	8d 40 08             	lea    0x8(%eax),%eax
  8019a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019a8:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8019ad:	e9 8b 00 00 00       	jmp    801a3d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b5:	8b 10                	mov    (%eax),%edx
  8019b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019bc:	8d 40 04             	lea    0x4(%eax),%eax
  8019bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019c2:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8019c7:	eb 74                	jmp    801a3d <vprintfmt+0x3a8>
	if (lflag >= 2)
  8019c9:	83 f9 01             	cmp    $0x1,%ecx
  8019cc:	7f 1b                	jg     8019e9 <vprintfmt+0x354>
	else if (lflag)
  8019ce:	85 c9                	test   %ecx,%ecx
  8019d0:	74 2c                	je     8019fe <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8019d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d5:	8b 10                	mov    (%eax),%edx
  8019d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019dc:	8d 40 04             	lea    0x4(%eax),%eax
  8019df:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019e2:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8019e7:	eb 54                	jmp    801a3d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ec:	8b 10                	mov    (%eax),%edx
  8019ee:	8b 48 04             	mov    0x4(%eax),%ecx
  8019f1:	8d 40 08             	lea    0x8(%eax),%eax
  8019f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019f7:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8019fc:	eb 3f                	jmp    801a3d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801a01:	8b 10                	mov    (%eax),%edx
  801a03:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a08:	8d 40 04             	lea    0x4(%eax),%eax
  801a0b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a0e:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801a13:	eb 28                	jmp    801a3d <vprintfmt+0x3a8>
			putch('0', putdat);
  801a15:	83 ec 08             	sub    $0x8,%esp
  801a18:	53                   	push   %ebx
  801a19:	6a 30                	push   $0x30
  801a1b:	ff d6                	call   *%esi
			putch('x', putdat);
  801a1d:	83 c4 08             	add    $0x8,%esp
  801a20:	53                   	push   %ebx
  801a21:	6a 78                	push   $0x78
  801a23:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a25:	8b 45 14             	mov    0x14(%ebp),%eax
  801a28:	8b 10                	mov    (%eax),%edx
  801a2a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a2f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a32:	8d 40 04             	lea    0x4(%eax),%eax
  801a35:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a38:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801a3d:	83 ec 0c             	sub    $0xc,%esp
  801a40:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801a44:	50                   	push   %eax
  801a45:	ff 75 e0             	push   -0x20(%ebp)
  801a48:	57                   	push   %edi
  801a49:	51                   	push   %ecx
  801a4a:	52                   	push   %edx
  801a4b:	89 da                	mov    %ebx,%edx
  801a4d:	89 f0                	mov    %esi,%eax
  801a4f:	e8 5e fb ff ff       	call   8015b2 <printnum>
			break;
  801a54:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801a57:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a5a:	e9 54 fc ff ff       	jmp    8016b3 <vprintfmt+0x1e>
	if (lflag >= 2)
  801a5f:	83 f9 01             	cmp    $0x1,%ecx
  801a62:	7f 1b                	jg     801a7f <vprintfmt+0x3ea>
	else if (lflag)
  801a64:	85 c9                	test   %ecx,%ecx
  801a66:	74 2c                	je     801a94 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801a68:	8b 45 14             	mov    0x14(%ebp),%eax
  801a6b:	8b 10                	mov    (%eax),%edx
  801a6d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a72:	8d 40 04             	lea    0x4(%eax),%eax
  801a75:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a78:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801a7d:	eb be                	jmp    801a3d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801a7f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a82:	8b 10                	mov    (%eax),%edx
  801a84:	8b 48 04             	mov    0x4(%eax),%ecx
  801a87:	8d 40 08             	lea    0x8(%eax),%eax
  801a8a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a8d:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  801a92:	eb a9                	jmp    801a3d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a94:	8b 45 14             	mov    0x14(%ebp),%eax
  801a97:	8b 10                	mov    (%eax),%edx
  801a99:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a9e:	8d 40 04             	lea    0x4(%eax),%eax
  801aa1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801aa4:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  801aa9:	eb 92                	jmp    801a3d <vprintfmt+0x3a8>
			putch(ch, putdat);
  801aab:	83 ec 08             	sub    $0x8,%esp
  801aae:	53                   	push   %ebx
  801aaf:	6a 25                	push   $0x25
  801ab1:	ff d6                	call   *%esi
			break;
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	eb 9f                	jmp    801a57 <vprintfmt+0x3c2>
			putch('%', putdat);
  801ab8:	83 ec 08             	sub    $0x8,%esp
  801abb:	53                   	push   %ebx
  801abc:	6a 25                	push   $0x25
  801abe:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	89 f8                	mov    %edi,%eax
  801ac5:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801ac9:	74 05                	je     801ad0 <vprintfmt+0x43b>
  801acb:	83 e8 01             	sub    $0x1,%eax
  801ace:	eb f5                	jmp    801ac5 <vprintfmt+0x430>
  801ad0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ad3:	eb 82                	jmp    801a57 <vprintfmt+0x3c2>

00801ad5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	83 ec 18             	sub    $0x18,%esp
  801adb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ade:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ae1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ae4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ae8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801aeb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801af2:	85 c0                	test   %eax,%eax
  801af4:	74 26                	je     801b1c <vsnprintf+0x47>
  801af6:	85 d2                	test   %edx,%edx
  801af8:	7e 22                	jle    801b1c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801afa:	ff 75 14             	push   0x14(%ebp)
  801afd:	ff 75 10             	push   0x10(%ebp)
  801b00:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b03:	50                   	push   %eax
  801b04:	68 5b 16 80 00       	push   $0x80165b
  801b09:	e8 87 fb ff ff       	call   801695 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b11:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b17:	83 c4 10             	add    $0x10,%esp
}
  801b1a:	c9                   	leave  
  801b1b:	c3                   	ret    
		return -E_INVAL;
  801b1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b21:	eb f7                	jmp    801b1a <vsnprintf+0x45>

00801b23 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b23:	55                   	push   %ebp
  801b24:	89 e5                	mov    %esp,%ebp
  801b26:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b29:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b2c:	50                   	push   %eax
  801b2d:	ff 75 10             	push   0x10(%ebp)
  801b30:	ff 75 0c             	push   0xc(%ebp)
  801b33:	ff 75 08             	push   0x8(%ebp)
  801b36:	e8 9a ff ff ff       	call   801ad5 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b3b:	c9                   	leave  
  801b3c:	c3                   	ret    

00801b3d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b43:	b8 00 00 00 00       	mov    $0x0,%eax
  801b48:	eb 03                	jmp    801b4d <strlen+0x10>
		n++;
  801b4a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801b4d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b51:	75 f7                	jne    801b4a <strlen+0xd>
	return n;
}
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    

00801b55 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b5b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801b63:	eb 03                	jmp    801b68 <strnlen+0x13>
		n++;
  801b65:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b68:	39 d0                	cmp    %edx,%eax
  801b6a:	74 08                	je     801b74 <strnlen+0x1f>
  801b6c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801b70:	75 f3                	jne    801b65 <strnlen+0x10>
  801b72:	89 c2                	mov    %eax,%edx
	return n;
}
  801b74:	89 d0                	mov    %edx,%eax
  801b76:	5d                   	pop    %ebp
  801b77:	c3                   	ret    

00801b78 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	53                   	push   %ebx
  801b7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b82:	b8 00 00 00 00       	mov    $0x0,%eax
  801b87:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801b8b:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801b8e:	83 c0 01             	add    $0x1,%eax
  801b91:	84 d2                	test   %dl,%dl
  801b93:	75 f2                	jne    801b87 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801b95:	89 c8                	mov    %ecx,%eax
  801b97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b9a:	c9                   	leave  
  801b9b:	c3                   	ret    

00801b9c <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	53                   	push   %ebx
  801ba0:	83 ec 10             	sub    $0x10,%esp
  801ba3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801ba6:	53                   	push   %ebx
  801ba7:	e8 91 ff ff ff       	call   801b3d <strlen>
  801bac:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801baf:	ff 75 0c             	push   0xc(%ebp)
  801bb2:	01 d8                	add    %ebx,%eax
  801bb4:	50                   	push   %eax
  801bb5:	e8 be ff ff ff       	call   801b78 <strcpy>
	return dst;
}
  801bba:	89 d8                	mov    %ebx,%eax
  801bbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bbf:	c9                   	leave  
  801bc0:	c3                   	ret    

00801bc1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	56                   	push   %esi
  801bc5:	53                   	push   %ebx
  801bc6:	8b 75 08             	mov    0x8(%ebp),%esi
  801bc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bcc:	89 f3                	mov    %esi,%ebx
  801bce:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bd1:	89 f0                	mov    %esi,%eax
  801bd3:	eb 0f                	jmp    801be4 <strncpy+0x23>
		*dst++ = *src;
  801bd5:	83 c0 01             	add    $0x1,%eax
  801bd8:	0f b6 0a             	movzbl (%edx),%ecx
  801bdb:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bde:	80 f9 01             	cmp    $0x1,%cl
  801be1:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801be4:	39 d8                	cmp    %ebx,%eax
  801be6:	75 ed                	jne    801bd5 <strncpy+0x14>
	}
	return ret;
}
  801be8:	89 f0                	mov    %esi,%eax
  801bea:	5b                   	pop    %ebx
  801beb:	5e                   	pop    %esi
  801bec:	5d                   	pop    %ebp
  801bed:	c3                   	ret    

00801bee <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	56                   	push   %esi
  801bf2:	53                   	push   %ebx
  801bf3:	8b 75 08             	mov    0x8(%ebp),%esi
  801bf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bf9:	8b 55 10             	mov    0x10(%ebp),%edx
  801bfc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bfe:	85 d2                	test   %edx,%edx
  801c00:	74 21                	je     801c23 <strlcpy+0x35>
  801c02:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c06:	89 f2                	mov    %esi,%edx
  801c08:	eb 09                	jmp    801c13 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c0a:	83 c1 01             	add    $0x1,%ecx
  801c0d:	83 c2 01             	add    $0x1,%edx
  801c10:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801c13:	39 c2                	cmp    %eax,%edx
  801c15:	74 09                	je     801c20 <strlcpy+0x32>
  801c17:	0f b6 19             	movzbl (%ecx),%ebx
  801c1a:	84 db                	test   %bl,%bl
  801c1c:	75 ec                	jne    801c0a <strlcpy+0x1c>
  801c1e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c20:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c23:	29 f0                	sub    %esi,%eax
}
  801c25:	5b                   	pop    %ebx
  801c26:	5e                   	pop    %esi
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    

00801c29 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c2f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c32:	eb 06                	jmp    801c3a <strcmp+0x11>
		p++, q++;
  801c34:	83 c1 01             	add    $0x1,%ecx
  801c37:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801c3a:	0f b6 01             	movzbl (%ecx),%eax
  801c3d:	84 c0                	test   %al,%al
  801c3f:	74 04                	je     801c45 <strcmp+0x1c>
  801c41:	3a 02                	cmp    (%edx),%al
  801c43:	74 ef                	je     801c34 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c45:	0f b6 c0             	movzbl %al,%eax
  801c48:	0f b6 12             	movzbl (%edx),%edx
  801c4b:	29 d0                	sub    %edx,%eax
}
  801c4d:	5d                   	pop    %ebp
  801c4e:	c3                   	ret    

00801c4f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	53                   	push   %ebx
  801c53:	8b 45 08             	mov    0x8(%ebp),%eax
  801c56:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c59:	89 c3                	mov    %eax,%ebx
  801c5b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c5e:	eb 06                	jmp    801c66 <strncmp+0x17>
		n--, p++, q++;
  801c60:	83 c0 01             	add    $0x1,%eax
  801c63:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801c66:	39 d8                	cmp    %ebx,%eax
  801c68:	74 18                	je     801c82 <strncmp+0x33>
  801c6a:	0f b6 08             	movzbl (%eax),%ecx
  801c6d:	84 c9                	test   %cl,%cl
  801c6f:	74 04                	je     801c75 <strncmp+0x26>
  801c71:	3a 0a                	cmp    (%edx),%cl
  801c73:	74 eb                	je     801c60 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c75:	0f b6 00             	movzbl (%eax),%eax
  801c78:	0f b6 12             	movzbl (%edx),%edx
  801c7b:	29 d0                	sub    %edx,%eax
}
  801c7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c80:	c9                   	leave  
  801c81:	c3                   	ret    
		return 0;
  801c82:	b8 00 00 00 00       	mov    $0x0,%eax
  801c87:	eb f4                	jmp    801c7d <strncmp+0x2e>

00801c89 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c93:	eb 03                	jmp    801c98 <strchr+0xf>
  801c95:	83 c0 01             	add    $0x1,%eax
  801c98:	0f b6 10             	movzbl (%eax),%edx
  801c9b:	84 d2                	test   %dl,%dl
  801c9d:	74 06                	je     801ca5 <strchr+0x1c>
		if (*s == c)
  801c9f:	38 ca                	cmp    %cl,%dl
  801ca1:	75 f2                	jne    801c95 <strchr+0xc>
  801ca3:	eb 05                	jmp    801caa <strchr+0x21>
			return (char *) s;
	return 0;
  801ca5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801caa:	5d                   	pop    %ebp
  801cab:	c3                   	ret    

00801cac <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cb6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cb9:	38 ca                	cmp    %cl,%dl
  801cbb:	74 09                	je     801cc6 <strfind+0x1a>
  801cbd:	84 d2                	test   %dl,%dl
  801cbf:	74 05                	je     801cc6 <strfind+0x1a>
	for (; *s; s++)
  801cc1:	83 c0 01             	add    $0x1,%eax
  801cc4:	eb f0                	jmp    801cb6 <strfind+0xa>
			break;
	return (char *) s;
}
  801cc6:	5d                   	pop    %ebp
  801cc7:	c3                   	ret    

00801cc8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cc8:	55                   	push   %ebp
  801cc9:	89 e5                	mov    %esp,%ebp
  801ccb:	57                   	push   %edi
  801ccc:	56                   	push   %esi
  801ccd:	53                   	push   %ebx
  801cce:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cd1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cd4:	85 c9                	test   %ecx,%ecx
  801cd6:	74 2f                	je     801d07 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cd8:	89 f8                	mov    %edi,%eax
  801cda:	09 c8                	or     %ecx,%eax
  801cdc:	a8 03                	test   $0x3,%al
  801cde:	75 21                	jne    801d01 <memset+0x39>
		c &= 0xFF;
  801ce0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ce4:	89 d0                	mov    %edx,%eax
  801ce6:	c1 e0 08             	shl    $0x8,%eax
  801ce9:	89 d3                	mov    %edx,%ebx
  801ceb:	c1 e3 18             	shl    $0x18,%ebx
  801cee:	89 d6                	mov    %edx,%esi
  801cf0:	c1 e6 10             	shl    $0x10,%esi
  801cf3:	09 f3                	or     %esi,%ebx
  801cf5:	09 da                	or     %ebx,%edx
  801cf7:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801cf9:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801cfc:	fc                   	cld    
  801cfd:	f3 ab                	rep stos %eax,%es:(%edi)
  801cff:	eb 06                	jmp    801d07 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d01:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d04:	fc                   	cld    
  801d05:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d07:	89 f8                	mov    %edi,%eax
  801d09:	5b                   	pop    %ebx
  801d0a:	5e                   	pop    %esi
  801d0b:	5f                   	pop    %edi
  801d0c:	5d                   	pop    %ebp
  801d0d:	c3                   	ret    

00801d0e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	57                   	push   %edi
  801d12:	56                   	push   %esi
  801d13:	8b 45 08             	mov    0x8(%ebp),%eax
  801d16:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d19:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d1c:	39 c6                	cmp    %eax,%esi
  801d1e:	73 32                	jae    801d52 <memmove+0x44>
  801d20:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d23:	39 c2                	cmp    %eax,%edx
  801d25:	76 2b                	jbe    801d52 <memmove+0x44>
		s += n;
		d += n;
  801d27:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d2a:	89 d6                	mov    %edx,%esi
  801d2c:	09 fe                	or     %edi,%esi
  801d2e:	09 ce                	or     %ecx,%esi
  801d30:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d36:	75 0e                	jne    801d46 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d38:	83 ef 04             	sub    $0x4,%edi
  801d3b:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d3e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801d41:	fd                   	std    
  801d42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d44:	eb 09                	jmp    801d4f <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d46:	83 ef 01             	sub    $0x1,%edi
  801d49:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801d4c:	fd                   	std    
  801d4d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d4f:	fc                   	cld    
  801d50:	eb 1a                	jmp    801d6c <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d52:	89 f2                	mov    %esi,%edx
  801d54:	09 c2                	or     %eax,%edx
  801d56:	09 ca                	or     %ecx,%edx
  801d58:	f6 c2 03             	test   $0x3,%dl
  801d5b:	75 0a                	jne    801d67 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d5d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801d60:	89 c7                	mov    %eax,%edi
  801d62:	fc                   	cld    
  801d63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d65:	eb 05                	jmp    801d6c <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801d67:	89 c7                	mov    %eax,%edi
  801d69:	fc                   	cld    
  801d6a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d6c:	5e                   	pop    %esi
  801d6d:	5f                   	pop    %edi
  801d6e:	5d                   	pop    %ebp
  801d6f:	c3                   	ret    

00801d70 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d76:	ff 75 10             	push   0x10(%ebp)
  801d79:	ff 75 0c             	push   0xc(%ebp)
  801d7c:	ff 75 08             	push   0x8(%ebp)
  801d7f:	e8 8a ff ff ff       	call   801d0e <memmove>
}
  801d84:	c9                   	leave  
  801d85:	c3                   	ret    

00801d86 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	56                   	push   %esi
  801d8a:	53                   	push   %ebx
  801d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d91:	89 c6                	mov    %eax,%esi
  801d93:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d96:	eb 06                	jmp    801d9e <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801d98:	83 c0 01             	add    $0x1,%eax
  801d9b:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801d9e:	39 f0                	cmp    %esi,%eax
  801da0:	74 14                	je     801db6 <memcmp+0x30>
		if (*s1 != *s2)
  801da2:	0f b6 08             	movzbl (%eax),%ecx
  801da5:	0f b6 1a             	movzbl (%edx),%ebx
  801da8:	38 d9                	cmp    %bl,%cl
  801daa:	74 ec                	je     801d98 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801dac:	0f b6 c1             	movzbl %cl,%eax
  801daf:	0f b6 db             	movzbl %bl,%ebx
  801db2:	29 d8                	sub    %ebx,%eax
  801db4:	eb 05                	jmp    801dbb <memcmp+0x35>
	}

	return 0;
  801db6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dbb:	5b                   	pop    %ebx
  801dbc:	5e                   	pop    %esi
  801dbd:	5d                   	pop    %ebp
  801dbe:	c3                   	ret    

00801dbf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801dc8:	89 c2                	mov    %eax,%edx
  801dca:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801dcd:	eb 03                	jmp    801dd2 <memfind+0x13>
  801dcf:	83 c0 01             	add    $0x1,%eax
  801dd2:	39 d0                	cmp    %edx,%eax
  801dd4:	73 04                	jae    801dda <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dd6:	38 08                	cmp    %cl,(%eax)
  801dd8:	75 f5                	jne    801dcf <memfind+0x10>
			break;
	return (void *) s;
}
  801dda:	5d                   	pop    %ebp
  801ddb:	c3                   	ret    

00801ddc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	57                   	push   %edi
  801de0:	56                   	push   %esi
  801de1:	53                   	push   %ebx
  801de2:	8b 55 08             	mov    0x8(%ebp),%edx
  801de5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801de8:	eb 03                	jmp    801ded <strtol+0x11>
		s++;
  801dea:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801ded:	0f b6 02             	movzbl (%edx),%eax
  801df0:	3c 20                	cmp    $0x20,%al
  801df2:	74 f6                	je     801dea <strtol+0xe>
  801df4:	3c 09                	cmp    $0x9,%al
  801df6:	74 f2                	je     801dea <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801df8:	3c 2b                	cmp    $0x2b,%al
  801dfa:	74 2a                	je     801e26 <strtol+0x4a>
	int neg = 0;
  801dfc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801e01:	3c 2d                	cmp    $0x2d,%al
  801e03:	74 2b                	je     801e30 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e05:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e0b:	75 0f                	jne    801e1c <strtol+0x40>
  801e0d:	80 3a 30             	cmpb   $0x30,(%edx)
  801e10:	74 28                	je     801e3a <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e12:	85 db                	test   %ebx,%ebx
  801e14:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e19:	0f 44 d8             	cmove  %eax,%ebx
  801e1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e21:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801e24:	eb 46                	jmp    801e6c <strtol+0x90>
		s++;
  801e26:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801e29:	bf 00 00 00 00       	mov    $0x0,%edi
  801e2e:	eb d5                	jmp    801e05 <strtol+0x29>
		s++, neg = 1;
  801e30:	83 c2 01             	add    $0x1,%edx
  801e33:	bf 01 00 00 00       	mov    $0x1,%edi
  801e38:	eb cb                	jmp    801e05 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e3a:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e3e:	74 0e                	je     801e4e <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801e40:	85 db                	test   %ebx,%ebx
  801e42:	75 d8                	jne    801e1c <strtol+0x40>
		s++, base = 8;
  801e44:	83 c2 01             	add    $0x1,%edx
  801e47:	bb 08 00 00 00       	mov    $0x8,%ebx
  801e4c:	eb ce                	jmp    801e1c <strtol+0x40>
		s += 2, base = 16;
  801e4e:	83 c2 02             	add    $0x2,%edx
  801e51:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e56:	eb c4                	jmp    801e1c <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801e58:	0f be c0             	movsbl %al,%eax
  801e5b:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801e5e:	3b 45 10             	cmp    0x10(%ebp),%eax
  801e61:	7d 3a                	jge    801e9d <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801e63:	83 c2 01             	add    $0x1,%edx
  801e66:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801e6a:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801e6c:	0f b6 02             	movzbl (%edx),%eax
  801e6f:	8d 70 d0             	lea    -0x30(%eax),%esi
  801e72:	89 f3                	mov    %esi,%ebx
  801e74:	80 fb 09             	cmp    $0x9,%bl
  801e77:	76 df                	jbe    801e58 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801e79:	8d 70 9f             	lea    -0x61(%eax),%esi
  801e7c:	89 f3                	mov    %esi,%ebx
  801e7e:	80 fb 19             	cmp    $0x19,%bl
  801e81:	77 08                	ja     801e8b <strtol+0xaf>
			dig = *s - 'a' + 10;
  801e83:	0f be c0             	movsbl %al,%eax
  801e86:	83 e8 57             	sub    $0x57,%eax
  801e89:	eb d3                	jmp    801e5e <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801e8b:	8d 70 bf             	lea    -0x41(%eax),%esi
  801e8e:	89 f3                	mov    %esi,%ebx
  801e90:	80 fb 19             	cmp    $0x19,%bl
  801e93:	77 08                	ja     801e9d <strtol+0xc1>
			dig = *s - 'A' + 10;
  801e95:	0f be c0             	movsbl %al,%eax
  801e98:	83 e8 37             	sub    $0x37,%eax
  801e9b:	eb c1                	jmp    801e5e <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801e9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ea1:	74 05                	je     801ea8 <strtol+0xcc>
		*endptr = (char *) s;
  801ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea6:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801ea8:	89 c8                	mov    %ecx,%eax
  801eaa:	f7 d8                	neg    %eax
  801eac:	85 ff                	test   %edi,%edi
  801eae:	0f 45 c8             	cmovne %eax,%ecx
}
  801eb1:	89 c8                	mov    %ecx,%eax
  801eb3:	5b                   	pop    %ebx
  801eb4:	5e                   	pop    %esi
  801eb5:	5f                   	pop    %edi
  801eb6:	5d                   	pop    %ebp
  801eb7:	c3                   	ret    

00801eb8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eb8:	55                   	push   %ebp
  801eb9:	89 e5                	mov    %esp,%ebp
  801ebb:	56                   	push   %esi
  801ebc:	53                   	push   %ebx
  801ebd:	8b 75 08             	mov    0x8(%ebp),%esi
  801ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801ec6:	85 c0                	test   %eax,%eax
  801ec8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ecd:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ed0:	83 ec 0c             	sub    $0xc,%esp
  801ed3:	50                   	push   %eax
  801ed4:	e8 3a e4 ff ff       	call   800313 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ed9:	83 c4 10             	add    $0x10,%esp
  801edc:	85 f6                	test   %esi,%esi
  801ede:	74 14                	je     801ef4 <ipc_recv+0x3c>
  801ee0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	78 09                	js     801ef2 <ipc_recv+0x3a>
  801ee9:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801eef:	8b 52 74             	mov    0x74(%edx),%edx
  801ef2:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801ef4:	85 db                	test   %ebx,%ebx
  801ef6:	74 14                	je     801f0c <ipc_recv+0x54>
  801ef8:	ba 00 00 00 00       	mov    $0x0,%edx
  801efd:	85 c0                	test   %eax,%eax
  801eff:	78 09                	js     801f0a <ipc_recv+0x52>
  801f01:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f07:	8b 52 78             	mov    0x78(%edx),%edx
  801f0a:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f0c:	85 c0                	test   %eax,%eax
  801f0e:	78 08                	js     801f18 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801f10:	a1 00 40 80 00       	mov    0x804000,%eax
  801f15:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f1b:	5b                   	pop    %ebx
  801f1c:	5e                   	pop    %esi
  801f1d:	5d                   	pop    %ebp
  801f1e:	c3                   	ret    

00801f1f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f1f:	55                   	push   %ebp
  801f20:	89 e5                	mov    %esp,%ebp
  801f22:	57                   	push   %edi
  801f23:	56                   	push   %esi
  801f24:	53                   	push   %ebx
  801f25:	83 ec 0c             	sub    $0xc,%esp
  801f28:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f2b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f31:	85 db                	test   %ebx,%ebx
  801f33:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f38:	0f 44 d8             	cmove  %eax,%ebx
  801f3b:	eb 05                	jmp    801f42 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f3d:	e8 02 e2 ff ff       	call   800144 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f42:	ff 75 14             	push   0x14(%ebp)
  801f45:	53                   	push   %ebx
  801f46:	56                   	push   %esi
  801f47:	57                   	push   %edi
  801f48:	e8 a3 e3 ff ff       	call   8002f0 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f4d:	83 c4 10             	add    $0x10,%esp
  801f50:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f53:	74 e8                	je     801f3d <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f55:	85 c0                	test   %eax,%eax
  801f57:	78 08                	js     801f61 <ipc_send+0x42>
	}while (r<0);

}
  801f59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5c:	5b                   	pop    %ebx
  801f5d:	5e                   	pop    %esi
  801f5e:	5f                   	pop    %edi
  801f5f:	5d                   	pop    %ebp
  801f60:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f61:	50                   	push   %eax
  801f62:	68 bf 26 80 00       	push   $0x8026bf
  801f67:	6a 3d                	push   $0x3d
  801f69:	68 d3 26 80 00       	push   $0x8026d3
  801f6e:	e8 50 f5 ff ff       	call   8014c3 <_panic>

00801f73 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f79:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f7e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f81:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f87:	8b 52 50             	mov    0x50(%edx),%edx
  801f8a:	39 ca                	cmp    %ecx,%edx
  801f8c:	74 11                	je     801f9f <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801f8e:	83 c0 01             	add    $0x1,%eax
  801f91:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f96:	75 e6                	jne    801f7e <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f98:	b8 00 00 00 00       	mov    $0x0,%eax
  801f9d:	eb 0b                	jmp    801faa <ipc_find_env+0x37>
			return envs[i].env_id;
  801f9f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fa2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fa7:	8b 40 48             	mov    0x48(%eax),%eax
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
