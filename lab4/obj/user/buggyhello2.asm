
obj/user/buggyhello2：     文件格式 elf32-i386


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
  80003e:	ff 35 00 20 80 00    	push   0x802000
  800044:	e8 5d 00 00 00       	call   8000a6 <sys_cputs>
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
  800059:	e8 c6 00 00 00       	call   800124 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 42 00 00 00       	call   8000e3 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b7:	89 c3                	mov    %eax,%ebx
  8000b9:	89 c7                	mov    %eax,%edi
  8000bb:	89 c6                	mov    %eax,%esi
  8000bd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bf:	5b                   	pop    %ebx
  8000c0:	5e                   	pop    %esi
  8000c1:	5f                   	pop    %edi
  8000c2:	5d                   	pop    %ebp
  8000c3:	c3                   	ret    

008000c4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d4:	89 d1                	mov    %edx,%ecx
  8000d6:	89 d3                	mov    %edx,%ebx
  8000d8:	89 d7                	mov    %edx,%edi
  8000da:	89 d6                	mov    %edx,%esi
  8000dc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f9:	89 cb                	mov    %ecx,%ebx
  8000fb:	89 cf                	mov    %ecx,%edi
  8000fd:	89 ce                	mov    %ecx,%esi
  8000ff:	cd 30                	int    $0x30
	if(check && ret > 0)
  800101:	85 c0                	test   %eax,%eax
  800103:	7f 08                	jg     80010d <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 78 0f 80 00       	push   $0x800f78
  800118:	6a 2a                	push   $0x2a
  80011a:	68 95 0f 80 00       	push   $0x800f95
  80011f:	e8 ed 01 00 00       	call   800311 <_panic>

00800124 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	57                   	push   %edi
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012a:	ba 00 00 00 00       	mov    $0x0,%edx
  80012f:	b8 02 00 00 00       	mov    $0x2,%eax
  800134:	89 d1                	mov    %edx,%ecx
  800136:	89 d3                	mov    %edx,%ebx
  800138:	89 d7                	mov    %edx,%edi
  80013a:	89 d6                	mov    %edx,%esi
  80013c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_yield>:

void
sys_yield(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
  800168:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80016b:	be 00 00 00 00       	mov    $0x0,%esi
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800176:	b8 04 00 00 00       	mov    $0x4,%eax
  80017b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017e:	89 f7                	mov    %esi,%edi
  800180:	cd 30                	int    $0x30
	if(check && ret > 0)
  800182:	85 c0                	test   %eax,%eax
  800184:	7f 08                	jg     80018e <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800186:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800189:	5b                   	pop    %ebx
  80018a:	5e                   	pop    %esi
  80018b:	5f                   	pop    %edi
  80018c:	5d                   	pop    %ebp
  80018d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	6a 04                	push   $0x4
  800194:	68 78 0f 80 00       	push   $0x800f78
  800199:	6a 2a                	push   $0x2a
  80019b:	68 95 0f 80 00       	push   $0x800f95
  8001a0:	e8 6c 01 00 00       	call   800311 <_panic>

008001a5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	57                   	push   %edi
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bf:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c4:	85 c0                	test   %eax,%eax
  8001c6:	7f 08                	jg     8001d0 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cb:	5b                   	pop    %ebx
  8001cc:	5e                   	pop    %esi
  8001cd:	5f                   	pop    %edi
  8001ce:	5d                   	pop    %ebp
  8001cf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	50                   	push   %eax
  8001d4:	6a 05                	push   $0x5
  8001d6:	68 78 0f 80 00       	push   $0x800f78
  8001db:	6a 2a                	push   $0x2a
  8001dd:	68 95 0f 80 00       	push   $0x800f95
  8001e2:	e8 2a 01 00 00       	call   800311 <_panic>

008001e7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	57                   	push   %edi
  8001eb:	56                   	push   %esi
  8001ec:	53                   	push   %ebx
  8001ed:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fb:	b8 06 00 00 00       	mov    $0x6,%eax
  800200:	89 df                	mov    %ebx,%edi
  800202:	89 de                	mov    %ebx,%esi
  800204:	cd 30                	int    $0x30
	if(check && ret > 0)
  800206:	85 c0                	test   %eax,%eax
  800208:	7f 08                	jg     800212 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020d:	5b                   	pop    %ebx
  80020e:	5e                   	pop    %esi
  80020f:	5f                   	pop    %edi
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	50                   	push   %eax
  800216:	6a 06                	push   $0x6
  800218:	68 78 0f 80 00       	push   $0x800f78
  80021d:	6a 2a                	push   $0x2a
  80021f:	68 95 0f 80 00       	push   $0x800f95
  800224:	e8 e8 00 00 00       	call   800311 <_panic>

00800229 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800232:	bb 00 00 00 00       	mov    $0x0,%ebx
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023d:	b8 08 00 00 00       	mov    $0x8,%eax
  800242:	89 df                	mov    %ebx,%edi
  800244:	89 de                	mov    %ebx,%esi
  800246:	cd 30                	int    $0x30
	if(check && ret > 0)
  800248:	85 c0                	test   %eax,%eax
  80024a:	7f 08                	jg     800254 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024f:	5b                   	pop    %ebx
  800250:	5e                   	pop    %esi
  800251:	5f                   	pop    %edi
  800252:	5d                   	pop    %ebp
  800253:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	50                   	push   %eax
  800258:	6a 08                	push   $0x8
  80025a:	68 78 0f 80 00       	push   $0x800f78
  80025f:	6a 2a                	push   $0x2a
  800261:	68 95 0f 80 00       	push   $0x800f95
  800266:	e8 a6 00 00 00       	call   800311 <_panic>

0080026b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	57                   	push   %edi
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800274:	bb 00 00 00 00       	mov    $0x0,%ebx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027f:	b8 09 00 00 00       	mov    $0x9,%eax
  800284:	89 df                	mov    %ebx,%edi
  800286:	89 de                	mov    %ebx,%esi
  800288:	cd 30                	int    $0x30
	if(check && ret > 0)
  80028a:	85 c0                	test   %eax,%eax
  80028c:	7f 08                	jg     800296 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80028e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800291:	5b                   	pop    %ebx
  800292:	5e                   	pop    %esi
  800293:	5f                   	pop    %edi
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	50                   	push   %eax
  80029a:	6a 09                	push   $0x9
  80029c:	68 78 0f 80 00       	push   $0x800f78
  8002a1:	6a 2a                	push   $0x2a
  8002a3:	68 95 0f 80 00       	push   $0x800f95
  8002a8:	e8 64 00 00 00       	call   800311 <_panic>

008002ad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	57                   	push   %edi
  8002b1:	56                   	push   %esi
  8002b2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002be:	be 00 00 00 00       	mov    $0x0,%esi
  8002c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c9:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002cb:	5b                   	pop    %ebx
  8002cc:	5e                   	pop    %esi
  8002cd:	5f                   	pop    %edi
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002de:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e6:	89 cb                	mov    %ecx,%ebx
  8002e8:	89 cf                	mov    %ecx,%edi
  8002ea:	89 ce                	mov    %ecx,%esi
  8002ec:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002ee:	85 c0                	test   %eax,%eax
  8002f0:	7f 08                	jg     8002fa <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f5:	5b                   	pop    %ebx
  8002f6:	5e                   	pop    %esi
  8002f7:	5f                   	pop    %edi
  8002f8:	5d                   	pop    %ebp
  8002f9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	50                   	push   %eax
  8002fe:	6a 0c                	push   $0xc
  800300:	68 78 0f 80 00       	push   $0x800f78
  800305:	6a 2a                	push   $0x2a
  800307:	68 95 0f 80 00       	push   $0x800f95
  80030c:	e8 00 00 00 00       	call   800311 <_panic>

00800311 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800316:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800319:	8b 35 04 20 80 00    	mov    0x802004,%esi
  80031f:	e8 00 fe ff ff       	call   800124 <sys_getenvid>
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	ff 75 0c             	push   0xc(%ebp)
  80032a:	ff 75 08             	push   0x8(%ebp)
  80032d:	56                   	push   %esi
  80032e:	50                   	push   %eax
  80032f:	68 a4 0f 80 00       	push   $0x800fa4
  800334:	e8 b3 00 00 00       	call   8003ec <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800339:	83 c4 18             	add    $0x18,%esp
  80033c:	53                   	push   %ebx
  80033d:	ff 75 10             	push   0x10(%ebp)
  800340:	e8 56 00 00 00       	call   80039b <vcprintf>
	cprintf("\n");
  800345:	c7 04 24 6c 0f 80 00 	movl   $0x800f6c,(%esp)
  80034c:	e8 9b 00 00 00       	call   8003ec <cprintf>
  800351:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800354:	cc                   	int3   
  800355:	eb fd                	jmp    800354 <_panic+0x43>

00800357 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	53                   	push   %ebx
  80035b:	83 ec 04             	sub    $0x4,%esp
  80035e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800361:	8b 13                	mov    (%ebx),%edx
  800363:	8d 42 01             	lea    0x1(%edx),%eax
  800366:	89 03                	mov    %eax,(%ebx)
  800368:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80036f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800374:	74 09                	je     80037f <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800376:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80037a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80037d:	c9                   	leave  
  80037e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80037f:	83 ec 08             	sub    $0x8,%esp
  800382:	68 ff 00 00 00       	push   $0xff
  800387:	8d 43 08             	lea    0x8(%ebx),%eax
  80038a:	50                   	push   %eax
  80038b:	e8 16 fd ff ff       	call   8000a6 <sys_cputs>
		b->idx = 0;
  800390:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800396:	83 c4 10             	add    $0x10,%esp
  800399:	eb db                	jmp    800376 <putch+0x1f>

0080039b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003ab:	00 00 00 
	b.cnt = 0;
  8003ae:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b8:	ff 75 0c             	push   0xc(%ebp)
  8003bb:	ff 75 08             	push   0x8(%ebp)
  8003be:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c4:	50                   	push   %eax
  8003c5:	68 57 03 80 00       	push   $0x800357
  8003ca:	e8 14 01 00 00       	call   8004e3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003cf:	83 c4 08             	add    $0x8,%esp
  8003d2:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003d8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	e8 c2 fc ff ff       	call   8000a6 <sys_cputs>

	return b.cnt;
}
  8003e4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ea:	c9                   	leave  
  8003eb:	c3                   	ret    

