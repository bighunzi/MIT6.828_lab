
obj/net/testinput：     文件格式 elf32-i386


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
  80002c:	e8 e9 07 00 00       	call   80081a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 7c             	sub    $0x7c,%esp
	envid_t ns_envid = sys_getenvid();
  80003c:	e8 af 12 00 00       	call   8012f0 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx
	int i, r, first = 1;

	binaryname = "testinput";
  800043:	c7 05 00 40 80 00 40 	movl   $0x802d40,0x804000
  80004a:	2d 80 00 

	output_envid = fork();
  80004d:	e8 2c 16 00 00       	call   80167e <fork>
  800052:	a3 04 50 80 00       	mov    %eax,0x805004
	if (output_envid < 0)
  800057:	85 c0                	test   %eax,%eax
  800059:	0f 88 79 01 00 00    	js     8001d8 <umain+0x1a5>
		panic("error forking");
	else if (output_envid == 0) {
  80005f:	0f 84 87 01 00 00    	je     8001ec <umain+0x1b9>
		output(ns_envid);
		return;
	}

	input_envid = fork();
  800065:	e8 14 16 00 00       	call   80167e <fork>
  80006a:	a3 00 50 80 00       	mov    %eax,0x805000
	if (input_envid < 0)
  80006f:	85 c0                	test   %eax,%eax
  800071:	0f 88 89 01 00 00    	js     800200 <umain+0x1cd>
		panic("error forking");
	else if (input_envid == 0) {
  800077:	0f 84 97 01 00 00    	je     800214 <umain+0x1e1>
		input(ns_envid);
		return;
	}

	cprintf("Sending ARP announcement...\n");
  80007d:	83 ec 0c             	sub    $0xc,%esp
  800080:	68 68 2d 80 00       	push   $0x802d68
  800085:	e8 ce 08 00 00       	call   800958 <cprintf>
	uint8_t mac[6] = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};
  80008a:	c7 45 98 52 54 00 12 	movl   $0x12005452,-0x68(%ebp)
  800091:	66 c7 45 9c 34 56    	movw   $0x5634,-0x64(%ebp)
	uint32_t myip = inet_addr(IP);
  800097:	c7 04 24 85 2d 80 00 	movl   $0x802d85,(%esp)
  80009e:	e8 42 07 00 00       	call   8007e5 <inet_addr>
  8000a3:	89 45 90             	mov    %eax,-0x70(%ebp)
	uint32_t gwip = inet_addr(DEFAULT);
  8000a6:	c7 04 24 8f 2d 80 00 	movl   $0x802d8f,(%esp)
  8000ad:	e8 33 07 00 00       	call   8007e5 <inet_addr>
  8000b2:	89 45 94             	mov    %eax,-0x6c(%ebp)
	if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  8000b5:	83 c4 0c             	add    $0xc,%esp
  8000b8:	6a 07                	push   $0x7
  8000ba:	68 00 b0 fe 0f       	push   $0xffeb000
  8000bf:	6a 00                	push   $0x0
  8000c1:	e8 68 12 00 00       	call   80132e <sys_page_alloc>
  8000c6:	83 c4 10             	add    $0x10,%esp
  8000c9:	85 c0                	test   %eax,%eax
  8000cb:	0f 88 51 01 00 00    	js     800222 <umain+0x1ef>
	pkt->jp_len = sizeof(*arp);
  8000d1:	c7 05 00 b0 fe 0f 2a 	movl   $0x2a,0xffeb000
  8000d8:	00 00 00 
	memset(arp->ethhdr.dest.addr, 0xff, ETHARP_HWADDR_LEN);
  8000db:	83 ec 04             	sub    $0x4,%esp
  8000de:	6a 06                	push   $0x6
  8000e0:	68 ff 00 00 00       	push   $0xff
  8000e5:	68 04 b0 fe 0f       	push   $0xffeb004
  8000ea:	e8 93 0f 00 00       	call   801082 <memset>
	memcpy(arp->ethhdr.src.addr,  mac,  ETHARP_HWADDR_LEN);
  8000ef:	83 c4 0c             	add    $0xc,%esp
  8000f2:	6a 06                	push   $0x6
  8000f4:	8d 5d 98             	lea    -0x68(%ebp),%ebx
  8000f7:	53                   	push   %ebx
  8000f8:	68 0a b0 fe 0f       	push   $0xffeb00a
  8000fd:	e8 28 10 00 00       	call   80112a <memcpy>
	arp->ethhdr.type = htons(ETHTYPE_ARP);
  800102:	c7 04 24 06 08 00 00 	movl   $0x806,(%esp)
  800109:	e8 b7 04 00 00       	call   8005c5 <htons>
  80010e:	66 a3 10 b0 fe 0f    	mov    %ax,0xffeb010
	arp->hwtype = htons(1); // Ethernet
  800114:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80011b:	e8 a5 04 00 00       	call   8005c5 <htons>
  800120:	66 a3 12 b0 fe 0f    	mov    %ax,0xffeb012
	arp->proto = htons(ETHTYPE_IP);
  800126:	c7 04 24 00 08 00 00 	movl   $0x800,(%esp)
  80012d:	e8 93 04 00 00       	call   8005c5 <htons>
  800132:	66 a3 14 b0 fe 0f    	mov    %ax,0xffeb014
	arp->_hwlen_protolen = htons((ETHARP_HWADDR_LEN << 8) | 4);
  800138:	c7 04 24 04 06 00 00 	movl   $0x604,(%esp)
  80013f:	e8 81 04 00 00       	call   8005c5 <htons>
  800144:	66 a3 16 b0 fe 0f    	mov    %ax,0xffeb016
	arp->opcode = htons(ARP_REQUEST);
  80014a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800151:	e8 6f 04 00 00       	call   8005c5 <htons>
  800156:	66 a3 18 b0 fe 0f    	mov    %ax,0xffeb018
	memcpy(arp->shwaddr.addr,  mac,   ETHARP_HWADDR_LEN);
  80015c:	83 c4 0c             	add    $0xc,%esp
  80015f:	6a 06                	push   $0x6
  800161:	53                   	push   %ebx
  800162:	68 1a b0 fe 0f       	push   $0xffeb01a
  800167:	e8 be 0f 00 00       	call   80112a <memcpy>
	memcpy(arp->sipaddr.addrw, &myip, 4);
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	6a 04                	push   $0x4
  800171:	8d 45 90             	lea    -0x70(%ebp),%eax
  800174:	50                   	push   %eax
  800175:	68 20 b0 fe 0f       	push   $0xffeb020
  80017a:	e8 ab 0f 00 00       	call   80112a <memcpy>
	memset(arp->dhwaddr.addr,  0x00,  ETHARP_HWADDR_LEN);
  80017f:	83 c4 0c             	add    $0xc,%esp
  800182:	6a 06                	push   $0x6
  800184:	6a 00                	push   $0x0
  800186:	68 24 b0 fe 0f       	push   $0xffeb024
  80018b:	e8 f2 0e 00 00       	call   801082 <memset>
	memcpy(arp->dipaddr.addrw, &gwip, 4);
  800190:	83 c4 0c             	add    $0xc,%esp
  800193:	6a 04                	push   $0x4
  800195:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800198:	50                   	push   %eax
  800199:	68 2a b0 fe 0f       	push   $0xffeb02a
  80019e:	e8 87 0f 00 00       	call   80112a <memcpy>
	ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8001a3:	6a 07                	push   $0x7
  8001a5:	68 00 b0 fe 0f       	push   $0xffeb000
  8001aa:	6a 0b                	push   $0xb
  8001ac:	ff 35 04 50 80 00    	push   0x805004
  8001b2:	e8 ba 16 00 00       	call   801871 <ipc_send>
	sys_page_unmap(0, pkt);
  8001b7:	83 c4 18             	add    $0x18,%esp
  8001ba:	68 00 b0 fe 0f       	push   $0xffeb000
  8001bf:	6a 00                	push   $0x0
  8001c1:	e8 ed 11 00 00       	call   8013b3 <sys_page_unmap>
}
  8001c6:	83 c4 10             	add    $0x10,%esp
	int i, r, first = 1;
  8001c9:	c7 85 7c ff ff ff 01 	movl   $0x1,-0x84(%ebp)
  8001d0:	00 00 00 
}
  8001d3:	e9 65 01 00 00       	jmp    80033d <umain+0x30a>
		panic("error forking");
  8001d8:	83 ec 04             	sub    $0x4,%esp
  8001db:	68 4a 2d 80 00       	push   $0x802d4a
  8001e0:	6a 4d                	push   $0x4d
  8001e2:	68 58 2d 80 00       	push   $0x802d58
  8001e7:	e8 91 06 00 00       	call   80087d <_panic>
		output(ns_envid);
  8001ec:	83 ec 0c             	sub    $0xc,%esp
  8001ef:	53                   	push   %ebx
  8001f0:	e8 d6 02 00 00       	call   8004cb <output>
		return;
  8001f5:	83 c4 10             	add    $0x10,%esp
		// we've received the ARP reply
		if (first)
			cprintf("Waiting for packets...\n");
		first = 0;
	}
}
  8001f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fb:	5b                   	pop    %ebx
  8001fc:	5e                   	pop    %esi
  8001fd:	5f                   	pop    %edi
  8001fe:	5d                   	pop    %ebp
  8001ff:	c3                   	ret    
		panic("error forking");
  800200:	83 ec 04             	sub    $0x4,%esp
  800203:	68 4a 2d 80 00       	push   $0x802d4a
  800208:	6a 55                	push   $0x55
  80020a:	68 58 2d 80 00       	push   $0x802d58
  80020f:	e8 69 06 00 00       	call   80087d <_panic>
		input(ns_envid);
  800214:	83 ec 0c             	sub    $0xc,%esp
  800217:	53                   	push   %ebx
  800218:	e8 3d 02 00 00       	call   80045a <input>
		return;
  80021d:	83 c4 10             	add    $0x10,%esp
  800220:	eb d6                	jmp    8001f8 <umain+0x1c5>
		panic("sys_page_map: %e", r);
  800222:	50                   	push   %eax
  800223:	68 98 2d 80 00       	push   $0x802d98
  800228:	6a 19                	push   $0x19
  80022a:	68 58 2d 80 00       	push   $0x802d58
  80022f:	e8 49 06 00 00       	call   80087d <_panic>
			panic("ipc_recv: %e", req);
  800234:	50                   	push   %eax
  800235:	68 a9 2d 80 00       	push   $0x802da9
  80023a:	6a 64                	push   $0x64
  80023c:	68 58 2d 80 00       	push   $0x802d58
  800241:	e8 37 06 00 00       	call   80087d <_panic>
			panic("IPC from unexpected environment %08x", whom);
  800246:	52                   	push   %edx
  800247:	68 00 2e 80 00       	push   $0x802e00
  80024c:	6a 66                	push   $0x66
  80024e:	68 58 2d 80 00       	push   $0x802d58
  800253:	e8 25 06 00 00       	call   80087d <_panic>
			panic("Unexpected IPC %d", req);
  800258:	50                   	push   %eax
  800259:	68 b6 2d 80 00       	push   $0x802db6
  80025e:	6a 68                	push   $0x68
  800260:	68 58 2d 80 00       	push   $0x802d58
  800265:	e8 13 06 00 00       	call   80087d <_panic>
			out = buf + snprintf(buf, end - buf,
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	53                   	push   %ebx
  80026e:	68 c8 2d 80 00       	push   $0x802dc8
  800273:	68 d0 2d 80 00       	push   $0x802dd0
  800278:	6a 50                	push   $0x50
  80027a:	8d 45 98             	lea    -0x68(%ebp),%eax
  80027d:	50                   	push   %eax
  80027e:	e8 5a 0c 00 00       	call   800edd <snprintf>
  800283:	8d 4d 98             	lea    -0x68(%ebp),%ecx
  800286:	8d 34 01             	lea    (%ecx,%eax,1),%esi
  800289:	83 c4 20             	add    $0x20,%esp
  80028c:	eb 42                	jmp    8002d0 <umain+0x29d>
			cprintf("%.*s\n", out - buf, buf);
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	8d 45 98             	lea    -0x68(%ebp),%eax
  800294:	50                   	push   %eax
  800295:	89 f0                	mov    %esi,%eax
  800297:	8d 4d 98             	lea    -0x68(%ebp),%ecx
  80029a:	29 c8                	sub    %ecx,%eax
  80029c:	50                   	push   %eax
  80029d:	68 df 2d 80 00       	push   $0x802ddf
  8002a2:	e8 b1 06 00 00       	call   800958 <cprintf>
  8002a7:	83 c4 10             	add    $0x10,%esp
		if (i % 2 == 1)
  8002aa:	89 da                	mov    %ebx,%edx
  8002ac:	c1 ea 1f             	shr    $0x1f,%edx
  8002af:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  8002b2:	83 e0 01             	and    $0x1,%eax
  8002b5:	29 d0                	sub    %edx,%eax
  8002b7:	83 f8 01             	cmp    $0x1,%eax
  8002ba:	74 4e                	je     80030a <umain+0x2d7>
		if (i % 16 == 7)
  8002bc:	83 ff 07             	cmp    $0x7,%edi
  8002bf:	74 51                	je     800312 <umain+0x2df>
	for (i = 0; i < len; i++) {
  8002c1:	83 c3 01             	add    $0x1,%ebx
  8002c4:	39 5d 84             	cmp    %ebx,-0x7c(%ebp)
  8002c7:	7e 51                	jle    80031a <umain+0x2e7>
  8002c9:	89 df                	mov    %ebx,%edi
		if (i % 16 == 0)
  8002cb:	f6 c3 0f             	test   $0xf,%bl
  8002ce:	74 9a                	je     80026a <umain+0x237>
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
  8002d0:	0f b6 87 04 b0 fe 0f 	movzbl 0xffeb004(%edi),%eax
  8002d7:	50                   	push   %eax
  8002d8:	68 da 2d 80 00       	push   $0x802dda
  8002dd:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002e0:	29 f0                	sub    %esi,%eax
  8002e2:	50                   	push   %eax
  8002e3:	56                   	push   %esi
  8002e4:	e8 f4 0b 00 00       	call   800edd <snprintf>
  8002e9:	01 c6                	add    %eax,%esi
		if (i % 16 == 15 || i == len - 1)
  8002eb:	89 d8                	mov    %ebx,%eax
  8002ed:	c1 f8 1f             	sar    $0x1f,%eax
  8002f0:	c1 e8 1c             	shr    $0x1c,%eax
  8002f3:	8d 3c 03             	lea    (%ebx,%eax,1),%edi
  8002f6:	83 e7 0f             	and    $0xf,%edi
  8002f9:	29 c7                	sub    %eax,%edi
  8002fb:	83 c4 10             	add    $0x10,%esp
  8002fe:	83 ff 0f             	cmp    $0xf,%edi
  800301:	74 8b                	je     80028e <umain+0x25b>
  800303:	3b 5d 80             	cmp    -0x80(%ebp),%ebx
  800306:	75 a2                	jne    8002aa <umain+0x277>
  800308:	eb 84                	jmp    80028e <umain+0x25b>
			*(out++) = ' ';
  80030a:	c6 06 20             	movb   $0x20,(%esi)
  80030d:	8d 76 01             	lea    0x1(%esi),%esi
  800310:	eb aa                	jmp    8002bc <umain+0x289>
			*(out++) = ' ';
  800312:	c6 06 20             	movb   $0x20,(%esi)
  800315:	8d 76 01             	lea    0x1(%esi),%esi
  800318:	eb a7                	jmp    8002c1 <umain+0x28e>
		cprintf("\n");
  80031a:	83 ec 0c             	sub    $0xc,%esp
  80031d:	68 fb 2d 80 00       	push   $0x802dfb
  800322:	e8 31 06 00 00       	call   800958 <cprintf>
		if (first)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	83 bd 7c ff ff ff 00 	cmpl   $0x0,-0x84(%ebp)
  800331:	75 5f                	jne    800392 <umain+0x35f>
		first = 0;
  800333:	c7 85 7c ff ff ff 00 	movl   $0x0,-0x84(%ebp)
  80033a:	00 00 00 
		int32_t req = ipc_recv((int32_t *)&whom, pkt, &perm);
  80033d:	83 ec 04             	sub    $0x4,%esp
  800340:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800343:	50                   	push   %eax
  800344:	68 00 b0 fe 0f       	push   $0xffeb000
  800349:	8d 45 90             	lea    -0x70(%ebp),%eax
  80034c:	50                   	push   %eax
  80034d:	e8 af 14 00 00       	call   801801 <ipc_recv>
		if (req < 0)
  800352:	83 c4 10             	add    $0x10,%esp
  800355:	85 c0                	test   %eax,%eax
  800357:	0f 88 d7 fe ff ff    	js     800234 <umain+0x201>
		if (whom != input_envid)
  80035d:	8b 55 90             	mov    -0x70(%ebp),%edx
  800360:	3b 15 00 50 80 00    	cmp    0x805000,%edx
  800366:	0f 85 da fe ff ff    	jne    800246 <umain+0x213>
		if (req != NSREQ_INPUT)
  80036c:	83 f8 0a             	cmp    $0xa,%eax
  80036f:	0f 85 e3 fe ff ff    	jne    800258 <umain+0x225>
		hexdump("input: ", pkt->jp_data, pkt->jp_len);
  800375:	a1 00 b0 fe 0f       	mov    0xffeb000,%eax
  80037a:	89 45 84             	mov    %eax,-0x7c(%ebp)
	char *out = NULL;
  80037d:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < len; i++) {
  800382:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i % 16 == 15 || i == len - 1)
  800387:	83 e8 01             	sub    $0x1,%eax
  80038a:	89 45 80             	mov    %eax,-0x80(%ebp)
	for (i = 0; i < len; i++) {
  80038d:	e9 32 ff ff ff       	jmp    8002c4 <umain+0x291>
			cprintf("Waiting for packets...\n");
  800392:	83 ec 0c             	sub    $0xc,%esp
  800395:	68 e5 2d 80 00       	push   $0x802de5
  80039a:	e8 b9 05 00 00       	call   800958 <cprintf>
  80039f:	83 c4 10             	add    $0x10,%esp
  8003a2:	eb 8f                	jmp    800333 <umain+0x300>

008003a4 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	57                   	push   %edi
  8003a8:	56                   	push   %esi
  8003a9:	53                   	push   %ebx
  8003aa:	83 ec 1c             	sub    $0x1c,%esp
  8003ad:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  8003b0:	e8 6a 11 00 00       	call   80151f <sys_time_msec>
  8003b5:	03 45 0c             	add    0xc(%ebp),%eax
  8003b8:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  8003ba:	c7 05 00 40 80 00 25 	movl   $0x802e25,0x804000
  8003c1:	2e 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003c4:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8003c7:	eb 33                	jmp    8003fc <timer+0x58>
		if (r < 0)
  8003c9:	85 c0                	test   %eax,%eax
  8003cb:	78 43                	js     800410 <timer+0x6c>
		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8003cd:	6a 00                	push   $0x0
  8003cf:	6a 00                	push   $0x0
  8003d1:	6a 0c                	push   $0xc
  8003d3:	56                   	push   %esi
  8003d4:	e8 98 14 00 00       	call   801871 <ipc_send>
  8003d9:	83 c4 10             	add    $0x10,%esp
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003dc:	83 ec 04             	sub    $0x4,%esp
  8003df:	6a 00                	push   $0x0
  8003e1:	6a 00                	push   $0x0
  8003e3:	57                   	push   %edi
  8003e4:	e8 18 14 00 00       	call   801801 <ipc_recv>
  8003e9:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  8003eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ee:	83 c4 10             	add    $0x10,%esp
  8003f1:	39 f0                	cmp    %esi,%eax
  8003f3:	75 2d                	jne    800422 <timer+0x7e>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
				continue;
			}

			stop = sys_time_msec() + to;
  8003f5:	e8 25 11 00 00       	call   80151f <sys_time_msec>
  8003fa:	01 c3                	add    %eax,%ebx
		while((r = sys_time_msec()) < stop && r >= 0) {
  8003fc:	e8 1e 11 00 00       	call   80151f <sys_time_msec>
  800401:	85 c0                	test   %eax,%eax
  800403:	78 c4                	js     8003c9 <timer+0x25>
  800405:	39 d8                	cmp    %ebx,%eax
  800407:	73 c0                	jae    8003c9 <timer+0x25>
			sys_yield();
  800409:	e8 01 0f 00 00       	call   80130f <sys_yield>
  80040e:	eb ec                	jmp    8003fc <timer+0x58>
			panic("sys_time_msec: %e", r);
  800410:	50                   	push   %eax
  800411:	68 2e 2e 80 00       	push   $0x802e2e
  800416:	6a 0f                	push   $0xf
  800418:	68 40 2e 80 00       	push   $0x802e40
  80041d:	e8 5b 04 00 00       	call   80087d <_panic>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  800422:	83 ec 08             	sub    $0x8,%esp
  800425:	50                   	push   %eax
  800426:	68 4c 2e 80 00       	push   $0x802e4c
  80042b:	e8 28 05 00 00       	call   800958 <cprintf>
				continue;
  800430:	83 c4 10             	add    $0x10,%esp
  800433:	eb a7                	jmp    8003dc <timer+0x38>

00800435 <sleep>:

extern union Nsipc nsipcbuf;

void
sleep(int msec)
{
  800435:	55                   	push   %ebp
  800436:	89 e5                	mov    %esp,%ebp
  800438:	56                   	push   %esi
  800439:	53                   	push   %ebx
  80043a:	8b 75 08             	mov    0x8(%ebp),%esi
    int now = sys_time_msec();
  80043d:	e8 dd 10 00 00       	call   80151f <sys_time_msec>
  800442:	89 c3                	mov    %eax,%ebx

    while (msec > sys_time_msec()-now){
  800444:	eb 05                	jmp    80044b <sleep+0x16>
    	sys_yield();
  800446:	e8 c4 0e 00 00       	call   80130f <sys_yield>
    while (msec > sys_time_msec()-now){
  80044b:	e8 cf 10 00 00       	call   80151f <sys_time_msec>
  800450:	29 d8                	sub    %ebx,%eax
  800452:	39 f0                	cmp    %esi,%eax
  800454:	72 f0                	jb     800446 <sleep+0x11>
    }    
}
  800456:	5b                   	pop    %ebx
  800457:	5e                   	pop    %esi
  800458:	5d                   	pop    %ebp
  800459:	c3                   	ret    

0080045a <input>:

void
input(envid_t ns_envid)
{
  80045a:	55                   	push   %ebp
  80045b:	89 e5                	mov    %esp,%ebp
  80045d:	57                   	push   %edi
  80045e:	56                   	push   %esi
  80045f:	53                   	push   %ebx
  800460:	81 ec 1c 08 00 00    	sub    $0x81c,%esp
  800466:	8b 7d 08             	mov    0x8(%ebp),%edi
	binaryname = "ns_input";
  800469:	c7 05 00 40 80 00 87 	movl   $0x802e87,0x804000
  800470:	2e 80 00 
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
	size_t len;
	char rev_buf[RX_PACKET_SIZE];
	while(1){
		while ( sys_e1000_recv(rev_buf, &len)  < 0) {
  800473:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800476:	8d 9d e4 f7 ff ff    	lea    -0x81c(%ebp),%ebx
  80047c:	eb 05                	jmp    800483 <input+0x29>
			sys_yield();//没东西读，就阻塞，切换别的环境。    
  80047e:	e8 8c 0e 00 00       	call   80130f <sys_yield>
		while ( sys_e1000_recv(rev_buf, &len)  < 0) {
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	56                   	push   %esi
  800487:	53                   	push   %ebx
  800488:	e8 d2 10 00 00       	call   80155f <sys_e1000_recv>
  80048d:	83 c4 10             	add    $0x10,%esp
  800490:	85 c0                	test   %eax,%eax
  800492:	78 ea                	js     80047e <input+0x24>
		}
		memcpy(nsipcbuf.pkt.jp_data, rev_buf, len);
  800494:	83 ec 04             	sub    $0x4,%esp
  800497:	ff 75 e4             	push   -0x1c(%ebp)
  80049a:	53                   	push   %ebx
  80049b:	68 04 80 80 00       	push   $0x808004
  8004a0:	e8 85 0c 00 00       	call   80112a <memcpy>
		nsipcbuf.pkt.jp_len = len;
  8004a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004a8:	a3 00 80 80 00       	mov    %eax,0x808000
		
		ipc_send(ns_envid, NSREQ_INPUT, &nsipcbuf, PTE_P|PTE_U);
  8004ad:	6a 05                	push   $0x5
  8004af:	68 00 80 80 00       	push   $0x808000
  8004b4:	6a 0a                	push   $0xa
  8004b6:	57                   	push   %edi
  8004b7:	e8 b5 13 00 00       	call   801871 <ipc_send>
		
		sleep(30);//停留一段时间，不停留的话，测试不会通过，会丢包。
  8004bc:	83 c4 14             	add    $0x14,%esp
  8004bf:	6a 1e                	push   $0x1e
  8004c1:	e8 6f ff ff ff       	call   800435 <sleep>
		while ( sys_e1000_recv(rev_buf, &len)  < 0) {
  8004c6:	83 c4 10             	add    $0x10,%esp
  8004c9:	eb b8                	jmp    800483 <input+0x29>

008004cb <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  8004cb:	55                   	push   %ebp
  8004cc:	89 e5                	mov    %esp,%ebp
  8004ce:	56                   	push   %esi
  8004cf:	53                   	push   %ebx
  8004d0:	83 ec 10             	sub    $0x10,%esp
  8004d3:	8b 75 08             	mov    0x8(%ebp),%esi
	binaryname = "ns_output";
  8004d6:	c7 05 00 40 80 00 90 	movl   $0x802e90,0x804000
  8004dd:	2e 80 00 
	// 	- read a packet from the network server
	//	- send the packet to the device driver
	int r, perm;
	envid_t from_env;
	while(1){
		r=ipc_recv( &from_env , &nsipcbuf, NULL);
  8004e0:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8004e3:	eb 1f                	jmp    800504 <output+0x39>
		if(r!=NSREQ_OUTPUT || from_env!=ns_envid){
			continue;
		} 
		while( sys_e1000_try_send( nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len ) < 0 ){
			sys_yield();//发送失败，切换进程，让出控制器。
  8004e5:	e8 25 0e 00 00       	call   80130f <sys_yield>
		while( sys_e1000_try_send( nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len ) < 0 ){
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	ff 35 00 80 80 00    	push   0x808000
  8004f3:	68 04 80 80 00       	push   $0x808004
  8004f8:	e8 41 10 00 00       	call   80153e <sys_e1000_try_send>
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	85 c0                	test   %eax,%eax
  800502:	78 e1                	js     8004e5 <output+0x1a>
		r=ipc_recv( &from_env , &nsipcbuf, NULL);
  800504:	83 ec 04             	sub    $0x4,%esp
  800507:	6a 00                	push   $0x0
  800509:	68 00 80 80 00       	push   $0x808000
  80050e:	53                   	push   %ebx
  80050f:	e8 ed 12 00 00       	call   801801 <ipc_recv>
		if(r!=NSREQ_OUTPUT || from_env!=ns_envid){
  800514:	83 c4 10             	add    $0x10,%esp
  800517:	83 f8 0b             	cmp    $0xb,%eax
  80051a:	75 e8                	jne    800504 <output+0x39>
  80051c:	39 75 f4             	cmp    %esi,-0xc(%ebp)
  80051f:	75 e3                	jne    800504 <output+0x39>
  800521:	eb c7                	jmp    8004ea <output+0x1f>

00800523 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  800523:	55                   	push   %ebp
  800524:	89 e5                	mov    %esp,%ebp
  800526:	57                   	push   %edi
  800527:	56                   	push   %esi
  800528:	53                   	push   %ebx
  800529:	83 ec 1c             	sub    $0x1c,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  80052c:	8b 45 08             	mov    0x8(%ebp),%eax
  80052f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800532:	c6 45 db 00          	movb   $0x0,-0x25(%ebp)
  ap = (u8_t *)&s_addr;
  800536:	8d 75 f0             	lea    -0x10(%ebp),%esi
  rp = str;
  800539:	c7 45 dc 08 50 80 00 	movl   $0x805008,-0x24(%ebp)
  800540:	eb 32                	jmp    800574 <inet_ntoa+0x51>
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
  800542:	0f b6 c8             	movzbl %al,%ecx
  800545:	0f b6 4c 0d ed       	movzbl -0x13(%ebp,%ecx,1),%ecx
  80054a:	88 0a                	mov    %cl,(%edx)
  80054c:	83 c2 01             	add    $0x1,%edx
    while(i--)
  80054f:	83 e8 01             	sub    $0x1,%eax
  800552:	3c ff                	cmp    $0xff,%al
  800554:	75 ec                	jne    800542 <inet_ntoa+0x1f>
  800556:	0f b6 db             	movzbl %bl,%ebx
  800559:	03 5d dc             	add    -0x24(%ebp),%ebx
    *rp++ = '.';
  80055c:	8d 43 01             	lea    0x1(%ebx),%eax
  80055f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800562:	c6 03 2e             	movb   $0x2e,(%ebx)
  800565:	83 c6 01             	add    $0x1,%esi
  for(n = 0; n < 4; n++) {
  800568:	80 45 db 01          	addb   $0x1,-0x25(%ebp)
  80056c:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  800570:	3c 04                	cmp    $0x4,%al
  800572:	74 41                	je     8005b5 <inet_ntoa+0x92>
  rp = str;
  800574:	bb 00 00 00 00       	mov    $0x0,%ebx
      rem = *ap % (u8_t)10;
  800579:	0f b6 16             	movzbl (%esi),%edx
      *ap /= (u8_t)10;
  80057c:	b8 cd ff ff ff       	mov    $0xffffffcd,%eax
  800581:	f6 e2                	mul    %dl
  800583:	66 c1 e8 0b          	shr    $0xb,%ax
  800587:	88 06                	mov    %al,(%esi)
  800589:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  80058b:	83 c3 01             	add    $0x1,%ebx
  80058e:	0f b6 f9             	movzbl %cl,%edi
  800591:	89 7d e0             	mov    %edi,-0x20(%ebp)
      rem = *ap % (u8_t)10;
  800594:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800597:	01 c0                	add    %eax,%eax
  800599:	89 d1                	mov    %edx,%ecx
  80059b:	29 c1                	sub    %eax,%ecx
  80059d:	89 cf                	mov    %ecx,%edi
      inv[i++] = '0' + rem;
  80059f:	8d 47 30             	lea    0x30(%edi),%eax
  8005a2:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005a5:	88 44 3d ed          	mov    %al,-0x13(%ebp,%edi,1)
    } while(*ap);
  8005a9:	80 fa 09             	cmp    $0x9,%dl
  8005ac:	77 cb                	ja     800579 <inet_ntoa+0x56>
  8005ae:	8b 55 dc             	mov    -0x24(%ebp),%edx
      inv[i++] = '0' + rem;
  8005b1:	89 d8                	mov    %ebx,%eax
  8005b3:	eb 9a                	jmp    80054f <inet_ntoa+0x2c>
    ap++;
  }
  *--rp = 0;
  8005b5:	c6 03 00             	movb   $0x0,(%ebx)
  return str;
}
  8005b8:	b8 08 50 80 00       	mov    $0x805008,%eax
  8005bd:	83 c4 1c             	add    $0x1c,%esp
  8005c0:	5b                   	pop    %ebx
  8005c1:	5e                   	pop    %esi
  8005c2:	5f                   	pop    %edi
  8005c3:	5d                   	pop    %ebp
  8005c4:	c3                   	ret    

008005c5 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8005c5:	55                   	push   %ebp
  8005c6:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8005c8:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8005cc:	66 c1 c0 08          	rol    $0x8,%ax
}
  8005d0:	5d                   	pop    %ebp
  8005d1:	c3                   	ret    

008005d2 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  8005d2:	55                   	push   %ebp
  8005d3:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8005d5:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8005d9:	66 c1 c0 08          	rol    $0x8,%ax
  return htons(n);
}
  8005dd:	5d                   	pop    %ebp
  8005de:	c3                   	ret    

008005df <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  8005df:	55                   	push   %ebp
  8005e0:	89 e5                	mov    %esp,%ebp
  8005e2:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  8005e5:	89 d0                	mov    %edx,%eax
  8005e7:	c1 e0 18             	shl    $0x18,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  8005ea:	89 d1                	mov    %edx,%ecx
  8005ec:	c1 e9 18             	shr    $0x18,%ecx
    ((n & 0xff0000UL) >> 8) |
  8005ef:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  8005f1:	89 d1                	mov    %edx,%ecx
  8005f3:	c1 e1 08             	shl    $0x8,%ecx
  8005f6:	81 e1 00 00 ff 00    	and    $0xff0000,%ecx
    ((n & 0xff0000UL) >> 8) |
  8005fc:	09 c8                	or     %ecx,%eax
  8005fe:	c1 ea 08             	shr    $0x8,%edx
  800601:	81 e2 00 ff 00 00    	and    $0xff00,%edx
  800607:	09 d0                	or     %edx,%eax
}
  800609:	5d                   	pop    %ebp
  80060a:	c3                   	ret    

0080060b <inet_aton>:
{
  80060b:	55                   	push   %ebp
  80060c:	89 e5                	mov    %esp,%ebp
  80060e:	57                   	push   %edi
  80060f:	56                   	push   %esi
  800610:	53                   	push   %ebx
  800611:	83 ec 2c             	sub    $0x2c,%esp
  800614:	8b 55 08             	mov    0x8(%ebp),%edx
  c = *cp;
  800617:	0f be 02             	movsbl (%edx),%eax
  u32_t *pp = parts;
  80061a:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  80061d:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800620:	e9 a6 00 00 00       	jmp    8006cb <inet_aton+0xc0>
      c = *++cp;
  800625:	0f b6 42 01          	movzbl 0x1(%edx),%eax
      if (c == 'x' || c == 'X') {
  800629:	89 c1                	mov    %eax,%ecx
  80062b:	83 e1 df             	and    $0xffffffdf,%ecx
  80062e:	80 f9 58             	cmp    $0x58,%cl
  800631:	74 10                	je     800643 <inet_aton+0x38>
      c = *++cp;
  800633:	83 c2 01             	add    $0x1,%edx
  800636:	0f be c0             	movsbl %al,%eax
        base = 8;
  800639:	be 08 00 00 00       	mov    $0x8,%esi
  80063e:	e9 a2 00 00 00       	jmp    8006e5 <inet_aton+0xda>
        c = *++cp;
  800643:	0f be 42 02          	movsbl 0x2(%edx),%eax
  800647:	8d 52 02             	lea    0x2(%edx),%edx
        base = 16;
  80064a:	be 10 00 00 00       	mov    $0x10,%esi
  80064f:	e9 91 00 00 00       	jmp    8006e5 <inet_aton+0xda>
        val = (val * base) + (int)(c - '0');
  800654:	0f af fe             	imul   %esi,%edi
  800657:	8d 7c 38 d0          	lea    -0x30(%eax,%edi,1),%edi
        c = *++cp;
  80065b:	0f be 02             	movsbl (%edx),%eax
  80065e:	83 c2 01             	add    $0x1,%edx
  800661:	8d 5a ff             	lea    -0x1(%edx),%ebx
      if (isdigit(c)) {
  800664:	88 45 d7             	mov    %al,-0x29(%ebp)
  800667:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80066a:	80 f9 09             	cmp    $0x9,%cl
  80066d:	76 e5                	jbe    800654 <inet_aton+0x49>
      } else if (base == 16 && isxdigit(c)) {
  80066f:	83 fe 10             	cmp    $0x10,%esi
  800672:	75 34                	jne    8006a8 <inet_aton+0x9d>
  800674:	0f b6 4d d7          	movzbl -0x29(%ebp),%ecx
  800678:	83 e9 61             	sub    $0x61,%ecx
  80067b:	88 4d d6             	mov    %cl,-0x2a(%ebp)
  80067e:	0f b6 4d d7          	movzbl -0x29(%ebp),%ecx
  800682:	83 e1 df             	and    $0xffffffdf,%ecx
  800685:	83 e9 41             	sub    $0x41,%ecx
  800688:	80 f9 05             	cmp    $0x5,%cl
  80068b:	77 1b                	ja     8006a8 <inet_aton+0x9d>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  80068d:	c1 e7 04             	shl    $0x4,%edi
  800690:	83 c0 0a             	add    $0xa,%eax
  800693:	80 7d d6 1a          	cmpb   $0x1a,-0x2a(%ebp)
  800697:	19 c9                	sbb    %ecx,%ecx
  800699:	83 e1 20             	and    $0x20,%ecx
  80069c:	83 c1 41             	add    $0x41,%ecx
  80069f:	29 c8                	sub    %ecx,%eax
  8006a1:	09 c7                	or     %eax,%edi
        c = *++cp;
  8006a3:	0f be 02             	movsbl (%edx),%eax
  8006a6:	eb b6                	jmp    80065e <inet_aton+0x53>
    if (c == '.') {
  8006a8:	83 f8 2e             	cmp    $0x2e,%eax
  8006ab:	75 45                	jne    8006f2 <inet_aton+0xe7>
      if (pp >= parts + 3)
  8006ad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8006b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b3:	39 c6                	cmp    %eax,%esi
  8006b5:	0f 84 1b 01 00 00    	je     8007d6 <inet_aton+0x1cb>
      *pp++ = val;
  8006bb:	83 c6 04             	add    $0x4,%esi
  8006be:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006c1:	89 7e fc             	mov    %edi,-0x4(%esi)
      c = *++cp;
  8006c4:	8d 53 01             	lea    0x1(%ebx),%edx
  8006c7:	0f be 43 01          	movsbl 0x1(%ebx),%eax
    if (!isdigit(c))
  8006cb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8006ce:	80 f9 09             	cmp    $0x9,%cl
  8006d1:	0f 87 f8 00 00 00    	ja     8007cf <inet_aton+0x1c4>
    base = 10;
  8006d7:	be 0a 00 00 00       	mov    $0xa,%esi
    if (c == '0') {
  8006dc:	83 f8 30             	cmp    $0x30,%eax
  8006df:	0f 84 40 ff ff ff    	je     800625 <inet_aton+0x1a>
  8006e5:	83 c2 01             	add    $0x1,%edx
        base = 8;
  8006e8:	bf 00 00 00 00       	mov    $0x0,%edi
  8006ed:	e9 6f ff ff ff       	jmp    800661 <inet_aton+0x56>
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8006f2:	0f b6 75 d7          	movzbl -0x29(%ebp),%esi
  8006f6:	85 c0                	test   %eax,%eax
  8006f8:	74 29                	je     800723 <inet_aton+0x118>
    return (0);
  8006fa:	ba 00 00 00 00       	mov    $0x0,%edx
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8006ff:	89 f3                	mov    %esi,%ebx
  800701:	80 fb 1f             	cmp    $0x1f,%bl
  800704:	0f 86 d1 00 00 00    	jbe    8007db <inet_aton+0x1d0>
  80070a:	84 c0                	test   %al,%al
  80070c:	0f 88 c9 00 00 00    	js     8007db <inet_aton+0x1d0>
  800712:	83 f8 20             	cmp    $0x20,%eax
  800715:	74 0c                	je     800723 <inet_aton+0x118>
  800717:	83 e8 09             	sub    $0x9,%eax
  80071a:	83 f8 04             	cmp    $0x4,%eax
  80071d:	0f 87 b8 00 00 00    	ja     8007db <inet_aton+0x1d0>
  n = pp - parts + 1;
  800723:	8d 55 d8             	lea    -0x28(%ebp),%edx
  800726:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800729:	29 d0                	sub    %edx,%eax
  80072b:	c1 f8 02             	sar    $0x2,%eax
  80072e:	8d 50 01             	lea    0x1(%eax),%edx
  switch (n) {
  800731:	83 f8 02             	cmp    $0x2,%eax
  800734:	74 7a                	je     8007b0 <inet_aton+0x1a5>
  800736:	83 fa 03             	cmp    $0x3,%edx
  800739:	7f 49                	jg     800784 <inet_aton+0x179>
  80073b:	85 d2                	test   %edx,%edx
  80073d:	0f 84 98 00 00 00    	je     8007db <inet_aton+0x1d0>
  800743:	83 fa 02             	cmp    $0x2,%edx
  800746:	75 19                	jne    800761 <inet_aton+0x156>
      return (0);
  800748:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xffffffUL)
  80074d:	81 ff ff ff ff 00    	cmp    $0xffffff,%edi
  800753:	0f 87 82 00 00 00    	ja     8007db <inet_aton+0x1d0>
    val |= parts[0] << 24;
  800759:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80075c:	c1 e0 18             	shl    $0x18,%eax
  80075f:	09 c7                	or     %eax,%edi
  return (1);
  800761:	ba 01 00 00 00       	mov    $0x1,%edx
  if (addr)
  800766:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80076a:	74 6f                	je     8007db <inet_aton+0x1d0>
    addr->s_addr = htonl(val);
  80076c:	83 ec 0c             	sub    $0xc,%esp
  80076f:	57                   	push   %edi
  800770:	e8 6a fe ff ff       	call   8005df <htonl>
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80077b:	89 03                	mov    %eax,(%ebx)
  return (1);
  80077d:	ba 01 00 00 00       	mov    $0x1,%edx
  800782:	eb 57                	jmp    8007db <inet_aton+0x1d0>
  switch (n) {
  800784:	83 fa 04             	cmp    $0x4,%edx
  800787:	75 d8                	jne    800761 <inet_aton+0x156>
      return (0);
  800789:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xff)
  80078e:	81 ff ff 00 00 00    	cmp    $0xff,%edi
  800794:	77 45                	ja     8007db <inet_aton+0x1d0>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  800796:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800799:	c1 e0 18             	shl    $0x18,%eax
  80079c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80079f:	c1 e2 10             	shl    $0x10,%edx
  8007a2:	09 d0                	or     %edx,%eax
  8007a4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007a7:	c1 e2 08             	shl    $0x8,%edx
  8007aa:	09 d0                	or     %edx,%eax
  8007ac:	09 c7                	or     %eax,%edi
    break;
  8007ae:	eb b1                	jmp    800761 <inet_aton+0x156>
      return (0);
  8007b0:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xffff)
  8007b5:	81 ff ff ff 00 00    	cmp    $0xffff,%edi
  8007bb:	77 1e                	ja     8007db <inet_aton+0x1d0>
    val |= (parts[0] << 24) | (parts[1] << 16);
  8007bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007c0:	c1 e0 18             	shl    $0x18,%eax
  8007c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007c6:	c1 e2 10             	shl    $0x10,%edx
  8007c9:	09 d0                	or     %edx,%eax
  8007cb:	09 c7                	or     %eax,%edi
    break;
  8007cd:	eb 92                	jmp    800761 <inet_aton+0x156>
      return (0);
  8007cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d4:	eb 05                	jmp    8007db <inet_aton+0x1d0>
        return (0);
  8007d6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007db:	89 d0                	mov    %edx,%eax
  8007dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007e0:	5b                   	pop    %ebx
  8007e1:	5e                   	pop    %esi
  8007e2:	5f                   	pop    %edi
  8007e3:	5d                   	pop    %ebp
  8007e4:	c3                   	ret    

008007e5 <inet_addr>:
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	83 ec 20             	sub    $0x20,%esp
  if (inet_aton(cp, &val)) {
  8007eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007ee:	50                   	push   %eax
  8007ef:	ff 75 08             	push   0x8(%ebp)
  8007f2:	e8 14 fe ff ff       	call   80060b <inet_aton>
  8007f7:	83 c4 10             	add    $0x10,%esp
    return (val.s_addr);
  8007fa:	85 c0                	test   %eax,%eax
  8007fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800801:	0f 45 45 f4          	cmovne -0xc(%ebp),%eax
}
  800805:	c9                   	leave  
  800806:	c3                   	ret    

00800807 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	83 ec 14             	sub    $0x14,%esp
  return htonl(n);
  80080d:	ff 75 08             	push   0x8(%ebp)
  800810:	e8 ca fd ff ff       	call   8005df <htonl>
  800815:	83 c4 10             	add    $0x10,%esp
}
  800818:	c9                   	leave  
  800819:	c3                   	ret    

0080081a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800822:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800825:	e8 c6 0a 00 00       	call   8012f0 <sys_getenvid>
  80082a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80082f:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800835:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80083a:	a3 18 50 80 00       	mov    %eax,0x805018

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80083f:	85 db                	test   %ebx,%ebx
  800841:	7e 07                	jle    80084a <libmain+0x30>
		binaryname = argv[0];
  800843:	8b 06                	mov    (%esi),%eax
  800845:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  80084a:	83 ec 08             	sub    $0x8,%esp
  80084d:	56                   	push   %esi
  80084e:	53                   	push   %ebx
  80084f:	e8 df f7 ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800854:	e8 0a 00 00 00       	call   800863 <exit>
}
  800859:	83 c4 10             	add    $0x10,%esp
  80085c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80085f:	5b                   	pop    %ebx
  800860:	5e                   	pop    %esi
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800869:	e8 67 12 00 00       	call   801ad5 <close_all>
	sys_env_destroy(0);
  80086e:	83 ec 0c             	sub    $0xc,%esp
  800871:	6a 00                	push   $0x0
  800873:	e8 37 0a 00 00       	call   8012af <sys_env_destroy>
}
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	c9                   	leave  
  80087c:	c3                   	ret    

0080087d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	56                   	push   %esi
  800881:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800882:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800885:	8b 35 00 40 80 00    	mov    0x804000,%esi
  80088b:	e8 60 0a 00 00       	call   8012f0 <sys_getenvid>
  800890:	83 ec 0c             	sub    $0xc,%esp
  800893:	ff 75 0c             	push   0xc(%ebp)
  800896:	ff 75 08             	push   0x8(%ebp)
  800899:	56                   	push   %esi
  80089a:	50                   	push   %eax
  80089b:	68 a4 2e 80 00       	push   $0x802ea4
  8008a0:	e8 b3 00 00 00       	call   800958 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8008a5:	83 c4 18             	add    $0x18,%esp
  8008a8:	53                   	push   %ebx
  8008a9:	ff 75 10             	push   0x10(%ebp)
  8008ac:	e8 56 00 00 00       	call   800907 <vcprintf>
	cprintf("\n");
  8008b1:	c7 04 24 fb 2d 80 00 	movl   $0x802dfb,(%esp)
  8008b8:	e8 9b 00 00 00       	call   800958 <cprintf>
  8008bd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8008c0:	cc                   	int3   
  8008c1:	eb fd                	jmp    8008c0 <_panic+0x43>

008008c3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	53                   	push   %ebx
  8008c7:	83 ec 04             	sub    $0x4,%esp
  8008ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8008cd:	8b 13                	mov    (%ebx),%edx
  8008cf:	8d 42 01             	lea    0x1(%edx),%eax
  8008d2:	89 03                	mov    %eax,(%ebx)
  8008d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8008db:	3d ff 00 00 00       	cmp    $0xff,%eax
  8008e0:	74 09                	je     8008eb <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8008e2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8008e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8008eb:	83 ec 08             	sub    $0x8,%esp
  8008ee:	68 ff 00 00 00       	push   $0xff
  8008f3:	8d 43 08             	lea    0x8(%ebx),%eax
  8008f6:	50                   	push   %eax
  8008f7:	e8 76 09 00 00       	call   801272 <sys_cputs>
		b->idx = 0;
  8008fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800902:	83 c4 10             	add    $0x10,%esp
  800905:	eb db                	jmp    8008e2 <putch+0x1f>

00800907 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800910:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800917:	00 00 00 
	b.cnt = 0;
  80091a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800921:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800924:	ff 75 0c             	push   0xc(%ebp)
  800927:	ff 75 08             	push   0x8(%ebp)
  80092a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800930:	50                   	push   %eax
  800931:	68 c3 08 80 00       	push   $0x8008c3
  800936:	e8 14 01 00 00       	call   800a4f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80093b:	83 c4 08             	add    $0x8,%esp
  80093e:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800944:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80094a:	50                   	push   %eax
  80094b:	e8 22 09 00 00       	call   801272 <sys_cputs>

	return b.cnt;
}
  800950:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800956:	c9                   	leave  
  800957:	c3                   	ret    

00800958 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80095e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800961:	50                   	push   %eax
  800962:	ff 75 08             	push   0x8(%ebp)
  800965:	e8 9d ff ff ff       	call   800907 <vcprintf>
	va_end(ap);

	return cnt;
}
  80096a:	c9                   	leave  
  80096b:	c3                   	ret    

0080096c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	57                   	push   %edi
  800970:	56                   	push   %esi
  800971:	53                   	push   %ebx
  800972:	83 ec 1c             	sub    $0x1c,%esp
  800975:	89 c7                	mov    %eax,%edi
  800977:	89 d6                	mov    %edx,%esi
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097f:	89 d1                	mov    %edx,%ecx
  800981:	89 c2                	mov    %eax,%edx
  800983:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800986:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800989:	8b 45 10             	mov    0x10(%ebp),%eax
  80098c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80098f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800992:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800999:	39 c2                	cmp    %eax,%edx
  80099b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80099e:	72 3e                	jb     8009de <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8009a0:	83 ec 0c             	sub    $0xc,%esp
  8009a3:	ff 75 18             	push   0x18(%ebp)
  8009a6:	83 eb 01             	sub    $0x1,%ebx
  8009a9:	53                   	push   %ebx
  8009aa:	50                   	push   %eax
  8009ab:	83 ec 08             	sub    $0x8,%esp
  8009ae:	ff 75 e4             	push   -0x1c(%ebp)
  8009b1:	ff 75 e0             	push   -0x20(%ebp)
  8009b4:	ff 75 dc             	push   -0x24(%ebp)
  8009b7:	ff 75 d8             	push   -0x28(%ebp)
  8009ba:	e8 31 21 00 00       	call   802af0 <__udivdi3>
  8009bf:	83 c4 18             	add    $0x18,%esp
  8009c2:	52                   	push   %edx
  8009c3:	50                   	push   %eax
  8009c4:	89 f2                	mov    %esi,%edx
  8009c6:	89 f8                	mov    %edi,%eax
  8009c8:	e8 9f ff ff ff       	call   80096c <printnum>
  8009cd:	83 c4 20             	add    $0x20,%esp
  8009d0:	eb 13                	jmp    8009e5 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8009d2:	83 ec 08             	sub    $0x8,%esp
  8009d5:	56                   	push   %esi
  8009d6:	ff 75 18             	push   0x18(%ebp)
  8009d9:	ff d7                	call   *%edi
  8009db:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8009de:	83 eb 01             	sub    $0x1,%ebx
  8009e1:	85 db                	test   %ebx,%ebx
  8009e3:	7f ed                	jg     8009d2 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8009e5:	83 ec 08             	sub    $0x8,%esp
  8009e8:	56                   	push   %esi
  8009e9:	83 ec 04             	sub    $0x4,%esp
  8009ec:	ff 75 e4             	push   -0x1c(%ebp)
  8009ef:	ff 75 e0             	push   -0x20(%ebp)
  8009f2:	ff 75 dc             	push   -0x24(%ebp)
  8009f5:	ff 75 d8             	push   -0x28(%ebp)
  8009f8:	e8 13 22 00 00       	call   802c10 <__umoddi3>
  8009fd:	83 c4 14             	add    $0x14,%esp
  800a00:	0f be 80 c7 2e 80 00 	movsbl 0x802ec7(%eax),%eax
  800a07:	50                   	push   %eax
  800a08:	ff d7                	call   *%edi
}
  800a0a:	83 c4 10             	add    $0x10,%esp
  800a0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a10:	5b                   	pop    %ebx
  800a11:	5e                   	pop    %esi
  800a12:	5f                   	pop    %edi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800a1b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800a1f:	8b 10                	mov    (%eax),%edx
  800a21:	3b 50 04             	cmp    0x4(%eax),%edx
  800a24:	73 0a                	jae    800a30 <sprintputch+0x1b>
		*b->buf++ = ch;
  800a26:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a29:	89 08                	mov    %ecx,(%eax)
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	88 02                	mov    %al,(%edx)
}
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <printfmt>:
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800a38:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800a3b:	50                   	push   %eax
  800a3c:	ff 75 10             	push   0x10(%ebp)
  800a3f:	ff 75 0c             	push   0xc(%ebp)
  800a42:	ff 75 08             	push   0x8(%ebp)
  800a45:	e8 05 00 00 00       	call   800a4f <vprintfmt>
}
  800a4a:	83 c4 10             	add    $0x10,%esp
  800a4d:	c9                   	leave  
  800a4e:	c3                   	ret    

00800a4f <vprintfmt>:
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	57                   	push   %edi
  800a53:	56                   	push   %esi
  800a54:	53                   	push   %ebx
  800a55:	83 ec 3c             	sub    $0x3c,%esp
  800a58:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a5e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a61:	eb 0a                	jmp    800a6d <vprintfmt+0x1e>
			putch(ch, putdat);
  800a63:	83 ec 08             	sub    $0x8,%esp
  800a66:	53                   	push   %ebx
  800a67:	50                   	push   %eax
  800a68:	ff d6                	call   *%esi
  800a6a:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a6d:	83 c7 01             	add    $0x1,%edi
  800a70:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a74:	83 f8 25             	cmp    $0x25,%eax
  800a77:	74 0c                	je     800a85 <vprintfmt+0x36>
			if (ch == '\0')
  800a79:	85 c0                	test   %eax,%eax
  800a7b:	75 e6                	jne    800a63 <vprintfmt+0x14>
}
  800a7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5f                   	pop    %edi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    
		padc = ' ';
  800a85:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800a89:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800a90:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800a97:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800a9e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800aa3:	8d 47 01             	lea    0x1(%edi),%eax
  800aa6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800aa9:	0f b6 17             	movzbl (%edi),%edx
  800aac:	8d 42 dd             	lea    -0x23(%edx),%eax
  800aaf:	3c 55                	cmp    $0x55,%al
  800ab1:	0f 87 bb 03 00 00    	ja     800e72 <vprintfmt+0x423>
  800ab7:	0f b6 c0             	movzbl %al,%eax
  800aba:	ff 24 85 00 30 80 00 	jmp    *0x803000(,%eax,4)
  800ac1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800ac4:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800ac8:	eb d9                	jmp    800aa3 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800aca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800acd:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800ad1:	eb d0                	jmp    800aa3 <vprintfmt+0x54>
  800ad3:	0f b6 d2             	movzbl %dl,%edx
  800ad6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ade:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800ae1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800ae4:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800ae8:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800aeb:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800aee:	83 f9 09             	cmp    $0x9,%ecx
  800af1:	77 55                	ja     800b48 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800af3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800af6:	eb e9                	jmp    800ae1 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800af8:	8b 45 14             	mov    0x14(%ebp),%eax
  800afb:	8b 00                	mov    (%eax),%eax
  800afd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b00:	8b 45 14             	mov    0x14(%ebp),%eax
  800b03:	8d 40 04             	lea    0x4(%eax),%eax
  800b06:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800b09:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800b0c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b10:	79 91                	jns    800aa3 <vprintfmt+0x54>
				width = precision, precision = -1;
  800b12:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b15:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b18:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800b1f:	eb 82                	jmp    800aa3 <vprintfmt+0x54>
  800b21:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800b24:	85 d2                	test   %edx,%edx
  800b26:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2b:	0f 49 c2             	cmovns %edx,%eax
  800b2e:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800b31:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800b34:	e9 6a ff ff ff       	jmp    800aa3 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800b39:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800b3c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800b43:	e9 5b ff ff ff       	jmp    800aa3 <vprintfmt+0x54>
  800b48:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800b4b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b4e:	eb bc                	jmp    800b0c <vprintfmt+0xbd>
			lflag++;
  800b50:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800b53:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800b56:	e9 48 ff ff ff       	jmp    800aa3 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800b5b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5e:	8d 78 04             	lea    0x4(%eax),%edi
  800b61:	83 ec 08             	sub    $0x8,%esp
  800b64:	53                   	push   %ebx
  800b65:	ff 30                	push   (%eax)
  800b67:	ff d6                	call   *%esi
			break;
  800b69:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800b6c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800b6f:	e9 9d 02 00 00       	jmp    800e11 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800b74:	8b 45 14             	mov    0x14(%ebp),%eax
  800b77:	8d 78 04             	lea    0x4(%eax),%edi
  800b7a:	8b 10                	mov    (%eax),%edx
  800b7c:	89 d0                	mov    %edx,%eax
  800b7e:	f7 d8                	neg    %eax
  800b80:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b83:	83 f8 0f             	cmp    $0xf,%eax
  800b86:	7f 23                	jg     800bab <vprintfmt+0x15c>
  800b88:	8b 14 85 60 31 80 00 	mov    0x803160(,%eax,4),%edx
  800b8f:	85 d2                	test   %edx,%edx
  800b91:	74 18                	je     800bab <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800b93:	52                   	push   %edx
  800b94:	68 81 33 80 00       	push   $0x803381
  800b99:	53                   	push   %ebx
  800b9a:	56                   	push   %esi
  800b9b:	e8 92 fe ff ff       	call   800a32 <printfmt>
  800ba0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800ba3:	89 7d 14             	mov    %edi,0x14(%ebp)
  800ba6:	e9 66 02 00 00       	jmp    800e11 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800bab:	50                   	push   %eax
  800bac:	68 df 2e 80 00       	push   $0x802edf
  800bb1:	53                   	push   %ebx
  800bb2:	56                   	push   %esi
  800bb3:	e8 7a fe ff ff       	call   800a32 <printfmt>
  800bb8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800bbb:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800bbe:	e9 4e 02 00 00       	jmp    800e11 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800bc3:	8b 45 14             	mov    0x14(%ebp),%eax
  800bc6:	83 c0 04             	add    $0x4,%eax
  800bc9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800bcc:	8b 45 14             	mov    0x14(%ebp),%eax
  800bcf:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800bd1:	85 d2                	test   %edx,%edx
  800bd3:	b8 d8 2e 80 00       	mov    $0x802ed8,%eax
  800bd8:	0f 45 c2             	cmovne %edx,%eax
  800bdb:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800bde:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800be2:	7e 06                	jle    800bea <vprintfmt+0x19b>
  800be4:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800be8:	75 0d                	jne    800bf7 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800bea:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800bed:	89 c7                	mov    %eax,%edi
  800bef:	03 45 e0             	add    -0x20(%ebp),%eax
  800bf2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bf5:	eb 55                	jmp    800c4c <vprintfmt+0x1fd>
  800bf7:	83 ec 08             	sub    $0x8,%esp
  800bfa:	ff 75 d8             	push   -0x28(%ebp)
  800bfd:	ff 75 cc             	push   -0x34(%ebp)
  800c00:	e8 0a 03 00 00       	call   800f0f <strnlen>
  800c05:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800c08:	29 c1                	sub    %eax,%ecx
  800c0a:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800c0d:	83 c4 10             	add    $0x10,%esp
  800c10:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800c12:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800c16:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800c19:	eb 0f                	jmp    800c2a <vprintfmt+0x1db>
					putch(padc, putdat);
  800c1b:	83 ec 08             	sub    $0x8,%esp
  800c1e:	53                   	push   %ebx
  800c1f:	ff 75 e0             	push   -0x20(%ebp)
  800c22:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800c24:	83 ef 01             	sub    $0x1,%edi
  800c27:	83 c4 10             	add    $0x10,%esp
  800c2a:	85 ff                	test   %edi,%edi
  800c2c:	7f ed                	jg     800c1b <vprintfmt+0x1cc>
  800c2e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800c31:	85 d2                	test   %edx,%edx
  800c33:	b8 00 00 00 00       	mov    $0x0,%eax
  800c38:	0f 49 c2             	cmovns %edx,%eax
  800c3b:	29 c2                	sub    %eax,%edx
  800c3d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800c40:	eb a8                	jmp    800bea <vprintfmt+0x19b>
					putch(ch, putdat);
  800c42:	83 ec 08             	sub    $0x8,%esp
  800c45:	53                   	push   %ebx
  800c46:	52                   	push   %edx
  800c47:	ff d6                	call   *%esi
  800c49:	83 c4 10             	add    $0x10,%esp
  800c4c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800c4f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c51:	83 c7 01             	add    $0x1,%edi
  800c54:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c58:	0f be d0             	movsbl %al,%edx
  800c5b:	85 d2                	test   %edx,%edx
  800c5d:	74 4b                	je     800caa <vprintfmt+0x25b>
  800c5f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800c63:	78 06                	js     800c6b <vprintfmt+0x21c>
  800c65:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800c69:	78 1e                	js     800c89 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800c6b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800c6f:	74 d1                	je     800c42 <vprintfmt+0x1f3>
  800c71:	0f be c0             	movsbl %al,%eax
  800c74:	83 e8 20             	sub    $0x20,%eax
  800c77:	83 f8 5e             	cmp    $0x5e,%eax
  800c7a:	76 c6                	jbe    800c42 <vprintfmt+0x1f3>
					putch('?', putdat);
  800c7c:	83 ec 08             	sub    $0x8,%esp
  800c7f:	53                   	push   %ebx
  800c80:	6a 3f                	push   $0x3f
  800c82:	ff d6                	call   *%esi
  800c84:	83 c4 10             	add    $0x10,%esp
  800c87:	eb c3                	jmp    800c4c <vprintfmt+0x1fd>
  800c89:	89 cf                	mov    %ecx,%edi
  800c8b:	eb 0e                	jmp    800c9b <vprintfmt+0x24c>
				putch(' ', putdat);
  800c8d:	83 ec 08             	sub    $0x8,%esp
  800c90:	53                   	push   %ebx
  800c91:	6a 20                	push   $0x20
  800c93:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800c95:	83 ef 01             	sub    $0x1,%edi
  800c98:	83 c4 10             	add    $0x10,%esp
  800c9b:	85 ff                	test   %edi,%edi
  800c9d:	7f ee                	jg     800c8d <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800c9f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800ca2:	89 45 14             	mov    %eax,0x14(%ebp)
  800ca5:	e9 67 01 00 00       	jmp    800e11 <vprintfmt+0x3c2>
  800caa:	89 cf                	mov    %ecx,%edi
  800cac:	eb ed                	jmp    800c9b <vprintfmt+0x24c>
	if (lflag >= 2)
  800cae:	83 f9 01             	cmp    $0x1,%ecx
  800cb1:	7f 1b                	jg     800cce <vprintfmt+0x27f>
	else if (lflag)
  800cb3:	85 c9                	test   %ecx,%ecx
  800cb5:	74 63                	je     800d1a <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800cb7:	8b 45 14             	mov    0x14(%ebp),%eax
  800cba:	8b 00                	mov    (%eax),%eax
  800cbc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800cbf:	99                   	cltd   
  800cc0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800cc3:	8b 45 14             	mov    0x14(%ebp),%eax
  800cc6:	8d 40 04             	lea    0x4(%eax),%eax
  800cc9:	89 45 14             	mov    %eax,0x14(%ebp)
  800ccc:	eb 17                	jmp    800ce5 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800cce:	8b 45 14             	mov    0x14(%ebp),%eax
  800cd1:	8b 50 04             	mov    0x4(%eax),%edx
  800cd4:	8b 00                	mov    (%eax),%eax
  800cd6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800cd9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800cdc:	8b 45 14             	mov    0x14(%ebp),%eax
  800cdf:	8d 40 08             	lea    0x8(%eax),%eax
  800ce2:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800ce5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ce8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800ceb:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800cf0:	85 c9                	test   %ecx,%ecx
  800cf2:	0f 89 ff 00 00 00    	jns    800df7 <vprintfmt+0x3a8>
				putch('-', putdat);
  800cf8:	83 ec 08             	sub    $0x8,%esp
  800cfb:	53                   	push   %ebx
  800cfc:	6a 2d                	push   $0x2d
  800cfe:	ff d6                	call   *%esi
				num = -(long long) num;
  800d00:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800d03:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800d06:	f7 da                	neg    %edx
  800d08:	83 d1 00             	adc    $0x0,%ecx
  800d0b:	f7 d9                	neg    %ecx
  800d0d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800d10:	bf 0a 00 00 00       	mov    $0xa,%edi
  800d15:	e9 dd 00 00 00       	jmp    800df7 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800d1a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d1d:	8b 00                	mov    (%eax),%eax
  800d1f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d22:	99                   	cltd   
  800d23:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800d26:	8b 45 14             	mov    0x14(%ebp),%eax
  800d29:	8d 40 04             	lea    0x4(%eax),%eax
  800d2c:	89 45 14             	mov    %eax,0x14(%ebp)
  800d2f:	eb b4                	jmp    800ce5 <vprintfmt+0x296>
	if (lflag >= 2)
  800d31:	83 f9 01             	cmp    $0x1,%ecx
  800d34:	7f 1e                	jg     800d54 <vprintfmt+0x305>
	else if (lflag)
  800d36:	85 c9                	test   %ecx,%ecx
  800d38:	74 32                	je     800d6c <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800d3a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d3d:	8b 10                	mov    (%eax),%edx
  800d3f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d44:	8d 40 04             	lea    0x4(%eax),%eax
  800d47:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800d4a:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800d4f:	e9 a3 00 00 00       	jmp    800df7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800d54:	8b 45 14             	mov    0x14(%ebp),%eax
  800d57:	8b 10                	mov    (%eax),%edx
  800d59:	8b 48 04             	mov    0x4(%eax),%ecx
  800d5c:	8d 40 08             	lea    0x8(%eax),%eax
  800d5f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800d62:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800d67:	e9 8b 00 00 00       	jmp    800df7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800d6c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d6f:	8b 10                	mov    (%eax),%edx
  800d71:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d76:	8d 40 04             	lea    0x4(%eax),%eax
  800d79:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800d7c:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800d81:	eb 74                	jmp    800df7 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800d83:	83 f9 01             	cmp    $0x1,%ecx
  800d86:	7f 1b                	jg     800da3 <vprintfmt+0x354>
	else if (lflag)
  800d88:	85 c9                	test   %ecx,%ecx
  800d8a:	74 2c                	je     800db8 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800d8c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d8f:	8b 10                	mov    (%eax),%edx
  800d91:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d96:	8d 40 04             	lea    0x4(%eax),%eax
  800d99:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800d9c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800da1:	eb 54                	jmp    800df7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800da3:	8b 45 14             	mov    0x14(%ebp),%eax
  800da6:	8b 10                	mov    (%eax),%edx
  800da8:	8b 48 04             	mov    0x4(%eax),%ecx
  800dab:	8d 40 08             	lea    0x8(%eax),%eax
  800dae:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800db1:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800db6:	eb 3f                	jmp    800df7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800db8:	8b 45 14             	mov    0x14(%ebp),%eax
  800dbb:	8b 10                	mov    (%eax),%edx
  800dbd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc2:	8d 40 04             	lea    0x4(%eax),%eax
  800dc5:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800dc8:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800dcd:	eb 28                	jmp    800df7 <vprintfmt+0x3a8>
			putch('0', putdat);
  800dcf:	83 ec 08             	sub    $0x8,%esp
  800dd2:	53                   	push   %ebx
  800dd3:	6a 30                	push   $0x30
  800dd5:	ff d6                	call   *%esi
			putch('x', putdat);
  800dd7:	83 c4 08             	add    $0x8,%esp
  800dda:	53                   	push   %ebx
  800ddb:	6a 78                	push   $0x78
  800ddd:	ff d6                	call   *%esi
			num = (unsigned long long)
  800ddf:	8b 45 14             	mov    0x14(%ebp),%eax
  800de2:	8b 10                	mov    (%eax),%edx
  800de4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800de9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800dec:	8d 40 04             	lea    0x4(%eax),%eax
  800def:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800df2:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800df7:	83 ec 0c             	sub    $0xc,%esp
  800dfa:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800dfe:	50                   	push   %eax
  800dff:	ff 75 e0             	push   -0x20(%ebp)
  800e02:	57                   	push   %edi
  800e03:	51                   	push   %ecx
  800e04:	52                   	push   %edx
  800e05:	89 da                	mov    %ebx,%edx
  800e07:	89 f0                	mov    %esi,%eax
  800e09:	e8 5e fb ff ff       	call   80096c <printnum>
			break;
  800e0e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800e11:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800e14:	e9 54 fc ff ff       	jmp    800a6d <vprintfmt+0x1e>
	if (lflag >= 2)
  800e19:	83 f9 01             	cmp    $0x1,%ecx
  800e1c:	7f 1b                	jg     800e39 <vprintfmt+0x3ea>
	else if (lflag)
  800e1e:	85 c9                	test   %ecx,%ecx
  800e20:	74 2c                	je     800e4e <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800e22:	8b 45 14             	mov    0x14(%ebp),%eax
  800e25:	8b 10                	mov    (%eax),%edx
  800e27:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e2c:	8d 40 04             	lea    0x4(%eax),%eax
  800e2f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800e32:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800e37:	eb be                	jmp    800df7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800e39:	8b 45 14             	mov    0x14(%ebp),%eax
  800e3c:	8b 10                	mov    (%eax),%edx
  800e3e:	8b 48 04             	mov    0x4(%eax),%ecx
  800e41:	8d 40 08             	lea    0x8(%eax),%eax
  800e44:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800e47:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800e4c:	eb a9                	jmp    800df7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800e4e:	8b 45 14             	mov    0x14(%ebp),%eax
  800e51:	8b 10                	mov    (%eax),%edx
  800e53:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e58:	8d 40 04             	lea    0x4(%eax),%eax
  800e5b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800e5e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800e63:	eb 92                	jmp    800df7 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800e65:	83 ec 08             	sub    $0x8,%esp
  800e68:	53                   	push   %ebx
  800e69:	6a 25                	push   $0x25
  800e6b:	ff d6                	call   *%esi
			break;
  800e6d:	83 c4 10             	add    $0x10,%esp
  800e70:	eb 9f                	jmp    800e11 <vprintfmt+0x3c2>
			putch('%', putdat);
  800e72:	83 ec 08             	sub    $0x8,%esp
  800e75:	53                   	push   %ebx
  800e76:	6a 25                	push   $0x25
  800e78:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800e7a:	83 c4 10             	add    $0x10,%esp
  800e7d:	89 f8                	mov    %edi,%eax
  800e7f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800e83:	74 05                	je     800e8a <vprintfmt+0x43b>
  800e85:	83 e8 01             	sub    $0x1,%eax
  800e88:	eb f5                	jmp    800e7f <vprintfmt+0x430>
  800e8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e8d:	eb 82                	jmp    800e11 <vprintfmt+0x3c2>

00800e8f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	83 ec 18             	sub    $0x18,%esp
  800e95:	8b 45 08             	mov    0x8(%ebp),%eax
  800e98:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800e9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e9e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ea2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ea5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800eac:	85 c0                	test   %eax,%eax
  800eae:	74 26                	je     800ed6 <vsnprintf+0x47>
  800eb0:	85 d2                	test   %edx,%edx
  800eb2:	7e 22                	jle    800ed6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800eb4:	ff 75 14             	push   0x14(%ebp)
  800eb7:	ff 75 10             	push   0x10(%ebp)
  800eba:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ebd:	50                   	push   %eax
  800ebe:	68 15 0a 80 00       	push   $0x800a15
  800ec3:	e8 87 fb ff ff       	call   800a4f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ec8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ecb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed1:	83 c4 10             	add    $0x10,%esp
}
  800ed4:	c9                   	leave  
  800ed5:	c3                   	ret    
		return -E_INVAL;
  800ed6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800edb:	eb f7                	jmp    800ed4 <vsnprintf+0x45>

