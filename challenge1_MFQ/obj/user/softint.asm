
obj/user/softint.debug：     文件格式 elf32-i386


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
  80002c:	e8 05 00 00 00       	call   800036 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	asm volatile("int $14");	// page fault
  800033:	cd 0e                	int    $0xe
}
  800035:	c3                   	ret    

00800036 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800036:	55                   	push   %ebp
  800037:	89 e5                	mov    %esp,%ebp
  800039:	56                   	push   %esi
  80003a:	53                   	push   %ebx
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800041:	e8 d1 00 00 00       	call   800117 <sys_getenvid>
  800046:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004b:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x30>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800085:	e8 ee 04 00 00       	call   800578 <close_all>
	sys_env_destroy(0);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7f 08                	jg     800100 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000fb:	5b                   	pop    %ebx
  8000fc:	5e                   	pop    %esi
  8000fd:	5f                   	pop    %edi
  8000fe:	5d                   	pop    %ebp
  8000ff:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800100:	83 ec 0c             	sub    $0xc,%esp
  800103:	50                   	push   %eax
  800104:	6a 03                	push   $0x3
  800106:	68 4a 22 80 00       	push   $0x80224a
  80010b:	6a 2a                	push   $0x2a
  80010d:	68 67 22 80 00       	push   $0x802267
  800112:	e8 9e 13 00 00       	call   8014b5 <_panic>

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_yield>:

void
sys_yield(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 0b 00 00 00       	mov    $0xb,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80015e:	be 00 00 00 00       	mov    $0x0,%esi
  800163:	8b 55 08             	mov    0x8(%ebp),%edx
  800166:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800169:	b8 04 00 00 00       	mov    $0x4,%eax
  80016e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800171:	89 f7                	mov    %esi,%edi
  800173:	cd 30                	int    $0x30
	if(check && ret > 0)
  800175:	85 c0                	test   %eax,%eax
  800177:	7f 08                	jg     800181 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800179:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	6a 04                	push   $0x4
  800187:	68 4a 22 80 00       	push   $0x80224a
  80018c:	6a 2a                	push   $0x2a
  80018e:	68 67 22 80 00       	push   $0x802267
  800193:	e8 1d 13 00 00       	call   8014b5 <_panic>

00800198 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	7f 08                	jg     8001c3 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001be:	5b                   	pop    %ebx
  8001bf:	5e                   	pop    %esi
  8001c0:	5f                   	pop    %edi
  8001c1:	5d                   	pop    %ebp
  8001c2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c3:	83 ec 0c             	sub    $0xc,%esp
  8001c6:	50                   	push   %eax
  8001c7:	6a 05                	push   $0x5
  8001c9:	68 4a 22 80 00       	push   $0x80224a
  8001ce:	6a 2a                	push   $0x2a
  8001d0:	68 67 22 80 00       	push   $0x802267
  8001d5:	e8 db 12 00 00       	call   8014b5 <_panic>

008001da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f3:	89 df                	mov    %ebx,%edi
  8001f5:	89 de                	mov    %ebx,%esi
  8001f7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f9:	85 c0                	test   %eax,%eax
  8001fb:	7f 08                	jg     800205 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800200:	5b                   	pop    %ebx
  800201:	5e                   	pop    %esi
  800202:	5f                   	pop    %edi
  800203:	5d                   	pop    %ebp
  800204:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800205:	83 ec 0c             	sub    $0xc,%esp
  800208:	50                   	push   %eax
  800209:	6a 06                	push   $0x6
  80020b:	68 4a 22 80 00       	push   $0x80224a
  800210:	6a 2a                	push   $0x2a
  800212:	68 67 22 80 00       	push   $0x802267
  800217:	e8 99 12 00 00       	call   8014b5 <_panic>

0080021c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	8b 55 08             	mov    0x8(%ebp),%edx
  80022d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800230:	b8 08 00 00 00       	mov    $0x8,%eax
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7f 08                	jg     800247 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80023f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800242:	5b                   	pop    %ebx
  800243:	5e                   	pop    %esi
  800244:	5f                   	pop    %edi
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800247:	83 ec 0c             	sub    $0xc,%esp
  80024a:	50                   	push   %eax
  80024b:	6a 08                	push   $0x8
  80024d:	68 4a 22 80 00       	push   $0x80224a
  800252:	6a 2a                	push   $0x2a
  800254:	68 67 22 80 00       	push   $0x802267
  800259:	e8 57 12 00 00       	call   8014b5 <_panic>

0080025e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	57                   	push   %edi
  800262:	56                   	push   %esi
  800263:	53                   	push   %ebx
  800264:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026c:	8b 55 08             	mov    0x8(%ebp),%edx
  80026f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800272:	b8 09 00 00 00       	mov    $0x9,%eax
  800277:	89 df                	mov    %ebx,%edi
  800279:	89 de                	mov    %ebx,%esi
  80027b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027d:	85 c0                	test   %eax,%eax
  80027f:	7f 08                	jg     800289 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800281:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800284:	5b                   	pop    %ebx
  800285:	5e                   	pop    %esi
  800286:	5f                   	pop    %edi
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800289:	83 ec 0c             	sub    $0xc,%esp
  80028c:	50                   	push   %eax
  80028d:	6a 09                	push   $0x9
  80028f:	68 4a 22 80 00       	push   $0x80224a
  800294:	6a 2a                	push   $0x2a
  800296:	68 67 22 80 00       	push   $0x802267
  80029b:	e8 15 12 00 00       	call   8014b5 <_panic>

008002a0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b9:	89 df                	mov    %ebx,%edi
  8002bb:	89 de                	mov    %ebx,%esi
  8002bd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	7f 08                	jg     8002cb <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c6:	5b                   	pop    %ebx
  8002c7:	5e                   	pop    %esi
  8002c8:	5f                   	pop    %edi
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cb:	83 ec 0c             	sub    $0xc,%esp
  8002ce:	50                   	push   %eax
  8002cf:	6a 0a                	push   $0xa
  8002d1:	68 4a 22 80 00       	push   $0x80224a
  8002d6:	6a 2a                	push   $0x2a
  8002d8:	68 67 22 80 00       	push   $0x802267
  8002dd:	e8 d3 11 00 00       	call   8014b5 <_panic>

008002e2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f3:	be 00 00 00 00       	mov    $0x0,%esi
  8002f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fe:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80030e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800313:	8b 55 08             	mov    0x8(%ebp),%edx
  800316:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031b:	89 cb                	mov    %ecx,%ebx
  80031d:	89 cf                	mov    %ecx,%edi
  80031f:	89 ce                	mov    %ecx,%esi
  800321:	cd 30                	int    $0x30
	if(check && ret > 0)
  800323:	85 c0                	test   %eax,%eax
  800325:	7f 08                	jg     80032f <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800327:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032a:	5b                   	pop    %ebx
  80032b:	5e                   	pop    %esi
  80032c:	5f                   	pop    %edi
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80032f:	83 ec 0c             	sub    $0xc,%esp
  800332:	50                   	push   %eax
  800333:	6a 0d                	push   $0xd
  800335:	68 4a 22 80 00       	push   $0x80224a
  80033a:	6a 2a                	push   $0x2a
  80033c:	68 67 22 80 00       	push   $0x802267
  800341:	e8 6f 11 00 00       	call   8014b5 <_panic>

00800346 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	57                   	push   %edi
  80034a:	56                   	push   %esi
  80034b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80034c:	ba 00 00 00 00       	mov    $0x0,%edx
  800351:	b8 0e 00 00 00       	mov    $0xe,%eax
  800356:	89 d1                	mov    %edx,%ecx
  800358:	89 d3                	mov    %edx,%ebx
  80035a:	89 d7                	mov    %edx,%edi
  80035c:	89 d6                	mov    %edx,%esi
  80035e:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800360:	5b                   	pop    %ebx
  800361:	5e                   	pop    %esi
  800362:	5f                   	pop    %edi
  800363:	5d                   	pop    %ebp
  800364:	c3                   	ret    

00800365 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
  800368:	57                   	push   %edi
  800369:	56                   	push   %esi
  80036a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80036b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800370:	8b 55 08             	mov    0x8(%ebp),%edx
  800373:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800376:	b8 0f 00 00 00       	mov    $0xf,%eax
  80037b:	89 df                	mov    %ebx,%edi
  80037d:	89 de                	mov    %ebx,%esi
  80037f:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800381:	5b                   	pop    %ebx
  800382:	5e                   	pop    %esi
  800383:	5f                   	pop    %edi
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	57                   	push   %edi
  80038a:	56                   	push   %esi
  80038b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80038c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800391:	8b 55 08             	mov    0x8(%ebp),%edx
  800394:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800397:	b8 10 00 00 00       	mov    $0x10,%eax
  80039c:	89 df                	mov    %ebx,%edi
  80039e:	89 de                	mov    %ebx,%esi
  8003a0:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8003a2:	5b                   	pop    %ebx
  8003a3:	5e                   	pop    %esi
  8003a4:	5f                   	pop    %edi
  8003a5:	5d                   	pop    %ebp
  8003a6:	c3                   	ret    

008003a7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ad:	05 00 00 00 30       	add    $0x30000000,%eax
  8003b2:	c1 e8 0c             	shr    $0xc,%eax
}
  8003b5:	5d                   	pop    %ebp
  8003b6:	c3                   	ret    

008003b7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bd:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003c2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003c7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003cc:	5d                   	pop    %ebp
  8003cd:	c3                   	ret    

008003ce <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003d6:	89 c2                	mov    %eax,%edx
  8003d8:	c1 ea 16             	shr    $0x16,%edx
  8003db:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e2:	f6 c2 01             	test   $0x1,%dl
  8003e5:	74 29                	je     800410 <fd_alloc+0x42>
  8003e7:	89 c2                	mov    %eax,%edx
  8003e9:	c1 ea 0c             	shr    $0xc,%edx
  8003ec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f3:	f6 c2 01             	test   $0x1,%dl
  8003f6:	74 18                	je     800410 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8003f8:	05 00 10 00 00       	add    $0x1000,%eax
  8003fd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800402:	75 d2                	jne    8003d6 <fd_alloc+0x8>
  800404:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800409:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80040e:	eb 05                	jmp    800415 <fd_alloc+0x47>
			return 0;
  800410:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800415:	8b 55 08             	mov    0x8(%ebp),%edx
  800418:	89 02                	mov    %eax,(%edx)
}
  80041a:	89 c8                	mov    %ecx,%eax
  80041c:	5d                   	pop    %ebp
  80041d:	c3                   	ret    

0080041e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80041e:	55                   	push   %ebp
  80041f:	89 e5                	mov    %esp,%ebp
  800421:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800424:	83 f8 1f             	cmp    $0x1f,%eax
  800427:	77 30                	ja     800459 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800429:	c1 e0 0c             	shl    $0xc,%eax
  80042c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800431:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800437:	f6 c2 01             	test   $0x1,%dl
  80043a:	74 24                	je     800460 <fd_lookup+0x42>
  80043c:	89 c2                	mov    %eax,%edx
  80043e:	c1 ea 0c             	shr    $0xc,%edx
  800441:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800448:	f6 c2 01             	test   $0x1,%dl
  80044b:	74 1a                	je     800467 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80044d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800450:	89 02                	mov    %eax,(%edx)
	return 0;
  800452:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800457:	5d                   	pop    %ebp
  800458:	c3                   	ret    
		return -E_INVAL;
  800459:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80045e:	eb f7                	jmp    800457 <fd_lookup+0x39>
		return -E_INVAL;
  800460:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800465:	eb f0                	jmp    800457 <fd_lookup+0x39>
  800467:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80046c:	eb e9                	jmp    800457 <fd_lookup+0x39>

0080046e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	53                   	push   %ebx
  800472:	83 ec 04             	sub    $0x4,%esp
  800475:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800478:	b8 00 00 00 00       	mov    $0x0,%eax
  80047d:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800482:	39 13                	cmp    %edx,(%ebx)
  800484:	74 37                	je     8004bd <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800486:	83 c0 01             	add    $0x1,%eax
  800489:	8b 1c 85 f4 22 80 00 	mov    0x8022f4(,%eax,4),%ebx
  800490:	85 db                	test   %ebx,%ebx
  800492:	75 ee                	jne    800482 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800494:	a1 00 40 80 00       	mov    0x804000,%eax
  800499:	8b 40 58             	mov    0x58(%eax),%eax
  80049c:	83 ec 04             	sub    $0x4,%esp
  80049f:	52                   	push   %edx
  8004a0:	50                   	push   %eax
  8004a1:	68 78 22 80 00       	push   $0x802278
  8004a6:	e8 e5 10 00 00       	call   801590 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8004b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004b6:	89 1a                	mov    %ebx,(%edx)
}
  8004b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004bb:	c9                   	leave  
  8004bc:	c3                   	ret    
			return 0;
  8004bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c2:	eb ef                	jmp    8004b3 <dev_lookup+0x45>

008004c4 <fd_close>:
{
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	57                   	push   %edi
  8004c8:	56                   	push   %esi
  8004c9:	53                   	push   %ebx
  8004ca:	83 ec 24             	sub    $0x24,%esp
  8004cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004d3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004d6:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004d7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004dd:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e0:	50                   	push   %eax
  8004e1:	e8 38 ff ff ff       	call   80041e <fd_lookup>
  8004e6:	89 c3                	mov    %eax,%ebx
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	78 05                	js     8004f4 <fd_close+0x30>
	    || fd != fd2)
  8004ef:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004f2:	74 16                	je     80050a <fd_close+0x46>
		return (must_exist ? r : 0);
  8004f4:	89 f8                	mov    %edi,%eax
  8004f6:	84 c0                	test   %al,%al
  8004f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fd:	0f 44 d8             	cmove  %eax,%ebx
}
  800500:	89 d8                	mov    %ebx,%eax
  800502:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800505:	5b                   	pop    %ebx
  800506:	5e                   	pop    %esi
  800507:	5f                   	pop    %edi
  800508:	5d                   	pop    %ebp
  800509:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800510:	50                   	push   %eax
  800511:	ff 36                	push   (%esi)
  800513:	e8 56 ff ff ff       	call   80046e <dev_lookup>
  800518:	89 c3                	mov    %eax,%ebx
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	85 c0                	test   %eax,%eax
  80051f:	78 1a                	js     80053b <fd_close+0x77>
		if (dev->dev_close)
  800521:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800524:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800527:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80052c:	85 c0                	test   %eax,%eax
  80052e:	74 0b                	je     80053b <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800530:	83 ec 0c             	sub    $0xc,%esp
  800533:	56                   	push   %esi
  800534:	ff d0                	call   *%eax
  800536:	89 c3                	mov    %eax,%ebx
  800538:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	56                   	push   %esi
  80053f:	6a 00                	push   $0x0
  800541:	e8 94 fc ff ff       	call   8001da <sys_page_unmap>
	return r;
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	eb b5                	jmp    800500 <fd_close+0x3c>

0080054b <close>:

int
close(int fdnum)
{
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
  80054e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800551:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800554:	50                   	push   %eax
  800555:	ff 75 08             	push   0x8(%ebp)
  800558:	e8 c1 fe ff ff       	call   80041e <fd_lookup>
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 02                	jns    800566 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800564:	c9                   	leave  
  800565:	c3                   	ret    
		return fd_close(fd, 1);
  800566:	83 ec 08             	sub    $0x8,%esp
  800569:	6a 01                	push   $0x1
  80056b:	ff 75 f4             	push   -0xc(%ebp)
  80056e:	e8 51 ff ff ff       	call   8004c4 <fd_close>
  800573:	83 c4 10             	add    $0x10,%esp
  800576:	eb ec                	jmp    800564 <close+0x19>

00800578 <close_all>:

void
close_all(void)
{
  800578:	55                   	push   %ebp
  800579:	89 e5                	mov    %esp,%ebp
  80057b:	53                   	push   %ebx
  80057c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80057f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800584:	83 ec 0c             	sub    $0xc,%esp
  800587:	53                   	push   %ebx
  800588:	e8 be ff ff ff       	call   80054b <close>
	for (i = 0; i < MAXFD; i++)
  80058d:	83 c3 01             	add    $0x1,%ebx
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	83 fb 20             	cmp    $0x20,%ebx
  800596:	75 ec                	jne    800584 <close_all+0xc>
}
  800598:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80059b:	c9                   	leave  
  80059c:	c3                   	ret    

0080059d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80059d:	55                   	push   %ebp
  80059e:	89 e5                	mov    %esp,%ebp
  8005a0:	57                   	push   %edi
  8005a1:	56                   	push   %esi
  8005a2:	53                   	push   %ebx
  8005a3:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005a6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005a9:	50                   	push   %eax
  8005aa:	ff 75 08             	push   0x8(%ebp)
  8005ad:	e8 6c fe ff ff       	call   80041e <fd_lookup>
  8005b2:	89 c3                	mov    %eax,%ebx
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	85 c0                	test   %eax,%eax
  8005b9:	78 7f                	js     80063a <dup+0x9d>
		return r;
	close(newfdnum);
  8005bb:	83 ec 0c             	sub    $0xc,%esp
  8005be:	ff 75 0c             	push   0xc(%ebp)
  8005c1:	e8 85 ff ff ff       	call   80054b <close>

	newfd = INDEX2FD(newfdnum);
  8005c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005c9:	c1 e6 0c             	shl    $0xc,%esi
  8005cc:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d5:	89 3c 24             	mov    %edi,(%esp)
  8005d8:	e8 da fd ff ff       	call   8003b7 <fd2data>
  8005dd:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005df:	89 34 24             	mov    %esi,(%esp)
  8005e2:	e8 d0 fd ff ff       	call   8003b7 <fd2data>
  8005e7:	83 c4 10             	add    $0x10,%esp
  8005ea:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005ed:	89 d8                	mov    %ebx,%eax
  8005ef:	c1 e8 16             	shr    $0x16,%eax
  8005f2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005f9:	a8 01                	test   $0x1,%al
  8005fb:	74 11                	je     80060e <dup+0x71>
  8005fd:	89 d8                	mov    %ebx,%eax
  8005ff:	c1 e8 0c             	shr    $0xc,%eax
  800602:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800609:	f6 c2 01             	test   $0x1,%dl
  80060c:	75 36                	jne    800644 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060e:	89 f8                	mov    %edi,%eax
  800610:	c1 e8 0c             	shr    $0xc,%eax
  800613:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80061a:	83 ec 0c             	sub    $0xc,%esp
  80061d:	25 07 0e 00 00       	and    $0xe07,%eax
  800622:	50                   	push   %eax
  800623:	56                   	push   %esi
  800624:	6a 00                	push   $0x0
  800626:	57                   	push   %edi
  800627:	6a 00                	push   $0x0
  800629:	e8 6a fb ff ff       	call   800198 <sys_page_map>
  80062e:	89 c3                	mov    %eax,%ebx
  800630:	83 c4 20             	add    $0x20,%esp
  800633:	85 c0                	test   %eax,%eax
  800635:	78 33                	js     80066a <dup+0xcd>
		goto err;

	return newfdnum;
  800637:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80063a:	89 d8                	mov    %ebx,%eax
  80063c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063f:	5b                   	pop    %ebx
  800640:	5e                   	pop    %esi
  800641:	5f                   	pop    %edi
  800642:	5d                   	pop    %ebp
  800643:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800644:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80064b:	83 ec 0c             	sub    $0xc,%esp
  80064e:	25 07 0e 00 00       	and    $0xe07,%eax
  800653:	50                   	push   %eax
  800654:	ff 75 d4             	push   -0x2c(%ebp)
  800657:	6a 00                	push   $0x0
  800659:	53                   	push   %ebx
  80065a:	6a 00                	push   $0x0
  80065c:	e8 37 fb ff ff       	call   800198 <sys_page_map>
  800661:	89 c3                	mov    %eax,%ebx
  800663:	83 c4 20             	add    $0x20,%esp
  800666:	85 c0                	test   %eax,%eax
  800668:	79 a4                	jns    80060e <dup+0x71>
	sys_page_unmap(0, newfd);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	56                   	push   %esi
  80066e:	6a 00                	push   $0x0
  800670:	e8 65 fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  800675:	83 c4 08             	add    $0x8,%esp
  800678:	ff 75 d4             	push   -0x2c(%ebp)
  80067b:	6a 00                	push   $0x0
  80067d:	e8 58 fb ff ff       	call   8001da <sys_page_unmap>
	return r;
  800682:	83 c4 10             	add    $0x10,%esp
  800685:	eb b3                	jmp    80063a <dup+0x9d>

00800687 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
  80068a:	56                   	push   %esi
  80068b:	53                   	push   %ebx
  80068c:	83 ec 18             	sub    $0x18,%esp
  80068f:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800692:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800695:	50                   	push   %eax
  800696:	56                   	push   %esi
  800697:	e8 82 fd ff ff       	call   80041e <fd_lookup>
  80069c:	83 c4 10             	add    $0x10,%esp
  80069f:	85 c0                	test   %eax,%eax
  8006a1:	78 3c                	js     8006df <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a3:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006ac:	50                   	push   %eax
  8006ad:	ff 33                	push   (%ebx)
  8006af:	e8 ba fd ff ff       	call   80046e <dev_lookup>
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	85 c0                	test   %eax,%eax
  8006b9:	78 24                	js     8006df <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006bb:	8b 43 08             	mov    0x8(%ebx),%eax
  8006be:	83 e0 03             	and    $0x3,%eax
  8006c1:	83 f8 01             	cmp    $0x1,%eax
  8006c4:	74 20                	je     8006e6 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c9:	8b 40 08             	mov    0x8(%eax),%eax
  8006cc:	85 c0                	test   %eax,%eax
  8006ce:	74 37                	je     800707 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006d0:	83 ec 04             	sub    $0x4,%esp
  8006d3:	ff 75 10             	push   0x10(%ebp)
  8006d6:	ff 75 0c             	push   0xc(%ebp)
  8006d9:	53                   	push   %ebx
  8006da:	ff d0                	call   *%eax
  8006dc:	83 c4 10             	add    $0x10,%esp
}
  8006df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006e2:	5b                   	pop    %ebx
  8006e3:	5e                   	pop    %esi
  8006e4:	5d                   	pop    %ebp
  8006e5:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006e6:	a1 00 40 80 00       	mov    0x804000,%eax
  8006eb:	8b 40 58             	mov    0x58(%eax),%eax
  8006ee:	83 ec 04             	sub    $0x4,%esp
  8006f1:	56                   	push   %esi
  8006f2:	50                   	push   %eax
  8006f3:	68 b9 22 80 00       	push   $0x8022b9
  8006f8:	e8 93 0e 00 00       	call   801590 <cprintf>
		return -E_INVAL;
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800705:	eb d8                	jmp    8006df <read+0x58>
		return -E_NOT_SUPP;
  800707:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80070c:	eb d1                	jmp    8006df <read+0x58>

0080070e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80070e:	55                   	push   %ebp
  80070f:	89 e5                	mov    %esp,%ebp
  800711:	57                   	push   %edi
  800712:	56                   	push   %esi
  800713:	53                   	push   %ebx
  800714:	83 ec 0c             	sub    $0xc,%esp
  800717:	8b 7d 08             	mov    0x8(%ebp),%edi
  80071a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80071d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800722:	eb 02                	jmp    800726 <readn+0x18>
  800724:	01 c3                	add    %eax,%ebx
  800726:	39 f3                	cmp    %esi,%ebx
  800728:	73 21                	jae    80074b <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80072a:	83 ec 04             	sub    $0x4,%esp
  80072d:	89 f0                	mov    %esi,%eax
  80072f:	29 d8                	sub    %ebx,%eax
  800731:	50                   	push   %eax
  800732:	89 d8                	mov    %ebx,%eax
  800734:	03 45 0c             	add    0xc(%ebp),%eax
  800737:	50                   	push   %eax
  800738:	57                   	push   %edi
  800739:	e8 49 ff ff ff       	call   800687 <read>
		if (m < 0)
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	85 c0                	test   %eax,%eax
  800743:	78 04                	js     800749 <readn+0x3b>
			return m;
		if (m == 0)
  800745:	75 dd                	jne    800724 <readn+0x16>
  800747:	eb 02                	jmp    80074b <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800749:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80074b:	89 d8                	mov    %ebx,%eax
  80074d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800750:	5b                   	pop    %ebx
  800751:	5e                   	pop    %esi
  800752:	5f                   	pop    %edi
  800753:	5d                   	pop    %ebp
  800754:	c3                   	ret    

00800755 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	56                   	push   %esi
  800759:	53                   	push   %ebx
  80075a:	83 ec 18             	sub    $0x18,%esp
  80075d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800760:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800763:	50                   	push   %eax
  800764:	53                   	push   %ebx
  800765:	e8 b4 fc ff ff       	call   80041e <fd_lookup>
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	85 c0                	test   %eax,%eax
  80076f:	78 37                	js     8007a8 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800771:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800774:	83 ec 08             	sub    $0x8,%esp
  800777:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80077a:	50                   	push   %eax
  80077b:	ff 36                	push   (%esi)
  80077d:	e8 ec fc ff ff       	call   80046e <dev_lookup>
  800782:	83 c4 10             	add    $0x10,%esp
  800785:	85 c0                	test   %eax,%eax
  800787:	78 1f                	js     8007a8 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800789:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80078d:	74 20                	je     8007af <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80078f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800792:	8b 40 0c             	mov    0xc(%eax),%eax
  800795:	85 c0                	test   %eax,%eax
  800797:	74 37                	je     8007d0 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800799:	83 ec 04             	sub    $0x4,%esp
  80079c:	ff 75 10             	push   0x10(%ebp)
  80079f:	ff 75 0c             	push   0xc(%ebp)
  8007a2:	56                   	push   %esi
  8007a3:	ff d0                	call   *%eax
  8007a5:	83 c4 10             	add    $0x10,%esp
}
  8007a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007ab:	5b                   	pop    %ebx
  8007ac:	5e                   	pop    %esi
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007af:	a1 00 40 80 00       	mov    0x804000,%eax
  8007b4:	8b 40 58             	mov    0x58(%eax),%eax
  8007b7:	83 ec 04             	sub    $0x4,%esp
  8007ba:	53                   	push   %ebx
  8007bb:	50                   	push   %eax
  8007bc:	68 d5 22 80 00       	push   $0x8022d5
  8007c1:	e8 ca 0d 00 00       	call   801590 <cprintf>
		return -E_INVAL;
  8007c6:	83 c4 10             	add    $0x10,%esp
  8007c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ce:	eb d8                	jmp    8007a8 <write+0x53>
		return -E_NOT_SUPP;
  8007d0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007d5:	eb d1                	jmp    8007a8 <write+0x53>

008007d7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e0:	50                   	push   %eax
  8007e1:	ff 75 08             	push   0x8(%ebp)
  8007e4:	e8 35 fc ff ff       	call   80041e <fd_lookup>
  8007e9:	83 c4 10             	add    $0x10,%esp
  8007ec:	85 c0                	test   %eax,%eax
  8007ee:	78 0e                	js     8007fe <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	56                   	push   %esi
  800804:	53                   	push   %ebx
  800805:	83 ec 18             	sub    $0x18,%esp
  800808:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80080b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80080e:	50                   	push   %eax
  80080f:	53                   	push   %ebx
  800810:	e8 09 fc ff ff       	call   80041e <fd_lookup>
  800815:	83 c4 10             	add    $0x10,%esp
  800818:	85 c0                	test   %eax,%eax
  80081a:	78 34                	js     800850 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80081c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800825:	50                   	push   %eax
  800826:	ff 36                	push   (%esi)
  800828:	e8 41 fc ff ff       	call   80046e <dev_lookup>
  80082d:	83 c4 10             	add    $0x10,%esp
  800830:	85 c0                	test   %eax,%eax
  800832:	78 1c                	js     800850 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800834:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800838:	74 1d                	je     800857 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80083a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083d:	8b 40 18             	mov    0x18(%eax),%eax
  800840:	85 c0                	test   %eax,%eax
  800842:	74 34                	je     800878 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800844:	83 ec 08             	sub    $0x8,%esp
  800847:	ff 75 0c             	push   0xc(%ebp)
  80084a:	56                   	push   %esi
  80084b:	ff d0                	call   *%eax
  80084d:	83 c4 10             	add    $0x10,%esp
}
  800850:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800853:	5b                   	pop    %ebx
  800854:	5e                   	pop    %esi
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    
			thisenv->env_id, fdnum);
  800857:	a1 00 40 80 00       	mov    0x804000,%eax
  80085c:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80085f:	83 ec 04             	sub    $0x4,%esp
  800862:	53                   	push   %ebx
  800863:	50                   	push   %eax
  800864:	68 98 22 80 00       	push   $0x802298
  800869:	e8 22 0d 00 00       	call   801590 <cprintf>
		return -E_INVAL;
  80086e:	83 c4 10             	add    $0x10,%esp
  800871:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800876:	eb d8                	jmp    800850 <ftruncate+0x50>
		return -E_NOT_SUPP;
  800878:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80087d:	eb d1                	jmp    800850 <ftruncate+0x50>

0080087f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	56                   	push   %esi
  800883:	53                   	push   %ebx
  800884:	83 ec 18             	sub    $0x18,%esp
  800887:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80088a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80088d:	50                   	push   %eax
  80088e:	ff 75 08             	push   0x8(%ebp)
  800891:	e8 88 fb ff ff       	call   80041e <fd_lookup>
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	85 c0                	test   %eax,%eax
  80089b:	78 49                	js     8008e6 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80089d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8008a0:	83 ec 08             	sub    $0x8,%esp
  8008a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a6:	50                   	push   %eax
  8008a7:	ff 36                	push   (%esi)
  8008a9:	e8 c0 fb ff ff       	call   80046e <dev_lookup>
  8008ae:	83 c4 10             	add    $0x10,%esp
  8008b1:	85 c0                	test   %eax,%eax
  8008b3:	78 31                	js     8008e6 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8008b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008bc:	74 2f                	je     8008ed <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008be:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c8:	00 00 00 
	stat->st_isdir = 0;
  8008cb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d2:	00 00 00 
	stat->st_dev = dev;
  8008d5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008db:	83 ec 08             	sub    $0x8,%esp
  8008de:	53                   	push   %ebx
  8008df:	56                   	push   %esi
  8008e0:	ff 50 14             	call   *0x14(%eax)
  8008e3:	83 c4 10             	add    $0x10,%esp
}
  8008e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008e9:	5b                   	pop    %ebx
  8008ea:	5e                   	pop    %esi
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    
		return -E_NOT_SUPP;
  8008ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008f2:	eb f2                	jmp    8008e6 <fstat+0x67>

