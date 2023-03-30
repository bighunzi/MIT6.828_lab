
obj/net/testoutput：     文件格式 elf32-i386


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
  80002c:	e8 70 02 00 00       	call   8002a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
static struct jif_pkt *pkt = (struct jif_pkt*)REQVA;


void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	envid_t ns_envid = sys_getenvid();
  800038:	e8 37 0d 00 00       	call   800d74 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi
	int i, r;

	binaryname = "testoutput";
  80003f:	c7 05 00 30 80 00 a0 	movl   $0x8027a0,0x803000
  800046:	27 80 00 

	output_envid = fork();
  800049:	e8 b4 10 00 00       	call   801102 <fork>
  80004e:	a3 00 40 80 00       	mov    %eax,0x804000
	if (output_envid < 0)
  800053:	85 c0                	test   %eax,%eax
  800055:	0f 88 93 00 00 00    	js     8000ee <umain+0xbb>
	else if (output_envid == 0) {
		output(ns_envid);
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
  80005b:	bb 00 00 00 00       	mov    $0x0,%ebx
	else if (output_envid == 0) {
  800060:	0f 84 9c 00 00 00    	je     800102 <umain+0xcf>
		if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  800066:	83 ec 04             	sub    $0x4,%esp
  800069:	6a 07                	push   $0x7
  80006b:	68 00 b0 fe 0f       	push   $0xffeb000
  800070:	6a 00                	push   $0x0
  800072:	e8 3b 0d 00 00       	call   800db2 <sys_page_alloc>
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	85 c0                	test   %eax,%eax
  80007c:	0f 88 8e 00 00 00    	js     800110 <umain+0xdd>
			panic("sys_page_alloc: %e", r);
		pkt->jp_len = snprintf(pkt->jp_data,
  800082:	53                   	push   %ebx
  800083:	68 dd 27 80 00       	push   $0x8027dd
  800088:	68 fc 0f 00 00       	push   $0xffc
  80008d:	68 04 b0 fe 0f       	push   $0xffeb004
  800092:	e8 ca 08 00 00       	call   800961 <snprintf>
  800097:	a3 00 b0 fe 0f       	mov    %eax,0xffeb000
				       PGSIZE - sizeof(pkt->jp_len),
				       "Packet %02d", i);
		cprintf("Transmitting packet %d\n", i);
  80009c:	83 c4 08             	add    $0x8,%esp
  80009f:	53                   	push   %ebx
  8000a0:	68 e9 27 80 00       	push   $0x8027e9
  8000a5:	e8 32 03 00 00       	call   8003dc <cprintf>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8000aa:	6a 07                	push   $0x7
  8000ac:	68 00 b0 fe 0f       	push   $0xffeb000
  8000b1:	6a 0b                	push   $0xb
  8000b3:	ff 35 00 40 80 00    	push   0x804000
  8000b9:	e8 2b 12 00 00       	call   8012e9 <ipc_send>
		sys_page_unmap(0, pkt);
  8000be:	83 c4 18             	add    $0x18,%esp
  8000c1:	68 00 b0 fe 0f       	push   $0xffeb000
  8000c6:	6a 00                	push   $0x0
  8000c8:	e8 6a 0d 00 00       	call   800e37 <sys_page_unmap>
	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
  8000cd:	83 c3 01             	add    $0x1,%ebx
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	83 fb 0a             	cmp    $0xa,%ebx
  8000d6:	75 8e                	jne    800066 <umain+0x33>
  8000d8:	bb 14 00 00 00       	mov    $0x14,%ebx
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
		sys_yield();
  8000dd:	e8 b1 0c 00 00       	call   800d93 <sys_yield>
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
  8000e2:	83 eb 01             	sub    $0x1,%ebx
  8000e5:	75 f6                	jne    8000dd <umain+0xaa>
}
  8000e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    
		panic("error forking");
  8000ee:	83 ec 04             	sub    $0x4,%esp
  8000f1:	68 ab 27 80 00       	push   $0x8027ab
  8000f6:	6a 16                	push   $0x16
  8000f8:	68 b9 27 80 00       	push   $0x8027b9
  8000fd:	e8 ff 01 00 00       	call   800301 <_panic>
		output(ns_envid);
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	56                   	push   %esi
  800106:	e8 3e 01 00 00       	call   800249 <output>
		return;
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	eb d7                	jmp    8000e7 <umain+0xb4>
			panic("sys_page_alloc: %e", r);
  800110:	50                   	push   %eax
  800111:	68 ca 27 80 00       	push   $0x8027ca
  800116:	6a 1e                	push   $0x1e
  800118:	68 b9 27 80 00       	push   $0x8027b9
  80011d:	e8 df 01 00 00       	call   800301 <_panic>

00800122 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	57                   	push   %edi
  800126:	56                   	push   %esi
  800127:	53                   	push   %ebx
  800128:	83 ec 1c             	sub    $0x1c,%esp
  80012b:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  80012e:	e8 70 0e 00 00       	call   800fa3 <sys_time_msec>
  800133:	03 45 0c             	add    0xc(%ebp),%eax
  800136:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  800138:	c7 05 00 30 80 00 01 	movl   $0x802801,0x803000
  80013f:	28 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800142:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800145:	eb 33                	jmp    80017a <timer+0x58>
		if (r < 0)
  800147:	85 c0                	test   %eax,%eax
  800149:	78 43                	js     80018e <timer+0x6c>
		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  80014b:	6a 00                	push   $0x0
  80014d:	6a 00                	push   $0x0
  80014f:	6a 0c                	push   $0xc
  800151:	56                   	push   %esi
  800152:	e8 92 11 00 00       	call   8012e9 <ipc_send>
  800157:	83 c4 10             	add    $0x10,%esp
			to = ipc_recv((int32_t *) &whom, 0, 0);
  80015a:	83 ec 04             	sub    $0x4,%esp
  80015d:	6a 00                	push   $0x0
  80015f:	6a 00                	push   $0x0
  800161:	57                   	push   %edi
  800162:	e8 1b 11 00 00       	call   801282 <ipc_recv>
  800167:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  800169:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80016c:	83 c4 10             	add    $0x10,%esp
  80016f:	39 f0                	cmp    %esi,%eax
  800171:	75 2d                	jne    8001a0 <timer+0x7e>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
				continue;
			}

			stop = sys_time_msec() + to;
  800173:	e8 2b 0e 00 00       	call   800fa3 <sys_time_msec>
  800178:	01 c3                	add    %eax,%ebx
		while((r = sys_time_msec()) < stop && r >= 0) {
  80017a:	e8 24 0e 00 00       	call   800fa3 <sys_time_msec>
  80017f:	85 c0                	test   %eax,%eax
  800181:	78 c4                	js     800147 <timer+0x25>
  800183:	39 d8                	cmp    %ebx,%eax
  800185:	73 c0                	jae    800147 <timer+0x25>
			sys_yield();
  800187:	e8 07 0c 00 00       	call   800d93 <sys_yield>
  80018c:	eb ec                	jmp    80017a <timer+0x58>
			panic("sys_time_msec: %e", r);
  80018e:	50                   	push   %eax
  80018f:	68 0a 28 80 00       	push   $0x80280a
  800194:	6a 0f                	push   $0xf
  800196:	68 1c 28 80 00       	push   $0x80281c
  80019b:	e8 61 01 00 00       	call   800301 <_panic>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  8001a0:	83 ec 08             	sub    $0x8,%esp
  8001a3:	50                   	push   %eax
  8001a4:	68 28 28 80 00       	push   $0x802828
  8001a9:	e8 2e 02 00 00       	call   8003dc <cprintf>
				continue;
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	eb a7                	jmp    80015a <timer+0x38>

008001b3 <sleep>:

extern union Nsipc nsipcbuf;

void
sleep(int msec)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	56                   	push   %esi
  8001b7:	53                   	push   %ebx
  8001b8:	8b 75 08             	mov    0x8(%ebp),%esi
    unsigned now = sys_time_msec();
  8001bb:	e8 e3 0d 00 00       	call   800fa3 <sys_time_msec>
  8001c0:	89 c3                	mov    %eax,%ebx

    while (msec > sys_time_msec()-now){
  8001c2:	eb 05                	jmp    8001c9 <sleep+0x16>
    	sys_yield();
  8001c4:	e8 ca 0b 00 00       	call   800d93 <sys_yield>
    while (msec > sys_time_msec()-now){
  8001c9:	e8 d5 0d 00 00       	call   800fa3 <sys_time_msec>
  8001ce:	29 d8                	sub    %ebx,%eax
  8001d0:	39 f0                	cmp    %esi,%eax
  8001d2:	72 f0                	jb     8001c4 <sleep+0x11>
    }    
}
  8001d4:	5b                   	pop    %ebx
  8001d5:	5e                   	pop    %esi
  8001d6:	5d                   	pop    %ebp
  8001d7:	c3                   	ret    

008001d8 <input>:

void
input(envid_t ns_envid)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	57                   	push   %edi
  8001dc:	56                   	push   %esi
  8001dd:	53                   	push   %ebx
  8001de:	81 ec 1c 08 00 00    	sub    $0x81c,%esp
  8001e4:	8b 7d 08             	mov    0x8(%ebp),%edi
	binaryname = "ns_input";
  8001e7:	c7 05 00 30 80 00 63 	movl   $0x802863,0x803000
  8001ee:	28 80 00 
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
	size_t len;
	char rev_buf[RX_PACKET_SIZE];
	while(1){
		while ( sys_e1000_recv(rev_buf, &len)  < 0) {
  8001f1:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8001f4:	8d 9d e4 f7 ff ff    	lea    -0x81c(%ebp),%ebx
  8001fa:	eb 05                	jmp    800201 <input+0x29>
			sys_yield();//没东西读，就阻塞，切换别的环境。    
  8001fc:	e8 92 0b 00 00       	call   800d93 <sys_yield>
		while ( sys_e1000_recv(rev_buf, &len)  < 0) {
  800201:	83 ec 08             	sub    $0x8,%esp
  800204:	56                   	push   %esi
  800205:	53                   	push   %ebx
  800206:	e8 d8 0d 00 00       	call   800fe3 <sys_e1000_recv>
  80020b:	83 c4 10             	add    $0x10,%esp
  80020e:	85 c0                	test   %eax,%eax
  800210:	78 ea                	js     8001fc <input+0x24>
		}
		memcpy(nsipcbuf.pkt.jp_data, rev_buf, len);
  800212:	83 ec 04             	sub    $0x4,%esp
  800215:	ff 75 e4             	push   -0x1c(%ebp)
  800218:	53                   	push   %ebx
  800219:	68 04 70 80 00       	push   $0x807004
  80021e:	e8 8b 09 00 00       	call   800bae <memcpy>
		nsipcbuf.pkt.jp_len = len;
  800223:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800226:	a3 00 70 80 00       	mov    %eax,0x807000
		
		ipc_send(ns_envid, NSREQ_INPUT, &nsipcbuf, PTE_P|PTE_U);
  80022b:	6a 05                	push   $0x5
  80022d:	68 00 70 80 00       	push   $0x807000
  800232:	6a 0a                	push   $0xa
  800234:	57                   	push   %edi
  800235:	e8 af 10 00 00       	call   8012e9 <ipc_send>
		
		sleep(30);//停留一段时间，不停留的话，测试不会通过，会丢包。
  80023a:	83 c4 14             	add    $0x14,%esp
  80023d:	6a 1e                	push   $0x1e
  80023f:	e8 6f ff ff ff       	call   8001b3 <sleep>
		while ( sys_e1000_recv(rev_buf, &len)  < 0) {
  800244:	83 c4 10             	add    $0x10,%esp
  800247:	eb b8                	jmp    800201 <input+0x29>

00800249 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 10             	sub    $0x10,%esp
  800251:	8b 75 08             	mov    0x8(%ebp),%esi
	binaryname = "ns_output";
  800254:	c7 05 00 30 80 00 6c 	movl   $0x80286c,0x803000
  80025b:	28 80 00 
	// 	- read a packet from the network server
	//	- send the packet to the device driver
	int r, perm;
	envid_t from_env;
	while(1){
		r=ipc_recv( &from_env , &nsipcbuf, NULL);
  80025e:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  800261:	eb 1f                	jmp    800282 <output+0x39>
		if(r!=NSREQ_OUTPUT || from_env!=ns_envid){
			continue;
		} 
		while( sys_e1000_try_send( nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len ) < 0 ){
			sys_yield();//发送失败，切换进程，让出控制器。
  800263:	e8 2b 0b 00 00       	call   800d93 <sys_yield>
		while( sys_e1000_try_send( nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len ) < 0 ){
  800268:	83 ec 08             	sub    $0x8,%esp
  80026b:	ff 35 00 70 80 00    	push   0x807000
  800271:	68 04 70 80 00       	push   $0x807004
  800276:	e8 47 0d 00 00       	call   800fc2 <sys_e1000_try_send>
  80027b:	83 c4 10             	add    $0x10,%esp
  80027e:	85 c0                	test   %eax,%eax
  800280:	78 e1                	js     800263 <output+0x1a>
		r=ipc_recv( &from_env , &nsipcbuf, NULL);
  800282:	83 ec 04             	sub    $0x4,%esp
  800285:	6a 00                	push   $0x0
  800287:	68 00 70 80 00       	push   $0x807000
  80028c:	53                   	push   %ebx
  80028d:	e8 f0 0f 00 00       	call   801282 <ipc_recv>
		if(r!=NSREQ_OUTPUT || from_env!=ns_envid){
  800292:	83 c4 10             	add    $0x10,%esp
  800295:	83 f8 0b             	cmp    $0xb,%eax
  800298:	75 e8                	jne    800282 <output+0x39>
  80029a:	39 75 f4             	cmp    %esi,-0xc(%ebp)
  80029d:	75 e3                	jne    800282 <output+0x39>
  80029f:	eb c7                	jmp    800268 <output+0x1f>

008002a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8002ac:	e8 c3 0a 00 00       	call   800d74 <sys_getenvid>
  8002b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002be:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002c3:	85 db                	test   %ebx,%ebx
  8002c5:	7e 07                	jle    8002ce <libmain+0x2d>
		binaryname = argv[0];
  8002c7:	8b 06                	mov    (%esi),%eax
  8002c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002ce:	83 ec 08             	sub    $0x8,%esp
  8002d1:	56                   	push   %esi
  8002d2:	53                   	push   %ebx
  8002d3:	e8 5b fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002d8:	e8 0a 00 00 00       	call   8002e7 <exit>
}
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002e3:	5b                   	pop    %ebx
  8002e4:	5e                   	pop    %esi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002ed:	e8 55 12 00 00       	call   801547 <close_all>
	sys_env_destroy(0);
  8002f2:	83 ec 0c             	sub    $0xc,%esp
  8002f5:	6a 00                	push   $0x0
  8002f7:	e8 37 0a 00 00       	call   800d33 <sys_env_destroy>
}
  8002fc:	83 c4 10             	add    $0x10,%esp
  8002ff:	c9                   	leave  
  800300:	c3                   	ret    

00800301 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800306:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800309:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80030f:	e8 60 0a 00 00       	call   800d74 <sys_getenvid>
  800314:	83 ec 0c             	sub    $0xc,%esp
  800317:	ff 75 0c             	push   0xc(%ebp)
  80031a:	ff 75 08             	push   0x8(%ebp)
  80031d:	56                   	push   %esi
  80031e:	50                   	push   %eax
  80031f:	68 80 28 80 00       	push   $0x802880
  800324:	e8 b3 00 00 00       	call   8003dc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800329:	83 c4 18             	add    $0x18,%esp
  80032c:	53                   	push   %ebx
  80032d:	ff 75 10             	push   0x10(%ebp)
  800330:	e8 56 00 00 00       	call   80038b <vcprintf>
	cprintf("\n");
  800335:	c7 04 24 ff 27 80 00 	movl   $0x8027ff,(%esp)
  80033c:	e8 9b 00 00 00       	call   8003dc <cprintf>
  800341:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800344:	cc                   	int3   
  800345:	eb fd                	jmp    800344 <_panic+0x43>

00800347 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	53                   	push   %ebx
  80034b:	83 ec 04             	sub    $0x4,%esp
  80034e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800351:	8b 13                	mov    (%ebx),%edx
  800353:	8d 42 01             	lea    0x1(%edx),%eax
  800356:	89 03                	mov    %eax,(%ebx)
  800358:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80035b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80035f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800364:	74 09                	je     80036f <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800366:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80036a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80036d:	c9                   	leave  
  80036e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80036f:	83 ec 08             	sub    $0x8,%esp
  800372:	68 ff 00 00 00       	push   $0xff
  800377:	8d 43 08             	lea    0x8(%ebx),%eax
  80037a:	50                   	push   %eax
  80037b:	e8 76 09 00 00       	call   800cf6 <sys_cputs>
		b->idx = 0;
  800380:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800386:	83 c4 10             	add    $0x10,%esp
  800389:	eb db                	jmp    800366 <putch+0x1f>

0080038b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
  80038e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800394:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80039b:	00 00 00 
	b.cnt = 0;
  80039e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003a5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a8:	ff 75 0c             	push   0xc(%ebp)
  8003ab:	ff 75 08             	push   0x8(%ebp)
  8003ae:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003b4:	50                   	push   %eax
  8003b5:	68 47 03 80 00       	push   $0x800347
  8003ba:	e8 14 01 00 00       	call   8004d3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003bf:	83 c4 08             	add    $0x8,%esp
  8003c2:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003c8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ce:	50                   	push   %eax
  8003cf:	e8 22 09 00 00       	call   800cf6 <sys_cputs>

	return b.cnt;
}
  8003d4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003da:	c9                   	leave  
  8003db:	c3                   	ret    

008003dc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003e5:	50                   	push   %eax
  8003e6:	ff 75 08             	push   0x8(%ebp)
  8003e9:	e8 9d ff ff ff       	call   80038b <vcprintf>
	va_end(ap);

	return cnt;
}
  8003ee:	c9                   	leave  
  8003ef:	c3                   	ret    

008003f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	57                   	push   %edi
  8003f4:	56                   	push   %esi
  8003f5:	53                   	push   %ebx
  8003f6:	83 ec 1c             	sub    $0x1c,%esp
  8003f9:	89 c7                	mov    %eax,%edi
  8003fb:	89 d6                	mov    %edx,%esi
  8003fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800400:	8b 55 0c             	mov    0xc(%ebp),%edx
  800403:	89 d1                	mov    %edx,%ecx
  800405:	89 c2                	mov    %eax,%edx
  800407:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80040d:	8b 45 10             	mov    0x10(%ebp),%eax
  800410:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800413:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800416:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80041d:	39 c2                	cmp    %eax,%edx
  80041f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800422:	72 3e                	jb     800462 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800424:	83 ec 0c             	sub    $0xc,%esp
  800427:	ff 75 18             	push   0x18(%ebp)
  80042a:	83 eb 01             	sub    $0x1,%ebx
  80042d:	53                   	push   %ebx
  80042e:	50                   	push   %eax
  80042f:	83 ec 08             	sub    $0x8,%esp
  800432:	ff 75 e4             	push   -0x1c(%ebp)
  800435:	ff 75 e0             	push   -0x20(%ebp)
  800438:	ff 75 dc             	push   -0x24(%ebp)
  80043b:	ff 75 d8             	push   -0x28(%ebp)
  80043e:	e8 1d 21 00 00       	call   802560 <__udivdi3>
  800443:	83 c4 18             	add    $0x18,%esp
  800446:	52                   	push   %edx
  800447:	50                   	push   %eax
  800448:	89 f2                	mov    %esi,%edx
  80044a:	89 f8                	mov    %edi,%eax
  80044c:	e8 9f ff ff ff       	call   8003f0 <printnum>
  800451:	83 c4 20             	add    $0x20,%esp
  800454:	eb 13                	jmp    800469 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800456:	83 ec 08             	sub    $0x8,%esp
  800459:	56                   	push   %esi
  80045a:	ff 75 18             	push   0x18(%ebp)
  80045d:	ff d7                	call   *%edi
  80045f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800462:	83 eb 01             	sub    $0x1,%ebx
  800465:	85 db                	test   %ebx,%ebx
  800467:	7f ed                	jg     800456 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	56                   	push   %esi
  80046d:	83 ec 04             	sub    $0x4,%esp
  800470:	ff 75 e4             	push   -0x1c(%ebp)
  800473:	ff 75 e0             	push   -0x20(%ebp)
  800476:	ff 75 dc             	push   -0x24(%ebp)
  800479:	ff 75 d8             	push   -0x28(%ebp)
  80047c:	e8 ff 21 00 00       	call   802680 <__umoddi3>
  800481:	83 c4 14             	add    $0x14,%esp
  800484:	0f be 80 a3 28 80 00 	movsbl 0x8028a3(%eax),%eax
  80048b:	50                   	push   %eax
  80048c:	ff d7                	call   *%edi
}
  80048e:	83 c4 10             	add    $0x10,%esp
  800491:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800494:	5b                   	pop    %ebx
  800495:	5e                   	pop    %esi
  800496:	5f                   	pop    %edi
  800497:	5d                   	pop    %ebp
  800498:	c3                   	ret    

00800499 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800499:	55                   	push   %ebp
  80049a:	89 e5                	mov    %esp,%ebp
  80049c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80049f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004a3:	8b 10                	mov    (%eax),%edx
  8004a5:	3b 50 04             	cmp    0x4(%eax),%edx
  8004a8:	73 0a                	jae    8004b4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004aa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004ad:	89 08                	mov    %ecx,(%eax)
  8004af:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b2:	88 02                	mov    %al,(%edx)
}
  8004b4:	5d                   	pop    %ebp
  8004b5:	c3                   	ret    

008004b6 <printfmt>:
{
  8004b6:	55                   	push   %ebp
  8004b7:	89 e5                	mov    %esp,%ebp
  8004b9:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004bc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004bf:	50                   	push   %eax
  8004c0:	ff 75 10             	push   0x10(%ebp)
  8004c3:	ff 75 0c             	push   0xc(%ebp)
  8004c6:	ff 75 08             	push   0x8(%ebp)
  8004c9:	e8 05 00 00 00       	call   8004d3 <vprintfmt>
}
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	c9                   	leave  
  8004d2:	c3                   	ret    

008004d3 <vprintfmt>:
{
  8004d3:	55                   	push   %ebp
  8004d4:	89 e5                	mov    %esp,%ebp
  8004d6:	57                   	push   %edi
  8004d7:	56                   	push   %esi
  8004d8:	53                   	push   %ebx
  8004d9:	83 ec 3c             	sub    $0x3c,%esp
  8004dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004e5:	eb 0a                	jmp    8004f1 <vprintfmt+0x1e>
			putch(ch, putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	53                   	push   %ebx
  8004eb:	50                   	push   %eax
  8004ec:	ff d6                	call   *%esi
  8004ee:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004f1:	83 c7 01             	add    $0x1,%edi
  8004f4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f8:	83 f8 25             	cmp    $0x25,%eax
  8004fb:	74 0c                	je     800509 <vprintfmt+0x36>
			if (ch == '\0')
  8004fd:	85 c0                	test   %eax,%eax
  8004ff:	75 e6                	jne    8004e7 <vprintfmt+0x14>
}
  800501:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800504:	5b                   	pop    %ebx
  800505:	5e                   	pop    %esi
  800506:	5f                   	pop    %edi
  800507:	5d                   	pop    %ebp
  800508:	c3                   	ret    
		padc = ' ';
  800509:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80050d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800514:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80051b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800522:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8d 47 01             	lea    0x1(%edi),%eax
  80052a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80052d:	0f b6 17             	movzbl (%edi),%edx
  800530:	8d 42 dd             	lea    -0x23(%edx),%eax
  800533:	3c 55                	cmp    $0x55,%al
  800535:	0f 87 bb 03 00 00    	ja     8008f6 <vprintfmt+0x423>
  80053b:	0f b6 c0             	movzbl %al,%eax
  80053e:	ff 24 85 e0 29 80 00 	jmp    *0x8029e0(,%eax,4)
  800545:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800548:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80054c:	eb d9                	jmp    800527 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800551:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800555:	eb d0                	jmp    800527 <vprintfmt+0x54>
  800557:	0f b6 d2             	movzbl %dl,%edx
  80055a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80055d:	b8 00 00 00 00       	mov    $0x0,%eax
  800562:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800565:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800568:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80056c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80056f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800572:	83 f9 09             	cmp    $0x9,%ecx
  800575:	77 55                	ja     8005cc <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800577:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80057a:	eb e9                	jmp    800565 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8d 40 04             	lea    0x4(%eax),%eax
  80058a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800590:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800594:	79 91                	jns    800527 <vprintfmt+0x54>
				width = precision, precision = -1;
  800596:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800599:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80059c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005a3:	eb 82                	jmp    800527 <vprintfmt+0x54>
  8005a5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005a8:	85 d2                	test   %edx,%edx
  8005aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8005af:	0f 49 c2             	cmovns %edx,%eax
  8005b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005b8:	e9 6a ff ff ff       	jmp    800527 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005c0:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005c7:	e9 5b ff ff ff       	jmp    800527 <vprintfmt+0x54>
  8005cc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d2:	eb bc                	jmp    800590 <vprintfmt+0xbd>
			lflag++;
  8005d4:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005da:	e9 48 ff ff ff       	jmp    800527 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 78 04             	lea    0x4(%eax),%edi
  8005e5:	83 ec 08             	sub    $0x8,%esp
  8005e8:	53                   	push   %ebx
  8005e9:	ff 30                	push   (%eax)
  8005eb:	ff d6                	call   *%esi
			break;
  8005ed:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005f0:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005f3:	e9 9d 02 00 00       	jmp    800895 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 78 04             	lea    0x4(%eax),%edi
  8005fe:	8b 10                	mov    (%eax),%edx
  800600:	89 d0                	mov    %edx,%eax
  800602:	f7 d8                	neg    %eax
  800604:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800607:	83 f8 0f             	cmp    $0xf,%eax
  80060a:	7f 23                	jg     80062f <vprintfmt+0x15c>
  80060c:	8b 14 85 40 2b 80 00 	mov    0x802b40(,%eax,4),%edx
  800613:	85 d2                	test   %edx,%edx
  800615:	74 18                	je     80062f <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800617:	52                   	push   %edx
  800618:	68 61 2d 80 00       	push   $0x802d61
  80061d:	53                   	push   %ebx
  80061e:	56                   	push   %esi
  80061f:	e8 92 fe ff ff       	call   8004b6 <printfmt>
  800624:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800627:	89 7d 14             	mov    %edi,0x14(%ebp)
  80062a:	e9 66 02 00 00       	jmp    800895 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80062f:	50                   	push   %eax
  800630:	68 bb 28 80 00       	push   $0x8028bb
  800635:	53                   	push   %ebx
  800636:	56                   	push   %esi
  800637:	e8 7a fe ff ff       	call   8004b6 <printfmt>
  80063c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80063f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800642:	e9 4e 02 00 00       	jmp    800895 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	83 c0 04             	add    $0x4,%eax
  80064d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800655:	85 d2                	test   %edx,%edx
  800657:	b8 b4 28 80 00       	mov    $0x8028b4,%eax
  80065c:	0f 45 c2             	cmovne %edx,%eax
  80065f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800662:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800666:	7e 06                	jle    80066e <vprintfmt+0x19b>
  800668:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80066c:	75 0d                	jne    80067b <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80066e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800671:	89 c7                	mov    %eax,%edi
  800673:	03 45 e0             	add    -0x20(%ebp),%eax
  800676:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800679:	eb 55                	jmp    8006d0 <vprintfmt+0x1fd>
  80067b:	83 ec 08             	sub    $0x8,%esp
  80067e:	ff 75 d8             	push   -0x28(%ebp)
  800681:	ff 75 cc             	push   -0x34(%ebp)
  800684:	e8 0a 03 00 00       	call   800993 <strnlen>
  800689:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80068c:	29 c1                	sub    %eax,%ecx
  80068e:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800696:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80069a:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80069d:	eb 0f                	jmp    8006ae <vprintfmt+0x1db>
					putch(padc, putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	ff 75 e0             	push   -0x20(%ebp)
  8006a6:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a8:	83 ef 01             	sub    $0x1,%edi
  8006ab:	83 c4 10             	add    $0x10,%esp
  8006ae:	85 ff                	test   %edi,%edi
  8006b0:	7f ed                	jg     80069f <vprintfmt+0x1cc>
  8006b2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006b5:	85 d2                	test   %edx,%edx
  8006b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bc:	0f 49 c2             	cmovns %edx,%eax
  8006bf:	29 c2                	sub    %eax,%edx
  8006c1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006c4:	eb a8                	jmp    80066e <vprintfmt+0x19b>
					putch(ch, putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	52                   	push   %edx
  8006cb:	ff d6                	call   *%esi
  8006cd:	83 c4 10             	add    $0x10,%esp
  8006d0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006d3:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d5:	83 c7 01             	add    $0x1,%edi
  8006d8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006dc:	0f be d0             	movsbl %al,%edx
  8006df:	85 d2                	test   %edx,%edx
  8006e1:	74 4b                	je     80072e <vprintfmt+0x25b>
  8006e3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006e7:	78 06                	js     8006ef <vprintfmt+0x21c>
  8006e9:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8006ed:	78 1e                	js     80070d <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8006ef:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006f3:	74 d1                	je     8006c6 <vprintfmt+0x1f3>
  8006f5:	0f be c0             	movsbl %al,%eax
  8006f8:	83 e8 20             	sub    $0x20,%eax
  8006fb:	83 f8 5e             	cmp    $0x5e,%eax
  8006fe:	76 c6                	jbe    8006c6 <vprintfmt+0x1f3>
					putch('?', putdat);
  800700:	83 ec 08             	sub    $0x8,%esp
  800703:	53                   	push   %ebx
  800704:	6a 3f                	push   $0x3f
  800706:	ff d6                	call   *%esi
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	eb c3                	jmp    8006d0 <vprintfmt+0x1fd>
  80070d:	89 cf                	mov    %ecx,%edi
  80070f:	eb 0e                	jmp    80071f <vprintfmt+0x24c>
				putch(' ', putdat);
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	53                   	push   %ebx
  800715:	6a 20                	push   $0x20
  800717:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800719:	83 ef 01             	sub    $0x1,%edi
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	85 ff                	test   %edi,%edi
  800721:	7f ee                	jg     800711 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800723:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800726:	89 45 14             	mov    %eax,0x14(%ebp)
  800729:	e9 67 01 00 00       	jmp    800895 <vprintfmt+0x3c2>
  80072e:	89 cf                	mov    %ecx,%edi
  800730:	eb ed                	jmp    80071f <vprintfmt+0x24c>
	if (lflag >= 2)
  800732:	83 f9 01             	cmp    $0x1,%ecx
  800735:	7f 1b                	jg     800752 <vprintfmt+0x27f>
	else if (lflag)
  800737:	85 c9                	test   %ecx,%ecx
  800739:	74 63                	je     80079e <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80073b:	8b 45 14             	mov    0x14(%ebp),%eax
  80073e:	8b 00                	mov    (%eax),%eax
  800740:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800743:	99                   	cltd   
  800744:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8d 40 04             	lea    0x4(%eax),%eax
  80074d:	89 45 14             	mov    %eax,0x14(%ebp)
  800750:	eb 17                	jmp    800769 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800752:	8b 45 14             	mov    0x14(%ebp),%eax
  800755:	8b 50 04             	mov    0x4(%eax),%edx
  800758:	8b 00                	mov    (%eax),%eax
  80075a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80075d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800760:	8b 45 14             	mov    0x14(%ebp),%eax
  800763:	8d 40 08             	lea    0x8(%eax),%eax
  800766:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800769:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80076c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80076f:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800774:	85 c9                	test   %ecx,%ecx
  800776:	0f 89 ff 00 00 00    	jns    80087b <vprintfmt+0x3a8>
				putch('-', putdat);
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	53                   	push   %ebx
  800780:	6a 2d                	push   $0x2d
  800782:	ff d6                	call   *%esi
				num = -(long long) num;
  800784:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800787:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80078a:	f7 da                	neg    %edx
  80078c:	83 d1 00             	adc    $0x0,%ecx
  80078f:	f7 d9                	neg    %ecx
  800791:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800794:	bf 0a 00 00 00       	mov    $0xa,%edi
  800799:	e9 dd 00 00 00       	jmp    80087b <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8b 00                	mov    (%eax),%eax
  8007a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a6:	99                   	cltd   
  8007a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8d 40 04             	lea    0x4(%eax),%eax
  8007b0:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b3:	eb b4                	jmp    800769 <vprintfmt+0x296>
	if (lflag >= 2)
  8007b5:	83 f9 01             	cmp    $0x1,%ecx
  8007b8:	7f 1e                	jg     8007d8 <vprintfmt+0x305>
	else if (lflag)
  8007ba:	85 c9                	test   %ecx,%ecx
  8007bc:	74 32                	je     8007f0 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8007be:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c1:	8b 10                	mov    (%eax),%edx
  8007c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c8:	8d 40 04             	lea    0x4(%eax),%eax
  8007cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007ce:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8007d3:	e9 a3 00 00 00       	jmp    80087b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007db:	8b 10                	mov    (%eax),%edx
  8007dd:	8b 48 04             	mov    0x4(%eax),%ecx
  8007e0:	8d 40 08             	lea    0x8(%eax),%eax
  8007e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007e6:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8007eb:	e9 8b 00 00 00       	jmp    80087b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f3:	8b 10                	mov    (%eax),%edx
  8007f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fa:	8d 40 04             	lea    0x4(%eax),%eax
  8007fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800800:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800805:	eb 74                	jmp    80087b <vprintfmt+0x3a8>
	if (lflag >= 2)
  800807:	83 f9 01             	cmp    $0x1,%ecx
  80080a:	7f 1b                	jg     800827 <vprintfmt+0x354>
	else if (lflag)
  80080c:	85 c9                	test   %ecx,%ecx
  80080e:	74 2c                	je     80083c <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	8b 10                	mov    (%eax),%edx
  800815:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081a:	8d 40 04             	lea    0x4(%eax),%eax
  80081d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800820:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800825:	eb 54                	jmp    80087b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800827:	8b 45 14             	mov    0x14(%ebp),%eax
  80082a:	8b 10                	mov    (%eax),%edx
  80082c:	8b 48 04             	mov    0x4(%eax),%ecx
  80082f:	8d 40 08             	lea    0x8(%eax),%eax
  800832:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800835:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80083a:	eb 3f                	jmp    80087b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	8b 10                	mov    (%eax),%edx
  800841:	b9 00 00 00 00       	mov    $0x0,%ecx
  800846:	8d 40 04             	lea    0x4(%eax),%eax
  800849:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80084c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800851:	eb 28                	jmp    80087b <vprintfmt+0x3a8>
			putch('0', putdat);
  800853:	83 ec 08             	sub    $0x8,%esp
  800856:	53                   	push   %ebx
  800857:	6a 30                	push   $0x30
  800859:	ff d6                	call   *%esi
			putch('x', putdat);
  80085b:	83 c4 08             	add    $0x8,%esp
  80085e:	53                   	push   %ebx
  80085f:	6a 78                	push   $0x78
  800861:	ff d6                	call   *%esi
			num = (unsigned long long)
  800863:	8b 45 14             	mov    0x14(%ebp),%eax
  800866:	8b 10                	mov    (%eax),%edx
  800868:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80086d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800870:	8d 40 04             	lea    0x4(%eax),%eax
  800873:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800876:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80087b:	83 ec 0c             	sub    $0xc,%esp
  80087e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800882:	50                   	push   %eax
  800883:	ff 75 e0             	push   -0x20(%ebp)
  800886:	57                   	push   %edi
  800887:	51                   	push   %ecx
  800888:	52                   	push   %edx
  800889:	89 da                	mov    %ebx,%edx
  80088b:	89 f0                	mov    %esi,%eax
  80088d:	e8 5e fb ff ff       	call   8003f0 <printnum>
			break;
  800892:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800895:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800898:	e9 54 fc ff ff       	jmp    8004f1 <vprintfmt+0x1e>
	if (lflag >= 2)
  80089d:	83 f9 01             	cmp    $0x1,%ecx
  8008a0:	7f 1b                	jg     8008bd <vprintfmt+0x3ea>
	else if (lflag)
  8008a2:	85 c9                	test   %ecx,%ecx
  8008a4:	74 2c                	je     8008d2 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8008a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a9:	8b 10                	mov    (%eax),%edx
  8008ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b0:	8d 40 04             	lea    0x4(%eax),%eax
  8008b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008b6:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8008bb:	eb be                	jmp    80087b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8008bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c0:	8b 10                	mov    (%eax),%edx
  8008c2:	8b 48 04             	mov    0x4(%eax),%ecx
  8008c5:	8d 40 08             	lea    0x8(%eax),%eax
  8008c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008cb:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8008d0:	eb a9                	jmp    80087b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8008d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d5:	8b 10                	mov    (%eax),%edx
  8008d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008dc:	8d 40 04             	lea    0x4(%eax),%eax
  8008df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008e2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8008e7:	eb 92                	jmp    80087b <vprintfmt+0x3a8>
			putch(ch, putdat);
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	53                   	push   %ebx
  8008ed:	6a 25                	push   $0x25
  8008ef:	ff d6                	call   *%esi
			break;
  8008f1:	83 c4 10             	add    $0x10,%esp
  8008f4:	eb 9f                	jmp    800895 <vprintfmt+0x3c2>
			putch('%', putdat);
  8008f6:	83 ec 08             	sub    $0x8,%esp
  8008f9:	53                   	push   %ebx
  8008fa:	6a 25                	push   $0x25
  8008fc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	89 f8                	mov    %edi,%eax
  800903:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800907:	74 05                	je     80090e <vprintfmt+0x43b>
  800909:	83 e8 01             	sub    $0x1,%eax
  80090c:	eb f5                	jmp    800903 <vprintfmt+0x430>
  80090e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800911:	eb 82                	jmp    800895 <vprintfmt+0x3c2>

00800913 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	83 ec 18             	sub    $0x18,%esp
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80091f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800922:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800926:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800929:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800930:	85 c0                	test   %eax,%eax
  800932:	74 26                	je     80095a <vsnprintf+0x47>
  800934:	85 d2                	test   %edx,%edx
  800936:	7e 22                	jle    80095a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800938:	ff 75 14             	push   0x14(%ebp)
  80093b:	ff 75 10             	push   0x10(%ebp)
  80093e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800941:	50                   	push   %eax
  800942:	68 99 04 80 00       	push   $0x800499
  800947:	e8 87 fb ff ff       	call   8004d3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80094c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80094f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800952:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800955:	83 c4 10             	add    $0x10,%esp
}
  800958:	c9                   	leave  
  800959:	c3                   	ret    
		return -E_INVAL;
  80095a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80095f:	eb f7                	jmp    800958 <vsnprintf+0x45>

00800961 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800967:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80096a:	50                   	push   %eax
  80096b:	ff 75 10             	push   0x10(%ebp)
  80096e:	ff 75 0c             	push   0xc(%ebp)
  800971:	ff 75 08             	push   0x8(%ebp)
  800974:	e8 9a ff ff ff       	call   800913 <vsnprintf>
	va_end(ap);

	return rc;
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800981:	b8 00 00 00 00       	mov    $0x0,%eax
  800986:	eb 03                	jmp    80098b <strlen+0x10>
		n++;
  800988:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80098b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80098f:	75 f7                	jne    800988 <strlen+0xd>
	return n;
}
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800999:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099c:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a1:	eb 03                	jmp    8009a6 <strnlen+0x13>
		n++;
  8009a3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a6:	39 d0                	cmp    %edx,%eax
  8009a8:	74 08                	je     8009b2 <strnlen+0x1f>
  8009aa:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009ae:	75 f3                	jne    8009a3 <strnlen+0x10>
  8009b0:	89 c2                	mov    %eax,%edx
	return n;
}
  8009b2:	89 d0                	mov    %edx,%eax
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	53                   	push   %ebx
  8009ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c5:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8009c9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8009cc:	83 c0 01             	add    $0x1,%eax
  8009cf:	84 d2                	test   %dl,%dl
  8009d1:	75 f2                	jne    8009c5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009d3:	89 c8                	mov    %ecx,%eax
  8009d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d8:	c9                   	leave  
  8009d9:	c3                   	ret    

008009da <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	53                   	push   %ebx
  8009de:	83 ec 10             	sub    $0x10,%esp
  8009e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009e4:	53                   	push   %ebx
  8009e5:	e8 91 ff ff ff       	call   80097b <strlen>
  8009ea:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8009ed:	ff 75 0c             	push   0xc(%ebp)
  8009f0:	01 d8                	add    %ebx,%eax
  8009f2:	50                   	push   %eax
  8009f3:	e8 be ff ff ff       	call   8009b6 <strcpy>
	return dst;
}
  8009f8:	89 d8                	mov    %ebx,%eax
  8009fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 75 08             	mov    0x8(%ebp),%esi
  800a07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0a:	89 f3                	mov    %esi,%ebx
  800a0c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a0f:	89 f0                	mov    %esi,%eax
  800a11:	eb 0f                	jmp    800a22 <strncpy+0x23>
		*dst++ = *src;
  800a13:	83 c0 01             	add    $0x1,%eax
  800a16:	0f b6 0a             	movzbl (%edx),%ecx
  800a19:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a1c:	80 f9 01             	cmp    $0x1,%cl
  800a1f:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800a22:	39 d8                	cmp    %ebx,%eax
  800a24:	75 ed                	jne    800a13 <strncpy+0x14>
	}
	return ret;
}
  800a26:	89 f0                	mov    %esi,%eax
  800a28:	5b                   	pop    %ebx
  800a29:	5e                   	pop    %esi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	56                   	push   %esi
  800a30:	53                   	push   %ebx
  800a31:	8b 75 08             	mov    0x8(%ebp),%esi
  800a34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a37:	8b 55 10             	mov    0x10(%ebp),%edx
  800a3a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a3c:	85 d2                	test   %edx,%edx
  800a3e:	74 21                	je     800a61 <strlcpy+0x35>
  800a40:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a44:	89 f2                	mov    %esi,%edx
  800a46:	eb 09                	jmp    800a51 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a48:	83 c1 01             	add    $0x1,%ecx
  800a4b:	83 c2 01             	add    $0x1,%edx
  800a4e:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800a51:	39 c2                	cmp    %eax,%edx
  800a53:	74 09                	je     800a5e <strlcpy+0x32>
  800a55:	0f b6 19             	movzbl (%ecx),%ebx
  800a58:	84 db                	test   %bl,%bl
  800a5a:	75 ec                	jne    800a48 <strlcpy+0x1c>
  800a5c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a5e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a61:	29 f0                	sub    %esi,%eax
}
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a70:	eb 06                	jmp    800a78 <strcmp+0x11>
		p++, q++;
  800a72:	83 c1 01             	add    $0x1,%ecx
  800a75:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a78:	0f b6 01             	movzbl (%ecx),%eax
  800a7b:	84 c0                	test   %al,%al
  800a7d:	74 04                	je     800a83 <strcmp+0x1c>
  800a7f:	3a 02                	cmp    (%edx),%al
  800a81:	74 ef                	je     800a72 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a83:	0f b6 c0             	movzbl %al,%eax
  800a86:	0f b6 12             	movzbl (%edx),%edx
  800a89:	29 d0                	sub    %edx,%eax
}
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	53                   	push   %ebx
  800a91:	8b 45 08             	mov    0x8(%ebp),%eax
  800a94:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a97:	89 c3                	mov    %eax,%ebx
  800a99:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a9c:	eb 06                	jmp    800aa4 <strncmp+0x17>
		n--, p++, q++;
  800a9e:	83 c0 01             	add    $0x1,%eax
  800aa1:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800aa4:	39 d8                	cmp    %ebx,%eax
  800aa6:	74 18                	je     800ac0 <strncmp+0x33>
  800aa8:	0f b6 08             	movzbl (%eax),%ecx
  800aab:	84 c9                	test   %cl,%cl
  800aad:	74 04                	je     800ab3 <strncmp+0x26>
  800aaf:	3a 0a                	cmp    (%edx),%cl
  800ab1:	74 eb                	je     800a9e <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab3:	0f b6 00             	movzbl (%eax),%eax
  800ab6:	0f b6 12             	movzbl (%edx),%edx
  800ab9:	29 d0                	sub    %edx,%eax
}
  800abb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800abe:	c9                   	leave  
  800abf:	c3                   	ret    
		return 0;
  800ac0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac5:	eb f4                	jmp    800abb <strncmp+0x2e>

