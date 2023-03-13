
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
  800045:	e8 ce 00 00 00       	call   800118 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800086:	e8 88 04 00 00       	call   800513 <close_all>
	sys_env_destroy(0);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	6a 00                	push   $0x0
  800090:	e8 42 00 00 00       	call   8000d7 <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e8:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7f 08                	jg     800101 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000fc:	5b                   	pop    %ebx
  8000fd:	5e                   	pop    %esi
  8000fe:	5f                   	pop    %edi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 6a 1d 80 00       	push   $0x801d6a
  80010c:	6a 2a                	push   $0x2a
  80010e:	68 87 1d 80 00       	push   $0x801d87
  800113:	e8 d0 0e 00 00       	call   800fe8 <_panic>

00800118 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 d1                	mov    %edx,%ecx
  80012a:	89 d3                	mov    %edx,%ebx
  80012c:	89 d7                	mov    %edx,%edi
  80012e:	89 d6                	mov    %edx,%esi
  800130:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_yield>:

void
sys_yield(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 0b 00 00 00       	mov    $0xb,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	8b 55 08             	mov    0x8(%ebp),%edx
  800167:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016a:	b8 04 00 00 00       	mov    $0x4,%eax
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7f 08                	jg     800182 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80017a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80017d:	5b                   	pop    %ebx
  80017e:	5e                   	pop    %esi
  80017f:	5f                   	pop    %edi
  800180:	5d                   	pop    %ebp
  800181:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 6a 1d 80 00       	push   $0x801d6a
  80018d:	6a 2a                	push   $0x2a
  80018f:	68 87 1d 80 00       	push   $0x801d87
  800194:	e8 4f 0e 00 00       	call   800fe8 <_panic>

00800199 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a8:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7f 08                	jg     8001c4 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 6a 1d 80 00       	push   $0x801d6a
  8001cf:	6a 2a                	push   $0x2a
  8001d1:	68 87 1d 80 00       	push   $0x801d87
  8001d6:	e8 0d 0e 00 00       	call   800fe8 <_panic>

008001db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ef:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f4:	89 df                	mov    %ebx,%edi
  8001f6:	89 de                	mov    %ebx,%esi
  8001f8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7f 08                	jg     800206 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 6a 1d 80 00       	push   $0x801d6a
  800211:	6a 2a                	push   $0x2a
  800213:	68 87 1d 80 00       	push   $0x801d87
  800218:	e8 cb 0d 00 00       	call   800fe8 <_panic>

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	8b 55 08             	mov    0x8(%ebp),%edx
  80022e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800231:	b8 08 00 00 00       	mov    $0x8,%eax
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7f 08                	jg     800248 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 6a 1d 80 00       	push   $0x801d6a
  800253:	6a 2a                	push   $0x2a
  800255:	68 87 1d 80 00       	push   $0x801d87
  80025a:	e8 89 0d 00 00       	call   800fe8 <_panic>

0080025f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	8b 55 08             	mov    0x8(%ebp),%edx
  800270:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800273:	b8 09 00 00 00       	mov    $0x9,%eax
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7f 08                	jg     80028a <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 6a 1d 80 00       	push   $0x801d6a
  800295:	6a 2a                	push   $0x2a
  800297:	68 87 1d 80 00       	push   $0x801d87
  80029c:	e8 47 0d 00 00       	call   800fe8 <_panic>

008002a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002af:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ba:	89 df                	mov    %ebx,%edi
  8002bc:	89 de                	mov    %ebx,%esi
  8002be:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	7f 08                	jg     8002cc <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 0a                	push   $0xa
  8002d2:	68 6a 1d 80 00       	push   $0x801d6a
  8002d7:	6a 2a                	push   $0x2a
  8002d9:	68 87 1d 80 00       	push   $0x801d87
  8002de:	e8 05 0d 00 00       	call   800fe8 <_panic>

008002e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ef:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f4:	be 00 00 00 00       	mov    $0x0,%esi
  8002f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ff:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80030f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800314:	8b 55 08             	mov    0x8(%ebp),%edx
  800317:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031c:	89 cb                	mov    %ecx,%ebx
  80031e:	89 cf                	mov    %ecx,%edi
  800320:	89 ce                	mov    %ecx,%esi
  800322:	cd 30                	int    $0x30
	if(check && ret > 0)
  800324:	85 c0                	test   %eax,%eax
  800326:	7f 08                	jg     800330 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800328:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032b:	5b                   	pop    %ebx
  80032c:	5e                   	pop    %esi
  80032d:	5f                   	pop    %edi
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	50                   	push   %eax
  800334:	6a 0d                	push   $0xd
  800336:	68 6a 1d 80 00       	push   $0x801d6a
  80033b:	6a 2a                	push   $0x2a
  80033d:	68 87 1d 80 00       	push   $0x801d87
  800342:	e8 a1 0c 00 00       	call   800fe8 <_panic>

00800347 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	05 00 00 00 30       	add    $0x30000000,%eax
  800352:	c1 e8 0c             	shr    $0xc,%eax
}
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800362:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800367:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800376:	89 c2                	mov    %eax,%edx
  800378:	c1 ea 16             	shr    $0x16,%edx
  80037b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800382:	f6 c2 01             	test   $0x1,%dl
  800385:	74 29                	je     8003b0 <fd_alloc+0x42>
  800387:	89 c2                	mov    %eax,%edx
  800389:	c1 ea 0c             	shr    $0xc,%edx
  80038c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800393:	f6 c2 01             	test   $0x1,%dl
  800396:	74 18                	je     8003b0 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800398:	05 00 10 00 00       	add    $0x1000,%eax
  80039d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003a2:	75 d2                	jne    800376 <fd_alloc+0x8>
  8003a4:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8003a9:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8003ae:	eb 05                	jmp    8003b5 <fd_alloc+0x47>
			return 0;
  8003b0:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8003b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b8:	89 02                	mov    %eax,(%edx)
}
  8003ba:	89 c8                	mov    %ecx,%eax
  8003bc:	5d                   	pop    %ebp
  8003bd:	c3                   	ret    

008003be <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c4:	83 f8 1f             	cmp    $0x1f,%eax
  8003c7:	77 30                	ja     8003f9 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c9:	c1 e0 0c             	shl    $0xc,%eax
  8003cc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d1:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003d7:	f6 c2 01             	test   $0x1,%dl
  8003da:	74 24                	je     800400 <fd_lookup+0x42>
  8003dc:	89 c2                	mov    %eax,%edx
  8003de:	c1 ea 0c             	shr    $0xc,%edx
  8003e1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e8:	f6 c2 01             	test   $0x1,%dl
  8003eb:	74 1a                	je     800407 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f0:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003f7:	5d                   	pop    %ebp
  8003f8:	c3                   	ret    
		return -E_INVAL;
  8003f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003fe:	eb f7                	jmp    8003f7 <fd_lookup+0x39>
		return -E_INVAL;
  800400:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800405:	eb f0                	jmp    8003f7 <fd_lookup+0x39>
  800407:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040c:	eb e9                	jmp    8003f7 <fd_lookup+0x39>

0080040e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
  800411:	53                   	push   %ebx
  800412:	83 ec 04             	sub    $0x4,%esp
  800415:	8b 55 08             	mov    0x8(%ebp),%edx
  800418:	b8 14 1e 80 00       	mov    $0x801e14,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  80041d:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800422:	39 13                	cmp    %edx,(%ebx)
  800424:	74 32                	je     800458 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800426:	83 c0 04             	add    $0x4,%eax
  800429:	8b 18                	mov    (%eax),%ebx
  80042b:	85 db                	test   %ebx,%ebx
  80042d:	75 f3                	jne    800422 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80042f:	a1 00 40 80 00       	mov    0x804000,%eax
  800434:	8b 40 48             	mov    0x48(%eax),%eax
  800437:	83 ec 04             	sub    $0x4,%esp
  80043a:	52                   	push   %edx
  80043b:	50                   	push   %eax
  80043c:	68 98 1d 80 00       	push   $0x801d98
  800441:	e8 7d 0c 00 00       	call   8010c3 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  80044e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800451:	89 1a                	mov    %ebx,(%edx)
}
  800453:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800456:	c9                   	leave  
  800457:	c3                   	ret    
			return 0;
  800458:	b8 00 00 00 00       	mov    $0x0,%eax
  80045d:	eb ef                	jmp    80044e <dev_lookup+0x40>

0080045f <fd_close>:
{
  80045f:	55                   	push   %ebp
  800460:	89 e5                	mov    %esp,%ebp
  800462:	57                   	push   %edi
  800463:	56                   	push   %esi
  800464:	53                   	push   %ebx
  800465:	83 ec 24             	sub    $0x24,%esp
  800468:	8b 75 08             	mov    0x8(%ebp),%esi
  80046b:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80046e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800471:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800472:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800478:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80047b:	50                   	push   %eax
  80047c:	e8 3d ff ff ff       	call   8003be <fd_lookup>
  800481:	89 c3                	mov    %eax,%ebx
  800483:	83 c4 10             	add    $0x10,%esp
  800486:	85 c0                	test   %eax,%eax
  800488:	78 05                	js     80048f <fd_close+0x30>
	    || fd != fd2)
  80048a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80048d:	74 16                	je     8004a5 <fd_close+0x46>
		return (must_exist ? r : 0);
  80048f:	89 f8                	mov    %edi,%eax
  800491:	84 c0                	test   %al,%al
  800493:	b8 00 00 00 00       	mov    $0x0,%eax
  800498:	0f 44 d8             	cmove  %eax,%ebx
}
  80049b:	89 d8                	mov    %ebx,%eax
  80049d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a0:	5b                   	pop    %ebx
  8004a1:	5e                   	pop    %esi
  8004a2:	5f                   	pop    %edi
  8004a3:	5d                   	pop    %ebp
  8004a4:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004ab:	50                   	push   %eax
  8004ac:	ff 36                	push   (%esi)
  8004ae:	e8 5b ff ff ff       	call   80040e <dev_lookup>
  8004b3:	89 c3                	mov    %eax,%ebx
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	85 c0                	test   %eax,%eax
  8004ba:	78 1a                	js     8004d6 <fd_close+0x77>
		if (dev->dev_close)
  8004bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004bf:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8004c2:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004c7:	85 c0                	test   %eax,%eax
  8004c9:	74 0b                	je     8004d6 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8004cb:	83 ec 0c             	sub    $0xc,%esp
  8004ce:	56                   	push   %esi
  8004cf:	ff d0                	call   *%eax
  8004d1:	89 c3                	mov    %eax,%ebx
  8004d3:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	56                   	push   %esi
  8004da:	6a 00                	push   $0x0
  8004dc:	e8 fa fc ff ff       	call   8001db <sys_page_unmap>
	return r;
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	eb b5                	jmp    80049b <fd_close+0x3c>

008004e6 <close>:

int
close(int fdnum)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ef:	50                   	push   %eax
  8004f0:	ff 75 08             	push   0x8(%ebp)
  8004f3:	e8 c6 fe ff ff       	call   8003be <fd_lookup>
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	85 c0                	test   %eax,%eax
  8004fd:	79 02                	jns    800501 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8004ff:	c9                   	leave  
  800500:	c3                   	ret    
		return fd_close(fd, 1);
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	6a 01                	push   $0x1
  800506:	ff 75 f4             	push   -0xc(%ebp)
  800509:	e8 51 ff ff ff       	call   80045f <fd_close>
  80050e:	83 c4 10             	add    $0x10,%esp
  800511:	eb ec                	jmp    8004ff <close+0x19>

00800513 <close_all>:

void
close_all(void)
{
  800513:	55                   	push   %ebp
  800514:	89 e5                	mov    %esp,%ebp
  800516:	53                   	push   %ebx
  800517:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80051a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051f:	83 ec 0c             	sub    $0xc,%esp
  800522:	53                   	push   %ebx
  800523:	e8 be ff ff ff       	call   8004e6 <close>
	for (i = 0; i < MAXFD; i++)
  800528:	83 c3 01             	add    $0x1,%ebx
  80052b:	83 c4 10             	add    $0x10,%esp
  80052e:	83 fb 20             	cmp    $0x20,%ebx
  800531:	75 ec                	jne    80051f <close_all+0xc>
}
  800533:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800536:	c9                   	leave  
  800537:	c3                   	ret    

00800538 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800538:	55                   	push   %ebp
  800539:	89 e5                	mov    %esp,%ebp
  80053b:	57                   	push   %edi
  80053c:	56                   	push   %esi
  80053d:	53                   	push   %ebx
  80053e:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800541:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800544:	50                   	push   %eax
  800545:	ff 75 08             	push   0x8(%ebp)
  800548:	e8 71 fe ff ff       	call   8003be <fd_lookup>
  80054d:	89 c3                	mov    %eax,%ebx
  80054f:	83 c4 10             	add    $0x10,%esp
  800552:	85 c0                	test   %eax,%eax
  800554:	78 7f                	js     8005d5 <dup+0x9d>
		return r;
	close(newfdnum);
  800556:	83 ec 0c             	sub    $0xc,%esp
  800559:	ff 75 0c             	push   0xc(%ebp)
  80055c:	e8 85 ff ff ff       	call   8004e6 <close>

	newfd = INDEX2FD(newfdnum);
  800561:	8b 75 0c             	mov    0xc(%ebp),%esi
  800564:	c1 e6 0c             	shl    $0xc,%esi
  800567:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80056d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800570:	89 3c 24             	mov    %edi,(%esp)
  800573:	e8 df fd ff ff       	call   800357 <fd2data>
  800578:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80057a:	89 34 24             	mov    %esi,(%esp)
  80057d:	e8 d5 fd ff ff       	call   800357 <fd2data>
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800588:	89 d8                	mov    %ebx,%eax
  80058a:	c1 e8 16             	shr    $0x16,%eax
  80058d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800594:	a8 01                	test   $0x1,%al
  800596:	74 11                	je     8005a9 <dup+0x71>
  800598:	89 d8                	mov    %ebx,%eax
  80059a:	c1 e8 0c             	shr    $0xc,%eax
  80059d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a4:	f6 c2 01             	test   $0x1,%dl
  8005a7:	75 36                	jne    8005df <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005a9:	89 f8                	mov    %edi,%eax
  8005ab:	c1 e8 0c             	shr    $0xc,%eax
  8005ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b5:	83 ec 0c             	sub    $0xc,%esp
  8005b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005bd:	50                   	push   %eax
  8005be:	56                   	push   %esi
  8005bf:	6a 00                	push   $0x0
  8005c1:	57                   	push   %edi
  8005c2:	6a 00                	push   $0x0
  8005c4:	e8 d0 fb ff ff       	call   800199 <sys_page_map>
  8005c9:	89 c3                	mov    %eax,%ebx
  8005cb:	83 c4 20             	add    $0x20,%esp
  8005ce:	85 c0                	test   %eax,%eax
  8005d0:	78 33                	js     800605 <dup+0xcd>
		goto err;

	return newfdnum;
  8005d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005d5:	89 d8                	mov    %ebx,%eax
  8005d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005da:	5b                   	pop    %ebx
  8005db:	5e                   	pop    %esi
  8005dc:	5f                   	pop    %edi
  8005dd:	5d                   	pop    %ebp
  8005de:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005df:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e6:	83 ec 0c             	sub    $0xc,%esp
  8005e9:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ee:	50                   	push   %eax
  8005ef:	ff 75 d4             	push   -0x2c(%ebp)
  8005f2:	6a 00                	push   $0x0
  8005f4:	53                   	push   %ebx
  8005f5:	6a 00                	push   $0x0
  8005f7:	e8 9d fb ff ff       	call   800199 <sys_page_map>
  8005fc:	89 c3                	mov    %eax,%ebx
  8005fe:	83 c4 20             	add    $0x20,%esp
  800601:	85 c0                	test   %eax,%eax
  800603:	79 a4                	jns    8005a9 <dup+0x71>
	sys_page_unmap(0, newfd);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	56                   	push   %esi
  800609:	6a 00                	push   $0x0
  80060b:	e8 cb fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  800610:	83 c4 08             	add    $0x8,%esp
  800613:	ff 75 d4             	push   -0x2c(%ebp)
  800616:	6a 00                	push   $0x0
  800618:	e8 be fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	eb b3                	jmp    8005d5 <dup+0x9d>