008008f4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	56                   	push   %esi
  8008f8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008f9:	83 ec 08             	sub    $0x8,%esp
  8008fc:	6a 00                	push   $0x0
  8008fe:	ff 75 08             	push   0x8(%ebp)
  800901:	e8 e4 01 00 00       	call   800aea <open>
  800906:	89 c3                	mov    %eax,%ebx
  800908:	83 c4 10             	add    $0x10,%esp
  80090b:	85 c0                	test   %eax,%eax
  80090d:	78 1b                	js     80092a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80090f:	83 ec 08             	sub    $0x8,%esp
  800912:	ff 75 0c             	push   0xc(%ebp)
  800915:	50                   	push   %eax
  800916:	e8 64 ff ff ff       	call   80087f <fstat>
  80091b:	89 c6                	mov    %eax,%esi
	close(fd);
  80091d:	89 1c 24             	mov    %ebx,(%esp)
  800920:	e8 26 fc ff ff       	call   80054b <close>
	return r;
  800925:	83 c4 10             	add    $0x10,%esp
  800928:	89 f3                	mov    %esi,%ebx
}
  80092a:	89 d8                	mov    %ebx,%eax
  80092c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80092f:	5b                   	pop    %ebx
  800930:	5e                   	pop    %esi
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	56                   	push   %esi
  800937:	53                   	push   %ebx
  800938:	89 c6                	mov    %eax,%esi
  80093a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80093c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800943:	74 27                	je     80096c <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800945:	6a 07                	push   $0x7
  800947:	68 00 50 80 00       	push   $0x805000
  80094c:	56                   	push   %esi
  80094d:	ff 35 00 60 80 00    	push   0x806000
  800953:	e8 c2 15 00 00       	call   801f1a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800958:	83 c4 0c             	add    $0xc,%esp
  80095b:	6a 00                	push   $0x0
  80095d:	53                   	push   %ebx
  80095e:	6a 00                	push   $0x0
  800960:	e8 45 15 00 00       	call   801eaa <ipc_recv>
}
  800965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80096c:	83 ec 0c             	sub    $0xc,%esp
  80096f:	6a 01                	push   $0x1
  800971:	e8 f8 15 00 00       	call   801f6e <ipc_find_env>
  800976:	a3 00 60 80 00       	mov    %eax,0x806000
  80097b:	83 c4 10             	add    $0x10,%esp
  80097e:	eb c5                	jmp    800945 <fsipc+0x12>

00800980 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	8b 40 0c             	mov    0xc(%eax),%eax
  80098c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800991:	8b 45 0c             	mov    0xc(%ebp),%eax
  800994:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800999:	ba 00 00 00 00       	mov    $0x0,%edx
  80099e:	b8 02 00 00 00       	mov    $0x2,%eax
  8009a3:	e8 8b ff ff ff       	call   800933 <fsipc>
}
  8009a8:	c9                   	leave  
  8009a9:	c3                   	ret    

008009aa <devfile_flush>:
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c0:	b8 06 00 00 00       	mov    $0x6,%eax
  8009c5:	e8 69 ff ff ff       	call   800933 <fsipc>
}
  8009ca:	c9                   	leave  
  8009cb:	c3                   	ret    

008009cc <devfile_stat>:
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	53                   	push   %ebx
  8009d0:	83 ec 04             	sub    $0x4,%esp
  8009d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8009dc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e6:	b8 05 00 00 00       	mov    $0x5,%eax
  8009eb:	e8 43 ff ff ff       	call   800933 <fsipc>
  8009f0:	85 c0                	test   %eax,%eax
  8009f2:	78 2c                	js     800a20 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009f4:	83 ec 08             	sub    $0x8,%esp
  8009f7:	68 00 50 80 00       	push   $0x805000
  8009fc:	53                   	push   %ebx
  8009fd:	e8 68 11 00 00       	call   801b6a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a02:	a1 80 50 80 00       	mov    0x805080,%eax
  800a07:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a0d:	a1 84 50 80 00       	mov    0x805084,%eax
  800a12:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a18:	83 c4 10             	add    $0x10,%esp
  800a1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a23:	c9                   	leave  
  800a24:	c3                   	ret    

00800a25 <devfile_write>:
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	83 ec 0c             	sub    $0xc,%esp
  800a2b:	8b 45 10             	mov    0x10(%ebp),%eax
  800a2e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a33:	39 d0                	cmp    %edx,%eax
  800a35:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a38:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3b:	8b 52 0c             	mov    0xc(%edx),%edx
  800a3e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a44:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a49:	50                   	push   %eax
  800a4a:	ff 75 0c             	push   0xc(%ebp)
  800a4d:	68 08 50 80 00       	push   $0x805008
  800a52:	e8 a9 12 00 00       	call   801d00 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a57:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5c:	b8 04 00 00 00       	mov    $0x4,%eax
  800a61:	e8 cd fe ff ff       	call   800933 <fsipc>
}
  800a66:	c9                   	leave  
  800a67:	c3                   	ret    

00800a68 <devfile_read>:
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
  800a6d:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	8b 40 0c             	mov    0xc(%eax),%eax
  800a76:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a7b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a81:	ba 00 00 00 00       	mov    $0x0,%edx
  800a86:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8b:	e8 a3 fe ff ff       	call   800933 <fsipc>
  800a90:	89 c3                	mov    %eax,%ebx
  800a92:	85 c0                	test   %eax,%eax
  800a94:	78 1f                	js     800ab5 <devfile_read+0x4d>
	assert(r <= n);
  800a96:	39 f0                	cmp    %esi,%eax
  800a98:	77 24                	ja     800abe <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a9a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a9f:	7f 33                	jg     800ad4 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aa1:	83 ec 04             	sub    $0x4,%esp
  800aa4:	50                   	push   %eax
  800aa5:	68 00 50 80 00       	push   $0x805000
  800aaa:	ff 75 0c             	push   0xc(%ebp)
  800aad:	e8 4e 12 00 00       	call   801d00 <memmove>
	return r;
  800ab2:	83 c4 10             	add    $0x10,%esp
}
  800ab5:	89 d8                	mov    %ebx,%eax
  800ab7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    
	assert(r <= n);
  800abe:	68 08 23 80 00       	push   $0x802308
  800ac3:	68 0f 23 80 00       	push   $0x80230f
  800ac8:	6a 7c                	push   $0x7c
  800aca:	68 24 23 80 00       	push   $0x802324
  800acf:	e8 e1 09 00 00       	call   8014b5 <_panic>
	assert(r <= PGSIZE);
  800ad4:	68 2f 23 80 00       	push   $0x80232f
  800ad9:	68 0f 23 80 00       	push   $0x80230f
  800ade:	6a 7d                	push   $0x7d
  800ae0:	68 24 23 80 00       	push   $0x802324
  800ae5:	e8 cb 09 00 00       	call   8014b5 <_panic>

00800aea <open>:
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	56                   	push   %esi
  800aee:	53                   	push   %ebx
  800aef:	83 ec 1c             	sub    $0x1c,%esp
  800af2:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800af5:	56                   	push   %esi
  800af6:	e8 34 10 00 00       	call   801b2f <strlen>
  800afb:	83 c4 10             	add    $0x10,%esp
  800afe:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b03:	7f 6c                	jg     800b71 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800b05:	83 ec 0c             	sub    $0xc,%esp
  800b08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b0b:	50                   	push   %eax
  800b0c:	e8 bd f8 ff ff       	call   8003ce <fd_alloc>
  800b11:	89 c3                	mov    %eax,%ebx
  800b13:	83 c4 10             	add    $0x10,%esp
  800b16:	85 c0                	test   %eax,%eax
  800b18:	78 3c                	js     800b56 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800b1a:	83 ec 08             	sub    $0x8,%esp
  800b1d:	56                   	push   %esi
  800b1e:	68 00 50 80 00       	push   $0x805000
  800b23:	e8 42 10 00 00       	call   801b6a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2b:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b30:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b33:	b8 01 00 00 00       	mov    $0x1,%eax
  800b38:	e8 f6 fd ff ff       	call   800933 <fsipc>
  800b3d:	89 c3                	mov    %eax,%ebx
  800b3f:	83 c4 10             	add    $0x10,%esp
  800b42:	85 c0                	test   %eax,%eax
  800b44:	78 19                	js     800b5f <open+0x75>
	return fd2num(fd);
  800b46:	83 ec 0c             	sub    $0xc,%esp
  800b49:	ff 75 f4             	push   -0xc(%ebp)
  800b4c:	e8 56 f8 ff ff       	call   8003a7 <fd2num>
  800b51:	89 c3                	mov    %eax,%ebx
  800b53:	83 c4 10             	add    $0x10,%esp
}
  800b56:	89 d8                	mov    %ebx,%eax
  800b58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    
		fd_close(fd, 0);
  800b5f:	83 ec 08             	sub    $0x8,%esp
  800b62:	6a 00                	push   $0x0
  800b64:	ff 75 f4             	push   -0xc(%ebp)
  800b67:	e8 58 f9 ff ff       	call   8004c4 <fd_close>
		return r;
  800b6c:	83 c4 10             	add    $0x10,%esp
  800b6f:	eb e5                	jmp    800b56 <open+0x6c>
		return -E_BAD_PATH;
  800b71:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b76:	eb de                	jmp    800b56 <open+0x6c>

00800b78 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b83:	b8 08 00 00 00       	mov    $0x8,%eax
  800b88:	e8 a6 fd ff ff       	call   800933 <fsipc>
}
  800b8d:	c9                   	leave  
  800b8e:	c3                   	ret    

00800b8f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b95:	68 3b 23 80 00       	push   $0x80233b
  800b9a:	ff 75 0c             	push   0xc(%ebp)
  800b9d:	e8 c8 0f 00 00       	call   801b6a <strcpy>
	return 0;
}
  800ba2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba7:	c9                   	leave  
  800ba8:	c3                   	ret    

00800ba9 <devsock_close>:
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	53                   	push   %ebx
  800bad:	83 ec 10             	sub    $0x10,%esp
  800bb0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bb3:	53                   	push   %ebx
  800bb4:	e8 f4 13 00 00       	call   801fad <pageref>
  800bb9:	89 c2                	mov    %eax,%edx
  800bbb:	83 c4 10             	add    $0x10,%esp
		return 0;
  800bbe:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800bc3:	83 fa 01             	cmp    $0x1,%edx
  800bc6:	74 05                	je     800bcd <devsock_close+0x24>
}
  800bc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bcb:	c9                   	leave  
  800bcc:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800bcd:	83 ec 0c             	sub    $0xc,%esp
  800bd0:	ff 73 0c             	push   0xc(%ebx)
  800bd3:	e8 b7 02 00 00       	call   800e8f <nsipc_close>
  800bd8:	83 c4 10             	add    $0x10,%esp
  800bdb:	eb eb                	jmp    800bc8 <devsock_close+0x1f>

00800bdd <devsock_write>:
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800be3:	6a 00                	push   $0x0
  800be5:	ff 75 10             	push   0x10(%ebp)
  800be8:	ff 75 0c             	push   0xc(%ebp)
  800beb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bee:	ff 70 0c             	push   0xc(%eax)
  800bf1:	e8 79 03 00 00       	call   800f6f <nsipc_send>
}
  800bf6:	c9                   	leave  
  800bf7:	c3                   	ret    

00800bf8 <devsock_read>:
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800bfe:	6a 00                	push   $0x0
  800c00:	ff 75 10             	push   0x10(%ebp)
  800c03:	ff 75 0c             	push   0xc(%ebp)
  800c06:	8b 45 08             	mov    0x8(%ebp),%eax
  800c09:	ff 70 0c             	push   0xc(%eax)
  800c0c:	e8 ef 02 00 00       	call   800f00 <nsipc_recv>
}
  800c11:	c9                   	leave  
  800c12:	c3                   	ret    

00800c13 <fd2sockid>:
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c19:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c1c:	52                   	push   %edx
  800c1d:	50                   	push   %eax
  800c1e:	e8 fb f7 ff ff       	call   80041e <fd_lookup>
  800c23:	83 c4 10             	add    $0x10,%esp
  800c26:	85 c0                	test   %eax,%eax
  800c28:	78 10                	js     800c3a <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c2d:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c33:	39 08                	cmp    %ecx,(%eax)
  800c35:	75 05                	jne    800c3c <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c37:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c3a:	c9                   	leave  
  800c3b:	c3                   	ret    
		return -E_NOT_SUPP;
  800c3c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c41:	eb f7                	jmp    800c3a <fd2sockid+0x27>

00800c43 <alloc_sockfd>:
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 1c             	sub    $0x1c,%esp
  800c4b:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c50:	50                   	push   %eax
  800c51:	e8 78 f7 ff ff       	call   8003ce <fd_alloc>
  800c56:	89 c3                	mov    %eax,%ebx
  800c58:	83 c4 10             	add    $0x10,%esp
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	78 43                	js     800ca2 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c5f:	83 ec 04             	sub    $0x4,%esp
  800c62:	68 07 04 00 00       	push   $0x407
  800c67:	ff 75 f4             	push   -0xc(%ebp)
  800c6a:	6a 00                	push   $0x0
  800c6c:	e8 e4 f4 ff ff       	call   800155 <sys_page_alloc>
  800c71:	89 c3                	mov    %eax,%ebx
  800c73:	83 c4 10             	add    $0x10,%esp
  800c76:	85 c0                	test   %eax,%eax
  800c78:	78 28                	js     800ca2 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c7d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c83:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c88:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c8f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c92:	83 ec 0c             	sub    $0xc,%esp
  800c95:	50                   	push   %eax
  800c96:	e8 0c f7 ff ff       	call   8003a7 <fd2num>
  800c9b:	89 c3                	mov    %eax,%ebx
  800c9d:	83 c4 10             	add    $0x10,%esp
  800ca0:	eb 0c                	jmp    800cae <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800ca2:	83 ec 0c             	sub    $0xc,%esp
  800ca5:	56                   	push   %esi
  800ca6:	e8 e4 01 00 00       	call   800e8f <nsipc_close>
		return r;
  800cab:	83 c4 10             	add    $0x10,%esp
}
  800cae:	89 d8                	mov    %ebx,%eax
  800cb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <accept>:
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc0:	e8 4e ff ff ff       	call   800c13 <fd2sockid>
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	78 1b                	js     800ce4 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cc9:	83 ec 04             	sub    $0x4,%esp
  800ccc:	ff 75 10             	push   0x10(%ebp)
  800ccf:	ff 75 0c             	push   0xc(%ebp)
  800cd2:	50                   	push   %eax
  800cd3:	e8 0e 01 00 00       	call   800de6 <nsipc_accept>
  800cd8:	83 c4 10             	add    $0x10,%esp
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	78 05                	js     800ce4 <accept+0x2d>
	return alloc_sockfd(r);
  800cdf:	e8 5f ff ff ff       	call   800c43 <alloc_sockfd>
}
  800ce4:	c9                   	leave  
  800ce5:	c3                   	ret    

00800ce6 <bind>:
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cec:	8b 45 08             	mov    0x8(%ebp),%eax
  800cef:	e8 1f ff ff ff       	call   800c13 <fd2sockid>
  800cf4:	85 c0                	test   %eax,%eax
  800cf6:	78 12                	js     800d0a <bind+0x24>
	return nsipc_bind(r, name, namelen);
  800cf8:	83 ec 04             	sub    $0x4,%esp
  800cfb:	ff 75 10             	push   0x10(%ebp)
  800cfe:	ff 75 0c             	push   0xc(%ebp)
  800d01:	50                   	push   %eax
  800d02:	e8 31 01 00 00       	call   800e38 <nsipc_bind>
  800d07:	83 c4 10             	add    $0x10,%esp
}
  800d0a:	c9                   	leave  
  800d0b:	c3                   	ret    

00800d0c <shutdown>:
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d12:	8b 45 08             	mov    0x8(%ebp),%eax
  800d15:	e8 f9 fe ff ff       	call   800c13 <fd2sockid>
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	78 0f                	js     800d2d <shutdown+0x21>
	return nsipc_shutdown(r, how);
  800d1e:	83 ec 08             	sub    $0x8,%esp
  800d21:	ff 75 0c             	push   0xc(%ebp)
  800d24:	50                   	push   %eax
  800d25:	e8 43 01 00 00       	call   800e6d <nsipc_shutdown>
  800d2a:	83 c4 10             	add    $0x10,%esp
}
  800d2d:	c9                   	leave  
  800d2e:	c3                   	ret    

