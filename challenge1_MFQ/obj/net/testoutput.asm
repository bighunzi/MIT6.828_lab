
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
  800038:	e8 3a 0d 00 00       	call   800d77 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi
	int i, r;

	binaryname = "testoutput";
  80003f:	c7 05 00 30 80 00 c0 	movl   $0x8027c0,0x803000
  800046:	27 80 00 

	output_envid = fork();
  800049:	e8 b7 10 00 00       	call   801105 <fork>
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
  800072:	e8 3e 0d 00 00       	call   800db5 <sys_page_alloc>
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	85 c0                	test   %eax,%eax
  80007c:	0f 88 8e 00 00 00    	js     800110 <umain+0xdd>
			panic("sys_page_alloc: %e", r);
		pkt->jp_len = snprintf(pkt->jp_data,
  800082:	53                   	push   %ebx
  800083:	68 fd 27 80 00       	push   $0x8027fd
  800088:	68 fc 0f 00 00       	push   $0xffc
  80008d:	68 04 b0 fe 0f       	push   $0xffeb004
  800092:	e8 cd 08 00 00       	call   800964 <snprintf>
  800097:	a3 00 b0 fe 0f       	mov    %eax,0xffeb000
				       PGSIZE - sizeof(pkt->jp_len),
				       "Packet %02d", i);
		cprintf("Transmitting packet %d\n", i);
  80009c:	83 c4 08             	add    $0x8,%esp
  80009f:	53                   	push   %ebx
  8000a0:	68 09 28 80 00       	push   $0x802809
  8000a5:	e8 35 03 00 00       	call   8003df <cprintf>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8000aa:	6a 07                	push   $0x7
  8000ac:	68 00 b0 fe 0f       	push   $0xffeb000
  8000b1:	6a 0b                	push   $0xb
  8000b3:	ff 35 00 40 80 00    	push   0x804000
  8000b9:	e8 3a 12 00 00       	call   8012f8 <ipc_send>
		sys_page_unmap(0, pkt);
  8000be:	83 c4 18             	add    $0x18,%esp
  8000c1:	68 00 b0 fe 0f       	push   $0xffeb000
  8000c6:	6a 00                	push   $0x0
  8000c8:	e8 6d 0d 00 00       	call   800e3a <sys_page_unmap>
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
  8000dd:	e8 b4 0c 00 00       	call   800d96 <sys_yield>
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
  8000f1:	68 cb 27 80 00       	push   $0x8027cb
  8000f6:	6a 16                	push   $0x16
  8000f8:	68 d9 27 80 00       	push   $0x8027d9
  8000fd:	e8 02 02 00 00       	call   800304 <_panic>
		output(ns_envid);
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	56                   	push   %esi
  800106:	e8 3e 01 00 00       	call   800249 <output>
		return;
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	eb d7                	jmp    8000e7 <umain+0xb4>
			panic("sys_page_alloc: %e", r);
  800110:	50                   	push   %eax
  800111:	68 ea 27 80 00       	push   $0x8027ea
  800116:	6a 1e                	push   $0x1e
  800118:	68 d9 27 80 00       	push   $0x8027d9
  80011d:	e8 e2 01 00 00       	call   800304 <_panic>

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
  80012e:	e8 73 0e 00 00       	call   800fa6 <sys_time_msec>
  800133:	03 45 0c             	add    0xc(%ebp),%eax
  800136:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  800138:	c7 05 00 30 80 00 21 	movl   $0x802821,0x803000
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
  800152:	e8 a1 11 00 00       	call   8012f8 <ipc_send>
  800157:	83 c4 10             	add    $0x10,%esp
			to = ipc_recv((int32_t *) &whom, 0, 0);
  80015a:	83 ec 04             	sub    $0x4,%esp
  80015d:	6a 00                	push   $0x0
  80015f:	6a 00                	push   $0x0
  800161:	57                   	push   %edi
  800162:	e8 21 11 00 00       	call   801288 <ipc_recv>
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
  800173:	e8 2e 0e 00 00       	call   800fa6 <sys_time_msec>
  800178:	01 c3                	add    %eax,%ebx
		while((r = sys_time_msec()) < stop && r >= 0) {
  80017a:	e8 27 0e 00 00       	call   800fa6 <sys_time_msec>
  80017f:	85 c0                	test   %eax,%eax
  800181:	78 c4                	js     800147 <timer+0x25>
  800183:	39 d8                	cmp    %ebx,%eax
  800185:	73 c0                	jae    800147 <timer+0x25>
			sys_yield();
  800187:	e8 0a 0c 00 00       	call   800d96 <sys_yield>
  80018c:	eb ec                	jmp    80017a <timer+0x58>
			panic("sys_time_msec: %e", r);
  80018e:	50                   	push   %eax
  80018f:	68 2a 28 80 00       	push   $0x80282a
  800194:	6a 0f                	push   $0xf
  800196:	68 3c 28 80 00       	push   $0x80283c
  80019b:	e8 64 01 00 00       	call   800304 <_panic>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  8001a0:	83 ec 08             	sub    $0x8,%esp
  8001a3:	50                   	push   %eax
  8001a4:	68 48 28 80 00       	push   $0x802848
  8001a9:	e8 31 02 00 00       	call   8003df <cprintf>
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
    int now = sys_time_msec();
  8001bb:	e8 e6 0d 00 00       	call   800fa6 <sys_time_msec>
  8001c0:	89 c3                	mov    %eax,%ebx

    while (msec > sys_time_msec()-now){
  8001c2:	eb 05                	jmp    8001c9 <sleep+0x16>
    	sys_yield();
  8001c4:	e8 cd 0b 00 00       	call   800d96 <sys_yield>
    while (msec > sys_time_msec()-now){
  8001c9:	e8 d8 0d 00 00       	call   800fa6 <sys_time_msec>
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
  8001e7:	c7 05 00 30 80 00 83 	movl   $0x802883,0x803000
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
  8001fc:	e8 95 0b 00 00       	call   800d96 <sys_yield>
		while ( sys_e1000_recv(rev_buf, &len)  < 0) {
  800201:	83 ec 08             	sub    $0x8,%esp
  800204:	56                   	push   %esi
  800205:	53                   	push   %ebx
  800206:	e8 db 0d 00 00       	call   800fe6 <sys_e1000_recv>
  80020b:	83 c4 10             	add    $0x10,%esp
  80020e:	85 c0                	test   %eax,%eax
  800210:	78 ea                	js     8001fc <input+0x24>
		}
		memcpy(nsipcbuf.pkt.jp_data, rev_buf, len);
  800212:	83 ec 04             	sub    $0x4,%esp
  800215:	ff 75 e4             	push   -0x1c(%ebp)
  800218:	53                   	push   %ebx
  800219:	68 04 70 80 00       	push   $0x807004
  80021e:	e8 8e 09 00 00       	call   800bb1 <memcpy>
		nsipcbuf.pkt.jp_len = len;
  800223:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800226:	a3 00 70 80 00       	mov    %eax,0x807000
		
		ipc_send(ns_envid, NSREQ_INPUT, &nsipcbuf, PTE_P|PTE_U);
  80022b:	6a 05                	push   $0x5
  80022d:	68 00 70 80 00       	push   $0x807000
  800232:	6a 0a                	push   $0xa
  800234:	57                   	push   %edi
  800235:	e8 be 10 00 00       	call   8012f8 <ipc_send>
		
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
  800254:	c7 05 00 30 80 00 8c 	movl   $0x80288c,0x803000
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
  800263:	e8 2e 0b 00 00       	call   800d96 <sys_yield>
		while( sys_e1000_try_send( nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len ) < 0 ){
  800268:	83 ec 08             	sub    $0x8,%esp
  80026b:	ff 35 00 70 80 00    	push   0x807000
  800271:	68 04 70 80 00       	push   $0x807004
  800276:	e8 4a 0d 00 00       	call   800fc5 <sys_e1000_try_send>
  80027b:	83 c4 10             	add    $0x10,%esp
  80027e:	85 c0                	test   %eax,%eax
  800280:	78 e1                	js     800263 <output+0x1a>
		r=ipc_recv( &from_env , &nsipcbuf, NULL);
  800282:	83 ec 04             	sub    $0x4,%esp
  800285:	6a 00                	push   $0x0
  800287:	68 00 70 80 00       	push   $0x807000
  80028c:	53                   	push   %ebx
  80028d:	e8 f6 0f 00 00       	call   801288 <ipc_recv>
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
  8002ac:	e8 c6 0a 00 00       	call   800d77 <sys_getenvid>
  8002b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002b6:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8002bc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002c1:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002c6:	85 db                	test   %ebx,%ebx
  8002c8:	7e 07                	jle    8002d1 <libmain+0x30>
		binaryname = argv[0];
  8002ca:	8b 06                	mov    (%esi),%eax
  8002cc:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002d1:	83 ec 08             	sub    $0x8,%esp
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	e8 58 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002db:	e8 0a 00 00 00       	call   8002ea <exit>
}
  8002e0:	83 c4 10             	add    $0x10,%esp
  8002e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    

008002ea <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002f0:	e8 67 12 00 00       	call   80155c <close_all>
	sys_env_destroy(0);
  8002f5:	83 ec 0c             	sub    $0xc,%esp
  8002f8:	6a 00                	push   $0x0
  8002fa:	e8 37 0a 00 00       	call   800d36 <sys_env_destroy>
}
  8002ff:	83 c4 10             	add    $0x10,%esp
  800302:	c9                   	leave  
  800303:	c3                   	ret    

00800304 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	56                   	push   %esi
  800308:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800309:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80030c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800312:	e8 60 0a 00 00       	call   800d77 <sys_getenvid>
  800317:	83 ec 0c             	sub    $0xc,%esp
  80031a:	ff 75 0c             	push   0xc(%ebp)
  80031d:	ff 75 08             	push   0x8(%ebp)
  800320:	56                   	push   %esi
  800321:	50                   	push   %eax
  800322:	68 a0 28 80 00       	push   $0x8028a0
  800327:	e8 b3 00 00 00       	call   8003df <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80032c:	83 c4 18             	add    $0x18,%esp
  80032f:	53                   	push   %ebx
  800330:	ff 75 10             	push   0x10(%ebp)
  800333:	e8 56 00 00 00       	call   80038e <vcprintf>
	cprintf("\n");
  800338:	c7 04 24 1f 28 80 00 	movl   $0x80281f,(%esp)
  80033f:	e8 9b 00 00 00       	call   8003df <cprintf>
  800344:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800347:	cc                   	int3   
  800348:	eb fd                	jmp    800347 <_panic+0x43>

0080034a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	53                   	push   %ebx
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800354:	8b 13                	mov    (%ebx),%edx
  800356:	8d 42 01             	lea    0x1(%edx),%eax
  800359:	89 03                	mov    %eax,(%ebx)
  80035b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80035e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800362:	3d ff 00 00 00       	cmp    $0xff,%eax
  800367:	74 09                	je     800372 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800369:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80036d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800370:	c9                   	leave  
  800371:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800372:	83 ec 08             	sub    $0x8,%esp
  800375:	68 ff 00 00 00       	push   $0xff
  80037a:	8d 43 08             	lea    0x8(%ebx),%eax
  80037d:	50                   	push   %eax
  80037e:	e8 76 09 00 00       	call   800cf9 <sys_cputs>
		b->idx = 0;
  800383:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800389:	83 c4 10             	add    $0x10,%esp
  80038c:	eb db                	jmp    800369 <putch+0x1f>

0080038e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800397:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80039e:	00 00 00 
	b.cnt = 0;
  8003a1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003a8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ab:	ff 75 0c             	push   0xc(%ebp)
  8003ae:	ff 75 08             	push   0x8(%ebp)
  8003b1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003b7:	50                   	push   %eax
  8003b8:	68 4a 03 80 00       	push   $0x80034a
  8003bd:	e8 14 01 00 00       	call   8004d6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c2:	83 c4 08             	add    $0x8,%esp
  8003c5:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003cb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d1:	50                   	push   %eax
  8003d2:	e8 22 09 00 00       	call   800cf9 <sys_cputs>

	return b.cnt;
}
  8003d7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003dd:	c9                   	leave  
  8003de:	c3                   	ret    

008003df <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003e8:	50                   	push   %eax
  8003e9:	ff 75 08             	push   0x8(%ebp)
  8003ec:	e8 9d ff ff ff       	call   80038e <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f1:	c9                   	leave  
  8003f2:	c3                   	ret    

008003f3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f3:	55                   	push   %ebp
  8003f4:	89 e5                	mov    %esp,%ebp
  8003f6:	57                   	push   %edi
  8003f7:	56                   	push   %esi
  8003f8:	53                   	push   %ebx
  8003f9:	83 ec 1c             	sub    $0x1c,%esp
  8003fc:	89 c7                	mov    %eax,%edi
  8003fe:	89 d6                	mov    %edx,%esi
  800400:	8b 45 08             	mov    0x8(%ebp),%eax
  800403:	8b 55 0c             	mov    0xc(%ebp),%edx
  800406:	89 d1                	mov    %edx,%ecx
  800408:	89 c2                	mov    %eax,%edx
  80040a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800410:	8b 45 10             	mov    0x10(%ebp),%eax
  800413:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800416:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800419:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800420:	39 c2                	cmp    %eax,%edx
  800422:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800425:	72 3e                	jb     800465 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff 75 18             	push   0x18(%ebp)
  80042d:	83 eb 01             	sub    $0x1,%ebx
  800430:	53                   	push   %ebx
  800431:	50                   	push   %eax
  800432:	83 ec 08             	sub    $0x8,%esp
  800435:	ff 75 e4             	push   -0x1c(%ebp)
  800438:	ff 75 e0             	push   -0x20(%ebp)
  80043b:	ff 75 dc             	push   -0x24(%ebp)
  80043e:	ff 75 d8             	push   -0x28(%ebp)
  800441:	e8 3a 21 00 00       	call   802580 <__udivdi3>
  800446:	83 c4 18             	add    $0x18,%esp
  800449:	52                   	push   %edx
  80044a:	50                   	push   %eax
  80044b:	89 f2                	mov    %esi,%edx
  80044d:	89 f8                	mov    %edi,%eax
  80044f:	e8 9f ff ff ff       	call   8003f3 <printnum>
  800454:	83 c4 20             	add    $0x20,%esp
  800457:	eb 13                	jmp    80046c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800459:	83 ec 08             	sub    $0x8,%esp
  80045c:	56                   	push   %esi
  80045d:	ff 75 18             	push   0x18(%ebp)
  800460:	ff d7                	call   *%edi
  800462:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800465:	83 eb 01             	sub    $0x1,%ebx
  800468:	85 db                	test   %ebx,%ebx
  80046a:	7f ed                	jg     800459 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	56                   	push   %esi
  800470:	83 ec 04             	sub    $0x4,%esp
  800473:	ff 75 e4             	push   -0x1c(%ebp)
  800476:	ff 75 e0             	push   -0x20(%ebp)
  800479:	ff 75 dc             	push   -0x24(%ebp)
  80047c:	ff 75 d8             	push   -0x28(%ebp)
  80047f:	e8 1c 22 00 00       	call   8026a0 <__umoddi3>
  800484:	83 c4 14             	add    $0x14,%esp
  800487:	0f be 80 c3 28 80 00 	movsbl 0x8028c3(%eax),%eax
  80048e:	50                   	push   %eax
  80048f:	ff d7                	call   *%edi
}
  800491:	83 c4 10             	add    $0x10,%esp
  800494:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800497:	5b                   	pop    %ebx
  800498:	5e                   	pop    %esi
  800499:	5f                   	pop    %edi
  80049a:	5d                   	pop    %ebp
  80049b:	c3                   	ret    

0080049c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
  80049f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004a6:	8b 10                	mov    (%eax),%edx
  8004a8:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ab:	73 0a                	jae    8004b7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ad:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004b0:	89 08                	mov    %ecx,(%eax)
  8004b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b5:	88 02                	mov    %al,(%edx)
}
  8004b7:	5d                   	pop    %ebp
  8004b8:	c3                   	ret    

008004b9 <printfmt>:
{
  8004b9:	55                   	push   %ebp
  8004ba:	89 e5                	mov    %esp,%ebp
  8004bc:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004bf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c2:	50                   	push   %eax
  8004c3:	ff 75 10             	push   0x10(%ebp)
  8004c6:	ff 75 0c             	push   0xc(%ebp)
  8004c9:	ff 75 08             	push   0x8(%ebp)
  8004cc:	e8 05 00 00 00       	call   8004d6 <vprintfmt>
}
  8004d1:	83 c4 10             	add    $0x10,%esp
  8004d4:	c9                   	leave  
  8004d5:	c3                   	ret    

