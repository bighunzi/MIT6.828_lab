
obj/user/buggyhello2.debug：     文件格式 elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	push   0x803000
  800044:	e8 68 00 00 00       	call   8000b1 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 d1 00 00 00       	call   80012f <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 db                	test   %ebx,%ebx
  800075:	7e 07                	jle    80007e <libmain+0x30>
		binaryname = argv[0];
  800077:	8b 06                	mov    (%esi),%eax
  800079:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80007e:	83 ec 08             	sub    $0x8,%esp
  800081:	56                   	push   %esi
  800082:	53                   	push   %ebx
  800083:	e8 ab ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800088:	e8 0a 00 00 00       	call   800097 <exit>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    

00800097 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800097:	55                   	push   %ebp
  800098:	89 e5                	mov    %esp,%ebp
  80009a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009d:	e8 ee 04 00 00       	call   800590 <close_all>
	sys_env_destroy(0);
  8000a2:	83 ec 0c             	sub    $0xc,%esp
  8000a5:	6a 00                	push   $0x0
  8000a7:	e8 42 00 00 00       	call   8000ee <sys_env_destroy>
}
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	c9                   	leave  
  8000b0:	c3                   	ret    

008000b1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b1:	55                   	push   %ebp
  8000b2:	89 e5                	mov    %esp,%ebp
  8000b4:	57                   	push   %edi
  8000b5:	56                   	push   %esi
  8000b6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	89 c3                	mov    %eax,%ebx
  8000c4:	89 c7                	mov    %eax,%edi
  8000c6:	89 c6                	mov    %eax,%esi
  8000c8:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	56                   	push   %esi
  8000d4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000da:	b8 01 00 00 00       	mov    $0x1,%eax
  8000df:	89 d1                	mov    %edx,%ecx
  8000e1:	89 d3                	mov    %edx,%ebx
  8000e3:	89 d7                	mov    %edx,%edi
  8000e5:	89 d6                	mov    %edx,%esi
  8000e7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5f                   	pop    %edi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	89 cb                	mov    %ecx,%ebx
  800106:	89 cf                	mov    %ecx,%edi
  800108:	89 ce                	mov    %ecx,%esi
  80010a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010c:	85 c0                	test   %eax,%eax
  80010e:	7f 08                	jg     800118 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800118:	83 ec 0c             	sub    $0xc,%esp
  80011b:	50                   	push   %eax
  80011c:	6a 03                	push   $0x3
  80011e:	68 78 22 80 00       	push   $0x802278
  800123:	6a 2a                	push   $0x2a
  800125:	68 95 22 80 00       	push   $0x802295
  80012a:	e8 9e 13 00 00       	call   8014cd <_panic>

0080012f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	57                   	push   %edi
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
	asm volatile("int %1\n"
  800135:	ba 00 00 00 00       	mov    $0x0,%edx
  80013a:	b8 02 00 00 00       	mov    $0x2,%eax
  80013f:	89 d1                	mov    %edx,%ecx
  800141:	89 d3                	mov    %edx,%ebx
  800143:	89 d7                	mov    %edx,%edi
  800145:	89 d6                	mov    %edx,%esi
  800147:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5f                   	pop    %edi
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    

0080014e <sys_yield>:

void
sys_yield(void)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	57                   	push   %edi
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
	asm volatile("int %1\n"
  800154:	ba 00 00 00 00       	mov    $0x0,%edx
  800159:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015e:	89 d1                	mov    %edx,%ecx
  800160:	89 d3                	mov    %edx,%ebx
  800162:	89 d7                	mov    %edx,%edi
  800164:	89 d6                	mov    %edx,%esi
  800166:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800168:	5b                   	pop    %ebx
  800169:	5e                   	pop    %esi
  80016a:	5f                   	pop    %edi
  80016b:	5d                   	pop    %ebp
  80016c:	c3                   	ret    

0080016d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	57                   	push   %edi
  800171:	56                   	push   %esi
  800172:	53                   	push   %ebx
  800173:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800176:	be 00 00 00 00       	mov    $0x0,%esi
  80017b:	8b 55 08             	mov    0x8(%ebp),%edx
  80017e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800181:	b8 04 00 00 00       	mov    $0x4,%eax
  800186:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800189:	89 f7                	mov    %esi,%edi
  80018b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80018d:	85 c0                	test   %eax,%eax
  80018f:	7f 08                	jg     800199 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800199:	83 ec 0c             	sub    $0xc,%esp
  80019c:	50                   	push   %eax
  80019d:	6a 04                	push   $0x4
  80019f:	68 78 22 80 00       	push   $0x802278
  8001a4:	6a 2a                	push   $0x2a
  8001a6:	68 95 22 80 00       	push   $0x802295
  8001ab:	e8 1d 13 00 00       	call   8014cd <_panic>

008001b0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bf:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ca:	8b 75 18             	mov    0x18(%ebp),%esi
  8001cd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001cf:	85 c0                	test   %eax,%eax
  8001d1:	7f 08                	jg     8001db <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001db:	83 ec 0c             	sub    $0xc,%esp
  8001de:	50                   	push   %eax
  8001df:	6a 05                	push   $0x5
  8001e1:	68 78 22 80 00       	push   $0x802278
  8001e6:	6a 2a                	push   $0x2a
  8001e8:	68 95 22 80 00       	push   $0x802295
  8001ed:	e8 db 12 00 00       	call   8014cd <_panic>

008001f2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	57                   	push   %edi
  8001f6:	56                   	push   %esi
  8001f7:	53                   	push   %ebx
  8001f8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800200:	8b 55 08             	mov    0x8(%ebp),%edx
  800203:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800206:	b8 06 00 00 00       	mov    $0x6,%eax
  80020b:	89 df                	mov    %ebx,%edi
  80020d:	89 de                	mov    %ebx,%esi
  80020f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800211:	85 c0                	test   %eax,%eax
  800213:	7f 08                	jg     80021d <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80021d:	83 ec 0c             	sub    $0xc,%esp
  800220:	50                   	push   %eax
  800221:	6a 06                	push   $0x6
  800223:	68 78 22 80 00       	push   $0x802278
  800228:	6a 2a                	push   $0x2a
  80022a:	68 95 22 80 00       	push   $0x802295
  80022f:	e8 99 12 00 00       	call   8014cd <_panic>

00800234 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	57                   	push   %edi
  800238:	56                   	push   %esi
  800239:	53                   	push   %ebx
  80023a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80023d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800242:	8b 55 08             	mov    0x8(%ebp),%edx
  800245:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800248:	b8 08 00 00 00       	mov    $0x8,%eax
  80024d:	89 df                	mov    %ebx,%edi
  80024f:	89 de                	mov    %ebx,%esi
  800251:	cd 30                	int    $0x30
	if(check && ret > 0)
  800253:	85 c0                	test   %eax,%eax
  800255:	7f 08                	jg     80025f <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80025f:	83 ec 0c             	sub    $0xc,%esp
  800262:	50                   	push   %eax
  800263:	6a 08                	push   $0x8
  800265:	68 78 22 80 00       	push   $0x802278
  80026a:	6a 2a                	push   $0x2a
  80026c:	68 95 22 80 00       	push   $0x802295
  800271:	e8 57 12 00 00       	call   8014cd <_panic>

00800276 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
  800279:	57                   	push   %edi
  80027a:	56                   	push   %esi
  80027b:	53                   	push   %ebx
  80027c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80027f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800284:	8b 55 08             	mov    0x8(%ebp),%edx
  800287:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028a:	b8 09 00 00 00       	mov    $0x9,%eax
  80028f:	89 df                	mov    %ebx,%edi
  800291:	89 de                	mov    %ebx,%esi
  800293:	cd 30                	int    $0x30
	if(check && ret > 0)
  800295:	85 c0                	test   %eax,%eax
  800297:	7f 08                	jg     8002a1 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a1:	83 ec 0c             	sub    $0xc,%esp
  8002a4:	50                   	push   %eax
  8002a5:	6a 09                	push   $0x9
  8002a7:	68 78 22 80 00       	push   $0x802278
  8002ac:	6a 2a                	push   $0x2a
  8002ae:	68 95 22 80 00       	push   $0x802295
  8002b3:	e8 15 12 00 00       	call   8014cd <_panic>

008002b8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	57                   	push   %edi
  8002bc:	56                   	push   %esi
  8002bd:	53                   	push   %ebx
  8002be:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002d1:	89 df                	mov    %ebx,%edi
  8002d3:	89 de                	mov    %ebx,%esi
  8002d5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d7:	85 c0                	test   %eax,%eax
  8002d9:	7f 08                	jg     8002e3 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002de:	5b                   	pop    %ebx
  8002df:	5e                   	pop    %esi
  8002e0:	5f                   	pop    %edi
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e3:	83 ec 0c             	sub    $0xc,%esp
  8002e6:	50                   	push   %eax
  8002e7:	6a 0a                	push   $0xa
  8002e9:	68 78 22 80 00       	push   $0x802278
  8002ee:	6a 2a                	push   $0x2a
  8002f0:	68 95 22 80 00       	push   $0x802295
  8002f5:	e8 d3 11 00 00       	call   8014cd <_panic>

008002fa <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
  8002fd:	57                   	push   %edi
  8002fe:	56                   	push   %esi
  8002ff:	53                   	push   %ebx
	asm volatile("int %1\n"
  800300:	8b 55 08             	mov    0x8(%ebp),%edx
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030b:	be 00 00 00 00       	mov    $0x0,%esi
  800310:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800313:	8b 7d 14             	mov    0x14(%ebp),%edi
  800316:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800318:	5b                   	pop    %ebx
  800319:	5e                   	pop    %esi
  80031a:	5f                   	pop    %edi
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	57                   	push   %edi
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
  800323:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800326:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032b:	8b 55 08             	mov    0x8(%ebp),%edx
  80032e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800333:	89 cb                	mov    %ecx,%ebx
  800335:	89 cf                	mov    %ecx,%edi
  800337:	89 ce                	mov    %ecx,%esi
  800339:	cd 30                	int    $0x30
	if(check && ret > 0)
  80033b:	85 c0                	test   %eax,%eax
  80033d:	7f 08                	jg     800347 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800342:	5b                   	pop    %ebx
  800343:	5e                   	pop    %esi
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800347:	83 ec 0c             	sub    $0xc,%esp
  80034a:	50                   	push   %eax
  80034b:	6a 0d                	push   $0xd
  80034d:	68 78 22 80 00       	push   $0x802278
  800352:	6a 2a                	push   $0x2a
  800354:	68 95 22 80 00       	push   $0x802295
  800359:	e8 6f 11 00 00       	call   8014cd <_panic>

0080035e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	57                   	push   %edi
  800362:	56                   	push   %esi
  800363:	53                   	push   %ebx
	asm volatile("int %1\n"
  800364:	ba 00 00 00 00       	mov    $0x0,%edx
  800369:	b8 0e 00 00 00       	mov    $0xe,%eax
  80036e:	89 d1                	mov    %edx,%ecx
  800370:	89 d3                	mov    %edx,%ebx
  800372:	89 d7                	mov    %edx,%edi
  800374:	89 d6                	mov    %edx,%esi
  800376:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800378:	5b                   	pop    %ebx
  800379:	5e                   	pop    %esi
  80037a:	5f                   	pop    %edi
  80037b:	5d                   	pop    %ebp
  80037c:	c3                   	ret    

0080037d <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	57                   	push   %edi
  800381:	56                   	push   %esi
  800382:	53                   	push   %ebx
	asm volatile("int %1\n"
  800383:	bb 00 00 00 00       	mov    $0x0,%ebx
  800388:	8b 55 08             	mov    0x8(%ebp),%edx
  80038b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800393:	89 df                	mov    %ebx,%edi
  800395:	89 de                	mov    %ebx,%esi
  800397:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800399:	5b                   	pop    %ebx
  80039a:	5e                   	pop    %esi
  80039b:	5f                   	pop    %edi
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	57                   	push   %edi
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8003a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003af:	b8 10 00 00 00       	mov    $0x10,%eax
  8003b4:	89 df                	mov    %ebx,%edi
  8003b6:	89 de                	mov    %ebx,%esi
  8003b8:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8003ba:	5b                   	pop    %ebx
  8003bb:	5e                   	pop    %esi
  8003bc:	5f                   	pop    %edi
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    

008003bf <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c5:	05 00 00 00 30       	add    $0x30000000,%eax
  8003ca:	c1 e8 0c             	shr    $0xc,%eax
}
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d5:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003da:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003df:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    

008003e6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 16             	shr    $0x16,%edx
  8003f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 29                	je     800428 <fd_alloc+0x42>
  8003ff:	89 c2                	mov    %eax,%edx
  800401:	c1 ea 0c             	shr    $0xc,%edx
  800404:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80040b:	f6 c2 01             	test   $0x1,%dl
  80040e:	74 18                	je     800428 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800410:	05 00 10 00 00       	add    $0x1000,%eax
  800415:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80041a:	75 d2                	jne    8003ee <fd_alloc+0x8>
  80041c:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800421:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800426:	eb 05                	jmp    80042d <fd_alloc+0x47>
			return 0;
  800428:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80042d:	8b 55 08             	mov    0x8(%ebp),%edx
  800430:	89 02                	mov    %eax,(%edx)
}
  800432:	89 c8                	mov    %ecx,%eax
  800434:	5d                   	pop    %ebp
  800435:	c3                   	ret    

00800436 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
  800439:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80043c:	83 f8 1f             	cmp    $0x1f,%eax
  80043f:	77 30                	ja     800471 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800441:	c1 e0 0c             	shl    $0xc,%eax
  800444:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800449:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80044f:	f6 c2 01             	test   $0x1,%dl
  800452:	74 24                	je     800478 <fd_lookup+0x42>
  800454:	89 c2                	mov    %eax,%edx
  800456:	c1 ea 0c             	shr    $0xc,%edx
  800459:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800460:	f6 c2 01             	test   $0x1,%dl
  800463:	74 1a                	je     80047f <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800465:	8b 55 0c             	mov    0xc(%ebp),%edx
  800468:	89 02                	mov    %eax,(%edx)
	return 0;
  80046a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80046f:	5d                   	pop    %ebp
  800470:	c3                   	ret    
		return -E_INVAL;
  800471:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800476:	eb f7                	jmp    80046f <fd_lookup+0x39>
		return -E_INVAL;
  800478:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80047d:	eb f0                	jmp    80046f <fd_lookup+0x39>
  80047f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800484:	eb e9                	jmp    80046f <fd_lookup+0x39>

00800486 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
  800489:	53                   	push   %ebx
  80048a:	83 ec 04             	sub    $0x4,%esp
  80048d:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800490:	b8 00 00 00 00       	mov    $0x0,%eax
  800495:	bb 08 30 80 00       	mov    $0x803008,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80049a:	39 13                	cmp    %edx,(%ebx)
  80049c:	74 37                	je     8004d5 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  80049e:	83 c0 01             	add    $0x1,%eax
  8004a1:	8b 1c 85 20 23 80 00 	mov    0x802320(,%eax,4),%ebx
  8004a8:	85 db                	test   %ebx,%ebx
  8004aa:	75 ee                	jne    80049a <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004ac:	a1 00 40 80 00       	mov    0x804000,%eax
  8004b1:	8b 40 58             	mov    0x58(%eax),%eax
  8004b4:	83 ec 04             	sub    $0x4,%esp
  8004b7:	52                   	push   %edx
  8004b8:	50                   	push   %eax
  8004b9:	68 a4 22 80 00       	push   $0x8022a4
  8004be:	e8 e5 10 00 00       	call   8015a8 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8004cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ce:	89 1a                	mov    %ebx,(%edx)
}
  8004d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004d3:	c9                   	leave  
  8004d4:	c3                   	ret    
			return 0;
  8004d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004da:	eb ef                	jmp    8004cb <dev_lookup+0x45>

008004dc <fd_close>:
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	57                   	push   %edi
  8004e0:	56                   	push   %esi
  8004e1:	53                   	push   %ebx
  8004e2:	83 ec 24             	sub    $0x24,%esp
  8004e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004eb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004ee:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004ef:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004f5:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004f8:	50                   	push   %eax
  8004f9:	e8 38 ff ff ff       	call   800436 <fd_lookup>
  8004fe:	89 c3                	mov    %eax,%ebx
  800500:	83 c4 10             	add    $0x10,%esp
  800503:	85 c0                	test   %eax,%eax
  800505:	78 05                	js     80050c <fd_close+0x30>
	    || fd != fd2)
  800507:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80050a:	74 16                	je     800522 <fd_close+0x46>
		return (must_exist ? r : 0);
  80050c:	89 f8                	mov    %edi,%eax
  80050e:	84 c0                	test   %al,%al
  800510:	b8 00 00 00 00       	mov    $0x0,%eax
  800515:	0f 44 d8             	cmove  %eax,%ebx
}
  800518:	89 d8                	mov    %ebx,%eax
  80051a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80051d:	5b                   	pop    %ebx
  80051e:	5e                   	pop    %esi
  80051f:	5f                   	pop    %edi
  800520:	5d                   	pop    %ebp
  800521:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800522:	83 ec 08             	sub    $0x8,%esp
  800525:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800528:	50                   	push   %eax
  800529:	ff 36                	push   (%esi)
  80052b:	e8 56 ff ff ff       	call   800486 <dev_lookup>
  800530:	89 c3                	mov    %eax,%ebx
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	85 c0                	test   %eax,%eax
  800537:	78 1a                	js     800553 <fd_close+0x77>
		if (dev->dev_close)
  800539:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80053c:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80053f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800544:	85 c0                	test   %eax,%eax
  800546:	74 0b                	je     800553 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800548:	83 ec 0c             	sub    $0xc,%esp
  80054b:	56                   	push   %esi
  80054c:	ff d0                	call   *%eax
  80054e:	89 c3                	mov    %eax,%ebx
  800550:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	56                   	push   %esi
  800557:	6a 00                	push   $0x0
  800559:	e8 94 fc ff ff       	call   8001f2 <sys_page_unmap>
	return r;
  80055e:	83 c4 10             	add    $0x10,%esp
  800561:	eb b5                	jmp    800518 <fd_close+0x3c>