00800edd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ee3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ee6:	50                   	push   %eax
  800ee7:	ff 75 10             	push   0x10(%ebp)
  800eea:	ff 75 0c             	push   0xc(%ebp)
  800eed:	ff 75 08             	push   0x8(%ebp)
  800ef0:	e8 9a ff ff ff       	call   800e8f <vsnprintf>
	va_end(ap);

	return rc;
}
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    

00800ef7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800efd:	b8 00 00 00 00       	mov    $0x0,%eax
  800f02:	eb 03                	jmp    800f07 <strlen+0x10>
		n++;
  800f04:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800f07:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800f0b:	75 f7                	jne    800f04 <strlen+0xd>
	return n;
}
  800f0d:	5d                   	pop    %ebp
  800f0e:	c3                   	ret    

00800f0f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f15:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f18:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1d:	eb 03                	jmp    800f22 <strnlen+0x13>
		n++;
  800f1f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f22:	39 d0                	cmp    %edx,%eax
  800f24:	74 08                	je     800f2e <strnlen+0x1f>
  800f26:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800f2a:	75 f3                	jne    800f1f <strnlen+0x10>
  800f2c:	89 c2                	mov    %eax,%edx
	return n;
}
  800f2e:	89 d0                	mov    %edx,%eax
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    

00800f32 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	53                   	push   %ebx
  800f36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f39:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800f3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f41:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800f45:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800f48:	83 c0 01             	add    $0x1,%eax
  800f4b:	84 d2                	test   %dl,%dl
  800f4d:	75 f2                	jne    800f41 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800f4f:	89 c8                	mov    %ecx,%eax
  800f51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f54:	c9                   	leave  
  800f55:	c3                   	ret    