00800622 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800622:	55                   	push   %ebp
  800623:	89 e5                	mov    %esp,%ebp
  800625:	56                   	push   %esi
  800626:	53                   	push   %ebx
  800627:	83 ec 18             	sub    $0x18,%esp
  80062a:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80062d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800630:	50                   	push   %eax
  800631:	56                   	push   %esi
  800632:	e8 87 fd ff ff       	call   8003be <fd_lookup>
  800637:	83 c4 10             	add    $0x10,%esp
  80063a:	85 c0                	test   %eax,%eax
  80063c:	78 3c                	js     80067a <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80063e:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800647:	50                   	push   %eax
  800648:	ff 33                	push   (%ebx)
  80064a:	e8 bf fd ff ff       	call   80040e <dev_lookup>
  80064f:	83 c4 10             	add    $0x10,%esp
  800652:	85 c0                	test   %eax,%eax
  800654:	78 24                	js     80067a <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800656:	8b 43 08             	mov    0x8(%ebx),%eax
  800659:	83 e0 03             	and    $0x3,%eax
  80065c:	83 f8 01             	cmp    $0x1,%eax
  80065f:	74 20                	je     800681 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800661:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800664:	8b 40 08             	mov    0x8(%eax),%eax
  800667:	85 c0                	test   %eax,%eax
  800669:	74 37                	je     8006a2 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80066b:	83 ec 04             	sub    $0x4,%esp
  80066e:	ff 75 10             	push   0x10(%ebp)
  800671:	ff 75 0c             	push   0xc(%ebp)
  800674:	53                   	push   %ebx
  800675:	ff d0                	call   *%eax
  800677:	83 c4 10             	add    $0x10,%esp
}
  80067a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80067d:	5b                   	pop    %ebx
  80067e:	5e                   	pop    %esi
  80067f:	5d                   	pop    %ebp
  800680:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800681:	a1 00 40 80 00       	mov    0x804000,%eax
  800686:	8b 40 48             	mov    0x48(%eax),%eax
  800689:	83 ec 04             	sub    $0x4,%esp
  80068c:	56                   	push   %esi
  80068d:	50                   	push   %eax
  80068e:	68 d9 1d 80 00       	push   $0x801dd9
  800693:	e8 2b 0a 00 00       	call   8010c3 <cprintf>
		return -E_INVAL;
  800698:	83 c4 10             	add    $0x10,%esp
  80069b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006a0:	eb d8                	jmp    80067a <read+0x58>
		return -E_NOT_SUPP;
  8006a2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006a7:	eb d1                	jmp    80067a <read+0x58>

008006a9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006a9:	55                   	push   %ebp
  8006aa:	89 e5                	mov    %esp,%ebp
  8006ac:	57                   	push   %edi
  8006ad:	56                   	push   %esi
  8006ae:	53                   	push   %ebx
  8006af:	83 ec 0c             	sub    $0xc,%esp
  8006b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006bd:	eb 02                	jmp    8006c1 <readn+0x18>
  8006bf:	01 c3                	add    %eax,%ebx
  8006c1:	39 f3                	cmp    %esi,%ebx
  8006c3:	73 21                	jae    8006e6 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006c5:	83 ec 04             	sub    $0x4,%esp
  8006c8:	89 f0                	mov    %esi,%eax
  8006ca:	29 d8                	sub    %ebx,%eax
  8006cc:	50                   	push   %eax
  8006cd:	89 d8                	mov    %ebx,%eax
  8006cf:	03 45 0c             	add    0xc(%ebp),%eax
  8006d2:	50                   	push   %eax
  8006d3:	57                   	push   %edi
  8006d4:	e8 49 ff ff ff       	call   800622 <read>
		if (m < 0)
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	85 c0                	test   %eax,%eax
  8006de:	78 04                	js     8006e4 <readn+0x3b>
			return m;
		if (m == 0)
  8006e0:	75 dd                	jne    8006bf <readn+0x16>
  8006e2:	eb 02                	jmp    8006e6 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e4:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006e6:	89 d8                	mov    %ebx,%eax
  8006e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006eb:	5b                   	pop    %ebx
  8006ec:	5e                   	pop    %esi
  8006ed:	5f                   	pop    %edi
  8006ee:	5d                   	pop    %ebp
  8006ef:	c3                   	ret    

008006f0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	56                   	push   %esi
  8006f4:	53                   	push   %ebx
  8006f5:	83 ec 18             	sub    $0x18,%esp
  8006f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006fe:	50                   	push   %eax
  8006ff:	53                   	push   %ebx
  800700:	e8 b9 fc ff ff       	call   8003be <fd_lookup>
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	85 c0                	test   %eax,%eax
  80070a:	78 37                	js     800743 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80070c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80070f:	83 ec 08             	sub    $0x8,%esp
  800712:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800715:	50                   	push   %eax
  800716:	ff 36                	push   (%esi)
  800718:	e8 f1 fc ff ff       	call   80040e <dev_lookup>
  80071d:	83 c4 10             	add    $0x10,%esp
  800720:	85 c0                	test   %eax,%eax
  800722:	78 1f                	js     800743 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800724:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800728:	74 20                	je     80074a <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80072a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072d:	8b 40 0c             	mov    0xc(%eax),%eax
  800730:	85 c0                	test   %eax,%eax
  800732:	74 37                	je     80076b <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800734:	83 ec 04             	sub    $0x4,%esp
  800737:	ff 75 10             	push   0x10(%ebp)
  80073a:	ff 75 0c             	push   0xc(%ebp)
  80073d:	56                   	push   %esi
  80073e:	ff d0                	call   *%eax
  800740:	83 c4 10             	add    $0x10,%esp
}
  800743:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800746:	5b                   	pop    %ebx
  800747:	5e                   	pop    %esi
  800748:	5d                   	pop    %ebp
  800749:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074a:	a1 00 40 80 00       	mov    0x804000,%eax
  80074f:	8b 40 48             	mov    0x48(%eax),%eax
  800752:	83 ec 04             	sub    $0x4,%esp
  800755:	53                   	push   %ebx
  800756:	50                   	push   %eax
  800757:	68 f5 1d 80 00       	push   $0x801df5
  80075c:	e8 62 09 00 00       	call   8010c3 <cprintf>
		return -E_INVAL;
  800761:	83 c4 10             	add    $0x10,%esp
  800764:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800769:	eb d8                	jmp    800743 <write+0x53>
		return -E_NOT_SUPP;
  80076b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800770:	eb d1                	jmp    800743 <write+0x53>

00800772 <seek>:

int
seek(int fdnum, off_t offset)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800778:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80077b:	50                   	push   %eax
  80077c:	ff 75 08             	push   0x8(%ebp)
  80077f:	e8 3a fc ff ff       	call   8003be <fd_lookup>
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	85 c0                	test   %eax,%eax
  800789:	78 0e                	js     800799 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80078b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800791:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800794:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800799:	c9                   	leave  
  80079a:	c3                   	ret    

0080079b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	56                   	push   %esi
  80079f:	53                   	push   %ebx
  8007a0:	83 ec 18             	sub    $0x18,%esp
  8007a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007a9:	50                   	push   %eax
  8007aa:	53                   	push   %ebx
  8007ab:	e8 0e fc ff ff       	call   8003be <fd_lookup>
  8007b0:	83 c4 10             	add    $0x10,%esp
  8007b3:	85 c0                	test   %eax,%eax
  8007b5:	78 34                	js     8007eb <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b7:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8007ba:	83 ec 08             	sub    $0x8,%esp
  8007bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c0:	50                   	push   %eax
  8007c1:	ff 36                	push   (%esi)
  8007c3:	e8 46 fc ff ff       	call   80040e <dev_lookup>
  8007c8:	83 c4 10             	add    $0x10,%esp
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	78 1c                	js     8007eb <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007cf:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8007d3:	74 1d                	je     8007f2 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d8:	8b 40 18             	mov    0x18(%eax),%eax
  8007db:	85 c0                	test   %eax,%eax
  8007dd:	74 34                	je     800813 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	ff 75 0c             	push   0xc(%ebp)
  8007e5:	56                   	push   %esi
  8007e6:	ff d0                	call   *%eax
  8007e8:	83 c4 10             	add    $0x10,%esp
}
  8007eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007f2:	a1 00 40 80 00       	mov    0x804000,%eax
  8007f7:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007fa:	83 ec 04             	sub    $0x4,%esp
  8007fd:	53                   	push   %ebx
  8007fe:	50                   	push   %eax
  8007ff:	68 b8 1d 80 00       	push   $0x801db8
  800804:	e8 ba 08 00 00       	call   8010c3 <cprintf>
		return -E_INVAL;
  800809:	83 c4 10             	add    $0x10,%esp
  80080c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800811:	eb d8                	jmp    8007eb <ftruncate+0x50>
		return -E_NOT_SUPP;
  800813:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800818:	eb d1                	jmp    8007eb <ftruncate+0x50>

0080081a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	83 ec 18             	sub    $0x18,%esp
  800822:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800825:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800828:	50                   	push   %eax
  800829:	ff 75 08             	push   0x8(%ebp)
  80082c:	e8 8d fb ff ff       	call   8003be <fd_lookup>
  800831:	83 c4 10             	add    $0x10,%esp
  800834:	85 c0                	test   %eax,%eax
  800836:	78 49                	js     800881 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800838:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80083b:	83 ec 08             	sub    $0x8,%esp
  80083e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800841:	50                   	push   %eax
  800842:	ff 36                	push   (%esi)
  800844:	e8 c5 fb ff ff       	call   80040e <dev_lookup>
  800849:	83 c4 10             	add    $0x10,%esp
  80084c:	85 c0                	test   %eax,%eax
  80084e:	78 31                	js     800881 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  800850:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800853:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800857:	74 2f                	je     800888 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800859:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80085c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800863:	00 00 00 
	stat->st_isdir = 0;
  800866:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80086d:	00 00 00 
	stat->st_dev = dev;
  800870:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800876:	83 ec 08             	sub    $0x8,%esp
  800879:	53                   	push   %ebx
  80087a:	56                   	push   %esi
  80087b:	ff 50 14             	call   *0x14(%eax)
  80087e:	83 c4 10             	add    $0x10,%esp
}
  800881:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800884:	5b                   	pop    %ebx
  800885:	5e                   	pop    %esi
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    
		return -E_NOT_SUPP;
  800888:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80088d:	eb f2                	jmp    800881 <fstat+0x67>

0080088f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	56                   	push   %esi
  800893:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800894:	83 ec 08             	sub    $0x8,%esp
  800897:	6a 00                	push   $0x0
  800899:	ff 75 08             	push   0x8(%ebp)
  80089c:	e8 e4 01 00 00       	call   800a85 <open>
  8008a1:	89 c3                	mov    %eax,%ebx
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	85 c0                	test   %eax,%eax
  8008a8:	78 1b                	js     8008c5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008aa:	83 ec 08             	sub    $0x8,%esp
  8008ad:	ff 75 0c             	push   0xc(%ebp)
  8008b0:	50                   	push   %eax
  8008b1:	e8 64 ff ff ff       	call   80081a <fstat>
  8008b6:	89 c6                	mov    %eax,%esi
	close(fd);
  8008b8:	89 1c 24             	mov    %ebx,(%esp)
  8008bb:	e8 26 fc ff ff       	call   8004e6 <close>
	return r;
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	89 f3                	mov    %esi,%ebx
}
  8008c5:	89 d8                	mov    %ebx,%eax
  8008c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	56                   	push   %esi
  8008d2:	53                   	push   %ebx
  8008d3:	89 c6                	mov    %eax,%esi
  8008d5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008d7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8008de:	74 27                	je     800907 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008e0:	6a 07                	push   $0x7
  8008e2:	68 00 50 80 00       	push   $0x805000
  8008e7:	56                   	push   %esi
  8008e8:	ff 35 00 60 80 00    	push   0x806000
  8008ee:	e8 51 11 00 00       	call   801a44 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008f3:	83 c4 0c             	add    $0xc,%esp
  8008f6:	6a 00                	push   $0x0
  8008f8:	53                   	push   %ebx
  8008f9:	6a 00                	push   $0x0
  8008fb:	e8 dd 10 00 00       	call   8019dd <ipc_recv>
}
  800900:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800903:	5b                   	pop    %ebx
  800904:	5e                   	pop    %esi
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800907:	83 ec 0c             	sub    $0xc,%esp
  80090a:	6a 01                	push   $0x1
  80090c:	e8 87 11 00 00       	call   801a98 <ipc_find_env>
  800911:	a3 00 60 80 00       	mov    %eax,0x806000
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	eb c5                	jmp    8008e0 <fsipc+0x12>