00800563 <close>:

int
close(int fdnum)
{
  800563:	55                   	push   %ebp
  800564:	89 e5                	mov    %esp,%ebp
  800566:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800569:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80056c:	50                   	push   %eax
  80056d:	ff 75 08             	push   0x8(%ebp)
  800570:	e8 c1 fe ff ff       	call   800436 <fd_lookup>
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	85 c0                	test   %eax,%eax
  80057a:	79 02                	jns    80057e <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80057c:	c9                   	leave  
  80057d:	c3                   	ret    
		return fd_close(fd, 1);
  80057e:	83 ec 08             	sub    $0x8,%esp
  800581:	6a 01                	push   $0x1
  800583:	ff 75 f4             	push   -0xc(%ebp)
  800586:	e8 51 ff ff ff       	call   8004dc <fd_close>
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	eb ec                	jmp    80057c <close+0x19>

00800590 <close_all>:

void
close_all(void)
{
  800590:	55                   	push   %ebp
  800591:	89 e5                	mov    %esp,%ebp
  800593:	53                   	push   %ebx
  800594:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800597:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80059c:	83 ec 0c             	sub    $0xc,%esp
  80059f:	53                   	push   %ebx
  8005a0:	e8 be ff ff ff       	call   800563 <close>
	for (i = 0; i < MAXFD; i++)
  8005a5:	83 c3 01             	add    $0x1,%ebx
  8005a8:	83 c4 10             	add    $0x10,%esp
  8005ab:	83 fb 20             	cmp    $0x20,%ebx
  8005ae:	75 ec                	jne    80059c <close_all+0xc>
}
  8005b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005b3:	c9                   	leave  
  8005b4:	c3                   	ret    

008005b5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005b5:	55                   	push   %ebp
  8005b6:	89 e5                	mov    %esp,%ebp
  8005b8:	57                   	push   %edi
  8005b9:	56                   	push   %esi
  8005ba:	53                   	push   %ebx
  8005bb:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005be:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005c1:	50                   	push   %eax
  8005c2:	ff 75 08             	push   0x8(%ebp)
  8005c5:	e8 6c fe ff ff       	call   800436 <fd_lookup>
  8005ca:	89 c3                	mov    %eax,%ebx
  8005cc:	83 c4 10             	add    $0x10,%esp
  8005cf:	85 c0                	test   %eax,%eax
  8005d1:	78 7f                	js     800652 <dup+0x9d>
		return r;
	close(newfdnum);
  8005d3:	83 ec 0c             	sub    $0xc,%esp
  8005d6:	ff 75 0c             	push   0xc(%ebp)
  8005d9:	e8 85 ff ff ff       	call   800563 <close>

	newfd = INDEX2FD(newfdnum);
  8005de:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005e1:	c1 e6 0c             	shl    $0xc,%esi
  8005e4:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ed:	89 3c 24             	mov    %edi,(%esp)
  8005f0:	e8 da fd ff ff       	call   8003cf <fd2data>
  8005f5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005f7:	89 34 24             	mov    %esi,(%esp)
  8005fa:	e8 d0 fd ff ff       	call   8003cf <fd2data>
  8005ff:	83 c4 10             	add    $0x10,%esp
  800602:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800605:	89 d8                	mov    %ebx,%eax
  800607:	c1 e8 16             	shr    $0x16,%eax
  80060a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800611:	a8 01                	test   $0x1,%al
  800613:	74 11                	je     800626 <dup+0x71>
  800615:	89 d8                	mov    %ebx,%eax
  800617:	c1 e8 0c             	shr    $0xc,%eax
  80061a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800621:	f6 c2 01             	test   $0x1,%dl
  800624:	75 36                	jne    80065c <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800626:	89 f8                	mov    %edi,%eax
  800628:	c1 e8 0c             	shr    $0xc,%eax
  80062b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800632:	83 ec 0c             	sub    $0xc,%esp
  800635:	25 07 0e 00 00       	and    $0xe07,%eax
  80063a:	50                   	push   %eax
  80063b:	56                   	push   %esi
  80063c:	6a 00                	push   $0x0
  80063e:	57                   	push   %edi
  80063f:	6a 00                	push   $0x0
  800641:	e8 6a fb ff ff       	call   8001b0 <sys_page_map>
  800646:	89 c3                	mov    %eax,%ebx
  800648:	83 c4 20             	add    $0x20,%esp
  80064b:	85 c0                	test   %eax,%eax
  80064d:	78 33                	js     800682 <dup+0xcd>
		goto err;

	return newfdnum;
  80064f:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800652:	89 d8                	mov    %ebx,%eax
  800654:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800657:	5b                   	pop    %ebx
  800658:	5e                   	pop    %esi
  800659:	5f                   	pop    %edi
  80065a:	5d                   	pop    %ebp
  80065b:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80065c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800663:	83 ec 0c             	sub    $0xc,%esp
  800666:	25 07 0e 00 00       	and    $0xe07,%eax
  80066b:	50                   	push   %eax
  80066c:	ff 75 d4             	push   -0x2c(%ebp)
  80066f:	6a 00                	push   $0x0
  800671:	53                   	push   %ebx
  800672:	6a 00                	push   $0x0
  800674:	e8 37 fb ff ff       	call   8001b0 <sys_page_map>
  800679:	89 c3                	mov    %eax,%ebx
  80067b:	83 c4 20             	add    $0x20,%esp
  80067e:	85 c0                	test   %eax,%eax
  800680:	79 a4                	jns    800626 <dup+0x71>
	sys_page_unmap(0, newfd);
  800682:	83 ec 08             	sub    $0x8,%esp
  800685:	56                   	push   %esi
  800686:	6a 00                	push   $0x0
  800688:	e8 65 fb ff ff       	call   8001f2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80068d:	83 c4 08             	add    $0x8,%esp
  800690:	ff 75 d4             	push   -0x2c(%ebp)
  800693:	6a 00                	push   $0x0
  800695:	e8 58 fb ff ff       	call   8001f2 <sys_page_unmap>
	return r;
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	eb b3                	jmp    800652 <dup+0x9d>

0080069f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80069f:	55                   	push   %ebp
  8006a0:	89 e5                	mov    %esp,%ebp
  8006a2:	56                   	push   %esi
  8006a3:	53                   	push   %ebx
  8006a4:	83 ec 18             	sub    $0x18,%esp
  8006a7:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006ad:	50                   	push   %eax
  8006ae:	56                   	push   %esi
  8006af:	e8 82 fd ff ff       	call   800436 <fd_lookup>
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	85 c0                	test   %eax,%eax
  8006b9:	78 3c                	js     8006f7 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006bb:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006c4:	50                   	push   %eax
  8006c5:	ff 33                	push   (%ebx)
  8006c7:	e8 ba fd ff ff       	call   800486 <dev_lookup>
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	78 24                	js     8006f7 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006d3:	8b 43 08             	mov    0x8(%ebx),%eax
  8006d6:	83 e0 03             	and    $0x3,%eax
  8006d9:	83 f8 01             	cmp    $0x1,%eax
  8006dc:	74 20                	je     8006fe <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e1:	8b 40 08             	mov    0x8(%eax),%eax
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	74 37                	je     80071f <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006e8:	83 ec 04             	sub    $0x4,%esp
  8006eb:	ff 75 10             	push   0x10(%ebp)
  8006ee:	ff 75 0c             	push   0xc(%ebp)
  8006f1:	53                   	push   %ebx
  8006f2:	ff d0                	call   *%eax
  8006f4:	83 c4 10             	add    $0x10,%esp
}
  8006f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006fa:	5b                   	pop    %ebx
  8006fb:	5e                   	pop    %esi
  8006fc:	5d                   	pop    %ebp
  8006fd:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006fe:	a1 00 40 80 00       	mov    0x804000,%eax
  800703:	8b 40 58             	mov    0x58(%eax),%eax
  800706:	83 ec 04             	sub    $0x4,%esp
  800709:	56                   	push   %esi
  80070a:	50                   	push   %eax
  80070b:	68 e5 22 80 00       	push   $0x8022e5
  800710:	e8 93 0e 00 00       	call   8015a8 <cprintf>
		return -E_INVAL;
  800715:	83 c4 10             	add    $0x10,%esp
  800718:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80071d:	eb d8                	jmp    8006f7 <read+0x58>
		return -E_NOT_SUPP;
  80071f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800724:	eb d1                	jmp    8006f7 <read+0x58>

00800726 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800726:	55                   	push   %ebp
  800727:	89 e5                	mov    %esp,%ebp
  800729:	57                   	push   %edi
  80072a:	56                   	push   %esi
  80072b:	53                   	push   %ebx
  80072c:	83 ec 0c             	sub    $0xc,%esp
  80072f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800732:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800735:	bb 00 00 00 00       	mov    $0x0,%ebx
  80073a:	eb 02                	jmp    80073e <readn+0x18>
  80073c:	01 c3                	add    %eax,%ebx
  80073e:	39 f3                	cmp    %esi,%ebx
  800740:	73 21                	jae    800763 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800742:	83 ec 04             	sub    $0x4,%esp
  800745:	89 f0                	mov    %esi,%eax
  800747:	29 d8                	sub    %ebx,%eax
  800749:	50                   	push   %eax
  80074a:	89 d8                	mov    %ebx,%eax
  80074c:	03 45 0c             	add    0xc(%ebp),%eax
  80074f:	50                   	push   %eax
  800750:	57                   	push   %edi
  800751:	e8 49 ff ff ff       	call   80069f <read>
		if (m < 0)
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	85 c0                	test   %eax,%eax
  80075b:	78 04                	js     800761 <readn+0x3b>
			return m;
		if (m == 0)
  80075d:	75 dd                	jne    80073c <readn+0x16>
  80075f:	eb 02                	jmp    800763 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800761:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800763:	89 d8                	mov    %ebx,%eax
  800765:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800768:	5b                   	pop    %ebx
  800769:	5e                   	pop    %esi
  80076a:	5f                   	pop    %edi
  80076b:	5d                   	pop    %ebp
  80076c:	c3                   	ret    

0080076d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	56                   	push   %esi
  800771:	53                   	push   %ebx
  800772:	83 ec 18             	sub    $0x18,%esp
  800775:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800778:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80077b:	50                   	push   %eax
  80077c:	53                   	push   %ebx
  80077d:	e8 b4 fc ff ff       	call   800436 <fd_lookup>
  800782:	83 c4 10             	add    $0x10,%esp
  800785:	85 c0                	test   %eax,%eax
  800787:	78 37                	js     8007c0 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800789:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80078c:	83 ec 08             	sub    $0x8,%esp
  80078f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800792:	50                   	push   %eax
  800793:	ff 36                	push   (%esi)
  800795:	e8 ec fc ff ff       	call   800486 <dev_lookup>
  80079a:	83 c4 10             	add    $0x10,%esp
  80079d:	85 c0                	test   %eax,%eax
  80079f:	78 1f                	js     8007c0 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007a1:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8007a5:	74 20                	je     8007c7 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8007ad:	85 c0                	test   %eax,%eax
  8007af:	74 37                	je     8007e8 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007b1:	83 ec 04             	sub    $0x4,%esp
  8007b4:	ff 75 10             	push   0x10(%ebp)
  8007b7:	ff 75 0c             	push   0xc(%ebp)
  8007ba:	56                   	push   %esi
  8007bb:	ff d0                	call   *%eax
  8007bd:	83 c4 10             	add    $0x10,%esp
}
  8007c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007c3:	5b                   	pop    %ebx
  8007c4:	5e                   	pop    %esi
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007c7:	a1 00 40 80 00       	mov    0x804000,%eax
  8007cc:	8b 40 58             	mov    0x58(%eax),%eax
  8007cf:	83 ec 04             	sub    $0x4,%esp
  8007d2:	53                   	push   %ebx
  8007d3:	50                   	push   %eax
  8007d4:	68 01 23 80 00       	push   $0x802301
  8007d9:	e8 ca 0d 00 00       	call   8015a8 <cprintf>
		return -E_INVAL;
  8007de:	83 c4 10             	add    $0x10,%esp
  8007e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e6:	eb d8                	jmp    8007c0 <write+0x53>
		return -E_NOT_SUPP;
  8007e8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007ed:	eb d1                	jmp    8007c0 <write+0x53>

008007ef <seek>:

int
seek(int fdnum, off_t offset)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f8:	50                   	push   %eax
  8007f9:	ff 75 08             	push   0x8(%ebp)
  8007fc:	e8 35 fc ff ff       	call   800436 <fd_lookup>
  800801:	83 c4 10             	add    $0x10,%esp
  800804:	85 c0                	test   %eax,%eax
  800806:	78 0e                	js     800816 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800808:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80080e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800811:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800816:	c9                   	leave  
  800817:	c3                   	ret    

00800818 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	56                   	push   %esi
  80081c:	53                   	push   %ebx
  80081d:	83 ec 18             	sub    $0x18,%esp
  800820:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800823:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800826:	50                   	push   %eax
  800827:	53                   	push   %ebx
  800828:	e8 09 fc ff ff       	call   800436 <fd_lookup>
  80082d:	83 c4 10             	add    $0x10,%esp
  800830:	85 c0                	test   %eax,%eax
  800832:	78 34                	js     800868 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800834:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800837:	83 ec 08             	sub    $0x8,%esp
  80083a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80083d:	50                   	push   %eax
  80083e:	ff 36                	push   (%esi)
  800840:	e8 41 fc ff ff       	call   800486 <dev_lookup>
  800845:	83 c4 10             	add    $0x10,%esp
  800848:	85 c0                	test   %eax,%eax
  80084a:	78 1c                	js     800868 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80084c:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800850:	74 1d                	je     80086f <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800852:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800855:	8b 40 18             	mov    0x18(%eax),%eax
  800858:	85 c0                	test   %eax,%eax
  80085a:	74 34                	je     800890 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80085c:	83 ec 08             	sub    $0x8,%esp
  80085f:	ff 75 0c             	push   0xc(%ebp)
  800862:	56                   	push   %esi
  800863:	ff d0                	call   *%eax
  800865:	83 c4 10             	add    $0x10,%esp
}
  800868:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80086b:	5b                   	pop    %ebx
  80086c:	5e                   	pop    %esi
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    
			thisenv->env_id, fdnum);
  80086f:	a1 00 40 80 00       	mov    0x804000,%eax
  800874:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800877:	83 ec 04             	sub    $0x4,%esp
  80087a:	53                   	push   %ebx
  80087b:	50                   	push   %eax
  80087c:	68 c4 22 80 00       	push   $0x8022c4
  800881:	e8 22 0d 00 00       	call   8015a8 <cprintf>
		return -E_INVAL;
  800886:	83 c4 10             	add    $0x10,%esp
  800889:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088e:	eb d8                	jmp    800868 <ftruncate+0x50>
		return -E_NOT_SUPP;
  800890:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800895:	eb d1                	jmp    800868 <ftruncate+0x50>

00800897 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	56                   	push   %esi
  80089b:	53                   	push   %ebx
  80089c:	83 ec 18             	sub    $0x18,%esp
  80089f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a5:	50                   	push   %eax
  8008a6:	ff 75 08             	push   0x8(%ebp)
  8008a9:	e8 88 fb ff ff       	call   800436 <fd_lookup>
  8008ae:	83 c4 10             	add    $0x10,%esp
  8008b1:	85 c0                	test   %eax,%eax
  8008b3:	78 49                	js     8008fe <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b5:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8008b8:	83 ec 08             	sub    $0x8,%esp
  8008bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008be:	50                   	push   %eax
  8008bf:	ff 36                	push   (%esi)
  8008c1:	e8 c0 fb ff ff       	call   800486 <dev_lookup>
  8008c6:	83 c4 10             	add    $0x10,%esp
  8008c9:	85 c0                	test   %eax,%eax
  8008cb:	78 31                	js     8008fe <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8008cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008d4:	74 2f                	je     800905 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008d6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008d9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008e0:	00 00 00 
	stat->st_isdir = 0;
  8008e3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ea:	00 00 00 
	stat->st_dev = dev;
  8008ed:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008f3:	83 ec 08             	sub    $0x8,%esp
  8008f6:	53                   	push   %ebx
  8008f7:	56                   	push   %esi
  8008f8:	ff 50 14             	call   *0x14(%eax)
  8008fb:	83 c4 10             	add    $0x10,%esp
}
  8008fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800901:	5b                   	pop    %ebx
  800902:	5e                   	pop    %esi
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    
		return -E_NOT_SUPP;
  800905:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80090a:	eb f2                	jmp    8008fe <fstat+0x67>

