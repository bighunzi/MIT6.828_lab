
obj/user/softint：     文件格式 elf32-i386


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
  800041:	e8 c6 00 00 00       	call   80010c <sys_getenvid>
  800046:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80004e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800053:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800058:	85 db                	test   %ebx,%ebx
  80005a:	7e 07                	jle    800063 <libmain+0x2d>
		binaryname = argv[0];
  80005c:	8b 06                	mov    (%esi),%eax
  80005e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	56                   	push   %esi
  800067:	53                   	push   %ebx
  800068:	e8 c6 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80006d:	e8 0a 00 00 00       	call   80007c <exit>
}
  800072:	83 c4 10             	add    $0x10,%esp
  800075:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800078:	5b                   	pop    %ebx
  800079:	5e                   	pop    %esi
  80007a:	5d                   	pop    %ebp
  80007b:	c3                   	ret    

0080007c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007c:	55                   	push   %ebp
  80007d:	89 e5                	mov    %esp,%ebp
  80007f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800082:	6a 00                	push   $0x0
  800084:	e8 42 00 00 00       	call   8000cb <sys_env_destroy>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	c9                   	leave  
  80008d:	c3                   	ret    

0080008e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80008e:	55                   	push   %ebp
  80008f:	89 e5                	mov    %esp,%ebp
  800091:	57                   	push   %edi
  800092:	56                   	push   %esi
  800093:	53                   	push   %ebx
	asm volatile("int %1\n"
  800094:	b8 00 00 00 00       	mov    $0x0,%eax
  800099:	8b 55 08             	mov    0x8(%ebp),%edx
  80009c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009f:	89 c3                	mov    %eax,%ebx
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	89 c6                	mov    %eax,%esi
  8000a5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5f                   	pop    %edi
  8000aa:	5d                   	pop    %ebp
  8000ab:	c3                   	ret    

008000ac <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bc:	89 d1                	mov    %edx,%ecx
  8000be:	89 d3                	mov    %edx,%ebx
  8000c0:	89 d7                	mov    %edx,%edi
  8000c2:	89 d6                	mov    %edx,%esi
  8000c4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c6:	5b                   	pop    %ebx
  8000c7:	5e                   	pop    %esi
  8000c8:	5f                   	pop    %edi
  8000c9:	5d                   	pop    %ebp
  8000ca:	c3                   	ret    

008000cb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	57                   	push   %edi
  8000cf:	56                   	push   %esi
  8000d0:	53                   	push   %ebx
  8000d1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000dc:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e1:	89 cb                	mov    %ecx,%ebx
  8000e3:	89 cf                	mov    %ecx,%edi
  8000e5:	89 ce                	mov    %ecx,%esi
  8000e7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000e9:	85 c0                	test   %eax,%eax
  8000eb:	7f 08                	jg     8000f5 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	50                   	push   %eax
  8000f9:	6a 03                	push   $0x3
  8000fb:	68 4a 0f 80 00       	push   $0x800f4a
  800100:	6a 2a                	push   $0x2a
  800102:	68 67 0f 80 00       	push   $0x800f67
  800107:	e8 ed 01 00 00       	call   8002f9 <_panic>

0080010c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	57                   	push   %edi
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
	asm volatile("int %1\n"
  800112:	ba 00 00 00 00       	mov    $0x0,%edx
  800117:	b8 02 00 00 00       	mov    $0x2,%eax
  80011c:	89 d1                	mov    %edx,%ecx
  80011e:	89 d3                	mov    %edx,%ebx
  800120:	89 d7                	mov    %edx,%edi
  800122:	89 d6                	mov    %edx,%esi
  800124:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	5f                   	pop    %edi
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    

0080012b <sys_yield>:

void
sys_yield(void)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	57                   	push   %edi
  80012f:	56                   	push   %esi
  800130:	53                   	push   %ebx
	asm volatile("int %1\n"
  800131:	ba 00 00 00 00       	mov    $0x0,%edx
  800136:	b8 0a 00 00 00       	mov    $0xa,%eax
  80013b:	89 d1                	mov    %edx,%ecx
  80013d:	89 d3                	mov    %edx,%ebx
  80013f:	89 d7                	mov    %edx,%edi
  800141:	89 d6                	mov    %edx,%esi
  800143:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5f                   	pop    %edi
  800148:	5d                   	pop    %ebp
  800149:	c3                   	ret    

0080014a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	57                   	push   %edi
  80014e:	56                   	push   %esi
  80014f:	53                   	push   %ebx
  800150:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800153:	be 00 00 00 00       	mov    $0x0,%esi
  800158:	8b 55 08             	mov    0x8(%ebp),%edx
  80015b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80015e:	b8 04 00 00 00       	mov    $0x4,%eax
  800163:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800166:	89 f7                	mov    %esi,%edi
  800168:	cd 30                	int    $0x30
	if(check && ret > 0)
  80016a:	85 c0                	test   %eax,%eax
  80016c:	7f 08                	jg     800176 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80016e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800171:	5b                   	pop    %ebx
  800172:	5e                   	pop    %esi
  800173:	5f                   	pop    %edi
  800174:	5d                   	pop    %ebp
  800175:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	50                   	push   %eax
  80017a:	6a 04                	push   $0x4
  80017c:	68 4a 0f 80 00       	push   $0x800f4a
  800181:	6a 2a                	push   $0x2a
  800183:	68 67 0f 80 00       	push   $0x800f67
  800188:	e8 6c 01 00 00       	call   8002f9 <_panic>

0080018d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	57                   	push   %edi
  800191:	56                   	push   %esi
  800192:	53                   	push   %ebx
  800193:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800196:	8b 55 08             	mov    0x8(%ebp),%edx
  800199:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019c:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001a7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001aa:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ac:	85 c0                	test   %eax,%eax
  8001ae:	7f 08                	jg     8001b8 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	50                   	push   %eax
  8001bc:	6a 05                	push   $0x5
  8001be:	68 4a 0f 80 00       	push   $0x800f4a
  8001c3:	6a 2a                	push   $0x2a
  8001c5:	68 67 0f 80 00       	push   $0x800f67
  8001ca:	e8 2a 01 00 00       	call   8002f9 <_panic>

008001cf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	57                   	push   %edi
  8001d3:	56                   	push   %esi
  8001d4:	53                   	push   %ebx
  8001d5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e3:	b8 06 00 00 00       	mov    $0x6,%eax
  8001e8:	89 df                	mov    %ebx,%edi
  8001ea:	89 de                	mov    %ebx,%esi
  8001ec:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ee:	85 c0                	test   %eax,%eax
  8001f0:	7f 08                	jg     8001fa <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f5:	5b                   	pop    %ebx
  8001f6:	5e                   	pop    %esi
  8001f7:	5f                   	pop    %edi
  8001f8:	5d                   	pop    %ebp
  8001f9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fa:	83 ec 0c             	sub    $0xc,%esp
  8001fd:	50                   	push   %eax
  8001fe:	6a 06                	push   $0x6
  800200:	68 4a 0f 80 00       	push   $0x800f4a
  800205:	6a 2a                	push   $0x2a
  800207:	68 67 0f 80 00       	push   $0x800f67
  80020c:	e8 e8 00 00 00       	call   8002f9 <_panic>

00800211 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	57                   	push   %edi
  800215:	56                   	push   %esi
  800216:	53                   	push   %ebx
  800217:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80021a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021f:	8b 55 08             	mov    0x8(%ebp),%edx
  800222:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800225:	b8 08 00 00 00       	mov    $0x8,%eax
  80022a:	89 df                	mov    %ebx,%edi
  80022c:	89 de                	mov    %ebx,%esi
  80022e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800230:	85 c0                	test   %eax,%eax
  800232:	7f 08                	jg     80023c <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800234:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800237:	5b                   	pop    %ebx
  800238:	5e                   	pop    %esi
  800239:	5f                   	pop    %edi
  80023a:	5d                   	pop    %ebp
  80023b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	50                   	push   %eax
  800240:	6a 08                	push   $0x8
  800242:	68 4a 0f 80 00       	push   $0x800f4a
  800247:	6a 2a                	push   $0x2a
  800249:	68 67 0f 80 00       	push   $0x800f67
  80024e:	e8 a6 00 00 00       	call   8002f9 <_panic>

00800253 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	57                   	push   %edi
  800257:	56                   	push   %esi
  800258:	53                   	push   %ebx
  800259:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80025c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800261:	8b 55 08             	mov    0x8(%ebp),%edx
  800264:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800267:	b8 09 00 00 00       	mov    $0x9,%eax
  80026c:	89 df                	mov    %ebx,%edi
  80026e:	89 de                	mov    %ebx,%esi
  800270:	cd 30                	int    $0x30
	if(check && ret > 0)
  800272:	85 c0                	test   %eax,%eax
  800274:	7f 08                	jg     80027e <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800276:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800279:	5b                   	pop    %ebx
  80027a:	5e                   	pop    %esi
  80027b:	5f                   	pop    %edi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	50                   	push   %eax
  800282:	6a 09                	push   $0x9
  800284:	68 4a 0f 80 00       	push   $0x800f4a
  800289:	6a 2a                	push   $0x2a
  80028b:	68 67 0f 80 00       	push   $0x800f67
  800290:	e8 64 00 00 00       	call   8002f9 <_panic>

00800295 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	57                   	push   %edi
  800299:	56                   	push   %esi
  80029a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80029b:	8b 55 08             	mov    0x8(%ebp),%edx
  80029e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002a6:	be 00 00 00 00       	mov    $0x0,%esi
  8002ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ae:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b1:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002b3:	5b                   	pop    %ebx
  8002b4:	5e                   	pop    %esi
  8002b5:	5f                   	pop    %edi
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    

008002b8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	57                   	push   %edi
  8002bc:	56                   	push   %esi
  8002bd:	53                   	push   %ebx
  8002be:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ce:	89 cb                	mov    %ecx,%ebx
  8002d0:	89 cf                	mov    %ecx,%edi
  8002d2:	89 ce                	mov    %ecx,%esi
  8002d4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d6:	85 c0                	test   %eax,%eax
  8002d8:	7f 08                	jg     8002e2 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e2:	83 ec 0c             	sub    $0xc,%esp
  8002e5:	50                   	push   %eax
  8002e6:	6a 0c                	push   $0xc
  8002e8:	68 4a 0f 80 00       	push   $0x800f4a
  8002ed:	6a 2a                	push   $0x2a
  8002ef:	68 67 0f 80 00       	push   $0x800f67
  8002f4:	e8 00 00 00 00       	call   8002f9 <_panic>

008002f9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	56                   	push   %esi
  8002fd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002fe:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800301:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800307:	e8 00 fe ff ff       	call   80010c <sys_getenvid>
  80030c:	83 ec 0c             	sub    $0xc,%esp
  80030f:	ff 75 0c             	push   0xc(%ebp)
  800312:	ff 75 08             	push   0x8(%ebp)
  800315:	56                   	push   %esi
  800316:	50                   	push   %eax
  800317:	68 78 0f 80 00       	push   $0x800f78
  80031c:	e8 b3 00 00 00       	call   8003d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800321:	83 c4 18             	add    $0x18,%esp
  800324:	53                   	push   %ebx
  800325:	ff 75 10             	push   0x10(%ebp)
  800328:	e8 56 00 00 00       	call   800383 <vcprintf>
	cprintf("\n");
  80032d:	c7 04 24 9b 0f 80 00 	movl   $0x800f9b,(%esp)
  800334:	e8 9b 00 00 00       	call   8003d4 <cprintf>
  800339:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80033c:	cc                   	int3   
  80033d:	eb fd                	jmp    80033c <_panic+0x43>

0080033f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	53                   	push   %ebx
  800343:	83 ec 04             	sub    $0x4,%esp
  800346:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800349:	8b 13                	mov    (%ebx),%edx
  80034b:	8d 42 01             	lea    0x1(%edx),%eax
  80034e:	89 03                	mov    %eax,(%ebx)
  800350:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800353:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800357:	3d ff 00 00 00       	cmp    $0xff,%eax
  80035c:	74 09                	je     800367 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80035e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800362:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800365:	c9                   	leave  
  800366:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800367:	83 ec 08             	sub    $0x8,%esp
  80036a:	68 ff 00 00 00       	push   $0xff
  80036f:	8d 43 08             	lea    0x8(%ebx),%eax
  800372:	50                   	push   %eax
  800373:	e8 16 fd ff ff       	call   80008e <sys_cputs>
		b->idx = 0;
  800378:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80037e:	83 c4 10             	add    $0x10,%esp
  800381:	eb db                	jmp    80035e <putch+0x1f>

00800383 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80038c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800393:	00 00 00 
	b.cnt = 0;
  800396:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80039d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a0:	ff 75 0c             	push   0xc(%ebp)
  8003a3:	ff 75 08             	push   0x8(%ebp)
  8003a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ac:	50                   	push   %eax
  8003ad:	68 3f 03 80 00       	push   $0x80033f
  8003b2:	e8 14 01 00 00       	call   8004cb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003b7:	83 c4 08             	add    $0x8,%esp
  8003ba:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003c6:	50                   	push   %eax
  8003c7:	e8 c2 fc ff ff       	call   80008e <sys_cputs>

	return b.cnt;
}
  8003cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003d2:	c9                   	leave  
  8003d3:	c3                   	ret    

008003d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003dd:	50                   	push   %eax
  8003de:	ff 75 08             	push   0x8(%ebp)
  8003e1:	e8 9d ff ff ff       	call   800383 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003e6:	c9                   	leave  
  8003e7:	c3                   	ret    

008003e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	57                   	push   %edi
  8003ec:	56                   	push   %esi
  8003ed:	53                   	push   %ebx
  8003ee:	83 ec 1c             	sub    $0x1c,%esp
  8003f1:	89 c7                	mov    %eax,%edi
  8003f3:	89 d6                	mov    %edx,%esi
  8003f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fb:	89 d1                	mov    %edx,%ecx
  8003fd:	89 c2                	mov    %eax,%edx
  8003ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800402:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800405:	8b 45 10             	mov    0x10(%ebp),%eax
  800408:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80040b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800415:	39 c2                	cmp    %eax,%edx
  800417:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80041a:	72 3e                	jb     80045a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80041c:	83 ec 0c             	sub    $0xc,%esp
  80041f:	ff 75 18             	push   0x18(%ebp)
  800422:	83 eb 01             	sub    $0x1,%ebx
  800425:	53                   	push   %ebx
  800426:	50                   	push   %eax
  800427:	83 ec 08             	sub    $0x8,%esp
  80042a:	ff 75 e4             	push   -0x1c(%ebp)
  80042d:	ff 75 e0             	push   -0x20(%ebp)
  800430:	ff 75 dc             	push   -0x24(%ebp)
  800433:	ff 75 d8             	push   -0x28(%ebp)
  800436:	e8 b5 08 00 00       	call   800cf0 <__udivdi3>
  80043b:	83 c4 18             	add    $0x18,%esp
  80043e:	52                   	push   %edx
  80043f:	50                   	push   %eax
  800440:	89 f2                	mov    %esi,%edx
  800442:	89 f8                	mov    %edi,%eax
  800444:	e8 9f ff ff ff       	call   8003e8 <printnum>
  800449:	83 c4 20             	add    $0x20,%esp
  80044c:	eb 13                	jmp    800461 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80044e:	83 ec 08             	sub    $0x8,%esp
  800451:	56                   	push   %esi
  800452:	ff 75 18             	push   0x18(%ebp)
  800455:	ff d7                	call   *%edi
  800457:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80045a:	83 eb 01             	sub    $0x1,%ebx
  80045d:	85 db                	test   %ebx,%ebx
  80045f:	7f ed                	jg     80044e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	56                   	push   %esi
  800465:	83 ec 04             	sub    $0x4,%esp
  800468:	ff 75 e4             	push   -0x1c(%ebp)
  80046b:	ff 75 e0             	push   -0x20(%ebp)
  80046e:	ff 75 dc             	push   -0x24(%ebp)
  800471:	ff 75 d8             	push   -0x28(%ebp)
  800474:	e8 97 09 00 00       	call   800e10 <__umoddi3>
  800479:	83 c4 14             	add    $0x14,%esp
  80047c:	0f be 80 9d 0f 80 00 	movsbl 0x800f9d(%eax),%eax
  800483:	50                   	push   %eax
  800484:	ff d7                	call   *%edi
}
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048c:	5b                   	pop    %ebx
  80048d:	5e                   	pop    %esi
  80048e:	5f                   	pop    %edi
  80048f:	5d                   	pop    %ebp
  800490:	c3                   	ret    

00800491 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800497:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80049b:	8b 10                	mov    (%eax),%edx
  80049d:	3b 50 04             	cmp    0x4(%eax),%edx
  8004a0:	73 0a                	jae    8004ac <sprintputch+0x1b>
		*b->buf++ = ch;
  8004a2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004a5:	89 08                	mov    %ecx,(%eax)
  8004a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004aa:	88 02                	mov    %al,(%edx)
}
  8004ac:	5d                   	pop    %ebp
  8004ad:	c3                   	ret    