008004d6 <vprintfmt>:
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	57                   	push   %edi
  8004da:	56                   	push   %esi
  8004db:	53                   	push   %ebx
  8004dc:	83 ec 3c             	sub    $0x3c,%esp
  8004df:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004e8:	eb 0a                	jmp    8004f4 <vprintfmt+0x1e>
			putch(ch, putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	53                   	push   %ebx
  8004ee:	50                   	push   %eax
  8004ef:	ff d6                	call   *%esi
  8004f1:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004f4:	83 c7 01             	add    $0x1,%edi
  8004f7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004fb:	83 f8 25             	cmp    $0x25,%eax
  8004fe:	74 0c                	je     80050c <vprintfmt+0x36>
			if (ch == '\0')
  800500:	85 c0                	test   %eax,%eax
  800502:	75 e6                	jne    8004ea <vprintfmt+0x14>
}
  800504:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800507:	5b                   	pop    %ebx
  800508:	5e                   	pop    %esi
  800509:	5f                   	pop    %edi
  80050a:	5d                   	pop    %ebp
  80050b:	c3                   	ret    
		padc = ' ';
  80050c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800510:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800517:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80051e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800525:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80052a:	8d 47 01             	lea    0x1(%edi),%eax
  80052d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800530:	0f b6 17             	movzbl (%edi),%edx
  800533:	8d 42 dd             	lea    -0x23(%edx),%eax
  800536:	3c 55                	cmp    $0x55,%al
  800538:	0f 87 bb 03 00 00    	ja     8008f9 <vprintfmt+0x423>
  80053e:	0f b6 c0             	movzbl %al,%eax
  800541:	ff 24 85 00 2a 80 00 	jmp    *0x802a00(,%eax,4)
  800548:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80054b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80054f:	eb d9                	jmp    80052a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800551:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800554:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800558:	eb d0                	jmp    80052a <vprintfmt+0x54>
  80055a:	0f b6 d2             	movzbl %dl,%edx
  80055d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800560:	b8 00 00 00 00       	mov    $0x0,%eax
  800565:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800568:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80056b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80056f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800572:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800575:	83 f9 09             	cmp    $0x9,%ecx
  800578:	77 55                	ja     8005cf <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80057a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80057d:	eb e9                	jmp    800568 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8b 00                	mov    (%eax),%eax
  800584:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800587:	8b 45 14             	mov    0x14(%ebp),%eax
  80058a:	8d 40 04             	lea    0x4(%eax),%eax
  80058d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800590:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800593:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800597:	79 91                	jns    80052a <vprintfmt+0x54>
				width = precision, precision = -1;
  800599:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80059c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80059f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005a6:	eb 82                	jmp    80052a <vprintfmt+0x54>
  8005a8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005ab:	85 d2                	test   %edx,%edx
  8005ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b2:	0f 49 c2             	cmovns %edx,%eax
  8005b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005bb:	e9 6a ff ff ff       	jmp    80052a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005c3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005ca:	e9 5b ff ff ff       	jmp    80052a <vprintfmt+0x54>
  8005cf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d5:	eb bc                	jmp    800593 <vprintfmt+0xbd>
			lflag++;
  8005d7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005dd:	e9 48 ff ff ff       	jmp    80052a <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 78 04             	lea    0x4(%eax),%edi
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	53                   	push   %ebx
  8005ec:	ff 30                	push   (%eax)
  8005ee:	ff d6                	call   *%esi
			break;
  8005f0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005f3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005f6:	e9 9d 02 00 00       	jmp    800898 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 78 04             	lea    0x4(%eax),%edi
  800601:	8b 10                	mov    (%eax),%edx
  800603:	89 d0                	mov    %edx,%eax
  800605:	f7 d8                	neg    %eax
  800607:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80060a:	83 f8 0f             	cmp    $0xf,%eax
  80060d:	7f 23                	jg     800632 <vprintfmt+0x15c>
  80060f:	8b 14 85 60 2b 80 00 	mov    0x802b60(,%eax,4),%edx
  800616:	85 d2                	test   %edx,%edx
  800618:	74 18                	je     800632 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80061a:	52                   	push   %edx
  80061b:	68 81 2d 80 00       	push   $0x802d81
  800620:	53                   	push   %ebx
  800621:	56                   	push   %esi
  800622:	e8 92 fe ff ff       	call   8004b9 <printfmt>
  800627:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80062a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80062d:	e9 66 02 00 00       	jmp    800898 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800632:	50                   	push   %eax
  800633:	68 db 28 80 00       	push   $0x8028db
  800638:	53                   	push   %ebx
  800639:	56                   	push   %esi
  80063a:	e8 7a fe ff ff       	call   8004b9 <printfmt>
  80063f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800642:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800645:	e9 4e 02 00 00       	jmp    800898 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	83 c0 04             	add    $0x4,%eax
  800650:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800658:	85 d2                	test   %edx,%edx
  80065a:	b8 d4 28 80 00       	mov    $0x8028d4,%eax
  80065f:	0f 45 c2             	cmovne %edx,%eax
  800662:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800665:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800669:	7e 06                	jle    800671 <vprintfmt+0x19b>
  80066b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80066f:	75 0d                	jne    80067e <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800671:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800674:	89 c7                	mov    %eax,%edi
  800676:	03 45 e0             	add    -0x20(%ebp),%eax
  800679:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80067c:	eb 55                	jmp    8006d3 <vprintfmt+0x1fd>
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	ff 75 d8             	push   -0x28(%ebp)
  800684:	ff 75 cc             	push   -0x34(%ebp)
  800687:	e8 0a 03 00 00       	call   800996 <strnlen>
  80068c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80068f:	29 c1                	sub    %eax,%ecx
  800691:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800694:	83 c4 10             	add    $0x10,%esp
  800697:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800699:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80069d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a0:	eb 0f                	jmp    8006b1 <vprintfmt+0x1db>
					putch(padc, putdat);
  8006a2:	83 ec 08             	sub    $0x8,%esp
  8006a5:	53                   	push   %ebx
  8006a6:	ff 75 e0             	push   -0x20(%ebp)
  8006a9:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ab:	83 ef 01             	sub    $0x1,%edi
  8006ae:	83 c4 10             	add    $0x10,%esp
  8006b1:	85 ff                	test   %edi,%edi
  8006b3:	7f ed                	jg     8006a2 <vprintfmt+0x1cc>
  8006b5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006b8:	85 d2                	test   %edx,%edx
  8006ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bf:	0f 49 c2             	cmovns %edx,%eax
  8006c2:	29 c2                	sub    %eax,%edx
  8006c4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006c7:	eb a8                	jmp    800671 <vprintfmt+0x19b>
					putch(ch, putdat);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	53                   	push   %ebx
  8006cd:	52                   	push   %edx
  8006ce:	ff d6                	call   *%esi
  8006d0:	83 c4 10             	add    $0x10,%esp
  8006d3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006d6:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d8:	83 c7 01             	add    $0x1,%edi
  8006db:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006df:	0f be d0             	movsbl %al,%edx
  8006e2:	85 d2                	test   %edx,%edx
  8006e4:	74 4b                	je     800731 <vprintfmt+0x25b>
  8006e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006ea:	78 06                	js     8006f2 <vprintfmt+0x21c>
  8006ec:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8006f0:	78 1e                	js     800710 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8006f2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006f6:	74 d1                	je     8006c9 <vprintfmt+0x1f3>
  8006f8:	0f be c0             	movsbl %al,%eax
  8006fb:	83 e8 20             	sub    $0x20,%eax
  8006fe:	83 f8 5e             	cmp    $0x5e,%eax
  800701:	76 c6                	jbe    8006c9 <vprintfmt+0x1f3>
					putch('?', putdat);
  800703:	83 ec 08             	sub    $0x8,%esp
  800706:	53                   	push   %ebx
  800707:	6a 3f                	push   $0x3f
  800709:	ff d6                	call   *%esi
  80070b:	83 c4 10             	add    $0x10,%esp
  80070e:	eb c3                	jmp    8006d3 <vprintfmt+0x1fd>
  800710:	89 cf                	mov    %ecx,%edi
  800712:	eb 0e                	jmp    800722 <vprintfmt+0x24c>
				putch(' ', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	6a 20                	push   $0x20
  80071a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80071c:	83 ef 01             	sub    $0x1,%edi
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	85 ff                	test   %edi,%edi
  800724:	7f ee                	jg     800714 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800726:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800729:	89 45 14             	mov    %eax,0x14(%ebp)
  80072c:	e9 67 01 00 00       	jmp    800898 <vprintfmt+0x3c2>
  800731:	89 cf                	mov    %ecx,%edi
  800733:	eb ed                	jmp    800722 <vprintfmt+0x24c>
	if (lflag >= 2)
  800735:	83 f9 01             	cmp    $0x1,%ecx
  800738:	7f 1b                	jg     800755 <vprintfmt+0x27f>
	else if (lflag)
  80073a:	85 c9                	test   %ecx,%ecx
  80073c:	74 63                	je     8007a1 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80073e:	8b 45 14             	mov    0x14(%ebp),%eax
  800741:	8b 00                	mov    (%eax),%eax
  800743:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800746:	99                   	cltd   
  800747:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8d 40 04             	lea    0x4(%eax),%eax
  800750:	89 45 14             	mov    %eax,0x14(%ebp)
  800753:	eb 17                	jmp    80076c <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800755:	8b 45 14             	mov    0x14(%ebp),%eax
  800758:	8b 50 04             	mov    0x4(%eax),%edx
  80075b:	8b 00                	mov    (%eax),%eax
  80075d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800760:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8d 40 08             	lea    0x8(%eax),%eax
  800769:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80076c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80076f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800772:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800777:	85 c9                	test   %ecx,%ecx
  800779:	0f 89 ff 00 00 00    	jns    80087e <vprintfmt+0x3a8>
				putch('-', putdat);
  80077f:	83 ec 08             	sub    $0x8,%esp
  800782:	53                   	push   %ebx
  800783:	6a 2d                	push   $0x2d
  800785:	ff d6                	call   *%esi
				num = -(long long) num;
  800787:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80078a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80078d:	f7 da                	neg    %edx
  80078f:	83 d1 00             	adc    $0x0,%ecx
  800792:	f7 d9                	neg    %ecx
  800794:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800797:	bf 0a 00 00 00       	mov    $0xa,%edi
  80079c:	e9 dd 00 00 00       	jmp    80087e <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8007a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a4:	8b 00                	mov    (%eax),%eax
  8007a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a9:	99                   	cltd   
  8007aa:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b0:	8d 40 04             	lea    0x4(%eax),%eax
  8007b3:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b6:	eb b4                	jmp    80076c <vprintfmt+0x296>
	if (lflag >= 2)
  8007b8:	83 f9 01             	cmp    $0x1,%ecx
  8007bb:	7f 1e                	jg     8007db <vprintfmt+0x305>
	else if (lflag)
  8007bd:	85 c9                	test   %ecx,%ecx
  8007bf:	74 32                	je     8007f3 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8007c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c4:	8b 10                	mov    (%eax),%edx
  8007c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007cb:	8d 40 04             	lea    0x4(%eax),%eax
  8007ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007d1:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8007d6:	e9 a3 00 00 00       	jmp    80087e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8b 10                	mov    (%eax),%edx
  8007e0:	8b 48 04             	mov    0x4(%eax),%ecx
  8007e3:	8d 40 08             	lea    0x8(%eax),%eax
  8007e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007e9:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8007ee:	e9 8b 00 00 00       	jmp    80087e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f6:	8b 10                	mov    (%eax),%edx
  8007f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fd:	8d 40 04             	lea    0x4(%eax),%eax
  800800:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800803:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800808:	eb 74                	jmp    80087e <vprintfmt+0x3a8>
	if (lflag >= 2)
  80080a:	83 f9 01             	cmp    $0x1,%ecx
  80080d:	7f 1b                	jg     80082a <vprintfmt+0x354>
	else if (lflag)
  80080f:	85 c9                	test   %ecx,%ecx
  800811:	74 2c                	je     80083f <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800813:	8b 45 14             	mov    0x14(%ebp),%eax
  800816:	8b 10                	mov    (%eax),%edx
  800818:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081d:	8d 40 04             	lea    0x4(%eax),%eax
  800820:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800823:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800828:	eb 54                	jmp    80087e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80082a:	8b 45 14             	mov    0x14(%ebp),%eax
  80082d:	8b 10                	mov    (%eax),%edx
  80082f:	8b 48 04             	mov    0x4(%eax),%ecx
  800832:	8d 40 08             	lea    0x8(%eax),%eax
  800835:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800838:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80083d:	eb 3f                	jmp    80087e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80083f:	8b 45 14             	mov    0x14(%ebp),%eax
  800842:	8b 10                	mov    (%eax),%edx
  800844:	b9 00 00 00 00       	mov    $0x0,%ecx
  800849:	8d 40 04             	lea    0x4(%eax),%eax
  80084c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80084f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800854:	eb 28                	jmp    80087e <vprintfmt+0x3a8>
			putch('0', putdat);
  800856:	83 ec 08             	sub    $0x8,%esp
  800859:	53                   	push   %ebx
  80085a:	6a 30                	push   $0x30
  80085c:	ff d6                	call   *%esi
			putch('x', putdat);
  80085e:	83 c4 08             	add    $0x8,%esp
  800861:	53                   	push   %ebx
  800862:	6a 78                	push   $0x78
  800864:	ff d6                	call   *%esi
			num = (unsigned long long)
  800866:	8b 45 14             	mov    0x14(%ebp),%eax
  800869:	8b 10                	mov    (%eax),%edx
  80086b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800870:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800873:	8d 40 04             	lea    0x4(%eax),%eax
  800876:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800879:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80087e:	83 ec 0c             	sub    $0xc,%esp
  800881:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800885:	50                   	push   %eax
  800886:	ff 75 e0             	push   -0x20(%ebp)
  800889:	57                   	push   %edi
  80088a:	51                   	push   %ecx
  80088b:	52                   	push   %edx
  80088c:	89 da                	mov    %ebx,%edx
  80088e:	89 f0                	mov    %esi,%eax
  800890:	e8 5e fb ff ff       	call   8003f3 <printnum>
			break;
  800895:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800898:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80089b:	e9 54 fc ff ff       	jmp    8004f4 <vprintfmt+0x1e>
	if (lflag >= 2)
  8008a0:	83 f9 01             	cmp    $0x1,%ecx
  8008a3:	7f 1b                	jg     8008c0 <vprintfmt+0x3ea>
	else if (lflag)
  8008a5:	85 c9                	test   %ecx,%ecx
  8008a7:	74 2c                	je     8008d5 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8008a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ac:	8b 10                	mov    (%eax),%edx
  8008ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b3:	8d 40 04             	lea    0x4(%eax),%eax
  8008b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008b9:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8008be:	eb be                	jmp    80087e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8008c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c3:	8b 10                	mov    (%eax),%edx
  8008c5:	8b 48 04             	mov    0x4(%eax),%ecx
  8008c8:	8d 40 08             	lea    0x8(%eax),%eax
  8008cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ce:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8008d3:	eb a9                	jmp    80087e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8008d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d8:	8b 10                	mov    (%eax),%edx
  8008da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008df:	8d 40 04             	lea    0x4(%eax),%eax
  8008e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008e5:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8008ea:	eb 92                	jmp    80087e <vprintfmt+0x3a8>
			putch(ch, putdat);
  8008ec:	83 ec 08             	sub    $0x8,%esp
  8008ef:	53                   	push   %ebx
  8008f0:	6a 25                	push   $0x25
  8008f2:	ff d6                	call   *%esi
			break;
  8008f4:	83 c4 10             	add    $0x10,%esp
  8008f7:	eb 9f                	jmp    800898 <vprintfmt+0x3c2>
			putch('%', putdat);
  8008f9:	83 ec 08             	sub    $0x8,%esp
  8008fc:	53                   	push   %ebx
  8008fd:	6a 25                	push   $0x25
  8008ff:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800901:	83 c4 10             	add    $0x10,%esp
  800904:	89 f8                	mov    %edi,%eax
  800906:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80090a:	74 05                	je     800911 <vprintfmt+0x43b>
  80090c:	83 e8 01             	sub    $0x1,%eax
  80090f:	eb f5                	jmp    800906 <vprintfmt+0x430>
  800911:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800914:	eb 82                	jmp    800898 <vprintfmt+0x3c2>

00800916 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	83 ec 18             	sub    $0x18,%esp
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800922:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800925:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800929:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80092c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800933:	85 c0                	test   %eax,%eax
  800935:	74 26                	je     80095d <vsnprintf+0x47>
  800937:	85 d2                	test   %edx,%edx
  800939:	7e 22                	jle    80095d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80093b:	ff 75 14             	push   0x14(%ebp)
  80093e:	ff 75 10             	push   0x10(%ebp)
  800941:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800944:	50                   	push   %eax
  800945:	68 9c 04 80 00       	push   $0x80049c
  80094a:	e8 87 fb ff ff       	call   8004d6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80094f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800952:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800955:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800958:	83 c4 10             	add    $0x10,%esp
}
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    
		return -E_INVAL;
  80095d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800962:	eb f7                	jmp    80095b <vsnprintf+0x45>

00800964 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80096a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80096d:	50                   	push   %eax
  80096e:	ff 75 10             	push   0x10(%ebp)
  800971:	ff 75 0c             	push   0xc(%ebp)
  800974:	ff 75 08             	push   0x8(%ebp)
  800977:	e8 9a ff ff ff       	call   800916 <vsnprintf>
	va_end(ap);

	return rc;
}
  80097c:	c9                   	leave  
  80097d:	c3                   	ret    

0080097e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800984:	b8 00 00 00 00       	mov    $0x0,%eax
  800989:	eb 03                	jmp    80098e <strlen+0x10>
		n++;
  80098b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80098e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800992:	75 f7                	jne    80098b <strlen+0xd>
	return n;
}
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099f:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a4:	eb 03                	jmp    8009a9 <strnlen+0x13>
		n++;
  8009a6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a9:	39 d0                	cmp    %edx,%eax
  8009ab:	74 08                	je     8009b5 <strnlen+0x1f>
  8009ad:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009b1:	75 f3                	jne    8009a6 <strnlen+0x10>
  8009b3:	89 c2                	mov    %eax,%edx
	return n;
}
  8009b5:	89 d0                	mov    %edx,%eax
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	53                   	push   %ebx
  8009bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8009cc:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8009cf:	83 c0 01             	add    $0x1,%eax
  8009d2:	84 d2                	test   %dl,%dl
  8009d4:	75 f2                	jne    8009c8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009d6:	89 c8                	mov    %ecx,%eax
  8009d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	53                   	push   %ebx
  8009e1:	83 ec 10             	sub    $0x10,%esp
  8009e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009e7:	53                   	push   %ebx
  8009e8:	e8 91 ff ff ff       	call   80097e <strlen>
  8009ed:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8009f0:	ff 75 0c             	push   0xc(%ebp)
  8009f3:	01 d8                	add    %ebx,%eax
  8009f5:	50                   	push   %eax
  8009f6:	e8 be ff ff ff       	call   8009b9 <strcpy>
	return dst;
}
  8009fb:	89 d8                	mov    %ebx,%eax
  8009fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a00:	c9                   	leave  
  800a01:	c3                   	ret    

00800a02 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	56                   	push   %esi
  800a06:	53                   	push   %ebx
  800a07:	8b 75 08             	mov    0x8(%ebp),%esi
  800a0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0d:	89 f3                	mov    %esi,%ebx
  800a0f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a12:	89 f0                	mov    %esi,%eax
  800a14:	eb 0f                	jmp    800a25 <strncpy+0x23>
		*dst++ = *src;
  800a16:	83 c0 01             	add    $0x1,%eax
  800a19:	0f b6 0a             	movzbl (%edx),%ecx
  800a1c:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a1f:	80 f9 01             	cmp    $0x1,%cl
  800a22:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800a25:	39 d8                	cmp    %ebx,%eax
  800a27:	75 ed                	jne    800a16 <strncpy+0x14>
	}
	return ret;
}
  800a29:	89 f0                	mov    %esi,%eax
  800a2b:	5b                   	pop    %ebx
  800a2c:	5e                   	pop    %esi
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
  800a34:	8b 75 08             	mov    0x8(%ebp),%esi
  800a37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3a:	8b 55 10             	mov    0x10(%ebp),%edx
  800a3d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a3f:	85 d2                	test   %edx,%edx
  800a41:	74 21                	je     800a64 <strlcpy+0x35>
  800a43:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a47:	89 f2                	mov    %esi,%edx
  800a49:	eb 09                	jmp    800a54 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a4b:	83 c1 01             	add    $0x1,%ecx
  800a4e:	83 c2 01             	add    $0x1,%edx
  800a51:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800a54:	39 c2                	cmp    %eax,%edx
  800a56:	74 09                	je     800a61 <strlcpy+0x32>
  800a58:	0f b6 19             	movzbl (%ecx),%ebx
  800a5b:	84 db                	test   %bl,%bl
  800a5d:	75 ec                	jne    800a4b <strlcpy+0x1c>
  800a5f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a61:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a64:	29 f0                	sub    %esi,%eax
}
  800a66:	5b                   	pop    %ebx
  800a67:	5e                   	pop    %esi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a70:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a73:	eb 06                	jmp    800a7b <strcmp+0x11>
		p++, q++;
  800a75:	83 c1 01             	add    $0x1,%ecx
  800a78:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a7b:	0f b6 01             	movzbl (%ecx),%eax
  800a7e:	84 c0                	test   %al,%al
  800a80:	74 04                	je     800a86 <strcmp+0x1c>
  800a82:	3a 02                	cmp    (%edx),%al
  800a84:	74 ef                	je     800a75 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a86:	0f b6 c0             	movzbl %al,%eax
  800a89:	0f b6 12             	movzbl (%edx),%edx
  800a8c:	29 d0                	sub    %edx,%eax
}
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	53                   	push   %ebx
  800a94:	8b 45 08             	mov    0x8(%ebp),%eax
  800a97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9a:	89 c3                	mov    %eax,%ebx
  800a9c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a9f:	eb 06                	jmp    800aa7 <strncmp+0x17>
		n--, p++, q++;
  800aa1:	83 c0 01             	add    $0x1,%eax
  800aa4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800aa7:	39 d8                	cmp    %ebx,%eax
  800aa9:	74 18                	je     800ac3 <strncmp+0x33>
  800aab:	0f b6 08             	movzbl (%eax),%ecx
  800aae:	84 c9                	test   %cl,%cl
  800ab0:	74 04                	je     800ab6 <strncmp+0x26>
  800ab2:	3a 0a                	cmp    (%edx),%cl
  800ab4:	74 eb                	je     800aa1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab6:	0f b6 00             	movzbl (%eax),%eax
  800ab9:	0f b6 12             	movzbl (%edx),%edx
  800abc:	29 d0                	sub    %edx,%eax
}
  800abe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac1:	c9                   	leave  
  800ac2:	c3                   	ret    
		return 0;
  800ac3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac8:	eb f4                	jmp    800abe <strncmp+0x2e>