0080090c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	56                   	push   %esi
  800910:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800911:	83 ec 08             	sub    $0x8,%esp
  800914:	6a 00                	push   $0x0
  800916:	ff 75 08             	push   0x8(%ebp)
  800919:	e8 e4 01 00 00       	call   800b02 <open>
  80091e:	89 c3                	mov    %eax,%ebx
  800920:	83 c4 10             	add    $0x10,%esp
  800923:	85 c0                	test   %eax,%eax
  800925:	78 1b                	js     800942 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800927:	83 ec 08             	sub    $0x8,%esp
  80092a:	ff 75 0c             	push   0xc(%ebp)
  80092d:	50                   	push   %eax
  80092e:	e8 64 ff ff ff       	call   800897 <fstat>
  800933:	89 c6                	mov    %eax,%esi
	close(fd);
  800935:	89 1c 24             	mov    %ebx,(%esp)
  800938:	e8 26 fc ff ff       	call   800563 <close>
	return r;
  80093d:	83 c4 10             	add    $0x10,%esp
  800940:	89 f3                	mov    %esi,%ebx
}
  800942:	89 d8                	mov    %ebx,%eax
  800944:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800947:	5b                   	pop    %ebx
  800948:	5e                   	pop    %esi
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	56                   	push   %esi
  80094f:	53                   	push   %ebx
  800950:	89 c6                	mov    %eax,%esi
  800952:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800954:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80095b:	74 27                	je     800984 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80095d:	6a 07                	push   $0x7
  80095f:	68 00 50 80 00       	push   $0x805000
  800964:	56                   	push   %esi
  800965:	ff 35 00 60 80 00    	push   0x806000
  80096b:	e8 c2 15 00 00       	call   801f32 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800970:	83 c4 0c             	add    $0xc,%esp
  800973:	6a 00                	push   $0x0
  800975:	53                   	push   %ebx
  800976:	6a 00                	push   $0x0
  800978:	e8 45 15 00 00       	call   801ec2 <ipc_recv>
}
  80097d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800980:	5b                   	pop    %ebx
  800981:	5e                   	pop    %esi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800984:	83 ec 0c             	sub    $0xc,%esp
  800987:	6a 01                	push   $0x1
  800989:	e8 f8 15 00 00       	call   801f86 <ipc_find_env>
  80098e:	a3 00 60 80 00       	mov    %eax,0x806000
  800993:	83 c4 10             	add    $0x10,%esp
  800996:	eb c5                	jmp    80095d <fsipc+0x12>

00800998 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ac:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b6:	b8 02 00 00 00       	mov    $0x2,%eax
  8009bb:	e8 8b ff ff ff       	call   80094b <fsipc>
}
  8009c0:	c9                   	leave  
  8009c1:	c3                   	ret    

008009c2 <devfile_flush>:
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ce:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d8:	b8 06 00 00 00       	mov    $0x6,%eax
  8009dd:	e8 69 ff ff ff       	call   80094b <fsipc>
}
  8009e2:	c9                   	leave  
  8009e3:	c3                   	ret    

008009e4 <devfile_stat>:
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	53                   	push   %ebx
  8009e8:	83 ec 04             	sub    $0x4,%esp
  8009eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fe:	b8 05 00 00 00       	mov    $0x5,%eax
  800a03:	e8 43 ff ff ff       	call   80094b <fsipc>
  800a08:	85 c0                	test   %eax,%eax
  800a0a:	78 2c                	js     800a38 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a0c:	83 ec 08             	sub    $0x8,%esp
  800a0f:	68 00 50 80 00       	push   $0x805000
  800a14:	53                   	push   %ebx
  800a15:	e8 68 11 00 00       	call   801b82 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a1a:	a1 80 50 80 00       	mov    0x805080,%eax
  800a1f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a25:	a1 84 50 80 00       	mov    0x805084,%eax
  800a2a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a30:	83 c4 10             	add    $0x10,%esp
  800a33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a3b:	c9                   	leave  
  800a3c:	c3                   	ret    

00800a3d <devfile_write>:
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	83 ec 0c             	sub    $0xc,%esp
  800a43:	8b 45 10             	mov    0x10(%ebp),%eax
  800a46:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a4b:	39 d0                	cmp    %edx,%eax
  800a4d:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a50:	8b 55 08             	mov    0x8(%ebp),%edx
  800a53:	8b 52 0c             	mov    0xc(%edx),%edx
  800a56:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a5c:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a61:	50                   	push   %eax
  800a62:	ff 75 0c             	push   0xc(%ebp)
  800a65:	68 08 50 80 00       	push   $0x805008
  800a6a:	e8 a9 12 00 00       	call   801d18 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a74:	b8 04 00 00 00       	mov    $0x4,%eax
  800a79:	e8 cd fe ff ff       	call   80094b <fsipc>
}
  800a7e:	c9                   	leave  
  800a7f:	c3                   	ret    

00800a80 <devfile_read>:
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
  800a85:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a93:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a99:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9e:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa3:	e8 a3 fe ff ff       	call   80094b <fsipc>
  800aa8:	89 c3                	mov    %eax,%ebx
  800aaa:	85 c0                	test   %eax,%eax
  800aac:	78 1f                	js     800acd <devfile_read+0x4d>
	assert(r <= n);
  800aae:	39 f0                	cmp    %esi,%eax
  800ab0:	77 24                	ja     800ad6 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800ab2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ab7:	7f 33                	jg     800aec <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ab9:	83 ec 04             	sub    $0x4,%esp
  800abc:	50                   	push   %eax
  800abd:	68 00 50 80 00       	push   $0x805000
  800ac2:	ff 75 0c             	push   0xc(%ebp)
  800ac5:	e8 4e 12 00 00       	call   801d18 <memmove>
	return r;
  800aca:	83 c4 10             	add    $0x10,%esp
}
  800acd:	89 d8                	mov    %ebx,%eax
  800acf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    
	assert(r <= n);
  800ad6:	68 34 23 80 00       	push   $0x802334
  800adb:	68 3b 23 80 00       	push   $0x80233b
  800ae0:	6a 7c                	push   $0x7c
  800ae2:	68 50 23 80 00       	push   $0x802350
  800ae7:	e8 e1 09 00 00       	call   8014cd <_panic>
	assert(r <= PGSIZE);
  800aec:	68 5b 23 80 00       	push   $0x80235b
  800af1:	68 3b 23 80 00       	push   $0x80233b
  800af6:	6a 7d                	push   $0x7d
  800af8:	68 50 23 80 00       	push   $0x802350
  800afd:	e8 cb 09 00 00       	call   8014cd <_panic>

00800b02 <open>:
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	83 ec 1c             	sub    $0x1c,%esp
  800b0a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b0d:	56                   	push   %esi
  800b0e:	e8 34 10 00 00       	call   801b47 <strlen>
  800b13:	83 c4 10             	add    $0x10,%esp
  800b16:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b1b:	7f 6c                	jg     800b89 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800b1d:	83 ec 0c             	sub    $0xc,%esp
  800b20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b23:	50                   	push   %eax
  800b24:	e8 bd f8 ff ff       	call   8003e6 <fd_alloc>
  800b29:	89 c3                	mov    %eax,%ebx
  800b2b:	83 c4 10             	add    $0x10,%esp
  800b2e:	85 c0                	test   %eax,%eax
  800b30:	78 3c                	js     800b6e <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800b32:	83 ec 08             	sub    $0x8,%esp
  800b35:	56                   	push   %esi
  800b36:	68 00 50 80 00       	push   $0x805000
  800b3b:	e8 42 10 00 00       	call   801b82 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b43:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b48:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b4b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b50:	e8 f6 fd ff ff       	call   80094b <fsipc>
  800b55:	89 c3                	mov    %eax,%ebx
  800b57:	83 c4 10             	add    $0x10,%esp
  800b5a:	85 c0                	test   %eax,%eax
  800b5c:	78 19                	js     800b77 <open+0x75>
	return fd2num(fd);
  800b5e:	83 ec 0c             	sub    $0xc,%esp
  800b61:	ff 75 f4             	push   -0xc(%ebp)
  800b64:	e8 56 f8 ff ff       	call   8003bf <fd2num>
  800b69:	89 c3                	mov    %eax,%ebx
  800b6b:	83 c4 10             	add    $0x10,%esp
}
  800b6e:	89 d8                	mov    %ebx,%eax
  800b70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    
		fd_close(fd, 0);
  800b77:	83 ec 08             	sub    $0x8,%esp
  800b7a:	6a 00                	push   $0x0
  800b7c:	ff 75 f4             	push   -0xc(%ebp)
  800b7f:	e8 58 f9 ff ff       	call   8004dc <fd_close>
		return r;
  800b84:	83 c4 10             	add    $0x10,%esp
  800b87:	eb e5                	jmp    800b6e <open+0x6c>
		return -E_BAD_PATH;
  800b89:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b8e:	eb de                	jmp    800b6e <open+0x6c>

00800b90 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b96:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9b:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba0:	e8 a6 fd ff ff       	call   80094b <fsipc>
}
  800ba5:	c9                   	leave  
  800ba6:	c3                   	ret    

00800ba7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bad:	68 67 23 80 00       	push   $0x802367
  800bb2:	ff 75 0c             	push   0xc(%ebp)
  800bb5:	e8 c8 0f 00 00       	call   801b82 <strcpy>
	return 0;
}
  800bba:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbf:	c9                   	leave  
  800bc0:	c3                   	ret    

00800bc1 <devsock_close>:
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	53                   	push   %ebx
  800bc5:	83 ec 10             	sub    $0x10,%esp
  800bc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bcb:	53                   	push   %ebx
  800bcc:	e8 f4 13 00 00       	call   801fc5 <pageref>
  800bd1:	89 c2                	mov    %eax,%edx
  800bd3:	83 c4 10             	add    $0x10,%esp
		return 0;
  800bd6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800bdb:	83 fa 01             	cmp    $0x1,%edx
  800bde:	74 05                	je     800be5 <devsock_close+0x24>
}
  800be0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be3:	c9                   	leave  
  800be4:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	ff 73 0c             	push   0xc(%ebx)
  800beb:	e8 b7 02 00 00       	call   800ea7 <nsipc_close>
  800bf0:	83 c4 10             	add    $0x10,%esp
  800bf3:	eb eb                	jmp    800be0 <devsock_close+0x1f>

00800bf5 <devsock_write>:
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bfb:	6a 00                	push   $0x0
  800bfd:	ff 75 10             	push   0x10(%ebp)
  800c00:	ff 75 0c             	push   0xc(%ebp)
  800c03:	8b 45 08             	mov    0x8(%ebp),%eax
  800c06:	ff 70 0c             	push   0xc(%eax)
  800c09:	e8 79 03 00 00       	call   800f87 <nsipc_send>
}
  800c0e:	c9                   	leave  
  800c0f:	c3                   	ret    

00800c10 <devsock_read>:
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c16:	6a 00                	push   $0x0
  800c18:	ff 75 10             	push   0x10(%ebp)
  800c1b:	ff 75 0c             	push   0xc(%ebp)
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c21:	ff 70 0c             	push   0xc(%eax)
  800c24:	e8 ef 02 00 00       	call   800f18 <nsipc_recv>
}
  800c29:	c9                   	leave  
  800c2a:	c3                   	ret    

00800c2b <fd2sockid>:
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c31:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c34:	52                   	push   %edx
  800c35:	50                   	push   %eax
  800c36:	e8 fb f7 ff ff       	call   800436 <fd_lookup>
  800c3b:	83 c4 10             	add    $0x10,%esp
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	78 10                	js     800c52 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c45:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  800c4b:	39 08                	cmp    %ecx,(%eax)
  800c4d:	75 05                	jne    800c54 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c4f:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c52:	c9                   	leave  
  800c53:	c3                   	ret    
		return -E_NOT_SUPP;
  800c54:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c59:	eb f7                	jmp    800c52 <fd2sockid+0x27>

00800c5b <alloc_sockfd>:
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
  800c60:	83 ec 1c             	sub    $0x1c,%esp
  800c63:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c68:	50                   	push   %eax
  800c69:	e8 78 f7 ff ff       	call   8003e6 <fd_alloc>
  800c6e:	89 c3                	mov    %eax,%ebx
  800c70:	83 c4 10             	add    $0x10,%esp
  800c73:	85 c0                	test   %eax,%eax
  800c75:	78 43                	js     800cba <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c77:	83 ec 04             	sub    $0x4,%esp
  800c7a:	68 07 04 00 00       	push   $0x407
  800c7f:	ff 75 f4             	push   -0xc(%ebp)
  800c82:	6a 00                	push   $0x0
  800c84:	e8 e4 f4 ff ff       	call   80016d <sys_page_alloc>
  800c89:	89 c3                	mov    %eax,%ebx
  800c8b:	83 c4 10             	add    $0x10,%esp
  800c8e:	85 c0                	test   %eax,%eax
  800c90:	78 28                	js     800cba <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c95:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800c9b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800ca7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	50                   	push   %eax
  800cae:	e8 0c f7 ff ff       	call   8003bf <fd2num>
  800cb3:	89 c3                	mov    %eax,%ebx
  800cb5:	83 c4 10             	add    $0x10,%esp
  800cb8:	eb 0c                	jmp    800cc6 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800cba:	83 ec 0c             	sub    $0xc,%esp
  800cbd:	56                   	push   %esi
  800cbe:	e8 e4 01 00 00       	call   800ea7 <nsipc_close>
		return r;
  800cc3:	83 c4 10             	add    $0x10,%esp
}
  800cc6:	89 d8                	mov    %ebx,%eax
  800cc8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <accept>:
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd8:	e8 4e ff ff ff       	call   800c2b <fd2sockid>
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	78 1b                	js     800cfc <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ce1:	83 ec 04             	sub    $0x4,%esp
  800ce4:	ff 75 10             	push   0x10(%ebp)
  800ce7:	ff 75 0c             	push   0xc(%ebp)
  800cea:	50                   	push   %eax
  800ceb:	e8 0e 01 00 00       	call   800dfe <nsipc_accept>
  800cf0:	83 c4 10             	add    $0x10,%esp
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	78 05                	js     800cfc <accept+0x2d>
	return alloc_sockfd(r);
  800cf7:	e8 5f ff ff ff       	call   800c5b <alloc_sockfd>
}
  800cfc:	c9                   	leave  
  800cfd:	c3                   	ret    

00800cfe <bind>:
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d04:	8b 45 08             	mov    0x8(%ebp),%eax
  800d07:	e8 1f ff ff ff       	call   800c2b <fd2sockid>
  800d0c:	85 c0                	test   %eax,%eax
  800d0e:	78 12                	js     800d22 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  800d10:	83 ec 04             	sub    $0x4,%esp
  800d13:	ff 75 10             	push   0x10(%ebp)
  800d16:	ff 75 0c             	push   0xc(%ebp)
  800d19:	50                   	push   %eax
  800d1a:	e8 31 01 00 00       	call   800e50 <nsipc_bind>
  800d1f:	83 c4 10             	add    $0x10,%esp
}
  800d22:	c9                   	leave  
  800d23:	c3                   	ret    

00800d24 <shutdown>:
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2d:	e8 f9 fe ff ff       	call   800c2b <fd2sockid>
  800d32:	85 c0                	test   %eax,%eax
  800d34:	78 0f                	js     800d45 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  800d36:	83 ec 08             	sub    $0x8,%esp
  800d39:	ff 75 0c             	push   0xc(%ebp)
  800d3c:	50                   	push   %eax
  800d3d:	e8 43 01 00 00       	call   800e85 <nsipc_shutdown>
  800d42:	83 c4 10             	add    $0x10,%esp
}
  800d45:	c9                   	leave  
  800d46:	c3                   	ret    

00800d47 <connect>:
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d50:	e8 d6 fe ff ff       	call   800c2b <fd2sockid>
  800d55:	85 c0                	test   %eax,%eax
  800d57:	78 12                	js     800d6b <connect+0x24>
	return nsipc_connect(r, name, namelen);
  800d59:	83 ec 04             	sub    $0x4,%esp
  800d5c:	ff 75 10             	push   0x10(%ebp)
  800d5f:	ff 75 0c             	push   0xc(%ebp)
  800d62:	50                   	push   %eax
  800d63:	e8 59 01 00 00       	call   800ec1 <nsipc_connect>
  800d68:	83 c4 10             	add    $0x10,%esp
}
  800d6b:	c9                   	leave  
  800d6c:	c3                   	ret    

00800d6d <listen>:
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d73:	8b 45 08             	mov    0x8(%ebp),%eax
  800d76:	e8 b0 fe ff ff       	call   800c2b <fd2sockid>
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	78 0f                	js     800d8e <listen+0x21>
	return nsipc_listen(r, backlog);
  800d7f:	83 ec 08             	sub    $0x8,%esp
  800d82:	ff 75 0c             	push   0xc(%ebp)
  800d85:	50                   	push   %eax
  800d86:	e8 6b 01 00 00       	call   800ef6 <nsipc_listen>
  800d8b:	83 c4 10             	add    $0x10,%esp
}
  800d8e:	c9                   	leave  
  800d8f:	c3                   	ret    

00800d90 <socket>:

int
socket(int domain, int type, int protocol)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d96:	ff 75 10             	push   0x10(%ebp)
  800d99:	ff 75 0c             	push   0xc(%ebp)
  800d9c:	ff 75 08             	push   0x8(%ebp)
  800d9f:	e8 41 02 00 00       	call   800fe5 <nsipc_socket>
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	85 c0                	test   %eax,%eax
  800da9:	78 05                	js     800db0 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dab:	e8 ab fe ff ff       	call   800c5b <alloc_sockfd>
}
  800db0:	c9                   	leave  
  800db1:	c3                   	ret    