00800f56 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	53                   	push   %ebx
  800f5a:	83 ec 10             	sub    $0x10,%esp
  800f5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800f60:	53                   	push   %ebx
  800f61:	e8 91 ff ff ff       	call   800ef7 <strlen>
  800f66:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800f69:	ff 75 0c             	push   0xc(%ebp)
  800f6c:	01 d8                	add    %ebx,%eax
  800f6e:	50                   	push   %eax
  800f6f:	e8 be ff ff ff       	call   800f32 <strcpy>
	return dst;
}
  800f74:	89 d8                	mov    %ebx,%eax
  800f76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f79:	c9                   	leave  
  800f7a:	c3                   	ret    

00800f7b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	56                   	push   %esi
  800f7f:	53                   	push   %ebx
  800f80:	8b 75 08             	mov    0x8(%ebp),%esi
  800f83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f86:	89 f3                	mov    %esi,%ebx
  800f88:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f8b:	89 f0                	mov    %esi,%eax
  800f8d:	eb 0f                	jmp    800f9e <strncpy+0x23>
		*dst++ = *src;
  800f8f:	83 c0 01             	add    $0x1,%eax
  800f92:	0f b6 0a             	movzbl (%edx),%ecx
  800f95:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800f98:	80 f9 01             	cmp    $0x1,%cl
  800f9b:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800f9e:	39 d8                	cmp    %ebx,%eax
  800fa0:	75 ed                	jne    800f8f <strncpy+0x14>
	}
	return ret;
}
  800fa2:	89 f0                	mov    %esi,%eax
  800fa4:	5b                   	pop    %ebx
  800fa5:	5e                   	pop    %esi
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    

00800fa8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	56                   	push   %esi
  800fac:	53                   	push   %ebx
  800fad:	8b 75 08             	mov    0x8(%ebp),%esi
  800fb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb3:	8b 55 10             	mov    0x10(%ebp),%edx
  800fb6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800fb8:	85 d2                	test   %edx,%edx
  800fba:	74 21                	je     800fdd <strlcpy+0x35>
  800fbc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800fc0:	89 f2                	mov    %esi,%edx
  800fc2:	eb 09                	jmp    800fcd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800fc4:	83 c1 01             	add    $0x1,%ecx
  800fc7:	83 c2 01             	add    $0x1,%edx
  800fca:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800fcd:	39 c2                	cmp    %eax,%edx
  800fcf:	74 09                	je     800fda <strlcpy+0x32>
  800fd1:	0f b6 19             	movzbl (%ecx),%ebx
  800fd4:	84 db                	test   %bl,%bl
  800fd6:	75 ec                	jne    800fc4 <strlcpy+0x1c>
  800fd8:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800fda:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800fdd:	29 f0                	sub    %esi,%eax
}
  800fdf:	5b                   	pop    %ebx
  800fe0:	5e                   	pop    %esi
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800fec:	eb 06                	jmp    800ff4 <strcmp+0x11>
		p++, q++;
  800fee:	83 c1 01             	add    $0x1,%ecx
  800ff1:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800ff4:	0f b6 01             	movzbl (%ecx),%eax
  800ff7:	84 c0                	test   %al,%al
  800ff9:	74 04                	je     800fff <strcmp+0x1c>
  800ffb:	3a 02                	cmp    (%edx),%al
  800ffd:	74 ef                	je     800fee <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800fff:	0f b6 c0             	movzbl %al,%eax
  801002:	0f b6 12             	movzbl (%edx),%edx
  801005:	29 d0                	sub    %edx,%eax
}
  801007:	5d                   	pop    %ebp
  801008:	c3                   	ret    

00801009 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	53                   	push   %ebx
  80100d:	8b 45 08             	mov    0x8(%ebp),%eax
  801010:	8b 55 0c             	mov    0xc(%ebp),%edx
  801013:	89 c3                	mov    %eax,%ebx
  801015:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801018:	eb 06                	jmp    801020 <strncmp+0x17>
		n--, p++, q++;
  80101a:	83 c0 01             	add    $0x1,%eax
  80101d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801020:	39 d8                	cmp    %ebx,%eax
  801022:	74 18                	je     80103c <strncmp+0x33>
  801024:	0f b6 08             	movzbl (%eax),%ecx
  801027:	84 c9                	test   %cl,%cl
  801029:	74 04                	je     80102f <strncmp+0x26>
  80102b:	3a 0a                	cmp    (%edx),%cl
  80102d:	74 eb                	je     80101a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80102f:	0f b6 00             	movzbl (%eax),%eax
  801032:	0f b6 12             	movzbl (%edx),%edx
  801035:	29 d0                	sub    %edx,%eax
}
  801037:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80103a:	c9                   	leave  
  80103b:	c3                   	ret    
		return 0;
  80103c:	b8 00 00 00 00       	mov    $0x0,%eax
  801041:	eb f4                	jmp    801037 <strncmp+0x2e>

00801043 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	8b 45 08             	mov    0x8(%ebp),%eax
  801049:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80104d:	eb 03                	jmp    801052 <strchr+0xf>
  80104f:	83 c0 01             	add    $0x1,%eax
  801052:	0f b6 10             	movzbl (%eax),%edx
  801055:	84 d2                	test   %dl,%dl
  801057:	74 06                	je     80105f <strchr+0x1c>
		if (*s == c)
  801059:	38 ca                	cmp    %cl,%dl
  80105b:	75 f2                	jne    80104f <strchr+0xc>
  80105d:	eb 05                	jmp    801064 <strchr+0x21>
			return (char *) s;
	return 0;
  80105f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	8b 45 08             	mov    0x8(%ebp),%eax
  80106c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801070:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801073:	38 ca                	cmp    %cl,%dl
  801075:	74 09                	je     801080 <strfind+0x1a>
  801077:	84 d2                	test   %dl,%dl
  801079:	74 05                	je     801080 <strfind+0x1a>
	for (; *s; s++)
  80107b:	83 c0 01             	add    $0x1,%eax
  80107e:	eb f0                	jmp    801070 <strfind+0xa>
			break;
	return (char *) s;
}
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    