00800aca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad4:	eb 03                	jmp    800ad9 <strchr+0xf>
  800ad6:	83 c0 01             	add    $0x1,%eax
  800ad9:	0f b6 10             	movzbl (%eax),%edx
  800adc:	84 d2                	test   %dl,%dl
  800ade:	74 06                	je     800ae6 <strchr+0x1c>
		if (*s == c)
  800ae0:	38 ca                	cmp    %cl,%dl
  800ae2:	75 f2                	jne    800ad6 <strchr+0xc>
  800ae4:	eb 05                	jmp    800aeb <strchr+0x21>
			return (char *) s;
	return 0;
  800ae6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	8b 45 08             	mov    0x8(%ebp),%eax
  800af3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800afa:	38 ca                	cmp    %cl,%dl
  800afc:	74 09                	je     800b07 <strfind+0x1a>
  800afe:	84 d2                	test   %dl,%dl
  800b00:	74 05                	je     800b07 <strfind+0x1a>
	for (; *s; s++)
  800b02:	83 c0 01             	add    $0x1,%eax
  800b05:	eb f0                	jmp    800af7 <strfind+0xa>
			break;
	return (char *) s;
}
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	57                   	push   %edi
  800b0d:	56                   	push   %esi
  800b0e:	53                   	push   %ebx
  800b0f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b12:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b15:	85 c9                	test   %ecx,%ecx
  800b17:	74 2f                	je     800b48 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b19:	89 f8                	mov    %edi,%eax
  800b1b:	09 c8                	or     %ecx,%eax
  800b1d:	a8 03                	test   $0x3,%al
  800b1f:	75 21                	jne    800b42 <memset+0x39>
		c &= 0xFF;
  800b21:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b25:	89 d0                	mov    %edx,%eax
  800b27:	c1 e0 08             	shl    $0x8,%eax
  800b2a:	89 d3                	mov    %edx,%ebx
  800b2c:	c1 e3 18             	shl    $0x18,%ebx
  800b2f:	89 d6                	mov    %edx,%esi
  800b31:	c1 e6 10             	shl    $0x10,%esi
  800b34:	09 f3                	or     %esi,%ebx
  800b36:	09 da                	or     %ebx,%edx
  800b38:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b3a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b3d:	fc                   	cld    
  800b3e:	f3 ab                	rep stos %eax,%es:(%edi)
  800b40:	eb 06                	jmp    800b48 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b45:	fc                   	cld    
  800b46:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b48:	89 f8                	mov    %edi,%eax
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	8b 45 08             	mov    0x8(%ebp),%eax
  800b57:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b5d:	39 c6                	cmp    %eax,%esi
  800b5f:	73 32                	jae    800b93 <memmove+0x44>
  800b61:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b64:	39 c2                	cmp    %eax,%edx
  800b66:	76 2b                	jbe    800b93 <memmove+0x44>
		s += n;
		d += n;
  800b68:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b6b:	89 d6                	mov    %edx,%esi
  800b6d:	09 fe                	or     %edi,%esi
  800b6f:	09 ce                	or     %ecx,%esi
  800b71:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b77:	75 0e                	jne    800b87 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b79:	83 ef 04             	sub    $0x4,%edi
  800b7c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b7f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b82:	fd                   	std    
  800b83:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b85:	eb 09                	jmp    800b90 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b87:	83 ef 01             	sub    $0x1,%edi
  800b8a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b8d:	fd                   	std    
  800b8e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b90:	fc                   	cld    
  800b91:	eb 1a                	jmp    800bad <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b93:	89 f2                	mov    %esi,%edx
  800b95:	09 c2                	or     %eax,%edx
  800b97:	09 ca                	or     %ecx,%edx
  800b99:	f6 c2 03             	test   $0x3,%dl
  800b9c:	75 0a                	jne    800ba8 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b9e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ba1:	89 c7                	mov    %eax,%edi
  800ba3:	fc                   	cld    
  800ba4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba6:	eb 05                	jmp    800bad <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800ba8:	89 c7                	mov    %eax,%edi
  800baa:	fc                   	cld    
  800bab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bb7:	ff 75 10             	push   0x10(%ebp)
  800bba:	ff 75 0c             	push   0xc(%ebp)
  800bbd:	ff 75 08             	push   0x8(%ebp)
  800bc0:	e8 8a ff ff ff       	call   800b4f <memmove>
}
  800bc5:	c9                   	leave  
  800bc6:	c3                   	ret    

00800bc7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd2:	89 c6                	mov    %eax,%esi
  800bd4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd7:	eb 06                	jmp    800bdf <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bd9:	83 c0 01             	add    $0x1,%eax
  800bdc:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800bdf:	39 f0                	cmp    %esi,%eax
  800be1:	74 14                	je     800bf7 <memcmp+0x30>
		if (*s1 != *s2)
  800be3:	0f b6 08             	movzbl (%eax),%ecx
  800be6:	0f b6 1a             	movzbl (%edx),%ebx
  800be9:	38 d9                	cmp    %bl,%cl
  800beb:	74 ec                	je     800bd9 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800bed:	0f b6 c1             	movzbl %cl,%eax
  800bf0:	0f b6 db             	movzbl %bl,%ebx
  800bf3:	29 d8                	sub    %ebx,%eax
  800bf5:	eb 05                	jmp    800bfc <memcmp+0x35>
	}

	return 0;
  800bf7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	8b 45 08             	mov    0x8(%ebp),%eax
  800c06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c09:	89 c2                	mov    %eax,%edx
  800c0b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c0e:	eb 03                	jmp    800c13 <memfind+0x13>
  800c10:	83 c0 01             	add    $0x1,%eax
  800c13:	39 d0                	cmp    %edx,%eax
  800c15:	73 04                	jae    800c1b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c17:	38 08                	cmp    %cl,(%eax)
  800c19:	75 f5                	jne    800c10 <memfind+0x10>
			break;
	return (void *) s;
}
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	8b 55 08             	mov    0x8(%ebp),%edx
  800c26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c29:	eb 03                	jmp    800c2e <strtol+0x11>
		s++;
  800c2b:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c2e:	0f b6 02             	movzbl (%edx),%eax
  800c31:	3c 20                	cmp    $0x20,%al
  800c33:	74 f6                	je     800c2b <strtol+0xe>
  800c35:	3c 09                	cmp    $0x9,%al
  800c37:	74 f2                	je     800c2b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c39:	3c 2b                	cmp    $0x2b,%al
  800c3b:	74 2a                	je     800c67 <strtol+0x4a>
	int neg = 0;
  800c3d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c42:	3c 2d                	cmp    $0x2d,%al
  800c44:	74 2b                	je     800c71 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c46:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c4c:	75 0f                	jne    800c5d <strtol+0x40>
  800c4e:	80 3a 30             	cmpb   $0x30,(%edx)
  800c51:	74 28                	je     800c7b <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c53:	85 db                	test   %ebx,%ebx
  800c55:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c5a:	0f 44 d8             	cmove  %eax,%ebx
  800c5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c62:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c65:	eb 46                	jmp    800cad <strtol+0x90>
		s++;
  800c67:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c6a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c6f:	eb d5                	jmp    800c46 <strtol+0x29>
		s++, neg = 1;
  800c71:	83 c2 01             	add    $0x1,%edx
  800c74:	bf 01 00 00 00       	mov    $0x1,%edi
  800c79:	eb cb                	jmp    800c46 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c7b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c7f:	74 0e                	je     800c8f <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800c81:	85 db                	test   %ebx,%ebx
  800c83:	75 d8                	jne    800c5d <strtol+0x40>
		s++, base = 8;
  800c85:	83 c2 01             	add    $0x1,%edx
  800c88:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c8d:	eb ce                	jmp    800c5d <strtol+0x40>
		s += 2, base = 16;
  800c8f:	83 c2 02             	add    $0x2,%edx
  800c92:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c97:	eb c4                	jmp    800c5d <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c99:	0f be c0             	movsbl %al,%eax
  800c9c:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c9f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ca2:	7d 3a                	jge    800cde <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ca4:	83 c2 01             	add    $0x1,%edx
  800ca7:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800cab:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800cad:	0f b6 02             	movzbl (%edx),%eax
  800cb0:	8d 70 d0             	lea    -0x30(%eax),%esi
  800cb3:	89 f3                	mov    %esi,%ebx
  800cb5:	80 fb 09             	cmp    $0x9,%bl
  800cb8:	76 df                	jbe    800c99 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800cba:	8d 70 9f             	lea    -0x61(%eax),%esi
  800cbd:	89 f3                	mov    %esi,%ebx
  800cbf:	80 fb 19             	cmp    $0x19,%bl
  800cc2:	77 08                	ja     800ccc <strtol+0xaf>
			dig = *s - 'a' + 10;
  800cc4:	0f be c0             	movsbl %al,%eax
  800cc7:	83 e8 57             	sub    $0x57,%eax
  800cca:	eb d3                	jmp    800c9f <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ccc:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ccf:	89 f3                	mov    %esi,%ebx
  800cd1:	80 fb 19             	cmp    $0x19,%bl
  800cd4:	77 08                	ja     800cde <strtol+0xc1>
			dig = *s - 'A' + 10;
  800cd6:	0f be c0             	movsbl %al,%eax
  800cd9:	83 e8 37             	sub    $0x37,%eax
  800cdc:	eb c1                	jmp    800c9f <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800cde:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ce2:	74 05                	je     800ce9 <strtol+0xcc>
		*endptr = (char *) s;
  800ce4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce7:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ce9:	89 c8                	mov    %ecx,%eax
  800ceb:	f7 d8                	neg    %eax
  800ced:	85 ff                	test   %edi,%edi
  800cef:	0f 45 c8             	cmovne %eax,%ecx
}
  800cf2:	89 c8                	mov    %ecx,%eax
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cff:	b8 00 00 00 00       	mov    $0x0,%eax
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0a:	89 c3                	mov    %eax,%ebx
  800d0c:	89 c7                	mov    %eax,%edi
  800d0e:	89 c6                	mov    %eax,%esi
  800d10:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d22:	b8 01 00 00 00       	mov    $0x1,%eax
  800d27:	89 d1                	mov    %edx,%ecx
  800d29:	89 d3                	mov    %edx,%ebx
  800d2b:	89 d7                	mov    %edx,%edi
  800d2d:	89 d6                	mov    %edx,%esi
  800d2f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d3f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	b8 03 00 00 00       	mov    $0x3,%eax
  800d4c:	89 cb                	mov    %ecx,%ebx
  800d4e:	89 cf                	mov    %ecx,%edi
  800d50:	89 ce                	mov    %ecx,%esi
  800d52:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d54:	85 c0                	test   %eax,%eax
  800d56:	7f 08                	jg     800d60 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d60:	83 ec 0c             	sub    $0xc,%esp
  800d63:	50                   	push   %eax
  800d64:	6a 03                	push   $0x3
  800d66:	68 bf 2b 80 00       	push   $0x802bbf
  800d6b:	6a 2a                	push   $0x2a
  800d6d:	68 dc 2b 80 00       	push   $0x802bdc
  800d72:	e8 8d f5 ff ff       	call   800304 <_panic>

00800d77 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	57                   	push   %edi
  800d7b:	56                   	push   %esi
  800d7c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d82:	b8 02 00 00 00       	mov    $0x2,%eax
  800d87:	89 d1                	mov    %edx,%ecx
  800d89:	89 d3                	mov    %edx,%ebx
  800d8b:	89 d7                	mov    %edx,%edi
  800d8d:	89 d6                	mov    %edx,%esi
  800d8f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <sys_yield>:

void
sys_yield(void)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	57                   	push   %edi
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800da1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800da6:	89 d1                	mov    %edx,%ecx
  800da8:	89 d3                	mov    %edx,%ebx
  800daa:	89 d7                	mov    %edx,%edi
  800dac:	89 d6                	mov    %edx,%esi
  800dae:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
  800dbb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dbe:	be 00 00 00 00       	mov    $0x0,%esi
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc9:	b8 04 00 00 00       	mov    $0x4,%eax
  800dce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd1:	89 f7                	mov    %esi,%edi
  800dd3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	7f 08                	jg     800de1 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de1:	83 ec 0c             	sub    $0xc,%esp
  800de4:	50                   	push   %eax
  800de5:	6a 04                	push   $0x4
  800de7:	68 bf 2b 80 00       	push   $0x802bbf
  800dec:	6a 2a                	push   $0x2a
  800dee:	68 dc 2b 80 00       	push   $0x802bdc
  800df3:	e8 0c f5 ff ff       	call   800304 <_panic>

00800df8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	57                   	push   %edi
  800dfc:	56                   	push   %esi
  800dfd:	53                   	push   %ebx
  800dfe:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e01:	8b 55 08             	mov    0x8(%ebp),%edx
  800e04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e07:	b8 05 00 00 00       	mov    $0x5,%eax
  800e0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e12:	8b 75 18             	mov    0x18(%ebp),%esi
  800e15:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e17:	85 c0                	test   %eax,%eax
  800e19:	7f 08                	jg     800e23 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e23:	83 ec 0c             	sub    $0xc,%esp
  800e26:	50                   	push   %eax
  800e27:	6a 05                	push   $0x5
  800e29:	68 bf 2b 80 00       	push   $0x802bbf
  800e2e:	6a 2a                	push   $0x2a
  800e30:	68 dc 2b 80 00       	push   $0x802bdc
  800e35:	e8 ca f4 ff ff       	call   800304 <_panic>

00800e3a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	57                   	push   %edi
  800e3e:	56                   	push   %esi
  800e3f:	53                   	push   %ebx
  800e40:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e48:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4e:	b8 06 00 00 00       	mov    $0x6,%eax
  800e53:	89 df                	mov    %ebx,%edi
  800e55:	89 de                	mov    %ebx,%esi
  800e57:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	7f 08                	jg     800e65 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e65:	83 ec 0c             	sub    $0xc,%esp
  800e68:	50                   	push   %eax
  800e69:	6a 06                	push   $0x6
  800e6b:	68 bf 2b 80 00       	push   $0x802bbf
  800e70:	6a 2a                	push   $0x2a
  800e72:	68 dc 2b 80 00       	push   $0x802bdc
  800e77:	e8 88 f4 ff ff       	call   800304 <_panic>

00800e7c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	57                   	push   %edi
  800e80:	56                   	push   %esi
  800e81:	53                   	push   %ebx
  800e82:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e85:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e90:	b8 08 00 00 00       	mov    $0x8,%eax
  800e95:	89 df                	mov    %ebx,%edi
  800e97:	89 de                	mov    %ebx,%esi
  800e99:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	7f 08                	jg     800ea7 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea7:	83 ec 0c             	sub    $0xc,%esp
  800eaa:	50                   	push   %eax
  800eab:	6a 08                	push   $0x8
  800ead:	68 bf 2b 80 00       	push   $0x802bbf
  800eb2:	6a 2a                	push   $0x2a
  800eb4:	68 dc 2b 80 00       	push   $0x802bdc
  800eb9:	e8 46 f4 ff ff       	call   800304 <_panic>

00800ebe <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ec7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ecc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed2:	b8 09 00 00 00       	mov    $0x9,%eax
  800ed7:	89 df                	mov    %ebx,%edi
  800ed9:	89 de                	mov    %ebx,%esi
  800edb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800edd:	85 c0                	test   %eax,%eax
  800edf:	7f 08                	jg     800ee9 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ee1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee9:	83 ec 0c             	sub    $0xc,%esp
  800eec:	50                   	push   %eax
  800eed:	6a 09                	push   $0x9
  800eef:	68 bf 2b 80 00       	push   $0x802bbf
  800ef4:	6a 2a                	push   $0x2a
  800ef6:	68 dc 2b 80 00       	push   $0x802bdc
  800efb:	e8 04 f4 ff ff       	call   800304 <_panic>

00800f00 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
  800f06:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f14:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f19:	89 df                	mov    %ebx,%edi
  800f1b:	89 de                	mov    %ebx,%esi
  800f1d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	7f 08                	jg     800f2b <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f26:	5b                   	pop    %ebx
  800f27:	5e                   	pop    %esi
  800f28:	5f                   	pop    %edi
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2b:	83 ec 0c             	sub    $0xc,%esp
  800f2e:	50                   	push   %eax
  800f2f:	6a 0a                	push   $0xa
  800f31:	68 bf 2b 80 00       	push   $0x802bbf
  800f36:	6a 2a                	push   $0x2a
  800f38:	68 dc 2b 80 00       	push   $0x802bdc
  800f3d:	e8 c2 f3 ff ff       	call   800304 <_panic>

00800f42 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	57                   	push   %edi
  800f46:	56                   	push   %esi
  800f47:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f48:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f53:	be 00 00 00 00       	mov    $0x0,%esi
  800f58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f5b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f5e:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f60:	5b                   	pop    %ebx
  800f61:	5e                   	pop    %esi
  800f62:	5f                   	pop    %edi
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    

00800f65 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	57                   	push   %edi
  800f69:	56                   	push   %esi
  800f6a:	53                   	push   %ebx
  800f6b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f73:	8b 55 08             	mov    0x8(%ebp),%edx
  800f76:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f7b:	89 cb                	mov    %ecx,%ebx
  800f7d:	89 cf                	mov    %ecx,%edi
  800f7f:	89 ce                	mov    %ecx,%esi
  800f81:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f83:	85 c0                	test   %eax,%eax
  800f85:	7f 08                	jg     800f8f <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8a:	5b                   	pop    %ebx
  800f8b:	5e                   	pop    %esi
  800f8c:	5f                   	pop    %edi
  800f8d:	5d                   	pop    %ebp
  800f8e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	50                   	push   %eax
  800f93:	6a 0d                	push   $0xd
  800f95:	68 bf 2b 80 00       	push   $0x802bbf
  800f9a:	6a 2a                	push   $0x2a
  800f9c:	68 dc 2b 80 00       	push   $0x802bdc
  800fa1:	e8 5e f3 ff ff       	call   800304 <_panic>

00800fa6 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fac:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb1:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fb6:	89 d1                	mov    %edx,%ecx
  800fb8:	89 d3                	mov    %edx,%ebx
  800fba:	89 d7                	mov    %edx,%edi
  800fbc:	89 d6                	mov    %edx,%esi
  800fbe:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800fc0:	5b                   	pop    %ebx
  800fc1:	5e                   	pop    %esi
  800fc2:	5f                   	pop    %edi
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    

00800fc5 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	57                   	push   %edi
  800fc9:	56                   	push   %esi
  800fca:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd6:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fdb:	89 df                	mov    %ebx,%edi
  800fdd:	89 de                	mov    %ebx,%esi
  800fdf:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800fe1:	5b                   	pop    %ebx
  800fe2:	5e                   	pop    %esi
  800fe3:	5f                   	pop    %edi
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    

00800fe6 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	57                   	push   %edi
  800fea:	56                   	push   %esi
  800feb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff7:	b8 10 00 00 00       	mov    $0x10,%eax
  800ffc:	89 df                	mov    %ebx,%edi
  800ffe:	89 de                	mov    %ebx,%esi
  801000:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  801002:	5b                   	pop    %ebx
  801003:	5e                   	pop    %esi
  801004:	5f                   	pop    %edi
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    

