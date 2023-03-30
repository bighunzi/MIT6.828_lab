
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
  800049:	e8 ce 00 00 00       	call   80011c <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008a:	e8 ee 04 00 00       	call   80057d <close_all>
	sys_env_destroy(0);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	6a 00                	push   $0x0
  800094:	e8 42 00 00 00       	call   8000db <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7f 08                	jg     800105 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5f                   	pop    %edi
  800103:	5d                   	pop    %ebp
  800104:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800105:	83 ec 0c             	sub    $0xc,%esp
  800108:	50                   	push   %eax
  800109:	6a 03                	push   $0x3
  80010b:	68 2a 22 80 00       	push   $0x80222a
  800110:	6a 2a                	push   $0x2a
  800112:	68 47 22 80 00       	push   $0x802247
  800117:	e8 9e 13 00 00       	call   8014ba <_panic>

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
	asm volatile("int %1\n"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 02 00 00 00       	mov    $0x2,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	89 d6                	mov    %edx,%esi
  800134:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_yield>:

void
sys_yield(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800163:	be 00 00 00 00       	mov    $0x0,%esi
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016e:	b8 04 00 00 00       	mov    $0x4,%eax
  800173:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800176:	89 f7                	mov    %esi,%edi
  800178:	cd 30                	int    $0x30
	if(check && ret > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7f 08                	jg     800186 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80017e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800181:	5b                   	pop    %ebx
  800182:	5e                   	pop    %esi
  800183:	5f                   	pop    %edi
  800184:	5d                   	pop    %ebp
  800185:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800186:	83 ec 0c             	sub    $0xc,%esp
  800189:	50                   	push   %eax
  80018a:	6a 04                	push   $0x4
  80018c:	68 2a 22 80 00       	push   $0x80222a
  800191:	6a 2a                	push   $0x2a
  800193:	68 47 22 80 00       	push   $0x802247
  800198:	e8 1d 13 00 00       	call   8014ba <_panic>

0080019d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ac:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ba:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	7f 08                	jg     8001c8 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c3:	5b                   	pop    %ebx
  8001c4:	5e                   	pop    %esi
  8001c5:	5f                   	pop    %edi
  8001c6:	5d                   	pop    %ebp
  8001c7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c8:	83 ec 0c             	sub    $0xc,%esp
  8001cb:	50                   	push   %eax
  8001cc:	6a 05                	push   $0x5
  8001ce:	68 2a 22 80 00       	push   $0x80222a
  8001d3:	6a 2a                	push   $0x2a
  8001d5:	68 47 22 80 00       	push   $0x802247
  8001da:	e8 db 12 00 00       	call   8014ba <_panic>

008001df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f3:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f8:	89 df                	mov    %ebx,%edi
  8001fa:	89 de                	mov    %ebx,%esi
  8001fc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7f 08                	jg     80020a <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800202:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800205:	5b                   	pop    %ebx
  800206:	5e                   	pop    %esi
  800207:	5f                   	pop    %edi
  800208:	5d                   	pop    %ebp
  800209:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80020a:	83 ec 0c             	sub    $0xc,%esp
  80020d:	50                   	push   %eax
  80020e:	6a 06                	push   $0x6
  800210:	68 2a 22 80 00       	push   $0x80222a
  800215:	6a 2a                	push   $0x2a
  800217:	68 47 22 80 00       	push   $0x802247
  80021c:	e8 99 12 00 00       	call   8014ba <_panic>

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	8b 55 08             	mov    0x8(%ebp),%edx
  800232:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800235:	b8 08 00 00 00       	mov    $0x8,%eax
  80023a:	89 df                	mov    %ebx,%edi
  80023c:	89 de                	mov    %ebx,%esi
  80023e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7f 08                	jg     80024c <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800244:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800247:	5b                   	pop    %ebx
  800248:	5e                   	pop    %esi
  800249:	5f                   	pop    %edi
  80024a:	5d                   	pop    %ebp
  80024b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	50                   	push   %eax
  800250:	6a 08                	push   $0x8
  800252:	68 2a 22 80 00       	push   $0x80222a
  800257:	6a 2a                	push   $0x2a
  800259:	68 47 22 80 00       	push   $0x802247
  80025e:	e8 57 12 00 00       	call   8014ba <_panic>

00800263 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	8b 55 08             	mov    0x8(%ebp),%edx
  800274:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800277:	b8 09 00 00 00       	mov    $0x9,%eax
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7f 08                	jg     80028e <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800286:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800289:	5b                   	pop    %ebx
  80028a:	5e                   	pop    %esi
  80028b:	5f                   	pop    %edi
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80028e:	83 ec 0c             	sub    $0xc,%esp
  800291:	50                   	push   %eax
  800292:	6a 09                	push   $0x9
  800294:	68 2a 22 80 00       	push   $0x80222a
  800299:	6a 2a                	push   $0x2a
  80029b:	68 47 22 80 00       	push   $0x802247
  8002a0:	e8 15 12 00 00       	call   8014ba <_panic>

008002a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002be:	89 df                	mov    %ebx,%edi
  8002c0:	89 de                	mov    %ebx,%esi
  8002c2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7f 08                	jg     8002d0 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cb:	5b                   	pop    %ebx
  8002cc:	5e                   	pop    %esi
  8002cd:	5f                   	pop    %edi
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	50                   	push   %eax
  8002d4:	6a 0a                	push   $0xa
  8002d6:	68 2a 22 80 00       	push   $0x80222a
  8002db:	6a 2a                	push   $0x2a
  8002dd:	68 47 22 80 00       	push   $0x802247
  8002e2:	e8 d3 11 00 00       	call   8014ba <_panic>

008002e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f8:	be 00 00 00 00       	mov    $0x0,%esi
  8002fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800300:	8b 7d 14             	mov    0x14(%ebp),%edi
  800303:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800320:	89 cb                	mov    %ecx,%ebx
  800322:	89 cf                	mov    %ecx,%edi
  800324:	89 ce                	mov    %ecx,%esi
  800326:	cd 30                	int    $0x30
	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7f 08                	jg     800334 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80032c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032f:	5b                   	pop    %ebx
  800330:	5e                   	pop    %esi
  800331:	5f                   	pop    %edi
  800332:	5d                   	pop    %ebp
  800333:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800334:	83 ec 0c             	sub    $0xc,%esp
  800337:	50                   	push   %eax
  800338:	6a 0d                	push   $0xd
  80033a:	68 2a 22 80 00       	push   $0x80222a
  80033f:	6a 2a                	push   $0x2a
  800341:	68 47 22 80 00       	push   $0x802247
  800346:	e8 6f 11 00 00       	call   8014ba <_panic>

0080034b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	57                   	push   %edi
  80034f:	56                   	push   %esi
  800350:	53                   	push   %ebx
	asm volatile("int %1\n"
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	b8 0e 00 00 00       	mov    $0xe,%eax
  80035b:	89 d1                	mov    %edx,%ecx
  80035d:	89 d3                	mov    %edx,%ebx
  80035f:	89 d7                	mov    %edx,%edi
  800361:	89 d6                	mov    %edx,%esi
  800363:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800365:	5b                   	pop    %ebx
  800366:	5e                   	pop    %esi
  800367:	5f                   	pop    %edi
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	57                   	push   %edi
  80036e:	56                   	push   %esi
  80036f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800370:	bb 00 00 00 00       	mov    $0x0,%ebx
  800375:	8b 55 08             	mov    0x8(%ebp),%edx
  800378:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80037b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800380:	89 df                	mov    %ebx,%edi
  800382:	89 de                	mov    %ebx,%esi
  800384:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800386:	5b                   	pop    %ebx
  800387:	5e                   	pop    %esi
  800388:	5f                   	pop    %edi
  800389:	5d                   	pop    %ebp
  80038a:	c3                   	ret    

0080038b <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
  80038e:	57                   	push   %edi
  80038f:	56                   	push   %esi
  800390:	53                   	push   %ebx
	asm volatile("int %1\n"
  800391:	bb 00 00 00 00       	mov    $0x0,%ebx
  800396:	8b 55 08             	mov    0x8(%ebp),%edx
  800399:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80039c:	b8 10 00 00 00       	mov    $0x10,%eax
  8003a1:	89 df                	mov    %ebx,%edi
  8003a3:	89 de                	mov    %ebx,%esi
  8003a5:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8003a7:	5b                   	pop    %ebx
  8003a8:	5e                   	pop    %esi
  8003a9:	5f                   	pop    %edi
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003af:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b2:	05 00 00 00 30       	add    $0x30000000,%eax
  8003b7:	c1 e8 0c             	shr    $0xc,%eax
}
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c2:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003cc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003d1:	5d                   	pop    %ebp
  8003d2:	c3                   	ret    

008003d3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003db:	89 c2                	mov    %eax,%edx
  8003dd:	c1 ea 16             	shr    $0x16,%edx
  8003e0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e7:	f6 c2 01             	test   $0x1,%dl
  8003ea:	74 29                	je     800415 <fd_alloc+0x42>
  8003ec:	89 c2                	mov    %eax,%edx
  8003ee:	c1 ea 0c             	shr    $0xc,%edx
  8003f1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f8:	f6 c2 01             	test   $0x1,%dl
  8003fb:	74 18                	je     800415 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8003fd:	05 00 10 00 00       	add    $0x1000,%eax
  800402:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800407:	75 d2                	jne    8003db <fd_alloc+0x8>
  800409:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80040e:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800413:	eb 05                	jmp    80041a <fd_alloc+0x47>
			return 0;
  800415:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80041a:	8b 55 08             	mov    0x8(%ebp),%edx
  80041d:	89 02                	mov    %eax,(%edx)
}
  80041f:	89 c8                	mov    %ecx,%eax
  800421:	5d                   	pop    %ebp
  800422:	c3                   	ret    

00800423 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800429:	83 f8 1f             	cmp    $0x1f,%eax
  80042c:	77 30                	ja     80045e <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80042e:	c1 e0 0c             	shl    $0xc,%eax
  800431:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800436:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80043c:	f6 c2 01             	test   $0x1,%dl
  80043f:	74 24                	je     800465 <fd_lookup+0x42>
  800441:	89 c2                	mov    %eax,%edx
  800443:	c1 ea 0c             	shr    $0xc,%edx
  800446:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80044d:	f6 c2 01             	test   $0x1,%dl
  800450:	74 1a                	je     80046c <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800452:	8b 55 0c             	mov    0xc(%ebp),%edx
  800455:	89 02                	mov    %eax,(%edx)
	return 0;
  800457:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80045c:	5d                   	pop    %ebp
  80045d:	c3                   	ret    
		return -E_INVAL;
  80045e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800463:	eb f7                	jmp    80045c <fd_lookup+0x39>
		return -E_INVAL;
  800465:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80046a:	eb f0                	jmp    80045c <fd_lookup+0x39>
  80046c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800471:	eb e9                	jmp    80045c <fd_lookup+0x39>

00800473 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	53                   	push   %ebx
  800477:	83 ec 04             	sub    $0x4,%esp
  80047a:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80047d:	b8 00 00 00 00       	mov    $0x0,%eax
  800482:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800487:	39 13                	cmp    %edx,(%ebx)
  800489:	74 37                	je     8004c2 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  80048b:	83 c0 01             	add    $0x1,%eax
  80048e:	8b 1c 85 d4 22 80 00 	mov    0x8022d4(,%eax,4),%ebx
  800495:	85 db                	test   %ebx,%ebx
  800497:	75 ee                	jne    800487 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800499:	a1 00 40 80 00       	mov    0x804000,%eax
  80049e:	8b 40 48             	mov    0x48(%eax),%eax
  8004a1:	83 ec 04             	sub    $0x4,%esp
  8004a4:	52                   	push   %edx
  8004a5:	50                   	push   %eax
  8004a6:	68 58 22 80 00       	push   $0x802258
  8004ab:	e8 e5 10 00 00       	call   801595 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8004b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004bb:	89 1a                	mov    %ebx,(%edx)
}
  8004bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004c0:	c9                   	leave  
  8004c1:	c3                   	ret    
			return 0;
  8004c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c7:	eb ef                	jmp    8004b8 <dev_lookup+0x45>

008004c9 <fd_close>:
{
  8004c9:	55                   	push   %ebp
  8004ca:	89 e5                	mov    %esp,%ebp
  8004cc:	57                   	push   %edi
  8004cd:	56                   	push   %esi
  8004ce:	53                   	push   %ebx
  8004cf:	83 ec 24             	sub    $0x24,%esp
  8004d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d5:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004d8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004db:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004dc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004e2:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e5:	50                   	push   %eax
  8004e6:	e8 38 ff ff ff       	call   800423 <fd_lookup>
  8004eb:	89 c3                	mov    %eax,%ebx
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	78 05                	js     8004f9 <fd_close+0x30>
	    || fd != fd2)
  8004f4:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004f7:	74 16                	je     80050f <fd_close+0x46>
		return (must_exist ? r : 0);
  8004f9:	89 f8                	mov    %edi,%eax
  8004fb:	84 c0                	test   %al,%al
  8004fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800502:	0f 44 d8             	cmove  %eax,%ebx
}
  800505:	89 d8                	mov    %ebx,%eax
  800507:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80050a:	5b                   	pop    %ebx
  80050b:	5e                   	pop    %esi
  80050c:	5f                   	pop    %edi
  80050d:	5d                   	pop    %ebp
  80050e:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800515:	50                   	push   %eax
  800516:	ff 36                	push   (%esi)
  800518:	e8 56 ff ff ff       	call   800473 <dev_lookup>
  80051d:	89 c3                	mov    %eax,%ebx
  80051f:	83 c4 10             	add    $0x10,%esp
  800522:	85 c0                	test   %eax,%eax
  800524:	78 1a                	js     800540 <fd_close+0x77>
		if (dev->dev_close)
  800526:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800529:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80052c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800531:	85 c0                	test   %eax,%eax
  800533:	74 0b                	je     800540 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800535:	83 ec 0c             	sub    $0xc,%esp
  800538:	56                   	push   %esi
  800539:	ff d0                	call   *%eax
  80053b:	89 c3                	mov    %eax,%ebx
  80053d:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800540:	83 ec 08             	sub    $0x8,%esp
  800543:	56                   	push   %esi
  800544:	6a 00                	push   $0x0
  800546:	e8 94 fc ff ff       	call   8001df <sys_page_unmap>
	return r;
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	eb b5                	jmp    800505 <fd_close+0x3c>

00800550 <close>:

int
close(int fdnum)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800556:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800559:	50                   	push   %eax
  80055a:	ff 75 08             	push   0x8(%ebp)
  80055d:	e8 c1 fe ff ff       	call   800423 <fd_lookup>
  800562:	83 c4 10             	add    $0x10,%esp
  800565:	85 c0                	test   %eax,%eax
  800567:	79 02                	jns    80056b <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800569:	c9                   	leave  
  80056a:	c3                   	ret    
		return fd_close(fd, 1);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	6a 01                	push   $0x1
  800570:	ff 75 f4             	push   -0xc(%ebp)
  800573:	e8 51 ff ff ff       	call   8004c9 <fd_close>
  800578:	83 c4 10             	add    $0x10,%esp
  80057b:	eb ec                	jmp    800569 <close+0x19>

0080057d <close_all>:

void
close_all(void)
{
  80057d:	55                   	push   %ebp
  80057e:	89 e5                	mov    %esp,%ebp
  800580:	53                   	push   %ebx
  800581:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800584:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800589:	83 ec 0c             	sub    $0xc,%esp
  80058c:	53                   	push   %ebx
  80058d:	e8 be ff ff ff       	call   800550 <close>
	for (i = 0; i < MAXFD; i++)
  800592:	83 c3 01             	add    $0x1,%ebx
  800595:	83 c4 10             	add    $0x10,%esp
  800598:	83 fb 20             	cmp    $0x20,%ebx
  80059b:	75 ec                	jne    800589 <close_all+0xc>
}
  80059d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005a0:	c9                   	leave  
  8005a1:	c3                   	ret    

008005a2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005a2:	55                   	push   %ebp
  8005a3:	89 e5                	mov    %esp,%ebp
  8005a5:	57                   	push   %edi
  8005a6:	56                   	push   %esi
  8005a7:	53                   	push   %ebx
  8005a8:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005ab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005ae:	50                   	push   %eax
  8005af:	ff 75 08             	push   0x8(%ebp)
  8005b2:	e8 6c fe ff ff       	call   800423 <fd_lookup>
  8005b7:	89 c3                	mov    %eax,%ebx
  8005b9:	83 c4 10             	add    $0x10,%esp
  8005bc:	85 c0                	test   %eax,%eax
  8005be:	78 7f                	js     80063f <dup+0x9d>
		return r;
	close(newfdnum);
  8005c0:	83 ec 0c             	sub    $0xc,%esp
  8005c3:	ff 75 0c             	push   0xc(%ebp)
  8005c6:	e8 85 ff ff ff       	call   800550 <close>

	newfd = INDEX2FD(newfdnum);
  8005cb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005ce:	c1 e6 0c             	shl    $0xc,%esi
  8005d1:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005da:	89 3c 24             	mov    %edi,(%esp)
  8005dd:	e8 da fd ff ff       	call   8003bc <fd2data>
  8005e2:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005e4:	89 34 24             	mov    %esi,(%esp)
  8005e7:	e8 d0 fd ff ff       	call   8003bc <fd2data>
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005f2:	89 d8                	mov    %ebx,%eax
  8005f4:	c1 e8 16             	shr    $0x16,%eax
  8005f7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005fe:	a8 01                	test   $0x1,%al
  800600:	74 11                	je     800613 <dup+0x71>
  800602:	89 d8                	mov    %ebx,%eax
  800604:	c1 e8 0c             	shr    $0xc,%eax
  800607:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80060e:	f6 c2 01             	test   $0x1,%dl
  800611:	75 36                	jne    800649 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800613:	89 f8                	mov    %edi,%eax
  800615:	c1 e8 0c             	shr    $0xc,%eax
  800618:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80061f:	83 ec 0c             	sub    $0xc,%esp
  800622:	25 07 0e 00 00       	and    $0xe07,%eax
  800627:	50                   	push   %eax
  800628:	56                   	push   %esi
  800629:	6a 00                	push   $0x0
  80062b:	57                   	push   %edi
  80062c:	6a 00                	push   $0x0
  80062e:	e8 6a fb ff ff       	call   80019d <sys_page_map>
  800633:	89 c3                	mov    %eax,%ebx
  800635:	83 c4 20             	add    $0x20,%esp
  800638:	85 c0                	test   %eax,%eax
  80063a:	78 33                	js     80066f <dup+0xcd>
		goto err;

	return newfdnum;
  80063c:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80063f:	89 d8                	mov    %ebx,%eax
  800641:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800644:	5b                   	pop    %ebx
  800645:	5e                   	pop    %esi
  800646:	5f                   	pop    %edi
  800647:	5d                   	pop    %ebp
  800648:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800649:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800650:	83 ec 0c             	sub    $0xc,%esp
  800653:	25 07 0e 00 00       	and    $0xe07,%eax
  800658:	50                   	push   %eax
  800659:	ff 75 d4             	push   -0x2c(%ebp)
  80065c:	6a 00                	push   $0x0
  80065e:	53                   	push   %ebx
  80065f:	6a 00                	push   $0x0
  800661:	e8 37 fb ff ff       	call   80019d <sys_page_map>
  800666:	89 c3                	mov    %eax,%ebx
  800668:	83 c4 20             	add    $0x20,%esp
  80066b:	85 c0                	test   %eax,%eax
  80066d:	79 a4                	jns    800613 <dup+0x71>
	sys_page_unmap(0, newfd);
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	56                   	push   %esi
  800673:	6a 00                	push   $0x0
  800675:	e8 65 fb ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  80067a:	83 c4 08             	add    $0x8,%esp
  80067d:	ff 75 d4             	push   -0x2c(%ebp)
  800680:	6a 00                	push   $0x0
  800682:	e8 58 fb ff ff       	call   8001df <sys_page_unmap>
	return r;
  800687:	83 c4 10             	add    $0x10,%esp
  80068a:	eb b3                	jmp    80063f <dup+0x9d>

0080068c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80068c:	55                   	push   %ebp
  80068d:	89 e5                	mov    %esp,%ebp
  80068f:	56                   	push   %esi
  800690:	53                   	push   %ebx
  800691:	83 ec 18             	sub    $0x18,%esp
  800694:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800697:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80069a:	50                   	push   %eax
  80069b:	56                   	push   %esi
  80069c:	e8 82 fd ff ff       	call   800423 <fd_lookup>
  8006a1:	83 c4 10             	add    $0x10,%esp
  8006a4:	85 c0                	test   %eax,%eax
  8006a6:	78 3c                	js     8006e4 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a8:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006b1:	50                   	push   %eax
  8006b2:	ff 33                	push   (%ebx)
  8006b4:	e8 ba fd ff ff       	call   800473 <dev_lookup>
  8006b9:	83 c4 10             	add    $0x10,%esp
  8006bc:	85 c0                	test   %eax,%eax
  8006be:	78 24                	js     8006e4 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006c0:	8b 43 08             	mov    0x8(%ebx),%eax
  8006c3:	83 e0 03             	and    $0x3,%eax
  8006c6:	83 f8 01             	cmp    $0x1,%eax
  8006c9:	74 20                	je     8006eb <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ce:	8b 40 08             	mov    0x8(%eax),%eax
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	74 37                	je     80070c <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006d5:	83 ec 04             	sub    $0x4,%esp
  8006d8:	ff 75 10             	push   0x10(%ebp)
  8006db:	ff 75 0c             	push   0xc(%ebp)
  8006de:	53                   	push   %ebx
  8006df:	ff d0                	call   *%eax
  8006e1:	83 c4 10             	add    $0x10,%esp
}
  8006e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006e7:	5b                   	pop    %ebx
  8006e8:	5e                   	pop    %esi
  8006e9:	5d                   	pop    %ebp
  8006ea:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006eb:	a1 00 40 80 00       	mov    0x804000,%eax
  8006f0:	8b 40 48             	mov    0x48(%eax),%eax
  8006f3:	83 ec 04             	sub    $0x4,%esp
  8006f6:	56                   	push   %esi
  8006f7:	50                   	push   %eax
  8006f8:	68 99 22 80 00       	push   $0x802299
  8006fd:	e8 93 0e 00 00       	call   801595 <cprintf>
		return -E_INVAL;
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80070a:	eb d8                	jmp    8006e4 <read+0x58>
		return -E_NOT_SUPP;
  80070c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800711:	eb d1                	jmp    8006e4 <read+0x58>