00800db2 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	53                   	push   %ebx
  800db6:	83 ec 04             	sub    $0x4,%esp
  800db9:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dbb:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  800dc2:	74 26                	je     800dea <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dc4:	6a 07                	push   $0x7
  800dc6:	68 00 70 80 00       	push   $0x807000
  800dcb:	53                   	push   %ebx
  800dcc:	ff 35 00 80 80 00    	push   0x808000
  800dd2:	e8 5b 11 00 00       	call   801f32 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dd7:	83 c4 0c             	add    $0xc,%esp
  800dda:	6a 00                	push   $0x0
  800ddc:	6a 00                	push   $0x0
  800dde:	6a 00                	push   $0x0
  800de0:	e8 dd 10 00 00       	call   801ec2 <ipc_recv>
}
  800de5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800de8:	c9                   	leave  
  800de9:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dea:	83 ec 0c             	sub    $0xc,%esp
  800ded:	6a 02                	push   $0x2
  800def:	e8 92 11 00 00       	call   801f86 <ipc_find_env>
  800df4:	a3 00 80 80 00       	mov    %eax,0x808000
  800df9:	83 c4 10             	add    $0x10,%esp
  800dfc:	eb c6                	jmp    800dc4 <nsipc+0x12>

00800dfe <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
  800e03:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e06:	8b 45 08             	mov    0x8(%ebp),%eax
  800e09:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e0e:	8b 06                	mov    (%esi),%eax
  800e10:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e15:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1a:	e8 93 ff ff ff       	call   800db2 <nsipc>
  800e1f:	89 c3                	mov    %eax,%ebx
  800e21:	85 c0                	test   %eax,%eax
  800e23:	79 09                	jns    800e2e <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800e25:	89 d8                	mov    %ebx,%eax
  800e27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e2a:	5b                   	pop    %ebx
  800e2b:	5e                   	pop    %esi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e2e:	83 ec 04             	sub    $0x4,%esp
  800e31:	ff 35 10 70 80 00    	push   0x807010
  800e37:	68 00 70 80 00       	push   $0x807000
  800e3c:	ff 75 0c             	push   0xc(%ebp)
  800e3f:	e8 d4 0e 00 00       	call   801d18 <memmove>
		*addrlen = ret->ret_addrlen;
  800e44:	a1 10 70 80 00       	mov    0x807010,%eax
  800e49:	89 06                	mov    %eax,(%esi)
  800e4b:	83 c4 10             	add    $0x10,%esp
	return r;
  800e4e:	eb d5                	jmp    800e25 <nsipc_accept+0x27>

00800e50 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	53                   	push   %ebx
  800e54:	83 ec 08             	sub    $0x8,%esp
  800e57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e62:	53                   	push   %ebx
  800e63:	ff 75 0c             	push   0xc(%ebp)
  800e66:	68 04 70 80 00       	push   $0x807004
  800e6b:	e8 a8 0e 00 00       	call   801d18 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e70:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  800e76:	b8 02 00 00 00       	mov    $0x2,%eax
  800e7b:	e8 32 ff ff ff       	call   800db2 <nsipc>
}
  800e80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e83:	c9                   	leave  
  800e84:	c3                   	ret    

00800e85 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  800e93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e96:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  800e9b:	b8 03 00 00 00       	mov    $0x3,%eax
  800ea0:	e8 0d ff ff ff       	call   800db2 <nsipc>
}
  800ea5:	c9                   	leave  
  800ea6:	c3                   	ret    

00800ea7 <nsipc_close>:

int
nsipc_close(int s)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ead:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb0:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  800eb5:	b8 04 00 00 00       	mov    $0x4,%eax
  800eba:	e8 f3 fe ff ff       	call   800db2 <nsipc>
}
  800ebf:	c9                   	leave  
  800ec0:	c3                   	ret    

00800ec1 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	53                   	push   %ebx
  800ec5:	83 ec 08             	sub    $0x8,%esp
  800ec8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ecb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ece:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ed3:	53                   	push   %ebx
  800ed4:	ff 75 0c             	push   0xc(%ebp)
  800ed7:	68 04 70 80 00       	push   $0x807004
  800edc:	e8 37 0e 00 00       	call   801d18 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ee1:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  800ee7:	b8 05 00 00 00       	mov    $0x5,%eax
  800eec:	e8 c1 fe ff ff       	call   800db2 <nsipc>
}
  800ef1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef4:	c9                   	leave  
  800ef5:	c3                   	ret    

00800ef6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800efc:	8b 45 08             	mov    0x8(%ebp),%eax
  800eff:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  800f04:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f07:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  800f0c:	b8 06 00 00 00       	mov    $0x6,%eax
  800f11:	e8 9c fe ff ff       	call   800db2 <nsipc>
}
  800f16:	c9                   	leave  
  800f17:	c3                   	ret    

00800f18 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	56                   	push   %esi
  800f1c:	53                   	push   %ebx
  800f1d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f20:	8b 45 08             	mov    0x8(%ebp),%eax
  800f23:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  800f28:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  800f2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f31:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f36:	b8 07 00 00 00       	mov    $0x7,%eax
  800f3b:	e8 72 fe ff ff       	call   800db2 <nsipc>
  800f40:	89 c3                	mov    %eax,%ebx
  800f42:	85 c0                	test   %eax,%eax
  800f44:	78 22                	js     800f68 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  800f46:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f4b:	39 c6                	cmp    %eax,%esi
  800f4d:	0f 4e c6             	cmovle %esi,%eax
  800f50:	39 c3                	cmp    %eax,%ebx
  800f52:	7f 1d                	jg     800f71 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f54:	83 ec 04             	sub    $0x4,%esp
  800f57:	53                   	push   %ebx
  800f58:	68 00 70 80 00       	push   $0x807000
  800f5d:	ff 75 0c             	push   0xc(%ebp)
  800f60:	e8 b3 0d 00 00       	call   801d18 <memmove>
  800f65:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f68:	89 d8                	mov    %ebx,%eax
  800f6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f6d:	5b                   	pop    %ebx
  800f6e:	5e                   	pop    %esi
  800f6f:	5d                   	pop    %ebp
  800f70:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f71:	68 73 23 80 00       	push   $0x802373
  800f76:	68 3b 23 80 00       	push   $0x80233b
  800f7b:	6a 62                	push   $0x62
  800f7d:	68 88 23 80 00       	push   $0x802388
  800f82:	e8 46 05 00 00       	call   8014cd <_panic>

00800f87 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	53                   	push   %ebx
  800f8b:	83 ec 04             	sub    $0x4,%esp
  800f8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f91:	8b 45 08             	mov    0x8(%ebp),%eax
  800f94:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  800f99:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f9f:	7f 2e                	jg     800fcf <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fa1:	83 ec 04             	sub    $0x4,%esp
  800fa4:	53                   	push   %ebx
  800fa5:	ff 75 0c             	push   0xc(%ebp)
  800fa8:	68 0c 70 80 00       	push   $0x80700c
  800fad:	e8 66 0d 00 00       	call   801d18 <memmove>
	nsipcbuf.send.req_size = size;
  800fb2:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  800fb8:	8b 45 14             	mov    0x14(%ebp),%eax
  800fbb:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  800fc0:	b8 08 00 00 00       	mov    $0x8,%eax
  800fc5:	e8 e8 fd ff ff       	call   800db2 <nsipc>
}
  800fca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    
	assert(size < 1600);
  800fcf:	68 94 23 80 00       	push   $0x802394
  800fd4:	68 3b 23 80 00       	push   $0x80233b
  800fd9:	6a 6d                	push   $0x6d
  800fdb:	68 88 23 80 00       	push   $0x802388
  800fe0:	e8 e8 04 00 00       	call   8014cd <_panic>

00800fe5 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800feb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fee:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  800ff3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff6:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  800ffb:	8b 45 10             	mov    0x10(%ebp),%eax
  800ffe:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801003:	b8 09 00 00 00       	mov    $0x9,%eax
  801008:	e8 a5 fd ff ff       	call   800db2 <nsipc>
}
  80100d:	c9                   	leave  
  80100e:	c3                   	ret    

0080100f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
  801012:	56                   	push   %esi
  801013:	53                   	push   %ebx
  801014:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	ff 75 08             	push   0x8(%ebp)
  80101d:	e8 ad f3 ff ff       	call   8003cf <fd2data>
  801022:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801024:	83 c4 08             	add    $0x8,%esp
  801027:	68 a0 23 80 00       	push   $0x8023a0
  80102c:	53                   	push   %ebx
  80102d:	e8 50 0b 00 00       	call   801b82 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801032:	8b 46 04             	mov    0x4(%esi),%eax
  801035:	2b 06                	sub    (%esi),%eax
  801037:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80103d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801044:	00 00 00 
	stat->st_dev = &devpipe;
  801047:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  80104e:	30 80 00 
	return 0;
}
  801051:	b8 00 00 00 00       	mov    $0x0,%eax
  801056:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801059:	5b                   	pop    %ebx
  80105a:	5e                   	pop    %esi
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	53                   	push   %ebx
  801061:	83 ec 0c             	sub    $0xc,%esp
  801064:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801067:	53                   	push   %ebx
  801068:	6a 00                	push   $0x0
  80106a:	e8 83 f1 ff ff       	call   8001f2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80106f:	89 1c 24             	mov    %ebx,(%esp)
  801072:	e8 58 f3 ff ff       	call   8003cf <fd2data>
  801077:	83 c4 08             	add    $0x8,%esp
  80107a:	50                   	push   %eax
  80107b:	6a 00                	push   $0x0
  80107d:	e8 70 f1 ff ff       	call   8001f2 <sys_page_unmap>
}
  801082:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801085:	c9                   	leave  
  801086:	c3                   	ret    

00801087 <_pipeisclosed>:
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	57                   	push   %edi
  80108b:	56                   	push   %esi
  80108c:	53                   	push   %ebx
  80108d:	83 ec 1c             	sub    $0x1c,%esp
  801090:	89 c7                	mov    %eax,%edi
  801092:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801094:	a1 00 40 80 00       	mov    0x804000,%eax
  801099:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	57                   	push   %edi
  8010a0:	e8 20 0f 00 00       	call   801fc5 <pageref>
  8010a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010a8:	89 34 24             	mov    %esi,(%esp)
  8010ab:	e8 15 0f 00 00       	call   801fc5 <pageref>
		nn = thisenv->env_runs;
  8010b0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8010b6:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  8010b9:	83 c4 10             	add    $0x10,%esp
  8010bc:	39 cb                	cmp    %ecx,%ebx
  8010be:	74 1b                	je     8010db <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010c0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010c3:	75 cf                	jne    801094 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010c5:	8b 42 68             	mov    0x68(%edx),%eax
  8010c8:	6a 01                	push   $0x1
  8010ca:	50                   	push   %eax
  8010cb:	53                   	push   %ebx
  8010cc:	68 a7 23 80 00       	push   $0x8023a7
  8010d1:	e8 d2 04 00 00       	call   8015a8 <cprintf>
  8010d6:	83 c4 10             	add    $0x10,%esp
  8010d9:	eb b9                	jmp    801094 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010db:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010de:	0f 94 c0             	sete   %al
  8010e1:	0f b6 c0             	movzbl %al,%eax
}
  8010e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e7:	5b                   	pop    %ebx
  8010e8:	5e                   	pop    %esi
  8010e9:	5f                   	pop    %edi
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    

008010ec <devpipe_write>:
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	57                   	push   %edi
  8010f0:	56                   	push   %esi
  8010f1:	53                   	push   %ebx
  8010f2:	83 ec 28             	sub    $0x28,%esp
  8010f5:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8010f8:	56                   	push   %esi
  8010f9:	e8 d1 f2 ff ff       	call   8003cf <fd2data>
  8010fe:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	bf 00 00 00 00       	mov    $0x0,%edi
  801108:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80110b:	75 09                	jne    801116 <devpipe_write+0x2a>
	return i;
  80110d:	89 f8                	mov    %edi,%eax
  80110f:	eb 23                	jmp    801134 <devpipe_write+0x48>
			sys_yield();
  801111:	e8 38 f0 ff ff       	call   80014e <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801116:	8b 43 04             	mov    0x4(%ebx),%eax
  801119:	8b 0b                	mov    (%ebx),%ecx
  80111b:	8d 51 20             	lea    0x20(%ecx),%edx
  80111e:	39 d0                	cmp    %edx,%eax
  801120:	72 1a                	jb     80113c <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801122:	89 da                	mov    %ebx,%edx
  801124:	89 f0                	mov    %esi,%eax
  801126:	e8 5c ff ff ff       	call   801087 <_pipeisclosed>
  80112b:	85 c0                	test   %eax,%eax
  80112d:	74 e2                	je     801111 <devpipe_write+0x25>
				return 0;
  80112f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801134:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801137:	5b                   	pop    %ebx
  801138:	5e                   	pop    %esi
  801139:	5f                   	pop    %edi
  80113a:	5d                   	pop    %ebp
  80113b:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80113c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801143:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801146:	89 c2                	mov    %eax,%edx
  801148:	c1 fa 1f             	sar    $0x1f,%edx
  80114b:	89 d1                	mov    %edx,%ecx
  80114d:	c1 e9 1b             	shr    $0x1b,%ecx
  801150:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801153:	83 e2 1f             	and    $0x1f,%edx
  801156:	29 ca                	sub    %ecx,%edx
  801158:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80115c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801160:	83 c0 01             	add    $0x1,%eax
  801163:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801166:	83 c7 01             	add    $0x1,%edi
  801169:	eb 9d                	jmp    801108 <devpipe_write+0x1c>

0080116b <devpipe_read>:
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	57                   	push   %edi
  80116f:	56                   	push   %esi
  801170:	53                   	push   %ebx
  801171:	83 ec 18             	sub    $0x18,%esp
  801174:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801177:	57                   	push   %edi
  801178:	e8 52 f2 ff ff       	call   8003cf <fd2data>
  80117d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80117f:	83 c4 10             	add    $0x10,%esp
  801182:	be 00 00 00 00       	mov    $0x0,%esi
  801187:	3b 75 10             	cmp    0x10(%ebp),%esi
  80118a:	75 13                	jne    80119f <devpipe_read+0x34>
	return i;
  80118c:	89 f0                	mov    %esi,%eax
  80118e:	eb 02                	jmp    801192 <devpipe_read+0x27>
				return i;
  801190:	89 f0                	mov    %esi,%eax
}
  801192:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801195:	5b                   	pop    %ebx
  801196:	5e                   	pop    %esi
  801197:	5f                   	pop    %edi
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    
			sys_yield();
  80119a:	e8 af ef ff ff       	call   80014e <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80119f:	8b 03                	mov    (%ebx),%eax
  8011a1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8011a4:	75 18                	jne    8011be <devpipe_read+0x53>
			if (i > 0)
  8011a6:	85 f6                	test   %esi,%esi
  8011a8:	75 e6                	jne    801190 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8011aa:	89 da                	mov    %ebx,%edx
  8011ac:	89 f8                	mov    %edi,%eax
  8011ae:	e8 d4 fe ff ff       	call   801087 <_pipeisclosed>
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	74 e3                	je     80119a <devpipe_read+0x2f>
				return 0;
  8011b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011bc:	eb d4                	jmp    801192 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011be:	99                   	cltd   
  8011bf:	c1 ea 1b             	shr    $0x1b,%edx
  8011c2:	01 d0                	add    %edx,%eax
  8011c4:	83 e0 1f             	and    $0x1f,%eax
  8011c7:	29 d0                	sub    %edx,%eax
  8011c9:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d1:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011d4:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011d7:	83 c6 01             	add    $0x1,%esi
  8011da:	eb ab                	jmp    801187 <devpipe_read+0x1c>