00800d2f <connect>:
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d35:	8b 45 08             	mov    0x8(%ebp),%eax
  800d38:	e8 d6 fe ff ff       	call   800c13 <fd2sockid>
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	78 12                	js     800d53 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  800d41:	83 ec 04             	sub    $0x4,%esp
  800d44:	ff 75 10             	push   0x10(%ebp)
  800d47:	ff 75 0c             	push   0xc(%ebp)
  800d4a:	50                   	push   %eax
  800d4b:	e8 59 01 00 00       	call   800ea9 <nsipc_connect>
  800d50:	83 c4 10             	add    $0x10,%esp
}
  800d53:	c9                   	leave  
  800d54:	c3                   	ret    

00800d55 <listen>:
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5e:	e8 b0 fe ff ff       	call   800c13 <fd2sockid>
  800d63:	85 c0                	test   %eax,%eax
  800d65:	78 0f                	js     800d76 <listen+0x21>
	return nsipc_listen(r, backlog);
  800d67:	83 ec 08             	sub    $0x8,%esp
  800d6a:	ff 75 0c             	push   0xc(%ebp)
  800d6d:	50                   	push   %eax
  800d6e:	e8 6b 01 00 00       	call   800ede <nsipc_listen>
  800d73:	83 c4 10             	add    $0x10,%esp
}
  800d76:	c9                   	leave  
  800d77:	c3                   	ret    

00800d78 <socket>:

int
socket(int domain, int type, int protocol)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d7e:	ff 75 10             	push   0x10(%ebp)
  800d81:	ff 75 0c             	push   0xc(%ebp)
  800d84:	ff 75 08             	push   0x8(%ebp)
  800d87:	e8 41 02 00 00       	call   800fcd <nsipc_socket>
  800d8c:	83 c4 10             	add    $0x10,%esp
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	78 05                	js     800d98 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800d93:	e8 ab fe ff ff       	call   800c43 <alloc_sockfd>
}
  800d98:	c9                   	leave  
  800d99:	c3                   	ret    

00800d9a <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	53                   	push   %ebx
  800d9e:	83 ec 04             	sub    $0x4,%esp
  800da1:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800da3:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  800daa:	74 26                	je     800dd2 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dac:	6a 07                	push   $0x7
  800dae:	68 00 70 80 00       	push   $0x807000
  800db3:	53                   	push   %ebx
  800db4:	ff 35 00 80 80 00    	push   0x808000
  800dba:	e8 5b 11 00 00       	call   801f1a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dbf:	83 c4 0c             	add    $0xc,%esp
  800dc2:	6a 00                	push   $0x0
  800dc4:	6a 00                	push   $0x0
  800dc6:	6a 00                	push   $0x0
  800dc8:	e8 dd 10 00 00       	call   801eaa <ipc_recv>
}
  800dcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dd0:	c9                   	leave  
  800dd1:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dd2:	83 ec 0c             	sub    $0xc,%esp
  800dd5:	6a 02                	push   $0x2
  800dd7:	e8 92 11 00 00       	call   801f6e <ipc_find_env>
  800ddc:	a3 00 80 80 00       	mov    %eax,0x808000
  800de1:	83 c4 10             	add    $0x10,%esp
  800de4:	eb c6                	jmp    800dac <nsipc+0x12>

00800de6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	56                   	push   %esi
  800dea:	53                   	push   %ebx
  800deb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
  800df1:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800df6:	8b 06                	mov    (%esi),%eax
  800df8:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800dfd:	b8 01 00 00 00       	mov    $0x1,%eax
  800e02:	e8 93 ff ff ff       	call   800d9a <nsipc>
  800e07:	89 c3                	mov    %eax,%ebx
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	79 09                	jns    800e16 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800e0d:	89 d8                	mov    %ebx,%eax
  800e0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e12:	5b                   	pop    %ebx
  800e13:	5e                   	pop    %esi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e16:	83 ec 04             	sub    $0x4,%esp
  800e19:	ff 35 10 70 80 00    	push   0x807010
  800e1f:	68 00 70 80 00       	push   $0x807000
  800e24:	ff 75 0c             	push   0xc(%ebp)
  800e27:	e8 d4 0e 00 00       	call   801d00 <memmove>
		*addrlen = ret->ret_addrlen;
  800e2c:	a1 10 70 80 00       	mov    0x807010,%eax
  800e31:	89 06                	mov    %eax,(%esi)
  800e33:	83 c4 10             	add    $0x10,%esp
	return r;
  800e36:	eb d5                	jmp    800e0d <nsipc_accept+0x27>

00800e38 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	53                   	push   %ebx
  800e3c:	83 ec 08             	sub    $0x8,%esp
  800e3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e42:	8b 45 08             	mov    0x8(%ebp),%eax
  800e45:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e4a:	53                   	push   %ebx
  800e4b:	ff 75 0c             	push   0xc(%ebp)
  800e4e:	68 04 70 80 00       	push   $0x807004
  800e53:	e8 a8 0e 00 00       	call   801d00 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e58:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  800e5e:	b8 02 00 00 00       	mov    $0x2,%eax
  800e63:	e8 32 ff ff ff       	call   800d9a <nsipc>
}
  800e68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e6b:	c9                   	leave  
  800e6c:	c3                   	ret    

00800e6d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e73:	8b 45 08             	mov    0x8(%ebp),%eax
  800e76:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  800e7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7e:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  800e83:	b8 03 00 00 00       	mov    $0x3,%eax
  800e88:	e8 0d ff ff ff       	call   800d9a <nsipc>
}
  800e8d:	c9                   	leave  
  800e8e:	c3                   	ret    

00800e8f <nsipc_close>:

int
nsipc_close(int s)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e95:	8b 45 08             	mov    0x8(%ebp),%eax
  800e98:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  800e9d:	b8 04 00 00 00       	mov    $0x4,%eax
  800ea2:	e8 f3 fe ff ff       	call   800d9a <nsipc>
}
  800ea7:	c9                   	leave  
  800ea8:	c3                   	ret    

00800ea9 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	53                   	push   %ebx
  800ead:	83 ec 08             	sub    $0x8,%esp
  800eb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800eb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb6:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ebb:	53                   	push   %ebx
  800ebc:	ff 75 0c             	push   0xc(%ebp)
  800ebf:	68 04 70 80 00       	push   $0x807004
  800ec4:	e8 37 0e 00 00       	call   801d00 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ec9:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  800ecf:	b8 05 00 00 00       	mov    $0x5,%eax
  800ed4:	e8 c1 fe ff ff       	call   800d9a <nsipc>
}
  800ed9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800edc:	c9                   	leave  
  800edd:	c3                   	ret    

00800ede <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ee4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  800eec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eef:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  800ef4:	b8 06 00 00 00       	mov    $0x6,%eax
  800ef9:	e8 9c fe ff ff       	call   800d9a <nsipc>
}
  800efe:	c9                   	leave  
  800eff:	c3                   	ret    

00800f00 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	56                   	push   %esi
  800f04:	53                   	push   %ebx
  800f05:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f08:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  800f10:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  800f16:	8b 45 14             	mov    0x14(%ebp),%eax
  800f19:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f1e:	b8 07 00 00 00       	mov    $0x7,%eax
  800f23:	e8 72 fe ff ff       	call   800d9a <nsipc>
  800f28:	89 c3                	mov    %eax,%ebx
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	78 22                	js     800f50 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  800f2e:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f33:	39 c6                	cmp    %eax,%esi
  800f35:	0f 4e c6             	cmovle %esi,%eax
  800f38:	39 c3                	cmp    %eax,%ebx
  800f3a:	7f 1d                	jg     800f59 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f3c:	83 ec 04             	sub    $0x4,%esp
  800f3f:	53                   	push   %ebx
  800f40:	68 00 70 80 00       	push   $0x807000
  800f45:	ff 75 0c             	push   0xc(%ebp)
  800f48:	e8 b3 0d 00 00       	call   801d00 <memmove>
  800f4d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f50:	89 d8                	mov    %ebx,%eax
  800f52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f59:	68 47 23 80 00       	push   $0x802347
  800f5e:	68 0f 23 80 00       	push   $0x80230f
  800f63:	6a 62                	push   $0x62
  800f65:	68 5c 23 80 00       	push   $0x80235c
  800f6a:	e8 46 05 00 00       	call   8014b5 <_panic>

00800f6f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	53                   	push   %ebx
  800f73:	83 ec 04             	sub    $0x4,%esp
  800f76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f79:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7c:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  800f81:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f87:	7f 2e                	jg     800fb7 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f89:	83 ec 04             	sub    $0x4,%esp
  800f8c:	53                   	push   %ebx
  800f8d:	ff 75 0c             	push   0xc(%ebp)
  800f90:	68 0c 70 80 00       	push   $0x80700c
  800f95:	e8 66 0d 00 00       	call   801d00 <memmove>
	nsipcbuf.send.req_size = size;
  800f9a:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  800fa0:	8b 45 14             	mov    0x14(%ebp),%eax
  800fa3:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  800fa8:	b8 08 00 00 00       	mov    $0x8,%eax
  800fad:	e8 e8 fd ff ff       	call   800d9a <nsipc>
}
  800fb2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb5:	c9                   	leave  
  800fb6:	c3                   	ret    
	assert(size < 1600);
  800fb7:	68 68 23 80 00       	push   $0x802368
  800fbc:	68 0f 23 80 00       	push   $0x80230f
  800fc1:	6a 6d                	push   $0x6d
  800fc3:	68 5c 23 80 00       	push   $0x80235c
  800fc8:	e8 e8 04 00 00       	call   8014b5 <_panic>

00800fcd <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd6:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  800fdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fde:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  800fe3:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe6:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  800feb:	b8 09 00 00 00       	mov    $0x9,%eax
  800ff0:	e8 a5 fd ff ff       	call   800d9a <nsipc>
}
  800ff5:	c9                   	leave  
  800ff6:	c3                   	ret    

00800ff7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	56                   	push   %esi
  800ffb:	53                   	push   %ebx
  800ffc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800fff:	83 ec 0c             	sub    $0xc,%esp
  801002:	ff 75 08             	push   0x8(%ebp)
  801005:	e8 ad f3 ff ff       	call   8003b7 <fd2data>
  80100a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80100c:	83 c4 08             	add    $0x8,%esp
  80100f:	68 74 23 80 00       	push   $0x802374
  801014:	53                   	push   %ebx
  801015:	e8 50 0b 00 00       	call   801b6a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80101a:	8b 46 04             	mov    0x4(%esi),%eax
  80101d:	2b 06                	sub    (%esi),%eax
  80101f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801025:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80102c:	00 00 00 
	stat->st_dev = &devpipe;
  80102f:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801036:	30 80 00 
	return 0;
}
  801039:	b8 00 00 00 00       	mov    $0x0,%eax
  80103e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801041:	5b                   	pop    %ebx
  801042:	5e                   	pop    %esi
  801043:	5d                   	pop    %ebp
  801044:	c3                   	ret    

00801045 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	53                   	push   %ebx
  801049:	83 ec 0c             	sub    $0xc,%esp
  80104c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80104f:	53                   	push   %ebx
  801050:	6a 00                	push   $0x0
  801052:	e8 83 f1 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801057:	89 1c 24             	mov    %ebx,(%esp)
  80105a:	e8 58 f3 ff ff       	call   8003b7 <fd2data>
  80105f:	83 c4 08             	add    $0x8,%esp
  801062:	50                   	push   %eax
  801063:	6a 00                	push   $0x0
  801065:	e8 70 f1 ff ff       	call   8001da <sys_page_unmap>
}
  80106a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106d:	c9                   	leave  
  80106e:	c3                   	ret    

0080106f <_pipeisclosed>:
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	57                   	push   %edi
  801073:	56                   	push   %esi
  801074:	53                   	push   %ebx
  801075:	83 ec 1c             	sub    $0x1c,%esp
  801078:	89 c7                	mov    %eax,%edi
  80107a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80107c:	a1 00 40 80 00       	mov    0x804000,%eax
  801081:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801084:	83 ec 0c             	sub    $0xc,%esp
  801087:	57                   	push   %edi
  801088:	e8 20 0f 00 00       	call   801fad <pageref>
  80108d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801090:	89 34 24             	mov    %esi,(%esp)
  801093:	e8 15 0f 00 00       	call   801fad <pageref>
		nn = thisenv->env_runs;
  801098:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80109e:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	39 cb                	cmp    %ecx,%ebx
  8010a6:	74 1b                	je     8010c3 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010a8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010ab:	75 cf                	jne    80107c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010ad:	8b 42 68             	mov    0x68(%edx),%eax
  8010b0:	6a 01                	push   $0x1
  8010b2:	50                   	push   %eax
  8010b3:	53                   	push   %ebx
  8010b4:	68 7b 23 80 00       	push   $0x80237b
  8010b9:	e8 d2 04 00 00       	call   801590 <cprintf>
  8010be:	83 c4 10             	add    $0x10,%esp
  8010c1:	eb b9                	jmp    80107c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010c3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010c6:	0f 94 c0             	sete   %al
  8010c9:	0f b6 c0             	movzbl %al,%eax
}
  8010cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cf:	5b                   	pop    %ebx
  8010d0:	5e                   	pop    %esi
  8010d1:	5f                   	pop    %edi
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <devpipe_write>:
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	57                   	push   %edi
  8010d8:	56                   	push   %esi
  8010d9:	53                   	push   %ebx
  8010da:	83 ec 28             	sub    $0x28,%esp
  8010dd:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8010e0:	56                   	push   %esi
  8010e1:	e8 d1 f2 ff ff       	call   8003b7 <fd2data>
  8010e6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8010e8:	83 c4 10             	add    $0x10,%esp
  8010eb:	bf 00 00 00 00       	mov    $0x0,%edi
  8010f0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8010f3:	75 09                	jne    8010fe <devpipe_write+0x2a>
	return i;
  8010f5:	89 f8                	mov    %edi,%eax
  8010f7:	eb 23                	jmp    80111c <devpipe_write+0x48>
			sys_yield();
  8010f9:	e8 38 f0 ff ff       	call   800136 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8010fe:	8b 43 04             	mov    0x4(%ebx),%eax
  801101:	8b 0b                	mov    (%ebx),%ecx
  801103:	8d 51 20             	lea    0x20(%ecx),%edx
  801106:	39 d0                	cmp    %edx,%eax
  801108:	72 1a                	jb     801124 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80110a:	89 da                	mov    %ebx,%edx
  80110c:	89 f0                	mov    %esi,%eax
  80110e:	e8 5c ff ff ff       	call   80106f <_pipeisclosed>
  801113:	85 c0                	test   %eax,%eax
  801115:	74 e2                	je     8010f9 <devpipe_write+0x25>
				return 0;
  801117:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80111c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111f:	5b                   	pop    %ebx
  801120:	5e                   	pop    %esi
  801121:	5f                   	pop    %edi
  801122:	5d                   	pop    %ebp
  801123:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801124:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801127:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80112b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80112e:	89 c2                	mov    %eax,%edx
  801130:	c1 fa 1f             	sar    $0x1f,%edx
  801133:	89 d1                	mov    %edx,%ecx
  801135:	c1 e9 1b             	shr    $0x1b,%ecx
  801138:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80113b:	83 e2 1f             	and    $0x1f,%edx
  80113e:	29 ca                	sub    %ecx,%edx
  801140:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801144:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801148:	83 c0 01             	add    $0x1,%eax
  80114b:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80114e:	83 c7 01             	add    $0x1,%edi
  801151:	eb 9d                	jmp    8010f0 <devpipe_write+0x1c>