0080091b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	8b 40 0c             	mov    0xc(%eax),%eax
  800927:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80092c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800934:	ba 00 00 00 00       	mov    $0x0,%edx
  800939:	b8 02 00 00 00       	mov    $0x2,%eax
  80093e:	e8 8b ff ff ff       	call   8008ce <fsipc>
}
  800943:	c9                   	leave  
  800944:	c3                   	ret    

00800945 <devfile_flush>:
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 40 0c             	mov    0xc(%eax),%eax
  800951:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800956:	ba 00 00 00 00       	mov    $0x0,%edx
  80095b:	b8 06 00 00 00       	mov    $0x6,%eax
  800960:	e8 69 ff ff ff       	call   8008ce <fsipc>
}
  800965:	c9                   	leave  
  800966:	c3                   	ret    

00800967 <devfile_stat>:
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	53                   	push   %ebx
  80096b:	83 ec 04             	sub    $0x4,%esp
  80096e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	8b 40 0c             	mov    0xc(%eax),%eax
  800977:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80097c:	ba 00 00 00 00       	mov    $0x0,%edx
  800981:	b8 05 00 00 00       	mov    $0x5,%eax
  800986:	e8 43 ff ff ff       	call   8008ce <fsipc>
  80098b:	85 c0                	test   %eax,%eax
  80098d:	78 2c                	js     8009bb <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80098f:	83 ec 08             	sub    $0x8,%esp
  800992:	68 00 50 80 00       	push   $0x805000
  800997:	53                   	push   %ebx
  800998:	e8 00 0d 00 00       	call   80169d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80099d:	a1 80 50 80 00       	mov    0x805080,%eax
  8009a2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009a8:	a1 84 50 80 00       	mov    0x805084,%eax
  8009ad:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009b3:	83 c4 10             	add    $0x10,%esp
  8009b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    

008009c0 <devfile_write>:
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	83 ec 0c             	sub    $0xc,%esp
  8009c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009ce:	39 d0                	cmp    %edx,%eax
  8009d0:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d6:	8b 52 0c             	mov    0xc(%edx),%edx
  8009d9:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009df:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8009e4:	50                   	push   %eax
  8009e5:	ff 75 0c             	push   0xc(%ebp)
  8009e8:	68 08 50 80 00       	push   $0x805008
  8009ed:	e8 41 0e 00 00       	call   801833 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8009f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f7:	b8 04 00 00 00       	mov    $0x4,%eax
  8009fc:	e8 cd fe ff ff       	call   8008ce <fsipc>
}
  800a01:	c9                   	leave  
  800a02:	c3                   	ret    

00800a03 <devfile_read>:
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	56                   	push   %esi
  800a07:	53                   	push   %ebx
  800a08:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a11:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a16:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a21:	b8 03 00 00 00       	mov    $0x3,%eax
  800a26:	e8 a3 fe ff ff       	call   8008ce <fsipc>
  800a2b:	89 c3                	mov    %eax,%ebx
  800a2d:	85 c0                	test   %eax,%eax
  800a2f:	78 1f                	js     800a50 <devfile_read+0x4d>
	assert(r <= n);
  800a31:	39 f0                	cmp    %esi,%eax
  800a33:	77 24                	ja     800a59 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a35:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a3a:	7f 33                	jg     800a6f <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a3c:	83 ec 04             	sub    $0x4,%esp
  800a3f:	50                   	push   %eax
  800a40:	68 00 50 80 00       	push   $0x805000
  800a45:	ff 75 0c             	push   0xc(%ebp)
  800a48:	e8 e6 0d 00 00       	call   801833 <memmove>
	return r;
  800a4d:	83 c4 10             	add    $0x10,%esp
}
  800a50:	89 d8                	mov    %ebx,%eax
  800a52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a55:	5b                   	pop    %ebx
  800a56:	5e                   	pop    %esi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    
	assert(r <= n);
  800a59:	68 24 1e 80 00       	push   $0x801e24
  800a5e:	68 2b 1e 80 00       	push   $0x801e2b
  800a63:	6a 7c                	push   $0x7c
  800a65:	68 40 1e 80 00       	push   $0x801e40
  800a6a:	e8 79 05 00 00       	call   800fe8 <_panic>
	assert(r <= PGSIZE);
  800a6f:	68 4b 1e 80 00       	push   $0x801e4b
  800a74:	68 2b 1e 80 00       	push   $0x801e2b
  800a79:	6a 7d                	push   $0x7d
  800a7b:	68 40 1e 80 00       	push   $0x801e40
  800a80:	e8 63 05 00 00       	call   800fe8 <_panic>

00800a85 <open>:
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
  800a8a:	83 ec 1c             	sub    $0x1c,%esp
  800a8d:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800a90:	56                   	push   %esi
  800a91:	e8 cc 0b 00 00       	call   801662 <strlen>
  800a96:	83 c4 10             	add    $0x10,%esp
  800a99:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a9e:	7f 6c                	jg     800b0c <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800aa0:	83 ec 0c             	sub    $0xc,%esp
  800aa3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aa6:	50                   	push   %eax
  800aa7:	e8 c2 f8 ff ff       	call   80036e <fd_alloc>
  800aac:	89 c3                	mov    %eax,%ebx
  800aae:	83 c4 10             	add    $0x10,%esp
  800ab1:	85 c0                	test   %eax,%eax
  800ab3:	78 3c                	js     800af1 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800ab5:	83 ec 08             	sub    $0x8,%esp
  800ab8:	56                   	push   %esi
  800ab9:	68 00 50 80 00       	push   $0x805000
  800abe:	e8 da 0b 00 00       	call   80169d <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac6:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800acb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ace:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad3:	e8 f6 fd ff ff       	call   8008ce <fsipc>
  800ad8:	89 c3                	mov    %eax,%ebx
  800ada:	83 c4 10             	add    $0x10,%esp
  800add:	85 c0                	test   %eax,%eax
  800adf:	78 19                	js     800afa <open+0x75>
	return fd2num(fd);
  800ae1:	83 ec 0c             	sub    $0xc,%esp
  800ae4:	ff 75 f4             	push   -0xc(%ebp)
  800ae7:	e8 5b f8 ff ff       	call   800347 <fd2num>
  800aec:	89 c3                	mov    %eax,%ebx
  800aee:	83 c4 10             	add    $0x10,%esp
}
  800af1:	89 d8                	mov    %ebx,%eax
  800af3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    
		fd_close(fd, 0);
  800afa:	83 ec 08             	sub    $0x8,%esp
  800afd:	6a 00                	push   $0x0
  800aff:	ff 75 f4             	push   -0xc(%ebp)
  800b02:	e8 58 f9 ff ff       	call   80045f <fd_close>
		return r;
  800b07:	83 c4 10             	add    $0x10,%esp
  800b0a:	eb e5                	jmp    800af1 <open+0x6c>
		return -E_BAD_PATH;
  800b0c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b11:	eb de                	jmp    800af1 <open+0x6c>

00800b13 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b19:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b23:	e8 a6 fd ff ff       	call   8008ce <fsipc>
}
  800b28:	c9                   	leave  
  800b29:	c3                   	ret    

00800b2a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
  800b2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b32:	83 ec 0c             	sub    $0xc,%esp
  800b35:	ff 75 08             	push   0x8(%ebp)
  800b38:	e8 1a f8 ff ff       	call   800357 <fd2data>
  800b3d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b3f:	83 c4 08             	add    $0x8,%esp
  800b42:	68 57 1e 80 00       	push   $0x801e57
  800b47:	53                   	push   %ebx
  800b48:	e8 50 0b 00 00       	call   80169d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b4d:	8b 46 04             	mov    0x4(%esi),%eax
  800b50:	2b 06                	sub    (%esi),%eax
  800b52:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b58:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b5f:	00 00 00 
	stat->st_dev = &devpipe;
  800b62:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b69:	30 80 00 
	return 0;
}
  800b6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	53                   	push   %ebx
  800b7c:	83 ec 0c             	sub    $0xc,%esp
  800b7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b82:	53                   	push   %ebx
  800b83:	6a 00                	push   $0x0
  800b85:	e8 51 f6 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b8a:	89 1c 24             	mov    %ebx,(%esp)
  800b8d:	e8 c5 f7 ff ff       	call   800357 <fd2data>
  800b92:	83 c4 08             	add    $0x8,%esp
  800b95:	50                   	push   %eax
  800b96:	6a 00                	push   $0x0
  800b98:	e8 3e f6 ff ff       	call   8001db <sys_page_unmap>
}
  800b9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba0:	c9                   	leave  
  800ba1:	c3                   	ret    

00800ba2 <_pipeisclosed>:
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 1c             	sub    $0x1c,%esp
  800bab:	89 c7                	mov    %eax,%edi
  800bad:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800baf:	a1 00 40 80 00       	mov    0x804000,%eax
  800bb4:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	57                   	push   %edi
  800bbb:	e8 11 0f 00 00       	call   801ad1 <pageref>
  800bc0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bc3:	89 34 24             	mov    %esi,(%esp)
  800bc6:	e8 06 0f 00 00       	call   801ad1 <pageref>
		nn = thisenv->env_runs;
  800bcb:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800bd1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bd4:	83 c4 10             	add    $0x10,%esp
  800bd7:	39 cb                	cmp    %ecx,%ebx
  800bd9:	74 1b                	je     800bf6 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800bdb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800bde:	75 cf                	jne    800baf <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800be0:	8b 42 58             	mov    0x58(%edx),%eax
  800be3:	6a 01                	push   $0x1
  800be5:	50                   	push   %eax
  800be6:	53                   	push   %ebx
  800be7:	68 5e 1e 80 00       	push   $0x801e5e
  800bec:	e8 d2 04 00 00       	call   8010c3 <cprintf>
  800bf1:	83 c4 10             	add    $0x10,%esp
  800bf4:	eb b9                	jmp    800baf <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800bf6:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800bf9:	0f 94 c0             	sete   %al
  800bfc:	0f b6 c0             	movzbl %al,%eax
}
  800bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <devpipe_write>:
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 28             	sub    $0x28,%esp
  800c10:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c13:	56                   	push   %esi
  800c14:	e8 3e f7 ff ff       	call   800357 <fd2data>
  800c19:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c1b:	83 c4 10             	add    $0x10,%esp
  800c1e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c23:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c26:	75 09                	jne    800c31 <devpipe_write+0x2a>
	return i;
  800c28:	89 f8                	mov    %edi,%eax
  800c2a:	eb 23                	jmp    800c4f <devpipe_write+0x48>
			sys_yield();
  800c2c:	e8 06 f5 ff ff       	call   800137 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c31:	8b 43 04             	mov    0x4(%ebx),%eax
  800c34:	8b 0b                	mov    (%ebx),%ecx
  800c36:	8d 51 20             	lea    0x20(%ecx),%edx
  800c39:	39 d0                	cmp    %edx,%eax
  800c3b:	72 1a                	jb     800c57 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  800c3d:	89 da                	mov    %ebx,%edx
  800c3f:	89 f0                	mov    %esi,%eax
  800c41:	e8 5c ff ff ff       	call   800ba2 <_pipeisclosed>
  800c46:	85 c0                	test   %eax,%eax
  800c48:	74 e2                	je     800c2c <devpipe_write+0x25>
				return 0;
  800c4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c5e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c61:	89 c2                	mov    %eax,%edx
  800c63:	c1 fa 1f             	sar    $0x1f,%edx
  800c66:	89 d1                	mov    %edx,%ecx
  800c68:	c1 e9 1b             	shr    $0x1b,%ecx
  800c6b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c6e:	83 e2 1f             	and    $0x1f,%edx
  800c71:	29 ca                	sub    %ecx,%edx
  800c73:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c77:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c7b:	83 c0 01             	add    $0x1,%eax
  800c7e:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c81:	83 c7 01             	add    $0x1,%edi
  800c84:	eb 9d                	jmp    800c23 <devpipe_write+0x1c>

00800c86 <devpipe_read>:
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 18             	sub    $0x18,%esp
  800c8f:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800c92:	57                   	push   %edi
  800c93:	e8 bf f6 ff ff       	call   800357 <fd2data>
  800c98:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c9a:	83 c4 10             	add    $0x10,%esp
  800c9d:	be 00 00 00 00       	mov    $0x0,%esi
  800ca2:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ca5:	75 13                	jne    800cba <devpipe_read+0x34>
	return i;
  800ca7:	89 f0                	mov    %esi,%eax
  800ca9:	eb 02                	jmp    800cad <devpipe_read+0x27>
				return i;
  800cab:	89 f0                	mov    %esi,%eax
}
  800cad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    
			sys_yield();
  800cb5:	e8 7d f4 ff ff       	call   800137 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800cba:	8b 03                	mov    (%ebx),%eax
  800cbc:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cbf:	75 18                	jne    800cd9 <devpipe_read+0x53>
			if (i > 0)
  800cc1:	85 f6                	test   %esi,%esi
  800cc3:	75 e6                	jne    800cab <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  800cc5:	89 da                	mov    %ebx,%edx
  800cc7:	89 f8                	mov    %edi,%eax
  800cc9:	e8 d4 fe ff ff       	call   800ba2 <_pipeisclosed>
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	74 e3                	je     800cb5 <devpipe_read+0x2f>
				return 0;
  800cd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd7:	eb d4                	jmp    800cad <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cd9:	99                   	cltd   
  800cda:	c1 ea 1b             	shr    $0x1b,%edx
  800cdd:	01 d0                	add    %edx,%eax
  800cdf:	83 e0 1f             	and    $0x1f,%eax
  800ce2:	29 d0                	sub    %edx,%eax
  800ce4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800ce9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cec:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800cef:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800cf2:	83 c6 01             	add    $0x1,%esi
  800cf5:	eb ab                	jmp    800ca2 <devpipe_read+0x1c>