008011dc <pipe>:
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	56                   	push   %esi
  8011e0:	53                   	push   %ebx
  8011e1:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e7:	50                   	push   %eax
  8011e8:	e8 f9 f1 ff ff       	call   8003e6 <fd_alloc>
  8011ed:	89 c3                	mov    %eax,%ebx
  8011ef:	83 c4 10             	add    $0x10,%esp
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	0f 88 23 01 00 00    	js     80131d <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011fa:	83 ec 04             	sub    $0x4,%esp
  8011fd:	68 07 04 00 00       	push   $0x407
  801202:	ff 75 f4             	push   -0xc(%ebp)
  801205:	6a 00                	push   $0x0
  801207:	e8 61 ef ff ff       	call   80016d <sys_page_alloc>
  80120c:	89 c3                	mov    %eax,%ebx
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	85 c0                	test   %eax,%eax
  801213:	0f 88 04 01 00 00    	js     80131d <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801219:	83 ec 0c             	sub    $0xc,%esp
  80121c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121f:	50                   	push   %eax
  801220:	e8 c1 f1 ff ff       	call   8003e6 <fd_alloc>
  801225:	89 c3                	mov    %eax,%ebx
  801227:	83 c4 10             	add    $0x10,%esp
  80122a:	85 c0                	test   %eax,%eax
  80122c:	0f 88 db 00 00 00    	js     80130d <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801232:	83 ec 04             	sub    $0x4,%esp
  801235:	68 07 04 00 00       	push   $0x407
  80123a:	ff 75 f0             	push   -0x10(%ebp)
  80123d:	6a 00                	push   $0x0
  80123f:	e8 29 ef ff ff       	call   80016d <sys_page_alloc>
  801244:	89 c3                	mov    %eax,%ebx
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	85 c0                	test   %eax,%eax
  80124b:	0f 88 bc 00 00 00    	js     80130d <pipe+0x131>
	va = fd2data(fd0);
  801251:	83 ec 0c             	sub    $0xc,%esp
  801254:	ff 75 f4             	push   -0xc(%ebp)
  801257:	e8 73 f1 ff ff       	call   8003cf <fd2data>
  80125c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80125e:	83 c4 0c             	add    $0xc,%esp
  801261:	68 07 04 00 00       	push   $0x407
  801266:	50                   	push   %eax
  801267:	6a 00                	push   $0x0
  801269:	e8 ff ee ff ff       	call   80016d <sys_page_alloc>
  80126e:	89 c3                	mov    %eax,%ebx
  801270:	83 c4 10             	add    $0x10,%esp
  801273:	85 c0                	test   %eax,%eax
  801275:	0f 88 82 00 00 00    	js     8012fd <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80127b:	83 ec 0c             	sub    $0xc,%esp
  80127e:	ff 75 f0             	push   -0x10(%ebp)
  801281:	e8 49 f1 ff ff       	call   8003cf <fd2data>
  801286:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80128d:	50                   	push   %eax
  80128e:	6a 00                	push   $0x0
  801290:	56                   	push   %esi
  801291:	6a 00                	push   $0x0
  801293:	e8 18 ef ff ff       	call   8001b0 <sys_page_map>
  801298:	89 c3                	mov    %eax,%ebx
  80129a:	83 c4 20             	add    $0x20,%esp
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 4e                	js     8012ef <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8012a1:	a1 40 30 80 00       	mov    0x803040,%eax
  8012a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a9:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8012ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ae:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012b8:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012c4:	83 ec 0c             	sub    $0xc,%esp
  8012c7:	ff 75 f4             	push   -0xc(%ebp)
  8012ca:	e8 f0 f0 ff ff       	call   8003bf <fd2num>
  8012cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012d4:	83 c4 04             	add    $0x4,%esp
  8012d7:	ff 75 f0             	push   -0x10(%ebp)
  8012da:	e8 e0 f0 ff ff       	call   8003bf <fd2num>
  8012df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012e5:	83 c4 10             	add    $0x10,%esp
  8012e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ed:	eb 2e                	jmp    80131d <pipe+0x141>
	sys_page_unmap(0, va);
  8012ef:	83 ec 08             	sub    $0x8,%esp
  8012f2:	56                   	push   %esi
  8012f3:	6a 00                	push   $0x0
  8012f5:	e8 f8 ee ff ff       	call   8001f2 <sys_page_unmap>
  8012fa:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8012fd:	83 ec 08             	sub    $0x8,%esp
  801300:	ff 75 f0             	push   -0x10(%ebp)
  801303:	6a 00                	push   $0x0
  801305:	e8 e8 ee ff ff       	call   8001f2 <sys_page_unmap>
  80130a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80130d:	83 ec 08             	sub    $0x8,%esp
  801310:	ff 75 f4             	push   -0xc(%ebp)
  801313:	6a 00                	push   $0x0
  801315:	e8 d8 ee ff ff       	call   8001f2 <sys_page_unmap>
  80131a:	83 c4 10             	add    $0x10,%esp
}
  80131d:	89 d8                	mov    %ebx,%eax
  80131f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801322:	5b                   	pop    %ebx
  801323:	5e                   	pop    %esi
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    

00801326 <pipeisclosed>:
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80132c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132f:	50                   	push   %eax
  801330:	ff 75 08             	push   0x8(%ebp)
  801333:	e8 fe f0 ff ff       	call   800436 <fd_lookup>
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	85 c0                	test   %eax,%eax
  80133d:	78 18                	js     801357 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80133f:	83 ec 0c             	sub    $0xc,%esp
  801342:	ff 75 f4             	push   -0xc(%ebp)
  801345:	e8 85 f0 ff ff       	call   8003cf <fd2data>
  80134a:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80134c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134f:	e8 33 fd ff ff       	call   801087 <_pipeisclosed>
  801354:	83 c4 10             	add    $0x10,%esp
}
  801357:	c9                   	leave  
  801358:	c3                   	ret    

00801359 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801359:	b8 00 00 00 00       	mov    $0x0,%eax
  80135e:	c3                   	ret    

0080135f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80135f:	55                   	push   %ebp
  801360:	89 e5                	mov    %esp,%ebp
  801362:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801365:	68 bf 23 80 00       	push   $0x8023bf
  80136a:	ff 75 0c             	push   0xc(%ebp)
  80136d:	e8 10 08 00 00       	call   801b82 <strcpy>
	return 0;
}
  801372:	b8 00 00 00 00       	mov    $0x0,%eax
  801377:	c9                   	leave  
  801378:	c3                   	ret    

00801379 <devcons_write>:
{
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
  80137c:	57                   	push   %edi
  80137d:	56                   	push   %esi
  80137e:	53                   	push   %ebx
  80137f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801385:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80138a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801390:	eb 2e                	jmp    8013c0 <devcons_write+0x47>
		m = n - tot;
  801392:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801395:	29 f3                	sub    %esi,%ebx
  801397:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80139c:	39 c3                	cmp    %eax,%ebx
  80139e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8013a1:	83 ec 04             	sub    $0x4,%esp
  8013a4:	53                   	push   %ebx
  8013a5:	89 f0                	mov    %esi,%eax
  8013a7:	03 45 0c             	add    0xc(%ebp),%eax
  8013aa:	50                   	push   %eax
  8013ab:	57                   	push   %edi
  8013ac:	e8 67 09 00 00       	call   801d18 <memmove>
		sys_cputs(buf, m);
  8013b1:	83 c4 08             	add    $0x8,%esp
  8013b4:	53                   	push   %ebx
  8013b5:	57                   	push   %edi
  8013b6:	e8 f6 ec ff ff       	call   8000b1 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013bb:	01 de                	add    %ebx,%esi
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013c3:	72 cd                	jb     801392 <devcons_write+0x19>
}
  8013c5:	89 f0                	mov    %esi,%eax
  8013c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ca:	5b                   	pop    %ebx
  8013cb:	5e                   	pop    %esi
  8013cc:	5f                   	pop    %edi
  8013cd:	5d                   	pop    %ebp
  8013ce:	c3                   	ret    

008013cf <devcons_read>:
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	83 ec 08             	sub    $0x8,%esp
  8013d5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013de:	75 07                	jne    8013e7 <devcons_read+0x18>
  8013e0:	eb 1f                	jmp    801401 <devcons_read+0x32>
		sys_yield();
  8013e2:	e8 67 ed ff ff       	call   80014e <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8013e7:	e8 e3 ec ff ff       	call   8000cf <sys_cgetc>
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	74 f2                	je     8013e2 <devcons_read+0x13>
	if (c < 0)
  8013f0:	78 0f                	js     801401 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8013f2:	83 f8 04             	cmp    $0x4,%eax
  8013f5:	74 0c                	je     801403 <devcons_read+0x34>
	*(char*)vbuf = c;
  8013f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013fa:	88 02                	mov    %al,(%edx)
	return 1;
  8013fc:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801401:	c9                   	leave  
  801402:	c3                   	ret    
		return 0;
  801403:	b8 00 00 00 00       	mov    $0x0,%eax
  801408:	eb f7                	jmp    801401 <devcons_read+0x32>

0080140a <cputchar>:
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801410:	8b 45 08             	mov    0x8(%ebp),%eax
  801413:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801416:	6a 01                	push   $0x1
  801418:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80141b:	50                   	push   %eax
  80141c:	e8 90 ec ff ff       	call   8000b1 <sys_cputs>
}
  801421:	83 c4 10             	add    $0x10,%esp
  801424:	c9                   	leave  
  801425:	c3                   	ret    

00801426 <getchar>:
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80142c:	6a 01                	push   $0x1
  80142e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801431:	50                   	push   %eax
  801432:	6a 00                	push   $0x0
  801434:	e8 66 f2 ff ff       	call   80069f <read>
	if (r < 0)
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 06                	js     801446 <getchar+0x20>
	if (r < 1)
  801440:	74 06                	je     801448 <getchar+0x22>
	return c;
  801442:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801446:	c9                   	leave  
  801447:	c3                   	ret    
		return -E_EOF;
  801448:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80144d:	eb f7                	jmp    801446 <getchar+0x20>

0080144f <iscons>:
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801455:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801458:	50                   	push   %eax
  801459:	ff 75 08             	push   0x8(%ebp)
  80145c:	e8 d5 ef ff ff       	call   800436 <fd_lookup>
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	85 c0                	test   %eax,%eax
  801466:	78 11                	js     801479 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146b:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  801471:	39 10                	cmp    %edx,(%eax)
  801473:	0f 94 c0             	sete   %al
  801476:	0f b6 c0             	movzbl %al,%eax
}
  801479:	c9                   	leave  
  80147a:	c3                   	ret    

0080147b <opencons>:
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801484:	50                   	push   %eax
  801485:	e8 5c ef ff ff       	call   8003e6 <fd_alloc>
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	85 c0                	test   %eax,%eax
  80148f:	78 3a                	js     8014cb <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801491:	83 ec 04             	sub    $0x4,%esp
  801494:	68 07 04 00 00       	push   $0x407
  801499:	ff 75 f4             	push   -0xc(%ebp)
  80149c:	6a 00                	push   $0x0
  80149e:	e8 ca ec ff ff       	call   80016d <sys_page_alloc>
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 21                	js     8014cb <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8014aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ad:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8014b3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014bf:	83 ec 0c             	sub    $0xc,%esp
  8014c2:	50                   	push   %eax
  8014c3:	e8 f7 ee ff ff       	call   8003bf <fd2num>
  8014c8:	83 c4 10             	add    $0x10,%esp
}
  8014cb:	c9                   	leave  
  8014cc:	c3                   	ret    

008014cd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	56                   	push   %esi
  8014d1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014d2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014d5:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8014db:	e8 4f ec ff ff       	call   80012f <sys_getenvid>
  8014e0:	83 ec 0c             	sub    $0xc,%esp
  8014e3:	ff 75 0c             	push   0xc(%ebp)
  8014e6:	ff 75 08             	push   0x8(%ebp)
  8014e9:	56                   	push   %esi
  8014ea:	50                   	push   %eax
  8014eb:	68 cc 23 80 00       	push   $0x8023cc
  8014f0:	e8 b3 00 00 00       	call   8015a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014f5:	83 c4 18             	add    $0x18,%esp
  8014f8:	53                   	push   %ebx
  8014f9:	ff 75 10             	push   0x10(%ebp)
  8014fc:	e8 56 00 00 00       	call   801557 <vcprintf>
	cprintf("\n");
  801501:	c7 04 24 b8 23 80 00 	movl   $0x8023b8,(%esp)
  801508:	e8 9b 00 00 00       	call   8015a8 <cprintf>
  80150d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801510:	cc                   	int3   
  801511:	eb fd                	jmp    801510 <_panic+0x43>

00801513 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801513:	55                   	push   %ebp
  801514:	89 e5                	mov    %esp,%ebp
  801516:	53                   	push   %ebx
  801517:	83 ec 04             	sub    $0x4,%esp
  80151a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80151d:	8b 13                	mov    (%ebx),%edx
  80151f:	8d 42 01             	lea    0x1(%edx),%eax
  801522:	89 03                	mov    %eax,(%ebx)
  801524:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801527:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80152b:	3d ff 00 00 00       	cmp    $0xff,%eax
  801530:	74 09                	je     80153b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801532:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801536:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801539:	c9                   	leave  
  80153a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80153b:	83 ec 08             	sub    $0x8,%esp
  80153e:	68 ff 00 00 00       	push   $0xff
  801543:	8d 43 08             	lea    0x8(%ebx),%eax
  801546:	50                   	push   %eax
  801547:	e8 65 eb ff ff       	call   8000b1 <sys_cputs>
		b->idx = 0;
  80154c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	eb db                	jmp    801532 <putch+0x1f>

00801557 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801560:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801567:	00 00 00 
	b.cnt = 0;
  80156a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801571:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801574:	ff 75 0c             	push   0xc(%ebp)
  801577:	ff 75 08             	push   0x8(%ebp)
  80157a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801580:	50                   	push   %eax
  801581:	68 13 15 80 00       	push   $0x801513
  801586:	e8 14 01 00 00       	call   80169f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80158b:	83 c4 08             	add    $0x8,%esp
  80158e:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  801594:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80159a:	50                   	push   %eax
  80159b:	e8 11 eb ff ff       	call   8000b1 <sys_cputs>

	return b.cnt;
}
  8015a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015a6:	c9                   	leave  
  8015a7:	c3                   	ret    

008015a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015b1:	50                   	push   %eax
  8015b2:	ff 75 08             	push   0x8(%ebp)
  8015b5:	e8 9d ff ff ff       	call   801557 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015ba:	c9                   	leave  
  8015bb:	c3                   	ret    

008015bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	57                   	push   %edi
  8015c0:	56                   	push   %esi
  8015c1:	53                   	push   %ebx
  8015c2:	83 ec 1c             	sub    $0x1c,%esp
  8015c5:	89 c7                	mov    %eax,%edi
  8015c7:	89 d6                	mov    %edx,%esi
  8015c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015cf:	89 d1                	mov    %edx,%ecx
  8015d1:	89 c2                	mov    %eax,%edx
  8015d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015d6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8015dc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015df:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015e2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8015e9:	39 c2                	cmp    %eax,%edx
  8015eb:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8015ee:	72 3e                	jb     80162e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015f0:	83 ec 0c             	sub    $0xc,%esp
  8015f3:	ff 75 18             	push   0x18(%ebp)
  8015f6:	83 eb 01             	sub    $0x1,%ebx
  8015f9:	53                   	push   %ebx
  8015fa:	50                   	push   %eax
  8015fb:	83 ec 08             	sub    $0x8,%esp
  8015fe:	ff 75 e4             	push   -0x1c(%ebp)
  801601:	ff 75 e0             	push   -0x20(%ebp)
  801604:	ff 75 dc             	push   -0x24(%ebp)
  801607:	ff 75 d8             	push   -0x28(%ebp)
  80160a:	e8 01 0a 00 00       	call   802010 <__udivdi3>
  80160f:	83 c4 18             	add    $0x18,%esp
  801612:	52                   	push   %edx
  801613:	50                   	push   %eax
  801614:	89 f2                	mov    %esi,%edx
  801616:	89 f8                	mov    %edi,%eax
  801618:	e8 9f ff ff ff       	call   8015bc <printnum>
  80161d:	83 c4 20             	add    $0x20,%esp
  801620:	eb 13                	jmp    801635 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801622:	83 ec 08             	sub    $0x8,%esp
  801625:	56                   	push   %esi
  801626:	ff 75 18             	push   0x18(%ebp)
  801629:	ff d7                	call   *%edi
  80162b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80162e:	83 eb 01             	sub    $0x1,%ebx
  801631:	85 db                	test   %ebx,%ebx
  801633:	7f ed                	jg     801622 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801635:	83 ec 08             	sub    $0x8,%esp
  801638:	56                   	push   %esi
  801639:	83 ec 04             	sub    $0x4,%esp
  80163c:	ff 75 e4             	push   -0x1c(%ebp)
  80163f:	ff 75 e0             	push   -0x20(%ebp)
  801642:	ff 75 dc             	push   -0x24(%ebp)
  801645:	ff 75 d8             	push   -0x28(%ebp)
  801648:	e8 e3 0a 00 00       	call   802130 <__umoddi3>
  80164d:	83 c4 14             	add    $0x14,%esp
  801650:	0f be 80 ef 23 80 00 	movsbl 0x8023ef(%eax),%eax
  801657:	50                   	push   %eax
  801658:	ff d7                	call   *%edi
}
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801660:	5b                   	pop    %ebx
  801661:	5e                   	pop    %esi
  801662:	5f                   	pop    %edi
  801663:	5d                   	pop    %ebp
  801664:	c3                   	ret    

00801665 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80166b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80166f:	8b 10                	mov    (%eax),%edx
  801671:	3b 50 04             	cmp    0x4(%eax),%edx
  801674:	73 0a                	jae    801680 <sprintputch+0x1b>
		*b->buf++ = ch;
  801676:	8d 4a 01             	lea    0x1(%edx),%ecx
  801679:	89 08                	mov    %ecx,(%eax)
  80167b:	8b 45 08             	mov    0x8(%ebp),%eax
  80167e:	88 02                	mov    %al,(%edx)
}
  801680:	5d                   	pop    %ebp
  801681:	c3                   	ret    

00801682 <printfmt>:
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801688:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80168b:	50                   	push   %eax
  80168c:	ff 75 10             	push   0x10(%ebp)
  80168f:	ff 75 0c             	push   0xc(%ebp)
  801692:	ff 75 08             	push   0x8(%ebp)
  801695:	e8 05 00 00 00       	call   80169f <vprintfmt>
}
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	c9                   	leave  
  80169e:	c3                   	ret    