00801082 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	57                   	push   %edi
  801086:	56                   	push   %esi
  801087:	53                   	push   %ebx
  801088:	8b 7d 08             	mov    0x8(%ebp),%edi
  80108b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80108e:	85 c9                	test   %ecx,%ecx
  801090:	74 2f                	je     8010c1 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801092:	89 f8                	mov    %edi,%eax
  801094:	09 c8                	or     %ecx,%eax
  801096:	a8 03                	test   $0x3,%al
  801098:	75 21                	jne    8010bb <memset+0x39>
		c &= 0xFF;
  80109a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80109e:	89 d0                	mov    %edx,%eax
  8010a0:	c1 e0 08             	shl    $0x8,%eax
  8010a3:	89 d3                	mov    %edx,%ebx
  8010a5:	c1 e3 18             	shl    $0x18,%ebx
  8010a8:	89 d6                	mov    %edx,%esi
  8010aa:	c1 e6 10             	shl    $0x10,%esi
  8010ad:	09 f3                	or     %esi,%ebx
  8010af:	09 da                	or     %ebx,%edx
  8010b1:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8010b3:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8010b6:	fc                   	cld    
  8010b7:	f3 ab                	rep stos %eax,%es:(%edi)
  8010b9:	eb 06                	jmp    8010c1 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8010bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010be:	fc                   	cld    
  8010bf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8010c1:	89 f8                	mov    %edi,%eax
  8010c3:	5b                   	pop    %ebx
  8010c4:	5e                   	pop    %esi
  8010c5:	5f                   	pop    %edi
  8010c6:	5d                   	pop    %ebp
  8010c7:	c3                   	ret    

008010c8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	57                   	push   %edi
  8010cc:	56                   	push   %esi
  8010cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8010d6:	39 c6                	cmp    %eax,%esi
  8010d8:	73 32                	jae    80110c <memmove+0x44>
  8010da:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8010dd:	39 c2                	cmp    %eax,%edx
  8010df:	76 2b                	jbe    80110c <memmove+0x44>
		s += n;
		d += n;
  8010e1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8010e4:	89 d6                	mov    %edx,%esi
  8010e6:	09 fe                	or     %edi,%esi
  8010e8:	09 ce                	or     %ecx,%esi
  8010ea:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8010f0:	75 0e                	jne    801100 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8010f2:	83 ef 04             	sub    $0x4,%edi
  8010f5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8010f8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8010fb:	fd                   	std    
  8010fc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8010fe:	eb 09                	jmp    801109 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801100:	83 ef 01             	sub    $0x1,%edi
  801103:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801106:	fd                   	std    
  801107:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801109:	fc                   	cld    
  80110a:	eb 1a                	jmp    801126 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80110c:	89 f2                	mov    %esi,%edx
  80110e:	09 c2                	or     %eax,%edx
  801110:	09 ca                	or     %ecx,%edx
  801112:	f6 c2 03             	test   $0x3,%dl
  801115:	75 0a                	jne    801121 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801117:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80111a:	89 c7                	mov    %eax,%edi
  80111c:	fc                   	cld    
  80111d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80111f:	eb 05                	jmp    801126 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801121:	89 c7                	mov    %eax,%edi
  801123:	fc                   	cld    
  801124:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801126:	5e                   	pop    %esi
  801127:	5f                   	pop    %edi
  801128:	5d                   	pop    %ebp
  801129:	c3                   	ret    

0080112a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801130:	ff 75 10             	push   0x10(%ebp)
  801133:	ff 75 0c             	push   0xc(%ebp)
  801136:	ff 75 08             	push   0x8(%ebp)
  801139:	e8 8a ff ff ff       	call   8010c8 <memmove>
}
  80113e:	c9                   	leave  
  80113f:	c3                   	ret    

00801140 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	56                   	push   %esi
  801144:	53                   	push   %ebx
  801145:	8b 45 08             	mov    0x8(%ebp),%eax
  801148:	8b 55 0c             	mov    0xc(%ebp),%edx
  80114b:	89 c6                	mov    %eax,%esi
  80114d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801150:	eb 06                	jmp    801158 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801152:	83 c0 01             	add    $0x1,%eax
  801155:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801158:	39 f0                	cmp    %esi,%eax
  80115a:	74 14                	je     801170 <memcmp+0x30>
		if (*s1 != *s2)
  80115c:	0f b6 08             	movzbl (%eax),%ecx
  80115f:	0f b6 1a             	movzbl (%edx),%ebx
  801162:	38 d9                	cmp    %bl,%cl
  801164:	74 ec                	je     801152 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801166:	0f b6 c1             	movzbl %cl,%eax
  801169:	0f b6 db             	movzbl %bl,%ebx
  80116c:	29 d8                	sub    %ebx,%eax
  80116e:	eb 05                	jmp    801175 <memcmp+0x35>
	}

	return 0;
  801170:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801175:	5b                   	pop    %ebx
  801176:	5e                   	pop    %esi
  801177:	5d                   	pop    %ebp
  801178:	c3                   	ret    

00801179 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801179:	55                   	push   %ebp
  80117a:	89 e5                	mov    %esp,%ebp
  80117c:	8b 45 08             	mov    0x8(%ebp),%eax
  80117f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801182:	89 c2                	mov    %eax,%edx
  801184:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801187:	eb 03                	jmp    80118c <memfind+0x13>
  801189:	83 c0 01             	add    $0x1,%eax
  80118c:	39 d0                	cmp    %edx,%eax
  80118e:	73 04                	jae    801194 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801190:	38 08                	cmp    %cl,(%eax)
  801192:	75 f5                	jne    801189 <memfind+0x10>
			break;
	return (void *) s;
}
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    

00801196 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	57                   	push   %edi
  80119a:	56                   	push   %esi
  80119b:	53                   	push   %ebx
  80119c:	8b 55 08             	mov    0x8(%ebp),%edx
  80119f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8011a2:	eb 03                	jmp    8011a7 <strtol+0x11>
		s++;
  8011a4:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8011a7:	0f b6 02             	movzbl (%edx),%eax
  8011aa:	3c 20                	cmp    $0x20,%al
  8011ac:	74 f6                	je     8011a4 <strtol+0xe>
  8011ae:	3c 09                	cmp    $0x9,%al
  8011b0:	74 f2                	je     8011a4 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8011b2:	3c 2b                	cmp    $0x2b,%al
  8011b4:	74 2a                	je     8011e0 <strtol+0x4a>
	int neg = 0;
  8011b6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8011bb:	3c 2d                	cmp    $0x2d,%al
  8011bd:	74 2b                	je     8011ea <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8011bf:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8011c5:	75 0f                	jne    8011d6 <strtol+0x40>
  8011c7:	80 3a 30             	cmpb   $0x30,(%edx)
  8011ca:	74 28                	je     8011f4 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8011cc:	85 db                	test   %ebx,%ebx
  8011ce:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011d3:	0f 44 d8             	cmove  %eax,%ebx
  8011d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011db:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8011de:	eb 46                	jmp    801226 <strtol+0x90>
		s++;
  8011e0:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8011e3:	bf 00 00 00 00       	mov    $0x0,%edi
  8011e8:	eb d5                	jmp    8011bf <strtol+0x29>
		s++, neg = 1;
  8011ea:	83 c2 01             	add    $0x1,%edx
  8011ed:	bf 01 00 00 00       	mov    $0x1,%edi
  8011f2:	eb cb                	jmp    8011bf <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8011f4:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8011f8:	74 0e                	je     801208 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8011fa:	85 db                	test   %ebx,%ebx
  8011fc:	75 d8                	jne    8011d6 <strtol+0x40>
		s++, base = 8;
  8011fe:	83 c2 01             	add    $0x1,%edx
  801201:	bb 08 00 00 00       	mov    $0x8,%ebx
  801206:	eb ce                	jmp    8011d6 <strtol+0x40>
		s += 2, base = 16;
  801208:	83 c2 02             	add    $0x2,%edx
  80120b:	bb 10 00 00 00       	mov    $0x10,%ebx
  801210:	eb c4                	jmp    8011d6 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801212:	0f be c0             	movsbl %al,%eax
  801215:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801218:	3b 45 10             	cmp    0x10(%ebp),%eax
  80121b:	7d 3a                	jge    801257 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  80121d:	83 c2 01             	add    $0x1,%edx
  801220:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801224:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801226:	0f b6 02             	movzbl (%edx),%eax
  801229:	8d 70 d0             	lea    -0x30(%eax),%esi
  80122c:	89 f3                	mov    %esi,%ebx
  80122e:	80 fb 09             	cmp    $0x9,%bl
  801231:	76 df                	jbe    801212 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801233:	8d 70 9f             	lea    -0x61(%eax),%esi
  801236:	89 f3                	mov    %esi,%ebx
  801238:	80 fb 19             	cmp    $0x19,%bl
  80123b:	77 08                	ja     801245 <strtol+0xaf>
			dig = *s - 'a' + 10;
  80123d:	0f be c0             	movsbl %al,%eax
  801240:	83 e8 57             	sub    $0x57,%eax
  801243:	eb d3                	jmp    801218 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801245:	8d 70 bf             	lea    -0x41(%eax),%esi
  801248:	89 f3                	mov    %esi,%ebx
  80124a:	80 fb 19             	cmp    $0x19,%bl
  80124d:	77 08                	ja     801257 <strtol+0xc1>
			dig = *s - 'A' + 10;
  80124f:	0f be c0             	movsbl %al,%eax
  801252:	83 e8 37             	sub    $0x37,%eax
  801255:	eb c1                	jmp    801218 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801257:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80125b:	74 05                	je     801262 <strtol+0xcc>
		*endptr = (char *) s;
  80125d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801260:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801262:	89 c8                	mov    %ecx,%eax
  801264:	f7 d8                	neg    %eax
  801266:	85 ff                	test   %edi,%edi
  801268:	0f 45 c8             	cmovne %eax,%ecx
}
  80126b:	89 c8                	mov    %ecx,%eax
  80126d:	5b                   	pop    %ebx
  80126e:	5e                   	pop    %esi
  80126f:	5f                   	pop    %edi
  801270:	5d                   	pop    %ebp
  801271:	c3                   	ret    

00801272 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	57                   	push   %edi
  801276:	56                   	push   %esi
  801277:	53                   	push   %ebx
	asm volatile("int %1\n"
  801278:	b8 00 00 00 00       	mov    $0x0,%eax
  80127d:	8b 55 08             	mov    0x8(%ebp),%edx
  801280:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801283:	89 c3                	mov    %eax,%ebx
  801285:	89 c7                	mov    %eax,%edi
  801287:	89 c6                	mov    %eax,%esi
  801289:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80128b:	5b                   	pop    %ebx
  80128c:	5e                   	pop    %esi
  80128d:	5f                   	pop    %edi
  80128e:	5d                   	pop    %ebp
  80128f:	c3                   	ret    

00801290 <sys_cgetc>:

int
sys_cgetc(void)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	57                   	push   %edi
  801294:	56                   	push   %esi
  801295:	53                   	push   %ebx
	asm volatile("int %1\n"
  801296:	ba 00 00 00 00       	mov    $0x0,%edx
  80129b:	b8 01 00 00 00       	mov    $0x1,%eax
  8012a0:	89 d1                	mov    %edx,%ecx
  8012a2:	89 d3                	mov    %edx,%ebx
  8012a4:	89 d7                	mov    %edx,%edi
  8012a6:	89 d6                	mov    %edx,%esi
  8012a8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8012aa:	5b                   	pop    %ebx
  8012ab:	5e                   	pop    %esi
  8012ac:	5f                   	pop    %edi
  8012ad:	5d                   	pop    %ebp
  8012ae:	c3                   	ret    

008012af <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	57                   	push   %edi
  8012b3:	56                   	push   %esi
  8012b4:	53                   	push   %ebx
  8012b5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c0:	b8 03 00 00 00       	mov    $0x3,%eax
  8012c5:	89 cb                	mov    %ecx,%ebx
  8012c7:	89 cf                	mov    %ecx,%edi
  8012c9:	89 ce                	mov    %ecx,%esi
  8012cb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	7f 08                	jg     8012d9 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8012d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d4:	5b                   	pop    %ebx
  8012d5:	5e                   	pop    %esi
  8012d6:	5f                   	pop    %edi
  8012d7:	5d                   	pop    %ebp
  8012d8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8012d9:	83 ec 0c             	sub    $0xc,%esp
  8012dc:	50                   	push   %eax
  8012dd:	6a 03                	push   $0x3
  8012df:	68 bf 31 80 00       	push   $0x8031bf
  8012e4:	6a 2a                	push   $0x2a
  8012e6:	68 dc 31 80 00       	push   $0x8031dc
  8012eb:	e8 8d f5 ff ff       	call   80087d <_panic>

008012f0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	57                   	push   %edi
  8012f4:	56                   	push   %esi
  8012f5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8012f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8012fb:	b8 02 00 00 00       	mov    $0x2,%eax
  801300:	89 d1                	mov    %edx,%ecx
  801302:	89 d3                	mov    %edx,%ebx
  801304:	89 d7                	mov    %edx,%edi
  801306:	89 d6                	mov    %edx,%esi
  801308:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80130a:	5b                   	pop    %ebx
  80130b:	5e                   	pop    %esi
  80130c:	5f                   	pop    %edi
  80130d:	5d                   	pop    %ebp
  80130e:	c3                   	ret    

0080130f <sys_yield>:

void
sys_yield(void)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	57                   	push   %edi
  801313:	56                   	push   %esi
  801314:	53                   	push   %ebx
	asm volatile("int %1\n"
  801315:	ba 00 00 00 00       	mov    $0x0,%edx
  80131a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80131f:	89 d1                	mov    %edx,%ecx
  801321:	89 d3                	mov    %edx,%ebx
  801323:	89 d7                	mov    %edx,%edi
  801325:	89 d6                	mov    %edx,%esi
  801327:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801329:	5b                   	pop    %ebx
  80132a:	5e                   	pop    %esi
  80132b:	5f                   	pop    %edi
  80132c:	5d                   	pop    %ebp
  80132d:	c3                   	ret    

0080132e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80132e:	55                   	push   %ebp
  80132f:	89 e5                	mov    %esp,%ebp
  801331:	57                   	push   %edi
  801332:	56                   	push   %esi
  801333:	53                   	push   %ebx
  801334:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801337:	be 00 00 00 00       	mov    $0x0,%esi
  80133c:	8b 55 08             	mov    0x8(%ebp),%edx
  80133f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801342:	b8 04 00 00 00       	mov    $0x4,%eax
  801347:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80134a:	89 f7                	mov    %esi,%edi
  80134c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80134e:	85 c0                	test   %eax,%eax
  801350:	7f 08                	jg     80135a <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801352:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801355:	5b                   	pop    %ebx
  801356:	5e                   	pop    %esi
  801357:	5f                   	pop    %edi
  801358:	5d                   	pop    %ebp
  801359:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80135a:	83 ec 0c             	sub    $0xc,%esp
  80135d:	50                   	push   %eax
  80135e:	6a 04                	push   $0x4
  801360:	68 bf 31 80 00       	push   $0x8031bf
  801365:	6a 2a                	push   $0x2a
  801367:	68 dc 31 80 00       	push   $0x8031dc
  80136c:	e8 0c f5 ff ff       	call   80087d <_panic>

00801371 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	57                   	push   %edi
  801375:	56                   	push   %esi
  801376:	53                   	push   %ebx
  801377:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80137a:	8b 55 08             	mov    0x8(%ebp),%edx
  80137d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801380:	b8 05 00 00 00       	mov    $0x5,%eax
  801385:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801388:	8b 7d 14             	mov    0x14(%ebp),%edi
  80138b:	8b 75 18             	mov    0x18(%ebp),%esi
  80138e:	cd 30                	int    $0x30
	if(check && ret > 0)
  801390:	85 c0                	test   %eax,%eax
  801392:	7f 08                	jg     80139c <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801394:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801397:	5b                   	pop    %ebx
  801398:	5e                   	pop    %esi
  801399:	5f                   	pop    %edi
  80139a:	5d                   	pop    %ebp
  80139b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80139c:	83 ec 0c             	sub    $0xc,%esp
  80139f:	50                   	push   %eax
  8013a0:	6a 05                	push   $0x5
  8013a2:	68 bf 31 80 00       	push   $0x8031bf
  8013a7:	6a 2a                	push   $0x2a
  8013a9:	68 dc 31 80 00       	push   $0x8031dc
  8013ae:	e8 ca f4 ff ff       	call   80087d <_panic>

008013b3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	57                   	push   %edi
  8013b7:	56                   	push   %esi
  8013b8:	53                   	push   %ebx
  8013b9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8013bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8013c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013c7:	b8 06 00 00 00       	mov    $0x6,%eax
  8013cc:	89 df                	mov    %ebx,%edi
  8013ce:	89 de                	mov    %ebx,%esi
  8013d0:	cd 30                	int    $0x30
	if(check && ret > 0)
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	7f 08                	jg     8013de <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8013d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d9:	5b                   	pop    %ebx
  8013da:	5e                   	pop    %esi
  8013db:	5f                   	pop    %edi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8013de:	83 ec 0c             	sub    $0xc,%esp
  8013e1:	50                   	push   %eax
  8013e2:	6a 06                	push   $0x6
  8013e4:	68 bf 31 80 00       	push   $0x8031bf
  8013e9:	6a 2a                	push   $0x2a
  8013eb:	68 dc 31 80 00       	push   $0x8031dc
  8013f0:	e8 88 f4 ff ff       	call   80087d <_panic>

008013f5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
  8013f8:	57                   	push   %edi
  8013f9:	56                   	push   %esi
  8013fa:	53                   	push   %ebx
  8013fb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8013fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801403:	8b 55 08             	mov    0x8(%ebp),%edx
  801406:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801409:	b8 08 00 00 00       	mov    $0x8,%eax
  80140e:	89 df                	mov    %ebx,%edi
  801410:	89 de                	mov    %ebx,%esi
  801412:	cd 30                	int    $0x30
	if(check && ret > 0)
  801414:	85 c0                	test   %eax,%eax
  801416:	7f 08                	jg     801420 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801418:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80141b:	5b                   	pop    %ebx
  80141c:	5e                   	pop    %esi
  80141d:	5f                   	pop    %edi
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801420:	83 ec 0c             	sub    $0xc,%esp
  801423:	50                   	push   %eax
  801424:	6a 08                	push   $0x8
  801426:	68 bf 31 80 00       	push   $0x8031bf
  80142b:	6a 2a                	push   $0x2a
  80142d:	68 dc 31 80 00       	push   $0x8031dc
  801432:	e8 46 f4 ff ff       	call   80087d <_panic>

00801437 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	57                   	push   %edi
  80143b:	56                   	push   %esi
  80143c:	53                   	push   %ebx
  80143d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801440:	bb 00 00 00 00       	mov    $0x0,%ebx
  801445:	8b 55 08             	mov    0x8(%ebp),%edx
  801448:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80144b:	b8 09 00 00 00       	mov    $0x9,%eax
  801450:	89 df                	mov    %ebx,%edi
  801452:	89 de                	mov    %ebx,%esi
  801454:	cd 30                	int    $0x30
	if(check && ret > 0)
  801456:	85 c0                	test   %eax,%eax
  801458:	7f 08                	jg     801462 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80145a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80145d:	5b                   	pop    %ebx
  80145e:	5e                   	pop    %esi
  80145f:	5f                   	pop    %edi
  801460:	5d                   	pop    %ebp
  801461:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801462:	83 ec 0c             	sub    $0xc,%esp
  801465:	50                   	push   %eax
  801466:	6a 09                	push   $0x9
  801468:	68 bf 31 80 00       	push   $0x8031bf
  80146d:	6a 2a                	push   $0x2a
  80146f:	68 dc 31 80 00       	push   $0x8031dc
  801474:	e8 04 f4 ff ff       	call   80087d <_panic>

00801479 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801479:	55                   	push   %ebp
  80147a:	89 e5                	mov    %esp,%ebp
  80147c:	57                   	push   %edi
  80147d:	56                   	push   %esi
  80147e:	53                   	push   %ebx
  80147f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801482:	bb 00 00 00 00       	mov    $0x0,%ebx
  801487:	8b 55 08             	mov    0x8(%ebp),%edx
  80148a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80148d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801492:	89 df                	mov    %ebx,%edi
  801494:	89 de                	mov    %ebx,%esi
  801496:	cd 30                	int    $0x30
	if(check && ret > 0)
  801498:	85 c0                	test   %eax,%eax
  80149a:	7f 08                	jg     8014a4 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80149c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149f:	5b                   	pop    %ebx
  8014a0:	5e                   	pop    %esi
  8014a1:	5f                   	pop    %edi
  8014a2:	5d                   	pop    %ebp
  8014a3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8014a4:	83 ec 0c             	sub    $0xc,%esp
  8014a7:	50                   	push   %eax
  8014a8:	6a 0a                	push   $0xa
  8014aa:	68 bf 31 80 00       	push   $0x8031bf
  8014af:	6a 2a                	push   $0x2a
  8014b1:	68 dc 31 80 00       	push   $0x8031dc
  8014b6:	e8 c2 f3 ff ff       	call   80087d <_panic>

008014bb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	57                   	push   %edi
  8014bf:	56                   	push   %esi
  8014c0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8014c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8014c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014c7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8014cc:	be 00 00 00 00       	mov    $0x0,%esi
  8014d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014d4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8014d7:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8014d9:	5b                   	pop    %ebx
  8014da:	5e                   	pop    %esi
  8014db:	5f                   	pop    %edi
  8014dc:	5d                   	pop    %ebp
  8014dd:	c3                   	ret    

008014de <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8014de:	55                   	push   %ebp
  8014df:	89 e5                	mov    %esp,%ebp
  8014e1:	57                   	push   %edi
  8014e2:	56                   	push   %esi
  8014e3:	53                   	push   %ebx
  8014e4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8014e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ef:	b8 0d 00 00 00       	mov    $0xd,%eax
  8014f4:	89 cb                	mov    %ecx,%ebx
  8014f6:	89 cf                	mov    %ecx,%edi
  8014f8:	89 ce                	mov    %ecx,%esi
  8014fa:	cd 30                	int    $0x30
	if(check && ret > 0)
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	7f 08                	jg     801508 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801500:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801503:	5b                   	pop    %ebx
  801504:	5e                   	pop    %esi
  801505:	5f                   	pop    %edi
  801506:	5d                   	pop    %ebp
  801507:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801508:	83 ec 0c             	sub    $0xc,%esp
  80150b:	50                   	push   %eax
  80150c:	6a 0d                	push   $0xd
  80150e:	68 bf 31 80 00       	push   $0x8031bf
  801513:	6a 2a                	push   $0x2a
  801515:	68 dc 31 80 00       	push   $0x8031dc
  80151a:	e8 5e f3 ff ff       	call   80087d <_panic>

0080151f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80151f:	55                   	push   %ebp
  801520:	89 e5                	mov    %esp,%ebp
  801522:	57                   	push   %edi
  801523:	56                   	push   %esi
  801524:	53                   	push   %ebx
	asm volatile("int %1\n"
  801525:	ba 00 00 00 00       	mov    $0x0,%edx
  80152a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80152f:	89 d1                	mov    %edx,%ecx
  801531:	89 d3                	mov    %edx,%ebx
  801533:	89 d7                	mov    %edx,%edi
  801535:	89 d6                	mov    %edx,%esi
  801537:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801539:	5b                   	pop    %ebx
  80153a:	5e                   	pop    %esi
  80153b:	5f                   	pop    %edi
  80153c:	5d                   	pop    %ebp
  80153d:	c3                   	ret    

0080153e <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	57                   	push   %edi
  801542:	56                   	push   %esi
  801543:	53                   	push   %ebx
	asm volatile("int %1\n"
  801544:	bb 00 00 00 00       	mov    $0x0,%ebx
  801549:	8b 55 08             	mov    0x8(%ebp),%edx
  80154c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80154f:	b8 0f 00 00 00       	mov    $0xf,%eax
  801554:	89 df                	mov    %ebx,%edi
  801556:	89 de                	mov    %ebx,%esi
  801558:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  80155a:	5b                   	pop    %ebx
  80155b:	5e                   	pop    %esi
  80155c:	5f                   	pop    %edi
  80155d:	5d                   	pop    %ebp
  80155e:	c3                   	ret    

0080155f <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	57                   	push   %edi
  801563:	56                   	push   %esi
  801564:	53                   	push   %ebx
	asm volatile("int %1\n"
  801565:	bb 00 00 00 00       	mov    $0x0,%ebx
  80156a:	8b 55 08             	mov    0x8(%ebp),%edx
  80156d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801570:	b8 10 00 00 00       	mov    $0x10,%eax
  801575:	89 df                	mov    %ebx,%edi
  801577:	89 de                	mov    %ebx,%esi
  801579:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  80157b:	5b                   	pop    %ebx
  80157c:	5e                   	pop    %esi
  80157d:	5f                   	pop    %edi
  80157e:	5d                   	pop    %ebp
  80157f:	c3                   	ret    

00801580 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	56                   	push   %esi
  801584:	53                   	push   %ebx
  801585:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801588:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  80158a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80158e:	0f 84 8e 00 00 00    	je     801622 <pgfault+0xa2>
  801594:	89 f0                	mov    %esi,%eax
  801596:	c1 e8 0c             	shr    $0xc,%eax
  801599:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015a0:	f6 c4 08             	test   $0x8,%ah
  8015a3:	74 7d                	je     801622 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  8015a5:	e8 46 fd ff ff       	call   8012f0 <sys_getenvid>
  8015aa:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  8015ac:	83 ec 04             	sub    $0x4,%esp
  8015af:	6a 07                	push   $0x7
  8015b1:	68 00 f0 7f 00       	push   $0x7ff000
  8015b6:	50                   	push   %eax
  8015b7:	e8 72 fd ff ff       	call   80132e <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 73                	js     801636 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  8015c3:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  8015c9:	83 ec 04             	sub    $0x4,%esp
  8015cc:	68 00 10 00 00       	push   $0x1000
  8015d1:	56                   	push   %esi
  8015d2:	68 00 f0 7f 00       	push   $0x7ff000
  8015d7:	e8 ec fa ff ff       	call   8010c8 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  8015dc:	83 c4 08             	add    $0x8,%esp
  8015df:	56                   	push   %esi
  8015e0:	53                   	push   %ebx
  8015e1:	e8 cd fd ff ff       	call   8013b3 <sys_page_unmap>
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	78 5b                	js     801648 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  8015ed:	83 ec 0c             	sub    $0xc,%esp
  8015f0:	6a 07                	push   $0x7
  8015f2:	56                   	push   %esi
  8015f3:	53                   	push   %ebx
  8015f4:	68 00 f0 7f 00       	push   $0x7ff000
  8015f9:	53                   	push   %ebx
  8015fa:	e8 72 fd ff ff       	call   801371 <sys_page_map>
  8015ff:	83 c4 20             	add    $0x20,%esp
  801602:	85 c0                	test   %eax,%eax
  801604:	78 54                	js     80165a <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  801606:	83 ec 08             	sub    $0x8,%esp
  801609:	68 00 f0 7f 00       	push   $0x7ff000
  80160e:	53                   	push   %ebx
  80160f:	e8 9f fd ff ff       	call   8013b3 <sys_page_unmap>
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	85 c0                	test   %eax,%eax
  801619:	78 51                	js     80166c <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  80161b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161e:	5b                   	pop    %ebx
  80161f:	5e                   	pop    %esi
  801620:	5d                   	pop    %ebp
  801621:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  801622:	83 ec 04             	sub    $0x4,%esp
  801625:	68 ec 31 80 00       	push   $0x8031ec
  80162a:	6a 1d                	push   $0x1d
  80162c:	68 68 32 80 00       	push   $0x803268
  801631:	e8 47 f2 ff ff       	call   80087d <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  801636:	50                   	push   %eax
  801637:	68 24 32 80 00       	push   $0x803224
  80163c:	6a 29                	push   $0x29
  80163e:	68 68 32 80 00       	push   $0x803268
  801643:	e8 35 f2 ff ff       	call   80087d <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  801648:	50                   	push   %eax
  801649:	68 48 32 80 00       	push   $0x803248
  80164e:	6a 2e                	push   $0x2e
  801650:	68 68 32 80 00       	push   $0x803268
  801655:	e8 23 f2 ff ff       	call   80087d <_panic>
		panic("pgfault: page map failed (%e)", r);
  80165a:	50                   	push   %eax
  80165b:	68 73 32 80 00       	push   $0x803273
  801660:	6a 30                	push   $0x30
  801662:	68 68 32 80 00       	push   $0x803268
  801667:	e8 11 f2 ff ff       	call   80087d <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  80166c:	50                   	push   %eax
  80166d:	68 48 32 80 00       	push   $0x803248
  801672:	6a 32                	push   $0x32
  801674:	68 68 32 80 00       	push   $0x803268
  801679:	e8 ff f1 ff ff       	call   80087d <_panic>

0080167e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	57                   	push   %edi
  801682:	56                   	push   %esi
  801683:	53                   	push   %ebx
  801684:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  801687:	68 80 15 80 00       	push   $0x801580
  80168c:	e8 81 13 00 00       	call   802a12 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801691:	b8 07 00 00 00       	mov    $0x7,%eax
  801696:	cd 30                	int    $0x30
  801698:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	78 30                	js     8016d2 <fork+0x54>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  8016a2:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  8016a7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8016ab:	75 76                	jne    801723 <fork+0xa5>
		thisenv = &envs[ENVX(sys_getenvid())];
  8016ad:	e8 3e fc ff ff       	call   8012f0 <sys_getenvid>
  8016b2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016b7:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8016bd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016c2:	a3 18 50 80 00       	mov    %eax,0x805018
		return 0;
  8016c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  8016ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016cd:	5b                   	pop    %ebx
  8016ce:	5e                   	pop    %esi
  8016cf:	5f                   	pop    %edi
  8016d0:	5d                   	pop    %ebp
  8016d1:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  8016d2:	50                   	push   %eax
  8016d3:	68 91 32 80 00       	push   $0x803291
  8016d8:	6a 78                	push   $0x78
  8016da:	68 68 32 80 00       	push   $0x803268
  8016df:	e8 99 f1 ff ff       	call   80087d <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  8016e4:	83 ec 0c             	sub    $0xc,%esp
  8016e7:	ff 75 e4             	push   -0x1c(%ebp)
  8016ea:	57                   	push   %edi
  8016eb:	ff 75 dc             	push   -0x24(%ebp)
  8016ee:	57                   	push   %edi
  8016ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8016f2:	56                   	push   %esi
  8016f3:	e8 79 fc ff ff       	call   801371 <sys_page_map>
	if(r<0) return r;
  8016f8:	83 c4 20             	add    $0x20,%esp
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	78 cb                	js     8016ca <fork+0x4c>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  8016ff:	83 ec 0c             	sub    $0xc,%esp
  801702:	ff 75 e4             	push   -0x1c(%ebp)
  801705:	57                   	push   %edi
  801706:	56                   	push   %esi
  801707:	57                   	push   %edi
  801708:	56                   	push   %esi
  801709:	e8 63 fc ff ff       	call   801371 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  80170e:	83 c4 20             	add    $0x20,%esp
  801711:	85 c0                	test   %eax,%eax
  801713:	78 76                	js     80178b <fork+0x10d>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801715:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80171b:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801721:	74 75                	je     801798 <fork+0x11a>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  801723:	89 d8                	mov    %ebx,%eax
  801725:	c1 e8 16             	shr    $0x16,%eax
  801728:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80172f:	a8 01                	test   $0x1,%al
  801731:	74 e2                	je     801715 <fork+0x97>
  801733:	89 de                	mov    %ebx,%esi
  801735:	c1 ee 0c             	shr    $0xc,%esi
  801738:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80173f:	a8 01                	test   $0x1,%al
  801741:	74 d2                	je     801715 <fork+0x97>
	envid_t this_envid = sys_getenvid();//父进程号
  801743:	e8 a8 fb ff ff       	call   8012f0 <sys_getenvid>
  801748:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  80174b:	89 f7                	mov    %esi,%edi
  80174d:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  801750:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801757:	89 c1                	mov    %eax,%ecx
  801759:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  80175f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  801762:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  801769:	f6 c6 04             	test   $0x4,%dh
  80176c:	0f 85 72 ff ff ff    	jne    8016e4 <fork+0x66>
		perm &= ~PTE_W;
  801772:	25 05 0e 00 00       	and    $0xe05,%eax
  801777:	80 cc 08             	or     $0x8,%ah
  80177a:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  801780:	0f 44 c1             	cmove  %ecx,%eax
  801783:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801786:	e9 59 ff ff ff       	jmp    8016e4 <fork+0x66>
  80178b:	ba 00 00 00 00       	mov    $0x0,%edx
  801790:	0f 4f c2             	cmovg  %edx,%eax
  801793:	e9 32 ff ff ff       	jmp    8016ca <fork+0x4c>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801798:	83 ec 04             	sub    $0x4,%esp
  80179b:	6a 07                	push   $0x7
  80179d:	68 00 f0 bf ee       	push   $0xeebff000
  8017a2:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8017a5:	57                   	push   %edi
  8017a6:	e8 83 fb ff ff       	call   80132e <sys_page_alloc>
	if(r<0) return r;
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	0f 88 14 ff ff ff    	js     8016ca <fork+0x4c>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8017b6:	83 ec 08             	sub    $0x8,%esp
  8017b9:	68 88 2a 80 00       	push   $0x802a88
  8017be:	57                   	push   %edi
  8017bf:	e8 b5 fc ff ff       	call   801479 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  8017c4:	83 c4 10             	add    $0x10,%esp
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	0f 88 fb fe ff ff    	js     8016ca <fork+0x4c>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8017cf:	83 ec 08             	sub    $0x8,%esp
  8017d2:	6a 02                	push   $0x2
  8017d4:	57                   	push   %edi
  8017d5:	e8 1b fc ff ff       	call   8013f5 <sys_env_set_status>
	if(r<0) return r;
  8017da:	83 c4 10             	add    $0x10,%esp
	return envid;
  8017dd:	85 c0                	test   %eax,%eax
  8017df:	0f 49 c7             	cmovns %edi,%eax
  8017e2:	e9 e3 fe ff ff       	jmp    8016ca <fork+0x4c>

008017e7 <sfork>:

// Challenge!
int
sfork(void)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8017ed:	68 a1 32 80 00       	push   $0x8032a1
  8017f2:	68 a1 00 00 00       	push   $0xa1
  8017f7:	68 68 32 80 00       	push   $0x803268
  8017fc:	e8 7c f0 ff ff       	call   80087d <_panic>

00801801 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	56                   	push   %esi
  801805:	53                   	push   %ebx
  801806:	8b 75 08             	mov    0x8(%ebp),%esi
  801809:	8b 45 0c             	mov    0xc(%ebp),%eax
  80180c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80180f:	85 c0                	test   %eax,%eax
  801811:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801816:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801819:	83 ec 0c             	sub    $0xc,%esp
  80181c:	50                   	push   %eax
  80181d:	e8 bc fc ff ff       	call   8014de <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	85 f6                	test   %esi,%esi
  801827:	74 17                	je     801840 <ipc_recv+0x3f>
  801829:	ba 00 00 00 00       	mov    $0x0,%edx
  80182e:	85 c0                	test   %eax,%eax
  801830:	78 0c                	js     80183e <ipc_recv+0x3d>
  801832:	8b 15 18 50 80 00    	mov    0x805018,%edx
  801838:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  80183e:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801840:	85 db                	test   %ebx,%ebx
  801842:	74 17                	je     80185b <ipc_recv+0x5a>
  801844:	ba 00 00 00 00       	mov    $0x0,%edx
  801849:	85 c0                	test   %eax,%eax
  80184b:	78 0c                	js     801859 <ipc_recv+0x58>
  80184d:	8b 15 18 50 80 00    	mov    0x805018,%edx
  801853:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801859:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  80185b:	85 c0                	test   %eax,%eax
  80185d:	78 0b                	js     80186a <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  80185f:	a1 18 50 80 00       	mov    0x805018,%eax
  801864:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  80186a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80186d:	5b                   	pop    %ebx
  80186e:	5e                   	pop    %esi
  80186f:	5d                   	pop    %ebp
  801870:	c3                   	ret    

00801871 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	57                   	push   %edi
  801875:	56                   	push   %esi
  801876:	53                   	push   %ebx
  801877:	83 ec 0c             	sub    $0xc,%esp
  80187a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80187d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801880:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801883:	85 db                	test   %ebx,%ebx
  801885:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80188a:	0f 44 d8             	cmove  %eax,%ebx
  80188d:	eb 05                	jmp    801894 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80188f:	e8 7b fa ff ff       	call   80130f <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801894:	ff 75 14             	push   0x14(%ebp)
  801897:	53                   	push   %ebx
  801898:	56                   	push   %esi
  801899:	57                   	push   %edi
  80189a:	e8 1c fc ff ff       	call   8014bb <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8018a5:	74 e8                	je     80188f <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8018a7:	85 c0                	test   %eax,%eax
  8018a9:	78 08                	js     8018b3 <ipc_send+0x42>
	}while (r<0);

}
  8018ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ae:	5b                   	pop    %ebx
  8018af:	5e                   	pop    %esi
  8018b0:	5f                   	pop    %edi
  8018b1:	5d                   	pop    %ebp
  8018b2:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8018b3:	50                   	push   %eax
  8018b4:	68 b7 32 80 00       	push   $0x8032b7
  8018b9:	6a 3d                	push   $0x3d
  8018bb:	68 cb 32 80 00       	push   $0x8032cb
  8018c0:	e8 b8 ef ff ff       	call   80087d <_panic>

008018c5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8018cb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8018d0:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  8018d6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8018dc:	8b 52 60             	mov    0x60(%edx),%edx
  8018df:	39 ca                	cmp    %ecx,%edx
  8018e1:	74 11                	je     8018f4 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  8018e3:	83 c0 01             	add    $0x1,%eax
  8018e6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8018eb:	75 e3                	jne    8018d0 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8018ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f2:	eb 0e                	jmp    801902 <ipc_find_env+0x3d>
			return envs[i].env_id;
  8018f4:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8018fa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8018ff:	8b 40 58             	mov    0x58(%eax),%eax
}
  801902:	5d                   	pop    %ebp
  801903:	c3                   	ret    

00801904 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801907:	8b 45 08             	mov    0x8(%ebp),%eax
  80190a:	05 00 00 00 30       	add    $0x30000000,%eax
  80190f:	c1 e8 0c             	shr    $0xc,%eax
}
  801912:	5d                   	pop    %ebp
  801913:	c3                   	ret    

00801914 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801917:	8b 45 08             	mov    0x8(%ebp),%eax
  80191a:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80191f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801924:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801929:	5d                   	pop    %ebp
  80192a:	c3                   	ret    

0080192b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801933:	89 c2                	mov    %eax,%edx
  801935:	c1 ea 16             	shr    $0x16,%edx
  801938:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80193f:	f6 c2 01             	test   $0x1,%dl
  801942:	74 29                	je     80196d <fd_alloc+0x42>
  801944:	89 c2                	mov    %eax,%edx
  801946:	c1 ea 0c             	shr    $0xc,%edx
  801949:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801950:	f6 c2 01             	test   $0x1,%dl
  801953:	74 18                	je     80196d <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801955:	05 00 10 00 00       	add    $0x1000,%eax
  80195a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80195f:	75 d2                	jne    801933 <fd_alloc+0x8>
  801961:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801966:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80196b:	eb 05                	jmp    801972 <fd_alloc+0x47>
			return 0;
  80196d:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801972:	8b 55 08             	mov    0x8(%ebp),%edx
  801975:	89 02                	mov    %eax,(%edx)
}
  801977:	89 c8                	mov    %ecx,%eax
  801979:	5d                   	pop    %ebp
  80197a:	c3                   	ret    

0080197b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801981:	83 f8 1f             	cmp    $0x1f,%eax
  801984:	77 30                	ja     8019b6 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801986:	c1 e0 0c             	shl    $0xc,%eax
  801989:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80198e:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801994:	f6 c2 01             	test   $0x1,%dl
  801997:	74 24                	je     8019bd <fd_lookup+0x42>
  801999:	89 c2                	mov    %eax,%edx
  80199b:	c1 ea 0c             	shr    $0xc,%edx
  80199e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019a5:	f6 c2 01             	test   $0x1,%dl
  8019a8:	74 1a                	je     8019c4 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8019aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019ad:	89 02                	mov    %eax,(%edx)
	return 0;
  8019af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b4:	5d                   	pop    %ebp
  8019b5:	c3                   	ret    
		return -E_INVAL;
  8019b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019bb:	eb f7                	jmp    8019b4 <fd_lookup+0x39>
		return -E_INVAL;
  8019bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019c2:	eb f0                	jmp    8019b4 <fd_lookup+0x39>
  8019c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019c9:	eb e9                	jmp    8019b4 <fd_lookup+0x39>

008019cb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	53                   	push   %ebx
  8019cf:	83 ec 04             	sub    $0x4,%esp
  8019d2:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8019d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019da:	bb 04 40 80 00       	mov    $0x804004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8019df:	39 13                	cmp    %edx,(%ebx)
  8019e1:	74 37                	je     801a1a <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8019e3:	83 c0 01             	add    $0x1,%eax
  8019e6:	8b 1c 85 54 33 80 00 	mov    0x803354(,%eax,4),%ebx
  8019ed:	85 db                	test   %ebx,%ebx
  8019ef:	75 ee                	jne    8019df <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8019f1:	a1 18 50 80 00       	mov    0x805018,%eax
  8019f6:	8b 40 58             	mov    0x58(%eax),%eax
  8019f9:	83 ec 04             	sub    $0x4,%esp
  8019fc:	52                   	push   %edx
  8019fd:	50                   	push   %eax
  8019fe:	68 d8 32 80 00       	push   $0x8032d8
  801a03:	e8 50 ef ff ff       	call   800958 <cprintf>
	*dev = 0;
	return -E_INVAL;
  801a08:	83 c4 10             	add    $0x10,%esp
  801a0b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801a10:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a13:	89 1a                	mov    %ebx,(%edx)
}
  801a15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a18:	c9                   	leave  
  801a19:	c3                   	ret    
			return 0;
  801a1a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a1f:	eb ef                	jmp    801a10 <dev_lookup+0x45>