00800ac7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	8b 45 08             	mov    0x8(%ebp),%eax
  800acd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad1:	eb 03                	jmp    800ad6 <strchr+0xf>
  800ad3:	83 c0 01             	add    $0x1,%eax
  800ad6:	0f b6 10             	movzbl (%eax),%edx
  800ad9:	84 d2                	test   %dl,%dl
  800adb:	74 06                	je     800ae3 <strchr+0x1c>
		if (*s == c)
  800add:	38 ca                	cmp    %cl,%dl
  800adf:	75 f2                	jne    800ad3 <strchr+0xc>
  800ae1:	eb 05                	jmp    800ae8 <strchr+0x21>
			return (char *) s;
	return 0;
  800ae3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
  800af0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800af7:	38 ca                	cmp    %cl,%dl
  800af9:	74 09                	je     800b04 <strfind+0x1a>
  800afb:	84 d2                	test   %dl,%dl
  800afd:	74 05                	je     800b04 <strfind+0x1a>
	for (; *s; s++)
  800aff:	83 c0 01             	add    $0x1,%eax
  800b02:	eb f0                	jmp    800af4 <strfind+0xa>
			break;
	return (char *) s;
}
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
  800b0c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b12:	85 c9                	test   %ecx,%ecx
  800b14:	74 2f                	je     800b45 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b16:	89 f8                	mov    %edi,%eax
  800b18:	09 c8                	or     %ecx,%eax
  800b1a:	a8 03                	test   $0x3,%al
  800b1c:	75 21                	jne    800b3f <memset+0x39>
		c &= 0xFF;
  800b1e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b22:	89 d0                	mov    %edx,%eax
  800b24:	c1 e0 08             	shl    $0x8,%eax
  800b27:	89 d3                	mov    %edx,%ebx
  800b29:	c1 e3 18             	shl    $0x18,%ebx
  800b2c:	89 d6                	mov    %edx,%esi
  800b2e:	c1 e6 10             	shl    $0x10,%esi
  800b31:	09 f3                	or     %esi,%ebx
  800b33:	09 da                	or     %ebx,%edx
  800b35:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b37:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b3a:	fc                   	cld    
  800b3b:	f3 ab                	rep stos %eax,%es:(%edi)
  800b3d:	eb 06                	jmp    800b45 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b42:	fc                   	cld    
  800b43:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b45:	89 f8                	mov    %edi,%eax
  800b47:	5b                   	pop    %ebx
  800b48:	5e                   	pop    %esi
  800b49:	5f                   	pop    %edi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	8b 45 08             	mov    0x8(%ebp),%eax
  800b54:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b57:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b5a:	39 c6                	cmp    %eax,%esi
  800b5c:	73 32                	jae    800b90 <memmove+0x44>
  800b5e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b61:	39 c2                	cmp    %eax,%edx
  800b63:	76 2b                	jbe    800b90 <memmove+0x44>
		s += n;
		d += n;
  800b65:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	09 fe                	or     %edi,%esi
  800b6c:	09 ce                	or     %ecx,%esi
  800b6e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b74:	75 0e                	jne    800b84 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b76:	83 ef 04             	sub    $0x4,%edi
  800b79:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b7c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b7f:	fd                   	std    
  800b80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b82:	eb 09                	jmp    800b8d <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b84:	83 ef 01             	sub    $0x1,%edi
  800b87:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b8a:	fd                   	std    
  800b8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b8d:	fc                   	cld    
  800b8e:	eb 1a                	jmp    800baa <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b90:	89 f2                	mov    %esi,%edx
  800b92:	09 c2                	or     %eax,%edx
  800b94:	09 ca                	or     %ecx,%edx
  800b96:	f6 c2 03             	test   $0x3,%dl
  800b99:	75 0a                	jne    800ba5 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b9b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b9e:	89 c7                	mov    %eax,%edi
  800ba0:	fc                   	cld    
  800ba1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba3:	eb 05                	jmp    800baa <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800ba5:	89 c7                	mov    %eax,%edi
  800ba7:	fc                   	cld    
  800ba8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bb4:	ff 75 10             	push   0x10(%ebp)
  800bb7:	ff 75 0c             	push   0xc(%ebp)
  800bba:	ff 75 08             	push   0x8(%ebp)
  800bbd:	e8 8a ff ff ff       	call   800b4c <memmove>
}
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcf:	89 c6                	mov    %eax,%esi
  800bd1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd4:	eb 06                	jmp    800bdc <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bd6:	83 c0 01             	add    $0x1,%eax
  800bd9:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800bdc:	39 f0                	cmp    %esi,%eax
  800bde:	74 14                	je     800bf4 <memcmp+0x30>
		if (*s1 != *s2)
  800be0:	0f b6 08             	movzbl (%eax),%ecx
  800be3:	0f b6 1a             	movzbl (%edx),%ebx
  800be6:	38 d9                	cmp    %bl,%cl
  800be8:	74 ec                	je     800bd6 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800bea:	0f b6 c1             	movzbl %cl,%eax
  800bed:	0f b6 db             	movzbl %bl,%ebx
  800bf0:	29 d8                	sub    %ebx,%eax
  800bf2:	eb 05                	jmp    800bf9 <memcmp+0x35>
	}

	return 0;
  800bf4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	8b 45 08             	mov    0x8(%ebp),%eax
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c06:	89 c2                	mov    %eax,%edx
  800c08:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c0b:	eb 03                	jmp    800c10 <memfind+0x13>
  800c0d:	83 c0 01             	add    $0x1,%eax
  800c10:	39 d0                	cmp    %edx,%eax
  800c12:	73 04                	jae    800c18 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c14:	38 08                	cmp    %cl,(%eax)
  800c16:	75 f5                	jne    800c0d <memfind+0x10>
			break;
	return (void *) s;
}
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	8b 55 08             	mov    0x8(%ebp),%edx
  800c23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c26:	eb 03                	jmp    800c2b <strtol+0x11>
		s++;
  800c28:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c2b:	0f b6 02             	movzbl (%edx),%eax
  800c2e:	3c 20                	cmp    $0x20,%al
  800c30:	74 f6                	je     800c28 <strtol+0xe>
  800c32:	3c 09                	cmp    $0x9,%al
  800c34:	74 f2                	je     800c28 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c36:	3c 2b                	cmp    $0x2b,%al
  800c38:	74 2a                	je     800c64 <strtol+0x4a>
	int neg = 0;
  800c3a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c3f:	3c 2d                	cmp    $0x2d,%al
  800c41:	74 2b                	je     800c6e <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c43:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c49:	75 0f                	jne    800c5a <strtol+0x40>
  800c4b:	80 3a 30             	cmpb   $0x30,(%edx)
  800c4e:	74 28                	je     800c78 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c50:	85 db                	test   %ebx,%ebx
  800c52:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c57:	0f 44 d8             	cmove  %eax,%ebx
  800c5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c5f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c62:	eb 46                	jmp    800caa <strtol+0x90>
		s++;
  800c64:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c67:	bf 00 00 00 00       	mov    $0x0,%edi
  800c6c:	eb d5                	jmp    800c43 <strtol+0x29>
		s++, neg = 1;
  800c6e:	83 c2 01             	add    $0x1,%edx
  800c71:	bf 01 00 00 00       	mov    $0x1,%edi
  800c76:	eb cb                	jmp    800c43 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c78:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c7c:	74 0e                	je     800c8c <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800c7e:	85 db                	test   %ebx,%ebx
  800c80:	75 d8                	jne    800c5a <strtol+0x40>
		s++, base = 8;
  800c82:	83 c2 01             	add    $0x1,%edx
  800c85:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c8a:	eb ce                	jmp    800c5a <strtol+0x40>
		s += 2, base = 16;
  800c8c:	83 c2 02             	add    $0x2,%edx
  800c8f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c94:	eb c4                	jmp    800c5a <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c96:	0f be c0             	movsbl %al,%eax
  800c99:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c9c:	3b 45 10             	cmp    0x10(%ebp),%eax
  800c9f:	7d 3a                	jge    800cdb <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ca1:	83 c2 01             	add    $0x1,%edx
  800ca4:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ca8:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800caa:	0f b6 02             	movzbl (%edx),%eax
  800cad:	8d 70 d0             	lea    -0x30(%eax),%esi
  800cb0:	89 f3                	mov    %esi,%ebx
  800cb2:	80 fb 09             	cmp    $0x9,%bl
  800cb5:	76 df                	jbe    800c96 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800cb7:	8d 70 9f             	lea    -0x61(%eax),%esi
  800cba:	89 f3                	mov    %esi,%ebx
  800cbc:	80 fb 19             	cmp    $0x19,%bl
  800cbf:	77 08                	ja     800cc9 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800cc1:	0f be c0             	movsbl %al,%eax
  800cc4:	83 e8 57             	sub    $0x57,%eax
  800cc7:	eb d3                	jmp    800c9c <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800cc9:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ccc:	89 f3                	mov    %esi,%ebx
  800cce:	80 fb 19             	cmp    $0x19,%bl
  800cd1:	77 08                	ja     800cdb <strtol+0xc1>
			dig = *s - 'A' + 10;
  800cd3:	0f be c0             	movsbl %al,%eax
  800cd6:	83 e8 37             	sub    $0x37,%eax
  800cd9:	eb c1                	jmp    800c9c <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800cdb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cdf:	74 05                	je     800ce6 <strtol+0xcc>
		*endptr = (char *) s;
  800ce1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce4:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ce6:	89 c8                	mov    %ecx,%eax
  800ce8:	f7 d8                	neg    %eax
  800cea:	85 ff                	test   %edi,%edi
  800cec:	0f 45 c8             	cmovne %eax,%ecx
}
  800cef:	89 c8                	mov    %ecx,%eax
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	57                   	push   %edi
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cfc:	b8 00 00 00 00       	mov    $0x0,%eax
  800d01:	8b 55 08             	mov    0x8(%ebp),%edx
  800d04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d07:	89 c3                	mov    %eax,%ebx
  800d09:	89 c7                	mov    %eax,%edi
  800d0b:	89 c6                	mov    %eax,%esi
  800d0d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d24:	89 d1                	mov    %edx,%ecx
  800d26:	89 d3                	mov    %edx,%ebx
  800d28:	89 d7                	mov    %edx,%edi
  800d2a:	89 d6                	mov    %edx,%esi
  800d2c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	b8 03 00 00 00       	mov    $0x3,%eax
  800d49:	89 cb                	mov    %ecx,%ebx
  800d4b:	89 cf                	mov    %ecx,%edi
  800d4d:	89 ce                	mov    %ecx,%esi
  800d4f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d51:	85 c0                	test   %eax,%eax
  800d53:	7f 08                	jg     800d5d <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	83 ec 0c             	sub    $0xc,%esp
  800d60:	50                   	push   %eax
  800d61:	6a 03                	push   $0x3
  800d63:	68 9f 2b 80 00       	push   $0x802b9f
  800d68:	6a 2a                	push   $0x2a
  800d6a:	68 bc 2b 80 00       	push   $0x802bbc
  800d6f:	e8 8d f5 ff ff       	call   800301 <_panic>