00800713 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	57                   	push   %edi
  800717:	56                   	push   %esi
  800718:	53                   	push   %ebx
  800719:	83 ec 0c             	sub    $0xc,%esp
  80071c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80071f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800722:	bb 00 00 00 00       	mov    $0x0,%ebx
  800727:	eb 02                	jmp    80072b <readn+0x18>
  800729:	01 c3                	add    %eax,%ebx
  80072b:	39 f3                	cmp    %esi,%ebx
  80072d:	73 21                	jae    800750 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80072f:	83 ec 04             	sub    $0x4,%esp
  800732:	89 f0                	mov    %esi,%eax
  800734:	29 d8                	sub    %ebx,%eax
  800736:	50                   	push   %eax
  800737:	89 d8                	mov    %ebx,%eax
  800739:	03 45 0c             	add    0xc(%ebp),%eax
  80073c:	50                   	push   %eax
  80073d:	57                   	push   %edi
  80073e:	e8 49 ff ff ff       	call   80068c <read>
		if (m < 0)
  800743:	83 c4 10             	add    $0x10,%esp
  800746:	85 c0                	test   %eax,%eax
  800748:	78 04                	js     80074e <readn+0x3b>
			return m;
		if (m == 0)
  80074a:	75 dd                	jne    800729 <readn+0x16>
  80074c:	eb 02                	jmp    800750 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80074e:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800750:	89 d8                	mov    %ebx,%eax
  800752:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800755:	5b                   	pop    %ebx
  800756:	5e                   	pop    %esi
  800757:	5f                   	pop    %edi
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	56                   	push   %esi
  80075e:	53                   	push   %ebx
  80075f:	83 ec 18             	sub    $0x18,%esp
  800762:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800765:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800768:	50                   	push   %eax
  800769:	53                   	push   %ebx
  80076a:	e8 b4 fc ff ff       	call   800423 <fd_lookup>
  80076f:	83 c4 10             	add    $0x10,%esp
  800772:	85 c0                	test   %eax,%eax
  800774:	78 37                	js     8007ad <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800776:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800779:	83 ec 08             	sub    $0x8,%esp
  80077c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80077f:	50                   	push   %eax
  800780:	ff 36                	push   (%esi)
  800782:	e8 ec fc ff ff       	call   800473 <dev_lookup>
  800787:	83 c4 10             	add    $0x10,%esp
  80078a:	85 c0                	test   %eax,%eax
  80078c:	78 1f                	js     8007ad <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80078e:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800792:	74 20                	je     8007b4 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800794:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800797:	8b 40 0c             	mov    0xc(%eax),%eax
  80079a:	85 c0                	test   %eax,%eax
  80079c:	74 37                	je     8007d5 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80079e:	83 ec 04             	sub    $0x4,%esp
  8007a1:	ff 75 10             	push   0x10(%ebp)
  8007a4:	ff 75 0c             	push   0xc(%ebp)
  8007a7:	56                   	push   %esi
  8007a8:	ff d0                	call   *%eax
  8007aa:	83 c4 10             	add    $0x10,%esp
}
  8007ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007b0:	5b                   	pop    %ebx
  8007b1:	5e                   	pop    %esi
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007b4:	a1 00 40 80 00       	mov    0x804000,%eax
  8007b9:	8b 40 48             	mov    0x48(%eax),%eax
  8007bc:	83 ec 04             	sub    $0x4,%esp
  8007bf:	53                   	push   %ebx
  8007c0:	50                   	push   %eax
  8007c1:	68 b5 22 80 00       	push   $0x8022b5
  8007c6:	e8 ca 0d 00 00       	call   801595 <cprintf>
		return -E_INVAL;
  8007cb:	83 c4 10             	add    $0x10,%esp
  8007ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d3:	eb d8                	jmp    8007ad <write+0x53>
		return -E_NOT_SUPP;
  8007d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007da:	eb d1                	jmp    8007ad <write+0x53>

008007dc <seek>:

int
seek(int fdnum, off_t offset)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e5:	50                   	push   %eax
  8007e6:	ff 75 08             	push   0x8(%ebp)
  8007e9:	e8 35 fc ff ff       	call   800423 <fd_lookup>
  8007ee:	83 c4 10             	add    $0x10,%esp
  8007f1:	85 c0                	test   %eax,%eax
  8007f3:	78 0e                	js     800803 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007fb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800803:	c9                   	leave  
  800804:	c3                   	ret    

00800805 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	56                   	push   %esi
  800809:	53                   	push   %ebx
  80080a:	83 ec 18             	sub    $0x18,%esp
  80080d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800810:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800813:	50                   	push   %eax
  800814:	53                   	push   %ebx
  800815:	e8 09 fc ff ff       	call   800423 <fd_lookup>
  80081a:	83 c4 10             	add    $0x10,%esp
  80081d:	85 c0                	test   %eax,%eax
  80081f:	78 34                	js     800855 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800821:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800824:	83 ec 08             	sub    $0x8,%esp
  800827:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80082a:	50                   	push   %eax
  80082b:	ff 36                	push   (%esi)
  80082d:	e8 41 fc ff ff       	call   800473 <dev_lookup>
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	85 c0                	test   %eax,%eax
  800837:	78 1c                	js     800855 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800839:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80083d:	74 1d                	je     80085c <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80083f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800842:	8b 40 18             	mov    0x18(%eax),%eax
  800845:	85 c0                	test   %eax,%eax
  800847:	74 34                	je     80087d <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800849:	83 ec 08             	sub    $0x8,%esp
  80084c:	ff 75 0c             	push   0xc(%ebp)
  80084f:	56                   	push   %esi
  800850:	ff d0                	call   *%eax
  800852:	83 c4 10             	add    $0x10,%esp
}
  800855:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800858:	5b                   	pop    %ebx
  800859:	5e                   	pop    %esi
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    
			thisenv->env_id, fdnum);
  80085c:	a1 00 40 80 00       	mov    0x804000,%eax
  800861:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800864:	83 ec 04             	sub    $0x4,%esp
  800867:	53                   	push   %ebx
  800868:	50                   	push   %eax
  800869:	68 78 22 80 00       	push   $0x802278
  80086e:	e8 22 0d 00 00       	call   801595 <cprintf>
		return -E_INVAL;
  800873:	83 c4 10             	add    $0x10,%esp
  800876:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80087b:	eb d8                	jmp    800855 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80087d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800882:	eb d1                	jmp    800855 <ftruncate+0x50>

00800884 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	56                   	push   %esi
  800888:	53                   	push   %ebx
  800889:	83 ec 18             	sub    $0x18,%esp
  80088c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80088f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800892:	50                   	push   %eax
  800893:	ff 75 08             	push   0x8(%ebp)
  800896:	e8 88 fb ff ff       	call   800423 <fd_lookup>
  80089b:	83 c4 10             	add    $0x10,%esp
  80089e:	85 c0                	test   %eax,%eax
  8008a0:	78 49                	js     8008eb <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ab:	50                   	push   %eax
  8008ac:	ff 36                	push   (%esi)
  8008ae:	e8 c0 fb ff ff       	call   800473 <dev_lookup>
  8008b3:	83 c4 10             	add    $0x10,%esp
  8008b6:	85 c0                	test   %eax,%eax
  8008b8:	78 31                	js     8008eb <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8008ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008bd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c1:	74 2f                	je     8008f2 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008cd:	00 00 00 
	stat->st_isdir = 0;
  8008d0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d7:	00 00 00 
	stat->st_dev = dev;
  8008da:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008e0:	83 ec 08             	sub    $0x8,%esp
  8008e3:	53                   	push   %ebx
  8008e4:	56                   	push   %esi
  8008e5:	ff 50 14             	call   *0x14(%eax)
  8008e8:	83 c4 10             	add    $0x10,%esp
}
  8008eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ee:	5b                   	pop    %ebx
  8008ef:	5e                   	pop    %esi
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    
		return -E_NOT_SUPP;
  8008f2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008f7:	eb f2                	jmp    8008eb <fstat+0x67>