00801153 <devpipe_read>:
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	57                   	push   %edi
  801157:	56                   	push   %esi
  801158:	53                   	push   %ebx
  801159:	83 ec 18             	sub    $0x18,%esp
  80115c:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80115f:	57                   	push   %edi
  801160:	e8 52 f2 ff ff       	call   8003b7 <fd2data>
  801165:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	be 00 00 00 00       	mov    $0x0,%esi
  80116f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801172:	75 13                	jne    801187 <devpipe_read+0x34>
	return i;
  801174:	89 f0                	mov    %esi,%eax
  801176:	eb 02                	jmp    80117a <devpipe_read+0x27>
				return i;
  801178:	89 f0                	mov    %esi,%eax
}
  80117a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117d:	5b                   	pop    %ebx
  80117e:	5e                   	pop    %esi
  80117f:	5f                   	pop    %edi
  801180:	5d                   	pop    %ebp
  801181:	c3                   	ret    
			sys_yield();
  801182:	e8 af ef ff ff       	call   800136 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801187:	8b 03                	mov    (%ebx),%eax
  801189:	3b 43 04             	cmp    0x4(%ebx),%eax
  80118c:	75 18                	jne    8011a6 <devpipe_read+0x53>
			if (i > 0)
  80118e:	85 f6                	test   %esi,%esi
  801190:	75 e6                	jne    801178 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801192:	89 da                	mov    %ebx,%edx
  801194:	89 f8                	mov    %edi,%eax
  801196:	e8 d4 fe ff ff       	call   80106f <_pipeisclosed>
  80119b:	85 c0                	test   %eax,%eax
  80119d:	74 e3                	je     801182 <devpipe_read+0x2f>
				return 0;
  80119f:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a4:	eb d4                	jmp    80117a <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011a6:	99                   	cltd   
  8011a7:	c1 ea 1b             	shr    $0x1b,%edx
  8011aa:	01 d0                	add    %edx,%eax
  8011ac:	83 e0 1f             	and    $0x1f,%eax
  8011af:	29 d0                	sub    %edx,%eax
  8011b1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011bc:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011bf:	83 c6 01             	add    $0x1,%esi
  8011c2:	eb ab                	jmp    80116f <devpipe_read+0x1c>

008011c4 <pipe>:
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	56                   	push   %esi
  8011c8:	53                   	push   %ebx
  8011c9:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cf:	50                   	push   %eax
  8011d0:	e8 f9 f1 ff ff       	call   8003ce <fd_alloc>
  8011d5:	89 c3                	mov    %eax,%ebx
  8011d7:	83 c4 10             	add    $0x10,%esp
  8011da:	85 c0                	test   %eax,%eax
  8011dc:	0f 88 23 01 00 00    	js     801305 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011e2:	83 ec 04             	sub    $0x4,%esp
  8011e5:	68 07 04 00 00       	push   $0x407
  8011ea:	ff 75 f4             	push   -0xc(%ebp)
  8011ed:	6a 00                	push   $0x0
  8011ef:	e8 61 ef ff ff       	call   800155 <sys_page_alloc>
  8011f4:	89 c3                	mov    %eax,%ebx
  8011f6:	83 c4 10             	add    $0x10,%esp
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	0f 88 04 01 00 00    	js     801305 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801201:	83 ec 0c             	sub    $0xc,%esp
  801204:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801207:	50                   	push   %eax
  801208:	e8 c1 f1 ff ff       	call   8003ce <fd_alloc>
  80120d:	89 c3                	mov    %eax,%ebx
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	85 c0                	test   %eax,%eax
  801214:	0f 88 db 00 00 00    	js     8012f5 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80121a:	83 ec 04             	sub    $0x4,%esp
  80121d:	68 07 04 00 00       	push   $0x407
  801222:	ff 75 f0             	push   -0x10(%ebp)
  801225:	6a 00                	push   $0x0
  801227:	e8 29 ef ff ff       	call   800155 <sys_page_alloc>
  80122c:	89 c3                	mov    %eax,%ebx
  80122e:	83 c4 10             	add    $0x10,%esp
  801231:	85 c0                	test   %eax,%eax
  801233:	0f 88 bc 00 00 00    	js     8012f5 <pipe+0x131>
	va = fd2data(fd0);
  801239:	83 ec 0c             	sub    $0xc,%esp
  80123c:	ff 75 f4             	push   -0xc(%ebp)
  80123f:	e8 73 f1 ff ff       	call   8003b7 <fd2data>
  801244:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801246:	83 c4 0c             	add    $0xc,%esp
  801249:	68 07 04 00 00       	push   $0x407
  80124e:	50                   	push   %eax
  80124f:	6a 00                	push   $0x0
  801251:	e8 ff ee ff ff       	call   800155 <sys_page_alloc>
  801256:	89 c3                	mov    %eax,%ebx
  801258:	83 c4 10             	add    $0x10,%esp
  80125b:	85 c0                	test   %eax,%eax
  80125d:	0f 88 82 00 00 00    	js     8012e5 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801263:	83 ec 0c             	sub    $0xc,%esp
  801266:	ff 75 f0             	push   -0x10(%ebp)
  801269:	e8 49 f1 ff ff       	call   8003b7 <fd2data>
  80126e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801275:	50                   	push   %eax
  801276:	6a 00                	push   $0x0
  801278:	56                   	push   %esi
  801279:	6a 00                	push   $0x0
  80127b:	e8 18 ef ff ff       	call   800198 <sys_page_map>
  801280:	89 c3                	mov    %eax,%ebx
  801282:	83 c4 20             	add    $0x20,%esp
  801285:	85 c0                	test   %eax,%eax
  801287:	78 4e                	js     8012d7 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801289:	a1 3c 30 80 00       	mov    0x80303c,%eax
  80128e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801291:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801293:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801296:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80129d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012a0:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012ac:	83 ec 0c             	sub    $0xc,%esp
  8012af:	ff 75 f4             	push   -0xc(%ebp)
  8012b2:	e8 f0 f0 ff ff       	call   8003a7 <fd2num>
  8012b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ba:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012bc:	83 c4 04             	add    $0x4,%esp
  8012bf:	ff 75 f0             	push   -0x10(%ebp)
  8012c2:	e8 e0 f0 ff ff       	call   8003a7 <fd2num>
  8012c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ca:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012cd:	83 c4 10             	add    $0x10,%esp
  8012d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d5:	eb 2e                	jmp    801305 <pipe+0x141>
	sys_page_unmap(0, va);
  8012d7:	83 ec 08             	sub    $0x8,%esp
  8012da:	56                   	push   %esi
  8012db:	6a 00                	push   $0x0
  8012dd:	e8 f8 ee ff ff       	call   8001da <sys_page_unmap>
  8012e2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8012e5:	83 ec 08             	sub    $0x8,%esp
  8012e8:	ff 75 f0             	push   -0x10(%ebp)
  8012eb:	6a 00                	push   $0x0
  8012ed:	e8 e8 ee ff ff       	call   8001da <sys_page_unmap>
  8012f2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8012f5:	83 ec 08             	sub    $0x8,%esp
  8012f8:	ff 75 f4             	push   -0xc(%ebp)
  8012fb:	6a 00                	push   $0x0
  8012fd:	e8 d8 ee ff ff       	call   8001da <sys_page_unmap>
  801302:	83 c4 10             	add    $0x10,%esp
}
  801305:	89 d8                	mov    %ebx,%eax
  801307:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80130a:	5b                   	pop    %ebx
  80130b:	5e                   	pop    %esi
  80130c:	5d                   	pop    %ebp
  80130d:	c3                   	ret    

0080130e <pipeisclosed>:
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801314:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801317:	50                   	push   %eax
  801318:	ff 75 08             	push   0x8(%ebp)
  80131b:	e8 fe f0 ff ff       	call   80041e <fd_lookup>
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	85 c0                	test   %eax,%eax
  801325:	78 18                	js     80133f <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801327:	83 ec 0c             	sub    $0xc,%esp
  80132a:	ff 75 f4             	push   -0xc(%ebp)
  80132d:	e8 85 f0 ff ff       	call   8003b7 <fd2data>
  801332:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801334:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801337:	e8 33 fd ff ff       	call   80106f <_pipeisclosed>
  80133c:	83 c4 10             	add    $0x10,%esp
}
  80133f:	c9                   	leave  
  801340:	c3                   	ret    

00801341 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801341:	b8 00 00 00 00       	mov    $0x0,%eax
  801346:	c3                   	ret    

00801347 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80134d:	68 93 23 80 00       	push   $0x802393
  801352:	ff 75 0c             	push   0xc(%ebp)
  801355:	e8 10 08 00 00       	call   801b6a <strcpy>
	return 0;
}
  80135a:	b8 00 00 00 00       	mov    $0x0,%eax
  80135f:	c9                   	leave  
  801360:	c3                   	ret    

00801361 <devcons_write>:
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	57                   	push   %edi
  801365:	56                   	push   %esi
  801366:	53                   	push   %ebx
  801367:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80136d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801372:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801378:	eb 2e                	jmp    8013a8 <devcons_write+0x47>
		m = n - tot;
  80137a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80137d:	29 f3                	sub    %esi,%ebx
  80137f:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801384:	39 c3                	cmp    %eax,%ebx
  801386:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801389:	83 ec 04             	sub    $0x4,%esp
  80138c:	53                   	push   %ebx
  80138d:	89 f0                	mov    %esi,%eax
  80138f:	03 45 0c             	add    0xc(%ebp),%eax
  801392:	50                   	push   %eax
  801393:	57                   	push   %edi
  801394:	e8 67 09 00 00       	call   801d00 <memmove>
		sys_cputs(buf, m);
  801399:	83 c4 08             	add    $0x8,%esp
  80139c:	53                   	push   %ebx
  80139d:	57                   	push   %edi
  80139e:	e8 f6 ec ff ff       	call   800099 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013a3:	01 de                	add    %ebx,%esi
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013ab:	72 cd                	jb     80137a <devcons_write+0x19>
}
  8013ad:	89 f0                	mov    %esi,%eax
  8013af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b2:	5b                   	pop    %ebx
  8013b3:	5e                   	pop    %esi
  8013b4:	5f                   	pop    %edi
  8013b5:	5d                   	pop    %ebp
  8013b6:	c3                   	ret    

008013b7 <devcons_read>:
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	83 ec 08             	sub    $0x8,%esp
  8013bd:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013c6:	75 07                	jne    8013cf <devcons_read+0x18>
  8013c8:	eb 1f                	jmp    8013e9 <devcons_read+0x32>
		sys_yield();
  8013ca:	e8 67 ed ff ff       	call   800136 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8013cf:	e8 e3 ec ff ff       	call   8000b7 <sys_cgetc>
  8013d4:	85 c0                	test   %eax,%eax
  8013d6:	74 f2                	je     8013ca <devcons_read+0x13>
	if (c < 0)
  8013d8:	78 0f                	js     8013e9 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8013da:	83 f8 04             	cmp    $0x4,%eax
  8013dd:	74 0c                	je     8013eb <devcons_read+0x34>
	*(char*)vbuf = c;
  8013df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013e2:	88 02                	mov    %al,(%edx)
	return 1;
  8013e4:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8013e9:	c9                   	leave  
  8013ea:	c3                   	ret    
		return 0;
  8013eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f0:	eb f7                	jmp    8013e9 <devcons_read+0x32>

008013f2 <cputchar>:
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fb:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8013fe:	6a 01                	push   $0x1
  801400:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801403:	50                   	push   %eax
  801404:	e8 90 ec ff ff       	call   800099 <sys_cputs>
}
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	c9                   	leave  
  80140d:	c3                   	ret    

0080140e <getchar>:
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
  801411:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801414:	6a 01                	push   $0x1
  801416:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801419:	50                   	push   %eax
  80141a:	6a 00                	push   $0x0
  80141c:	e8 66 f2 ff ff       	call   800687 <read>
	if (r < 0)
  801421:	83 c4 10             	add    $0x10,%esp
  801424:	85 c0                	test   %eax,%eax
  801426:	78 06                	js     80142e <getchar+0x20>
	if (r < 1)
  801428:	74 06                	je     801430 <getchar+0x22>
	return c;
  80142a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80142e:	c9                   	leave  
  80142f:	c3                   	ret    
		return -E_EOF;
  801430:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801435:	eb f7                	jmp    80142e <getchar+0x20>

00801437 <iscons>:
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80143d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801440:	50                   	push   %eax
  801441:	ff 75 08             	push   0x8(%ebp)
  801444:	e8 d5 ef ff ff       	call   80041e <fd_lookup>
  801449:	83 c4 10             	add    $0x10,%esp
  80144c:	85 c0                	test   %eax,%eax
  80144e:	78 11                	js     801461 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801450:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801453:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801459:	39 10                	cmp    %edx,(%eax)
  80145b:	0f 94 c0             	sete   %al
  80145e:	0f b6 c0             	movzbl %al,%eax
}
  801461:	c9                   	leave  
  801462:	c3                   	ret    

00801463 <opencons>:
{
  801463:	55                   	push   %ebp
  801464:	89 e5                	mov    %esp,%ebp
  801466:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801469:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146c:	50                   	push   %eax
  80146d:	e8 5c ef ff ff       	call   8003ce <fd_alloc>
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	85 c0                	test   %eax,%eax
  801477:	78 3a                	js     8014b3 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801479:	83 ec 04             	sub    $0x4,%esp
  80147c:	68 07 04 00 00       	push   $0x407
  801481:	ff 75 f4             	push   -0xc(%ebp)
  801484:	6a 00                	push   $0x0
  801486:	e8 ca ec ff ff       	call   800155 <sys_page_alloc>
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	85 c0                	test   %eax,%eax
  801490:	78 21                	js     8014b3 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801492:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801495:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80149b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80149d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014a7:	83 ec 0c             	sub    $0xc,%esp
  8014aa:	50                   	push   %eax
  8014ab:	e8 f7 ee ff ff       	call   8003a7 <fd2num>
  8014b0:	83 c4 10             	add    $0x10,%esp
}
  8014b3:	c9                   	leave  
  8014b4:	c3                   	ret    

008014b5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	56                   	push   %esi
  8014b9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014ba:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014bd:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014c3:	e8 4f ec ff ff       	call   800117 <sys_getenvid>
  8014c8:	83 ec 0c             	sub    $0xc,%esp
  8014cb:	ff 75 0c             	push   0xc(%ebp)
  8014ce:	ff 75 08             	push   0x8(%ebp)
  8014d1:	56                   	push   %esi
  8014d2:	50                   	push   %eax
  8014d3:	68 a0 23 80 00       	push   $0x8023a0
  8014d8:	e8 b3 00 00 00       	call   801590 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014dd:	83 c4 18             	add    $0x18,%esp
  8014e0:	53                   	push   %ebx
  8014e1:	ff 75 10             	push   0x10(%ebp)
  8014e4:	e8 56 00 00 00       	call   80153f <vcprintf>
	cprintf("\n");
  8014e9:	c7 04 24 8c 23 80 00 	movl   $0x80238c,(%esp)
  8014f0:	e8 9b 00 00 00       	call   801590 <cprintf>
  8014f5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014f8:	cc                   	int3   
  8014f9:	eb fd                	jmp    8014f8 <_panic+0x43>

008014fb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	53                   	push   %ebx
  8014ff:	83 ec 04             	sub    $0x4,%esp
  801502:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801505:	8b 13                	mov    (%ebx),%edx
  801507:	8d 42 01             	lea    0x1(%edx),%eax
  80150a:	89 03                	mov    %eax,(%ebx)
  80150c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80150f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801513:	3d ff 00 00 00       	cmp    $0xff,%eax
  801518:	74 09                	je     801523 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80151a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80151e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801521:	c9                   	leave  
  801522:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801523:	83 ec 08             	sub    $0x8,%esp
  801526:	68 ff 00 00 00       	push   $0xff
  80152b:	8d 43 08             	lea    0x8(%ebx),%eax
  80152e:	50                   	push   %eax
  80152f:	e8 65 eb ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  801534:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80153a:	83 c4 10             	add    $0x10,%esp
  80153d:	eb db                	jmp    80151a <putch+0x1f>

