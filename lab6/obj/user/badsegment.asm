
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
  800086:	e8 ee 04 00 00       	call   800579 <close_all>
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
  800107:	68 2a 22 80 00       	push   $0x80222a
  80010c:	6a 2a                	push   $0x2a
  80010e:	68 47 22 80 00       	push   $0x802247
  800113:	e8 9e 13 00 00       	call   8014b6 <_panic>

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
  800188:	68 2a 22 80 00       	push   $0x80222a
  80018d:	6a 2a                	push   $0x2a
  80018f:	68 47 22 80 00       	push   $0x802247
  800194:	e8 1d 13 00 00       	call   8014b6 <_panic>

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
  8001ca:	68 2a 22 80 00       	push   $0x80222a
  8001cf:	6a 2a                	push   $0x2a
  8001d1:	68 47 22 80 00       	push   $0x802247
  8001d6:	e8 db 12 00 00       	call   8014b6 <_panic>

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
  80020c:	68 2a 22 80 00       	push   $0x80222a
  800211:	6a 2a                	push   $0x2a
  800213:	68 47 22 80 00       	push   $0x802247
  800218:	e8 99 12 00 00       	call   8014b6 <_panic>

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
  80024e:	68 2a 22 80 00       	push   $0x80222a
  800253:	6a 2a                	push   $0x2a
  800255:	68 47 22 80 00       	push   $0x802247
  80025a:	e8 57 12 00 00       	call   8014b6 <_panic>

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
  800290:	68 2a 22 80 00       	push   $0x80222a
  800295:	6a 2a                	push   $0x2a
  800297:	68 47 22 80 00       	push   $0x802247
  80029c:	e8 15 12 00 00       	call   8014b6 <_panic>

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
  8002d2:	68 2a 22 80 00       	push   $0x80222a
  8002d7:	6a 2a                	push   $0x2a
  8002d9:	68 47 22 80 00       	push   $0x802247
  8002de:	e8 d3 11 00 00       	call   8014b6 <_panic>

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
  800336:	68 2a 22 80 00       	push   $0x80222a
  80033b:	6a 2a                	push   $0x2a
  80033d:	68 47 22 80 00       	push   $0x802247
  800342:	e8 6f 11 00 00       	call   8014b6 <_panic>

00800347 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	57                   	push   %edi
  80034b:	56                   	push   %esi
  80034c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	b8 0e 00 00 00       	mov    $0xe,%eax
  800357:	89 d1                	mov    %edx,%ecx
  800359:	89 d3                	mov    %edx,%ebx
  80035b:	89 d7                	mov    %edx,%edi
  80035d:	89 d6                	mov    %edx,%esi
  80035f:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800361:	5b                   	pop    %ebx
  800362:	5e                   	pop    %esi
  800363:	5f                   	pop    %edi
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	57                   	push   %edi
  80036a:	56                   	push   %esi
  80036b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80036c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800371:	8b 55 08             	mov    0x8(%ebp),%edx
  800374:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800377:	b8 0f 00 00 00       	mov    $0xf,%eax
  80037c:	89 df                	mov    %ebx,%edi
  80037e:	89 de                	mov    %ebx,%esi
  800380:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800382:	5b                   	pop    %ebx
  800383:	5e                   	pop    %esi
  800384:	5f                   	pop    %edi
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    

00800387 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	57                   	push   %edi
  80038b:	56                   	push   %esi
  80038c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80038d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800392:	8b 55 08             	mov    0x8(%ebp),%edx
  800395:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800398:	b8 10 00 00 00       	mov    $0x10,%eax
  80039d:	89 df                	mov    %ebx,%edi
  80039f:	89 de                	mov    %ebx,%esi
  8003a1:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8003a3:	5b                   	pop    %ebx
  8003a4:	5e                   	pop    %esi
  8003a5:	5f                   	pop    %edi
  8003a6:	5d                   	pop    %ebp
  8003a7:	c3                   	ret    

008003a8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ae:	05 00 00 00 30       	add    $0x30000000,%eax
  8003b3:	c1 e8 0c             	shr    $0xc,%eax
}
  8003b6:	5d                   	pop    %ebp
  8003b7:	c3                   	ret    

008003b8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003be:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003c8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003d7:	89 c2                	mov    %eax,%edx
  8003d9:	c1 ea 16             	shr    $0x16,%edx
  8003dc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e3:	f6 c2 01             	test   $0x1,%dl
  8003e6:	74 29                	je     800411 <fd_alloc+0x42>
  8003e8:	89 c2                	mov    %eax,%edx
  8003ea:	c1 ea 0c             	shr    $0xc,%edx
  8003ed:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f4:	f6 c2 01             	test   $0x1,%dl
  8003f7:	74 18                	je     800411 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8003f9:	05 00 10 00 00       	add    $0x1000,%eax
  8003fe:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800403:	75 d2                	jne    8003d7 <fd_alloc+0x8>
  800405:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80040a:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80040f:	eb 05                	jmp    800416 <fd_alloc+0x47>
			return 0;
  800411:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800416:	8b 55 08             	mov    0x8(%ebp),%edx
  800419:	89 02                	mov    %eax,(%edx)
}
  80041b:	89 c8                	mov    %ecx,%eax
  80041d:	5d                   	pop    %ebp
  80041e:	c3                   	ret    

0080041f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800425:	83 f8 1f             	cmp    $0x1f,%eax
  800428:	77 30                	ja     80045a <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80042a:	c1 e0 0c             	shl    $0xc,%eax
  80042d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800432:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800438:	f6 c2 01             	test   $0x1,%dl
  80043b:	74 24                	je     800461 <fd_lookup+0x42>
  80043d:	89 c2                	mov    %eax,%edx
  80043f:	c1 ea 0c             	shr    $0xc,%edx
  800442:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800449:	f6 c2 01             	test   $0x1,%dl
  80044c:	74 1a                	je     800468 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80044e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800451:	89 02                	mov    %eax,(%edx)
	return 0;
  800453:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800458:	5d                   	pop    %ebp
  800459:	c3                   	ret    
		return -E_INVAL;
  80045a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80045f:	eb f7                	jmp    800458 <fd_lookup+0x39>
		return -E_INVAL;
  800461:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800466:	eb f0                	jmp    800458 <fd_lookup+0x39>
  800468:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80046d:	eb e9                	jmp    800458 <fd_lookup+0x39>

0080046f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80046f:	55                   	push   %ebp
  800470:	89 e5                	mov    %esp,%ebp
  800472:	53                   	push   %ebx
  800473:	83 ec 04             	sub    $0x4,%esp
  800476:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800479:	b8 00 00 00 00       	mov    $0x0,%eax
  80047e:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800483:	39 13                	cmp    %edx,(%ebx)
  800485:	74 37                	je     8004be <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800487:	83 c0 01             	add    $0x1,%eax
  80048a:	8b 1c 85 d4 22 80 00 	mov    0x8022d4(,%eax,4),%ebx
  800491:	85 db                	test   %ebx,%ebx
  800493:	75 ee                	jne    800483 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800495:	a1 00 40 80 00       	mov    0x804000,%eax
  80049a:	8b 40 48             	mov    0x48(%eax),%eax
  80049d:	83 ec 04             	sub    $0x4,%esp
  8004a0:	52                   	push   %edx
  8004a1:	50                   	push   %eax
  8004a2:	68 58 22 80 00       	push   $0x802258
  8004a7:	e8 e5 10 00 00       	call   801591 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8004b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004b7:	89 1a                	mov    %ebx,(%edx)
}
  8004b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004bc:	c9                   	leave  
  8004bd:	c3                   	ret    
			return 0;
  8004be:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c3:	eb ef                	jmp    8004b4 <dev_lookup+0x45>

008004c5 <fd_close>:
{
  8004c5:	55                   	push   %ebp
  8004c6:	89 e5                	mov    %esp,%ebp
  8004c8:	57                   	push   %edi
  8004c9:	56                   	push   %esi
  8004ca:	53                   	push   %ebx
  8004cb:	83 ec 24             	sub    $0x24,%esp
  8004ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004d4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004d7:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004d8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004de:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e1:	50                   	push   %eax
  8004e2:	e8 38 ff ff ff       	call   80041f <fd_lookup>
  8004e7:	89 c3                	mov    %eax,%ebx
  8004e9:	83 c4 10             	add    $0x10,%esp
  8004ec:	85 c0                	test   %eax,%eax
  8004ee:	78 05                	js     8004f5 <fd_close+0x30>
	    || fd != fd2)
  8004f0:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004f3:	74 16                	je     80050b <fd_close+0x46>
		return (must_exist ? r : 0);
  8004f5:	89 f8                	mov    %edi,%eax
  8004f7:	84 c0                	test   %al,%al
  8004f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fe:	0f 44 d8             	cmove  %eax,%ebx
}
  800501:	89 d8                	mov    %ebx,%eax
  800503:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800506:	5b                   	pop    %ebx
  800507:	5e                   	pop    %esi
  800508:	5f                   	pop    %edi
  800509:	5d                   	pop    %ebp
  80050a:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800511:	50                   	push   %eax
  800512:	ff 36                	push   (%esi)
  800514:	e8 56 ff ff ff       	call   80046f <dev_lookup>
  800519:	89 c3                	mov    %eax,%ebx
  80051b:	83 c4 10             	add    $0x10,%esp
  80051e:	85 c0                	test   %eax,%eax
  800520:	78 1a                	js     80053c <fd_close+0x77>
		if (dev->dev_close)
  800522:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800525:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800528:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80052d:	85 c0                	test   %eax,%eax
  80052f:	74 0b                	je     80053c <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800531:	83 ec 0c             	sub    $0xc,%esp
  800534:	56                   	push   %esi
  800535:	ff d0                	call   *%eax
  800537:	89 c3                	mov    %eax,%ebx
  800539:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80053c:	83 ec 08             	sub    $0x8,%esp
  80053f:	56                   	push   %esi
  800540:	6a 00                	push   $0x0
  800542:	e8 94 fc ff ff       	call   8001db <sys_page_unmap>
	return r;
  800547:	83 c4 10             	add    $0x10,%esp
  80054a:	eb b5                	jmp    800501 <fd_close+0x3c>

0080054c <close>:

int
close(int fdnum)
{
  80054c:	55                   	push   %ebp
  80054d:	89 e5                	mov    %esp,%ebp
  80054f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800552:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800555:	50                   	push   %eax
  800556:	ff 75 08             	push   0x8(%ebp)
  800559:	e8 c1 fe ff ff       	call   80041f <fd_lookup>
  80055e:	83 c4 10             	add    $0x10,%esp
  800561:	85 c0                	test   %eax,%eax
  800563:	79 02                	jns    800567 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800565:	c9                   	leave  
  800566:	c3                   	ret    
		return fd_close(fd, 1);
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	6a 01                	push   $0x1
  80056c:	ff 75 f4             	push   -0xc(%ebp)
  80056f:	e8 51 ff ff ff       	call   8004c5 <fd_close>
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	eb ec                	jmp    800565 <close+0x19>

00800579 <close_all>:

void
close_all(void)
{
  800579:	55                   	push   %ebp
  80057a:	89 e5                	mov    %esp,%ebp
  80057c:	53                   	push   %ebx
  80057d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800580:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800585:	83 ec 0c             	sub    $0xc,%esp
  800588:	53                   	push   %ebx
  800589:	e8 be ff ff ff       	call   80054c <close>
	for (i = 0; i < MAXFD; i++)
  80058e:	83 c3 01             	add    $0x1,%ebx
  800591:	83 c4 10             	add    $0x10,%esp
  800594:	83 fb 20             	cmp    $0x20,%ebx
  800597:	75 ec                	jne    800585 <close_all+0xc>
}
  800599:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80059c:	c9                   	leave  
  80059d:	c3                   	ret    

0080059e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80059e:	55                   	push   %ebp
  80059f:	89 e5                	mov    %esp,%ebp
  8005a1:	57                   	push   %edi
  8005a2:	56                   	push   %esi
  8005a3:	53                   	push   %ebx
  8005a4:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005a7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005aa:	50                   	push   %eax
  8005ab:	ff 75 08             	push   0x8(%ebp)
  8005ae:	e8 6c fe ff ff       	call   80041f <fd_lookup>
  8005b3:	89 c3                	mov    %eax,%ebx
  8005b5:	83 c4 10             	add    $0x10,%esp
  8005b8:	85 c0                	test   %eax,%eax
  8005ba:	78 7f                	js     80063b <dup+0x9d>
		return r;
	close(newfdnum);
  8005bc:	83 ec 0c             	sub    $0xc,%esp
  8005bf:	ff 75 0c             	push   0xc(%ebp)
  8005c2:	e8 85 ff ff ff       	call   80054c <close>

	newfd = INDEX2FD(newfdnum);
  8005c7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005ca:	c1 e6 0c             	shl    $0xc,%esi
  8005cd:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d6:	89 3c 24             	mov    %edi,(%esp)
  8005d9:	e8 da fd ff ff       	call   8003b8 <fd2data>
  8005de:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005e0:	89 34 24             	mov    %esi,(%esp)
  8005e3:	e8 d0 fd ff ff       	call   8003b8 <fd2data>
  8005e8:	83 c4 10             	add    $0x10,%esp
  8005eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005ee:	89 d8                	mov    %ebx,%eax
  8005f0:	c1 e8 16             	shr    $0x16,%eax
  8005f3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005fa:	a8 01                	test   $0x1,%al
  8005fc:	74 11                	je     80060f <dup+0x71>
  8005fe:	89 d8                	mov    %ebx,%eax
  800600:	c1 e8 0c             	shr    $0xc,%eax
  800603:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80060a:	f6 c2 01             	test   $0x1,%dl
  80060d:	75 36                	jne    800645 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060f:	89 f8                	mov    %edi,%eax
  800611:	c1 e8 0c             	shr    $0xc,%eax
  800614:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80061b:	83 ec 0c             	sub    $0xc,%esp
  80061e:	25 07 0e 00 00       	and    $0xe07,%eax
  800623:	50                   	push   %eax
  800624:	56                   	push   %esi
  800625:	6a 00                	push   $0x0
  800627:	57                   	push   %edi
  800628:	6a 00                	push   $0x0
  80062a:	e8 6a fb ff ff       	call   800199 <sys_page_map>
  80062f:	89 c3                	mov    %eax,%ebx
  800631:	83 c4 20             	add    $0x20,%esp
  800634:	85 c0                	test   %eax,%eax
  800636:	78 33                	js     80066b <dup+0xcd>
		goto err;

	return newfdnum;
  800638:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80063b:	89 d8                	mov    %ebx,%eax
  80063d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800640:	5b                   	pop    %ebx
  800641:	5e                   	pop    %esi
  800642:	5f                   	pop    %edi
  800643:	5d                   	pop    %ebp
  800644:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800645:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80064c:	83 ec 0c             	sub    $0xc,%esp
  80064f:	25 07 0e 00 00       	and    $0xe07,%eax
  800654:	50                   	push   %eax
  800655:	ff 75 d4             	push   -0x2c(%ebp)
  800658:	6a 00                	push   $0x0
  80065a:	53                   	push   %ebx
  80065b:	6a 00                	push   $0x0
  80065d:	e8 37 fb ff ff       	call   800199 <sys_page_map>
  800662:	89 c3                	mov    %eax,%ebx
  800664:	83 c4 20             	add    $0x20,%esp
  800667:	85 c0                	test   %eax,%eax
  800669:	79 a4                	jns    80060f <dup+0x71>
	sys_page_unmap(0, newfd);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	56                   	push   %esi
  80066f:	6a 00                	push   $0x0
  800671:	e8 65 fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  800676:	83 c4 08             	add    $0x8,%esp
  800679:	ff 75 d4             	push   -0x2c(%ebp)
  80067c:	6a 00                	push   $0x0
  80067e:	e8 58 fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	eb b3                	jmp    80063b <dup+0x9d>

00800688 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	56                   	push   %esi
  80068c:	53                   	push   %ebx
  80068d:	83 ec 18             	sub    $0x18,%esp
  800690:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800693:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800696:	50                   	push   %eax
  800697:	56                   	push   %esi
  800698:	e8 82 fd ff ff       	call   80041f <fd_lookup>
  80069d:	83 c4 10             	add    $0x10,%esp
  8006a0:	85 c0                	test   %eax,%eax
  8006a2:	78 3c                	js     8006e0 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a4:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006ad:	50                   	push   %eax
  8006ae:	ff 33                	push   (%ebx)
  8006b0:	e8 ba fd ff ff       	call   80046f <dev_lookup>
  8006b5:	83 c4 10             	add    $0x10,%esp
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	78 24                	js     8006e0 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006bc:	8b 43 08             	mov    0x8(%ebx),%eax
  8006bf:	83 e0 03             	and    $0x3,%eax
  8006c2:	83 f8 01             	cmp    $0x1,%eax
  8006c5:	74 20                	je     8006e7 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ca:	8b 40 08             	mov    0x8(%eax),%eax
  8006cd:	85 c0                	test   %eax,%eax
  8006cf:	74 37                	je     800708 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006d1:	83 ec 04             	sub    $0x4,%esp
  8006d4:	ff 75 10             	push   0x10(%ebp)
  8006d7:	ff 75 0c             	push   0xc(%ebp)
  8006da:	53                   	push   %ebx
  8006db:	ff d0                	call   *%eax
  8006dd:	83 c4 10             	add    $0x10,%esp
}
  8006e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006e3:	5b                   	pop    %ebx
  8006e4:	5e                   	pop    %esi
  8006e5:	5d                   	pop    %ebp
  8006e6:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006e7:	a1 00 40 80 00       	mov    0x804000,%eax
  8006ec:	8b 40 48             	mov    0x48(%eax),%eax
  8006ef:	83 ec 04             	sub    $0x4,%esp
  8006f2:	56                   	push   %esi
  8006f3:	50                   	push   %eax
  8006f4:	68 99 22 80 00       	push   $0x802299
  8006f9:	e8 93 0e 00 00       	call   801591 <cprintf>
		return -E_INVAL;
  8006fe:	83 c4 10             	add    $0x10,%esp
  800701:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800706:	eb d8                	jmp    8006e0 <read+0x58>
		return -E_NOT_SUPP;
  800708:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80070d:	eb d1                	jmp    8006e0 <read+0x58>