008008f9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	56                   	push   %esi
  8008fd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008fe:	83 ec 08             	sub    $0x8,%esp
  800901:	6a 00                	push   $0x0
  800903:	ff 75 08             	push   0x8(%ebp)
  800906:	e8 e4 01 00 00       	call   800aef <open>
  80090b:	89 c3                	mov    %eax,%ebx
  80090d:	83 c4 10             	add    $0x10,%esp
  800910:	85 c0                	test   %eax,%eax
  800912:	78 1b                	js     80092f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800914:	83 ec 08             	sub    $0x8,%esp
  800917:	ff 75 0c             	push   0xc(%ebp)
  80091a:	50                   	push   %eax
  80091b:	e8 64 ff ff ff       	call   800884 <fstat>
  800920:	89 c6                	mov    %eax,%esi
	close(fd);
  800922:	89 1c 24             	mov    %ebx,(%esp)
  800925:	e8 26 fc ff ff       	call   800550 <close>
	return r;
  80092a:	83 c4 10             	add    $0x10,%esp
  80092d:	89 f3                	mov    %esi,%ebx
}
  80092f:	89 d8                	mov    %ebx,%eax
  800931:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800934:	5b                   	pop    %ebx
  800935:	5e                   	pop    %esi
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	89 c6                	mov    %eax,%esi
  80093f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800941:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800948:	74 27                	je     800971 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80094a:	6a 07                	push   $0x7
  80094c:	68 00 50 80 00       	push   $0x805000
  800951:	56                   	push   %esi
  800952:	ff 35 00 60 80 00    	push   0x806000
  800958:	e8 b9 15 00 00       	call   801f16 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80095d:	83 c4 0c             	add    $0xc,%esp
  800960:	6a 00                	push   $0x0
  800962:	53                   	push   %ebx
  800963:	6a 00                	push   $0x0
  800965:	e8 45 15 00 00       	call   801eaf <ipc_recv>
}
  80096a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80096d:	5b                   	pop    %ebx
  80096e:	5e                   	pop    %esi
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800971:	83 ec 0c             	sub    $0xc,%esp
  800974:	6a 01                	push   $0x1
  800976:	e8 ef 15 00 00       	call   801f6a <ipc_find_env>
  80097b:	a3 00 60 80 00       	mov    %eax,0x806000
  800980:	83 c4 10             	add    $0x10,%esp
  800983:	eb c5                	jmp    80094a <fsipc+0x12>

00800985 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 40 0c             	mov    0xc(%eax),%eax
  800991:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800996:	8b 45 0c             	mov    0xc(%ebp),%eax
  800999:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80099e:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a3:	b8 02 00 00 00       	mov    $0x2,%eax
  8009a8:	e8 8b ff ff ff       	call   800938 <fsipc>
}
  8009ad:	c9                   	leave  
  8009ae:	c3                   	ret    

008009af <devfile_flush>:
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009bb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c5:	b8 06 00 00 00       	mov    $0x6,%eax
  8009ca:	e8 69 ff ff ff       	call   800938 <fsipc>
}
  8009cf:	c9                   	leave  
  8009d0:	c3                   	ret    

008009d1 <devfile_stat>:
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	53                   	push   %ebx
  8009d5:	83 ec 04             	sub    $0x4,%esp
  8009d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009eb:	b8 05 00 00 00       	mov    $0x5,%eax
  8009f0:	e8 43 ff ff ff       	call   800938 <fsipc>
  8009f5:	85 c0                	test   %eax,%eax
  8009f7:	78 2c                	js     800a25 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009f9:	83 ec 08             	sub    $0x8,%esp
  8009fc:	68 00 50 80 00       	push   $0x805000
  800a01:	53                   	push   %ebx
  800a02:	e8 68 11 00 00       	call   801b6f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a07:	a1 80 50 80 00       	mov    0x805080,%eax
  800a0c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a12:	a1 84 50 80 00       	mov    0x805084,%eax
  800a17:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a1d:	83 c4 10             	add    $0x10,%esp
  800a20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a28:	c9                   	leave  
  800a29:	c3                   	ret    

00800a2a <devfile_write>:
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	83 ec 0c             	sub    $0xc,%esp
  800a30:	8b 45 10             	mov    0x10(%ebp),%eax
  800a33:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a38:	39 d0                	cmp    %edx,%eax
  800a3a:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a40:	8b 52 0c             	mov    0xc(%edx),%edx
  800a43:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a49:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a4e:	50                   	push   %eax
  800a4f:	ff 75 0c             	push   0xc(%ebp)
  800a52:	68 08 50 80 00       	push   $0x805008
  800a57:	e8 a9 12 00 00       	call   801d05 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a61:	b8 04 00 00 00       	mov    $0x4,%eax
  800a66:	e8 cd fe ff ff       	call   800938 <fsipc>
}
  800a6b:	c9                   	leave  
  800a6c:	c3                   	ret    

00800a6d <devfile_read>:
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
  800a72:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a75:	8b 45 08             	mov    0x8(%ebp),%eax
  800a78:	8b 40 0c             	mov    0xc(%eax),%eax
  800a7b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a80:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a86:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8b:	b8 03 00 00 00       	mov    $0x3,%eax
  800a90:	e8 a3 fe ff ff       	call   800938 <fsipc>
  800a95:	89 c3                	mov    %eax,%ebx
  800a97:	85 c0                	test   %eax,%eax
  800a99:	78 1f                	js     800aba <devfile_read+0x4d>
	assert(r <= n);
  800a9b:	39 f0                	cmp    %esi,%eax
  800a9d:	77 24                	ja     800ac3 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a9f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aa4:	7f 33                	jg     800ad9 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aa6:	83 ec 04             	sub    $0x4,%esp
  800aa9:	50                   	push   %eax
  800aaa:	68 00 50 80 00       	push   $0x805000
  800aaf:	ff 75 0c             	push   0xc(%ebp)
  800ab2:	e8 4e 12 00 00       	call   801d05 <memmove>
	return r;
  800ab7:	83 c4 10             	add    $0x10,%esp
}
  800aba:	89 d8                	mov    %ebx,%eax
  800abc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    
	assert(r <= n);
  800ac3:	68 e8 22 80 00       	push   $0x8022e8
  800ac8:	68 ef 22 80 00       	push   $0x8022ef
  800acd:	6a 7c                	push   $0x7c
  800acf:	68 04 23 80 00       	push   $0x802304
  800ad4:	e8 e1 09 00 00       	call   8014ba <_panic>
	assert(r <= PGSIZE);
  800ad9:	68 0f 23 80 00       	push   $0x80230f
  800ade:	68 ef 22 80 00       	push   $0x8022ef
  800ae3:	6a 7d                	push   $0x7d
  800ae5:	68 04 23 80 00       	push   $0x802304
  800aea:	e8 cb 09 00 00       	call   8014ba <_panic>

00800aef <open>:
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
  800af4:	83 ec 1c             	sub    $0x1c,%esp
  800af7:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800afa:	56                   	push   %esi
  800afb:	e8 34 10 00 00       	call   801b34 <strlen>
  800b00:	83 c4 10             	add    $0x10,%esp
  800b03:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b08:	7f 6c                	jg     800b76 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800b0a:	83 ec 0c             	sub    $0xc,%esp
  800b0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b10:	50                   	push   %eax
  800b11:	e8 bd f8 ff ff       	call   8003d3 <fd_alloc>
  800b16:	89 c3                	mov    %eax,%ebx
  800b18:	83 c4 10             	add    $0x10,%esp
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	78 3c                	js     800b5b <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800b1f:	83 ec 08             	sub    $0x8,%esp
  800b22:	56                   	push   %esi
  800b23:	68 00 50 80 00       	push   $0x805000
  800b28:	e8 42 10 00 00       	call   801b6f <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b30:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b35:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b38:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3d:	e8 f6 fd ff ff       	call   800938 <fsipc>
  800b42:	89 c3                	mov    %eax,%ebx
  800b44:	83 c4 10             	add    $0x10,%esp
  800b47:	85 c0                	test   %eax,%eax
  800b49:	78 19                	js     800b64 <open+0x75>
	return fd2num(fd);
  800b4b:	83 ec 0c             	sub    $0xc,%esp
  800b4e:	ff 75 f4             	push   -0xc(%ebp)
  800b51:	e8 56 f8 ff ff       	call   8003ac <fd2num>
  800b56:	89 c3                	mov    %eax,%ebx
  800b58:	83 c4 10             	add    $0x10,%esp
}
  800b5b:	89 d8                	mov    %ebx,%eax
  800b5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    
		fd_close(fd, 0);
  800b64:	83 ec 08             	sub    $0x8,%esp
  800b67:	6a 00                	push   $0x0
  800b69:	ff 75 f4             	push   -0xc(%ebp)
  800b6c:	e8 58 f9 ff ff       	call   8004c9 <fd_close>
		return r;
  800b71:	83 c4 10             	add    $0x10,%esp
  800b74:	eb e5                	jmp    800b5b <open+0x6c>
		return -E_BAD_PATH;
  800b76:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b7b:	eb de                	jmp    800b5b <open+0x6c>

00800b7d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b83:	ba 00 00 00 00       	mov    $0x0,%edx
  800b88:	b8 08 00 00 00       	mov    $0x8,%eax
  800b8d:	e8 a6 fd ff ff       	call   800938 <fsipc>
}
  800b92:	c9                   	leave  
  800b93:	c3                   	ret    

00800b94 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b9a:	68 1b 23 80 00       	push   $0x80231b
  800b9f:	ff 75 0c             	push   0xc(%ebp)
  800ba2:	e8 c8 0f 00 00       	call   801b6f <strcpy>
	return 0;
}
  800ba7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bac:	c9                   	leave  
  800bad:	c3                   	ret    

00800bae <devsock_close>:
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	53                   	push   %ebx
  800bb2:	83 ec 10             	sub    $0x10,%esp
  800bb5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bb8:	53                   	push   %ebx
  800bb9:	e8 e5 13 00 00       	call   801fa3 <pageref>
  800bbe:	89 c2                	mov    %eax,%edx
  800bc0:	83 c4 10             	add    $0x10,%esp
		return 0;
  800bc3:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800bc8:	83 fa 01             	cmp    $0x1,%edx
  800bcb:	74 05                	je     800bd2 <devsock_close+0x24>
}
  800bcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd0:	c9                   	leave  
  800bd1:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	ff 73 0c             	push   0xc(%ebx)
  800bd8:	e8 b7 02 00 00       	call   800e94 <nsipc_close>
  800bdd:	83 c4 10             	add    $0x10,%esp
  800be0:	eb eb                	jmp    800bcd <devsock_close+0x1f>

00800be2 <devsock_write>:
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800be8:	6a 00                	push   $0x0
  800bea:	ff 75 10             	push   0x10(%ebp)
  800bed:	ff 75 0c             	push   0xc(%ebp)
  800bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf3:	ff 70 0c             	push   0xc(%eax)
  800bf6:	e8 79 03 00 00       	call   800f74 <nsipc_send>
}
  800bfb:	c9                   	leave  
  800bfc:	c3                   	ret    

00800bfd <devsock_read>:
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c03:	6a 00                	push   $0x0
  800c05:	ff 75 10             	push   0x10(%ebp)
  800c08:	ff 75 0c             	push   0xc(%ebp)
  800c0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0e:	ff 70 0c             	push   0xc(%eax)
  800c11:	e8 ef 02 00 00       	call   800f05 <nsipc_recv>
}
  800c16:	c9                   	leave  
  800c17:	c3                   	ret    

00800c18 <fd2sockid>:
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c1e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c21:	52                   	push   %edx
  800c22:	50                   	push   %eax
  800c23:	e8 fb f7 ff ff       	call   800423 <fd_lookup>
  800c28:	83 c4 10             	add    $0x10,%esp
  800c2b:	85 c0                	test   %eax,%eax
  800c2d:	78 10                	js     800c3f <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c32:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c38:	39 08                	cmp    %ecx,(%eax)
  800c3a:	75 05                	jne    800c41 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c3c:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c3f:	c9                   	leave  
  800c40:	c3                   	ret    
		return -E_NOT_SUPP;
  800c41:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c46:	eb f7                	jmp    800c3f <fd2sockid+0x27>

00800c48 <alloc_sockfd>:
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 1c             	sub    $0x1c,%esp
  800c50:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c55:	50                   	push   %eax
  800c56:	e8 78 f7 ff ff       	call   8003d3 <fd_alloc>
  800c5b:	89 c3                	mov    %eax,%ebx
  800c5d:	83 c4 10             	add    $0x10,%esp
  800c60:	85 c0                	test   %eax,%eax
  800c62:	78 43                	js     800ca7 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c64:	83 ec 04             	sub    $0x4,%esp
  800c67:	68 07 04 00 00       	push   $0x407
  800c6c:	ff 75 f4             	push   -0xc(%ebp)
  800c6f:	6a 00                	push   $0x0
  800c71:	e8 e4 f4 ff ff       	call   80015a <sys_page_alloc>
  800c76:	89 c3                	mov    %eax,%ebx
  800c78:	83 c4 10             	add    $0x10,%esp
  800c7b:	85 c0                	test   %eax,%eax
  800c7d:	78 28                	js     800ca7 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c82:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c88:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c8d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c94:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c97:	83 ec 0c             	sub    $0xc,%esp
  800c9a:	50                   	push   %eax
  800c9b:	e8 0c f7 ff ff       	call   8003ac <fd2num>
  800ca0:	89 c3                	mov    %eax,%ebx
  800ca2:	83 c4 10             	add    $0x10,%esp
  800ca5:	eb 0c                	jmp    800cb3 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800ca7:	83 ec 0c             	sub    $0xc,%esp
  800caa:	56                   	push   %esi
  800cab:	e8 e4 01 00 00       	call   800e94 <nsipc_close>
		return r;
  800cb0:	83 c4 10             	add    $0x10,%esp
}
  800cb3:	89 d8                	mov    %ebx,%eax
  800cb5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <accept>:
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc5:	e8 4e ff ff ff       	call   800c18 <fd2sockid>
  800cca:	85 c0                	test   %eax,%eax
  800ccc:	78 1b                	js     800ce9 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cce:	83 ec 04             	sub    $0x4,%esp
  800cd1:	ff 75 10             	push   0x10(%ebp)
  800cd4:	ff 75 0c             	push   0xc(%ebp)
  800cd7:	50                   	push   %eax
  800cd8:	e8 0e 01 00 00       	call   800deb <nsipc_accept>
  800cdd:	83 c4 10             	add    $0x10,%esp
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	78 05                	js     800ce9 <accept+0x2d>
	return alloc_sockfd(r);
  800ce4:	e8 5f ff ff ff       	call   800c48 <alloc_sockfd>
}
  800ce9:	c9                   	leave  
  800cea:	c3                   	ret    

00800ceb <bind>:
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf4:	e8 1f ff ff ff       	call   800c18 <fd2sockid>
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	78 12                	js     800d0f <bind+0x24>
	return nsipc_bind(r, name, namelen);
  800cfd:	83 ec 04             	sub    $0x4,%esp
  800d00:	ff 75 10             	push   0x10(%ebp)
  800d03:	ff 75 0c             	push   0xc(%ebp)
  800d06:	50                   	push   %eax
  800d07:	e8 31 01 00 00       	call   800e3d <nsipc_bind>
  800d0c:	83 c4 10             	add    $0x10,%esp
}
  800d0f:	c9                   	leave  
  800d10:	c3                   	ret    

00800d11 <shutdown>:
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d17:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1a:	e8 f9 fe ff ff       	call   800c18 <fd2sockid>
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	78 0f                	js     800d32 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  800d23:	83 ec 08             	sub    $0x8,%esp
  800d26:	ff 75 0c             	push   0xc(%ebp)
  800d29:	50                   	push   %eax
  800d2a:	e8 43 01 00 00       	call   800e72 <nsipc_shutdown>
  800d2f:	83 c4 10             	add    $0x10,%esp
}
  800d32:	c9                   	leave  
  800d33:	c3                   	ret    