0080153f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801548:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80154f:	00 00 00 
	b.cnt = 0;
  801552:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801559:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80155c:	ff 75 0c             	push   0xc(%ebp)
  80155f:	ff 75 08             	push   0x8(%ebp)
  801562:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801568:	50                   	push   %eax
  801569:	68 fb 14 80 00       	push   $0x8014fb
  80156e:	e8 14 01 00 00       	call   801687 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801573:	83 c4 08             	add    $0x8,%esp
  801576:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80157c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801582:	50                   	push   %eax
  801583:	e8 11 eb ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  801588:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80158e:	c9                   	leave  
  80158f:	c3                   	ret    

00801590 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801596:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801599:	50                   	push   %eax
  80159a:	ff 75 08             	push   0x8(%ebp)
  80159d:	e8 9d ff ff ff       	call   80153f <vcprintf>
	va_end(ap);

	return cnt;
}
  8015a2:	c9                   	leave  
  8015a3:	c3                   	ret    

008015a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	57                   	push   %edi
  8015a8:	56                   	push   %esi
  8015a9:	53                   	push   %ebx
  8015aa:	83 ec 1c             	sub    $0x1c,%esp
  8015ad:	89 c7                	mov    %eax,%edi
  8015af:	89 d6                	mov    %edx,%esi
  8015b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b7:	89 d1                	mov    %edx,%ecx
  8015b9:	89 c2                	mov    %eax,%edx
  8015bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015be:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8015c4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8015d1:	39 c2                	cmp    %eax,%edx
  8015d3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8015d6:	72 3e                	jb     801616 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015d8:	83 ec 0c             	sub    $0xc,%esp
  8015db:	ff 75 18             	push   0x18(%ebp)
  8015de:	83 eb 01             	sub    $0x1,%ebx
  8015e1:	53                   	push   %ebx
  8015e2:	50                   	push   %eax
  8015e3:	83 ec 08             	sub    $0x8,%esp
  8015e6:	ff 75 e4             	push   -0x1c(%ebp)
  8015e9:	ff 75 e0             	push   -0x20(%ebp)
  8015ec:	ff 75 dc             	push   -0x24(%ebp)
  8015ef:	ff 75 d8             	push   -0x28(%ebp)
  8015f2:	e8 f9 09 00 00       	call   801ff0 <__udivdi3>
  8015f7:	83 c4 18             	add    $0x18,%esp
  8015fa:	52                   	push   %edx
  8015fb:	50                   	push   %eax
  8015fc:	89 f2                	mov    %esi,%edx
  8015fe:	89 f8                	mov    %edi,%eax
  801600:	e8 9f ff ff ff       	call   8015a4 <printnum>
  801605:	83 c4 20             	add    $0x20,%esp
  801608:	eb 13                	jmp    80161d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80160a:	83 ec 08             	sub    $0x8,%esp
  80160d:	56                   	push   %esi
  80160e:	ff 75 18             	push   0x18(%ebp)
  801611:	ff d7                	call   *%edi
  801613:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801616:	83 eb 01             	sub    $0x1,%ebx
  801619:	85 db                	test   %ebx,%ebx
  80161b:	7f ed                	jg     80160a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80161d:	83 ec 08             	sub    $0x8,%esp
  801620:	56                   	push   %esi
  801621:	83 ec 04             	sub    $0x4,%esp
  801624:	ff 75 e4             	push   -0x1c(%ebp)
  801627:	ff 75 e0             	push   -0x20(%ebp)
  80162a:	ff 75 dc             	push   -0x24(%ebp)
  80162d:	ff 75 d8             	push   -0x28(%ebp)
  801630:	e8 db 0a 00 00       	call   802110 <__umoddi3>
  801635:	83 c4 14             	add    $0x14,%esp
  801638:	0f be 80 c3 23 80 00 	movsbl 0x8023c3(%eax),%eax
  80163f:	50                   	push   %eax
  801640:	ff d7                	call   *%edi
}
  801642:	83 c4 10             	add    $0x10,%esp
  801645:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801648:	5b                   	pop    %ebx
  801649:	5e                   	pop    %esi
  80164a:	5f                   	pop    %edi
  80164b:	5d                   	pop    %ebp
  80164c:	c3                   	ret    

0080164d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801653:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801657:	8b 10                	mov    (%eax),%edx
  801659:	3b 50 04             	cmp    0x4(%eax),%edx
  80165c:	73 0a                	jae    801668 <sprintputch+0x1b>
		*b->buf++ = ch;
  80165e:	8d 4a 01             	lea    0x1(%edx),%ecx
  801661:	89 08                	mov    %ecx,(%eax)
  801663:	8b 45 08             	mov    0x8(%ebp),%eax
  801666:	88 02                	mov    %al,(%edx)
}
  801668:	5d                   	pop    %ebp
  801669:	c3                   	ret    

0080166a <printfmt>:
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801670:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801673:	50                   	push   %eax
  801674:	ff 75 10             	push   0x10(%ebp)
  801677:	ff 75 0c             	push   0xc(%ebp)
  80167a:	ff 75 08             	push   0x8(%ebp)
  80167d:	e8 05 00 00 00       	call   801687 <vprintfmt>
}
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	c9                   	leave  
  801686:	c3                   	ret    

00801687 <vprintfmt>:
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	57                   	push   %edi
  80168b:	56                   	push   %esi
  80168c:	53                   	push   %ebx
  80168d:	83 ec 3c             	sub    $0x3c,%esp
  801690:	8b 75 08             	mov    0x8(%ebp),%esi
  801693:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801696:	8b 7d 10             	mov    0x10(%ebp),%edi
  801699:	eb 0a                	jmp    8016a5 <vprintfmt+0x1e>
			putch(ch, putdat);
  80169b:	83 ec 08             	sub    $0x8,%esp
  80169e:	53                   	push   %ebx
  80169f:	50                   	push   %eax
  8016a0:	ff d6                	call   *%esi
  8016a2:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016a5:	83 c7 01             	add    $0x1,%edi
  8016a8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016ac:	83 f8 25             	cmp    $0x25,%eax
  8016af:	74 0c                	je     8016bd <vprintfmt+0x36>
			if (ch == '\0')
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	75 e6                	jne    80169b <vprintfmt+0x14>
}
  8016b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b8:	5b                   	pop    %ebx
  8016b9:	5e                   	pop    %esi
  8016ba:	5f                   	pop    %edi
  8016bb:	5d                   	pop    %ebp
  8016bc:	c3                   	ret    
		padc = ' ';
  8016bd:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8016c1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8016c8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8016cf:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8016d6:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8016db:	8d 47 01             	lea    0x1(%edi),%eax
  8016de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016e1:	0f b6 17             	movzbl (%edi),%edx
  8016e4:	8d 42 dd             	lea    -0x23(%edx),%eax
  8016e7:	3c 55                	cmp    $0x55,%al
  8016e9:	0f 87 bb 03 00 00    	ja     801aaa <vprintfmt+0x423>
  8016ef:	0f b6 c0             	movzbl %al,%eax
  8016f2:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
  8016f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8016fc:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801700:	eb d9                	jmp    8016db <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801702:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801705:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801709:	eb d0                	jmp    8016db <vprintfmt+0x54>
  80170b:	0f b6 d2             	movzbl %dl,%edx
  80170e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801711:	b8 00 00 00 00       	mov    $0x0,%eax
  801716:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801719:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80171c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801720:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801723:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801726:	83 f9 09             	cmp    $0x9,%ecx
  801729:	77 55                	ja     801780 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80172b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80172e:	eb e9                	jmp    801719 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801730:	8b 45 14             	mov    0x14(%ebp),%eax
  801733:	8b 00                	mov    (%eax),%eax
  801735:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801738:	8b 45 14             	mov    0x14(%ebp),%eax
  80173b:	8d 40 04             	lea    0x4(%eax),%eax
  80173e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801741:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801744:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801748:	79 91                	jns    8016db <vprintfmt+0x54>
				width = precision, precision = -1;
  80174a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80174d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801750:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801757:	eb 82                	jmp    8016db <vprintfmt+0x54>
  801759:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80175c:	85 d2                	test   %edx,%edx
  80175e:	b8 00 00 00 00       	mov    $0x0,%eax
  801763:	0f 49 c2             	cmovns %edx,%eax
  801766:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801769:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80176c:	e9 6a ff ff ff       	jmp    8016db <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801771:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801774:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80177b:	e9 5b ff ff ff       	jmp    8016db <vprintfmt+0x54>
  801780:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801783:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801786:	eb bc                	jmp    801744 <vprintfmt+0xbd>
			lflag++;
  801788:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80178b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80178e:	e9 48 ff ff ff       	jmp    8016db <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  801793:	8b 45 14             	mov    0x14(%ebp),%eax
  801796:	8d 78 04             	lea    0x4(%eax),%edi
  801799:	83 ec 08             	sub    $0x8,%esp
  80179c:	53                   	push   %ebx
  80179d:	ff 30                	push   (%eax)
  80179f:	ff d6                	call   *%esi
			break;
  8017a1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017a4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017a7:	e9 9d 02 00 00       	jmp    801a49 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8017ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8017af:	8d 78 04             	lea    0x4(%eax),%edi
  8017b2:	8b 10                	mov    (%eax),%edx
  8017b4:	89 d0                	mov    %edx,%eax
  8017b6:	f7 d8                	neg    %eax
  8017b8:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017bb:	83 f8 0f             	cmp    $0xf,%eax
  8017be:	7f 23                	jg     8017e3 <vprintfmt+0x15c>
  8017c0:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  8017c7:	85 d2                	test   %edx,%edx
  8017c9:	74 18                	je     8017e3 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8017cb:	52                   	push   %edx
  8017cc:	68 21 23 80 00       	push   $0x802321
  8017d1:	53                   	push   %ebx
  8017d2:	56                   	push   %esi
  8017d3:	e8 92 fe ff ff       	call   80166a <printfmt>
  8017d8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017db:	89 7d 14             	mov    %edi,0x14(%ebp)
  8017de:	e9 66 02 00 00       	jmp    801a49 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8017e3:	50                   	push   %eax
  8017e4:	68 db 23 80 00       	push   $0x8023db
  8017e9:	53                   	push   %ebx
  8017ea:	56                   	push   %esi
  8017eb:	e8 7a fe ff ff       	call   80166a <printfmt>
  8017f0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017f3:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8017f6:	e9 4e 02 00 00       	jmp    801a49 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8017fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8017fe:	83 c0 04             	add    $0x4,%eax
  801801:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801804:	8b 45 14             	mov    0x14(%ebp),%eax
  801807:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801809:	85 d2                	test   %edx,%edx
  80180b:	b8 d4 23 80 00       	mov    $0x8023d4,%eax
  801810:	0f 45 c2             	cmovne %edx,%eax
  801813:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801816:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80181a:	7e 06                	jle    801822 <vprintfmt+0x19b>
  80181c:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801820:	75 0d                	jne    80182f <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801822:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801825:	89 c7                	mov    %eax,%edi
  801827:	03 45 e0             	add    -0x20(%ebp),%eax
  80182a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80182d:	eb 55                	jmp    801884 <vprintfmt+0x1fd>
  80182f:	83 ec 08             	sub    $0x8,%esp
  801832:	ff 75 d8             	push   -0x28(%ebp)
  801835:	ff 75 cc             	push   -0x34(%ebp)
  801838:	e8 0a 03 00 00       	call   801b47 <strnlen>
  80183d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801840:	29 c1                	sub    %eax,%ecx
  801842:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801845:	83 c4 10             	add    $0x10,%esp
  801848:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80184a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80184e:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801851:	eb 0f                	jmp    801862 <vprintfmt+0x1db>
					putch(padc, putdat);
  801853:	83 ec 08             	sub    $0x8,%esp
  801856:	53                   	push   %ebx
  801857:	ff 75 e0             	push   -0x20(%ebp)
  80185a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80185c:	83 ef 01             	sub    $0x1,%edi
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	85 ff                	test   %edi,%edi
  801864:	7f ed                	jg     801853 <vprintfmt+0x1cc>
  801866:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801869:	85 d2                	test   %edx,%edx
  80186b:	b8 00 00 00 00       	mov    $0x0,%eax
  801870:	0f 49 c2             	cmovns %edx,%eax
  801873:	29 c2                	sub    %eax,%edx
  801875:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801878:	eb a8                	jmp    801822 <vprintfmt+0x19b>
					putch(ch, putdat);
  80187a:	83 ec 08             	sub    $0x8,%esp
  80187d:	53                   	push   %ebx
  80187e:	52                   	push   %edx
  80187f:	ff d6                	call   *%esi
  801881:	83 c4 10             	add    $0x10,%esp
  801884:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801887:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801889:	83 c7 01             	add    $0x1,%edi
  80188c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801890:	0f be d0             	movsbl %al,%edx
  801893:	85 d2                	test   %edx,%edx
  801895:	74 4b                	je     8018e2 <vprintfmt+0x25b>
  801897:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80189b:	78 06                	js     8018a3 <vprintfmt+0x21c>
  80189d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018a1:	78 1e                	js     8018c1 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8018a3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018a7:	74 d1                	je     80187a <vprintfmt+0x1f3>
  8018a9:	0f be c0             	movsbl %al,%eax
  8018ac:	83 e8 20             	sub    $0x20,%eax
  8018af:	83 f8 5e             	cmp    $0x5e,%eax
  8018b2:	76 c6                	jbe    80187a <vprintfmt+0x1f3>
					putch('?', putdat);
  8018b4:	83 ec 08             	sub    $0x8,%esp
  8018b7:	53                   	push   %ebx
  8018b8:	6a 3f                	push   $0x3f
  8018ba:	ff d6                	call   *%esi
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	eb c3                	jmp    801884 <vprintfmt+0x1fd>
  8018c1:	89 cf                	mov    %ecx,%edi
  8018c3:	eb 0e                	jmp    8018d3 <vprintfmt+0x24c>
				putch(' ', putdat);
  8018c5:	83 ec 08             	sub    $0x8,%esp
  8018c8:	53                   	push   %ebx
  8018c9:	6a 20                	push   $0x20
  8018cb:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8018cd:	83 ef 01             	sub    $0x1,%edi
  8018d0:	83 c4 10             	add    $0x10,%esp
  8018d3:	85 ff                	test   %edi,%edi
  8018d5:	7f ee                	jg     8018c5 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8018d7:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8018da:	89 45 14             	mov    %eax,0x14(%ebp)
  8018dd:	e9 67 01 00 00       	jmp    801a49 <vprintfmt+0x3c2>
  8018e2:	89 cf                	mov    %ecx,%edi
  8018e4:	eb ed                	jmp    8018d3 <vprintfmt+0x24c>
	if (lflag >= 2)
  8018e6:	83 f9 01             	cmp    $0x1,%ecx
  8018e9:	7f 1b                	jg     801906 <vprintfmt+0x27f>
	else if (lflag)
  8018eb:	85 c9                	test   %ecx,%ecx
  8018ed:	74 63                	je     801952 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8018ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f2:	8b 00                	mov    (%eax),%eax
  8018f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018f7:	99                   	cltd   
  8018f8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8018fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8018fe:	8d 40 04             	lea    0x4(%eax),%eax
  801901:	89 45 14             	mov    %eax,0x14(%ebp)
  801904:	eb 17                	jmp    80191d <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801906:	8b 45 14             	mov    0x14(%ebp),%eax
  801909:	8b 50 04             	mov    0x4(%eax),%edx
  80190c:	8b 00                	mov    (%eax),%eax
  80190e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801911:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801914:	8b 45 14             	mov    0x14(%ebp),%eax
  801917:	8d 40 08             	lea    0x8(%eax),%eax
  80191a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80191d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801920:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801923:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801928:	85 c9                	test   %ecx,%ecx
  80192a:	0f 89 ff 00 00 00    	jns    801a2f <vprintfmt+0x3a8>
				putch('-', putdat);
  801930:	83 ec 08             	sub    $0x8,%esp
  801933:	53                   	push   %ebx
  801934:	6a 2d                	push   $0x2d
  801936:	ff d6                	call   *%esi
				num = -(long long) num;
  801938:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80193b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80193e:	f7 da                	neg    %edx
  801940:	83 d1 00             	adc    $0x0,%ecx
  801943:	f7 d9                	neg    %ecx
  801945:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801948:	bf 0a 00 00 00       	mov    $0xa,%edi
  80194d:	e9 dd 00 00 00       	jmp    801a2f <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801952:	8b 45 14             	mov    0x14(%ebp),%eax
  801955:	8b 00                	mov    (%eax),%eax
  801957:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80195a:	99                   	cltd   
  80195b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80195e:	8b 45 14             	mov    0x14(%ebp),%eax
  801961:	8d 40 04             	lea    0x4(%eax),%eax
  801964:	89 45 14             	mov    %eax,0x14(%ebp)
  801967:	eb b4                	jmp    80191d <vprintfmt+0x296>
	if (lflag >= 2)
  801969:	83 f9 01             	cmp    $0x1,%ecx
  80196c:	7f 1e                	jg     80198c <vprintfmt+0x305>
	else if (lflag)
  80196e:	85 c9                	test   %ecx,%ecx
  801970:	74 32                	je     8019a4 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  801972:	8b 45 14             	mov    0x14(%ebp),%eax
  801975:	8b 10                	mov    (%eax),%edx
  801977:	b9 00 00 00 00       	mov    $0x0,%ecx
  80197c:	8d 40 04             	lea    0x4(%eax),%eax
  80197f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801982:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  801987:	e9 a3 00 00 00       	jmp    801a2f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80198c:	8b 45 14             	mov    0x14(%ebp),%eax
  80198f:	8b 10                	mov    (%eax),%edx
  801991:	8b 48 04             	mov    0x4(%eax),%ecx
  801994:	8d 40 08             	lea    0x8(%eax),%eax
  801997:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80199a:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80199f:	e9 8b 00 00 00       	jmp    801a2f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a7:	8b 10                	mov    (%eax),%edx
  8019a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019ae:	8d 40 04             	lea    0x4(%eax),%eax
  8019b1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019b4:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8019b9:	eb 74                	jmp    801a2f <vprintfmt+0x3a8>
	if (lflag >= 2)
  8019bb:	83 f9 01             	cmp    $0x1,%ecx
  8019be:	7f 1b                	jg     8019db <vprintfmt+0x354>
	else if (lflag)
  8019c0:	85 c9                	test   %ecx,%ecx
  8019c2:	74 2c                	je     8019f0 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8019c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c7:	8b 10                	mov    (%eax),%edx
  8019c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019ce:	8d 40 04             	lea    0x4(%eax),%eax
  8019d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019d4:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8019d9:	eb 54                	jmp    801a2f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019db:	8b 45 14             	mov    0x14(%ebp),%eax
  8019de:	8b 10                	mov    (%eax),%edx
  8019e0:	8b 48 04             	mov    0x4(%eax),%ecx
  8019e3:	8d 40 08             	lea    0x8(%eax),%eax
  8019e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019e9:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8019ee:	eb 3f                	jmp    801a2f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f3:	8b 10                	mov    (%eax),%edx
  8019f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019fa:	8d 40 04             	lea    0x4(%eax),%eax
  8019fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a00:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801a05:	eb 28                	jmp    801a2f <vprintfmt+0x3a8>
			putch('0', putdat);
  801a07:	83 ec 08             	sub    $0x8,%esp
  801a0a:	53                   	push   %ebx
  801a0b:	6a 30                	push   $0x30
  801a0d:	ff d6                	call   *%esi
			putch('x', putdat);
  801a0f:	83 c4 08             	add    $0x8,%esp
  801a12:	53                   	push   %ebx
  801a13:	6a 78                	push   $0x78
  801a15:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a17:	8b 45 14             	mov    0x14(%ebp),%eax
  801a1a:	8b 10                	mov    (%eax),%edx
  801a1c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a21:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a24:	8d 40 04             	lea    0x4(%eax),%eax
  801a27:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a2a:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801a2f:	83 ec 0c             	sub    $0xc,%esp
  801a32:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801a36:	50                   	push   %eax
  801a37:	ff 75 e0             	push   -0x20(%ebp)
  801a3a:	57                   	push   %edi
  801a3b:	51                   	push   %ecx
  801a3c:	52                   	push   %edx
  801a3d:	89 da                	mov    %ebx,%edx
  801a3f:	89 f0                	mov    %esi,%eax
  801a41:	e8 5e fb ff ff       	call   8015a4 <printnum>
			break;
  801a46:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801a49:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a4c:	e9 54 fc ff ff       	jmp    8016a5 <vprintfmt+0x1e>
	if (lflag >= 2)
  801a51:	83 f9 01             	cmp    $0x1,%ecx
  801a54:	7f 1b                	jg     801a71 <vprintfmt+0x3ea>
	else if (lflag)
  801a56:	85 c9                	test   %ecx,%ecx
  801a58:	74 2c                	je     801a86 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801a5a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a5d:	8b 10                	mov    (%eax),%edx
  801a5f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a64:	8d 40 04             	lea    0x4(%eax),%eax
  801a67:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a6a:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801a6f:	eb be                	jmp    801a2f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801a71:	8b 45 14             	mov    0x14(%ebp),%eax
  801a74:	8b 10                	mov    (%eax),%edx
  801a76:	8b 48 04             	mov    0x4(%eax),%ecx
  801a79:	8d 40 08             	lea    0x8(%eax),%eax
  801a7c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a7f:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  801a84:	eb a9                	jmp    801a2f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a86:	8b 45 14             	mov    0x14(%ebp),%eax
  801a89:	8b 10                	mov    (%eax),%edx
  801a8b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a90:	8d 40 04             	lea    0x4(%eax),%eax
  801a93:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a96:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  801a9b:	eb 92                	jmp    801a2f <vprintfmt+0x3a8>
			putch(ch, putdat);
  801a9d:	83 ec 08             	sub    $0x8,%esp
  801aa0:	53                   	push   %ebx
  801aa1:	6a 25                	push   $0x25
  801aa3:	ff d6                	call   *%esi
			break;
  801aa5:	83 c4 10             	add    $0x10,%esp
  801aa8:	eb 9f                	jmp    801a49 <vprintfmt+0x3c2>
			putch('%', putdat);
  801aaa:	83 ec 08             	sub    $0x8,%esp
  801aad:	53                   	push   %ebx
  801aae:	6a 25                	push   $0x25
  801ab0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	89 f8                	mov    %edi,%eax
  801ab7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801abb:	74 05                	je     801ac2 <vprintfmt+0x43b>
  801abd:	83 e8 01             	sub    $0x1,%eax
  801ac0:	eb f5                	jmp    801ab7 <vprintfmt+0x430>
  801ac2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ac5:	eb 82                	jmp    801a49 <vprintfmt+0x3c2>