00801007 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	56                   	push   %esi
  80100b:	53                   	push   %ebx
  80100c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80100f:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  801011:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801015:	0f 84 8e 00 00 00    	je     8010a9 <pgfault+0xa2>
  80101b:	89 f0                	mov    %esi,%eax
  80101d:	c1 e8 0c             	shr    $0xc,%eax
  801020:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801027:	f6 c4 08             	test   $0x8,%ah
  80102a:	74 7d                	je     8010a9 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  80102c:	e8 46 fd ff ff       	call   800d77 <sys_getenvid>
  801031:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  801033:	83 ec 04             	sub    $0x4,%esp
  801036:	6a 07                	push   $0x7
  801038:	68 00 f0 7f 00       	push   $0x7ff000
  80103d:	50                   	push   %eax
  80103e:	e8 72 fd ff ff       	call   800db5 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  801043:	83 c4 10             	add    $0x10,%esp
  801046:	85 c0                	test   %eax,%eax
  801048:	78 73                	js     8010bd <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  80104a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  801050:	83 ec 04             	sub    $0x4,%esp
  801053:	68 00 10 00 00       	push   $0x1000
  801058:	56                   	push   %esi
  801059:	68 00 f0 7f 00       	push   $0x7ff000
  80105e:	e8 ec fa ff ff       	call   800b4f <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  801063:	83 c4 08             	add    $0x8,%esp
  801066:	56                   	push   %esi
  801067:	53                   	push   %ebx
  801068:	e8 cd fd ff ff       	call   800e3a <sys_page_unmap>
  80106d:	83 c4 10             	add    $0x10,%esp
  801070:	85 c0                	test   %eax,%eax
  801072:	78 5b                	js     8010cf <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  801074:	83 ec 0c             	sub    $0xc,%esp
  801077:	6a 07                	push   $0x7
  801079:	56                   	push   %esi
  80107a:	53                   	push   %ebx
  80107b:	68 00 f0 7f 00       	push   $0x7ff000
  801080:	53                   	push   %ebx
  801081:	e8 72 fd ff ff       	call   800df8 <sys_page_map>
  801086:	83 c4 20             	add    $0x20,%esp
  801089:	85 c0                	test   %eax,%eax
  80108b:	78 54                	js     8010e1 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  80108d:	83 ec 08             	sub    $0x8,%esp
  801090:	68 00 f0 7f 00       	push   $0x7ff000
  801095:	53                   	push   %ebx
  801096:	e8 9f fd ff ff       	call   800e3a <sys_page_unmap>
  80109b:	83 c4 10             	add    $0x10,%esp
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	78 51                	js     8010f3 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  8010a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010a5:	5b                   	pop    %ebx
  8010a6:	5e                   	pop    %esi
  8010a7:	5d                   	pop    %ebp
  8010a8:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  8010a9:	83 ec 04             	sub    $0x4,%esp
  8010ac:	68 ec 2b 80 00       	push   $0x802bec
  8010b1:	6a 1d                	push   $0x1d
  8010b3:	68 68 2c 80 00       	push   $0x802c68
  8010b8:	e8 47 f2 ff ff       	call   800304 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  8010bd:	50                   	push   %eax
  8010be:	68 24 2c 80 00       	push   $0x802c24
  8010c3:	6a 29                	push   $0x29
  8010c5:	68 68 2c 80 00       	push   $0x802c68
  8010ca:	e8 35 f2 ff ff       	call   800304 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  8010cf:	50                   	push   %eax
  8010d0:	68 48 2c 80 00       	push   $0x802c48
  8010d5:	6a 2e                	push   $0x2e
  8010d7:	68 68 2c 80 00       	push   $0x802c68
  8010dc:	e8 23 f2 ff ff       	call   800304 <_panic>
		panic("pgfault: page map failed (%e)", r);
  8010e1:	50                   	push   %eax
  8010e2:	68 73 2c 80 00       	push   $0x802c73
  8010e7:	6a 30                	push   $0x30
  8010e9:	68 68 2c 80 00       	push   $0x802c68
  8010ee:	e8 11 f2 ff ff       	call   800304 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  8010f3:	50                   	push   %eax
  8010f4:	68 48 2c 80 00       	push   $0x802c48
  8010f9:	6a 32                	push   $0x32
  8010fb:	68 68 2c 80 00       	push   $0x802c68
  801100:	e8 ff f1 ff ff       	call   800304 <_panic>

00801105 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	57                   	push   %edi
  801109:	56                   	push   %esi
  80110a:	53                   	push   %ebx
  80110b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  80110e:	68 07 10 80 00       	push   $0x801007
  801113:	e8 81 13 00 00       	call   802499 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801118:	b8 07 00 00 00       	mov    $0x7,%eax
  80111d:	cd 30                	int    $0x30
  80111f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  801122:	83 c4 10             	add    $0x10,%esp
  801125:	85 c0                	test   %eax,%eax
  801127:	78 30                	js     801159 <fork+0x54>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801129:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  80112e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801132:	75 76                	jne    8011aa <fork+0xa5>
		thisenv = &envs[ENVX(sys_getenvid())];
  801134:	e8 3e fc ff ff       	call   800d77 <sys_getenvid>
  801139:	25 ff 03 00 00       	and    $0x3ff,%eax
  80113e:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801144:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801149:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80114e:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  801151:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801154:	5b                   	pop    %ebx
  801155:	5e                   	pop    %esi
  801156:	5f                   	pop    %edi
  801157:	5d                   	pop    %ebp
  801158:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  801159:	50                   	push   %eax
  80115a:	68 91 2c 80 00       	push   $0x802c91
  80115f:	6a 78                	push   $0x78
  801161:	68 68 2c 80 00       	push   $0x802c68
  801166:	e8 99 f1 ff ff       	call   800304 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  80116b:	83 ec 0c             	sub    $0xc,%esp
  80116e:	ff 75 e4             	push   -0x1c(%ebp)
  801171:	57                   	push   %edi
  801172:	ff 75 dc             	push   -0x24(%ebp)
  801175:	57                   	push   %edi
  801176:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801179:	56                   	push   %esi
  80117a:	e8 79 fc ff ff       	call   800df8 <sys_page_map>
	if(r<0) return r;
  80117f:	83 c4 20             	add    $0x20,%esp
  801182:	85 c0                	test   %eax,%eax
  801184:	78 cb                	js     801151 <fork+0x4c>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  801186:	83 ec 0c             	sub    $0xc,%esp
  801189:	ff 75 e4             	push   -0x1c(%ebp)
  80118c:	57                   	push   %edi
  80118d:	56                   	push   %esi
  80118e:	57                   	push   %edi
  80118f:	56                   	push   %esi
  801190:	e8 63 fc ff ff       	call   800df8 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  801195:	83 c4 20             	add    $0x20,%esp
  801198:	85 c0                	test   %eax,%eax
  80119a:	78 76                	js     801212 <fork+0x10d>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  80119c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011a2:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011a8:	74 75                	je     80121f <fork+0x11a>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  8011aa:	89 d8                	mov    %ebx,%eax
  8011ac:	c1 e8 16             	shr    $0x16,%eax
  8011af:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011b6:	a8 01                	test   $0x1,%al
  8011b8:	74 e2                	je     80119c <fork+0x97>
  8011ba:	89 de                	mov    %ebx,%esi
  8011bc:	c1 ee 0c             	shr    $0xc,%esi
  8011bf:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011c6:	a8 01                	test   $0x1,%al
  8011c8:	74 d2                	je     80119c <fork+0x97>
	envid_t this_envid = sys_getenvid();//父进程号
  8011ca:	e8 a8 fb ff ff       	call   800d77 <sys_getenvid>
  8011cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  8011d2:	89 f7                	mov    %esi,%edi
  8011d4:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  8011d7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011de:	89 c1                	mov    %eax,%ecx
  8011e0:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  8011e6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  8011e9:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  8011f0:	f6 c6 04             	test   $0x4,%dh
  8011f3:	0f 85 72 ff ff ff    	jne    80116b <fork+0x66>
		perm &= ~PTE_W;
  8011f9:	25 05 0e 00 00       	and    $0xe05,%eax
  8011fe:	80 cc 08             	or     $0x8,%ah
  801201:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  801207:	0f 44 c1             	cmove  %ecx,%eax
  80120a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80120d:	e9 59 ff ff ff       	jmp    80116b <fork+0x66>
  801212:	ba 00 00 00 00       	mov    $0x0,%edx
  801217:	0f 4f c2             	cmovg  %edx,%eax
  80121a:	e9 32 ff ff ff       	jmp    801151 <fork+0x4c>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  80121f:	83 ec 04             	sub    $0x4,%esp
  801222:	6a 07                	push   $0x7
  801224:	68 00 f0 bf ee       	push   $0xeebff000
  801229:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80122c:	57                   	push   %edi
  80122d:	e8 83 fb ff ff       	call   800db5 <sys_page_alloc>
	if(r<0) return r;
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	85 c0                	test   %eax,%eax
  801237:	0f 88 14 ff ff ff    	js     801151 <fork+0x4c>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80123d:	83 ec 08             	sub    $0x8,%esp
  801240:	68 0f 25 80 00       	push   $0x80250f
  801245:	57                   	push   %edi
  801246:	e8 b5 fc ff ff       	call   800f00 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	85 c0                	test   %eax,%eax
  801250:	0f 88 fb fe ff ff    	js     801151 <fork+0x4c>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801256:	83 ec 08             	sub    $0x8,%esp
  801259:	6a 02                	push   $0x2
  80125b:	57                   	push   %edi
  80125c:	e8 1b fc ff ff       	call   800e7c <sys_env_set_status>
	if(r<0) return r;
  801261:	83 c4 10             	add    $0x10,%esp
	return envid;
  801264:	85 c0                	test   %eax,%eax
  801266:	0f 49 c7             	cmovns %edi,%eax
  801269:	e9 e3 fe ff ff       	jmp    801151 <fork+0x4c>

0080126e <sfork>:

// Challenge!
int
sfork(void)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801274:	68 a1 2c 80 00       	push   $0x802ca1
  801279:	68 a1 00 00 00       	push   $0xa1
  80127e:	68 68 2c 80 00       	push   $0x802c68
  801283:	e8 7c f0 ff ff       	call   800304 <_panic>

00801288 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	56                   	push   %esi
  80128c:	53                   	push   %ebx
  80128d:	8b 75 08             	mov    0x8(%ebp),%esi
  801290:	8b 45 0c             	mov    0xc(%ebp),%eax
  801293:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801296:	85 c0                	test   %eax,%eax
  801298:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80129d:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8012a0:	83 ec 0c             	sub    $0xc,%esp
  8012a3:	50                   	push   %eax
  8012a4:	e8 bc fc ff ff       	call   800f65 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8012a9:	83 c4 10             	add    $0x10,%esp
  8012ac:	85 f6                	test   %esi,%esi
  8012ae:	74 17                	je     8012c7 <ipc_recv+0x3f>
  8012b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 0c                	js     8012c5 <ipc_recv+0x3d>
  8012b9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8012bf:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  8012c5:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8012c7:	85 db                	test   %ebx,%ebx
  8012c9:	74 17                	je     8012e2 <ipc_recv+0x5a>
  8012cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	78 0c                	js     8012e0 <ipc_recv+0x58>
  8012d4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8012da:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  8012e0:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	78 0b                	js     8012f1 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  8012e6:	a1 04 40 80 00       	mov    0x804004,%eax
  8012eb:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  8012f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f4:	5b                   	pop    %ebx
  8012f5:	5e                   	pop    %esi
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	57                   	push   %edi
  8012fc:	56                   	push   %esi
  8012fd:	53                   	push   %ebx
  8012fe:	83 ec 0c             	sub    $0xc,%esp
  801301:	8b 7d 08             	mov    0x8(%ebp),%edi
  801304:	8b 75 0c             	mov    0xc(%ebp),%esi
  801307:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  80130a:	85 db                	test   %ebx,%ebx
  80130c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801311:	0f 44 d8             	cmove  %eax,%ebx
  801314:	eb 05                	jmp    80131b <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801316:	e8 7b fa ff ff       	call   800d96 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80131b:	ff 75 14             	push   0x14(%ebp)
  80131e:	53                   	push   %ebx
  80131f:	56                   	push   %esi
  801320:	57                   	push   %edi
  801321:	e8 1c fc ff ff       	call   800f42 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80132c:	74 e8                	je     801316 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80132e:	85 c0                	test   %eax,%eax
  801330:	78 08                	js     80133a <ipc_send+0x42>
	}while (r<0);

}
  801332:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801335:	5b                   	pop    %ebx
  801336:	5e                   	pop    %esi
  801337:	5f                   	pop    %edi
  801338:	5d                   	pop    %ebp
  801339:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80133a:	50                   	push   %eax
  80133b:	68 b7 2c 80 00       	push   $0x802cb7
  801340:	6a 3d                	push   $0x3d
  801342:	68 cb 2c 80 00       	push   $0x802ccb
  801347:	e8 b8 ef ff ff       	call   800304 <_panic>

0080134c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801352:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801357:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  80135d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801363:	8b 52 60             	mov    0x60(%edx),%edx
  801366:	39 ca                	cmp    %ecx,%edx
  801368:	74 11                	je     80137b <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  80136a:	83 c0 01             	add    $0x1,%eax
  80136d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801372:	75 e3                	jne    801357 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801374:	b8 00 00 00 00       	mov    $0x0,%eax
  801379:	eb 0e                	jmp    801389 <ipc_find_env+0x3d>
			return envs[i].env_id;
  80137b:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801381:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801386:	8b 40 58             	mov    0x58(%eax),%eax
}
  801389:	5d                   	pop    %ebp
  80138a:	c3                   	ret    

0080138b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80138e:	8b 45 08             	mov    0x8(%ebp),%eax
  801391:	05 00 00 00 30       	add    $0x30000000,%eax
  801396:	c1 e8 0c             	shr    $0xc,%eax
}
  801399:	5d                   	pop    %ebp
  80139a:	c3                   	ret    

0080139b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80139e:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a1:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8013a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013ab:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013b0:	5d                   	pop    %ebp
  8013b1:	c3                   	ret    

008013b2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013ba:	89 c2                	mov    %eax,%edx
  8013bc:	c1 ea 16             	shr    $0x16,%edx
  8013bf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013c6:	f6 c2 01             	test   $0x1,%dl
  8013c9:	74 29                	je     8013f4 <fd_alloc+0x42>
  8013cb:	89 c2                	mov    %eax,%edx
  8013cd:	c1 ea 0c             	shr    $0xc,%edx
  8013d0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013d7:	f6 c2 01             	test   $0x1,%dl
  8013da:	74 18                	je     8013f4 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8013dc:	05 00 10 00 00       	add    $0x1000,%eax
  8013e1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013e6:	75 d2                	jne    8013ba <fd_alloc+0x8>
  8013e8:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8013ed:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8013f2:	eb 05                	jmp    8013f9 <fd_alloc+0x47>
			return 0;
  8013f4:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8013f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8013fc:	89 02                	mov    %eax,(%edx)
}
  8013fe:	89 c8                	mov    %ecx,%eax
  801400:	5d                   	pop    %ebp
  801401:	c3                   	ret    

00801402 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801402:	55                   	push   %ebp
  801403:	89 e5                	mov    %esp,%ebp
  801405:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801408:	83 f8 1f             	cmp    $0x1f,%eax
  80140b:	77 30                	ja     80143d <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80140d:	c1 e0 0c             	shl    $0xc,%eax
  801410:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801415:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80141b:	f6 c2 01             	test   $0x1,%dl
  80141e:	74 24                	je     801444 <fd_lookup+0x42>
  801420:	89 c2                	mov    %eax,%edx
  801422:	c1 ea 0c             	shr    $0xc,%edx
  801425:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80142c:	f6 c2 01             	test   $0x1,%dl
  80142f:	74 1a                	je     80144b <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801431:	8b 55 0c             	mov    0xc(%ebp),%edx
  801434:	89 02                	mov    %eax,(%edx)
	return 0;
  801436:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80143b:	5d                   	pop    %ebp
  80143c:	c3                   	ret    
		return -E_INVAL;
  80143d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801442:	eb f7                	jmp    80143b <fd_lookup+0x39>
		return -E_INVAL;
  801444:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801449:	eb f0                	jmp    80143b <fd_lookup+0x39>
  80144b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801450:	eb e9                	jmp    80143b <fd_lookup+0x39>

00801452 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	53                   	push   %ebx
  801456:	83 ec 04             	sub    $0x4,%esp
  801459:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80145c:	b8 00 00 00 00       	mov    $0x0,%eax
  801461:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801466:	39 13                	cmp    %edx,(%ebx)
  801468:	74 37                	je     8014a1 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  80146a:	83 c0 01             	add    $0x1,%eax
  80146d:	8b 1c 85 54 2d 80 00 	mov    0x802d54(,%eax,4),%ebx
  801474:	85 db                	test   %ebx,%ebx
  801476:	75 ee                	jne    801466 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801478:	a1 04 40 80 00       	mov    0x804004,%eax
  80147d:	8b 40 58             	mov    0x58(%eax),%eax
  801480:	83 ec 04             	sub    $0x4,%esp
  801483:	52                   	push   %edx
  801484:	50                   	push   %eax
  801485:	68 d8 2c 80 00       	push   $0x802cd8
  80148a:	e8 50 ef ff ff       	call   8003df <cprintf>
	*dev = 0;
	return -E_INVAL;
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801497:	8b 55 0c             	mov    0xc(%ebp),%edx
  80149a:	89 1a                	mov    %ebx,(%edx)
}
  80149c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149f:	c9                   	leave  
  8014a0:	c3                   	ret    
			return 0;
  8014a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a6:	eb ef                	jmp    801497 <dev_lookup+0x45>

008014a8 <fd_close>:
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	57                   	push   %edi
  8014ac:	56                   	push   %esi
  8014ad:	53                   	push   %ebx
  8014ae:	83 ec 24             	sub    $0x24,%esp
  8014b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8014b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014ba:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014bb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014c1:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014c4:	50                   	push   %eax
  8014c5:	e8 38 ff ff ff       	call   801402 <fd_lookup>
  8014ca:	89 c3                	mov    %eax,%ebx
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 05                	js     8014d8 <fd_close+0x30>
	    || fd != fd2)
  8014d3:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8014d6:	74 16                	je     8014ee <fd_close+0x46>
		return (must_exist ? r : 0);
  8014d8:	89 f8                	mov    %edi,%eax
  8014da:	84 c0                	test   %al,%al
  8014dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e1:	0f 44 d8             	cmove  %eax,%ebx
}
  8014e4:	89 d8                	mov    %ebx,%eax
  8014e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e9:	5b                   	pop    %ebx
  8014ea:	5e                   	pop    %esi
  8014eb:	5f                   	pop    %edi
  8014ec:	5d                   	pop    %ebp
  8014ed:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014ee:	83 ec 08             	sub    $0x8,%esp
  8014f1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8014f4:	50                   	push   %eax
  8014f5:	ff 36                	push   (%esi)
  8014f7:	e8 56 ff ff ff       	call   801452 <dev_lookup>
  8014fc:	89 c3                	mov    %eax,%ebx
  8014fe:	83 c4 10             	add    $0x10,%esp
  801501:	85 c0                	test   %eax,%eax
  801503:	78 1a                	js     80151f <fd_close+0x77>
		if (dev->dev_close)
  801505:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801508:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80150b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801510:	85 c0                	test   %eax,%eax
  801512:	74 0b                	je     80151f <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801514:	83 ec 0c             	sub    $0xc,%esp
  801517:	56                   	push   %esi
  801518:	ff d0                	call   *%eax
  80151a:	89 c3                	mov    %eax,%ebx
  80151c:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80151f:	83 ec 08             	sub    $0x8,%esp
  801522:	56                   	push   %esi
  801523:	6a 00                	push   $0x0
  801525:	e8 10 f9 ff ff       	call   800e3a <sys_page_unmap>
	return r;
  80152a:	83 c4 10             	add    $0x10,%esp
  80152d:	eb b5                	jmp    8014e4 <fd_close+0x3c>

0080152f <close>:

int
close(int fdnum)
{
  80152f:	55                   	push   %ebp
  801530:	89 e5                	mov    %esp,%ebp
  801532:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801535:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801538:	50                   	push   %eax
  801539:	ff 75 08             	push   0x8(%ebp)
  80153c:	e8 c1 fe ff ff       	call   801402 <fd_lookup>
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	85 c0                	test   %eax,%eax
  801546:	79 02                	jns    80154a <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801548:	c9                   	leave  
  801549:	c3                   	ret    
		return fd_close(fd, 1);
  80154a:	83 ec 08             	sub    $0x8,%esp
  80154d:	6a 01                	push   $0x1
  80154f:	ff 75 f4             	push   -0xc(%ebp)
  801552:	e8 51 ff ff ff       	call   8014a8 <fd_close>
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	eb ec                	jmp    801548 <close+0x19>

0080155c <close_all>:

void
close_all(void)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	53                   	push   %ebx
  801560:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801563:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801568:	83 ec 0c             	sub    $0xc,%esp
  80156b:	53                   	push   %ebx
  80156c:	e8 be ff ff ff       	call   80152f <close>
	for (i = 0; i < MAXFD; i++)
  801571:	83 c3 01             	add    $0x1,%ebx
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	83 fb 20             	cmp    $0x20,%ebx
  80157a:	75 ec                	jne    801568 <close_all+0xc>
}
  80157c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157f:	c9                   	leave  
  801580:	c3                   	ret    