0080070f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	57                   	push   %edi
  800713:	56                   	push   %esi
  800714:	53                   	push   %ebx
  800715:	83 ec 0c             	sub    $0xc,%esp
  800718:	8b 7d 08             	mov    0x8(%ebp),%edi
  80071b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80071e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800723:	eb 02                	jmp    800727 <readn+0x18>
  800725:	01 c3                	add    %eax,%ebx
  800727:	39 f3                	cmp    %esi,%ebx
  800729:	73 21                	jae    80074c <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80072b:	83 ec 04             	sub    $0x4,%esp
  80072e:	89 f0                	mov    %esi,%eax
  800730:	29 d8                	sub    %ebx,%eax
  800732:	50                   	push   %eax
  800733:	89 d8                	mov    %ebx,%eax
  800735:	03 45 0c             	add    0xc(%ebp),%eax
  800738:	50                   	push   %eax
  800739:	57                   	push   %edi
  80073a:	e8 49 ff ff ff       	call   800688 <read>
		if (m < 0)
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	85 c0                	test   %eax,%eax
  800744:	78 04                	js     80074a <readn+0x3b>
			return m;
		if (m == 0)
  800746:	75 dd                	jne    800725 <readn+0x16>
  800748:	eb 02                	jmp    80074c <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80074a:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80074c:	89 d8                	mov    %ebx,%eax
  80074e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800751:	5b                   	pop    %ebx
  800752:	5e                   	pop    %esi
  800753:	5f                   	pop    %edi
  800754:	5d                   	pop    %ebp
  800755:	c3                   	ret    

00800756 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	56                   	push   %esi
  80075a:	53                   	push   %ebx
  80075b:	83 ec 18             	sub    $0x18,%esp
  80075e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800761:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800764:	50                   	push   %eax
  800765:	53                   	push   %ebx
  800766:	e8 b4 fc ff ff       	call   80041f <fd_lookup>
  80076b:	83 c4 10             	add    $0x10,%esp
  80076e:	85 c0                	test   %eax,%eax
  800770:	78 37                	js     8007a9 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800772:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800775:	83 ec 08             	sub    $0x8,%esp
  800778:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80077b:	50                   	push   %eax
  80077c:	ff 36                	push   (%esi)
  80077e:	e8 ec fc ff ff       	call   80046f <dev_lookup>
  800783:	83 c4 10             	add    $0x10,%esp
  800786:	85 c0                	test   %eax,%eax
  800788:	78 1f                	js     8007a9 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80078a:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80078e:	74 20                	je     8007b0 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800790:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800793:	8b 40 0c             	mov    0xc(%eax),%eax
  800796:	85 c0                	test   %eax,%eax
  800798:	74 37                	je     8007d1 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80079a:	83 ec 04             	sub    $0x4,%esp
  80079d:	ff 75 10             	push   0x10(%ebp)
  8007a0:	ff 75 0c             	push   0xc(%ebp)
  8007a3:	56                   	push   %esi
  8007a4:	ff d0                	call   *%eax
  8007a6:	83 c4 10             	add    $0x10,%esp
}
  8007a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007ac:	5b                   	pop    %ebx
  8007ad:	5e                   	pop    %esi
  8007ae:	5d                   	pop    %ebp
  8007af:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007b0:	a1 00 40 80 00       	mov    0x804000,%eax
  8007b5:	8b 40 48             	mov    0x48(%eax),%eax
  8007b8:	83 ec 04             	sub    $0x4,%esp
  8007bb:	53                   	push   %ebx
  8007bc:	50                   	push   %eax
  8007bd:	68 b5 22 80 00       	push   $0x8022b5
  8007c2:	e8 ca 0d 00 00       	call   801591 <cprintf>
		return -E_INVAL;
  8007c7:	83 c4 10             	add    $0x10,%esp
  8007ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007cf:	eb d8                	jmp    8007a9 <write+0x53>
		return -E_NOT_SUPP;
  8007d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007d6:	eb d1                	jmp    8007a9 <write+0x53>

008007d8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e1:	50                   	push   %eax
  8007e2:	ff 75 08             	push   0x8(%ebp)
  8007e5:	e8 35 fc ff ff       	call   80041f <fd_lookup>
  8007ea:	83 c4 10             	add    $0x10,%esp
  8007ed:	85 c0                	test   %eax,%eax
  8007ef:	78 0e                	js     8007ff <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ff:	c9                   	leave  
  800800:	c3                   	ret    

00800801 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	56                   	push   %esi
  800805:	53                   	push   %ebx
  800806:	83 ec 18             	sub    $0x18,%esp
  800809:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80080c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80080f:	50                   	push   %eax
  800810:	53                   	push   %ebx
  800811:	e8 09 fc ff ff       	call   80041f <fd_lookup>
  800816:	83 c4 10             	add    $0x10,%esp
  800819:	85 c0                	test   %eax,%eax
  80081b:	78 34                	js     800851 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80081d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800820:	83 ec 08             	sub    $0x8,%esp
  800823:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800826:	50                   	push   %eax
  800827:	ff 36                	push   (%esi)
  800829:	e8 41 fc ff ff       	call   80046f <dev_lookup>
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	85 c0                	test   %eax,%eax
  800833:	78 1c                	js     800851 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800835:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800839:	74 1d                	je     800858 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80083b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083e:	8b 40 18             	mov    0x18(%eax),%eax
  800841:	85 c0                	test   %eax,%eax
  800843:	74 34                	je     800879 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800845:	83 ec 08             	sub    $0x8,%esp
  800848:	ff 75 0c             	push   0xc(%ebp)
  80084b:	56                   	push   %esi
  80084c:	ff d0                	call   *%eax
  80084e:	83 c4 10             	add    $0x10,%esp
}
  800851:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800854:	5b                   	pop    %ebx
  800855:	5e                   	pop    %esi
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    
			thisenv->env_id, fdnum);
  800858:	a1 00 40 80 00       	mov    0x804000,%eax
  80085d:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800860:	83 ec 04             	sub    $0x4,%esp
  800863:	53                   	push   %ebx
  800864:	50                   	push   %eax
  800865:	68 78 22 80 00       	push   $0x802278
  80086a:	e8 22 0d 00 00       	call   801591 <cprintf>
		return -E_INVAL;
  80086f:	83 c4 10             	add    $0x10,%esp
  800872:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800877:	eb d8                	jmp    800851 <ftruncate+0x50>
		return -E_NOT_SUPP;
  800879:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80087e:	eb d1                	jmp    800851 <ftruncate+0x50>

00800880 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	56                   	push   %esi
  800884:	53                   	push   %ebx
  800885:	83 ec 18             	sub    $0x18,%esp
  800888:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80088b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80088e:	50                   	push   %eax
  80088f:	ff 75 08             	push   0x8(%ebp)
  800892:	e8 88 fb ff ff       	call   80041f <fd_lookup>
  800897:	83 c4 10             	add    $0x10,%esp
  80089a:	85 c0                	test   %eax,%eax
  80089c:	78 49                	js     8008e7 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80089e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8008a1:	83 ec 08             	sub    $0x8,%esp
  8008a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a7:	50                   	push   %eax
  8008a8:	ff 36                	push   (%esi)
  8008aa:	e8 c0 fb ff ff       	call   80046f <dev_lookup>
  8008af:	83 c4 10             	add    $0x10,%esp
  8008b2:	85 c0                	test   %eax,%eax
  8008b4:	78 31                	js     8008e7 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8008b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008bd:	74 2f                	je     8008ee <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008bf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c9:	00 00 00 
	stat->st_isdir = 0;
  8008cc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d3:	00 00 00 
	stat->st_dev = dev;
  8008d6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	53                   	push   %ebx
  8008e0:	56                   	push   %esi
  8008e1:	ff 50 14             	call   *0x14(%eax)
  8008e4:	83 c4 10             	add    $0x10,%esp
}
  8008e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ea:	5b                   	pop    %ebx
  8008eb:	5e                   	pop    %esi
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    
		return -E_NOT_SUPP;
  8008ee:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008f3:	eb f2                	jmp    8008e7 <fstat+0x67>

008008f5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008fa:	83 ec 08             	sub    $0x8,%esp
  8008fd:	6a 00                	push   $0x0
  8008ff:	ff 75 08             	push   0x8(%ebp)
  800902:	e8 e4 01 00 00       	call   800aeb <open>
  800907:	89 c3                	mov    %eax,%ebx
  800909:	83 c4 10             	add    $0x10,%esp
  80090c:	85 c0                	test   %eax,%eax
  80090e:	78 1b                	js     80092b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800910:	83 ec 08             	sub    $0x8,%esp
  800913:	ff 75 0c             	push   0xc(%ebp)
  800916:	50                   	push   %eax
  800917:	e8 64 ff ff ff       	call   800880 <fstat>
  80091c:	89 c6                	mov    %eax,%esi
	close(fd);
  80091e:	89 1c 24             	mov    %ebx,(%esp)
  800921:	e8 26 fc ff ff       	call   80054c <close>
	return r;
  800926:	83 c4 10             	add    $0x10,%esp
  800929:	89 f3                	mov    %esi,%ebx
}
  80092b:	89 d8                	mov    %ebx,%eax
  80092d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800930:	5b                   	pop    %ebx
  800931:	5e                   	pop    %esi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	89 c6                	mov    %eax,%esi
  80093b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80093d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800944:	74 27                	je     80096d <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800946:	6a 07                	push   $0x7
  800948:	68 00 50 80 00       	push   $0x805000
  80094d:	56                   	push   %esi
  80094e:	ff 35 00 60 80 00    	push   0x806000
  800954:	e8 b9 15 00 00       	call   801f12 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800959:	83 c4 0c             	add    $0xc,%esp
  80095c:	6a 00                	push   $0x0
  80095e:	53                   	push   %ebx
  80095f:	6a 00                	push   $0x0
  800961:	e8 45 15 00 00       	call   801eab <ipc_recv>
}
  800966:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800969:	5b                   	pop    %ebx
  80096a:	5e                   	pop    %esi
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80096d:	83 ec 0c             	sub    $0xc,%esp
  800970:	6a 01                	push   $0x1
  800972:	e8 ef 15 00 00       	call   801f66 <ipc_find_env>
  800977:	a3 00 60 80 00       	mov    %eax,0x806000
  80097c:	83 c4 10             	add    $0x10,%esp
  80097f:	eb c5                	jmp    800946 <fsipc+0x12>

00800981 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 40 0c             	mov    0xc(%eax),%eax
  80098d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800992:	8b 45 0c             	mov    0xc(%ebp),%eax
  800995:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80099a:	ba 00 00 00 00       	mov    $0x0,%edx
  80099f:	b8 02 00 00 00       	mov    $0x2,%eax
  8009a4:	e8 8b ff ff ff       	call   800934 <fsipc>
}
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <devfile_flush>:
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c1:	b8 06 00 00 00       	mov    $0x6,%eax
  8009c6:	e8 69 ff ff ff       	call   800934 <fsipc>
}
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <devfile_stat>:
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	53                   	push   %ebx
  8009d1:	83 ec 04             	sub    $0x4,%esp
  8009d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	8b 40 0c             	mov    0xc(%eax),%eax
  8009dd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ec:	e8 43 ff ff ff       	call   800934 <fsipc>
  8009f1:	85 c0                	test   %eax,%eax
  8009f3:	78 2c                	js     800a21 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009f5:	83 ec 08             	sub    $0x8,%esp
  8009f8:	68 00 50 80 00       	push   $0x805000
  8009fd:	53                   	push   %ebx
  8009fe:	e8 68 11 00 00       	call   801b6b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a03:	a1 80 50 80 00       	mov    0x805080,%eax
  800a08:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a0e:	a1 84 50 80 00       	mov    0x805084,%eax
  800a13:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a19:	83 c4 10             	add    $0x10,%esp
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a24:	c9                   	leave  
  800a25:	c3                   	ret    