00800d34 <connect>:
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3d:	e8 d6 fe ff ff       	call   800c18 <fd2sockid>
  800d42:	85 c0                	test   %eax,%eax
  800d44:	78 12                	js     800d58 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  800d46:	83 ec 04             	sub    $0x4,%esp
  800d49:	ff 75 10             	push   0x10(%ebp)
  800d4c:	ff 75 0c             	push   0xc(%ebp)
  800d4f:	50                   	push   %eax
  800d50:	e8 59 01 00 00       	call   800eae <nsipc_connect>
  800d55:	83 c4 10             	add    $0x10,%esp
}
  800d58:	c9                   	leave  
  800d59:	c3                   	ret    

00800d5a <listen>:
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	e8 b0 fe ff ff       	call   800c18 <fd2sockid>
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	78 0f                	js     800d7b <listen+0x21>
	return nsipc_listen(r, backlog);
  800d6c:	83 ec 08             	sub    $0x8,%esp
  800d6f:	ff 75 0c             	push   0xc(%ebp)
  800d72:	50                   	push   %eax
  800d73:	e8 6b 01 00 00       	call   800ee3 <nsipc_listen>
  800d78:	83 c4 10             	add    $0x10,%esp
}
  800d7b:	c9                   	leave  
  800d7c:	c3                   	ret    

00800d7d <socket>:

int
socket(int domain, int type, int protocol)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d83:	ff 75 10             	push   0x10(%ebp)
  800d86:	ff 75 0c             	push   0xc(%ebp)
  800d89:	ff 75 08             	push   0x8(%ebp)
  800d8c:	e8 41 02 00 00       	call   800fd2 <nsipc_socket>
  800d91:	83 c4 10             	add    $0x10,%esp
  800d94:	85 c0                	test   %eax,%eax
  800d96:	78 05                	js     800d9d <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800d98:	e8 ab fe ff ff       	call   800c48 <alloc_sockfd>
}
  800d9d:	c9                   	leave  
  800d9e:	c3                   	ret    

00800d9f <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	53                   	push   %ebx
  800da3:	83 ec 04             	sub    $0x4,%esp
  800da6:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800da8:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  800daf:	74 26                	je     800dd7 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800db1:	6a 07                	push   $0x7
  800db3:	68 00 70 80 00       	push   $0x807000
  800db8:	53                   	push   %ebx
  800db9:	ff 35 00 80 80 00    	push   0x808000
  800dbf:	e8 52 11 00 00       	call   801f16 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dc4:	83 c4 0c             	add    $0xc,%esp
  800dc7:	6a 00                	push   $0x0
  800dc9:	6a 00                	push   $0x0
  800dcb:	6a 00                	push   $0x0
  800dcd:	e8 dd 10 00 00       	call   801eaf <ipc_recv>
}
  800dd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dd5:	c9                   	leave  
  800dd6:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dd7:	83 ec 0c             	sub    $0xc,%esp
  800dda:	6a 02                	push   $0x2
  800ddc:	e8 89 11 00 00       	call   801f6a <ipc_find_env>
  800de1:	a3 00 80 80 00       	mov    %eax,0x808000
  800de6:	83 c4 10             	add    $0x10,%esp
  800de9:	eb c6                	jmp    800db1 <nsipc+0x12>

00800deb <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	56                   	push   %esi
  800def:	53                   	push   %ebx
  800df0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800df3:	8b 45 08             	mov    0x8(%ebp),%eax
  800df6:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800dfb:	8b 06                	mov    (%esi),%eax
  800dfd:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e02:	b8 01 00 00 00       	mov    $0x1,%eax
  800e07:	e8 93 ff ff ff       	call   800d9f <nsipc>
  800e0c:	89 c3                	mov    %eax,%ebx
  800e0e:	85 c0                	test   %eax,%eax
  800e10:	79 09                	jns    800e1b <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800e12:	89 d8                	mov    %ebx,%eax
  800e14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e17:	5b                   	pop    %ebx
  800e18:	5e                   	pop    %esi
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e1b:	83 ec 04             	sub    $0x4,%esp
  800e1e:	ff 35 10 70 80 00    	push   0x807010
  800e24:	68 00 70 80 00       	push   $0x807000
  800e29:	ff 75 0c             	push   0xc(%ebp)
  800e2c:	e8 d4 0e 00 00       	call   801d05 <memmove>
		*addrlen = ret->ret_addrlen;
  800e31:	a1 10 70 80 00       	mov    0x807010,%eax
  800e36:	89 06                	mov    %eax,(%esi)
  800e38:	83 c4 10             	add    $0x10,%esp
	return r;
  800e3b:	eb d5                	jmp    800e12 <nsipc_accept+0x27>

00800e3d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	53                   	push   %ebx
  800e41:	83 ec 08             	sub    $0x8,%esp
  800e44:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e47:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4a:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e4f:	53                   	push   %ebx
  800e50:	ff 75 0c             	push   0xc(%ebp)
  800e53:	68 04 70 80 00       	push   $0x807004
  800e58:	e8 a8 0e 00 00       	call   801d05 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e5d:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  800e63:	b8 02 00 00 00       	mov    $0x2,%eax
  800e68:	e8 32 ff ff ff       	call   800d9f <nsipc>
}
  800e6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e70:	c9                   	leave  
  800e71:	c3                   	ret    

00800e72 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e78:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  800e80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e83:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  800e88:	b8 03 00 00 00       	mov    $0x3,%eax
  800e8d:	e8 0d ff ff ff       	call   800d9f <nsipc>
}
  800e92:	c9                   	leave  
  800e93:	c3                   	ret    

00800e94 <nsipc_close>:

int
nsipc_close(int s)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9d:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  800ea2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ea7:	e8 f3 fe ff ff       	call   800d9f <nsipc>
}
  800eac:	c9                   	leave  
  800ead:	c3                   	ret    

00800eae <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	53                   	push   %ebx
  800eb2:	83 ec 08             	sub    $0x8,%esp
  800eb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800eb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebb:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ec0:	53                   	push   %ebx
  800ec1:	ff 75 0c             	push   0xc(%ebp)
  800ec4:	68 04 70 80 00       	push   $0x807004
  800ec9:	e8 37 0e 00 00       	call   801d05 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ece:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  800ed4:	b8 05 00 00 00       	mov    $0x5,%eax
  800ed9:	e8 c1 fe ff ff       	call   800d9f <nsipc>
}
  800ede:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee1:	c9                   	leave  
  800ee2:	c3                   	ret    

00800ee3 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ee9:	8b 45 08             	mov    0x8(%ebp),%eax
  800eec:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  800ef1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef4:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  800ef9:	b8 06 00 00 00       	mov    $0x6,%eax
  800efe:	e8 9c fe ff ff       	call   800d9f <nsipc>
}
  800f03:	c9                   	leave  
  800f04:	c3                   	ret    

00800f05 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	56                   	push   %esi
  800f09:	53                   	push   %ebx
  800f0a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f10:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  800f15:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  800f1b:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1e:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f23:	b8 07 00 00 00       	mov    $0x7,%eax
  800f28:	e8 72 fe ff ff       	call   800d9f <nsipc>
  800f2d:	89 c3                	mov    %eax,%ebx
  800f2f:	85 c0                	test   %eax,%eax
  800f31:	78 22                	js     800f55 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  800f33:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f38:	39 c6                	cmp    %eax,%esi
  800f3a:	0f 4e c6             	cmovle %esi,%eax
  800f3d:	39 c3                	cmp    %eax,%ebx
  800f3f:	7f 1d                	jg     800f5e <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f41:	83 ec 04             	sub    $0x4,%esp
  800f44:	53                   	push   %ebx
  800f45:	68 00 70 80 00       	push   $0x807000
  800f4a:	ff 75 0c             	push   0xc(%ebp)
  800f4d:	e8 b3 0d 00 00       	call   801d05 <memmove>
  800f52:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f55:	89 d8                	mov    %ebx,%eax
  800f57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f5a:	5b                   	pop    %ebx
  800f5b:	5e                   	pop    %esi
  800f5c:	5d                   	pop    %ebp
  800f5d:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f5e:	68 27 23 80 00       	push   $0x802327
  800f63:	68 ef 22 80 00       	push   $0x8022ef
  800f68:	6a 62                	push   $0x62
  800f6a:	68 3c 23 80 00       	push   $0x80233c
  800f6f:	e8 46 05 00 00       	call   8014ba <_panic>

00800f74 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	53                   	push   %ebx
  800f78:	83 ec 04             	sub    $0x4,%esp
  800f7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f81:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  800f86:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f8c:	7f 2e                	jg     800fbc <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f8e:	83 ec 04             	sub    $0x4,%esp
  800f91:	53                   	push   %ebx
  800f92:	ff 75 0c             	push   0xc(%ebp)
  800f95:	68 0c 70 80 00       	push   $0x80700c
  800f9a:	e8 66 0d 00 00       	call   801d05 <memmove>
	nsipcbuf.send.req_size = size;
  800f9f:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  800fa5:	8b 45 14             	mov    0x14(%ebp),%eax
  800fa8:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  800fad:	b8 08 00 00 00       	mov    $0x8,%eax
  800fb2:	e8 e8 fd ff ff       	call   800d9f <nsipc>
}
  800fb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fba:	c9                   	leave  
  800fbb:	c3                   	ret    
	assert(size < 1600);
  800fbc:	68 48 23 80 00       	push   $0x802348
  800fc1:	68 ef 22 80 00       	push   $0x8022ef
  800fc6:	6a 6d                	push   $0x6d
  800fc8:	68 3c 23 80 00       	push   $0x80233c
  800fcd:	e8 e8 04 00 00       	call   8014ba <_panic>

00800fd2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  800fe0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe3:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  800fe8:	8b 45 10             	mov    0x10(%ebp),%eax
  800feb:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  800ff0:	b8 09 00 00 00       	mov    $0x9,%eax
  800ff5:	e8 a5 fd ff ff       	call   800d9f <nsipc>
}
  800ffa:	c9                   	leave  
  800ffb:	c3                   	ret    

00800ffc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	56                   	push   %esi
  801000:	53                   	push   %ebx
  801001:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801004:	83 ec 0c             	sub    $0xc,%esp
  801007:	ff 75 08             	push   0x8(%ebp)
  80100a:	e8 ad f3 ff ff       	call   8003bc <fd2data>
  80100f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801011:	83 c4 08             	add    $0x8,%esp
  801014:	68 54 23 80 00       	push   $0x802354
  801019:	53                   	push   %ebx
  80101a:	e8 50 0b 00 00       	call   801b6f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80101f:	8b 46 04             	mov    0x4(%esi),%eax
  801022:	2b 06                	sub    (%esi),%eax
  801024:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80102a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801031:	00 00 00 
	stat->st_dev = &devpipe;
  801034:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80103b:	30 80 00 
	return 0;
}
  80103e:	b8 00 00 00 00       	mov    $0x0,%eax
  801043:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801046:	5b                   	pop    %ebx
  801047:	5e                   	pop    %esi
  801048:	5d                   	pop    %ebp
  801049:	c3                   	ret    

0080104a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	53                   	push   %ebx
  80104e:	83 ec 0c             	sub    $0xc,%esp
  801051:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801054:	53                   	push   %ebx
  801055:	6a 00                	push   $0x0
  801057:	e8 83 f1 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80105c:	89 1c 24             	mov    %ebx,(%esp)
  80105f:	e8 58 f3 ff ff       	call   8003bc <fd2data>
  801064:	83 c4 08             	add    $0x8,%esp
  801067:	50                   	push   %eax
  801068:	6a 00                	push   $0x0
  80106a:	e8 70 f1 ff ff       	call   8001df <sys_page_unmap>
}
  80106f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801072:	c9                   	leave  
  801073:	c3                   	ret    

00801074 <_pipeisclosed>:
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	57                   	push   %edi
  801078:	56                   	push   %esi
  801079:	53                   	push   %ebx
  80107a:	83 ec 1c             	sub    $0x1c,%esp
  80107d:	89 c7                	mov    %eax,%edi
  80107f:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801081:	a1 00 40 80 00       	mov    0x804000,%eax
  801086:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801089:	83 ec 0c             	sub    $0xc,%esp
  80108c:	57                   	push   %edi
  80108d:	e8 11 0f 00 00       	call   801fa3 <pageref>
  801092:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801095:	89 34 24             	mov    %esi,(%esp)
  801098:	e8 06 0f 00 00       	call   801fa3 <pageref>
		nn = thisenv->env_runs;
  80109d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8010a3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010a6:	83 c4 10             	add    $0x10,%esp
  8010a9:	39 cb                	cmp    %ecx,%ebx
  8010ab:	74 1b                	je     8010c8 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010ad:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010b0:	75 cf                	jne    801081 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010b2:	8b 42 58             	mov    0x58(%edx),%eax
  8010b5:	6a 01                	push   $0x1
  8010b7:	50                   	push   %eax
  8010b8:	53                   	push   %ebx
  8010b9:	68 5b 23 80 00       	push   $0x80235b
  8010be:	e8 d2 04 00 00       	call   801595 <cprintf>
  8010c3:	83 c4 10             	add    $0x10,%esp
  8010c6:	eb b9                	jmp    801081 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010c8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010cb:	0f 94 c0             	sete   %al
  8010ce:	0f b6 c0             	movzbl %al,%eax
}
  8010d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d4:	5b                   	pop    %ebx
  8010d5:	5e                   	pop    %esi
  8010d6:	5f                   	pop    %edi
  8010d7:	5d                   	pop    %ebp
  8010d8:	c3                   	ret    

008010d9 <devpipe_write>:
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	57                   	push   %edi
  8010dd:	56                   	push   %esi
  8010de:	53                   	push   %ebx
  8010df:	83 ec 28             	sub    $0x28,%esp
  8010e2:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8010e5:	56                   	push   %esi
  8010e6:	e8 d1 f2 ff ff       	call   8003bc <fd2data>
  8010eb:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8010ed:	83 c4 10             	add    $0x10,%esp
  8010f0:	bf 00 00 00 00       	mov    $0x0,%edi
  8010f5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8010f8:	75 09                	jne    801103 <devpipe_write+0x2a>
	return i;
  8010fa:	89 f8                	mov    %edi,%eax
  8010fc:	eb 23                	jmp    801121 <devpipe_write+0x48>
			sys_yield();
  8010fe:	e8 38 f0 ff ff       	call   80013b <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801103:	8b 43 04             	mov    0x4(%ebx),%eax
  801106:	8b 0b                	mov    (%ebx),%ecx
  801108:	8d 51 20             	lea    0x20(%ecx),%edx
  80110b:	39 d0                	cmp    %edx,%eax
  80110d:	72 1a                	jb     801129 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80110f:	89 da                	mov    %ebx,%edx
  801111:	89 f0                	mov    %esi,%eax
  801113:	e8 5c ff ff ff       	call   801074 <_pipeisclosed>
  801118:	85 c0                	test   %eax,%eax
  80111a:	74 e2                	je     8010fe <devpipe_write+0x25>
				return 0;
  80111c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801121:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801124:	5b                   	pop    %ebx
  801125:	5e                   	pop    %esi
  801126:	5f                   	pop    %edi
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801129:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801130:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801133:	89 c2                	mov    %eax,%edx
  801135:	c1 fa 1f             	sar    $0x1f,%edx
  801138:	89 d1                	mov    %edx,%ecx
  80113a:	c1 e9 1b             	shr    $0x1b,%ecx
  80113d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801140:	83 e2 1f             	and    $0x1f,%edx
  801143:	29 ca                	sub    %ecx,%edx
  801145:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801149:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80114d:	83 c0 01             	add    $0x1,%eax
  801150:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801153:	83 c7 01             	add    $0x1,%edi
  801156:	eb 9d                	jmp    8010f5 <devpipe_write+0x1c>