00801ac7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	83 ec 18             	sub    $0x18,%esp
  801acd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ad3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ad6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ada:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801add:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	74 26                	je     801b0e <vsnprintf+0x47>
  801ae8:	85 d2                	test   %edx,%edx
  801aea:	7e 22                	jle    801b0e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801aec:	ff 75 14             	push   0x14(%ebp)
  801aef:	ff 75 10             	push   0x10(%ebp)
  801af2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801af5:	50                   	push   %eax
  801af6:	68 4d 16 80 00       	push   $0x80164d
  801afb:	e8 87 fb ff ff       	call   801687 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b00:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b03:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b09:	83 c4 10             	add    $0x10,%esp
}
  801b0c:	c9                   	leave  
  801b0d:	c3                   	ret    
		return -E_INVAL;
  801b0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b13:	eb f7                	jmp    801b0c <vsnprintf+0x45>

00801b15 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b1b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b1e:	50                   	push   %eax
  801b1f:	ff 75 10             	push   0x10(%ebp)
  801b22:	ff 75 0c             	push   0xc(%ebp)
  801b25:	ff 75 08             	push   0x8(%ebp)
  801b28:	e8 9a ff ff ff       	call   801ac7 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    

00801b2f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b35:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3a:	eb 03                	jmp    801b3f <strlen+0x10>
		n++;
  801b3c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801b3f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b43:	75 f7                	jne    801b3c <strlen+0xd>
	return n;
}
  801b45:	5d                   	pop    %ebp
  801b46:	c3                   	ret    

00801b47 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b47:	55                   	push   %ebp
  801b48:	89 e5                	mov    %esp,%ebp
  801b4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b4d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b50:	b8 00 00 00 00       	mov    $0x0,%eax
  801b55:	eb 03                	jmp    801b5a <strnlen+0x13>
		n++;
  801b57:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b5a:	39 d0                	cmp    %edx,%eax
  801b5c:	74 08                	je     801b66 <strnlen+0x1f>
  801b5e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801b62:	75 f3                	jne    801b57 <strnlen+0x10>
  801b64:	89 c2                	mov    %eax,%edx
	return n;
}
  801b66:	89 d0                	mov    %edx,%eax
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    

00801b6a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	53                   	push   %ebx
  801b6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b74:	b8 00 00 00 00       	mov    $0x0,%eax
  801b79:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801b7d:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801b80:	83 c0 01             	add    $0x1,%eax
  801b83:	84 d2                	test   %dl,%dl
  801b85:	75 f2                	jne    801b79 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801b87:	89 c8                	mov    %ecx,%eax
  801b89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8c:	c9                   	leave  
  801b8d:	c3                   	ret    

00801b8e <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	53                   	push   %ebx
  801b92:	83 ec 10             	sub    $0x10,%esp
  801b95:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b98:	53                   	push   %ebx
  801b99:	e8 91 ff ff ff       	call   801b2f <strlen>
  801b9e:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801ba1:	ff 75 0c             	push   0xc(%ebp)
  801ba4:	01 d8                	add    %ebx,%eax
  801ba6:	50                   	push   %eax
  801ba7:	e8 be ff ff ff       	call   801b6a <strcpy>
	return dst;
}
  801bac:	89 d8                	mov    %ebx,%eax
  801bae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb1:	c9                   	leave  
  801bb2:	c3                   	ret    

00801bb3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	56                   	push   %esi
  801bb7:	53                   	push   %ebx
  801bb8:	8b 75 08             	mov    0x8(%ebp),%esi
  801bbb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bbe:	89 f3                	mov    %esi,%ebx
  801bc0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bc3:	89 f0                	mov    %esi,%eax
  801bc5:	eb 0f                	jmp    801bd6 <strncpy+0x23>
		*dst++ = *src;
  801bc7:	83 c0 01             	add    $0x1,%eax
  801bca:	0f b6 0a             	movzbl (%edx),%ecx
  801bcd:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bd0:	80 f9 01             	cmp    $0x1,%cl
  801bd3:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801bd6:	39 d8                	cmp    %ebx,%eax
  801bd8:	75 ed                	jne    801bc7 <strncpy+0x14>
	}
	return ret;
}
  801bda:	89 f0                	mov    %esi,%eax
  801bdc:	5b                   	pop    %ebx
  801bdd:	5e                   	pop    %esi
  801bde:	5d                   	pop    %ebp
  801bdf:	c3                   	ret    

00801be0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	56                   	push   %esi
  801be4:	53                   	push   %ebx
  801be5:	8b 75 08             	mov    0x8(%ebp),%esi
  801be8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801beb:	8b 55 10             	mov    0x10(%ebp),%edx
  801bee:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bf0:	85 d2                	test   %edx,%edx
  801bf2:	74 21                	je     801c15 <strlcpy+0x35>
  801bf4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bf8:	89 f2                	mov    %esi,%edx
  801bfa:	eb 09                	jmp    801c05 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bfc:	83 c1 01             	add    $0x1,%ecx
  801bff:	83 c2 01             	add    $0x1,%edx
  801c02:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801c05:	39 c2                	cmp    %eax,%edx
  801c07:	74 09                	je     801c12 <strlcpy+0x32>
  801c09:	0f b6 19             	movzbl (%ecx),%ebx
  801c0c:	84 db                	test   %bl,%bl
  801c0e:	75 ec                	jne    801bfc <strlcpy+0x1c>
  801c10:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c12:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c15:	29 f0                	sub    %esi,%eax
}
  801c17:	5b                   	pop    %ebx
  801c18:	5e                   	pop    %esi
  801c19:	5d                   	pop    %ebp
  801c1a:	c3                   	ret    

00801c1b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c1b:	55                   	push   %ebp
  801c1c:	89 e5                	mov    %esp,%ebp
  801c1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c21:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c24:	eb 06                	jmp    801c2c <strcmp+0x11>
		p++, q++;
  801c26:	83 c1 01             	add    $0x1,%ecx
  801c29:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801c2c:	0f b6 01             	movzbl (%ecx),%eax
  801c2f:	84 c0                	test   %al,%al
  801c31:	74 04                	je     801c37 <strcmp+0x1c>
  801c33:	3a 02                	cmp    (%edx),%al
  801c35:	74 ef                	je     801c26 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c37:	0f b6 c0             	movzbl %al,%eax
  801c3a:	0f b6 12             	movzbl (%edx),%edx
  801c3d:	29 d0                	sub    %edx,%eax
}
  801c3f:	5d                   	pop    %ebp
  801c40:	c3                   	ret    

00801c41 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	53                   	push   %ebx
  801c45:	8b 45 08             	mov    0x8(%ebp),%eax
  801c48:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c4b:	89 c3                	mov    %eax,%ebx
  801c4d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c50:	eb 06                	jmp    801c58 <strncmp+0x17>
		n--, p++, q++;
  801c52:	83 c0 01             	add    $0x1,%eax
  801c55:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801c58:	39 d8                	cmp    %ebx,%eax
  801c5a:	74 18                	je     801c74 <strncmp+0x33>
  801c5c:	0f b6 08             	movzbl (%eax),%ecx
  801c5f:	84 c9                	test   %cl,%cl
  801c61:	74 04                	je     801c67 <strncmp+0x26>
  801c63:	3a 0a                	cmp    (%edx),%cl
  801c65:	74 eb                	je     801c52 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c67:	0f b6 00             	movzbl (%eax),%eax
  801c6a:	0f b6 12             	movzbl (%edx),%edx
  801c6d:	29 d0                	sub    %edx,%eax
}
  801c6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c72:	c9                   	leave  
  801c73:	c3                   	ret    
		return 0;
  801c74:	b8 00 00 00 00       	mov    $0x0,%eax
  801c79:	eb f4                	jmp    801c6f <strncmp+0x2e>

00801c7b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c85:	eb 03                	jmp    801c8a <strchr+0xf>
  801c87:	83 c0 01             	add    $0x1,%eax
  801c8a:	0f b6 10             	movzbl (%eax),%edx
  801c8d:	84 d2                	test   %dl,%dl
  801c8f:	74 06                	je     801c97 <strchr+0x1c>
		if (*s == c)
  801c91:	38 ca                	cmp    %cl,%dl
  801c93:	75 f2                	jne    801c87 <strchr+0xc>
  801c95:	eb 05                	jmp    801c9c <strchr+0x21>
			return (char *) s;
	return 0;
  801c97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c9c:	5d                   	pop    %ebp
  801c9d:	c3                   	ret    