00800cf7 <pipe>:
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
  800cfc:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800cff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d02:	50                   	push   %eax
  800d03:	e8 66 f6 ff ff       	call   80036e <fd_alloc>
  800d08:	89 c3                	mov    %eax,%ebx
  800d0a:	83 c4 10             	add    $0x10,%esp
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	0f 88 23 01 00 00    	js     800e38 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d15:	83 ec 04             	sub    $0x4,%esp
  800d18:	68 07 04 00 00       	push   $0x407
  800d1d:	ff 75 f4             	push   -0xc(%ebp)
  800d20:	6a 00                	push   $0x0
  800d22:	e8 2f f4 ff ff       	call   800156 <sys_page_alloc>
  800d27:	89 c3                	mov    %eax,%ebx
  800d29:	83 c4 10             	add    $0x10,%esp
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	0f 88 04 01 00 00    	js     800e38 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  800d34:	83 ec 0c             	sub    $0xc,%esp
  800d37:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d3a:	50                   	push   %eax
  800d3b:	e8 2e f6 ff ff       	call   80036e <fd_alloc>
  800d40:	89 c3                	mov    %eax,%ebx
  800d42:	83 c4 10             	add    $0x10,%esp
  800d45:	85 c0                	test   %eax,%eax
  800d47:	0f 88 db 00 00 00    	js     800e28 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d4d:	83 ec 04             	sub    $0x4,%esp
  800d50:	68 07 04 00 00       	push   $0x407
  800d55:	ff 75 f0             	push   -0x10(%ebp)
  800d58:	6a 00                	push   $0x0
  800d5a:	e8 f7 f3 ff ff       	call   800156 <sys_page_alloc>
  800d5f:	89 c3                	mov    %eax,%ebx
  800d61:	83 c4 10             	add    $0x10,%esp
  800d64:	85 c0                	test   %eax,%eax
  800d66:	0f 88 bc 00 00 00    	js     800e28 <pipe+0x131>
	va = fd2data(fd0);
  800d6c:	83 ec 0c             	sub    $0xc,%esp
  800d6f:	ff 75 f4             	push   -0xc(%ebp)
  800d72:	e8 e0 f5 ff ff       	call   800357 <fd2data>
  800d77:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d79:	83 c4 0c             	add    $0xc,%esp
  800d7c:	68 07 04 00 00       	push   $0x407
  800d81:	50                   	push   %eax
  800d82:	6a 00                	push   $0x0
  800d84:	e8 cd f3 ff ff       	call   800156 <sys_page_alloc>
  800d89:	89 c3                	mov    %eax,%ebx
  800d8b:	83 c4 10             	add    $0x10,%esp
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	0f 88 82 00 00 00    	js     800e18 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d96:	83 ec 0c             	sub    $0xc,%esp
  800d99:	ff 75 f0             	push   -0x10(%ebp)
  800d9c:	e8 b6 f5 ff ff       	call   800357 <fd2data>
  800da1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800da8:	50                   	push   %eax
  800da9:	6a 00                	push   $0x0
  800dab:	56                   	push   %esi
  800dac:	6a 00                	push   $0x0
  800dae:	e8 e6 f3 ff ff       	call   800199 <sys_page_map>
  800db3:	89 c3                	mov    %eax,%ebx
  800db5:	83 c4 20             	add    $0x20,%esp
  800db8:	85 c0                	test   %eax,%eax
  800dba:	78 4e                	js     800e0a <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  800dbc:	a1 20 30 80 00       	mov    0x803020,%eax
  800dc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dc4:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800dc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dc9:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800dd0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dd3:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800dd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dd8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800ddf:	83 ec 0c             	sub    $0xc,%esp
  800de2:	ff 75 f4             	push   -0xc(%ebp)
  800de5:	e8 5d f5 ff ff       	call   800347 <fd2num>
  800dea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ded:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800def:	83 c4 04             	add    $0x4,%esp
  800df2:	ff 75 f0             	push   -0x10(%ebp)
  800df5:	e8 4d f5 ff ff       	call   800347 <fd2num>
  800dfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfd:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e00:	83 c4 10             	add    $0x10,%esp
  800e03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e08:	eb 2e                	jmp    800e38 <pipe+0x141>
	sys_page_unmap(0, va);
  800e0a:	83 ec 08             	sub    $0x8,%esp
  800e0d:	56                   	push   %esi
  800e0e:	6a 00                	push   $0x0
  800e10:	e8 c6 f3 ff ff       	call   8001db <sys_page_unmap>
  800e15:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e18:	83 ec 08             	sub    $0x8,%esp
  800e1b:	ff 75 f0             	push   -0x10(%ebp)
  800e1e:	6a 00                	push   $0x0
  800e20:	e8 b6 f3 ff ff       	call   8001db <sys_page_unmap>
  800e25:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e28:	83 ec 08             	sub    $0x8,%esp
  800e2b:	ff 75 f4             	push   -0xc(%ebp)
  800e2e:	6a 00                	push   $0x0
  800e30:	e8 a6 f3 ff ff       	call   8001db <sys_page_unmap>
  800e35:	83 c4 10             	add    $0x10,%esp
}
  800e38:	89 d8                	mov    %ebx,%eax
  800e3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <pipeisclosed>:
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e47:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e4a:	50                   	push   %eax
  800e4b:	ff 75 08             	push   0x8(%ebp)
  800e4e:	e8 6b f5 ff ff       	call   8003be <fd_lookup>
  800e53:	83 c4 10             	add    $0x10,%esp
  800e56:	85 c0                	test   %eax,%eax
  800e58:	78 18                	js     800e72 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e5a:	83 ec 0c             	sub    $0xc,%esp
  800e5d:	ff 75 f4             	push   -0xc(%ebp)
  800e60:	e8 f2 f4 ff ff       	call   800357 <fd2data>
  800e65:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e6a:	e8 33 fd ff ff       	call   800ba2 <_pipeisclosed>
  800e6f:	83 c4 10             	add    $0x10,%esp
}
  800e72:	c9                   	leave  
  800e73:	c3                   	ret    

00800e74 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  800e74:	b8 00 00 00 00       	mov    $0x0,%eax
  800e79:	c3                   	ret    

00800e7a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e80:	68 76 1e 80 00       	push   $0x801e76
  800e85:	ff 75 0c             	push   0xc(%ebp)
  800e88:	e8 10 08 00 00       	call   80169d <strcpy>
	return 0;
}
  800e8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e92:	c9                   	leave  
  800e93:	c3                   	ret    

00800e94 <devcons_write>:
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	57                   	push   %edi
  800e98:	56                   	push   %esi
  800e99:	53                   	push   %ebx
  800e9a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ea0:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ea5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800eab:	eb 2e                	jmp    800edb <devcons_write+0x47>
		m = n - tot;
  800ead:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb0:	29 f3                	sub    %esi,%ebx
  800eb2:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800eb7:	39 c3                	cmp    %eax,%ebx
  800eb9:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ebc:	83 ec 04             	sub    $0x4,%esp
  800ebf:	53                   	push   %ebx
  800ec0:	89 f0                	mov    %esi,%eax
  800ec2:	03 45 0c             	add    0xc(%ebp),%eax
  800ec5:	50                   	push   %eax
  800ec6:	57                   	push   %edi
  800ec7:	e8 67 09 00 00       	call   801833 <memmove>
		sys_cputs(buf, m);
  800ecc:	83 c4 08             	add    $0x8,%esp
  800ecf:	53                   	push   %ebx
  800ed0:	57                   	push   %edi
  800ed1:	e8 c4 f1 ff ff       	call   80009a <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800ed6:	01 de                	add    %ebx,%esi
  800ed8:	83 c4 10             	add    $0x10,%esp
  800edb:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ede:	72 cd                	jb     800ead <devcons_write+0x19>
}
  800ee0:	89 f0                	mov    %esi,%eax
  800ee2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee5:	5b                   	pop    %ebx
  800ee6:	5e                   	pop    %esi
  800ee7:	5f                   	pop    %edi
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    

00800eea <devcons_read>:
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	83 ec 08             	sub    $0x8,%esp
  800ef0:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800ef5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ef9:	75 07                	jne    800f02 <devcons_read+0x18>
  800efb:	eb 1f                	jmp    800f1c <devcons_read+0x32>
		sys_yield();
  800efd:	e8 35 f2 ff ff       	call   800137 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f02:	e8 b1 f1 ff ff       	call   8000b8 <sys_cgetc>
  800f07:	85 c0                	test   %eax,%eax
  800f09:	74 f2                	je     800efd <devcons_read+0x13>
	if (c < 0)
  800f0b:	78 0f                	js     800f1c <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  800f0d:	83 f8 04             	cmp    $0x4,%eax
  800f10:	74 0c                	je     800f1e <devcons_read+0x34>
	*(char*)vbuf = c;
  800f12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f15:	88 02                	mov    %al,(%edx)
	return 1;
  800f17:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f1c:	c9                   	leave  
  800f1d:	c3                   	ret    
		return 0;
  800f1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f23:	eb f7                	jmp    800f1c <devcons_read+0x32>

00800f25 <cputchar>:
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f31:	6a 01                	push   $0x1
  800f33:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f36:	50                   	push   %eax
  800f37:	e8 5e f1 ff ff       	call   80009a <sys_cputs>
}
  800f3c:	83 c4 10             	add    $0x10,%esp
  800f3f:	c9                   	leave  
  800f40:	c3                   	ret    

00800f41 <getchar>:
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f47:	6a 01                	push   $0x1
  800f49:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f4c:	50                   	push   %eax
  800f4d:	6a 00                	push   $0x0
  800f4f:	e8 ce f6 ff ff       	call   800622 <read>
	if (r < 0)
  800f54:	83 c4 10             	add    $0x10,%esp
  800f57:	85 c0                	test   %eax,%eax
  800f59:	78 06                	js     800f61 <getchar+0x20>
	if (r < 1)
  800f5b:	74 06                	je     800f63 <getchar+0x22>
	return c;
  800f5d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    
		return -E_EOF;
  800f63:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800f68:	eb f7                	jmp    800f61 <getchar+0x20>

00800f6a <iscons>:
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f73:	50                   	push   %eax
  800f74:	ff 75 08             	push   0x8(%ebp)
  800f77:	e8 42 f4 ff ff       	call   8003be <fd_lookup>
  800f7c:	83 c4 10             	add    $0x10,%esp
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	78 11                	js     800f94 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f86:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f8c:	39 10                	cmp    %edx,(%eax)
  800f8e:	0f 94 c0             	sete   %al
  800f91:	0f b6 c0             	movzbl %al,%eax
}
  800f94:	c9                   	leave  
  800f95:	c3                   	ret    

00800f96 <opencons>:
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800f9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9f:	50                   	push   %eax
  800fa0:	e8 c9 f3 ff ff       	call   80036e <fd_alloc>
  800fa5:	83 c4 10             	add    $0x10,%esp
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	78 3a                	js     800fe6 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fac:	83 ec 04             	sub    $0x4,%esp
  800faf:	68 07 04 00 00       	push   $0x407
  800fb4:	ff 75 f4             	push   -0xc(%ebp)
  800fb7:	6a 00                	push   $0x0
  800fb9:	e8 98 f1 ff ff       	call   800156 <sys_page_alloc>
  800fbe:	83 c4 10             	add    $0x10,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	78 21                	js     800fe6 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fce:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fda:	83 ec 0c             	sub    $0xc,%esp
  800fdd:	50                   	push   %eax
  800fde:	e8 64 f3 ff ff       	call   800347 <fd2num>
  800fe3:	83 c4 10             	add    $0x10,%esp
}
  800fe6:	c9                   	leave  
  800fe7:	c3                   	ret    

00800fe8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	56                   	push   %esi
  800fec:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fed:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ff0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800ff6:	e8 1d f1 ff ff       	call   800118 <sys_getenvid>
  800ffb:	83 ec 0c             	sub    $0xc,%esp
  800ffe:	ff 75 0c             	push   0xc(%ebp)
  801001:	ff 75 08             	push   0x8(%ebp)
  801004:	56                   	push   %esi
  801005:	50                   	push   %eax
  801006:	68 84 1e 80 00       	push   $0x801e84
  80100b:	e8 b3 00 00 00       	call   8010c3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801010:	83 c4 18             	add    $0x18,%esp
  801013:	53                   	push   %ebx
  801014:	ff 75 10             	push   0x10(%ebp)
  801017:	e8 56 00 00 00       	call   801072 <vcprintf>
	cprintf("\n");
  80101c:	c7 04 24 6f 1e 80 00 	movl   $0x801e6f,(%esp)
  801023:	e8 9b 00 00 00       	call   8010c3 <cprintf>
  801028:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80102b:	cc                   	int3   
  80102c:	eb fd                	jmp    80102b <_panic+0x43>

0080102e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	53                   	push   %ebx
  801032:	83 ec 04             	sub    $0x4,%esp
  801035:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801038:	8b 13                	mov    (%ebx),%edx
  80103a:	8d 42 01             	lea    0x1(%edx),%eax
  80103d:	89 03                	mov    %eax,(%ebx)
  80103f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801042:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801046:	3d ff 00 00 00       	cmp    $0xff,%eax
  80104b:	74 09                	je     801056 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80104d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801051:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801054:	c9                   	leave  
  801055:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801056:	83 ec 08             	sub    $0x8,%esp
  801059:	68 ff 00 00 00       	push   $0xff
  80105e:	8d 43 08             	lea    0x8(%ebx),%eax
  801061:	50                   	push   %eax
  801062:	e8 33 f0 ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  801067:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80106d:	83 c4 10             	add    $0x10,%esp
  801070:	eb db                	jmp    80104d <putch+0x1f>

00801072 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80107b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801082:	00 00 00 
	b.cnt = 0;
  801085:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80108c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80108f:	ff 75 0c             	push   0xc(%ebp)
  801092:	ff 75 08             	push   0x8(%ebp)
  801095:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80109b:	50                   	push   %eax
  80109c:	68 2e 10 80 00       	push   $0x80102e
  8010a1:	e8 14 01 00 00       	call   8011ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010a6:	83 c4 08             	add    $0x8,%esp
  8010a9:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8010af:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010b5:	50                   	push   %eax
  8010b6:	e8 df ef ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  8010bb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010c1:	c9                   	leave  
  8010c2:	c3                   	ret    

008010c3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010c9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010cc:	50                   	push   %eax
  8010cd:	ff 75 08             	push   0x8(%ebp)
  8010d0:	e8 9d ff ff ff       	call   801072 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010d5:	c9                   	leave  
  8010d6:	c3                   	ret    