008003ec <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f5:	50                   	push   %eax
  8003f6:	ff 75 08             	push   0x8(%ebp)
  8003f9:	e8 9d ff ff ff       	call   80039b <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fe:	c9                   	leave  
  8003ff:	c3                   	ret    

00800400 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	57                   	push   %edi
  800404:	56                   	push   %esi
  800405:	53                   	push   %ebx
  800406:	83 ec 1c             	sub    $0x1c,%esp
  800409:	89 c7                	mov    %eax,%edi
  80040b:	89 d6                	mov    %edx,%esi
  80040d:	8b 45 08             	mov    0x8(%ebp),%eax
  800410:	8b 55 0c             	mov    0xc(%ebp),%edx
  800413:	89 d1                	mov    %edx,%ecx
  800415:	89 c2                	mov    %eax,%edx
  800417:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80041d:	8b 45 10             	mov    0x10(%ebp),%eax
  800420:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800423:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800426:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80042d:	39 c2                	cmp    %eax,%edx
  80042f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800432:	72 3e                	jb     800472 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800434:	83 ec 0c             	sub    $0xc,%esp
  800437:	ff 75 18             	push   0x18(%ebp)
  80043a:	83 eb 01             	sub    $0x1,%ebx
  80043d:	53                   	push   %ebx
  80043e:	50                   	push   %eax
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	ff 75 e4             	push   -0x1c(%ebp)
  800445:	ff 75 e0             	push   -0x20(%ebp)
  800448:	ff 75 dc             	push   -0x24(%ebp)
  80044b:	ff 75 d8             	push   -0x28(%ebp)
  80044e:	e8 bd 08 00 00       	call   800d10 <__udivdi3>
  800453:	83 c4 18             	add    $0x18,%esp
  800456:	52                   	push   %edx
  800457:	50                   	push   %eax
  800458:	89 f2                	mov    %esi,%edx
  80045a:	89 f8                	mov    %edi,%eax
  80045c:	e8 9f ff ff ff       	call   800400 <printnum>
  800461:	83 c4 20             	add    $0x20,%esp
  800464:	eb 13                	jmp    800479 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	56                   	push   %esi
  80046a:	ff 75 18             	push   0x18(%ebp)
  80046d:	ff d7                	call   *%edi
  80046f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800472:	83 eb 01             	sub    $0x1,%ebx
  800475:	85 db                	test   %ebx,%ebx
  800477:	7f ed                	jg     800466 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	56                   	push   %esi
  80047d:	83 ec 04             	sub    $0x4,%esp
  800480:	ff 75 e4             	push   -0x1c(%ebp)
  800483:	ff 75 e0             	push   -0x20(%ebp)
  800486:	ff 75 dc             	push   -0x24(%ebp)
  800489:	ff 75 d8             	push   -0x28(%ebp)
  80048c:	e8 9f 09 00 00       	call   800e30 <__umoddi3>
  800491:	83 c4 14             	add    $0x14,%esp
  800494:	0f be 80 c7 0f 80 00 	movsbl 0x800fc7(%eax),%eax
  80049b:	50                   	push   %eax
  80049c:	ff d7                	call   *%edi
}
  80049e:	83 c4 10             	add    $0x10,%esp
  8004a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a4:	5b                   	pop    %ebx
  8004a5:	5e                   	pop    %esi
  8004a6:	5f                   	pop    %edi
  8004a7:	5d                   	pop    %ebp
  8004a8:	c3                   	ret    

008004a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a9:	55                   	push   %ebp
  8004aa:	89 e5                	mov    %esp,%ebp
  8004ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004b3:	8b 10                	mov    (%eax),%edx
  8004b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b8:	73 0a                	jae    8004c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004bd:	89 08                	mov    %ecx,(%eax)
  8004bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c2:	88 02                	mov    %al,(%edx)
}
  8004c4:	5d                   	pop    %ebp
  8004c5:	c3                   	ret    

008004c6 <printfmt>:
{
  8004c6:	55                   	push   %ebp
  8004c7:	89 e5                	mov    %esp,%ebp
  8004c9:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004cf:	50                   	push   %eax
  8004d0:	ff 75 10             	push   0x10(%ebp)
  8004d3:	ff 75 0c             	push   0xc(%ebp)
  8004d6:	ff 75 08             	push   0x8(%ebp)
  8004d9:	e8 05 00 00 00       	call   8004e3 <vprintfmt>
}
  8004de:	83 c4 10             	add    $0x10,%esp
  8004e1:	c9                   	leave  
  8004e2:	c3                   	ret    