00801158 <devpipe_read>:
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	57                   	push   %edi
  80115c:	56                   	push   %esi
  80115d:	53                   	push   %ebx
  80115e:	83 ec 18             	sub    $0x18,%esp
  801161:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801164:	57                   	push   %edi
  801165:	e8 52 f2 ff ff       	call   8003bc <fd2data>
  80116a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80116c:	83 c4 10             	add    $0x10,%esp
  80116f:	be 00 00 00 00       	mov    $0x0,%esi
  801174:	3b 75 10             	cmp    0x10(%ebp),%esi
  801177:	75 13                	jne    80118c <devpipe_read+0x34>
	return i;
  801179:	89 f0                	mov    %esi,%eax
  80117b:	eb 02                	jmp    80117f <devpipe_read+0x27>
				return i;
  80117d:	89 f0                	mov    %esi,%eax
}
  80117f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801182:	5b                   	pop    %ebx
  801183:	5e                   	pop    %esi
  801184:	5f                   	pop    %edi
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    
			sys_yield();
  801187:	e8 af ef ff ff       	call   80013b <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80118c:	8b 03                	mov    (%ebx),%eax
  80118e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801191:	75 18                	jne    8011ab <devpipe_read+0x53>
			if (i > 0)
  801193:	85 f6                	test   %esi,%esi
  801195:	75 e6                	jne    80117d <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801197:	89 da                	mov    %ebx,%edx
  801199:	89 f8                	mov    %edi,%eax
  80119b:	e8 d4 fe ff ff       	call   801074 <_pipeisclosed>
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	74 e3                	je     801187 <devpipe_read+0x2f>
				return 0;
  8011a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a9:	eb d4                	jmp    80117f <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011ab:	99                   	cltd   
  8011ac:	c1 ea 1b             	shr    $0x1b,%edx
  8011af:	01 d0                	add    %edx,%eax
  8011b1:	83 e0 1f             	and    $0x1f,%eax
  8011b4:	29 d0                	sub    %edx,%eax
  8011b6:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011be:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011c1:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011c4:	83 c6 01             	add    $0x1,%esi
  8011c7:	eb ab                	jmp    801174 <devpipe_read+0x1c>

008011c9 <pipe>:
{
  8011c9:	55                   	push   %ebp
  8011ca:	89 e5                	mov    %esp,%ebp
  8011cc:	56                   	push   %esi
  8011cd:	53                   	push   %ebx
  8011ce:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d4:	50                   	push   %eax
  8011d5:	e8 f9 f1 ff ff       	call   8003d3 <fd_alloc>
  8011da:	89 c3                	mov    %eax,%ebx
  8011dc:	83 c4 10             	add    $0x10,%esp
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	0f 88 23 01 00 00    	js     80130a <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011e7:	83 ec 04             	sub    $0x4,%esp
  8011ea:	68 07 04 00 00       	push   $0x407
  8011ef:	ff 75 f4             	push   -0xc(%ebp)
  8011f2:	6a 00                	push   $0x0
  8011f4:	e8 61 ef ff ff       	call   80015a <sys_page_alloc>
  8011f9:	89 c3                	mov    %eax,%ebx
  8011fb:	83 c4 10             	add    $0x10,%esp
  8011fe:	85 c0                	test   %eax,%eax
  801200:	0f 88 04 01 00 00    	js     80130a <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801206:	83 ec 0c             	sub    $0xc,%esp
  801209:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120c:	50                   	push   %eax
  80120d:	e8 c1 f1 ff ff       	call   8003d3 <fd_alloc>
  801212:	89 c3                	mov    %eax,%ebx
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	85 c0                	test   %eax,%eax
  801219:	0f 88 db 00 00 00    	js     8012fa <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80121f:	83 ec 04             	sub    $0x4,%esp
  801222:	68 07 04 00 00       	push   $0x407
  801227:	ff 75 f0             	push   -0x10(%ebp)
  80122a:	6a 00                	push   $0x0
  80122c:	e8 29 ef ff ff       	call   80015a <sys_page_alloc>
  801231:	89 c3                	mov    %eax,%ebx
  801233:	83 c4 10             	add    $0x10,%esp
  801236:	85 c0                	test   %eax,%eax
  801238:	0f 88 bc 00 00 00    	js     8012fa <pipe+0x131>
	va = fd2data(fd0);
  80123e:	83 ec 0c             	sub    $0xc,%esp
  801241:	ff 75 f4             	push   -0xc(%ebp)
  801244:	e8 73 f1 ff ff       	call   8003bc <fd2data>
  801249:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80124b:	83 c4 0c             	add    $0xc,%esp
  80124e:	68 07 04 00 00       	push   $0x407
  801253:	50                   	push   %eax
  801254:	6a 00                	push   $0x0
  801256:	e8 ff ee ff ff       	call   80015a <sys_page_alloc>
  80125b:	89 c3                	mov    %eax,%ebx
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	85 c0                	test   %eax,%eax
  801262:	0f 88 82 00 00 00    	js     8012ea <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801268:	83 ec 0c             	sub    $0xc,%esp
  80126b:	ff 75 f0             	push   -0x10(%ebp)
  80126e:	e8 49 f1 ff ff       	call   8003bc <fd2data>
  801273:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80127a:	50                   	push   %eax
  80127b:	6a 00                	push   $0x0
  80127d:	56                   	push   %esi
  80127e:	6a 00                	push   $0x0
  801280:	e8 18 ef ff ff       	call   80019d <sys_page_map>
  801285:	89 c3                	mov    %eax,%ebx
  801287:	83 c4 20             	add    $0x20,%esp
  80128a:	85 c0                	test   %eax,%eax
  80128c:	78 4e                	js     8012dc <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80128e:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801293:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801296:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801298:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80129b:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012a5:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012aa:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012b1:	83 ec 0c             	sub    $0xc,%esp
  8012b4:	ff 75 f4             	push   -0xc(%ebp)
  8012b7:	e8 f0 f0 ff ff       	call   8003ac <fd2num>
  8012bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012bf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012c1:	83 c4 04             	add    $0x4,%esp
  8012c4:	ff 75 f0             	push   -0x10(%ebp)
  8012c7:	e8 e0 f0 ff ff       	call   8003ac <fd2num>
  8012cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012cf:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012da:	eb 2e                	jmp    80130a <pipe+0x141>
	sys_page_unmap(0, va);
  8012dc:	83 ec 08             	sub    $0x8,%esp
  8012df:	56                   	push   %esi
  8012e0:	6a 00                	push   $0x0
  8012e2:	e8 f8 ee ff ff       	call   8001df <sys_page_unmap>
  8012e7:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8012ea:	83 ec 08             	sub    $0x8,%esp
  8012ed:	ff 75 f0             	push   -0x10(%ebp)
  8012f0:	6a 00                	push   $0x0
  8012f2:	e8 e8 ee ff ff       	call   8001df <sys_page_unmap>
  8012f7:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8012fa:	83 ec 08             	sub    $0x8,%esp
  8012fd:	ff 75 f4             	push   -0xc(%ebp)
  801300:	6a 00                	push   $0x0
  801302:	e8 d8 ee ff ff       	call   8001df <sys_page_unmap>
  801307:	83 c4 10             	add    $0x10,%esp
}
  80130a:	89 d8                	mov    %ebx,%eax
  80130c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80130f:	5b                   	pop    %ebx
  801310:	5e                   	pop    %esi
  801311:	5d                   	pop    %ebp
  801312:	c3                   	ret    

00801313 <pipeisclosed>:
{
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801319:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131c:	50                   	push   %eax
  80131d:	ff 75 08             	push   0x8(%ebp)
  801320:	e8 fe f0 ff ff       	call   800423 <fd_lookup>
  801325:	83 c4 10             	add    $0x10,%esp
  801328:	85 c0                	test   %eax,%eax
  80132a:	78 18                	js     801344 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80132c:	83 ec 0c             	sub    $0xc,%esp
  80132f:	ff 75 f4             	push   -0xc(%ebp)
  801332:	e8 85 f0 ff ff       	call   8003bc <fd2data>
  801337:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801339:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133c:	e8 33 fd ff ff       	call   801074 <_pipeisclosed>
  801341:	83 c4 10             	add    $0x10,%esp
}
  801344:	c9                   	leave  
  801345:	c3                   	ret    

00801346 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801346:	b8 00 00 00 00       	mov    $0x0,%eax
  80134b:	c3                   	ret    

0080134c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801352:	68 73 23 80 00       	push   $0x802373
  801357:	ff 75 0c             	push   0xc(%ebp)
  80135a:	e8 10 08 00 00       	call   801b6f <strcpy>
	return 0;
}
  80135f:	b8 00 00 00 00       	mov    $0x0,%eax
  801364:	c9                   	leave  
  801365:	c3                   	ret    

00801366 <devcons_write>:
{
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
  801369:	57                   	push   %edi
  80136a:	56                   	push   %esi
  80136b:	53                   	push   %ebx
  80136c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801372:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801377:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80137d:	eb 2e                	jmp    8013ad <devcons_write+0x47>
		m = n - tot;
  80137f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801382:	29 f3                	sub    %esi,%ebx
  801384:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801389:	39 c3                	cmp    %eax,%ebx
  80138b:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80138e:	83 ec 04             	sub    $0x4,%esp
  801391:	53                   	push   %ebx
  801392:	89 f0                	mov    %esi,%eax
  801394:	03 45 0c             	add    0xc(%ebp),%eax
  801397:	50                   	push   %eax
  801398:	57                   	push   %edi
  801399:	e8 67 09 00 00       	call   801d05 <memmove>
		sys_cputs(buf, m);
  80139e:	83 c4 08             	add    $0x8,%esp
  8013a1:	53                   	push   %ebx
  8013a2:	57                   	push   %edi
  8013a3:	e8 f6 ec ff ff       	call   80009e <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013a8:	01 de                	add    %ebx,%esi
  8013aa:	83 c4 10             	add    $0x10,%esp
  8013ad:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013b0:	72 cd                	jb     80137f <devcons_write+0x19>
}
  8013b2:	89 f0                	mov    %esi,%eax
  8013b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b7:	5b                   	pop    %ebx
  8013b8:	5e                   	pop    %esi
  8013b9:	5f                   	pop    %edi
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    

008013bc <devcons_read>:
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	83 ec 08             	sub    $0x8,%esp
  8013c2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013c7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013cb:	75 07                	jne    8013d4 <devcons_read+0x18>
  8013cd:	eb 1f                	jmp    8013ee <devcons_read+0x32>
		sys_yield();
  8013cf:	e8 67 ed ff ff       	call   80013b <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8013d4:	e8 e3 ec ff ff       	call   8000bc <sys_cgetc>
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	74 f2                	je     8013cf <devcons_read+0x13>
	if (c < 0)
  8013dd:	78 0f                	js     8013ee <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8013df:	83 f8 04             	cmp    $0x4,%eax
  8013e2:	74 0c                	je     8013f0 <devcons_read+0x34>
	*(char*)vbuf = c;
  8013e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013e7:	88 02                	mov    %al,(%edx)
	return 1;
  8013e9:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8013ee:	c9                   	leave  
  8013ef:	c3                   	ret    
		return 0;
  8013f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f5:	eb f7                	jmp    8013ee <devcons_read+0x32>

008013f7 <cputchar>:
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801400:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801403:	6a 01                	push   $0x1
  801405:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801408:	50                   	push   %eax
  801409:	e8 90 ec ff ff       	call   80009e <sys_cputs>
}
  80140e:	83 c4 10             	add    $0x10,%esp
  801411:	c9                   	leave  
  801412:	c3                   	ret    

00801413 <getchar>:
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801419:	6a 01                	push   $0x1
  80141b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80141e:	50                   	push   %eax
  80141f:	6a 00                	push   $0x0
  801421:	e8 66 f2 ff ff       	call   80068c <read>
	if (r < 0)
  801426:	83 c4 10             	add    $0x10,%esp
  801429:	85 c0                	test   %eax,%eax
  80142b:	78 06                	js     801433 <getchar+0x20>
	if (r < 1)
  80142d:	74 06                	je     801435 <getchar+0x22>
	return c;
  80142f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801433:	c9                   	leave  
  801434:	c3                   	ret    
		return -E_EOF;
  801435:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80143a:	eb f7                	jmp    801433 <getchar+0x20>

0080143c <iscons>:
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801442:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801445:	50                   	push   %eax
  801446:	ff 75 08             	push   0x8(%ebp)
  801449:	e8 d5 ef ff ff       	call   800423 <fd_lookup>
  80144e:	83 c4 10             	add    $0x10,%esp
  801451:	85 c0                	test   %eax,%eax
  801453:	78 11                	js     801466 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801455:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801458:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80145e:	39 10                	cmp    %edx,(%eax)
  801460:	0f 94 c0             	sete   %al
  801463:	0f b6 c0             	movzbl %al,%eax
}
  801466:	c9                   	leave  
  801467:	c3                   	ret    

00801468 <opencons>:
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80146e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801471:	50                   	push   %eax
  801472:	e8 5c ef ff ff       	call   8003d3 <fd_alloc>
  801477:	83 c4 10             	add    $0x10,%esp
  80147a:	85 c0                	test   %eax,%eax
  80147c:	78 3a                	js     8014b8 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80147e:	83 ec 04             	sub    $0x4,%esp
  801481:	68 07 04 00 00       	push   $0x407
  801486:	ff 75 f4             	push   -0xc(%ebp)
  801489:	6a 00                	push   $0x0
  80148b:	e8 ca ec ff ff       	call   80015a <sys_page_alloc>
  801490:	83 c4 10             	add    $0x10,%esp
  801493:	85 c0                	test   %eax,%eax
  801495:	78 21                	js     8014b8 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801497:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014a0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014ac:	83 ec 0c             	sub    $0xc,%esp
  8014af:	50                   	push   %eax
  8014b0:	e8 f7 ee ff ff       	call   8003ac <fd2num>
  8014b5:	83 c4 10             	add    $0x10,%esp
}
  8014b8:	c9                   	leave  
  8014b9:	c3                   	ret    

008014ba <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	56                   	push   %esi
  8014be:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014bf:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014c2:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014c8:	e8 4f ec ff ff       	call   80011c <sys_getenvid>
  8014cd:	83 ec 0c             	sub    $0xc,%esp
  8014d0:	ff 75 0c             	push   0xc(%ebp)
  8014d3:	ff 75 08             	push   0x8(%ebp)
  8014d6:	56                   	push   %esi
  8014d7:	50                   	push   %eax
  8014d8:	68 80 23 80 00       	push   $0x802380
  8014dd:	e8 b3 00 00 00       	call   801595 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014e2:	83 c4 18             	add    $0x18,%esp
  8014e5:	53                   	push   %ebx
  8014e6:	ff 75 10             	push   0x10(%ebp)
  8014e9:	e8 56 00 00 00       	call   801544 <vcprintf>
	cprintf("\n");
  8014ee:	c7 04 24 6c 23 80 00 	movl   $0x80236c,(%esp)
  8014f5:	e8 9b 00 00 00       	call   801595 <cprintf>
  8014fa:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014fd:	cc                   	int3   
  8014fe:	eb fd                	jmp    8014fd <_panic+0x43>