008010d7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	57                   	push   %edi
  8010db:	56                   	push   %esi
  8010dc:	53                   	push   %ebx
  8010dd:	83 ec 1c             	sub    $0x1c,%esp
  8010e0:	89 c7                	mov    %eax,%edi
  8010e2:	89 d6                	mov    %edx,%esi
  8010e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ea:	89 d1                	mov    %edx,%ecx
  8010ec:	89 c2                	mov    %eax,%edx
  8010ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010f1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8010f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8010f7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010fd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801104:	39 c2                	cmp    %eax,%edx
  801106:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801109:	72 3e                	jb     801149 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80110b:	83 ec 0c             	sub    $0xc,%esp
  80110e:	ff 75 18             	push   0x18(%ebp)
  801111:	83 eb 01             	sub    $0x1,%ebx
  801114:	53                   	push   %ebx
  801115:	50                   	push   %eax
  801116:	83 ec 08             	sub    $0x8,%esp
  801119:	ff 75 e4             	push   -0x1c(%ebp)
  80111c:	ff 75 e0             	push   -0x20(%ebp)
  80111f:	ff 75 dc             	push   -0x24(%ebp)
  801122:	ff 75 d8             	push   -0x28(%ebp)
  801125:	e8 e6 09 00 00       	call   801b10 <__udivdi3>
  80112a:	83 c4 18             	add    $0x18,%esp
  80112d:	52                   	push   %edx
  80112e:	50                   	push   %eax
  80112f:	89 f2                	mov    %esi,%edx
  801131:	89 f8                	mov    %edi,%eax
  801133:	e8 9f ff ff ff       	call   8010d7 <printnum>
  801138:	83 c4 20             	add    $0x20,%esp
  80113b:	eb 13                	jmp    801150 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80113d:	83 ec 08             	sub    $0x8,%esp
  801140:	56                   	push   %esi
  801141:	ff 75 18             	push   0x18(%ebp)
  801144:	ff d7                	call   *%edi
  801146:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801149:	83 eb 01             	sub    $0x1,%ebx
  80114c:	85 db                	test   %ebx,%ebx
  80114e:	7f ed                	jg     80113d <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801150:	83 ec 08             	sub    $0x8,%esp
  801153:	56                   	push   %esi
  801154:	83 ec 04             	sub    $0x4,%esp
  801157:	ff 75 e4             	push   -0x1c(%ebp)
  80115a:	ff 75 e0             	push   -0x20(%ebp)
  80115d:	ff 75 dc             	push   -0x24(%ebp)
  801160:	ff 75 d8             	push   -0x28(%ebp)
  801163:	e8 c8 0a 00 00       	call   801c30 <__umoddi3>
  801168:	83 c4 14             	add    $0x14,%esp
  80116b:	0f be 80 a7 1e 80 00 	movsbl 0x801ea7(%eax),%eax
  801172:	50                   	push   %eax
  801173:	ff d7                	call   *%edi
}
  801175:	83 c4 10             	add    $0x10,%esp
  801178:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117b:	5b                   	pop    %ebx
  80117c:	5e                   	pop    %esi
  80117d:	5f                   	pop    %edi
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801186:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80118a:	8b 10                	mov    (%eax),%edx
  80118c:	3b 50 04             	cmp    0x4(%eax),%edx
  80118f:	73 0a                	jae    80119b <sprintputch+0x1b>
		*b->buf++ = ch;
  801191:	8d 4a 01             	lea    0x1(%edx),%ecx
  801194:	89 08                	mov    %ecx,(%eax)
  801196:	8b 45 08             	mov    0x8(%ebp),%eax
  801199:	88 02                	mov    %al,(%edx)
}
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <printfmt>:
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011a3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011a6:	50                   	push   %eax
  8011a7:	ff 75 10             	push   0x10(%ebp)
  8011aa:	ff 75 0c             	push   0xc(%ebp)
  8011ad:	ff 75 08             	push   0x8(%ebp)
  8011b0:	e8 05 00 00 00       	call   8011ba <vprintfmt>
}
  8011b5:	83 c4 10             	add    $0x10,%esp
  8011b8:	c9                   	leave  
  8011b9:	c3                   	ret    

008011ba <vprintfmt>:
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	57                   	push   %edi
  8011be:	56                   	push   %esi
  8011bf:	53                   	push   %ebx
  8011c0:	83 ec 3c             	sub    $0x3c,%esp
  8011c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8011c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011c9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011cc:	eb 0a                	jmp    8011d8 <vprintfmt+0x1e>
			putch(ch, putdat);
  8011ce:	83 ec 08             	sub    $0x8,%esp
  8011d1:	53                   	push   %ebx
  8011d2:	50                   	push   %eax
  8011d3:	ff d6                	call   *%esi
  8011d5:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8011d8:	83 c7 01             	add    $0x1,%edi
  8011db:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8011df:	83 f8 25             	cmp    $0x25,%eax
  8011e2:	74 0c                	je     8011f0 <vprintfmt+0x36>
			if (ch == '\0')
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	75 e6                	jne    8011ce <vprintfmt+0x14>
}
  8011e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011eb:	5b                   	pop    %ebx
  8011ec:	5e                   	pop    %esi
  8011ed:	5f                   	pop    %edi
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    
		padc = ' ';
  8011f0:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8011f4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8011fb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801202:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801209:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80120e:	8d 47 01             	lea    0x1(%edi),%eax
  801211:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801214:	0f b6 17             	movzbl (%edi),%edx
  801217:	8d 42 dd             	lea    -0x23(%edx),%eax
  80121a:	3c 55                	cmp    $0x55,%al
  80121c:	0f 87 bb 03 00 00    	ja     8015dd <vprintfmt+0x423>
  801222:	0f b6 c0             	movzbl %al,%eax
  801225:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  80122c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80122f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801233:	eb d9                	jmp    80120e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801235:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801238:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80123c:	eb d0                	jmp    80120e <vprintfmt+0x54>
  80123e:	0f b6 d2             	movzbl %dl,%edx
  801241:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801244:	b8 00 00 00 00       	mov    $0x0,%eax
  801249:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80124c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80124f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801253:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801256:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801259:	83 f9 09             	cmp    $0x9,%ecx
  80125c:	77 55                	ja     8012b3 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80125e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801261:	eb e9                	jmp    80124c <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801263:	8b 45 14             	mov    0x14(%ebp),%eax
  801266:	8b 00                	mov    (%eax),%eax
  801268:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80126b:	8b 45 14             	mov    0x14(%ebp),%eax
  80126e:	8d 40 04             	lea    0x4(%eax),%eax
  801271:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801274:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801277:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80127b:	79 91                	jns    80120e <vprintfmt+0x54>
				width = precision, precision = -1;
  80127d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801280:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801283:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80128a:	eb 82                	jmp    80120e <vprintfmt+0x54>
  80128c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80128f:	85 d2                	test   %edx,%edx
  801291:	b8 00 00 00 00       	mov    $0x0,%eax
  801296:	0f 49 c2             	cmovns %edx,%eax
  801299:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80129c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80129f:	e9 6a ff ff ff       	jmp    80120e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8012a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012a7:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8012ae:	e9 5b ff ff ff       	jmp    80120e <vprintfmt+0x54>
  8012b3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012b9:	eb bc                	jmp    801277 <vprintfmt+0xbd>
			lflag++;
  8012bb:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012c1:	e9 48 ff ff ff       	jmp    80120e <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8012c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c9:	8d 78 04             	lea    0x4(%eax),%edi
  8012cc:	83 ec 08             	sub    $0x8,%esp
  8012cf:	53                   	push   %ebx
  8012d0:	ff 30                	push   (%eax)
  8012d2:	ff d6                	call   *%esi
			break;
  8012d4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8012d7:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8012da:	e9 9d 02 00 00       	jmp    80157c <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8012df:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e2:	8d 78 04             	lea    0x4(%eax),%edi
  8012e5:	8b 10                	mov    (%eax),%edx
  8012e7:	89 d0                	mov    %edx,%eax
  8012e9:	f7 d8                	neg    %eax
  8012eb:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8012ee:	83 f8 0f             	cmp    $0xf,%eax
  8012f1:	7f 23                	jg     801316 <vprintfmt+0x15c>
  8012f3:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  8012fa:	85 d2                	test   %edx,%edx
  8012fc:	74 18                	je     801316 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8012fe:	52                   	push   %edx
  8012ff:	68 3d 1e 80 00       	push   $0x801e3d
  801304:	53                   	push   %ebx
  801305:	56                   	push   %esi
  801306:	e8 92 fe ff ff       	call   80119d <printfmt>
  80130b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80130e:	89 7d 14             	mov    %edi,0x14(%ebp)
  801311:	e9 66 02 00 00       	jmp    80157c <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  801316:	50                   	push   %eax
  801317:	68 bf 1e 80 00       	push   $0x801ebf
  80131c:	53                   	push   %ebx
  80131d:	56                   	push   %esi
  80131e:	e8 7a fe ff ff       	call   80119d <printfmt>
  801323:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801326:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801329:	e9 4e 02 00 00       	jmp    80157c <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80132e:	8b 45 14             	mov    0x14(%ebp),%eax
  801331:	83 c0 04             	add    $0x4,%eax
  801334:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801337:	8b 45 14             	mov    0x14(%ebp),%eax
  80133a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80133c:	85 d2                	test   %edx,%edx
  80133e:	b8 b8 1e 80 00       	mov    $0x801eb8,%eax
  801343:	0f 45 c2             	cmovne %edx,%eax
  801346:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801349:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80134d:	7e 06                	jle    801355 <vprintfmt+0x19b>
  80134f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801353:	75 0d                	jne    801362 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801355:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801358:	89 c7                	mov    %eax,%edi
  80135a:	03 45 e0             	add    -0x20(%ebp),%eax
  80135d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801360:	eb 55                	jmp    8013b7 <vprintfmt+0x1fd>
  801362:	83 ec 08             	sub    $0x8,%esp
  801365:	ff 75 d8             	push   -0x28(%ebp)
  801368:	ff 75 cc             	push   -0x34(%ebp)
  80136b:	e8 0a 03 00 00       	call   80167a <strnlen>
  801370:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801373:	29 c1                	sub    %eax,%ecx
  801375:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80137d:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801381:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801384:	eb 0f                	jmp    801395 <vprintfmt+0x1db>
					putch(padc, putdat);
  801386:	83 ec 08             	sub    $0x8,%esp
  801389:	53                   	push   %ebx
  80138a:	ff 75 e0             	push   -0x20(%ebp)
  80138d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80138f:	83 ef 01             	sub    $0x1,%edi
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	85 ff                	test   %edi,%edi
  801397:	7f ed                	jg     801386 <vprintfmt+0x1cc>
  801399:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80139c:	85 d2                	test   %edx,%edx
  80139e:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a3:	0f 49 c2             	cmovns %edx,%eax
  8013a6:	29 c2                	sub    %eax,%edx
  8013a8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8013ab:	eb a8                	jmp    801355 <vprintfmt+0x19b>
					putch(ch, putdat);
  8013ad:	83 ec 08             	sub    $0x8,%esp
  8013b0:	53                   	push   %ebx
  8013b1:	52                   	push   %edx
  8013b2:	ff d6                	call   *%esi
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013ba:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013bc:	83 c7 01             	add    $0x1,%edi
  8013bf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8013c3:	0f be d0             	movsbl %al,%edx
  8013c6:	85 d2                	test   %edx,%edx
  8013c8:	74 4b                	je     801415 <vprintfmt+0x25b>
  8013ca:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013ce:	78 06                	js     8013d6 <vprintfmt+0x21c>
  8013d0:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8013d4:	78 1e                	js     8013f4 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8013d6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8013da:	74 d1                	je     8013ad <vprintfmt+0x1f3>
  8013dc:	0f be c0             	movsbl %al,%eax
  8013df:	83 e8 20             	sub    $0x20,%eax
  8013e2:	83 f8 5e             	cmp    $0x5e,%eax
  8013e5:	76 c6                	jbe    8013ad <vprintfmt+0x1f3>
					putch('?', putdat);
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	53                   	push   %ebx
  8013eb:	6a 3f                	push   $0x3f
  8013ed:	ff d6                	call   *%esi
  8013ef:	83 c4 10             	add    $0x10,%esp
  8013f2:	eb c3                	jmp    8013b7 <vprintfmt+0x1fd>
  8013f4:	89 cf                	mov    %ecx,%edi
  8013f6:	eb 0e                	jmp    801406 <vprintfmt+0x24c>
				putch(' ', putdat);
  8013f8:	83 ec 08             	sub    $0x8,%esp
  8013fb:	53                   	push   %ebx
  8013fc:	6a 20                	push   $0x20
  8013fe:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801400:	83 ef 01             	sub    $0x1,%edi
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	85 ff                	test   %edi,%edi
  801408:	7f ee                	jg     8013f8 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80140a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80140d:	89 45 14             	mov    %eax,0x14(%ebp)
  801410:	e9 67 01 00 00       	jmp    80157c <vprintfmt+0x3c2>
  801415:	89 cf                	mov    %ecx,%edi
  801417:	eb ed                	jmp    801406 <vprintfmt+0x24c>
	if (lflag >= 2)
  801419:	83 f9 01             	cmp    $0x1,%ecx
  80141c:	7f 1b                	jg     801439 <vprintfmt+0x27f>
	else if (lflag)
  80141e:	85 c9                	test   %ecx,%ecx
  801420:	74 63                	je     801485 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  801422:	8b 45 14             	mov    0x14(%ebp),%eax
  801425:	8b 00                	mov    (%eax),%eax
  801427:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80142a:	99                   	cltd   
  80142b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80142e:	8b 45 14             	mov    0x14(%ebp),%eax
  801431:	8d 40 04             	lea    0x4(%eax),%eax
  801434:	89 45 14             	mov    %eax,0x14(%ebp)
  801437:	eb 17                	jmp    801450 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801439:	8b 45 14             	mov    0x14(%ebp),%eax
  80143c:	8b 50 04             	mov    0x4(%eax),%edx
  80143f:	8b 00                	mov    (%eax),%eax
  801441:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801444:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801447:	8b 45 14             	mov    0x14(%ebp),%eax
  80144a:	8d 40 08             	lea    0x8(%eax),%eax
  80144d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801450:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801453:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801456:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80145b:	85 c9                	test   %ecx,%ecx
  80145d:	0f 89 ff 00 00 00    	jns    801562 <vprintfmt+0x3a8>
				putch('-', putdat);
  801463:	83 ec 08             	sub    $0x8,%esp
  801466:	53                   	push   %ebx
  801467:	6a 2d                	push   $0x2d
  801469:	ff d6                	call   *%esi
				num = -(long long) num;
  80146b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80146e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801471:	f7 da                	neg    %edx
  801473:	83 d1 00             	adc    $0x0,%ecx
  801476:	f7 d9                	neg    %ecx
  801478:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80147b:	bf 0a 00 00 00       	mov    $0xa,%edi
  801480:	e9 dd 00 00 00       	jmp    801562 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801485:	8b 45 14             	mov    0x14(%ebp),%eax
  801488:	8b 00                	mov    (%eax),%eax
  80148a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80148d:	99                   	cltd   
  80148e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801491:	8b 45 14             	mov    0x14(%ebp),%eax
  801494:	8d 40 04             	lea    0x4(%eax),%eax
  801497:	89 45 14             	mov    %eax,0x14(%ebp)
  80149a:	eb b4                	jmp    801450 <vprintfmt+0x296>
	if (lflag >= 2)
  80149c:	83 f9 01             	cmp    $0x1,%ecx
  80149f:	7f 1e                	jg     8014bf <vprintfmt+0x305>
	else if (lflag)
  8014a1:	85 c9                	test   %ecx,%ecx
  8014a3:	74 32                	je     8014d7 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8014a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a8:	8b 10                	mov    (%eax),%edx
  8014aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014af:	8d 40 04             	lea    0x4(%eax),%eax
  8014b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014b5:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8014ba:	e9 a3 00 00 00       	jmp    801562 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8014bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c2:	8b 10                	mov    (%eax),%edx
  8014c4:	8b 48 04             	mov    0x4(%eax),%ecx
  8014c7:	8d 40 08             	lea    0x8(%eax),%eax
  8014ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014cd:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8014d2:	e9 8b 00 00 00       	jmp    801562 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8014d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014da:	8b 10                	mov    (%eax),%edx
  8014dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014e1:	8d 40 04             	lea    0x4(%eax),%eax
  8014e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014e7:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8014ec:	eb 74                	jmp    801562 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8014ee:	83 f9 01             	cmp    $0x1,%ecx
  8014f1:	7f 1b                	jg     80150e <vprintfmt+0x354>
	else if (lflag)
  8014f3:	85 c9                	test   %ecx,%ecx
  8014f5:	74 2c                	je     801523 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8014f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fa:	8b 10                	mov    (%eax),%edx
  8014fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  801501:	8d 40 04             	lea    0x4(%eax),%eax
  801504:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801507:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80150c:	eb 54                	jmp    801562 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80150e:	8b 45 14             	mov    0x14(%ebp),%eax
  801511:	8b 10                	mov    (%eax),%edx
  801513:	8b 48 04             	mov    0x4(%eax),%ecx
  801516:	8d 40 08             	lea    0x8(%eax),%eax
  801519:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80151c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  801521:	eb 3f                	jmp    801562 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801523:	8b 45 14             	mov    0x14(%ebp),%eax
  801526:	8b 10                	mov    (%eax),%edx
  801528:	b9 00 00 00 00       	mov    $0x0,%ecx
  80152d:	8d 40 04             	lea    0x4(%eax),%eax
  801530:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801533:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801538:	eb 28                	jmp    801562 <vprintfmt+0x3a8>
			putch('0', putdat);
  80153a:	83 ec 08             	sub    $0x8,%esp
  80153d:	53                   	push   %ebx
  80153e:	6a 30                	push   $0x30
  801540:	ff d6                	call   *%esi
			putch('x', putdat);
  801542:	83 c4 08             	add    $0x8,%esp
  801545:	53                   	push   %ebx
  801546:	6a 78                	push   $0x78
  801548:	ff d6                	call   *%esi
			num = (unsigned long long)
  80154a:	8b 45 14             	mov    0x14(%ebp),%eax
  80154d:	8b 10                	mov    (%eax),%edx
  80154f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801554:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801557:	8d 40 04             	lea    0x4(%eax),%eax
  80155a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80155d:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801562:	83 ec 0c             	sub    $0xc,%esp
  801565:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801569:	50                   	push   %eax
  80156a:	ff 75 e0             	push   -0x20(%ebp)
  80156d:	57                   	push   %edi
  80156e:	51                   	push   %ecx
  80156f:	52                   	push   %edx
  801570:	89 da                	mov    %ebx,%edx
  801572:	89 f0                	mov    %esi,%eax
  801574:	e8 5e fb ff ff       	call   8010d7 <printnum>
			break;
  801579:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80157c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80157f:	e9 54 fc ff ff       	jmp    8011d8 <vprintfmt+0x1e>
	if (lflag >= 2)
  801584:	83 f9 01             	cmp    $0x1,%ecx
  801587:	7f 1b                	jg     8015a4 <vprintfmt+0x3ea>
	else if (lflag)
  801589:	85 c9                	test   %ecx,%ecx
  80158b:	74 2c                	je     8015b9 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80158d:	8b 45 14             	mov    0x14(%ebp),%eax
  801590:	8b 10                	mov    (%eax),%edx
  801592:	b9 00 00 00 00       	mov    $0x0,%ecx
  801597:	8d 40 04             	lea    0x4(%eax),%eax
  80159a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80159d:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8015a2:	eb be                	jmp    801562 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8015a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a7:	8b 10                	mov    (%eax),%edx
  8015a9:	8b 48 04             	mov    0x4(%eax),%ecx
  8015ac:	8d 40 08             	lea    0x8(%eax),%eax
  8015af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015b2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8015b7:	eb a9                	jmp    801562 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8015b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8015bc:	8b 10                	mov    (%eax),%edx
  8015be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015c3:	8d 40 04             	lea    0x4(%eax),%eax
  8015c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015c9:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8015ce:	eb 92                	jmp    801562 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	53                   	push   %ebx
  8015d4:	6a 25                	push   $0x25
  8015d6:	ff d6                	call   *%esi
			break;
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	eb 9f                	jmp    80157c <vprintfmt+0x3c2>
			putch('%', putdat);
  8015dd:	83 ec 08             	sub    $0x8,%esp
  8015e0:	53                   	push   %ebx
  8015e1:	6a 25                	push   $0x25
  8015e3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	89 f8                	mov    %edi,%eax
  8015ea:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8015ee:	74 05                	je     8015f5 <vprintfmt+0x43b>
  8015f0:	83 e8 01             	sub    $0x1,%eax
  8015f3:	eb f5                	jmp    8015ea <vprintfmt+0x430>
  8015f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015f8:	eb 82                	jmp    80157c <vprintfmt+0x3c2>