008004ae <printfmt>:
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
  8004b1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004b7:	50                   	push   %eax
  8004b8:	ff 75 10             	push   0x10(%ebp)
  8004bb:	ff 75 0c             	push   0xc(%ebp)
  8004be:	ff 75 08             	push   0x8(%ebp)
  8004c1:	e8 05 00 00 00       	call   8004cb <vprintfmt>
}
  8004c6:	83 c4 10             	add    $0x10,%esp
  8004c9:	c9                   	leave  
  8004ca:	c3                   	ret    

008004cb <vprintfmt>:
{
  8004cb:	55                   	push   %ebp
  8004cc:	89 e5                	mov    %esp,%ebp
  8004ce:	57                   	push   %edi
  8004cf:	56                   	push   %esi
  8004d0:	53                   	push   %ebx
  8004d1:	83 ec 3c             	sub    $0x3c,%esp
  8004d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004da:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004dd:	eb 0a                	jmp    8004e9 <vprintfmt+0x1e>
			putch(ch, putdat);
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	53                   	push   %ebx
  8004e3:	50                   	push   %eax
  8004e4:	ff d6                	call   *%esi
  8004e6:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004e9:	83 c7 01             	add    $0x1,%edi
  8004ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f0:	83 f8 25             	cmp    $0x25,%eax
  8004f3:	74 0c                	je     800501 <vprintfmt+0x36>
			if (ch == '\0')
  8004f5:	85 c0                	test   %eax,%eax
  8004f7:	75 e6                	jne    8004df <vprintfmt+0x14>
}
  8004f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004fc:	5b                   	pop    %ebx
  8004fd:	5e                   	pop    %esi
  8004fe:	5f                   	pop    %edi
  8004ff:	5d                   	pop    %ebp
  800500:	c3                   	ret    
		padc = ' ';
  800501:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800505:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80050c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800513:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80051a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80051f:	8d 47 01             	lea    0x1(%edi),%eax
  800522:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800525:	0f b6 17             	movzbl (%edi),%edx
  800528:	8d 42 dd             	lea    -0x23(%edx),%eax
  80052b:	3c 55                	cmp    $0x55,%al
  80052d:	0f 87 bb 03 00 00    	ja     8008ee <vprintfmt+0x423>
  800533:	0f b6 c0             	movzbl %al,%eax
  800536:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)
  80053d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800540:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800544:	eb d9                	jmp    80051f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800546:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800549:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80054d:	eb d0                	jmp    80051f <vprintfmt+0x54>
  80054f:	0f b6 d2             	movzbl %dl,%edx
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800555:	b8 00 00 00 00       	mov    $0x0,%eax
  80055a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80055d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800560:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800564:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800567:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80056a:	83 f9 09             	cmp    $0x9,%ecx
  80056d:	77 55                	ja     8005c4 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80056f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800572:	eb e9                	jmp    80055d <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8b 00                	mov    (%eax),%eax
  800579:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8d 40 04             	lea    0x4(%eax),%eax
  800582:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800585:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800588:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058c:	79 91                	jns    80051f <vprintfmt+0x54>
				width = precision, precision = -1;
  80058e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800591:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800594:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80059b:	eb 82                	jmp    80051f <vprintfmt+0x54>
  80059d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005a0:	85 d2                	test   %edx,%edx
  8005a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a7:	0f 49 c2             	cmovns %edx,%eax
  8005aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005b0:	e9 6a ff ff ff       	jmp    80051f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005b8:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005bf:	e9 5b ff ff ff       	jmp    80051f <vprintfmt+0x54>
  8005c4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ca:	eb bc                	jmp    800588 <vprintfmt+0xbd>
			lflag++;
  8005cc:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005d2:	e9 48 ff ff ff       	jmp    80051f <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 78 04             	lea    0x4(%eax),%edi
  8005dd:	83 ec 08             	sub    $0x8,%esp
  8005e0:	53                   	push   %ebx
  8005e1:	ff 30                	push   (%eax)
  8005e3:	ff d6                	call   *%esi
			break;
  8005e5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005e8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005eb:	e9 9d 02 00 00       	jmp    80088d <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	8d 78 04             	lea    0x4(%eax),%edi
  8005f6:	8b 10                	mov    (%eax),%edx
  8005f8:	89 d0                	mov    %edx,%eax
  8005fa:	f7 d8                	neg    %eax
  8005fc:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ff:	83 f8 08             	cmp    $0x8,%eax
  800602:	7f 23                	jg     800627 <vprintfmt+0x15c>
  800604:	8b 14 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%edx
  80060b:	85 d2                	test   %edx,%edx
  80060d:	74 18                	je     800627 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80060f:	52                   	push   %edx
  800610:	68 be 0f 80 00       	push   $0x800fbe
  800615:	53                   	push   %ebx
  800616:	56                   	push   %esi
  800617:	e8 92 fe ff ff       	call   8004ae <printfmt>
  80061c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80061f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800622:	e9 66 02 00 00       	jmp    80088d <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800627:	50                   	push   %eax
  800628:	68 b5 0f 80 00       	push   $0x800fb5
  80062d:	53                   	push   %ebx
  80062e:	56                   	push   %esi
  80062f:	e8 7a fe ff ff       	call   8004ae <printfmt>
  800634:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800637:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80063a:	e9 4e 02 00 00       	jmp    80088d <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	83 c0 04             	add    $0x4,%eax
  800645:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80064d:	85 d2                	test   %edx,%edx
  80064f:	b8 ae 0f 80 00       	mov    $0x800fae,%eax
  800654:	0f 45 c2             	cmovne %edx,%eax
  800657:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80065a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80065e:	7e 06                	jle    800666 <vprintfmt+0x19b>
  800660:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800664:	75 0d                	jne    800673 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800666:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800669:	89 c7                	mov    %eax,%edi
  80066b:	03 45 e0             	add    -0x20(%ebp),%eax
  80066e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800671:	eb 55                	jmp    8006c8 <vprintfmt+0x1fd>
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	ff 75 d8             	push   -0x28(%ebp)
  800679:	ff 75 cc             	push   -0x34(%ebp)
  80067c:	e8 0a 03 00 00       	call   80098b <strnlen>
  800681:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800684:	29 c1                	sub    %eax,%ecx
  800686:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800689:	83 c4 10             	add    $0x10,%esp
  80068c:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80068e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800692:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800695:	eb 0f                	jmp    8006a6 <vprintfmt+0x1db>
					putch(padc, putdat);
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	53                   	push   %ebx
  80069b:	ff 75 e0             	push   -0x20(%ebp)
  80069e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a0:	83 ef 01             	sub    $0x1,%edi
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	85 ff                	test   %edi,%edi
  8006a8:	7f ed                	jg     800697 <vprintfmt+0x1cc>
  8006aa:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006ad:	85 d2                	test   %edx,%edx
  8006af:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b4:	0f 49 c2             	cmovns %edx,%eax
  8006b7:	29 c2                	sub    %eax,%edx
  8006b9:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006bc:	eb a8                	jmp    800666 <vprintfmt+0x19b>
					putch(ch, putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	53                   	push   %ebx
  8006c2:	52                   	push   %edx
  8006c3:	ff d6                	call   *%esi
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006cb:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006cd:	83 c7 01             	add    $0x1,%edi
  8006d0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006d4:	0f be d0             	movsbl %al,%edx
  8006d7:	85 d2                	test   %edx,%edx
  8006d9:	74 4b                	je     800726 <vprintfmt+0x25b>
  8006db:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006df:	78 06                	js     8006e7 <vprintfmt+0x21c>
  8006e1:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8006e5:	78 1e                	js     800705 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8006e7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006eb:	74 d1                	je     8006be <vprintfmt+0x1f3>
  8006ed:	0f be c0             	movsbl %al,%eax
  8006f0:	83 e8 20             	sub    $0x20,%eax
  8006f3:	83 f8 5e             	cmp    $0x5e,%eax
  8006f6:	76 c6                	jbe    8006be <vprintfmt+0x1f3>
					putch('?', putdat);
  8006f8:	83 ec 08             	sub    $0x8,%esp
  8006fb:	53                   	push   %ebx
  8006fc:	6a 3f                	push   $0x3f
  8006fe:	ff d6                	call   *%esi
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	eb c3                	jmp    8006c8 <vprintfmt+0x1fd>
  800705:	89 cf                	mov    %ecx,%edi
  800707:	eb 0e                	jmp    800717 <vprintfmt+0x24c>
				putch(' ', putdat);
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	53                   	push   %ebx
  80070d:	6a 20                	push   $0x20
  80070f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800711:	83 ef 01             	sub    $0x1,%edi
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	85 ff                	test   %edi,%edi
  800719:	7f ee                	jg     800709 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80071b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80071e:	89 45 14             	mov    %eax,0x14(%ebp)
  800721:	e9 67 01 00 00       	jmp    80088d <vprintfmt+0x3c2>
  800726:	89 cf                	mov    %ecx,%edi
  800728:	eb ed                	jmp    800717 <vprintfmt+0x24c>
	if (lflag >= 2)
  80072a:	83 f9 01             	cmp    $0x1,%ecx
  80072d:	7f 1b                	jg     80074a <vprintfmt+0x27f>
	else if (lflag)
  80072f:	85 c9                	test   %ecx,%ecx
  800731:	74 63                	je     800796 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800733:	8b 45 14             	mov    0x14(%ebp),%eax
  800736:	8b 00                	mov    (%eax),%eax
  800738:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073b:	99                   	cltd   
  80073c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80073f:	8b 45 14             	mov    0x14(%ebp),%eax
  800742:	8d 40 04             	lea    0x4(%eax),%eax
  800745:	89 45 14             	mov    %eax,0x14(%ebp)
  800748:	eb 17                	jmp    800761 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8b 50 04             	mov    0x4(%eax),%edx
  800750:	8b 00                	mov    (%eax),%eax
  800752:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800755:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8d 40 08             	lea    0x8(%eax),%eax
  80075e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800761:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800764:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800767:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80076c:	85 c9                	test   %ecx,%ecx
  80076e:	0f 89 ff 00 00 00    	jns    800873 <vprintfmt+0x3a8>
				putch('-', putdat);
  800774:	83 ec 08             	sub    $0x8,%esp
  800777:	53                   	push   %ebx
  800778:	6a 2d                	push   $0x2d
  80077a:	ff d6                	call   *%esi
				num = -(long long) num;
  80077c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80077f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800782:	f7 da                	neg    %edx
  800784:	83 d1 00             	adc    $0x0,%ecx
  800787:	f7 d9                	neg    %ecx
  800789:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80078c:	bf 0a 00 00 00       	mov    $0xa,%edi
  800791:	e9 dd 00 00 00       	jmp    800873 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800796:	8b 45 14             	mov    0x14(%ebp),%eax
  800799:	8b 00                	mov    (%eax),%eax
  80079b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80079e:	99                   	cltd   
  80079f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a5:	8d 40 04             	lea    0x4(%eax),%eax
  8007a8:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ab:	eb b4                	jmp    800761 <vprintfmt+0x296>
	if (lflag >= 2)
  8007ad:	83 f9 01             	cmp    $0x1,%ecx
  8007b0:	7f 1e                	jg     8007d0 <vprintfmt+0x305>
	else if (lflag)
  8007b2:	85 c9                	test   %ecx,%ecx
  8007b4:	74 32                	je     8007e8 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8007b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b9:	8b 10                	mov    (%eax),%edx
  8007bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c0:	8d 40 04             	lea    0x4(%eax),%eax
  8007c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007c6:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8007cb:	e9 a3 00 00 00       	jmp    800873 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d3:	8b 10                	mov    (%eax),%edx
  8007d5:	8b 48 04             	mov    0x4(%eax),%ecx
  8007d8:	8d 40 08             	lea    0x8(%eax),%eax
  8007db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007de:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8007e3:	e9 8b 00 00 00       	jmp    800873 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8b 10                	mov    (%eax),%edx
  8007ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f2:	8d 40 04             	lea    0x4(%eax),%eax
  8007f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007f8:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8007fd:	eb 74                	jmp    800873 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8007ff:	83 f9 01             	cmp    $0x1,%ecx
  800802:	7f 1b                	jg     80081f <vprintfmt+0x354>
	else if (lflag)
  800804:	85 c9                	test   %ecx,%ecx
  800806:	74 2c                	je     800834 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800808:	8b 45 14             	mov    0x14(%ebp),%eax
  80080b:	8b 10                	mov    (%eax),%edx
  80080d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800812:	8d 40 04             	lea    0x4(%eax),%eax
  800815:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800818:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80081d:	eb 54                	jmp    800873 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80081f:	8b 45 14             	mov    0x14(%ebp),%eax
  800822:	8b 10                	mov    (%eax),%edx
  800824:	8b 48 04             	mov    0x4(%eax),%ecx
  800827:	8d 40 08             	lea    0x8(%eax),%eax
  80082a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80082d:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800832:	eb 3f                	jmp    800873 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800834:	8b 45 14             	mov    0x14(%ebp),%eax
  800837:	8b 10                	mov    (%eax),%edx
  800839:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083e:	8d 40 04             	lea    0x4(%eax),%eax
  800841:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800844:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800849:	eb 28                	jmp    800873 <vprintfmt+0x3a8>
			putch('0', putdat);
  80084b:	83 ec 08             	sub    $0x8,%esp
  80084e:	53                   	push   %ebx
  80084f:	6a 30                	push   $0x30
  800851:	ff d6                	call   *%esi
			putch('x', putdat);
  800853:	83 c4 08             	add    $0x8,%esp
  800856:	53                   	push   %ebx
  800857:	6a 78                	push   $0x78
  800859:	ff d6                	call   *%esi
			num = (unsigned long long)
  80085b:	8b 45 14             	mov    0x14(%ebp),%eax
  80085e:	8b 10                	mov    (%eax),%edx
  800860:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800865:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800868:	8d 40 04             	lea    0x4(%eax),%eax
  80086b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80086e:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800873:	83 ec 0c             	sub    $0xc,%esp
  800876:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80087a:	50                   	push   %eax
  80087b:	ff 75 e0             	push   -0x20(%ebp)
  80087e:	57                   	push   %edi
  80087f:	51                   	push   %ecx
  800880:	52                   	push   %edx
  800881:	89 da                	mov    %ebx,%edx
  800883:	89 f0                	mov    %esi,%eax
  800885:	e8 5e fb ff ff       	call   8003e8 <printnum>
			break;
  80088a:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80088d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800890:	e9 54 fc ff ff       	jmp    8004e9 <vprintfmt+0x1e>
	if (lflag >= 2)
  800895:	83 f9 01             	cmp    $0x1,%ecx
  800898:	7f 1b                	jg     8008b5 <vprintfmt+0x3ea>
	else if (lflag)
  80089a:	85 c9                	test   %ecx,%ecx
  80089c:	74 2c                	je     8008ca <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80089e:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a1:	8b 10                	mov    (%eax),%edx
  8008a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008a8:	8d 40 04             	lea    0x4(%eax),%eax
  8008ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ae:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8008b3:	eb be                	jmp    800873 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8008b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b8:	8b 10                	mov    (%eax),%edx
  8008ba:	8b 48 04             	mov    0x4(%eax),%ecx
  8008bd:	8d 40 08             	lea    0x8(%eax),%eax
  8008c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008c3:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8008c8:	eb a9                	jmp    800873 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8008ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cd:	8b 10                	mov    (%eax),%edx
  8008cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008d4:	8d 40 04             	lea    0x4(%eax),%eax
  8008d7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008da:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8008df:	eb 92                	jmp    800873 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	53                   	push   %ebx
  8008e5:	6a 25                	push   $0x25
  8008e7:	ff d6                	call   *%esi
			break;
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	eb 9f                	jmp    80088d <vprintfmt+0x3c2>
			putch('%', putdat);
  8008ee:	83 ec 08             	sub    $0x8,%esp
  8008f1:	53                   	push   %ebx
  8008f2:	6a 25                	push   $0x25
  8008f4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008f6:	83 c4 10             	add    $0x10,%esp
  8008f9:	89 f8                	mov    %edi,%eax
  8008fb:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8008ff:	74 05                	je     800906 <vprintfmt+0x43b>
  800901:	83 e8 01             	sub    $0x1,%eax
  800904:	eb f5                	jmp    8008fb <vprintfmt+0x430>
  800906:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800909:	eb 82                	jmp    80088d <vprintfmt+0x3c2>

0080090b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	83 ec 18             	sub    $0x18,%esp
  800911:	8b 45 08             	mov    0x8(%ebp),%eax
  800914:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800917:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80091a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80091e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800921:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800928:	85 c0                	test   %eax,%eax
  80092a:	74 26                	je     800952 <vsnprintf+0x47>
  80092c:	85 d2                	test   %edx,%edx
  80092e:	7e 22                	jle    800952 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800930:	ff 75 14             	push   0x14(%ebp)
  800933:	ff 75 10             	push   0x10(%ebp)
  800936:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800939:	50                   	push   %eax
  80093a:	68 91 04 80 00       	push   $0x800491
  80093f:	e8 87 fb ff ff       	call   8004cb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800944:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800947:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80094a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094d:	83 c4 10             	add    $0x10,%esp
}
  800950:	c9                   	leave  
  800951:	c3                   	ret    
		return -E_INVAL;
  800952:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800957:	eb f7                	jmp    800950 <vsnprintf+0x45>