00801a21 <fd_close>:
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	57                   	push   %edi
  801a25:	56                   	push   %esi
  801a26:	53                   	push   %ebx
  801a27:	83 ec 24             	sub    $0x24,%esp
  801a2a:	8b 75 08             	mov    0x8(%ebp),%esi
  801a2d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a30:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a33:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801a34:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801a3a:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a3d:	50                   	push   %eax
  801a3e:	e8 38 ff ff ff       	call   80197b <fd_lookup>
  801a43:	89 c3                	mov    %eax,%ebx
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	78 05                	js     801a51 <fd_close+0x30>
	    || fd != fd2)
  801a4c:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801a4f:	74 16                	je     801a67 <fd_close+0x46>
		return (must_exist ? r : 0);
  801a51:	89 f8                	mov    %edi,%eax
  801a53:	84 c0                	test   %al,%al
  801a55:	b8 00 00 00 00       	mov    $0x0,%eax
  801a5a:	0f 44 d8             	cmove  %eax,%ebx
}
  801a5d:	89 d8                	mov    %ebx,%eax
  801a5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a62:	5b                   	pop    %ebx
  801a63:	5e                   	pop    %esi
  801a64:	5f                   	pop    %edi
  801a65:	5d                   	pop    %ebp
  801a66:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801a67:	83 ec 08             	sub    $0x8,%esp
  801a6a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801a6d:	50                   	push   %eax
  801a6e:	ff 36                	push   (%esi)
  801a70:	e8 56 ff ff ff       	call   8019cb <dev_lookup>
  801a75:	89 c3                	mov    %eax,%ebx
  801a77:	83 c4 10             	add    $0x10,%esp
  801a7a:	85 c0                	test   %eax,%eax
  801a7c:	78 1a                	js     801a98 <fd_close+0x77>
		if (dev->dev_close)
  801a7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a81:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801a84:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	74 0b                	je     801a98 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801a8d:	83 ec 0c             	sub    $0xc,%esp
  801a90:	56                   	push   %esi
  801a91:	ff d0                	call   *%eax
  801a93:	89 c3                	mov    %eax,%ebx
  801a95:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801a98:	83 ec 08             	sub    $0x8,%esp
  801a9b:	56                   	push   %esi
  801a9c:	6a 00                	push   $0x0
  801a9e:	e8 10 f9 ff ff       	call   8013b3 <sys_page_unmap>
	return r;
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	eb b5                	jmp    801a5d <fd_close+0x3c>

00801aa8 <close>:

int
close(int fdnum)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab1:	50                   	push   %eax
  801ab2:	ff 75 08             	push   0x8(%ebp)
  801ab5:	e8 c1 fe ff ff       	call   80197b <fd_lookup>
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	85 c0                	test   %eax,%eax
  801abf:	79 02                	jns    801ac3 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801ac1:	c9                   	leave  
  801ac2:	c3                   	ret    
		return fd_close(fd, 1);
  801ac3:	83 ec 08             	sub    $0x8,%esp
  801ac6:	6a 01                	push   $0x1
  801ac8:	ff 75 f4             	push   -0xc(%ebp)
  801acb:	e8 51 ff ff ff       	call   801a21 <fd_close>
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	eb ec                	jmp    801ac1 <close+0x19>

00801ad5 <close_all>:

void
close_all(void)
{
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	53                   	push   %ebx
  801ad9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801adc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801ae1:	83 ec 0c             	sub    $0xc,%esp
  801ae4:	53                   	push   %ebx
  801ae5:	e8 be ff ff ff       	call   801aa8 <close>
	for (i = 0; i < MAXFD; i++)
  801aea:	83 c3 01             	add    $0x1,%ebx
  801aed:	83 c4 10             	add    $0x10,%esp
  801af0:	83 fb 20             	cmp    $0x20,%ebx
  801af3:	75 ec                	jne    801ae1 <close_all+0xc>
}
  801af5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af8:	c9                   	leave  
  801af9:	c3                   	ret    

00801afa <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	57                   	push   %edi
  801afe:	56                   	push   %esi
  801aff:	53                   	push   %ebx
  801b00:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801b03:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b06:	50                   	push   %eax
  801b07:	ff 75 08             	push   0x8(%ebp)
  801b0a:	e8 6c fe ff ff       	call   80197b <fd_lookup>
  801b0f:	89 c3                	mov    %eax,%ebx
  801b11:	83 c4 10             	add    $0x10,%esp
  801b14:	85 c0                	test   %eax,%eax
  801b16:	78 7f                	js     801b97 <dup+0x9d>
		return r;
	close(newfdnum);
  801b18:	83 ec 0c             	sub    $0xc,%esp
  801b1b:	ff 75 0c             	push   0xc(%ebp)
  801b1e:	e8 85 ff ff ff       	call   801aa8 <close>

	newfd = INDEX2FD(newfdnum);
  801b23:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b26:	c1 e6 0c             	shl    $0xc,%esi
  801b29:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801b2f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b32:	89 3c 24             	mov    %edi,(%esp)
  801b35:	e8 da fd ff ff       	call   801914 <fd2data>
  801b3a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801b3c:	89 34 24             	mov    %esi,(%esp)
  801b3f:	e8 d0 fd ff ff       	call   801914 <fd2data>
  801b44:	83 c4 10             	add    $0x10,%esp
  801b47:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801b4a:	89 d8                	mov    %ebx,%eax
  801b4c:	c1 e8 16             	shr    $0x16,%eax
  801b4f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b56:	a8 01                	test   $0x1,%al
  801b58:	74 11                	je     801b6b <dup+0x71>
  801b5a:	89 d8                	mov    %ebx,%eax
  801b5c:	c1 e8 0c             	shr    $0xc,%eax
  801b5f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801b66:	f6 c2 01             	test   $0x1,%dl
  801b69:	75 36                	jne    801ba1 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801b6b:	89 f8                	mov    %edi,%eax
  801b6d:	c1 e8 0c             	shr    $0xc,%eax
  801b70:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b77:	83 ec 0c             	sub    $0xc,%esp
  801b7a:	25 07 0e 00 00       	and    $0xe07,%eax
  801b7f:	50                   	push   %eax
  801b80:	56                   	push   %esi
  801b81:	6a 00                	push   $0x0
  801b83:	57                   	push   %edi
  801b84:	6a 00                	push   $0x0
  801b86:	e8 e6 f7 ff ff       	call   801371 <sys_page_map>
  801b8b:	89 c3                	mov    %eax,%ebx
  801b8d:	83 c4 20             	add    $0x20,%esp
  801b90:	85 c0                	test   %eax,%eax
  801b92:	78 33                	js     801bc7 <dup+0xcd>
		goto err;

	return newfdnum;
  801b94:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801b97:	89 d8                	mov    %ebx,%eax
  801b99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9c:	5b                   	pop    %ebx
  801b9d:	5e                   	pop    %esi
  801b9e:	5f                   	pop    %edi
  801b9f:	5d                   	pop    %ebp
  801ba0:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801ba1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ba8:	83 ec 0c             	sub    $0xc,%esp
  801bab:	25 07 0e 00 00       	and    $0xe07,%eax
  801bb0:	50                   	push   %eax
  801bb1:	ff 75 d4             	push   -0x2c(%ebp)
  801bb4:	6a 00                	push   $0x0
  801bb6:	53                   	push   %ebx
  801bb7:	6a 00                	push   $0x0
  801bb9:	e8 b3 f7 ff ff       	call   801371 <sys_page_map>
  801bbe:	89 c3                	mov    %eax,%ebx
  801bc0:	83 c4 20             	add    $0x20,%esp
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	79 a4                	jns    801b6b <dup+0x71>
	sys_page_unmap(0, newfd);
  801bc7:	83 ec 08             	sub    $0x8,%esp
  801bca:	56                   	push   %esi
  801bcb:	6a 00                	push   $0x0
  801bcd:	e8 e1 f7 ff ff       	call   8013b3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801bd2:	83 c4 08             	add    $0x8,%esp
  801bd5:	ff 75 d4             	push   -0x2c(%ebp)
  801bd8:	6a 00                	push   $0x0
  801bda:	e8 d4 f7 ff ff       	call   8013b3 <sys_page_unmap>
	return r;
  801bdf:	83 c4 10             	add    $0x10,%esp
  801be2:	eb b3                	jmp    801b97 <dup+0x9d>

00801be4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	56                   	push   %esi
  801be8:	53                   	push   %ebx
  801be9:	83 ec 18             	sub    $0x18,%esp
  801bec:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bf2:	50                   	push   %eax
  801bf3:	56                   	push   %esi
  801bf4:	e8 82 fd ff ff       	call   80197b <fd_lookup>
  801bf9:	83 c4 10             	add    $0x10,%esp
  801bfc:	85 c0                	test   %eax,%eax
  801bfe:	78 3c                	js     801c3c <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c00:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801c03:	83 ec 08             	sub    $0x8,%esp
  801c06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c09:	50                   	push   %eax
  801c0a:	ff 33                	push   (%ebx)
  801c0c:	e8 ba fd ff ff       	call   8019cb <dev_lookup>
  801c11:	83 c4 10             	add    $0x10,%esp
  801c14:	85 c0                	test   %eax,%eax
  801c16:	78 24                	js     801c3c <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801c18:	8b 43 08             	mov    0x8(%ebx),%eax
  801c1b:	83 e0 03             	and    $0x3,%eax
  801c1e:	83 f8 01             	cmp    $0x1,%eax
  801c21:	74 20                	je     801c43 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c26:	8b 40 08             	mov    0x8(%eax),%eax
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	74 37                	je     801c64 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801c2d:	83 ec 04             	sub    $0x4,%esp
  801c30:	ff 75 10             	push   0x10(%ebp)
  801c33:	ff 75 0c             	push   0xc(%ebp)
  801c36:	53                   	push   %ebx
  801c37:	ff d0                	call   *%eax
  801c39:	83 c4 10             	add    $0x10,%esp
}
  801c3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c3f:	5b                   	pop    %ebx
  801c40:	5e                   	pop    %esi
  801c41:	5d                   	pop    %ebp
  801c42:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801c43:	a1 18 50 80 00       	mov    0x805018,%eax
  801c48:	8b 40 58             	mov    0x58(%eax),%eax
  801c4b:	83 ec 04             	sub    $0x4,%esp
  801c4e:	56                   	push   %esi
  801c4f:	50                   	push   %eax
  801c50:	68 19 33 80 00       	push   $0x803319
  801c55:	e8 fe ec ff ff       	call   800958 <cprintf>
		return -E_INVAL;
  801c5a:	83 c4 10             	add    $0x10,%esp
  801c5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c62:	eb d8                	jmp    801c3c <read+0x58>
		return -E_NOT_SUPP;
  801c64:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c69:	eb d1                	jmp    801c3c <read+0x58>