008015fa <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015fa:	55                   	push   %ebp
  8015fb:	89 e5                	mov    %esp,%ebp
  8015fd:	83 ec 18             	sub    $0x18,%esp
  801600:	8b 45 08             	mov    0x8(%ebp),%eax
  801603:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801606:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801609:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80160d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801610:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801617:	85 c0                	test   %eax,%eax
  801619:	74 26                	je     801641 <vsnprintf+0x47>
  80161b:	85 d2                	test   %edx,%edx
  80161d:	7e 22                	jle    801641 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80161f:	ff 75 14             	push   0x14(%ebp)
  801622:	ff 75 10             	push   0x10(%ebp)
  801625:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801628:	50                   	push   %eax
  801629:	68 80 11 80 00       	push   $0x801180
  80162e:	e8 87 fb ff ff       	call   8011ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801633:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801636:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801639:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80163c:	83 c4 10             	add    $0x10,%esp
}
  80163f:	c9                   	leave  
  801640:	c3                   	ret    
		return -E_INVAL;
  801641:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801646:	eb f7                	jmp    80163f <vsnprintf+0x45>

00801648 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80164e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801651:	50                   	push   %eax
  801652:	ff 75 10             	push   0x10(%ebp)
  801655:	ff 75 0c             	push   0xc(%ebp)
  801658:	ff 75 08             	push   0x8(%ebp)
  80165b:	e8 9a ff ff ff       	call   8015fa <vsnprintf>
	va_end(ap);

	return rc;
}
  801660:	c9                   	leave  
  801661:	c3                   	ret    

00801662 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801668:	b8 00 00 00 00       	mov    $0x0,%eax
  80166d:	eb 03                	jmp    801672 <strlen+0x10>
		n++;
  80166f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801672:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801676:	75 f7                	jne    80166f <strlen+0xd>
	return n;
}
  801678:	5d                   	pop    %ebp
  801679:	c3                   	ret    

0080167a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801680:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801683:	b8 00 00 00 00       	mov    $0x0,%eax
  801688:	eb 03                	jmp    80168d <strnlen+0x13>
		n++;
  80168a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80168d:	39 d0                	cmp    %edx,%eax
  80168f:	74 08                	je     801699 <strnlen+0x1f>
  801691:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801695:	75 f3                	jne    80168a <strnlen+0x10>
  801697:	89 c2                	mov    %eax,%edx
	return n;
}
  801699:	89 d0                	mov    %edx,%eax
  80169b:	5d                   	pop    %ebp
  80169c:	c3                   	ret    

0080169d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	53                   	push   %ebx
  8016a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ac:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016b0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016b3:	83 c0 01             	add    $0x1,%eax
  8016b6:	84 d2                	test   %dl,%dl
  8016b8:	75 f2                	jne    8016ac <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8016ba:	89 c8                	mov    %ecx,%eax
  8016bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	53                   	push   %ebx
  8016c5:	83 ec 10             	sub    $0x10,%esp
  8016c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016cb:	53                   	push   %ebx
  8016cc:	e8 91 ff ff ff       	call   801662 <strlen>
  8016d1:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8016d4:	ff 75 0c             	push   0xc(%ebp)
  8016d7:	01 d8                	add    %ebx,%eax
  8016d9:	50                   	push   %eax
  8016da:	e8 be ff ff ff       	call   80169d <strcpy>
	return dst;
}
  8016df:	89 d8                	mov    %ebx,%eax
  8016e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e4:	c9                   	leave  
  8016e5:	c3                   	ret    

008016e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	56                   	push   %esi
  8016ea:	53                   	push   %ebx
  8016eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f1:	89 f3                	mov    %esi,%ebx
  8016f3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016f6:	89 f0                	mov    %esi,%eax
  8016f8:	eb 0f                	jmp    801709 <strncpy+0x23>
		*dst++ = *src;
  8016fa:	83 c0 01             	add    $0x1,%eax
  8016fd:	0f b6 0a             	movzbl (%edx),%ecx
  801700:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801703:	80 f9 01             	cmp    $0x1,%cl
  801706:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801709:	39 d8                	cmp    %ebx,%eax
  80170b:	75 ed                	jne    8016fa <strncpy+0x14>
	}
	return ret;
}
  80170d:	89 f0                	mov    %esi,%eax
  80170f:	5b                   	pop    %ebx
  801710:	5e                   	pop    %esi
  801711:	5d                   	pop    %ebp
  801712:	c3                   	ret    

00801713 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	56                   	push   %esi
  801717:	53                   	push   %ebx
  801718:	8b 75 08             	mov    0x8(%ebp),%esi
  80171b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80171e:	8b 55 10             	mov    0x10(%ebp),%edx
  801721:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801723:	85 d2                	test   %edx,%edx
  801725:	74 21                	je     801748 <strlcpy+0x35>
  801727:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80172b:	89 f2                	mov    %esi,%edx
  80172d:	eb 09                	jmp    801738 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80172f:	83 c1 01             	add    $0x1,%ecx
  801732:	83 c2 01             	add    $0x1,%edx
  801735:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801738:	39 c2                	cmp    %eax,%edx
  80173a:	74 09                	je     801745 <strlcpy+0x32>
  80173c:	0f b6 19             	movzbl (%ecx),%ebx
  80173f:	84 db                	test   %bl,%bl
  801741:	75 ec                	jne    80172f <strlcpy+0x1c>
  801743:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801745:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801748:	29 f0                	sub    %esi,%eax
}
  80174a:	5b                   	pop    %ebx
  80174b:	5e                   	pop    %esi
  80174c:	5d                   	pop    %ebp
  80174d:	c3                   	ret    

0080174e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801754:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801757:	eb 06                	jmp    80175f <strcmp+0x11>
		p++, q++;
  801759:	83 c1 01             	add    $0x1,%ecx
  80175c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80175f:	0f b6 01             	movzbl (%ecx),%eax
  801762:	84 c0                	test   %al,%al
  801764:	74 04                	je     80176a <strcmp+0x1c>
  801766:	3a 02                	cmp    (%edx),%al
  801768:	74 ef                	je     801759 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80176a:	0f b6 c0             	movzbl %al,%eax
  80176d:	0f b6 12             	movzbl (%edx),%edx
  801770:	29 d0                	sub    %edx,%eax
}
  801772:	5d                   	pop    %ebp
  801773:	c3                   	ret    

00801774 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	53                   	push   %ebx
  801778:	8b 45 08             	mov    0x8(%ebp),%eax
  80177b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80177e:	89 c3                	mov    %eax,%ebx
  801780:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801783:	eb 06                	jmp    80178b <strncmp+0x17>
		n--, p++, q++;
  801785:	83 c0 01             	add    $0x1,%eax
  801788:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80178b:	39 d8                	cmp    %ebx,%eax
  80178d:	74 18                	je     8017a7 <strncmp+0x33>
  80178f:	0f b6 08             	movzbl (%eax),%ecx
  801792:	84 c9                	test   %cl,%cl
  801794:	74 04                	je     80179a <strncmp+0x26>
  801796:	3a 0a                	cmp    (%edx),%cl
  801798:	74 eb                	je     801785 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80179a:	0f b6 00             	movzbl (%eax),%eax
  80179d:	0f b6 12             	movzbl (%edx),%edx
  8017a0:	29 d0                	sub    %edx,%eax
}
  8017a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a5:	c9                   	leave  
  8017a6:	c3                   	ret    
		return 0;
  8017a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ac:	eb f4                	jmp    8017a2 <strncmp+0x2e>

