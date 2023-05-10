
obj/user/evilhello.debug：     文件格式 elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 68 00 00 00       	call   8000ad <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800055:	e8 d1 00 00 00       	call   80012b <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800065:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006a:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006f:	85 db                	test   %ebx,%ebx
  800071:	7e 07                	jle    80007a <libmain+0x30>
		binaryname = argv[0];
  800073:	8b 06                	mov    (%esi),%eax
  800075:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007a:	83 ec 08             	sub    $0x8,%esp
  80007d:	56                   	push   %esi
  80007e:	53                   	push   %ebx
  80007f:	e8 af ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800084:	e8 0a 00 00 00       	call   800093 <exit>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008f:	5b                   	pop    %ebx
  800090:	5e                   	pop    %esi
  800091:	5d                   	pop    %ebp
  800092:	c3                   	ret    

00800093 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800093:	55                   	push   %ebp
  800094:	89 e5                	mov    %esp,%ebp
  800096:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800099:	e8 ee 04 00 00       	call   80058c <close_all>
	sys_env_destroy(0);
  80009e:	83 ec 0c             	sub    $0xc,%esp
  8000a1:	6a 00                	push   $0x0
  8000a3:	e8 42 00 00 00       	call   8000ea <sys_env_destroy>
}
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	c9                   	leave  
  8000ac:	c3                   	ret    

008000ad <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ad:	55                   	push   %ebp
  8000ae:	89 e5                	mov    %esp,%ebp
  8000b0:	57                   	push   %edi
  8000b1:	56                   	push   %esi
  8000b2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000be:	89 c3                	mov    %eax,%ebx
  8000c0:	89 c7                	mov    %eax,%edi
  8000c2:	89 c6                	mov    %eax,%esi
  8000c4:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c6:	5b                   	pop    %ebx
  8000c7:	5e                   	pop    %esi
  8000c8:	5f                   	pop    %edi
  8000c9:	5d                   	pop    %ebp
  8000ca:	c3                   	ret    

008000cb <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	57                   	push   %edi
  8000cf:	56                   	push   %esi
  8000d0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000db:	89 d1                	mov    %edx,%ecx
  8000dd:	89 d3                	mov    %edx,%ebx
  8000df:	89 d7                	mov    %edx,%edi
  8000e1:	89 d6                	mov    %edx,%esi
  8000e3:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e5:	5b                   	pop    %ebx
  8000e6:	5e                   	pop    %esi
  8000e7:	5f                   	pop    %edi
  8000e8:	5d                   	pop    %ebp
  8000e9:	c3                   	ret    

008000ea <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	57                   	push   %edi
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fb:	b8 03 00 00 00       	mov    $0x3,%eax
  800100:	89 cb                	mov    %ecx,%ebx
  800102:	89 cf                	mov    %ecx,%edi
  800104:	89 ce                	mov    %ecx,%esi
  800106:	cd 30                	int    $0x30
	if(check && ret > 0)
  800108:	85 c0                	test   %eax,%eax
  80010a:	7f 08                	jg     800114 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5f                   	pop    %edi
  800112:	5d                   	pop    %ebp
  800113:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	50                   	push   %eax
  800118:	6a 03                	push   $0x3
  80011a:	68 4a 22 80 00       	push   $0x80224a
  80011f:	6a 2a                	push   $0x2a
  800121:	68 67 22 80 00       	push   $0x802267
  800126:	e8 9e 13 00 00       	call   8014c9 <_panic>

0080012b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	57                   	push   %edi
  80012f:	56                   	push   %esi
  800130:	53                   	push   %ebx
	asm volatile("int %1\n"
  800131:	ba 00 00 00 00       	mov    $0x0,%edx
  800136:	b8 02 00 00 00       	mov    $0x2,%eax
  80013b:	89 d1                	mov    %edx,%ecx
  80013d:	89 d3                	mov    %edx,%ebx
  80013f:	89 d7                	mov    %edx,%edi
  800141:	89 d6                	mov    %edx,%esi
  800143:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5f                   	pop    %edi
  800148:	5d                   	pop    %ebp
  800149:	c3                   	ret    

0080014a <sys_yield>:

void
sys_yield(void)
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	57                   	push   %edi
  80014e:	56                   	push   %esi
  80014f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800150:	ba 00 00 00 00       	mov    $0x0,%edx
  800155:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015a:	89 d1                	mov    %edx,%ecx
  80015c:	89 d3                	mov    %edx,%ebx
  80015e:	89 d7                	mov    %edx,%edi
  800160:	89 d6                	mov    %edx,%esi
  800162:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800164:	5b                   	pop    %ebx
  800165:	5e                   	pop    %esi
  800166:	5f                   	pop    %edi
  800167:	5d                   	pop    %ebp
  800168:	c3                   	ret    

00800169 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	57                   	push   %edi
  80016d:	56                   	push   %esi
  80016e:	53                   	push   %ebx
  80016f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800172:	be 00 00 00 00       	mov    $0x0,%esi
  800177:	8b 55 08             	mov    0x8(%ebp),%edx
  80017a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017d:	b8 04 00 00 00       	mov    $0x4,%eax
  800182:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800185:	89 f7                	mov    %esi,%edi
  800187:	cd 30                	int    $0x30
	if(check && ret > 0)
  800189:	85 c0                	test   %eax,%eax
  80018b:	7f 08                	jg     800195 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800190:	5b                   	pop    %ebx
  800191:	5e                   	pop    %esi
  800192:	5f                   	pop    %edi
  800193:	5d                   	pop    %ebp
  800194:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	50                   	push   %eax
  800199:	6a 04                	push   $0x4
  80019b:	68 4a 22 80 00       	push   $0x80224a
  8001a0:	6a 2a                	push   $0x2a
  8001a2:	68 67 22 80 00       	push   $0x802267
  8001a7:	e8 1d 13 00 00       	call   8014c9 <_panic>

008001ac <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	57                   	push   %edi
  8001b0:	56                   	push   %esi
  8001b1:	53                   	push   %ebx
  8001b2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bb:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001cb:	85 c0                	test   %eax,%eax
  8001cd:	7f 08                	jg     8001d7 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d2:	5b                   	pop    %ebx
  8001d3:	5e                   	pop    %esi
  8001d4:	5f                   	pop    %edi
  8001d5:	5d                   	pop    %ebp
  8001d6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	50                   	push   %eax
  8001db:	6a 05                	push   $0x5
  8001dd:	68 4a 22 80 00       	push   $0x80224a
  8001e2:	6a 2a                	push   $0x2a
  8001e4:	68 67 22 80 00       	push   $0x802267
  8001e9:	e8 db 12 00 00       	call   8014c9 <_panic>

008001ee <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	57                   	push   %edi
  8001f2:	56                   	push   %esi
  8001f3:	53                   	push   %ebx
  8001f4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800202:	b8 06 00 00 00       	mov    $0x6,%eax
  800207:	89 df                	mov    %ebx,%edi
  800209:	89 de                	mov    %ebx,%esi
  80020b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80020d:	85 c0                	test   %eax,%eax
  80020f:	7f 08                	jg     800219 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800211:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800214:	5b                   	pop    %ebx
  800215:	5e                   	pop    %esi
  800216:	5f                   	pop    %edi
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800219:	83 ec 0c             	sub    $0xc,%esp
  80021c:	50                   	push   %eax
  80021d:	6a 06                	push   $0x6
  80021f:	68 4a 22 80 00       	push   $0x80224a
  800224:	6a 2a                	push   $0x2a
  800226:	68 67 22 80 00       	push   $0x802267
  80022b:	e8 99 12 00 00       	call   8014c9 <_panic>

00800230 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800239:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023e:	8b 55 08             	mov    0x8(%ebp),%edx
  800241:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800244:	b8 08 00 00 00       	mov    $0x8,%eax
  800249:	89 df                	mov    %ebx,%edi
  80024b:	89 de                	mov    %ebx,%esi
  80024d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80024f:	85 c0                	test   %eax,%eax
  800251:	7f 08                	jg     80025b <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800253:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800256:	5b                   	pop    %ebx
  800257:	5e                   	pop    %esi
  800258:	5f                   	pop    %edi
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80025b:	83 ec 0c             	sub    $0xc,%esp
  80025e:	50                   	push   %eax
  80025f:	6a 08                	push   $0x8
  800261:	68 4a 22 80 00       	push   $0x80224a
  800266:	6a 2a                	push   $0x2a
  800268:	68 67 22 80 00       	push   $0x802267
  80026d:	e8 57 12 00 00       	call   8014c9 <_panic>

00800272 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	57                   	push   %edi
  800276:	56                   	push   %esi
  800277:	53                   	push   %ebx
  800278:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80027b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800280:	8b 55 08             	mov    0x8(%ebp),%edx
  800283:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800286:	b8 09 00 00 00       	mov    $0x9,%eax
  80028b:	89 df                	mov    %ebx,%edi
  80028d:	89 de                	mov    %ebx,%esi
  80028f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800291:	85 c0                	test   %eax,%eax
  800293:	7f 08                	jg     80029d <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800295:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800298:	5b                   	pop    %ebx
  800299:	5e                   	pop    %esi
  80029a:	5f                   	pop    %edi
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80029d:	83 ec 0c             	sub    $0xc,%esp
  8002a0:	50                   	push   %eax
  8002a1:	6a 09                	push   $0x9
  8002a3:	68 4a 22 80 00       	push   $0x80224a
  8002a8:	6a 2a                	push   $0x2a
  8002aa:	68 67 22 80 00       	push   $0x802267
  8002af:	e8 15 12 00 00       	call   8014c9 <_panic>

008002b4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	57                   	push   %edi
  8002b8:	56                   	push   %esi
  8002b9:	53                   	push   %ebx
  8002ba:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002cd:	89 df                	mov    %ebx,%edi
  8002cf:	89 de                	mov    %ebx,%esi
  8002d1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d3:	85 c0                	test   %eax,%eax
  8002d5:	7f 08                	jg     8002df <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002da:	5b                   	pop    %ebx
  8002db:	5e                   	pop    %esi
  8002dc:	5f                   	pop    %edi
  8002dd:	5d                   	pop    %ebp
  8002de:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002df:	83 ec 0c             	sub    $0xc,%esp
  8002e2:	50                   	push   %eax
  8002e3:	6a 0a                	push   $0xa
  8002e5:	68 4a 22 80 00       	push   $0x80224a
  8002ea:	6a 2a                	push   $0x2a
  8002ec:	68 67 22 80 00       	push   $0x802267
  8002f1:	e8 d3 11 00 00       	call   8014c9 <_panic>

008002f6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	57                   	push   %edi
  8002fa:	56                   	push   %esi
  8002fb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800302:	b8 0c 00 00 00       	mov    $0xc,%eax
  800307:	be 00 00 00 00       	mov    $0x0,%esi
  80030c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800312:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800314:	5b                   	pop    %ebx
  800315:	5e                   	pop    %esi
  800316:	5f                   	pop    %edi
  800317:	5d                   	pop    %ebp
  800318:	c3                   	ret    

00800319 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	57                   	push   %edi
  80031d:	56                   	push   %esi
  80031e:	53                   	push   %ebx
  80031f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800322:	b9 00 00 00 00       	mov    $0x0,%ecx
  800327:	8b 55 08             	mov    0x8(%ebp),%edx
  80032a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032f:	89 cb                	mov    %ecx,%ebx
  800331:	89 cf                	mov    %ecx,%edi
  800333:	89 ce                	mov    %ecx,%esi
  800335:	cd 30                	int    $0x30
	if(check && ret > 0)
  800337:	85 c0                	test   %eax,%eax
  800339:	7f 08                	jg     800343 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033e:	5b                   	pop    %ebx
  80033f:	5e                   	pop    %esi
  800340:	5f                   	pop    %edi
  800341:	5d                   	pop    %ebp
  800342:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800343:	83 ec 0c             	sub    $0xc,%esp
  800346:	50                   	push   %eax
  800347:	6a 0d                	push   $0xd
  800349:	68 4a 22 80 00       	push   $0x80224a
  80034e:	6a 2a                	push   $0x2a
  800350:	68 67 22 80 00       	push   $0x802267
  800355:	e8 6f 11 00 00       	call   8014c9 <_panic>

0080035a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	57                   	push   %edi
  80035e:	56                   	push   %esi
  80035f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800360:	ba 00 00 00 00       	mov    $0x0,%edx
  800365:	b8 0e 00 00 00       	mov    $0xe,%eax
  80036a:	89 d1                	mov    %edx,%ecx
  80036c:	89 d3                	mov    %edx,%ebx
  80036e:	89 d7                	mov    %edx,%edi
  800370:	89 d6                	mov    %edx,%esi
  800372:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800374:	5b                   	pop    %ebx
  800375:	5e                   	pop    %esi
  800376:	5f                   	pop    %edi
  800377:	5d                   	pop    %ebp
  800378:	c3                   	ret    

00800379 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800379:	55                   	push   %ebp
  80037a:	89 e5                	mov    %esp,%ebp
  80037c:	57                   	push   %edi
  80037d:	56                   	push   %esi
  80037e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80037f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800384:	8b 55 08             	mov    0x8(%ebp),%edx
  800387:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038a:	b8 0f 00 00 00       	mov    $0xf,%eax
  80038f:	89 df                	mov    %ebx,%edi
  800391:	89 de                	mov    %ebx,%esi
  800393:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800395:	5b                   	pop    %ebx
  800396:	5e                   	pop    %esi
  800397:	5f                   	pop    %edi
  800398:	5d                   	pop    %ebp
  800399:	c3                   	ret    

0080039a <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	57                   	push   %edi
  80039e:	56                   	push   %esi
  80039f:	53                   	push   %ebx
	asm volatile("int %1\n"
  8003a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003ab:	b8 10 00 00 00       	mov    $0x10,%eax
  8003b0:	89 df                	mov    %ebx,%edi
  8003b2:	89 de                	mov    %ebx,%esi
  8003b4:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8003b6:	5b                   	pop    %ebx
  8003b7:	5e                   	pop    %esi
  8003b8:	5f                   	pop    %edi
  8003b9:	5d                   	pop    %ebp
  8003ba:	c3                   	ret    

008003bb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003be:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c1:	05 00 00 00 30       	add    $0x30000000,%eax
  8003c6:	c1 e8 0c             	shr    $0xc,%eax
}
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    

008003cb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d1:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003db:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003e0:	5d                   	pop    %ebp
  8003e1:	c3                   	ret    

008003e2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003e2:	55                   	push   %ebp
  8003e3:	89 e5                	mov    %esp,%ebp
  8003e5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003ea:	89 c2                	mov    %eax,%edx
  8003ec:	c1 ea 16             	shr    $0x16,%edx
  8003ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003f6:	f6 c2 01             	test   $0x1,%dl
  8003f9:	74 29                	je     800424 <fd_alloc+0x42>
  8003fb:	89 c2                	mov    %eax,%edx
  8003fd:	c1 ea 0c             	shr    $0xc,%edx
  800400:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800407:	f6 c2 01             	test   $0x1,%dl
  80040a:	74 18                	je     800424 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80040c:	05 00 10 00 00       	add    $0x1000,%eax
  800411:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800416:	75 d2                	jne    8003ea <fd_alloc+0x8>
  800418:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80041d:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800422:	eb 05                	jmp    800429 <fd_alloc+0x47>
			return 0;
  800424:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800429:	8b 55 08             	mov    0x8(%ebp),%edx
  80042c:	89 02                	mov    %eax,(%edx)
}
  80042e:	89 c8                	mov    %ecx,%eax
  800430:	5d                   	pop    %ebp
  800431:	c3                   	ret    

00800432 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800438:	83 f8 1f             	cmp    $0x1f,%eax
  80043b:	77 30                	ja     80046d <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80043d:	c1 e0 0c             	shl    $0xc,%eax
  800440:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800445:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80044b:	f6 c2 01             	test   $0x1,%dl
  80044e:	74 24                	je     800474 <fd_lookup+0x42>
  800450:	89 c2                	mov    %eax,%edx
  800452:	c1 ea 0c             	shr    $0xc,%edx
  800455:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80045c:	f6 c2 01             	test   $0x1,%dl
  80045f:	74 1a                	je     80047b <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800461:	8b 55 0c             	mov    0xc(%ebp),%edx
  800464:	89 02                	mov    %eax,(%edx)
	return 0;
  800466:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80046b:	5d                   	pop    %ebp
  80046c:	c3                   	ret    
		return -E_INVAL;
  80046d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800472:	eb f7                	jmp    80046b <fd_lookup+0x39>
		return -E_INVAL;
  800474:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800479:	eb f0                	jmp    80046b <fd_lookup+0x39>
  80047b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800480:	eb e9                	jmp    80046b <fd_lookup+0x39>