00800a26 <devfile_write>:
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	83 ec 0c             	sub    $0xc,%esp
  800a2c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a2f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a34:	39 d0                	cmp    %edx,%eax
  800a36:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a39:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3c:	8b 52 0c             	mov    0xc(%edx),%edx
  800a3f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a45:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a4a:	50                   	push   %eax
  800a4b:	ff 75 0c             	push   0xc(%ebp)
  800a4e:	68 08 50 80 00       	push   $0x805008
  800a53:	e8 a9 12 00 00       	call   801d01 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a58:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5d:	b8 04 00 00 00       	mov    $0x4,%eax
  800a62:	e8 cd fe ff ff       	call   800934 <fsipc>
}
  800a67:	c9                   	leave  
  800a68:	c3                   	ret    

00800a69 <devfile_read>:
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
  800a6e:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a71:	8b 45 08             	mov    0x8(%ebp),%eax
  800a74:	8b 40 0c             	mov    0xc(%eax),%eax
  800a77:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a7c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a82:	ba 00 00 00 00       	mov    $0x0,%edx
  800a87:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8c:	e8 a3 fe ff ff       	call   800934 <fsipc>
  800a91:	89 c3                	mov    %eax,%ebx
  800a93:	85 c0                	test   %eax,%eax
  800a95:	78 1f                	js     800ab6 <devfile_read+0x4d>
	assert(r <= n);
  800a97:	39 f0                	cmp    %esi,%eax
  800a99:	77 24                	ja     800abf <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a9b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aa0:	7f 33                	jg     800ad5 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aa2:	83 ec 04             	sub    $0x4,%esp
  800aa5:	50                   	push   %eax
  800aa6:	68 00 50 80 00       	push   $0x805000
  800aab:	ff 75 0c             	push   0xc(%ebp)
  800aae:	e8 4e 12 00 00       	call   801d01 <memmove>
	return r;
  800ab3:	83 c4 10             	add    $0x10,%esp
}
  800ab6:	89 d8                	mov    %ebx,%eax
  800ab8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800abb:	5b                   	pop    %ebx
  800abc:	5e                   	pop    %esi
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    
	assert(r <= n);
  800abf:	68 e8 22 80 00       	push   $0x8022e8
  800ac4:	68 ef 22 80 00       	push   $0x8022ef
  800ac9:	6a 7c                	push   $0x7c
  800acb:	68 04 23 80 00       	push   $0x802304
  800ad0:	e8 e1 09 00 00       	call   8014b6 <_panic>
	assert(r <= PGSIZE);
  800ad5:	68 0f 23 80 00       	push   $0x80230f
  800ada:	68 ef 22 80 00       	push   $0x8022ef
  800adf:	6a 7d                	push   $0x7d
  800ae1:	68 04 23 80 00       	push   $0x802304
  800ae6:	e8 cb 09 00 00       	call   8014b6 <_panic>

00800aeb <open>:
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
  800af0:	83 ec 1c             	sub    $0x1c,%esp
  800af3:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800af6:	56                   	push   %esi
  800af7:	e8 34 10 00 00       	call   801b30 <strlen>
  800afc:	83 c4 10             	add    $0x10,%esp
  800aff:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b04:	7f 6c                	jg     800b72 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800b06:	83 ec 0c             	sub    $0xc,%esp
  800b09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b0c:	50                   	push   %eax
  800b0d:	e8 bd f8 ff ff       	call   8003cf <fd_alloc>
  800b12:	89 c3                	mov    %eax,%ebx
  800b14:	83 c4 10             	add    $0x10,%esp
  800b17:	85 c0                	test   %eax,%eax
  800b19:	78 3c                	js     800b57 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800b1b:	83 ec 08             	sub    $0x8,%esp
  800b1e:	56                   	push   %esi
  800b1f:	68 00 50 80 00       	push   $0x805000
  800b24:	e8 42 10 00 00       	call   801b6b <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2c:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b31:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b34:	b8 01 00 00 00       	mov    $0x1,%eax
  800b39:	e8 f6 fd ff ff       	call   800934 <fsipc>
  800b3e:	89 c3                	mov    %eax,%ebx
  800b40:	83 c4 10             	add    $0x10,%esp
  800b43:	85 c0                	test   %eax,%eax
  800b45:	78 19                	js     800b60 <open+0x75>
	return fd2num(fd);
  800b47:	83 ec 0c             	sub    $0xc,%esp
  800b4a:	ff 75 f4             	push   -0xc(%ebp)
  800b4d:	e8 56 f8 ff ff       	call   8003a8 <fd2num>
  800b52:	89 c3                	mov    %eax,%ebx
  800b54:	83 c4 10             	add    $0x10,%esp
}
  800b57:	89 d8                	mov    %ebx,%eax
  800b59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    
		fd_close(fd, 0);
  800b60:	83 ec 08             	sub    $0x8,%esp
  800b63:	6a 00                	push   $0x0
  800b65:	ff 75 f4             	push   -0xc(%ebp)
  800b68:	e8 58 f9 ff ff       	call   8004c5 <fd_close>
		return r;
  800b6d:	83 c4 10             	add    $0x10,%esp
  800b70:	eb e5                	jmp    800b57 <open+0x6c>
		return -E_BAD_PATH;
  800b72:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b77:	eb de                	jmp    800b57 <open+0x6c>

00800b79 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b84:	b8 08 00 00 00       	mov    $0x8,%eax
  800b89:	e8 a6 fd ff ff       	call   800934 <fsipc>
}
  800b8e:	c9                   	leave  
  800b8f:	c3                   	ret    

00800b90 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b96:	68 1b 23 80 00       	push   $0x80231b
  800b9b:	ff 75 0c             	push   0xc(%ebp)
  800b9e:	e8 c8 0f 00 00       	call   801b6b <strcpy>
	return 0;
}
  800ba3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba8:	c9                   	leave  
  800ba9:	c3                   	ret    

00800baa <devsock_close>:
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	53                   	push   %ebx
  800bae:	83 ec 10             	sub    $0x10,%esp
  800bb1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bb4:	53                   	push   %ebx
  800bb5:	e8 e5 13 00 00       	call   801f9f <pageref>
  800bba:	89 c2                	mov    %eax,%edx
  800bbc:	83 c4 10             	add    $0x10,%esp
		return 0;
  800bbf:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800bc4:	83 fa 01             	cmp    $0x1,%edx
  800bc7:	74 05                	je     800bce <devsock_close+0x24>
}
  800bc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bcc:	c9                   	leave  
  800bcd:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800bce:	83 ec 0c             	sub    $0xc,%esp
  800bd1:	ff 73 0c             	push   0xc(%ebx)
  800bd4:	e8 b7 02 00 00       	call   800e90 <nsipc_close>
  800bd9:	83 c4 10             	add    $0x10,%esp
  800bdc:	eb eb                	jmp    800bc9 <devsock_close+0x1f>

00800bde <devsock_write>:
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800be4:	6a 00                	push   $0x0
  800be6:	ff 75 10             	push   0x10(%ebp)
  800be9:	ff 75 0c             	push   0xc(%ebp)
  800bec:	8b 45 08             	mov    0x8(%ebp),%eax
  800bef:	ff 70 0c             	push   0xc(%eax)
  800bf2:	e8 79 03 00 00       	call   800f70 <nsipc_send>
}
  800bf7:	c9                   	leave  
  800bf8:	c3                   	ret    

00800bf9 <devsock_read>:
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800bff:	6a 00                	push   $0x0
  800c01:	ff 75 10             	push   0x10(%ebp)
  800c04:	ff 75 0c             	push   0xc(%ebp)
  800c07:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0a:	ff 70 0c             	push   0xc(%eax)
  800c0d:	e8 ef 02 00 00       	call   800f01 <nsipc_recv>
}
  800c12:	c9                   	leave  
  800c13:	c3                   	ret    

00800c14 <fd2sockid>:
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c1a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c1d:	52                   	push   %edx
  800c1e:	50                   	push   %eax
  800c1f:	e8 fb f7 ff ff       	call   80041f <fd_lookup>
  800c24:	83 c4 10             	add    $0x10,%esp
  800c27:	85 c0                	test   %eax,%eax
  800c29:	78 10                	js     800c3b <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c2e:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c34:	39 08                	cmp    %ecx,(%eax)
  800c36:	75 05                	jne    800c3d <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c38:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c3b:	c9                   	leave  
  800c3c:	c3                   	ret    
		return -E_NOT_SUPP;
  800c3d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c42:	eb f7                	jmp    800c3b <fd2sockid+0x27>

00800c44 <alloc_sockfd>:
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 1c             	sub    $0x1c,%esp
  800c4c:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c51:	50                   	push   %eax
  800c52:	e8 78 f7 ff ff       	call   8003cf <fd_alloc>
  800c57:	89 c3                	mov    %eax,%ebx
  800c59:	83 c4 10             	add    $0x10,%esp
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	78 43                	js     800ca3 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c60:	83 ec 04             	sub    $0x4,%esp
  800c63:	68 07 04 00 00       	push   $0x407
  800c68:	ff 75 f4             	push   -0xc(%ebp)
  800c6b:	6a 00                	push   $0x0
  800c6d:	e8 e4 f4 ff ff       	call   800156 <sys_page_alloc>
  800c72:	89 c3                	mov    %eax,%ebx
  800c74:	83 c4 10             	add    $0x10,%esp
  800c77:	85 c0                	test   %eax,%eax
  800c79:	78 28                	js     800ca3 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c7e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c84:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c89:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c90:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c93:	83 ec 0c             	sub    $0xc,%esp
  800c96:	50                   	push   %eax
  800c97:	e8 0c f7 ff ff       	call   8003a8 <fd2num>
  800c9c:	89 c3                	mov    %eax,%ebx
  800c9e:	83 c4 10             	add    $0x10,%esp
  800ca1:	eb 0c                	jmp    800caf <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	56                   	push   %esi
  800ca7:	e8 e4 01 00 00       	call   800e90 <nsipc_close>
		return r;
  800cac:	83 c4 10             	add    $0x10,%esp
}
  800caf:	89 d8                	mov    %ebx,%eax
  800cb1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <accept>:
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc1:	e8 4e ff ff ff       	call   800c14 <fd2sockid>
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	78 1b                	js     800ce5 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cca:	83 ec 04             	sub    $0x4,%esp
  800ccd:	ff 75 10             	push   0x10(%ebp)
  800cd0:	ff 75 0c             	push   0xc(%ebp)
  800cd3:	50                   	push   %eax
  800cd4:	e8 0e 01 00 00       	call   800de7 <nsipc_accept>
  800cd9:	83 c4 10             	add    $0x10,%esp
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	78 05                	js     800ce5 <accept+0x2d>
	return alloc_sockfd(r);
  800ce0:	e8 5f ff ff ff       	call   800c44 <alloc_sockfd>
}
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    

00800ce7 <bind>:
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800ced:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf0:	e8 1f ff ff ff       	call   800c14 <fd2sockid>
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	78 12                	js     800d0b <bind+0x24>
	return nsipc_bind(r, name, namelen);
  800cf9:	83 ec 04             	sub    $0x4,%esp
  800cfc:	ff 75 10             	push   0x10(%ebp)
  800cff:	ff 75 0c             	push   0xc(%ebp)
  800d02:	50                   	push   %eax
  800d03:	e8 31 01 00 00       	call   800e39 <nsipc_bind>
  800d08:	83 c4 10             	add    $0x10,%esp
}
  800d0b:	c9                   	leave  
  800d0c:	c3                   	ret    

00800d0d <shutdown>:
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d13:	8b 45 08             	mov    0x8(%ebp),%eax
  800d16:	e8 f9 fe ff ff       	call   800c14 <fd2sockid>
  800d1b:	85 c0                	test   %eax,%eax
  800d1d:	78 0f                	js     800d2e <shutdown+0x21>
	return nsipc_shutdown(r, how);
  800d1f:	83 ec 08             	sub    $0x8,%esp
  800d22:	ff 75 0c             	push   0xc(%ebp)
  800d25:	50                   	push   %eax
  800d26:	e8 43 01 00 00       	call   800e6e <nsipc_shutdown>
  800d2b:	83 c4 10             	add    $0x10,%esp
}
  800d2e:	c9                   	leave  
  800d2f:	c3                   	ret    

00800d30 <connect>:
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d36:	8b 45 08             	mov    0x8(%ebp),%eax
  800d39:	e8 d6 fe ff ff       	call   800c14 <fd2sockid>
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	78 12                	js     800d54 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  800d42:	83 ec 04             	sub    $0x4,%esp
  800d45:	ff 75 10             	push   0x10(%ebp)
  800d48:	ff 75 0c             	push   0xc(%ebp)
  800d4b:	50                   	push   %eax
  800d4c:	e8 59 01 00 00       	call   800eaa <nsipc_connect>
  800d51:	83 c4 10             	add    $0x10,%esp
}
  800d54:	c9                   	leave  
  800d55:	c3                   	ret    

00800d56 <listen>:
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5f:	e8 b0 fe ff ff       	call   800c14 <fd2sockid>
  800d64:	85 c0                	test   %eax,%eax
  800d66:	78 0f                	js     800d77 <listen+0x21>
	return nsipc_listen(r, backlog);
  800d68:	83 ec 08             	sub    $0x8,%esp
  800d6b:	ff 75 0c             	push   0xc(%ebp)
  800d6e:	50                   	push   %eax
  800d6f:	e8 6b 01 00 00       	call   800edf <nsipc_listen>
  800d74:	83 c4 10             	add    $0x10,%esp
}
  800d77:	c9                   	leave  
  800d78:	c3                   	ret    

00800d79 <socket>:

int
socket(int domain, int type, int protocol)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d7f:	ff 75 10             	push   0x10(%ebp)
  800d82:	ff 75 0c             	push   0xc(%ebp)
  800d85:	ff 75 08             	push   0x8(%ebp)
  800d88:	e8 41 02 00 00       	call   800fce <nsipc_socket>
  800d8d:	83 c4 10             	add    $0x10,%esp
  800d90:	85 c0                	test   %eax,%eax
  800d92:	78 05                	js     800d99 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800d94:	e8 ab fe ff ff       	call   800c44 <alloc_sockfd>
}
  800d99:	c9                   	leave  
  800d9a:	c3                   	ret    

00800d9b <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	53                   	push   %ebx
  800d9f:	83 ec 04             	sub    $0x4,%esp
  800da2:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800da4:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  800dab:	74 26                	je     800dd3 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dad:	6a 07                	push   $0x7
  800daf:	68 00 70 80 00       	push   $0x807000
  800db4:	53                   	push   %ebx
  800db5:	ff 35 00 80 80 00    	push   0x808000
  800dbb:	e8 52 11 00 00       	call   801f12 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dc0:	83 c4 0c             	add    $0xc,%esp
  800dc3:	6a 00                	push   $0x0
  800dc5:	6a 00                	push   $0x0
  800dc7:	6a 00                	push   $0x0
  800dc9:	e8 dd 10 00 00       	call   801eab <ipc_recv>
}
  800dce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dd1:	c9                   	leave  
  800dd2:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dd3:	83 ec 0c             	sub    $0xc,%esp
  800dd6:	6a 02                	push   $0x2
  800dd8:	e8 89 11 00 00       	call   801f66 <ipc_find_env>
  800ddd:	a3 00 80 80 00       	mov    %eax,0x808000
  800de2:	83 c4 10             	add    $0x10,%esp
  800de5:	eb c6                	jmp    800dad <nsipc+0x12>