00800959 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80095f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800962:	50                   	push   %eax
  800963:	ff 75 10             	push   0x10(%ebp)
  800966:	ff 75 0c             	push   0xc(%ebp)
  800969:	ff 75 08             	push   0x8(%ebp)
  80096c:	e8 9a ff ff ff       	call   80090b <vsnprintf>
	va_end(ap);

	return rc;
}
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800979:	b8 00 00 00 00       	mov    $0x0,%eax
  80097e:	eb 03                	jmp    800983 <strlen+0x10>
		n++;
  800980:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800983:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800987:	75 f7                	jne    800980 <strlen+0xd>
	return n;
}
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800991:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
  800999:	eb 03                	jmp    80099e <strnlen+0x13>
		n++;
  80099b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099e:	39 d0                	cmp    %edx,%eax
  8009a0:	74 08                	je     8009aa <strnlen+0x1f>
  8009a2:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009a6:	75 f3                	jne    80099b <strnlen+0x10>
  8009a8:	89 c2                	mov    %eax,%edx
	return n;
}
  8009aa:	89 d0                	mov    %edx,%eax
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	53                   	push   %ebx
  8009b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8009bd:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8009c1:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8009c4:	83 c0 01             	add    $0x1,%eax
  8009c7:	84 d2                	test   %dl,%dl
  8009c9:	75 f2                	jne    8009bd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009cb:	89 c8                	mov    %ecx,%eax
  8009cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d0:	c9                   	leave  
  8009d1:	c3                   	ret    