00801581 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801581:	55                   	push   %ebp
  801582:	89 e5                	mov    %esp,%ebp
  801584:	57                   	push   %edi
  801585:	56                   	push   %esi
  801586:	53                   	push   %ebx
  801587:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80158a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	ff 75 08             	push   0x8(%ebp)
  801591:	e8 6c fe ff ff       	call   801402 <fd_lookup>
  801596:	89 c3                	mov    %eax,%ebx
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	85 c0                	test   %eax,%eax
  80159d:	78 7f                	js     80161e <dup+0x9d>
		return r;
	close(newfdnum);
  80159f:	83 ec 0c             	sub    $0xc,%esp
  8015a2:	ff 75 0c             	push   0xc(%ebp)
  8015a5:	e8 85 ff ff ff       	call   80152f <close>

	newfd = INDEX2FD(newfdnum);
  8015aa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8015ad:	c1 e6 0c             	shl    $0xc,%esi
  8015b0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8015b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015b9:	89 3c 24             	mov    %edi,(%esp)
  8015bc:	e8 da fd ff ff       	call   80139b <fd2data>
  8015c1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015c3:	89 34 24             	mov    %esi,(%esp)
  8015c6:	e8 d0 fd ff ff       	call   80139b <fd2data>
  8015cb:	83 c4 10             	add    $0x10,%esp
  8015ce:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015d1:	89 d8                	mov    %ebx,%eax
  8015d3:	c1 e8 16             	shr    $0x16,%eax
  8015d6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015dd:	a8 01                	test   $0x1,%al
  8015df:	74 11                	je     8015f2 <dup+0x71>
  8015e1:	89 d8                	mov    %ebx,%eax
  8015e3:	c1 e8 0c             	shr    $0xc,%eax
  8015e6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015ed:	f6 c2 01             	test   $0x1,%dl
  8015f0:	75 36                	jne    801628 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015f2:	89 f8                	mov    %edi,%eax
  8015f4:	c1 e8 0c             	shr    $0xc,%eax
  8015f7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015fe:	83 ec 0c             	sub    $0xc,%esp
  801601:	25 07 0e 00 00       	and    $0xe07,%eax
  801606:	50                   	push   %eax
  801607:	56                   	push   %esi
  801608:	6a 00                	push   $0x0
  80160a:	57                   	push   %edi
  80160b:	6a 00                	push   $0x0
  80160d:	e8 e6 f7 ff ff       	call   800df8 <sys_page_map>
  801612:	89 c3                	mov    %eax,%ebx
  801614:	83 c4 20             	add    $0x20,%esp
  801617:	85 c0                	test   %eax,%eax
  801619:	78 33                	js     80164e <dup+0xcd>
		goto err;

	return newfdnum;
  80161b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80161e:	89 d8                	mov    %ebx,%eax
  801620:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801623:	5b                   	pop    %ebx
  801624:	5e                   	pop    %esi
  801625:	5f                   	pop    %edi
  801626:	5d                   	pop    %ebp
  801627:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801628:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80162f:	83 ec 0c             	sub    $0xc,%esp
  801632:	25 07 0e 00 00       	and    $0xe07,%eax
  801637:	50                   	push   %eax
  801638:	ff 75 d4             	push   -0x2c(%ebp)
  80163b:	6a 00                	push   $0x0
  80163d:	53                   	push   %ebx
  80163e:	6a 00                	push   $0x0
  801640:	e8 b3 f7 ff ff       	call   800df8 <sys_page_map>
  801645:	89 c3                	mov    %eax,%ebx
  801647:	83 c4 20             	add    $0x20,%esp
  80164a:	85 c0                	test   %eax,%eax
  80164c:	79 a4                	jns    8015f2 <dup+0x71>
	sys_page_unmap(0, newfd);
  80164e:	83 ec 08             	sub    $0x8,%esp
  801651:	56                   	push   %esi
  801652:	6a 00                	push   $0x0
  801654:	e8 e1 f7 ff ff       	call   800e3a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801659:	83 c4 08             	add    $0x8,%esp
  80165c:	ff 75 d4             	push   -0x2c(%ebp)
  80165f:	6a 00                	push   $0x0
  801661:	e8 d4 f7 ff ff       	call   800e3a <sys_page_unmap>
	return r;
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	eb b3                	jmp    80161e <dup+0x9d>

0080166b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	56                   	push   %esi
  80166f:	53                   	push   %ebx
  801670:	83 ec 18             	sub    $0x18,%esp
  801673:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801676:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801679:	50                   	push   %eax
  80167a:	56                   	push   %esi
  80167b:	e8 82 fd ff ff       	call   801402 <fd_lookup>
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	85 c0                	test   %eax,%eax
  801685:	78 3c                	js     8016c3 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801687:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80168a:	83 ec 08             	sub    $0x8,%esp
  80168d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801690:	50                   	push   %eax
  801691:	ff 33                	push   (%ebx)
  801693:	e8 ba fd ff ff       	call   801452 <dev_lookup>
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	85 c0                	test   %eax,%eax
  80169d:	78 24                	js     8016c3 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80169f:	8b 43 08             	mov    0x8(%ebx),%eax
  8016a2:	83 e0 03             	and    $0x3,%eax
  8016a5:	83 f8 01             	cmp    $0x1,%eax
  8016a8:	74 20                	je     8016ca <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8016aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ad:	8b 40 08             	mov    0x8(%eax),%eax
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	74 37                	je     8016eb <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016b4:	83 ec 04             	sub    $0x4,%esp
  8016b7:	ff 75 10             	push   0x10(%ebp)
  8016ba:	ff 75 0c             	push   0xc(%ebp)
  8016bd:	53                   	push   %ebx
  8016be:	ff d0                	call   *%eax
  8016c0:	83 c4 10             	add    $0x10,%esp
}
  8016c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c6:	5b                   	pop    %ebx
  8016c7:	5e                   	pop    %esi
  8016c8:	5d                   	pop    %ebp
  8016c9:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016ca:	a1 04 40 80 00       	mov    0x804004,%eax
  8016cf:	8b 40 58             	mov    0x58(%eax),%eax
  8016d2:	83 ec 04             	sub    $0x4,%esp
  8016d5:	56                   	push   %esi
  8016d6:	50                   	push   %eax
  8016d7:	68 19 2d 80 00       	push   $0x802d19
  8016dc:	e8 fe ec ff ff       	call   8003df <cprintf>
		return -E_INVAL;
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016e9:	eb d8                	jmp    8016c3 <read+0x58>
		return -E_NOT_SUPP;
  8016eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016f0:	eb d1                	jmp    8016c3 <read+0x58>

008016f2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	57                   	push   %edi
  8016f6:	56                   	push   %esi
  8016f7:	53                   	push   %ebx
  8016f8:	83 ec 0c             	sub    $0xc,%esp
  8016fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016fe:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801701:	bb 00 00 00 00       	mov    $0x0,%ebx
  801706:	eb 02                	jmp    80170a <readn+0x18>
  801708:	01 c3                	add    %eax,%ebx
  80170a:	39 f3                	cmp    %esi,%ebx
  80170c:	73 21                	jae    80172f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80170e:	83 ec 04             	sub    $0x4,%esp
  801711:	89 f0                	mov    %esi,%eax
  801713:	29 d8                	sub    %ebx,%eax
  801715:	50                   	push   %eax
  801716:	89 d8                	mov    %ebx,%eax
  801718:	03 45 0c             	add    0xc(%ebp),%eax
  80171b:	50                   	push   %eax
  80171c:	57                   	push   %edi
  80171d:	e8 49 ff ff ff       	call   80166b <read>
		if (m < 0)
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	85 c0                	test   %eax,%eax
  801727:	78 04                	js     80172d <readn+0x3b>
			return m;
		if (m == 0)
  801729:	75 dd                	jne    801708 <readn+0x16>
  80172b:	eb 02                	jmp    80172f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80172d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80172f:	89 d8                	mov    %ebx,%eax
  801731:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801734:	5b                   	pop    %ebx
  801735:	5e                   	pop    %esi
  801736:	5f                   	pop    %edi
  801737:	5d                   	pop    %ebp
  801738:	c3                   	ret    

00801739 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	56                   	push   %esi
  80173d:	53                   	push   %ebx
  80173e:	83 ec 18             	sub    $0x18,%esp
  801741:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801744:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801747:	50                   	push   %eax
  801748:	53                   	push   %ebx
  801749:	e8 b4 fc ff ff       	call   801402 <fd_lookup>
  80174e:	83 c4 10             	add    $0x10,%esp
  801751:	85 c0                	test   %eax,%eax
  801753:	78 37                	js     80178c <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801755:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801758:	83 ec 08             	sub    $0x8,%esp
  80175b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175e:	50                   	push   %eax
  80175f:	ff 36                	push   (%esi)
  801761:	e8 ec fc ff ff       	call   801452 <dev_lookup>
  801766:	83 c4 10             	add    $0x10,%esp
  801769:	85 c0                	test   %eax,%eax
  80176b:	78 1f                	js     80178c <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80176d:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801771:	74 20                	je     801793 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801773:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801776:	8b 40 0c             	mov    0xc(%eax),%eax
  801779:	85 c0                	test   %eax,%eax
  80177b:	74 37                	je     8017b4 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80177d:	83 ec 04             	sub    $0x4,%esp
  801780:	ff 75 10             	push   0x10(%ebp)
  801783:	ff 75 0c             	push   0xc(%ebp)
  801786:	56                   	push   %esi
  801787:	ff d0                	call   *%eax
  801789:	83 c4 10             	add    $0x10,%esp
}
  80178c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178f:	5b                   	pop    %ebx
  801790:	5e                   	pop    %esi
  801791:	5d                   	pop    %ebp
  801792:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801793:	a1 04 40 80 00       	mov    0x804004,%eax
  801798:	8b 40 58             	mov    0x58(%eax),%eax
  80179b:	83 ec 04             	sub    $0x4,%esp
  80179e:	53                   	push   %ebx
  80179f:	50                   	push   %eax
  8017a0:	68 35 2d 80 00       	push   $0x802d35
  8017a5:	e8 35 ec ff ff       	call   8003df <cprintf>
		return -E_INVAL;
  8017aa:	83 c4 10             	add    $0x10,%esp
  8017ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017b2:	eb d8                	jmp    80178c <write+0x53>
		return -E_NOT_SUPP;
  8017b4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017b9:	eb d1                	jmp    80178c <write+0x53>

008017bb <seek>:

int
seek(int fdnum, off_t offset)
{
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c4:	50                   	push   %eax
  8017c5:	ff 75 08             	push   0x8(%ebp)
  8017c8:	e8 35 fc ff ff       	call   801402 <fd_lookup>
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	78 0e                	js     8017e2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017da:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e2:	c9                   	leave  
  8017e3:	c3                   	ret    

008017e4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	56                   	push   %esi
  8017e8:	53                   	push   %ebx
  8017e9:	83 ec 18             	sub    $0x18,%esp
  8017ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f2:	50                   	push   %eax
  8017f3:	53                   	push   %ebx
  8017f4:	e8 09 fc ff ff       	call   801402 <fd_lookup>
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	85 c0                	test   %eax,%eax
  8017fe:	78 34                	js     801834 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801800:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801803:	83 ec 08             	sub    $0x8,%esp
  801806:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801809:	50                   	push   %eax
  80180a:	ff 36                	push   (%esi)
  80180c:	e8 41 fc ff ff       	call   801452 <dev_lookup>
  801811:	83 c4 10             	add    $0x10,%esp
  801814:	85 c0                	test   %eax,%eax
  801816:	78 1c                	js     801834 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801818:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80181c:	74 1d                	je     80183b <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80181e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801821:	8b 40 18             	mov    0x18(%eax),%eax
  801824:	85 c0                	test   %eax,%eax
  801826:	74 34                	je     80185c <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801828:	83 ec 08             	sub    $0x8,%esp
  80182b:	ff 75 0c             	push   0xc(%ebp)
  80182e:	56                   	push   %esi
  80182f:	ff d0                	call   *%eax
  801831:	83 c4 10             	add    $0x10,%esp
}
  801834:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801837:	5b                   	pop    %ebx
  801838:	5e                   	pop    %esi
  801839:	5d                   	pop    %ebp
  80183a:	c3                   	ret    
			thisenv->env_id, fdnum);
  80183b:	a1 04 40 80 00       	mov    0x804004,%eax
  801840:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801843:	83 ec 04             	sub    $0x4,%esp
  801846:	53                   	push   %ebx
  801847:	50                   	push   %eax
  801848:	68 f8 2c 80 00       	push   $0x802cf8
  80184d:	e8 8d eb ff ff       	call   8003df <cprintf>
		return -E_INVAL;
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80185a:	eb d8                	jmp    801834 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80185c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801861:	eb d1                	jmp    801834 <ftruncate+0x50>

00801863 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	56                   	push   %esi
  801867:	53                   	push   %ebx
  801868:	83 ec 18             	sub    $0x18,%esp
  80186b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80186e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801871:	50                   	push   %eax
  801872:	ff 75 08             	push   0x8(%ebp)
  801875:	e8 88 fb ff ff       	call   801402 <fd_lookup>
  80187a:	83 c4 10             	add    $0x10,%esp
  80187d:	85 c0                	test   %eax,%eax
  80187f:	78 49                	js     8018ca <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801881:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801884:	83 ec 08             	sub    $0x8,%esp
  801887:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188a:	50                   	push   %eax
  80188b:	ff 36                	push   (%esi)
  80188d:	e8 c0 fb ff ff       	call   801452 <dev_lookup>
  801892:	83 c4 10             	add    $0x10,%esp
  801895:	85 c0                	test   %eax,%eax
  801897:	78 31                	js     8018ca <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801899:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80189c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018a0:	74 2f                	je     8018d1 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018a2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018a5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018ac:	00 00 00 
	stat->st_isdir = 0;
  8018af:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018b6:	00 00 00 
	stat->st_dev = dev;
  8018b9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018bf:	83 ec 08             	sub    $0x8,%esp
  8018c2:	53                   	push   %ebx
  8018c3:	56                   	push   %esi
  8018c4:	ff 50 14             	call   *0x14(%eax)
  8018c7:	83 c4 10             	add    $0x10,%esp
}
  8018ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018cd:	5b                   	pop    %ebx
  8018ce:	5e                   	pop    %esi
  8018cf:	5d                   	pop    %ebp
  8018d0:	c3                   	ret    
		return -E_NOT_SUPP;
  8018d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018d6:	eb f2                	jmp    8018ca <fstat+0x67>

008018d8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	56                   	push   %esi
  8018dc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018dd:	83 ec 08             	sub    $0x8,%esp
  8018e0:	6a 00                	push   $0x0
  8018e2:	ff 75 08             	push   0x8(%ebp)
  8018e5:	e8 e4 01 00 00       	call   801ace <open>
  8018ea:	89 c3                	mov    %eax,%ebx
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	85 c0                	test   %eax,%eax
  8018f1:	78 1b                	js     80190e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018f3:	83 ec 08             	sub    $0x8,%esp
  8018f6:	ff 75 0c             	push   0xc(%ebp)
  8018f9:	50                   	push   %eax
  8018fa:	e8 64 ff ff ff       	call   801863 <fstat>
  8018ff:	89 c6                	mov    %eax,%esi
	close(fd);
  801901:	89 1c 24             	mov    %ebx,(%esp)
  801904:	e8 26 fc ff ff       	call   80152f <close>
	return r;
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	89 f3                	mov    %esi,%ebx
}
  80190e:	89 d8                	mov    %ebx,%eax
  801910:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801913:	5b                   	pop    %ebx
  801914:	5e                   	pop    %esi
  801915:	5d                   	pop    %ebp
  801916:	c3                   	ret    

00801917 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	56                   	push   %esi
  80191b:	53                   	push   %ebx
  80191c:	89 c6                	mov    %eax,%esi
  80191e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801920:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801927:	74 27                	je     801950 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801929:	6a 07                	push   $0x7
  80192b:	68 00 50 80 00       	push   $0x805000
  801930:	56                   	push   %esi
  801931:	ff 35 00 60 80 00    	push   0x806000
  801937:	e8 bc f9 ff ff       	call   8012f8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80193c:	83 c4 0c             	add    $0xc,%esp
  80193f:	6a 00                	push   $0x0
  801941:	53                   	push   %ebx
  801942:	6a 00                	push   $0x0
  801944:	e8 3f f9 ff ff       	call   801288 <ipc_recv>
}
  801949:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80194c:	5b                   	pop    %ebx
  80194d:	5e                   	pop    %esi
  80194e:	5d                   	pop    %ebp
  80194f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801950:	83 ec 0c             	sub    $0xc,%esp
  801953:	6a 01                	push   $0x1
  801955:	e8 f2 f9 ff ff       	call   80134c <ipc_find_env>
  80195a:	a3 00 60 80 00       	mov    %eax,0x806000
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	eb c5                	jmp    801929 <fsipc+0x12>

00801964 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80196a:	8b 45 08             	mov    0x8(%ebp),%eax
  80196d:	8b 40 0c             	mov    0xc(%eax),%eax
  801970:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801975:	8b 45 0c             	mov    0xc(%ebp),%eax
  801978:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80197d:	ba 00 00 00 00       	mov    $0x0,%edx
  801982:	b8 02 00 00 00       	mov    $0x2,%eax
  801987:	e8 8b ff ff ff       	call   801917 <fsipc>
}
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    

0080198e <devfile_flush>:
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801994:	8b 45 08             	mov    0x8(%ebp),%eax
  801997:	8b 40 0c             	mov    0xc(%eax),%eax
  80199a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80199f:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a4:	b8 06 00 00 00       	mov    $0x6,%eax
  8019a9:	e8 69 ff ff ff       	call   801917 <fsipc>
}
  8019ae:	c9                   	leave  
  8019af:	c3                   	ret    

008019b0 <devfile_stat>:
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	53                   	push   %ebx
  8019b4:	83 ec 04             	sub    $0x4,%esp
  8019b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8019cf:	e8 43 ff ff ff       	call   801917 <fsipc>
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	78 2c                	js     801a04 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019d8:	83 ec 08             	sub    $0x8,%esp
  8019db:	68 00 50 80 00       	push   $0x805000
  8019e0:	53                   	push   %ebx
  8019e1:	e8 d3 ef ff ff       	call   8009b9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019e6:	a1 80 50 80 00       	mov    0x805080,%eax
  8019eb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019f1:	a1 84 50 80 00       	mov    0x805084,%eax
  8019f6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019fc:	83 c4 10             	add    $0x10,%esp
  8019ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a07:	c9                   	leave  
  801a08:	c3                   	ret    

00801a09 <devfile_write>:
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	83 ec 0c             	sub    $0xc,%esp
  801a0f:	8b 45 10             	mov    0x10(%ebp),%eax
  801a12:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a17:	39 d0                	cmp    %edx,%eax
  801a19:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a1c:	8b 55 08             	mov    0x8(%ebp),%edx
  801a1f:	8b 52 0c             	mov    0xc(%edx),%edx
  801a22:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801a28:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801a2d:	50                   	push   %eax
  801a2e:	ff 75 0c             	push   0xc(%ebp)
  801a31:	68 08 50 80 00       	push   $0x805008
  801a36:	e8 14 f1 ff ff       	call   800b4f <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801a3b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a40:	b8 04 00 00 00       	mov    $0x4,%eax
  801a45:	e8 cd fe ff ff       	call   801917 <fsipc>
}
  801a4a:	c9                   	leave  
  801a4b:	c3                   	ret    