00800de7 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
  800dec:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800def:	8b 45 08             	mov    0x8(%ebp),%eax
  800df2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800df7:	8b 06                	mov    (%esi),%eax
  800df9:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800dfe:	b8 01 00 00 00       	mov    $0x1,%eax
  800e03:	e8 93 ff ff ff       	call   800d9b <nsipc>
  800e08:	89 c3                	mov    %eax,%ebx
  800e0a:	85 c0                	test   %eax,%eax
  800e0c:	79 09                	jns    800e17 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800e0e:	89 d8                	mov    %ebx,%eax
  800e10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e17:	83 ec 04             	sub    $0x4,%esp
  800e1a:	ff 35 10 70 80 00    	push   0x807010
  800e20:	68 00 70 80 00       	push   $0x807000
  800e25:	ff 75 0c             	push   0xc(%ebp)
  800e28:	e8 d4 0e 00 00       	call   801d01 <memmove>
		*addrlen = ret->ret_addrlen;
  800e2d:	a1 10 70 80 00       	mov    0x807010,%eax
  800e32:	89 06                	mov    %eax,(%esi)
  800e34:	83 c4 10             	add    $0x10,%esp
	return r;
  800e37:	eb d5                	jmp    800e0e <nsipc_accept+0x27>

00800e39 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	53                   	push   %ebx
  800e3d:	83 ec 08             	sub    $0x8,%esp
  800e40:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e43:	8b 45 08             	mov    0x8(%ebp),%eax
  800e46:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e4b:	53                   	push   %ebx
  800e4c:	ff 75 0c             	push   0xc(%ebp)
  800e4f:	68 04 70 80 00       	push   $0x807004
  800e54:	e8 a8 0e 00 00       	call   801d01 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e59:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  800e5f:	b8 02 00 00 00       	mov    $0x2,%eax
  800e64:	e8 32 ff ff ff       	call   800d9b <nsipc>
}
  800e69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e6c:	c9                   	leave  
  800e6d:	c3                   	ret    

00800e6e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e74:	8b 45 08             	mov    0x8(%ebp),%eax
  800e77:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  800e7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  800e84:	b8 03 00 00 00       	mov    $0x3,%eax
  800e89:	e8 0d ff ff ff       	call   800d9b <nsipc>
}
  800e8e:	c9                   	leave  
  800e8f:	c3                   	ret    

00800e90 <nsipc_close>:

int
nsipc_close(int s)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e96:	8b 45 08             	mov    0x8(%ebp),%eax
  800e99:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  800e9e:	b8 04 00 00 00       	mov    $0x4,%eax
  800ea3:	e8 f3 fe ff ff       	call   800d9b <nsipc>
}
  800ea8:	c9                   	leave  
  800ea9:	c3                   	ret    

00800eaa <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	53                   	push   %ebx
  800eae:	83 ec 08             	sub    $0x8,%esp
  800eb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb7:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ebc:	53                   	push   %ebx
  800ebd:	ff 75 0c             	push   0xc(%ebp)
  800ec0:	68 04 70 80 00       	push   $0x807004
  800ec5:	e8 37 0e 00 00       	call   801d01 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800eca:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  800ed0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ed5:	e8 c1 fe ff ff       	call   800d9b <nsipc>
}
  800eda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800edd:	c9                   	leave  
  800ede:	c3                   	ret    

00800edf <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ee5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  800eed:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef0:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  800ef5:	b8 06 00 00 00       	mov    $0x6,%eax
  800efa:	e8 9c fe ff ff       	call   800d9b <nsipc>
}
  800eff:	c9                   	leave  
  800f00:	c3                   	ret    

00800f01 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
  800f06:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f09:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  800f11:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  800f17:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1a:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f1f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f24:	e8 72 fe ff ff       	call   800d9b <nsipc>
  800f29:	89 c3                	mov    %eax,%ebx
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	78 22                	js     800f51 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  800f2f:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f34:	39 c6                	cmp    %eax,%esi
  800f36:	0f 4e c6             	cmovle %esi,%eax
  800f39:	39 c3                	cmp    %eax,%ebx
  800f3b:	7f 1d                	jg     800f5a <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f3d:	83 ec 04             	sub    $0x4,%esp
  800f40:	53                   	push   %ebx
  800f41:	68 00 70 80 00       	push   $0x807000
  800f46:	ff 75 0c             	push   0xc(%ebp)
  800f49:	e8 b3 0d 00 00       	call   801d01 <memmove>
  800f4e:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f51:	89 d8                	mov    %ebx,%eax
  800f53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f56:	5b                   	pop    %ebx
  800f57:	5e                   	pop    %esi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f5a:	68 27 23 80 00       	push   $0x802327
  800f5f:	68 ef 22 80 00       	push   $0x8022ef
  800f64:	6a 62                	push   $0x62
  800f66:	68 3c 23 80 00       	push   $0x80233c
  800f6b:	e8 46 05 00 00       	call   8014b6 <_panic>

00800f70 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	53                   	push   %ebx
  800f74:	83 ec 04             	sub    $0x4,%esp
  800f77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7d:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  800f82:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f88:	7f 2e                	jg     800fb8 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f8a:	83 ec 04             	sub    $0x4,%esp
  800f8d:	53                   	push   %ebx
  800f8e:	ff 75 0c             	push   0xc(%ebp)
  800f91:	68 0c 70 80 00       	push   $0x80700c
  800f96:	e8 66 0d 00 00       	call   801d01 <memmove>
	nsipcbuf.send.req_size = size;
  800f9b:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  800fa1:	8b 45 14             	mov    0x14(%ebp),%eax
  800fa4:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  800fa9:	b8 08 00 00 00       	mov    $0x8,%eax
  800fae:	e8 e8 fd ff ff       	call   800d9b <nsipc>
}
  800fb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb6:	c9                   	leave  
  800fb7:	c3                   	ret    
	assert(size < 1600);
  800fb8:	68 48 23 80 00       	push   $0x802348
  800fbd:	68 ef 22 80 00       	push   $0x8022ef
  800fc2:	6a 6d                	push   $0x6d
  800fc4:	68 3c 23 80 00       	push   $0x80233c
  800fc9:	e8 e8 04 00 00       	call   8014b6 <_panic>

00800fce <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  800fdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdf:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  800fe4:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe7:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  800fec:	b8 09 00 00 00       	mov    $0x9,%eax
  800ff1:	e8 a5 fd ff ff       	call   800d9b <nsipc>
}
  800ff6:	c9                   	leave  
  800ff7:	c3                   	ret    

00800ff8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	56                   	push   %esi
  800ffc:	53                   	push   %ebx
  800ffd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801000:	83 ec 0c             	sub    $0xc,%esp
  801003:	ff 75 08             	push   0x8(%ebp)
  801006:	e8 ad f3 ff ff       	call   8003b8 <fd2data>
  80100b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80100d:	83 c4 08             	add    $0x8,%esp
  801010:	68 54 23 80 00       	push   $0x802354
  801015:	53                   	push   %ebx
  801016:	e8 50 0b 00 00       	call   801b6b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80101b:	8b 46 04             	mov    0x4(%esi),%eax
  80101e:	2b 06                	sub    (%esi),%eax
  801020:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801026:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80102d:	00 00 00 
	stat->st_dev = &devpipe;
  801030:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801037:	30 80 00 
	return 0;
}
  80103a:	b8 00 00 00 00       	mov    $0x0,%eax
  80103f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801042:	5b                   	pop    %ebx
  801043:	5e                   	pop    %esi
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    

00801046 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	53                   	push   %ebx
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801050:	53                   	push   %ebx
  801051:	6a 00                	push   $0x0
  801053:	e8 83 f1 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801058:	89 1c 24             	mov    %ebx,(%esp)
  80105b:	e8 58 f3 ff ff       	call   8003b8 <fd2data>
  801060:	83 c4 08             	add    $0x8,%esp
  801063:	50                   	push   %eax
  801064:	6a 00                	push   $0x0
  801066:	e8 70 f1 ff ff       	call   8001db <sys_page_unmap>
}
  80106b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106e:	c9                   	leave  
  80106f:	c3                   	ret    

00801070 <_pipeisclosed>:
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	57                   	push   %edi
  801074:	56                   	push   %esi
  801075:	53                   	push   %ebx
  801076:	83 ec 1c             	sub    $0x1c,%esp
  801079:	89 c7                	mov    %eax,%edi
  80107b:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80107d:	a1 00 40 80 00       	mov    0x804000,%eax
  801082:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801085:	83 ec 0c             	sub    $0xc,%esp
  801088:	57                   	push   %edi
  801089:	e8 11 0f 00 00       	call   801f9f <pageref>
  80108e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801091:	89 34 24             	mov    %esi,(%esp)
  801094:	e8 06 0f 00 00       	call   801f9f <pageref>
		nn = thisenv->env_runs;
  801099:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80109f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010a2:	83 c4 10             	add    $0x10,%esp
  8010a5:	39 cb                	cmp    %ecx,%ebx
  8010a7:	74 1b                	je     8010c4 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010a9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010ac:	75 cf                	jne    80107d <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010ae:	8b 42 58             	mov    0x58(%edx),%eax
  8010b1:	6a 01                	push   $0x1
  8010b3:	50                   	push   %eax
  8010b4:	53                   	push   %ebx
  8010b5:	68 5b 23 80 00       	push   $0x80235b
  8010ba:	e8 d2 04 00 00       	call   801591 <cprintf>
  8010bf:	83 c4 10             	add    $0x10,%esp
  8010c2:	eb b9                	jmp    80107d <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010c4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010c7:	0f 94 c0             	sete   %al
  8010ca:	0f b6 c0             	movzbl %al,%eax
}
  8010cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d0:	5b                   	pop    %ebx
  8010d1:	5e                   	pop    %esi
  8010d2:	5f                   	pop    %edi
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    

008010d5 <devpipe_write>:
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	57                   	push   %edi
  8010d9:	56                   	push   %esi
  8010da:	53                   	push   %ebx
  8010db:	83 ec 28             	sub    $0x28,%esp
  8010de:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8010e1:	56                   	push   %esi
  8010e2:	e8 d1 f2 ff ff       	call   8003b8 <fd2data>
  8010e7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	bf 00 00 00 00       	mov    $0x0,%edi
  8010f1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8010f4:	75 09                	jne    8010ff <devpipe_write+0x2a>
	return i;
  8010f6:	89 f8                	mov    %edi,%eax
  8010f8:	eb 23                	jmp    80111d <devpipe_write+0x48>
			sys_yield();
  8010fa:	e8 38 f0 ff ff       	call   800137 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8010ff:	8b 43 04             	mov    0x4(%ebx),%eax
  801102:	8b 0b                	mov    (%ebx),%ecx
  801104:	8d 51 20             	lea    0x20(%ecx),%edx
  801107:	39 d0                	cmp    %edx,%eax
  801109:	72 1a                	jb     801125 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80110b:	89 da                	mov    %ebx,%edx
  80110d:	89 f0                	mov    %esi,%eax
  80110f:	e8 5c ff ff ff       	call   801070 <_pipeisclosed>
  801114:	85 c0                	test   %eax,%eax
  801116:	74 e2                	je     8010fa <devpipe_write+0x25>
				return 0;
  801118:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80111d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801120:	5b                   	pop    %ebx
  801121:	5e                   	pop    %esi
  801122:	5f                   	pop    %edi
  801123:	5d                   	pop    %ebp
  801124:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801125:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801128:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80112c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80112f:	89 c2                	mov    %eax,%edx
  801131:	c1 fa 1f             	sar    $0x1f,%edx
  801134:	89 d1                	mov    %edx,%ecx
  801136:	c1 e9 1b             	shr    $0x1b,%ecx
  801139:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80113c:	83 e2 1f             	and    $0x1f,%edx
  80113f:	29 ca                	sub    %ecx,%edx
  801141:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801145:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801149:	83 c0 01             	add    $0x1,%eax
  80114c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80114f:	83 c7 01             	add    $0x1,%edi
  801152:	eb 9d                	jmp    8010f1 <devpipe_write+0x1c>

00801154 <devpipe_read>:
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	57                   	push   %edi
  801158:	56                   	push   %esi
  801159:	53                   	push   %ebx
  80115a:	83 ec 18             	sub    $0x18,%esp
  80115d:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801160:	57                   	push   %edi
  801161:	e8 52 f2 ff ff       	call   8003b8 <fd2data>
  801166:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801168:	83 c4 10             	add    $0x10,%esp
  80116b:	be 00 00 00 00       	mov    $0x0,%esi
  801170:	3b 75 10             	cmp    0x10(%ebp),%esi
  801173:	75 13                	jne    801188 <devpipe_read+0x34>
	return i;
  801175:	89 f0                	mov    %esi,%eax
  801177:	eb 02                	jmp    80117b <devpipe_read+0x27>
				return i;
  801179:	89 f0                	mov    %esi,%eax
}
  80117b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117e:	5b                   	pop    %ebx
  80117f:	5e                   	pop    %esi
  801180:	5f                   	pop    %edi
  801181:	5d                   	pop    %ebp
  801182:	c3                   	ret    
			sys_yield();
  801183:	e8 af ef ff ff       	call   800137 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801188:	8b 03                	mov    (%ebx),%eax
  80118a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80118d:	75 18                	jne    8011a7 <devpipe_read+0x53>
			if (i > 0)
  80118f:	85 f6                	test   %esi,%esi
  801191:	75 e6                	jne    801179 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801193:	89 da                	mov    %ebx,%edx
  801195:	89 f8                	mov    %edi,%eax
  801197:	e8 d4 fe ff ff       	call   801070 <_pipeisclosed>
  80119c:	85 c0                	test   %eax,%eax
  80119e:	74 e3                	je     801183 <devpipe_read+0x2f>
				return 0;
  8011a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a5:	eb d4                	jmp    80117b <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011a7:	99                   	cltd   
  8011a8:	c1 ea 1b             	shr    $0x1b,%edx
  8011ab:	01 d0                	add    %edx,%eax
  8011ad:	83 e0 1f             	and    $0x1f,%eax
  8011b0:	29 d0                	sub    %edx,%eax
  8011b2:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ba:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011bd:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011c0:	83 c6 01             	add    $0x1,%esi
  8011c3:	eb ab                	jmp    801170 <devpipe_read+0x1c>