00800482 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800482:	55                   	push   %ebp
  800483:	89 e5                	mov    %esp,%ebp
  800485:	53                   	push   %ebx
  800486:	83 ec 04             	sub    $0x4,%esp
  800489:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80048c:	b8 00 00 00 00       	mov    $0x0,%eax
  800491:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800496:	39 13                	cmp    %edx,(%ebx)
  800498:	74 37                	je     8004d1 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  80049a:	83 c0 01             	add    $0x1,%eax
  80049d:	8b 1c 85 f4 22 80 00 	mov    0x8022f4(,%eax,4),%ebx
  8004a4:	85 db                	test   %ebx,%ebx
  8004a6:	75 ee                	jne    800496 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004a8:	a1 00 40 80 00       	mov    0x804000,%eax
  8004ad:	8b 40 58             	mov    0x58(%eax),%eax
  8004b0:	83 ec 04             	sub    $0x4,%esp
  8004b3:	52                   	push   %edx
  8004b4:	50                   	push   %eax
  8004b5:	68 78 22 80 00       	push   $0x802278
  8004ba:	e8 e5 10 00 00       	call   8015a4 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8004c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ca:	89 1a                	mov    %ebx,(%edx)
}
  8004cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004cf:	c9                   	leave  
  8004d0:	c3                   	ret    
			return 0;
  8004d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d6:	eb ef                	jmp    8004c7 <dev_lookup+0x45>

008004d8 <fd_close>:
{
  8004d8:	55                   	push   %ebp
  8004d9:	89 e5                	mov    %esp,%ebp
  8004db:	57                   	push   %edi
  8004dc:	56                   	push   %esi
  8004dd:	53                   	push   %ebx
  8004de:	83 ec 24             	sub    $0x24,%esp
  8004e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004ea:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004eb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004f1:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004f4:	50                   	push   %eax
  8004f5:	e8 38 ff ff ff       	call   800432 <fd_lookup>
  8004fa:	89 c3                	mov    %eax,%ebx
  8004fc:	83 c4 10             	add    $0x10,%esp
  8004ff:	85 c0                	test   %eax,%eax
  800501:	78 05                	js     800508 <fd_close+0x30>
	    || fd != fd2)
  800503:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800506:	74 16                	je     80051e <fd_close+0x46>
		return (must_exist ? r : 0);
  800508:	89 f8                	mov    %edi,%eax
  80050a:	84 c0                	test   %al,%al
  80050c:	b8 00 00 00 00       	mov    $0x0,%eax
  800511:	0f 44 d8             	cmove  %eax,%ebx
}
  800514:	89 d8                	mov    %ebx,%eax
  800516:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800519:	5b                   	pop    %ebx
  80051a:	5e                   	pop    %esi
  80051b:	5f                   	pop    %edi
  80051c:	5d                   	pop    %ebp
  80051d:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800524:	50                   	push   %eax
  800525:	ff 36                	push   (%esi)
  800527:	e8 56 ff ff ff       	call   800482 <dev_lookup>
  80052c:	89 c3                	mov    %eax,%ebx
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	85 c0                	test   %eax,%eax
  800533:	78 1a                	js     80054f <fd_close+0x77>
		if (dev->dev_close)
  800535:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800538:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80053b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800540:	85 c0                	test   %eax,%eax
  800542:	74 0b                	je     80054f <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800544:	83 ec 0c             	sub    $0xc,%esp
  800547:	56                   	push   %esi
  800548:	ff d0                	call   *%eax
  80054a:	89 c3                	mov    %eax,%ebx
  80054c:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	56                   	push   %esi
  800553:	6a 00                	push   $0x0
  800555:	e8 94 fc ff ff       	call   8001ee <sys_page_unmap>
	return r;
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	eb b5                	jmp    800514 <fd_close+0x3c>

0080055f <close>:

int
close(int fdnum)
{
  80055f:	55                   	push   %ebp
  800560:	89 e5                	mov    %esp,%ebp
  800562:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800565:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800568:	50                   	push   %eax
  800569:	ff 75 08             	push   0x8(%ebp)
  80056c:	e8 c1 fe ff ff       	call   800432 <fd_lookup>
  800571:	83 c4 10             	add    $0x10,%esp
  800574:	85 c0                	test   %eax,%eax
  800576:	79 02                	jns    80057a <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800578:	c9                   	leave  
  800579:	c3                   	ret    
		return fd_close(fd, 1);
  80057a:	83 ec 08             	sub    $0x8,%esp
  80057d:	6a 01                	push   $0x1
  80057f:	ff 75 f4             	push   -0xc(%ebp)
  800582:	e8 51 ff ff ff       	call   8004d8 <fd_close>
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	eb ec                	jmp    800578 <close+0x19>

0080058c <close_all>:

void
close_all(void)
{
  80058c:	55                   	push   %ebp
  80058d:	89 e5                	mov    %esp,%ebp
  80058f:	53                   	push   %ebx
  800590:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800593:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800598:	83 ec 0c             	sub    $0xc,%esp
  80059b:	53                   	push   %ebx
  80059c:	e8 be ff ff ff       	call   80055f <close>
	for (i = 0; i < MAXFD; i++)
  8005a1:	83 c3 01             	add    $0x1,%ebx
  8005a4:	83 c4 10             	add    $0x10,%esp
  8005a7:	83 fb 20             	cmp    $0x20,%ebx
  8005aa:	75 ec                	jne    800598 <close_all+0xc>
}
  8005ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005af:	c9                   	leave  
  8005b0:	c3                   	ret    

008005b1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005b1:	55                   	push   %ebp
  8005b2:	89 e5                	mov    %esp,%ebp
  8005b4:	57                   	push   %edi
  8005b5:	56                   	push   %esi
  8005b6:	53                   	push   %ebx
  8005b7:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005ba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005bd:	50                   	push   %eax
  8005be:	ff 75 08             	push   0x8(%ebp)
  8005c1:	e8 6c fe ff ff       	call   800432 <fd_lookup>
  8005c6:	89 c3                	mov    %eax,%ebx
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	78 7f                	js     80064e <dup+0x9d>
		return r;
	close(newfdnum);
  8005cf:	83 ec 0c             	sub    $0xc,%esp
  8005d2:	ff 75 0c             	push   0xc(%ebp)
  8005d5:	e8 85 ff ff ff       	call   80055f <close>

	newfd = INDEX2FD(newfdnum);
  8005da:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005dd:	c1 e6 0c             	shl    $0xc,%esi
  8005e0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e9:	89 3c 24             	mov    %edi,(%esp)
  8005ec:	e8 da fd ff ff       	call   8003cb <fd2data>
  8005f1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005f3:	89 34 24             	mov    %esi,(%esp)
  8005f6:	e8 d0 fd ff ff       	call   8003cb <fd2data>
  8005fb:	83 c4 10             	add    $0x10,%esp
  8005fe:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800601:	89 d8                	mov    %ebx,%eax
  800603:	c1 e8 16             	shr    $0x16,%eax
  800606:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80060d:	a8 01                	test   $0x1,%al
  80060f:	74 11                	je     800622 <dup+0x71>
  800611:	89 d8                	mov    %ebx,%eax
  800613:	c1 e8 0c             	shr    $0xc,%eax
  800616:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80061d:	f6 c2 01             	test   $0x1,%dl
  800620:	75 36                	jne    800658 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800622:	89 f8                	mov    %edi,%eax
  800624:	c1 e8 0c             	shr    $0xc,%eax
  800627:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80062e:	83 ec 0c             	sub    $0xc,%esp
  800631:	25 07 0e 00 00       	and    $0xe07,%eax
  800636:	50                   	push   %eax
  800637:	56                   	push   %esi
  800638:	6a 00                	push   $0x0
  80063a:	57                   	push   %edi
  80063b:	6a 00                	push   $0x0
  80063d:	e8 6a fb ff ff       	call   8001ac <sys_page_map>
  800642:	89 c3                	mov    %eax,%ebx
  800644:	83 c4 20             	add    $0x20,%esp
  800647:	85 c0                	test   %eax,%eax
  800649:	78 33                	js     80067e <dup+0xcd>
		goto err;

	return newfdnum;
  80064b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80064e:	89 d8                	mov    %ebx,%eax
  800650:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800653:	5b                   	pop    %ebx
  800654:	5e                   	pop    %esi
  800655:	5f                   	pop    %edi
  800656:	5d                   	pop    %ebp
  800657:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800658:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80065f:	83 ec 0c             	sub    $0xc,%esp
  800662:	25 07 0e 00 00       	and    $0xe07,%eax
  800667:	50                   	push   %eax
  800668:	ff 75 d4             	push   -0x2c(%ebp)
  80066b:	6a 00                	push   $0x0
  80066d:	53                   	push   %ebx
  80066e:	6a 00                	push   $0x0
  800670:	e8 37 fb ff ff       	call   8001ac <sys_page_map>
  800675:	89 c3                	mov    %eax,%ebx
  800677:	83 c4 20             	add    $0x20,%esp
  80067a:	85 c0                	test   %eax,%eax
  80067c:	79 a4                	jns    800622 <dup+0x71>
	sys_page_unmap(0, newfd);
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	56                   	push   %esi
  800682:	6a 00                	push   $0x0
  800684:	e8 65 fb ff ff       	call   8001ee <sys_page_unmap>
	sys_page_unmap(0, nva);
  800689:	83 c4 08             	add    $0x8,%esp
  80068c:	ff 75 d4             	push   -0x2c(%ebp)
  80068f:	6a 00                	push   $0x0
  800691:	e8 58 fb ff ff       	call   8001ee <sys_page_unmap>
	return r;
  800696:	83 c4 10             	add    $0x10,%esp
  800699:	eb b3                	jmp    80064e <dup+0x9d>

0080069b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80069b:	55                   	push   %ebp
  80069c:	89 e5                	mov    %esp,%ebp
  80069e:	56                   	push   %esi
  80069f:	53                   	push   %ebx
  8006a0:	83 ec 18             	sub    $0x18,%esp
  8006a3:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006a9:	50                   	push   %eax
  8006aa:	56                   	push   %esi
  8006ab:	e8 82 fd ff ff       	call   800432 <fd_lookup>
  8006b0:	83 c4 10             	add    $0x10,%esp
  8006b3:	85 c0                	test   %eax,%eax
  8006b5:	78 3c                	js     8006f3 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b7:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8006ba:	83 ec 08             	sub    $0x8,%esp
  8006bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006c0:	50                   	push   %eax
  8006c1:	ff 33                	push   (%ebx)
  8006c3:	e8 ba fd ff ff       	call   800482 <dev_lookup>
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	85 c0                	test   %eax,%eax
  8006cd:	78 24                	js     8006f3 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006cf:	8b 43 08             	mov    0x8(%ebx),%eax
  8006d2:	83 e0 03             	and    $0x3,%eax
  8006d5:	83 f8 01             	cmp    $0x1,%eax
  8006d8:	74 20                	je     8006fa <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006dd:	8b 40 08             	mov    0x8(%eax),%eax
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	74 37                	je     80071b <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006e4:	83 ec 04             	sub    $0x4,%esp
  8006e7:	ff 75 10             	push   0x10(%ebp)
  8006ea:	ff 75 0c             	push   0xc(%ebp)
  8006ed:	53                   	push   %ebx
  8006ee:	ff d0                	call   *%eax
  8006f0:	83 c4 10             	add    $0x10,%esp
}
  8006f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006f6:	5b                   	pop    %ebx
  8006f7:	5e                   	pop    %esi
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006fa:	a1 00 40 80 00       	mov    0x804000,%eax
  8006ff:	8b 40 58             	mov    0x58(%eax),%eax
  800702:	83 ec 04             	sub    $0x4,%esp
  800705:	56                   	push   %esi
  800706:	50                   	push   %eax
  800707:	68 b9 22 80 00       	push   $0x8022b9
  80070c:	e8 93 0e 00 00       	call   8015a4 <cprintf>
		return -E_INVAL;
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800719:	eb d8                	jmp    8006f3 <read+0x58>
		return -E_NOT_SUPP;
  80071b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800720:	eb d1                	jmp    8006f3 <read+0x58>

00800722 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	57                   	push   %edi
  800726:	56                   	push   %esi
  800727:	53                   	push   %ebx
  800728:	83 ec 0c             	sub    $0xc,%esp
  80072b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80072e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800731:	bb 00 00 00 00       	mov    $0x0,%ebx
  800736:	eb 02                	jmp    80073a <readn+0x18>
  800738:	01 c3                	add    %eax,%ebx
  80073a:	39 f3                	cmp    %esi,%ebx
  80073c:	73 21                	jae    80075f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80073e:	83 ec 04             	sub    $0x4,%esp
  800741:	89 f0                	mov    %esi,%eax
  800743:	29 d8                	sub    %ebx,%eax
  800745:	50                   	push   %eax
  800746:	89 d8                	mov    %ebx,%eax
  800748:	03 45 0c             	add    0xc(%ebp),%eax
  80074b:	50                   	push   %eax
  80074c:	57                   	push   %edi
  80074d:	e8 49 ff ff ff       	call   80069b <read>
		if (m < 0)
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	85 c0                	test   %eax,%eax
  800757:	78 04                	js     80075d <readn+0x3b>
			return m;
		if (m == 0)
  800759:	75 dd                	jne    800738 <readn+0x16>
  80075b:	eb 02                	jmp    80075f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80075d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80075f:	89 d8                	mov    %ebx,%eax
  800761:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800764:	5b                   	pop    %ebx
  800765:	5e                   	pop    %esi
  800766:	5f                   	pop    %edi
  800767:	5d                   	pop    %ebp
  800768:	c3                   	ret    

00800769 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	56                   	push   %esi
  80076d:	53                   	push   %ebx
  80076e:	83 ec 18             	sub    $0x18,%esp
  800771:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800774:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800777:	50                   	push   %eax
  800778:	53                   	push   %ebx
  800779:	e8 b4 fc ff ff       	call   800432 <fd_lookup>
  80077e:	83 c4 10             	add    $0x10,%esp
  800781:	85 c0                	test   %eax,%eax
  800783:	78 37                	js     8007bc <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800785:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800788:	83 ec 08             	sub    $0x8,%esp
  80078b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80078e:	50                   	push   %eax
  80078f:	ff 36                	push   (%esi)
  800791:	e8 ec fc ff ff       	call   800482 <dev_lookup>
  800796:	83 c4 10             	add    $0x10,%esp
  800799:	85 c0                	test   %eax,%eax
  80079b:	78 1f                	js     8007bc <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80079d:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8007a1:	74 20                	je     8007c3 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8007a9:	85 c0                	test   %eax,%eax
  8007ab:	74 37                	je     8007e4 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007ad:	83 ec 04             	sub    $0x4,%esp
  8007b0:	ff 75 10             	push   0x10(%ebp)
  8007b3:	ff 75 0c             	push   0xc(%ebp)
  8007b6:	56                   	push   %esi
  8007b7:	ff d0                	call   *%eax
  8007b9:	83 c4 10             	add    $0x10,%esp
}
  8007bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007bf:	5b                   	pop    %ebx
  8007c0:	5e                   	pop    %esi
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007c3:	a1 00 40 80 00       	mov    0x804000,%eax
  8007c8:	8b 40 58             	mov    0x58(%eax),%eax
  8007cb:	83 ec 04             	sub    $0x4,%esp
  8007ce:	53                   	push   %ebx
  8007cf:	50                   	push   %eax
  8007d0:	68 d5 22 80 00       	push   $0x8022d5
  8007d5:	e8 ca 0d 00 00       	call   8015a4 <cprintf>
		return -E_INVAL;
  8007da:	83 c4 10             	add    $0x10,%esp
  8007dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e2:	eb d8                	jmp    8007bc <write+0x53>
		return -E_NOT_SUPP;
  8007e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007e9:	eb d1                	jmp    8007bc <write+0x53>

008007eb <seek>:

int
seek(int fdnum, off_t offset)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f4:	50                   	push   %eax
  8007f5:	ff 75 08             	push   0x8(%ebp)
  8007f8:	e8 35 fc ff ff       	call   800432 <fd_lookup>
  8007fd:	83 c4 10             	add    $0x10,%esp
  800800:	85 c0                	test   %eax,%eax
  800802:	78 0e                	js     800812 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
  800807:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80080a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80080d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800812:	c9                   	leave  
  800813:	c3                   	ret    

00800814 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	56                   	push   %esi
  800818:	53                   	push   %ebx
  800819:	83 ec 18             	sub    $0x18,%esp
  80081c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80081f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800822:	50                   	push   %eax
  800823:	53                   	push   %ebx
  800824:	e8 09 fc ff ff       	call   800432 <fd_lookup>
  800829:	83 c4 10             	add    $0x10,%esp
  80082c:	85 c0                	test   %eax,%eax
  80082e:	78 34                	js     800864 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800830:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800833:	83 ec 08             	sub    $0x8,%esp
  800836:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800839:	50                   	push   %eax
  80083a:	ff 36                	push   (%esi)
  80083c:	e8 41 fc ff ff       	call   800482 <dev_lookup>
  800841:	83 c4 10             	add    $0x10,%esp
  800844:	85 c0                	test   %eax,%eax
  800846:	78 1c                	js     800864 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800848:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80084c:	74 1d                	je     80086b <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80084e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800851:	8b 40 18             	mov    0x18(%eax),%eax
  800854:	85 c0                	test   %eax,%eax
  800856:	74 34                	je     80088c <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800858:	83 ec 08             	sub    $0x8,%esp
  80085b:	ff 75 0c             	push   0xc(%ebp)
  80085e:	56                   	push   %esi
  80085f:	ff d0                	call   *%eax
  800861:	83 c4 10             	add    $0x10,%esp
}
  800864:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800867:	5b                   	pop    %ebx
  800868:	5e                   	pop    %esi
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    
			thisenv->env_id, fdnum);
  80086b:	a1 00 40 80 00       	mov    0x804000,%eax
  800870:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800873:	83 ec 04             	sub    $0x4,%esp
  800876:	53                   	push   %ebx
  800877:	50                   	push   %eax
  800878:	68 98 22 80 00       	push   $0x802298
  80087d:	e8 22 0d 00 00       	call   8015a4 <cprintf>
		return -E_INVAL;
  800882:	83 c4 10             	add    $0x10,%esp
  800885:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088a:	eb d8                	jmp    800864 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80088c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800891:	eb d1                	jmp    800864 <ftruncate+0x50>

00800893 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
  800898:	83 ec 18             	sub    $0x18,%esp
  80089b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80089e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a1:	50                   	push   %eax
  8008a2:	ff 75 08             	push   0x8(%ebp)
  8008a5:	e8 88 fb ff ff       	call   800432 <fd_lookup>
  8008aa:	83 c4 10             	add    $0x10,%esp
  8008ad:	85 c0                	test   %eax,%eax
  8008af:	78 49                	js     8008fa <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b1:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ba:	50                   	push   %eax
  8008bb:	ff 36                	push   (%esi)
  8008bd:	e8 c0 fb ff ff       	call   800482 <dev_lookup>
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	78 31                	js     8008fa <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8008c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008cc:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008d0:	74 2f                	je     800901 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008d2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008d5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008dc:	00 00 00 
	stat->st_isdir = 0;
  8008df:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008e6:	00 00 00 
	stat->st_dev = dev;
  8008e9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ef:	83 ec 08             	sub    $0x8,%esp
  8008f2:	53                   	push   %ebx
  8008f3:	56                   	push   %esi
  8008f4:	ff 50 14             	call   *0x14(%eax)
  8008f7:	83 c4 10             	add    $0x10,%esp
}
  8008fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008fd:	5b                   	pop    %ebx
  8008fe:	5e                   	pop    %esi
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    
		return -E_NOT_SUPP;
  800901:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800906:	eb f2                	jmp    8008fa <fstat+0x67>

00800908 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	56                   	push   %esi
  80090c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80090d:	83 ec 08             	sub    $0x8,%esp
  800910:	6a 00                	push   $0x0
  800912:	ff 75 08             	push   0x8(%ebp)
  800915:	e8 e4 01 00 00       	call   800afe <open>
  80091a:	89 c3                	mov    %eax,%ebx
  80091c:	83 c4 10             	add    $0x10,%esp
  80091f:	85 c0                	test   %eax,%eax
  800921:	78 1b                	js     80093e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800923:	83 ec 08             	sub    $0x8,%esp
  800926:	ff 75 0c             	push   0xc(%ebp)
  800929:	50                   	push   %eax
  80092a:	e8 64 ff ff ff       	call   800893 <fstat>
  80092f:	89 c6                	mov    %eax,%esi
	close(fd);
  800931:	89 1c 24             	mov    %ebx,(%esp)
  800934:	e8 26 fc ff ff       	call   80055f <close>
	return r;
  800939:	83 c4 10             	add    $0x10,%esp
  80093c:	89 f3                	mov    %esi,%ebx
}
  80093e:	89 d8                	mov    %ebx,%eax
  800940:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	56                   	push   %esi
  80094b:	53                   	push   %ebx
  80094c:	89 c6                	mov    %eax,%esi
  80094e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800950:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800957:	74 27                	je     800980 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800959:	6a 07                	push   $0x7
  80095b:	68 00 50 80 00       	push   $0x805000
  800960:	56                   	push   %esi
  800961:	ff 35 00 60 80 00    	push   0x806000
  800967:	e8 c2 15 00 00       	call   801f2e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80096c:	83 c4 0c             	add    $0xc,%esp
  80096f:	6a 00                	push   $0x0
  800971:	53                   	push   %ebx
  800972:	6a 00                	push   $0x0
  800974:	e8 45 15 00 00       	call   801ebe <ipc_recv>
}
  800979:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80097c:	5b                   	pop    %ebx
  80097d:	5e                   	pop    %esi
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800980:	83 ec 0c             	sub    $0xc,%esp
  800983:	6a 01                	push   $0x1
  800985:	e8 f8 15 00 00       	call   801f82 <ipc_find_env>
  80098a:	a3 00 60 80 00       	mov    %eax,0x806000
  80098f:	83 c4 10             	add    $0x10,%esp
  800992:	eb c5                	jmp    800959 <fsipc+0x12>

00800994 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b2:	b8 02 00 00 00       	mov    $0x2,%eax
  8009b7:	e8 8b ff ff ff       	call   800947 <fsipc>
}
  8009bc:	c9                   	leave  
  8009bd:	c3                   	ret    

008009be <devfile_flush>:
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ca:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d4:	b8 06 00 00 00       	mov    $0x6,%eax
  8009d9:	e8 69 ff ff ff       	call   800947 <fsipc>
}
  8009de:	c9                   	leave  
  8009df:	c3                   	ret    

008009e0 <devfile_stat>:
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	53                   	push   %ebx
  8009e4:	83 ec 04             	sub    $0x4,%esp
  8009e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fa:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ff:	e8 43 ff ff ff       	call   800947 <fsipc>
  800a04:	85 c0                	test   %eax,%eax
  800a06:	78 2c                	js     800a34 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a08:	83 ec 08             	sub    $0x8,%esp
  800a0b:	68 00 50 80 00       	push   $0x805000
  800a10:	53                   	push   %ebx
  800a11:	e8 68 11 00 00       	call   801b7e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a16:	a1 80 50 80 00       	mov    0x805080,%eax
  800a1b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a21:	a1 84 50 80 00       	mov    0x805084,%eax
  800a26:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a2c:	83 c4 10             	add    $0x10,%esp
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a37:	c9                   	leave  
  800a38:	c3                   	ret    

00800a39 <devfile_write>:
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	83 ec 0c             	sub    $0xc,%esp
  800a3f:	8b 45 10             	mov    0x10(%ebp),%eax
  800a42:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a47:	39 d0                	cmp    %edx,%eax
  800a49:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4f:	8b 52 0c             	mov    0xc(%edx),%edx
  800a52:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a58:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a5d:	50                   	push   %eax
  800a5e:	ff 75 0c             	push   0xc(%ebp)
  800a61:	68 08 50 80 00       	push   $0x805008
  800a66:	e8 a9 12 00 00       	call   801d14 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a70:	b8 04 00 00 00       	mov    $0x4,%eax
  800a75:	e8 cd fe ff ff       	call   800947 <fsipc>
}
  800a7a:	c9                   	leave  
  800a7b:	c3                   	ret    

00800a7c <devfile_read>:
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a8f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a95:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9f:	e8 a3 fe ff ff       	call   800947 <fsipc>
  800aa4:	89 c3                	mov    %eax,%ebx
  800aa6:	85 c0                	test   %eax,%eax
  800aa8:	78 1f                	js     800ac9 <devfile_read+0x4d>
	assert(r <= n);
  800aaa:	39 f0                	cmp    %esi,%eax
  800aac:	77 24                	ja     800ad2 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800aae:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ab3:	7f 33                	jg     800ae8 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ab5:	83 ec 04             	sub    $0x4,%esp
  800ab8:	50                   	push   %eax
  800ab9:	68 00 50 80 00       	push   $0x805000
  800abe:	ff 75 0c             	push   0xc(%ebp)
  800ac1:	e8 4e 12 00 00       	call   801d14 <memmove>
	return r;
  800ac6:	83 c4 10             	add    $0x10,%esp
}
  800ac9:	89 d8                	mov    %ebx,%eax
  800acb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    
	assert(r <= n);
  800ad2:	68 08 23 80 00       	push   $0x802308
  800ad7:	68 0f 23 80 00       	push   $0x80230f
  800adc:	6a 7c                	push   $0x7c
  800ade:	68 24 23 80 00       	push   $0x802324
  800ae3:	e8 e1 09 00 00       	call   8014c9 <_panic>
	assert(r <= PGSIZE);
  800ae8:	68 2f 23 80 00       	push   $0x80232f
  800aed:	68 0f 23 80 00       	push   $0x80230f
  800af2:	6a 7d                	push   $0x7d
  800af4:	68 24 23 80 00       	push   $0x802324
  800af9:	e8 cb 09 00 00       	call   8014c9 <_panic>

00800afe <open>:
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	83 ec 1c             	sub    $0x1c,%esp
  800b06:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b09:	56                   	push   %esi
  800b0a:	e8 34 10 00 00       	call   801b43 <strlen>
  800b0f:	83 c4 10             	add    $0x10,%esp
  800b12:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b17:	7f 6c                	jg     800b85 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800b19:	83 ec 0c             	sub    $0xc,%esp
  800b1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b1f:	50                   	push   %eax
  800b20:	e8 bd f8 ff ff       	call   8003e2 <fd_alloc>
  800b25:	89 c3                	mov    %eax,%ebx
  800b27:	83 c4 10             	add    $0x10,%esp
  800b2a:	85 c0                	test   %eax,%eax
  800b2c:	78 3c                	js     800b6a <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800b2e:	83 ec 08             	sub    $0x8,%esp
  800b31:	56                   	push   %esi
  800b32:	68 00 50 80 00       	push   $0x805000
  800b37:	e8 42 10 00 00       	call   801b7e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3f:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b44:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b47:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4c:	e8 f6 fd ff ff       	call   800947 <fsipc>
  800b51:	89 c3                	mov    %eax,%ebx
  800b53:	83 c4 10             	add    $0x10,%esp
  800b56:	85 c0                	test   %eax,%eax
  800b58:	78 19                	js     800b73 <open+0x75>
	return fd2num(fd);
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	ff 75 f4             	push   -0xc(%ebp)
  800b60:	e8 56 f8 ff ff       	call   8003bb <fd2num>
  800b65:	89 c3                	mov    %eax,%ebx
  800b67:	83 c4 10             	add    $0x10,%esp
}
  800b6a:	89 d8                	mov    %ebx,%eax
  800b6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    
		fd_close(fd, 0);
  800b73:	83 ec 08             	sub    $0x8,%esp
  800b76:	6a 00                	push   $0x0
  800b78:	ff 75 f4             	push   -0xc(%ebp)
  800b7b:	e8 58 f9 ff ff       	call   8004d8 <fd_close>
		return r;
  800b80:	83 c4 10             	add    $0x10,%esp
  800b83:	eb e5                	jmp    800b6a <open+0x6c>
		return -E_BAD_PATH;
  800b85:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b8a:	eb de                	jmp    800b6a <open+0x6c>

00800b8c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b92:	ba 00 00 00 00       	mov    $0x0,%edx
  800b97:	b8 08 00 00 00       	mov    $0x8,%eax
  800b9c:	e8 a6 fd ff ff       	call   800947 <fsipc>
}
  800ba1:	c9                   	leave  
  800ba2:	c3                   	ret    

00800ba3 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800ba9:	68 3b 23 80 00       	push   $0x80233b
  800bae:	ff 75 0c             	push   0xc(%ebp)
  800bb1:	e8 c8 0f 00 00       	call   801b7e <strcpy>
	return 0;
}
  800bb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbb:	c9                   	leave  
  800bbc:	c3                   	ret    

00800bbd <devsock_close>:
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	53                   	push   %ebx
  800bc1:	83 ec 10             	sub    $0x10,%esp
  800bc4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bc7:	53                   	push   %ebx
  800bc8:	e8 f4 13 00 00       	call   801fc1 <pageref>
  800bcd:	89 c2                	mov    %eax,%edx
  800bcf:	83 c4 10             	add    $0x10,%esp
		return 0;
  800bd2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800bd7:	83 fa 01             	cmp    $0x1,%edx
  800bda:	74 05                	je     800be1 <devsock_close+0x24>
}
  800bdc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bdf:	c9                   	leave  
  800be0:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800be1:	83 ec 0c             	sub    $0xc,%esp
  800be4:	ff 73 0c             	push   0xc(%ebx)
  800be7:	e8 b7 02 00 00       	call   800ea3 <nsipc_close>
  800bec:	83 c4 10             	add    $0x10,%esp
  800bef:	eb eb                	jmp    800bdc <devsock_close+0x1f>

00800bf1 <devsock_write>:
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bf7:	6a 00                	push   $0x0
  800bf9:	ff 75 10             	push   0x10(%ebp)
  800bfc:	ff 75 0c             	push   0xc(%ebp)
  800bff:	8b 45 08             	mov    0x8(%ebp),%eax
  800c02:	ff 70 0c             	push   0xc(%eax)
  800c05:	e8 79 03 00 00       	call   800f83 <nsipc_send>
}
  800c0a:	c9                   	leave  
  800c0b:	c3                   	ret    

00800c0c <devsock_read>:
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c12:	6a 00                	push   $0x0
  800c14:	ff 75 10             	push   0x10(%ebp)
  800c17:	ff 75 0c             	push   0xc(%ebp)
  800c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1d:	ff 70 0c             	push   0xc(%eax)
  800c20:	e8 ef 02 00 00       	call   800f14 <nsipc_recv>
}
  800c25:	c9                   	leave  
  800c26:	c3                   	ret    

00800c27 <fd2sockid>:
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c2d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c30:	52                   	push   %edx
  800c31:	50                   	push   %eax
  800c32:	e8 fb f7 ff ff       	call   800432 <fd_lookup>
  800c37:	83 c4 10             	add    $0x10,%esp
  800c3a:	85 c0                	test   %eax,%eax
  800c3c:	78 10                	js     800c4e <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c41:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c47:	39 08                	cmp    %ecx,(%eax)
  800c49:	75 05                	jne    800c50 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c4b:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c4e:	c9                   	leave  
  800c4f:	c3                   	ret    
		return -E_NOT_SUPP;
  800c50:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c55:	eb f7                	jmp    800c4e <fd2sockid+0x27>