0080169f <vprintfmt>:
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	57                   	push   %edi
  8016a3:	56                   	push   %esi
  8016a4:	53                   	push   %ebx
  8016a5:	83 ec 3c             	sub    $0x3c,%esp
  8016a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016ae:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016b1:	eb 0a                	jmp    8016bd <vprintfmt+0x1e>
			putch(ch, putdat);
  8016b3:	83 ec 08             	sub    $0x8,%esp
  8016b6:	53                   	push   %ebx
  8016b7:	50                   	push   %eax
  8016b8:	ff d6                	call   *%esi
  8016ba:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016bd:	83 c7 01             	add    $0x1,%edi
  8016c0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016c4:	83 f8 25             	cmp    $0x25,%eax
  8016c7:	74 0c                	je     8016d5 <vprintfmt+0x36>
			if (ch == '\0')
  8016c9:	85 c0                	test   %eax,%eax
  8016cb:	75 e6                	jne    8016b3 <vprintfmt+0x14>
}
  8016cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016d0:	5b                   	pop    %ebx
  8016d1:	5e                   	pop    %esi
  8016d2:	5f                   	pop    %edi
  8016d3:	5d                   	pop    %ebp
  8016d4:	c3                   	ret    
		padc = ' ';
  8016d5:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8016d9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8016e0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8016e7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8016ee:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8016f3:	8d 47 01             	lea    0x1(%edi),%eax
  8016f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016f9:	0f b6 17             	movzbl (%edi),%edx
  8016fc:	8d 42 dd             	lea    -0x23(%edx),%eax
  8016ff:	3c 55                	cmp    $0x55,%al
  801701:	0f 87 bb 03 00 00    	ja     801ac2 <vprintfmt+0x423>
  801707:	0f b6 c0             	movzbl %al,%eax
  80170a:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  801711:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801714:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801718:	eb d9                	jmp    8016f3 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80171a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80171d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801721:	eb d0                	jmp    8016f3 <vprintfmt+0x54>
  801723:	0f b6 d2             	movzbl %dl,%edx
  801726:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801729:	b8 00 00 00 00       	mov    $0x0,%eax
  80172e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801731:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801734:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801738:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80173b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80173e:	83 f9 09             	cmp    $0x9,%ecx
  801741:	77 55                	ja     801798 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  801743:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801746:	eb e9                	jmp    801731 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801748:	8b 45 14             	mov    0x14(%ebp),%eax
  80174b:	8b 00                	mov    (%eax),%eax
  80174d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801750:	8b 45 14             	mov    0x14(%ebp),%eax
  801753:	8d 40 04             	lea    0x4(%eax),%eax
  801756:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801759:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80175c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801760:	79 91                	jns    8016f3 <vprintfmt+0x54>
				width = precision, precision = -1;
  801762:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801765:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801768:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80176f:	eb 82                	jmp    8016f3 <vprintfmt+0x54>
  801771:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801774:	85 d2                	test   %edx,%edx
  801776:	b8 00 00 00 00       	mov    $0x0,%eax
  80177b:	0f 49 c2             	cmovns %edx,%eax
  80177e:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801781:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801784:	e9 6a ff ff ff       	jmp    8016f3 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801789:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80178c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801793:	e9 5b ff ff ff       	jmp    8016f3 <vprintfmt+0x54>
  801798:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80179b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80179e:	eb bc                	jmp    80175c <vprintfmt+0xbd>
			lflag++;
  8017a0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8017a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017a6:	e9 48 ff ff ff       	jmp    8016f3 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8017ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ae:	8d 78 04             	lea    0x4(%eax),%edi
  8017b1:	83 ec 08             	sub    $0x8,%esp
  8017b4:	53                   	push   %ebx
  8017b5:	ff 30                	push   (%eax)
  8017b7:	ff d6                	call   *%esi
			break;
  8017b9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017bc:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017bf:	e9 9d 02 00 00       	jmp    801a61 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8017c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8017c7:	8d 78 04             	lea    0x4(%eax),%edi
  8017ca:	8b 10                	mov    (%eax),%edx
  8017cc:	89 d0                	mov    %edx,%eax
  8017ce:	f7 d8                	neg    %eax
  8017d0:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017d3:	83 f8 0f             	cmp    $0xf,%eax
  8017d6:	7f 23                	jg     8017fb <vprintfmt+0x15c>
  8017d8:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  8017df:	85 d2                	test   %edx,%edx
  8017e1:	74 18                	je     8017fb <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8017e3:	52                   	push   %edx
  8017e4:	68 4d 23 80 00       	push   $0x80234d
  8017e9:	53                   	push   %ebx
  8017ea:	56                   	push   %esi
  8017eb:	e8 92 fe ff ff       	call   801682 <printfmt>
  8017f0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017f3:	89 7d 14             	mov    %edi,0x14(%ebp)
  8017f6:	e9 66 02 00 00       	jmp    801a61 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8017fb:	50                   	push   %eax
  8017fc:	68 07 24 80 00       	push   $0x802407
  801801:	53                   	push   %ebx
  801802:	56                   	push   %esi
  801803:	e8 7a fe ff ff       	call   801682 <printfmt>
  801808:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80180b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80180e:	e9 4e 02 00 00       	jmp    801a61 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  801813:	8b 45 14             	mov    0x14(%ebp),%eax
  801816:	83 c0 04             	add    $0x4,%eax
  801819:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80181c:	8b 45 14             	mov    0x14(%ebp),%eax
  80181f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801821:	85 d2                	test   %edx,%edx
  801823:	b8 00 24 80 00       	mov    $0x802400,%eax
  801828:	0f 45 c2             	cmovne %edx,%eax
  80182b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80182e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801832:	7e 06                	jle    80183a <vprintfmt+0x19b>
  801834:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801838:	75 0d                	jne    801847 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80183a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80183d:	89 c7                	mov    %eax,%edi
  80183f:	03 45 e0             	add    -0x20(%ebp),%eax
  801842:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801845:	eb 55                	jmp    80189c <vprintfmt+0x1fd>
  801847:	83 ec 08             	sub    $0x8,%esp
  80184a:	ff 75 d8             	push   -0x28(%ebp)
  80184d:	ff 75 cc             	push   -0x34(%ebp)
  801850:	e8 0a 03 00 00       	call   801b5f <strnlen>
  801855:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801858:	29 c1                	sub    %eax,%ecx
  80185a:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80185d:	83 c4 10             	add    $0x10,%esp
  801860:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  801862:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801866:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801869:	eb 0f                	jmp    80187a <vprintfmt+0x1db>
					putch(padc, putdat);
  80186b:	83 ec 08             	sub    $0x8,%esp
  80186e:	53                   	push   %ebx
  80186f:	ff 75 e0             	push   -0x20(%ebp)
  801872:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801874:	83 ef 01             	sub    $0x1,%edi
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	85 ff                	test   %edi,%edi
  80187c:	7f ed                	jg     80186b <vprintfmt+0x1cc>
  80187e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801881:	85 d2                	test   %edx,%edx
  801883:	b8 00 00 00 00       	mov    $0x0,%eax
  801888:	0f 49 c2             	cmovns %edx,%eax
  80188b:	29 c2                	sub    %eax,%edx
  80188d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801890:	eb a8                	jmp    80183a <vprintfmt+0x19b>
					putch(ch, putdat);
  801892:	83 ec 08             	sub    $0x8,%esp
  801895:	53                   	push   %ebx
  801896:	52                   	push   %edx
  801897:	ff d6                	call   *%esi
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80189f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018a1:	83 c7 01             	add    $0x1,%edi
  8018a4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018a8:	0f be d0             	movsbl %al,%edx
  8018ab:	85 d2                	test   %edx,%edx
  8018ad:	74 4b                	je     8018fa <vprintfmt+0x25b>
  8018af:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018b3:	78 06                	js     8018bb <vprintfmt+0x21c>
  8018b5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018b9:	78 1e                	js     8018d9 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8018bb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018bf:	74 d1                	je     801892 <vprintfmt+0x1f3>
  8018c1:	0f be c0             	movsbl %al,%eax
  8018c4:	83 e8 20             	sub    $0x20,%eax
  8018c7:	83 f8 5e             	cmp    $0x5e,%eax
  8018ca:	76 c6                	jbe    801892 <vprintfmt+0x1f3>
					putch('?', putdat);
  8018cc:	83 ec 08             	sub    $0x8,%esp
  8018cf:	53                   	push   %ebx
  8018d0:	6a 3f                	push   $0x3f
  8018d2:	ff d6                	call   *%esi
  8018d4:	83 c4 10             	add    $0x10,%esp
  8018d7:	eb c3                	jmp    80189c <vprintfmt+0x1fd>
  8018d9:	89 cf                	mov    %ecx,%edi
  8018db:	eb 0e                	jmp    8018eb <vprintfmt+0x24c>
				putch(' ', putdat);
  8018dd:	83 ec 08             	sub    $0x8,%esp
  8018e0:	53                   	push   %ebx
  8018e1:	6a 20                	push   $0x20
  8018e3:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8018e5:	83 ef 01             	sub    $0x1,%edi
  8018e8:	83 c4 10             	add    $0x10,%esp
  8018eb:	85 ff                	test   %edi,%edi
  8018ed:	7f ee                	jg     8018dd <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8018ef:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8018f2:	89 45 14             	mov    %eax,0x14(%ebp)
  8018f5:	e9 67 01 00 00       	jmp    801a61 <vprintfmt+0x3c2>
  8018fa:	89 cf                	mov    %ecx,%edi
  8018fc:	eb ed                	jmp    8018eb <vprintfmt+0x24c>
	if (lflag >= 2)
  8018fe:	83 f9 01             	cmp    $0x1,%ecx
  801901:	7f 1b                	jg     80191e <vprintfmt+0x27f>
	else if (lflag)
  801903:	85 c9                	test   %ecx,%ecx
  801905:	74 63                	je     80196a <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  801907:	8b 45 14             	mov    0x14(%ebp),%eax
  80190a:	8b 00                	mov    (%eax),%eax
  80190c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80190f:	99                   	cltd   
  801910:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801913:	8b 45 14             	mov    0x14(%ebp),%eax
  801916:	8d 40 04             	lea    0x4(%eax),%eax
  801919:	89 45 14             	mov    %eax,0x14(%ebp)
  80191c:	eb 17                	jmp    801935 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80191e:	8b 45 14             	mov    0x14(%ebp),%eax
  801921:	8b 50 04             	mov    0x4(%eax),%edx
  801924:	8b 00                	mov    (%eax),%eax
  801926:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801929:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80192c:	8b 45 14             	mov    0x14(%ebp),%eax
  80192f:	8d 40 08             	lea    0x8(%eax),%eax
  801932:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801935:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801938:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80193b:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801940:	85 c9                	test   %ecx,%ecx
  801942:	0f 89 ff 00 00 00    	jns    801a47 <vprintfmt+0x3a8>
				putch('-', putdat);
  801948:	83 ec 08             	sub    $0x8,%esp
  80194b:	53                   	push   %ebx
  80194c:	6a 2d                	push   $0x2d
  80194e:	ff d6                	call   *%esi
				num = -(long long) num;
  801950:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801953:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801956:	f7 da                	neg    %edx
  801958:	83 d1 00             	adc    $0x0,%ecx
  80195b:	f7 d9                	neg    %ecx
  80195d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801960:	bf 0a 00 00 00       	mov    $0xa,%edi
  801965:	e9 dd 00 00 00       	jmp    801a47 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80196a:	8b 45 14             	mov    0x14(%ebp),%eax
  80196d:	8b 00                	mov    (%eax),%eax
  80196f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801972:	99                   	cltd   
  801973:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801976:	8b 45 14             	mov    0x14(%ebp),%eax
  801979:	8d 40 04             	lea    0x4(%eax),%eax
  80197c:	89 45 14             	mov    %eax,0x14(%ebp)
  80197f:	eb b4                	jmp    801935 <vprintfmt+0x296>
	if (lflag >= 2)
  801981:	83 f9 01             	cmp    $0x1,%ecx
  801984:	7f 1e                	jg     8019a4 <vprintfmt+0x305>
	else if (lflag)
  801986:	85 c9                	test   %ecx,%ecx
  801988:	74 32                	je     8019bc <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80198a:	8b 45 14             	mov    0x14(%ebp),%eax
  80198d:	8b 10                	mov    (%eax),%edx
  80198f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801994:	8d 40 04             	lea    0x4(%eax),%eax
  801997:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80199a:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80199f:	e9 a3 00 00 00       	jmp    801a47 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a7:	8b 10                	mov    (%eax),%edx
  8019a9:	8b 48 04             	mov    0x4(%eax),%ecx
  8019ac:	8d 40 08             	lea    0x8(%eax),%eax
  8019af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019b2:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8019b7:	e9 8b 00 00 00       	jmp    801a47 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8019bf:	8b 10                	mov    (%eax),%edx
  8019c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019c6:	8d 40 04             	lea    0x4(%eax),%eax
  8019c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019cc:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8019d1:	eb 74                	jmp    801a47 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8019d3:	83 f9 01             	cmp    $0x1,%ecx
  8019d6:	7f 1b                	jg     8019f3 <vprintfmt+0x354>
	else if (lflag)
  8019d8:	85 c9                	test   %ecx,%ecx
  8019da:	74 2c                	je     801a08 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8019dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8019df:	8b 10                	mov    (%eax),%edx
  8019e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019e6:	8d 40 04             	lea    0x4(%eax),%eax
  8019e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019ec:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8019f1:	eb 54                	jmp    801a47 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f6:	8b 10                	mov    (%eax),%edx
  8019f8:	8b 48 04             	mov    0x4(%eax),%ecx
  8019fb:	8d 40 08             	lea    0x8(%eax),%eax
  8019fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a01:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  801a06:	eb 3f                	jmp    801a47 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a08:	8b 45 14             	mov    0x14(%ebp),%eax
  801a0b:	8b 10                	mov    (%eax),%edx
  801a0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a12:	8d 40 04             	lea    0x4(%eax),%eax
  801a15:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a18:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801a1d:	eb 28                	jmp    801a47 <vprintfmt+0x3a8>
			putch('0', putdat);
  801a1f:	83 ec 08             	sub    $0x8,%esp
  801a22:	53                   	push   %ebx
  801a23:	6a 30                	push   $0x30
  801a25:	ff d6                	call   *%esi
			putch('x', putdat);
  801a27:	83 c4 08             	add    $0x8,%esp
  801a2a:	53                   	push   %ebx
  801a2b:	6a 78                	push   $0x78
  801a2d:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a2f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a32:	8b 10                	mov    (%eax),%edx
  801a34:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a39:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a3c:	8d 40 04             	lea    0x4(%eax),%eax
  801a3f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a42:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801a47:	83 ec 0c             	sub    $0xc,%esp
  801a4a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801a4e:	50                   	push   %eax
  801a4f:	ff 75 e0             	push   -0x20(%ebp)
  801a52:	57                   	push   %edi
  801a53:	51                   	push   %ecx
  801a54:	52                   	push   %edx
  801a55:	89 da                	mov    %ebx,%edx
  801a57:	89 f0                	mov    %esi,%eax
  801a59:	e8 5e fb ff ff       	call   8015bc <printnum>
			break;
  801a5e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801a61:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a64:	e9 54 fc ff ff       	jmp    8016bd <vprintfmt+0x1e>
	if (lflag >= 2)
  801a69:	83 f9 01             	cmp    $0x1,%ecx
  801a6c:	7f 1b                	jg     801a89 <vprintfmt+0x3ea>
	else if (lflag)
  801a6e:	85 c9                	test   %ecx,%ecx
  801a70:	74 2c                	je     801a9e <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801a72:	8b 45 14             	mov    0x14(%ebp),%eax
  801a75:	8b 10                	mov    (%eax),%edx
  801a77:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a7c:	8d 40 04             	lea    0x4(%eax),%eax
  801a7f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a82:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801a87:	eb be                	jmp    801a47 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801a89:	8b 45 14             	mov    0x14(%ebp),%eax
  801a8c:	8b 10                	mov    (%eax),%edx
  801a8e:	8b 48 04             	mov    0x4(%eax),%ecx
  801a91:	8d 40 08             	lea    0x8(%eax),%eax
  801a94:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a97:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  801a9c:	eb a9                	jmp    801a47 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a9e:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa1:	8b 10                	mov    (%eax),%edx
  801aa3:	b9 00 00 00 00       	mov    $0x0,%ecx
  801aa8:	8d 40 04             	lea    0x4(%eax),%eax
  801aab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801aae:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  801ab3:	eb 92                	jmp    801a47 <vprintfmt+0x3a8>
			putch(ch, putdat);
  801ab5:	83 ec 08             	sub    $0x8,%esp
  801ab8:	53                   	push   %ebx
  801ab9:	6a 25                	push   $0x25
  801abb:	ff d6                	call   *%esi
			break;
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	eb 9f                	jmp    801a61 <vprintfmt+0x3c2>
			putch('%', putdat);
  801ac2:	83 ec 08             	sub    $0x8,%esp
  801ac5:	53                   	push   %ebx
  801ac6:	6a 25                	push   $0x25
  801ac8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	89 f8                	mov    %edi,%eax
  801acf:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801ad3:	74 05                	je     801ada <vprintfmt+0x43b>
  801ad5:	83 e8 01             	sub    $0x1,%eax
  801ad8:	eb f5                	jmp    801acf <vprintfmt+0x430>
  801ada:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801add:	eb 82                	jmp    801a61 <vprintfmt+0x3c2>

00801adf <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	83 ec 18             	sub    $0x18,%esp
  801ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801aeb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801aee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801af2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801af5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801afc:	85 c0                	test   %eax,%eax
  801afe:	74 26                	je     801b26 <vsnprintf+0x47>
  801b00:	85 d2                	test   %edx,%edx
  801b02:	7e 22                	jle    801b26 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b04:	ff 75 14             	push   0x14(%ebp)
  801b07:	ff 75 10             	push   0x10(%ebp)
  801b0a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b0d:	50                   	push   %eax
  801b0e:	68 65 16 80 00       	push   $0x801665
  801b13:	e8 87 fb ff ff       	call   80169f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b18:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b1b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b21:	83 c4 10             	add    $0x10,%esp
}
  801b24:	c9                   	leave  
  801b25:	c3                   	ret    
		return -E_INVAL;
  801b26:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b2b:	eb f7                	jmp    801b24 <vsnprintf+0x45>

00801b2d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b33:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b36:	50                   	push   %eax
  801b37:	ff 75 10             	push   0x10(%ebp)
  801b3a:	ff 75 0c             	push   0xc(%ebp)
  801b3d:	ff 75 08             	push   0x8(%ebp)
  801b40:	e8 9a ff ff ff       	call   801adf <vsnprintf>
	va_end(ap);

	return rc;
}
  801b45:	c9                   	leave  
  801b46:	c3                   	ret    