00801500 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	53                   	push   %ebx
  801504:	83 ec 04             	sub    $0x4,%esp
  801507:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80150a:	8b 13                	mov    (%ebx),%edx
  80150c:	8d 42 01             	lea    0x1(%edx),%eax
  80150f:	89 03                	mov    %eax,(%ebx)
  801511:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801514:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801518:	3d ff 00 00 00       	cmp    $0xff,%eax
  80151d:	74 09                	je     801528 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80151f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801523:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801526:	c9                   	leave  
  801527:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801528:	83 ec 08             	sub    $0x8,%esp
  80152b:	68 ff 00 00 00       	push   $0xff
  801530:	8d 43 08             	lea    0x8(%ebx),%eax
  801533:	50                   	push   %eax
  801534:	e8 65 eb ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  801539:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	eb db                	jmp    80151f <putch+0x1f>

00801544 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80154d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801554:	00 00 00 
	b.cnt = 0;
  801557:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80155e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801561:	ff 75 0c             	push   0xc(%ebp)
  801564:	ff 75 08             	push   0x8(%ebp)
  801567:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80156d:	50                   	push   %eax
  80156e:	68 00 15 80 00       	push   $0x801500
  801573:	e8 14 01 00 00       	call   80168c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801578:	83 c4 08             	add    $0x8,%esp
  80157b:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  801581:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801587:	50                   	push   %eax
  801588:	e8 11 eb ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  80158d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801593:	c9                   	leave  
  801594:	c3                   	ret    

00801595 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801595:	55                   	push   %ebp
  801596:	89 e5                	mov    %esp,%ebp
  801598:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80159b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80159e:	50                   	push   %eax
  80159f:	ff 75 08             	push   0x8(%ebp)
  8015a2:	e8 9d ff ff ff       	call   801544 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015a7:	c9                   	leave  
  8015a8:	c3                   	ret    

008015a9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	57                   	push   %edi
  8015ad:	56                   	push   %esi
  8015ae:	53                   	push   %ebx
  8015af:	83 ec 1c             	sub    $0x1c,%esp
  8015b2:	89 c7                	mov    %eax,%edi
  8015b4:	89 d6                	mov    %edx,%esi
  8015b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015bc:	89 d1                	mov    %edx,%ecx
  8015be:	89 c2                	mov    %eax,%edx
  8015c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015c3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8015c9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015cf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8015d6:	39 c2                	cmp    %eax,%edx
  8015d8:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8015db:	72 3e                	jb     80161b <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015dd:	83 ec 0c             	sub    $0xc,%esp
  8015e0:	ff 75 18             	push   0x18(%ebp)
  8015e3:	83 eb 01             	sub    $0x1,%ebx
  8015e6:	53                   	push   %ebx
  8015e7:	50                   	push   %eax
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	ff 75 e4             	push   -0x1c(%ebp)
  8015ee:	ff 75 e0             	push   -0x20(%ebp)
  8015f1:	ff 75 dc             	push   -0x24(%ebp)
  8015f4:	ff 75 d8             	push   -0x28(%ebp)
  8015f7:	e8 e4 09 00 00       	call   801fe0 <__udivdi3>
  8015fc:	83 c4 18             	add    $0x18,%esp
  8015ff:	52                   	push   %edx
  801600:	50                   	push   %eax
  801601:	89 f2                	mov    %esi,%edx
  801603:	89 f8                	mov    %edi,%eax
  801605:	e8 9f ff ff ff       	call   8015a9 <printnum>
  80160a:	83 c4 20             	add    $0x20,%esp
  80160d:	eb 13                	jmp    801622 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80160f:	83 ec 08             	sub    $0x8,%esp
  801612:	56                   	push   %esi
  801613:	ff 75 18             	push   0x18(%ebp)
  801616:	ff d7                	call   *%edi
  801618:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80161b:	83 eb 01             	sub    $0x1,%ebx
  80161e:	85 db                	test   %ebx,%ebx
  801620:	7f ed                	jg     80160f <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801622:	83 ec 08             	sub    $0x8,%esp
  801625:	56                   	push   %esi
  801626:	83 ec 04             	sub    $0x4,%esp
  801629:	ff 75 e4             	push   -0x1c(%ebp)
  80162c:	ff 75 e0             	push   -0x20(%ebp)
  80162f:	ff 75 dc             	push   -0x24(%ebp)
  801632:	ff 75 d8             	push   -0x28(%ebp)
  801635:	e8 c6 0a 00 00       	call   802100 <__umoddi3>
  80163a:	83 c4 14             	add    $0x14,%esp
  80163d:	0f be 80 a3 23 80 00 	movsbl 0x8023a3(%eax),%eax
  801644:	50                   	push   %eax
  801645:	ff d7                	call   *%edi
}
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80164d:	5b                   	pop    %ebx
  80164e:	5e                   	pop    %esi
  80164f:	5f                   	pop    %edi
  801650:	5d                   	pop    %ebp
  801651:	c3                   	ret    

00801652 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801652:	55                   	push   %ebp
  801653:	89 e5                	mov    %esp,%ebp
  801655:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801658:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80165c:	8b 10                	mov    (%eax),%edx
  80165e:	3b 50 04             	cmp    0x4(%eax),%edx
  801661:	73 0a                	jae    80166d <sprintputch+0x1b>
		*b->buf++ = ch;
  801663:	8d 4a 01             	lea    0x1(%edx),%ecx
  801666:	89 08                	mov    %ecx,(%eax)
  801668:	8b 45 08             	mov    0x8(%ebp),%eax
  80166b:	88 02                	mov    %al,(%edx)
}
  80166d:	5d                   	pop    %ebp
  80166e:	c3                   	ret    

0080166f <printfmt>:
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801675:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801678:	50                   	push   %eax
  801679:	ff 75 10             	push   0x10(%ebp)
  80167c:	ff 75 0c             	push   0xc(%ebp)
  80167f:	ff 75 08             	push   0x8(%ebp)
  801682:	e8 05 00 00 00       	call   80168c <vprintfmt>
}
  801687:	83 c4 10             	add    $0x10,%esp
  80168a:	c9                   	leave  
  80168b:	c3                   	ret    

0080168c <vprintfmt>:
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	57                   	push   %edi
  801690:	56                   	push   %esi
  801691:	53                   	push   %ebx
  801692:	83 ec 3c             	sub    $0x3c,%esp
  801695:	8b 75 08             	mov    0x8(%ebp),%esi
  801698:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80169b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80169e:	eb 0a                	jmp    8016aa <vprintfmt+0x1e>
			putch(ch, putdat);
  8016a0:	83 ec 08             	sub    $0x8,%esp
  8016a3:	53                   	push   %ebx
  8016a4:	50                   	push   %eax
  8016a5:	ff d6                	call   *%esi
  8016a7:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016aa:	83 c7 01             	add    $0x1,%edi
  8016ad:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016b1:	83 f8 25             	cmp    $0x25,%eax
  8016b4:	74 0c                	je     8016c2 <vprintfmt+0x36>
			if (ch == '\0')
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	75 e6                	jne    8016a0 <vprintfmt+0x14>
}
  8016ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016bd:	5b                   	pop    %ebx
  8016be:	5e                   	pop    %esi
  8016bf:	5f                   	pop    %edi
  8016c0:	5d                   	pop    %ebp
  8016c1:	c3                   	ret    
		padc = ' ';
  8016c2:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8016c6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8016cd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8016d4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8016db:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8016e0:	8d 47 01             	lea    0x1(%edi),%eax
  8016e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016e6:	0f b6 17             	movzbl (%edi),%edx
  8016e9:	8d 42 dd             	lea    -0x23(%edx),%eax
  8016ec:	3c 55                	cmp    $0x55,%al
  8016ee:	0f 87 bb 03 00 00    	ja     801aaf <vprintfmt+0x423>
  8016f4:	0f b6 c0             	movzbl %al,%eax
  8016f7:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  8016fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801701:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801705:	eb d9                	jmp    8016e0 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801707:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80170a:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80170e:	eb d0                	jmp    8016e0 <vprintfmt+0x54>
  801710:	0f b6 d2             	movzbl %dl,%edx
  801713:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801716:	b8 00 00 00 00       	mov    $0x0,%eax
  80171b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80171e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801721:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801725:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801728:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80172b:	83 f9 09             	cmp    $0x9,%ecx
  80172e:	77 55                	ja     801785 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  801730:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801733:	eb e9                	jmp    80171e <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801735:	8b 45 14             	mov    0x14(%ebp),%eax
  801738:	8b 00                	mov    (%eax),%eax
  80173a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80173d:	8b 45 14             	mov    0x14(%ebp),%eax
  801740:	8d 40 04             	lea    0x4(%eax),%eax
  801743:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801746:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801749:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80174d:	79 91                	jns    8016e0 <vprintfmt+0x54>
				width = precision, precision = -1;
  80174f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801752:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801755:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80175c:	eb 82                	jmp    8016e0 <vprintfmt+0x54>
  80175e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801761:	85 d2                	test   %edx,%edx
  801763:	b8 00 00 00 00       	mov    $0x0,%eax
  801768:	0f 49 c2             	cmovns %edx,%eax
  80176b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80176e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801771:	e9 6a ff ff ff       	jmp    8016e0 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801776:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801779:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801780:	e9 5b ff ff ff       	jmp    8016e0 <vprintfmt+0x54>
  801785:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801788:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80178b:	eb bc                	jmp    801749 <vprintfmt+0xbd>
			lflag++;
  80178d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801790:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801793:	e9 48 ff ff ff       	jmp    8016e0 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  801798:	8b 45 14             	mov    0x14(%ebp),%eax
  80179b:	8d 78 04             	lea    0x4(%eax),%edi
  80179e:	83 ec 08             	sub    $0x8,%esp
  8017a1:	53                   	push   %ebx
  8017a2:	ff 30                	push   (%eax)
  8017a4:	ff d6                	call   *%esi
			break;
  8017a6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017a9:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017ac:	e9 9d 02 00 00       	jmp    801a4e <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8017b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8017b4:	8d 78 04             	lea    0x4(%eax),%edi
  8017b7:	8b 10                	mov    (%eax),%edx
  8017b9:	89 d0                	mov    %edx,%eax
  8017bb:	f7 d8                	neg    %eax
  8017bd:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017c0:	83 f8 0f             	cmp    $0xf,%eax
  8017c3:	7f 23                	jg     8017e8 <vprintfmt+0x15c>
  8017c5:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  8017cc:	85 d2                	test   %edx,%edx
  8017ce:	74 18                	je     8017e8 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8017d0:	52                   	push   %edx
  8017d1:	68 01 23 80 00       	push   $0x802301
  8017d6:	53                   	push   %ebx
  8017d7:	56                   	push   %esi
  8017d8:	e8 92 fe ff ff       	call   80166f <printfmt>
  8017dd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017e0:	89 7d 14             	mov    %edi,0x14(%ebp)
  8017e3:	e9 66 02 00 00       	jmp    801a4e <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8017e8:	50                   	push   %eax
  8017e9:	68 bb 23 80 00       	push   $0x8023bb
  8017ee:	53                   	push   %ebx
  8017ef:	56                   	push   %esi
  8017f0:	e8 7a fe ff ff       	call   80166f <printfmt>
  8017f5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017f8:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8017fb:	e9 4e 02 00 00       	jmp    801a4e <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  801800:	8b 45 14             	mov    0x14(%ebp),%eax
  801803:	83 c0 04             	add    $0x4,%eax
  801806:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801809:	8b 45 14             	mov    0x14(%ebp),%eax
  80180c:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80180e:	85 d2                	test   %edx,%edx
  801810:	b8 b4 23 80 00       	mov    $0x8023b4,%eax
  801815:	0f 45 c2             	cmovne %edx,%eax
  801818:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80181b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80181f:	7e 06                	jle    801827 <vprintfmt+0x19b>
  801821:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801825:	75 0d                	jne    801834 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801827:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80182a:	89 c7                	mov    %eax,%edi
  80182c:	03 45 e0             	add    -0x20(%ebp),%eax
  80182f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801832:	eb 55                	jmp    801889 <vprintfmt+0x1fd>
  801834:	83 ec 08             	sub    $0x8,%esp
  801837:	ff 75 d8             	push   -0x28(%ebp)
  80183a:	ff 75 cc             	push   -0x34(%ebp)
  80183d:	e8 0a 03 00 00       	call   801b4c <strnlen>
  801842:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801845:	29 c1                	sub    %eax,%ecx
  801847:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80184a:	83 c4 10             	add    $0x10,%esp
  80184d:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80184f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801853:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801856:	eb 0f                	jmp    801867 <vprintfmt+0x1db>
					putch(padc, putdat);
  801858:	83 ec 08             	sub    $0x8,%esp
  80185b:	53                   	push   %ebx
  80185c:	ff 75 e0             	push   -0x20(%ebp)
  80185f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801861:	83 ef 01             	sub    $0x1,%edi
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	85 ff                	test   %edi,%edi
  801869:	7f ed                	jg     801858 <vprintfmt+0x1cc>
  80186b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80186e:	85 d2                	test   %edx,%edx
  801870:	b8 00 00 00 00       	mov    $0x0,%eax
  801875:	0f 49 c2             	cmovns %edx,%eax
  801878:	29 c2                	sub    %eax,%edx
  80187a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80187d:	eb a8                	jmp    801827 <vprintfmt+0x19b>
					putch(ch, putdat);
  80187f:	83 ec 08             	sub    $0x8,%esp
  801882:	53                   	push   %ebx
  801883:	52                   	push   %edx
  801884:	ff d6                	call   *%esi
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80188c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80188e:	83 c7 01             	add    $0x1,%edi
  801891:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801895:	0f be d0             	movsbl %al,%edx
  801898:	85 d2                	test   %edx,%edx
  80189a:	74 4b                	je     8018e7 <vprintfmt+0x25b>
  80189c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018a0:	78 06                	js     8018a8 <vprintfmt+0x21c>
  8018a2:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018a6:	78 1e                	js     8018c6 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8018a8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018ac:	74 d1                	je     80187f <vprintfmt+0x1f3>
  8018ae:	0f be c0             	movsbl %al,%eax
  8018b1:	83 e8 20             	sub    $0x20,%eax
  8018b4:	83 f8 5e             	cmp    $0x5e,%eax
  8018b7:	76 c6                	jbe    80187f <vprintfmt+0x1f3>
					putch('?', putdat);
  8018b9:	83 ec 08             	sub    $0x8,%esp
  8018bc:	53                   	push   %ebx
  8018bd:	6a 3f                	push   $0x3f
  8018bf:	ff d6                	call   *%esi
  8018c1:	83 c4 10             	add    $0x10,%esp
  8018c4:	eb c3                	jmp    801889 <vprintfmt+0x1fd>
  8018c6:	89 cf                	mov    %ecx,%edi
  8018c8:	eb 0e                	jmp    8018d8 <vprintfmt+0x24c>
				putch(' ', putdat);
  8018ca:	83 ec 08             	sub    $0x8,%esp
  8018cd:	53                   	push   %ebx
  8018ce:	6a 20                	push   $0x20
  8018d0:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8018d2:	83 ef 01             	sub    $0x1,%edi
  8018d5:	83 c4 10             	add    $0x10,%esp
  8018d8:	85 ff                	test   %edi,%edi
  8018da:	7f ee                	jg     8018ca <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8018dc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8018df:	89 45 14             	mov    %eax,0x14(%ebp)
  8018e2:	e9 67 01 00 00       	jmp    801a4e <vprintfmt+0x3c2>
  8018e7:	89 cf                	mov    %ecx,%edi
  8018e9:	eb ed                	jmp    8018d8 <vprintfmt+0x24c>
	if (lflag >= 2)
  8018eb:	83 f9 01             	cmp    $0x1,%ecx
  8018ee:	7f 1b                	jg     80190b <vprintfmt+0x27f>
	else if (lflag)
  8018f0:	85 c9                	test   %ecx,%ecx
  8018f2:	74 63                	je     801957 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8018f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f7:	8b 00                	mov    (%eax),%eax
  8018f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018fc:	99                   	cltd   
  8018fd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801900:	8b 45 14             	mov    0x14(%ebp),%eax
  801903:	8d 40 04             	lea    0x4(%eax),%eax
  801906:	89 45 14             	mov    %eax,0x14(%ebp)
  801909:	eb 17                	jmp    801922 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80190b:	8b 45 14             	mov    0x14(%ebp),%eax
  80190e:	8b 50 04             	mov    0x4(%eax),%edx
  801911:	8b 00                	mov    (%eax),%eax
  801913:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801916:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801919:	8b 45 14             	mov    0x14(%ebp),%eax
  80191c:	8d 40 08             	lea    0x8(%eax),%eax
  80191f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801922:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801925:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801928:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80192d:	85 c9                	test   %ecx,%ecx
  80192f:	0f 89 ff 00 00 00    	jns    801a34 <vprintfmt+0x3a8>
				putch('-', putdat);
  801935:	83 ec 08             	sub    $0x8,%esp
  801938:	53                   	push   %ebx
  801939:	6a 2d                	push   $0x2d
  80193b:	ff d6                	call   *%esi
				num = -(long long) num;
  80193d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801940:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801943:	f7 da                	neg    %edx
  801945:	83 d1 00             	adc    $0x0,%ecx
  801948:	f7 d9                	neg    %ecx
  80194a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80194d:	bf 0a 00 00 00       	mov    $0xa,%edi
  801952:	e9 dd 00 00 00       	jmp    801a34 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801957:	8b 45 14             	mov    0x14(%ebp),%eax
  80195a:	8b 00                	mov    (%eax),%eax
  80195c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80195f:	99                   	cltd   
  801960:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801963:	8b 45 14             	mov    0x14(%ebp),%eax
  801966:	8d 40 04             	lea    0x4(%eax),%eax
  801969:	89 45 14             	mov    %eax,0x14(%ebp)
  80196c:	eb b4                	jmp    801922 <vprintfmt+0x296>
	if (lflag >= 2)
  80196e:	83 f9 01             	cmp    $0x1,%ecx
  801971:	7f 1e                	jg     801991 <vprintfmt+0x305>
	else if (lflag)
  801973:	85 c9                	test   %ecx,%ecx
  801975:	74 32                	je     8019a9 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  801977:	8b 45 14             	mov    0x14(%ebp),%eax
  80197a:	8b 10                	mov    (%eax),%edx
  80197c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801981:	8d 40 04             	lea    0x4(%eax),%eax
  801984:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801987:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80198c:	e9 a3 00 00 00       	jmp    801a34 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801991:	8b 45 14             	mov    0x14(%ebp),%eax
  801994:	8b 10                	mov    (%eax),%edx
  801996:	8b 48 04             	mov    0x4(%eax),%ecx
  801999:	8d 40 08             	lea    0x8(%eax),%eax
  80199c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80199f:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8019a4:	e9 8b 00 00 00       	jmp    801a34 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ac:	8b 10                	mov    (%eax),%edx
  8019ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019b3:	8d 40 04             	lea    0x4(%eax),%eax
  8019b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019b9:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8019be:	eb 74                	jmp    801a34 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8019c0:	83 f9 01             	cmp    $0x1,%ecx
  8019c3:	7f 1b                	jg     8019e0 <vprintfmt+0x354>
	else if (lflag)
  8019c5:	85 c9                	test   %ecx,%ecx
  8019c7:	74 2c                	je     8019f5 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8019c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019cc:	8b 10                	mov    (%eax),%edx
  8019ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019d3:	8d 40 04             	lea    0x4(%eax),%eax
  8019d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019d9:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8019de:	eb 54                	jmp    801a34 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e3:	8b 10                	mov    (%eax),%edx
  8019e5:	8b 48 04             	mov    0x4(%eax),%ecx
  8019e8:	8d 40 08             	lea    0x8(%eax),%eax
  8019eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019ee:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8019f3:	eb 3f                	jmp    801a34 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f8:	8b 10                	mov    (%eax),%edx
  8019fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019ff:	8d 40 04             	lea    0x4(%eax),%eax
  801a02:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a05:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801a0a:	eb 28                	jmp    801a34 <vprintfmt+0x3a8>
			putch('0', putdat);
  801a0c:	83 ec 08             	sub    $0x8,%esp
  801a0f:	53                   	push   %ebx
  801a10:	6a 30                	push   $0x30
  801a12:	ff d6                	call   *%esi
			putch('x', putdat);
  801a14:	83 c4 08             	add    $0x8,%esp
  801a17:	53                   	push   %ebx
  801a18:	6a 78                	push   $0x78
  801a1a:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a1c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a1f:	8b 10                	mov    (%eax),%edx
  801a21:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a26:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a29:	8d 40 04             	lea    0x4(%eax),%eax
  801a2c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a2f:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801a34:	83 ec 0c             	sub    $0xc,%esp
  801a37:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801a3b:	50                   	push   %eax
  801a3c:	ff 75 e0             	push   -0x20(%ebp)
  801a3f:	57                   	push   %edi
  801a40:	51                   	push   %ecx
  801a41:	52                   	push   %edx
  801a42:	89 da                	mov    %ebx,%edx
  801a44:	89 f0                	mov    %esi,%eax
  801a46:	e8 5e fb ff ff       	call   8015a9 <printnum>
			break;
  801a4b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801a4e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a51:	e9 54 fc ff ff       	jmp    8016aa <vprintfmt+0x1e>
	if (lflag >= 2)
  801a56:	83 f9 01             	cmp    $0x1,%ecx
  801a59:	7f 1b                	jg     801a76 <vprintfmt+0x3ea>
	else if (lflag)
  801a5b:	85 c9                	test   %ecx,%ecx
  801a5d:	74 2c                	je     801a8b <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801a5f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a62:	8b 10                	mov    (%eax),%edx
  801a64:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a69:	8d 40 04             	lea    0x4(%eax),%eax
  801a6c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a6f:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801a74:	eb be                	jmp    801a34 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801a76:	8b 45 14             	mov    0x14(%ebp),%eax
  801a79:	8b 10                	mov    (%eax),%edx
  801a7b:	8b 48 04             	mov    0x4(%eax),%ecx
  801a7e:	8d 40 08             	lea    0x8(%eax),%eax
  801a81:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a84:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  801a89:	eb a9                	jmp    801a34 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a8b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a8e:	8b 10                	mov    (%eax),%edx
  801a90:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a95:	8d 40 04             	lea    0x4(%eax),%eax
  801a98:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a9b:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  801aa0:	eb 92                	jmp    801a34 <vprintfmt+0x3a8>
			putch(ch, putdat);
  801aa2:	83 ec 08             	sub    $0x8,%esp
  801aa5:	53                   	push   %ebx
  801aa6:	6a 25                	push   $0x25
  801aa8:	ff d6                	call   *%esi
			break;
  801aaa:	83 c4 10             	add    $0x10,%esp
  801aad:	eb 9f                	jmp    801a4e <vprintfmt+0x3c2>
			putch('%', putdat);
  801aaf:	83 ec 08             	sub    $0x8,%esp
  801ab2:	53                   	push   %ebx
  801ab3:	6a 25                	push   $0x25
  801ab5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ab7:	83 c4 10             	add    $0x10,%esp
  801aba:	89 f8                	mov    %edi,%eax
  801abc:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801ac0:	74 05                	je     801ac7 <vprintfmt+0x43b>
  801ac2:	83 e8 01             	sub    $0x1,%eax
  801ac5:	eb f5                	jmp    801abc <vprintfmt+0x430>
  801ac7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801aca:	eb 82                	jmp    801a4e <vprintfmt+0x3c2>