00801a4c <devfile_read>:
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	56                   	push   %esi
  801a50:	53                   	push   %ebx
  801a51:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a54:	8b 45 08             	mov    0x8(%ebp),%eax
  801a57:	8b 40 0c             	mov    0xc(%eax),%eax
  801a5a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a5f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a65:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6a:	b8 03 00 00 00       	mov    $0x3,%eax
  801a6f:	e8 a3 fe ff ff       	call   801917 <fsipc>
  801a74:	89 c3                	mov    %eax,%ebx
  801a76:	85 c0                	test   %eax,%eax
  801a78:	78 1f                	js     801a99 <devfile_read+0x4d>
	assert(r <= n);
  801a7a:	39 f0                	cmp    %esi,%eax
  801a7c:	77 24                	ja     801aa2 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801a7e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a83:	7f 33                	jg     801ab8 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a85:	83 ec 04             	sub    $0x4,%esp
  801a88:	50                   	push   %eax
  801a89:	68 00 50 80 00       	push   $0x805000
  801a8e:	ff 75 0c             	push   0xc(%ebp)
  801a91:	e8 b9 f0 ff ff       	call   800b4f <memmove>
	return r;
  801a96:	83 c4 10             	add    $0x10,%esp
}
  801a99:	89 d8                	mov    %ebx,%eax
  801a9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9e:	5b                   	pop    %ebx
  801a9f:	5e                   	pop    %esi
  801aa0:	5d                   	pop    %ebp
  801aa1:	c3                   	ret    
	assert(r <= n);
  801aa2:	68 68 2d 80 00       	push   $0x802d68
  801aa7:	68 6f 2d 80 00       	push   $0x802d6f
  801aac:	6a 7c                	push   $0x7c
  801aae:	68 84 2d 80 00       	push   $0x802d84
  801ab3:	e8 4c e8 ff ff       	call   800304 <_panic>
	assert(r <= PGSIZE);
  801ab8:	68 8f 2d 80 00       	push   $0x802d8f
  801abd:	68 6f 2d 80 00       	push   $0x802d6f
  801ac2:	6a 7d                	push   $0x7d
  801ac4:	68 84 2d 80 00       	push   $0x802d84
  801ac9:	e8 36 e8 ff ff       	call   800304 <_panic>

00801ace <open>:
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	56                   	push   %esi
  801ad2:	53                   	push   %ebx
  801ad3:	83 ec 1c             	sub    $0x1c,%esp
  801ad6:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801ad9:	56                   	push   %esi
  801ada:	e8 9f ee ff ff       	call   80097e <strlen>
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ae7:	7f 6c                	jg     801b55 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801ae9:	83 ec 0c             	sub    $0xc,%esp
  801aec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aef:	50                   	push   %eax
  801af0:	e8 bd f8 ff ff       	call   8013b2 <fd_alloc>
  801af5:	89 c3                	mov    %eax,%ebx
  801af7:	83 c4 10             	add    $0x10,%esp
  801afa:	85 c0                	test   %eax,%eax
  801afc:	78 3c                	js     801b3a <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801afe:	83 ec 08             	sub    $0x8,%esp
  801b01:	56                   	push   %esi
  801b02:	68 00 50 80 00       	push   $0x805000
  801b07:	e8 ad ee ff ff       	call   8009b9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0f:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b14:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b17:	b8 01 00 00 00       	mov    $0x1,%eax
  801b1c:	e8 f6 fd ff ff       	call   801917 <fsipc>
  801b21:	89 c3                	mov    %eax,%ebx
  801b23:	83 c4 10             	add    $0x10,%esp
  801b26:	85 c0                	test   %eax,%eax
  801b28:	78 19                	js     801b43 <open+0x75>
	return fd2num(fd);
  801b2a:	83 ec 0c             	sub    $0xc,%esp
  801b2d:	ff 75 f4             	push   -0xc(%ebp)
  801b30:	e8 56 f8 ff ff       	call   80138b <fd2num>
  801b35:	89 c3                	mov    %eax,%ebx
  801b37:	83 c4 10             	add    $0x10,%esp
}
  801b3a:	89 d8                	mov    %ebx,%eax
  801b3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b3f:	5b                   	pop    %ebx
  801b40:	5e                   	pop    %esi
  801b41:	5d                   	pop    %ebp
  801b42:	c3                   	ret    
		fd_close(fd, 0);
  801b43:	83 ec 08             	sub    $0x8,%esp
  801b46:	6a 00                	push   $0x0
  801b48:	ff 75 f4             	push   -0xc(%ebp)
  801b4b:	e8 58 f9 ff ff       	call   8014a8 <fd_close>
		return r;
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	eb e5                	jmp    801b3a <open+0x6c>
		return -E_BAD_PATH;
  801b55:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801b5a:	eb de                	jmp    801b3a <open+0x6c>

00801b5c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b5c:	55                   	push   %ebp
  801b5d:	89 e5                	mov    %esp,%ebp
  801b5f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b62:	ba 00 00 00 00       	mov    $0x0,%edx
  801b67:	b8 08 00 00 00       	mov    $0x8,%eax
  801b6c:	e8 a6 fd ff ff       	call   801917 <fsipc>
}
  801b71:	c9                   	leave  
  801b72:	c3                   	ret    

00801b73 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801b79:	68 9b 2d 80 00       	push   $0x802d9b
  801b7e:	ff 75 0c             	push   0xc(%ebp)
  801b81:	e8 33 ee ff ff       	call   8009b9 <strcpy>
	return 0;
}
  801b86:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8b:	c9                   	leave  
  801b8c:	c3                   	ret    

00801b8d <devsock_close>:
{
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	53                   	push   %ebx
  801b91:	83 ec 10             	sub    $0x10,%esp
  801b94:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b97:	53                   	push   %ebx
  801b98:	e8 98 09 00 00       	call   802535 <pageref>
  801b9d:	89 c2                	mov    %eax,%edx
  801b9f:	83 c4 10             	add    $0x10,%esp
		return 0;
  801ba2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801ba7:	83 fa 01             	cmp    $0x1,%edx
  801baa:	74 05                	je     801bb1 <devsock_close+0x24>
}
  801bac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801baf:	c9                   	leave  
  801bb0:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801bb1:	83 ec 0c             	sub    $0xc,%esp
  801bb4:	ff 73 0c             	push   0xc(%ebx)
  801bb7:	e8 b7 02 00 00       	call   801e73 <nsipc_close>
  801bbc:	83 c4 10             	add    $0x10,%esp
  801bbf:	eb eb                	jmp    801bac <devsock_close+0x1f>

00801bc1 <devsock_write>:
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801bc7:	6a 00                	push   $0x0
  801bc9:	ff 75 10             	push   0x10(%ebp)
  801bcc:	ff 75 0c             	push   0xc(%ebp)
  801bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd2:	ff 70 0c             	push   0xc(%eax)
  801bd5:	e8 79 03 00 00       	call   801f53 <nsipc_send>
}
  801bda:	c9                   	leave  
  801bdb:	c3                   	ret    

00801bdc <devsock_read>:
{
  801bdc:	55                   	push   %ebp
  801bdd:	89 e5                	mov    %esp,%ebp
  801bdf:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801be2:	6a 00                	push   $0x0
  801be4:	ff 75 10             	push   0x10(%ebp)
  801be7:	ff 75 0c             	push   0xc(%ebp)
  801bea:	8b 45 08             	mov    0x8(%ebp),%eax
  801bed:	ff 70 0c             	push   0xc(%eax)
  801bf0:	e8 ef 02 00 00       	call   801ee4 <nsipc_recv>
}
  801bf5:	c9                   	leave  
  801bf6:	c3                   	ret    

00801bf7 <fd2sockid>:
{
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801bfd:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c00:	52                   	push   %edx
  801c01:	50                   	push   %eax
  801c02:	e8 fb f7 ff ff       	call   801402 <fd_lookup>
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	85 c0                	test   %eax,%eax
  801c0c:	78 10                	js     801c1e <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c11:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801c17:	39 08                	cmp    %ecx,(%eax)
  801c19:	75 05                	jne    801c20 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801c1b:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801c1e:	c9                   	leave  
  801c1f:	c3                   	ret    
		return -E_NOT_SUPP;
  801c20:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c25:	eb f7                	jmp    801c1e <fd2sockid+0x27>

00801c27 <alloc_sockfd>:
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	56                   	push   %esi
  801c2b:	53                   	push   %ebx
  801c2c:	83 ec 1c             	sub    $0x1c,%esp
  801c2f:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801c31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c34:	50                   	push   %eax
  801c35:	e8 78 f7 ff ff       	call   8013b2 <fd_alloc>
  801c3a:	89 c3                	mov    %eax,%ebx
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	78 43                	js     801c86 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c43:	83 ec 04             	sub    $0x4,%esp
  801c46:	68 07 04 00 00       	push   $0x407
  801c4b:	ff 75 f4             	push   -0xc(%ebp)
  801c4e:	6a 00                	push   $0x0
  801c50:	e8 60 f1 ff ff       	call   800db5 <sys_page_alloc>
  801c55:	89 c3                	mov    %eax,%ebx
  801c57:	83 c4 10             	add    $0x10,%esp
  801c5a:	85 c0                	test   %eax,%eax
  801c5c:	78 28                	js     801c86 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c61:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c67:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c73:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c76:	83 ec 0c             	sub    $0xc,%esp
  801c79:	50                   	push   %eax
  801c7a:	e8 0c f7 ff ff       	call   80138b <fd2num>
  801c7f:	89 c3                	mov    %eax,%ebx
  801c81:	83 c4 10             	add    $0x10,%esp
  801c84:	eb 0c                	jmp    801c92 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801c86:	83 ec 0c             	sub    $0xc,%esp
  801c89:	56                   	push   %esi
  801c8a:	e8 e4 01 00 00       	call   801e73 <nsipc_close>
		return r;
  801c8f:	83 c4 10             	add    $0x10,%esp
}
  801c92:	89 d8                	mov    %ebx,%eax
  801c94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c97:	5b                   	pop    %ebx
  801c98:	5e                   	pop    %esi
  801c99:	5d                   	pop    %ebp
  801c9a:	c3                   	ret    

00801c9b <accept>:
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca4:	e8 4e ff ff ff       	call   801bf7 <fd2sockid>
  801ca9:	85 c0                	test   %eax,%eax
  801cab:	78 1b                	js     801cc8 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801cad:	83 ec 04             	sub    $0x4,%esp
  801cb0:	ff 75 10             	push   0x10(%ebp)
  801cb3:	ff 75 0c             	push   0xc(%ebp)
  801cb6:	50                   	push   %eax
  801cb7:	e8 0e 01 00 00       	call   801dca <nsipc_accept>
  801cbc:	83 c4 10             	add    $0x10,%esp
  801cbf:	85 c0                	test   %eax,%eax
  801cc1:	78 05                	js     801cc8 <accept+0x2d>
	return alloc_sockfd(r);
  801cc3:	e8 5f ff ff ff       	call   801c27 <alloc_sockfd>
}
  801cc8:	c9                   	leave  
  801cc9:	c3                   	ret    

00801cca <bind>:
{
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd3:	e8 1f ff ff ff       	call   801bf7 <fd2sockid>
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	78 12                	js     801cee <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801cdc:	83 ec 04             	sub    $0x4,%esp
  801cdf:	ff 75 10             	push   0x10(%ebp)
  801ce2:	ff 75 0c             	push   0xc(%ebp)
  801ce5:	50                   	push   %eax
  801ce6:	e8 31 01 00 00       	call   801e1c <nsipc_bind>
  801ceb:	83 c4 10             	add    $0x10,%esp
}
  801cee:	c9                   	leave  
  801cef:	c3                   	ret    

00801cf0 <shutdown>:
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801cf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf9:	e8 f9 fe ff ff       	call   801bf7 <fd2sockid>
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	78 0f                	js     801d11 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801d02:	83 ec 08             	sub    $0x8,%esp
  801d05:	ff 75 0c             	push   0xc(%ebp)
  801d08:	50                   	push   %eax
  801d09:	e8 43 01 00 00       	call   801e51 <nsipc_shutdown>
  801d0e:	83 c4 10             	add    $0x10,%esp
}
  801d11:	c9                   	leave  
  801d12:	c3                   	ret    

00801d13 <connect>:
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d19:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1c:	e8 d6 fe ff ff       	call   801bf7 <fd2sockid>
  801d21:	85 c0                	test   %eax,%eax
  801d23:	78 12                	js     801d37 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801d25:	83 ec 04             	sub    $0x4,%esp
  801d28:	ff 75 10             	push   0x10(%ebp)
  801d2b:	ff 75 0c             	push   0xc(%ebp)
  801d2e:	50                   	push   %eax
  801d2f:	e8 59 01 00 00       	call   801e8d <nsipc_connect>
  801d34:	83 c4 10             	add    $0x10,%esp
}
  801d37:	c9                   	leave  
  801d38:	c3                   	ret    

00801d39 <listen>:
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d42:	e8 b0 fe ff ff       	call   801bf7 <fd2sockid>
  801d47:	85 c0                	test   %eax,%eax
  801d49:	78 0f                	js     801d5a <listen+0x21>
	return nsipc_listen(r, backlog);
  801d4b:	83 ec 08             	sub    $0x8,%esp
  801d4e:	ff 75 0c             	push   0xc(%ebp)
  801d51:	50                   	push   %eax
  801d52:	e8 6b 01 00 00       	call   801ec2 <nsipc_listen>
  801d57:	83 c4 10             	add    $0x10,%esp
}
  801d5a:	c9                   	leave  
  801d5b:	c3                   	ret    

00801d5c <socket>:

int
socket(int domain, int type, int protocol)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d62:	ff 75 10             	push   0x10(%ebp)
  801d65:	ff 75 0c             	push   0xc(%ebp)
  801d68:	ff 75 08             	push   0x8(%ebp)
  801d6b:	e8 41 02 00 00       	call   801fb1 <nsipc_socket>
  801d70:	83 c4 10             	add    $0x10,%esp
  801d73:	85 c0                	test   %eax,%eax
  801d75:	78 05                	js     801d7c <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801d77:	e8 ab fe ff ff       	call   801c27 <alloc_sockfd>
}
  801d7c:	c9                   	leave  
  801d7d:	c3                   	ret    

00801d7e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	53                   	push   %ebx
  801d82:	83 ec 04             	sub    $0x4,%esp
  801d85:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d87:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801d8e:	74 26                	je     801db6 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d90:	6a 07                	push   $0x7
  801d92:	68 00 70 80 00       	push   $0x807000
  801d97:	53                   	push   %ebx
  801d98:	ff 35 00 80 80 00    	push   0x808000
  801d9e:	e8 55 f5 ff ff       	call   8012f8 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801da3:	83 c4 0c             	add    $0xc,%esp
  801da6:	6a 00                	push   $0x0
  801da8:	6a 00                	push   $0x0
  801daa:	6a 00                	push   $0x0
  801dac:	e8 d7 f4 ff ff       	call   801288 <ipc_recv>
}
  801db1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801db4:	c9                   	leave  
  801db5:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801db6:	83 ec 0c             	sub    $0xc,%esp
  801db9:	6a 02                	push   $0x2
  801dbb:	e8 8c f5 ff ff       	call   80134c <ipc_find_env>
  801dc0:	a3 00 80 80 00       	mov    %eax,0x808000
  801dc5:	83 c4 10             	add    $0x10,%esp
  801dc8:	eb c6                	jmp    801d90 <nsipc+0x12>

00801dca <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	56                   	push   %esi
  801dce:	53                   	push   %ebx
  801dcf:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801dda:	8b 06                	mov    (%esi),%eax
  801ddc:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801de1:	b8 01 00 00 00       	mov    $0x1,%eax
  801de6:	e8 93 ff ff ff       	call   801d7e <nsipc>
  801deb:	89 c3                	mov    %eax,%ebx
  801ded:	85 c0                	test   %eax,%eax
  801def:	79 09                	jns    801dfa <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801df1:	89 d8                	mov    %ebx,%eax
  801df3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801df6:	5b                   	pop    %ebx
  801df7:	5e                   	pop    %esi
  801df8:	5d                   	pop    %ebp
  801df9:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801dfa:	83 ec 04             	sub    $0x4,%esp
  801dfd:	ff 35 10 70 80 00    	push   0x807010
  801e03:	68 00 70 80 00       	push   $0x807000
  801e08:	ff 75 0c             	push   0xc(%ebp)
  801e0b:	e8 3f ed ff ff       	call   800b4f <memmove>
		*addrlen = ret->ret_addrlen;
  801e10:	a1 10 70 80 00       	mov    0x807010,%eax
  801e15:	89 06                	mov    %eax,(%esi)
  801e17:	83 c4 10             	add    $0x10,%esp
	return r;
  801e1a:	eb d5                	jmp    801df1 <nsipc_accept+0x27>

00801e1c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	53                   	push   %ebx
  801e20:	83 ec 08             	sub    $0x8,%esp
  801e23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e26:	8b 45 08             	mov    0x8(%ebp),%eax
  801e29:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e2e:	53                   	push   %ebx
  801e2f:	ff 75 0c             	push   0xc(%ebp)
  801e32:	68 04 70 80 00       	push   $0x807004
  801e37:	e8 13 ed ff ff       	call   800b4f <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e3c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801e42:	b8 02 00 00 00       	mov    $0x2,%eax
  801e47:	e8 32 ff ff ff       	call   801d7e <nsipc>
}
  801e4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e4f:	c9                   	leave  
  801e50:	c3                   	ret    

00801e51 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
  801e54:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e57:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801e5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e62:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801e67:	b8 03 00 00 00       	mov    $0x3,%eax
  801e6c:	e8 0d ff ff ff       	call   801d7e <nsipc>
}
  801e71:	c9                   	leave  
  801e72:	c3                   	ret    

00801e73 <nsipc_close>:

int
nsipc_close(int s)
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e79:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7c:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801e81:	b8 04 00 00 00       	mov    $0x4,%eax
  801e86:	e8 f3 fe ff ff       	call   801d7e <nsipc>
}
  801e8b:	c9                   	leave  
  801e8c:	c3                   	ret    

00801e8d <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e8d:	55                   	push   %ebp
  801e8e:	89 e5                	mov    %esp,%ebp
  801e90:	53                   	push   %ebx
  801e91:	83 ec 08             	sub    $0x8,%esp
  801e94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e97:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9a:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e9f:	53                   	push   %ebx
  801ea0:	ff 75 0c             	push   0xc(%ebp)
  801ea3:	68 04 70 80 00       	push   $0x807004
  801ea8:	e8 a2 ec ff ff       	call   800b4f <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ead:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801eb3:	b8 05 00 00 00       	mov    $0x5,%eax
  801eb8:	e8 c1 fe ff ff       	call   801d7e <nsipc>
}
  801ebd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ec0:	c9                   	leave  
  801ec1:	c3                   	ret    

00801ec2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ec2:	55                   	push   %ebp
  801ec3:	89 e5                	mov    %esp,%ebp
  801ec5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ed3:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801ed8:	b8 06 00 00 00       	mov    $0x6,%eax
  801edd:	e8 9c fe ff ff       	call   801d7e <nsipc>
}
  801ee2:	c9                   	leave  
  801ee3:	c3                   	ret    

00801ee4 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
  801ee7:	56                   	push   %esi
  801ee8:	53                   	push   %ebx
  801ee9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801eec:	8b 45 08             	mov    0x8(%ebp),%eax
  801eef:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801ef4:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801efa:	8b 45 14             	mov    0x14(%ebp),%eax
  801efd:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f02:	b8 07 00 00 00       	mov    $0x7,%eax
  801f07:	e8 72 fe ff ff       	call   801d7e <nsipc>
  801f0c:	89 c3                	mov    %eax,%ebx
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	78 22                	js     801f34 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801f12:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801f17:	39 c6                	cmp    %eax,%esi
  801f19:	0f 4e c6             	cmovle %esi,%eax
  801f1c:	39 c3                	cmp    %eax,%ebx
  801f1e:	7f 1d                	jg     801f3d <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f20:	83 ec 04             	sub    $0x4,%esp
  801f23:	53                   	push   %ebx
  801f24:	68 00 70 80 00       	push   $0x807000
  801f29:	ff 75 0c             	push   0xc(%ebp)
  801f2c:	e8 1e ec ff ff       	call   800b4f <memmove>
  801f31:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f34:	89 d8                	mov    %ebx,%eax
  801f36:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f39:	5b                   	pop    %ebx
  801f3a:	5e                   	pop    %esi
  801f3b:	5d                   	pop    %ebp
  801f3c:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801f3d:	68 a7 2d 80 00       	push   $0x802da7
  801f42:	68 6f 2d 80 00       	push   $0x802d6f
  801f47:	6a 62                	push   $0x62
  801f49:	68 bc 2d 80 00       	push   $0x802dbc
  801f4e:	e8 b1 e3 ff ff       	call   800304 <_panic>