00800d74 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7f:	b8 02 00 00 00       	mov    $0x2,%eax
  800d84:	89 d1                	mov    %edx,%ecx
  800d86:	89 d3                	mov    %edx,%ebx
  800d88:	89 d7                	mov    %edx,%edi
  800d8a:	89 d6                	mov    %edx,%esi
  800d8c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <sys_yield>:

void
sys_yield(void)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d99:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800da3:	89 d1                	mov    %edx,%ecx
  800da5:	89 d3                	mov    %edx,%ebx
  800da7:	89 d7                	mov    %edx,%edi
  800da9:	89 d6                	mov    %edx,%esi
  800dab:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    

00800db2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
  800db8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dbb:	be 00 00 00 00       	mov    $0x0,%esi
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc6:	b8 04 00 00 00       	mov    $0x4,%eax
  800dcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dce:	89 f7                	mov    %esi,%edi
  800dd0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	7f 08                	jg     800dde <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dde:	83 ec 0c             	sub    $0xc,%esp
  800de1:	50                   	push   %eax
  800de2:	6a 04                	push   $0x4
  800de4:	68 9f 2b 80 00       	push   $0x802b9f
  800de9:	6a 2a                	push   $0x2a
  800deb:	68 bc 2b 80 00       	push   $0x802bbc
  800df0:	e8 0c f5 ff ff       	call   800301 <_panic>

00800df5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	57                   	push   %edi
  800df9:	56                   	push   %esi
  800dfa:	53                   	push   %ebx
  800dfb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e04:	b8 05 00 00 00       	mov    $0x5,%eax
  800e09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e0f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e12:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e14:	85 c0                	test   %eax,%eax
  800e16:	7f 08                	jg     800e20 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e20:	83 ec 0c             	sub    $0xc,%esp
  800e23:	50                   	push   %eax
  800e24:	6a 05                	push   $0x5
  800e26:	68 9f 2b 80 00       	push   $0x802b9f
  800e2b:	6a 2a                	push   $0x2a
  800e2d:	68 bc 2b 80 00       	push   $0x802bbc
  800e32:	e8 ca f4 ff ff       	call   800301 <_panic>

00800e37 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	57                   	push   %edi
  800e3b:	56                   	push   %esi
  800e3c:	53                   	push   %ebx
  800e3d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e40:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e45:	8b 55 08             	mov    0x8(%ebp),%edx
  800e48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4b:	b8 06 00 00 00       	mov    $0x6,%eax
  800e50:	89 df                	mov    %ebx,%edi
  800e52:	89 de                	mov    %ebx,%esi
  800e54:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e56:	85 c0                	test   %eax,%eax
  800e58:	7f 08                	jg     800e62 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e62:	83 ec 0c             	sub    $0xc,%esp
  800e65:	50                   	push   %eax
  800e66:	6a 06                	push   $0x6
  800e68:	68 9f 2b 80 00       	push   $0x802b9f
  800e6d:	6a 2a                	push   $0x2a
  800e6f:	68 bc 2b 80 00       	push   $0x802bbc
  800e74:	e8 88 f4 ff ff       	call   800301 <_panic>

00800e79 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	57                   	push   %edi
  800e7d:	56                   	push   %esi
  800e7e:	53                   	push   %ebx
  800e7f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e82:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e87:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8d:	b8 08 00 00 00       	mov    $0x8,%eax
  800e92:	89 df                	mov    %ebx,%edi
  800e94:	89 de                	mov    %ebx,%esi
  800e96:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e98:	85 c0                	test   %eax,%eax
  800e9a:	7f 08                	jg     800ea4 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	5f                   	pop    %edi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea4:	83 ec 0c             	sub    $0xc,%esp
  800ea7:	50                   	push   %eax
  800ea8:	6a 08                	push   $0x8
  800eaa:	68 9f 2b 80 00       	push   $0x802b9f
  800eaf:	6a 2a                	push   $0x2a
  800eb1:	68 bc 2b 80 00       	push   $0x802bbc
  800eb6:	e8 46 f4 ff ff       	call   800301 <_panic>

00800ebb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	57                   	push   %edi
  800ebf:	56                   	push   %esi
  800ec0:	53                   	push   %ebx
  800ec1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ec4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecf:	b8 09 00 00 00       	mov    $0x9,%eax
  800ed4:	89 df                	mov    %ebx,%edi
  800ed6:	89 de                	mov    %ebx,%esi
  800ed8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eda:	85 c0                	test   %eax,%eax
  800edc:	7f 08                	jg     800ee6 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ede:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee1:	5b                   	pop    %ebx
  800ee2:	5e                   	pop    %esi
  800ee3:	5f                   	pop    %edi
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee6:	83 ec 0c             	sub    $0xc,%esp
  800ee9:	50                   	push   %eax
  800eea:	6a 09                	push   $0x9
  800eec:	68 9f 2b 80 00       	push   $0x802b9f
  800ef1:	6a 2a                	push   $0x2a
  800ef3:	68 bc 2b 80 00       	push   $0x802bbc
  800ef8:	e8 04 f4 ff ff       	call   800301 <_panic>

00800efd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	57                   	push   %edi
  800f01:	56                   	push   %esi
  800f02:	53                   	push   %ebx
  800f03:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f11:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f16:	89 df                	mov    %ebx,%edi
  800f18:	89 de                	mov    %ebx,%esi
  800f1a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	7f 08                	jg     800f28 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f23:	5b                   	pop    %ebx
  800f24:	5e                   	pop    %esi
  800f25:	5f                   	pop    %edi
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f28:	83 ec 0c             	sub    $0xc,%esp
  800f2b:	50                   	push   %eax
  800f2c:	6a 0a                	push   $0xa
  800f2e:	68 9f 2b 80 00       	push   $0x802b9f
  800f33:	6a 2a                	push   $0x2a
  800f35:	68 bc 2b 80 00       	push   $0x802bbc
  800f3a:	e8 c2 f3 ff ff       	call   800301 <_panic>

00800f3f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	57                   	push   %edi
  800f43:	56                   	push   %esi
  800f44:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f45:	8b 55 08             	mov    0x8(%ebp),%edx
  800f48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f50:	be 00 00 00 00       	mov    $0x0,%esi
  800f55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f58:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f5b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f5d:	5b                   	pop    %ebx
  800f5e:	5e                   	pop    %esi
  800f5f:	5f                   	pop    %edi
  800f60:	5d                   	pop    %ebp
  800f61:	c3                   	ret    