008004e3 <vprintfmt>:
{
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
  8004e6:	57                   	push   %edi
  8004e7:	56                   	push   %esi
  8004e8:	53                   	push   %ebx
  8004e9:	83 ec 3c             	sub    $0x3c,%esp
  8004ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004f5:	eb 0a                	jmp    800501 <vprintfmt+0x1e>
			putch(ch, putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	50                   	push   %eax
  8004fc:	ff d6                	call   *%esi
  8004fe:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800501:	83 c7 01             	add    $0x1,%edi
  800504:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800508:	83 f8 25             	cmp    $0x25,%eax
  80050b:	74 0c                	je     800519 <vprintfmt+0x36>
			if (ch == '\0')
  80050d:	85 c0                	test   %eax,%eax
  80050f:	75 e6                	jne    8004f7 <vprintfmt+0x14>
}
  800511:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800514:	5b                   	pop    %ebx
  800515:	5e                   	pop    %esi
  800516:	5f                   	pop    %edi
  800517:	5d                   	pop    %ebp
  800518:	c3                   	ret    
		padc = ' ';
  800519:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80051d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800524:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80052b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800532:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800537:	8d 47 01             	lea    0x1(%edi),%eax
  80053a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80053d:	0f b6 17             	movzbl (%edi),%edx
  800540:	8d 42 dd             	lea    -0x23(%edx),%eax
  800543:	3c 55                	cmp    $0x55,%al
  800545:	0f 87 bb 03 00 00    	ja     800906 <vprintfmt+0x423>
  80054b:	0f b6 c0             	movzbl %al,%eax
  80054e:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)
  800555:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800558:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80055c:	eb d9                	jmp    800537 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80055e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800561:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800565:	eb d0                	jmp    800537 <vprintfmt+0x54>
  800567:	0f b6 d2             	movzbl %dl,%edx
  80056a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80056d:	b8 00 00 00 00       	mov    $0x0,%eax
  800572:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800575:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800578:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80057c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80057f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800582:	83 f9 09             	cmp    $0x9,%ecx
  800585:	77 55                	ja     8005dc <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800587:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80058a:	eb e9                	jmp    800575 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 40 04             	lea    0x4(%eax),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80059d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005a0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a4:	79 91                	jns    800537 <vprintfmt+0x54>
				width = precision, precision = -1;
  8005a6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ac:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005b3:	eb 82                	jmp    800537 <vprintfmt+0x54>
  8005b5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005b8:	85 d2                	test   %edx,%edx
  8005ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8005bf:	0f 49 c2             	cmovns %edx,%eax
  8005c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005c8:	e9 6a ff ff ff       	jmp    800537 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005d0:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005d7:	e9 5b ff ff ff       	jmp    800537 <vprintfmt+0x54>
  8005dc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e2:	eb bc                	jmp    8005a0 <vprintfmt+0xbd>
			lflag++;
  8005e4:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005ea:	e9 48 ff ff ff       	jmp    800537 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 78 04             	lea    0x4(%eax),%edi
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	53                   	push   %ebx
  8005f9:	ff 30                	push   (%eax)
  8005fb:	ff d6                	call   *%esi
			break;
  8005fd:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800600:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800603:	e9 9d 02 00 00       	jmp    8008a5 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 78 04             	lea    0x4(%eax),%edi
  80060e:	8b 10                	mov    (%eax),%edx
  800610:	89 d0                	mov    %edx,%eax
  800612:	f7 d8                	neg    %eax
  800614:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800617:	83 f8 08             	cmp    $0x8,%eax
  80061a:	7f 23                	jg     80063f <vprintfmt+0x15c>
  80061c:	8b 14 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edx
  800623:	85 d2                	test   %edx,%edx
  800625:	74 18                	je     80063f <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800627:	52                   	push   %edx
  800628:	68 e8 0f 80 00       	push   $0x800fe8
  80062d:	53                   	push   %ebx
  80062e:	56                   	push   %esi
  80062f:	e8 92 fe ff ff       	call   8004c6 <printfmt>
  800634:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800637:	89 7d 14             	mov    %edi,0x14(%ebp)
  80063a:	e9 66 02 00 00       	jmp    8008a5 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80063f:	50                   	push   %eax
  800640:	68 df 0f 80 00       	push   $0x800fdf
  800645:	53                   	push   %ebx
  800646:	56                   	push   %esi
  800647:	e8 7a fe ff ff       	call   8004c6 <printfmt>
  80064c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80064f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800652:	e9 4e 02 00 00       	jmp    8008a5 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	83 c0 04             	add    $0x4,%eax
  80065d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800665:	85 d2                	test   %edx,%edx
  800667:	b8 d8 0f 80 00       	mov    $0x800fd8,%eax
  80066c:	0f 45 c2             	cmovne %edx,%eax
  80066f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800672:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800676:	7e 06                	jle    80067e <vprintfmt+0x19b>
  800678:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80067c:	75 0d                	jne    80068b <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80067e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800681:	89 c7                	mov    %eax,%edi
  800683:	03 45 e0             	add    -0x20(%ebp),%eax
  800686:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800689:	eb 55                	jmp    8006e0 <vprintfmt+0x1fd>
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	ff 75 d8             	push   -0x28(%ebp)
  800691:	ff 75 cc             	push   -0x34(%ebp)
  800694:	e8 0a 03 00 00       	call   8009a3 <strnlen>
  800699:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80069c:	29 c1                	sub    %eax,%ecx
  80069e:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8006a1:	83 c4 10             	add    $0x10,%esp
  8006a4:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8006a6:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ad:	eb 0f                	jmp    8006be <vprintfmt+0x1db>
					putch(padc, putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	ff 75 e0             	push   -0x20(%ebp)
  8006b6:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b8:	83 ef 01             	sub    $0x1,%edi
  8006bb:	83 c4 10             	add    $0x10,%esp
  8006be:	85 ff                	test   %edi,%edi
  8006c0:	7f ed                	jg     8006af <vprintfmt+0x1cc>
  8006c2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006c5:	85 d2                	test   %edx,%edx
  8006c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006cc:	0f 49 c2             	cmovns %edx,%eax
  8006cf:	29 c2                	sub    %eax,%edx
  8006d1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006d4:	eb a8                	jmp    80067e <vprintfmt+0x19b>
					putch(ch, putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	53                   	push   %ebx
  8006da:	52                   	push   %edx
  8006db:	ff d6                	call   *%esi
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006e3:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e5:	83 c7 01             	add    $0x1,%edi
  8006e8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ec:	0f be d0             	movsbl %al,%edx
  8006ef:	85 d2                	test   %edx,%edx
  8006f1:	74 4b                	je     80073e <vprintfmt+0x25b>
  8006f3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006f7:	78 06                	js     8006ff <vprintfmt+0x21c>
  8006f9:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8006fd:	78 1e                	js     80071d <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8006ff:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800703:	74 d1                	je     8006d6 <vprintfmt+0x1f3>
  800705:	0f be c0             	movsbl %al,%eax
  800708:	83 e8 20             	sub    $0x20,%eax
  80070b:	83 f8 5e             	cmp    $0x5e,%eax
  80070e:	76 c6                	jbe    8006d6 <vprintfmt+0x1f3>
					putch('?', putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	6a 3f                	push   $0x3f
  800716:	ff d6                	call   *%esi
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	eb c3                	jmp    8006e0 <vprintfmt+0x1fd>
  80071d:	89 cf                	mov    %ecx,%edi
  80071f:	eb 0e                	jmp    80072f <vprintfmt+0x24c>
				putch(' ', putdat);
  800721:	83 ec 08             	sub    $0x8,%esp
  800724:	53                   	push   %ebx
  800725:	6a 20                	push   $0x20
  800727:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800729:	83 ef 01             	sub    $0x1,%edi
  80072c:	83 c4 10             	add    $0x10,%esp
  80072f:	85 ff                	test   %edi,%edi
  800731:	7f ee                	jg     800721 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800733:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800736:	89 45 14             	mov    %eax,0x14(%ebp)
  800739:	e9 67 01 00 00       	jmp    8008a5 <vprintfmt+0x3c2>
  80073e:	89 cf                	mov    %ecx,%edi
  800740:	eb ed                	jmp    80072f <vprintfmt+0x24c>
	if (lflag >= 2)
  800742:	83 f9 01             	cmp    $0x1,%ecx
  800745:	7f 1b                	jg     800762 <vprintfmt+0x27f>
	else if (lflag)
  800747:	85 c9                	test   %ecx,%ecx
  800749:	74 63                	je     8007ae <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8b 00                	mov    (%eax),%eax
  800750:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800753:	99                   	cltd   
  800754:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8d 40 04             	lea    0x4(%eax),%eax
  80075d:	89 45 14             	mov    %eax,0x14(%ebp)
  800760:	eb 17                	jmp    800779 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800762:	8b 45 14             	mov    0x14(%ebp),%eax
  800765:	8b 50 04             	mov    0x4(%eax),%edx
  800768:	8b 00                	mov    (%eax),%eax
  80076a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800770:	8b 45 14             	mov    0x14(%ebp),%eax
  800773:	8d 40 08             	lea    0x8(%eax),%eax
  800776:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800779:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80077c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80077f:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800784:	85 c9                	test   %ecx,%ecx
  800786:	0f 89 ff 00 00 00    	jns    80088b <vprintfmt+0x3a8>
				putch('-', putdat);
  80078c:	83 ec 08             	sub    $0x8,%esp
  80078f:	53                   	push   %ebx
  800790:	6a 2d                	push   $0x2d
  800792:	ff d6                	call   *%esi
				num = -(long long) num;
  800794:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800797:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80079a:	f7 da                	neg    %edx
  80079c:	83 d1 00             	adc    $0x0,%ecx
  80079f:	f7 d9                	neg    %ecx
  8007a1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007a4:	bf 0a 00 00 00       	mov    $0xa,%edi
  8007a9:	e9 dd 00 00 00       	jmp    80088b <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8b 00                	mov    (%eax),%eax
  8007b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b6:	99                   	cltd   
  8007b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bd:	8d 40 04             	lea    0x4(%eax),%eax
  8007c0:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c3:	eb b4                	jmp    800779 <vprintfmt+0x296>
	if (lflag >= 2)
  8007c5:	83 f9 01             	cmp    $0x1,%ecx
  8007c8:	7f 1e                	jg     8007e8 <vprintfmt+0x305>
	else if (lflag)
  8007ca:	85 c9                	test   %ecx,%ecx
  8007cc:	74 32                	je     800800 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8007ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d1:	8b 10                	mov    (%eax),%edx
  8007d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d8:	8d 40 04             	lea    0x4(%eax),%eax
  8007db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007de:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8007e3:	e9 a3 00 00 00       	jmp    80088b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8b 10                	mov    (%eax),%edx
  8007ed:	8b 48 04             	mov    0x4(%eax),%ecx
  8007f0:	8d 40 08             	lea    0x8(%eax),%eax
  8007f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007f6:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8007fb:	e9 8b 00 00 00       	jmp    80088b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800800:	8b 45 14             	mov    0x14(%ebp),%eax
  800803:	8b 10                	mov    (%eax),%edx
  800805:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080a:	8d 40 04             	lea    0x4(%eax),%eax
  80080d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800810:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800815:	eb 74                	jmp    80088b <vprintfmt+0x3a8>
	if (lflag >= 2)
  800817:	83 f9 01             	cmp    $0x1,%ecx
  80081a:	7f 1b                	jg     800837 <vprintfmt+0x354>
	else if (lflag)
  80081c:	85 c9                	test   %ecx,%ecx
  80081e:	74 2c                	je     80084c <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800820:	8b 45 14             	mov    0x14(%ebp),%eax
  800823:	8b 10                	mov    (%eax),%edx
  800825:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082a:	8d 40 04             	lea    0x4(%eax),%eax
  80082d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800830:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800835:	eb 54                	jmp    80088b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800837:	8b 45 14             	mov    0x14(%ebp),%eax
  80083a:	8b 10                	mov    (%eax),%edx
  80083c:	8b 48 04             	mov    0x4(%eax),%ecx
  80083f:	8d 40 08             	lea    0x8(%eax),%eax
  800842:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800845:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80084a:	eb 3f                	jmp    80088b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8b 10                	mov    (%eax),%edx
  800851:	b9 00 00 00 00       	mov    $0x0,%ecx
  800856:	8d 40 04             	lea    0x4(%eax),%eax
  800859:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80085c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800861:	eb 28                	jmp    80088b <vprintfmt+0x3a8>
			putch('0', putdat);
  800863:	83 ec 08             	sub    $0x8,%esp
  800866:	53                   	push   %ebx
  800867:	6a 30                	push   $0x30
  800869:	ff d6                	call   *%esi
			putch('x', putdat);
  80086b:	83 c4 08             	add    $0x8,%esp
  80086e:	53                   	push   %ebx
  80086f:	6a 78                	push   $0x78
  800871:	ff d6                	call   *%esi
			num = (unsigned long long)
  800873:	8b 45 14             	mov    0x14(%ebp),%eax
  800876:	8b 10                	mov    (%eax),%edx
  800878:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80087d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800880:	8d 40 04             	lea    0x4(%eax),%eax
  800883:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800886:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80088b:	83 ec 0c             	sub    $0xc,%esp
  80088e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800892:	50                   	push   %eax
  800893:	ff 75 e0             	push   -0x20(%ebp)
  800896:	57                   	push   %edi
  800897:	51                   	push   %ecx
  800898:	52                   	push   %edx
  800899:	89 da                	mov    %ebx,%edx
  80089b:	89 f0                	mov    %esi,%eax
  80089d:	e8 5e fb ff ff       	call   800400 <printnum>
			break;
  8008a2:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008a8:	e9 54 fc ff ff       	jmp    800501 <vprintfmt+0x1e>
	if (lflag >= 2)
  8008ad:	83 f9 01             	cmp    $0x1,%ecx
  8008b0:	7f 1b                	jg     8008cd <vprintfmt+0x3ea>
	else if (lflag)
  8008b2:	85 c9                	test   %ecx,%ecx
  8008b4:	74 2c                	je     8008e2 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8008b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b9:	8b 10                	mov    (%eax),%edx
  8008bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c0:	8d 40 04             	lea    0x4(%eax),%eax
  8008c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008c6:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8008cb:	eb be                	jmp    80088b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8008cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d0:	8b 10                	mov    (%eax),%edx
  8008d2:	8b 48 04             	mov    0x4(%eax),%ecx
  8008d5:	8d 40 08             	lea    0x8(%eax),%eax
  8008d8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008db:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8008e0:	eb a9                	jmp    80088b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8008e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e5:	8b 10                	mov    (%eax),%edx
  8008e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ec:	8d 40 04             	lea    0x4(%eax),%eax
  8008ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008f2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8008f7:	eb 92                	jmp    80088b <vprintfmt+0x3a8>
			putch(ch, putdat);
  8008f9:	83 ec 08             	sub    $0x8,%esp
  8008fc:	53                   	push   %ebx
  8008fd:	6a 25                	push   $0x25
  8008ff:	ff d6                	call   *%esi
			break;
  800901:	83 c4 10             	add    $0x10,%esp
  800904:	eb 9f                	jmp    8008a5 <vprintfmt+0x3c2>
			putch('%', putdat);
  800906:	83 ec 08             	sub    $0x8,%esp
  800909:	53                   	push   %ebx
  80090a:	6a 25                	push   $0x25
  80090c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80090e:	83 c4 10             	add    $0x10,%esp
  800911:	89 f8                	mov    %edi,%eax
  800913:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800917:	74 05                	je     80091e <vprintfmt+0x43b>
  800919:	83 e8 01             	sub    $0x1,%eax
  80091c:	eb f5                	jmp    800913 <vprintfmt+0x430>
  80091e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800921:	eb 82                	jmp    8008a5 <vprintfmt+0x3c2>

00800923 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	83 ec 18             	sub    $0x18,%esp
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80092f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800932:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800936:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800939:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800940:	85 c0                	test   %eax,%eax
  800942:	74 26                	je     80096a <vsnprintf+0x47>
  800944:	85 d2                	test   %edx,%edx
  800946:	7e 22                	jle    80096a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800948:	ff 75 14             	push   0x14(%ebp)
  80094b:	ff 75 10             	push   0x10(%ebp)
  80094e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800951:	50                   	push   %eax
  800952:	68 a9 04 80 00       	push   $0x8004a9
  800957:	e8 87 fb ff ff       	call   8004e3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80095c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80095f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800962:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800965:	83 c4 10             	add    $0x10,%esp
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    
		return -E_INVAL;
  80096a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80096f:	eb f7                	jmp    800968 <vsnprintf+0x45>

00800971 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800977:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80097a:	50                   	push   %eax
  80097b:	ff 75 10             	push   0x10(%ebp)
  80097e:	ff 75 0c             	push   0xc(%ebp)
  800981:	ff 75 08             	push   0x8(%ebp)
  800984:	e8 9a ff ff ff       	call   800923 <vsnprintf>
	va_end(ap);

	return rc;
}
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800991:	b8 00 00 00 00       	mov    $0x0,%eax
  800996:	eb 03                	jmp    80099b <strlen+0x10>
		n++;
  800998:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80099b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80099f:	75 f7                	jne    800998 <strlen+0xd>
	return n;
}
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a9:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b1:	eb 03                	jmp    8009b6 <strnlen+0x13>
		n++;
  8009b3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b6:	39 d0                	cmp    %edx,%eax
  8009b8:	74 08                	je     8009c2 <strnlen+0x1f>
  8009ba:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009be:	75 f3                	jne    8009b3 <strnlen+0x10>
  8009c0:	89 c2                	mov    %eax,%edx
	return n;
}
  8009c2:	89 d0                	mov    %edx,%eax
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	53                   	push   %ebx
  8009ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d5:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8009d9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8009dc:	83 c0 01             	add    $0x1,%eax
  8009df:	84 d2                	test   %dl,%dl
  8009e1:	75 f2                	jne    8009d5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009e3:	89 c8                	mov    %ecx,%eax
  8009e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	53                   	push   %ebx
  8009ee:	83 ec 10             	sub    $0x10,%esp
  8009f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f4:	53                   	push   %ebx
  8009f5:	e8 91 ff ff ff       	call   80098b <strlen>
  8009fa:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8009fd:	ff 75 0c             	push   0xc(%ebp)
  800a00:	01 d8                	add    %ebx,%eax
  800a02:	50                   	push   %eax
  800a03:	e8 be ff ff ff       	call   8009c6 <strcpy>
	return dst;
}
  800a08:	89 d8                	mov    %ebx,%eax
  800a0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0d:	c9                   	leave  
  800a0e:	c3                   	ret    