00801c6b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801c6b:	55                   	push   %ebp
  801c6c:	89 e5                	mov    %esp,%ebp
  801c6e:	57                   	push   %edi
  801c6f:	56                   	push   %esi
  801c70:	53                   	push   %ebx
  801c71:	83 ec 0c             	sub    $0xc,%esp
  801c74:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c77:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801c7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c7f:	eb 02                	jmp    801c83 <readn+0x18>
  801c81:	01 c3                	add    %eax,%ebx
  801c83:	39 f3                	cmp    %esi,%ebx
  801c85:	73 21                	jae    801ca8 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801c87:	83 ec 04             	sub    $0x4,%esp
  801c8a:	89 f0                	mov    %esi,%eax
  801c8c:	29 d8                	sub    %ebx,%eax
  801c8e:	50                   	push   %eax
  801c8f:	89 d8                	mov    %ebx,%eax
  801c91:	03 45 0c             	add    0xc(%ebp),%eax
  801c94:	50                   	push   %eax
  801c95:	57                   	push   %edi
  801c96:	e8 49 ff ff ff       	call   801be4 <read>
		if (m < 0)
  801c9b:	83 c4 10             	add    $0x10,%esp
  801c9e:	85 c0                	test   %eax,%eax
  801ca0:	78 04                	js     801ca6 <readn+0x3b>
			return m;
		if (m == 0)
  801ca2:	75 dd                	jne    801c81 <readn+0x16>
  801ca4:	eb 02                	jmp    801ca8 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801ca6:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801ca8:	89 d8                	mov    %ebx,%eax
  801caa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5f                   	pop    %edi
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    

00801cb2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	56                   	push   %esi
  801cb6:	53                   	push   %ebx
  801cb7:	83 ec 18             	sub    $0x18,%esp
  801cba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801cbd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cc0:	50                   	push   %eax
  801cc1:	53                   	push   %ebx
  801cc2:	e8 b4 fc ff ff       	call   80197b <fd_lookup>
  801cc7:	83 c4 10             	add    $0x10,%esp
  801cca:	85 c0                	test   %eax,%eax
  801ccc:	78 37                	js     801d05 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cce:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801cd1:	83 ec 08             	sub    $0x8,%esp
  801cd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd7:	50                   	push   %eax
  801cd8:	ff 36                	push   (%esi)
  801cda:	e8 ec fc ff ff       	call   8019cb <dev_lookup>
  801cdf:	83 c4 10             	add    $0x10,%esp
  801ce2:	85 c0                	test   %eax,%eax
  801ce4:	78 1f                	js     801d05 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ce6:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801cea:	74 20                	je     801d0c <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cef:	8b 40 0c             	mov    0xc(%eax),%eax
  801cf2:	85 c0                	test   %eax,%eax
  801cf4:	74 37                	je     801d2d <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801cf6:	83 ec 04             	sub    $0x4,%esp
  801cf9:	ff 75 10             	push   0x10(%ebp)
  801cfc:	ff 75 0c             	push   0xc(%ebp)
  801cff:	56                   	push   %esi
  801d00:	ff d0                	call   *%eax
  801d02:	83 c4 10             	add    $0x10,%esp
}
  801d05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d08:	5b                   	pop    %ebx
  801d09:	5e                   	pop    %esi
  801d0a:	5d                   	pop    %ebp
  801d0b:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801d0c:	a1 18 50 80 00       	mov    0x805018,%eax
  801d11:	8b 40 58             	mov    0x58(%eax),%eax
  801d14:	83 ec 04             	sub    $0x4,%esp
  801d17:	53                   	push   %ebx
  801d18:	50                   	push   %eax
  801d19:	68 35 33 80 00       	push   $0x803335
  801d1e:	e8 35 ec ff ff       	call   800958 <cprintf>
		return -E_INVAL;
  801d23:	83 c4 10             	add    $0x10,%esp
  801d26:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d2b:	eb d8                	jmp    801d05 <write+0x53>
		return -E_NOT_SUPP;
  801d2d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801d32:	eb d1                	jmp    801d05 <write+0x53>

00801d34 <seek>:

int
seek(int fdnum, off_t offset)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3d:	50                   	push   %eax
  801d3e:	ff 75 08             	push   0x8(%ebp)
  801d41:	e8 35 fc ff ff       	call   80197b <fd_lookup>
  801d46:	83 c4 10             	add    $0x10,%esp
  801d49:	85 c0                	test   %eax,%eax
  801d4b:	78 0e                	js     801d5b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801d4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d53:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801d56:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d5b:	c9                   	leave  
  801d5c:	c3                   	ret    

00801d5d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	56                   	push   %esi
  801d61:	53                   	push   %ebx
  801d62:	83 ec 18             	sub    $0x18,%esp
  801d65:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d68:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d6b:	50                   	push   %eax
  801d6c:	53                   	push   %ebx
  801d6d:	e8 09 fc ff ff       	call   80197b <fd_lookup>
  801d72:	83 c4 10             	add    $0x10,%esp
  801d75:	85 c0                	test   %eax,%eax
  801d77:	78 34                	js     801dad <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d79:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801d7c:	83 ec 08             	sub    $0x8,%esp
  801d7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d82:	50                   	push   %eax
  801d83:	ff 36                	push   (%esi)
  801d85:	e8 41 fc ff ff       	call   8019cb <dev_lookup>
  801d8a:	83 c4 10             	add    $0x10,%esp
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	78 1c                	js     801dad <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801d91:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801d95:	74 1d                	je     801db4 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9a:	8b 40 18             	mov    0x18(%eax),%eax
  801d9d:	85 c0                	test   %eax,%eax
  801d9f:	74 34                	je     801dd5 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801da1:	83 ec 08             	sub    $0x8,%esp
  801da4:	ff 75 0c             	push   0xc(%ebp)
  801da7:	56                   	push   %esi
  801da8:	ff d0                	call   *%eax
  801daa:	83 c4 10             	add    $0x10,%esp
}
  801dad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db0:	5b                   	pop    %ebx
  801db1:	5e                   	pop    %esi
  801db2:	5d                   	pop    %ebp
  801db3:	c3                   	ret    
			thisenv->env_id, fdnum);
  801db4:	a1 18 50 80 00       	mov    0x805018,%eax
  801db9:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801dbc:	83 ec 04             	sub    $0x4,%esp
  801dbf:	53                   	push   %ebx
  801dc0:	50                   	push   %eax
  801dc1:	68 f8 32 80 00       	push   $0x8032f8
  801dc6:	e8 8d eb ff ff       	call   800958 <cprintf>
		return -E_INVAL;
  801dcb:	83 c4 10             	add    $0x10,%esp
  801dce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801dd3:	eb d8                	jmp    801dad <ftruncate+0x50>
		return -E_NOT_SUPP;
  801dd5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801dda:	eb d1                	jmp    801dad <ftruncate+0x50>

00801ddc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	56                   	push   %esi
  801de0:	53                   	push   %ebx
  801de1:	83 ec 18             	sub    $0x18,%esp
  801de4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801de7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dea:	50                   	push   %eax
  801deb:	ff 75 08             	push   0x8(%ebp)
  801dee:	e8 88 fb ff ff       	call   80197b <fd_lookup>
  801df3:	83 c4 10             	add    $0x10,%esp
  801df6:	85 c0                	test   %eax,%eax
  801df8:	78 49                	js     801e43 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801dfa:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801dfd:	83 ec 08             	sub    $0x8,%esp
  801e00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e03:	50                   	push   %eax
  801e04:	ff 36                	push   (%esi)
  801e06:	e8 c0 fb ff ff       	call   8019cb <dev_lookup>
  801e0b:	83 c4 10             	add    $0x10,%esp
  801e0e:	85 c0                	test   %eax,%eax
  801e10:	78 31                	js     801e43 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e15:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801e19:	74 2f                	je     801e4a <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801e1b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801e1e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801e25:	00 00 00 
	stat->st_isdir = 0;
  801e28:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e2f:	00 00 00 
	stat->st_dev = dev;
  801e32:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801e38:	83 ec 08             	sub    $0x8,%esp
  801e3b:	53                   	push   %ebx
  801e3c:	56                   	push   %esi
  801e3d:	ff 50 14             	call   *0x14(%eax)
  801e40:	83 c4 10             	add    $0x10,%esp
}
  801e43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e46:	5b                   	pop    %ebx
  801e47:	5e                   	pop    %esi
  801e48:	5d                   	pop    %ebp
  801e49:	c3                   	ret    
		return -E_NOT_SUPP;
  801e4a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801e4f:	eb f2                	jmp    801e43 <fstat+0x67>

00801e51 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
  801e54:	56                   	push   %esi
  801e55:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801e56:	83 ec 08             	sub    $0x8,%esp
  801e59:	6a 00                	push   $0x0
  801e5b:	ff 75 08             	push   0x8(%ebp)
  801e5e:	e8 e4 01 00 00       	call   802047 <open>
  801e63:	89 c3                	mov    %eax,%ebx
  801e65:	83 c4 10             	add    $0x10,%esp
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	78 1b                	js     801e87 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801e6c:	83 ec 08             	sub    $0x8,%esp
  801e6f:	ff 75 0c             	push   0xc(%ebp)
  801e72:	50                   	push   %eax
  801e73:	e8 64 ff ff ff       	call   801ddc <fstat>
  801e78:	89 c6                	mov    %eax,%esi
	close(fd);
  801e7a:	89 1c 24             	mov    %ebx,(%esp)
  801e7d:	e8 26 fc ff ff       	call   801aa8 <close>
	return r;
  801e82:	83 c4 10             	add    $0x10,%esp
  801e85:	89 f3                	mov    %esi,%ebx
}
  801e87:	89 d8                	mov    %ebx,%eax
  801e89:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e8c:	5b                   	pop    %ebx
  801e8d:	5e                   	pop    %esi
  801e8e:	5d                   	pop    %ebp
  801e8f:	c3                   	ret    

00801e90 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	56                   	push   %esi
  801e94:	53                   	push   %ebx
  801e95:	89 c6                	mov    %eax,%esi
  801e97:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801e99:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  801ea0:	74 27                	je     801ec9 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ea2:	6a 07                	push   $0x7
  801ea4:	68 00 60 80 00       	push   $0x806000
  801ea9:	56                   	push   %esi
  801eaa:	ff 35 00 70 80 00    	push   0x807000
  801eb0:	e8 bc f9 ff ff       	call   801871 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801eb5:	83 c4 0c             	add    $0xc,%esp
  801eb8:	6a 00                	push   $0x0
  801eba:	53                   	push   %ebx
  801ebb:	6a 00                	push   $0x0
  801ebd:	e8 3f f9 ff ff       	call   801801 <ipc_recv>
}
  801ec2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ec5:	5b                   	pop    %ebx
  801ec6:	5e                   	pop    %esi
  801ec7:	5d                   	pop    %ebp
  801ec8:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ec9:	83 ec 0c             	sub    $0xc,%esp
  801ecc:	6a 01                	push   $0x1
  801ece:	e8 f2 f9 ff ff       	call   8018c5 <ipc_find_env>
  801ed3:	a3 00 70 80 00       	mov    %eax,0x807000
  801ed8:	83 c4 10             	add    $0x10,%esp
  801edb:	eb c5                	jmp    801ea2 <fsipc+0x12>

00801edd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801edd:	55                   	push   %ebp
  801ede:	89 e5                	mov    %esp,%ebp
  801ee0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ee3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee6:	8b 40 0c             	mov    0xc(%eax),%eax
  801ee9:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801eee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef1:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ef6:	ba 00 00 00 00       	mov    $0x0,%edx
  801efb:	b8 02 00 00 00       	mov    $0x2,%eax
  801f00:	e8 8b ff ff ff       	call   801e90 <fsipc>
}
  801f05:	c9                   	leave  
  801f06:	c3                   	ret    

00801f07 <devfile_flush>:
{
  801f07:	55                   	push   %ebp
  801f08:	89 e5                	mov    %esp,%ebp
  801f0a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801f0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f10:	8b 40 0c             	mov    0xc(%eax),%eax
  801f13:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801f18:	ba 00 00 00 00       	mov    $0x0,%edx
  801f1d:	b8 06 00 00 00       	mov    $0x6,%eax
  801f22:	e8 69 ff ff ff       	call   801e90 <fsipc>
}
  801f27:	c9                   	leave  
  801f28:	c3                   	ret    

00801f29 <devfile_stat>:
{
  801f29:	55                   	push   %ebp
  801f2a:	89 e5                	mov    %esp,%ebp
  801f2c:	53                   	push   %ebx
  801f2d:	83 ec 04             	sub    $0x4,%esp
  801f30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801f33:	8b 45 08             	mov    0x8(%ebp),%eax
  801f36:	8b 40 0c             	mov    0xc(%eax),%eax
  801f39:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801f3e:	ba 00 00 00 00       	mov    $0x0,%edx
  801f43:	b8 05 00 00 00       	mov    $0x5,%eax
  801f48:	e8 43 ff ff ff       	call   801e90 <fsipc>
  801f4d:	85 c0                	test   %eax,%eax
  801f4f:	78 2c                	js     801f7d <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801f51:	83 ec 08             	sub    $0x8,%esp
  801f54:	68 00 60 80 00       	push   $0x806000
  801f59:	53                   	push   %ebx
  801f5a:	e8 d3 ef ff ff       	call   800f32 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801f5f:	a1 80 60 80 00       	mov    0x806080,%eax
  801f64:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801f6a:	a1 84 60 80 00       	mov    0x806084,%eax
  801f6f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801f75:	83 c4 10             	add    $0x10,%esp
  801f78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f80:	c9                   	leave  
  801f81:	c3                   	ret    

00801f82 <devfile_write>:
{
  801f82:	55                   	push   %ebp
  801f83:	89 e5                	mov    %esp,%ebp
  801f85:	83 ec 0c             	sub    $0xc,%esp
  801f88:	8b 45 10             	mov    0x10(%ebp),%eax
  801f8b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801f90:	39 d0                	cmp    %edx,%eax
  801f92:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801f95:	8b 55 08             	mov    0x8(%ebp),%edx
  801f98:	8b 52 0c             	mov    0xc(%edx),%edx
  801f9b:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801fa1:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801fa6:	50                   	push   %eax
  801fa7:	ff 75 0c             	push   0xc(%ebp)
  801faa:	68 08 60 80 00       	push   $0x806008
  801faf:	e8 14 f1 ff ff       	call   8010c8 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801fb4:	ba 00 00 00 00       	mov    $0x0,%edx
  801fb9:	b8 04 00 00 00       	mov    $0x4,%eax
  801fbe:	e8 cd fe ff ff       	call   801e90 <fsipc>
}
  801fc3:	c9                   	leave  
  801fc4:	c3                   	ret    

00801fc5 <devfile_read>:
{
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
  801fc8:	56                   	push   %esi
  801fc9:	53                   	push   %ebx
  801fca:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801fcd:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd0:	8b 40 0c             	mov    0xc(%eax),%eax
  801fd3:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801fd8:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801fde:	ba 00 00 00 00       	mov    $0x0,%edx
  801fe3:	b8 03 00 00 00       	mov    $0x3,%eax
  801fe8:	e8 a3 fe ff ff       	call   801e90 <fsipc>
  801fed:	89 c3                	mov    %eax,%ebx
  801fef:	85 c0                	test   %eax,%eax
  801ff1:	78 1f                	js     802012 <devfile_read+0x4d>
	assert(r <= n);
  801ff3:	39 f0                	cmp    %esi,%eax
  801ff5:	77 24                	ja     80201b <devfile_read+0x56>
	assert(r <= PGSIZE);
  801ff7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ffc:	7f 33                	jg     802031 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ffe:	83 ec 04             	sub    $0x4,%esp
  802001:	50                   	push   %eax
  802002:	68 00 60 80 00       	push   $0x806000
  802007:	ff 75 0c             	push   0xc(%ebp)
  80200a:	e8 b9 f0 ff ff       	call   8010c8 <memmove>
	return r;
  80200f:	83 c4 10             	add    $0x10,%esp
}
  802012:	89 d8                	mov    %ebx,%eax
  802014:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802017:	5b                   	pop    %ebx
  802018:	5e                   	pop    %esi
  802019:	5d                   	pop    %ebp
  80201a:	c3                   	ret    
	assert(r <= n);
  80201b:	68 68 33 80 00       	push   $0x803368
  802020:	68 6f 33 80 00       	push   $0x80336f
  802025:	6a 7c                	push   $0x7c
  802027:	68 84 33 80 00       	push   $0x803384
  80202c:	e8 4c e8 ff ff       	call   80087d <_panic>
	assert(r <= PGSIZE);
  802031:	68 8f 33 80 00       	push   $0x80338f
  802036:	68 6f 33 80 00       	push   $0x80336f
  80203b:	6a 7d                	push   $0x7d
  80203d:	68 84 33 80 00       	push   $0x803384
  802042:	e8 36 e8 ff ff       	call   80087d <_panic>

00802047 <open>:
{
  802047:	55                   	push   %ebp
  802048:	89 e5                	mov    %esp,%ebp
  80204a:	56                   	push   %esi
  80204b:	53                   	push   %ebx
  80204c:	83 ec 1c             	sub    $0x1c,%esp
  80204f:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  802052:	56                   	push   %esi
  802053:	e8 9f ee ff ff       	call   800ef7 <strlen>
  802058:	83 c4 10             	add    $0x10,%esp
  80205b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802060:	7f 6c                	jg     8020ce <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  802062:	83 ec 0c             	sub    $0xc,%esp
  802065:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802068:	50                   	push   %eax
  802069:	e8 bd f8 ff ff       	call   80192b <fd_alloc>
  80206e:	89 c3                	mov    %eax,%ebx
  802070:	83 c4 10             	add    $0x10,%esp
  802073:	85 c0                	test   %eax,%eax
  802075:	78 3c                	js     8020b3 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  802077:	83 ec 08             	sub    $0x8,%esp
  80207a:	56                   	push   %esi
  80207b:	68 00 60 80 00       	push   $0x806000
  802080:	e8 ad ee ff ff       	call   800f32 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802085:	8b 45 0c             	mov    0xc(%ebp),%eax
  802088:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80208d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802090:	b8 01 00 00 00       	mov    $0x1,%eax
  802095:	e8 f6 fd ff ff       	call   801e90 <fsipc>
  80209a:	89 c3                	mov    %eax,%ebx
  80209c:	83 c4 10             	add    $0x10,%esp
  80209f:	85 c0                	test   %eax,%eax
  8020a1:	78 19                	js     8020bc <open+0x75>
	return fd2num(fd);
  8020a3:	83 ec 0c             	sub    $0xc,%esp
  8020a6:	ff 75 f4             	push   -0xc(%ebp)
  8020a9:	e8 56 f8 ff ff       	call   801904 <fd2num>
  8020ae:	89 c3                	mov    %eax,%ebx
  8020b0:	83 c4 10             	add    $0x10,%esp
}
  8020b3:	89 d8                	mov    %ebx,%eax
  8020b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020b8:	5b                   	pop    %ebx
  8020b9:	5e                   	pop    %esi
  8020ba:	5d                   	pop    %ebp
  8020bb:	c3                   	ret    
		fd_close(fd, 0);
  8020bc:	83 ec 08             	sub    $0x8,%esp
  8020bf:	6a 00                	push   $0x0
  8020c1:	ff 75 f4             	push   -0xc(%ebp)
  8020c4:	e8 58 f9 ff ff       	call   801a21 <fd_close>
		return r;
  8020c9:	83 c4 10             	add    $0x10,%esp
  8020cc:	eb e5                	jmp    8020b3 <open+0x6c>
		return -E_BAD_PATH;
  8020ce:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8020d3:	eb de                	jmp    8020b3 <open+0x6c>

008020d5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8020d5:	55                   	push   %ebp
  8020d6:	89 e5                	mov    %esp,%ebp
  8020d8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8020db:	ba 00 00 00 00       	mov    $0x0,%edx
  8020e0:	b8 08 00 00 00       	mov    $0x8,%eax
  8020e5:	e8 a6 fd ff ff       	call   801e90 <fsipc>
}
  8020ea:	c9                   	leave  
  8020eb:	c3                   	ret    

008020ec <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8020ec:	55                   	push   %ebp
  8020ed:	89 e5                	mov    %esp,%ebp
  8020ef:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8020f2:	68 9b 33 80 00       	push   $0x80339b
  8020f7:	ff 75 0c             	push   0xc(%ebp)
  8020fa:	e8 33 ee ff ff       	call   800f32 <strcpy>
	return 0;
}
  8020ff:	b8 00 00 00 00       	mov    $0x0,%eax
  802104:	c9                   	leave  
  802105:	c3                   	ret    

00802106 <devsock_close>:
{
  802106:	55                   	push   %ebp
  802107:	89 e5                	mov    %esp,%ebp
  802109:	53                   	push   %ebx
  80210a:	83 ec 10             	sub    $0x10,%esp
  80210d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802110:	53                   	push   %ebx
  802111:	e8 98 09 00 00       	call   802aae <pageref>
  802116:	89 c2                	mov    %eax,%edx
  802118:	83 c4 10             	add    $0x10,%esp
		return 0;
  80211b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  802120:	83 fa 01             	cmp    $0x1,%edx
  802123:	74 05                	je     80212a <devsock_close+0x24>
}
  802125:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802128:	c9                   	leave  
  802129:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  80212a:	83 ec 0c             	sub    $0xc,%esp
  80212d:	ff 73 0c             	push   0xc(%ebx)
  802130:	e8 b7 02 00 00       	call   8023ec <nsipc_close>
  802135:	83 c4 10             	add    $0x10,%esp
  802138:	eb eb                	jmp    802125 <devsock_close+0x1f>

0080213a <devsock_write>:
{
  80213a:	55                   	push   %ebp
  80213b:	89 e5                	mov    %esp,%ebp
  80213d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802140:	6a 00                	push   $0x0
  802142:	ff 75 10             	push   0x10(%ebp)
  802145:	ff 75 0c             	push   0xc(%ebp)
  802148:	8b 45 08             	mov    0x8(%ebp),%eax
  80214b:	ff 70 0c             	push   0xc(%eax)
  80214e:	e8 79 03 00 00       	call   8024cc <nsipc_send>
}
  802153:	c9                   	leave  
  802154:	c3                   	ret    

00802155 <devsock_read>:
{
  802155:	55                   	push   %ebp
  802156:	89 e5                	mov    %esp,%ebp
  802158:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80215b:	6a 00                	push   $0x0
  80215d:	ff 75 10             	push   0x10(%ebp)
  802160:	ff 75 0c             	push   0xc(%ebp)
  802163:	8b 45 08             	mov    0x8(%ebp),%eax
  802166:	ff 70 0c             	push   0xc(%eax)
  802169:	e8 ef 02 00 00       	call   80245d <nsipc_recv>
}
  80216e:	c9                   	leave  
  80216f:	c3                   	ret    

00802170 <fd2sockid>:
{
  802170:	55                   	push   %ebp
  802171:	89 e5                	mov    %esp,%ebp
  802173:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  802176:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802179:	52                   	push   %edx
  80217a:	50                   	push   %eax
  80217b:	e8 fb f7 ff ff       	call   80197b <fd_lookup>
  802180:	83 c4 10             	add    $0x10,%esp
  802183:	85 c0                	test   %eax,%eax
  802185:	78 10                	js     802197 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  802187:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80218a:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  802190:	39 08                	cmp    %ecx,(%eax)
  802192:	75 05                	jne    802199 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  802194:	8b 40 0c             	mov    0xc(%eax),%eax
}
  802197:	c9                   	leave  
  802198:	c3                   	ret    
		return -E_NOT_SUPP;
  802199:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80219e:	eb f7                	jmp    802197 <fd2sockid+0x27>

008021a0 <alloc_sockfd>:
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	56                   	push   %esi
  8021a4:	53                   	push   %ebx
  8021a5:	83 ec 1c             	sub    $0x1c,%esp
  8021a8:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8021aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ad:	50                   	push   %eax
  8021ae:	e8 78 f7 ff ff       	call   80192b <fd_alloc>
  8021b3:	89 c3                	mov    %eax,%ebx
  8021b5:	83 c4 10             	add    $0x10,%esp
  8021b8:	85 c0                	test   %eax,%eax
  8021ba:	78 43                	js     8021ff <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8021bc:	83 ec 04             	sub    $0x4,%esp
  8021bf:	68 07 04 00 00       	push   $0x407
  8021c4:	ff 75 f4             	push   -0xc(%ebp)
  8021c7:	6a 00                	push   $0x0
  8021c9:	e8 60 f1 ff ff       	call   80132e <sys_page_alloc>
  8021ce:	89 c3                	mov    %eax,%ebx
  8021d0:	83 c4 10             	add    $0x10,%esp
  8021d3:	85 c0                	test   %eax,%eax
  8021d5:	78 28                	js     8021ff <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8021d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021da:	8b 15 20 40 80 00    	mov    0x804020,%edx
  8021e0:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8021e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8021ec:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8021ef:	83 ec 0c             	sub    $0xc,%esp
  8021f2:	50                   	push   %eax
  8021f3:	e8 0c f7 ff ff       	call   801904 <fd2num>
  8021f8:	89 c3                	mov    %eax,%ebx
  8021fa:	83 c4 10             	add    $0x10,%esp
  8021fd:	eb 0c                	jmp    80220b <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8021ff:	83 ec 0c             	sub    $0xc,%esp
  802202:	56                   	push   %esi
  802203:	e8 e4 01 00 00       	call   8023ec <nsipc_close>
		return r;
  802208:	83 c4 10             	add    $0x10,%esp
}
  80220b:	89 d8                	mov    %ebx,%eax
  80220d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802210:	5b                   	pop    %ebx
  802211:	5e                   	pop    %esi
  802212:	5d                   	pop    %ebp
  802213:	c3                   	ret    

00802214 <accept>:
{
  802214:	55                   	push   %ebp
  802215:	89 e5                	mov    %esp,%ebp
  802217:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80221a:	8b 45 08             	mov    0x8(%ebp),%eax
  80221d:	e8 4e ff ff ff       	call   802170 <fd2sockid>
  802222:	85 c0                	test   %eax,%eax
  802224:	78 1b                	js     802241 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802226:	83 ec 04             	sub    $0x4,%esp
  802229:	ff 75 10             	push   0x10(%ebp)
  80222c:	ff 75 0c             	push   0xc(%ebp)
  80222f:	50                   	push   %eax
  802230:	e8 0e 01 00 00       	call   802343 <nsipc_accept>
  802235:	83 c4 10             	add    $0x10,%esp
  802238:	85 c0                	test   %eax,%eax
  80223a:	78 05                	js     802241 <accept+0x2d>
	return alloc_sockfd(r);
  80223c:	e8 5f ff ff ff       	call   8021a0 <alloc_sockfd>
}
  802241:	c9                   	leave  
  802242:	c3                   	ret    