00801b47 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b47:	55                   	push   %ebp
  801b48:	89 e5                	mov    %esp,%ebp
  801b4a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b52:	eb 03                	jmp    801b57 <strlen+0x10>
		n++;
  801b54:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801b57:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b5b:	75 f7                	jne    801b54 <strlen+0xd>
	return n;
}
  801b5d:	5d                   	pop    %ebp
  801b5e:	c3                   	ret    

00801b5f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b65:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b68:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6d:	eb 03                	jmp    801b72 <strnlen+0x13>
		n++;
  801b6f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b72:	39 d0                	cmp    %edx,%eax
  801b74:	74 08                	je     801b7e <strnlen+0x1f>
  801b76:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801b7a:	75 f3                	jne    801b6f <strnlen+0x10>
  801b7c:	89 c2                	mov    %eax,%edx
	return n;
}
  801b7e:	89 d0                	mov    %edx,%eax
  801b80:	5d                   	pop    %ebp
  801b81:	c3                   	ret    

00801b82 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	53                   	push   %ebx
  801b86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b8c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b91:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801b95:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801b98:	83 c0 01             	add    $0x1,%eax
  801b9b:	84 d2                	test   %dl,%dl
  801b9d:	75 f2                	jne    801b91 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801b9f:	89 c8                	mov    %ecx,%eax
  801ba1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba4:	c9                   	leave  
  801ba5:	c3                   	ret    

00801ba6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801ba6:	55                   	push   %ebp
  801ba7:	89 e5                	mov    %esp,%ebp
  801ba9:	53                   	push   %ebx
  801baa:	83 ec 10             	sub    $0x10,%esp
  801bad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bb0:	53                   	push   %ebx
  801bb1:	e8 91 ff ff ff       	call   801b47 <strlen>
  801bb6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801bb9:	ff 75 0c             	push   0xc(%ebp)
  801bbc:	01 d8                	add    %ebx,%eax
  801bbe:	50                   	push   %eax
  801bbf:	e8 be ff ff ff       	call   801b82 <strcpy>
	return dst;
}
  801bc4:	89 d8                	mov    %ebx,%eax
  801bc6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc9:	c9                   	leave  
  801bca:	c3                   	ret    

00801bcb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	56                   	push   %esi
  801bcf:	53                   	push   %ebx
  801bd0:	8b 75 08             	mov    0x8(%ebp),%esi
  801bd3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bd6:	89 f3                	mov    %esi,%ebx
  801bd8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bdb:	89 f0                	mov    %esi,%eax
  801bdd:	eb 0f                	jmp    801bee <strncpy+0x23>
		*dst++ = *src;
  801bdf:	83 c0 01             	add    $0x1,%eax
  801be2:	0f b6 0a             	movzbl (%edx),%ecx
  801be5:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801be8:	80 f9 01             	cmp    $0x1,%cl
  801beb:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801bee:	39 d8                	cmp    %ebx,%eax
  801bf0:	75 ed                	jne    801bdf <strncpy+0x14>
	}
	return ret;
}
  801bf2:	89 f0                	mov    %esi,%eax
  801bf4:	5b                   	pop    %ebx
  801bf5:	5e                   	pop    %esi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    

00801bf8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	56                   	push   %esi
  801bfc:	53                   	push   %ebx
  801bfd:	8b 75 08             	mov    0x8(%ebp),%esi
  801c00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c03:	8b 55 10             	mov    0x10(%ebp),%edx
  801c06:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c08:	85 d2                	test   %edx,%edx
  801c0a:	74 21                	je     801c2d <strlcpy+0x35>
  801c0c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c10:	89 f2                	mov    %esi,%edx
  801c12:	eb 09                	jmp    801c1d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c14:	83 c1 01             	add    $0x1,%ecx
  801c17:	83 c2 01             	add    $0x1,%edx
  801c1a:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801c1d:	39 c2                	cmp    %eax,%edx
  801c1f:	74 09                	je     801c2a <strlcpy+0x32>
  801c21:	0f b6 19             	movzbl (%ecx),%ebx
  801c24:	84 db                	test   %bl,%bl
  801c26:	75 ec                	jne    801c14 <strlcpy+0x1c>
  801c28:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c2a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c2d:	29 f0                	sub    %esi,%eax
}
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5d                   	pop    %ebp
  801c32:	c3                   	ret    

00801c33 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c39:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c3c:	eb 06                	jmp    801c44 <strcmp+0x11>
		p++, q++;
  801c3e:	83 c1 01             	add    $0x1,%ecx
  801c41:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801c44:	0f b6 01             	movzbl (%ecx),%eax
  801c47:	84 c0                	test   %al,%al
  801c49:	74 04                	je     801c4f <strcmp+0x1c>
  801c4b:	3a 02                	cmp    (%edx),%al
  801c4d:	74 ef                	je     801c3e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c4f:	0f b6 c0             	movzbl %al,%eax
  801c52:	0f b6 12             	movzbl (%edx),%edx
  801c55:	29 d0                	sub    %edx,%eax
}
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    

00801c59 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	53                   	push   %ebx
  801c5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c60:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c63:	89 c3                	mov    %eax,%ebx
  801c65:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c68:	eb 06                	jmp    801c70 <strncmp+0x17>
		n--, p++, q++;
  801c6a:	83 c0 01             	add    $0x1,%eax
  801c6d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801c70:	39 d8                	cmp    %ebx,%eax
  801c72:	74 18                	je     801c8c <strncmp+0x33>
  801c74:	0f b6 08             	movzbl (%eax),%ecx
  801c77:	84 c9                	test   %cl,%cl
  801c79:	74 04                	je     801c7f <strncmp+0x26>
  801c7b:	3a 0a                	cmp    (%edx),%cl
  801c7d:	74 eb                	je     801c6a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c7f:	0f b6 00             	movzbl (%eax),%eax
  801c82:	0f b6 12             	movzbl (%edx),%edx
  801c85:	29 d0                	sub    %edx,%eax
}
  801c87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c8a:	c9                   	leave  
  801c8b:	c3                   	ret    
		return 0;
  801c8c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c91:	eb f4                	jmp    801c87 <strncmp+0x2e>

00801c93 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	8b 45 08             	mov    0x8(%ebp),%eax
  801c99:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c9d:	eb 03                	jmp    801ca2 <strchr+0xf>
  801c9f:	83 c0 01             	add    $0x1,%eax
  801ca2:	0f b6 10             	movzbl (%eax),%edx
  801ca5:	84 d2                	test   %dl,%dl
  801ca7:	74 06                	je     801caf <strchr+0x1c>
		if (*s == c)
  801ca9:	38 ca                	cmp    %cl,%dl
  801cab:	75 f2                	jne    801c9f <strchr+0xc>
  801cad:	eb 05                	jmp    801cb4 <strchr+0x21>
			return (char *) s;
	return 0;
  801caf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cb4:	5d                   	pop    %ebp
  801cb5:	c3                   	ret    

00801cb6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cb6:	55                   	push   %ebp
  801cb7:	89 e5                	mov    %esp,%ebp
  801cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cc0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cc3:	38 ca                	cmp    %cl,%dl
  801cc5:	74 09                	je     801cd0 <strfind+0x1a>
  801cc7:	84 d2                	test   %dl,%dl
  801cc9:	74 05                	je     801cd0 <strfind+0x1a>
	for (; *s; s++)
  801ccb:	83 c0 01             	add    $0x1,%eax
  801cce:	eb f0                	jmp    801cc0 <strfind+0xa>
			break;
	return (char *) s;
}
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    

00801cd2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	57                   	push   %edi
  801cd6:	56                   	push   %esi
  801cd7:	53                   	push   %ebx
  801cd8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cdb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cde:	85 c9                	test   %ecx,%ecx
  801ce0:	74 2f                	je     801d11 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ce2:	89 f8                	mov    %edi,%eax
  801ce4:	09 c8                	or     %ecx,%eax
  801ce6:	a8 03                	test   $0x3,%al
  801ce8:	75 21                	jne    801d0b <memset+0x39>
		c &= 0xFF;
  801cea:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cee:	89 d0                	mov    %edx,%eax
  801cf0:	c1 e0 08             	shl    $0x8,%eax
  801cf3:	89 d3                	mov    %edx,%ebx
  801cf5:	c1 e3 18             	shl    $0x18,%ebx
  801cf8:	89 d6                	mov    %edx,%esi
  801cfa:	c1 e6 10             	shl    $0x10,%esi
  801cfd:	09 f3                	or     %esi,%ebx
  801cff:	09 da                	or     %ebx,%edx
  801d01:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801d03:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801d06:	fc                   	cld    
  801d07:	f3 ab                	rep stos %eax,%es:(%edi)
  801d09:	eb 06                	jmp    801d11 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d0e:	fc                   	cld    
  801d0f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d11:	89 f8                	mov    %edi,%eax
  801d13:	5b                   	pop    %ebx
  801d14:	5e                   	pop    %esi
  801d15:	5f                   	pop    %edi
  801d16:	5d                   	pop    %ebp
  801d17:	c3                   	ret    

00801d18 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
  801d1b:	57                   	push   %edi
  801d1c:	56                   	push   %esi
  801d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d20:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d23:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d26:	39 c6                	cmp    %eax,%esi
  801d28:	73 32                	jae    801d5c <memmove+0x44>
  801d2a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d2d:	39 c2                	cmp    %eax,%edx
  801d2f:	76 2b                	jbe    801d5c <memmove+0x44>
		s += n;
		d += n;
  801d31:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d34:	89 d6                	mov    %edx,%esi
  801d36:	09 fe                	or     %edi,%esi
  801d38:	09 ce                	or     %ecx,%esi
  801d3a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d40:	75 0e                	jne    801d50 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d42:	83 ef 04             	sub    $0x4,%edi
  801d45:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d48:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801d4b:	fd                   	std    
  801d4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d4e:	eb 09                	jmp    801d59 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d50:	83 ef 01             	sub    $0x1,%edi
  801d53:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801d56:	fd                   	std    
  801d57:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d59:	fc                   	cld    
  801d5a:	eb 1a                	jmp    801d76 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d5c:	89 f2                	mov    %esi,%edx
  801d5e:	09 c2                	or     %eax,%edx
  801d60:	09 ca                	or     %ecx,%edx
  801d62:	f6 c2 03             	test   $0x3,%dl
  801d65:	75 0a                	jne    801d71 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d67:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801d6a:	89 c7                	mov    %eax,%edi
  801d6c:	fc                   	cld    
  801d6d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d6f:	eb 05                	jmp    801d76 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801d71:	89 c7                	mov    %eax,%edi
  801d73:	fc                   	cld    
  801d74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d76:	5e                   	pop    %esi
  801d77:	5f                   	pop    %edi
  801d78:	5d                   	pop    %ebp
  801d79:	c3                   	ret    

00801d7a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d80:	ff 75 10             	push   0x10(%ebp)
  801d83:	ff 75 0c             	push   0xc(%ebp)
  801d86:	ff 75 08             	push   0x8(%ebp)
  801d89:	e8 8a ff ff ff       	call   801d18 <memmove>
}
  801d8e:	c9                   	leave  
  801d8f:	c3                   	ret    

00801d90 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	56                   	push   %esi
  801d94:	53                   	push   %ebx
  801d95:	8b 45 08             	mov    0x8(%ebp),%eax
  801d98:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d9b:	89 c6                	mov    %eax,%esi
  801d9d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801da0:	eb 06                	jmp    801da8 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801da2:	83 c0 01             	add    $0x1,%eax
  801da5:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801da8:	39 f0                	cmp    %esi,%eax
  801daa:	74 14                	je     801dc0 <memcmp+0x30>
		if (*s1 != *s2)
  801dac:	0f b6 08             	movzbl (%eax),%ecx
  801daf:	0f b6 1a             	movzbl (%edx),%ebx
  801db2:	38 d9                	cmp    %bl,%cl
  801db4:	74 ec                	je     801da2 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801db6:	0f b6 c1             	movzbl %cl,%eax
  801db9:	0f b6 db             	movzbl %bl,%ebx
  801dbc:	29 d8                	sub    %ebx,%eax
  801dbe:	eb 05                	jmp    801dc5 <memcmp+0x35>
	}

	return 0;
  801dc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dc5:	5b                   	pop    %ebx
  801dc6:	5e                   	pop    %esi
  801dc7:	5d                   	pop    %ebp
  801dc8:	c3                   	ret    

00801dc9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dc9:	55                   	push   %ebp
  801dca:	89 e5                	mov    %esp,%ebp
  801dcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801dd2:	89 c2                	mov    %eax,%edx
  801dd4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801dd7:	eb 03                	jmp    801ddc <memfind+0x13>
  801dd9:	83 c0 01             	add    $0x1,%eax
  801ddc:	39 d0                	cmp    %edx,%eax
  801dde:	73 04                	jae    801de4 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801de0:	38 08                	cmp    %cl,(%eax)
  801de2:	75 f5                	jne    801dd9 <memfind+0x10>
			break;
	return (void *) s;
}
  801de4:	5d                   	pop    %ebp
  801de5:	c3                   	ret    

00801de6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801de6:	55                   	push   %ebp
  801de7:	89 e5                	mov    %esp,%ebp
  801de9:	57                   	push   %edi
  801dea:	56                   	push   %esi
  801deb:	53                   	push   %ebx
  801dec:	8b 55 08             	mov    0x8(%ebp),%edx
  801def:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801df2:	eb 03                	jmp    801df7 <strtol+0x11>
		s++;
  801df4:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801df7:	0f b6 02             	movzbl (%edx),%eax
  801dfa:	3c 20                	cmp    $0x20,%al
  801dfc:	74 f6                	je     801df4 <strtol+0xe>
  801dfe:	3c 09                	cmp    $0x9,%al
  801e00:	74 f2                	je     801df4 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801e02:	3c 2b                	cmp    $0x2b,%al
  801e04:	74 2a                	je     801e30 <strtol+0x4a>
	int neg = 0;
  801e06:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801e0b:	3c 2d                	cmp    $0x2d,%al
  801e0d:	74 2b                	je     801e3a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e0f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e15:	75 0f                	jne    801e26 <strtol+0x40>
  801e17:	80 3a 30             	cmpb   $0x30,(%edx)
  801e1a:	74 28                	je     801e44 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e1c:	85 db                	test   %ebx,%ebx
  801e1e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e23:	0f 44 d8             	cmove  %eax,%ebx
  801e26:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e2b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801e2e:	eb 46                	jmp    801e76 <strtol+0x90>
		s++;
  801e30:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801e33:	bf 00 00 00 00       	mov    $0x0,%edi
  801e38:	eb d5                	jmp    801e0f <strtol+0x29>
		s++, neg = 1;
  801e3a:	83 c2 01             	add    $0x1,%edx
  801e3d:	bf 01 00 00 00       	mov    $0x1,%edi
  801e42:	eb cb                	jmp    801e0f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e44:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e48:	74 0e                	je     801e58 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801e4a:	85 db                	test   %ebx,%ebx
  801e4c:	75 d8                	jne    801e26 <strtol+0x40>
		s++, base = 8;
  801e4e:	83 c2 01             	add    $0x1,%edx
  801e51:	bb 08 00 00 00       	mov    $0x8,%ebx
  801e56:	eb ce                	jmp    801e26 <strtol+0x40>
		s += 2, base = 16;
  801e58:	83 c2 02             	add    $0x2,%edx
  801e5b:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e60:	eb c4                	jmp    801e26 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801e62:	0f be c0             	movsbl %al,%eax
  801e65:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801e68:	3b 45 10             	cmp    0x10(%ebp),%eax
  801e6b:	7d 3a                	jge    801ea7 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801e6d:	83 c2 01             	add    $0x1,%edx
  801e70:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801e74:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801e76:	0f b6 02             	movzbl (%edx),%eax
  801e79:	8d 70 d0             	lea    -0x30(%eax),%esi
  801e7c:	89 f3                	mov    %esi,%ebx
  801e7e:	80 fb 09             	cmp    $0x9,%bl
  801e81:	76 df                	jbe    801e62 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801e83:	8d 70 9f             	lea    -0x61(%eax),%esi
  801e86:	89 f3                	mov    %esi,%ebx
  801e88:	80 fb 19             	cmp    $0x19,%bl
  801e8b:	77 08                	ja     801e95 <strtol+0xaf>
			dig = *s - 'a' + 10;
  801e8d:	0f be c0             	movsbl %al,%eax
  801e90:	83 e8 57             	sub    $0x57,%eax
  801e93:	eb d3                	jmp    801e68 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801e95:	8d 70 bf             	lea    -0x41(%eax),%esi
  801e98:	89 f3                	mov    %esi,%ebx
  801e9a:	80 fb 19             	cmp    $0x19,%bl
  801e9d:	77 08                	ja     801ea7 <strtol+0xc1>
			dig = *s - 'A' + 10;
  801e9f:	0f be c0             	movsbl %al,%eax
  801ea2:	83 e8 37             	sub    $0x37,%eax
  801ea5:	eb c1                	jmp    801e68 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801ea7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801eab:	74 05                	je     801eb2 <strtol+0xcc>
		*endptr = (char *) s;
  801ead:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb0:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801eb2:	89 c8                	mov    %ecx,%eax
  801eb4:	f7 d8                	neg    %eax
  801eb6:	85 ff                	test   %edi,%edi
  801eb8:	0f 45 c8             	cmovne %eax,%ecx
}
  801ebb:	89 c8                	mov    %ecx,%eax
  801ebd:	5b                   	pop    %ebx
  801ebe:	5e                   	pop    %esi
  801ebf:	5f                   	pop    %edi
  801ec0:	5d                   	pop    %ebp
  801ec1:	c3                   	ret    