008009d2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	53                   	push   %ebx
  8009d6:	83 ec 10             	sub    $0x10,%esp
  8009d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009dc:	53                   	push   %ebx
  8009dd:	e8 91 ff ff ff       	call   800973 <strlen>
  8009e2:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8009e5:	ff 75 0c             	push   0xc(%ebp)
  8009e8:	01 d8                	add    %ebx,%eax
  8009ea:	50                   	push   %eax
  8009eb:	e8 be ff ff ff       	call   8009ae <strcpy>
	return dst;
}
  8009f0:	89 d8                	mov    %ebx,%eax
  8009f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	56                   	push   %esi
  8009fb:	53                   	push   %ebx
  8009fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a02:	89 f3                	mov    %esi,%ebx
  800a04:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a07:	89 f0                	mov    %esi,%eax
  800a09:	eb 0f                	jmp    800a1a <strncpy+0x23>
		*dst++ = *src;
  800a0b:	83 c0 01             	add    $0x1,%eax
  800a0e:	0f b6 0a             	movzbl (%edx),%ecx
  800a11:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a14:	80 f9 01             	cmp    $0x1,%cl
  800a17:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800a1a:	39 d8                	cmp    %ebx,%eax
  800a1c:	75 ed                	jne    800a0b <strncpy+0x14>
	}
	return ret;
}
  800a1e:	89 f0                	mov    %esi,%eax
  800a20:	5b                   	pop    %ebx
  800a21:	5e                   	pop    %esi
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	56                   	push   %esi
  800a28:	53                   	push   %ebx
  800a29:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2f:	8b 55 10             	mov    0x10(%ebp),%edx
  800a32:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a34:	85 d2                	test   %edx,%edx
  800a36:	74 21                	je     800a59 <strlcpy+0x35>
  800a38:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a3c:	89 f2                	mov    %esi,%edx
  800a3e:	eb 09                	jmp    800a49 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a40:	83 c1 01             	add    $0x1,%ecx
  800a43:	83 c2 01             	add    $0x1,%edx
  800a46:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800a49:	39 c2                	cmp    %eax,%edx
  800a4b:	74 09                	je     800a56 <strlcpy+0x32>
  800a4d:	0f b6 19             	movzbl (%ecx),%ebx
  800a50:	84 db                	test   %bl,%bl
  800a52:	75 ec                	jne    800a40 <strlcpy+0x1c>
  800a54:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a56:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a59:	29 f0                	sub    %esi,%eax
}
  800a5b:	5b                   	pop    %ebx
  800a5c:	5e                   	pop    %esi
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a65:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a68:	eb 06                	jmp    800a70 <strcmp+0x11>
		p++, q++;
  800a6a:	83 c1 01             	add    $0x1,%ecx
  800a6d:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a70:	0f b6 01             	movzbl (%ecx),%eax
  800a73:	84 c0                	test   %al,%al
  800a75:	74 04                	je     800a7b <strcmp+0x1c>
  800a77:	3a 02                	cmp    (%edx),%al
  800a79:	74 ef                	je     800a6a <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7b:	0f b6 c0             	movzbl %al,%eax
  800a7e:	0f b6 12             	movzbl (%edx),%edx
  800a81:	29 d0                	sub    %edx,%eax
}
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	53                   	push   %ebx
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8f:	89 c3                	mov    %eax,%ebx
  800a91:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a94:	eb 06                	jmp    800a9c <strncmp+0x17>
		n--, p++, q++;
  800a96:	83 c0 01             	add    $0x1,%eax
  800a99:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a9c:	39 d8                	cmp    %ebx,%eax
  800a9e:	74 18                	je     800ab8 <strncmp+0x33>
  800aa0:	0f b6 08             	movzbl (%eax),%ecx
  800aa3:	84 c9                	test   %cl,%cl
  800aa5:	74 04                	je     800aab <strncmp+0x26>
  800aa7:	3a 0a                	cmp    (%edx),%cl
  800aa9:	74 eb                	je     800a96 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aab:	0f b6 00             	movzbl (%eax),%eax
  800aae:	0f b6 12             	movzbl (%edx),%edx
  800ab1:	29 d0                	sub    %edx,%eax
}
  800ab3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ab6:	c9                   	leave  
  800ab7:	c3                   	ret    
		return 0;
  800ab8:	b8 00 00 00 00       	mov    $0x0,%eax
  800abd:	eb f4                	jmp    800ab3 <strncmp+0x2e>