00802243 <bind>:
{
  802243:	55                   	push   %ebp
  802244:	89 e5                	mov    %esp,%ebp
  802246:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802249:	8b 45 08             	mov    0x8(%ebp),%eax
  80224c:	e8 1f ff ff ff       	call   802170 <fd2sockid>
  802251:	85 c0                	test   %eax,%eax
  802253:	78 12                	js     802267 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  802255:	83 ec 04             	sub    $0x4,%esp
  802258:	ff 75 10             	push   0x10(%ebp)
  80225b:	ff 75 0c             	push   0xc(%ebp)
  80225e:	50                   	push   %eax
  80225f:	e8 31 01 00 00       	call   802395 <nsipc_bind>
  802264:	83 c4 10             	add    $0x10,%esp
}
  802267:	c9                   	leave  
  802268:	c3                   	ret    

00802269 <shutdown>:
{
  802269:	55                   	push   %ebp
  80226a:	89 e5                	mov    %esp,%ebp
  80226c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80226f:	8b 45 08             	mov    0x8(%ebp),%eax
  802272:	e8 f9 fe ff ff       	call   802170 <fd2sockid>
  802277:	85 c0                	test   %eax,%eax
  802279:	78 0f                	js     80228a <shutdown+0x21>
	return nsipc_shutdown(r, how);
  80227b:	83 ec 08             	sub    $0x8,%esp
  80227e:	ff 75 0c             	push   0xc(%ebp)
  802281:	50                   	push   %eax
  802282:	e8 43 01 00 00       	call   8023ca <nsipc_shutdown>
  802287:	83 c4 10             	add    $0x10,%esp
}
  80228a:	c9                   	leave  
  80228b:	c3                   	ret    

0080228c <connect>:
{
  80228c:	55                   	push   %ebp
  80228d:	89 e5                	mov    %esp,%ebp
  80228f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802292:	8b 45 08             	mov    0x8(%ebp),%eax
  802295:	e8 d6 fe ff ff       	call   802170 <fd2sockid>
  80229a:	85 c0                	test   %eax,%eax
  80229c:	78 12                	js     8022b0 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  80229e:	83 ec 04             	sub    $0x4,%esp
  8022a1:	ff 75 10             	push   0x10(%ebp)
  8022a4:	ff 75 0c             	push   0xc(%ebp)
  8022a7:	50                   	push   %eax
  8022a8:	e8 59 01 00 00       	call   802406 <nsipc_connect>
  8022ad:	83 c4 10             	add    $0x10,%esp
}
  8022b0:	c9                   	leave  
  8022b1:	c3                   	ret    

008022b2 <listen>:
{
  8022b2:	55                   	push   %ebp
  8022b3:	89 e5                	mov    %esp,%ebp
  8022b5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8022b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bb:	e8 b0 fe ff ff       	call   802170 <fd2sockid>
  8022c0:	85 c0                	test   %eax,%eax
  8022c2:	78 0f                	js     8022d3 <listen+0x21>
	return nsipc_listen(r, backlog);
  8022c4:	83 ec 08             	sub    $0x8,%esp
  8022c7:	ff 75 0c             	push   0xc(%ebp)
  8022ca:	50                   	push   %eax
  8022cb:	e8 6b 01 00 00       	call   80243b <nsipc_listen>
  8022d0:	83 c4 10             	add    $0x10,%esp
}
  8022d3:	c9                   	leave  
  8022d4:	c3                   	ret    

008022d5 <socket>:

int
socket(int domain, int type, int protocol)
{
  8022d5:	55                   	push   %ebp
  8022d6:	89 e5                	mov    %esp,%ebp
  8022d8:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8022db:	ff 75 10             	push   0x10(%ebp)
  8022de:	ff 75 0c             	push   0xc(%ebp)
  8022e1:	ff 75 08             	push   0x8(%ebp)
  8022e4:	e8 41 02 00 00       	call   80252a <nsipc_socket>
  8022e9:	83 c4 10             	add    $0x10,%esp
  8022ec:	85 c0                	test   %eax,%eax
  8022ee:	78 05                	js     8022f5 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8022f0:	e8 ab fe ff ff       	call   8021a0 <alloc_sockfd>
}
  8022f5:	c9                   	leave  
  8022f6:	c3                   	ret    

008022f7 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8022f7:	55                   	push   %ebp
  8022f8:	89 e5                	mov    %esp,%ebp
  8022fa:	53                   	push   %ebx
  8022fb:	83 ec 04             	sub    $0x4,%esp
  8022fe:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802300:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  802307:	74 26                	je     80232f <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802309:	6a 07                	push   $0x7
  80230b:	68 00 80 80 00       	push   $0x808000
  802310:	53                   	push   %ebx
  802311:	ff 35 00 90 80 00    	push   0x809000
  802317:	e8 55 f5 ff ff       	call   801871 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80231c:	83 c4 0c             	add    $0xc,%esp
  80231f:	6a 00                	push   $0x0
  802321:	6a 00                	push   $0x0
  802323:	6a 00                	push   $0x0
  802325:	e8 d7 f4 ff ff       	call   801801 <ipc_recv>
}
  80232a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80232d:	c9                   	leave  
  80232e:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80232f:	83 ec 0c             	sub    $0xc,%esp
  802332:	6a 02                	push   $0x2
  802334:	e8 8c f5 ff ff       	call   8018c5 <ipc_find_env>
  802339:	a3 00 90 80 00       	mov    %eax,0x809000
  80233e:	83 c4 10             	add    $0x10,%esp
  802341:	eb c6                	jmp    802309 <nsipc+0x12>

00802343 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802343:	55                   	push   %ebp
  802344:	89 e5                	mov    %esp,%ebp
  802346:	56                   	push   %esi
  802347:	53                   	push   %ebx
  802348:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80234b:	8b 45 08             	mov    0x8(%ebp),%eax
  80234e:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802353:	8b 06                	mov    (%esi),%eax
  802355:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80235a:	b8 01 00 00 00       	mov    $0x1,%eax
  80235f:	e8 93 ff ff ff       	call   8022f7 <nsipc>
  802364:	89 c3                	mov    %eax,%ebx
  802366:	85 c0                	test   %eax,%eax
  802368:	79 09                	jns    802373 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  80236a:	89 d8                	mov    %ebx,%eax
  80236c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80236f:	5b                   	pop    %ebx
  802370:	5e                   	pop    %esi
  802371:	5d                   	pop    %ebp
  802372:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802373:	83 ec 04             	sub    $0x4,%esp
  802376:	ff 35 10 80 80 00    	push   0x808010
  80237c:	68 00 80 80 00       	push   $0x808000
  802381:	ff 75 0c             	push   0xc(%ebp)
  802384:	e8 3f ed ff ff       	call   8010c8 <memmove>
		*addrlen = ret->ret_addrlen;
  802389:	a1 10 80 80 00       	mov    0x808010,%eax
  80238e:	89 06                	mov    %eax,(%esi)
  802390:	83 c4 10             	add    $0x10,%esp
	return r;
  802393:	eb d5                	jmp    80236a <nsipc_accept+0x27>

00802395 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802395:	55                   	push   %ebp
  802396:	89 e5                	mov    %esp,%ebp
  802398:	53                   	push   %ebx
  802399:	83 ec 08             	sub    $0x8,%esp
  80239c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80239f:	8b 45 08             	mov    0x8(%ebp),%eax
  8023a2:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8023a7:	53                   	push   %ebx
  8023a8:	ff 75 0c             	push   0xc(%ebp)
  8023ab:	68 04 80 80 00       	push   $0x808004
  8023b0:	e8 13 ed ff ff       	call   8010c8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8023b5:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  8023bb:	b8 02 00 00 00       	mov    $0x2,%eax
  8023c0:	e8 32 ff ff ff       	call   8022f7 <nsipc>
}
  8023c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023c8:	c9                   	leave  
  8023c9:	c3                   	ret    

008023ca <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8023ca:	55                   	push   %ebp
  8023cb:	89 e5                	mov    %esp,%ebp
  8023cd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8023d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d3:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  8023d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023db:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  8023e0:	b8 03 00 00 00       	mov    $0x3,%eax
  8023e5:	e8 0d ff ff ff       	call   8022f7 <nsipc>
}
  8023ea:	c9                   	leave  
  8023eb:	c3                   	ret    

008023ec <nsipc_close>:

int
nsipc_close(int s)
{
  8023ec:	55                   	push   %ebp
  8023ed:	89 e5                	mov    %esp,%ebp
  8023ef:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8023f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f5:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  8023fa:	b8 04 00 00 00       	mov    $0x4,%eax
  8023ff:	e8 f3 fe ff ff       	call   8022f7 <nsipc>
}
  802404:	c9                   	leave  
  802405:	c3                   	ret    

00802406 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802406:	55                   	push   %ebp
  802407:	89 e5                	mov    %esp,%ebp
  802409:	53                   	push   %ebx
  80240a:	83 ec 08             	sub    $0x8,%esp
  80240d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802410:	8b 45 08             	mov    0x8(%ebp),%eax
  802413:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802418:	53                   	push   %ebx
  802419:	ff 75 0c             	push   0xc(%ebp)
  80241c:	68 04 80 80 00       	push   $0x808004
  802421:	e8 a2 ec ff ff       	call   8010c8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802426:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  80242c:	b8 05 00 00 00       	mov    $0x5,%eax
  802431:	e8 c1 fe ff ff       	call   8022f7 <nsipc>
}
  802436:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802439:	c9                   	leave  
  80243a:	c3                   	ret    

0080243b <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80243b:	55                   	push   %ebp
  80243c:	89 e5                	mov    %esp,%ebp
  80243e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802441:	8b 45 08             	mov    0x8(%ebp),%eax
  802444:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  802449:	8b 45 0c             	mov    0xc(%ebp),%eax
  80244c:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  802451:	b8 06 00 00 00       	mov    $0x6,%eax
  802456:	e8 9c fe ff ff       	call   8022f7 <nsipc>
}
  80245b:	c9                   	leave  
  80245c:	c3                   	ret    

0080245d <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80245d:	55                   	push   %ebp
  80245e:	89 e5                	mov    %esp,%ebp
  802460:	56                   	push   %esi
  802461:	53                   	push   %ebx
  802462:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802465:	8b 45 08             	mov    0x8(%ebp),%eax
  802468:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  80246d:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  802473:	8b 45 14             	mov    0x14(%ebp),%eax
  802476:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80247b:	b8 07 00 00 00       	mov    $0x7,%eax
  802480:	e8 72 fe ff ff       	call   8022f7 <nsipc>
  802485:	89 c3                	mov    %eax,%ebx
  802487:	85 c0                	test   %eax,%eax
  802489:	78 22                	js     8024ad <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  80248b:	b8 3f 06 00 00       	mov    $0x63f,%eax
  802490:	39 c6                	cmp    %eax,%esi
  802492:	0f 4e c6             	cmovle %esi,%eax
  802495:	39 c3                	cmp    %eax,%ebx
  802497:	7f 1d                	jg     8024b6 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802499:	83 ec 04             	sub    $0x4,%esp
  80249c:	53                   	push   %ebx
  80249d:	68 00 80 80 00       	push   $0x808000
  8024a2:	ff 75 0c             	push   0xc(%ebp)
  8024a5:	e8 1e ec ff ff       	call   8010c8 <memmove>
  8024aa:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8024ad:	89 d8                	mov    %ebx,%eax
  8024af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024b2:	5b                   	pop    %ebx
  8024b3:	5e                   	pop    %esi
  8024b4:	5d                   	pop    %ebp
  8024b5:	c3                   	ret    
		assert(r < 1600 && r <= len);
  8024b6:	68 a7 33 80 00       	push   $0x8033a7
  8024bb:	68 6f 33 80 00       	push   $0x80336f
  8024c0:	6a 62                	push   $0x62
  8024c2:	68 bc 33 80 00       	push   $0x8033bc
  8024c7:	e8 b1 e3 ff ff       	call   80087d <_panic>

008024cc <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8024cc:	55                   	push   %ebp
  8024cd:	89 e5                	mov    %esp,%ebp
  8024cf:	53                   	push   %ebx
  8024d0:	83 ec 04             	sub    $0x4,%esp
  8024d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8024d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024d9:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  8024de:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8024e4:	7f 2e                	jg     802514 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8024e6:	83 ec 04             	sub    $0x4,%esp
  8024e9:	53                   	push   %ebx
  8024ea:	ff 75 0c             	push   0xc(%ebp)
  8024ed:	68 0c 80 80 00       	push   $0x80800c
  8024f2:	e8 d1 eb ff ff       	call   8010c8 <memmove>
	nsipcbuf.send.req_size = size;
  8024f7:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  8024fd:	8b 45 14             	mov    0x14(%ebp),%eax
  802500:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  802505:	b8 08 00 00 00       	mov    $0x8,%eax
  80250a:	e8 e8 fd ff ff       	call   8022f7 <nsipc>
}
  80250f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802512:	c9                   	leave  
  802513:	c3                   	ret    
	assert(size < 1600);
  802514:	68 c8 33 80 00       	push   $0x8033c8
  802519:	68 6f 33 80 00       	push   $0x80336f
  80251e:	6a 6d                	push   $0x6d
  802520:	68 bc 33 80 00       	push   $0x8033bc
  802525:	e8 53 e3 ff ff       	call   80087d <_panic>

0080252a <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80252a:	55                   	push   %ebp
  80252b:	89 e5                	mov    %esp,%ebp
  80252d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802530:	8b 45 08             	mov    0x8(%ebp),%eax
  802533:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  802538:	8b 45 0c             	mov    0xc(%ebp),%eax
  80253b:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  802540:	8b 45 10             	mov    0x10(%ebp),%eax
  802543:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  802548:	b8 09 00 00 00       	mov    $0x9,%eax
  80254d:	e8 a5 fd ff ff       	call   8022f7 <nsipc>
}
  802552:	c9                   	leave  
  802553:	c3                   	ret    

00802554 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802554:	55                   	push   %ebp
  802555:	89 e5                	mov    %esp,%ebp
  802557:	56                   	push   %esi
  802558:	53                   	push   %ebx
  802559:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80255c:	83 ec 0c             	sub    $0xc,%esp
  80255f:	ff 75 08             	push   0x8(%ebp)
  802562:	e8 ad f3 ff ff       	call   801914 <fd2data>
  802567:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802569:	83 c4 08             	add    $0x8,%esp
  80256c:	68 d4 33 80 00       	push   $0x8033d4
  802571:	53                   	push   %ebx
  802572:	e8 bb e9 ff ff       	call   800f32 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802577:	8b 46 04             	mov    0x4(%esi),%eax
  80257a:	2b 06                	sub    (%esi),%eax
  80257c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802582:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802589:	00 00 00 
	stat->st_dev = &devpipe;
  80258c:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802593:	40 80 00 
	return 0;
}
  802596:	b8 00 00 00 00       	mov    $0x0,%eax
  80259b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80259e:	5b                   	pop    %ebx
  80259f:	5e                   	pop    %esi
  8025a0:	5d                   	pop    %ebp
  8025a1:	c3                   	ret    

008025a2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8025a2:	55                   	push   %ebp
  8025a3:	89 e5                	mov    %esp,%ebp
  8025a5:	53                   	push   %ebx
  8025a6:	83 ec 0c             	sub    $0xc,%esp
  8025a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8025ac:	53                   	push   %ebx
  8025ad:	6a 00                	push   $0x0
  8025af:	e8 ff ed ff ff       	call   8013b3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8025b4:	89 1c 24             	mov    %ebx,(%esp)
  8025b7:	e8 58 f3 ff ff       	call   801914 <fd2data>
  8025bc:	83 c4 08             	add    $0x8,%esp
  8025bf:	50                   	push   %eax
  8025c0:	6a 00                	push   $0x0
  8025c2:	e8 ec ed ff ff       	call   8013b3 <sys_page_unmap>
}
  8025c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8025ca:	c9                   	leave  
  8025cb:	c3                   	ret    

008025cc <_pipeisclosed>:
{
  8025cc:	55                   	push   %ebp
  8025cd:	89 e5                	mov    %esp,%ebp
  8025cf:	57                   	push   %edi
  8025d0:	56                   	push   %esi
  8025d1:	53                   	push   %ebx
  8025d2:	83 ec 1c             	sub    $0x1c,%esp
  8025d5:	89 c7                	mov    %eax,%edi
  8025d7:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8025d9:	a1 18 50 80 00       	mov    0x805018,%eax
  8025de:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8025e1:	83 ec 0c             	sub    $0xc,%esp
  8025e4:	57                   	push   %edi
  8025e5:	e8 c4 04 00 00       	call   802aae <pageref>
  8025ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8025ed:	89 34 24             	mov    %esi,(%esp)
  8025f0:	e8 b9 04 00 00       	call   802aae <pageref>
		nn = thisenv->env_runs;
  8025f5:	8b 15 18 50 80 00    	mov    0x805018,%edx
  8025fb:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  8025fe:	83 c4 10             	add    $0x10,%esp
  802601:	39 cb                	cmp    %ecx,%ebx
  802603:	74 1b                	je     802620 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802605:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802608:	75 cf                	jne    8025d9 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80260a:	8b 42 68             	mov    0x68(%edx),%eax
  80260d:	6a 01                	push   $0x1
  80260f:	50                   	push   %eax
  802610:	53                   	push   %ebx
  802611:	68 db 33 80 00       	push   $0x8033db
  802616:	e8 3d e3 ff ff       	call   800958 <cprintf>
  80261b:	83 c4 10             	add    $0x10,%esp
  80261e:	eb b9                	jmp    8025d9 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802620:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802623:	0f 94 c0             	sete   %al
  802626:	0f b6 c0             	movzbl %al,%eax
}
  802629:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80262c:	5b                   	pop    %ebx
  80262d:	5e                   	pop    %esi
  80262e:	5f                   	pop    %edi
  80262f:	5d                   	pop    %ebp
  802630:	c3                   	ret    

00802631 <devpipe_write>:
{
  802631:	55                   	push   %ebp
  802632:	89 e5                	mov    %esp,%ebp
  802634:	57                   	push   %edi
  802635:	56                   	push   %esi
  802636:	53                   	push   %ebx
  802637:	83 ec 28             	sub    $0x28,%esp
  80263a:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80263d:	56                   	push   %esi
  80263e:	e8 d1 f2 ff ff       	call   801914 <fd2data>
  802643:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802645:	83 c4 10             	add    $0x10,%esp
  802648:	bf 00 00 00 00       	mov    $0x0,%edi
  80264d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802650:	75 09                	jne    80265b <devpipe_write+0x2a>
	return i;
  802652:	89 f8                	mov    %edi,%eax
  802654:	eb 23                	jmp    802679 <devpipe_write+0x48>
			sys_yield();
  802656:	e8 b4 ec ff ff       	call   80130f <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80265b:	8b 43 04             	mov    0x4(%ebx),%eax
  80265e:	8b 0b                	mov    (%ebx),%ecx
  802660:	8d 51 20             	lea    0x20(%ecx),%edx
  802663:	39 d0                	cmp    %edx,%eax
  802665:	72 1a                	jb     802681 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  802667:	89 da                	mov    %ebx,%edx
  802669:	89 f0                	mov    %esi,%eax
  80266b:	e8 5c ff ff ff       	call   8025cc <_pipeisclosed>
  802670:	85 c0                	test   %eax,%eax
  802672:	74 e2                	je     802656 <devpipe_write+0x25>
				return 0;
  802674:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802679:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80267c:	5b                   	pop    %ebx
  80267d:	5e                   	pop    %esi
  80267e:	5f                   	pop    %edi
  80267f:	5d                   	pop    %ebp
  802680:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802681:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802684:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802688:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80268b:	89 c2                	mov    %eax,%edx
  80268d:	c1 fa 1f             	sar    $0x1f,%edx
  802690:	89 d1                	mov    %edx,%ecx
  802692:	c1 e9 1b             	shr    $0x1b,%ecx
  802695:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802698:	83 e2 1f             	and    $0x1f,%edx
  80269b:	29 ca                	sub    %ecx,%edx
  80269d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8026a1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8026a5:	83 c0 01             	add    $0x1,%eax
  8026a8:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8026ab:	83 c7 01             	add    $0x1,%edi
  8026ae:	eb 9d                	jmp    80264d <devpipe_write+0x1c>

008026b0 <devpipe_read>:
{
  8026b0:	55                   	push   %ebp
  8026b1:	89 e5                	mov    %esp,%ebp
  8026b3:	57                   	push   %edi
  8026b4:	56                   	push   %esi
  8026b5:	53                   	push   %ebx
  8026b6:	83 ec 18             	sub    $0x18,%esp
  8026b9:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8026bc:	57                   	push   %edi
  8026bd:	e8 52 f2 ff ff       	call   801914 <fd2data>
  8026c2:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8026c4:	83 c4 10             	add    $0x10,%esp
  8026c7:	be 00 00 00 00       	mov    $0x0,%esi
  8026cc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8026cf:	75 13                	jne    8026e4 <devpipe_read+0x34>
	return i;
  8026d1:	89 f0                	mov    %esi,%eax
  8026d3:	eb 02                	jmp    8026d7 <devpipe_read+0x27>
				return i;
  8026d5:	89 f0                	mov    %esi,%eax
}
  8026d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026da:	5b                   	pop    %ebx
  8026db:	5e                   	pop    %esi
  8026dc:	5f                   	pop    %edi
  8026dd:	5d                   	pop    %ebp
  8026de:	c3                   	ret    
			sys_yield();
  8026df:	e8 2b ec ff ff       	call   80130f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8026e4:	8b 03                	mov    (%ebx),%eax
  8026e6:	3b 43 04             	cmp    0x4(%ebx),%eax
  8026e9:	75 18                	jne    802703 <devpipe_read+0x53>
			if (i > 0)
  8026eb:	85 f6                	test   %esi,%esi
  8026ed:	75 e6                	jne    8026d5 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8026ef:	89 da                	mov    %ebx,%edx
  8026f1:	89 f8                	mov    %edi,%eax
  8026f3:	e8 d4 fe ff ff       	call   8025cc <_pipeisclosed>
  8026f8:	85 c0                	test   %eax,%eax
  8026fa:	74 e3                	je     8026df <devpipe_read+0x2f>
				return 0;
  8026fc:	b8 00 00 00 00       	mov    $0x0,%eax
  802701:	eb d4                	jmp    8026d7 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802703:	99                   	cltd   
  802704:	c1 ea 1b             	shr    $0x1b,%edx
  802707:	01 d0                	add    %edx,%eax
  802709:	83 e0 1f             	and    $0x1f,%eax
  80270c:	29 d0                	sub    %edx,%eax
  80270e:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802713:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802716:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802719:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80271c:	83 c6 01             	add    $0x1,%esi
  80271f:	eb ab                	jmp    8026cc <devpipe_read+0x1c>

00802721 <pipe>:
{
  802721:	55                   	push   %ebp
  802722:	89 e5                	mov    %esp,%ebp
  802724:	56                   	push   %esi
  802725:	53                   	push   %ebx
  802726:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802729:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80272c:	50                   	push   %eax
  80272d:	e8 f9 f1 ff ff       	call   80192b <fd_alloc>
  802732:	89 c3                	mov    %eax,%ebx
  802734:	83 c4 10             	add    $0x10,%esp
  802737:	85 c0                	test   %eax,%eax
  802739:	0f 88 23 01 00 00    	js     802862 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80273f:	83 ec 04             	sub    $0x4,%esp
  802742:	68 07 04 00 00       	push   $0x407
  802747:	ff 75 f4             	push   -0xc(%ebp)
  80274a:	6a 00                	push   $0x0
  80274c:	e8 dd eb ff ff       	call   80132e <sys_page_alloc>
  802751:	89 c3                	mov    %eax,%ebx
  802753:	83 c4 10             	add    $0x10,%esp
  802756:	85 c0                	test   %eax,%eax
  802758:	0f 88 04 01 00 00    	js     802862 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  80275e:	83 ec 0c             	sub    $0xc,%esp
  802761:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802764:	50                   	push   %eax
  802765:	e8 c1 f1 ff ff       	call   80192b <fd_alloc>
  80276a:	89 c3                	mov    %eax,%ebx
  80276c:	83 c4 10             	add    $0x10,%esp
  80276f:	85 c0                	test   %eax,%eax
  802771:	0f 88 db 00 00 00    	js     802852 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802777:	83 ec 04             	sub    $0x4,%esp
  80277a:	68 07 04 00 00       	push   $0x407
  80277f:	ff 75 f0             	push   -0x10(%ebp)
  802782:	6a 00                	push   $0x0
  802784:	e8 a5 eb ff ff       	call   80132e <sys_page_alloc>
  802789:	89 c3                	mov    %eax,%ebx
  80278b:	83 c4 10             	add    $0x10,%esp
  80278e:	85 c0                	test   %eax,%eax
  802790:	0f 88 bc 00 00 00    	js     802852 <pipe+0x131>
	va = fd2data(fd0);
  802796:	83 ec 0c             	sub    $0xc,%esp
  802799:	ff 75 f4             	push   -0xc(%ebp)
  80279c:	e8 73 f1 ff ff       	call   801914 <fd2data>
  8027a1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8027a3:	83 c4 0c             	add    $0xc,%esp
  8027a6:	68 07 04 00 00       	push   $0x407
  8027ab:	50                   	push   %eax
  8027ac:	6a 00                	push   $0x0
  8027ae:	e8 7b eb ff ff       	call   80132e <sys_page_alloc>
  8027b3:	89 c3                	mov    %eax,%ebx
  8027b5:	83 c4 10             	add    $0x10,%esp
  8027b8:	85 c0                	test   %eax,%eax
  8027ba:	0f 88 82 00 00 00    	js     802842 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8027c0:	83 ec 0c             	sub    $0xc,%esp
  8027c3:	ff 75 f0             	push   -0x10(%ebp)
  8027c6:	e8 49 f1 ff ff       	call   801914 <fd2data>
  8027cb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8027d2:	50                   	push   %eax
  8027d3:	6a 00                	push   $0x0
  8027d5:	56                   	push   %esi
  8027d6:	6a 00                	push   $0x0
  8027d8:	e8 94 eb ff ff       	call   801371 <sys_page_map>
  8027dd:	89 c3                	mov    %eax,%ebx
  8027df:	83 c4 20             	add    $0x20,%esp
  8027e2:	85 c0                	test   %eax,%eax
  8027e4:	78 4e                	js     802834 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8027e6:	a1 3c 40 80 00       	mov    0x80403c,%eax
  8027eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8027ee:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8027f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8027f3:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8027fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8027fd:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8027ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802802:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802809:	83 ec 0c             	sub    $0xc,%esp
  80280c:	ff 75 f4             	push   -0xc(%ebp)
  80280f:	e8 f0 f0 ff ff       	call   801904 <fd2num>
  802814:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802817:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802819:	83 c4 04             	add    $0x4,%esp
  80281c:	ff 75 f0             	push   -0x10(%ebp)
  80281f:	e8 e0 f0 ff ff       	call   801904 <fd2num>
  802824:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802827:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80282a:	83 c4 10             	add    $0x10,%esp
  80282d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802832:	eb 2e                	jmp    802862 <pipe+0x141>
	sys_page_unmap(0, va);
  802834:	83 ec 08             	sub    $0x8,%esp
  802837:	56                   	push   %esi
  802838:	6a 00                	push   $0x0
  80283a:	e8 74 eb ff ff       	call   8013b3 <sys_page_unmap>
  80283f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802842:	83 ec 08             	sub    $0x8,%esp
  802845:	ff 75 f0             	push   -0x10(%ebp)
  802848:	6a 00                	push   $0x0
  80284a:	e8 64 eb ff ff       	call   8013b3 <sys_page_unmap>
  80284f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802852:	83 ec 08             	sub    $0x8,%esp
  802855:	ff 75 f4             	push   -0xc(%ebp)
  802858:	6a 00                	push   $0x0
  80285a:	e8 54 eb ff ff       	call   8013b3 <sys_page_unmap>
  80285f:	83 c4 10             	add    $0x10,%esp
}
  802862:	89 d8                	mov    %ebx,%eax
  802864:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802867:	5b                   	pop    %ebx
  802868:	5e                   	pop    %esi
  802869:	5d                   	pop    %ebp
  80286a:	c3                   	ret    

0080286b <pipeisclosed>:
{
  80286b:	55                   	push   %ebp
  80286c:	89 e5                	mov    %esp,%ebp
  80286e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802871:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802874:	50                   	push   %eax
  802875:	ff 75 08             	push   0x8(%ebp)
  802878:	e8 fe f0 ff ff       	call   80197b <fd_lookup>
  80287d:	83 c4 10             	add    $0x10,%esp
  802880:	85 c0                	test   %eax,%eax
  802882:	78 18                	js     80289c <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802884:	83 ec 0c             	sub    $0xc,%esp
  802887:	ff 75 f4             	push   -0xc(%ebp)
  80288a:	e8 85 f0 ff ff       	call   801914 <fd2data>
  80288f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802891:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802894:	e8 33 fd ff ff       	call   8025cc <_pipeisclosed>
  802899:	83 c4 10             	add    $0x10,%esp
}
  80289c:	c9                   	leave  
  80289d:	c3                   	ret    

0080289e <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80289e:	b8 00 00 00 00       	mov    $0x0,%eax
  8028a3:	c3                   	ret    

008028a4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8028a4:	55                   	push   %ebp
  8028a5:	89 e5                	mov    %esp,%ebp
  8028a7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8028aa:	68 f3 33 80 00       	push   $0x8033f3
  8028af:	ff 75 0c             	push   0xc(%ebp)
  8028b2:	e8 7b e6 ff ff       	call   800f32 <strcpy>
	return 0;
}
  8028b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8028bc:	c9                   	leave  
  8028bd:	c3                   	ret    