008017ae <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017b8:	eb 03                	jmp    8017bd <strchr+0xf>
  8017ba:	83 c0 01             	add    $0x1,%eax
  8017bd:	0f b6 10             	movzbl (%eax),%edx
  8017c0:	84 d2                	test   %dl,%dl
  8017c2:	74 06                	je     8017ca <strchr+0x1c>
		if (*s == c)
  8017c4:	38 ca                	cmp    %cl,%dl
  8017c6:	75 f2                	jne    8017ba <strchr+0xc>
  8017c8:	eb 05                	jmp    8017cf <strchr+0x21>
			return (char *) s;
	return 0;
  8017ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017cf:	5d                   	pop    %ebp
  8017d0:	c3                   	ret    

008017d1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017db:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017de:	38 ca                	cmp    %cl,%dl
  8017e0:	74 09                	je     8017eb <strfind+0x1a>
  8017e2:	84 d2                	test   %dl,%dl
  8017e4:	74 05                	je     8017eb <strfind+0x1a>
	for (; *s; s++)
  8017e6:	83 c0 01             	add    $0x1,%eax
  8017e9:	eb f0                	jmp    8017db <strfind+0xa>
			break;
	return (char *) s;
}
  8017eb:	5d                   	pop    %ebp
  8017ec:	c3                   	ret    

008017ed <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	57                   	push   %edi
  8017f1:	56                   	push   %esi
  8017f2:	53                   	push   %ebx
  8017f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017f9:	85 c9                	test   %ecx,%ecx
  8017fb:	74 2f                	je     80182c <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017fd:	89 f8                	mov    %edi,%eax
  8017ff:	09 c8                	or     %ecx,%eax
  801801:	a8 03                	test   $0x3,%al
  801803:	75 21                	jne    801826 <memset+0x39>
		c &= 0xFF;
  801805:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801809:	89 d0                	mov    %edx,%eax
  80180b:	c1 e0 08             	shl    $0x8,%eax
  80180e:	89 d3                	mov    %edx,%ebx
  801810:	c1 e3 18             	shl    $0x18,%ebx
  801813:	89 d6                	mov    %edx,%esi
  801815:	c1 e6 10             	shl    $0x10,%esi
  801818:	09 f3                	or     %esi,%ebx
  80181a:	09 da                	or     %ebx,%edx
  80181c:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80181e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801821:	fc                   	cld    
  801822:	f3 ab                	rep stos %eax,%es:(%edi)
  801824:	eb 06                	jmp    80182c <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801826:	8b 45 0c             	mov    0xc(%ebp),%eax
  801829:	fc                   	cld    
  80182a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80182c:	89 f8                	mov    %edi,%eax
  80182e:	5b                   	pop    %ebx
  80182f:	5e                   	pop    %esi
  801830:	5f                   	pop    %edi
  801831:	5d                   	pop    %ebp
  801832:	c3                   	ret    

00801833 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	57                   	push   %edi
  801837:	56                   	push   %esi
  801838:	8b 45 08             	mov    0x8(%ebp),%eax
  80183b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80183e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801841:	39 c6                	cmp    %eax,%esi
  801843:	73 32                	jae    801877 <memmove+0x44>
  801845:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801848:	39 c2                	cmp    %eax,%edx
  80184a:	76 2b                	jbe    801877 <memmove+0x44>
		s += n;
		d += n;
  80184c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80184f:	89 d6                	mov    %edx,%esi
  801851:	09 fe                	or     %edi,%esi
  801853:	09 ce                	or     %ecx,%esi
  801855:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80185b:	75 0e                	jne    80186b <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80185d:	83 ef 04             	sub    $0x4,%edi
  801860:	8d 72 fc             	lea    -0x4(%edx),%esi
  801863:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801866:	fd                   	std    
  801867:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801869:	eb 09                	jmp    801874 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80186b:	83 ef 01             	sub    $0x1,%edi
  80186e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801871:	fd                   	std    
  801872:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801874:	fc                   	cld    
  801875:	eb 1a                	jmp    801891 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801877:	89 f2                	mov    %esi,%edx
  801879:	09 c2                	or     %eax,%edx
  80187b:	09 ca                	or     %ecx,%edx
  80187d:	f6 c2 03             	test   $0x3,%dl
  801880:	75 0a                	jne    80188c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801882:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801885:	89 c7                	mov    %eax,%edi
  801887:	fc                   	cld    
  801888:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80188a:	eb 05                	jmp    801891 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  80188c:	89 c7                	mov    %eax,%edi
  80188e:	fc                   	cld    
  80188f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801891:	5e                   	pop    %esi
  801892:	5f                   	pop    %edi
  801893:	5d                   	pop    %ebp
  801894:	c3                   	ret    

00801895 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
  801898:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80189b:	ff 75 10             	push   0x10(%ebp)
  80189e:	ff 75 0c             	push   0xc(%ebp)
  8018a1:	ff 75 08             	push   0x8(%ebp)
  8018a4:	e8 8a ff ff ff       	call   801833 <memmove>
}
  8018a9:	c9                   	leave  
  8018aa:	c3                   	ret    

008018ab <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	56                   	push   %esi
  8018af:	53                   	push   %ebx
  8018b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018b6:	89 c6                	mov    %eax,%esi
  8018b8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018bb:	eb 06                	jmp    8018c3 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8018bd:	83 c0 01             	add    $0x1,%eax
  8018c0:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8018c3:	39 f0                	cmp    %esi,%eax
  8018c5:	74 14                	je     8018db <memcmp+0x30>
		if (*s1 != *s2)
  8018c7:	0f b6 08             	movzbl (%eax),%ecx
  8018ca:	0f b6 1a             	movzbl (%edx),%ebx
  8018cd:	38 d9                	cmp    %bl,%cl
  8018cf:	74 ec                	je     8018bd <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8018d1:	0f b6 c1             	movzbl %cl,%eax
  8018d4:	0f b6 db             	movzbl %bl,%ebx
  8018d7:	29 d8                	sub    %ebx,%eax
  8018d9:	eb 05                	jmp    8018e0 <memcmp+0x35>
	}

	return 0;
  8018db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018e0:	5b                   	pop    %ebx
  8018e1:	5e                   	pop    %esi
  8018e2:	5d                   	pop    %ebp
  8018e3:	c3                   	ret    

008018e4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8018ed:	89 c2                	mov    %eax,%edx
  8018ef:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018f2:	eb 03                	jmp    8018f7 <memfind+0x13>
  8018f4:	83 c0 01             	add    $0x1,%eax
  8018f7:	39 d0                	cmp    %edx,%eax
  8018f9:	73 04                	jae    8018ff <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018fb:	38 08                	cmp    %cl,(%eax)
  8018fd:	75 f5                	jne    8018f4 <memfind+0x10>
			break;
	return (void *) s;
}
  8018ff:	5d                   	pop    %ebp
  801900:	c3                   	ret    

00801901 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	57                   	push   %edi
  801905:	56                   	push   %esi
  801906:	53                   	push   %ebx
  801907:	8b 55 08             	mov    0x8(%ebp),%edx
  80190a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80190d:	eb 03                	jmp    801912 <strtol+0x11>
		s++;
  80190f:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801912:	0f b6 02             	movzbl (%edx),%eax
  801915:	3c 20                	cmp    $0x20,%al
  801917:	74 f6                	je     80190f <strtol+0xe>
  801919:	3c 09                	cmp    $0x9,%al
  80191b:	74 f2                	je     80190f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  80191d:	3c 2b                	cmp    $0x2b,%al
  80191f:	74 2a                	je     80194b <strtol+0x4a>
	int neg = 0;
  801921:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801926:	3c 2d                	cmp    $0x2d,%al
  801928:	74 2b                	je     801955 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80192a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801930:	75 0f                	jne    801941 <strtol+0x40>
  801932:	80 3a 30             	cmpb   $0x30,(%edx)
  801935:	74 28                	je     80195f <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801937:	85 db                	test   %ebx,%ebx
  801939:	b8 0a 00 00 00       	mov    $0xa,%eax
  80193e:	0f 44 d8             	cmove  %eax,%ebx
  801941:	b9 00 00 00 00       	mov    $0x0,%ecx
  801946:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801949:	eb 46                	jmp    801991 <strtol+0x90>
		s++;
  80194b:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  80194e:	bf 00 00 00 00       	mov    $0x0,%edi
  801953:	eb d5                	jmp    80192a <strtol+0x29>
		s++, neg = 1;
  801955:	83 c2 01             	add    $0x1,%edx
  801958:	bf 01 00 00 00       	mov    $0x1,%edi
  80195d:	eb cb                	jmp    80192a <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80195f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801963:	74 0e                	je     801973 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801965:	85 db                	test   %ebx,%ebx
  801967:	75 d8                	jne    801941 <strtol+0x40>
		s++, base = 8;
  801969:	83 c2 01             	add    $0x1,%edx
  80196c:	bb 08 00 00 00       	mov    $0x8,%ebx
  801971:	eb ce                	jmp    801941 <strtol+0x40>
		s += 2, base = 16;
  801973:	83 c2 02             	add    $0x2,%edx
  801976:	bb 10 00 00 00       	mov    $0x10,%ebx
  80197b:	eb c4                	jmp    801941 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  80197d:	0f be c0             	movsbl %al,%eax
  801980:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801983:	3b 45 10             	cmp    0x10(%ebp),%eax
  801986:	7d 3a                	jge    8019c2 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801988:	83 c2 01             	add    $0x1,%edx
  80198b:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  80198f:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801991:	0f b6 02             	movzbl (%edx),%eax
  801994:	8d 70 d0             	lea    -0x30(%eax),%esi
  801997:	89 f3                	mov    %esi,%ebx
  801999:	80 fb 09             	cmp    $0x9,%bl
  80199c:	76 df                	jbe    80197d <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  80199e:	8d 70 9f             	lea    -0x61(%eax),%esi
  8019a1:	89 f3                	mov    %esi,%ebx
  8019a3:	80 fb 19             	cmp    $0x19,%bl
  8019a6:	77 08                	ja     8019b0 <strtol+0xaf>
			dig = *s - 'a' + 10;
  8019a8:	0f be c0             	movsbl %al,%eax
  8019ab:	83 e8 57             	sub    $0x57,%eax
  8019ae:	eb d3                	jmp    801983 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8019b0:	8d 70 bf             	lea    -0x41(%eax),%esi
  8019b3:	89 f3                	mov    %esi,%ebx
  8019b5:	80 fb 19             	cmp    $0x19,%bl
  8019b8:	77 08                	ja     8019c2 <strtol+0xc1>
			dig = *s - 'A' + 10;
  8019ba:	0f be c0             	movsbl %al,%eax
  8019bd:	83 e8 37             	sub    $0x37,%eax
  8019c0:	eb c1                	jmp    801983 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8019c2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019c6:	74 05                	je     8019cd <strtol+0xcc>
		*endptr = (char *) s;
  8019c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019cb:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8019cd:	89 c8                	mov    %ecx,%eax
  8019cf:	f7 d8                	neg    %eax
  8019d1:	85 ff                	test   %edi,%edi
  8019d3:	0f 45 c8             	cmovne %eax,%ecx
}
  8019d6:	89 c8                	mov    %ecx,%eax
  8019d8:	5b                   	pop    %ebx
  8019d9:	5e                   	pop    %esi
  8019da:	5f                   	pop    %edi
  8019db:	5d                   	pop    %ebp
  8019dc:	c3                   	ret    

008019dd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	56                   	push   %esi
  8019e1:	53                   	push   %ebx
  8019e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8019e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019f2:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8019f5:	83 ec 0c             	sub    $0xc,%esp
  8019f8:	50                   	push   %eax
  8019f9:	e8 08 e9 ff ff       	call   800306 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8019fe:	83 c4 10             	add    $0x10,%esp
  801a01:	85 f6                	test   %esi,%esi
  801a03:	74 14                	je     801a19 <ipc_recv+0x3c>
  801a05:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	78 09                	js     801a17 <ipc_recv+0x3a>
  801a0e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a14:	8b 52 74             	mov    0x74(%edx),%edx
  801a17:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801a19:	85 db                	test   %ebx,%ebx
  801a1b:	74 14                	je     801a31 <ipc_recv+0x54>
  801a1d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a22:	85 c0                	test   %eax,%eax
  801a24:	78 09                	js     801a2f <ipc_recv+0x52>
  801a26:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a2c:	8b 52 78             	mov    0x78(%edx),%edx
  801a2f:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801a31:	85 c0                	test   %eax,%eax
  801a33:	78 08                	js     801a3d <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801a35:	a1 00 40 80 00       	mov    0x804000,%eax
  801a3a:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a40:	5b                   	pop    %ebx
  801a41:	5e                   	pop    %esi
  801a42:	5d                   	pop    %ebp
  801a43:	c3                   	ret    

00801a44 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	57                   	push   %edi
  801a48:	56                   	push   %esi
  801a49:	53                   	push   %ebx
  801a4a:	83 ec 0c             	sub    $0xc,%esp
  801a4d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a50:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801a56:	85 db                	test   %ebx,%ebx
  801a58:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a5d:	0f 44 d8             	cmove  %eax,%ebx
  801a60:	eb 05                	jmp    801a67 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a62:	e8 d0 e6 ff ff       	call   800137 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801a67:	ff 75 14             	push   0x14(%ebp)
  801a6a:	53                   	push   %ebx
  801a6b:	56                   	push   %esi
  801a6c:	57                   	push   %edi
  801a6d:	e8 71 e8 ff ff       	call   8002e3 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a72:	83 c4 10             	add    $0x10,%esp
  801a75:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a78:	74 e8                	je     801a62 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801a7a:	85 c0                	test   %eax,%eax
  801a7c:	78 08                	js     801a86 <ipc_send+0x42>
	}while (r<0);

}
  801a7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a81:	5b                   	pop    %ebx
  801a82:	5e                   	pop    %esi
  801a83:	5f                   	pop    %edi
  801a84:	5d                   	pop    %ebp
  801a85:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801a86:	50                   	push   %eax
  801a87:	68 9f 21 80 00       	push   $0x80219f
  801a8c:	6a 3d                	push   $0x3d
  801a8e:	68 b3 21 80 00       	push   $0x8021b3
  801a93:	e8 50 f5 ff ff       	call   800fe8 <_panic>

00801a98 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801a9e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801aa3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801aa6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aac:	8b 52 50             	mov    0x50(%edx),%edx
  801aaf:	39 ca                	cmp    %ecx,%edx
  801ab1:	74 11                	je     801ac4 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801ab3:	83 c0 01             	add    $0x1,%eax
  801ab6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801abb:	75 e6                	jne    801aa3 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801abd:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac2:	eb 0b                	jmp    801acf <ipc_find_env+0x37>
			return envs[i].env_id;
  801ac4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ac7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801acc:	8b 40 48             	mov    0x48(%eax),%eax
}
  801acf:	5d                   	pop    %ebp
  801ad0:	c3                   	ret    