00800c57 <alloc_sockfd>:
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
  800c5c:	83 ec 1c             	sub    $0x1c,%esp
  800c5f:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c64:	50                   	push   %eax
  800c65:	e8 78 f7 ff ff       	call   8003e2 <fd_alloc>
  800c6a:	89 c3                	mov    %eax,%ebx
  800c6c:	83 c4 10             	add    $0x10,%esp
  800c6f:	85 c0                	test   %eax,%eax
  800c71:	78 43                	js     800cb6 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c73:	83 ec 04             	sub    $0x4,%esp
  800c76:	68 07 04 00 00       	push   $0x407
  800c7b:	ff 75 f4             	push   -0xc(%ebp)
  800c7e:	6a 00                	push   $0x0
  800c80:	e8 e4 f4 ff ff       	call   800169 <sys_page_alloc>
  800c85:	89 c3                	mov    %eax,%ebx
  800c87:	83 c4 10             	add    $0x10,%esp
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	78 28                	js     800cb6 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c91:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c97:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c9c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800ca3:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ca6:	83 ec 0c             	sub    $0xc,%esp
  800ca9:	50                   	push   %eax
  800caa:	e8 0c f7 ff ff       	call   8003bb <fd2num>
  800caf:	89 c3                	mov    %eax,%ebx
  800cb1:	83 c4 10             	add    $0x10,%esp
  800cb4:	eb 0c                	jmp    800cc2 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800cb6:	83 ec 0c             	sub    $0xc,%esp
  800cb9:	56                   	push   %esi
  800cba:	e8 e4 01 00 00       	call   800ea3 <nsipc_close>
		return r;
  800cbf:	83 c4 10             	add    $0x10,%esp
}
  800cc2:	89 d8                	mov    %ebx,%eax
  800cc4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <accept>:
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd4:	e8 4e ff ff ff       	call   800c27 <fd2sockid>
  800cd9:	85 c0                	test   %eax,%eax
  800cdb:	78 1b                	js     800cf8 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cdd:	83 ec 04             	sub    $0x4,%esp
  800ce0:	ff 75 10             	push   0x10(%ebp)
  800ce3:	ff 75 0c             	push   0xc(%ebp)
  800ce6:	50                   	push   %eax
  800ce7:	e8 0e 01 00 00       	call   800dfa <nsipc_accept>
  800cec:	83 c4 10             	add    $0x10,%esp
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	78 05                	js     800cf8 <accept+0x2d>
	return alloc_sockfd(r);
  800cf3:	e8 5f ff ff ff       	call   800c57 <alloc_sockfd>
}
  800cf8:	c9                   	leave  
  800cf9:	c3                   	ret    

00800cfa <bind>:
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d00:	8b 45 08             	mov    0x8(%ebp),%eax
  800d03:	e8 1f ff ff ff       	call   800c27 <fd2sockid>
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	78 12                	js     800d1e <bind+0x24>
	return nsipc_bind(r, name, namelen);
  800d0c:	83 ec 04             	sub    $0x4,%esp
  800d0f:	ff 75 10             	push   0x10(%ebp)
  800d12:	ff 75 0c             	push   0xc(%ebp)
  800d15:	50                   	push   %eax
  800d16:	e8 31 01 00 00       	call   800e4c <nsipc_bind>
  800d1b:	83 c4 10             	add    $0x10,%esp
}
  800d1e:	c9                   	leave  
  800d1f:	c3                   	ret    

00800d20 <shutdown>:
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d26:	8b 45 08             	mov    0x8(%ebp),%eax
  800d29:	e8 f9 fe ff ff       	call   800c27 <fd2sockid>
  800d2e:	85 c0                	test   %eax,%eax
  800d30:	78 0f                	js     800d41 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  800d32:	83 ec 08             	sub    $0x8,%esp
  800d35:	ff 75 0c             	push   0xc(%ebp)
  800d38:	50                   	push   %eax
  800d39:	e8 43 01 00 00       	call   800e81 <nsipc_shutdown>
  800d3e:	83 c4 10             	add    $0x10,%esp
}
  800d41:	c9                   	leave  
  800d42:	c3                   	ret    

00800d43 <connect>:
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d49:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4c:	e8 d6 fe ff ff       	call   800c27 <fd2sockid>
  800d51:	85 c0                	test   %eax,%eax
  800d53:	78 12                	js     800d67 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  800d55:	83 ec 04             	sub    $0x4,%esp
  800d58:	ff 75 10             	push   0x10(%ebp)
  800d5b:	ff 75 0c             	push   0xc(%ebp)
  800d5e:	50                   	push   %eax
  800d5f:	e8 59 01 00 00       	call   800ebd <nsipc_connect>
  800d64:	83 c4 10             	add    $0x10,%esp
}
  800d67:	c9                   	leave  
  800d68:	c3                   	ret    

00800d69 <listen>:
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d72:	e8 b0 fe ff ff       	call   800c27 <fd2sockid>
  800d77:	85 c0                	test   %eax,%eax
  800d79:	78 0f                	js     800d8a <listen+0x21>
	return nsipc_listen(r, backlog);
  800d7b:	83 ec 08             	sub    $0x8,%esp
  800d7e:	ff 75 0c             	push   0xc(%ebp)
  800d81:	50                   	push   %eax
  800d82:	e8 6b 01 00 00       	call   800ef2 <nsipc_listen>
  800d87:	83 c4 10             	add    $0x10,%esp
}
  800d8a:	c9                   	leave  
  800d8b:	c3                   	ret    

00800d8c <socket>:

int
socket(int domain, int type, int protocol)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d92:	ff 75 10             	push   0x10(%ebp)
  800d95:	ff 75 0c             	push   0xc(%ebp)
  800d98:	ff 75 08             	push   0x8(%ebp)
  800d9b:	e8 41 02 00 00       	call   800fe1 <nsipc_socket>
  800da0:	83 c4 10             	add    $0x10,%esp
  800da3:	85 c0                	test   %eax,%eax
  800da5:	78 05                	js     800dac <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800da7:	e8 ab fe ff ff       	call   800c57 <alloc_sockfd>
}
  800dac:	c9                   	leave  
  800dad:	c3                   	ret    

00800dae <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	53                   	push   %ebx
  800db2:	83 ec 04             	sub    $0x4,%esp
  800db5:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800db7:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  800dbe:	74 26                	je     800de6 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dc0:	6a 07                	push   $0x7
  800dc2:	68 00 70 80 00       	push   $0x807000
  800dc7:	53                   	push   %ebx
  800dc8:	ff 35 00 80 80 00    	push   0x808000
  800dce:	e8 5b 11 00 00       	call   801f2e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dd3:	83 c4 0c             	add    $0xc,%esp
  800dd6:	6a 00                	push   $0x0
  800dd8:	6a 00                	push   $0x0
  800dda:	6a 00                	push   $0x0
  800ddc:	e8 dd 10 00 00       	call   801ebe <ipc_recv>
}
  800de1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800de4:	c9                   	leave  
  800de5:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800de6:	83 ec 0c             	sub    $0xc,%esp
  800de9:	6a 02                	push   $0x2
  800deb:	e8 92 11 00 00       	call   801f82 <ipc_find_env>
  800df0:	a3 00 80 80 00       	mov    %eax,0x808000
  800df5:	83 c4 10             	add    $0x10,%esp
  800df8:	eb c6                	jmp    800dc0 <nsipc+0x12>

00800dfa <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	56                   	push   %esi
  800dfe:	53                   	push   %ebx
  800dff:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e02:	8b 45 08             	mov    0x8(%ebp),%eax
  800e05:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e0a:	8b 06                	mov    (%esi),%eax
  800e0c:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e11:	b8 01 00 00 00       	mov    $0x1,%eax
  800e16:	e8 93 ff ff ff       	call   800dae <nsipc>
  800e1b:	89 c3                	mov    %eax,%ebx
  800e1d:	85 c0                	test   %eax,%eax
  800e1f:	79 09                	jns    800e2a <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800e21:	89 d8                	mov    %ebx,%eax
  800e23:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e26:	5b                   	pop    %ebx
  800e27:	5e                   	pop    %esi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e2a:	83 ec 04             	sub    $0x4,%esp
  800e2d:	ff 35 10 70 80 00    	push   0x807010
  800e33:	68 00 70 80 00       	push   $0x807000
  800e38:	ff 75 0c             	push   0xc(%ebp)
  800e3b:	e8 d4 0e 00 00       	call   801d14 <memmove>
		*addrlen = ret->ret_addrlen;
  800e40:	a1 10 70 80 00       	mov    0x807010,%eax
  800e45:	89 06                	mov    %eax,(%esi)
  800e47:	83 c4 10             	add    $0x10,%esp
	return r;
  800e4a:	eb d5                	jmp    800e21 <nsipc_accept+0x27>

00800e4c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	53                   	push   %ebx
  800e50:	83 ec 08             	sub    $0x8,%esp
  800e53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e56:	8b 45 08             	mov    0x8(%ebp),%eax
  800e59:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e5e:	53                   	push   %ebx
  800e5f:	ff 75 0c             	push   0xc(%ebp)
  800e62:	68 04 70 80 00       	push   $0x807004
  800e67:	e8 a8 0e 00 00       	call   801d14 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e6c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  800e72:	b8 02 00 00 00       	mov    $0x2,%eax
  800e77:	e8 32 ff ff ff       	call   800dae <nsipc>
}
  800e7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e7f:	c9                   	leave  
  800e80:	c3                   	ret    

00800e81 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e87:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  800e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e92:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  800e97:	b8 03 00 00 00       	mov    $0x3,%eax
  800e9c:	e8 0d ff ff ff       	call   800dae <nsipc>
}
  800ea1:	c9                   	leave  
  800ea2:	c3                   	ret    

00800ea3 <nsipc_close>:

int
nsipc_close(int s)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ea9:	8b 45 08             	mov    0x8(%ebp),%eax
  800eac:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  800eb1:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb6:	e8 f3 fe ff ff       	call   800dae <nsipc>
}
  800ebb:	c9                   	leave  
  800ebc:	c3                   	ret    

00800ebd <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	53                   	push   %ebx
  800ec1:	83 ec 08             	sub    $0x8,%esp
  800ec4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eca:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ecf:	53                   	push   %ebx
  800ed0:	ff 75 0c             	push   0xc(%ebp)
  800ed3:	68 04 70 80 00       	push   $0x807004
  800ed8:	e8 37 0e 00 00       	call   801d14 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800edd:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  800ee3:	b8 05 00 00 00       	mov    $0x5,%eax
  800ee8:	e8 c1 fe ff ff       	call   800dae <nsipc>
}
  800eed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef0:	c9                   	leave  
  800ef1:	c3                   	ret    

00800ef2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ef8:	8b 45 08             	mov    0x8(%ebp),%eax
  800efb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  800f00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f03:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  800f08:	b8 06 00 00 00       	mov    $0x6,%eax
  800f0d:	e8 9c fe ff ff       	call   800dae <nsipc>
}
  800f12:	c9                   	leave  
  800f13:	c3                   	ret    

00800f14 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	56                   	push   %esi
  800f18:	53                   	push   %ebx
  800f19:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  800f24:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  800f2a:	8b 45 14             	mov    0x14(%ebp),%eax
  800f2d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f32:	b8 07 00 00 00       	mov    $0x7,%eax
  800f37:	e8 72 fe ff ff       	call   800dae <nsipc>
  800f3c:	89 c3                	mov    %eax,%ebx
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	78 22                	js     800f64 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  800f42:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f47:	39 c6                	cmp    %eax,%esi
  800f49:	0f 4e c6             	cmovle %esi,%eax
  800f4c:	39 c3                	cmp    %eax,%ebx
  800f4e:	7f 1d                	jg     800f6d <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f50:	83 ec 04             	sub    $0x4,%esp
  800f53:	53                   	push   %ebx
  800f54:	68 00 70 80 00       	push   $0x807000
  800f59:	ff 75 0c             	push   0xc(%ebp)
  800f5c:	e8 b3 0d 00 00       	call   801d14 <memmove>
  800f61:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f64:	89 d8                	mov    %ebx,%eax
  800f66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f69:	5b                   	pop    %ebx
  800f6a:	5e                   	pop    %esi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f6d:	68 47 23 80 00       	push   $0x802347
  800f72:	68 0f 23 80 00       	push   $0x80230f
  800f77:	6a 62                	push   $0x62
  800f79:	68 5c 23 80 00       	push   $0x80235c
  800f7e:	e8 46 05 00 00       	call   8014c9 <_panic>

00800f83 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	53                   	push   %ebx
  800f87:	83 ec 04             	sub    $0x4,%esp
  800f8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f90:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  800f95:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f9b:	7f 2e                	jg     800fcb <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f9d:	83 ec 04             	sub    $0x4,%esp
  800fa0:	53                   	push   %ebx
  800fa1:	ff 75 0c             	push   0xc(%ebp)
  800fa4:	68 0c 70 80 00       	push   $0x80700c
  800fa9:	e8 66 0d 00 00       	call   801d14 <memmove>
	nsipcbuf.send.req_size = size;
  800fae:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  800fb4:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb7:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  800fbc:	b8 08 00 00 00       	mov    $0x8,%eax
  800fc1:	e8 e8 fd ff ff       	call   800dae <nsipc>
}
  800fc6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc9:	c9                   	leave  
  800fca:	c3                   	ret    
	assert(size < 1600);
  800fcb:	68 68 23 80 00       	push   $0x802368
  800fd0:	68 0f 23 80 00       	push   $0x80230f
  800fd5:	6a 6d                	push   $0x6d
  800fd7:	68 5c 23 80 00       	push   $0x80235c
  800fdc:	e8 e8 04 00 00       	call   8014c9 <_panic>

00800fe1 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fe7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fea:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  800fef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff2:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  800ff7:	8b 45 10             	mov    0x10(%ebp),%eax
  800ffa:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  800fff:	b8 09 00 00 00       	mov    $0x9,%eax
  801004:	e8 a5 fd ff ff       	call   800dae <nsipc>
}
  801009:	c9                   	leave  
  80100a:	c3                   	ret    

0080100b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	56                   	push   %esi
  80100f:	53                   	push   %ebx
  801010:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801013:	83 ec 0c             	sub    $0xc,%esp
  801016:	ff 75 08             	push   0x8(%ebp)
  801019:	e8 ad f3 ff ff       	call   8003cb <fd2data>
  80101e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801020:	83 c4 08             	add    $0x8,%esp
  801023:	68 74 23 80 00       	push   $0x802374
  801028:	53                   	push   %ebx
  801029:	e8 50 0b 00 00       	call   801b7e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80102e:	8b 46 04             	mov    0x4(%esi),%eax
  801031:	2b 06                	sub    (%esi),%eax
  801033:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801039:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801040:	00 00 00 
	stat->st_dev = &devpipe;
  801043:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80104a:	30 80 00 
	return 0;
}
  80104d:	b8 00 00 00 00       	mov    $0x0,%eax
  801052:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801055:	5b                   	pop    %ebx
  801056:	5e                   	pop    %esi
  801057:	5d                   	pop    %ebp
  801058:	c3                   	ret    

00801059 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	53                   	push   %ebx
  80105d:	83 ec 0c             	sub    $0xc,%esp
  801060:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801063:	53                   	push   %ebx
  801064:	6a 00                	push   $0x0
  801066:	e8 83 f1 ff ff       	call   8001ee <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80106b:	89 1c 24             	mov    %ebx,(%esp)
  80106e:	e8 58 f3 ff ff       	call   8003cb <fd2data>
  801073:	83 c4 08             	add    $0x8,%esp
  801076:	50                   	push   %eax
  801077:	6a 00                	push   $0x0
  801079:	e8 70 f1 ff ff       	call   8001ee <sys_page_unmap>
}
  80107e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801081:	c9                   	leave  
  801082:	c3                   	ret    

00801083 <_pipeisclosed>:
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	57                   	push   %edi
  801087:	56                   	push   %esi
  801088:	53                   	push   %ebx
  801089:	83 ec 1c             	sub    $0x1c,%esp
  80108c:	89 c7                	mov    %eax,%edi
  80108e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801090:	a1 00 40 80 00       	mov    0x804000,%eax
  801095:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801098:	83 ec 0c             	sub    $0xc,%esp
  80109b:	57                   	push   %edi
  80109c:	e8 20 0f 00 00       	call   801fc1 <pageref>
  8010a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010a4:	89 34 24             	mov    %esi,(%esp)
  8010a7:	e8 15 0f 00 00       	call   801fc1 <pageref>
		nn = thisenv->env_runs;
  8010ac:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8010b2:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  8010b5:	83 c4 10             	add    $0x10,%esp
  8010b8:	39 cb                	cmp    %ecx,%ebx
  8010ba:	74 1b                	je     8010d7 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010bc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010bf:	75 cf                	jne    801090 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010c1:	8b 42 68             	mov    0x68(%edx),%eax
  8010c4:	6a 01                	push   $0x1
  8010c6:	50                   	push   %eax
  8010c7:	53                   	push   %ebx
  8010c8:	68 7b 23 80 00       	push   $0x80237b
  8010cd:	e8 d2 04 00 00       	call   8015a4 <cprintf>
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	eb b9                	jmp    801090 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010d7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010da:	0f 94 c0             	sete   %al
  8010dd:	0f b6 c0             	movzbl %al,%eax
}
  8010e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e3:	5b                   	pop    %ebx
  8010e4:	5e                   	pop    %esi
  8010e5:	5f                   	pop    %edi
  8010e6:	5d                   	pop    %ebp
  8010e7:	c3                   	ret    