00800f62 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f62:	55                   	push   %ebp
  800f63:	89 e5                	mov    %esp,%ebp
  800f65:	57                   	push   %edi
  800f66:	56                   	push   %esi
  800f67:	53                   	push   %ebx
  800f68:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f6b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f70:	8b 55 08             	mov    0x8(%ebp),%edx
  800f73:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f78:	89 cb                	mov    %ecx,%ebx
  800f7a:	89 cf                	mov    %ecx,%edi
  800f7c:	89 ce                	mov    %ecx,%esi
  800f7e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f80:	85 c0                	test   %eax,%eax
  800f82:	7f 08                	jg     800f8c <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f87:	5b                   	pop    %ebx
  800f88:	5e                   	pop    %esi
  800f89:	5f                   	pop    %edi
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8c:	83 ec 0c             	sub    $0xc,%esp
  800f8f:	50                   	push   %eax
  800f90:	6a 0d                	push   $0xd
  800f92:	68 9f 2b 80 00       	push   $0x802b9f
  800f97:	6a 2a                	push   $0x2a
  800f99:	68 bc 2b 80 00       	push   $0x802bbc
  800f9e:	e8 5e f3 ff ff       	call   800301 <_panic>

00800fa3 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	57                   	push   %edi
  800fa7:	56                   	push   %esi
  800fa8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fa9:	ba 00 00 00 00       	mov    $0x0,%edx
  800fae:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fb3:	89 d1                	mov    %edx,%ecx
  800fb5:	89 d3                	mov    %edx,%ebx
  800fb7:	89 d7                	mov    %edx,%edi
  800fb9:	89 d6                	mov    %edx,%esi
  800fbb:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800fbd:	5b                   	pop    %ebx
  800fbe:	5e                   	pop    %esi
  800fbf:	5f                   	pop    %edi
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    

00800fc2 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	57                   	push   %edi
  800fc6:	56                   	push   %esi
  800fc7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd3:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fd8:	89 df                	mov    %ebx,%edi
  800fda:	89 de                	mov    %ebx,%esi
  800fdc:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800fde:	5b                   	pop    %ebx
  800fdf:	5e                   	pop    %esi
  800fe0:	5f                   	pop    %edi
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	57                   	push   %edi
  800fe7:	56                   	push   %esi
  800fe8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fe9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff4:	b8 10 00 00 00       	mov    $0x10,%eax
  800ff9:	89 df                	mov    %ebx,%edi
  800ffb:	89 de                	mov    %ebx,%esi
  800ffd:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800fff:	5b                   	pop    %ebx
  801000:	5e                   	pop    %esi
  801001:	5f                   	pop    %edi
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    

00801004 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	56                   	push   %esi
  801008:	53                   	push   %ebx
  801009:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80100c:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  80100e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801012:	0f 84 8e 00 00 00    	je     8010a6 <pgfault+0xa2>
  801018:	89 f0                	mov    %esi,%eax
  80101a:	c1 e8 0c             	shr    $0xc,%eax
  80101d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801024:	f6 c4 08             	test   $0x8,%ah
  801027:	74 7d                	je     8010a6 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  801029:	e8 46 fd ff ff       	call   800d74 <sys_getenvid>
  80102e:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  801030:	83 ec 04             	sub    $0x4,%esp
  801033:	6a 07                	push   $0x7
  801035:	68 00 f0 7f 00       	push   $0x7ff000
  80103a:	50                   	push   %eax
  80103b:	e8 72 fd ff ff       	call   800db2 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  801040:	83 c4 10             	add    $0x10,%esp
  801043:	85 c0                	test   %eax,%eax
  801045:	78 73                	js     8010ba <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  801047:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  80104d:	83 ec 04             	sub    $0x4,%esp
  801050:	68 00 10 00 00       	push   $0x1000
  801055:	56                   	push   %esi
  801056:	68 00 f0 7f 00       	push   $0x7ff000
  80105b:	e8 ec fa ff ff       	call   800b4c <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  801060:	83 c4 08             	add    $0x8,%esp
  801063:	56                   	push   %esi
  801064:	53                   	push   %ebx
  801065:	e8 cd fd ff ff       	call   800e37 <sys_page_unmap>
  80106a:	83 c4 10             	add    $0x10,%esp
  80106d:	85 c0                	test   %eax,%eax
  80106f:	78 5b                	js     8010cc <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  801071:	83 ec 0c             	sub    $0xc,%esp
  801074:	6a 07                	push   $0x7
  801076:	56                   	push   %esi
  801077:	53                   	push   %ebx
  801078:	68 00 f0 7f 00       	push   $0x7ff000
  80107d:	53                   	push   %ebx
  80107e:	e8 72 fd ff ff       	call   800df5 <sys_page_map>
  801083:	83 c4 20             	add    $0x20,%esp
  801086:	85 c0                	test   %eax,%eax
  801088:	78 54                	js     8010de <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  80108a:	83 ec 08             	sub    $0x8,%esp
  80108d:	68 00 f0 7f 00       	push   $0x7ff000
  801092:	53                   	push   %ebx
  801093:	e8 9f fd ff ff       	call   800e37 <sys_page_unmap>
  801098:	83 c4 10             	add    $0x10,%esp
  80109b:	85 c0                	test   %eax,%eax
  80109d:	78 51                	js     8010f0 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  80109f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010a2:	5b                   	pop    %ebx
  8010a3:	5e                   	pop    %esi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  8010a6:	83 ec 04             	sub    $0x4,%esp
  8010a9:	68 cc 2b 80 00       	push   $0x802bcc
  8010ae:	6a 1d                	push   $0x1d
  8010b0:	68 48 2c 80 00       	push   $0x802c48
  8010b5:	e8 47 f2 ff ff       	call   800301 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  8010ba:	50                   	push   %eax
  8010bb:	68 04 2c 80 00       	push   $0x802c04
  8010c0:	6a 29                	push   $0x29
  8010c2:	68 48 2c 80 00       	push   $0x802c48
  8010c7:	e8 35 f2 ff ff       	call   800301 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  8010cc:	50                   	push   %eax
  8010cd:	68 28 2c 80 00       	push   $0x802c28
  8010d2:	6a 2e                	push   $0x2e
  8010d4:	68 48 2c 80 00       	push   $0x802c48
  8010d9:	e8 23 f2 ff ff       	call   800301 <_panic>
		panic("pgfault: page map failed (%e)", r);
  8010de:	50                   	push   %eax
  8010df:	68 53 2c 80 00       	push   $0x802c53
  8010e4:	6a 30                	push   $0x30
  8010e6:	68 48 2c 80 00       	push   $0x802c48
  8010eb:	e8 11 f2 ff ff       	call   800301 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  8010f0:	50                   	push   %eax
  8010f1:	68 28 2c 80 00       	push   $0x802c28
  8010f6:	6a 32                	push   $0x32
  8010f8:	68 48 2c 80 00       	push   $0x802c48
  8010fd:	e8 ff f1 ff ff       	call   800301 <_panic>

00801102 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	57                   	push   %edi
  801106:	56                   	push   %esi
  801107:	53                   	push   %ebx
  801108:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  80110b:	68 04 10 80 00       	push   $0x801004
  801110:	e8 6f 13 00 00       	call   802484 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801115:	b8 07 00 00 00       	mov    $0x7,%eax
  80111a:	cd 30                	int    $0x30
  80111c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  80111f:	83 c4 10             	add    $0x10,%esp
  801122:	85 c0                	test   %eax,%eax
  801124:	78 2d                	js     801153 <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801126:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  80112b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80112f:	75 73                	jne    8011a4 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  801131:	e8 3e fc ff ff       	call   800d74 <sys_getenvid>
  801136:	25 ff 03 00 00       	and    $0x3ff,%eax
  80113b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80113e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801143:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801148:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  80114b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114e:	5b                   	pop    %ebx
  80114f:	5e                   	pop    %esi
  801150:	5f                   	pop    %edi
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  801153:	50                   	push   %eax
  801154:	68 71 2c 80 00       	push   $0x802c71
  801159:	6a 78                	push   $0x78
  80115b:	68 48 2c 80 00       	push   $0x802c48
  801160:	e8 9c f1 ff ff       	call   800301 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  801165:	83 ec 0c             	sub    $0xc,%esp
  801168:	ff 75 e4             	push   -0x1c(%ebp)
  80116b:	57                   	push   %edi
  80116c:	ff 75 dc             	push   -0x24(%ebp)
  80116f:	57                   	push   %edi
  801170:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801173:	56                   	push   %esi
  801174:	e8 7c fc ff ff       	call   800df5 <sys_page_map>
	if(r<0) return r;
  801179:	83 c4 20             	add    $0x20,%esp
  80117c:	85 c0                	test   %eax,%eax
  80117e:	78 cb                	js     80114b <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  801180:	83 ec 0c             	sub    $0xc,%esp
  801183:	ff 75 e4             	push   -0x1c(%ebp)
  801186:	57                   	push   %edi
  801187:	56                   	push   %esi
  801188:	57                   	push   %edi
  801189:	56                   	push   %esi
  80118a:	e8 66 fc ff ff       	call   800df5 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  80118f:	83 c4 20             	add    $0x20,%esp
  801192:	85 c0                	test   %eax,%eax
  801194:	78 76                	js     80120c <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801196:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80119c:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011a2:	74 75                	je     801219 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  8011a4:	89 d8                	mov    %ebx,%eax
  8011a6:	c1 e8 16             	shr    $0x16,%eax
  8011a9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011b0:	a8 01                	test   $0x1,%al
  8011b2:	74 e2                	je     801196 <fork+0x94>
  8011b4:	89 de                	mov    %ebx,%esi
  8011b6:	c1 ee 0c             	shr    $0xc,%esi
  8011b9:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011c0:	a8 01                	test   $0x1,%al
  8011c2:	74 d2                	je     801196 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  8011c4:	e8 ab fb ff ff       	call   800d74 <sys_getenvid>
  8011c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  8011cc:	89 f7                	mov    %esi,%edi
  8011ce:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  8011d1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011d8:	89 c1                	mov    %eax,%ecx
  8011da:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  8011e0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  8011e3:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  8011ea:	f6 c6 04             	test   $0x4,%dh
  8011ed:	0f 85 72 ff ff ff    	jne    801165 <fork+0x63>
		perm &= ~PTE_W;
  8011f3:	25 05 0e 00 00       	and    $0xe05,%eax
  8011f8:	80 cc 08             	or     $0x8,%ah
  8011fb:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  801201:	0f 44 c1             	cmove  %ecx,%eax
  801204:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801207:	e9 59 ff ff ff       	jmp    801165 <fork+0x63>
  80120c:	ba 00 00 00 00       	mov    $0x0,%edx
  801211:	0f 4f c2             	cmovg  %edx,%eax
  801214:	e9 32 ff ff ff       	jmp    80114b <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801219:	83 ec 04             	sub    $0x4,%esp
  80121c:	6a 07                	push   $0x7
  80121e:	68 00 f0 bf ee       	push   $0xeebff000
  801223:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801226:	57                   	push   %edi
  801227:	e8 86 fb ff ff       	call   800db2 <sys_page_alloc>
	if(r<0) return r;
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	85 c0                	test   %eax,%eax
  801231:	0f 88 14 ff ff ff    	js     80114b <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801237:	83 ec 08             	sub    $0x8,%esp
  80123a:	68 fa 24 80 00       	push   $0x8024fa
  80123f:	57                   	push   %edi
  801240:	e8 b8 fc ff ff       	call   800efd <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801245:	83 c4 10             	add    $0x10,%esp
  801248:	85 c0                	test   %eax,%eax
  80124a:	0f 88 fb fe ff ff    	js     80114b <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801250:	83 ec 08             	sub    $0x8,%esp
  801253:	6a 02                	push   $0x2
  801255:	57                   	push   %edi
  801256:	e8 1e fc ff ff       	call   800e79 <sys_env_set_status>
	if(r<0) return r;
  80125b:	83 c4 10             	add    $0x10,%esp
	return envid;
  80125e:	85 c0                	test   %eax,%eax
  801260:	0f 49 c7             	cmovns %edi,%eax
  801263:	e9 e3 fe ff ff       	jmp    80114b <fork+0x49>

00801268 <sfork>:

// Challenge!
int
sfork(void)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80126e:	68 81 2c 80 00       	push   $0x802c81
  801273:	68 a1 00 00 00       	push   $0xa1
  801278:	68 48 2c 80 00       	push   $0x802c48
  80127d:	e8 7f f0 ff ff       	call   800301 <_panic>

00801282 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	56                   	push   %esi
  801286:	53                   	push   %ebx
  801287:	8b 75 08             	mov    0x8(%ebp),%esi
  80128a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801290:	85 c0                	test   %eax,%eax
  801292:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801297:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  80129a:	83 ec 0c             	sub    $0xc,%esp
  80129d:	50                   	push   %eax
  80129e:	e8 bf fc ff ff       	call   800f62 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	85 f6                	test   %esi,%esi
  8012a8:	74 14                	je     8012be <ipc_recv+0x3c>
  8012aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	78 09                	js     8012bc <ipc_recv+0x3a>
  8012b3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8012b9:	8b 52 74             	mov    0x74(%edx),%edx
  8012bc:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8012be:	85 db                	test   %ebx,%ebx
  8012c0:	74 14                	je     8012d6 <ipc_recv+0x54>
  8012c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c7:	85 c0                	test   %eax,%eax
  8012c9:	78 09                	js     8012d4 <ipc_recv+0x52>
  8012cb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8012d1:	8b 52 78             	mov    0x78(%edx),%edx
  8012d4:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	78 08                	js     8012e2 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  8012da:	a1 04 40 80 00       	mov    0x804004,%eax
  8012df:	8b 40 70             	mov    0x70(%eax),%eax
}
  8012e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e5:	5b                   	pop    %ebx
  8012e6:	5e                   	pop    %esi
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    

008012e9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	57                   	push   %edi
  8012ed:	56                   	push   %esi
  8012ee:	53                   	push   %ebx
  8012ef:	83 ec 0c             	sub    $0xc,%esp
  8012f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8012fb:	85 db                	test   %ebx,%ebx
  8012fd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801302:	0f 44 d8             	cmove  %eax,%ebx
  801305:	eb 05                	jmp    80130c <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801307:	e8 87 fa ff ff       	call   800d93 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80130c:	ff 75 14             	push   0x14(%ebp)
  80130f:	53                   	push   %ebx
  801310:	56                   	push   %esi
  801311:	57                   	push   %edi
  801312:	e8 28 fc ff ff       	call   800f3f <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801317:	83 c4 10             	add    $0x10,%esp
  80131a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80131d:	74 e8                	je     801307 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80131f:	85 c0                	test   %eax,%eax
  801321:	78 08                	js     80132b <ipc_send+0x42>
	}while (r<0);

}
  801323:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801326:	5b                   	pop    %ebx
  801327:	5e                   	pop    %esi
  801328:	5f                   	pop    %edi
  801329:	5d                   	pop    %ebp
  80132a:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80132b:	50                   	push   %eax
  80132c:	68 97 2c 80 00       	push   $0x802c97
  801331:	6a 3d                	push   $0x3d
  801333:	68 ab 2c 80 00       	push   $0x802cab
  801338:	e8 c4 ef ff ff       	call   800301 <_panic>

0080133d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801343:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801348:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80134b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801351:	8b 52 50             	mov    0x50(%edx),%edx
  801354:	39 ca                	cmp    %ecx,%edx
  801356:	74 11                	je     801369 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801358:	83 c0 01             	add    $0x1,%eax
  80135b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801360:	75 e6                	jne    801348 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801362:	b8 00 00 00 00       	mov    $0x0,%eax
  801367:	eb 0b                	jmp    801374 <ipc_find_env+0x37>
			return envs[i].env_id;
  801369:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80136c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801371:	8b 40 48             	mov    0x48(%eax),%eax
}
  801374:	5d                   	pop    %ebp
  801375:	c3                   	ret    

00801376 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801379:	8b 45 08             	mov    0x8(%ebp),%eax
  80137c:	05 00 00 00 30       	add    $0x30000000,%eax
  801381:	c1 e8 0c             	shr    $0xc,%eax
}
  801384:	5d                   	pop    %ebp
  801385:	c3                   	ret    

00801386 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801389:	8b 45 08             	mov    0x8(%ebp),%eax
  80138c:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801391:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801396:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    

0080139d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013a5:	89 c2                	mov    %eax,%edx
  8013a7:	c1 ea 16             	shr    $0x16,%edx
  8013aa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013b1:	f6 c2 01             	test   $0x1,%dl
  8013b4:	74 29                	je     8013df <fd_alloc+0x42>
  8013b6:	89 c2                	mov    %eax,%edx
  8013b8:	c1 ea 0c             	shr    $0xc,%edx
  8013bb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013c2:	f6 c2 01             	test   $0x1,%dl
  8013c5:	74 18                	je     8013df <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8013c7:	05 00 10 00 00       	add    $0x1000,%eax
  8013cc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013d1:	75 d2                	jne    8013a5 <fd_alloc+0x8>
  8013d3:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8013d8:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8013dd:	eb 05                	jmp    8013e4 <fd_alloc+0x47>
			return 0;
  8013df:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8013e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8013e7:	89 02                	mov    %eax,(%edx)
}
  8013e9:	89 c8                	mov    %ecx,%eax
  8013eb:	5d                   	pop    %ebp
  8013ec:	c3                   	ret    

008013ed <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013f3:	83 f8 1f             	cmp    $0x1f,%eax
  8013f6:	77 30                	ja     801428 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013f8:	c1 e0 0c             	shl    $0xc,%eax
  8013fb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801400:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801406:	f6 c2 01             	test   $0x1,%dl
  801409:	74 24                	je     80142f <fd_lookup+0x42>
  80140b:	89 c2                	mov    %eax,%edx
  80140d:	c1 ea 0c             	shr    $0xc,%edx
  801410:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801417:	f6 c2 01             	test   $0x1,%dl
  80141a:	74 1a                	je     801436 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80141c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80141f:	89 02                	mov    %eax,(%edx)
	return 0;
  801421:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    
		return -E_INVAL;
  801428:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80142d:	eb f7                	jmp    801426 <fd_lookup+0x39>
		return -E_INVAL;
  80142f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801434:	eb f0                	jmp    801426 <fd_lookup+0x39>
  801436:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80143b:	eb e9                	jmp    801426 <fd_lookup+0x39>

0080143d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80143d:	55                   	push   %ebp
  80143e:	89 e5                	mov    %esp,%ebp
  801440:	53                   	push   %ebx
  801441:	83 ec 04             	sub    $0x4,%esp
  801444:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801447:	b8 00 00 00 00       	mov    $0x0,%eax
  80144c:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801451:	39 13                	cmp    %edx,(%ebx)
  801453:	74 37                	je     80148c <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  801455:	83 c0 01             	add    $0x1,%eax
  801458:	8b 1c 85 34 2d 80 00 	mov    0x802d34(,%eax,4),%ebx
  80145f:	85 db                	test   %ebx,%ebx
  801461:	75 ee                	jne    801451 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801463:	a1 04 40 80 00       	mov    0x804004,%eax
  801468:	8b 40 48             	mov    0x48(%eax),%eax
  80146b:	83 ec 04             	sub    $0x4,%esp
  80146e:	52                   	push   %edx
  80146f:	50                   	push   %eax
  801470:	68 b8 2c 80 00       	push   $0x802cb8
  801475:	e8 62 ef ff ff       	call   8003dc <cprintf>
	*dev = 0;
	return -E_INVAL;
  80147a:	83 c4 10             	add    $0x10,%esp
  80147d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801482:	8b 55 0c             	mov    0xc(%ebp),%edx
  801485:	89 1a                	mov    %ebx,(%edx)
}
  801487:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148a:	c9                   	leave  
  80148b:	c3                   	ret    
			return 0;
  80148c:	b8 00 00 00 00       	mov    $0x0,%eax
  801491:	eb ef                	jmp    801482 <dev_lookup+0x45>

00801493 <fd_close>:
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	57                   	push   %edi
  801497:	56                   	push   %esi
  801498:	53                   	push   %ebx
  801499:	83 ec 24             	sub    $0x24,%esp
  80149c:	8b 75 08             	mov    0x8(%ebp),%esi
  80149f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014a5:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014a6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014ac:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014af:	50                   	push   %eax
  8014b0:	e8 38 ff ff ff       	call   8013ed <fd_lookup>
  8014b5:	89 c3                	mov    %eax,%ebx
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 05                	js     8014c3 <fd_close+0x30>
	    || fd != fd2)
  8014be:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8014c1:	74 16                	je     8014d9 <fd_close+0x46>
		return (must_exist ? r : 0);
  8014c3:	89 f8                	mov    %edi,%eax
  8014c5:	84 c0                	test   %al,%al
  8014c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8014cc:	0f 44 d8             	cmove  %eax,%ebx
}
  8014cf:	89 d8                	mov    %ebx,%eax
  8014d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014d4:	5b                   	pop    %ebx
  8014d5:	5e                   	pop    %esi
  8014d6:	5f                   	pop    %edi
  8014d7:	5d                   	pop    %ebp
  8014d8:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014d9:	83 ec 08             	sub    $0x8,%esp
  8014dc:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8014df:	50                   	push   %eax
  8014e0:	ff 36                	push   (%esi)
  8014e2:	e8 56 ff ff ff       	call   80143d <dev_lookup>
  8014e7:	89 c3                	mov    %eax,%ebx
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	78 1a                	js     80150a <fd_close+0x77>
		if (dev->dev_close)
  8014f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014f3:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8014f6:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	74 0b                	je     80150a <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8014ff:	83 ec 0c             	sub    $0xc,%esp
  801502:	56                   	push   %esi
  801503:	ff d0                	call   *%eax
  801505:	89 c3                	mov    %eax,%ebx
  801507:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80150a:	83 ec 08             	sub    $0x8,%esp
  80150d:	56                   	push   %esi
  80150e:	6a 00                	push   $0x0
  801510:	e8 22 f9 ff ff       	call   800e37 <sys_page_unmap>
	return r;
  801515:	83 c4 10             	add    $0x10,%esp
  801518:	eb b5                	jmp    8014cf <fd_close+0x3c>