00800a0f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	8b 75 08             	mov    0x8(%ebp),%esi
  800a17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1a:	89 f3                	mov    %esi,%ebx
  800a1c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a1f:	89 f0                	mov    %esi,%eax
  800a21:	eb 0f                	jmp    800a32 <strncpy+0x23>
		*dst++ = *src;
  800a23:	83 c0 01             	add    $0x1,%eax
  800a26:	0f b6 0a             	movzbl (%edx),%ecx
  800a29:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a2c:	80 f9 01             	cmp    $0x1,%cl
  800a2f:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800a32:	39 d8                	cmp    %ebx,%eax
  800a34:	75 ed                	jne    800a23 <strncpy+0x14>
	}
	return ret;
}
  800a36:	89 f0                	mov    %esi,%eax
  800a38:	5b                   	pop    %ebx
  800a39:	5e                   	pop    %esi
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	8b 75 08             	mov    0x8(%ebp),%esi
  800a44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a47:	8b 55 10             	mov    0x10(%ebp),%edx
  800a4a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a4c:	85 d2                	test   %edx,%edx
  800a4e:	74 21                	je     800a71 <strlcpy+0x35>
  800a50:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a54:	89 f2                	mov    %esi,%edx
  800a56:	eb 09                	jmp    800a61 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a58:	83 c1 01             	add    $0x1,%ecx
  800a5b:	83 c2 01             	add    $0x1,%edx
  800a5e:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800a61:	39 c2                	cmp    %eax,%edx
  800a63:	74 09                	je     800a6e <strlcpy+0x32>
  800a65:	0f b6 19             	movzbl (%ecx),%ebx
  800a68:	84 db                	test   %bl,%bl
  800a6a:	75 ec                	jne    800a58 <strlcpy+0x1c>
  800a6c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a6e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a71:	29 f0                	sub    %esi,%eax
}
  800a73:	5b                   	pop    %ebx
  800a74:	5e                   	pop    %esi
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a80:	eb 06                	jmp    800a88 <strcmp+0x11>
		p++, q++;
  800a82:	83 c1 01             	add    $0x1,%ecx
  800a85:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a88:	0f b6 01             	movzbl (%ecx),%eax
  800a8b:	84 c0                	test   %al,%al
  800a8d:	74 04                	je     800a93 <strcmp+0x1c>
  800a8f:	3a 02                	cmp    (%edx),%al
  800a91:	74 ef                	je     800a82 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a93:	0f b6 c0             	movzbl %al,%eax
  800a96:	0f b6 12             	movzbl (%edx),%edx
  800a99:	29 d0                	sub    %edx,%eax
}
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	53                   	push   %ebx
  800aa1:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa7:	89 c3                	mov    %eax,%ebx
  800aa9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aac:	eb 06                	jmp    800ab4 <strncmp+0x17>
		n--, p++, q++;
  800aae:	83 c0 01             	add    $0x1,%eax
  800ab1:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ab4:	39 d8                	cmp    %ebx,%eax
  800ab6:	74 18                	je     800ad0 <strncmp+0x33>
  800ab8:	0f b6 08             	movzbl (%eax),%ecx
  800abb:	84 c9                	test   %cl,%cl
  800abd:	74 04                	je     800ac3 <strncmp+0x26>
  800abf:	3a 0a                	cmp    (%edx),%cl
  800ac1:	74 eb                	je     800aae <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac3:	0f b6 00             	movzbl (%eax),%eax
  800ac6:	0f b6 12             	movzbl (%edx),%edx
  800ac9:	29 d0                	sub    %edx,%eax
}
  800acb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ace:	c9                   	leave  
  800acf:	c3                   	ret    
		return 0;
  800ad0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad5:	eb f4                	jmp    800acb <strncmp+0x2e>