008011c5 <pipe>:
{
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	56                   	push   %esi
  8011c9:	53                   	push   %ebx
  8011ca:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d0:	50                   	push   %eax
  8011d1:	e8 f9 f1 ff ff       	call   8003cf <fd_alloc>
  8011d6:	89 c3                	mov    %eax,%ebx
  8011d8:	83 c4 10             	add    $0x10,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	0f 88 23 01 00 00    	js     801306 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011e3:	83 ec 04             	sub    $0x4,%esp
  8011e6:	68 07 04 00 00       	push   $0x407
  8011eb:	ff 75 f4             	push   -0xc(%ebp)
  8011ee:	6a 00                	push   $0x0
  8011f0:	e8 61 ef ff ff       	call   800156 <sys_page_alloc>
  8011f5:	89 c3                	mov    %eax,%ebx
  8011f7:	83 c4 10             	add    $0x10,%esp
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	0f 88 04 01 00 00    	js     801306 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801202:	83 ec 0c             	sub    $0xc,%esp
  801205:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801208:	50                   	push   %eax
  801209:	e8 c1 f1 ff ff       	call   8003cf <fd_alloc>
  80120e:	89 c3                	mov    %eax,%ebx
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	85 c0                	test   %eax,%eax
  801215:	0f 88 db 00 00 00    	js     8012f6 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80121b:	83 ec 04             	sub    $0x4,%esp
  80121e:	68 07 04 00 00       	push   $0x407
  801223:	ff 75 f0             	push   -0x10(%ebp)
  801226:	6a 00                	push   $0x0
  801228:	e8 29 ef ff ff       	call   800156 <sys_page_alloc>
  80122d:	89 c3                	mov    %eax,%ebx
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	85 c0                	test   %eax,%eax
  801234:	0f 88 bc 00 00 00    	js     8012f6 <pipe+0x131>
	va = fd2data(fd0);
  80123a:	83 ec 0c             	sub    $0xc,%esp
  80123d:	ff 75 f4             	push   -0xc(%ebp)
  801240:	e8 73 f1 ff ff       	call   8003b8 <fd2data>
  801245:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801247:	83 c4 0c             	add    $0xc,%esp
  80124a:	68 07 04 00 00       	push   $0x407
  80124f:	50                   	push   %eax
  801250:	6a 00                	push   $0x0
  801252:	e8 ff ee ff ff       	call   800156 <sys_page_alloc>
  801257:	89 c3                	mov    %eax,%ebx
  801259:	83 c4 10             	add    $0x10,%esp
  80125c:	85 c0                	test   %eax,%eax
  80125e:	0f 88 82 00 00 00    	js     8012e6 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801264:	83 ec 0c             	sub    $0xc,%esp
  801267:	ff 75 f0             	push   -0x10(%ebp)
  80126a:	e8 49 f1 ff ff       	call   8003b8 <fd2data>
  80126f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801276:	50                   	push   %eax
  801277:	6a 00                	push   $0x0
  801279:	56                   	push   %esi
  80127a:	6a 00                	push   $0x0
  80127c:	e8 18 ef ff ff       	call   800199 <sys_page_map>
  801281:	89 c3                	mov    %eax,%ebx
  801283:	83 c4 20             	add    $0x20,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	78 4e                	js     8012d8 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80128a:	a1 3c 30 80 00       	mov    0x80303c,%eax
  80128f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801292:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801294:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801297:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80129e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012a1:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012ad:	83 ec 0c             	sub    $0xc,%esp
  8012b0:	ff 75 f4             	push   -0xc(%ebp)
  8012b3:	e8 f0 f0 ff ff       	call   8003a8 <fd2num>
  8012b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012bb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012bd:	83 c4 04             	add    $0x4,%esp
  8012c0:	ff 75 f0             	push   -0x10(%ebp)
  8012c3:	e8 e0 f0 ff ff       	call   8003a8 <fd2num>
  8012c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012cb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012ce:	83 c4 10             	add    $0x10,%esp
  8012d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d6:	eb 2e                	jmp    801306 <pipe+0x141>
	sys_page_unmap(0, va);
  8012d8:	83 ec 08             	sub    $0x8,%esp
  8012db:	56                   	push   %esi
  8012dc:	6a 00                	push   $0x0
  8012de:	e8 f8 ee ff ff       	call   8001db <sys_page_unmap>
  8012e3:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8012e6:	83 ec 08             	sub    $0x8,%esp
  8012e9:	ff 75 f0             	push   -0x10(%ebp)
  8012ec:	6a 00                	push   $0x0
  8012ee:	e8 e8 ee ff ff       	call   8001db <sys_page_unmap>
  8012f3:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8012f6:	83 ec 08             	sub    $0x8,%esp
  8012f9:	ff 75 f4             	push   -0xc(%ebp)
  8012fc:	6a 00                	push   $0x0
  8012fe:	e8 d8 ee ff ff       	call   8001db <sys_page_unmap>
  801303:	83 c4 10             	add    $0x10,%esp
}
  801306:	89 d8                	mov    %ebx,%eax
  801308:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80130b:	5b                   	pop    %ebx
  80130c:	5e                   	pop    %esi
  80130d:	5d                   	pop    %ebp
  80130e:	c3                   	ret    

0080130f <pipeisclosed>:
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801315:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801318:	50                   	push   %eax
  801319:	ff 75 08             	push   0x8(%ebp)
  80131c:	e8 fe f0 ff ff       	call   80041f <fd_lookup>
  801321:	83 c4 10             	add    $0x10,%esp
  801324:	85 c0                	test   %eax,%eax
  801326:	78 18                	js     801340 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801328:	83 ec 0c             	sub    $0xc,%esp
  80132b:	ff 75 f4             	push   -0xc(%ebp)
  80132e:	e8 85 f0 ff ff       	call   8003b8 <fd2data>
  801333:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801335:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801338:	e8 33 fd ff ff       	call   801070 <_pipeisclosed>
  80133d:	83 c4 10             	add    $0x10,%esp
}
  801340:	c9                   	leave  
  801341:	c3                   	ret    

00801342 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801342:	b8 00 00 00 00       	mov    $0x0,%eax
  801347:	c3                   	ret    

00801348 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80134e:	68 73 23 80 00       	push   $0x802373
  801353:	ff 75 0c             	push   0xc(%ebp)
  801356:	e8 10 08 00 00       	call   801b6b <strcpy>
	return 0;
}
  80135b:	b8 00 00 00 00       	mov    $0x0,%eax
  801360:	c9                   	leave  
  801361:	c3                   	ret    

00801362 <devcons_write>:
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	57                   	push   %edi
  801366:	56                   	push   %esi
  801367:	53                   	push   %ebx
  801368:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80136e:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801373:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801379:	eb 2e                	jmp    8013a9 <devcons_write+0x47>
		m = n - tot;
  80137b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80137e:	29 f3                	sub    %esi,%ebx
  801380:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801385:	39 c3                	cmp    %eax,%ebx
  801387:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80138a:	83 ec 04             	sub    $0x4,%esp
  80138d:	53                   	push   %ebx
  80138e:	89 f0                	mov    %esi,%eax
  801390:	03 45 0c             	add    0xc(%ebp),%eax
  801393:	50                   	push   %eax
  801394:	57                   	push   %edi
  801395:	e8 67 09 00 00       	call   801d01 <memmove>
		sys_cputs(buf, m);
  80139a:	83 c4 08             	add    $0x8,%esp
  80139d:	53                   	push   %ebx
  80139e:	57                   	push   %edi
  80139f:	e8 f6 ec ff ff       	call   80009a <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013a4:	01 de                	add    %ebx,%esi
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013ac:	72 cd                	jb     80137b <devcons_write+0x19>
}
  8013ae:	89 f0                	mov    %esi,%eax
  8013b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b3:	5b                   	pop    %ebx
  8013b4:	5e                   	pop    %esi
  8013b5:	5f                   	pop    %edi
  8013b6:	5d                   	pop    %ebp
  8013b7:	c3                   	ret    

008013b8 <devcons_read>:
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
  8013bb:	83 ec 08             	sub    $0x8,%esp
  8013be:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013c7:	75 07                	jne    8013d0 <devcons_read+0x18>
  8013c9:	eb 1f                	jmp    8013ea <devcons_read+0x32>
		sys_yield();
  8013cb:	e8 67 ed ff ff       	call   800137 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8013d0:	e8 e3 ec ff ff       	call   8000b8 <sys_cgetc>
  8013d5:	85 c0                	test   %eax,%eax
  8013d7:	74 f2                	je     8013cb <devcons_read+0x13>
	if (c < 0)
  8013d9:	78 0f                	js     8013ea <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8013db:	83 f8 04             	cmp    $0x4,%eax
  8013de:	74 0c                	je     8013ec <devcons_read+0x34>
	*(char*)vbuf = c;
  8013e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013e3:	88 02                	mov    %al,(%edx)
	return 1;
  8013e5:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8013ea:	c9                   	leave  
  8013eb:	c3                   	ret    
		return 0;
  8013ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f1:	eb f7                	jmp    8013ea <devcons_read+0x32>

008013f3 <cputchar>:
{
  8013f3:	55                   	push   %ebp
  8013f4:	89 e5                	mov    %esp,%ebp
  8013f6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fc:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8013ff:	6a 01                	push   $0x1
  801401:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801404:	50                   	push   %eax
  801405:	e8 90 ec ff ff       	call   80009a <sys_cputs>
}
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	c9                   	leave  
  80140e:	c3                   	ret    

0080140f <getchar>:
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801415:	6a 01                	push   $0x1
  801417:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80141a:	50                   	push   %eax
  80141b:	6a 00                	push   $0x0
  80141d:	e8 66 f2 ff ff       	call   800688 <read>
	if (r < 0)
  801422:	83 c4 10             	add    $0x10,%esp
  801425:	85 c0                	test   %eax,%eax
  801427:	78 06                	js     80142f <getchar+0x20>
	if (r < 1)
  801429:	74 06                	je     801431 <getchar+0x22>
	return c;
  80142b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80142f:	c9                   	leave  
  801430:	c3                   	ret    
		return -E_EOF;
  801431:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801436:	eb f7                	jmp    80142f <getchar+0x20>

00801438 <iscons>:
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80143e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801441:	50                   	push   %eax
  801442:	ff 75 08             	push   0x8(%ebp)
  801445:	e8 d5 ef ff ff       	call   80041f <fd_lookup>
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	85 c0                	test   %eax,%eax
  80144f:	78 11                	js     801462 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801451:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801454:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80145a:	39 10                	cmp    %edx,(%eax)
  80145c:	0f 94 c0             	sete   %al
  80145f:	0f b6 c0             	movzbl %al,%eax
}
  801462:	c9                   	leave  
  801463:	c3                   	ret    

00801464 <opencons>:
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80146a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146d:	50                   	push   %eax
  80146e:	e8 5c ef ff ff       	call   8003cf <fd_alloc>
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	85 c0                	test   %eax,%eax
  801478:	78 3a                	js     8014b4 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80147a:	83 ec 04             	sub    $0x4,%esp
  80147d:	68 07 04 00 00       	push   $0x407
  801482:	ff 75 f4             	push   -0xc(%ebp)
  801485:	6a 00                	push   $0x0
  801487:	e8 ca ec ff ff       	call   800156 <sys_page_alloc>
  80148c:	83 c4 10             	add    $0x10,%esp
  80148f:	85 c0                	test   %eax,%eax
  801491:	78 21                	js     8014b4 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801493:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801496:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80149c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80149e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014a8:	83 ec 0c             	sub    $0xc,%esp
  8014ab:	50                   	push   %eax
  8014ac:	e8 f7 ee ff ff       	call   8003a8 <fd2num>
  8014b1:	83 c4 10             	add    $0x10,%esp
}
  8014b4:	c9                   	leave  
  8014b5:	c3                   	ret    

008014b6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	56                   	push   %esi
  8014ba:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014bb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014be:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014c4:	e8 4f ec ff ff       	call   800118 <sys_getenvid>
  8014c9:	83 ec 0c             	sub    $0xc,%esp
  8014cc:	ff 75 0c             	push   0xc(%ebp)
  8014cf:	ff 75 08             	push   0x8(%ebp)
  8014d2:	56                   	push   %esi
  8014d3:	50                   	push   %eax
  8014d4:	68 80 23 80 00       	push   $0x802380
  8014d9:	e8 b3 00 00 00       	call   801591 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014de:	83 c4 18             	add    $0x18,%esp
  8014e1:	53                   	push   %ebx
  8014e2:	ff 75 10             	push   0x10(%ebp)
  8014e5:	e8 56 00 00 00       	call   801540 <vcprintf>
	cprintf("\n");
  8014ea:	c7 04 24 6c 23 80 00 	movl   $0x80236c,(%esp)
  8014f1:	e8 9b 00 00 00       	call   801591 <cprintf>
  8014f6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014f9:	cc                   	int3   
  8014fa:	eb fd                	jmp    8014f9 <_panic+0x43>

008014fc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	53                   	push   %ebx
  801500:	83 ec 04             	sub    $0x4,%esp
  801503:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801506:	8b 13                	mov    (%ebx),%edx
  801508:	8d 42 01             	lea    0x1(%edx),%eax
  80150b:	89 03                	mov    %eax,(%ebx)
  80150d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801510:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801514:	3d ff 00 00 00       	cmp    $0xff,%eax
  801519:	74 09                	je     801524 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80151b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80151f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801522:	c9                   	leave  
  801523:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801524:	83 ec 08             	sub    $0x8,%esp
  801527:	68 ff 00 00 00       	push   $0xff
  80152c:	8d 43 08             	lea    0x8(%ebx),%eax
  80152f:	50                   	push   %eax
  801530:	e8 65 eb ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  801535:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	eb db                	jmp    80151b <putch+0x1f>

00801540 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801549:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801550:	00 00 00 
	b.cnt = 0;
  801553:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80155a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80155d:	ff 75 0c             	push   0xc(%ebp)
  801560:	ff 75 08             	push   0x8(%ebp)
  801563:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801569:	50                   	push   %eax
  80156a:	68 fc 14 80 00       	push   $0x8014fc
  80156f:	e8 14 01 00 00       	call   801688 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801574:	83 c4 08             	add    $0x8,%esp
  801577:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80157d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801583:	50                   	push   %eax
  801584:	e8 11 eb ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  801589:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80158f:	c9                   	leave  
  801590:	c3                   	ret    

00801591 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801597:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80159a:	50                   	push   %eax
  80159b:	ff 75 08             	push   0x8(%ebp)
  80159e:	e8 9d ff ff ff       	call   801540 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015a3:	c9                   	leave  
  8015a4:	c3                   	ret    