00801acc <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	83 ec 18             	sub    $0x18,%esp
  801ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ad8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801adb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801adf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ae2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	74 26                	je     801b13 <vsnprintf+0x47>
  801aed:	85 d2                	test   %edx,%edx
  801aef:	7e 22                	jle    801b13 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801af1:	ff 75 14             	push   0x14(%ebp)
  801af4:	ff 75 10             	push   0x10(%ebp)
  801af7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801afa:	50                   	push   %eax
  801afb:	68 52 16 80 00       	push   $0x801652
  801b00:	e8 87 fb ff ff       	call   80168c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b05:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b08:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0e:	83 c4 10             	add    $0x10,%esp
}
  801b11:	c9                   	leave  
  801b12:	c3                   	ret    
		return -E_INVAL;
  801b13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b18:	eb f7                	jmp    801b11 <vsnprintf+0x45>

00801b1a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b20:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b23:	50                   	push   %eax
  801b24:	ff 75 10             	push   0x10(%ebp)
  801b27:	ff 75 0c             	push   0xc(%ebp)
  801b2a:	ff 75 08             	push   0x8(%ebp)
  801b2d:	e8 9a ff ff ff       	call   801acc <vsnprintf>
	va_end(ap);

	return rc;
}
  801b32:	c9                   	leave  
  801b33:	c3                   	ret    

00801b34 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3f:	eb 03                	jmp    801b44 <strlen+0x10>
		n++;
  801b41:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801b44:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b48:	75 f7                	jne    801b41 <strlen+0xd>
	return n;
}
  801b4a:	5d                   	pop    %ebp
  801b4b:	c3                   	ret    

00801b4c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b52:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b55:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5a:	eb 03                	jmp    801b5f <strnlen+0x13>
		n++;
  801b5c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b5f:	39 d0                	cmp    %edx,%eax
  801b61:	74 08                	je     801b6b <strnlen+0x1f>
  801b63:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801b67:	75 f3                	jne    801b5c <strnlen+0x10>
  801b69:	89 c2                	mov    %eax,%edx
	return n;
}
  801b6b:	89 d0                	mov    %edx,%eax
  801b6d:	5d                   	pop    %ebp
  801b6e:	c3                   	ret    

00801b6f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	53                   	push   %ebx
  801b73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b79:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7e:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801b82:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801b85:	83 c0 01             	add    $0x1,%eax
  801b88:	84 d2                	test   %dl,%dl
  801b8a:	75 f2                	jne    801b7e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801b8c:	89 c8                	mov    %ecx,%eax
  801b8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b91:	c9                   	leave  
  801b92:	c3                   	ret    

00801b93 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	53                   	push   %ebx
  801b97:	83 ec 10             	sub    $0x10,%esp
  801b9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b9d:	53                   	push   %ebx
  801b9e:	e8 91 ff ff ff       	call   801b34 <strlen>
  801ba3:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801ba6:	ff 75 0c             	push   0xc(%ebp)
  801ba9:	01 d8                	add    %ebx,%eax
  801bab:	50                   	push   %eax
  801bac:	e8 be ff ff ff       	call   801b6f <strcpy>
	return dst;
}
  801bb1:	89 d8                	mov    %ebx,%eax
  801bb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb6:	c9                   	leave  
  801bb7:	c3                   	ret    

00801bb8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	56                   	push   %esi
  801bbc:	53                   	push   %ebx
  801bbd:	8b 75 08             	mov    0x8(%ebp),%esi
  801bc0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bc3:	89 f3                	mov    %esi,%ebx
  801bc5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bc8:	89 f0                	mov    %esi,%eax
  801bca:	eb 0f                	jmp    801bdb <strncpy+0x23>
		*dst++ = *src;
  801bcc:	83 c0 01             	add    $0x1,%eax
  801bcf:	0f b6 0a             	movzbl (%edx),%ecx
  801bd2:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bd5:	80 f9 01             	cmp    $0x1,%cl
  801bd8:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801bdb:	39 d8                	cmp    %ebx,%eax
  801bdd:	75 ed                	jne    801bcc <strncpy+0x14>
	}
	return ret;
}
  801bdf:	89 f0                	mov    %esi,%eax
  801be1:	5b                   	pop    %ebx
  801be2:	5e                   	pop    %esi
  801be3:	5d                   	pop    %ebp
  801be4:	c3                   	ret    

00801be5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	56                   	push   %esi
  801be9:	53                   	push   %ebx
  801bea:	8b 75 08             	mov    0x8(%ebp),%esi
  801bed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bf0:	8b 55 10             	mov    0x10(%ebp),%edx
  801bf3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bf5:	85 d2                	test   %edx,%edx
  801bf7:	74 21                	je     801c1a <strlcpy+0x35>
  801bf9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bfd:	89 f2                	mov    %esi,%edx
  801bff:	eb 09                	jmp    801c0a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c01:	83 c1 01             	add    $0x1,%ecx
  801c04:	83 c2 01             	add    $0x1,%edx
  801c07:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801c0a:	39 c2                	cmp    %eax,%edx
  801c0c:	74 09                	je     801c17 <strlcpy+0x32>
  801c0e:	0f b6 19             	movzbl (%ecx),%ebx
  801c11:	84 db                	test   %bl,%bl
  801c13:	75 ec                	jne    801c01 <strlcpy+0x1c>
  801c15:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c17:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c1a:	29 f0                	sub    %esi,%eax
}
  801c1c:	5b                   	pop    %ebx
  801c1d:	5e                   	pop    %esi
  801c1e:	5d                   	pop    %ebp
  801c1f:	c3                   	ret    

00801c20 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c26:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c29:	eb 06                	jmp    801c31 <strcmp+0x11>
		p++, q++;
  801c2b:	83 c1 01             	add    $0x1,%ecx
  801c2e:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801c31:	0f b6 01             	movzbl (%ecx),%eax
  801c34:	84 c0                	test   %al,%al
  801c36:	74 04                	je     801c3c <strcmp+0x1c>
  801c38:	3a 02                	cmp    (%edx),%al
  801c3a:	74 ef                	je     801c2b <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c3c:	0f b6 c0             	movzbl %al,%eax
  801c3f:	0f b6 12             	movzbl (%edx),%edx
  801c42:	29 d0                	sub    %edx,%eax
}
  801c44:	5d                   	pop    %ebp
  801c45:	c3                   	ret    

00801c46 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	53                   	push   %ebx
  801c4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c50:	89 c3                	mov    %eax,%ebx
  801c52:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c55:	eb 06                	jmp    801c5d <strncmp+0x17>
		n--, p++, q++;
  801c57:	83 c0 01             	add    $0x1,%eax
  801c5a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801c5d:	39 d8                	cmp    %ebx,%eax
  801c5f:	74 18                	je     801c79 <strncmp+0x33>
  801c61:	0f b6 08             	movzbl (%eax),%ecx
  801c64:	84 c9                	test   %cl,%cl
  801c66:	74 04                	je     801c6c <strncmp+0x26>
  801c68:	3a 0a                	cmp    (%edx),%cl
  801c6a:	74 eb                	je     801c57 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c6c:	0f b6 00             	movzbl (%eax),%eax
  801c6f:	0f b6 12             	movzbl (%edx),%edx
  801c72:	29 d0                	sub    %edx,%eax
}
  801c74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c77:	c9                   	leave  
  801c78:	c3                   	ret    
		return 0;
  801c79:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7e:	eb f4                	jmp    801c74 <strncmp+0x2e>

00801c80 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	8b 45 08             	mov    0x8(%ebp),%eax
  801c86:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c8a:	eb 03                	jmp    801c8f <strchr+0xf>
  801c8c:	83 c0 01             	add    $0x1,%eax
  801c8f:	0f b6 10             	movzbl (%eax),%edx
  801c92:	84 d2                	test   %dl,%dl
  801c94:	74 06                	je     801c9c <strchr+0x1c>
		if (*s == c)
  801c96:	38 ca                	cmp    %cl,%dl
  801c98:	75 f2                	jne    801c8c <strchr+0xc>
  801c9a:	eb 05                	jmp    801ca1 <strchr+0x21>
			return (char *) s;
	return 0;
  801c9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ca1:	5d                   	pop    %ebp
  801ca2:	c3                   	ret    