00800ad7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	8b 45 08             	mov    0x8(%ebp),%eax
  800add:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae1:	eb 03                	jmp    800ae6 <strchr+0xf>
  800ae3:	83 c0 01             	add    $0x1,%eax
  800ae6:	0f b6 10             	movzbl (%eax),%edx
  800ae9:	84 d2                	test   %dl,%dl
  800aeb:	74 06                	je     800af3 <strchr+0x1c>
		if (*s == c)
  800aed:	38 ca                	cmp    %cl,%dl
  800aef:	75 f2                	jne    800ae3 <strchr+0xc>
  800af1:	eb 05                	jmp    800af8 <strchr+0x21>
			return (char *) s;
	return 0;
  800af3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	8b 45 08             	mov    0x8(%ebp),%eax
  800b00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b04:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b07:	38 ca                	cmp    %cl,%dl
  800b09:	74 09                	je     800b14 <strfind+0x1a>
  800b0b:	84 d2                	test   %dl,%dl
  800b0d:	74 05                	je     800b14 <strfind+0x1a>
	for (; *s; s++)
  800b0f:	83 c0 01             	add    $0x1,%eax
  800b12:	eb f0                	jmp    800b04 <strfind+0xa>
			break;
	return (char *) s;
}
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
  800b1c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b22:	85 c9                	test   %ecx,%ecx
  800b24:	74 2f                	je     800b55 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b26:	89 f8                	mov    %edi,%eax
  800b28:	09 c8                	or     %ecx,%eax
  800b2a:	a8 03                	test   $0x3,%al
  800b2c:	75 21                	jne    800b4f <memset+0x39>
		c &= 0xFF;
  800b2e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b32:	89 d0                	mov    %edx,%eax
  800b34:	c1 e0 08             	shl    $0x8,%eax
  800b37:	89 d3                	mov    %edx,%ebx
  800b39:	c1 e3 18             	shl    $0x18,%ebx
  800b3c:	89 d6                	mov    %edx,%esi
  800b3e:	c1 e6 10             	shl    $0x10,%esi
  800b41:	09 f3                	or     %esi,%ebx
  800b43:	09 da                	or     %ebx,%edx
  800b45:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b47:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b4a:	fc                   	cld    
  800b4b:	f3 ab                	rep stos %eax,%es:(%edi)
  800b4d:	eb 06                	jmp    800b55 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b52:	fc                   	cld    
  800b53:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b55:	89 f8                	mov    %edi,%eax
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	8b 45 08             	mov    0x8(%ebp),%eax
  800b64:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b67:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b6a:	39 c6                	cmp    %eax,%esi
  800b6c:	73 32                	jae    800ba0 <memmove+0x44>
  800b6e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b71:	39 c2                	cmp    %eax,%edx
  800b73:	76 2b                	jbe    800ba0 <memmove+0x44>
		s += n;
		d += n;
  800b75:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	09 fe                	or     %edi,%esi
  800b7c:	09 ce                	or     %ecx,%esi
  800b7e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b84:	75 0e                	jne    800b94 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b86:	83 ef 04             	sub    $0x4,%edi
  800b89:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b8c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b8f:	fd                   	std    
  800b90:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b92:	eb 09                	jmp    800b9d <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b94:	83 ef 01             	sub    $0x1,%edi
  800b97:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b9a:	fd                   	std    
  800b9b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b9d:	fc                   	cld    
  800b9e:	eb 1a                	jmp    800bba <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba0:	89 f2                	mov    %esi,%edx
  800ba2:	09 c2                	or     %eax,%edx
  800ba4:	09 ca                	or     %ecx,%edx
  800ba6:	f6 c2 03             	test   $0x3,%dl
  800ba9:	75 0a                	jne    800bb5 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bab:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800bae:	89 c7                	mov    %eax,%edi
  800bb0:	fc                   	cld    
  800bb1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb3:	eb 05                	jmp    800bba <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800bb5:	89 c7                	mov    %eax,%edi
  800bb7:	fc                   	cld    
  800bb8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bc4:	ff 75 10             	push   0x10(%ebp)
  800bc7:	ff 75 0c             	push   0xc(%ebp)
  800bca:	ff 75 08             	push   0x8(%ebp)
  800bcd:	e8 8a ff ff ff       	call   800b5c <memmove>
}
  800bd2:	c9                   	leave  
  800bd3:	c3                   	ret    