00800abf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac9:	eb 03                	jmp    800ace <strchr+0xf>
  800acb:	83 c0 01             	add    $0x1,%eax
  800ace:	0f b6 10             	movzbl (%eax),%edx
  800ad1:	84 d2                	test   %dl,%dl
  800ad3:	74 06                	je     800adb <strchr+0x1c>
		if (*s == c)
  800ad5:	38 ca                	cmp    %cl,%dl
  800ad7:	75 f2                	jne    800acb <strchr+0xc>
  800ad9:	eb 05                	jmp    800ae0 <strchr+0x21>
			return (char *) s;
	return 0;
  800adb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aec:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aef:	38 ca                	cmp    %cl,%dl
  800af1:	74 09                	je     800afc <strfind+0x1a>
  800af3:	84 d2                	test   %dl,%dl
  800af5:	74 05                	je     800afc <strfind+0x1a>
	for (; *s; s++)
  800af7:	83 c0 01             	add    $0x1,%eax
  800afa:	eb f0                	jmp    800aec <strfind+0xa>
			break;
	return (char *) s;
}
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
  800b04:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b07:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b0a:	85 c9                	test   %ecx,%ecx
  800b0c:	74 2f                	je     800b3d <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b0e:	89 f8                	mov    %edi,%eax
  800b10:	09 c8                	or     %ecx,%eax
  800b12:	a8 03                	test   $0x3,%al
  800b14:	75 21                	jne    800b37 <memset+0x39>
		c &= 0xFF;
  800b16:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b1a:	89 d0                	mov    %edx,%eax
  800b1c:	c1 e0 08             	shl    $0x8,%eax
  800b1f:	89 d3                	mov    %edx,%ebx
  800b21:	c1 e3 18             	shl    $0x18,%ebx
  800b24:	89 d6                	mov    %edx,%esi
  800b26:	c1 e6 10             	shl    $0x10,%esi
  800b29:	09 f3                	or     %esi,%ebx
  800b2b:	09 da                	or     %ebx,%edx
  800b2d:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b2f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b32:	fc                   	cld    
  800b33:	f3 ab                	rep stos %eax,%es:(%edi)
  800b35:	eb 06                	jmp    800b3d <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3a:	fc                   	cld    
  800b3b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b3d:	89 f8                	mov    %edi,%eax
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b52:	39 c6                	cmp    %eax,%esi
  800b54:	73 32                	jae    800b88 <memmove+0x44>
  800b56:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b59:	39 c2                	cmp    %eax,%edx
  800b5b:	76 2b                	jbe    800b88 <memmove+0x44>
		s += n;
		d += n;
  800b5d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b60:	89 d6                	mov    %edx,%esi
  800b62:	09 fe                	or     %edi,%esi
  800b64:	09 ce                	or     %ecx,%esi
  800b66:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b6c:	75 0e                	jne    800b7c <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b6e:	83 ef 04             	sub    $0x4,%edi
  800b71:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b74:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b77:	fd                   	std    
  800b78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7a:	eb 09                	jmp    800b85 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b7c:	83 ef 01             	sub    $0x1,%edi
  800b7f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b82:	fd                   	std    
  800b83:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b85:	fc                   	cld    
  800b86:	eb 1a                	jmp    800ba2 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b88:	89 f2                	mov    %esi,%edx
  800b8a:	09 c2                	or     %eax,%edx
  800b8c:	09 ca                	or     %ecx,%edx
  800b8e:	f6 c2 03             	test   $0x3,%dl
  800b91:	75 0a                	jne    800b9d <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b93:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b96:	89 c7                	mov    %eax,%edi
  800b98:	fc                   	cld    
  800b99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b9b:	eb 05                	jmp    800ba2 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800b9d:	89 c7                	mov    %eax,%edi
  800b9f:	fc                   	cld    
  800ba0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bac:	ff 75 10             	push   0x10(%ebp)
  800baf:	ff 75 0c             	push   0xc(%ebp)
  800bb2:	ff 75 08             	push   0x8(%ebp)
  800bb5:	e8 8a ff ff ff       	call   800b44 <memmove>
}
  800bba:	c9                   	leave  
  800bbb:	c3                   	ret    