008010e8 <devpipe_write>:
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	57                   	push   %edi
  8010ec:	56                   	push   %esi
  8010ed:	53                   	push   %ebx
  8010ee:	83 ec 28             	sub    $0x28,%esp
  8010f1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8010f4:	56                   	push   %esi
  8010f5:	e8 d1 f2 ff ff       	call   8003cb <fd2data>
  8010fa:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8010fc:	83 c4 10             	add    $0x10,%esp
  8010ff:	bf 00 00 00 00       	mov    $0x0,%edi
  801104:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801107:	75 09                	jne    801112 <devpipe_write+0x2a>
	return i;
  801109:	89 f8                	mov    %edi,%eax
  80110b:	eb 23                	jmp    801130 <devpipe_write+0x48>
			sys_yield();
  80110d:	e8 38 f0 ff ff       	call   80014a <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801112:	8b 43 04             	mov    0x4(%ebx),%eax
  801115:	8b 0b                	mov    (%ebx),%ecx
  801117:	8d 51 20             	lea    0x20(%ecx),%edx
  80111a:	39 d0                	cmp    %edx,%eax
  80111c:	72 1a                	jb     801138 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80111e:	89 da                	mov    %ebx,%edx
  801120:	89 f0                	mov    %esi,%eax
  801122:	e8 5c ff ff ff       	call   801083 <_pipeisclosed>
  801127:	85 c0                	test   %eax,%eax
  801129:	74 e2                	je     80110d <devpipe_write+0x25>
				return 0;
  80112b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801130:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801133:	5b                   	pop    %ebx
  801134:	5e                   	pop    %esi
  801135:	5f                   	pop    %edi
  801136:	5d                   	pop    %ebp
  801137:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801138:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80113f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801142:	89 c2                	mov    %eax,%edx
  801144:	c1 fa 1f             	sar    $0x1f,%edx
  801147:	89 d1                	mov    %edx,%ecx
  801149:	c1 e9 1b             	shr    $0x1b,%ecx
  80114c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80114f:	83 e2 1f             	and    $0x1f,%edx
  801152:	29 ca                	sub    %ecx,%edx
  801154:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801158:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80115c:	83 c0 01             	add    $0x1,%eax
  80115f:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801162:	83 c7 01             	add    $0x1,%edi
  801165:	eb 9d                	jmp    801104 <devpipe_write+0x1c>

00801167 <devpipe_read>:
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	57                   	push   %edi
  80116b:	56                   	push   %esi
  80116c:	53                   	push   %ebx
  80116d:	83 ec 18             	sub    $0x18,%esp
  801170:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801173:	57                   	push   %edi
  801174:	e8 52 f2 ff ff       	call   8003cb <fd2data>
  801179:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80117b:	83 c4 10             	add    $0x10,%esp
  80117e:	be 00 00 00 00       	mov    $0x0,%esi
  801183:	3b 75 10             	cmp    0x10(%ebp),%esi
  801186:	75 13                	jne    80119b <devpipe_read+0x34>
	return i;
  801188:	89 f0                	mov    %esi,%eax
  80118a:	eb 02                	jmp    80118e <devpipe_read+0x27>
				return i;
  80118c:	89 f0                	mov    %esi,%eax
}
  80118e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801191:	5b                   	pop    %ebx
  801192:	5e                   	pop    %esi
  801193:	5f                   	pop    %edi
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    
			sys_yield();
  801196:	e8 af ef ff ff       	call   80014a <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80119b:	8b 03                	mov    (%ebx),%eax
  80119d:	3b 43 04             	cmp    0x4(%ebx),%eax
  8011a0:	75 18                	jne    8011ba <devpipe_read+0x53>
			if (i > 0)
  8011a2:	85 f6                	test   %esi,%esi
  8011a4:	75 e6                	jne    80118c <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8011a6:	89 da                	mov    %ebx,%edx
  8011a8:	89 f8                	mov    %edi,%eax
  8011aa:	e8 d4 fe ff ff       	call   801083 <_pipeisclosed>
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	74 e3                	je     801196 <devpipe_read+0x2f>
				return 0;
  8011b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b8:	eb d4                	jmp    80118e <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011ba:	99                   	cltd   
  8011bb:	c1 ea 1b             	shr    $0x1b,%edx
  8011be:	01 d0                	add    %edx,%eax
  8011c0:	83 e0 1f             	and    $0x1f,%eax
  8011c3:	29 d0                	sub    %edx,%eax
  8011c5:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011cd:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011d0:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011d3:	83 c6 01             	add    $0x1,%esi
  8011d6:	eb ab                	jmp    801183 <devpipe_read+0x1c>

008011d8 <pipe>:
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	56                   	push   %esi
  8011dc:	53                   	push   %ebx
  8011dd:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e3:	50                   	push   %eax
  8011e4:	e8 f9 f1 ff ff       	call   8003e2 <fd_alloc>
  8011e9:	89 c3                	mov    %eax,%ebx
  8011eb:	83 c4 10             	add    $0x10,%esp
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	0f 88 23 01 00 00    	js     801319 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011f6:	83 ec 04             	sub    $0x4,%esp
  8011f9:	68 07 04 00 00       	push   $0x407
  8011fe:	ff 75 f4             	push   -0xc(%ebp)
  801201:	6a 00                	push   $0x0
  801203:	e8 61 ef ff ff       	call   800169 <sys_page_alloc>
  801208:	89 c3                	mov    %eax,%ebx
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	85 c0                	test   %eax,%eax
  80120f:	0f 88 04 01 00 00    	js     801319 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801215:	83 ec 0c             	sub    $0xc,%esp
  801218:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121b:	50                   	push   %eax
  80121c:	e8 c1 f1 ff ff       	call   8003e2 <fd_alloc>
  801221:	89 c3                	mov    %eax,%ebx
  801223:	83 c4 10             	add    $0x10,%esp
  801226:	85 c0                	test   %eax,%eax
  801228:	0f 88 db 00 00 00    	js     801309 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80122e:	83 ec 04             	sub    $0x4,%esp
  801231:	68 07 04 00 00       	push   $0x407
  801236:	ff 75 f0             	push   -0x10(%ebp)
  801239:	6a 00                	push   $0x0
  80123b:	e8 29 ef ff ff       	call   800169 <sys_page_alloc>
  801240:	89 c3                	mov    %eax,%ebx
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	85 c0                	test   %eax,%eax
  801247:	0f 88 bc 00 00 00    	js     801309 <pipe+0x131>
	va = fd2data(fd0);
  80124d:	83 ec 0c             	sub    $0xc,%esp
  801250:	ff 75 f4             	push   -0xc(%ebp)
  801253:	e8 73 f1 ff ff       	call   8003cb <fd2data>
  801258:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80125a:	83 c4 0c             	add    $0xc,%esp
  80125d:	68 07 04 00 00       	push   $0x407
  801262:	50                   	push   %eax
  801263:	6a 00                	push   $0x0
  801265:	e8 ff ee ff ff       	call   800169 <sys_page_alloc>
  80126a:	89 c3                	mov    %eax,%ebx
  80126c:	83 c4 10             	add    $0x10,%esp
  80126f:	85 c0                	test   %eax,%eax
  801271:	0f 88 82 00 00 00    	js     8012f9 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801277:	83 ec 0c             	sub    $0xc,%esp
  80127a:	ff 75 f0             	push   -0x10(%ebp)
  80127d:	e8 49 f1 ff ff       	call   8003cb <fd2data>
  801282:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801289:	50                   	push   %eax
  80128a:	6a 00                	push   $0x0
  80128c:	56                   	push   %esi
  80128d:	6a 00                	push   $0x0
  80128f:	e8 18 ef ff ff       	call   8001ac <sys_page_map>
  801294:	89 c3                	mov    %eax,%ebx
  801296:	83 c4 20             	add    $0x20,%esp
  801299:	85 c0                	test   %eax,%eax
  80129b:	78 4e                	js     8012eb <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80129d:	a1 3c 30 80 00       	mov    0x80303c,%eax
  8012a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a5:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8012a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012aa:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012b1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012b4:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012c0:	83 ec 0c             	sub    $0xc,%esp
  8012c3:	ff 75 f4             	push   -0xc(%ebp)
  8012c6:	e8 f0 f0 ff ff       	call   8003bb <fd2num>
  8012cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ce:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012d0:	83 c4 04             	add    $0x4,%esp
  8012d3:	ff 75 f0             	push   -0x10(%ebp)
  8012d6:	e8 e0 f0 ff ff       	call   8003bb <fd2num>
  8012db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012de:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012e1:	83 c4 10             	add    $0x10,%esp
  8012e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e9:	eb 2e                	jmp    801319 <pipe+0x141>
	sys_page_unmap(0, va);
  8012eb:	83 ec 08             	sub    $0x8,%esp
  8012ee:	56                   	push   %esi
  8012ef:	6a 00                	push   $0x0
  8012f1:	e8 f8 ee ff ff       	call   8001ee <sys_page_unmap>
  8012f6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8012f9:	83 ec 08             	sub    $0x8,%esp
  8012fc:	ff 75 f0             	push   -0x10(%ebp)
  8012ff:	6a 00                	push   $0x0
  801301:	e8 e8 ee ff ff       	call   8001ee <sys_page_unmap>
  801306:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801309:	83 ec 08             	sub    $0x8,%esp
  80130c:	ff 75 f4             	push   -0xc(%ebp)
  80130f:	6a 00                	push   $0x0
  801311:	e8 d8 ee ff ff       	call   8001ee <sys_page_unmap>
  801316:	83 c4 10             	add    $0x10,%esp
}
  801319:	89 d8                	mov    %ebx,%eax
  80131b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131e:	5b                   	pop    %ebx
  80131f:	5e                   	pop    %esi
  801320:	5d                   	pop    %ebp
  801321:	c3                   	ret    

00801322 <pipeisclosed>:
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801328:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132b:	50                   	push   %eax
  80132c:	ff 75 08             	push   0x8(%ebp)
  80132f:	e8 fe f0 ff ff       	call   800432 <fd_lookup>
  801334:	83 c4 10             	add    $0x10,%esp
  801337:	85 c0                	test   %eax,%eax
  801339:	78 18                	js     801353 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80133b:	83 ec 0c             	sub    $0xc,%esp
  80133e:	ff 75 f4             	push   -0xc(%ebp)
  801341:	e8 85 f0 ff ff       	call   8003cb <fd2data>
  801346:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801348:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134b:	e8 33 fd ff ff       	call   801083 <_pipeisclosed>
  801350:	83 c4 10             	add    $0x10,%esp
}
  801353:	c9                   	leave  
  801354:	c3                   	ret    

00801355 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801355:	b8 00 00 00 00       	mov    $0x0,%eax
  80135a:	c3                   	ret    

0080135b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80135b:	55                   	push   %ebp
  80135c:	89 e5                	mov    %esp,%ebp
  80135e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801361:	68 93 23 80 00       	push   $0x802393
  801366:	ff 75 0c             	push   0xc(%ebp)
  801369:	e8 10 08 00 00       	call   801b7e <strcpy>
	return 0;
}
  80136e:	b8 00 00 00 00       	mov    $0x0,%eax
  801373:	c9                   	leave  
  801374:	c3                   	ret    

00801375 <devcons_write>:
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	57                   	push   %edi
  801379:	56                   	push   %esi
  80137a:	53                   	push   %ebx
  80137b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801381:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801386:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80138c:	eb 2e                	jmp    8013bc <devcons_write+0x47>
		m = n - tot;
  80138e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801391:	29 f3                	sub    %esi,%ebx
  801393:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801398:	39 c3                	cmp    %eax,%ebx
  80139a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80139d:	83 ec 04             	sub    $0x4,%esp
  8013a0:	53                   	push   %ebx
  8013a1:	89 f0                	mov    %esi,%eax
  8013a3:	03 45 0c             	add    0xc(%ebp),%eax
  8013a6:	50                   	push   %eax
  8013a7:	57                   	push   %edi
  8013a8:	e8 67 09 00 00       	call   801d14 <memmove>
		sys_cputs(buf, m);
  8013ad:	83 c4 08             	add    $0x8,%esp
  8013b0:	53                   	push   %ebx
  8013b1:	57                   	push   %edi
  8013b2:	e8 f6 ec ff ff       	call   8000ad <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013b7:	01 de                	add    %ebx,%esi
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013bf:	72 cd                	jb     80138e <devcons_write+0x19>
}
  8013c1:	89 f0                	mov    %esi,%eax
  8013c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c6:	5b                   	pop    %ebx
  8013c7:	5e                   	pop    %esi
  8013c8:	5f                   	pop    %edi
  8013c9:	5d                   	pop    %ebp
  8013ca:	c3                   	ret    

008013cb <devcons_read>:
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	83 ec 08             	sub    $0x8,%esp
  8013d1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013d6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013da:	75 07                	jne    8013e3 <devcons_read+0x18>
  8013dc:	eb 1f                	jmp    8013fd <devcons_read+0x32>
		sys_yield();
  8013de:	e8 67 ed ff ff       	call   80014a <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8013e3:	e8 e3 ec ff ff       	call   8000cb <sys_cgetc>
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	74 f2                	je     8013de <devcons_read+0x13>
	if (c < 0)
  8013ec:	78 0f                	js     8013fd <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8013ee:	83 f8 04             	cmp    $0x4,%eax
  8013f1:	74 0c                	je     8013ff <devcons_read+0x34>
	*(char*)vbuf = c;
  8013f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013f6:	88 02                	mov    %al,(%edx)
	return 1;
  8013f8:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8013fd:	c9                   	leave  
  8013fe:	c3                   	ret    
		return 0;
  8013ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801404:	eb f7                	jmp    8013fd <devcons_read+0x32>

00801406 <cputchar>:
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80140c:	8b 45 08             	mov    0x8(%ebp),%eax
  80140f:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801412:	6a 01                	push   $0x1
  801414:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801417:	50                   	push   %eax
  801418:	e8 90 ec ff ff       	call   8000ad <sys_cputs>
}
  80141d:	83 c4 10             	add    $0x10,%esp
  801420:	c9                   	leave  
  801421:	c3                   	ret    

00801422 <getchar>:
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801428:	6a 01                	push   $0x1
  80142a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80142d:	50                   	push   %eax
  80142e:	6a 00                	push   $0x0
  801430:	e8 66 f2 ff ff       	call   80069b <read>
	if (r < 0)
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	85 c0                	test   %eax,%eax
  80143a:	78 06                	js     801442 <getchar+0x20>
	if (r < 1)
  80143c:	74 06                	je     801444 <getchar+0x22>
	return c;
  80143e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801442:	c9                   	leave  
  801443:	c3                   	ret    
		return -E_EOF;
  801444:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801449:	eb f7                	jmp    801442 <getchar+0x20>

0080144b <iscons>:
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801451:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801454:	50                   	push   %eax
  801455:	ff 75 08             	push   0x8(%ebp)
  801458:	e8 d5 ef ff ff       	call   800432 <fd_lookup>
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	85 c0                	test   %eax,%eax
  801462:	78 11                	js     801475 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801464:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801467:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80146d:	39 10                	cmp    %edx,(%eax)
  80146f:	0f 94 c0             	sete   %al
  801472:	0f b6 c0             	movzbl %al,%eax
}
  801475:	c9                   	leave  
  801476:	c3                   	ret    

00801477 <opencons>:
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80147d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801480:	50                   	push   %eax
  801481:	e8 5c ef ff ff       	call   8003e2 <fd_alloc>
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 3a                	js     8014c7 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80148d:	83 ec 04             	sub    $0x4,%esp
  801490:	68 07 04 00 00       	push   $0x407
  801495:	ff 75 f4             	push   -0xc(%ebp)
  801498:	6a 00                	push   $0x0
  80149a:	e8 ca ec ff ff       	call   800169 <sys_page_alloc>
  80149f:	83 c4 10             	add    $0x10,%esp
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	78 21                	js     8014c7 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8014a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a9:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014af:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014bb:	83 ec 0c             	sub    $0xc,%esp
  8014be:	50                   	push   %eax
  8014bf:	e8 f7 ee ff ff       	call   8003bb <fd2num>
  8014c4:	83 c4 10             	add    $0x10,%esp
}
  8014c7:	c9                   	leave  
  8014c8:	c3                   	ret    