008015a5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	57                   	push   %edi
  8015a9:	56                   	push   %esi
  8015aa:	53                   	push   %ebx
  8015ab:	83 ec 1c             	sub    $0x1c,%esp
  8015ae:	89 c7                	mov    %eax,%edi
  8015b0:	89 d6                	mov    %edx,%esi
  8015b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b8:	89 d1                	mov    %edx,%ecx
  8015ba:	89 c2                	mov    %eax,%edx
  8015bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015bf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8015c5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015cb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8015d2:	39 c2                	cmp    %eax,%edx
  8015d4:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8015d7:	72 3e                	jb     801617 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015d9:	83 ec 0c             	sub    $0xc,%esp
  8015dc:	ff 75 18             	push   0x18(%ebp)
  8015df:	83 eb 01             	sub    $0x1,%ebx
  8015e2:	53                   	push   %ebx
  8015e3:	50                   	push   %eax
  8015e4:	83 ec 08             	sub    $0x8,%esp
  8015e7:	ff 75 e4             	push   -0x1c(%ebp)
  8015ea:	ff 75 e0             	push   -0x20(%ebp)
  8015ed:	ff 75 dc             	push   -0x24(%ebp)
  8015f0:	ff 75 d8             	push   -0x28(%ebp)
  8015f3:	e8 e8 09 00 00       	call   801fe0 <__udivdi3>
  8015f8:	83 c4 18             	add    $0x18,%esp
  8015fb:	52                   	push   %edx
  8015fc:	50                   	push   %eax
  8015fd:	89 f2                	mov    %esi,%edx
  8015ff:	89 f8                	mov    %edi,%eax
  801601:	e8 9f ff ff ff       	call   8015a5 <printnum>
  801606:	83 c4 20             	add    $0x20,%esp
  801609:	eb 13                	jmp    80161e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80160b:	83 ec 08             	sub    $0x8,%esp
  80160e:	56                   	push   %esi
  80160f:	ff 75 18             	push   0x18(%ebp)
  801612:	ff d7                	call   *%edi
  801614:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801617:	83 eb 01             	sub    $0x1,%ebx
  80161a:	85 db                	test   %ebx,%ebx
  80161c:	7f ed                	jg     80160b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80161e:	83 ec 08             	sub    $0x8,%esp
  801621:	56                   	push   %esi
  801622:	83 ec 04             	sub    $0x4,%esp
  801625:	ff 75 e4             	push   -0x1c(%ebp)
  801628:	ff 75 e0             	push   -0x20(%ebp)
  80162b:	ff 75 dc             	push   -0x24(%ebp)
  80162e:	ff 75 d8             	push   -0x28(%ebp)
  801631:	e8 ca 0a 00 00       	call   802100 <__umoddi3>
  801636:	83 c4 14             	add    $0x14,%esp
  801639:	0f be 80 a3 23 80 00 	movsbl 0x8023a3(%eax),%eax
  801640:	50                   	push   %eax
  801641:	ff d7                	call   *%edi
}
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801649:	5b                   	pop    %ebx
  80164a:	5e                   	pop    %esi
  80164b:	5f                   	pop    %edi
  80164c:	5d                   	pop    %ebp
  80164d:	c3                   	ret    

0080164e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801654:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801658:	8b 10                	mov    (%eax),%edx
  80165a:	3b 50 04             	cmp    0x4(%eax),%edx
  80165d:	73 0a                	jae    801669 <sprintputch+0x1b>
		*b->buf++ = ch;
  80165f:	8d 4a 01             	lea    0x1(%edx),%ecx
  801662:	89 08                	mov    %ecx,(%eax)
  801664:	8b 45 08             	mov    0x8(%ebp),%eax
  801667:	88 02                	mov    %al,(%edx)
}
  801669:	5d                   	pop    %ebp
  80166a:	c3                   	ret    

0080166b <printfmt>:
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801671:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801674:	50                   	push   %eax
  801675:	ff 75 10             	push   0x10(%ebp)
  801678:	ff 75 0c             	push   0xc(%ebp)
  80167b:	ff 75 08             	push   0x8(%ebp)
  80167e:	e8 05 00 00 00       	call   801688 <vprintfmt>
}
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	c9                   	leave  
  801687:	c3                   	ret    

00801688 <vprintfmt>:
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	57                   	push   %edi
  80168c:	56                   	push   %esi
  80168d:	53                   	push   %ebx
  80168e:	83 ec 3c             	sub    $0x3c,%esp
  801691:	8b 75 08             	mov    0x8(%ebp),%esi
  801694:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801697:	8b 7d 10             	mov    0x10(%ebp),%edi
  80169a:	eb 0a                	jmp    8016a6 <vprintfmt+0x1e>
			putch(ch, putdat);
  80169c:	83 ec 08             	sub    $0x8,%esp
  80169f:	53                   	push   %ebx
  8016a0:	50                   	push   %eax
  8016a1:	ff d6                	call   *%esi
  8016a3:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016a6:	83 c7 01             	add    $0x1,%edi
  8016a9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016ad:	83 f8 25             	cmp    $0x25,%eax
  8016b0:	74 0c                	je     8016be <vprintfmt+0x36>
			if (ch == '\0')
  8016b2:	85 c0                	test   %eax,%eax
  8016b4:	75 e6                	jne    80169c <vprintfmt+0x14>
}
  8016b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b9:	5b                   	pop    %ebx
  8016ba:	5e                   	pop    %esi
  8016bb:	5f                   	pop    %edi
  8016bc:	5d                   	pop    %ebp
  8016bd:	c3                   	ret    
		padc = ' ';
  8016be:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8016c2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8016c9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8016d0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8016d7:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8016dc:	8d 47 01             	lea    0x1(%edi),%eax
  8016df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016e2:	0f b6 17             	movzbl (%edi),%edx
  8016e5:	8d 42 dd             	lea    -0x23(%edx),%eax
  8016e8:	3c 55                	cmp    $0x55,%al
  8016ea:	0f 87 bb 03 00 00    	ja     801aab <vprintfmt+0x423>
  8016f0:	0f b6 c0             	movzbl %al,%eax
  8016f3:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  8016fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8016fd:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801701:	eb d9                	jmp    8016dc <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801703:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801706:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80170a:	eb d0                	jmp    8016dc <vprintfmt+0x54>
  80170c:	0f b6 d2             	movzbl %dl,%edx
  80170f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801712:	b8 00 00 00 00       	mov    $0x0,%eax
  801717:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80171a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80171d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801721:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801724:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801727:	83 f9 09             	cmp    $0x9,%ecx
  80172a:	77 55                	ja     801781 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80172c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80172f:	eb e9                	jmp    80171a <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801731:	8b 45 14             	mov    0x14(%ebp),%eax
  801734:	8b 00                	mov    (%eax),%eax
  801736:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801739:	8b 45 14             	mov    0x14(%ebp),%eax
  80173c:	8d 40 04             	lea    0x4(%eax),%eax
  80173f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801742:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801745:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801749:	79 91                	jns    8016dc <vprintfmt+0x54>
				width = precision, precision = -1;
  80174b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80174e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801751:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801758:	eb 82                	jmp    8016dc <vprintfmt+0x54>
  80175a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80175d:	85 d2                	test   %edx,%edx
  80175f:	b8 00 00 00 00       	mov    $0x0,%eax
  801764:	0f 49 c2             	cmovns %edx,%eax
  801767:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80176a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80176d:	e9 6a ff ff ff       	jmp    8016dc <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801772:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801775:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80177c:	e9 5b ff ff ff       	jmp    8016dc <vprintfmt+0x54>
  801781:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801784:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801787:	eb bc                	jmp    801745 <vprintfmt+0xbd>
			lflag++;
  801789:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80178c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80178f:	e9 48 ff ff ff       	jmp    8016dc <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  801794:	8b 45 14             	mov    0x14(%ebp),%eax
  801797:	8d 78 04             	lea    0x4(%eax),%edi
  80179a:	83 ec 08             	sub    $0x8,%esp
  80179d:	53                   	push   %ebx
  80179e:	ff 30                	push   (%eax)
  8017a0:	ff d6                	call   *%esi
			break;
  8017a2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017a5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017a8:	e9 9d 02 00 00       	jmp    801a4a <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8017ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8017b0:	8d 78 04             	lea    0x4(%eax),%edi
  8017b3:	8b 10                	mov    (%eax),%edx
  8017b5:	89 d0                	mov    %edx,%eax
  8017b7:	f7 d8                	neg    %eax
  8017b9:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017bc:	83 f8 0f             	cmp    $0xf,%eax
  8017bf:	7f 23                	jg     8017e4 <vprintfmt+0x15c>
  8017c1:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  8017c8:	85 d2                	test   %edx,%edx
  8017ca:	74 18                	je     8017e4 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8017cc:	52                   	push   %edx
  8017cd:	68 01 23 80 00       	push   $0x802301
  8017d2:	53                   	push   %ebx
  8017d3:	56                   	push   %esi
  8017d4:	e8 92 fe ff ff       	call   80166b <printfmt>
  8017d9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017dc:	89 7d 14             	mov    %edi,0x14(%ebp)
  8017df:	e9 66 02 00 00       	jmp    801a4a <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8017e4:	50                   	push   %eax
  8017e5:	68 bb 23 80 00       	push   $0x8023bb
  8017ea:	53                   	push   %ebx
  8017eb:	56                   	push   %esi
  8017ec:	e8 7a fe ff ff       	call   80166b <printfmt>
  8017f1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017f4:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8017f7:	e9 4e 02 00 00       	jmp    801a4a <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8017fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ff:	83 c0 04             	add    $0x4,%eax
  801802:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801805:	8b 45 14             	mov    0x14(%ebp),%eax
  801808:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80180a:	85 d2                	test   %edx,%edx
  80180c:	b8 b4 23 80 00       	mov    $0x8023b4,%eax
  801811:	0f 45 c2             	cmovne %edx,%eax
  801814:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801817:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80181b:	7e 06                	jle    801823 <vprintfmt+0x19b>
  80181d:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801821:	75 0d                	jne    801830 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801823:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801826:	89 c7                	mov    %eax,%edi
  801828:	03 45 e0             	add    -0x20(%ebp),%eax
  80182b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80182e:	eb 55                	jmp    801885 <vprintfmt+0x1fd>
  801830:	83 ec 08             	sub    $0x8,%esp
  801833:	ff 75 d8             	push   -0x28(%ebp)
  801836:	ff 75 cc             	push   -0x34(%ebp)
  801839:	e8 0a 03 00 00       	call   801b48 <strnlen>
  80183e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801841:	29 c1                	sub    %eax,%ecx
  801843:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801846:	83 c4 10             	add    $0x10,%esp
  801849:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80184b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80184f:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801852:	eb 0f                	jmp    801863 <vprintfmt+0x1db>
					putch(padc, putdat);
  801854:	83 ec 08             	sub    $0x8,%esp
  801857:	53                   	push   %ebx
  801858:	ff 75 e0             	push   -0x20(%ebp)
  80185b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80185d:	83 ef 01             	sub    $0x1,%edi
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	85 ff                	test   %edi,%edi
  801865:	7f ed                	jg     801854 <vprintfmt+0x1cc>
  801867:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80186a:	85 d2                	test   %edx,%edx
  80186c:	b8 00 00 00 00       	mov    $0x0,%eax
  801871:	0f 49 c2             	cmovns %edx,%eax
  801874:	29 c2                	sub    %eax,%edx
  801876:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801879:	eb a8                	jmp    801823 <vprintfmt+0x19b>
					putch(ch, putdat);
  80187b:	83 ec 08             	sub    $0x8,%esp
  80187e:	53                   	push   %ebx
  80187f:	52                   	push   %edx
  801880:	ff d6                	call   *%esi
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801888:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80188a:	83 c7 01             	add    $0x1,%edi
  80188d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801891:	0f be d0             	movsbl %al,%edx
  801894:	85 d2                	test   %edx,%edx
  801896:	74 4b                	je     8018e3 <vprintfmt+0x25b>
  801898:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80189c:	78 06                	js     8018a4 <vprintfmt+0x21c>
  80189e:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018a2:	78 1e                	js     8018c2 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8018a4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018a8:	74 d1                	je     80187b <vprintfmt+0x1f3>
  8018aa:	0f be c0             	movsbl %al,%eax
  8018ad:	83 e8 20             	sub    $0x20,%eax
  8018b0:	83 f8 5e             	cmp    $0x5e,%eax
  8018b3:	76 c6                	jbe    80187b <vprintfmt+0x1f3>
					putch('?', putdat);
  8018b5:	83 ec 08             	sub    $0x8,%esp
  8018b8:	53                   	push   %ebx
  8018b9:	6a 3f                	push   $0x3f
  8018bb:	ff d6                	call   *%esi
  8018bd:	83 c4 10             	add    $0x10,%esp
  8018c0:	eb c3                	jmp    801885 <vprintfmt+0x1fd>
  8018c2:	89 cf                	mov    %ecx,%edi
  8018c4:	eb 0e                	jmp    8018d4 <vprintfmt+0x24c>
				putch(' ', putdat);
  8018c6:	83 ec 08             	sub    $0x8,%esp
  8018c9:	53                   	push   %ebx
  8018ca:	6a 20                	push   $0x20
  8018cc:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8018ce:	83 ef 01             	sub    $0x1,%edi
  8018d1:	83 c4 10             	add    $0x10,%esp
  8018d4:	85 ff                	test   %edi,%edi
  8018d6:	7f ee                	jg     8018c6 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8018d8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8018db:	89 45 14             	mov    %eax,0x14(%ebp)
  8018de:	e9 67 01 00 00       	jmp    801a4a <vprintfmt+0x3c2>
  8018e3:	89 cf                	mov    %ecx,%edi
  8018e5:	eb ed                	jmp    8018d4 <vprintfmt+0x24c>
	if (lflag >= 2)
  8018e7:	83 f9 01             	cmp    $0x1,%ecx
  8018ea:	7f 1b                	jg     801907 <vprintfmt+0x27f>
	else if (lflag)
  8018ec:	85 c9                	test   %ecx,%ecx
  8018ee:	74 63                	je     801953 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8018f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f3:	8b 00                	mov    (%eax),%eax
  8018f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018f8:	99                   	cltd   
  8018f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8018fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ff:	8d 40 04             	lea    0x4(%eax),%eax
  801902:	89 45 14             	mov    %eax,0x14(%ebp)
  801905:	eb 17                	jmp    80191e <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801907:	8b 45 14             	mov    0x14(%ebp),%eax
  80190a:	8b 50 04             	mov    0x4(%eax),%edx
  80190d:	8b 00                	mov    (%eax),%eax
  80190f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801912:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801915:	8b 45 14             	mov    0x14(%ebp),%eax
  801918:	8d 40 08             	lea    0x8(%eax),%eax
  80191b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80191e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801921:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801924:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801929:	85 c9                	test   %ecx,%ecx
  80192b:	0f 89 ff 00 00 00    	jns    801a30 <vprintfmt+0x3a8>
				putch('-', putdat);
  801931:	83 ec 08             	sub    $0x8,%esp
  801934:	53                   	push   %ebx
  801935:	6a 2d                	push   $0x2d
  801937:	ff d6                	call   *%esi
				num = -(long long) num;
  801939:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80193c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80193f:	f7 da                	neg    %edx
  801941:	83 d1 00             	adc    $0x0,%ecx
  801944:	f7 d9                	neg    %ecx
  801946:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801949:	bf 0a 00 00 00       	mov    $0xa,%edi
  80194e:	e9 dd 00 00 00       	jmp    801a30 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801953:	8b 45 14             	mov    0x14(%ebp),%eax
  801956:	8b 00                	mov    (%eax),%eax
  801958:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80195b:	99                   	cltd   
  80195c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80195f:	8b 45 14             	mov    0x14(%ebp),%eax
  801962:	8d 40 04             	lea    0x4(%eax),%eax
  801965:	89 45 14             	mov    %eax,0x14(%ebp)
  801968:	eb b4                	jmp    80191e <vprintfmt+0x296>
	if (lflag >= 2)
  80196a:	83 f9 01             	cmp    $0x1,%ecx
  80196d:	7f 1e                	jg     80198d <vprintfmt+0x305>
	else if (lflag)
  80196f:	85 c9                	test   %ecx,%ecx
  801971:	74 32                	je     8019a5 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  801973:	8b 45 14             	mov    0x14(%ebp),%eax
  801976:	8b 10                	mov    (%eax),%edx
  801978:	b9 00 00 00 00       	mov    $0x0,%ecx
  80197d:	8d 40 04             	lea    0x4(%eax),%eax
  801980:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801983:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  801988:	e9 a3 00 00 00       	jmp    801a30 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80198d:	8b 45 14             	mov    0x14(%ebp),%eax
  801990:	8b 10                	mov    (%eax),%edx
  801992:	8b 48 04             	mov    0x4(%eax),%ecx
  801995:	8d 40 08             	lea    0x8(%eax),%eax
  801998:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80199b:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8019a0:	e9 8b 00 00 00       	jmp    801a30 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a8:	8b 10                	mov    (%eax),%edx
  8019aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019af:	8d 40 04             	lea    0x4(%eax),%eax
  8019b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019b5:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8019ba:	eb 74                	jmp    801a30 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8019bc:	83 f9 01             	cmp    $0x1,%ecx
  8019bf:	7f 1b                	jg     8019dc <vprintfmt+0x354>
	else if (lflag)
  8019c1:	85 c9                	test   %ecx,%ecx
  8019c3:	74 2c                	je     8019f1 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8019c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c8:	8b 10                	mov    (%eax),%edx
  8019ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019cf:	8d 40 04             	lea    0x4(%eax),%eax
  8019d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019d5:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8019da:	eb 54                	jmp    801a30 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8019df:	8b 10                	mov    (%eax),%edx
  8019e1:	8b 48 04             	mov    0x4(%eax),%ecx
  8019e4:	8d 40 08             	lea    0x8(%eax),%eax
  8019e7:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019ea:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8019ef:	eb 3f                	jmp    801a30 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f4:	8b 10                	mov    (%eax),%edx
  8019f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019fb:	8d 40 04             	lea    0x4(%eax),%eax
  8019fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a01:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801a06:	eb 28                	jmp    801a30 <vprintfmt+0x3a8>
			putch('0', putdat);
  801a08:	83 ec 08             	sub    $0x8,%esp
  801a0b:	53                   	push   %ebx
  801a0c:	6a 30                	push   $0x30
  801a0e:	ff d6                	call   *%esi
			putch('x', putdat);
  801a10:	83 c4 08             	add    $0x8,%esp
  801a13:	53                   	push   %ebx
  801a14:	6a 78                	push   $0x78
  801a16:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a18:	8b 45 14             	mov    0x14(%ebp),%eax
  801a1b:	8b 10                	mov    (%eax),%edx
  801a1d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a22:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a25:	8d 40 04             	lea    0x4(%eax),%eax
  801a28:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a2b:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801a30:	83 ec 0c             	sub    $0xc,%esp
  801a33:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801a37:	50                   	push   %eax
  801a38:	ff 75 e0             	push   -0x20(%ebp)
  801a3b:	57                   	push   %edi
  801a3c:	51                   	push   %ecx
  801a3d:	52                   	push   %edx
  801a3e:	89 da                	mov    %ebx,%edx
  801a40:	89 f0                	mov    %esi,%eax
  801a42:	e8 5e fb ff ff       	call   8015a5 <printnum>
			break;
  801a47:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801a4a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a4d:	e9 54 fc ff ff       	jmp    8016a6 <vprintfmt+0x1e>
	if (lflag >= 2)
  801a52:	83 f9 01             	cmp    $0x1,%ecx
  801a55:	7f 1b                	jg     801a72 <vprintfmt+0x3ea>
	else if (lflag)
  801a57:	85 c9                	test   %ecx,%ecx
  801a59:	74 2c                	je     801a87 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801a5b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a5e:	8b 10                	mov    (%eax),%edx
  801a60:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a65:	8d 40 04             	lea    0x4(%eax),%eax
  801a68:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a6b:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801a70:	eb be                	jmp    801a30 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801a72:	8b 45 14             	mov    0x14(%ebp),%eax
  801a75:	8b 10                	mov    (%eax),%edx
  801a77:	8b 48 04             	mov    0x4(%eax),%ecx
  801a7a:	8d 40 08             	lea    0x8(%eax),%eax
  801a7d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a80:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  801a85:	eb a9                	jmp    801a30 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a87:	8b 45 14             	mov    0x14(%ebp),%eax
  801a8a:	8b 10                	mov    (%eax),%edx
  801a8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a91:	8d 40 04             	lea    0x4(%eax),%eax
  801a94:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a97:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  801a9c:	eb 92                	jmp    801a30 <vprintfmt+0x3a8>
			putch(ch, putdat);
  801a9e:	83 ec 08             	sub    $0x8,%esp
  801aa1:	53                   	push   %ebx
  801aa2:	6a 25                	push   $0x25
  801aa4:	ff d6                	call   *%esi
			break;
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	eb 9f                	jmp    801a4a <vprintfmt+0x3c2>
			putch('%', putdat);
  801aab:	83 ec 08             	sub    $0x8,%esp
  801aae:	53                   	push   %ebx
  801aaf:	6a 25                	push   $0x25
  801ab1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	89 f8                	mov    %edi,%eax
  801ab8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801abc:	74 05                	je     801ac3 <vprintfmt+0x43b>
  801abe:	83 e8 01             	sub    $0x1,%eax
  801ac1:	eb f5                	jmp    801ab8 <vprintfmt+0x430>
  801ac3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ac6:	eb 82                	jmp    801a4a <vprintfmt+0x3c2>