0080151a <close>:

int
close(int fdnum)
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801520:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801523:	50                   	push   %eax
  801524:	ff 75 08             	push   0x8(%ebp)
  801527:	e8 c1 fe ff ff       	call   8013ed <fd_lookup>
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	85 c0                	test   %eax,%eax
  801531:	79 02                	jns    801535 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801533:	c9                   	leave  
  801534:	c3                   	ret    
		return fd_close(fd, 1);
  801535:	83 ec 08             	sub    $0x8,%esp
  801538:	6a 01                	push   $0x1
  80153a:	ff 75 f4             	push   -0xc(%ebp)
  80153d:	e8 51 ff ff ff       	call   801493 <fd_close>
  801542:	83 c4 10             	add    $0x10,%esp
  801545:	eb ec                	jmp    801533 <close+0x19>

00801547 <close_all>:

void
close_all(void)
{
  801547:	55                   	push   %ebp
  801548:	89 e5                	mov    %esp,%ebp
  80154a:	53                   	push   %ebx
  80154b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80154e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801553:	83 ec 0c             	sub    $0xc,%esp
  801556:	53                   	push   %ebx
  801557:	e8 be ff ff ff       	call   80151a <close>
	for (i = 0; i < MAXFD; i++)
  80155c:	83 c3 01             	add    $0x1,%ebx
  80155f:	83 c4 10             	add    $0x10,%esp
  801562:	83 fb 20             	cmp    $0x20,%ebx
  801565:	75 ec                	jne    801553 <close_all+0xc>
}
  801567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156a:	c9                   	leave  
  80156b:	c3                   	ret    

0080156c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	57                   	push   %edi
  801570:	56                   	push   %esi
  801571:	53                   	push   %ebx
  801572:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801575:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801578:	50                   	push   %eax
  801579:	ff 75 08             	push   0x8(%ebp)
  80157c:	e8 6c fe ff ff       	call   8013ed <fd_lookup>
  801581:	89 c3                	mov    %eax,%ebx
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	85 c0                	test   %eax,%eax
  801588:	78 7f                	js     801609 <dup+0x9d>
		return r;
	close(newfdnum);
  80158a:	83 ec 0c             	sub    $0xc,%esp
  80158d:	ff 75 0c             	push   0xc(%ebp)
  801590:	e8 85 ff ff ff       	call   80151a <close>

	newfd = INDEX2FD(newfdnum);
  801595:	8b 75 0c             	mov    0xc(%ebp),%esi
  801598:	c1 e6 0c             	shl    $0xc,%esi
  80159b:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8015a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015a4:	89 3c 24             	mov    %edi,(%esp)
  8015a7:	e8 da fd ff ff       	call   801386 <fd2data>
  8015ac:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015ae:	89 34 24             	mov    %esi,(%esp)
  8015b1:	e8 d0 fd ff ff       	call   801386 <fd2data>
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015bc:	89 d8                	mov    %ebx,%eax
  8015be:	c1 e8 16             	shr    $0x16,%eax
  8015c1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015c8:	a8 01                	test   $0x1,%al
  8015ca:	74 11                	je     8015dd <dup+0x71>
  8015cc:	89 d8                	mov    %ebx,%eax
  8015ce:	c1 e8 0c             	shr    $0xc,%eax
  8015d1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015d8:	f6 c2 01             	test   $0x1,%dl
  8015db:	75 36                	jne    801613 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015dd:	89 f8                	mov    %edi,%eax
  8015df:	c1 e8 0c             	shr    $0xc,%eax
  8015e2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015e9:	83 ec 0c             	sub    $0xc,%esp
  8015ec:	25 07 0e 00 00       	and    $0xe07,%eax
  8015f1:	50                   	push   %eax
  8015f2:	56                   	push   %esi
  8015f3:	6a 00                	push   $0x0
  8015f5:	57                   	push   %edi
  8015f6:	6a 00                	push   $0x0
  8015f8:	e8 f8 f7 ff ff       	call   800df5 <sys_page_map>
  8015fd:	89 c3                	mov    %eax,%ebx
  8015ff:	83 c4 20             	add    $0x20,%esp
  801602:	85 c0                	test   %eax,%eax
  801604:	78 33                	js     801639 <dup+0xcd>
		goto err;

	return newfdnum;
  801606:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801609:	89 d8                	mov    %ebx,%eax
  80160b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160e:	5b                   	pop    %ebx
  80160f:	5e                   	pop    %esi
  801610:	5f                   	pop    %edi
  801611:	5d                   	pop    %ebp
  801612:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801613:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80161a:	83 ec 0c             	sub    $0xc,%esp
  80161d:	25 07 0e 00 00       	and    $0xe07,%eax
  801622:	50                   	push   %eax
  801623:	ff 75 d4             	push   -0x2c(%ebp)
  801626:	6a 00                	push   $0x0
  801628:	53                   	push   %ebx
  801629:	6a 00                	push   $0x0
  80162b:	e8 c5 f7 ff ff       	call   800df5 <sys_page_map>
  801630:	89 c3                	mov    %eax,%ebx
  801632:	83 c4 20             	add    $0x20,%esp
  801635:	85 c0                	test   %eax,%eax
  801637:	79 a4                	jns    8015dd <dup+0x71>
	sys_page_unmap(0, newfd);
  801639:	83 ec 08             	sub    $0x8,%esp
  80163c:	56                   	push   %esi
  80163d:	6a 00                	push   $0x0
  80163f:	e8 f3 f7 ff ff       	call   800e37 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801644:	83 c4 08             	add    $0x8,%esp
  801647:	ff 75 d4             	push   -0x2c(%ebp)
  80164a:	6a 00                	push   $0x0
  80164c:	e8 e6 f7 ff ff       	call   800e37 <sys_page_unmap>
	return r;
  801651:	83 c4 10             	add    $0x10,%esp
  801654:	eb b3                	jmp    801609 <dup+0x9d>

00801656 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	56                   	push   %esi
  80165a:	53                   	push   %ebx
  80165b:	83 ec 18             	sub    $0x18,%esp
  80165e:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801661:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801664:	50                   	push   %eax
  801665:	56                   	push   %esi
  801666:	e8 82 fd ff ff       	call   8013ed <fd_lookup>
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	85 c0                	test   %eax,%eax
  801670:	78 3c                	js     8016ae <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801672:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801675:	83 ec 08             	sub    $0x8,%esp
  801678:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167b:	50                   	push   %eax
  80167c:	ff 33                	push   (%ebx)
  80167e:	e8 ba fd ff ff       	call   80143d <dev_lookup>
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	85 c0                	test   %eax,%eax
  801688:	78 24                	js     8016ae <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80168a:	8b 43 08             	mov    0x8(%ebx),%eax
  80168d:	83 e0 03             	and    $0x3,%eax
  801690:	83 f8 01             	cmp    $0x1,%eax
  801693:	74 20                	je     8016b5 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801695:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801698:	8b 40 08             	mov    0x8(%eax),%eax
  80169b:	85 c0                	test   %eax,%eax
  80169d:	74 37                	je     8016d6 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80169f:	83 ec 04             	sub    $0x4,%esp
  8016a2:	ff 75 10             	push   0x10(%ebp)
  8016a5:	ff 75 0c             	push   0xc(%ebp)
  8016a8:	53                   	push   %ebx
  8016a9:	ff d0                	call   *%eax
  8016ab:	83 c4 10             	add    $0x10,%esp
}
  8016ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b1:	5b                   	pop    %ebx
  8016b2:	5e                   	pop    %esi
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016b5:	a1 04 40 80 00       	mov    0x804004,%eax
  8016ba:	8b 40 48             	mov    0x48(%eax),%eax
  8016bd:	83 ec 04             	sub    $0x4,%esp
  8016c0:	56                   	push   %esi
  8016c1:	50                   	push   %eax
  8016c2:	68 f9 2c 80 00       	push   $0x802cf9
  8016c7:	e8 10 ed ff ff       	call   8003dc <cprintf>
		return -E_INVAL;
  8016cc:	83 c4 10             	add    $0x10,%esp
  8016cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016d4:	eb d8                	jmp    8016ae <read+0x58>
		return -E_NOT_SUPP;
  8016d6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016db:	eb d1                	jmp    8016ae <read+0x58>

008016dd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	57                   	push   %edi
  8016e1:	56                   	push   %esi
  8016e2:	53                   	push   %ebx
  8016e3:	83 ec 0c             	sub    $0xc,%esp
  8016e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016e9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016f1:	eb 02                	jmp    8016f5 <readn+0x18>
  8016f3:	01 c3                	add    %eax,%ebx
  8016f5:	39 f3                	cmp    %esi,%ebx
  8016f7:	73 21                	jae    80171a <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016f9:	83 ec 04             	sub    $0x4,%esp
  8016fc:	89 f0                	mov    %esi,%eax
  8016fe:	29 d8                	sub    %ebx,%eax
  801700:	50                   	push   %eax
  801701:	89 d8                	mov    %ebx,%eax
  801703:	03 45 0c             	add    0xc(%ebp),%eax
  801706:	50                   	push   %eax
  801707:	57                   	push   %edi
  801708:	e8 49 ff ff ff       	call   801656 <read>
		if (m < 0)
  80170d:	83 c4 10             	add    $0x10,%esp
  801710:	85 c0                	test   %eax,%eax
  801712:	78 04                	js     801718 <readn+0x3b>
			return m;
		if (m == 0)
  801714:	75 dd                	jne    8016f3 <readn+0x16>
  801716:	eb 02                	jmp    80171a <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801718:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80171a:	89 d8                	mov    %ebx,%eax
  80171c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80171f:	5b                   	pop    %ebx
  801720:	5e                   	pop    %esi
  801721:	5f                   	pop    %edi
  801722:	5d                   	pop    %ebp
  801723:	c3                   	ret    

00801724 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	56                   	push   %esi
  801728:	53                   	push   %ebx
  801729:	83 ec 18             	sub    $0x18,%esp
  80172c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801732:	50                   	push   %eax
  801733:	53                   	push   %ebx
  801734:	e8 b4 fc ff ff       	call   8013ed <fd_lookup>
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	85 c0                	test   %eax,%eax
  80173e:	78 37                	js     801777 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801740:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801743:	83 ec 08             	sub    $0x8,%esp
  801746:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801749:	50                   	push   %eax
  80174a:	ff 36                	push   (%esi)
  80174c:	e8 ec fc ff ff       	call   80143d <dev_lookup>
  801751:	83 c4 10             	add    $0x10,%esp
  801754:	85 c0                	test   %eax,%eax
  801756:	78 1f                	js     801777 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801758:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80175c:	74 20                	je     80177e <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80175e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801761:	8b 40 0c             	mov    0xc(%eax),%eax
  801764:	85 c0                	test   %eax,%eax
  801766:	74 37                	je     80179f <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801768:	83 ec 04             	sub    $0x4,%esp
  80176b:	ff 75 10             	push   0x10(%ebp)
  80176e:	ff 75 0c             	push   0xc(%ebp)
  801771:	56                   	push   %esi
  801772:	ff d0                	call   *%eax
  801774:	83 c4 10             	add    $0x10,%esp
}
  801777:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80177a:	5b                   	pop    %ebx
  80177b:	5e                   	pop    %esi
  80177c:	5d                   	pop    %ebp
  80177d:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80177e:	a1 04 40 80 00       	mov    0x804004,%eax
  801783:	8b 40 48             	mov    0x48(%eax),%eax
  801786:	83 ec 04             	sub    $0x4,%esp
  801789:	53                   	push   %ebx
  80178a:	50                   	push   %eax
  80178b:	68 15 2d 80 00       	push   $0x802d15
  801790:	e8 47 ec ff ff       	call   8003dc <cprintf>
		return -E_INVAL;
  801795:	83 c4 10             	add    $0x10,%esp
  801798:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80179d:	eb d8                	jmp    801777 <write+0x53>
		return -E_NOT_SUPP;
  80179f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017a4:	eb d1                	jmp    801777 <write+0x53>

008017a6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017af:	50                   	push   %eax
  8017b0:	ff 75 08             	push   0x8(%ebp)
  8017b3:	e8 35 fc ff ff       	call   8013ed <fd_lookup>
  8017b8:	83 c4 10             	add    $0x10,%esp
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	78 0e                	js     8017cd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017cd:	c9                   	leave  
  8017ce:	c3                   	ret    

008017cf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	56                   	push   %esi
  8017d3:	53                   	push   %ebx
  8017d4:	83 ec 18             	sub    $0x18,%esp
  8017d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017dd:	50                   	push   %eax
  8017de:	53                   	push   %ebx
  8017df:	e8 09 fc ff ff       	call   8013ed <fd_lookup>
  8017e4:	83 c4 10             	add    $0x10,%esp
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	78 34                	js     80181f <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017eb:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8017ee:	83 ec 08             	sub    $0x8,%esp
  8017f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f4:	50                   	push   %eax
  8017f5:	ff 36                	push   (%esi)
  8017f7:	e8 41 fc ff ff       	call   80143d <dev_lookup>
  8017fc:	83 c4 10             	add    $0x10,%esp
  8017ff:	85 c0                	test   %eax,%eax
  801801:	78 1c                	js     80181f <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801803:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801807:	74 1d                	je     801826 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801809:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80180c:	8b 40 18             	mov    0x18(%eax),%eax
  80180f:	85 c0                	test   %eax,%eax
  801811:	74 34                	je     801847 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801813:	83 ec 08             	sub    $0x8,%esp
  801816:	ff 75 0c             	push   0xc(%ebp)
  801819:	56                   	push   %esi
  80181a:	ff d0                	call   *%eax
  80181c:	83 c4 10             	add    $0x10,%esp
}
  80181f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801822:	5b                   	pop    %ebx
  801823:	5e                   	pop    %esi
  801824:	5d                   	pop    %ebp
  801825:	c3                   	ret    
			thisenv->env_id, fdnum);
  801826:	a1 04 40 80 00       	mov    0x804004,%eax
  80182b:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80182e:	83 ec 04             	sub    $0x4,%esp
  801831:	53                   	push   %ebx
  801832:	50                   	push   %eax
  801833:	68 d8 2c 80 00       	push   $0x802cd8
  801838:	e8 9f eb ff ff       	call   8003dc <cprintf>
		return -E_INVAL;
  80183d:	83 c4 10             	add    $0x10,%esp
  801840:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801845:	eb d8                	jmp    80181f <ftruncate+0x50>
		return -E_NOT_SUPP;
  801847:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80184c:	eb d1                	jmp    80181f <ftruncate+0x50>

0080184e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	56                   	push   %esi
  801852:	53                   	push   %ebx
  801853:	83 ec 18             	sub    $0x18,%esp
  801856:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801859:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80185c:	50                   	push   %eax
  80185d:	ff 75 08             	push   0x8(%ebp)
  801860:	e8 88 fb ff ff       	call   8013ed <fd_lookup>
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	85 c0                	test   %eax,%eax
  80186a:	78 49                	js     8018b5 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80186c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80186f:	83 ec 08             	sub    $0x8,%esp
  801872:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801875:	50                   	push   %eax
  801876:	ff 36                	push   (%esi)
  801878:	e8 c0 fb ff ff       	call   80143d <dev_lookup>
  80187d:	83 c4 10             	add    $0x10,%esp
  801880:	85 c0                	test   %eax,%eax
  801882:	78 31                	js     8018b5 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801884:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801887:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80188b:	74 2f                	je     8018bc <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80188d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801890:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801897:	00 00 00 
	stat->st_isdir = 0;
  80189a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018a1:	00 00 00 
	stat->st_dev = dev;
  8018a4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018aa:	83 ec 08             	sub    $0x8,%esp
  8018ad:	53                   	push   %ebx
  8018ae:	56                   	push   %esi
  8018af:	ff 50 14             	call   *0x14(%eax)
  8018b2:	83 c4 10             	add    $0x10,%esp
}
  8018b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b8:	5b                   	pop    %ebx
  8018b9:	5e                   	pop    %esi
  8018ba:	5d                   	pop    %ebp
  8018bb:	c3                   	ret    
		return -E_NOT_SUPP;
  8018bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018c1:	eb f2                	jmp    8018b5 <fstat+0x67>

008018c3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	56                   	push   %esi
  8018c7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018c8:	83 ec 08             	sub    $0x8,%esp
  8018cb:	6a 00                	push   $0x0
  8018cd:	ff 75 08             	push   0x8(%ebp)
  8018d0:	e8 e4 01 00 00       	call   801ab9 <open>
  8018d5:	89 c3                	mov    %eax,%ebx
  8018d7:	83 c4 10             	add    $0x10,%esp
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	78 1b                	js     8018f9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018de:	83 ec 08             	sub    $0x8,%esp
  8018e1:	ff 75 0c             	push   0xc(%ebp)
  8018e4:	50                   	push   %eax
  8018e5:	e8 64 ff ff ff       	call   80184e <fstat>
  8018ea:	89 c6                	mov    %eax,%esi
	close(fd);
  8018ec:	89 1c 24             	mov    %ebx,(%esp)
  8018ef:	e8 26 fc ff ff       	call   80151a <close>
	return r;
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	89 f3                	mov    %esi,%ebx
}
  8018f9:	89 d8                	mov    %ebx,%eax
  8018fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fe:	5b                   	pop    %ebx
  8018ff:	5e                   	pop    %esi
  801900:	5d                   	pop    %ebp
  801901:	c3                   	ret    

00801902 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	56                   	push   %esi
  801906:	53                   	push   %ebx
  801907:	89 c6                	mov    %eax,%esi
  801909:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80190b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801912:	74 27                	je     80193b <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801914:	6a 07                	push   $0x7
  801916:	68 00 50 80 00       	push   $0x805000
  80191b:	56                   	push   %esi
  80191c:	ff 35 00 60 80 00    	push   0x806000
  801922:	e8 c2 f9 ff ff       	call   8012e9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801927:	83 c4 0c             	add    $0xc,%esp
  80192a:	6a 00                	push   $0x0
  80192c:	53                   	push   %ebx
  80192d:	6a 00                	push   $0x0
  80192f:	e8 4e f9 ff ff       	call   801282 <ipc_recv>
}
  801934:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801937:	5b                   	pop    %ebx
  801938:	5e                   	pop    %esi
  801939:	5d                   	pop    %ebp
  80193a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80193b:	83 ec 0c             	sub    $0xc,%esp
  80193e:	6a 01                	push   $0x1
  801940:	e8 f8 f9 ff ff       	call   80133d <ipc_find_env>
  801945:	a3 00 60 80 00       	mov    %eax,0x806000
  80194a:	83 c4 10             	add    $0x10,%esp
  80194d:	eb c5                	jmp    801914 <fsipc+0x12>

0080194f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80194f:	55                   	push   %ebp
  801950:	89 e5                	mov    %esp,%ebp
  801952:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801955:	8b 45 08             	mov    0x8(%ebp),%eax
  801958:	8b 40 0c             	mov    0xc(%eax),%eax
  80195b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801960:	8b 45 0c             	mov    0xc(%ebp),%eax
  801963:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801968:	ba 00 00 00 00       	mov    $0x0,%edx
  80196d:	b8 02 00 00 00       	mov    $0x2,%eax
  801972:	e8 8b ff ff ff       	call   801902 <fsipc>
}
  801977:	c9                   	leave  
  801978:	c3                   	ret    

00801979 <devfile_flush>:
{
  801979:	55                   	push   %ebp
  80197a:	89 e5                	mov    %esp,%ebp
  80197c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80197f:	8b 45 08             	mov    0x8(%ebp),%eax
  801982:	8b 40 0c             	mov    0xc(%eax),%eax
  801985:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80198a:	ba 00 00 00 00       	mov    $0x0,%edx
  80198f:	b8 06 00 00 00       	mov    $0x6,%eax
  801994:	e8 69 ff ff ff       	call   801902 <fsipc>
}
  801999:	c9                   	leave  
  80199a:	c3                   	ret    