008014c9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014c9:	55                   	push   %ebp
  8014ca:	89 e5                	mov    %esp,%ebp
  8014cc:	56                   	push   %esi
  8014cd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014ce:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014d1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014d7:	e8 4f ec ff ff       	call   80012b <sys_getenvid>
  8014dc:	83 ec 0c             	sub    $0xc,%esp
  8014df:	ff 75 0c             	push   0xc(%ebp)
  8014e2:	ff 75 08             	push   0x8(%ebp)
  8014e5:	56                   	push   %esi
  8014e6:	50                   	push   %eax
  8014e7:	68 a0 23 80 00       	push   $0x8023a0
  8014ec:	e8 b3 00 00 00       	call   8015a4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014f1:	83 c4 18             	add    $0x18,%esp
  8014f4:	53                   	push   %ebx
  8014f5:	ff 75 10             	push   0x10(%ebp)
  8014f8:	e8 56 00 00 00       	call   801553 <vcprintf>
	cprintf("\n");
  8014fd:	c7 04 24 8c 23 80 00 	movl   $0x80238c,(%esp)
  801504:	e8 9b 00 00 00       	call   8015a4 <cprintf>
  801509:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80150c:	cc                   	int3   
  80150d:	eb fd                	jmp    80150c <_panic+0x43>

0080150f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	53                   	push   %ebx
  801513:	83 ec 04             	sub    $0x4,%esp
  801516:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801519:	8b 13                	mov    (%ebx),%edx
  80151b:	8d 42 01             	lea    0x1(%edx),%eax
  80151e:	89 03                	mov    %eax,(%ebx)
  801520:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801523:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801527:	3d ff 00 00 00       	cmp    $0xff,%eax
  80152c:	74 09                	je     801537 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80152e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801532:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801535:	c9                   	leave  
  801536:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801537:	83 ec 08             	sub    $0x8,%esp
  80153a:	68 ff 00 00 00       	push   $0xff
  80153f:	8d 43 08             	lea    0x8(%ebx),%eax
  801542:	50                   	push   %eax
  801543:	e8 65 eb ff ff       	call   8000ad <sys_cputs>
		b->idx = 0;
  801548:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80154e:	83 c4 10             	add    $0x10,%esp
  801551:	eb db                	jmp    80152e <putch+0x1f>

00801553 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80155c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801563:	00 00 00 
	b.cnt = 0;
  801566:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80156d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801570:	ff 75 0c             	push   0xc(%ebp)
  801573:	ff 75 08             	push   0x8(%ebp)
  801576:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80157c:	50                   	push   %eax
  80157d:	68 0f 15 80 00       	push   $0x80150f
  801582:	e8 14 01 00 00       	call   80169b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801587:	83 c4 08             	add    $0x8,%esp
  80158a:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  801590:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801596:	50                   	push   %eax
  801597:	e8 11 eb ff ff       	call   8000ad <sys_cputs>

	return b.cnt;
}
  80159c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015a2:	c9                   	leave  
  8015a3:	c3                   	ret    

008015a4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015aa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015ad:	50                   	push   %eax
  8015ae:	ff 75 08             	push   0x8(%ebp)
  8015b1:	e8 9d ff ff ff       	call   801553 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	57                   	push   %edi
  8015bc:	56                   	push   %esi
  8015bd:	53                   	push   %ebx
  8015be:	83 ec 1c             	sub    $0x1c,%esp
  8015c1:	89 c7                	mov    %eax,%edi
  8015c3:	89 d6                	mov    %edx,%esi
  8015c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015cb:	89 d1                	mov    %edx,%ecx
  8015cd:	89 c2                	mov    %eax,%edx
  8015cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015d2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8015d8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015de:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8015e5:	39 c2                	cmp    %eax,%edx
  8015e7:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8015ea:	72 3e                	jb     80162a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015ec:	83 ec 0c             	sub    $0xc,%esp
  8015ef:	ff 75 18             	push   0x18(%ebp)
  8015f2:	83 eb 01             	sub    $0x1,%ebx
  8015f5:	53                   	push   %ebx
  8015f6:	50                   	push   %eax
  8015f7:	83 ec 08             	sub    $0x8,%esp
  8015fa:	ff 75 e4             	push   -0x1c(%ebp)
  8015fd:	ff 75 e0             	push   -0x20(%ebp)
  801600:	ff 75 dc             	push   -0x24(%ebp)
  801603:	ff 75 d8             	push   -0x28(%ebp)
  801606:	e8 f5 09 00 00       	call   802000 <__udivdi3>
  80160b:	83 c4 18             	add    $0x18,%esp
  80160e:	52                   	push   %edx
  80160f:	50                   	push   %eax
  801610:	89 f2                	mov    %esi,%edx
  801612:	89 f8                	mov    %edi,%eax
  801614:	e8 9f ff ff ff       	call   8015b8 <printnum>
  801619:	83 c4 20             	add    $0x20,%esp
  80161c:	eb 13                	jmp    801631 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80161e:	83 ec 08             	sub    $0x8,%esp
  801621:	56                   	push   %esi
  801622:	ff 75 18             	push   0x18(%ebp)
  801625:	ff d7                	call   *%edi
  801627:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80162a:	83 eb 01             	sub    $0x1,%ebx
  80162d:	85 db                	test   %ebx,%ebx
  80162f:	7f ed                	jg     80161e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801631:	83 ec 08             	sub    $0x8,%esp
  801634:	56                   	push   %esi
  801635:	83 ec 04             	sub    $0x4,%esp
  801638:	ff 75 e4             	push   -0x1c(%ebp)
  80163b:	ff 75 e0             	push   -0x20(%ebp)
  80163e:	ff 75 dc             	push   -0x24(%ebp)
  801641:	ff 75 d8             	push   -0x28(%ebp)
  801644:	e8 d7 0a 00 00       	call   802120 <__umoddi3>
  801649:	83 c4 14             	add    $0x14,%esp
  80164c:	0f be 80 c3 23 80 00 	movsbl 0x8023c3(%eax),%eax
  801653:	50                   	push   %eax
  801654:	ff d7                	call   *%edi
}
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80165c:	5b                   	pop    %ebx
  80165d:	5e                   	pop    %esi
  80165e:	5f                   	pop    %edi
  80165f:	5d                   	pop    %ebp
  801660:	c3                   	ret    

00801661 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801667:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80166b:	8b 10                	mov    (%eax),%edx
  80166d:	3b 50 04             	cmp    0x4(%eax),%edx
  801670:	73 0a                	jae    80167c <sprintputch+0x1b>
		*b->buf++ = ch;
  801672:	8d 4a 01             	lea    0x1(%edx),%ecx
  801675:	89 08                	mov    %ecx,(%eax)
  801677:	8b 45 08             	mov    0x8(%ebp),%eax
  80167a:	88 02                	mov    %al,(%edx)
}
  80167c:	5d                   	pop    %ebp
  80167d:	c3                   	ret    

0080167e <printfmt>:
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801684:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801687:	50                   	push   %eax
  801688:	ff 75 10             	push   0x10(%ebp)
  80168b:	ff 75 0c             	push   0xc(%ebp)
  80168e:	ff 75 08             	push   0x8(%ebp)
  801691:	e8 05 00 00 00       	call   80169b <vprintfmt>
}
  801696:	83 c4 10             	add    $0x10,%esp
  801699:	c9                   	leave  
  80169a:	c3                   	ret    