00801ac8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	83 ec 18             	sub    $0x18,%esp
  801ace:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ad4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ad7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801adb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ade:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	74 26                	je     801b0f <vsnprintf+0x47>
  801ae9:	85 d2                	test   %edx,%edx
  801aeb:	7e 22                	jle    801b0f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801aed:	ff 75 14             	push   0x14(%ebp)
  801af0:	ff 75 10             	push   0x10(%ebp)
  801af3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801af6:	50                   	push   %eax
  801af7:	68 4e 16 80 00       	push   $0x80164e
  801afc:	e8 87 fb ff ff       	call   801688 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b01:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b04:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0a:	83 c4 10             	add    $0x10,%esp
}
  801b0d:	c9                   	leave  
  801b0e:	c3                   	ret    
		return -E_INVAL;
  801b0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b14:	eb f7                	jmp    801b0d <vsnprintf+0x45>

00801b16 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b1c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b1f:	50                   	push   %eax
  801b20:	ff 75 10             	push   0x10(%ebp)
  801b23:	ff 75 0c             	push   0xc(%ebp)
  801b26:	ff 75 08             	push   0x8(%ebp)
  801b29:	e8 9a ff ff ff       	call   801ac8 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b2e:	c9                   	leave  
  801b2f:	c3                   	ret    

00801b30 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b36:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3b:	eb 03                	jmp    801b40 <strlen+0x10>
		n++;
  801b3d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801b40:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b44:	75 f7                	jne    801b3d <strlen+0xd>
	return n;
}
  801b46:	5d                   	pop    %ebp
  801b47:	c3                   	ret    

00801b48 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b4e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b51:	b8 00 00 00 00       	mov    $0x0,%eax
  801b56:	eb 03                	jmp    801b5b <strnlen+0x13>
		n++;
  801b58:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b5b:	39 d0                	cmp    %edx,%eax
  801b5d:	74 08                	je     801b67 <strnlen+0x1f>
  801b5f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801b63:	75 f3                	jne    801b58 <strnlen+0x10>
  801b65:	89 c2                	mov    %eax,%edx
	return n;
}
  801b67:	89 d0                	mov    %edx,%eax
  801b69:	5d                   	pop    %ebp
  801b6a:	c3                   	ret    

00801b6b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	53                   	push   %ebx
  801b6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b75:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801b7e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801b81:	83 c0 01             	add    $0x1,%eax
  801b84:	84 d2                	test   %dl,%dl
  801b86:	75 f2                	jne    801b7a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801b88:	89 c8                	mov    %ecx,%eax
  801b8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8d:	c9                   	leave  
  801b8e:	c3                   	ret    

00801b8f <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b8f:	55                   	push   %ebp
  801b90:	89 e5                	mov    %esp,%ebp
  801b92:	53                   	push   %ebx
  801b93:	83 ec 10             	sub    $0x10,%esp
  801b96:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b99:	53                   	push   %ebx
  801b9a:	e8 91 ff ff ff       	call   801b30 <strlen>
  801b9f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801ba2:	ff 75 0c             	push   0xc(%ebp)
  801ba5:	01 d8                	add    %ebx,%eax
  801ba7:	50                   	push   %eax
  801ba8:	e8 be ff ff ff       	call   801b6b <strcpy>
	return dst;
}
  801bad:	89 d8                	mov    %ebx,%eax
  801baf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb2:	c9                   	leave  
  801bb3:	c3                   	ret    

00801bb4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	56                   	push   %esi
  801bb8:	53                   	push   %ebx
  801bb9:	8b 75 08             	mov    0x8(%ebp),%esi
  801bbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bbf:	89 f3                	mov    %esi,%ebx
  801bc1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bc4:	89 f0                	mov    %esi,%eax
  801bc6:	eb 0f                	jmp    801bd7 <strncpy+0x23>
		*dst++ = *src;
  801bc8:	83 c0 01             	add    $0x1,%eax
  801bcb:	0f b6 0a             	movzbl (%edx),%ecx
  801bce:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bd1:	80 f9 01             	cmp    $0x1,%cl
  801bd4:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801bd7:	39 d8                	cmp    %ebx,%eax
  801bd9:	75 ed                	jne    801bc8 <strncpy+0x14>
	}
	return ret;
}
  801bdb:	89 f0                	mov    %esi,%eax
  801bdd:	5b                   	pop    %ebx
  801bde:	5e                   	pop    %esi
  801bdf:	5d                   	pop    %ebp
  801be0:	c3                   	ret    

00801be1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801be1:	55                   	push   %ebp
  801be2:	89 e5                	mov    %esp,%ebp
  801be4:	56                   	push   %esi
  801be5:	53                   	push   %ebx
  801be6:	8b 75 08             	mov    0x8(%ebp),%esi
  801be9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bec:	8b 55 10             	mov    0x10(%ebp),%edx
  801bef:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bf1:	85 d2                	test   %edx,%edx
  801bf3:	74 21                	je     801c16 <strlcpy+0x35>
  801bf5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bf9:	89 f2                	mov    %esi,%edx
  801bfb:	eb 09                	jmp    801c06 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bfd:	83 c1 01             	add    $0x1,%ecx
  801c00:	83 c2 01             	add    $0x1,%edx
  801c03:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801c06:	39 c2                	cmp    %eax,%edx
  801c08:	74 09                	je     801c13 <strlcpy+0x32>
  801c0a:	0f b6 19             	movzbl (%ecx),%ebx
  801c0d:	84 db                	test   %bl,%bl
  801c0f:	75 ec                	jne    801bfd <strlcpy+0x1c>
  801c11:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c13:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c16:	29 f0                	sub    %esi,%eax
}
  801c18:	5b                   	pop    %ebx
  801c19:	5e                   	pop    %esi
  801c1a:	5d                   	pop    %ebp
  801c1b:	c3                   	ret    

00801c1c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c22:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c25:	eb 06                	jmp    801c2d <strcmp+0x11>
		p++, q++;
  801c27:	83 c1 01             	add    $0x1,%ecx
  801c2a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801c2d:	0f b6 01             	movzbl (%ecx),%eax
  801c30:	84 c0                	test   %al,%al
  801c32:	74 04                	je     801c38 <strcmp+0x1c>
  801c34:	3a 02                	cmp    (%edx),%al
  801c36:	74 ef                	je     801c27 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c38:	0f b6 c0             	movzbl %al,%eax
  801c3b:	0f b6 12             	movzbl (%edx),%edx
  801c3e:	29 d0                	sub    %edx,%eax
}
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    

00801c42 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	53                   	push   %ebx
  801c46:	8b 45 08             	mov    0x8(%ebp),%eax
  801c49:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c4c:	89 c3                	mov    %eax,%ebx
  801c4e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c51:	eb 06                	jmp    801c59 <strncmp+0x17>
		n--, p++, q++;
  801c53:	83 c0 01             	add    $0x1,%eax
  801c56:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801c59:	39 d8                	cmp    %ebx,%eax
  801c5b:	74 18                	je     801c75 <strncmp+0x33>
  801c5d:	0f b6 08             	movzbl (%eax),%ecx
  801c60:	84 c9                	test   %cl,%cl
  801c62:	74 04                	je     801c68 <strncmp+0x26>
  801c64:	3a 0a                	cmp    (%edx),%cl
  801c66:	74 eb                	je     801c53 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c68:	0f b6 00             	movzbl (%eax),%eax
  801c6b:	0f b6 12             	movzbl (%edx),%edx
  801c6e:	29 d0                	sub    %edx,%eax
}
  801c70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c73:	c9                   	leave  
  801c74:	c3                   	ret    
		return 0;
  801c75:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7a:	eb f4                	jmp    801c70 <strncmp+0x2e>

00801c7c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c82:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c86:	eb 03                	jmp    801c8b <strchr+0xf>
  801c88:	83 c0 01             	add    $0x1,%eax
  801c8b:	0f b6 10             	movzbl (%eax),%edx
  801c8e:	84 d2                	test   %dl,%dl
  801c90:	74 06                	je     801c98 <strchr+0x1c>
		if (*s == c)
  801c92:	38 ca                	cmp    %cl,%dl
  801c94:	75 f2                	jne    801c88 <strchr+0xc>
  801c96:	eb 05                	jmp    801c9d <strchr+0x21>
			return (char *) s;
	return 0;
  801c98:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c9d:	5d                   	pop    %ebp
  801c9e:	c3                   	ret    

00801c9f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ca9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cac:	38 ca                	cmp    %cl,%dl
  801cae:	74 09                	je     801cb9 <strfind+0x1a>
  801cb0:	84 d2                	test   %dl,%dl
  801cb2:	74 05                	je     801cb9 <strfind+0x1a>
	for (; *s; s++)
  801cb4:	83 c0 01             	add    $0x1,%eax
  801cb7:	eb f0                	jmp    801ca9 <strfind+0xa>
			break;
	return (char *) s;
}
  801cb9:	5d                   	pop    %ebp
  801cba:	c3                   	ret    