0080199b <devfile_stat>:
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	53                   	push   %ebx
  80199f:	83 ec 04             	sub    $0x4,%esp
  8019a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ab:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8019ba:	e8 43 ff ff ff       	call   801902 <fsipc>
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	78 2c                	js     8019ef <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019c3:	83 ec 08             	sub    $0x8,%esp
  8019c6:	68 00 50 80 00       	push   $0x805000
  8019cb:	53                   	push   %ebx
  8019cc:	e8 e5 ef ff ff       	call   8009b6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019d1:	a1 80 50 80 00       	mov    0x805080,%eax
  8019d6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019dc:	a1 84 50 80 00       	mov    0x805084,%eax
  8019e1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f2:	c9                   	leave  
  8019f3:	c3                   	ret    

008019f4 <devfile_write>:
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	83 ec 0c             	sub    $0xc,%esp
  8019fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8019fd:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a02:	39 d0                	cmp    %edx,%eax
  801a04:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a07:	8b 55 08             	mov    0x8(%ebp),%edx
  801a0a:	8b 52 0c             	mov    0xc(%edx),%edx
  801a0d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801a13:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801a18:	50                   	push   %eax
  801a19:	ff 75 0c             	push   0xc(%ebp)
  801a1c:	68 08 50 80 00       	push   $0x805008
  801a21:	e8 26 f1 ff ff       	call   800b4c <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801a26:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2b:	b8 04 00 00 00       	mov    $0x4,%eax
  801a30:	e8 cd fe ff ff       	call   801902 <fsipc>
}
  801a35:	c9                   	leave  
  801a36:	c3                   	ret    

00801a37 <devfile_read>:
{
  801a37:	55                   	push   %ebp
  801a38:	89 e5                	mov    %esp,%ebp
  801a3a:	56                   	push   %esi
  801a3b:	53                   	push   %ebx
  801a3c:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a42:	8b 40 0c             	mov    0xc(%eax),%eax
  801a45:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a4a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a50:	ba 00 00 00 00       	mov    $0x0,%edx
  801a55:	b8 03 00 00 00       	mov    $0x3,%eax
  801a5a:	e8 a3 fe ff ff       	call   801902 <fsipc>
  801a5f:	89 c3                	mov    %eax,%ebx
  801a61:	85 c0                	test   %eax,%eax
  801a63:	78 1f                	js     801a84 <devfile_read+0x4d>
	assert(r <= n);
  801a65:	39 f0                	cmp    %esi,%eax
  801a67:	77 24                	ja     801a8d <devfile_read+0x56>
	assert(r <= PGSIZE);
  801a69:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a6e:	7f 33                	jg     801aa3 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a70:	83 ec 04             	sub    $0x4,%esp
  801a73:	50                   	push   %eax
  801a74:	68 00 50 80 00       	push   $0x805000
  801a79:	ff 75 0c             	push   0xc(%ebp)
  801a7c:	e8 cb f0 ff ff       	call   800b4c <memmove>
	return r;
  801a81:	83 c4 10             	add    $0x10,%esp
}
  801a84:	89 d8                	mov    %ebx,%eax
  801a86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a89:	5b                   	pop    %ebx
  801a8a:	5e                   	pop    %esi
  801a8b:	5d                   	pop    %ebp
  801a8c:	c3                   	ret    
	assert(r <= n);
  801a8d:	68 48 2d 80 00       	push   $0x802d48
  801a92:	68 4f 2d 80 00       	push   $0x802d4f
  801a97:	6a 7c                	push   $0x7c
  801a99:	68 64 2d 80 00       	push   $0x802d64
  801a9e:	e8 5e e8 ff ff       	call   800301 <_panic>
	assert(r <= PGSIZE);
  801aa3:	68 6f 2d 80 00       	push   $0x802d6f
  801aa8:	68 4f 2d 80 00       	push   $0x802d4f
  801aad:	6a 7d                	push   $0x7d
  801aaf:	68 64 2d 80 00       	push   $0x802d64
  801ab4:	e8 48 e8 ff ff       	call   800301 <_panic>

00801ab9 <open>:
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	56                   	push   %esi
  801abd:	53                   	push   %ebx
  801abe:	83 ec 1c             	sub    $0x1c,%esp
  801ac1:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801ac4:	56                   	push   %esi
  801ac5:	e8 b1 ee ff ff       	call   80097b <strlen>
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ad2:	7f 6c                	jg     801b40 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801ad4:	83 ec 0c             	sub    $0xc,%esp
  801ad7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ada:	50                   	push   %eax
  801adb:	e8 bd f8 ff ff       	call   80139d <fd_alloc>
  801ae0:	89 c3                	mov    %eax,%ebx
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	78 3c                	js     801b25 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801ae9:	83 ec 08             	sub    $0x8,%esp
  801aec:	56                   	push   %esi
  801aed:	68 00 50 80 00       	push   $0x805000
  801af2:	e8 bf ee ff ff       	call   8009b6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801af7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afa:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801aff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b02:	b8 01 00 00 00       	mov    $0x1,%eax
  801b07:	e8 f6 fd ff ff       	call   801902 <fsipc>
  801b0c:	89 c3                	mov    %eax,%ebx
  801b0e:	83 c4 10             	add    $0x10,%esp
  801b11:	85 c0                	test   %eax,%eax
  801b13:	78 19                	js     801b2e <open+0x75>
	return fd2num(fd);
  801b15:	83 ec 0c             	sub    $0xc,%esp
  801b18:	ff 75 f4             	push   -0xc(%ebp)
  801b1b:	e8 56 f8 ff ff       	call   801376 <fd2num>
  801b20:	89 c3                	mov    %eax,%ebx
  801b22:	83 c4 10             	add    $0x10,%esp
}
  801b25:	89 d8                	mov    %ebx,%eax
  801b27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2a:	5b                   	pop    %ebx
  801b2b:	5e                   	pop    %esi
  801b2c:	5d                   	pop    %ebp
  801b2d:	c3                   	ret    
		fd_close(fd, 0);
  801b2e:	83 ec 08             	sub    $0x8,%esp
  801b31:	6a 00                	push   $0x0
  801b33:	ff 75 f4             	push   -0xc(%ebp)
  801b36:	e8 58 f9 ff ff       	call   801493 <fd_close>
		return r;
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	eb e5                	jmp    801b25 <open+0x6c>
		return -E_BAD_PATH;
  801b40:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801b45:	eb de                	jmp    801b25 <open+0x6c>

00801b47 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b47:	55                   	push   %ebp
  801b48:	89 e5                	mov    %esp,%ebp
  801b4a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b4d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b52:	b8 08 00 00 00       	mov    $0x8,%eax
  801b57:	e8 a6 fd ff ff       	call   801902 <fsipc>
}
  801b5c:	c9                   	leave  
  801b5d:	c3                   	ret    

00801b5e <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801b64:	68 7b 2d 80 00       	push   $0x802d7b
  801b69:	ff 75 0c             	push   0xc(%ebp)
  801b6c:	e8 45 ee ff ff       	call   8009b6 <strcpy>
	return 0;
}
  801b71:	b8 00 00 00 00       	mov    $0x0,%eax
  801b76:	c9                   	leave  
  801b77:	c3                   	ret    

00801b78 <devsock_close>:
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	53                   	push   %ebx
  801b7c:	83 ec 10             	sub    $0x10,%esp
  801b7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b82:	53                   	push   %ebx
  801b83:	e8 98 09 00 00       	call   802520 <pageref>
  801b88:	89 c2                	mov    %eax,%edx
  801b8a:	83 c4 10             	add    $0x10,%esp
		return 0;
  801b8d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801b92:	83 fa 01             	cmp    $0x1,%edx
  801b95:	74 05                	je     801b9c <devsock_close+0x24>
}
  801b97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b9a:	c9                   	leave  
  801b9b:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801b9c:	83 ec 0c             	sub    $0xc,%esp
  801b9f:	ff 73 0c             	push   0xc(%ebx)
  801ba2:	e8 b7 02 00 00       	call   801e5e <nsipc_close>
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	eb eb                	jmp    801b97 <devsock_close+0x1f>

00801bac <devsock_write>:
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801bb2:	6a 00                	push   $0x0
  801bb4:	ff 75 10             	push   0x10(%ebp)
  801bb7:	ff 75 0c             	push   0xc(%ebp)
  801bba:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbd:	ff 70 0c             	push   0xc(%eax)
  801bc0:	e8 79 03 00 00       	call   801f3e <nsipc_send>
}
  801bc5:	c9                   	leave  
  801bc6:	c3                   	ret    

00801bc7 <devsock_read>:
{
  801bc7:	55                   	push   %ebp
  801bc8:	89 e5                	mov    %esp,%ebp
  801bca:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801bcd:	6a 00                	push   $0x0
  801bcf:	ff 75 10             	push   0x10(%ebp)
  801bd2:	ff 75 0c             	push   0xc(%ebp)
  801bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd8:	ff 70 0c             	push   0xc(%eax)
  801bdb:	e8 ef 02 00 00       	call   801ecf <nsipc_recv>
}
  801be0:	c9                   	leave  
  801be1:	c3                   	ret    

00801be2 <fd2sockid>:
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801be8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801beb:	52                   	push   %edx
  801bec:	50                   	push   %eax
  801bed:	e8 fb f7 ff ff       	call   8013ed <fd_lookup>
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	78 10                	js     801c09 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfc:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801c02:	39 08                	cmp    %ecx,(%eax)
  801c04:	75 05                	jne    801c0b <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801c06:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801c09:	c9                   	leave  
  801c0a:	c3                   	ret    
		return -E_NOT_SUPP;
  801c0b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c10:	eb f7                	jmp    801c09 <fd2sockid+0x27>

00801c12 <alloc_sockfd>:
{
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
  801c15:	56                   	push   %esi
  801c16:	53                   	push   %ebx
  801c17:	83 ec 1c             	sub    $0x1c,%esp
  801c1a:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801c1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c1f:	50                   	push   %eax
  801c20:	e8 78 f7 ff ff       	call   80139d <fd_alloc>
  801c25:	89 c3                	mov    %eax,%ebx
  801c27:	83 c4 10             	add    $0x10,%esp
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	78 43                	js     801c71 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c2e:	83 ec 04             	sub    $0x4,%esp
  801c31:	68 07 04 00 00       	push   $0x407
  801c36:	ff 75 f4             	push   -0xc(%ebp)
  801c39:	6a 00                	push   $0x0
  801c3b:	e8 72 f1 ff ff       	call   800db2 <sys_page_alloc>
  801c40:	89 c3                	mov    %eax,%ebx
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	85 c0                	test   %eax,%eax
  801c47:	78 28                	js     801c71 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c52:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c57:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c5e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c61:	83 ec 0c             	sub    $0xc,%esp
  801c64:	50                   	push   %eax
  801c65:	e8 0c f7 ff ff       	call   801376 <fd2num>
  801c6a:	89 c3                	mov    %eax,%ebx
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	eb 0c                	jmp    801c7d <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801c71:	83 ec 0c             	sub    $0xc,%esp
  801c74:	56                   	push   %esi
  801c75:	e8 e4 01 00 00       	call   801e5e <nsipc_close>
		return r;
  801c7a:	83 c4 10             	add    $0x10,%esp
}
  801c7d:	89 d8                	mov    %ebx,%eax
  801c7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c82:	5b                   	pop    %ebx
  801c83:	5e                   	pop    %esi
  801c84:	5d                   	pop    %ebp
  801c85:	c3                   	ret    

00801c86 <accept>:
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8f:	e8 4e ff ff ff       	call   801be2 <fd2sockid>
  801c94:	85 c0                	test   %eax,%eax
  801c96:	78 1b                	js     801cb3 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c98:	83 ec 04             	sub    $0x4,%esp
  801c9b:	ff 75 10             	push   0x10(%ebp)
  801c9e:	ff 75 0c             	push   0xc(%ebp)
  801ca1:	50                   	push   %eax
  801ca2:	e8 0e 01 00 00       	call   801db5 <nsipc_accept>
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	85 c0                	test   %eax,%eax
  801cac:	78 05                	js     801cb3 <accept+0x2d>
	return alloc_sockfd(r);
  801cae:	e8 5f ff ff ff       	call   801c12 <alloc_sockfd>
}
  801cb3:	c9                   	leave  
  801cb4:	c3                   	ret    

00801cb5 <bind>:
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbe:	e8 1f ff ff ff       	call   801be2 <fd2sockid>
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	78 12                	js     801cd9 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801cc7:	83 ec 04             	sub    $0x4,%esp
  801cca:	ff 75 10             	push   0x10(%ebp)
  801ccd:	ff 75 0c             	push   0xc(%ebp)
  801cd0:	50                   	push   %eax
  801cd1:	e8 31 01 00 00       	call   801e07 <nsipc_bind>
  801cd6:	83 c4 10             	add    $0x10,%esp
}
  801cd9:	c9                   	leave  
  801cda:	c3                   	ret    

00801cdb <shutdown>:
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ce1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce4:	e8 f9 fe ff ff       	call   801be2 <fd2sockid>
  801ce9:	85 c0                	test   %eax,%eax
  801ceb:	78 0f                	js     801cfc <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801ced:	83 ec 08             	sub    $0x8,%esp
  801cf0:	ff 75 0c             	push   0xc(%ebp)
  801cf3:	50                   	push   %eax
  801cf4:	e8 43 01 00 00       	call   801e3c <nsipc_shutdown>
  801cf9:	83 c4 10             	add    $0x10,%esp
}
  801cfc:	c9                   	leave  
  801cfd:	c3                   	ret    

00801cfe <connect>:
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d04:	8b 45 08             	mov    0x8(%ebp),%eax
  801d07:	e8 d6 fe ff ff       	call   801be2 <fd2sockid>
  801d0c:	85 c0                	test   %eax,%eax
  801d0e:	78 12                	js     801d22 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801d10:	83 ec 04             	sub    $0x4,%esp
  801d13:	ff 75 10             	push   0x10(%ebp)
  801d16:	ff 75 0c             	push   0xc(%ebp)
  801d19:	50                   	push   %eax
  801d1a:	e8 59 01 00 00       	call   801e78 <nsipc_connect>
  801d1f:	83 c4 10             	add    $0x10,%esp
}
  801d22:	c9                   	leave  
  801d23:	c3                   	ret    

00801d24 <listen>:
{
  801d24:	55                   	push   %ebp
  801d25:	89 e5                	mov    %esp,%ebp
  801d27:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2d:	e8 b0 fe ff ff       	call   801be2 <fd2sockid>
  801d32:	85 c0                	test   %eax,%eax
  801d34:	78 0f                	js     801d45 <listen+0x21>
	return nsipc_listen(r, backlog);
  801d36:	83 ec 08             	sub    $0x8,%esp
  801d39:	ff 75 0c             	push   0xc(%ebp)
  801d3c:	50                   	push   %eax
  801d3d:	e8 6b 01 00 00       	call   801ead <nsipc_listen>
  801d42:	83 c4 10             	add    $0x10,%esp
}
  801d45:	c9                   	leave  
  801d46:	c3                   	ret    

00801d47 <socket>:

int
socket(int domain, int type, int protocol)
{
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d4d:	ff 75 10             	push   0x10(%ebp)
  801d50:	ff 75 0c             	push   0xc(%ebp)
  801d53:	ff 75 08             	push   0x8(%ebp)
  801d56:	e8 41 02 00 00       	call   801f9c <nsipc_socket>
  801d5b:	83 c4 10             	add    $0x10,%esp
  801d5e:	85 c0                	test   %eax,%eax
  801d60:	78 05                	js     801d67 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801d62:	e8 ab fe ff ff       	call   801c12 <alloc_sockfd>
}
  801d67:	c9                   	leave  
  801d68:	c3                   	ret    

00801d69 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	53                   	push   %ebx
  801d6d:	83 ec 04             	sub    $0x4,%esp
  801d70:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d72:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801d79:	74 26                	je     801da1 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d7b:	6a 07                	push   $0x7
  801d7d:	68 00 70 80 00       	push   $0x807000
  801d82:	53                   	push   %ebx
  801d83:	ff 35 00 80 80 00    	push   0x808000
  801d89:	e8 5b f5 ff ff       	call   8012e9 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d8e:	83 c4 0c             	add    $0xc,%esp
  801d91:	6a 00                	push   $0x0
  801d93:	6a 00                	push   $0x0
  801d95:	6a 00                	push   $0x0
  801d97:	e8 e6 f4 ff ff       	call   801282 <ipc_recv>
}
  801d9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d9f:	c9                   	leave  
  801da0:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801da1:	83 ec 0c             	sub    $0xc,%esp
  801da4:	6a 02                	push   $0x2
  801da6:	e8 92 f5 ff ff       	call   80133d <ipc_find_env>
  801dab:	a3 00 80 80 00       	mov    %eax,0x808000
  801db0:	83 c4 10             	add    $0x10,%esp
  801db3:	eb c6                	jmp    801d7b <nsipc+0x12>

00801db5 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	56                   	push   %esi
  801db9:	53                   	push   %ebx
  801dba:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801dbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801dc5:	8b 06                	mov    (%esi),%eax
  801dc7:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801dcc:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd1:	e8 93 ff ff ff       	call   801d69 <nsipc>
  801dd6:	89 c3                	mov    %eax,%ebx
  801dd8:	85 c0                	test   %eax,%eax
  801dda:	79 09                	jns    801de5 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801ddc:	89 d8                	mov    %ebx,%eax
  801dde:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801de1:	5b                   	pop    %ebx
  801de2:	5e                   	pop    %esi
  801de3:	5d                   	pop    %ebp
  801de4:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801de5:	83 ec 04             	sub    $0x4,%esp
  801de8:	ff 35 10 70 80 00    	push   0x807010
  801dee:	68 00 70 80 00       	push   $0x807000
  801df3:	ff 75 0c             	push   0xc(%ebp)
  801df6:	e8 51 ed ff ff       	call   800b4c <memmove>
		*addrlen = ret->ret_addrlen;
  801dfb:	a1 10 70 80 00       	mov    0x807010,%eax
  801e00:	89 06                	mov    %eax,(%esi)
  801e02:	83 c4 10             	add    $0x10,%esp
	return r;
  801e05:	eb d5                	jmp    801ddc <nsipc_accept+0x27>

00801e07 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e07:	55                   	push   %ebp
  801e08:	89 e5                	mov    %esp,%ebp
  801e0a:	53                   	push   %ebx
  801e0b:	83 ec 08             	sub    $0x8,%esp
  801e0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e11:	8b 45 08             	mov    0x8(%ebp),%eax
  801e14:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e19:	53                   	push   %ebx
  801e1a:	ff 75 0c             	push   0xc(%ebp)
  801e1d:	68 04 70 80 00       	push   $0x807004
  801e22:	e8 25 ed ff ff       	call   800b4c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e27:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801e2d:	b8 02 00 00 00       	mov    $0x2,%eax
  801e32:	e8 32 ff ff ff       	call   801d69 <nsipc>
}
  801e37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e3a:	c9                   	leave  
  801e3b:	c3                   	ret    

00801e3c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e42:	8b 45 08             	mov    0x8(%ebp),%eax
  801e45:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e4d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801e52:	b8 03 00 00 00       	mov    $0x3,%eax
  801e57:	e8 0d ff ff ff       	call   801d69 <nsipc>
}
  801e5c:	c9                   	leave  
  801e5d:	c3                   	ret    

00801e5e <nsipc_close>:

int
nsipc_close(int s)
{
  801e5e:	55                   	push   %ebp
  801e5f:	89 e5                	mov    %esp,%ebp
  801e61:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e64:	8b 45 08             	mov    0x8(%ebp),%eax
  801e67:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801e6c:	b8 04 00 00 00       	mov    $0x4,%eax
  801e71:	e8 f3 fe ff ff       	call   801d69 <nsipc>
}
  801e76:	c9                   	leave  
  801e77:	c3                   	ret    

00801e78 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	53                   	push   %ebx
  801e7c:	83 ec 08             	sub    $0x8,%esp
  801e7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e82:	8b 45 08             	mov    0x8(%ebp),%eax
  801e85:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e8a:	53                   	push   %ebx
  801e8b:	ff 75 0c             	push   0xc(%ebp)
  801e8e:	68 04 70 80 00       	push   $0x807004
  801e93:	e8 b4 ec ff ff       	call   800b4c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e98:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801e9e:	b8 05 00 00 00       	mov    $0x5,%eax
  801ea3:	e8 c1 fe ff ff       	call   801d69 <nsipc>
}
  801ea8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eab:	c9                   	leave  
  801eac:	c3                   	ret    

00801ead <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ead:	55                   	push   %ebp
  801eae:	89 e5                	mov    %esp,%ebp
  801eb0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801eb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb6:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ebe:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801ec3:	b8 06 00 00 00       	mov    $0x6,%eax
  801ec8:	e8 9c fe ff ff       	call   801d69 <nsipc>
}
  801ecd:	c9                   	leave  
  801ece:	c3                   	ret    