00801c9e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c9e:	55                   	push   %ebp
  801c9f:	89 e5                	mov    %esp,%ebp
  801ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ca8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cab:	38 ca                	cmp    %cl,%dl
  801cad:	74 09                	je     801cb8 <strfind+0x1a>
  801caf:	84 d2                	test   %dl,%dl
  801cb1:	74 05                	je     801cb8 <strfind+0x1a>
	for (; *s; s++)
  801cb3:	83 c0 01             	add    $0x1,%eax
  801cb6:	eb f0                	jmp    801ca8 <strfind+0xa>
			break;
	return (char *) s;
}
  801cb8:	5d                   	pop    %ebp
  801cb9:	c3                   	ret    

00801cba <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cba:	55                   	push   %ebp
  801cbb:	89 e5                	mov    %esp,%ebp
  801cbd:	57                   	push   %edi
  801cbe:	56                   	push   %esi
  801cbf:	53                   	push   %ebx
  801cc0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cc3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cc6:	85 c9                	test   %ecx,%ecx
  801cc8:	74 2f                	je     801cf9 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cca:	89 f8                	mov    %edi,%eax
  801ccc:	09 c8                	or     %ecx,%eax
  801cce:	a8 03                	test   $0x3,%al
  801cd0:	75 21                	jne    801cf3 <memset+0x39>
		c &= 0xFF;
  801cd2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cd6:	89 d0                	mov    %edx,%eax
  801cd8:	c1 e0 08             	shl    $0x8,%eax
  801cdb:	89 d3                	mov    %edx,%ebx
  801cdd:	c1 e3 18             	shl    $0x18,%ebx
  801ce0:	89 d6                	mov    %edx,%esi
  801ce2:	c1 e6 10             	shl    $0x10,%esi
  801ce5:	09 f3                	or     %esi,%ebx
  801ce7:	09 da                	or     %ebx,%edx
  801ce9:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801ceb:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801cee:	fc                   	cld    
  801cef:	f3 ab                	rep stos %eax,%es:(%edi)
  801cf1:	eb 06                	jmp    801cf9 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf6:	fc                   	cld    
  801cf7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cf9:	89 f8                	mov    %edi,%eax
  801cfb:	5b                   	pop    %ebx
  801cfc:	5e                   	pop    %esi
  801cfd:	5f                   	pop    %edi
  801cfe:	5d                   	pop    %ebp
  801cff:	c3                   	ret    

00801d00 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	57                   	push   %edi
  801d04:	56                   	push   %esi
  801d05:	8b 45 08             	mov    0x8(%ebp),%eax
  801d08:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d0b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d0e:	39 c6                	cmp    %eax,%esi
  801d10:	73 32                	jae    801d44 <memmove+0x44>
  801d12:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d15:	39 c2                	cmp    %eax,%edx
  801d17:	76 2b                	jbe    801d44 <memmove+0x44>
		s += n;
		d += n;
  801d19:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d1c:	89 d6                	mov    %edx,%esi
  801d1e:	09 fe                	or     %edi,%esi
  801d20:	09 ce                	or     %ecx,%esi
  801d22:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d28:	75 0e                	jne    801d38 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d2a:	83 ef 04             	sub    $0x4,%edi
  801d2d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d30:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801d33:	fd                   	std    
  801d34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d36:	eb 09                	jmp    801d41 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d38:	83 ef 01             	sub    $0x1,%edi
  801d3b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801d3e:	fd                   	std    
  801d3f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d41:	fc                   	cld    
  801d42:	eb 1a                	jmp    801d5e <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d44:	89 f2                	mov    %esi,%edx
  801d46:	09 c2                	or     %eax,%edx
  801d48:	09 ca                	or     %ecx,%edx
  801d4a:	f6 c2 03             	test   $0x3,%dl
  801d4d:	75 0a                	jne    801d59 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d4f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801d52:	89 c7                	mov    %eax,%edi
  801d54:	fc                   	cld    
  801d55:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d57:	eb 05                	jmp    801d5e <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801d59:	89 c7                	mov    %eax,%edi
  801d5b:	fc                   	cld    
  801d5c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d5e:	5e                   	pop    %esi
  801d5f:	5f                   	pop    %edi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    

00801d62 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d68:	ff 75 10             	push   0x10(%ebp)
  801d6b:	ff 75 0c             	push   0xc(%ebp)
  801d6e:	ff 75 08             	push   0x8(%ebp)
  801d71:	e8 8a ff ff ff       	call   801d00 <memmove>
}
  801d76:	c9                   	leave  
  801d77:	c3                   	ret    

00801d78 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d78:	55                   	push   %ebp
  801d79:	89 e5                	mov    %esp,%ebp
  801d7b:	56                   	push   %esi
  801d7c:	53                   	push   %ebx
  801d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d80:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d83:	89 c6                	mov    %eax,%esi
  801d85:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d88:	eb 06                	jmp    801d90 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801d8a:	83 c0 01             	add    $0x1,%eax
  801d8d:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801d90:	39 f0                	cmp    %esi,%eax
  801d92:	74 14                	je     801da8 <memcmp+0x30>
		if (*s1 != *s2)
  801d94:	0f b6 08             	movzbl (%eax),%ecx
  801d97:	0f b6 1a             	movzbl (%edx),%ebx
  801d9a:	38 d9                	cmp    %bl,%cl
  801d9c:	74 ec                	je     801d8a <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801d9e:	0f b6 c1             	movzbl %cl,%eax
  801da1:	0f b6 db             	movzbl %bl,%ebx
  801da4:	29 d8                	sub    %ebx,%eax
  801da6:	eb 05                	jmp    801dad <memcmp+0x35>
	}

	return 0;
  801da8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dad:	5b                   	pop    %ebx
  801dae:	5e                   	pop    %esi
  801daf:	5d                   	pop    %ebp
  801db0:	c3                   	ret    

00801db1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
  801db4:	8b 45 08             	mov    0x8(%ebp),%eax
  801db7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801dba:	89 c2                	mov    %eax,%edx
  801dbc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801dbf:	eb 03                	jmp    801dc4 <memfind+0x13>
  801dc1:	83 c0 01             	add    $0x1,%eax
  801dc4:	39 d0                	cmp    %edx,%eax
  801dc6:	73 04                	jae    801dcc <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dc8:	38 08                	cmp    %cl,(%eax)
  801dca:	75 f5                	jne    801dc1 <memfind+0x10>
			break;
	return (void *) s;
}
  801dcc:	5d                   	pop    %ebp
  801dcd:	c3                   	ret    

00801dce <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dce:	55                   	push   %ebp
  801dcf:	89 e5                	mov    %esp,%ebp
  801dd1:	57                   	push   %edi
  801dd2:	56                   	push   %esi
  801dd3:	53                   	push   %ebx
  801dd4:	8b 55 08             	mov    0x8(%ebp),%edx
  801dd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dda:	eb 03                	jmp    801ddf <strtol+0x11>
		s++;
  801ddc:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801ddf:	0f b6 02             	movzbl (%edx),%eax
  801de2:	3c 20                	cmp    $0x20,%al
  801de4:	74 f6                	je     801ddc <strtol+0xe>
  801de6:	3c 09                	cmp    $0x9,%al
  801de8:	74 f2                	je     801ddc <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801dea:	3c 2b                	cmp    $0x2b,%al
  801dec:	74 2a                	je     801e18 <strtol+0x4a>
	int neg = 0;
  801dee:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801df3:	3c 2d                	cmp    $0x2d,%al
  801df5:	74 2b                	je     801e22 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801df7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801dfd:	75 0f                	jne    801e0e <strtol+0x40>
  801dff:	80 3a 30             	cmpb   $0x30,(%edx)
  801e02:	74 28                	je     801e2c <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e04:	85 db                	test   %ebx,%ebx
  801e06:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e0b:	0f 44 d8             	cmove  %eax,%ebx
  801e0e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e13:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801e16:	eb 46                	jmp    801e5e <strtol+0x90>
		s++;
  801e18:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801e1b:	bf 00 00 00 00       	mov    $0x0,%edi
  801e20:	eb d5                	jmp    801df7 <strtol+0x29>
		s++, neg = 1;
  801e22:	83 c2 01             	add    $0x1,%edx
  801e25:	bf 01 00 00 00       	mov    $0x1,%edi
  801e2a:	eb cb                	jmp    801df7 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e2c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e30:	74 0e                	je     801e40 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801e32:	85 db                	test   %ebx,%ebx
  801e34:	75 d8                	jne    801e0e <strtol+0x40>
		s++, base = 8;
  801e36:	83 c2 01             	add    $0x1,%edx
  801e39:	bb 08 00 00 00       	mov    $0x8,%ebx
  801e3e:	eb ce                	jmp    801e0e <strtol+0x40>
		s += 2, base = 16;
  801e40:	83 c2 02             	add    $0x2,%edx
  801e43:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e48:	eb c4                	jmp    801e0e <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801e4a:	0f be c0             	movsbl %al,%eax
  801e4d:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801e50:	3b 45 10             	cmp    0x10(%ebp),%eax
  801e53:	7d 3a                	jge    801e8f <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801e55:	83 c2 01             	add    $0x1,%edx
  801e58:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801e5c:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801e5e:	0f b6 02             	movzbl (%edx),%eax
  801e61:	8d 70 d0             	lea    -0x30(%eax),%esi
  801e64:	89 f3                	mov    %esi,%ebx
  801e66:	80 fb 09             	cmp    $0x9,%bl
  801e69:	76 df                	jbe    801e4a <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801e6b:	8d 70 9f             	lea    -0x61(%eax),%esi
  801e6e:	89 f3                	mov    %esi,%ebx
  801e70:	80 fb 19             	cmp    $0x19,%bl
  801e73:	77 08                	ja     801e7d <strtol+0xaf>
			dig = *s - 'a' + 10;
  801e75:	0f be c0             	movsbl %al,%eax
  801e78:	83 e8 57             	sub    $0x57,%eax
  801e7b:	eb d3                	jmp    801e50 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801e7d:	8d 70 bf             	lea    -0x41(%eax),%esi
  801e80:	89 f3                	mov    %esi,%ebx
  801e82:	80 fb 19             	cmp    $0x19,%bl
  801e85:	77 08                	ja     801e8f <strtol+0xc1>
			dig = *s - 'A' + 10;
  801e87:	0f be c0             	movsbl %al,%eax
  801e8a:	83 e8 37             	sub    $0x37,%eax
  801e8d:	eb c1                	jmp    801e50 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801e8f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e93:	74 05                	je     801e9a <strtol+0xcc>
		*endptr = (char *) s;
  801e95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e98:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801e9a:	89 c8                	mov    %ecx,%eax
  801e9c:	f7 d8                	neg    %eax
  801e9e:	85 ff                	test   %edi,%edi
  801ea0:	0f 45 c8             	cmovne %eax,%ecx
}
  801ea3:	89 c8                	mov    %ecx,%eax
  801ea5:	5b                   	pop    %ebx
  801ea6:	5e                   	pop    %esi
  801ea7:	5f                   	pop    %edi
  801ea8:	5d                   	pop    %ebp
  801ea9:	c3                   	ret    

00801eaa <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	56                   	push   %esi
  801eae:	53                   	push   %ebx
  801eaf:	8b 75 08             	mov    0x8(%ebp),%esi
  801eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801eb8:	85 c0                	test   %eax,%eax
  801eba:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ebf:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ec2:	83 ec 0c             	sub    $0xc,%esp
  801ec5:	50                   	push   %eax
  801ec6:	e8 3a e4 ff ff       	call   800305 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ecb:	83 c4 10             	add    $0x10,%esp
  801ece:	85 f6                	test   %esi,%esi
  801ed0:	74 17                	je     801ee9 <ipc_recv+0x3f>
  801ed2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed7:	85 c0                	test   %eax,%eax
  801ed9:	78 0c                	js     801ee7 <ipc_recv+0x3d>
  801edb:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ee1:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801ee7:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801ee9:	85 db                	test   %ebx,%ebx
  801eeb:	74 17                	je     801f04 <ipc_recv+0x5a>
  801eed:	ba 00 00 00 00       	mov    $0x0,%edx
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	78 0c                	js     801f02 <ipc_recv+0x58>
  801ef6:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801efc:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801f02:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f04:	85 c0                	test   %eax,%eax
  801f06:	78 0b                	js     801f13 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801f08:	a1 00 40 80 00       	mov    0x804000,%eax
  801f0d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801f13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f16:	5b                   	pop    %ebx
  801f17:	5e                   	pop    %esi
  801f18:	5d                   	pop    %ebp
  801f19:	c3                   	ret    

00801f1a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f1a:	55                   	push   %ebp
  801f1b:	89 e5                	mov    %esp,%ebp
  801f1d:	57                   	push   %edi
  801f1e:	56                   	push   %esi
  801f1f:	53                   	push   %ebx
  801f20:	83 ec 0c             	sub    $0xc,%esp
  801f23:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f26:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f2c:	85 db                	test   %ebx,%ebx
  801f2e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f33:	0f 44 d8             	cmove  %eax,%ebx
  801f36:	eb 05                	jmp    801f3d <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f38:	e8 f9 e1 ff ff       	call   800136 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f3d:	ff 75 14             	push   0x14(%ebp)
  801f40:	53                   	push   %ebx
  801f41:	56                   	push   %esi
  801f42:	57                   	push   %edi
  801f43:	e8 9a e3 ff ff       	call   8002e2 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f48:	83 c4 10             	add    $0x10,%esp
  801f4b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f4e:	74 e8                	je     801f38 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f50:	85 c0                	test   %eax,%eax
  801f52:	78 08                	js     801f5c <ipc_send+0x42>
	}while (r<0);

}
  801f54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f57:	5b                   	pop    %ebx
  801f58:	5e                   	pop    %esi
  801f59:	5f                   	pop    %edi
  801f5a:	5d                   	pop    %ebp
  801f5b:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f5c:	50                   	push   %eax
  801f5d:	68 bf 26 80 00       	push   $0x8026bf
  801f62:	6a 3d                	push   $0x3d
  801f64:	68 d3 26 80 00       	push   $0x8026d3
  801f69:	e8 47 f5 ff ff       	call   8014b5 <_panic>

00801f6e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f6e:	55                   	push   %ebp
  801f6f:	89 e5                	mov    %esp,%ebp
  801f71:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f74:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f79:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  801f7f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f85:	8b 52 60             	mov    0x60(%edx),%edx
  801f88:	39 ca                	cmp    %ecx,%edx
  801f8a:	74 11                	je     801f9d <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  801f8c:	83 c0 01             	add    $0x1,%eax
  801f8f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f94:	75 e3                	jne    801f79 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f96:	b8 00 00 00 00       	mov    $0x0,%eax
  801f9b:	eb 0e                	jmp    801fab <ipc_find_env+0x3d>
			return envs[i].env_id;
  801f9d:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801fa3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fa8:	8b 40 58             	mov    0x58(%eax),%eax
}
  801fab:	5d                   	pop    %ebp
  801fac:	c3                   	ret    

00801fad <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fad:	55                   	push   %ebp
  801fae:	89 e5                	mov    %esp,%ebp
  801fb0:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb3:	89 c2                	mov    %eax,%edx
  801fb5:	c1 ea 16             	shr    $0x16,%edx
  801fb8:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fbf:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fc4:	f6 c1 01             	test   $0x1,%cl
  801fc7:	74 1c                	je     801fe5 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801fc9:	c1 e8 0c             	shr    $0xc,%eax
  801fcc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fd3:	a8 01                	test   $0x1,%al
  801fd5:	74 0e                	je     801fe5 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fd7:	c1 e8 0c             	shr    $0xc,%eax
  801fda:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801fe1:	ef 
  801fe2:	0f b7 d2             	movzwl %dx,%edx
}
  801fe5:	89 d0                	mov    %edx,%eax
  801fe7:	5d                   	pop    %ebp
  801fe8:	c3                   	ret    
  801fe9:	66 90                	xchg   %ax,%ax
  801feb:	66 90                	xchg   %ax,%ax
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