00801ca3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cad:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cb0:	38 ca                	cmp    %cl,%dl
  801cb2:	74 09                	je     801cbd <strfind+0x1a>
  801cb4:	84 d2                	test   %dl,%dl
  801cb6:	74 05                	je     801cbd <strfind+0x1a>
	for (; *s; s++)
  801cb8:	83 c0 01             	add    $0x1,%eax
  801cbb:	eb f0                	jmp    801cad <strfind+0xa>
			break;
	return (char *) s;
}
  801cbd:	5d                   	pop    %ebp
  801cbe:	c3                   	ret    

00801cbf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	57                   	push   %edi
  801cc3:	56                   	push   %esi
  801cc4:	53                   	push   %ebx
  801cc5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cc8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ccb:	85 c9                	test   %ecx,%ecx
  801ccd:	74 2f                	je     801cfe <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ccf:	89 f8                	mov    %edi,%eax
  801cd1:	09 c8                	or     %ecx,%eax
  801cd3:	a8 03                	test   $0x3,%al
  801cd5:	75 21                	jne    801cf8 <memset+0x39>
		c &= 0xFF;
  801cd7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cdb:	89 d0                	mov    %edx,%eax
  801cdd:	c1 e0 08             	shl    $0x8,%eax
  801ce0:	89 d3                	mov    %edx,%ebx
  801ce2:	c1 e3 18             	shl    $0x18,%ebx
  801ce5:	89 d6                	mov    %edx,%esi
  801ce7:	c1 e6 10             	shl    $0x10,%esi
  801cea:	09 f3                	or     %esi,%ebx
  801cec:	09 da                	or     %ebx,%edx
  801cee:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801cf0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801cf3:	fc                   	cld    
  801cf4:	f3 ab                	rep stos %eax,%es:(%edi)
  801cf6:	eb 06                	jmp    801cfe <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cf8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cfb:	fc                   	cld    
  801cfc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cfe:	89 f8                	mov    %edi,%eax
  801d00:	5b                   	pop    %ebx
  801d01:	5e                   	pop    %esi
  801d02:	5f                   	pop    %edi
  801d03:	5d                   	pop    %ebp
  801d04:	c3                   	ret    

00801d05 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	57                   	push   %edi
  801d09:	56                   	push   %esi
  801d0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d10:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d13:	39 c6                	cmp    %eax,%esi
  801d15:	73 32                	jae    801d49 <memmove+0x44>
  801d17:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d1a:	39 c2                	cmp    %eax,%edx
  801d1c:	76 2b                	jbe    801d49 <memmove+0x44>
		s += n;
		d += n;
  801d1e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d21:	89 d6                	mov    %edx,%esi
  801d23:	09 fe                	or     %edi,%esi
  801d25:	09 ce                	or     %ecx,%esi
  801d27:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d2d:	75 0e                	jne    801d3d <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d2f:	83 ef 04             	sub    $0x4,%edi
  801d32:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d35:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801d38:	fd                   	std    
  801d39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d3b:	eb 09                	jmp    801d46 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d3d:	83 ef 01             	sub    $0x1,%edi
  801d40:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801d43:	fd                   	std    
  801d44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d46:	fc                   	cld    
  801d47:	eb 1a                	jmp    801d63 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d49:	89 f2                	mov    %esi,%edx
  801d4b:	09 c2                	or     %eax,%edx
  801d4d:	09 ca                	or     %ecx,%edx
  801d4f:	f6 c2 03             	test   $0x3,%dl
  801d52:	75 0a                	jne    801d5e <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d54:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801d57:	89 c7                	mov    %eax,%edi
  801d59:	fc                   	cld    
  801d5a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d5c:	eb 05                	jmp    801d63 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801d5e:	89 c7                	mov    %eax,%edi
  801d60:	fc                   	cld    
  801d61:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d63:	5e                   	pop    %esi
  801d64:	5f                   	pop    %edi
  801d65:	5d                   	pop    %ebp
  801d66:	c3                   	ret    

00801d67 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d6d:	ff 75 10             	push   0x10(%ebp)
  801d70:	ff 75 0c             	push   0xc(%ebp)
  801d73:	ff 75 08             	push   0x8(%ebp)
  801d76:	e8 8a ff ff ff       	call   801d05 <memmove>
}
  801d7b:	c9                   	leave  
  801d7c:	c3                   	ret    

00801d7d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
  801d80:	56                   	push   %esi
  801d81:	53                   	push   %ebx
  801d82:	8b 45 08             	mov    0x8(%ebp),%eax
  801d85:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d88:	89 c6                	mov    %eax,%esi
  801d8a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d8d:	eb 06                	jmp    801d95 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801d8f:	83 c0 01             	add    $0x1,%eax
  801d92:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801d95:	39 f0                	cmp    %esi,%eax
  801d97:	74 14                	je     801dad <memcmp+0x30>
		if (*s1 != *s2)
  801d99:	0f b6 08             	movzbl (%eax),%ecx
  801d9c:	0f b6 1a             	movzbl (%edx),%ebx
  801d9f:	38 d9                	cmp    %bl,%cl
  801da1:	74 ec                	je     801d8f <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801da3:	0f b6 c1             	movzbl %cl,%eax
  801da6:	0f b6 db             	movzbl %bl,%ebx
  801da9:	29 d8                	sub    %ebx,%eax
  801dab:	eb 05                	jmp    801db2 <memcmp+0x35>
	}

	return 0;
  801dad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801db2:	5b                   	pop    %ebx
  801db3:	5e                   	pop    %esi
  801db4:	5d                   	pop    %ebp
  801db5:	c3                   	ret    

00801db6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801dbf:	89 c2                	mov    %eax,%edx
  801dc1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801dc4:	eb 03                	jmp    801dc9 <memfind+0x13>
  801dc6:	83 c0 01             	add    $0x1,%eax
  801dc9:	39 d0                	cmp    %edx,%eax
  801dcb:	73 04                	jae    801dd1 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dcd:	38 08                	cmp    %cl,(%eax)
  801dcf:	75 f5                	jne    801dc6 <memfind+0x10>
			break;
	return (void *) s;
}
  801dd1:	5d                   	pop    %ebp
  801dd2:	c3                   	ret    

00801dd3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	57                   	push   %edi
  801dd7:	56                   	push   %esi
  801dd8:	53                   	push   %ebx
  801dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  801ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ddf:	eb 03                	jmp    801de4 <strtol+0x11>
		s++;
  801de1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801de4:	0f b6 02             	movzbl (%edx),%eax
  801de7:	3c 20                	cmp    $0x20,%al
  801de9:	74 f6                	je     801de1 <strtol+0xe>
  801deb:	3c 09                	cmp    $0x9,%al
  801ded:	74 f2                	je     801de1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801def:	3c 2b                	cmp    $0x2b,%al
  801df1:	74 2a                	je     801e1d <strtol+0x4a>
	int neg = 0;
  801df3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801df8:	3c 2d                	cmp    $0x2d,%al
  801dfa:	74 2b                	je     801e27 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801dfc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e02:	75 0f                	jne    801e13 <strtol+0x40>
  801e04:	80 3a 30             	cmpb   $0x30,(%edx)
  801e07:	74 28                	je     801e31 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e09:	85 db                	test   %ebx,%ebx
  801e0b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e10:	0f 44 d8             	cmove  %eax,%ebx
  801e13:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e18:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801e1b:	eb 46                	jmp    801e63 <strtol+0x90>
		s++;
  801e1d:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801e20:	bf 00 00 00 00       	mov    $0x0,%edi
  801e25:	eb d5                	jmp    801dfc <strtol+0x29>
		s++, neg = 1;
  801e27:	83 c2 01             	add    $0x1,%edx
  801e2a:	bf 01 00 00 00       	mov    $0x1,%edi
  801e2f:	eb cb                	jmp    801dfc <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e31:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e35:	74 0e                	je     801e45 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801e37:	85 db                	test   %ebx,%ebx
  801e39:	75 d8                	jne    801e13 <strtol+0x40>
		s++, base = 8;
  801e3b:	83 c2 01             	add    $0x1,%edx
  801e3e:	bb 08 00 00 00       	mov    $0x8,%ebx
  801e43:	eb ce                	jmp    801e13 <strtol+0x40>
		s += 2, base = 16;
  801e45:	83 c2 02             	add    $0x2,%edx
  801e48:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e4d:	eb c4                	jmp    801e13 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801e4f:	0f be c0             	movsbl %al,%eax
  801e52:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801e55:	3b 45 10             	cmp    0x10(%ebp),%eax
  801e58:	7d 3a                	jge    801e94 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801e5a:	83 c2 01             	add    $0x1,%edx
  801e5d:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801e61:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801e63:	0f b6 02             	movzbl (%edx),%eax
  801e66:	8d 70 d0             	lea    -0x30(%eax),%esi
  801e69:	89 f3                	mov    %esi,%ebx
  801e6b:	80 fb 09             	cmp    $0x9,%bl
  801e6e:	76 df                	jbe    801e4f <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801e70:	8d 70 9f             	lea    -0x61(%eax),%esi
  801e73:	89 f3                	mov    %esi,%ebx
  801e75:	80 fb 19             	cmp    $0x19,%bl
  801e78:	77 08                	ja     801e82 <strtol+0xaf>
			dig = *s - 'a' + 10;
  801e7a:	0f be c0             	movsbl %al,%eax
  801e7d:	83 e8 57             	sub    $0x57,%eax
  801e80:	eb d3                	jmp    801e55 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801e82:	8d 70 bf             	lea    -0x41(%eax),%esi
  801e85:	89 f3                	mov    %esi,%ebx
  801e87:	80 fb 19             	cmp    $0x19,%bl
  801e8a:	77 08                	ja     801e94 <strtol+0xc1>
			dig = *s - 'A' + 10;
  801e8c:	0f be c0             	movsbl %al,%eax
  801e8f:	83 e8 37             	sub    $0x37,%eax
  801e92:	eb c1                	jmp    801e55 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801e94:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e98:	74 05                	je     801e9f <strtol+0xcc>
		*endptr = (char *) s;
  801e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e9d:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801e9f:	89 c8                	mov    %ecx,%eax
  801ea1:	f7 d8                	neg    %eax
  801ea3:	85 ff                	test   %edi,%edi
  801ea5:	0f 45 c8             	cmovne %eax,%ecx
}
  801ea8:	89 c8                	mov    %ecx,%eax
  801eaa:	5b                   	pop    %ebx
  801eab:	5e                   	pop    %esi
  801eac:	5f                   	pop    %edi
  801ead:	5d                   	pop    %ebp
  801eae:	c3                   	ret    

00801eaf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	56                   	push   %esi
  801eb3:	53                   	push   %ebx
  801eb4:	8b 75 08             	mov    0x8(%ebp),%esi
  801eb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801ebd:	85 c0                	test   %eax,%eax
  801ebf:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ec4:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ec7:	83 ec 0c             	sub    $0xc,%esp
  801eca:	50                   	push   %eax
  801ecb:	e8 3a e4 ff ff       	call   80030a <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ed0:	83 c4 10             	add    $0x10,%esp
  801ed3:	85 f6                	test   %esi,%esi
  801ed5:	74 14                	je     801eeb <ipc_recv+0x3c>
  801ed7:	ba 00 00 00 00       	mov    $0x0,%edx
  801edc:	85 c0                	test   %eax,%eax
  801ede:	78 09                	js     801ee9 <ipc_recv+0x3a>
  801ee0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ee6:	8b 52 74             	mov    0x74(%edx),%edx
  801ee9:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801eeb:	85 db                	test   %ebx,%ebx
  801eed:	74 14                	je     801f03 <ipc_recv+0x54>
  801eef:	ba 00 00 00 00       	mov    $0x0,%edx
  801ef4:	85 c0                	test   %eax,%eax
  801ef6:	78 09                	js     801f01 <ipc_recv+0x52>
  801ef8:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801efe:	8b 52 78             	mov    0x78(%edx),%edx
  801f01:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f03:	85 c0                	test   %eax,%eax
  801f05:	78 08                	js     801f0f <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801f07:	a1 00 40 80 00       	mov    0x804000,%eax
  801f0c:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f12:	5b                   	pop    %ebx
  801f13:	5e                   	pop    %esi
  801f14:	5d                   	pop    %ebp
  801f15:	c3                   	ret    

00801f16 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f16:	55                   	push   %ebp
  801f17:	89 e5                	mov    %esp,%ebp
  801f19:	57                   	push   %edi
  801f1a:	56                   	push   %esi
  801f1b:	53                   	push   %ebx
  801f1c:	83 ec 0c             	sub    $0xc,%esp
  801f1f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f22:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f28:	85 db                	test   %ebx,%ebx
  801f2a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f2f:	0f 44 d8             	cmove  %eax,%ebx
  801f32:	eb 05                	jmp    801f39 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f34:	e8 02 e2 ff ff       	call   80013b <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f39:	ff 75 14             	push   0x14(%ebp)
  801f3c:	53                   	push   %ebx
  801f3d:	56                   	push   %esi
  801f3e:	57                   	push   %edi
  801f3f:	e8 a3 e3 ff ff       	call   8002e7 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f44:	83 c4 10             	add    $0x10,%esp
  801f47:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f4a:	74 e8                	je     801f34 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f4c:	85 c0                	test   %eax,%eax
  801f4e:	78 08                	js     801f58 <ipc_send+0x42>
	}while (r<0);

}
  801f50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f53:	5b                   	pop    %ebx
  801f54:	5e                   	pop    %esi
  801f55:	5f                   	pop    %edi
  801f56:	5d                   	pop    %ebp
  801f57:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f58:	50                   	push   %eax
  801f59:	68 9f 26 80 00       	push   $0x80269f
  801f5e:	6a 3d                	push   $0x3d
  801f60:	68 b3 26 80 00       	push   $0x8026b3
  801f65:	e8 50 f5 ff ff       	call   8014ba <_panic>

00801f6a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f70:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f75:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f78:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f7e:	8b 52 50             	mov    0x50(%edx),%edx
  801f81:	39 ca                	cmp    %ecx,%edx
  801f83:	74 11                	je     801f96 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801f85:	83 c0 01             	add    $0x1,%eax
  801f88:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f8d:	75 e6                	jne    801f75 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f8f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f94:	eb 0b                	jmp    801fa1 <ipc_find_env+0x37>
			return envs[i].env_id;
  801f96:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f99:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f9e:	8b 40 48             	mov    0x48(%eax),%eax
}
  801fa1:	5d                   	pop    %ebp
  801fa2:	c3                   	ret    

00801fa3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fa3:	55                   	push   %ebp
  801fa4:	89 e5                	mov    %esp,%ebp
  801fa6:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa9:	89 c2                	mov    %eax,%edx
  801fab:	c1 ea 16             	shr    $0x16,%edx
  801fae:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fb5:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fba:	f6 c1 01             	test   $0x1,%cl
  801fbd:	74 1c                	je     801fdb <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801fbf:	c1 e8 0c             	shr    $0xc,%eax
  801fc2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fc9:	a8 01                	test   $0x1,%al
  801fcb:	74 0e                	je     801fdb <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fcd:	c1 e8 0c             	shr    $0xc,%eax
  801fd0:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801fd7:	ef 
  801fd8:	0f b7 d2             	movzwl %dx,%edx
}
  801fdb:	89 d0                	mov    %edx,%eax
  801fdd:	5d                   	pop    %ebp
  801fde:	c3                   	ret    
  801fdf:	90                   	nop

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