00801ecf <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ecf:	55                   	push   %ebp
  801ed0:	89 e5                	mov    %esp,%ebp
  801ed2:	56                   	push   %esi
  801ed3:	53                   	push   %ebx
  801ed4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ed7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eda:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801edf:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801ee5:	8b 45 14             	mov    0x14(%ebp),%eax
  801ee8:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801eed:	b8 07 00 00 00       	mov    $0x7,%eax
  801ef2:	e8 72 fe ff ff       	call   801d69 <nsipc>
  801ef7:	89 c3                	mov    %eax,%ebx
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	78 22                	js     801f1f <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801efd:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801f02:	39 c6                	cmp    %eax,%esi
  801f04:	0f 4e c6             	cmovle %esi,%eax
  801f07:	39 c3                	cmp    %eax,%ebx
  801f09:	7f 1d                	jg     801f28 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f0b:	83 ec 04             	sub    $0x4,%esp
  801f0e:	53                   	push   %ebx
  801f0f:	68 00 70 80 00       	push   $0x807000
  801f14:	ff 75 0c             	push   0xc(%ebp)
  801f17:	e8 30 ec ff ff       	call   800b4c <memmove>
  801f1c:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f1f:	89 d8                	mov    %ebx,%eax
  801f21:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f24:	5b                   	pop    %ebx
  801f25:	5e                   	pop    %esi
  801f26:	5d                   	pop    %ebp
  801f27:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801f28:	68 87 2d 80 00       	push   $0x802d87
  801f2d:	68 4f 2d 80 00       	push   $0x802d4f
  801f32:	6a 62                	push   $0x62
  801f34:	68 9c 2d 80 00       	push   $0x802d9c
  801f39:	e8 c3 e3 ff ff       	call   800301 <_panic>

00801f3e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f3e:	55                   	push   %ebp
  801f3f:	89 e5                	mov    %esp,%ebp
  801f41:	53                   	push   %ebx
  801f42:	83 ec 04             	sub    $0x4,%esp
  801f45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f48:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801f50:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f56:	7f 2e                	jg     801f86 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f58:	83 ec 04             	sub    $0x4,%esp
  801f5b:	53                   	push   %ebx
  801f5c:	ff 75 0c             	push   0xc(%ebp)
  801f5f:	68 0c 70 80 00       	push   $0x80700c
  801f64:	e8 e3 eb ff ff       	call   800b4c <memmove>
	nsipcbuf.send.req_size = size;
  801f69:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801f6f:	8b 45 14             	mov    0x14(%ebp),%eax
  801f72:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801f77:	b8 08 00 00 00       	mov    $0x8,%eax
  801f7c:	e8 e8 fd ff ff       	call   801d69 <nsipc>
}
  801f81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f84:	c9                   	leave  
  801f85:	c3                   	ret    
	assert(size < 1600);
  801f86:	68 a8 2d 80 00       	push   $0x802da8
  801f8b:	68 4f 2d 80 00       	push   $0x802d4f
  801f90:	6a 6d                	push   $0x6d
  801f92:	68 9c 2d 80 00       	push   $0x802d9c
  801f97:	e8 65 e3 ff ff       	call   800301 <_panic>

00801f9c <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801fa2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801faa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fad:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801fb2:	8b 45 10             	mov    0x10(%ebp),%eax
  801fb5:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801fba:	b8 09 00 00 00       	mov    $0x9,%eax
  801fbf:	e8 a5 fd ff ff       	call   801d69 <nsipc>
}
  801fc4:	c9                   	leave  
  801fc5:	c3                   	ret    

00801fc6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801fc6:	55                   	push   %ebp
  801fc7:	89 e5                	mov    %esp,%ebp
  801fc9:	56                   	push   %esi
  801fca:	53                   	push   %ebx
  801fcb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801fce:	83 ec 0c             	sub    $0xc,%esp
  801fd1:	ff 75 08             	push   0x8(%ebp)
  801fd4:	e8 ad f3 ff ff       	call   801386 <fd2data>
  801fd9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801fdb:	83 c4 08             	add    $0x8,%esp
  801fde:	68 b4 2d 80 00       	push   $0x802db4
  801fe3:	53                   	push   %ebx
  801fe4:	e8 cd e9 ff ff       	call   8009b6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801fe9:	8b 46 04             	mov    0x4(%esi),%eax
  801fec:	2b 06                	sub    (%esi),%eax
  801fee:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ff4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ffb:	00 00 00 
	stat->st_dev = &devpipe;
  801ffe:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  802005:	30 80 00 
	return 0;
}
  802008:	b8 00 00 00 00       	mov    $0x0,%eax
  80200d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802010:	5b                   	pop    %ebx
  802011:	5e                   	pop    %esi
  802012:	5d                   	pop    %ebp
  802013:	c3                   	ret    

00802014 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802014:	55                   	push   %ebp
  802015:	89 e5                	mov    %esp,%ebp
  802017:	53                   	push   %ebx
  802018:	83 ec 0c             	sub    $0xc,%esp
  80201b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80201e:	53                   	push   %ebx
  80201f:	6a 00                	push   $0x0
  802021:	e8 11 ee ff ff       	call   800e37 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802026:	89 1c 24             	mov    %ebx,(%esp)
  802029:	e8 58 f3 ff ff       	call   801386 <fd2data>
  80202e:	83 c4 08             	add    $0x8,%esp
  802031:	50                   	push   %eax
  802032:	6a 00                	push   $0x0
  802034:	e8 fe ed ff ff       	call   800e37 <sys_page_unmap>
}
  802039:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80203c:	c9                   	leave  
  80203d:	c3                   	ret    

0080203e <_pipeisclosed>:
{
  80203e:	55                   	push   %ebp
  80203f:	89 e5                	mov    %esp,%ebp
  802041:	57                   	push   %edi
  802042:	56                   	push   %esi
  802043:	53                   	push   %ebx
  802044:	83 ec 1c             	sub    $0x1c,%esp
  802047:	89 c7                	mov    %eax,%edi
  802049:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80204b:	a1 04 40 80 00       	mov    0x804004,%eax
  802050:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802053:	83 ec 0c             	sub    $0xc,%esp
  802056:	57                   	push   %edi
  802057:	e8 c4 04 00 00       	call   802520 <pageref>
  80205c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80205f:	89 34 24             	mov    %esi,(%esp)
  802062:	e8 b9 04 00 00       	call   802520 <pageref>
		nn = thisenv->env_runs;
  802067:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80206d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802070:	83 c4 10             	add    $0x10,%esp
  802073:	39 cb                	cmp    %ecx,%ebx
  802075:	74 1b                	je     802092 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802077:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80207a:	75 cf                	jne    80204b <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80207c:	8b 42 58             	mov    0x58(%edx),%eax
  80207f:	6a 01                	push   $0x1
  802081:	50                   	push   %eax
  802082:	53                   	push   %ebx
  802083:	68 bb 2d 80 00       	push   $0x802dbb
  802088:	e8 4f e3 ff ff       	call   8003dc <cprintf>
  80208d:	83 c4 10             	add    $0x10,%esp
  802090:	eb b9                	jmp    80204b <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802092:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802095:	0f 94 c0             	sete   %al
  802098:	0f b6 c0             	movzbl %al,%eax
}
  80209b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80209e:	5b                   	pop    %ebx
  80209f:	5e                   	pop    %esi
  8020a0:	5f                   	pop    %edi
  8020a1:	5d                   	pop    %ebp
  8020a2:	c3                   	ret    

008020a3 <devpipe_write>:
{
  8020a3:	55                   	push   %ebp
  8020a4:	89 e5                	mov    %esp,%ebp
  8020a6:	57                   	push   %edi
  8020a7:	56                   	push   %esi
  8020a8:	53                   	push   %ebx
  8020a9:	83 ec 28             	sub    $0x28,%esp
  8020ac:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8020af:	56                   	push   %esi
  8020b0:	e8 d1 f2 ff ff       	call   801386 <fd2data>
  8020b5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8020b7:	83 c4 10             	add    $0x10,%esp
  8020ba:	bf 00 00 00 00       	mov    $0x0,%edi
  8020bf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020c2:	75 09                	jne    8020cd <devpipe_write+0x2a>
	return i;
  8020c4:	89 f8                	mov    %edi,%eax
  8020c6:	eb 23                	jmp    8020eb <devpipe_write+0x48>
			sys_yield();
  8020c8:	e8 c6 ec ff ff       	call   800d93 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020cd:	8b 43 04             	mov    0x4(%ebx),%eax
  8020d0:	8b 0b                	mov    (%ebx),%ecx
  8020d2:	8d 51 20             	lea    0x20(%ecx),%edx
  8020d5:	39 d0                	cmp    %edx,%eax
  8020d7:	72 1a                	jb     8020f3 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  8020d9:	89 da                	mov    %ebx,%edx
  8020db:	89 f0                	mov    %esi,%eax
  8020dd:	e8 5c ff ff ff       	call   80203e <_pipeisclosed>
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	74 e2                	je     8020c8 <devpipe_write+0x25>
				return 0;
  8020e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ee:	5b                   	pop    %ebx
  8020ef:	5e                   	pop    %esi
  8020f0:	5f                   	pop    %edi
  8020f1:	5d                   	pop    %ebp
  8020f2:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020f6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020fa:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020fd:	89 c2                	mov    %eax,%edx
  8020ff:	c1 fa 1f             	sar    $0x1f,%edx
  802102:	89 d1                	mov    %edx,%ecx
  802104:	c1 e9 1b             	shr    $0x1b,%ecx
  802107:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80210a:	83 e2 1f             	and    $0x1f,%edx
  80210d:	29 ca                	sub    %ecx,%edx
  80210f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802113:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802117:	83 c0 01             	add    $0x1,%eax
  80211a:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80211d:	83 c7 01             	add    $0x1,%edi
  802120:	eb 9d                	jmp    8020bf <devpipe_write+0x1c>

00802122 <devpipe_read>:
{
  802122:	55                   	push   %ebp
  802123:	89 e5                	mov    %esp,%ebp
  802125:	57                   	push   %edi
  802126:	56                   	push   %esi
  802127:	53                   	push   %ebx
  802128:	83 ec 18             	sub    $0x18,%esp
  80212b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80212e:	57                   	push   %edi
  80212f:	e8 52 f2 ff ff       	call   801386 <fd2data>
  802134:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802136:	83 c4 10             	add    $0x10,%esp
  802139:	be 00 00 00 00       	mov    $0x0,%esi
  80213e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802141:	75 13                	jne    802156 <devpipe_read+0x34>
	return i;
  802143:	89 f0                	mov    %esi,%eax
  802145:	eb 02                	jmp    802149 <devpipe_read+0x27>
				return i;
  802147:	89 f0                	mov    %esi,%eax
}
  802149:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80214c:	5b                   	pop    %ebx
  80214d:	5e                   	pop    %esi
  80214e:	5f                   	pop    %edi
  80214f:	5d                   	pop    %ebp
  802150:	c3                   	ret    
			sys_yield();
  802151:	e8 3d ec ff ff       	call   800d93 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802156:	8b 03                	mov    (%ebx),%eax
  802158:	3b 43 04             	cmp    0x4(%ebx),%eax
  80215b:	75 18                	jne    802175 <devpipe_read+0x53>
			if (i > 0)
  80215d:	85 f6                	test   %esi,%esi
  80215f:	75 e6                	jne    802147 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  802161:	89 da                	mov    %ebx,%edx
  802163:	89 f8                	mov    %edi,%eax
  802165:	e8 d4 fe ff ff       	call   80203e <_pipeisclosed>
  80216a:	85 c0                	test   %eax,%eax
  80216c:	74 e3                	je     802151 <devpipe_read+0x2f>
				return 0;
  80216e:	b8 00 00 00 00       	mov    $0x0,%eax
  802173:	eb d4                	jmp    802149 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802175:	99                   	cltd   
  802176:	c1 ea 1b             	shr    $0x1b,%edx
  802179:	01 d0                	add    %edx,%eax
  80217b:	83 e0 1f             	and    $0x1f,%eax
  80217e:	29 d0                	sub    %edx,%eax
  802180:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802185:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802188:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80218b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80218e:	83 c6 01             	add    $0x1,%esi
  802191:	eb ab                	jmp    80213e <devpipe_read+0x1c>

00802193 <pipe>:
{
  802193:	55                   	push   %ebp
  802194:	89 e5                	mov    %esp,%ebp
  802196:	56                   	push   %esi
  802197:	53                   	push   %ebx
  802198:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80219b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80219e:	50                   	push   %eax
  80219f:	e8 f9 f1 ff ff       	call   80139d <fd_alloc>
  8021a4:	89 c3                	mov    %eax,%ebx
  8021a6:	83 c4 10             	add    $0x10,%esp
  8021a9:	85 c0                	test   %eax,%eax
  8021ab:	0f 88 23 01 00 00    	js     8022d4 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021b1:	83 ec 04             	sub    $0x4,%esp
  8021b4:	68 07 04 00 00       	push   $0x407
  8021b9:	ff 75 f4             	push   -0xc(%ebp)
  8021bc:	6a 00                	push   $0x0
  8021be:	e8 ef eb ff ff       	call   800db2 <sys_page_alloc>
  8021c3:	89 c3                	mov    %eax,%ebx
  8021c5:	83 c4 10             	add    $0x10,%esp
  8021c8:	85 c0                	test   %eax,%eax
  8021ca:	0f 88 04 01 00 00    	js     8022d4 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  8021d0:	83 ec 0c             	sub    $0xc,%esp
  8021d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021d6:	50                   	push   %eax
  8021d7:	e8 c1 f1 ff ff       	call   80139d <fd_alloc>
  8021dc:	89 c3                	mov    %eax,%ebx
  8021de:	83 c4 10             	add    $0x10,%esp
  8021e1:	85 c0                	test   %eax,%eax
  8021e3:	0f 88 db 00 00 00    	js     8022c4 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021e9:	83 ec 04             	sub    $0x4,%esp
  8021ec:	68 07 04 00 00       	push   $0x407
  8021f1:	ff 75 f0             	push   -0x10(%ebp)
  8021f4:	6a 00                	push   $0x0
  8021f6:	e8 b7 eb ff ff       	call   800db2 <sys_page_alloc>
  8021fb:	89 c3                	mov    %eax,%ebx
  8021fd:	83 c4 10             	add    $0x10,%esp
  802200:	85 c0                	test   %eax,%eax
  802202:	0f 88 bc 00 00 00    	js     8022c4 <pipe+0x131>
	va = fd2data(fd0);
  802208:	83 ec 0c             	sub    $0xc,%esp
  80220b:	ff 75 f4             	push   -0xc(%ebp)
  80220e:	e8 73 f1 ff ff       	call   801386 <fd2data>
  802213:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802215:	83 c4 0c             	add    $0xc,%esp
  802218:	68 07 04 00 00       	push   $0x407
  80221d:	50                   	push   %eax
  80221e:	6a 00                	push   $0x0
  802220:	e8 8d eb ff ff       	call   800db2 <sys_page_alloc>
  802225:	89 c3                	mov    %eax,%ebx
  802227:	83 c4 10             	add    $0x10,%esp
  80222a:	85 c0                	test   %eax,%eax
  80222c:	0f 88 82 00 00 00    	js     8022b4 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802232:	83 ec 0c             	sub    $0xc,%esp
  802235:	ff 75 f0             	push   -0x10(%ebp)
  802238:	e8 49 f1 ff ff       	call   801386 <fd2data>
  80223d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802244:	50                   	push   %eax
  802245:	6a 00                	push   $0x0
  802247:	56                   	push   %esi
  802248:	6a 00                	push   $0x0
  80224a:	e8 a6 eb ff ff       	call   800df5 <sys_page_map>
  80224f:	89 c3                	mov    %eax,%ebx
  802251:	83 c4 20             	add    $0x20,%esp
  802254:	85 c0                	test   %eax,%eax
  802256:	78 4e                	js     8022a6 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  802258:	a1 3c 30 80 00       	mov    0x80303c,%eax
  80225d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802260:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802262:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802265:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80226c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80226f:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802271:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802274:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80227b:	83 ec 0c             	sub    $0xc,%esp
  80227e:	ff 75 f4             	push   -0xc(%ebp)
  802281:	e8 f0 f0 ff ff       	call   801376 <fd2num>
  802286:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802289:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80228b:	83 c4 04             	add    $0x4,%esp
  80228e:	ff 75 f0             	push   -0x10(%ebp)
  802291:	e8 e0 f0 ff ff       	call   801376 <fd2num>
  802296:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802299:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80229c:	83 c4 10             	add    $0x10,%esp
  80229f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8022a4:	eb 2e                	jmp    8022d4 <pipe+0x141>
	sys_page_unmap(0, va);
  8022a6:	83 ec 08             	sub    $0x8,%esp
  8022a9:	56                   	push   %esi
  8022aa:	6a 00                	push   $0x0
  8022ac:	e8 86 eb ff ff       	call   800e37 <sys_page_unmap>
  8022b1:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8022b4:	83 ec 08             	sub    $0x8,%esp
  8022b7:	ff 75 f0             	push   -0x10(%ebp)
  8022ba:	6a 00                	push   $0x0
  8022bc:	e8 76 eb ff ff       	call   800e37 <sys_page_unmap>
  8022c1:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8022c4:	83 ec 08             	sub    $0x8,%esp
  8022c7:	ff 75 f4             	push   -0xc(%ebp)
  8022ca:	6a 00                	push   $0x0
  8022cc:	e8 66 eb ff ff       	call   800e37 <sys_page_unmap>
  8022d1:	83 c4 10             	add    $0x10,%esp
}
  8022d4:	89 d8                	mov    %ebx,%eax
  8022d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022d9:	5b                   	pop    %ebx
  8022da:	5e                   	pop    %esi
  8022db:	5d                   	pop    %ebp
  8022dc:	c3                   	ret    

008022dd <pipeisclosed>:
{
  8022dd:	55                   	push   %ebp
  8022de:	89 e5                	mov    %esp,%ebp
  8022e0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022e6:	50                   	push   %eax
  8022e7:	ff 75 08             	push   0x8(%ebp)
  8022ea:	e8 fe f0 ff ff       	call   8013ed <fd_lookup>
  8022ef:	83 c4 10             	add    $0x10,%esp
  8022f2:	85 c0                	test   %eax,%eax
  8022f4:	78 18                	js     80230e <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8022f6:	83 ec 0c             	sub    $0xc,%esp
  8022f9:	ff 75 f4             	push   -0xc(%ebp)
  8022fc:	e8 85 f0 ff ff       	call   801386 <fd2data>
  802301:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802303:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802306:	e8 33 fd ff ff       	call   80203e <_pipeisclosed>
  80230b:	83 c4 10             	add    $0x10,%esp
}
  80230e:	c9                   	leave  
  80230f:	c3                   	ret    

00802310 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802310:	b8 00 00 00 00       	mov    $0x0,%eax
  802315:	c3                   	ret    

00802316 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802316:	55                   	push   %ebp
  802317:	89 e5                	mov    %esp,%ebp
  802319:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80231c:	68 d3 2d 80 00       	push   $0x802dd3
  802321:	ff 75 0c             	push   0xc(%ebp)
  802324:	e8 8d e6 ff ff       	call   8009b6 <strcpy>
	return 0;
}
  802329:	b8 00 00 00 00       	mov    $0x0,%eax
  80232e:	c9                   	leave  
  80232f:	c3                   	ret    

00802330 <devcons_write>:
{
  802330:	55                   	push   %ebp
  802331:	89 e5                	mov    %esp,%ebp
  802333:	57                   	push   %edi
  802334:	56                   	push   %esi
  802335:	53                   	push   %ebx
  802336:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80233c:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802341:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802347:	eb 2e                	jmp    802377 <devcons_write+0x47>
		m = n - tot;
  802349:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80234c:	29 f3                	sub    %esi,%ebx
  80234e:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802353:	39 c3                	cmp    %eax,%ebx
  802355:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802358:	83 ec 04             	sub    $0x4,%esp
  80235b:	53                   	push   %ebx
  80235c:	89 f0                	mov    %esi,%eax
  80235e:	03 45 0c             	add    0xc(%ebp),%eax
  802361:	50                   	push   %eax
  802362:	57                   	push   %edi
  802363:	e8 e4 e7 ff ff       	call   800b4c <memmove>
		sys_cputs(buf, m);
  802368:	83 c4 08             	add    $0x8,%esp
  80236b:	53                   	push   %ebx
  80236c:	57                   	push   %edi
  80236d:	e8 84 e9 ff ff       	call   800cf6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802372:	01 de                	add    %ebx,%esi
  802374:	83 c4 10             	add    $0x10,%esp
  802377:	3b 75 10             	cmp    0x10(%ebp),%esi
  80237a:	72 cd                	jb     802349 <devcons_write+0x19>
}
  80237c:	89 f0                	mov    %esi,%eax
  80237e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802381:	5b                   	pop    %ebx
  802382:	5e                   	pop    %esi
  802383:	5f                   	pop    %edi
  802384:	5d                   	pop    %ebp
  802385:	c3                   	ret    