00801cbb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	57                   	push   %edi
  801cbf:	56                   	push   %esi
  801cc0:	53                   	push   %ebx
  801cc1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cc4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cc7:	85 c9                	test   %ecx,%ecx
  801cc9:	74 2f                	je     801cfa <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ccb:	89 f8                	mov    %edi,%eax
  801ccd:	09 c8                	or     %ecx,%eax
  801ccf:	a8 03                	test   $0x3,%al
  801cd1:	75 21                	jne    801cf4 <memset+0x39>
		c &= 0xFF;
  801cd3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cd7:	89 d0                	mov    %edx,%eax
  801cd9:	c1 e0 08             	shl    $0x8,%eax
  801cdc:	89 d3                	mov    %edx,%ebx
  801cde:	c1 e3 18             	shl    $0x18,%ebx
  801ce1:	89 d6                	mov    %edx,%esi
  801ce3:	c1 e6 10             	shl    $0x10,%esi
  801ce6:	09 f3                	or     %esi,%ebx
  801ce8:	09 da                	or     %ebx,%edx
  801cea:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801cec:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801cef:	fc                   	cld    
  801cf0:	f3 ab                	rep stos %eax,%es:(%edi)
  801cf2:	eb 06                	jmp    801cfa <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cf4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf7:	fc                   	cld    
  801cf8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cfa:	89 f8                	mov    %edi,%eax
  801cfc:	5b                   	pop    %ebx
  801cfd:	5e                   	pop    %esi
  801cfe:	5f                   	pop    %edi
  801cff:	5d                   	pop    %ebp
  801d00:	c3                   	ret    

00801d01 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	57                   	push   %edi
  801d05:	56                   	push   %esi
  801d06:	8b 45 08             	mov    0x8(%ebp),%eax
  801d09:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d0c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d0f:	39 c6                	cmp    %eax,%esi
  801d11:	73 32                	jae    801d45 <memmove+0x44>
  801d13:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d16:	39 c2                	cmp    %eax,%edx
  801d18:	76 2b                	jbe    801d45 <memmove+0x44>
		s += n;
		d += n;
  801d1a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d1d:	89 d6                	mov    %edx,%esi
  801d1f:	09 fe                	or     %edi,%esi
  801d21:	09 ce                	or     %ecx,%esi
  801d23:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d29:	75 0e                	jne    801d39 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d2b:	83 ef 04             	sub    $0x4,%edi
  801d2e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d31:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801d34:	fd                   	std    
  801d35:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d37:	eb 09                	jmp    801d42 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d39:	83 ef 01             	sub    $0x1,%edi
  801d3c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801d3f:	fd                   	std    
  801d40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d42:	fc                   	cld    
  801d43:	eb 1a                	jmp    801d5f <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d45:	89 f2                	mov    %esi,%edx
  801d47:	09 c2                	or     %eax,%edx
  801d49:	09 ca                	or     %ecx,%edx
  801d4b:	f6 c2 03             	test   $0x3,%dl
  801d4e:	75 0a                	jne    801d5a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d50:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801d53:	89 c7                	mov    %eax,%edi
  801d55:	fc                   	cld    
  801d56:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d58:	eb 05                	jmp    801d5f <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801d5a:	89 c7                	mov    %eax,%edi
  801d5c:	fc                   	cld    
  801d5d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d5f:	5e                   	pop    %esi
  801d60:	5f                   	pop    %edi
  801d61:	5d                   	pop    %ebp
  801d62:	c3                   	ret    

00801d63 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d63:	55                   	push   %ebp
  801d64:	89 e5                	mov    %esp,%ebp
  801d66:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d69:	ff 75 10             	push   0x10(%ebp)
  801d6c:	ff 75 0c             	push   0xc(%ebp)
  801d6f:	ff 75 08             	push   0x8(%ebp)
  801d72:	e8 8a ff ff ff       	call   801d01 <memmove>
}
  801d77:	c9                   	leave  
  801d78:	c3                   	ret    

00801d79 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
  801d7c:	56                   	push   %esi
  801d7d:	53                   	push   %ebx
  801d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d81:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d84:	89 c6                	mov    %eax,%esi
  801d86:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d89:	eb 06                	jmp    801d91 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801d8b:	83 c0 01             	add    $0x1,%eax
  801d8e:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801d91:	39 f0                	cmp    %esi,%eax
  801d93:	74 14                	je     801da9 <memcmp+0x30>
		if (*s1 != *s2)
  801d95:	0f b6 08             	movzbl (%eax),%ecx
  801d98:	0f b6 1a             	movzbl (%edx),%ebx
  801d9b:	38 d9                	cmp    %bl,%cl
  801d9d:	74 ec                	je     801d8b <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801d9f:	0f b6 c1             	movzbl %cl,%eax
  801da2:	0f b6 db             	movzbl %bl,%ebx
  801da5:	29 d8                	sub    %ebx,%eax
  801da7:	eb 05                	jmp    801dae <memcmp+0x35>
	}

	return 0;
  801da9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dae:	5b                   	pop    %ebx
  801daf:	5e                   	pop    %esi
  801db0:	5d                   	pop    %ebp
  801db1:	c3                   	ret    

00801db2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801db2:	55                   	push   %ebp
  801db3:	89 e5                	mov    %esp,%ebp
  801db5:	8b 45 08             	mov    0x8(%ebp),%eax
  801db8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801dbb:	89 c2                	mov    %eax,%edx
  801dbd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801dc0:	eb 03                	jmp    801dc5 <memfind+0x13>
  801dc2:	83 c0 01             	add    $0x1,%eax
  801dc5:	39 d0                	cmp    %edx,%eax
  801dc7:	73 04                	jae    801dcd <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dc9:	38 08                	cmp    %cl,(%eax)
  801dcb:	75 f5                	jne    801dc2 <memfind+0x10>
			break;
	return (void *) s;
}
  801dcd:	5d                   	pop    %ebp
  801dce:	c3                   	ret    

00801dcf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	57                   	push   %edi
  801dd3:	56                   	push   %esi
  801dd4:	53                   	push   %ebx
  801dd5:	8b 55 08             	mov    0x8(%ebp),%edx
  801dd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ddb:	eb 03                	jmp    801de0 <strtol+0x11>
		s++;
  801ddd:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801de0:	0f b6 02             	movzbl (%edx),%eax
  801de3:	3c 20                	cmp    $0x20,%al
  801de5:	74 f6                	je     801ddd <strtol+0xe>
  801de7:	3c 09                	cmp    $0x9,%al
  801de9:	74 f2                	je     801ddd <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801deb:	3c 2b                	cmp    $0x2b,%al
  801ded:	74 2a                	je     801e19 <strtol+0x4a>
	int neg = 0;
  801def:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801df4:	3c 2d                	cmp    $0x2d,%al
  801df6:	74 2b                	je     801e23 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801df8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801dfe:	75 0f                	jne    801e0f <strtol+0x40>
  801e00:	80 3a 30             	cmpb   $0x30,(%edx)
  801e03:	74 28                	je     801e2d <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e05:	85 db                	test   %ebx,%ebx
  801e07:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e0c:	0f 44 d8             	cmove  %eax,%ebx
  801e0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e14:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801e17:	eb 46                	jmp    801e5f <strtol+0x90>
		s++;
  801e19:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801e1c:	bf 00 00 00 00       	mov    $0x0,%edi
  801e21:	eb d5                	jmp    801df8 <strtol+0x29>
		s++, neg = 1;
  801e23:	83 c2 01             	add    $0x1,%edx
  801e26:	bf 01 00 00 00       	mov    $0x1,%edi
  801e2b:	eb cb                	jmp    801df8 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e2d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e31:	74 0e                	je     801e41 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801e33:	85 db                	test   %ebx,%ebx
  801e35:	75 d8                	jne    801e0f <strtol+0x40>
		s++, base = 8;
  801e37:	83 c2 01             	add    $0x1,%edx
  801e3a:	bb 08 00 00 00       	mov    $0x8,%ebx
  801e3f:	eb ce                	jmp    801e0f <strtol+0x40>
		s += 2, base = 16;
  801e41:	83 c2 02             	add    $0x2,%edx
  801e44:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e49:	eb c4                	jmp    801e0f <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801e4b:	0f be c0             	movsbl %al,%eax
  801e4e:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801e51:	3b 45 10             	cmp    0x10(%ebp),%eax
  801e54:	7d 3a                	jge    801e90 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801e56:	83 c2 01             	add    $0x1,%edx
  801e59:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801e5d:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801e5f:	0f b6 02             	movzbl (%edx),%eax
  801e62:	8d 70 d0             	lea    -0x30(%eax),%esi
  801e65:	89 f3                	mov    %esi,%ebx
  801e67:	80 fb 09             	cmp    $0x9,%bl
  801e6a:	76 df                	jbe    801e4b <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801e6c:	8d 70 9f             	lea    -0x61(%eax),%esi
  801e6f:	89 f3                	mov    %esi,%ebx
  801e71:	80 fb 19             	cmp    $0x19,%bl
  801e74:	77 08                	ja     801e7e <strtol+0xaf>
			dig = *s - 'a' + 10;
  801e76:	0f be c0             	movsbl %al,%eax
  801e79:	83 e8 57             	sub    $0x57,%eax
  801e7c:	eb d3                	jmp    801e51 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801e7e:	8d 70 bf             	lea    -0x41(%eax),%esi
  801e81:	89 f3                	mov    %esi,%ebx
  801e83:	80 fb 19             	cmp    $0x19,%bl
  801e86:	77 08                	ja     801e90 <strtol+0xc1>
			dig = *s - 'A' + 10;
  801e88:	0f be c0             	movsbl %al,%eax
  801e8b:	83 e8 37             	sub    $0x37,%eax
  801e8e:	eb c1                	jmp    801e51 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801e90:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e94:	74 05                	je     801e9b <strtol+0xcc>
		*endptr = (char *) s;
  801e96:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e99:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801e9b:	89 c8                	mov    %ecx,%eax
  801e9d:	f7 d8                	neg    %eax
  801e9f:	85 ff                	test   %edi,%edi
  801ea1:	0f 45 c8             	cmovne %eax,%ecx
}
  801ea4:	89 c8                	mov    %ecx,%eax
  801ea6:	5b                   	pop    %ebx
  801ea7:	5e                   	pop    %esi
  801ea8:	5f                   	pop    %edi
  801ea9:	5d                   	pop    %ebp
  801eaa:	c3                   	ret    

00801eab <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eab:	55                   	push   %ebp
  801eac:	89 e5                	mov    %esp,%ebp
  801eae:	56                   	push   %esi
  801eaf:	53                   	push   %ebx
  801eb0:	8b 75 08             	mov    0x8(%ebp),%esi
  801eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801eb9:	85 c0                	test   %eax,%eax
  801ebb:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ec0:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ec3:	83 ec 0c             	sub    $0xc,%esp
  801ec6:	50                   	push   %eax
  801ec7:	e8 3a e4 ff ff       	call   800306 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	85 f6                	test   %esi,%esi
  801ed1:	74 14                	je     801ee7 <ipc_recv+0x3c>
  801ed3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	78 09                	js     801ee5 <ipc_recv+0x3a>
  801edc:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ee2:	8b 52 74             	mov    0x74(%edx),%edx
  801ee5:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801ee7:	85 db                	test   %ebx,%ebx
  801ee9:	74 14                	je     801eff <ipc_recv+0x54>
  801eeb:	ba 00 00 00 00       	mov    $0x0,%edx
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	78 09                	js     801efd <ipc_recv+0x52>
  801ef4:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801efa:	8b 52 78             	mov    0x78(%edx),%edx
  801efd:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801eff:	85 c0                	test   %eax,%eax
  801f01:	78 08                	js     801f0b <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801f03:	a1 00 40 80 00       	mov    0x804000,%eax
  801f08:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f0e:	5b                   	pop    %ebx
  801f0f:	5e                   	pop    %esi
  801f10:	5d                   	pop    %ebp
  801f11:	c3                   	ret    

00801f12 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	57                   	push   %edi
  801f16:	56                   	push   %esi
  801f17:	53                   	push   %ebx
  801f18:	83 ec 0c             	sub    $0xc,%esp
  801f1b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f24:	85 db                	test   %ebx,%ebx
  801f26:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f2b:	0f 44 d8             	cmove  %eax,%ebx
  801f2e:	eb 05                	jmp    801f35 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f30:	e8 02 e2 ff ff       	call   800137 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f35:	ff 75 14             	push   0x14(%ebp)
  801f38:	53                   	push   %ebx
  801f39:	56                   	push   %esi
  801f3a:	57                   	push   %edi
  801f3b:	e8 a3 e3 ff ff       	call   8002e3 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f40:	83 c4 10             	add    $0x10,%esp
  801f43:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f46:	74 e8                	je     801f30 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f48:	85 c0                	test   %eax,%eax
  801f4a:	78 08                	js     801f54 <ipc_send+0x42>
	}while (r<0);

}
  801f4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4f:	5b                   	pop    %ebx
  801f50:	5e                   	pop    %esi
  801f51:	5f                   	pop    %edi
  801f52:	5d                   	pop    %ebp
  801f53:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f54:	50                   	push   %eax
  801f55:	68 9f 26 80 00       	push   $0x80269f
  801f5a:	6a 3d                	push   $0x3d
  801f5c:	68 b3 26 80 00       	push   $0x8026b3
  801f61:	e8 50 f5 ff ff       	call   8014b6 <_panic>

00801f66 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f66:	55                   	push   %ebp
  801f67:	89 e5                	mov    %esp,%ebp
  801f69:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f6c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f71:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f74:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f7a:	8b 52 50             	mov    0x50(%edx),%edx
  801f7d:	39 ca                	cmp    %ecx,%edx
  801f7f:	74 11                	je     801f92 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801f81:	83 c0 01             	add    $0x1,%eax
  801f84:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f89:	75 e6                	jne    801f71 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f8b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f90:	eb 0b                	jmp    801f9d <ipc_find_env+0x37>
			return envs[i].env_id;
  801f92:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f95:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f9a:	8b 40 48             	mov    0x48(%eax),%eax
}
  801f9d:	5d                   	pop    %ebp
  801f9e:	c3                   	ret    

00801f9f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f9f:	55                   	push   %ebp
  801fa0:	89 e5                	mov    %esp,%ebp
  801fa2:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa5:	89 c2                	mov    %eax,%edx
  801fa7:	c1 ea 16             	shr    $0x16,%edx
  801faa:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fb1:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fb6:	f6 c1 01             	test   $0x1,%cl
  801fb9:	74 1c                	je     801fd7 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801fbb:	c1 e8 0c             	shr    $0xc,%eax
  801fbe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fc5:	a8 01                	test   $0x1,%al
  801fc7:	74 0e                	je     801fd7 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fc9:	c1 e8 0c             	shr    $0xc,%eax
  801fcc:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801fd3:	ef 
  801fd4:	0f b7 d2             	movzwl %dx,%edx
}
  801fd7:	89 d0                	mov    %edx,%eax
  801fd9:	5d                   	pop    %ebp
  801fda:	c3                   	ret    
  801fdb:	66 90                	xchg   %ax,%ax
  801fdd:	66 90                	xchg   %ax,%ax
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