00800bbc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
  800bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bc7:	89 c6                	mov    %eax,%esi
  800bc9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bcc:	eb 06                	jmp    800bd4 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bce:	83 c0 01             	add    $0x1,%eax
  800bd1:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800bd4:	39 f0                	cmp    %esi,%eax
  800bd6:	74 14                	je     800bec <memcmp+0x30>
		if (*s1 != *s2)
  800bd8:	0f b6 08             	movzbl (%eax),%ecx
  800bdb:	0f b6 1a             	movzbl (%edx),%ebx
  800bde:	38 d9                	cmp    %bl,%cl
  800be0:	74 ec                	je     800bce <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800be2:	0f b6 c1             	movzbl %cl,%eax
  800be5:	0f b6 db             	movzbl %bl,%ebx
  800be8:	29 d8                	sub    %ebx,%eax
  800bea:	eb 05                	jmp    800bf1 <memcmp+0x35>
	}

	return 0;
  800bec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bfe:	89 c2                	mov    %eax,%edx
  800c00:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c03:	eb 03                	jmp    800c08 <memfind+0x13>
  800c05:	83 c0 01             	add    $0x1,%eax
  800c08:	39 d0                	cmp    %edx,%eax
  800c0a:	73 04                	jae    800c10 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c0c:	38 08                	cmp    %cl,(%eax)
  800c0e:	75 f5                	jne    800c05 <memfind+0x10>
			break;
	return (void *) s;
}
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1e:	eb 03                	jmp    800c23 <strtol+0x11>
		s++;
  800c20:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c23:	0f b6 02             	movzbl (%edx),%eax
  800c26:	3c 20                	cmp    $0x20,%al
  800c28:	74 f6                	je     800c20 <strtol+0xe>
  800c2a:	3c 09                	cmp    $0x9,%al
  800c2c:	74 f2                	je     800c20 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c2e:	3c 2b                	cmp    $0x2b,%al
  800c30:	74 2a                	je     800c5c <strtol+0x4a>
	int neg = 0;
  800c32:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c37:	3c 2d                	cmp    $0x2d,%al
  800c39:	74 2b                	je     800c66 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c3b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c41:	75 0f                	jne    800c52 <strtol+0x40>
  800c43:	80 3a 30             	cmpb   $0x30,(%edx)
  800c46:	74 28                	je     800c70 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c48:	85 db                	test   %ebx,%ebx
  800c4a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c4f:	0f 44 d8             	cmove  %eax,%ebx
  800c52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c57:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c5a:	eb 46                	jmp    800ca2 <strtol+0x90>
		s++;
  800c5c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c5f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c64:	eb d5                	jmp    800c3b <strtol+0x29>
		s++, neg = 1;
  800c66:	83 c2 01             	add    $0x1,%edx
  800c69:	bf 01 00 00 00       	mov    $0x1,%edi
  800c6e:	eb cb                	jmp    800c3b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c70:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c74:	74 0e                	je     800c84 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800c76:	85 db                	test   %ebx,%ebx
  800c78:	75 d8                	jne    800c52 <strtol+0x40>
		s++, base = 8;
  800c7a:	83 c2 01             	add    $0x1,%edx
  800c7d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c82:	eb ce                	jmp    800c52 <strtol+0x40>
		s += 2, base = 16;
  800c84:	83 c2 02             	add    $0x2,%edx
  800c87:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c8c:	eb c4                	jmp    800c52 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c8e:	0f be c0             	movsbl %al,%eax
  800c91:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c94:	3b 45 10             	cmp    0x10(%ebp),%eax
  800c97:	7d 3a                	jge    800cd3 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c99:	83 c2 01             	add    $0x1,%edx
  800c9c:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ca0:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ca2:	0f b6 02             	movzbl (%edx),%eax
  800ca5:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ca8:	89 f3                	mov    %esi,%ebx
  800caa:	80 fb 09             	cmp    $0x9,%bl
  800cad:	76 df                	jbe    800c8e <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800caf:	8d 70 9f             	lea    -0x61(%eax),%esi
  800cb2:	89 f3                	mov    %esi,%ebx
  800cb4:	80 fb 19             	cmp    $0x19,%bl
  800cb7:	77 08                	ja     800cc1 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800cb9:	0f be c0             	movsbl %al,%eax
  800cbc:	83 e8 57             	sub    $0x57,%eax
  800cbf:	eb d3                	jmp    800c94 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800cc1:	8d 70 bf             	lea    -0x41(%eax),%esi
  800cc4:	89 f3                	mov    %esi,%ebx
  800cc6:	80 fb 19             	cmp    $0x19,%bl
  800cc9:	77 08                	ja     800cd3 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ccb:	0f be c0             	movsbl %al,%eax
  800cce:	83 e8 37             	sub    $0x37,%eax
  800cd1:	eb c1                	jmp    800c94 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800cd3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cd7:	74 05                	je     800cde <strtol+0xcc>
		*endptr = (char *) s;
  800cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cdc:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800cde:	89 c8                	mov    %ecx,%eax
  800ce0:	f7 d8                	neg    %eax
  800ce2:	85 ff                	test   %edi,%edi
  800ce4:	0f 45 c8             	cmovne %eax,%ecx
}
  800ce7:	89 c8                	mov    %ecx,%eax
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    
  800cee:	66 90                	xchg   %ax,%ax