00802386 <devcons_read>:
{
  802386:	55                   	push   %ebp
  802387:	89 e5                	mov    %esp,%ebp
  802389:	83 ec 08             	sub    $0x8,%esp
  80238c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802391:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802395:	75 07                	jne    80239e <devcons_read+0x18>
  802397:	eb 1f                	jmp    8023b8 <devcons_read+0x32>
		sys_yield();
  802399:	e8 f5 e9 ff ff       	call   800d93 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80239e:	e8 71 e9 ff ff       	call   800d14 <sys_cgetc>
  8023a3:	85 c0                	test   %eax,%eax
  8023a5:	74 f2                	je     802399 <devcons_read+0x13>
	if (c < 0)
  8023a7:	78 0f                	js     8023b8 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8023a9:	83 f8 04             	cmp    $0x4,%eax
  8023ac:	74 0c                	je     8023ba <devcons_read+0x34>
	*(char*)vbuf = c;
  8023ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023b1:	88 02                	mov    %al,(%edx)
	return 1;
  8023b3:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8023b8:	c9                   	leave  
  8023b9:	c3                   	ret    
		return 0;
  8023ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8023bf:	eb f7                	jmp    8023b8 <devcons_read+0x32>

008023c1 <cputchar>:
{
  8023c1:	55                   	push   %ebp
  8023c2:	89 e5                	mov    %esp,%ebp
  8023c4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8023c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ca:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8023cd:	6a 01                	push   $0x1
  8023cf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023d2:	50                   	push   %eax
  8023d3:	e8 1e e9 ff ff       	call   800cf6 <sys_cputs>
}
  8023d8:	83 c4 10             	add    $0x10,%esp
  8023db:	c9                   	leave  
  8023dc:	c3                   	ret    

008023dd <getchar>:
{
  8023dd:	55                   	push   %ebp
  8023de:	89 e5                	mov    %esp,%ebp
  8023e0:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8023e3:	6a 01                	push   $0x1
  8023e5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023e8:	50                   	push   %eax
  8023e9:	6a 00                	push   $0x0
  8023eb:	e8 66 f2 ff ff       	call   801656 <read>
	if (r < 0)
  8023f0:	83 c4 10             	add    $0x10,%esp
  8023f3:	85 c0                	test   %eax,%eax
  8023f5:	78 06                	js     8023fd <getchar+0x20>
	if (r < 1)
  8023f7:	74 06                	je     8023ff <getchar+0x22>
	return c;
  8023f9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8023fd:	c9                   	leave  
  8023fe:	c3                   	ret    
		return -E_EOF;
  8023ff:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802404:	eb f7                	jmp    8023fd <getchar+0x20>

00802406 <iscons>:
{
  802406:	55                   	push   %ebp
  802407:	89 e5                	mov    %esp,%ebp
  802409:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80240c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80240f:	50                   	push   %eax
  802410:	ff 75 08             	push   0x8(%ebp)
  802413:	e8 d5 ef ff ff       	call   8013ed <fd_lookup>
  802418:	83 c4 10             	add    $0x10,%esp
  80241b:	85 c0                	test   %eax,%eax
  80241d:	78 11                	js     802430 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80241f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802422:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802428:	39 10                	cmp    %edx,(%eax)
  80242a:	0f 94 c0             	sete   %al
  80242d:	0f b6 c0             	movzbl %al,%eax
}
  802430:	c9                   	leave  
  802431:	c3                   	ret    

00802432 <opencons>:
{
  802432:	55                   	push   %ebp
  802433:	89 e5                	mov    %esp,%ebp
  802435:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802438:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80243b:	50                   	push   %eax
  80243c:	e8 5c ef ff ff       	call   80139d <fd_alloc>
  802441:	83 c4 10             	add    $0x10,%esp
  802444:	85 c0                	test   %eax,%eax
  802446:	78 3a                	js     802482 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802448:	83 ec 04             	sub    $0x4,%esp
  80244b:	68 07 04 00 00       	push   $0x407
  802450:	ff 75 f4             	push   -0xc(%ebp)
  802453:	6a 00                	push   $0x0
  802455:	e8 58 e9 ff ff       	call   800db2 <sys_page_alloc>
  80245a:	83 c4 10             	add    $0x10,%esp
  80245d:	85 c0                	test   %eax,%eax
  80245f:	78 21                	js     802482 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  802461:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802464:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80246a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80246c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80246f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802476:	83 ec 0c             	sub    $0xc,%esp
  802479:	50                   	push   %eax
  80247a:	e8 f7 ee ff ff       	call   801376 <fd2num>
  80247f:	83 c4 10             	add    $0x10,%esp
}
  802482:	c9                   	leave  
  802483:	c3                   	ret    

00802484 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802484:	55                   	push   %ebp
  802485:	89 e5                	mov    %esp,%ebp
  802487:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  80248a:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  802491:	74 0a                	je     80249d <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802493:	8b 45 08             	mov    0x8(%ebp),%eax
  802496:	a3 04 80 80 00       	mov    %eax,0x808004
}
  80249b:	c9                   	leave  
  80249c:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  80249d:	e8 d2 e8 ff ff       	call   800d74 <sys_getenvid>
  8024a2:	83 ec 04             	sub    $0x4,%esp
  8024a5:	68 07 0e 00 00       	push   $0xe07
  8024aa:	68 00 f0 bf ee       	push   $0xeebff000
  8024af:	50                   	push   %eax
  8024b0:	e8 fd e8 ff ff       	call   800db2 <sys_page_alloc>
		if (r < 0) {
  8024b5:	83 c4 10             	add    $0x10,%esp
  8024b8:	85 c0                	test   %eax,%eax
  8024ba:	78 2c                	js     8024e8 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8024bc:	e8 b3 e8 ff ff       	call   800d74 <sys_getenvid>
  8024c1:	83 ec 08             	sub    $0x8,%esp
  8024c4:	68 fa 24 80 00       	push   $0x8024fa
  8024c9:	50                   	push   %eax
  8024ca:	e8 2e ea ff ff       	call   800efd <sys_env_set_pgfault_upcall>
		if (r < 0) {
  8024cf:	83 c4 10             	add    $0x10,%esp
  8024d2:	85 c0                	test   %eax,%eax
  8024d4:	79 bd                	jns    802493 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  8024d6:	50                   	push   %eax
  8024d7:	68 20 2e 80 00       	push   $0x802e20
  8024dc:	6a 28                	push   $0x28
  8024de:	68 56 2e 80 00       	push   $0x802e56
  8024e3:	e8 19 de ff ff       	call   800301 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  8024e8:	50                   	push   %eax
  8024e9:	68 e0 2d 80 00       	push   $0x802de0
  8024ee:	6a 23                	push   $0x23
  8024f0:	68 56 2e 80 00       	push   $0x802e56
  8024f5:	e8 07 de ff ff       	call   800301 <_panic>

008024fa <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8024fa:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8024fb:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  802500:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802502:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802505:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802509:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  80250c:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802510:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802514:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  802516:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802519:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  80251a:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  80251d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  80251e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  80251f:	c3                   	ret    

00802520 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802520:	55                   	push   %ebp
  802521:	89 e5                	mov    %esp,%ebp
  802523:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802526:	89 c2                	mov    %eax,%edx
  802528:	c1 ea 16             	shr    $0x16,%edx
  80252b:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802532:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802537:	f6 c1 01             	test   $0x1,%cl
  80253a:	74 1c                	je     802558 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  80253c:	c1 e8 0c             	shr    $0xc,%eax
  80253f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802546:	a8 01                	test   $0x1,%al
  802548:	74 0e                	je     802558 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80254a:	c1 e8 0c             	shr    $0xc,%eax
  80254d:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802554:	ef 
  802555:	0f b7 d2             	movzwl %dx,%edx
}
  802558:	89 d0                	mov    %edx,%eax
  80255a:	5d                   	pop    %ebp
  80255b:	c3                   	ret    
  80255c:	66 90                	xchg   %ax,%ax
  80255e:	66 90                	xchg   %ax,%ax

00802560 <__udivdi3>:
  802560:	f3 0f 1e fb          	endbr32 
  802564:	55                   	push   %ebp
  802565:	57                   	push   %edi
  802566:	56                   	push   %esi
  802567:	53                   	push   %ebx
  802568:	83 ec 1c             	sub    $0x1c,%esp
  80256b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80256f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802573:	8b 74 24 34          	mov    0x34(%esp),%esi
  802577:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80257b:	85 c0                	test   %eax,%eax
  80257d:	75 19                	jne    802598 <__udivdi3+0x38>
  80257f:	39 f3                	cmp    %esi,%ebx
  802581:	76 4d                	jbe    8025d0 <__udivdi3+0x70>
  802583:	31 ff                	xor    %edi,%edi
  802585:	89 e8                	mov    %ebp,%eax
  802587:	89 f2                	mov    %esi,%edx
  802589:	f7 f3                	div    %ebx
  80258b:	89 fa                	mov    %edi,%edx
  80258d:	83 c4 1c             	add    $0x1c,%esp
  802590:	5b                   	pop    %ebx
  802591:	5e                   	pop    %esi
  802592:	5f                   	pop    %edi
  802593:	5d                   	pop    %ebp
  802594:	c3                   	ret    
  802595:	8d 76 00             	lea    0x0(%esi),%esi
  802598:	39 f0                	cmp    %esi,%eax
  80259a:	76 14                	jbe    8025b0 <__udivdi3+0x50>
  80259c:	31 ff                	xor    %edi,%edi
  80259e:	31 c0                	xor    %eax,%eax
  8025a0:	89 fa                	mov    %edi,%edx
  8025a2:	83 c4 1c             	add    $0x1c,%esp
  8025a5:	5b                   	pop    %ebx
  8025a6:	5e                   	pop    %esi
  8025a7:	5f                   	pop    %edi
  8025a8:	5d                   	pop    %ebp
  8025a9:	c3                   	ret    
  8025aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025b0:	0f bd f8             	bsr    %eax,%edi
  8025b3:	83 f7 1f             	xor    $0x1f,%edi
  8025b6:	75 48                	jne    802600 <__udivdi3+0xa0>
  8025b8:	39 f0                	cmp    %esi,%eax
  8025ba:	72 06                	jb     8025c2 <__udivdi3+0x62>
  8025bc:	31 c0                	xor    %eax,%eax
  8025be:	39 eb                	cmp    %ebp,%ebx
  8025c0:	77 de                	ja     8025a0 <__udivdi3+0x40>
  8025c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8025c7:	eb d7                	jmp    8025a0 <__udivdi3+0x40>
  8025c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025d0:	89 d9                	mov    %ebx,%ecx
  8025d2:	85 db                	test   %ebx,%ebx
  8025d4:	75 0b                	jne    8025e1 <__udivdi3+0x81>
  8025d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025db:	31 d2                	xor    %edx,%edx
  8025dd:	f7 f3                	div    %ebx
  8025df:	89 c1                	mov    %eax,%ecx
  8025e1:	31 d2                	xor    %edx,%edx
  8025e3:	89 f0                	mov    %esi,%eax
  8025e5:	f7 f1                	div    %ecx
  8025e7:	89 c6                	mov    %eax,%esi
  8025e9:	89 e8                	mov    %ebp,%eax
  8025eb:	89 f7                	mov    %esi,%edi
  8025ed:	f7 f1                	div    %ecx
  8025ef:	89 fa                	mov    %edi,%edx
  8025f1:	83 c4 1c             	add    $0x1c,%esp
  8025f4:	5b                   	pop    %ebx
  8025f5:	5e                   	pop    %esi
  8025f6:	5f                   	pop    %edi
  8025f7:	5d                   	pop    %ebp
  8025f8:	c3                   	ret    
  8025f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802600:	89 f9                	mov    %edi,%ecx
  802602:	ba 20 00 00 00       	mov    $0x20,%edx
  802607:	29 fa                	sub    %edi,%edx
  802609:	d3 e0                	shl    %cl,%eax
  80260b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80260f:	89 d1                	mov    %edx,%ecx
  802611:	89 d8                	mov    %ebx,%eax
  802613:	d3 e8                	shr    %cl,%eax
  802615:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802619:	09 c1                	or     %eax,%ecx
  80261b:	89 f0                	mov    %esi,%eax
  80261d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802621:	89 f9                	mov    %edi,%ecx
  802623:	d3 e3                	shl    %cl,%ebx
  802625:	89 d1                	mov    %edx,%ecx
  802627:	d3 e8                	shr    %cl,%eax
  802629:	89 f9                	mov    %edi,%ecx
  80262b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80262f:	89 eb                	mov    %ebp,%ebx
  802631:	d3 e6                	shl    %cl,%esi
  802633:	89 d1                	mov    %edx,%ecx
  802635:	d3 eb                	shr    %cl,%ebx
  802637:	09 f3                	or     %esi,%ebx
  802639:	89 c6                	mov    %eax,%esi
  80263b:	89 f2                	mov    %esi,%edx
  80263d:	89 d8                	mov    %ebx,%eax
  80263f:	f7 74 24 08          	divl   0x8(%esp)
  802643:	89 d6                	mov    %edx,%esi
  802645:	89 c3                	mov    %eax,%ebx
  802647:	f7 64 24 0c          	mull   0xc(%esp)
  80264b:	39 d6                	cmp    %edx,%esi
  80264d:	72 19                	jb     802668 <__udivdi3+0x108>
  80264f:	89 f9                	mov    %edi,%ecx
  802651:	d3 e5                	shl    %cl,%ebp
  802653:	39 c5                	cmp    %eax,%ebp
  802655:	73 04                	jae    80265b <__udivdi3+0xfb>
  802657:	39 d6                	cmp    %edx,%esi
  802659:	74 0d                	je     802668 <__udivdi3+0x108>
  80265b:	89 d8                	mov    %ebx,%eax
  80265d:	31 ff                	xor    %edi,%edi
  80265f:	e9 3c ff ff ff       	jmp    8025a0 <__udivdi3+0x40>
  802664:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802668:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80266b:	31 ff                	xor    %edi,%edi
  80266d:	e9 2e ff ff ff       	jmp    8025a0 <__udivdi3+0x40>
  802672:	66 90                	xchg   %ax,%ax
  802674:	66 90                	xchg   %ax,%ax
  802676:	66 90                	xchg   %ax,%ax
  802678:	66 90                	xchg   %ax,%ax
  80267a:	66 90                	xchg   %ax,%ax
  80267c:	66 90                	xchg   %ax,%ax
  80267e:	66 90                	xchg   %ax,%ax

00802680 <__umoddi3>:
  802680:	f3 0f 1e fb          	endbr32 
  802684:	55                   	push   %ebp
  802685:	57                   	push   %edi
  802686:	56                   	push   %esi
  802687:	53                   	push   %ebx
  802688:	83 ec 1c             	sub    $0x1c,%esp
  80268b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80268f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802693:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802697:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80269b:	89 f0                	mov    %esi,%eax
  80269d:	89 da                	mov    %ebx,%edx
  80269f:	85 ff                	test   %edi,%edi
  8026a1:	75 15                	jne    8026b8 <__umoddi3+0x38>
  8026a3:	39 dd                	cmp    %ebx,%ebp
  8026a5:	76 39                	jbe    8026e0 <__umoddi3+0x60>
  8026a7:	f7 f5                	div    %ebp
  8026a9:	89 d0                	mov    %edx,%eax
  8026ab:	31 d2                	xor    %edx,%edx
  8026ad:	83 c4 1c             	add    $0x1c,%esp
  8026b0:	5b                   	pop    %ebx
  8026b1:	5e                   	pop    %esi
  8026b2:	5f                   	pop    %edi
  8026b3:	5d                   	pop    %ebp
  8026b4:	c3                   	ret    
  8026b5:	8d 76 00             	lea    0x0(%esi),%esi
  8026b8:	39 df                	cmp    %ebx,%edi
  8026ba:	77 f1                	ja     8026ad <__umoddi3+0x2d>
  8026bc:	0f bd cf             	bsr    %edi,%ecx
  8026bf:	83 f1 1f             	xor    $0x1f,%ecx
  8026c2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8026c6:	75 40                	jne    802708 <__umoddi3+0x88>
  8026c8:	39 df                	cmp    %ebx,%edi
  8026ca:	72 04                	jb     8026d0 <__umoddi3+0x50>
  8026cc:	39 f5                	cmp    %esi,%ebp
  8026ce:	77 dd                	ja     8026ad <__umoddi3+0x2d>
  8026d0:	89 da                	mov    %ebx,%edx
  8026d2:	89 f0                	mov    %esi,%eax
  8026d4:	29 e8                	sub    %ebp,%eax
  8026d6:	19 fa                	sbb    %edi,%edx
  8026d8:	eb d3                	jmp    8026ad <__umoddi3+0x2d>
  8026da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026e0:	89 e9                	mov    %ebp,%ecx
  8026e2:	85 ed                	test   %ebp,%ebp
  8026e4:	75 0b                	jne    8026f1 <__umoddi3+0x71>
  8026e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026eb:	31 d2                	xor    %edx,%edx
  8026ed:	f7 f5                	div    %ebp
  8026ef:	89 c1                	mov    %eax,%ecx
  8026f1:	89 d8                	mov    %ebx,%eax
  8026f3:	31 d2                	xor    %edx,%edx
  8026f5:	f7 f1                	div    %ecx
  8026f7:	89 f0                	mov    %esi,%eax
  8026f9:	f7 f1                	div    %ecx
  8026fb:	89 d0                	mov    %edx,%eax
  8026fd:	31 d2                	xor    %edx,%edx
  8026ff:	eb ac                	jmp    8026ad <__umoddi3+0x2d>
  802701:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802708:	8b 44 24 04          	mov    0x4(%esp),%eax
  80270c:	ba 20 00 00 00       	mov    $0x20,%edx
  802711:	29 c2                	sub    %eax,%edx
  802713:	89 c1                	mov    %eax,%ecx
  802715:	89 e8                	mov    %ebp,%eax
  802717:	d3 e7                	shl    %cl,%edi
  802719:	89 d1                	mov    %edx,%ecx
  80271b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80271f:	d3 e8                	shr    %cl,%eax
  802721:	89 c1                	mov    %eax,%ecx
  802723:	8b 44 24 04          	mov    0x4(%esp),%eax
  802727:	09 f9                	or     %edi,%ecx
  802729:	89 df                	mov    %ebx,%edi
  80272b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80272f:	89 c1                	mov    %eax,%ecx
  802731:	d3 e5                	shl    %cl,%ebp
  802733:	89 d1                	mov    %edx,%ecx
  802735:	d3 ef                	shr    %cl,%edi
  802737:	89 c1                	mov    %eax,%ecx
  802739:	89 f0                	mov    %esi,%eax
  80273b:	d3 e3                	shl    %cl,%ebx
  80273d:	89 d1                	mov    %edx,%ecx
  80273f:	89 fa                	mov    %edi,%edx
  802741:	d3 e8                	shr    %cl,%eax
  802743:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802748:	09 d8                	or     %ebx,%eax
  80274a:	f7 74 24 08          	divl   0x8(%esp)
  80274e:	89 d3                	mov    %edx,%ebx
  802750:	d3 e6                	shl    %cl,%esi
  802752:	f7 e5                	mul    %ebp
  802754:	89 c7                	mov    %eax,%edi
  802756:	89 d1                	mov    %edx,%ecx
  802758:	39 d3                	cmp    %edx,%ebx
  80275a:	72 06                	jb     802762 <__umoddi3+0xe2>
  80275c:	75 0e                	jne    80276c <__umoddi3+0xec>
  80275e:	39 c6                	cmp    %eax,%esi
  802760:	73 0a                	jae    80276c <__umoddi3+0xec>
  802762:	29 e8                	sub    %ebp,%eax
  802764:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802768:	89 d1                	mov    %edx,%ecx
  80276a:	89 c7                	mov    %eax,%edi
  80276c:	89 f5                	mov    %esi,%ebp
  80276e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802772:	29 fd                	sub    %edi,%ebp
  802774:	19 cb                	sbb    %ecx,%ebx
  802776:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80277b:	89 d8                	mov    %ebx,%eax
  80277d:	d3 e0                	shl    %cl,%eax
  80277f:	89 f1                	mov    %esi,%ecx
  802781:	d3 ed                	shr    %cl,%ebp
  802783:	d3 eb                	shr    %cl,%ebx
  802785:	09 e8                	or     %ebp,%eax
  802787:	89 da                	mov    %ebx,%edx
  802789:	83 c4 1c             	add    $0x1c,%esp
  80278c:	5b                   	pop    %ebx
  80278d:	5e                   	pop    %esi
  80278e:	5f                   	pop    %edi
  80278f:	5d                   	pop    %ebp
  802790:	c3                   	ret    