008028be <devcons_write>:
{
  8028be:	55                   	push   %ebp
  8028bf:	89 e5                	mov    %esp,%ebp
  8028c1:	57                   	push   %edi
  8028c2:	56                   	push   %esi
  8028c3:	53                   	push   %ebx
  8028c4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8028ca:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8028cf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8028d5:	eb 2e                	jmp    802905 <devcons_write+0x47>
		m = n - tot;
  8028d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8028da:	29 f3                	sub    %esi,%ebx
  8028dc:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8028e1:	39 c3                	cmp    %eax,%ebx
  8028e3:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8028e6:	83 ec 04             	sub    $0x4,%esp
  8028e9:	53                   	push   %ebx
  8028ea:	89 f0                	mov    %esi,%eax
  8028ec:	03 45 0c             	add    0xc(%ebp),%eax
  8028ef:	50                   	push   %eax
  8028f0:	57                   	push   %edi
  8028f1:	e8 d2 e7 ff ff       	call   8010c8 <memmove>
		sys_cputs(buf, m);
  8028f6:	83 c4 08             	add    $0x8,%esp
  8028f9:	53                   	push   %ebx
  8028fa:	57                   	push   %edi
  8028fb:	e8 72 e9 ff ff       	call   801272 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802900:	01 de                	add    %ebx,%esi
  802902:	83 c4 10             	add    $0x10,%esp
  802905:	3b 75 10             	cmp    0x10(%ebp),%esi
  802908:	72 cd                	jb     8028d7 <devcons_write+0x19>
}
  80290a:	89 f0                	mov    %esi,%eax
  80290c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80290f:	5b                   	pop    %ebx
  802910:	5e                   	pop    %esi
  802911:	5f                   	pop    %edi
  802912:	5d                   	pop    %ebp
  802913:	c3                   	ret    

00802914 <devcons_read>:
{
  802914:	55                   	push   %ebp
  802915:	89 e5                	mov    %esp,%ebp
  802917:	83 ec 08             	sub    $0x8,%esp
  80291a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80291f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802923:	75 07                	jne    80292c <devcons_read+0x18>
  802925:	eb 1f                	jmp    802946 <devcons_read+0x32>
		sys_yield();
  802927:	e8 e3 e9 ff ff       	call   80130f <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80292c:	e8 5f e9 ff ff       	call   801290 <sys_cgetc>
  802931:	85 c0                	test   %eax,%eax
  802933:	74 f2                	je     802927 <devcons_read+0x13>
	if (c < 0)
  802935:	78 0f                	js     802946 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802937:	83 f8 04             	cmp    $0x4,%eax
  80293a:	74 0c                	je     802948 <devcons_read+0x34>
	*(char*)vbuf = c;
  80293c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80293f:	88 02                	mov    %al,(%edx)
	return 1;
  802941:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802946:	c9                   	leave  
  802947:	c3                   	ret    
		return 0;
  802948:	b8 00 00 00 00       	mov    $0x0,%eax
  80294d:	eb f7                	jmp    802946 <devcons_read+0x32>

0080294f <cputchar>:
{
  80294f:	55                   	push   %ebp
  802950:	89 e5                	mov    %esp,%ebp
  802952:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802955:	8b 45 08             	mov    0x8(%ebp),%eax
  802958:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80295b:	6a 01                	push   $0x1
  80295d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802960:	50                   	push   %eax
  802961:	e8 0c e9 ff ff       	call   801272 <sys_cputs>
}
  802966:	83 c4 10             	add    $0x10,%esp
  802969:	c9                   	leave  
  80296a:	c3                   	ret    

0080296b <getchar>:
{
  80296b:	55                   	push   %ebp
  80296c:	89 e5                	mov    %esp,%ebp
  80296e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802971:	6a 01                	push   $0x1
  802973:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802976:	50                   	push   %eax
  802977:	6a 00                	push   $0x0
  802979:	e8 66 f2 ff ff       	call   801be4 <read>
	if (r < 0)
  80297e:	83 c4 10             	add    $0x10,%esp
  802981:	85 c0                	test   %eax,%eax
  802983:	78 06                	js     80298b <getchar+0x20>
	if (r < 1)
  802985:	74 06                	je     80298d <getchar+0x22>
	return c;
  802987:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80298b:	c9                   	leave  
  80298c:	c3                   	ret    
		return -E_EOF;
  80298d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802992:	eb f7                	jmp    80298b <getchar+0x20>

00802994 <iscons>:
{
  802994:	55                   	push   %ebp
  802995:	89 e5                	mov    %esp,%ebp
  802997:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80299a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80299d:	50                   	push   %eax
  80299e:	ff 75 08             	push   0x8(%ebp)
  8029a1:	e8 d5 ef ff ff       	call   80197b <fd_lookup>
  8029a6:	83 c4 10             	add    $0x10,%esp
  8029a9:	85 c0                	test   %eax,%eax
  8029ab:	78 11                	js     8029be <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8029ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029b0:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8029b6:	39 10                	cmp    %edx,(%eax)
  8029b8:	0f 94 c0             	sete   %al
  8029bb:	0f b6 c0             	movzbl %al,%eax
}
  8029be:	c9                   	leave  
  8029bf:	c3                   	ret    

008029c0 <opencons>:
{
  8029c0:	55                   	push   %ebp
  8029c1:	89 e5                	mov    %esp,%ebp
  8029c3:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8029c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029c9:	50                   	push   %eax
  8029ca:	e8 5c ef ff ff       	call   80192b <fd_alloc>
  8029cf:	83 c4 10             	add    $0x10,%esp
  8029d2:	85 c0                	test   %eax,%eax
  8029d4:	78 3a                	js     802a10 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8029d6:	83 ec 04             	sub    $0x4,%esp
  8029d9:	68 07 04 00 00       	push   $0x407
  8029de:	ff 75 f4             	push   -0xc(%ebp)
  8029e1:	6a 00                	push   $0x0
  8029e3:	e8 46 e9 ff ff       	call   80132e <sys_page_alloc>
  8029e8:	83 c4 10             	add    $0x10,%esp
  8029eb:	85 c0                	test   %eax,%eax
  8029ed:	78 21                	js     802a10 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8029ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029f2:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8029f8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8029fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029fd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802a04:	83 ec 0c             	sub    $0xc,%esp
  802a07:	50                   	push   %eax
  802a08:	e8 f7 ee ff ff       	call   801904 <fd2num>
  802a0d:	83 c4 10             	add    $0x10,%esp
}
  802a10:	c9                   	leave  
  802a11:	c3                   	ret    

00802a12 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802a12:	55                   	push   %ebp
  802a13:	89 e5                	mov    %esp,%ebp
  802a15:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  802a18:	83 3d 04 90 80 00 00 	cmpl   $0x0,0x809004
  802a1f:	74 0a                	je     802a2b <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802a21:	8b 45 08             	mov    0x8(%ebp),%eax
  802a24:	a3 04 90 80 00       	mov    %eax,0x809004
}
  802a29:	c9                   	leave  
  802a2a:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  802a2b:	e8 c0 e8 ff ff       	call   8012f0 <sys_getenvid>
  802a30:	83 ec 04             	sub    $0x4,%esp
  802a33:	68 07 0e 00 00       	push   $0xe07
  802a38:	68 00 f0 bf ee       	push   $0xeebff000
  802a3d:	50                   	push   %eax
  802a3e:	e8 eb e8 ff ff       	call   80132e <sys_page_alloc>
		if (r < 0) {
  802a43:	83 c4 10             	add    $0x10,%esp
  802a46:	85 c0                	test   %eax,%eax
  802a48:	78 2c                	js     802a76 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802a4a:	e8 a1 e8 ff ff       	call   8012f0 <sys_getenvid>
  802a4f:	83 ec 08             	sub    $0x8,%esp
  802a52:	68 88 2a 80 00       	push   $0x802a88
  802a57:	50                   	push   %eax
  802a58:	e8 1c ea ff ff       	call   801479 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802a5d:	83 c4 10             	add    $0x10,%esp
  802a60:	85 c0                	test   %eax,%eax
  802a62:	79 bd                	jns    802a21 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  802a64:	50                   	push   %eax
  802a65:	68 40 34 80 00       	push   $0x803440
  802a6a:	6a 28                	push   $0x28
  802a6c:	68 76 34 80 00       	push   $0x803476
  802a71:	e8 07 de ff ff       	call   80087d <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802a76:	50                   	push   %eax
  802a77:	68 00 34 80 00       	push   $0x803400
  802a7c:	6a 23                	push   $0x23
  802a7e:	68 76 34 80 00       	push   $0x803476
  802a83:	e8 f5 dd ff ff       	call   80087d <_panic>

00802a88 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802a88:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802a89:	a1 04 90 80 00       	mov    0x809004,%eax
	call *%eax
  802a8e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802a90:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802a93:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802a97:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802a9a:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802a9e:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802aa2:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  802aa4:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802aa7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  802aa8:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  802aab:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  802aac:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  802aad:	c3                   	ret    

00802aae <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802aae:	55                   	push   %ebp
  802aaf:	89 e5                	mov    %esp,%ebp
  802ab1:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802ab4:	89 c2                	mov    %eax,%edx
  802ab6:	c1 ea 16             	shr    $0x16,%edx
  802ab9:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802ac0:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802ac5:	f6 c1 01             	test   $0x1,%cl
  802ac8:	74 1c                	je     802ae6 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802aca:	c1 e8 0c             	shr    $0xc,%eax
  802acd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802ad4:	a8 01                	test   $0x1,%al
  802ad6:	74 0e                	je     802ae6 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802ad8:	c1 e8 0c             	shr    $0xc,%eax
  802adb:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802ae2:	ef 
  802ae3:	0f b7 d2             	movzwl %dx,%edx
}
  802ae6:	89 d0                	mov    %edx,%eax
  802ae8:	5d                   	pop    %ebp
  802ae9:	c3                   	ret    
  802aea:	66 90                	xchg   %ax,%ax
  802aec:	66 90                	xchg   %ax,%ax
  802aee:	66 90                	xchg   %ax,%ax

00802af0 <__udivdi3>:
  802af0:	f3 0f 1e fb          	endbr32 
  802af4:	55                   	push   %ebp
  802af5:	57                   	push   %edi
  802af6:	56                   	push   %esi
  802af7:	53                   	push   %ebx
  802af8:	83 ec 1c             	sub    $0x1c,%esp
  802afb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802aff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802b03:	8b 74 24 34          	mov    0x34(%esp),%esi
  802b07:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802b0b:	85 c0                	test   %eax,%eax
  802b0d:	75 19                	jne    802b28 <__udivdi3+0x38>
  802b0f:	39 f3                	cmp    %esi,%ebx
  802b11:	76 4d                	jbe    802b60 <__udivdi3+0x70>
  802b13:	31 ff                	xor    %edi,%edi
  802b15:	89 e8                	mov    %ebp,%eax
  802b17:	89 f2                	mov    %esi,%edx
  802b19:	f7 f3                	div    %ebx
  802b1b:	89 fa                	mov    %edi,%edx
  802b1d:	83 c4 1c             	add    $0x1c,%esp
  802b20:	5b                   	pop    %ebx
  802b21:	5e                   	pop    %esi
  802b22:	5f                   	pop    %edi
  802b23:	5d                   	pop    %ebp
  802b24:	c3                   	ret    
  802b25:	8d 76 00             	lea    0x0(%esi),%esi
  802b28:	39 f0                	cmp    %esi,%eax
  802b2a:	76 14                	jbe    802b40 <__udivdi3+0x50>
  802b2c:	31 ff                	xor    %edi,%edi
  802b2e:	31 c0                	xor    %eax,%eax
  802b30:	89 fa                	mov    %edi,%edx
  802b32:	83 c4 1c             	add    $0x1c,%esp
  802b35:	5b                   	pop    %ebx
  802b36:	5e                   	pop    %esi
  802b37:	5f                   	pop    %edi
  802b38:	5d                   	pop    %ebp
  802b39:	c3                   	ret    
  802b3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b40:	0f bd f8             	bsr    %eax,%edi
  802b43:	83 f7 1f             	xor    $0x1f,%edi
  802b46:	75 48                	jne    802b90 <__udivdi3+0xa0>
  802b48:	39 f0                	cmp    %esi,%eax
  802b4a:	72 06                	jb     802b52 <__udivdi3+0x62>
  802b4c:	31 c0                	xor    %eax,%eax
  802b4e:	39 eb                	cmp    %ebp,%ebx
  802b50:	77 de                	ja     802b30 <__udivdi3+0x40>
  802b52:	b8 01 00 00 00       	mov    $0x1,%eax
  802b57:	eb d7                	jmp    802b30 <__udivdi3+0x40>
  802b59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b60:	89 d9                	mov    %ebx,%ecx
  802b62:	85 db                	test   %ebx,%ebx
  802b64:	75 0b                	jne    802b71 <__udivdi3+0x81>
  802b66:	b8 01 00 00 00       	mov    $0x1,%eax
  802b6b:	31 d2                	xor    %edx,%edx
  802b6d:	f7 f3                	div    %ebx
  802b6f:	89 c1                	mov    %eax,%ecx
  802b71:	31 d2                	xor    %edx,%edx
  802b73:	89 f0                	mov    %esi,%eax
  802b75:	f7 f1                	div    %ecx
  802b77:	89 c6                	mov    %eax,%esi
  802b79:	89 e8                	mov    %ebp,%eax
  802b7b:	89 f7                	mov    %esi,%edi
  802b7d:	f7 f1                	div    %ecx
  802b7f:	89 fa                	mov    %edi,%edx
  802b81:	83 c4 1c             	add    $0x1c,%esp
  802b84:	5b                   	pop    %ebx
  802b85:	5e                   	pop    %esi
  802b86:	5f                   	pop    %edi
  802b87:	5d                   	pop    %ebp
  802b88:	c3                   	ret    
  802b89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b90:	89 f9                	mov    %edi,%ecx
  802b92:	ba 20 00 00 00       	mov    $0x20,%edx
  802b97:	29 fa                	sub    %edi,%edx
  802b99:	d3 e0                	shl    %cl,%eax
  802b9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  802b9f:	89 d1                	mov    %edx,%ecx
  802ba1:	89 d8                	mov    %ebx,%eax
  802ba3:	d3 e8                	shr    %cl,%eax
  802ba5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802ba9:	09 c1                	or     %eax,%ecx
  802bab:	89 f0                	mov    %esi,%eax
  802bad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802bb1:	89 f9                	mov    %edi,%ecx
  802bb3:	d3 e3                	shl    %cl,%ebx
  802bb5:	89 d1                	mov    %edx,%ecx
  802bb7:	d3 e8                	shr    %cl,%eax
  802bb9:	89 f9                	mov    %edi,%ecx
  802bbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802bbf:	89 eb                	mov    %ebp,%ebx
  802bc1:	d3 e6                	shl    %cl,%esi
  802bc3:	89 d1                	mov    %edx,%ecx
  802bc5:	d3 eb                	shr    %cl,%ebx
  802bc7:	09 f3                	or     %esi,%ebx
  802bc9:	89 c6                	mov    %eax,%esi
  802bcb:	89 f2                	mov    %esi,%edx
  802bcd:	89 d8                	mov    %ebx,%eax
  802bcf:	f7 74 24 08          	divl   0x8(%esp)
  802bd3:	89 d6                	mov    %edx,%esi
  802bd5:	89 c3                	mov    %eax,%ebx
  802bd7:	f7 64 24 0c          	mull   0xc(%esp)
  802bdb:	39 d6                	cmp    %edx,%esi
  802bdd:	72 19                	jb     802bf8 <__udivdi3+0x108>
  802bdf:	89 f9                	mov    %edi,%ecx
  802be1:	d3 e5                	shl    %cl,%ebp
  802be3:	39 c5                	cmp    %eax,%ebp
  802be5:	73 04                	jae    802beb <__udivdi3+0xfb>
  802be7:	39 d6                	cmp    %edx,%esi
  802be9:	74 0d                	je     802bf8 <__udivdi3+0x108>
  802beb:	89 d8                	mov    %ebx,%eax
  802bed:	31 ff                	xor    %edi,%edi
  802bef:	e9 3c ff ff ff       	jmp    802b30 <__udivdi3+0x40>
  802bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802bf8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802bfb:	31 ff                	xor    %edi,%edi
  802bfd:	e9 2e ff ff ff       	jmp    802b30 <__udivdi3+0x40>
  802c02:	66 90                	xchg   %ax,%ax
  802c04:	66 90                	xchg   %ax,%ax
  802c06:	66 90                	xchg   %ax,%ax
  802c08:	66 90                	xchg   %ax,%ax
  802c0a:	66 90                	xchg   %ax,%ax
  802c0c:	66 90                	xchg   %ax,%ax
  802c0e:	66 90                	xchg   %ax,%ax

00802c10 <__umoddi3>:
  802c10:	f3 0f 1e fb          	endbr32 
  802c14:	55                   	push   %ebp
  802c15:	57                   	push   %edi
  802c16:	56                   	push   %esi
  802c17:	53                   	push   %ebx
  802c18:	83 ec 1c             	sub    $0x1c,%esp
  802c1b:	8b 74 24 30          	mov    0x30(%esp),%esi
  802c1f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802c23:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802c27:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  802c2b:	89 f0                	mov    %esi,%eax
  802c2d:	89 da                	mov    %ebx,%edx
  802c2f:	85 ff                	test   %edi,%edi
  802c31:	75 15                	jne    802c48 <__umoddi3+0x38>
  802c33:	39 dd                	cmp    %ebx,%ebp
  802c35:	76 39                	jbe    802c70 <__umoddi3+0x60>
  802c37:	f7 f5                	div    %ebp
  802c39:	89 d0                	mov    %edx,%eax
  802c3b:	31 d2                	xor    %edx,%edx
  802c3d:	83 c4 1c             	add    $0x1c,%esp
  802c40:	5b                   	pop    %ebx
  802c41:	5e                   	pop    %esi
  802c42:	5f                   	pop    %edi
  802c43:	5d                   	pop    %ebp
  802c44:	c3                   	ret    
  802c45:	8d 76 00             	lea    0x0(%esi),%esi
  802c48:	39 df                	cmp    %ebx,%edi
  802c4a:	77 f1                	ja     802c3d <__umoddi3+0x2d>
  802c4c:	0f bd cf             	bsr    %edi,%ecx
  802c4f:	83 f1 1f             	xor    $0x1f,%ecx
  802c52:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802c56:	75 40                	jne    802c98 <__umoddi3+0x88>
  802c58:	39 df                	cmp    %ebx,%edi
  802c5a:	72 04                	jb     802c60 <__umoddi3+0x50>
  802c5c:	39 f5                	cmp    %esi,%ebp
  802c5e:	77 dd                	ja     802c3d <__umoddi3+0x2d>
  802c60:	89 da                	mov    %ebx,%edx
  802c62:	89 f0                	mov    %esi,%eax
  802c64:	29 e8                	sub    %ebp,%eax
  802c66:	19 fa                	sbb    %edi,%edx
  802c68:	eb d3                	jmp    802c3d <__umoddi3+0x2d>
  802c6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802c70:	89 e9                	mov    %ebp,%ecx
  802c72:	85 ed                	test   %ebp,%ebp
  802c74:	75 0b                	jne    802c81 <__umoddi3+0x71>
  802c76:	b8 01 00 00 00       	mov    $0x1,%eax
  802c7b:	31 d2                	xor    %edx,%edx
  802c7d:	f7 f5                	div    %ebp
  802c7f:	89 c1                	mov    %eax,%ecx
  802c81:	89 d8                	mov    %ebx,%eax
  802c83:	31 d2                	xor    %edx,%edx
  802c85:	f7 f1                	div    %ecx
  802c87:	89 f0                	mov    %esi,%eax
  802c89:	f7 f1                	div    %ecx
  802c8b:	89 d0                	mov    %edx,%eax
  802c8d:	31 d2                	xor    %edx,%edx
  802c8f:	eb ac                	jmp    802c3d <__umoddi3+0x2d>
  802c91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c98:	8b 44 24 04          	mov    0x4(%esp),%eax
  802c9c:	ba 20 00 00 00       	mov    $0x20,%edx
  802ca1:	29 c2                	sub    %eax,%edx
  802ca3:	89 c1                	mov    %eax,%ecx
  802ca5:	89 e8                	mov    %ebp,%eax
  802ca7:	d3 e7                	shl    %cl,%edi
  802ca9:	89 d1                	mov    %edx,%ecx
  802cab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802caf:	d3 e8                	shr    %cl,%eax
  802cb1:	89 c1                	mov    %eax,%ecx
  802cb3:	8b 44 24 04          	mov    0x4(%esp),%eax
  802cb7:	09 f9                	or     %edi,%ecx
  802cb9:	89 df                	mov    %ebx,%edi
  802cbb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802cbf:	89 c1                	mov    %eax,%ecx
  802cc1:	d3 e5                	shl    %cl,%ebp
  802cc3:	89 d1                	mov    %edx,%ecx
  802cc5:	d3 ef                	shr    %cl,%edi
  802cc7:	89 c1                	mov    %eax,%ecx
  802cc9:	89 f0                	mov    %esi,%eax
  802ccb:	d3 e3                	shl    %cl,%ebx
  802ccd:	89 d1                	mov    %edx,%ecx
  802ccf:	89 fa                	mov    %edi,%edx
  802cd1:	d3 e8                	shr    %cl,%eax
  802cd3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802cd8:	09 d8                	or     %ebx,%eax
  802cda:	f7 74 24 08          	divl   0x8(%esp)
  802cde:	89 d3                	mov    %edx,%ebx
  802ce0:	d3 e6                	shl    %cl,%esi
  802ce2:	f7 e5                	mul    %ebp
  802ce4:	89 c7                	mov    %eax,%edi
  802ce6:	89 d1                	mov    %edx,%ecx
  802ce8:	39 d3                	cmp    %edx,%ebx
  802cea:	72 06                	jb     802cf2 <__umoddi3+0xe2>
  802cec:	75 0e                	jne    802cfc <__umoddi3+0xec>
  802cee:	39 c6                	cmp    %eax,%esi
  802cf0:	73 0a                	jae    802cfc <__umoddi3+0xec>
  802cf2:	29 e8                	sub    %ebp,%eax
  802cf4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802cf8:	89 d1                	mov    %edx,%ecx
  802cfa:	89 c7                	mov    %eax,%edi
  802cfc:	89 f5                	mov    %esi,%ebp
  802cfe:	8b 74 24 04          	mov    0x4(%esp),%esi
  802d02:	29 fd                	sub    %edi,%ebp
  802d04:	19 cb                	sbb    %ecx,%ebx
  802d06:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802d0b:	89 d8                	mov    %ebx,%eax
  802d0d:	d3 e0                	shl    %cl,%eax
  802d0f:	89 f1                	mov    %esi,%ecx
  802d11:	d3 ed                	shr    %cl,%ebp
  802d13:	d3 eb                	shr    %cl,%ebx
  802d15:	09 e8                	or     %ebp,%eax
  802d17:	89 da                	mov    %ebx,%edx
  802d19:	83 c4 1c             	add    $0x1c,%esp
  802d1c:	5b                   	pop    %ebx
  802d1d:	5e                   	pop    %esi
  802d1e:	5f                   	pop    %edi
  802d1f:	5d                   	pop    %ebp
  802d20:	c3                   	ret    