00800cf0 <__udivdi3>:
  800cf0:	f3 0f 1e fb          	endbr32 
  800cf4:	55                   	push   %ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
  800cf8:	83 ec 1c             	sub    $0x1c,%esp
  800cfb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800cff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d03:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d07:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	75 19                	jne    800d28 <__udivdi3+0x38>
  800d0f:	39 f3                	cmp    %esi,%ebx
  800d11:	76 4d                	jbe    800d60 <__udivdi3+0x70>
  800d13:	31 ff                	xor    %edi,%edi
  800d15:	89 e8                	mov    %ebp,%eax
  800d17:	89 f2                	mov    %esi,%edx
  800d19:	f7 f3                	div    %ebx
  800d1b:	89 fa                	mov    %edi,%edx
  800d1d:	83 c4 1c             	add    $0x1c,%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    
  800d25:	8d 76 00             	lea    0x0(%esi),%esi
  800d28:	39 f0                	cmp    %esi,%eax
  800d2a:	76 14                	jbe    800d40 <__udivdi3+0x50>
  800d2c:	31 ff                	xor    %edi,%edi
  800d2e:	31 c0                	xor    %eax,%eax
  800d30:	89 fa                	mov    %edi,%edx
  800d32:	83 c4 1c             	add    $0x1c,%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    
  800d3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d40:	0f bd f8             	bsr    %eax,%edi
  800d43:	83 f7 1f             	xor    $0x1f,%edi
  800d46:	75 48                	jne    800d90 <__udivdi3+0xa0>
  800d48:	39 f0                	cmp    %esi,%eax
  800d4a:	72 06                	jb     800d52 <__udivdi3+0x62>
  800d4c:	31 c0                	xor    %eax,%eax
  800d4e:	39 eb                	cmp    %ebp,%ebx
  800d50:	77 de                	ja     800d30 <__udivdi3+0x40>
  800d52:	b8 01 00 00 00       	mov    $0x1,%eax
  800d57:	eb d7                	jmp    800d30 <__udivdi3+0x40>
  800d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d60:	89 d9                	mov    %ebx,%ecx
  800d62:	85 db                	test   %ebx,%ebx
  800d64:	75 0b                	jne    800d71 <__udivdi3+0x81>
  800d66:	b8 01 00 00 00       	mov    $0x1,%eax
  800d6b:	31 d2                	xor    %edx,%edx
  800d6d:	f7 f3                	div    %ebx
  800d6f:	89 c1                	mov    %eax,%ecx
  800d71:	31 d2                	xor    %edx,%edx
  800d73:	89 f0                	mov    %esi,%eax
  800d75:	f7 f1                	div    %ecx
  800d77:	89 c6                	mov    %eax,%esi
  800d79:	89 e8                	mov    %ebp,%eax
  800d7b:	89 f7                	mov    %esi,%edi
  800d7d:	f7 f1                	div    %ecx
  800d7f:	89 fa                	mov    %edi,%edx
  800d81:	83 c4 1c             	add    $0x1c,%esp
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    
  800d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d90:	89 f9                	mov    %edi,%ecx
  800d92:	ba 20 00 00 00       	mov    $0x20,%edx
  800d97:	29 fa                	sub    %edi,%edx
  800d99:	d3 e0                	shl    %cl,%eax
  800d9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d9f:	89 d1                	mov    %edx,%ecx
  800da1:	89 d8                	mov    %ebx,%eax
  800da3:	d3 e8                	shr    %cl,%eax
  800da5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800da9:	09 c1                	or     %eax,%ecx
  800dab:	89 f0                	mov    %esi,%eax
  800dad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800db1:	89 f9                	mov    %edi,%ecx
  800db3:	d3 e3                	shl    %cl,%ebx
  800db5:	89 d1                	mov    %edx,%ecx
  800db7:	d3 e8                	shr    %cl,%eax
  800db9:	89 f9                	mov    %edi,%ecx
  800dbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800dbf:	89 eb                	mov    %ebp,%ebx
  800dc1:	d3 e6                	shl    %cl,%esi
  800dc3:	89 d1                	mov    %edx,%ecx
  800dc5:	d3 eb                	shr    %cl,%ebx
  800dc7:	09 f3                	or     %esi,%ebx
  800dc9:	89 c6                	mov    %eax,%esi
  800dcb:	89 f2                	mov    %esi,%edx
  800dcd:	89 d8                	mov    %ebx,%eax
  800dcf:	f7 74 24 08          	divl   0x8(%esp)
  800dd3:	89 d6                	mov    %edx,%esi
  800dd5:	89 c3                	mov    %eax,%ebx
  800dd7:	f7 64 24 0c          	mull   0xc(%esp)
  800ddb:	39 d6                	cmp    %edx,%esi
  800ddd:	72 19                	jb     800df8 <__udivdi3+0x108>
  800ddf:	89 f9                	mov    %edi,%ecx
  800de1:	d3 e5                	shl    %cl,%ebp
  800de3:	39 c5                	cmp    %eax,%ebp
  800de5:	73 04                	jae    800deb <__udivdi3+0xfb>
  800de7:	39 d6                	cmp    %edx,%esi
  800de9:	74 0d                	je     800df8 <__udivdi3+0x108>
  800deb:	89 d8                	mov    %ebx,%eax
  800ded:	31 ff                	xor    %edi,%edi
  800def:	e9 3c ff ff ff       	jmp    800d30 <__udivdi3+0x40>
  800df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800df8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800dfb:	31 ff                	xor    %edi,%edi
  800dfd:	e9 2e ff ff ff       	jmp    800d30 <__udivdi3+0x40>
  800e02:	66 90                	xchg   %ax,%ax
  800e04:	66 90                	xchg   %ax,%ax
  800e06:	66 90                	xchg   %ax,%ax
  800e08:	66 90                	xchg   %ax,%ax
  800e0a:	66 90                	xchg   %ax,%ax
  800e0c:	66 90                	xchg   %ax,%ax
  800e0e:	66 90                	xchg   %ax,%ax