0080169b <vprintfmt>:
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	57                   	push   %edi
  80169f:	56                   	push   %esi
  8016a0:	53                   	push   %ebx
  8016a1:	83 ec 3c             	sub    $0x3c,%esp
  8016a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8016a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016aa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016ad:	eb 0a                	jmp    8016b9 <vprintfmt+0x1e>
			putch(ch, putdat);
  8016af:	83 ec 08             	sub    $0x8,%esp
  8016b2:	53                   	push   %ebx
  8016b3:	50                   	push   %eax
  8016b4:	ff d6                	call   *%esi
  8016b6:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016b9:	83 c7 01             	add    $0x1,%edi
  8016bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016c0:	83 f8 25             	cmp    $0x25,%eax
  8016c3:	74 0c                	je     8016d1 <vprintfmt+0x36>
			if (ch == '\0')
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	75 e6                	jne    8016af <vprintfmt+0x14>
}
  8016c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016cc:	5b                   	pop    %ebx
  8016cd:	5e                   	pop    %esi
  8016ce:	5f                   	pop    %edi
  8016cf:	5d                   	pop    %ebp
  8016d0:	c3                   	ret    
		padc = ' ';
  8016d1:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8016d5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8016dc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8016e3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8016ea:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8016ef:	8d 47 01             	lea    0x1(%edi),%eax
  8016f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016f5:	0f b6 17             	movzbl (%edi),%edx
  8016f8:	8d 42 dd             	lea    -0x23(%edx),%eax
  8016fb:	3c 55                	cmp    $0x55,%al
  8016fd:	0f 87 bb 03 00 00    	ja     801abe <vprintfmt+0x423>
  801703:	0f b6 c0             	movzbl %al,%eax
  801706:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
  80170d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801710:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801714:	eb d9                	jmp    8016ef <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801716:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801719:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80171d:	eb d0                	jmp    8016ef <vprintfmt+0x54>
  80171f:	0f b6 d2             	movzbl %dl,%edx
  801722:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801725:	b8 00 00 00 00       	mov    $0x0,%eax
  80172a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80172d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801730:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801734:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801737:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80173a:	83 f9 09             	cmp    $0x9,%ecx
  80173d:	77 55                	ja     801794 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80173f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801742:	eb e9                	jmp    80172d <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801744:	8b 45 14             	mov    0x14(%ebp),%eax
  801747:	8b 00                	mov    (%eax),%eax
  801749:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80174c:	8b 45 14             	mov    0x14(%ebp),%eax
  80174f:	8d 40 04             	lea    0x4(%eax),%eax
  801752:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801755:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801758:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80175c:	79 91                	jns    8016ef <vprintfmt+0x54>
				width = precision, precision = -1;
  80175e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801761:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801764:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80176b:	eb 82                	jmp    8016ef <vprintfmt+0x54>
  80176d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801770:	85 d2                	test   %edx,%edx
  801772:	b8 00 00 00 00       	mov    $0x0,%eax
  801777:	0f 49 c2             	cmovns %edx,%eax
  80177a:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80177d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801780:	e9 6a ff ff ff       	jmp    8016ef <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801785:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801788:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80178f:	e9 5b ff ff ff       	jmp    8016ef <vprintfmt+0x54>
  801794:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801797:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80179a:	eb bc                	jmp    801758 <vprintfmt+0xbd>
			lflag++;
  80179c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80179f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017a2:	e9 48 ff ff ff       	jmp    8016ef <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8017a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8017aa:	8d 78 04             	lea    0x4(%eax),%edi
  8017ad:	83 ec 08             	sub    $0x8,%esp
  8017b0:	53                   	push   %ebx
  8017b1:	ff 30                	push   (%eax)
  8017b3:	ff d6                	call   *%esi
			break;
  8017b5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017b8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017bb:	e9 9d 02 00 00       	jmp    801a5d <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8017c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8017c3:	8d 78 04             	lea    0x4(%eax),%edi
  8017c6:	8b 10                	mov    (%eax),%edx
  8017c8:	89 d0                	mov    %edx,%eax
  8017ca:	f7 d8                	neg    %eax
  8017cc:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017cf:	83 f8 0f             	cmp    $0xf,%eax
  8017d2:	7f 23                	jg     8017f7 <vprintfmt+0x15c>
  8017d4:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  8017db:	85 d2                	test   %edx,%edx
  8017dd:	74 18                	je     8017f7 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8017df:	52                   	push   %edx
  8017e0:	68 21 23 80 00       	push   $0x802321
  8017e5:	53                   	push   %ebx
  8017e6:	56                   	push   %esi
  8017e7:	e8 92 fe ff ff       	call   80167e <printfmt>
  8017ec:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017ef:	89 7d 14             	mov    %edi,0x14(%ebp)
  8017f2:	e9 66 02 00 00       	jmp    801a5d <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8017f7:	50                   	push   %eax
  8017f8:	68 db 23 80 00       	push   $0x8023db
  8017fd:	53                   	push   %ebx
  8017fe:	56                   	push   %esi
  8017ff:	e8 7a fe ff ff       	call   80167e <printfmt>
  801804:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801807:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80180a:	e9 4e 02 00 00       	jmp    801a5d <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80180f:	8b 45 14             	mov    0x14(%ebp),%eax
  801812:	83 c0 04             	add    $0x4,%eax
  801815:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801818:	8b 45 14             	mov    0x14(%ebp),%eax
  80181b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80181d:	85 d2                	test   %edx,%edx
  80181f:	b8 d4 23 80 00       	mov    $0x8023d4,%eax
  801824:	0f 45 c2             	cmovne %edx,%eax
  801827:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80182a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80182e:	7e 06                	jle    801836 <vprintfmt+0x19b>
  801830:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801834:	75 0d                	jne    801843 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801836:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801839:	89 c7                	mov    %eax,%edi
  80183b:	03 45 e0             	add    -0x20(%ebp),%eax
  80183e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801841:	eb 55                	jmp    801898 <vprintfmt+0x1fd>
  801843:	83 ec 08             	sub    $0x8,%esp
  801846:	ff 75 d8             	push   -0x28(%ebp)
  801849:	ff 75 cc             	push   -0x34(%ebp)
  80184c:	e8 0a 03 00 00       	call   801b5b <strnlen>
  801851:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801854:	29 c1                	sub    %eax,%ecx
  801856:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801859:	83 c4 10             	add    $0x10,%esp
  80185c:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80185e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801862:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801865:	eb 0f                	jmp    801876 <vprintfmt+0x1db>
					putch(padc, putdat);
  801867:	83 ec 08             	sub    $0x8,%esp
  80186a:	53                   	push   %ebx
  80186b:	ff 75 e0             	push   -0x20(%ebp)
  80186e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801870:	83 ef 01             	sub    $0x1,%edi
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	85 ff                	test   %edi,%edi
  801878:	7f ed                	jg     801867 <vprintfmt+0x1cc>
  80187a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80187d:	85 d2                	test   %edx,%edx
  80187f:	b8 00 00 00 00       	mov    $0x0,%eax
  801884:	0f 49 c2             	cmovns %edx,%eax
  801887:	29 c2                	sub    %eax,%edx
  801889:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80188c:	eb a8                	jmp    801836 <vprintfmt+0x19b>
					putch(ch, putdat);
  80188e:	83 ec 08             	sub    $0x8,%esp
  801891:	53                   	push   %ebx
  801892:	52                   	push   %edx
  801893:	ff d6                	call   *%esi
  801895:	83 c4 10             	add    $0x10,%esp
  801898:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80189b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80189d:	83 c7 01             	add    $0x1,%edi
  8018a0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018a4:	0f be d0             	movsbl %al,%edx
  8018a7:	85 d2                	test   %edx,%edx
  8018a9:	74 4b                	je     8018f6 <vprintfmt+0x25b>
  8018ab:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018af:	78 06                	js     8018b7 <vprintfmt+0x21c>
  8018b1:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018b5:	78 1e                	js     8018d5 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8018b7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018bb:	74 d1                	je     80188e <vprintfmt+0x1f3>
  8018bd:	0f be c0             	movsbl %al,%eax
  8018c0:	83 e8 20             	sub    $0x20,%eax
  8018c3:	83 f8 5e             	cmp    $0x5e,%eax
  8018c6:	76 c6                	jbe    80188e <vprintfmt+0x1f3>
					putch('?', putdat);
  8018c8:	83 ec 08             	sub    $0x8,%esp
  8018cb:	53                   	push   %ebx
  8018cc:	6a 3f                	push   $0x3f
  8018ce:	ff d6                	call   *%esi
  8018d0:	83 c4 10             	add    $0x10,%esp
  8018d3:	eb c3                	jmp    801898 <vprintfmt+0x1fd>
  8018d5:	89 cf                	mov    %ecx,%edi
  8018d7:	eb 0e                	jmp    8018e7 <vprintfmt+0x24c>
				putch(' ', putdat);
  8018d9:	83 ec 08             	sub    $0x8,%esp
  8018dc:	53                   	push   %ebx
  8018dd:	6a 20                	push   $0x20
  8018df:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8018e1:	83 ef 01             	sub    $0x1,%edi
  8018e4:	83 c4 10             	add    $0x10,%esp
  8018e7:	85 ff                	test   %edi,%edi
  8018e9:	7f ee                	jg     8018d9 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8018eb:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8018ee:	89 45 14             	mov    %eax,0x14(%ebp)
  8018f1:	e9 67 01 00 00       	jmp    801a5d <vprintfmt+0x3c2>
  8018f6:	89 cf                	mov    %ecx,%edi
  8018f8:	eb ed                	jmp    8018e7 <vprintfmt+0x24c>
	if (lflag >= 2)
  8018fa:	83 f9 01             	cmp    $0x1,%ecx
  8018fd:	7f 1b                	jg     80191a <vprintfmt+0x27f>
	else if (lflag)
  8018ff:	85 c9                	test   %ecx,%ecx
  801901:	74 63                	je     801966 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  801903:	8b 45 14             	mov    0x14(%ebp),%eax
  801906:	8b 00                	mov    (%eax),%eax
  801908:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80190b:	99                   	cltd   
  80190c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80190f:	8b 45 14             	mov    0x14(%ebp),%eax
  801912:	8d 40 04             	lea    0x4(%eax),%eax
  801915:	89 45 14             	mov    %eax,0x14(%ebp)
  801918:	eb 17                	jmp    801931 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80191a:	8b 45 14             	mov    0x14(%ebp),%eax
  80191d:	8b 50 04             	mov    0x4(%eax),%edx
  801920:	8b 00                	mov    (%eax),%eax
  801922:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801925:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801928:	8b 45 14             	mov    0x14(%ebp),%eax
  80192b:	8d 40 08             	lea    0x8(%eax),%eax
  80192e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801931:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801934:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801937:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80193c:	85 c9                	test   %ecx,%ecx
  80193e:	0f 89 ff 00 00 00    	jns    801a43 <vprintfmt+0x3a8>
				putch('-', putdat);
  801944:	83 ec 08             	sub    $0x8,%esp
  801947:	53                   	push   %ebx
  801948:	6a 2d                	push   $0x2d
  80194a:	ff d6                	call   *%esi
				num = -(long long) num;
  80194c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80194f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801952:	f7 da                	neg    %edx
  801954:	83 d1 00             	adc    $0x0,%ecx
  801957:	f7 d9                	neg    %ecx
  801959:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80195c:	bf 0a 00 00 00       	mov    $0xa,%edi
  801961:	e9 dd 00 00 00       	jmp    801a43 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801966:	8b 45 14             	mov    0x14(%ebp),%eax
  801969:	8b 00                	mov    (%eax),%eax
  80196b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80196e:	99                   	cltd   
  80196f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801972:	8b 45 14             	mov    0x14(%ebp),%eax
  801975:	8d 40 04             	lea    0x4(%eax),%eax
  801978:	89 45 14             	mov    %eax,0x14(%ebp)
  80197b:	eb b4                	jmp    801931 <vprintfmt+0x296>
	if (lflag >= 2)
  80197d:	83 f9 01             	cmp    $0x1,%ecx
  801980:	7f 1e                	jg     8019a0 <vprintfmt+0x305>
	else if (lflag)
  801982:	85 c9                	test   %ecx,%ecx
  801984:	74 32                	je     8019b8 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  801986:	8b 45 14             	mov    0x14(%ebp),%eax
  801989:	8b 10                	mov    (%eax),%edx
  80198b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801990:	8d 40 04             	lea    0x4(%eax),%eax
  801993:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801996:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80199b:	e9 a3 00 00 00       	jmp    801a43 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a3:	8b 10                	mov    (%eax),%edx
  8019a5:	8b 48 04             	mov    0x4(%eax),%ecx
  8019a8:	8d 40 08             	lea    0x8(%eax),%eax
  8019ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019ae:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8019b3:	e9 8b 00 00 00       	jmp    801a43 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019bb:	8b 10                	mov    (%eax),%edx
  8019bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019c2:	8d 40 04             	lea    0x4(%eax),%eax
  8019c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019c8:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8019cd:	eb 74                	jmp    801a43 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8019cf:	83 f9 01             	cmp    $0x1,%ecx
  8019d2:	7f 1b                	jg     8019ef <vprintfmt+0x354>
	else if (lflag)
  8019d4:	85 c9                	test   %ecx,%ecx
  8019d6:	74 2c                	je     801a04 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8019d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019db:	8b 10                	mov    (%eax),%edx
  8019dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019e2:	8d 40 04             	lea    0x4(%eax),%eax
  8019e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019e8:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8019ed:	eb 54                	jmp    801a43 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f2:	8b 10                	mov    (%eax),%edx
  8019f4:	8b 48 04             	mov    0x4(%eax),%ecx
  8019f7:	8d 40 08             	lea    0x8(%eax),%eax
  8019fa:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019fd:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  801a02:	eb 3f                	jmp    801a43 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a04:	8b 45 14             	mov    0x14(%ebp),%eax
  801a07:	8b 10                	mov    (%eax),%edx
  801a09:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a0e:	8d 40 04             	lea    0x4(%eax),%eax
  801a11:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a14:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801a19:	eb 28                	jmp    801a43 <vprintfmt+0x3a8>
			putch('0', putdat);
  801a1b:	83 ec 08             	sub    $0x8,%esp
  801a1e:	53                   	push   %ebx
  801a1f:	6a 30                	push   $0x30
  801a21:	ff d6                	call   *%esi
			putch('x', putdat);
  801a23:	83 c4 08             	add    $0x8,%esp
  801a26:	53                   	push   %ebx
  801a27:	6a 78                	push   $0x78
  801a29:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a2b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2e:	8b 10                	mov    (%eax),%edx
  801a30:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a35:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a38:	8d 40 04             	lea    0x4(%eax),%eax
  801a3b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a3e:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801a43:	83 ec 0c             	sub    $0xc,%esp
  801a46:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801a4a:	50                   	push   %eax
  801a4b:	ff 75 e0             	push   -0x20(%ebp)
  801a4e:	57                   	push   %edi
  801a4f:	51                   	push   %ecx
  801a50:	52                   	push   %edx
  801a51:	89 da                	mov    %ebx,%edx
  801a53:	89 f0                	mov    %esi,%eax
  801a55:	e8 5e fb ff ff       	call   8015b8 <printnum>
			break;
  801a5a:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801a5d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a60:	e9 54 fc ff ff       	jmp    8016b9 <vprintfmt+0x1e>
	if (lflag >= 2)
  801a65:	83 f9 01             	cmp    $0x1,%ecx
  801a68:	7f 1b                	jg     801a85 <vprintfmt+0x3ea>
	else if (lflag)
  801a6a:	85 c9                	test   %ecx,%ecx
  801a6c:	74 2c                	je     801a9a <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801a6e:	8b 45 14             	mov    0x14(%ebp),%eax
  801a71:	8b 10                	mov    (%eax),%edx
  801a73:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a78:	8d 40 04             	lea    0x4(%eax),%eax
  801a7b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a7e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801a83:	eb be                	jmp    801a43 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801a85:	8b 45 14             	mov    0x14(%ebp),%eax
  801a88:	8b 10                	mov    (%eax),%edx
  801a8a:	8b 48 04             	mov    0x4(%eax),%ecx
  801a8d:	8d 40 08             	lea    0x8(%eax),%eax
  801a90:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a93:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  801a98:	eb a9                	jmp    801a43 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a9a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a9d:	8b 10                	mov    (%eax),%edx
  801a9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801aa4:	8d 40 04             	lea    0x4(%eax),%eax
  801aa7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801aaa:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  801aaf:	eb 92                	jmp    801a43 <vprintfmt+0x3a8>
			putch(ch, putdat);
  801ab1:	83 ec 08             	sub    $0x8,%esp
  801ab4:	53                   	push   %ebx
  801ab5:	6a 25                	push   $0x25
  801ab7:	ff d6                	call   *%esi
			break;
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	eb 9f                	jmp    801a5d <vprintfmt+0x3c2>
			putch('%', putdat);
  801abe:	83 ec 08             	sub    $0x8,%esp
  801ac1:	53                   	push   %ebx
  801ac2:	6a 25                	push   $0x25
  801ac4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	89 f8                	mov    %edi,%eax
  801acb:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801acf:	74 05                	je     801ad6 <vprintfmt+0x43b>
  801ad1:	83 e8 01             	sub    $0x1,%eax
  801ad4:	eb f5                	jmp    801acb <vprintfmt+0x430>
  801ad6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ad9:	eb 82                	jmp    801a5d <vprintfmt+0x3c2>

00801adb <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	83 ec 18             	sub    $0x18,%esp
  801ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ae7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801aea:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801aee:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801af1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801af8:	85 c0                	test   %eax,%eax
  801afa:	74 26                	je     801b22 <vsnprintf+0x47>
  801afc:	85 d2                	test   %edx,%edx
  801afe:	7e 22                	jle    801b22 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b00:	ff 75 14             	push   0x14(%ebp)
  801b03:	ff 75 10             	push   0x10(%ebp)
  801b06:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b09:	50                   	push   %eax
  801b0a:	68 61 16 80 00       	push   $0x801661
  801b0f:	e8 87 fb ff ff       	call   80169b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b14:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b17:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1d:	83 c4 10             	add    $0x10,%esp
}
  801b20:	c9                   	leave  
  801b21:	c3                   	ret    
		return -E_INVAL;
  801b22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b27:	eb f7                	jmp    801b20 <vsnprintf+0x45>

00801b29 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b2f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b32:	50                   	push   %eax
  801b33:	ff 75 10             	push   0x10(%ebp)
  801b36:	ff 75 0c             	push   0xc(%ebp)
  801b39:	ff 75 08             	push   0x8(%ebp)
  801b3c:	e8 9a ff ff ff       	call   801adb <vsnprintf>
	va_end(ap);

	return rc;
}
  801b41:	c9                   	leave  
  801b42:	c3                   	ret    

00801b43 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b49:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4e:	eb 03                	jmp    801b53 <strlen+0x10>
		n++;
  801b50:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801b53:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b57:	75 f7                	jne    801b50 <strlen+0xd>
	return n;
}
  801b59:	5d                   	pop    %ebp
  801b5a:	c3                   	ret    

00801b5b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b61:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b64:	b8 00 00 00 00       	mov    $0x0,%eax
  801b69:	eb 03                	jmp    801b6e <strnlen+0x13>
		n++;
  801b6b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b6e:	39 d0                	cmp    %edx,%eax
  801b70:	74 08                	je     801b7a <strnlen+0x1f>
  801b72:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801b76:	75 f3                	jne    801b6b <strnlen+0x10>
  801b78:	89 c2                	mov    %eax,%edx
	return n;
}
  801b7a:	89 d0                	mov    %edx,%eax
  801b7c:	5d                   	pop    %ebp
  801b7d:	c3                   	ret    

00801b7e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	53                   	push   %ebx
  801b82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b85:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b88:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8d:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801b91:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801b94:	83 c0 01             	add    $0x1,%eax
  801b97:	84 d2                	test   %dl,%dl
  801b99:	75 f2                	jne    801b8d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801b9b:	89 c8                	mov    %ecx,%eax
  801b9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba0:	c9                   	leave  
  801ba1:	c3                   	ret    

00801ba2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	53                   	push   %ebx
  801ba6:	83 ec 10             	sub    $0x10,%esp
  801ba9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bac:	53                   	push   %ebx
  801bad:	e8 91 ff ff ff       	call   801b43 <strlen>
  801bb2:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801bb5:	ff 75 0c             	push   0xc(%ebp)
  801bb8:	01 d8                	add    %ebx,%eax
  801bba:	50                   	push   %eax
  801bbb:	e8 be ff ff ff       	call   801b7e <strcpy>
	return dst;
}
  801bc0:	89 d8                	mov    %ebx,%eax
  801bc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc5:	c9                   	leave  
  801bc6:	c3                   	ret    

00801bc7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bc7:	55                   	push   %ebp
  801bc8:	89 e5                	mov    %esp,%ebp
  801bca:	56                   	push   %esi
  801bcb:	53                   	push   %ebx
  801bcc:	8b 75 08             	mov    0x8(%ebp),%esi
  801bcf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bd2:	89 f3                	mov    %esi,%ebx
  801bd4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bd7:	89 f0                	mov    %esi,%eax
  801bd9:	eb 0f                	jmp    801bea <strncpy+0x23>
		*dst++ = *src;
  801bdb:	83 c0 01             	add    $0x1,%eax
  801bde:	0f b6 0a             	movzbl (%edx),%ecx
  801be1:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801be4:	80 f9 01             	cmp    $0x1,%cl
  801be7:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801bea:	39 d8                	cmp    %ebx,%eax
  801bec:	75 ed                	jne    801bdb <strncpy+0x14>
	}
	return ret;
}
  801bee:	89 f0                	mov    %esi,%eax
  801bf0:	5b                   	pop    %ebx
  801bf1:	5e                   	pop    %esi
  801bf2:	5d                   	pop    %ebp
  801bf3:	c3                   	ret    

00801bf4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bf4:	55                   	push   %ebp
  801bf5:	89 e5                	mov    %esp,%ebp
  801bf7:	56                   	push   %esi
  801bf8:	53                   	push   %ebx
  801bf9:	8b 75 08             	mov    0x8(%ebp),%esi
  801bfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bff:	8b 55 10             	mov    0x10(%ebp),%edx
  801c02:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c04:	85 d2                	test   %edx,%edx
  801c06:	74 21                	je     801c29 <strlcpy+0x35>
  801c08:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c0c:	89 f2                	mov    %esi,%edx
  801c0e:	eb 09                	jmp    801c19 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c10:	83 c1 01             	add    $0x1,%ecx
  801c13:	83 c2 01             	add    $0x1,%edx
  801c16:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801c19:	39 c2                	cmp    %eax,%edx
  801c1b:	74 09                	je     801c26 <strlcpy+0x32>
  801c1d:	0f b6 19             	movzbl (%ecx),%ebx
  801c20:	84 db                	test   %bl,%bl
  801c22:	75 ec                	jne    801c10 <strlcpy+0x1c>
  801c24:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c26:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c29:	29 f0                	sub    %esi,%eax
}
  801c2b:	5b                   	pop    %ebx
  801c2c:	5e                   	pop    %esi
  801c2d:	5d                   	pop    %ebp
  801c2e:	c3                   	ret    

00801c2f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c2f:	55                   	push   %ebp
  801c30:	89 e5                	mov    %esp,%ebp
  801c32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c35:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c38:	eb 06                	jmp    801c40 <strcmp+0x11>
		p++, q++;
  801c3a:	83 c1 01             	add    $0x1,%ecx
  801c3d:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801c40:	0f b6 01             	movzbl (%ecx),%eax
  801c43:	84 c0                	test   %al,%al
  801c45:	74 04                	je     801c4b <strcmp+0x1c>
  801c47:	3a 02                	cmp    (%edx),%al
  801c49:	74 ef                	je     801c3a <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c4b:	0f b6 c0             	movzbl %al,%eax
  801c4e:	0f b6 12             	movzbl (%edx),%edx
  801c51:	29 d0                	sub    %edx,%eax
}
  801c53:	5d                   	pop    %ebp
  801c54:	c3                   	ret    

00801c55 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	53                   	push   %ebx
  801c59:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c5f:	89 c3                	mov    %eax,%ebx
  801c61:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c64:	eb 06                	jmp    801c6c <strncmp+0x17>
		n--, p++, q++;
  801c66:	83 c0 01             	add    $0x1,%eax
  801c69:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801c6c:	39 d8                	cmp    %ebx,%eax
  801c6e:	74 18                	je     801c88 <strncmp+0x33>
  801c70:	0f b6 08             	movzbl (%eax),%ecx
  801c73:	84 c9                	test   %cl,%cl
  801c75:	74 04                	je     801c7b <strncmp+0x26>
  801c77:	3a 0a                	cmp    (%edx),%cl
  801c79:	74 eb                	je     801c66 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c7b:	0f b6 00             	movzbl (%eax),%eax
  801c7e:	0f b6 12             	movzbl (%edx),%edx
  801c81:	29 d0                	sub    %edx,%eax
}
  801c83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c86:	c9                   	leave  
  801c87:	c3                   	ret    
		return 0;
  801c88:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8d:	eb f4                	jmp    801c83 <strncmp+0x2e>