00801f53 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f53:	55                   	push   %ebp
  801f54:	89 e5                	mov    %esp,%ebp
  801f56:	53                   	push   %ebx
  801f57:	83 ec 04             	sub    $0x4,%esp
  801f5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f60:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801f65:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f6b:	7f 2e                	jg     801f9b <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f6d:	83 ec 04             	sub    $0x4,%esp
  801f70:	53                   	push   %ebx
  801f71:	ff 75 0c             	push   0xc(%ebp)
  801f74:	68 0c 70 80 00       	push   $0x80700c
  801f79:	e8 d1 eb ff ff       	call   800b4f <memmove>
	nsipcbuf.send.req_size = size;
  801f7e:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801f84:	8b 45 14             	mov    0x14(%ebp),%eax
  801f87:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801f8c:	b8 08 00 00 00       	mov    $0x8,%eax
  801f91:	e8 e8 fd ff ff       	call   801d7e <nsipc>
}
  801f96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f99:	c9                   	leave  
  801f9a:	c3                   	ret    
	assert(size < 1600);
  801f9b:	68 c8 2d 80 00       	push   $0x802dc8
  801fa0:	68 6f 2d 80 00       	push   $0x802d6f
  801fa5:	6a 6d                	push   $0x6d
  801fa7:	68 bc 2d 80 00       	push   $0x802dbc
  801fac:	e8 53 e3 ff ff       	call   800304 <_panic>

00801fb1 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801fb1:	55                   	push   %ebp
  801fb2:	89 e5                	mov    %esp,%ebp
  801fb4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801fb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801fba:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801fbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc2:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801fc7:	8b 45 10             	mov    0x10(%ebp),%eax
  801fca:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801fcf:	b8 09 00 00 00       	mov    $0x9,%eax
  801fd4:	e8 a5 fd ff ff       	call   801d7e <nsipc>
}
  801fd9:	c9                   	leave  
  801fda:	c3                   	ret    

00801fdb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801fdb:	55                   	push   %ebp
  801fdc:	89 e5                	mov    %esp,%ebp
  801fde:	56                   	push   %esi
  801fdf:	53                   	push   %ebx
  801fe0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801fe3:	83 ec 0c             	sub    $0xc,%esp
  801fe6:	ff 75 08             	push   0x8(%ebp)
  801fe9:	e8 ad f3 ff ff       	call   80139b <fd2data>
  801fee:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ff0:	83 c4 08             	add    $0x8,%esp
  801ff3:	68 d4 2d 80 00       	push   $0x802dd4
  801ff8:	53                   	push   %ebx
  801ff9:	e8 bb e9 ff ff       	call   8009b9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ffe:	8b 46 04             	mov    0x4(%esi),%eax
  802001:	2b 06                	sub    (%esi),%eax
  802003:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802009:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802010:	00 00 00 
	stat->st_dev = &devpipe;
  802013:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80201a:	30 80 00 
	return 0;
}
  80201d:	b8 00 00 00 00       	mov    $0x0,%eax
  802022:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802025:	5b                   	pop    %ebx
  802026:	5e                   	pop    %esi
  802027:	5d                   	pop    %ebp
  802028:	c3                   	ret    

00802029 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802029:	55                   	push   %ebp
  80202a:	89 e5                	mov    %esp,%ebp
  80202c:	53                   	push   %ebx
  80202d:	83 ec 0c             	sub    $0xc,%esp
  802030:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802033:	53                   	push   %ebx
  802034:	6a 00                	push   $0x0
  802036:	e8 ff ed ff ff       	call   800e3a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80203b:	89 1c 24             	mov    %ebx,(%esp)
  80203e:	e8 58 f3 ff ff       	call   80139b <fd2data>
  802043:	83 c4 08             	add    $0x8,%esp
  802046:	50                   	push   %eax
  802047:	6a 00                	push   $0x0
  802049:	e8 ec ed ff ff       	call   800e3a <sys_page_unmap>
}
  80204e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802051:	c9                   	leave  
  802052:	c3                   	ret    

00802053 <_pipeisclosed>:
{
  802053:	55                   	push   %ebp
  802054:	89 e5                	mov    %esp,%ebp
  802056:	57                   	push   %edi
  802057:	56                   	push   %esi
  802058:	53                   	push   %ebx
  802059:	83 ec 1c             	sub    $0x1c,%esp
  80205c:	89 c7                	mov    %eax,%edi
  80205e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802060:	a1 04 40 80 00       	mov    0x804004,%eax
  802065:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802068:	83 ec 0c             	sub    $0xc,%esp
  80206b:	57                   	push   %edi
  80206c:	e8 c4 04 00 00       	call   802535 <pageref>
  802071:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802074:	89 34 24             	mov    %esi,(%esp)
  802077:	e8 b9 04 00 00       	call   802535 <pageref>
		nn = thisenv->env_runs;
  80207c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802082:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  802085:	83 c4 10             	add    $0x10,%esp
  802088:	39 cb                	cmp    %ecx,%ebx
  80208a:	74 1b                	je     8020a7 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80208c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80208f:	75 cf                	jne    802060 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802091:	8b 42 68             	mov    0x68(%edx),%eax
  802094:	6a 01                	push   $0x1
  802096:	50                   	push   %eax
  802097:	53                   	push   %ebx
  802098:	68 db 2d 80 00       	push   $0x802ddb
  80209d:	e8 3d e3 ff ff       	call   8003df <cprintf>
  8020a2:	83 c4 10             	add    $0x10,%esp
  8020a5:	eb b9                	jmp    802060 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8020a7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8020aa:	0f 94 c0             	sete   %al
  8020ad:	0f b6 c0             	movzbl %al,%eax
}
  8020b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    

008020b8 <devpipe_write>:
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
  8020bb:	57                   	push   %edi
  8020bc:	56                   	push   %esi
  8020bd:	53                   	push   %ebx
  8020be:	83 ec 28             	sub    $0x28,%esp
  8020c1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8020c4:	56                   	push   %esi
  8020c5:	e8 d1 f2 ff ff       	call   80139b <fd2data>
  8020ca:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8020cc:	83 c4 10             	add    $0x10,%esp
  8020cf:	bf 00 00 00 00       	mov    $0x0,%edi
  8020d4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020d7:	75 09                	jne    8020e2 <devpipe_write+0x2a>
	return i;
  8020d9:	89 f8                	mov    %edi,%eax
  8020db:	eb 23                	jmp    802100 <devpipe_write+0x48>
			sys_yield();
  8020dd:	e8 b4 ec ff ff       	call   800d96 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020e2:	8b 43 04             	mov    0x4(%ebx),%eax
  8020e5:	8b 0b                	mov    (%ebx),%ecx
  8020e7:	8d 51 20             	lea    0x20(%ecx),%edx
  8020ea:	39 d0                	cmp    %edx,%eax
  8020ec:	72 1a                	jb     802108 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  8020ee:	89 da                	mov    %ebx,%edx
  8020f0:	89 f0                	mov    %esi,%eax
  8020f2:	e8 5c ff ff ff       	call   802053 <_pipeisclosed>
  8020f7:	85 c0                	test   %eax,%eax
  8020f9:	74 e2                	je     8020dd <devpipe_write+0x25>
				return 0;
  8020fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802100:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802108:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80210b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80210f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802112:	89 c2                	mov    %eax,%edx
  802114:	c1 fa 1f             	sar    $0x1f,%edx
  802117:	89 d1                	mov    %edx,%ecx
  802119:	c1 e9 1b             	shr    $0x1b,%ecx
  80211c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80211f:	83 e2 1f             	and    $0x1f,%edx
  802122:	29 ca                	sub    %ecx,%edx
  802124:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802128:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80212c:	83 c0 01             	add    $0x1,%eax
  80212f:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802132:	83 c7 01             	add    $0x1,%edi
  802135:	eb 9d                	jmp    8020d4 <devpipe_write+0x1c>

00802137 <devpipe_read>:
{
  802137:	55                   	push   %ebp
  802138:	89 e5                	mov    %esp,%ebp
  80213a:	57                   	push   %edi
  80213b:	56                   	push   %esi
  80213c:	53                   	push   %ebx
  80213d:	83 ec 18             	sub    $0x18,%esp
  802140:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802143:	57                   	push   %edi
  802144:	e8 52 f2 ff ff       	call   80139b <fd2data>
  802149:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80214b:	83 c4 10             	add    $0x10,%esp
  80214e:	be 00 00 00 00       	mov    $0x0,%esi
  802153:	3b 75 10             	cmp    0x10(%ebp),%esi
  802156:	75 13                	jne    80216b <devpipe_read+0x34>
	return i;
  802158:	89 f0                	mov    %esi,%eax
  80215a:	eb 02                	jmp    80215e <devpipe_read+0x27>
				return i;
  80215c:	89 f0                	mov    %esi,%eax
}
  80215e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802161:	5b                   	pop    %ebx
  802162:	5e                   	pop    %esi
  802163:	5f                   	pop    %edi
  802164:	5d                   	pop    %ebp
  802165:	c3                   	ret    
			sys_yield();
  802166:	e8 2b ec ff ff       	call   800d96 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80216b:	8b 03                	mov    (%ebx),%eax
  80216d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802170:	75 18                	jne    80218a <devpipe_read+0x53>
			if (i > 0)
  802172:	85 f6                	test   %esi,%esi
  802174:	75 e6                	jne    80215c <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  802176:	89 da                	mov    %ebx,%edx
  802178:	89 f8                	mov    %edi,%eax
  80217a:	e8 d4 fe ff ff       	call   802053 <_pipeisclosed>
  80217f:	85 c0                	test   %eax,%eax
  802181:	74 e3                	je     802166 <devpipe_read+0x2f>
				return 0;
  802183:	b8 00 00 00 00       	mov    $0x0,%eax
  802188:	eb d4                	jmp    80215e <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80218a:	99                   	cltd   
  80218b:	c1 ea 1b             	shr    $0x1b,%edx
  80218e:	01 d0                	add    %edx,%eax
  802190:	83 e0 1f             	and    $0x1f,%eax
  802193:	29 d0                	sub    %edx,%eax
  802195:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80219a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80219d:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8021a0:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8021a3:	83 c6 01             	add    $0x1,%esi
  8021a6:	eb ab                	jmp    802153 <devpipe_read+0x1c>

008021a8 <pipe>:
{
  8021a8:	55                   	push   %ebp
  8021a9:	89 e5                	mov    %esp,%ebp
  8021ab:	56                   	push   %esi
  8021ac:	53                   	push   %ebx
  8021ad:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8021b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021b3:	50                   	push   %eax
  8021b4:	e8 f9 f1 ff ff       	call   8013b2 <fd_alloc>
  8021b9:	89 c3                	mov    %eax,%ebx
  8021bb:	83 c4 10             	add    $0x10,%esp
  8021be:	85 c0                	test   %eax,%eax
  8021c0:	0f 88 23 01 00 00    	js     8022e9 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021c6:	83 ec 04             	sub    $0x4,%esp
  8021c9:	68 07 04 00 00       	push   $0x407
  8021ce:	ff 75 f4             	push   -0xc(%ebp)
  8021d1:	6a 00                	push   $0x0
  8021d3:	e8 dd eb ff ff       	call   800db5 <sys_page_alloc>
  8021d8:	89 c3                	mov    %eax,%ebx
  8021da:	83 c4 10             	add    $0x10,%esp
  8021dd:	85 c0                	test   %eax,%eax
  8021df:	0f 88 04 01 00 00    	js     8022e9 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  8021e5:	83 ec 0c             	sub    $0xc,%esp
  8021e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021eb:	50                   	push   %eax
  8021ec:	e8 c1 f1 ff ff       	call   8013b2 <fd_alloc>
  8021f1:	89 c3                	mov    %eax,%ebx
  8021f3:	83 c4 10             	add    $0x10,%esp
  8021f6:	85 c0                	test   %eax,%eax
  8021f8:	0f 88 db 00 00 00    	js     8022d9 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021fe:	83 ec 04             	sub    $0x4,%esp
  802201:	68 07 04 00 00       	push   $0x407
  802206:	ff 75 f0             	push   -0x10(%ebp)
  802209:	6a 00                	push   $0x0
  80220b:	e8 a5 eb ff ff       	call   800db5 <sys_page_alloc>
  802210:	89 c3                	mov    %eax,%ebx
  802212:	83 c4 10             	add    $0x10,%esp
  802215:	85 c0                	test   %eax,%eax
  802217:	0f 88 bc 00 00 00    	js     8022d9 <pipe+0x131>
	va = fd2data(fd0);
  80221d:	83 ec 0c             	sub    $0xc,%esp
  802220:	ff 75 f4             	push   -0xc(%ebp)
  802223:	e8 73 f1 ff ff       	call   80139b <fd2data>
  802228:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80222a:	83 c4 0c             	add    $0xc,%esp
  80222d:	68 07 04 00 00       	push   $0x407
  802232:	50                   	push   %eax
  802233:	6a 00                	push   $0x0
  802235:	e8 7b eb ff ff       	call   800db5 <sys_page_alloc>
  80223a:	89 c3                	mov    %eax,%ebx
  80223c:	83 c4 10             	add    $0x10,%esp
  80223f:	85 c0                	test   %eax,%eax
  802241:	0f 88 82 00 00 00    	js     8022c9 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802247:	83 ec 0c             	sub    $0xc,%esp
  80224a:	ff 75 f0             	push   -0x10(%ebp)
  80224d:	e8 49 f1 ff ff       	call   80139b <fd2data>
  802252:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802259:	50                   	push   %eax
  80225a:	6a 00                	push   $0x0
  80225c:	56                   	push   %esi
  80225d:	6a 00                	push   $0x0
  80225f:	e8 94 eb ff ff       	call   800df8 <sys_page_map>
  802264:	89 c3                	mov    %eax,%ebx
  802266:	83 c4 20             	add    $0x20,%esp
  802269:	85 c0                	test   %eax,%eax
  80226b:	78 4e                	js     8022bb <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80226d:	a1 3c 30 80 00       	mov    0x80303c,%eax
  802272:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802275:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802277:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80227a:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802281:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802284:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802286:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802289:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802290:	83 ec 0c             	sub    $0xc,%esp
  802293:	ff 75 f4             	push   -0xc(%ebp)
  802296:	e8 f0 f0 ff ff       	call   80138b <fd2num>
  80229b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80229e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8022a0:	83 c4 04             	add    $0x4,%esp
  8022a3:	ff 75 f0             	push   -0x10(%ebp)
  8022a6:	e8 e0 f0 ff ff       	call   80138b <fd2num>
  8022ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022ae:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8022b1:	83 c4 10             	add    $0x10,%esp
  8022b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8022b9:	eb 2e                	jmp    8022e9 <pipe+0x141>
	sys_page_unmap(0, va);
  8022bb:	83 ec 08             	sub    $0x8,%esp
  8022be:	56                   	push   %esi
  8022bf:	6a 00                	push   $0x0
  8022c1:	e8 74 eb ff ff       	call   800e3a <sys_page_unmap>
  8022c6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8022c9:	83 ec 08             	sub    $0x8,%esp
  8022cc:	ff 75 f0             	push   -0x10(%ebp)
  8022cf:	6a 00                	push   $0x0
  8022d1:	e8 64 eb ff ff       	call   800e3a <sys_page_unmap>
  8022d6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8022d9:	83 ec 08             	sub    $0x8,%esp
  8022dc:	ff 75 f4             	push   -0xc(%ebp)
  8022df:	6a 00                	push   $0x0
  8022e1:	e8 54 eb ff ff       	call   800e3a <sys_page_unmap>
  8022e6:	83 c4 10             	add    $0x10,%esp
}
  8022e9:	89 d8                	mov    %ebx,%eax
  8022eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022ee:	5b                   	pop    %ebx
  8022ef:	5e                   	pop    %esi
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    

008022f2 <pipeisclosed>:
{
  8022f2:	55                   	push   %ebp
  8022f3:	89 e5                	mov    %esp,%ebp
  8022f5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022fb:	50                   	push   %eax
  8022fc:	ff 75 08             	push   0x8(%ebp)
  8022ff:	e8 fe f0 ff ff       	call   801402 <fd_lookup>
  802304:	83 c4 10             	add    $0x10,%esp
  802307:	85 c0                	test   %eax,%eax
  802309:	78 18                	js     802323 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80230b:	83 ec 0c             	sub    $0xc,%esp
  80230e:	ff 75 f4             	push   -0xc(%ebp)
  802311:	e8 85 f0 ff ff       	call   80139b <fd2data>
  802316:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802318:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80231b:	e8 33 fd ff ff       	call   802053 <_pipeisclosed>
  802320:	83 c4 10             	add    $0x10,%esp
}
  802323:	c9                   	leave  
  802324:	c3                   	ret    

00802325 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802325:	b8 00 00 00 00       	mov    $0x0,%eax
  80232a:	c3                   	ret    

0080232b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80232b:	55                   	push   %ebp
  80232c:	89 e5                	mov    %esp,%ebp
  80232e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802331:	68 f3 2d 80 00       	push   $0x802df3
  802336:	ff 75 0c             	push   0xc(%ebp)
  802339:	e8 7b e6 ff ff       	call   8009b9 <strcpy>
	return 0;
}
  80233e:	b8 00 00 00 00       	mov    $0x0,%eax
  802343:	c9                   	leave  
  802344:	c3                   	ret    

00802345 <devcons_write>:
{
  802345:	55                   	push   %ebp
  802346:	89 e5                	mov    %esp,%ebp
  802348:	57                   	push   %edi
  802349:	56                   	push   %esi
  80234a:	53                   	push   %ebx
  80234b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802351:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802356:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80235c:	eb 2e                	jmp    80238c <devcons_write+0x47>
		m = n - tot;
  80235e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802361:	29 f3                	sub    %esi,%ebx
  802363:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802368:	39 c3                	cmp    %eax,%ebx
  80236a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80236d:	83 ec 04             	sub    $0x4,%esp
  802370:	53                   	push   %ebx
  802371:	89 f0                	mov    %esi,%eax
  802373:	03 45 0c             	add    0xc(%ebp),%eax
  802376:	50                   	push   %eax
  802377:	57                   	push   %edi
  802378:	e8 d2 e7 ff ff       	call   800b4f <memmove>
		sys_cputs(buf, m);
  80237d:	83 c4 08             	add    $0x8,%esp
  802380:	53                   	push   %ebx
  802381:	57                   	push   %edi
  802382:	e8 72 e9 ff ff       	call   800cf9 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802387:	01 de                	add    %ebx,%esi
  802389:	83 c4 10             	add    $0x10,%esp
  80238c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80238f:	72 cd                	jb     80235e <devcons_write+0x19>
}
  802391:	89 f0                	mov    %esi,%eax
  802393:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802396:	5b                   	pop    %ebx
  802397:	5e                   	pop    %esi
  802398:	5f                   	pop    %edi
  802399:	5d                   	pop    %ebp
  80239a:	c3                   	ret    