00801ec2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ec2:	55                   	push   %ebp
  801ec3:	89 e5                	mov    %esp,%ebp
  801ec5:	56                   	push   %esi
  801ec6:	53                   	push   %ebx
  801ec7:	8b 75 08             	mov    0x8(%ebp),%esi
  801eca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ecd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801ed0:	85 c0                	test   %eax,%eax
  801ed2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ed7:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801eda:	83 ec 0c             	sub    $0xc,%esp
  801edd:	50                   	push   %eax
  801ede:	e8 3a e4 ff ff       	call   80031d <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ee3:	83 c4 10             	add    $0x10,%esp
  801ee6:	85 f6                	test   %esi,%esi
  801ee8:	74 17                	je     801f01 <ipc_recv+0x3f>
  801eea:	ba 00 00 00 00       	mov    $0x0,%edx
  801eef:	85 c0                	test   %eax,%eax
  801ef1:	78 0c                	js     801eff <ipc_recv+0x3d>
  801ef3:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ef9:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801eff:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801f01:	85 db                	test   %ebx,%ebx
  801f03:	74 17                	je     801f1c <ipc_recv+0x5a>
  801f05:	ba 00 00 00 00       	mov    $0x0,%edx
  801f0a:	85 c0                	test   %eax,%eax
  801f0c:	78 0c                	js     801f1a <ipc_recv+0x58>
  801f0e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f14:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801f1a:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f1c:	85 c0                	test   %eax,%eax
  801f1e:	78 0b                	js     801f2b <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801f20:	a1 00 40 80 00       	mov    0x804000,%eax
  801f25:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801f2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f2e:	5b                   	pop    %ebx
  801f2f:	5e                   	pop    %esi
  801f30:	5d                   	pop    %ebp
  801f31:	c3                   	ret    

00801f32 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	57                   	push   %edi
  801f36:	56                   	push   %esi
  801f37:	53                   	push   %ebx
  801f38:	83 ec 0c             	sub    $0xc,%esp
  801f3b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f44:	85 db                	test   %ebx,%ebx
  801f46:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f4b:	0f 44 d8             	cmove  %eax,%ebx
  801f4e:	eb 05                	jmp    801f55 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f50:	e8 f9 e1 ff ff       	call   80014e <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f55:	ff 75 14             	push   0x14(%ebp)
  801f58:	53                   	push   %ebx
  801f59:	56                   	push   %esi
  801f5a:	57                   	push   %edi
  801f5b:	e8 9a e3 ff ff       	call   8002fa <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f60:	83 c4 10             	add    $0x10,%esp
  801f63:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f66:	74 e8                	je     801f50 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f68:	85 c0                	test   %eax,%eax
  801f6a:	78 08                	js     801f74 <ipc_send+0x42>
	}while (r<0);

}
  801f6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6f:	5b                   	pop    %ebx
  801f70:	5e                   	pop    %esi
  801f71:	5f                   	pop    %edi
  801f72:	5d                   	pop    %ebp
  801f73:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f74:	50                   	push   %eax
  801f75:	68 ff 26 80 00       	push   $0x8026ff
  801f7a:	6a 3d                	push   $0x3d
  801f7c:	68 13 27 80 00       	push   $0x802713
  801f81:	e8 47 f5 ff ff       	call   8014cd <_panic>

00801f86 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f86:	55                   	push   %ebp
  801f87:	89 e5                	mov    %esp,%ebp
  801f89:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f8c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f91:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  801f97:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f9d:	8b 52 60             	mov    0x60(%edx),%edx
  801fa0:	39 ca                	cmp    %ecx,%edx
  801fa2:	74 11                	je     801fb5 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  801fa4:	83 c0 01             	add    $0x1,%eax
  801fa7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fac:	75 e3                	jne    801f91 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801fae:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb3:	eb 0e                	jmp    801fc3 <ipc_find_env+0x3d>
			return envs[i].env_id;
  801fb5:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801fbb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fc0:	8b 40 58             	mov    0x58(%eax),%eax
}
  801fc3:	5d                   	pop    %ebp
  801fc4:	c3                   	ret    

00801fc5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
  801fc8:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fcb:	89 c2                	mov    %eax,%edx
  801fcd:	c1 ea 16             	shr    $0x16,%edx
  801fd0:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fd7:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fdc:	f6 c1 01             	test   $0x1,%cl
  801fdf:	74 1c                	je     801ffd <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801fe1:	c1 e8 0c             	shr    $0xc,%eax
  801fe4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801feb:	a8 01                	test   $0x1,%al
  801fed:	74 0e                	je     801ffd <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fef:	c1 e8 0c             	shr    $0xc,%eax
  801ff2:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801ff9:	ef 
  801ffa:	0f b7 d2             	movzwl %dx,%edx
}
  801ffd:	89 d0                	mov    %edx,%eax
  801fff:	5d                   	pop    %ebp
  802000:	c3                   	ret    
  802001:	66 90                	xchg   %ax,%ax
  802003:	66 90                	xchg   %ax,%ax
  802005:	66 90                	xchg   %ax,%ax
  802007:	66 90                	xchg   %ax,%ax
  802009:	66 90                	xchg   %ax,%ax
  80200b:	66 90                	xchg   %ax,%ax
  80200d:	66 90                	xchg   %ax,%ax
  80200f:	90                   	nop

00802010 <__udivdi3>:
  802010:	f3 0f 1e fb          	endbr32 
  802014:	55                   	push   %ebp
  802015:	57                   	push   %edi
  802016:	56                   	push   %esi
  802017:	53                   	push   %ebx
  802018:	83 ec 1c             	sub    $0x1c,%esp
  80201b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80201f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802023:	8b 74 24 34          	mov    0x34(%esp),%esi
  802027:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80202b:	85 c0                	test   %eax,%eax
  80202d:	75 19                	jne    802048 <__udivdi3+0x38>
  80202f:	39 f3                	cmp    %esi,%ebx
  802031:	76 4d                	jbe    802080 <__udivdi3+0x70>
  802033:	31 ff                	xor    %edi,%edi
  802035:	89 e8                	mov    %ebp,%eax
  802037:	89 f2                	mov    %esi,%edx
  802039:	f7 f3                	div    %ebx
  80203b:	89 fa                	mov    %edi,%edx
  80203d:	83 c4 1c             	add    $0x1c,%esp
  802040:	5b                   	pop    %ebx
  802041:	5e                   	pop    %esi
  802042:	5f                   	pop    %edi
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    
  802045:	8d 76 00             	lea    0x0(%esi),%esi
  802048:	39 f0                	cmp    %esi,%eax
  80204a:	76 14                	jbe    802060 <__udivdi3+0x50>
  80204c:	31 ff                	xor    %edi,%edi
  80204e:	31 c0                	xor    %eax,%eax
  802050:	89 fa                	mov    %edi,%edx
  802052:	83 c4 1c             	add    $0x1c,%esp
  802055:	5b                   	pop    %ebx
  802056:	5e                   	pop    %esi
  802057:	5f                   	pop    %edi
  802058:	5d                   	pop    %ebp
  802059:	c3                   	ret    
  80205a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802060:	0f bd f8             	bsr    %eax,%edi
  802063:	83 f7 1f             	xor    $0x1f,%edi
  802066:	75 48                	jne    8020b0 <__udivdi3+0xa0>
  802068:	39 f0                	cmp    %esi,%eax
  80206a:	72 06                	jb     802072 <__udivdi3+0x62>
  80206c:	31 c0                	xor    %eax,%eax
  80206e:	39 eb                	cmp    %ebp,%ebx
  802070:	77 de                	ja     802050 <__udivdi3+0x40>
  802072:	b8 01 00 00 00       	mov    $0x1,%eax
  802077:	eb d7                	jmp    802050 <__udivdi3+0x40>
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	89 d9                	mov    %ebx,%ecx
  802082:	85 db                	test   %ebx,%ebx
  802084:	75 0b                	jne    802091 <__udivdi3+0x81>
  802086:	b8 01 00 00 00       	mov    $0x1,%eax
  80208b:	31 d2                	xor    %edx,%edx
  80208d:	f7 f3                	div    %ebx
  80208f:	89 c1                	mov    %eax,%ecx
  802091:	31 d2                	xor    %edx,%edx
  802093:	89 f0                	mov    %esi,%eax
  802095:	f7 f1                	div    %ecx
  802097:	89 c6                	mov    %eax,%esi
  802099:	89 e8                	mov    %ebp,%eax
  80209b:	89 f7                	mov    %esi,%edi
  80209d:	f7 f1                	div    %ecx
  80209f:	89 fa                	mov    %edi,%edx
  8020a1:	83 c4 1c             	add    $0x1c,%esp
  8020a4:	5b                   	pop    %ebx
  8020a5:	5e                   	pop    %esi
  8020a6:	5f                   	pop    %edi
  8020a7:	5d                   	pop    %ebp
  8020a8:	c3                   	ret    
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 f9                	mov    %edi,%ecx
  8020b2:	ba 20 00 00 00       	mov    $0x20,%edx
  8020b7:	29 fa                	sub    %edi,%edx
  8020b9:	d3 e0                	shl    %cl,%eax
  8020bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020bf:	89 d1                	mov    %edx,%ecx
  8020c1:	89 d8                	mov    %ebx,%eax
  8020c3:	d3 e8                	shr    %cl,%eax
  8020c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020c9:	09 c1                	or     %eax,%ecx
  8020cb:	89 f0                	mov    %esi,%eax
  8020cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020d1:	89 f9                	mov    %edi,%ecx
  8020d3:	d3 e3                	shl    %cl,%ebx
  8020d5:	89 d1                	mov    %edx,%ecx
  8020d7:	d3 e8                	shr    %cl,%eax
  8020d9:	89 f9                	mov    %edi,%ecx
  8020db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020df:	89 eb                	mov    %ebp,%ebx
  8020e1:	d3 e6                	shl    %cl,%esi
  8020e3:	89 d1                	mov    %edx,%ecx
  8020e5:	d3 eb                	shr    %cl,%ebx
  8020e7:	09 f3                	or     %esi,%ebx
  8020e9:	89 c6                	mov    %eax,%esi
  8020eb:	89 f2                	mov    %esi,%edx
  8020ed:	89 d8                	mov    %ebx,%eax
  8020ef:	f7 74 24 08          	divl   0x8(%esp)
  8020f3:	89 d6                	mov    %edx,%esi
  8020f5:	89 c3                	mov    %eax,%ebx
  8020f7:	f7 64 24 0c          	mull   0xc(%esp)
  8020fb:	39 d6                	cmp    %edx,%esi
  8020fd:	72 19                	jb     802118 <__udivdi3+0x108>
  8020ff:	89 f9                	mov    %edi,%ecx
  802101:	d3 e5                	shl    %cl,%ebp
  802103:	39 c5                	cmp    %eax,%ebp
  802105:	73 04                	jae    80210b <__udivdi3+0xfb>
  802107:	39 d6                	cmp    %edx,%esi
  802109:	74 0d                	je     802118 <__udivdi3+0x108>
  80210b:	89 d8                	mov    %ebx,%eax
  80210d:	31 ff                	xor    %edi,%edi
  80210f:	e9 3c ff ff ff       	jmp    802050 <__udivdi3+0x40>
  802114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802118:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80211b:	31 ff                	xor    %edi,%edi
  80211d:	e9 2e ff ff ff       	jmp    802050 <__udivdi3+0x40>
  802122:	66 90                	xchg   %ax,%ax
  802124:	66 90                	xchg   %ax,%ax
  802126:	66 90                	xchg   %ax,%ax
  802128:	66 90                	xchg   %ax,%ax
  80212a:	66 90                	xchg   %ax,%ax
  80212c:	66 90                	xchg   %ax,%ax
  80212e:	66 90                	xchg   %ax,%ax

00802130 <__umoddi3>:
  802130:	f3 0f 1e fb          	endbr32 
  802134:	55                   	push   %ebp
  802135:	57                   	push   %edi
  802136:	56                   	push   %esi
  802137:	53                   	push   %ebx
  802138:	83 ec 1c             	sub    $0x1c,%esp
  80213b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80213f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802143:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802147:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80214b:	89 f0                	mov    %esi,%eax
  80214d:	89 da                	mov    %ebx,%edx
  80214f:	85 ff                	test   %edi,%edi
  802151:	75 15                	jne    802168 <__umoddi3+0x38>
  802153:	39 dd                	cmp    %ebx,%ebp
  802155:	76 39                	jbe    802190 <__umoddi3+0x60>
  802157:	f7 f5                	div    %ebp
  802159:	89 d0                	mov    %edx,%eax
  80215b:	31 d2                	xor    %edx,%edx
  80215d:	83 c4 1c             	add    $0x1c,%esp
  802160:	5b                   	pop    %ebx
  802161:	5e                   	pop    %esi
  802162:	5f                   	pop    %edi
  802163:	5d                   	pop    %ebp
  802164:	c3                   	ret    
  802165:	8d 76 00             	lea    0x0(%esi),%esi
  802168:	39 df                	cmp    %ebx,%edi
  80216a:	77 f1                	ja     80215d <__umoddi3+0x2d>
  80216c:	0f bd cf             	bsr    %edi,%ecx
  80216f:	83 f1 1f             	xor    $0x1f,%ecx
  802172:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802176:	75 40                	jne    8021b8 <__umoddi3+0x88>
  802178:	39 df                	cmp    %ebx,%edi
  80217a:	72 04                	jb     802180 <__umoddi3+0x50>
  80217c:	39 f5                	cmp    %esi,%ebp
  80217e:	77 dd                	ja     80215d <__umoddi3+0x2d>
  802180:	89 da                	mov    %ebx,%edx
  802182:	89 f0                	mov    %esi,%eax
  802184:	29 e8                	sub    %ebp,%eax
  802186:	19 fa                	sbb    %edi,%edx
  802188:	eb d3                	jmp    80215d <__umoddi3+0x2d>
  80218a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802190:	89 e9                	mov    %ebp,%ecx
  802192:	85 ed                	test   %ebp,%ebp
  802194:	75 0b                	jne    8021a1 <__umoddi3+0x71>
  802196:	b8 01 00 00 00       	mov    $0x1,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	f7 f5                	div    %ebp
  80219f:	89 c1                	mov    %eax,%ecx
  8021a1:	89 d8                	mov    %ebx,%eax
  8021a3:	31 d2                	xor    %edx,%edx
  8021a5:	f7 f1                	div    %ecx
  8021a7:	89 f0                	mov    %esi,%eax
  8021a9:	f7 f1                	div    %ecx
  8021ab:	89 d0                	mov    %edx,%eax
  8021ad:	31 d2                	xor    %edx,%edx
  8021af:	eb ac                	jmp    80215d <__umoddi3+0x2d>
  8021b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021bc:	ba 20 00 00 00       	mov    $0x20,%edx
  8021c1:	29 c2                	sub    %eax,%edx
  8021c3:	89 c1                	mov    %eax,%ecx
  8021c5:	89 e8                	mov    %ebp,%eax
  8021c7:	d3 e7                	shl    %cl,%edi
  8021c9:	89 d1                	mov    %edx,%ecx
  8021cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021cf:	d3 e8                	shr    %cl,%eax
  8021d1:	89 c1                	mov    %eax,%ecx
  8021d3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021d7:	09 f9                	or     %edi,%ecx
  8021d9:	89 df                	mov    %ebx,%edi
  8021db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021df:	89 c1                	mov    %eax,%ecx
  8021e1:	d3 e5                	shl    %cl,%ebp
  8021e3:	89 d1                	mov    %edx,%ecx
  8021e5:	d3 ef                	shr    %cl,%edi
  8021e7:	89 c1                	mov    %eax,%ecx
  8021e9:	89 f0                	mov    %esi,%eax
  8021eb:	d3 e3                	shl    %cl,%ebx
  8021ed:	89 d1                	mov    %edx,%ecx
  8021ef:	89 fa                	mov    %edi,%edx
  8021f1:	d3 e8                	shr    %cl,%eax
  8021f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021f8:	09 d8                	or     %ebx,%eax
  8021fa:	f7 74 24 08          	divl   0x8(%esp)
  8021fe:	89 d3                	mov    %edx,%ebx
  802200:	d3 e6                	shl    %cl,%esi
  802202:	f7 e5                	mul    %ebp
  802204:	89 c7                	mov    %eax,%edi
  802206:	89 d1                	mov    %edx,%ecx
  802208:	39 d3                	cmp    %edx,%ebx
  80220a:	72 06                	jb     802212 <__umoddi3+0xe2>
  80220c:	75 0e                	jne    80221c <__umoddi3+0xec>
  80220e:	39 c6                	cmp    %eax,%esi
  802210:	73 0a                	jae    80221c <__umoddi3+0xec>
  802212:	29 e8                	sub    %ebp,%eax
  802214:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802218:	89 d1                	mov    %edx,%ecx
  80221a:	89 c7                	mov    %eax,%edi
  80221c:	89 f5                	mov    %esi,%ebp
  80221e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802222:	29 fd                	sub    %edi,%ebp
  802224:	19 cb                	sbb    %ecx,%ebx
  802226:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80222b:	89 d8                	mov    %ebx,%eax
  80222d:	d3 e0                	shl    %cl,%eax
  80222f:	89 f1                	mov    %esi,%ecx
  802231:	d3 ed                	shr    %cl,%ebp
  802233:	d3 eb                	shr    %cl,%ebx
  802235:	09 e8                	or     %ebp,%eax
  802237:	89 da                	mov    %ebx,%edx
  802239:	83 c4 1c             	add    $0x1c,%esp
  80223c:	5b                   	pop    %ebx
  80223d:	5e                   	pop    %esi
  80223e:	5f                   	pop    %edi
  80223f:	5d                   	pop    %ebp
  802240:	c3                   	ret    