00800bd4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bdf:	89 c6                	mov    %eax,%esi
  800be1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be4:	eb 06                	jmp    800bec <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800be6:	83 c0 01             	add    $0x1,%eax
  800be9:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800bec:	39 f0                	cmp    %esi,%eax
  800bee:	74 14                	je     800c04 <memcmp+0x30>
		if (*s1 != *s2)
  800bf0:	0f b6 08             	movzbl (%eax),%ecx
  800bf3:	0f b6 1a             	movzbl (%edx),%ebx
  800bf6:	38 d9                	cmp    %bl,%cl
  800bf8:	74 ec                	je     800be6 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800bfa:	0f b6 c1             	movzbl %cl,%eax
  800bfd:	0f b6 db             	movzbl %bl,%ebx
  800c00:	29 d8                	sub    %ebx,%eax
  800c02:	eb 05                	jmp    800c09 <memcmp+0x35>
	}

	return 0;
  800c04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    

00800c0d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	8b 45 08             	mov    0x8(%ebp),%eax
  800c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c16:	89 c2                	mov    %eax,%edx
  800c18:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c1b:	eb 03                	jmp    800c20 <memfind+0x13>
  800c1d:	83 c0 01             	add    $0x1,%eax
  800c20:	39 d0                	cmp    %edx,%eax
  800c22:	73 04                	jae    800c28 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c24:	38 08                	cmp    %cl,(%eax)
  800c26:	75 f5                	jne    800c1d <memfind+0x10>
			break;
	return (void *) s;
}
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	57                   	push   %edi
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c36:	eb 03                	jmp    800c3b <strtol+0x11>
		s++;
  800c38:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c3b:	0f b6 02             	movzbl (%edx),%eax
  800c3e:	3c 20                	cmp    $0x20,%al
  800c40:	74 f6                	je     800c38 <strtol+0xe>
  800c42:	3c 09                	cmp    $0x9,%al
  800c44:	74 f2                	je     800c38 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c46:	3c 2b                	cmp    $0x2b,%al
  800c48:	74 2a                	je     800c74 <strtol+0x4a>
	int neg = 0;
  800c4a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c4f:	3c 2d                	cmp    $0x2d,%al
  800c51:	74 2b                	je     800c7e <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c53:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c59:	75 0f                	jne    800c6a <strtol+0x40>
  800c5b:	80 3a 30             	cmpb   $0x30,(%edx)
  800c5e:	74 28                	je     800c88 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c60:	85 db                	test   %ebx,%ebx
  800c62:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c67:	0f 44 d8             	cmove  %eax,%ebx
  800c6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c6f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c72:	eb 46                	jmp    800cba <strtol+0x90>
		s++;
  800c74:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c77:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7c:	eb d5                	jmp    800c53 <strtol+0x29>
		s++, neg = 1;
  800c7e:	83 c2 01             	add    $0x1,%edx
  800c81:	bf 01 00 00 00       	mov    $0x1,%edi
  800c86:	eb cb                	jmp    800c53 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c88:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c8c:	74 0e                	je     800c9c <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800c8e:	85 db                	test   %ebx,%ebx
  800c90:	75 d8                	jne    800c6a <strtol+0x40>
		s++, base = 8;
  800c92:	83 c2 01             	add    $0x1,%edx
  800c95:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c9a:	eb ce                	jmp    800c6a <strtol+0x40>
		s += 2, base = 16;
  800c9c:	83 c2 02             	add    $0x2,%edx
  800c9f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ca4:	eb c4                	jmp    800c6a <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ca6:	0f be c0             	movsbl %al,%eax
  800ca9:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cac:	3b 45 10             	cmp    0x10(%ebp),%eax
  800caf:	7d 3a                	jge    800ceb <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800cb1:	83 c2 01             	add    $0x1,%edx
  800cb4:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800cb8:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800cba:	0f b6 02             	movzbl (%edx),%eax
  800cbd:	8d 70 d0             	lea    -0x30(%eax),%esi
  800cc0:	89 f3                	mov    %esi,%ebx
  800cc2:	80 fb 09             	cmp    $0x9,%bl
  800cc5:	76 df                	jbe    800ca6 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800cc7:	8d 70 9f             	lea    -0x61(%eax),%esi
  800cca:	89 f3                	mov    %esi,%ebx
  800ccc:	80 fb 19             	cmp    $0x19,%bl
  800ccf:	77 08                	ja     800cd9 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800cd1:	0f be c0             	movsbl %al,%eax
  800cd4:	83 e8 57             	sub    $0x57,%eax
  800cd7:	eb d3                	jmp    800cac <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800cd9:	8d 70 bf             	lea    -0x41(%eax),%esi
  800cdc:	89 f3                	mov    %esi,%ebx
  800cde:	80 fb 19             	cmp    $0x19,%bl
  800ce1:	77 08                	ja     800ceb <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ce3:	0f be c0             	movsbl %al,%eax
  800ce6:	83 e8 37             	sub    $0x37,%eax
  800ce9:	eb c1                	jmp    800cac <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ceb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cef:	74 05                	je     800cf6 <strtol+0xcc>
		*endptr = (char *) s;
  800cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf4:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800cf6:	89 c8                	mov    %ecx,%eax
  800cf8:	f7 d8                	neg    %eax
  800cfa:	85 ff                	test   %edi,%edi
  800cfc:	0f 45 c8             	cmovne %eax,%ecx
}
  800cff:	89 c8                	mov    %ecx,%eax
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    
  800d06:	66 90                	xchg   %ax,%ax
  800d08:	66 90                	xchg   %ax,%ax
  800d0a:	66 90                	xchg   %ax,%ax
  800d0c:	66 90                	xchg   %ax,%ax
  800d0e:	66 90                	xchg   %ax,%ax