00800e10 <__umoddi3>:
  800e10:	f3 0f 1e fb          	endbr32 
  800e14:	55                   	push   %ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	83 ec 1c             	sub    $0x1c,%esp
  800e1b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e1f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e23:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800e27:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800e2b:	89 f0                	mov    %esi,%eax
  800e2d:	89 da                	mov    %ebx,%edx
  800e2f:	85 ff                	test   %edi,%edi
  800e31:	75 15                	jne    800e48 <__umoddi3+0x38>
  800e33:	39 dd                	cmp    %ebx,%ebp
  800e35:	76 39                	jbe    800e70 <__umoddi3+0x60>
  800e37:	f7 f5                	div    %ebp
  800e39:	89 d0                	mov    %edx,%eax
  800e3b:	31 d2                	xor    %edx,%edx
  800e3d:	83 c4 1c             	add    $0x1c,%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    
  800e45:	8d 76 00             	lea    0x0(%esi),%esi
  800e48:	39 df                	cmp    %ebx,%edi
  800e4a:	77 f1                	ja     800e3d <__umoddi3+0x2d>
  800e4c:	0f bd cf             	bsr    %edi,%ecx
  800e4f:	83 f1 1f             	xor    $0x1f,%ecx
  800e52:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e56:	75 40                	jne    800e98 <__umoddi3+0x88>
  800e58:	39 df                	cmp    %ebx,%edi
  800e5a:	72 04                	jb     800e60 <__umoddi3+0x50>
  800e5c:	39 f5                	cmp    %esi,%ebp
  800e5e:	77 dd                	ja     800e3d <__umoddi3+0x2d>
  800e60:	89 da                	mov    %ebx,%edx
  800e62:	89 f0                	mov    %esi,%eax
  800e64:	29 e8                	sub    %ebp,%eax
  800e66:	19 fa                	sbb    %edi,%edx
  800e68:	eb d3                	jmp    800e3d <__umoddi3+0x2d>
  800e6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e70:	89 e9                	mov    %ebp,%ecx
  800e72:	85 ed                	test   %ebp,%ebp
  800e74:	75 0b                	jne    800e81 <__umoddi3+0x71>
  800e76:	b8 01 00 00 00       	mov    $0x1,%eax
  800e7b:	31 d2                	xor    %edx,%edx
  800e7d:	f7 f5                	div    %ebp
  800e7f:	89 c1                	mov    %eax,%ecx
  800e81:	89 d8                	mov    %ebx,%eax
  800e83:	31 d2                	xor    %edx,%edx
  800e85:	f7 f1                	div    %ecx
  800e87:	89 f0                	mov    %esi,%eax
  800e89:	f7 f1                	div    %ecx
  800e8b:	89 d0                	mov    %edx,%eax
  800e8d:	31 d2                	xor    %edx,%edx
  800e8f:	eb ac                	jmp    800e3d <__umoddi3+0x2d>
  800e91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e98:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e9c:	ba 20 00 00 00       	mov    $0x20,%edx
  800ea1:	29 c2                	sub    %eax,%edx
  800ea3:	89 c1                	mov    %eax,%ecx
  800ea5:	89 e8                	mov    %ebp,%eax
  800ea7:	d3 e7                	shl    %cl,%edi
  800ea9:	89 d1                	mov    %edx,%ecx
  800eab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800eaf:	d3 e8                	shr    %cl,%eax
  800eb1:	89 c1                	mov    %eax,%ecx
  800eb3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800eb7:	09 f9                	or     %edi,%ecx
  800eb9:	89 df                	mov    %ebx,%edi
  800ebb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ebf:	89 c1                	mov    %eax,%ecx
  800ec1:	d3 e5                	shl    %cl,%ebp
  800ec3:	89 d1                	mov    %edx,%ecx
  800ec5:	d3 ef                	shr    %cl,%edi
  800ec7:	89 c1                	mov    %eax,%ecx
  800ec9:	89 f0                	mov    %esi,%eax
  800ecb:	d3 e3                	shl    %cl,%ebx
  800ecd:	89 d1                	mov    %edx,%ecx
  800ecf:	89 fa                	mov    %edi,%edx
  800ed1:	d3 e8                	shr    %cl,%eax
  800ed3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ed8:	09 d8                	or     %ebx,%eax
  800eda:	f7 74 24 08          	divl   0x8(%esp)
  800ede:	89 d3                	mov    %edx,%ebx
  800ee0:	d3 e6                	shl    %cl,%esi
  800ee2:	f7 e5                	mul    %ebp
  800ee4:	89 c7                	mov    %eax,%edi
  800ee6:	89 d1                	mov    %edx,%ecx
  800ee8:	39 d3                	cmp    %edx,%ebx
  800eea:	72 06                	jb     800ef2 <__umoddi3+0xe2>
  800eec:	75 0e                	jne    800efc <__umoddi3+0xec>
  800eee:	39 c6                	cmp    %eax,%esi
  800ef0:	73 0a                	jae    800efc <__umoddi3+0xec>
  800ef2:	29 e8                	sub    %ebp,%eax
  800ef4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800ef8:	89 d1                	mov    %edx,%ecx
  800efa:	89 c7                	mov    %eax,%edi
  800efc:	89 f5                	mov    %esi,%ebp
  800efe:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f02:	29 fd                	sub    %edi,%ebp
  800f04:	19 cb                	sbb    %ecx,%ebx
  800f06:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f0b:	89 d8                	mov    %ebx,%eax
  800f0d:	d3 e0                	shl    %cl,%eax
  800f0f:	89 f1                	mov    %esi,%ecx
  800f11:	d3 ed                	shr    %cl,%ebp
  800f13:	d3 eb                	shr    %cl,%ebx
  800f15:	09 e8                	or     %ebp,%eax
  800f17:	89 da                	mov    %ebx,%edx
  800f19:	83 c4 1c             	add    $0x1c,%esp
  800f1c:	5b                   	pop    %ebx
  800f1d:	5e                   	pop    %esi
  800f1e:	5f                   	pop    %edi
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    