00801ad1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ad7:	89 c2                	mov    %eax,%edx
  801ad9:	c1 ea 16             	shr    $0x16,%edx
  801adc:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801ae3:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801ae8:	f6 c1 01             	test   $0x1,%cl
  801aeb:	74 1c                	je     801b09 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801aed:	c1 e8 0c             	shr    $0xc,%eax
  801af0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801af7:	a8 01                	test   $0x1,%al
  801af9:	74 0e                	je     801b09 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801afb:	c1 e8 0c             	shr    $0xc,%eax
  801afe:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b05:	ef 
  801b06:	0f b7 d2             	movzwl %dx,%edx
}
  801b09:	89 d0                	mov    %edx,%eax
  801b0b:	5d                   	pop    %ebp
  801b0c:	c3                   	ret    
  801b0d:	66 90                	xchg   %ax,%ax
  801b0f:	90                   	nop

00801b10 <__udivdi3>:
  801b10:	f3 0f 1e fb          	endbr32 
  801b14:	55                   	push   %ebp
  801b15:	57                   	push   %edi
  801b16:	56                   	push   %esi
  801b17:	53                   	push   %ebx
  801b18:	83 ec 1c             	sub    $0x1c,%esp
  801b1b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801b1f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b23:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b27:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	75 19                	jne    801b48 <__udivdi3+0x38>
  801b2f:	39 f3                	cmp    %esi,%ebx
  801b31:	76 4d                	jbe    801b80 <__udivdi3+0x70>
  801b33:	31 ff                	xor    %edi,%edi
  801b35:	89 e8                	mov    %ebp,%eax
  801b37:	89 f2                	mov    %esi,%edx
  801b39:	f7 f3                	div    %ebx
  801b3b:	89 fa                	mov    %edi,%edx
  801b3d:	83 c4 1c             	add    $0x1c,%esp
  801b40:	5b                   	pop    %ebx
  801b41:	5e                   	pop    %esi
  801b42:	5f                   	pop    %edi
  801b43:	5d                   	pop    %ebp
  801b44:	c3                   	ret    
  801b45:	8d 76 00             	lea    0x0(%esi),%esi
  801b48:	39 f0                	cmp    %esi,%eax
  801b4a:	76 14                	jbe    801b60 <__udivdi3+0x50>
  801b4c:	31 ff                	xor    %edi,%edi
  801b4e:	31 c0                	xor    %eax,%eax
  801b50:	89 fa                	mov    %edi,%edx
  801b52:	83 c4 1c             	add    $0x1c,%esp
  801b55:	5b                   	pop    %ebx
  801b56:	5e                   	pop    %esi
  801b57:	5f                   	pop    %edi
  801b58:	5d                   	pop    %ebp
  801b59:	c3                   	ret    
  801b5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801b60:	0f bd f8             	bsr    %eax,%edi
  801b63:	83 f7 1f             	xor    $0x1f,%edi
  801b66:	75 48                	jne    801bb0 <__udivdi3+0xa0>
  801b68:	39 f0                	cmp    %esi,%eax
  801b6a:	72 06                	jb     801b72 <__udivdi3+0x62>
  801b6c:	31 c0                	xor    %eax,%eax
  801b6e:	39 eb                	cmp    %ebp,%ebx
  801b70:	77 de                	ja     801b50 <__udivdi3+0x40>
  801b72:	b8 01 00 00 00       	mov    $0x1,%eax
  801b77:	eb d7                	jmp    801b50 <__udivdi3+0x40>
  801b79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b80:	89 d9                	mov    %ebx,%ecx
  801b82:	85 db                	test   %ebx,%ebx
  801b84:	75 0b                	jne    801b91 <__udivdi3+0x81>
  801b86:	b8 01 00 00 00       	mov    $0x1,%eax
  801b8b:	31 d2                	xor    %edx,%edx
  801b8d:	f7 f3                	div    %ebx
  801b8f:	89 c1                	mov    %eax,%ecx
  801b91:	31 d2                	xor    %edx,%edx
  801b93:	89 f0                	mov    %esi,%eax
  801b95:	f7 f1                	div    %ecx
  801b97:	89 c6                	mov    %eax,%esi
  801b99:	89 e8                	mov    %ebp,%eax
  801b9b:	89 f7                	mov    %esi,%edi
  801b9d:	f7 f1                	div    %ecx
  801b9f:	89 fa                	mov    %edi,%edx
  801ba1:	83 c4 1c             	add    $0x1c,%esp
  801ba4:	5b                   	pop    %ebx
  801ba5:	5e                   	pop    %esi
  801ba6:	5f                   	pop    %edi
  801ba7:	5d                   	pop    %ebp
  801ba8:	c3                   	ret    
  801ba9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bb0:	89 f9                	mov    %edi,%ecx
  801bb2:	ba 20 00 00 00       	mov    $0x20,%edx
  801bb7:	29 fa                	sub    %edi,%edx
  801bb9:	d3 e0                	shl    %cl,%eax
  801bbb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bbf:	89 d1                	mov    %edx,%ecx
  801bc1:	89 d8                	mov    %ebx,%eax
  801bc3:	d3 e8                	shr    %cl,%eax
  801bc5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801bc9:	09 c1                	or     %eax,%ecx
  801bcb:	89 f0                	mov    %esi,%eax
  801bcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801bd1:	89 f9                	mov    %edi,%ecx
  801bd3:	d3 e3                	shl    %cl,%ebx
  801bd5:	89 d1                	mov    %edx,%ecx
  801bd7:	d3 e8                	shr    %cl,%eax
  801bd9:	89 f9                	mov    %edi,%ecx
  801bdb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801bdf:	89 eb                	mov    %ebp,%ebx
  801be1:	d3 e6                	shl    %cl,%esi
  801be3:	89 d1                	mov    %edx,%ecx
  801be5:	d3 eb                	shr    %cl,%ebx
  801be7:	09 f3                	or     %esi,%ebx
  801be9:	89 c6                	mov    %eax,%esi
  801beb:	89 f2                	mov    %esi,%edx
  801bed:	89 d8                	mov    %ebx,%eax
  801bef:	f7 74 24 08          	divl   0x8(%esp)
  801bf3:	89 d6                	mov    %edx,%esi
  801bf5:	89 c3                	mov    %eax,%ebx
  801bf7:	f7 64 24 0c          	mull   0xc(%esp)
  801bfb:	39 d6                	cmp    %edx,%esi
  801bfd:	72 19                	jb     801c18 <__udivdi3+0x108>
  801bff:	89 f9                	mov    %edi,%ecx
  801c01:	d3 e5                	shl    %cl,%ebp
  801c03:	39 c5                	cmp    %eax,%ebp
  801c05:	73 04                	jae    801c0b <__udivdi3+0xfb>
  801c07:	39 d6                	cmp    %edx,%esi
  801c09:	74 0d                	je     801c18 <__udivdi3+0x108>
  801c0b:	89 d8                	mov    %ebx,%eax
  801c0d:	31 ff                	xor    %edi,%edi
  801c0f:	e9 3c ff ff ff       	jmp    801b50 <__udivdi3+0x40>
  801c14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c18:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c1b:	31 ff                	xor    %edi,%edi
  801c1d:	e9 2e ff ff ff       	jmp    801b50 <__udivdi3+0x40>
  801c22:	66 90                	xchg   %ax,%ax
  801c24:	66 90                	xchg   %ax,%ax
  801c26:	66 90                	xchg   %ax,%ax
  801c28:	66 90                	xchg   %ax,%ax
  801c2a:	66 90                	xchg   %ax,%ax
  801c2c:	66 90                	xchg   %ax,%ax
  801c2e:	66 90                	xchg   %ax,%ax

00801c30 <__umoddi3>:
  801c30:	f3 0f 1e fb          	endbr32 
  801c34:	55                   	push   %ebp
  801c35:	57                   	push   %edi
  801c36:	56                   	push   %esi
  801c37:	53                   	push   %ebx
  801c38:	83 ec 1c             	sub    $0x1c,%esp
  801c3b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801c3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801c43:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801c47:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801c4b:	89 f0                	mov    %esi,%eax
  801c4d:	89 da                	mov    %ebx,%edx
  801c4f:	85 ff                	test   %edi,%edi
  801c51:	75 15                	jne    801c68 <__umoddi3+0x38>
  801c53:	39 dd                	cmp    %ebx,%ebp
  801c55:	76 39                	jbe    801c90 <__umoddi3+0x60>
  801c57:	f7 f5                	div    %ebp
  801c59:	89 d0                	mov    %edx,%eax
  801c5b:	31 d2                	xor    %edx,%edx
  801c5d:	83 c4 1c             	add    $0x1c,%esp
  801c60:	5b                   	pop    %ebx
  801c61:	5e                   	pop    %esi
  801c62:	5f                   	pop    %edi
  801c63:	5d                   	pop    %ebp
  801c64:	c3                   	ret    
  801c65:	8d 76 00             	lea    0x0(%esi),%esi
  801c68:	39 df                	cmp    %ebx,%edi
  801c6a:	77 f1                	ja     801c5d <__umoddi3+0x2d>
  801c6c:	0f bd cf             	bsr    %edi,%ecx
  801c6f:	83 f1 1f             	xor    $0x1f,%ecx
  801c72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c76:	75 40                	jne    801cb8 <__umoddi3+0x88>
  801c78:	39 df                	cmp    %ebx,%edi
  801c7a:	72 04                	jb     801c80 <__umoddi3+0x50>
  801c7c:	39 f5                	cmp    %esi,%ebp
  801c7e:	77 dd                	ja     801c5d <__umoddi3+0x2d>
  801c80:	89 da                	mov    %ebx,%edx
  801c82:	89 f0                	mov    %esi,%eax
  801c84:	29 e8                	sub    %ebp,%eax
  801c86:	19 fa                	sbb    %edi,%edx
  801c88:	eb d3                	jmp    801c5d <__umoddi3+0x2d>
  801c8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c90:	89 e9                	mov    %ebp,%ecx
  801c92:	85 ed                	test   %ebp,%ebp
  801c94:	75 0b                	jne    801ca1 <__umoddi3+0x71>
  801c96:	b8 01 00 00 00       	mov    $0x1,%eax
  801c9b:	31 d2                	xor    %edx,%edx
  801c9d:	f7 f5                	div    %ebp
  801c9f:	89 c1                	mov    %eax,%ecx
  801ca1:	89 d8                	mov    %ebx,%eax
  801ca3:	31 d2                	xor    %edx,%edx
  801ca5:	f7 f1                	div    %ecx
  801ca7:	89 f0                	mov    %esi,%eax
  801ca9:	f7 f1                	div    %ecx
  801cab:	89 d0                	mov    %edx,%eax
  801cad:	31 d2                	xor    %edx,%edx
  801caf:	eb ac                	jmp    801c5d <__umoddi3+0x2d>
  801cb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb8:	8b 44 24 04          	mov    0x4(%esp),%eax
  801cbc:	ba 20 00 00 00       	mov    $0x20,%edx
  801cc1:	29 c2                	sub    %eax,%edx
  801cc3:	89 c1                	mov    %eax,%ecx
  801cc5:	89 e8                	mov    %ebp,%eax
  801cc7:	d3 e7                	shl    %cl,%edi
  801cc9:	89 d1                	mov    %edx,%ecx
  801ccb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801ccf:	d3 e8                	shr    %cl,%eax
  801cd1:	89 c1                	mov    %eax,%ecx
  801cd3:	8b 44 24 04          	mov    0x4(%esp),%eax
  801cd7:	09 f9                	or     %edi,%ecx
  801cd9:	89 df                	mov    %ebx,%edi
  801cdb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cdf:	89 c1                	mov    %eax,%ecx
  801ce1:	d3 e5                	shl    %cl,%ebp
  801ce3:	89 d1                	mov    %edx,%ecx
  801ce5:	d3 ef                	shr    %cl,%edi
  801ce7:	89 c1                	mov    %eax,%ecx
  801ce9:	89 f0                	mov    %esi,%eax
  801ceb:	d3 e3                	shl    %cl,%ebx
  801ced:	89 d1                	mov    %edx,%ecx
  801cef:	89 fa                	mov    %edi,%edx
  801cf1:	d3 e8                	shr    %cl,%eax
  801cf3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801cf8:	09 d8                	or     %ebx,%eax
  801cfa:	f7 74 24 08          	divl   0x8(%esp)
  801cfe:	89 d3                	mov    %edx,%ebx
  801d00:	d3 e6                	shl    %cl,%esi
  801d02:	f7 e5                	mul    %ebp
  801d04:	89 c7                	mov    %eax,%edi
  801d06:	89 d1                	mov    %edx,%ecx
  801d08:	39 d3                	cmp    %edx,%ebx
  801d0a:	72 06                	jb     801d12 <__umoddi3+0xe2>
  801d0c:	75 0e                	jne    801d1c <__umoddi3+0xec>
  801d0e:	39 c6                	cmp    %eax,%esi
  801d10:	73 0a                	jae    801d1c <__umoddi3+0xec>
  801d12:	29 e8                	sub    %ebp,%eax
  801d14:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801d18:	89 d1                	mov    %edx,%ecx
  801d1a:	89 c7                	mov    %eax,%edi
  801d1c:	89 f5                	mov    %esi,%ebp
  801d1e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801d22:	29 fd                	sub    %edi,%ebp
  801d24:	19 cb                	sbb    %ecx,%ebx
  801d26:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d2b:	89 d8                	mov    %ebx,%eax
  801d2d:	d3 e0                	shl    %cl,%eax
  801d2f:	89 f1                	mov    %esi,%ecx
  801d31:	d3 ed                	shr    %cl,%ebp
  801d33:	d3 eb                	shr    %cl,%ebx
  801d35:	09 e8                	or     %ebp,%eax
  801d37:	89 da                	mov    %ebx,%edx
  801d39:	83 c4 1c             	add    $0x1c,%esp
  801d3c:	5b                   	pop    %ebx
  801d3d:	5e                   	pop    %esi
  801d3e:	5f                   	pop    %edi
  801d3f:	5d                   	pop    %ebp
  801d40:	c3                   	ret    