00801c8f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	8b 45 08             	mov    0x8(%ebp),%eax
  801c95:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c99:	eb 03                	jmp    801c9e <strchr+0xf>
  801c9b:	83 c0 01             	add    $0x1,%eax
  801c9e:	0f b6 10             	movzbl (%eax),%edx
  801ca1:	84 d2                	test   %dl,%dl
  801ca3:	74 06                	je     801cab <strchr+0x1c>
		if (*s == c)
  801ca5:	38 ca                	cmp    %cl,%dl
  801ca7:	75 f2                	jne    801c9b <strchr+0xc>
  801ca9:	eb 05                	jmp    801cb0 <strchr+0x21>
			return (char *) s;
	return 0;
  801cab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    

00801cb2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cbc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cbf:	38 ca                	cmp    %cl,%dl
  801cc1:	74 09                	je     801ccc <strfind+0x1a>
  801cc3:	84 d2                	test   %dl,%dl
  801cc5:	74 05                	je     801ccc <strfind+0x1a>
	for (; *s; s++)
  801cc7:	83 c0 01             	add    $0x1,%eax
  801cca:	eb f0                	jmp    801cbc <strfind+0xa>
			break;
	return (char *) s;
}
  801ccc:	5d                   	pop    %ebp
  801ccd:	c3                   	ret    

00801cce <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	57                   	push   %edi
  801cd2:	56                   	push   %esi
  801cd3:	53                   	push   %ebx
  801cd4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cd7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cda:	85 c9                	test   %ecx,%ecx
  801cdc:	74 2f                	je     801d0d <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cde:	89 f8                	mov    %edi,%eax
  801ce0:	09 c8                	or     %ecx,%eax
  801ce2:	a8 03                	test   $0x3,%al
  801ce4:	75 21                	jne    801d07 <memset+0x39>
		c &= 0xFF;
  801ce6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cea:	89 d0                	mov    %edx,%eax
  801cec:	c1 e0 08             	shl    $0x8,%eax
  801cef:	89 d3                	mov    %edx,%ebx
  801cf1:	c1 e3 18             	shl    $0x18,%ebx
  801cf4:	89 d6                	mov    %edx,%esi
  801cf6:	c1 e6 10             	shl    $0x10,%esi
  801cf9:	09 f3                	or     %esi,%ebx
  801cfb:	09 da                	or     %ebx,%edx
  801cfd:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801cff:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801d02:	fc                   	cld    
  801d03:	f3 ab                	rep stos %eax,%es:(%edi)
  801d05:	eb 06                	jmp    801d0d <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d07:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d0a:	fc                   	cld    
  801d0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d0d:	89 f8                	mov    %edi,%eax
  801d0f:	5b                   	pop    %ebx
  801d10:	5e                   	pop    %esi
  801d11:	5f                   	pop    %edi
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    

00801d14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	57                   	push   %edi
  801d18:	56                   	push   %esi
  801d19:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d22:	39 c6                	cmp    %eax,%esi
  801d24:	73 32                	jae    801d58 <memmove+0x44>
  801d26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d29:	39 c2                	cmp    %eax,%edx
  801d2b:	76 2b                	jbe    801d58 <memmove+0x44>
		s += n;
		d += n;
  801d2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d30:	89 d6                	mov    %edx,%esi
  801d32:	09 fe                	or     %edi,%esi
  801d34:	09 ce                	or     %ecx,%esi
  801d36:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d3c:	75 0e                	jne    801d4c <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d3e:	83 ef 04             	sub    $0x4,%edi
  801d41:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d44:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801d47:	fd                   	std    
  801d48:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d4a:	eb 09                	jmp    801d55 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d4c:	83 ef 01             	sub    $0x1,%edi
  801d4f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801d52:	fd                   	std    
  801d53:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d55:	fc                   	cld    
  801d56:	eb 1a                	jmp    801d72 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d58:	89 f2                	mov    %esi,%edx
  801d5a:	09 c2                	or     %eax,%edx
  801d5c:	09 ca                	or     %ecx,%edx
  801d5e:	f6 c2 03             	test   $0x3,%dl
  801d61:	75 0a                	jne    801d6d <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d63:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801d66:	89 c7                	mov    %eax,%edi
  801d68:	fc                   	cld    
  801d69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d6b:	eb 05                	jmp    801d72 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801d6d:	89 c7                	mov    %eax,%edi
  801d6f:	fc                   	cld    
  801d70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d72:	5e                   	pop    %esi
  801d73:	5f                   	pop    %edi
  801d74:	5d                   	pop    %ebp
  801d75:	c3                   	ret    

00801d76 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d7c:	ff 75 10             	push   0x10(%ebp)
  801d7f:	ff 75 0c             	push   0xc(%ebp)
  801d82:	ff 75 08             	push   0x8(%ebp)
  801d85:	e8 8a ff ff ff       	call   801d14 <memmove>
}
  801d8a:	c9                   	leave  
  801d8b:	c3                   	ret    

00801d8c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	56                   	push   %esi
  801d90:	53                   	push   %ebx
  801d91:	8b 45 08             	mov    0x8(%ebp),%eax
  801d94:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d97:	89 c6                	mov    %eax,%esi
  801d99:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d9c:	eb 06                	jmp    801da4 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801d9e:	83 c0 01             	add    $0x1,%eax
  801da1:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801da4:	39 f0                	cmp    %esi,%eax
  801da6:	74 14                	je     801dbc <memcmp+0x30>
		if (*s1 != *s2)
  801da8:	0f b6 08             	movzbl (%eax),%ecx
  801dab:	0f b6 1a             	movzbl (%edx),%ebx
  801dae:	38 d9                	cmp    %bl,%cl
  801db0:	74 ec                	je     801d9e <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801db2:	0f b6 c1             	movzbl %cl,%eax
  801db5:	0f b6 db             	movzbl %bl,%ebx
  801db8:	29 d8                	sub    %ebx,%eax
  801dba:	eb 05                	jmp    801dc1 <memcmp+0x35>
	}

	return 0;
  801dbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dc1:	5b                   	pop    %ebx
  801dc2:	5e                   	pop    %esi
  801dc3:	5d                   	pop    %ebp
  801dc4:	c3                   	ret    

00801dc5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801dce:	89 c2                	mov    %eax,%edx
  801dd0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801dd3:	eb 03                	jmp    801dd8 <memfind+0x13>
  801dd5:	83 c0 01             	add    $0x1,%eax
  801dd8:	39 d0                	cmp    %edx,%eax
  801dda:	73 04                	jae    801de0 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801ddc:	38 08                	cmp    %cl,(%eax)
  801dde:	75 f5                	jne    801dd5 <memfind+0x10>
			break;
	return (void *) s;
}
  801de0:	5d                   	pop    %ebp
  801de1:	c3                   	ret    

00801de2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	57                   	push   %edi
  801de6:	56                   	push   %esi
  801de7:	53                   	push   %ebx
  801de8:	8b 55 08             	mov    0x8(%ebp),%edx
  801deb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dee:	eb 03                	jmp    801df3 <strtol+0x11>
		s++;
  801df0:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801df3:	0f b6 02             	movzbl (%edx),%eax
  801df6:	3c 20                	cmp    $0x20,%al
  801df8:	74 f6                	je     801df0 <strtol+0xe>
  801dfa:	3c 09                	cmp    $0x9,%al
  801dfc:	74 f2                	je     801df0 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801dfe:	3c 2b                	cmp    $0x2b,%al
  801e00:	74 2a                	je     801e2c <strtol+0x4a>
	int neg = 0;
  801e02:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801e07:	3c 2d                	cmp    $0x2d,%al
  801e09:	74 2b                	je     801e36 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e0b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e11:	75 0f                	jne    801e22 <strtol+0x40>
  801e13:	80 3a 30             	cmpb   $0x30,(%edx)
  801e16:	74 28                	je     801e40 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e18:	85 db                	test   %ebx,%ebx
  801e1a:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e1f:	0f 44 d8             	cmove  %eax,%ebx
  801e22:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e27:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801e2a:	eb 46                	jmp    801e72 <strtol+0x90>
		s++;
  801e2c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801e2f:	bf 00 00 00 00       	mov    $0x0,%edi
  801e34:	eb d5                	jmp    801e0b <strtol+0x29>
		s++, neg = 1;
  801e36:	83 c2 01             	add    $0x1,%edx
  801e39:	bf 01 00 00 00       	mov    $0x1,%edi
  801e3e:	eb cb                	jmp    801e0b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e40:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e44:	74 0e                	je     801e54 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801e46:	85 db                	test   %ebx,%ebx
  801e48:	75 d8                	jne    801e22 <strtol+0x40>
		s++, base = 8;
  801e4a:	83 c2 01             	add    $0x1,%edx
  801e4d:	bb 08 00 00 00       	mov    $0x8,%ebx
  801e52:	eb ce                	jmp    801e22 <strtol+0x40>
		s += 2, base = 16;
  801e54:	83 c2 02             	add    $0x2,%edx
  801e57:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e5c:	eb c4                	jmp    801e22 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801e5e:	0f be c0             	movsbl %al,%eax
  801e61:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801e64:	3b 45 10             	cmp    0x10(%ebp),%eax
  801e67:	7d 3a                	jge    801ea3 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801e69:	83 c2 01             	add    $0x1,%edx
  801e6c:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801e70:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801e72:	0f b6 02             	movzbl (%edx),%eax
  801e75:	8d 70 d0             	lea    -0x30(%eax),%esi
  801e78:	89 f3                	mov    %esi,%ebx
  801e7a:	80 fb 09             	cmp    $0x9,%bl
  801e7d:	76 df                	jbe    801e5e <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801e7f:	8d 70 9f             	lea    -0x61(%eax),%esi
  801e82:	89 f3                	mov    %esi,%ebx
  801e84:	80 fb 19             	cmp    $0x19,%bl
  801e87:	77 08                	ja     801e91 <strtol+0xaf>
			dig = *s - 'a' + 10;
  801e89:	0f be c0             	movsbl %al,%eax
  801e8c:	83 e8 57             	sub    $0x57,%eax
  801e8f:	eb d3                	jmp    801e64 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801e91:	8d 70 bf             	lea    -0x41(%eax),%esi
  801e94:	89 f3                	mov    %esi,%ebx
  801e96:	80 fb 19             	cmp    $0x19,%bl
  801e99:	77 08                	ja     801ea3 <strtol+0xc1>
			dig = *s - 'A' + 10;
  801e9b:	0f be c0             	movsbl %al,%eax
  801e9e:	83 e8 37             	sub    $0x37,%eax
  801ea1:	eb c1                	jmp    801e64 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801ea3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ea7:	74 05                	je     801eae <strtol+0xcc>
		*endptr = (char *) s;
  801ea9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eac:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801eae:	89 c8                	mov    %ecx,%eax
  801eb0:	f7 d8                	neg    %eax
  801eb2:	85 ff                	test   %edi,%edi
  801eb4:	0f 45 c8             	cmovne %eax,%ecx
}
  801eb7:	89 c8                	mov    %ecx,%eax
  801eb9:	5b                   	pop    %ebx
  801eba:	5e                   	pop    %esi
  801ebb:	5f                   	pop    %edi
  801ebc:	5d                   	pop    %ebp
  801ebd:	c3                   	ret    

00801ebe <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	56                   	push   %esi
  801ec2:	53                   	push   %ebx
  801ec3:	8b 75 08             	mov    0x8(%ebp),%esi
  801ec6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801ecc:	85 c0                	test   %eax,%eax
  801ece:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ed3:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ed6:	83 ec 0c             	sub    $0xc,%esp
  801ed9:	50                   	push   %eax
  801eda:	e8 3a e4 ff ff       	call   800319 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801edf:	83 c4 10             	add    $0x10,%esp
  801ee2:	85 f6                	test   %esi,%esi
  801ee4:	74 17                	je     801efd <ipc_recv+0x3f>
  801ee6:	ba 00 00 00 00       	mov    $0x0,%edx
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	78 0c                	js     801efb <ipc_recv+0x3d>
  801eef:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ef5:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801efb:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801efd:	85 db                	test   %ebx,%ebx
  801eff:	74 17                	je     801f18 <ipc_recv+0x5a>
  801f01:	ba 00 00 00 00       	mov    $0x0,%edx
  801f06:	85 c0                	test   %eax,%eax
  801f08:	78 0c                	js     801f16 <ipc_recv+0x58>
  801f0a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f10:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801f16:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f18:	85 c0                	test   %eax,%eax
  801f1a:	78 0b                	js     801f27 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801f1c:	a1 00 40 80 00       	mov    0x804000,%eax
  801f21:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801f27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f2a:	5b                   	pop    %ebx
  801f2b:	5e                   	pop    %esi
  801f2c:	5d                   	pop    %ebp
  801f2d:	c3                   	ret    

00801f2e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	57                   	push   %edi
  801f32:	56                   	push   %esi
  801f33:	53                   	push   %ebx
  801f34:	83 ec 0c             	sub    $0xc,%esp
  801f37:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f3a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f40:	85 db                	test   %ebx,%ebx
  801f42:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f47:	0f 44 d8             	cmove  %eax,%ebx
  801f4a:	eb 05                	jmp    801f51 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f4c:	e8 f9 e1 ff ff       	call   80014a <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f51:	ff 75 14             	push   0x14(%ebp)
  801f54:	53                   	push   %ebx
  801f55:	56                   	push   %esi
  801f56:	57                   	push   %edi
  801f57:	e8 9a e3 ff ff       	call   8002f6 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f5c:	83 c4 10             	add    $0x10,%esp
  801f5f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f62:	74 e8                	je     801f4c <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f64:	85 c0                	test   %eax,%eax
  801f66:	78 08                	js     801f70 <ipc_send+0x42>
	}while (r<0);

}
  801f68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6b:	5b                   	pop    %ebx
  801f6c:	5e                   	pop    %esi
  801f6d:	5f                   	pop    %edi
  801f6e:	5d                   	pop    %ebp
  801f6f:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f70:	50                   	push   %eax
  801f71:	68 bf 26 80 00       	push   $0x8026bf
  801f76:	6a 3d                	push   $0x3d
  801f78:	68 d3 26 80 00       	push   $0x8026d3
  801f7d:	e8 47 f5 ff ff       	call   8014c9 <_panic>

00801f82 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f82:	55                   	push   %ebp
  801f83:	89 e5                	mov    %esp,%ebp
  801f85:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f88:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f8d:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  801f93:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f99:	8b 52 60             	mov    0x60(%edx),%edx
  801f9c:	39 ca                	cmp    %ecx,%edx
  801f9e:	74 11                	je     801fb1 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  801fa0:	83 c0 01             	add    $0x1,%eax
  801fa3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fa8:	75 e3                	jne    801f8d <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801faa:	b8 00 00 00 00       	mov    $0x0,%eax
  801faf:	eb 0e                	jmp    801fbf <ipc_find_env+0x3d>
			return envs[i].env_id;
  801fb1:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801fb7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fbc:	8b 40 58             	mov    0x58(%eax),%eax
}
  801fbf:	5d                   	pop    %ebp
  801fc0:	c3                   	ret    

00801fc1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fc1:	55                   	push   %ebp
  801fc2:	89 e5                	mov    %esp,%ebp
  801fc4:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc7:	89 c2                	mov    %eax,%edx
  801fc9:	c1 ea 16             	shr    $0x16,%edx
  801fcc:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fd3:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fd8:	f6 c1 01             	test   $0x1,%cl
  801fdb:	74 1c                	je     801ff9 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801fdd:	c1 e8 0c             	shr    $0xc,%eax
  801fe0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fe7:	a8 01                	test   $0x1,%al
  801fe9:	74 0e                	je     801ff9 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801feb:	c1 e8 0c             	shr    $0xc,%eax
  801fee:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801ff5:	ef 
  801ff6:	0f b7 d2             	movzwl %dx,%edx
}
  801ff9:	89 d0                	mov    %edx,%eax
  801ffb:	5d                   	pop    %ebp
  801ffc:	c3                   	ret    
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