00800d10 <__udivdi3>:
  800d10:	f3 0f 1e fb          	endbr32 
  800d14:	55                   	push   %ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	83 ec 1c             	sub    $0x1c,%esp
  800d1b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800d1f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d23:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d27:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	75 19                	jne    800d48 <__udivdi3+0x38>
  800d2f:	39 f3                	cmp    %esi,%ebx
  800d31:	76 4d                	jbe    800d80 <__udivdi3+0x70>
  800d33:	31 ff                	xor    %edi,%edi
  800d35:	89 e8                	mov    %ebp,%eax
  800d37:	89 f2                	mov    %esi,%edx
  800d39:	f7 f3                	div    %ebx
  800d3b:	89 fa                	mov    %edi,%edx
  800d3d:	83 c4 1c             	add    $0x1c,%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    
  800d45:	8d 76 00             	lea    0x0(%esi),%esi
  800d48:	39 f0                	cmp    %esi,%eax
  800d4a:	76 14                	jbe    800d60 <__udivdi3+0x50>
  800d4c:	31 ff                	xor    %edi,%edi
  800d4e:	31 c0                	xor    %eax,%eax
  800d50:	89 fa                	mov    %edi,%edx
  800d52:	83 c4 1c             	add    $0x1c,%esp
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    
  800d5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d60:	0f bd f8             	bsr    %eax,%edi
  800d63:	83 f7 1f             	xor    $0x1f,%edi
  800d66:	75 48                	jne    800db0 <__udivdi3+0xa0>
  800d68:	39 f0                	cmp    %esi,%eax
  800d6a:	72 06                	jb     800d72 <__udivdi3+0x62>
  800d6c:	31 c0                	xor    %eax,%eax
  800d6e:	39 eb                	cmp    %ebp,%ebx
  800d70:	77 de                	ja     800d50 <__udivdi3+0x40>
  800d72:	b8 01 00 00 00       	mov    $0x1,%eax
  800d77:	eb d7                	jmp    800d50 <__udivdi3+0x40>
  800d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d80:	89 d9                	mov    %ebx,%ecx
  800d82:	85 db                	test   %ebx,%ebx
  800d84:	75 0b                	jne    800d91 <__udivdi3+0x81>
  800d86:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8b:	31 d2                	xor    %edx,%edx
  800d8d:	f7 f3                	div    %ebx
  800d8f:	89 c1                	mov    %eax,%ecx
  800d91:	31 d2                	xor    %edx,%edx
  800d93:	89 f0                	mov    %esi,%eax
  800d95:	f7 f1                	div    %ecx
  800d97:	89 c6                	mov    %eax,%esi
  800d99:	89 e8                	mov    %ebp,%eax
  800d9b:	89 f7                	mov    %esi,%edi
  800d9d:	f7 f1                	div    %ecx
  800d9f:	89 fa                	mov    %edi,%edx
  800da1:	83 c4 1c             	add    $0x1c,%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    
  800da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800db0:	89 f9                	mov    %edi,%ecx
  800db2:	ba 20 00 00 00       	mov    $0x20,%edx
  800db7:	29 fa                	sub    %edi,%edx
  800db9:	d3 e0                	shl    %cl,%eax
  800dbb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dbf:	89 d1                	mov    %edx,%ecx
  800dc1:	89 d8                	mov    %ebx,%eax
  800dc3:	d3 e8                	shr    %cl,%eax
  800dc5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800dc9:	09 c1                	or     %eax,%ecx
  800dcb:	89 f0                	mov    %esi,%eax
  800dcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dd1:	89 f9                	mov    %edi,%ecx
  800dd3:	d3 e3                	shl    %cl,%ebx
  800dd5:	89 d1                	mov    %edx,%ecx
  800dd7:	d3 e8                	shr    %cl,%eax
  800dd9:	89 f9                	mov    %edi,%ecx
  800ddb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ddf:	89 eb                	mov    %ebp,%ebx
  800de1:	d3 e6                	shl    %cl,%esi
  800de3:	89 d1                	mov    %edx,%ecx
  800de5:	d3 eb                	shr    %cl,%ebx
  800de7:	09 f3                	or     %esi,%ebx
  800de9:	89 c6                	mov    %eax,%esi
  800deb:	89 f2                	mov    %esi,%edx
  800ded:	89 d8                	mov    %ebx,%eax
  800def:	f7 74 24 08          	divl   0x8(%esp)
  800df3:	89 d6                	mov    %edx,%esi
  800df5:	89 c3                	mov    %eax,%ebx
  800df7:	f7 64 24 0c          	mull   0xc(%esp)
  800dfb:	39 d6                	cmp    %edx,%esi
  800dfd:	72 19                	jb     800e18 <__udivdi3+0x108>
  800dff:	89 f9                	mov    %edi,%ecx
  800e01:	d3 e5                	shl    %cl,%ebp
  800e03:	39 c5                	cmp    %eax,%ebp
  800e05:	73 04                	jae    800e0b <__udivdi3+0xfb>
  800e07:	39 d6                	cmp    %edx,%esi
  800e09:	74 0d                	je     800e18 <__udivdi3+0x108>
  800e0b:	89 d8                	mov    %ebx,%eax
  800e0d:	31 ff                	xor    %edi,%edi
  800e0f:	e9 3c ff ff ff       	jmp    800d50 <__udivdi3+0x40>
  800e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e18:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e1b:	31 ff                	xor    %edi,%edi
  800e1d:	e9 2e ff ff ff       	jmp    800d50 <__udivdi3+0x40>
  800e22:	66 90                	xchg   %ax,%ax
  800e24:	66 90                	xchg   %ax,%ax
  800e26:	66 90                	xchg   %ax,%ax
  800e28:	66 90                	xchg   %ax,%ax
  800e2a:	66 90                	xchg   %ax,%ax
  800e2c:	66 90                	xchg   %ax,%ax
  800e2e:	66 90                	xchg   %ax,%ax