0080239b <devcons_read>:
{
  80239b:	55                   	push   %ebp
  80239c:	89 e5                	mov    %esp,%ebp
  80239e:	83 ec 08             	sub    $0x8,%esp
  8023a1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8023a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023aa:	75 07                	jne    8023b3 <devcons_read+0x18>
  8023ac:	eb 1f                	jmp    8023cd <devcons_read+0x32>
		sys_yield();
  8023ae:	e8 e3 e9 ff ff       	call   800d96 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8023b3:	e8 5f e9 ff ff       	call   800d17 <sys_cgetc>
  8023b8:	85 c0                	test   %eax,%eax
  8023ba:	74 f2                	je     8023ae <devcons_read+0x13>
	if (c < 0)
  8023bc:	78 0f                	js     8023cd <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8023be:	83 f8 04             	cmp    $0x4,%eax
  8023c1:	74 0c                	je     8023cf <devcons_read+0x34>
	*(char*)vbuf = c;
  8023c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023c6:	88 02                	mov    %al,(%edx)
	return 1;
  8023c8:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8023cd:	c9                   	leave  
  8023ce:	c3                   	ret    
		return 0;
  8023cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8023d4:	eb f7                	jmp    8023cd <devcons_read+0x32>

008023d6 <cputchar>:
{
  8023d6:	55                   	push   %ebp
  8023d7:	89 e5                	mov    %esp,%ebp
  8023d9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8023dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8023df:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8023e2:	6a 01                	push   $0x1
  8023e4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023e7:	50                   	push   %eax
  8023e8:	e8 0c e9 ff ff       	call   800cf9 <sys_cputs>
}
  8023ed:	83 c4 10             	add    $0x10,%esp
  8023f0:	c9                   	leave  
  8023f1:	c3                   	ret    

008023f2 <getchar>:
{
  8023f2:	55                   	push   %ebp
  8023f3:	89 e5                	mov    %esp,%ebp
  8023f5:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8023f8:	6a 01                	push   $0x1
  8023fa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023fd:	50                   	push   %eax
  8023fe:	6a 00                	push   $0x0
  802400:	e8 66 f2 ff ff       	call   80166b <read>
	if (r < 0)
  802405:	83 c4 10             	add    $0x10,%esp
  802408:	85 c0                	test   %eax,%eax
  80240a:	78 06                	js     802412 <getchar+0x20>
	if (r < 1)
  80240c:	74 06                	je     802414 <getchar+0x22>
	return c;
  80240e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802412:	c9                   	leave  
  802413:	c3                   	ret    
		return -E_EOF;
  802414:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802419:	eb f7                	jmp    802412 <getchar+0x20>

0080241b <iscons>:
{
  80241b:	55                   	push   %ebp
  80241c:	89 e5                	mov    %esp,%ebp
  80241e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802421:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802424:	50                   	push   %eax
  802425:	ff 75 08             	push   0x8(%ebp)
  802428:	e8 d5 ef ff ff       	call   801402 <fd_lookup>
  80242d:	83 c4 10             	add    $0x10,%esp
  802430:	85 c0                	test   %eax,%eax
  802432:	78 11                	js     802445 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802434:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802437:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80243d:	39 10                	cmp    %edx,(%eax)
  80243f:	0f 94 c0             	sete   %al
  802442:	0f b6 c0             	movzbl %al,%eax
}
  802445:	c9                   	leave  
  802446:	c3                   	ret    

00802447 <opencons>:
{
  802447:	55                   	push   %ebp
  802448:	89 e5                	mov    %esp,%ebp
  80244a:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80244d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802450:	50                   	push   %eax
  802451:	e8 5c ef ff ff       	call   8013b2 <fd_alloc>
  802456:	83 c4 10             	add    $0x10,%esp
  802459:	85 c0                	test   %eax,%eax
  80245b:	78 3a                	js     802497 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80245d:	83 ec 04             	sub    $0x4,%esp
  802460:	68 07 04 00 00       	push   $0x407
  802465:	ff 75 f4             	push   -0xc(%ebp)
  802468:	6a 00                	push   $0x0
  80246a:	e8 46 e9 ff ff       	call   800db5 <sys_page_alloc>
  80246f:	83 c4 10             	add    $0x10,%esp
  802472:	85 c0                	test   %eax,%eax
  802474:	78 21                	js     802497 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  802476:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802479:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80247f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802481:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802484:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80248b:	83 ec 0c             	sub    $0xc,%esp
  80248e:	50                   	push   %eax
  80248f:	e8 f7 ee ff ff       	call   80138b <fd2num>
  802494:	83 c4 10             	add    $0x10,%esp
}
  802497:	c9                   	leave  
  802498:	c3                   	ret    

00802499 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802499:	55                   	push   %ebp
  80249a:	89 e5                	mov    %esp,%ebp
  80249c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  80249f:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  8024a6:	74 0a                	je     8024b2 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8024a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ab:	a3 04 80 80 00       	mov    %eax,0x808004
}
  8024b0:	c9                   	leave  
  8024b1:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8024b2:	e8 c0 e8 ff ff       	call   800d77 <sys_getenvid>
  8024b7:	83 ec 04             	sub    $0x4,%esp
  8024ba:	68 07 0e 00 00       	push   $0xe07
  8024bf:	68 00 f0 bf ee       	push   $0xeebff000
  8024c4:	50                   	push   %eax
  8024c5:	e8 eb e8 ff ff       	call   800db5 <sys_page_alloc>
		if (r < 0) {
  8024ca:	83 c4 10             	add    $0x10,%esp
  8024cd:	85 c0                	test   %eax,%eax
  8024cf:	78 2c                	js     8024fd <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8024d1:	e8 a1 e8 ff ff       	call   800d77 <sys_getenvid>
  8024d6:	83 ec 08             	sub    $0x8,%esp
  8024d9:	68 0f 25 80 00       	push   $0x80250f
  8024de:	50                   	push   %eax
  8024df:	e8 1c ea ff ff       	call   800f00 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  8024e4:	83 c4 10             	add    $0x10,%esp
  8024e7:	85 c0                	test   %eax,%eax
  8024e9:	79 bd                	jns    8024a8 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  8024eb:	50                   	push   %eax
  8024ec:	68 40 2e 80 00       	push   $0x802e40
  8024f1:	6a 28                	push   $0x28
  8024f3:	68 76 2e 80 00       	push   $0x802e76
  8024f8:	e8 07 de ff ff       	call   800304 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  8024fd:	50                   	push   %eax
  8024fe:	68 00 2e 80 00       	push   $0x802e00
  802503:	6a 23                	push   $0x23
  802505:	68 76 2e 80 00       	push   $0x802e76
  80250a:	e8 f5 dd ff ff       	call   800304 <_panic>

0080250f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80250f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802510:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  802515:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802517:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  80251a:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  80251e:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802521:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802525:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802529:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  80252b:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  80252e:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  80252f:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  802532:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  802533:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  802534:	c3                   	ret    

00802535 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802535:	55                   	push   %ebp
  802536:	89 e5                	mov    %esp,%ebp
  802538:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80253b:	89 c2                	mov    %eax,%edx
  80253d:	c1 ea 16             	shr    $0x16,%edx
  802540:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802547:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80254c:	f6 c1 01             	test   $0x1,%cl
  80254f:	74 1c                	je     80256d <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802551:	c1 e8 0c             	shr    $0xc,%eax
  802554:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80255b:	a8 01                	test   $0x1,%al
  80255d:	74 0e                	je     80256d <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80255f:	c1 e8 0c             	shr    $0xc,%eax
  802562:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802569:	ef 
  80256a:	0f b7 d2             	movzwl %dx,%edx
}
  80256d:	89 d0                	mov    %edx,%eax
  80256f:	5d                   	pop    %ebp
  802570:	c3                   	ret    
  802571:	66 90                	xchg   %ax,%ax
  802573:	66 90                	xchg   %ax,%ax
  802575:	66 90                	xchg   %ax,%ax
  802577:	66 90                	xchg   %ax,%ax
  802579:	66 90                	xchg   %ax,%ax
  80257b:	66 90                	xchg   %ax,%ax
  80257d:	66 90                	xchg   %ax,%ax
  80257f:	90                   	nop

00802580 <__udivdi3>:
  802580:	f3 0f 1e fb          	endbr32 
  802584:	55                   	push   %ebp
  802585:	57                   	push   %edi
  802586:	56                   	push   %esi
  802587:	53                   	push   %ebx
  802588:	83 ec 1c             	sub    $0x1c,%esp
  80258b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80258f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802593:	8b 74 24 34          	mov    0x34(%esp),%esi
  802597:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80259b:	85 c0                	test   %eax,%eax
  80259d:	75 19                	jne    8025b8 <__udivdi3+0x38>
  80259f:	39 f3                	cmp    %esi,%ebx
  8025a1:	76 4d                	jbe    8025f0 <__udivdi3+0x70>
  8025a3:	31 ff                	xor    %edi,%edi
  8025a5:	89 e8                	mov    %ebp,%eax
  8025a7:	89 f2                	mov    %esi,%edx
  8025a9:	f7 f3                	div    %ebx
  8025ab:	89 fa                	mov    %edi,%edx
  8025ad:	83 c4 1c             	add    $0x1c,%esp
  8025b0:	5b                   	pop    %ebx
  8025b1:	5e                   	pop    %esi
  8025b2:	5f                   	pop    %edi
  8025b3:	5d                   	pop    %ebp
  8025b4:	c3                   	ret    
  8025b5:	8d 76 00             	lea    0x0(%esi),%esi
  8025b8:	39 f0                	cmp    %esi,%eax
  8025ba:	76 14                	jbe    8025d0 <__udivdi3+0x50>
  8025bc:	31 ff                	xor    %edi,%edi
  8025be:	31 c0                	xor    %eax,%eax
  8025c0:	89 fa                	mov    %edi,%edx
  8025c2:	83 c4 1c             	add    $0x1c,%esp
  8025c5:	5b                   	pop    %ebx
  8025c6:	5e                   	pop    %esi
  8025c7:	5f                   	pop    %edi
  8025c8:	5d                   	pop    %ebp
  8025c9:	c3                   	ret    
  8025ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025d0:	0f bd f8             	bsr    %eax,%edi
  8025d3:	83 f7 1f             	xor    $0x1f,%edi
  8025d6:	75 48                	jne    802620 <__udivdi3+0xa0>
  8025d8:	39 f0                	cmp    %esi,%eax
  8025da:	72 06                	jb     8025e2 <__udivdi3+0x62>
  8025dc:	31 c0                	xor    %eax,%eax
  8025de:	39 eb                	cmp    %ebp,%ebx
  8025e0:	77 de                	ja     8025c0 <__udivdi3+0x40>
  8025e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8025e7:	eb d7                	jmp    8025c0 <__udivdi3+0x40>
  8025e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	89 d9                	mov    %ebx,%ecx
  8025f2:	85 db                	test   %ebx,%ebx
  8025f4:	75 0b                	jne    802601 <__udivdi3+0x81>
  8025f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025fb:	31 d2                	xor    %edx,%edx
  8025fd:	f7 f3                	div    %ebx
  8025ff:	89 c1                	mov    %eax,%ecx
  802601:	31 d2                	xor    %edx,%edx
  802603:	89 f0                	mov    %esi,%eax
  802605:	f7 f1                	div    %ecx
  802607:	89 c6                	mov    %eax,%esi
  802609:	89 e8                	mov    %ebp,%eax
  80260b:	89 f7                	mov    %esi,%edi
  80260d:	f7 f1                	div    %ecx
  80260f:	89 fa                	mov    %edi,%edx
  802611:	83 c4 1c             	add    $0x1c,%esp
  802614:	5b                   	pop    %ebx
  802615:	5e                   	pop    %esi
  802616:	5f                   	pop    %edi
  802617:	5d                   	pop    %ebp
  802618:	c3                   	ret    
  802619:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802620:	89 f9                	mov    %edi,%ecx
  802622:	ba 20 00 00 00       	mov    $0x20,%edx
  802627:	29 fa                	sub    %edi,%edx
  802629:	d3 e0                	shl    %cl,%eax
  80262b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80262f:	89 d1                	mov    %edx,%ecx
  802631:	89 d8                	mov    %ebx,%eax
  802633:	d3 e8                	shr    %cl,%eax
  802635:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802639:	09 c1                	or     %eax,%ecx
  80263b:	89 f0                	mov    %esi,%eax
  80263d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802641:	89 f9                	mov    %edi,%ecx
  802643:	d3 e3                	shl    %cl,%ebx
  802645:	89 d1                	mov    %edx,%ecx
  802647:	d3 e8                	shr    %cl,%eax
  802649:	89 f9                	mov    %edi,%ecx
  80264b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80264f:	89 eb                	mov    %ebp,%ebx
  802651:	d3 e6                	shl    %cl,%esi
  802653:	89 d1                	mov    %edx,%ecx
  802655:	d3 eb                	shr    %cl,%ebx
  802657:	09 f3                	or     %esi,%ebx
  802659:	89 c6                	mov    %eax,%esi
  80265b:	89 f2                	mov    %esi,%edx
  80265d:	89 d8                	mov    %ebx,%eax
  80265f:	f7 74 24 08          	divl   0x8(%esp)
  802663:	89 d6                	mov    %edx,%esi
  802665:	89 c3                	mov    %eax,%ebx
  802667:	f7 64 24 0c          	mull   0xc(%esp)
  80266b:	39 d6                	cmp    %edx,%esi
  80266d:	72 19                	jb     802688 <__udivdi3+0x108>
  80266f:	89 f9                	mov    %edi,%ecx
  802671:	d3 e5                	shl    %cl,%ebp
  802673:	39 c5                	cmp    %eax,%ebp
  802675:	73 04                	jae    80267b <__udivdi3+0xfb>
  802677:	39 d6                	cmp    %edx,%esi
  802679:	74 0d                	je     802688 <__udivdi3+0x108>
  80267b:	89 d8                	mov    %ebx,%eax
  80267d:	31 ff                	xor    %edi,%edi
  80267f:	e9 3c ff ff ff       	jmp    8025c0 <__udivdi3+0x40>
  802684:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802688:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80268b:	31 ff                	xor    %edi,%edi
  80268d:	e9 2e ff ff ff       	jmp    8025c0 <__udivdi3+0x40>
  802692:	66 90                	xchg   %ax,%ax
  802694:	66 90                	xchg   %ax,%ax
  802696:	66 90                	xchg   %ax,%ax
  802698:	66 90                	xchg   %ax,%ax
  80269a:	66 90                	xchg   %ax,%ax
  80269c:	66 90                	xchg   %ax,%ax
  80269e:	66 90                	xchg   %ax,%ax

008026a0 <__umoddi3>:
  8026a0:	f3 0f 1e fb          	endbr32 
  8026a4:	55                   	push   %ebp
  8026a5:	57                   	push   %edi
  8026a6:	56                   	push   %esi
  8026a7:	53                   	push   %ebx
  8026a8:	83 ec 1c             	sub    $0x1c,%esp
  8026ab:	8b 74 24 30          	mov    0x30(%esp),%esi
  8026af:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8026b3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8026b7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8026bb:	89 f0                	mov    %esi,%eax
  8026bd:	89 da                	mov    %ebx,%edx
  8026bf:	85 ff                	test   %edi,%edi
  8026c1:	75 15                	jne    8026d8 <__umoddi3+0x38>
  8026c3:	39 dd                	cmp    %ebx,%ebp
  8026c5:	76 39                	jbe    802700 <__umoddi3+0x60>
  8026c7:	f7 f5                	div    %ebp
  8026c9:	89 d0                	mov    %edx,%eax
  8026cb:	31 d2                	xor    %edx,%edx
  8026cd:	83 c4 1c             	add    $0x1c,%esp
  8026d0:	5b                   	pop    %ebx
  8026d1:	5e                   	pop    %esi
  8026d2:	5f                   	pop    %edi
  8026d3:	5d                   	pop    %ebp
  8026d4:	c3                   	ret    
  8026d5:	8d 76 00             	lea    0x0(%esi),%esi
  8026d8:	39 df                	cmp    %ebx,%edi
  8026da:	77 f1                	ja     8026cd <__umoddi3+0x2d>
  8026dc:	0f bd cf             	bsr    %edi,%ecx
  8026df:	83 f1 1f             	xor    $0x1f,%ecx
  8026e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8026e6:	75 40                	jne    802728 <__umoddi3+0x88>
  8026e8:	39 df                	cmp    %ebx,%edi
  8026ea:	72 04                	jb     8026f0 <__umoddi3+0x50>
  8026ec:	39 f5                	cmp    %esi,%ebp
  8026ee:	77 dd                	ja     8026cd <__umoddi3+0x2d>
  8026f0:	89 da                	mov    %ebx,%edx
  8026f2:	89 f0                	mov    %esi,%eax
  8026f4:	29 e8                	sub    %ebp,%eax
  8026f6:	19 fa                	sbb    %edi,%edx
  8026f8:	eb d3                	jmp    8026cd <__umoddi3+0x2d>
  8026fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802700:	89 e9                	mov    %ebp,%ecx
  802702:	85 ed                	test   %ebp,%ebp
  802704:	75 0b                	jne    802711 <__umoddi3+0x71>
  802706:	b8 01 00 00 00       	mov    $0x1,%eax
  80270b:	31 d2                	xor    %edx,%edx
  80270d:	f7 f5                	div    %ebp
  80270f:	89 c1                	mov    %eax,%ecx
  802711:	89 d8                	mov    %ebx,%eax
  802713:	31 d2                	xor    %edx,%edx
  802715:	f7 f1                	div    %ecx
  802717:	89 f0                	mov    %esi,%eax
  802719:	f7 f1                	div    %ecx
  80271b:	89 d0                	mov    %edx,%eax
  80271d:	31 d2                	xor    %edx,%edx
  80271f:	eb ac                	jmp    8026cd <__umoddi3+0x2d>
  802721:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802728:	8b 44 24 04          	mov    0x4(%esp),%eax
  80272c:	ba 20 00 00 00       	mov    $0x20,%edx
  802731:	29 c2                	sub    %eax,%edx
  802733:	89 c1                	mov    %eax,%ecx
  802735:	89 e8                	mov    %ebp,%eax
  802737:	d3 e7                	shl    %cl,%edi
  802739:	89 d1                	mov    %edx,%ecx
  80273b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80273f:	d3 e8                	shr    %cl,%eax
  802741:	89 c1                	mov    %eax,%ecx
  802743:	8b 44 24 04          	mov    0x4(%esp),%eax
  802747:	09 f9                	or     %edi,%ecx
  802749:	89 df                	mov    %ebx,%edi
  80274b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80274f:	89 c1                	mov    %eax,%ecx
  802751:	d3 e5                	shl    %cl,%ebp
  802753:	89 d1                	mov    %edx,%ecx
  802755:	d3 ef                	shr    %cl,%edi
  802757:	89 c1                	mov    %eax,%ecx
  802759:	89 f0                	mov    %esi,%eax
  80275b:	d3 e3                	shl    %cl,%ebx
  80275d:	89 d1                	mov    %edx,%ecx
  80275f:	89 fa                	mov    %edi,%edx
  802761:	d3 e8                	shr    %cl,%eax
  802763:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802768:	09 d8                	or     %ebx,%eax
  80276a:	f7 74 24 08          	divl   0x8(%esp)
  80276e:	89 d3                	mov    %edx,%ebx
  802770:	d3 e6                	shl    %cl,%esi
  802772:	f7 e5                	mul    %ebp
  802774:	89 c7                	mov    %eax,%edi
  802776:	89 d1                	mov    %edx,%ecx
  802778:	39 d3                	cmp    %edx,%ebx
  80277a:	72 06                	jb     802782 <__umoddi3+0xe2>
  80277c:	75 0e                	jne    80278c <__umoddi3+0xec>
  80277e:	39 c6                	cmp    %eax,%esi
  802780:	73 0a                	jae    80278c <__umoddi3+0xec>
  802782:	29 e8                	sub    %ebp,%eax
  802784:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802788:	89 d1                	mov    %edx,%ecx
  80278a:	89 c7                	mov    %eax,%edi
  80278c:	89 f5                	mov    %esi,%ebp
  80278e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802792:	29 fd                	sub    %edi,%ebp
  802794:	19 cb                	sbb    %ecx,%ebx
  802796:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80279b:	89 d8                	mov    %ebx,%eax
  80279d:	d3 e0                	shl    %cl,%eax
  80279f:	89 f1                	mov    %esi,%ecx
  8027a1:	d3 ed                	shr    %cl,%ebp
  8027a3:	d3 eb                	shr    %cl,%ebx
  8027a5:	09 e8                	or     %ebp,%eax
  8027a7:	89 da                	mov    %ebx,%edx
  8027a9:	83 c4 1c             	add    $0x1c,%esp
  8027ac:	5b                   	pop    %ebx
  8027ad:	5e                   	pop    %esi
  8027ae:	5f                   	pop    %edi
  8027af:	5d                   	pop    %ebp
  8027b0:	c3                   	ret    