00800e30 <__umoddi3>:
  800e30:	f3 0f 1e fb          	endbr32 
  800e34:	55                   	push   %ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
  800e38:	83 ec 1c             	sub    $0x1c,%esp
  800e3b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e43:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800e47:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800e4b:	89 f0                	mov    %esi,%eax
  800e4d:	89 da                	mov    %ebx,%edx
  800e4f:	85 ff                	test   %edi,%edi
  800e51:	75 15                	jne    800e68 <__umoddi3+0x38>
  800e53:	39 dd                	cmp    %ebx,%ebp
  800e55:	76 39                	jbe    800e90 <__umoddi3+0x60>
  800e57:	f7 f5                	div    %ebp
  800e59:	89 d0                	mov    %edx,%eax
  800e5b:	31 d2                	xor    %edx,%edx
  800e5d:	83 c4 1c             	add    $0x1c,%esp
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    
  800e65:	8d 76 00             	lea    0x0(%esi),%esi
  800e68:	39 df                	cmp    %ebx,%edi
  800e6a:	77 f1                	ja     800e5d <__umoddi3+0x2d>
  800e6c:	0f bd cf             	bsr    %edi,%ecx
  800e6f:	83 f1 1f             	xor    $0x1f,%ecx
  800e72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e76:	75 40                	jne    800eb8 <__umoddi3+0x88>
  800e78:	39 df                	cmp    %ebx,%edi
  800e7a:	72 04                	jb     800e80 <__umoddi3+0x50>
  800e7c:	39 f5                	cmp    %esi,%ebp
  800e7e:	77 dd                	ja     800e5d <__umoddi3+0x2d>
  800e80:	89 da                	mov    %ebx,%edx
  800e82:	89 f0                	mov    %esi,%eax
  800e84:	29 e8                	sub    %ebp,%eax
  800e86:	19 fa                	sbb    %edi,%edx
  800e88:	eb d3                	jmp    800e5d <__umoddi3+0x2d>
  800e8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e90:	89 e9                	mov    %ebp,%ecx
  800e92:	85 ed                	test   %ebp,%ebp
  800e94:	75 0b                	jne    800ea1 <__umoddi3+0x71>
  800e96:	b8 01 00 00 00       	mov    $0x1,%eax
  800e9b:	31 d2                	xor    %edx,%edx
  800e9d:	f7 f5                	div    %ebp
  800e9f:	89 c1                	mov    %eax,%ecx
  800ea1:	89 d8                	mov    %ebx,%eax
  800ea3:	31 d2                	xor    %edx,%edx
  800ea5:	f7 f1                	div    %ecx
  800ea7:	89 f0                	mov    %esi,%eax
  800ea9:	f7 f1                	div    %ecx
  800eab:	89 d0                	mov    %edx,%eax
  800ead:	31 d2                	xor    %edx,%edx
  800eaf:	eb ac                	jmp    800e5d <__umoddi3+0x2d>
  800eb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ebc:	ba 20 00 00 00       	mov    $0x20,%edx
  800ec1:	29 c2                	sub    %eax,%edx
  800ec3:	89 c1                	mov    %eax,%ecx
  800ec5:	89 e8                	mov    %ebp,%eax
  800ec7:	d3 e7                	shl    %cl,%edi
  800ec9:	89 d1                	mov    %edx,%ecx
  800ecb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ecf:	d3 e8                	shr    %cl,%eax
  800ed1:	89 c1                	mov    %eax,%ecx
  800ed3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ed7:	09 f9                	or     %edi,%ecx
  800ed9:	89 df                	mov    %ebx,%edi
  800edb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800edf:	89 c1                	mov    %eax,%ecx
  800ee1:	d3 e5                	shl    %cl,%ebp
  800ee3:	89 d1                	mov    %edx,%ecx
  800ee5:	d3 ef                	shr    %cl,%edi
  800ee7:	89 c1                	mov    %eax,%ecx
  800ee9:	89 f0                	mov    %esi,%eax
  800eeb:	d3 e3                	shl    %cl,%ebx
  800eed:	89 d1                	mov    %edx,%ecx
  800eef:	89 fa                	mov    %edi,%edx
  800ef1:	d3 e8                	shr    %cl,%eax
  800ef3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ef8:	09 d8                	or     %ebx,%eax
  800efa:	f7 74 24 08          	divl   0x8(%esp)
  800efe:	89 d3                	mov    %edx,%ebx
  800f00:	d3 e6                	shl    %cl,%esi
  800f02:	f7 e5                	mul    %ebp
  800f04:	89 c7                	mov    %eax,%edi
  800f06:	89 d1                	mov    %edx,%ecx
  800f08:	39 d3                	cmp    %edx,%ebx
  800f0a:	72 06                	jb     800f12 <__umoddi3+0xe2>
  800f0c:	75 0e                	jne    800f1c <__umoddi3+0xec>
  800f0e:	39 c6                	cmp    %eax,%esi
  800f10:	73 0a                	jae    800f1c <__umoddi3+0xec>
  800f12:	29 e8                	sub    %ebp,%eax
  800f14:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800f18:	89 d1                	mov    %edx,%ecx
  800f1a:	89 c7                	mov    %eax,%edi
  800f1c:	89 f5                	mov    %esi,%ebp
  800f1e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f22:	29 fd                	sub    %edi,%ebp
  800f24:	19 cb                	sbb    %ecx,%ebx
  800f26:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f2b:	89 d8                	mov    %ebx,%eax
  800f2d:	d3 e0                	shl    %cl,%eax
  800f2f:	89 f1                	mov    %esi,%ecx
  800f31:	d3 ed                	shr    %cl,%ebp
  800f33:	d3 eb                	shr    %cl,%ebx
  800f35:	09 e8                	or     %ebp,%eax
  800f37:	89 da                	mov    %ebx,%edx
  800f39:	83 c4 1c             	add    $0x1c,%esp
  800f3c:	5b                   	pop    %ebx
  800f3d:	5e                   	pop    %esi
  800f3e:	5f                   	pop    %edi
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    
