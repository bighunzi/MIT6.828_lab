
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
  80003c:	e8 ac 12 00 00       	call   8012ed <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx
	int i, r, first = 1;

	binaryname = "testinput";
  800043:	c7 05 00 40 80 00 20 	movl   $0x802d20,0x804000
  80004a:	2d 80 00 

	output_envid = fork();
  80004d:	e8 29 16 00 00       	call   80167b <fork>
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
  800065:	e8 11 16 00 00       	call   80167b <fork>
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
  800080:	68 48 2d 80 00       	push   $0x802d48
  800085:	e8 cb 08 00 00       	call   800955 <cprintf>
	uint8_t mac[6] = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};
  80008a:	c7 45 98 52 54 00 12 	movl   $0x12005452,-0x68(%ebp)
  800091:	66 c7 45 9c 34 56    	movw   $0x5634,-0x64(%ebp)
	uint32_t myip = inet_addr(IP);
  800097:	c7 04 24 65 2d 80 00 	movl   $0x802d65,(%esp)
  80009e:	e8 42 07 00 00       	call   8007e5 <inet_addr>
  8000a3:	89 45 90             	mov    %eax,-0x70(%ebp)
	uint32_t gwip = inet_addr(DEFAULT);
  8000a6:	c7 04 24 6f 2d 80 00 	movl   $0x802d6f,(%esp)
  8000ad:	e8 33 07 00 00       	call   8007e5 <inet_addr>
  8000b2:	89 45 94             	mov    %eax,-0x6c(%ebp)
	if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  8000b5:	83 c4 0c             	add    $0xc,%esp
  8000b8:	6a 07                	push   $0x7
  8000ba:	68 00 b0 fe 0f       	push   $0xffeb000
  8000bf:	6a 00                	push   $0x0
  8000c1:	e8 65 12 00 00       	call   80132b <sys_page_alloc>
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
  8000ea:	e8 90 0f 00 00       	call   80107f <memset>
	memcpy(arp->ethhdr.src.addr,  mac,  ETHARP_HWADDR_LEN);
  8000ef:	83 c4 0c             	add    $0xc,%esp
  8000f2:	6a 06                	push   $0x6
  8000f4:	8d 5d 98             	lea    -0x68(%ebp),%ebx
  8000f7:	53                   	push   %ebx
  8000f8:	68 0a b0 fe 0f       	push   $0xffeb00a
  8000fd:	e8 25 10 00 00       	call   801127 <memcpy>
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
  800167:	e8 bb 0f 00 00       	call   801127 <memcpy>
	memcpy(arp->sipaddr.addrw, &myip, 4);
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	6a 04                	push   $0x4
  800171:	8d 45 90             	lea    -0x70(%ebp),%eax
  800174:	50                   	push   %eax
  800175:	68 20 b0 fe 0f       	push   $0xffeb020
  80017a:	e8 a8 0f 00 00       	call   801127 <memcpy>
	memset(arp->dhwaddr.addr,  0x00,  ETHARP_HWADDR_LEN);
  80017f:	83 c4 0c             	add    $0xc,%esp
  800182:	6a 06                	push   $0x6
  800184:	6a 00                	push   $0x0
  800186:	68 24 b0 fe 0f       	push   $0xffeb024
  80018b:	e8 ef 0e 00 00       	call   80107f <memset>
	memcpy(arp->dipaddr.addrw, &gwip, 4);
  800190:	83 c4 0c             	add    $0xc,%esp
  800193:	6a 04                	push   $0x4
  800195:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800198:	50                   	push   %eax
  800199:	68 2a b0 fe 0f       	push   $0xffeb02a
  80019e:	e8 84 0f 00 00       	call   801127 <memcpy>
	ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8001a3:	6a 07                	push   $0x7
  8001a5:	68 00 b0 fe 0f       	push   $0xffeb000
  8001aa:	6a 0b                	push   $0xb
  8001ac:	ff 35 04 50 80 00    	push   0x805004
  8001b2:	e8 ab 16 00 00       	call   801862 <ipc_send>
	sys_page_unmap(0, pkt);
  8001b7:	83 c4 18             	add    $0x18,%esp
  8001ba:	68 00 b0 fe 0f       	push   $0xffeb000
  8001bf:	6a 00                	push   $0x0
  8001c1:	e8 ea 11 00 00       	call   8013b0 <sys_page_unmap>
}
  8001c6:	83 c4 10             	add    $0x10,%esp
	int i, r, first = 1;
  8001c9:	c7 85 7c ff ff ff 01 	movl   $0x1,-0x84(%ebp)
  8001d0:	00 00 00 
}
  8001d3:	e9 65 01 00 00       	jmp    80033d <umain+0x30a>
		panic("error forking");
  8001d8:	83 ec 04             	sub    $0x4,%esp
  8001db:	68 2a 2d 80 00       	push   $0x802d2a
  8001e0:	6a 4d                	push   $0x4d
  8001e2:	68 38 2d 80 00       	push   $0x802d38
  8001e7:	e8 8e 06 00 00       	call   80087a <_panic>
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
  800203:	68 2a 2d 80 00       	push   $0x802d2a
  800208:	6a 55                	push   $0x55
  80020a:	68 38 2d 80 00       	push   $0x802d38
  80020f:	e8 66 06 00 00       	call   80087a <_panic>
		input(ns_envid);
  800214:	83 ec 0c             	sub    $0xc,%esp
  800217:	53                   	push   %ebx
  800218:	e8 3d 02 00 00       	call   80045a <input>
		return;
  80021d:	83 c4 10             	add    $0x10,%esp
  800220:	eb d6                	jmp    8001f8 <umain+0x1c5>
		panic("sys_page_map: %e", r);
  800222:	50                   	push   %eax
  800223:	68 78 2d 80 00       	push   $0x802d78
  800228:	6a 19                	push   $0x19
  80022a:	68 38 2d 80 00       	push   $0x802d38
  80022f:	e8 46 06 00 00       	call   80087a <_panic>
			panic("ipc_recv: %e", req);
  800234:	50                   	push   %eax
  800235:	68 89 2d 80 00       	push   $0x802d89
  80023a:	6a 64                	push   $0x64
  80023c:	68 38 2d 80 00       	push   $0x802d38
  800241:	e8 34 06 00 00       	call   80087a <_panic>
			panic("IPC from unexpected environment %08x", whom);
  800246:	52                   	push   %edx
  800247:	68 e0 2d 80 00       	push   $0x802de0
  80024c:	6a 66                	push   $0x66
  80024e:	68 38 2d 80 00       	push   $0x802d38
  800253:	e8 22 06 00 00       	call   80087a <_panic>
			panic("Unexpected IPC %d", req);
  800258:	50                   	push   %eax
  800259:	68 96 2d 80 00       	push   $0x802d96
  80025e:	6a 68                	push   $0x68
  800260:	68 38 2d 80 00       	push   $0x802d38
  800265:	e8 10 06 00 00       	call   80087a <_panic>
			out = buf + snprintf(buf, end - buf,
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	53                   	push   %ebx
  80026e:	68 a8 2d 80 00       	push   $0x802da8
  800273:	68 b0 2d 80 00       	push   $0x802db0
  800278:	6a 50                	push   $0x50
  80027a:	8d 45 98             	lea    -0x68(%ebp),%eax
  80027d:	50                   	push   %eax
  80027e:	e8 57 0c 00 00       	call   800eda <snprintf>
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
  80029d:	68 bf 2d 80 00       	push   $0x802dbf
  8002a2:	e8 ae 06 00 00       	call   800955 <cprintf>
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
  8002d8:	68 ba 2d 80 00       	push   $0x802dba
  8002dd:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002e0:	29 f0                	sub    %esi,%eax
  8002e2:	50                   	push   %eax
  8002e3:	56                   	push   %esi
  8002e4:	e8 f1 0b 00 00       	call   800eda <snprintf>
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
  80031d:	68 db 2d 80 00       	push   $0x802ddb
  800322:	e8 2e 06 00 00       	call   800955 <cprintf>
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
  80034d:	e8 a9 14 00 00       	call   8017fb <ipc_recv>
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
  800395:	68 c5 2d 80 00       	push   $0x802dc5
  80039a:	e8 b6 05 00 00       	call   800955 <cprintf>
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
  8003b0:	e8 67 11 00 00       	call   80151c <sys_time_msec>
  8003b5:	03 45 0c             	add    0xc(%ebp),%eax
  8003b8:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  8003ba:	c7 05 00 40 80 00 05 	movl   $0x802e05,0x804000
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
  8003d4:	e8 89 14 00 00       	call   801862 <ipc_send>
  8003d9:	83 c4 10             	add    $0x10,%esp
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003dc:	83 ec 04             	sub    $0x4,%esp
  8003df:	6a 00                	push   $0x0
  8003e1:	6a 00                	push   $0x0
  8003e3:	57                   	push   %edi
  8003e4:	e8 12 14 00 00       	call   8017fb <ipc_recv>
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
  8003f5:	e8 22 11 00 00       	call   80151c <sys_time_msec>
  8003fa:	01 c3                	add    %eax,%ebx
		while((r = sys_time_msec()) < stop && r >= 0) {
  8003fc:	e8 1b 11 00 00       	call   80151c <sys_time_msec>
  800401:	85 c0                	test   %eax,%eax
  800403:	78 c4                	js     8003c9 <timer+0x25>
  800405:	39 d8                	cmp    %ebx,%eax
  800407:	73 c0                	jae    8003c9 <timer+0x25>
			sys_yield();
  800409:	e8 fe 0e 00 00       	call   80130c <sys_yield>
  80040e:	eb ec                	jmp    8003fc <timer+0x58>
			panic("sys_time_msec: %e", r);
  800410:	50                   	push   %eax
  800411:	68 0e 2e 80 00       	push   $0x802e0e
  800416:	6a 0f                	push   $0xf
  800418:	68 20 2e 80 00       	push   $0x802e20
  80041d:	e8 58 04 00 00       	call   80087a <_panic>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  800422:	83 ec 08             	sub    $0x8,%esp
  800425:	50                   	push   %eax
  800426:	68 2c 2e 80 00       	push   $0x802e2c
  80042b:	e8 25 05 00 00       	call   800955 <cprintf>
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
    unsigned now = sys_time_msec();
  80043d:	e8 da 10 00 00       	call   80151c <sys_time_msec>
  800442:	89 c3                	mov    %eax,%ebx

    while (msec > sys_time_msec()-now){
  800444:	eb 05                	jmp    80044b <sleep+0x16>
    	sys_yield();
  800446:	e8 c1 0e 00 00       	call   80130c <sys_yield>
    while (msec > sys_time_msec()-now){
  80044b:	e8 cc 10 00 00       	call   80151c <sys_time_msec>
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
  800469:	c7 05 00 40 80 00 67 	movl   $0x802e67,0x804000
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
  80047e:	e8 89 0e 00 00       	call   80130c <sys_yield>
		while ( sys_e1000_recv(rev_buf, &len)  < 0) {
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	56                   	push   %esi
  800487:	53                   	push   %ebx
  800488:	e8 cf 10 00 00       	call   80155c <sys_e1000_recv>
  80048d:	83 c4 10             	add    $0x10,%esp
  800490:	85 c0                	test   %eax,%eax
  800492:	78 ea                	js     80047e <input+0x24>
		}
		memcpy(nsipcbuf.pkt.jp_data, rev_buf, len);
  800494:	83 ec 04             	sub    $0x4,%esp
  800497:	ff 75 e4             	push   -0x1c(%ebp)
  80049a:	53                   	push   %ebx
  80049b:	68 04 80 80 00       	push   $0x808004
  8004a0:	e8 82 0c 00 00       	call   801127 <memcpy>
		nsipcbuf.pkt.jp_len = len;
  8004a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004a8:	a3 00 80 80 00       	mov    %eax,0x808000
		
		ipc_send(ns_envid, NSREQ_INPUT, &nsipcbuf, PTE_P|PTE_U);
  8004ad:	6a 05                	push   $0x5
  8004af:	68 00 80 80 00       	push   $0x808000
  8004b4:	6a 0a                	push   $0xa
  8004b6:	57                   	push   %edi
  8004b7:	e8 a6 13 00 00       	call   801862 <ipc_send>
		
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
  8004d6:	c7 05 00 40 80 00 70 	movl   $0x802e70,0x804000
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
  8004e5:	e8 22 0e 00 00       	call   80130c <sys_yield>
		while( sys_e1000_try_send( nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len ) < 0 ){
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	ff 35 00 80 80 00    	push   0x808000
  8004f3:	68 04 80 80 00       	push   $0x808004
  8004f8:	e8 3e 10 00 00       	call   80153b <sys_e1000_try_send>
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	85 c0                	test   %eax,%eax
  800502:	78 e1                	js     8004e5 <output+0x1a>
		r=ipc_recv( &from_env , &nsipcbuf, NULL);
  800504:	83 ec 04             	sub    $0x4,%esp
  800507:	6a 00                	push   $0x0
  800509:	68 00 80 80 00       	push   $0x808000
  80050e:	53                   	push   %ebx
  80050f:	e8 e7 12 00 00       	call   8017fb <ipc_recv>
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
  800825:	e8 c3 0a 00 00       	call   8012ed <sys_getenvid>
  80082a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80082f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800832:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800837:	a3 18 50 80 00       	mov    %eax,0x805018

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80083c:	85 db                	test   %ebx,%ebx
  80083e:	7e 07                	jle    800847 <libmain+0x2d>
		binaryname = argv[0];
  800840:	8b 06                	mov    (%esi),%eax
  800842:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800847:	83 ec 08             	sub    $0x8,%esp
  80084a:	56                   	push   %esi
  80084b:	53                   	push   %ebx
  80084c:	e8 e2 f7 ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800851:	e8 0a 00 00 00       	call   800860 <exit>
}
  800856:	83 c4 10             	add    $0x10,%esp
  800859:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80085c:	5b                   	pop    %ebx
  80085d:	5e                   	pop    %esi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800866:	e8 55 12 00 00       	call   801ac0 <close_all>
	sys_env_destroy(0);
  80086b:	83 ec 0c             	sub    $0xc,%esp
  80086e:	6a 00                	push   $0x0
  800870:	e8 37 0a 00 00       	call   8012ac <sys_env_destroy>
}
  800875:	83 c4 10             	add    $0x10,%esp
  800878:	c9                   	leave  
  800879:	c3                   	ret    

0080087a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	56                   	push   %esi
  80087e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80087f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800882:	8b 35 00 40 80 00    	mov    0x804000,%esi
  800888:	e8 60 0a 00 00       	call   8012ed <sys_getenvid>
  80088d:	83 ec 0c             	sub    $0xc,%esp
  800890:	ff 75 0c             	push   0xc(%ebp)
  800893:	ff 75 08             	push   0x8(%ebp)
  800896:	56                   	push   %esi
  800897:	50                   	push   %eax
  800898:	68 84 2e 80 00       	push   $0x802e84
  80089d:	e8 b3 00 00 00       	call   800955 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8008a2:	83 c4 18             	add    $0x18,%esp
  8008a5:	53                   	push   %ebx
  8008a6:	ff 75 10             	push   0x10(%ebp)
  8008a9:	e8 56 00 00 00       	call   800904 <vcprintf>
	cprintf("\n");
  8008ae:	c7 04 24 db 2d 80 00 	movl   $0x802ddb,(%esp)
  8008b5:	e8 9b 00 00 00       	call   800955 <cprintf>
  8008ba:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8008bd:	cc                   	int3   
  8008be:	eb fd                	jmp    8008bd <_panic+0x43>

008008c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	53                   	push   %ebx
  8008c4:	83 ec 04             	sub    $0x4,%esp
  8008c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8008ca:	8b 13                	mov    (%ebx),%edx
  8008cc:	8d 42 01             	lea    0x1(%edx),%eax
  8008cf:	89 03                	mov    %eax,(%ebx)
  8008d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8008d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8008dd:	74 09                	je     8008e8 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8008df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8008e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8008e8:	83 ec 08             	sub    $0x8,%esp
  8008eb:	68 ff 00 00 00       	push   $0xff
  8008f0:	8d 43 08             	lea    0x8(%ebx),%eax
  8008f3:	50                   	push   %eax
  8008f4:	e8 76 09 00 00       	call   80126f <sys_cputs>
		b->idx = 0;
  8008f9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	eb db                	jmp    8008df <putch+0x1f>

00800904 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80090d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800914:	00 00 00 
	b.cnt = 0;
  800917:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80091e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800921:	ff 75 0c             	push   0xc(%ebp)
  800924:	ff 75 08             	push   0x8(%ebp)
  800927:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80092d:	50                   	push   %eax
  80092e:	68 c0 08 80 00       	push   $0x8008c0
  800933:	e8 14 01 00 00       	call   800a4c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800938:	83 c4 08             	add    $0x8,%esp
  80093b:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800941:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800947:	50                   	push   %eax
  800948:	e8 22 09 00 00       	call   80126f <sys_cputs>

	return b.cnt;
}
  80094d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800953:	c9                   	leave  
  800954:	c3                   	ret    

00800955 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80095b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80095e:	50                   	push   %eax
  80095f:	ff 75 08             	push   0x8(%ebp)
  800962:	e8 9d ff ff ff       	call   800904 <vcprintf>
	va_end(ap);

	return cnt;
}
  800967:	c9                   	leave  
  800968:	c3                   	ret    

00800969 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	57                   	push   %edi
  80096d:	56                   	push   %esi
  80096e:	53                   	push   %ebx
  80096f:	83 ec 1c             	sub    $0x1c,%esp
  800972:	89 c7                	mov    %eax,%edi
  800974:	89 d6                	mov    %edx,%esi
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097c:	89 d1                	mov    %edx,%ecx
  80097e:	89 c2                	mov    %eax,%edx
  800980:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800983:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800986:	8b 45 10             	mov    0x10(%ebp),%eax
  800989:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80098c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80098f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800996:	39 c2                	cmp    %eax,%edx
  800998:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80099b:	72 3e                	jb     8009db <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80099d:	83 ec 0c             	sub    $0xc,%esp
  8009a0:	ff 75 18             	push   0x18(%ebp)
  8009a3:	83 eb 01             	sub    $0x1,%ebx
  8009a6:	53                   	push   %ebx
  8009a7:	50                   	push   %eax
  8009a8:	83 ec 08             	sub    $0x8,%esp
  8009ab:	ff 75 e4             	push   -0x1c(%ebp)
  8009ae:	ff 75 e0             	push   -0x20(%ebp)
  8009b1:	ff 75 dc             	push   -0x24(%ebp)
  8009b4:	ff 75 d8             	push   -0x28(%ebp)
  8009b7:	e8 24 21 00 00       	call   802ae0 <__udivdi3>
  8009bc:	83 c4 18             	add    $0x18,%esp
  8009bf:	52                   	push   %edx
  8009c0:	50                   	push   %eax
  8009c1:	89 f2                	mov    %esi,%edx
  8009c3:	89 f8                	mov    %edi,%eax
  8009c5:	e8 9f ff ff ff       	call   800969 <printnum>
  8009ca:	83 c4 20             	add    $0x20,%esp
  8009cd:	eb 13                	jmp    8009e2 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8009cf:	83 ec 08             	sub    $0x8,%esp
  8009d2:	56                   	push   %esi
  8009d3:	ff 75 18             	push   0x18(%ebp)
  8009d6:	ff d7                	call   *%edi
  8009d8:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8009db:	83 eb 01             	sub    $0x1,%ebx
  8009de:	85 db                	test   %ebx,%ebx
  8009e0:	7f ed                	jg     8009cf <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8009e2:	83 ec 08             	sub    $0x8,%esp
  8009e5:	56                   	push   %esi
  8009e6:	83 ec 04             	sub    $0x4,%esp
  8009e9:	ff 75 e4             	push   -0x1c(%ebp)
  8009ec:	ff 75 e0             	push   -0x20(%ebp)
  8009ef:	ff 75 dc             	push   -0x24(%ebp)
  8009f2:	ff 75 d8             	push   -0x28(%ebp)
  8009f5:	e8 06 22 00 00       	call   802c00 <__umoddi3>
  8009fa:	83 c4 14             	add    $0x14,%esp
  8009fd:	0f be 80 a7 2e 80 00 	movsbl 0x802ea7(%eax),%eax
  800a04:	50                   	push   %eax
  800a05:	ff d7                	call   *%edi
}
  800a07:	83 c4 10             	add    $0x10,%esp
  800a0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a0d:	5b                   	pop    %ebx
  800a0e:	5e                   	pop    %esi
  800a0f:	5f                   	pop    %edi
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800a18:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800a1c:	8b 10                	mov    (%eax),%edx
  800a1e:	3b 50 04             	cmp    0x4(%eax),%edx
  800a21:	73 0a                	jae    800a2d <sprintputch+0x1b>
		*b->buf++ = ch;
  800a23:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a26:	89 08                	mov    %ecx,(%eax)
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	88 02                	mov    %al,(%edx)
}
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <printfmt>:
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800a35:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800a38:	50                   	push   %eax
  800a39:	ff 75 10             	push   0x10(%ebp)
  800a3c:	ff 75 0c             	push   0xc(%ebp)
  800a3f:	ff 75 08             	push   0x8(%ebp)
  800a42:	e8 05 00 00 00       	call   800a4c <vprintfmt>
}
  800a47:	83 c4 10             	add    $0x10,%esp
  800a4a:	c9                   	leave  
  800a4b:	c3                   	ret    

00800a4c <vprintfmt>:
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	57                   	push   %edi
  800a50:	56                   	push   %esi
  800a51:	53                   	push   %ebx
  800a52:	83 ec 3c             	sub    $0x3c,%esp
  800a55:	8b 75 08             	mov    0x8(%ebp),%esi
  800a58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a5b:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a5e:	eb 0a                	jmp    800a6a <vprintfmt+0x1e>
			putch(ch, putdat);
  800a60:	83 ec 08             	sub    $0x8,%esp
  800a63:	53                   	push   %ebx
  800a64:	50                   	push   %eax
  800a65:	ff d6                	call   *%esi
  800a67:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a6a:	83 c7 01             	add    $0x1,%edi
  800a6d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a71:	83 f8 25             	cmp    $0x25,%eax
  800a74:	74 0c                	je     800a82 <vprintfmt+0x36>
			if (ch == '\0')
  800a76:	85 c0                	test   %eax,%eax
  800a78:	75 e6                	jne    800a60 <vprintfmt+0x14>
}
  800a7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a7d:	5b                   	pop    %ebx
  800a7e:	5e                   	pop    %esi
  800a7f:	5f                   	pop    %edi
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    
		padc = ' ';
  800a82:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800a86:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800a8d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800a94:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800a9b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800aa0:	8d 47 01             	lea    0x1(%edi),%eax
  800aa3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800aa6:	0f b6 17             	movzbl (%edi),%edx
  800aa9:	8d 42 dd             	lea    -0x23(%edx),%eax
  800aac:	3c 55                	cmp    $0x55,%al
  800aae:	0f 87 bb 03 00 00    	ja     800e6f <vprintfmt+0x423>
  800ab4:	0f b6 c0             	movzbl %al,%eax
  800ab7:	ff 24 85 e0 2f 80 00 	jmp    *0x802fe0(,%eax,4)
  800abe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800ac1:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800ac5:	eb d9                	jmp    800aa0 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800ac7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800aca:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800ace:	eb d0                	jmp    800aa0 <vprintfmt+0x54>
  800ad0:	0f b6 d2             	movzbl %dl,%edx
  800ad3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800ad6:	b8 00 00 00 00       	mov    $0x0,%eax
  800adb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800ade:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800ae1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800ae5:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800ae8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800aeb:	83 f9 09             	cmp    $0x9,%ecx
  800aee:	77 55                	ja     800b45 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800af0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800af3:	eb e9                	jmp    800ade <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800af5:	8b 45 14             	mov    0x14(%ebp),%eax
  800af8:	8b 00                	mov    (%eax),%eax
  800afa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800afd:	8b 45 14             	mov    0x14(%ebp),%eax
  800b00:	8d 40 04             	lea    0x4(%eax),%eax
  800b03:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800b06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800b09:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b0d:	79 91                	jns    800aa0 <vprintfmt+0x54>
				width = precision, precision = -1;
  800b0f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b12:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b15:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800b1c:	eb 82                	jmp    800aa0 <vprintfmt+0x54>
  800b1e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800b21:	85 d2                	test   %edx,%edx
  800b23:	b8 00 00 00 00       	mov    $0x0,%eax
  800b28:	0f 49 c2             	cmovns %edx,%eax
  800b2b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800b2e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800b31:	e9 6a ff ff ff       	jmp    800aa0 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800b36:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800b39:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800b40:	e9 5b ff ff ff       	jmp    800aa0 <vprintfmt+0x54>
  800b45:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800b48:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b4b:	eb bc                	jmp    800b09 <vprintfmt+0xbd>
			lflag++;
  800b4d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800b50:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800b53:	e9 48 ff ff ff       	jmp    800aa0 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800b58:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5b:	8d 78 04             	lea    0x4(%eax),%edi
  800b5e:	83 ec 08             	sub    $0x8,%esp
  800b61:	53                   	push   %ebx
  800b62:	ff 30                	push   (%eax)
  800b64:	ff d6                	call   *%esi
			break;
  800b66:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800b69:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800b6c:	e9 9d 02 00 00       	jmp    800e0e <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800b71:	8b 45 14             	mov    0x14(%ebp),%eax
  800b74:	8d 78 04             	lea    0x4(%eax),%edi
  800b77:	8b 10                	mov    (%eax),%edx
  800b79:	89 d0                	mov    %edx,%eax
  800b7b:	f7 d8                	neg    %eax
  800b7d:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b80:	83 f8 0f             	cmp    $0xf,%eax
  800b83:	7f 23                	jg     800ba8 <vprintfmt+0x15c>
  800b85:	8b 14 85 40 31 80 00 	mov    0x803140(,%eax,4),%edx
  800b8c:	85 d2                	test   %edx,%edx
  800b8e:	74 18                	je     800ba8 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800b90:	52                   	push   %edx
  800b91:	68 61 33 80 00       	push   $0x803361
  800b96:	53                   	push   %ebx
  800b97:	56                   	push   %esi
  800b98:	e8 92 fe ff ff       	call   800a2f <printfmt>
  800b9d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800ba0:	89 7d 14             	mov    %edi,0x14(%ebp)
  800ba3:	e9 66 02 00 00       	jmp    800e0e <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800ba8:	50                   	push   %eax
  800ba9:	68 bf 2e 80 00       	push   $0x802ebf
  800bae:	53                   	push   %ebx
  800baf:	56                   	push   %esi
  800bb0:	e8 7a fe ff ff       	call   800a2f <printfmt>
  800bb5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800bb8:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800bbb:	e9 4e 02 00 00       	jmp    800e0e <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800bc0:	8b 45 14             	mov    0x14(%ebp),%eax
  800bc3:	83 c0 04             	add    $0x4,%eax
  800bc6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800bc9:	8b 45 14             	mov    0x14(%ebp),%eax
  800bcc:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800bce:	85 d2                	test   %edx,%edx
  800bd0:	b8 b8 2e 80 00       	mov    $0x802eb8,%eax
  800bd5:	0f 45 c2             	cmovne %edx,%eax
  800bd8:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800bdb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800bdf:	7e 06                	jle    800be7 <vprintfmt+0x19b>
  800be1:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800be5:	75 0d                	jne    800bf4 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800be7:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800bea:	89 c7                	mov    %eax,%edi
  800bec:	03 45 e0             	add    -0x20(%ebp),%eax
  800bef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bf2:	eb 55                	jmp    800c49 <vprintfmt+0x1fd>
  800bf4:	83 ec 08             	sub    $0x8,%esp
  800bf7:	ff 75 d8             	push   -0x28(%ebp)
  800bfa:	ff 75 cc             	push   -0x34(%ebp)
  800bfd:	e8 0a 03 00 00       	call   800f0c <strnlen>
  800c02:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800c05:	29 c1                	sub    %eax,%ecx
  800c07:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800c0a:	83 c4 10             	add    $0x10,%esp
  800c0d:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800c0f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800c13:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800c16:	eb 0f                	jmp    800c27 <vprintfmt+0x1db>
					putch(padc, putdat);
  800c18:	83 ec 08             	sub    $0x8,%esp
  800c1b:	53                   	push   %ebx
  800c1c:	ff 75 e0             	push   -0x20(%ebp)
  800c1f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800c21:	83 ef 01             	sub    $0x1,%edi
  800c24:	83 c4 10             	add    $0x10,%esp
  800c27:	85 ff                	test   %edi,%edi
  800c29:	7f ed                	jg     800c18 <vprintfmt+0x1cc>
  800c2b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800c2e:	85 d2                	test   %edx,%edx
  800c30:	b8 00 00 00 00       	mov    $0x0,%eax
  800c35:	0f 49 c2             	cmovns %edx,%eax
  800c38:	29 c2                	sub    %eax,%edx
  800c3a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800c3d:	eb a8                	jmp    800be7 <vprintfmt+0x19b>
					putch(ch, putdat);
  800c3f:	83 ec 08             	sub    $0x8,%esp
  800c42:	53                   	push   %ebx
  800c43:	52                   	push   %edx
  800c44:	ff d6                	call   *%esi
  800c46:	83 c4 10             	add    $0x10,%esp
  800c49:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800c4c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c4e:	83 c7 01             	add    $0x1,%edi
  800c51:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c55:	0f be d0             	movsbl %al,%edx
  800c58:	85 d2                	test   %edx,%edx
  800c5a:	74 4b                	je     800ca7 <vprintfmt+0x25b>
  800c5c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800c60:	78 06                	js     800c68 <vprintfmt+0x21c>
  800c62:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800c66:	78 1e                	js     800c86 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800c68:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800c6c:	74 d1                	je     800c3f <vprintfmt+0x1f3>
  800c6e:	0f be c0             	movsbl %al,%eax
  800c71:	83 e8 20             	sub    $0x20,%eax
  800c74:	83 f8 5e             	cmp    $0x5e,%eax
  800c77:	76 c6                	jbe    800c3f <vprintfmt+0x1f3>
					putch('?', putdat);
  800c79:	83 ec 08             	sub    $0x8,%esp
  800c7c:	53                   	push   %ebx
  800c7d:	6a 3f                	push   $0x3f
  800c7f:	ff d6                	call   *%esi
  800c81:	83 c4 10             	add    $0x10,%esp
  800c84:	eb c3                	jmp    800c49 <vprintfmt+0x1fd>
  800c86:	89 cf                	mov    %ecx,%edi
  800c88:	eb 0e                	jmp    800c98 <vprintfmt+0x24c>
				putch(' ', putdat);
  800c8a:	83 ec 08             	sub    $0x8,%esp
  800c8d:	53                   	push   %ebx
  800c8e:	6a 20                	push   $0x20
  800c90:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800c92:	83 ef 01             	sub    $0x1,%edi
  800c95:	83 c4 10             	add    $0x10,%esp
  800c98:	85 ff                	test   %edi,%edi
  800c9a:	7f ee                	jg     800c8a <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800c9c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800c9f:	89 45 14             	mov    %eax,0x14(%ebp)
  800ca2:	e9 67 01 00 00       	jmp    800e0e <vprintfmt+0x3c2>
  800ca7:	89 cf                	mov    %ecx,%edi
  800ca9:	eb ed                	jmp    800c98 <vprintfmt+0x24c>
	if (lflag >= 2)
  800cab:	83 f9 01             	cmp    $0x1,%ecx
  800cae:	7f 1b                	jg     800ccb <vprintfmt+0x27f>
	else if (lflag)
  800cb0:	85 c9                	test   %ecx,%ecx
  800cb2:	74 63                	je     800d17 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800cb4:	8b 45 14             	mov    0x14(%ebp),%eax
  800cb7:	8b 00                	mov    (%eax),%eax
  800cb9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800cbc:	99                   	cltd   
  800cbd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800cc0:	8b 45 14             	mov    0x14(%ebp),%eax
  800cc3:	8d 40 04             	lea    0x4(%eax),%eax
  800cc6:	89 45 14             	mov    %eax,0x14(%ebp)
  800cc9:	eb 17                	jmp    800ce2 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800ccb:	8b 45 14             	mov    0x14(%ebp),%eax
  800cce:	8b 50 04             	mov    0x4(%eax),%edx
  800cd1:	8b 00                	mov    (%eax),%eax
  800cd3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800cd6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800cd9:	8b 45 14             	mov    0x14(%ebp),%eax
  800cdc:	8d 40 08             	lea    0x8(%eax),%eax
  800cdf:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800ce2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ce5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800ce8:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800ced:	85 c9                	test   %ecx,%ecx
  800cef:	0f 89 ff 00 00 00    	jns    800df4 <vprintfmt+0x3a8>
				putch('-', putdat);
  800cf5:	83 ec 08             	sub    $0x8,%esp
  800cf8:	53                   	push   %ebx
  800cf9:	6a 2d                	push   $0x2d
  800cfb:	ff d6                	call   *%esi
				num = -(long long) num;
  800cfd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800d00:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800d03:	f7 da                	neg    %edx
  800d05:	83 d1 00             	adc    $0x0,%ecx
  800d08:	f7 d9                	neg    %ecx
  800d0a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800d0d:	bf 0a 00 00 00       	mov    $0xa,%edi
  800d12:	e9 dd 00 00 00       	jmp    800df4 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800d17:	8b 45 14             	mov    0x14(%ebp),%eax
  800d1a:	8b 00                	mov    (%eax),%eax
  800d1c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d1f:	99                   	cltd   
  800d20:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800d23:	8b 45 14             	mov    0x14(%ebp),%eax
  800d26:	8d 40 04             	lea    0x4(%eax),%eax
  800d29:	89 45 14             	mov    %eax,0x14(%ebp)
  800d2c:	eb b4                	jmp    800ce2 <vprintfmt+0x296>
	if (lflag >= 2)
  800d2e:	83 f9 01             	cmp    $0x1,%ecx
  800d31:	7f 1e                	jg     800d51 <vprintfmt+0x305>
	else if (lflag)
  800d33:	85 c9                	test   %ecx,%ecx
  800d35:	74 32                	je     800d69 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800d37:	8b 45 14             	mov    0x14(%ebp),%eax
  800d3a:	8b 10                	mov    (%eax),%edx
  800d3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d41:	8d 40 04             	lea    0x4(%eax),%eax
  800d44:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800d47:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800d4c:	e9 a3 00 00 00       	jmp    800df4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800d51:	8b 45 14             	mov    0x14(%ebp),%eax
  800d54:	8b 10                	mov    (%eax),%edx
  800d56:	8b 48 04             	mov    0x4(%eax),%ecx
  800d59:	8d 40 08             	lea    0x8(%eax),%eax
  800d5c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800d5f:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800d64:	e9 8b 00 00 00       	jmp    800df4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800d69:	8b 45 14             	mov    0x14(%ebp),%eax
  800d6c:	8b 10                	mov    (%eax),%edx
  800d6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d73:	8d 40 04             	lea    0x4(%eax),%eax
  800d76:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800d79:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800d7e:	eb 74                	jmp    800df4 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800d80:	83 f9 01             	cmp    $0x1,%ecx
  800d83:	7f 1b                	jg     800da0 <vprintfmt+0x354>
	else if (lflag)
  800d85:	85 c9                	test   %ecx,%ecx
  800d87:	74 2c                	je     800db5 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800d89:	8b 45 14             	mov    0x14(%ebp),%eax
  800d8c:	8b 10                	mov    (%eax),%edx
  800d8e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d93:	8d 40 04             	lea    0x4(%eax),%eax
  800d96:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800d99:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800d9e:	eb 54                	jmp    800df4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800da0:	8b 45 14             	mov    0x14(%ebp),%eax
  800da3:	8b 10                	mov    (%eax),%edx
  800da5:	8b 48 04             	mov    0x4(%eax),%ecx
  800da8:	8d 40 08             	lea    0x8(%eax),%eax
  800dab:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800dae:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800db3:	eb 3f                	jmp    800df4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800db5:	8b 45 14             	mov    0x14(%ebp),%eax
  800db8:	8b 10                	mov    (%eax),%edx
  800dba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbf:	8d 40 04             	lea    0x4(%eax),%eax
  800dc2:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800dc5:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800dca:	eb 28                	jmp    800df4 <vprintfmt+0x3a8>
			putch('0', putdat);
  800dcc:	83 ec 08             	sub    $0x8,%esp
  800dcf:	53                   	push   %ebx
  800dd0:	6a 30                	push   $0x30
  800dd2:	ff d6                	call   *%esi
			putch('x', putdat);
  800dd4:	83 c4 08             	add    $0x8,%esp
  800dd7:	53                   	push   %ebx
  800dd8:	6a 78                	push   $0x78
  800dda:	ff d6                	call   *%esi
			num = (unsigned long long)
  800ddc:	8b 45 14             	mov    0x14(%ebp),%eax
  800ddf:	8b 10                	mov    (%eax),%edx
  800de1:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800de6:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800de9:	8d 40 04             	lea    0x4(%eax),%eax
  800dec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800def:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800df4:	83 ec 0c             	sub    $0xc,%esp
  800df7:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800dfb:	50                   	push   %eax
  800dfc:	ff 75 e0             	push   -0x20(%ebp)
  800dff:	57                   	push   %edi
  800e00:	51                   	push   %ecx
  800e01:	52                   	push   %edx
  800e02:	89 da                	mov    %ebx,%edx
  800e04:	89 f0                	mov    %esi,%eax
  800e06:	e8 5e fb ff ff       	call   800969 <printnum>
			break;
  800e0b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800e0e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800e11:	e9 54 fc ff ff       	jmp    800a6a <vprintfmt+0x1e>
	if (lflag >= 2)
  800e16:	83 f9 01             	cmp    $0x1,%ecx
  800e19:	7f 1b                	jg     800e36 <vprintfmt+0x3ea>
	else if (lflag)
  800e1b:	85 c9                	test   %ecx,%ecx
  800e1d:	74 2c                	je     800e4b <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800e1f:	8b 45 14             	mov    0x14(%ebp),%eax
  800e22:	8b 10                	mov    (%eax),%edx
  800e24:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e29:	8d 40 04             	lea    0x4(%eax),%eax
  800e2c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800e2f:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800e34:	eb be                	jmp    800df4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800e36:	8b 45 14             	mov    0x14(%ebp),%eax
  800e39:	8b 10                	mov    (%eax),%edx
  800e3b:	8b 48 04             	mov    0x4(%eax),%ecx
  800e3e:	8d 40 08             	lea    0x8(%eax),%eax
  800e41:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800e44:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800e49:	eb a9                	jmp    800df4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800e4b:	8b 45 14             	mov    0x14(%ebp),%eax
  800e4e:	8b 10                	mov    (%eax),%edx
  800e50:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e55:	8d 40 04             	lea    0x4(%eax),%eax
  800e58:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800e5b:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800e60:	eb 92                	jmp    800df4 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800e62:	83 ec 08             	sub    $0x8,%esp
  800e65:	53                   	push   %ebx
  800e66:	6a 25                	push   $0x25
  800e68:	ff d6                	call   *%esi
			break;
  800e6a:	83 c4 10             	add    $0x10,%esp
  800e6d:	eb 9f                	jmp    800e0e <vprintfmt+0x3c2>
			putch('%', putdat);
  800e6f:	83 ec 08             	sub    $0x8,%esp
  800e72:	53                   	push   %ebx
  800e73:	6a 25                	push   $0x25
  800e75:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800e77:	83 c4 10             	add    $0x10,%esp
  800e7a:	89 f8                	mov    %edi,%eax
  800e7c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800e80:	74 05                	je     800e87 <vprintfmt+0x43b>
  800e82:	83 e8 01             	sub    $0x1,%eax
  800e85:	eb f5                	jmp    800e7c <vprintfmt+0x430>
  800e87:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e8a:	eb 82                	jmp    800e0e <vprintfmt+0x3c2>

00800e8c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	83 ec 18             	sub    $0x18,%esp
  800e92:	8b 45 08             	mov    0x8(%ebp),%eax
  800e95:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800e98:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e9b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800e9f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ea2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ea9:	85 c0                	test   %eax,%eax
  800eab:	74 26                	je     800ed3 <vsnprintf+0x47>
  800ead:	85 d2                	test   %edx,%edx
  800eaf:	7e 22                	jle    800ed3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800eb1:	ff 75 14             	push   0x14(%ebp)
  800eb4:	ff 75 10             	push   0x10(%ebp)
  800eb7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800eba:	50                   	push   %eax
  800ebb:	68 12 0a 80 00       	push   $0x800a12
  800ec0:	e8 87 fb ff ff       	call   800a4c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ec5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ec8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ece:	83 c4 10             	add    $0x10,%esp
}
  800ed1:	c9                   	leave  
  800ed2:	c3                   	ret    
		return -E_INVAL;
  800ed3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed8:	eb f7                	jmp    800ed1 <vsnprintf+0x45>

00800eda <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ee0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ee3:	50                   	push   %eax
  800ee4:	ff 75 10             	push   0x10(%ebp)
  800ee7:	ff 75 0c             	push   0xc(%ebp)
  800eea:	ff 75 08             	push   0x8(%ebp)
  800eed:	e8 9a ff ff ff       	call   800e8c <vsnprintf>
	va_end(ap);

	return rc;
}
  800ef2:	c9                   	leave  
  800ef3:	c3                   	ret    

00800ef4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800efa:	b8 00 00 00 00       	mov    $0x0,%eax
  800eff:	eb 03                	jmp    800f04 <strlen+0x10>
		n++;
  800f01:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800f04:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800f08:	75 f7                	jne    800f01 <strlen+0xd>
	return n;
}
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f12:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f15:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1a:	eb 03                	jmp    800f1f <strnlen+0x13>
		n++;
  800f1c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f1f:	39 d0                	cmp    %edx,%eax
  800f21:	74 08                	je     800f2b <strnlen+0x1f>
  800f23:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800f27:	75 f3                	jne    800f1c <strnlen+0x10>
  800f29:	89 c2                	mov    %eax,%edx
	return n;
}
  800f2b:	89 d0                	mov    %edx,%eax
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    

00800f2f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	53                   	push   %ebx
  800f33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f36:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800f39:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3e:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800f42:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800f45:	83 c0 01             	add    $0x1,%eax
  800f48:	84 d2                	test   %dl,%dl
  800f4a:	75 f2                	jne    800f3e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800f4c:	89 c8                	mov    %ecx,%eax
  800f4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    

00800f53 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	53                   	push   %ebx
  800f57:	83 ec 10             	sub    $0x10,%esp
  800f5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800f5d:	53                   	push   %ebx
  800f5e:	e8 91 ff ff ff       	call   800ef4 <strlen>
  800f63:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800f66:	ff 75 0c             	push   0xc(%ebp)
  800f69:	01 d8                	add    %ebx,%eax
  800f6b:	50                   	push   %eax
  800f6c:	e8 be ff ff ff       	call   800f2f <strcpy>
	return dst;
}
  800f71:	89 d8                	mov    %ebx,%eax
  800f73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f76:	c9                   	leave  
  800f77:	c3                   	ret    

00800f78 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	56                   	push   %esi
  800f7c:	53                   	push   %ebx
  800f7d:	8b 75 08             	mov    0x8(%ebp),%esi
  800f80:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f83:	89 f3                	mov    %esi,%ebx
  800f85:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f88:	89 f0                	mov    %esi,%eax
  800f8a:	eb 0f                	jmp    800f9b <strncpy+0x23>
		*dst++ = *src;
  800f8c:	83 c0 01             	add    $0x1,%eax
  800f8f:	0f b6 0a             	movzbl (%edx),%ecx
  800f92:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800f95:	80 f9 01             	cmp    $0x1,%cl
  800f98:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800f9b:	39 d8                	cmp    %ebx,%eax
  800f9d:	75 ed                	jne    800f8c <strncpy+0x14>
	}
	return ret;
}
  800f9f:	89 f0                	mov    %esi,%eax
  800fa1:	5b                   	pop    %ebx
  800fa2:	5e                   	pop    %esi
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    

00800fa5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	56                   	push   %esi
  800fa9:	53                   	push   %ebx
  800faa:	8b 75 08             	mov    0x8(%ebp),%esi
  800fad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb0:	8b 55 10             	mov    0x10(%ebp),%edx
  800fb3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800fb5:	85 d2                	test   %edx,%edx
  800fb7:	74 21                	je     800fda <strlcpy+0x35>
  800fb9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800fbd:	89 f2                	mov    %esi,%edx
  800fbf:	eb 09                	jmp    800fca <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800fc1:	83 c1 01             	add    $0x1,%ecx
  800fc4:	83 c2 01             	add    $0x1,%edx
  800fc7:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800fca:	39 c2                	cmp    %eax,%edx
  800fcc:	74 09                	je     800fd7 <strlcpy+0x32>
  800fce:	0f b6 19             	movzbl (%ecx),%ebx
  800fd1:	84 db                	test   %bl,%bl
  800fd3:	75 ec                	jne    800fc1 <strlcpy+0x1c>
  800fd5:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800fd7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800fda:	29 f0                	sub    %esi,%eax
}
  800fdc:	5b                   	pop    %ebx
  800fdd:	5e                   	pop    %esi
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    

00800fe0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800fe9:	eb 06                	jmp    800ff1 <strcmp+0x11>
		p++, q++;
  800feb:	83 c1 01             	add    $0x1,%ecx
  800fee:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800ff1:	0f b6 01             	movzbl (%ecx),%eax
  800ff4:	84 c0                	test   %al,%al
  800ff6:	74 04                	je     800ffc <strcmp+0x1c>
  800ff8:	3a 02                	cmp    (%edx),%al
  800ffa:	74 ef                	je     800feb <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ffc:	0f b6 c0             	movzbl %al,%eax
  800fff:	0f b6 12             	movzbl (%edx),%edx
  801002:	29 d0                	sub    %edx,%eax
}
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    

00801006 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	53                   	push   %ebx
  80100a:	8b 45 08             	mov    0x8(%ebp),%eax
  80100d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801010:	89 c3                	mov    %eax,%ebx
  801012:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801015:	eb 06                	jmp    80101d <strncmp+0x17>
		n--, p++, q++;
  801017:	83 c0 01             	add    $0x1,%eax
  80101a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80101d:	39 d8                	cmp    %ebx,%eax
  80101f:	74 18                	je     801039 <strncmp+0x33>
  801021:	0f b6 08             	movzbl (%eax),%ecx
  801024:	84 c9                	test   %cl,%cl
  801026:	74 04                	je     80102c <strncmp+0x26>
  801028:	3a 0a                	cmp    (%edx),%cl
  80102a:	74 eb                	je     801017 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80102c:	0f b6 00             	movzbl (%eax),%eax
  80102f:	0f b6 12             	movzbl (%edx),%edx
  801032:	29 d0                	sub    %edx,%eax
}
  801034:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801037:	c9                   	leave  
  801038:	c3                   	ret    
		return 0;
  801039:	b8 00 00 00 00       	mov    $0x0,%eax
  80103e:	eb f4                	jmp    801034 <strncmp+0x2e>

00801040 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	8b 45 08             	mov    0x8(%ebp),%eax
  801046:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80104a:	eb 03                	jmp    80104f <strchr+0xf>
  80104c:	83 c0 01             	add    $0x1,%eax
  80104f:	0f b6 10             	movzbl (%eax),%edx
  801052:	84 d2                	test   %dl,%dl
  801054:	74 06                	je     80105c <strchr+0x1c>
		if (*s == c)
  801056:	38 ca                	cmp    %cl,%dl
  801058:	75 f2                	jne    80104c <strchr+0xc>
  80105a:	eb 05                	jmp    801061 <strchr+0x21>
			return (char *) s;
	return 0;
  80105c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801061:	5d                   	pop    %ebp
  801062:	c3                   	ret    

00801063 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	8b 45 08             	mov    0x8(%ebp),%eax
  801069:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80106d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801070:	38 ca                	cmp    %cl,%dl
  801072:	74 09                	je     80107d <strfind+0x1a>
  801074:	84 d2                	test   %dl,%dl
  801076:	74 05                	je     80107d <strfind+0x1a>
	for (; *s; s++)
  801078:	83 c0 01             	add    $0x1,%eax
  80107b:	eb f0                	jmp    80106d <strfind+0xa>
			break;
	return (char *) s;
}
  80107d:	5d                   	pop    %ebp
  80107e:	c3                   	ret    

0080107f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	57                   	push   %edi
  801083:	56                   	push   %esi
  801084:	53                   	push   %ebx
  801085:	8b 7d 08             	mov    0x8(%ebp),%edi
  801088:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80108b:	85 c9                	test   %ecx,%ecx
  80108d:	74 2f                	je     8010be <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80108f:	89 f8                	mov    %edi,%eax
  801091:	09 c8                	or     %ecx,%eax
  801093:	a8 03                	test   $0x3,%al
  801095:	75 21                	jne    8010b8 <memset+0x39>
		c &= 0xFF;
  801097:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80109b:	89 d0                	mov    %edx,%eax
  80109d:	c1 e0 08             	shl    $0x8,%eax
  8010a0:	89 d3                	mov    %edx,%ebx
  8010a2:	c1 e3 18             	shl    $0x18,%ebx
  8010a5:	89 d6                	mov    %edx,%esi
  8010a7:	c1 e6 10             	shl    $0x10,%esi
  8010aa:	09 f3                	or     %esi,%ebx
  8010ac:	09 da                	or     %ebx,%edx
  8010ae:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8010b0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8010b3:	fc                   	cld    
  8010b4:	f3 ab                	rep stos %eax,%es:(%edi)
  8010b6:	eb 06                	jmp    8010be <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8010b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010bb:	fc                   	cld    
  8010bc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8010be:	89 f8                	mov    %edi,%eax
  8010c0:	5b                   	pop    %ebx
  8010c1:	5e                   	pop    %esi
  8010c2:	5f                   	pop    %edi
  8010c3:	5d                   	pop    %ebp
  8010c4:	c3                   	ret    

008010c5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	57                   	push   %edi
  8010c9:	56                   	push   %esi
  8010ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8010d3:	39 c6                	cmp    %eax,%esi
  8010d5:	73 32                	jae    801109 <memmove+0x44>
  8010d7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8010da:	39 c2                	cmp    %eax,%edx
  8010dc:	76 2b                	jbe    801109 <memmove+0x44>
		s += n;
		d += n;
  8010de:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8010e1:	89 d6                	mov    %edx,%esi
  8010e3:	09 fe                	or     %edi,%esi
  8010e5:	09 ce                	or     %ecx,%esi
  8010e7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8010ed:	75 0e                	jne    8010fd <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8010ef:	83 ef 04             	sub    $0x4,%edi
  8010f2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8010f5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8010f8:	fd                   	std    
  8010f9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8010fb:	eb 09                	jmp    801106 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8010fd:	83 ef 01             	sub    $0x1,%edi
  801100:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801103:	fd                   	std    
  801104:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801106:	fc                   	cld    
  801107:	eb 1a                	jmp    801123 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801109:	89 f2                	mov    %esi,%edx
  80110b:	09 c2                	or     %eax,%edx
  80110d:	09 ca                	or     %ecx,%edx
  80110f:	f6 c2 03             	test   $0x3,%dl
  801112:	75 0a                	jne    80111e <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801114:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801117:	89 c7                	mov    %eax,%edi
  801119:	fc                   	cld    
  80111a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80111c:	eb 05                	jmp    801123 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  80111e:	89 c7                	mov    %eax,%edi
  801120:	fc                   	cld    
  801121:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801123:	5e                   	pop    %esi
  801124:	5f                   	pop    %edi
  801125:	5d                   	pop    %ebp
  801126:	c3                   	ret    

00801127 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80112d:	ff 75 10             	push   0x10(%ebp)
  801130:	ff 75 0c             	push   0xc(%ebp)
  801133:	ff 75 08             	push   0x8(%ebp)
  801136:	e8 8a ff ff ff       	call   8010c5 <memmove>
}
  80113b:	c9                   	leave  
  80113c:	c3                   	ret    

0080113d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	56                   	push   %esi
  801141:	53                   	push   %ebx
  801142:	8b 45 08             	mov    0x8(%ebp),%eax
  801145:	8b 55 0c             	mov    0xc(%ebp),%edx
  801148:	89 c6                	mov    %eax,%esi
  80114a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80114d:	eb 06                	jmp    801155 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80114f:	83 c0 01             	add    $0x1,%eax
  801152:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801155:	39 f0                	cmp    %esi,%eax
  801157:	74 14                	je     80116d <memcmp+0x30>
		if (*s1 != *s2)
  801159:	0f b6 08             	movzbl (%eax),%ecx
  80115c:	0f b6 1a             	movzbl (%edx),%ebx
  80115f:	38 d9                	cmp    %bl,%cl
  801161:	74 ec                	je     80114f <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801163:	0f b6 c1             	movzbl %cl,%eax
  801166:	0f b6 db             	movzbl %bl,%ebx
  801169:	29 d8                	sub    %ebx,%eax
  80116b:	eb 05                	jmp    801172 <memcmp+0x35>
	}

	return 0;
  80116d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801172:	5b                   	pop    %ebx
  801173:	5e                   	pop    %esi
  801174:	5d                   	pop    %ebp
  801175:	c3                   	ret    

00801176 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	8b 45 08             	mov    0x8(%ebp),%eax
  80117c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80117f:	89 c2                	mov    %eax,%edx
  801181:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801184:	eb 03                	jmp    801189 <memfind+0x13>
  801186:	83 c0 01             	add    $0x1,%eax
  801189:	39 d0                	cmp    %edx,%eax
  80118b:	73 04                	jae    801191 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80118d:	38 08                	cmp    %cl,(%eax)
  80118f:	75 f5                	jne    801186 <memfind+0x10>
			break;
	return (void *) s;
}
  801191:	5d                   	pop    %ebp
  801192:	c3                   	ret    

00801193 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	57                   	push   %edi
  801197:	56                   	push   %esi
  801198:	53                   	push   %ebx
  801199:	8b 55 08             	mov    0x8(%ebp),%edx
  80119c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80119f:	eb 03                	jmp    8011a4 <strtol+0x11>
		s++;
  8011a1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8011a4:	0f b6 02             	movzbl (%edx),%eax
  8011a7:	3c 20                	cmp    $0x20,%al
  8011a9:	74 f6                	je     8011a1 <strtol+0xe>
  8011ab:	3c 09                	cmp    $0x9,%al
  8011ad:	74 f2                	je     8011a1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8011af:	3c 2b                	cmp    $0x2b,%al
  8011b1:	74 2a                	je     8011dd <strtol+0x4a>
	int neg = 0;
  8011b3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8011b8:	3c 2d                	cmp    $0x2d,%al
  8011ba:	74 2b                	je     8011e7 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8011bc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8011c2:	75 0f                	jne    8011d3 <strtol+0x40>
  8011c4:	80 3a 30             	cmpb   $0x30,(%edx)
  8011c7:	74 28                	je     8011f1 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8011c9:	85 db                	test   %ebx,%ebx
  8011cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011d0:	0f 44 d8             	cmove  %eax,%ebx
  8011d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011d8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8011db:	eb 46                	jmp    801223 <strtol+0x90>
		s++;
  8011dd:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8011e0:	bf 00 00 00 00       	mov    $0x0,%edi
  8011e5:	eb d5                	jmp    8011bc <strtol+0x29>
		s++, neg = 1;
  8011e7:	83 c2 01             	add    $0x1,%edx
  8011ea:	bf 01 00 00 00       	mov    $0x1,%edi
  8011ef:	eb cb                	jmp    8011bc <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8011f1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8011f5:	74 0e                	je     801205 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8011f7:	85 db                	test   %ebx,%ebx
  8011f9:	75 d8                	jne    8011d3 <strtol+0x40>
		s++, base = 8;
  8011fb:	83 c2 01             	add    $0x1,%edx
  8011fe:	bb 08 00 00 00       	mov    $0x8,%ebx
  801203:	eb ce                	jmp    8011d3 <strtol+0x40>
		s += 2, base = 16;
  801205:	83 c2 02             	add    $0x2,%edx
  801208:	bb 10 00 00 00       	mov    $0x10,%ebx
  80120d:	eb c4                	jmp    8011d3 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  80120f:	0f be c0             	movsbl %al,%eax
  801212:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801215:	3b 45 10             	cmp    0x10(%ebp),%eax
  801218:	7d 3a                	jge    801254 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  80121a:	83 c2 01             	add    $0x1,%edx
  80121d:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801221:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801223:	0f b6 02             	movzbl (%edx),%eax
  801226:	8d 70 d0             	lea    -0x30(%eax),%esi
  801229:	89 f3                	mov    %esi,%ebx
  80122b:	80 fb 09             	cmp    $0x9,%bl
  80122e:	76 df                	jbe    80120f <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801230:	8d 70 9f             	lea    -0x61(%eax),%esi
  801233:	89 f3                	mov    %esi,%ebx
  801235:	80 fb 19             	cmp    $0x19,%bl
  801238:	77 08                	ja     801242 <strtol+0xaf>
			dig = *s - 'a' + 10;
  80123a:	0f be c0             	movsbl %al,%eax
  80123d:	83 e8 57             	sub    $0x57,%eax
  801240:	eb d3                	jmp    801215 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801242:	8d 70 bf             	lea    -0x41(%eax),%esi
  801245:	89 f3                	mov    %esi,%ebx
  801247:	80 fb 19             	cmp    $0x19,%bl
  80124a:	77 08                	ja     801254 <strtol+0xc1>
			dig = *s - 'A' + 10;
  80124c:	0f be c0             	movsbl %al,%eax
  80124f:	83 e8 37             	sub    $0x37,%eax
  801252:	eb c1                	jmp    801215 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801254:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801258:	74 05                	je     80125f <strtol+0xcc>
		*endptr = (char *) s;
  80125a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80125d:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  80125f:	89 c8                	mov    %ecx,%eax
  801261:	f7 d8                	neg    %eax
  801263:	85 ff                	test   %edi,%edi
  801265:	0f 45 c8             	cmovne %eax,%ecx
}
  801268:	89 c8                	mov    %ecx,%eax
  80126a:	5b                   	pop    %ebx
  80126b:	5e                   	pop    %esi
  80126c:	5f                   	pop    %edi
  80126d:	5d                   	pop    %ebp
  80126e:	c3                   	ret    

0080126f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	57                   	push   %edi
  801273:	56                   	push   %esi
  801274:	53                   	push   %ebx
	asm volatile("int %1\n"
  801275:	b8 00 00 00 00       	mov    $0x0,%eax
  80127a:	8b 55 08             	mov    0x8(%ebp),%edx
  80127d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801280:	89 c3                	mov    %eax,%ebx
  801282:	89 c7                	mov    %eax,%edi
  801284:	89 c6                	mov    %eax,%esi
  801286:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801288:	5b                   	pop    %ebx
  801289:	5e                   	pop    %esi
  80128a:	5f                   	pop    %edi
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <sys_cgetc>:

int
sys_cgetc(void)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	57                   	push   %edi
  801291:	56                   	push   %esi
  801292:	53                   	push   %ebx
	asm volatile("int %1\n"
  801293:	ba 00 00 00 00       	mov    $0x0,%edx
  801298:	b8 01 00 00 00       	mov    $0x1,%eax
  80129d:	89 d1                	mov    %edx,%ecx
  80129f:	89 d3                	mov    %edx,%ebx
  8012a1:	89 d7                	mov    %edx,%edi
  8012a3:	89 d6                	mov    %edx,%esi
  8012a5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8012a7:	5b                   	pop    %ebx
  8012a8:	5e                   	pop    %esi
  8012a9:	5f                   	pop    %edi
  8012aa:	5d                   	pop    %ebp
  8012ab:	c3                   	ret    

008012ac <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	57                   	push   %edi
  8012b0:	56                   	push   %esi
  8012b1:	53                   	push   %ebx
  8012b2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8012bd:	b8 03 00 00 00       	mov    $0x3,%eax
  8012c2:	89 cb                	mov    %ecx,%ebx
  8012c4:	89 cf                	mov    %ecx,%edi
  8012c6:	89 ce                	mov    %ecx,%esi
  8012c8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	7f 08                	jg     8012d6 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8012ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d1:	5b                   	pop    %ebx
  8012d2:	5e                   	pop    %esi
  8012d3:	5f                   	pop    %edi
  8012d4:	5d                   	pop    %ebp
  8012d5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8012d6:	83 ec 0c             	sub    $0xc,%esp
  8012d9:	50                   	push   %eax
  8012da:	6a 03                	push   $0x3
  8012dc:	68 9f 31 80 00       	push   $0x80319f
  8012e1:	6a 2a                	push   $0x2a
  8012e3:	68 bc 31 80 00       	push   $0x8031bc
  8012e8:	e8 8d f5 ff ff       	call   80087a <_panic>

008012ed <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	57                   	push   %edi
  8012f1:	56                   	push   %esi
  8012f2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8012f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f8:	b8 02 00 00 00       	mov    $0x2,%eax
  8012fd:	89 d1                	mov    %edx,%ecx
  8012ff:	89 d3                	mov    %edx,%ebx
  801301:	89 d7                	mov    %edx,%edi
  801303:	89 d6                	mov    %edx,%esi
  801305:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801307:	5b                   	pop    %ebx
  801308:	5e                   	pop    %esi
  801309:	5f                   	pop    %edi
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    

0080130c <sys_yield>:

void
sys_yield(void)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	57                   	push   %edi
  801310:	56                   	push   %esi
  801311:	53                   	push   %ebx
	asm volatile("int %1\n"
  801312:	ba 00 00 00 00       	mov    $0x0,%edx
  801317:	b8 0b 00 00 00       	mov    $0xb,%eax
  80131c:	89 d1                	mov    %edx,%ecx
  80131e:	89 d3                	mov    %edx,%ebx
  801320:	89 d7                	mov    %edx,%edi
  801322:	89 d6                	mov    %edx,%esi
  801324:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801326:	5b                   	pop    %ebx
  801327:	5e                   	pop    %esi
  801328:	5f                   	pop    %edi
  801329:	5d                   	pop    %ebp
  80132a:	c3                   	ret    

0080132b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80132b:	55                   	push   %ebp
  80132c:	89 e5                	mov    %esp,%ebp
  80132e:	57                   	push   %edi
  80132f:	56                   	push   %esi
  801330:	53                   	push   %ebx
  801331:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801334:	be 00 00 00 00       	mov    $0x0,%esi
  801339:	8b 55 08             	mov    0x8(%ebp),%edx
  80133c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133f:	b8 04 00 00 00       	mov    $0x4,%eax
  801344:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801347:	89 f7                	mov    %esi,%edi
  801349:	cd 30                	int    $0x30
	if(check && ret > 0)
  80134b:	85 c0                	test   %eax,%eax
  80134d:	7f 08                	jg     801357 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80134f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801352:	5b                   	pop    %ebx
  801353:	5e                   	pop    %esi
  801354:	5f                   	pop    %edi
  801355:	5d                   	pop    %ebp
  801356:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801357:	83 ec 0c             	sub    $0xc,%esp
  80135a:	50                   	push   %eax
  80135b:	6a 04                	push   $0x4
  80135d:	68 9f 31 80 00       	push   $0x80319f
  801362:	6a 2a                	push   $0x2a
  801364:	68 bc 31 80 00       	push   $0x8031bc
  801369:	e8 0c f5 ff ff       	call   80087a <_panic>

0080136e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80136e:	55                   	push   %ebp
  80136f:	89 e5                	mov    %esp,%ebp
  801371:	57                   	push   %edi
  801372:	56                   	push   %esi
  801373:	53                   	push   %ebx
  801374:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801377:	8b 55 08             	mov    0x8(%ebp),%edx
  80137a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80137d:	b8 05 00 00 00       	mov    $0x5,%eax
  801382:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801385:	8b 7d 14             	mov    0x14(%ebp),%edi
  801388:	8b 75 18             	mov    0x18(%ebp),%esi
  80138b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80138d:	85 c0                	test   %eax,%eax
  80138f:	7f 08                	jg     801399 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801391:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801394:	5b                   	pop    %ebx
  801395:	5e                   	pop    %esi
  801396:	5f                   	pop    %edi
  801397:	5d                   	pop    %ebp
  801398:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801399:	83 ec 0c             	sub    $0xc,%esp
  80139c:	50                   	push   %eax
  80139d:	6a 05                	push   $0x5
  80139f:	68 9f 31 80 00       	push   $0x80319f
  8013a4:	6a 2a                	push   $0x2a
  8013a6:	68 bc 31 80 00       	push   $0x8031bc
  8013ab:	e8 ca f4 ff ff       	call   80087a <_panic>

008013b0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	57                   	push   %edi
  8013b4:	56                   	push   %esi
  8013b5:	53                   	push   %ebx
  8013b6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8013b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013be:	8b 55 08             	mov    0x8(%ebp),%edx
  8013c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013c4:	b8 06 00 00 00       	mov    $0x6,%eax
  8013c9:	89 df                	mov    %ebx,%edi
  8013cb:	89 de                	mov    %ebx,%esi
  8013cd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	7f 08                	jg     8013db <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8013d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d6:	5b                   	pop    %ebx
  8013d7:	5e                   	pop    %esi
  8013d8:	5f                   	pop    %edi
  8013d9:	5d                   	pop    %ebp
  8013da:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8013db:	83 ec 0c             	sub    $0xc,%esp
  8013de:	50                   	push   %eax
  8013df:	6a 06                	push   $0x6
  8013e1:	68 9f 31 80 00       	push   $0x80319f
  8013e6:	6a 2a                	push   $0x2a
  8013e8:	68 bc 31 80 00       	push   $0x8031bc
  8013ed:	e8 88 f4 ff ff       	call   80087a <_panic>

008013f2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	57                   	push   %edi
  8013f6:	56                   	push   %esi
  8013f7:	53                   	push   %ebx
  8013f8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8013fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801400:	8b 55 08             	mov    0x8(%ebp),%edx
  801403:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801406:	b8 08 00 00 00       	mov    $0x8,%eax
  80140b:	89 df                	mov    %ebx,%edi
  80140d:	89 de                	mov    %ebx,%esi
  80140f:	cd 30                	int    $0x30
	if(check && ret > 0)
  801411:	85 c0                	test   %eax,%eax
  801413:	7f 08                	jg     80141d <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801415:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801418:	5b                   	pop    %ebx
  801419:	5e                   	pop    %esi
  80141a:	5f                   	pop    %edi
  80141b:	5d                   	pop    %ebp
  80141c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80141d:	83 ec 0c             	sub    $0xc,%esp
  801420:	50                   	push   %eax
  801421:	6a 08                	push   $0x8
  801423:	68 9f 31 80 00       	push   $0x80319f
  801428:	6a 2a                	push   $0x2a
  80142a:	68 bc 31 80 00       	push   $0x8031bc
  80142f:	e8 46 f4 ff ff       	call   80087a <_panic>

00801434 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	57                   	push   %edi
  801438:	56                   	push   %esi
  801439:	53                   	push   %ebx
  80143a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80143d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801442:	8b 55 08             	mov    0x8(%ebp),%edx
  801445:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801448:	b8 09 00 00 00       	mov    $0x9,%eax
  80144d:	89 df                	mov    %ebx,%edi
  80144f:	89 de                	mov    %ebx,%esi
  801451:	cd 30                	int    $0x30
	if(check && ret > 0)
  801453:	85 c0                	test   %eax,%eax
  801455:	7f 08                	jg     80145f <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801457:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80145a:	5b                   	pop    %ebx
  80145b:	5e                   	pop    %esi
  80145c:	5f                   	pop    %edi
  80145d:	5d                   	pop    %ebp
  80145e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80145f:	83 ec 0c             	sub    $0xc,%esp
  801462:	50                   	push   %eax
  801463:	6a 09                	push   $0x9
  801465:	68 9f 31 80 00       	push   $0x80319f
  80146a:	6a 2a                	push   $0x2a
  80146c:	68 bc 31 80 00       	push   $0x8031bc
  801471:	e8 04 f4 ff ff       	call   80087a <_panic>

00801476 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	57                   	push   %edi
  80147a:	56                   	push   %esi
  80147b:	53                   	push   %ebx
  80147c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80147f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801484:	8b 55 08             	mov    0x8(%ebp),%edx
  801487:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80148a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80148f:	89 df                	mov    %ebx,%edi
  801491:	89 de                	mov    %ebx,%esi
  801493:	cd 30                	int    $0x30
	if(check && ret > 0)
  801495:	85 c0                	test   %eax,%eax
  801497:	7f 08                	jg     8014a1 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801499:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149c:	5b                   	pop    %ebx
  80149d:	5e                   	pop    %esi
  80149e:	5f                   	pop    %edi
  80149f:	5d                   	pop    %ebp
  8014a0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8014a1:	83 ec 0c             	sub    $0xc,%esp
  8014a4:	50                   	push   %eax
  8014a5:	6a 0a                	push   $0xa
  8014a7:	68 9f 31 80 00       	push   $0x80319f
  8014ac:	6a 2a                	push   $0x2a
  8014ae:	68 bc 31 80 00       	push   $0x8031bc
  8014b3:	e8 c2 f3 ff ff       	call   80087a <_panic>

008014b8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	57                   	push   %edi
  8014bc:	56                   	push   %esi
  8014bd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8014be:	8b 55 08             	mov    0x8(%ebp),%edx
  8014c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014c4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8014c9:	be 00 00 00 00       	mov    $0x0,%esi
  8014ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014d1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8014d4:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8014d6:	5b                   	pop    %ebx
  8014d7:	5e                   	pop    %esi
  8014d8:	5f                   	pop    %edi
  8014d9:	5d                   	pop    %ebp
  8014da:	c3                   	ret    

008014db <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	57                   	push   %edi
  8014df:	56                   	push   %esi
  8014e0:	53                   	push   %ebx
  8014e1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8014e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ec:	b8 0d 00 00 00       	mov    $0xd,%eax
  8014f1:	89 cb                	mov    %ecx,%ebx
  8014f3:	89 cf                	mov    %ecx,%edi
  8014f5:	89 ce                	mov    %ecx,%esi
  8014f7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	7f 08                	jg     801505 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8014fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801500:	5b                   	pop    %ebx
  801501:	5e                   	pop    %esi
  801502:	5f                   	pop    %edi
  801503:	5d                   	pop    %ebp
  801504:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801505:	83 ec 0c             	sub    $0xc,%esp
  801508:	50                   	push   %eax
  801509:	6a 0d                	push   $0xd
  80150b:	68 9f 31 80 00       	push   $0x80319f
  801510:	6a 2a                	push   $0x2a
  801512:	68 bc 31 80 00       	push   $0x8031bc
  801517:	e8 5e f3 ff ff       	call   80087a <_panic>

0080151c <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80151c:	55                   	push   %ebp
  80151d:	89 e5                	mov    %esp,%ebp
  80151f:	57                   	push   %edi
  801520:	56                   	push   %esi
  801521:	53                   	push   %ebx
	asm volatile("int %1\n"
  801522:	ba 00 00 00 00       	mov    $0x0,%edx
  801527:	b8 0e 00 00 00       	mov    $0xe,%eax
  80152c:	89 d1                	mov    %edx,%ecx
  80152e:	89 d3                	mov    %edx,%ebx
  801530:	89 d7                	mov    %edx,%edi
  801532:	89 d6                	mov    %edx,%esi
  801534:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801536:	5b                   	pop    %ebx
  801537:	5e                   	pop    %esi
  801538:	5f                   	pop    %edi
  801539:	5d                   	pop    %ebp
  80153a:	c3                   	ret    

0080153b <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	57                   	push   %edi
  80153f:	56                   	push   %esi
  801540:	53                   	push   %ebx
	asm volatile("int %1\n"
  801541:	bb 00 00 00 00       	mov    $0x0,%ebx
  801546:	8b 55 08             	mov    0x8(%ebp),%edx
  801549:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80154c:	b8 0f 00 00 00       	mov    $0xf,%eax
  801551:	89 df                	mov    %ebx,%edi
  801553:	89 de                	mov    %ebx,%esi
  801555:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  801557:	5b                   	pop    %ebx
  801558:	5e                   	pop    %esi
  801559:	5f                   	pop    %edi
  80155a:	5d                   	pop    %ebp
  80155b:	c3                   	ret    

0080155c <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	57                   	push   %edi
  801560:	56                   	push   %esi
  801561:	53                   	push   %ebx
	asm volatile("int %1\n"
  801562:	bb 00 00 00 00       	mov    $0x0,%ebx
  801567:	8b 55 08             	mov    0x8(%ebp),%edx
  80156a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80156d:	b8 10 00 00 00       	mov    $0x10,%eax
  801572:	89 df                	mov    %ebx,%edi
  801574:	89 de                	mov    %ebx,%esi
  801576:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  801578:	5b                   	pop    %ebx
  801579:	5e                   	pop    %esi
  80157a:	5f                   	pop    %edi
  80157b:	5d                   	pop    %ebp
  80157c:	c3                   	ret    

0080157d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
  801580:	56                   	push   %esi
  801581:	53                   	push   %ebx
  801582:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801585:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  801587:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80158b:	0f 84 8e 00 00 00    	je     80161f <pgfault+0xa2>
  801591:	89 f0                	mov    %esi,%eax
  801593:	c1 e8 0c             	shr    $0xc,%eax
  801596:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80159d:	f6 c4 08             	test   $0x8,%ah
  8015a0:	74 7d                	je     80161f <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  8015a2:	e8 46 fd ff ff       	call   8012ed <sys_getenvid>
  8015a7:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  8015a9:	83 ec 04             	sub    $0x4,%esp
  8015ac:	6a 07                	push   $0x7
  8015ae:	68 00 f0 7f 00       	push   $0x7ff000
  8015b3:	50                   	push   %eax
  8015b4:	e8 72 fd ff ff       	call   80132b <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	78 73                	js     801633 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  8015c0:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  8015c6:	83 ec 04             	sub    $0x4,%esp
  8015c9:	68 00 10 00 00       	push   $0x1000
  8015ce:	56                   	push   %esi
  8015cf:	68 00 f0 7f 00       	push   $0x7ff000
  8015d4:	e8 ec fa ff ff       	call   8010c5 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  8015d9:	83 c4 08             	add    $0x8,%esp
  8015dc:	56                   	push   %esi
  8015dd:	53                   	push   %ebx
  8015de:	e8 cd fd ff ff       	call   8013b0 <sys_page_unmap>
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	78 5b                	js     801645 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  8015ea:	83 ec 0c             	sub    $0xc,%esp
  8015ed:	6a 07                	push   $0x7
  8015ef:	56                   	push   %esi
  8015f0:	53                   	push   %ebx
  8015f1:	68 00 f0 7f 00       	push   $0x7ff000
  8015f6:	53                   	push   %ebx
  8015f7:	e8 72 fd ff ff       	call   80136e <sys_page_map>
  8015fc:	83 c4 20             	add    $0x20,%esp
  8015ff:	85 c0                	test   %eax,%eax
  801601:	78 54                	js     801657 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  801603:	83 ec 08             	sub    $0x8,%esp
  801606:	68 00 f0 7f 00       	push   $0x7ff000
  80160b:	53                   	push   %ebx
  80160c:	e8 9f fd ff ff       	call   8013b0 <sys_page_unmap>
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	85 c0                	test   %eax,%eax
  801616:	78 51                	js     801669 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  801618:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161b:	5b                   	pop    %ebx
  80161c:	5e                   	pop    %esi
  80161d:	5d                   	pop    %ebp
  80161e:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  80161f:	83 ec 04             	sub    $0x4,%esp
  801622:	68 cc 31 80 00       	push   $0x8031cc
  801627:	6a 1d                	push   $0x1d
  801629:	68 48 32 80 00       	push   $0x803248
  80162e:	e8 47 f2 ff ff       	call   80087a <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  801633:	50                   	push   %eax
  801634:	68 04 32 80 00       	push   $0x803204
  801639:	6a 29                	push   $0x29
  80163b:	68 48 32 80 00       	push   $0x803248
  801640:	e8 35 f2 ff ff       	call   80087a <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  801645:	50                   	push   %eax
  801646:	68 28 32 80 00       	push   $0x803228
  80164b:	6a 2e                	push   $0x2e
  80164d:	68 48 32 80 00       	push   $0x803248
  801652:	e8 23 f2 ff ff       	call   80087a <_panic>
		panic("pgfault: page map failed (%e)", r);
  801657:	50                   	push   %eax
  801658:	68 53 32 80 00       	push   $0x803253
  80165d:	6a 30                	push   $0x30
  80165f:	68 48 32 80 00       	push   $0x803248
  801664:	e8 11 f2 ff ff       	call   80087a <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  801669:	50                   	push   %eax
  80166a:	68 28 32 80 00       	push   $0x803228
  80166f:	6a 32                	push   $0x32
  801671:	68 48 32 80 00       	push   $0x803248
  801676:	e8 ff f1 ff ff       	call   80087a <_panic>

0080167b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	57                   	push   %edi
  80167f:	56                   	push   %esi
  801680:	53                   	push   %ebx
  801681:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  801684:	68 7d 15 80 00       	push   $0x80157d
  801689:	e8 6f 13 00 00       	call   8029fd <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80168e:	b8 07 00 00 00       	mov    $0x7,%eax
  801693:	cd 30                	int    $0x30
  801695:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	85 c0                	test   %eax,%eax
  80169d:	78 2d                	js     8016cc <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  80169f:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  8016a4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8016a8:	75 73                	jne    80171d <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  8016aa:	e8 3e fc ff ff       	call   8012ed <sys_getenvid>
  8016af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8016b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016bc:	a3 18 50 80 00       	mov    %eax,0x805018
		return 0;
  8016c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  8016c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c7:	5b                   	pop    %ebx
  8016c8:	5e                   	pop    %esi
  8016c9:	5f                   	pop    %edi
  8016ca:	5d                   	pop    %ebp
  8016cb:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  8016cc:	50                   	push   %eax
  8016cd:	68 71 32 80 00       	push   $0x803271
  8016d2:	6a 78                	push   $0x78
  8016d4:	68 48 32 80 00       	push   $0x803248
  8016d9:	e8 9c f1 ff ff       	call   80087a <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  8016de:	83 ec 0c             	sub    $0xc,%esp
  8016e1:	ff 75 e4             	push   -0x1c(%ebp)
  8016e4:	57                   	push   %edi
  8016e5:	ff 75 dc             	push   -0x24(%ebp)
  8016e8:	57                   	push   %edi
  8016e9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8016ec:	56                   	push   %esi
  8016ed:	e8 7c fc ff ff       	call   80136e <sys_page_map>
	if(r<0) return r;
  8016f2:	83 c4 20             	add    $0x20,%esp
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	78 cb                	js     8016c4 <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  8016f9:	83 ec 0c             	sub    $0xc,%esp
  8016fc:	ff 75 e4             	push   -0x1c(%ebp)
  8016ff:	57                   	push   %edi
  801700:	56                   	push   %esi
  801701:	57                   	push   %edi
  801702:	56                   	push   %esi
  801703:	e8 66 fc ff ff       	call   80136e <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  801708:	83 c4 20             	add    $0x20,%esp
  80170b:	85 c0                	test   %eax,%eax
  80170d:	78 76                	js     801785 <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  80170f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801715:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80171b:	74 75                	je     801792 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  80171d:	89 d8                	mov    %ebx,%eax
  80171f:	c1 e8 16             	shr    $0x16,%eax
  801722:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801729:	a8 01                	test   $0x1,%al
  80172b:	74 e2                	je     80170f <fork+0x94>
  80172d:	89 de                	mov    %ebx,%esi
  80172f:	c1 ee 0c             	shr    $0xc,%esi
  801732:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801739:	a8 01                	test   $0x1,%al
  80173b:	74 d2                	je     80170f <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  80173d:	e8 ab fb ff ff       	call   8012ed <sys_getenvid>
  801742:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  801745:	89 f7                	mov    %esi,%edi
  801747:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  80174a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801751:	89 c1                	mov    %eax,%ecx
  801753:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801759:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  80175c:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  801763:	f6 c6 04             	test   $0x4,%dh
  801766:	0f 85 72 ff ff ff    	jne    8016de <fork+0x63>
		perm &= ~PTE_W;
  80176c:	25 05 0e 00 00       	and    $0xe05,%eax
  801771:	80 cc 08             	or     $0x8,%ah
  801774:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  80177a:	0f 44 c1             	cmove  %ecx,%eax
  80177d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801780:	e9 59 ff ff ff       	jmp    8016de <fork+0x63>
  801785:	ba 00 00 00 00       	mov    $0x0,%edx
  80178a:	0f 4f c2             	cmovg  %edx,%eax
  80178d:	e9 32 ff ff ff       	jmp    8016c4 <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801792:	83 ec 04             	sub    $0x4,%esp
  801795:	6a 07                	push   $0x7
  801797:	68 00 f0 bf ee       	push   $0xeebff000
  80179c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80179f:	57                   	push   %edi
  8017a0:	e8 86 fb ff ff       	call   80132b <sys_page_alloc>
	if(r<0) return r;
  8017a5:	83 c4 10             	add    $0x10,%esp
  8017a8:	85 c0                	test   %eax,%eax
  8017aa:	0f 88 14 ff ff ff    	js     8016c4 <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8017b0:	83 ec 08             	sub    $0x8,%esp
  8017b3:	68 73 2a 80 00       	push   $0x802a73
  8017b8:	57                   	push   %edi
  8017b9:	e8 b8 fc ff ff       	call   801476 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	0f 88 fb fe ff ff    	js     8016c4 <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8017c9:	83 ec 08             	sub    $0x8,%esp
  8017cc:	6a 02                	push   $0x2
  8017ce:	57                   	push   %edi
  8017cf:	e8 1e fc ff ff       	call   8013f2 <sys_env_set_status>
	if(r<0) return r;
  8017d4:	83 c4 10             	add    $0x10,%esp
	return envid;
  8017d7:	85 c0                	test   %eax,%eax
  8017d9:	0f 49 c7             	cmovns %edi,%eax
  8017dc:	e9 e3 fe ff ff       	jmp    8016c4 <fork+0x49>

008017e1 <sfork>:

// Challenge!
int
sfork(void)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8017e7:	68 81 32 80 00       	push   $0x803281
  8017ec:	68 a1 00 00 00       	push   $0xa1
  8017f1:	68 48 32 80 00       	push   $0x803248
  8017f6:	e8 7f f0 ff ff       	call   80087a <_panic>

008017fb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	56                   	push   %esi
  8017ff:	53                   	push   %ebx
  801800:	8b 75 08             	mov    0x8(%ebp),%esi
  801803:	8b 45 0c             	mov    0xc(%ebp),%eax
  801806:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801809:	85 c0                	test   %eax,%eax
  80180b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801810:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801813:	83 ec 0c             	sub    $0xc,%esp
  801816:	50                   	push   %eax
  801817:	e8 bf fc ff ff       	call   8014db <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  80181c:	83 c4 10             	add    $0x10,%esp
  80181f:	85 f6                	test   %esi,%esi
  801821:	74 14                	je     801837 <ipc_recv+0x3c>
  801823:	ba 00 00 00 00       	mov    $0x0,%edx
  801828:	85 c0                	test   %eax,%eax
  80182a:	78 09                	js     801835 <ipc_recv+0x3a>
  80182c:	8b 15 18 50 80 00    	mov    0x805018,%edx
  801832:	8b 52 74             	mov    0x74(%edx),%edx
  801835:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801837:	85 db                	test   %ebx,%ebx
  801839:	74 14                	je     80184f <ipc_recv+0x54>
  80183b:	ba 00 00 00 00       	mov    $0x0,%edx
  801840:	85 c0                	test   %eax,%eax
  801842:	78 09                	js     80184d <ipc_recv+0x52>
  801844:	8b 15 18 50 80 00    	mov    0x805018,%edx
  80184a:	8b 52 78             	mov    0x78(%edx),%edx
  80184d:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  80184f:	85 c0                	test   %eax,%eax
  801851:	78 08                	js     80185b <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801853:	a1 18 50 80 00       	mov    0x805018,%eax
  801858:	8b 40 70             	mov    0x70(%eax),%eax
}
  80185b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80185e:	5b                   	pop    %ebx
  80185f:	5e                   	pop    %esi
  801860:	5d                   	pop    %ebp
  801861:	c3                   	ret    

00801862 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	57                   	push   %edi
  801866:	56                   	push   %esi
  801867:	53                   	push   %ebx
  801868:	83 ec 0c             	sub    $0xc,%esp
  80186b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80186e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801871:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801874:	85 db                	test   %ebx,%ebx
  801876:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80187b:	0f 44 d8             	cmove  %eax,%ebx
  80187e:	eb 05                	jmp    801885 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801880:	e8 87 fa ff ff       	call   80130c <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801885:	ff 75 14             	push   0x14(%ebp)
  801888:	53                   	push   %ebx
  801889:	56                   	push   %esi
  80188a:	57                   	push   %edi
  80188b:	e8 28 fc ff ff       	call   8014b8 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801890:	83 c4 10             	add    $0x10,%esp
  801893:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801896:	74 e8                	je     801880 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801898:	85 c0                	test   %eax,%eax
  80189a:	78 08                	js     8018a4 <ipc_send+0x42>
	}while (r<0);

}
  80189c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80189f:	5b                   	pop    %ebx
  8018a0:	5e                   	pop    %esi
  8018a1:	5f                   	pop    %edi
  8018a2:	5d                   	pop    %ebp
  8018a3:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8018a4:	50                   	push   %eax
  8018a5:	68 97 32 80 00       	push   $0x803297
  8018aa:	6a 3d                	push   $0x3d
  8018ac:	68 ab 32 80 00       	push   $0x8032ab
  8018b1:	e8 c4 ef ff ff       	call   80087a <_panic>

008018b6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8018bc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8018c1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8018c4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8018ca:	8b 52 50             	mov    0x50(%edx),%edx
  8018cd:	39 ca                	cmp    %ecx,%edx
  8018cf:	74 11                	je     8018e2 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8018d1:	83 c0 01             	add    $0x1,%eax
  8018d4:	3d 00 04 00 00       	cmp    $0x400,%eax
  8018d9:	75 e6                	jne    8018c1 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8018db:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e0:	eb 0b                	jmp    8018ed <ipc_find_env+0x37>
			return envs[i].env_id;
  8018e2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8018e5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8018ea:	8b 40 48             	mov    0x48(%eax),%eax
}
  8018ed:	5d                   	pop    %ebp
  8018ee:	c3                   	ret    

008018ef <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8018f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f5:	05 00 00 00 30       	add    $0x30000000,%eax
  8018fa:	c1 e8 0c             	shr    $0xc,%eax
}
  8018fd:	5d                   	pop    %ebp
  8018fe:	c3                   	ret    

008018ff <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801902:	8b 45 08             	mov    0x8(%ebp),%eax
  801905:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80190a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80190f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801914:	5d                   	pop    %ebp
  801915:	c3                   	ret    

00801916 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80191e:	89 c2                	mov    %eax,%edx
  801920:	c1 ea 16             	shr    $0x16,%edx
  801923:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80192a:	f6 c2 01             	test   $0x1,%dl
  80192d:	74 29                	je     801958 <fd_alloc+0x42>
  80192f:	89 c2                	mov    %eax,%edx
  801931:	c1 ea 0c             	shr    $0xc,%edx
  801934:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80193b:	f6 c2 01             	test   $0x1,%dl
  80193e:	74 18                	je     801958 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801940:	05 00 10 00 00       	add    $0x1000,%eax
  801945:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80194a:	75 d2                	jne    80191e <fd_alloc+0x8>
  80194c:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801951:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801956:	eb 05                	jmp    80195d <fd_alloc+0x47>
			return 0;
  801958:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80195d:	8b 55 08             	mov    0x8(%ebp),%edx
  801960:	89 02                	mov    %eax,(%edx)
}
  801962:	89 c8                	mov    %ecx,%eax
  801964:	5d                   	pop    %ebp
  801965:	c3                   	ret    

00801966 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80196c:	83 f8 1f             	cmp    $0x1f,%eax
  80196f:	77 30                	ja     8019a1 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801971:	c1 e0 0c             	shl    $0xc,%eax
  801974:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801979:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80197f:	f6 c2 01             	test   $0x1,%dl
  801982:	74 24                	je     8019a8 <fd_lookup+0x42>
  801984:	89 c2                	mov    %eax,%edx
  801986:	c1 ea 0c             	shr    $0xc,%edx
  801989:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801990:	f6 c2 01             	test   $0x1,%dl
  801993:	74 1a                	je     8019af <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801995:	8b 55 0c             	mov    0xc(%ebp),%edx
  801998:	89 02                	mov    %eax,(%edx)
	return 0;
  80199a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80199f:	5d                   	pop    %ebp
  8019a0:	c3                   	ret    
		return -E_INVAL;
  8019a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019a6:	eb f7                	jmp    80199f <fd_lookup+0x39>
		return -E_INVAL;
  8019a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019ad:	eb f0                	jmp    80199f <fd_lookup+0x39>
  8019af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019b4:	eb e9                	jmp    80199f <fd_lookup+0x39>

008019b6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	53                   	push   %ebx
  8019ba:	83 ec 04             	sub    $0x4,%esp
  8019bd:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8019c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c5:	bb 04 40 80 00       	mov    $0x804004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8019ca:	39 13                	cmp    %edx,(%ebx)
  8019cc:	74 37                	je     801a05 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8019ce:	83 c0 01             	add    $0x1,%eax
  8019d1:	8b 1c 85 34 33 80 00 	mov    0x803334(,%eax,4),%ebx
  8019d8:	85 db                	test   %ebx,%ebx
  8019da:	75 ee                	jne    8019ca <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8019dc:	a1 18 50 80 00       	mov    0x805018,%eax
  8019e1:	8b 40 48             	mov    0x48(%eax),%eax
  8019e4:	83 ec 04             	sub    $0x4,%esp
  8019e7:	52                   	push   %edx
  8019e8:	50                   	push   %eax
  8019e9:	68 b8 32 80 00       	push   $0x8032b8
  8019ee:	e8 62 ef ff ff       	call   800955 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8019fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019fe:	89 1a                	mov    %ebx,(%edx)
}
  801a00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a03:	c9                   	leave  
  801a04:	c3                   	ret    
			return 0;
  801a05:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0a:	eb ef                	jmp    8019fb <dev_lookup+0x45>

00801a0c <fd_close>:
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	57                   	push   %edi
  801a10:	56                   	push   %esi
  801a11:	53                   	push   %ebx
  801a12:	83 ec 24             	sub    $0x24,%esp
  801a15:	8b 75 08             	mov    0x8(%ebp),%esi
  801a18:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a1b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a1e:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801a1f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801a25:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a28:	50                   	push   %eax
  801a29:	e8 38 ff ff ff       	call   801966 <fd_lookup>
  801a2e:	89 c3                	mov    %eax,%ebx
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	85 c0                	test   %eax,%eax
  801a35:	78 05                	js     801a3c <fd_close+0x30>
	    || fd != fd2)
  801a37:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801a3a:	74 16                	je     801a52 <fd_close+0x46>
		return (must_exist ? r : 0);
  801a3c:	89 f8                	mov    %edi,%eax
  801a3e:	84 c0                	test   %al,%al
  801a40:	b8 00 00 00 00       	mov    $0x0,%eax
  801a45:	0f 44 d8             	cmove  %eax,%ebx
}
  801a48:	89 d8                	mov    %ebx,%eax
  801a4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a4d:	5b                   	pop    %ebx
  801a4e:	5e                   	pop    %esi
  801a4f:	5f                   	pop    %edi
  801a50:	5d                   	pop    %ebp
  801a51:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801a52:	83 ec 08             	sub    $0x8,%esp
  801a55:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801a58:	50                   	push   %eax
  801a59:	ff 36                	push   (%esi)
  801a5b:	e8 56 ff ff ff       	call   8019b6 <dev_lookup>
  801a60:	89 c3                	mov    %eax,%ebx
  801a62:	83 c4 10             	add    $0x10,%esp
  801a65:	85 c0                	test   %eax,%eax
  801a67:	78 1a                	js     801a83 <fd_close+0x77>
		if (dev->dev_close)
  801a69:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a6c:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801a6f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801a74:	85 c0                	test   %eax,%eax
  801a76:	74 0b                	je     801a83 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801a78:	83 ec 0c             	sub    $0xc,%esp
  801a7b:	56                   	push   %esi
  801a7c:	ff d0                	call   *%eax
  801a7e:	89 c3                	mov    %eax,%ebx
  801a80:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801a83:	83 ec 08             	sub    $0x8,%esp
  801a86:	56                   	push   %esi
  801a87:	6a 00                	push   $0x0
  801a89:	e8 22 f9 ff ff       	call   8013b0 <sys_page_unmap>
	return r;
  801a8e:	83 c4 10             	add    $0x10,%esp
  801a91:	eb b5                	jmp    801a48 <fd_close+0x3c>

00801a93 <close>:

int
close(int fdnum)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a9c:	50                   	push   %eax
  801a9d:	ff 75 08             	push   0x8(%ebp)
  801aa0:	e8 c1 fe ff ff       	call   801966 <fd_lookup>
  801aa5:	83 c4 10             	add    $0x10,%esp
  801aa8:	85 c0                	test   %eax,%eax
  801aaa:	79 02                	jns    801aae <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    
		return fd_close(fd, 1);
  801aae:	83 ec 08             	sub    $0x8,%esp
  801ab1:	6a 01                	push   $0x1
  801ab3:	ff 75 f4             	push   -0xc(%ebp)
  801ab6:	e8 51 ff ff ff       	call   801a0c <fd_close>
  801abb:	83 c4 10             	add    $0x10,%esp
  801abe:	eb ec                	jmp    801aac <close+0x19>

00801ac0 <close_all>:

void
close_all(void)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	53                   	push   %ebx
  801ac4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801ac7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801acc:	83 ec 0c             	sub    $0xc,%esp
  801acf:	53                   	push   %ebx
  801ad0:	e8 be ff ff ff       	call   801a93 <close>
	for (i = 0; i < MAXFD; i++)
  801ad5:	83 c3 01             	add    $0x1,%ebx
  801ad8:	83 c4 10             	add    $0x10,%esp
  801adb:	83 fb 20             	cmp    $0x20,%ebx
  801ade:	75 ec                	jne    801acc <close_all+0xc>
}
  801ae0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae3:	c9                   	leave  
  801ae4:	c3                   	ret    

00801ae5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	57                   	push   %edi
  801ae9:	56                   	push   %esi
  801aea:	53                   	push   %ebx
  801aeb:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801aee:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801af1:	50                   	push   %eax
  801af2:	ff 75 08             	push   0x8(%ebp)
  801af5:	e8 6c fe ff ff       	call   801966 <fd_lookup>
  801afa:	89 c3                	mov    %eax,%ebx
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	85 c0                	test   %eax,%eax
  801b01:	78 7f                	js     801b82 <dup+0x9d>
		return r;
	close(newfdnum);
  801b03:	83 ec 0c             	sub    $0xc,%esp
  801b06:	ff 75 0c             	push   0xc(%ebp)
  801b09:	e8 85 ff ff ff       	call   801a93 <close>

	newfd = INDEX2FD(newfdnum);
  801b0e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b11:	c1 e6 0c             	shl    $0xc,%esi
  801b14:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801b1a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b1d:	89 3c 24             	mov    %edi,(%esp)
  801b20:	e8 da fd ff ff       	call   8018ff <fd2data>
  801b25:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801b27:	89 34 24             	mov    %esi,(%esp)
  801b2a:	e8 d0 fd ff ff       	call   8018ff <fd2data>
  801b2f:	83 c4 10             	add    $0x10,%esp
  801b32:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801b35:	89 d8                	mov    %ebx,%eax
  801b37:	c1 e8 16             	shr    $0x16,%eax
  801b3a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b41:	a8 01                	test   $0x1,%al
  801b43:	74 11                	je     801b56 <dup+0x71>
  801b45:	89 d8                	mov    %ebx,%eax
  801b47:	c1 e8 0c             	shr    $0xc,%eax
  801b4a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801b51:	f6 c2 01             	test   $0x1,%dl
  801b54:	75 36                	jne    801b8c <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801b56:	89 f8                	mov    %edi,%eax
  801b58:	c1 e8 0c             	shr    $0xc,%eax
  801b5b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b62:	83 ec 0c             	sub    $0xc,%esp
  801b65:	25 07 0e 00 00       	and    $0xe07,%eax
  801b6a:	50                   	push   %eax
  801b6b:	56                   	push   %esi
  801b6c:	6a 00                	push   $0x0
  801b6e:	57                   	push   %edi
  801b6f:	6a 00                	push   $0x0
  801b71:	e8 f8 f7 ff ff       	call   80136e <sys_page_map>
  801b76:	89 c3                	mov    %eax,%ebx
  801b78:	83 c4 20             	add    $0x20,%esp
  801b7b:	85 c0                	test   %eax,%eax
  801b7d:	78 33                	js     801bb2 <dup+0xcd>
		goto err;

	return newfdnum;
  801b7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801b82:	89 d8                	mov    %ebx,%eax
  801b84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b87:	5b                   	pop    %ebx
  801b88:	5e                   	pop    %esi
  801b89:	5f                   	pop    %edi
  801b8a:	5d                   	pop    %ebp
  801b8b:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801b8c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b93:	83 ec 0c             	sub    $0xc,%esp
  801b96:	25 07 0e 00 00       	and    $0xe07,%eax
  801b9b:	50                   	push   %eax
  801b9c:	ff 75 d4             	push   -0x2c(%ebp)
  801b9f:	6a 00                	push   $0x0
  801ba1:	53                   	push   %ebx
  801ba2:	6a 00                	push   $0x0
  801ba4:	e8 c5 f7 ff ff       	call   80136e <sys_page_map>
  801ba9:	89 c3                	mov    %eax,%ebx
  801bab:	83 c4 20             	add    $0x20,%esp
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	79 a4                	jns    801b56 <dup+0x71>
	sys_page_unmap(0, newfd);
  801bb2:	83 ec 08             	sub    $0x8,%esp
  801bb5:	56                   	push   %esi
  801bb6:	6a 00                	push   $0x0
  801bb8:	e8 f3 f7 ff ff       	call   8013b0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801bbd:	83 c4 08             	add    $0x8,%esp
  801bc0:	ff 75 d4             	push   -0x2c(%ebp)
  801bc3:	6a 00                	push   $0x0
  801bc5:	e8 e6 f7 ff ff       	call   8013b0 <sys_page_unmap>
	return r;
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	eb b3                	jmp    801b82 <dup+0x9d>

00801bcf <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	56                   	push   %esi
  801bd3:	53                   	push   %ebx
  801bd4:	83 ec 18             	sub    $0x18,%esp
  801bd7:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bda:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bdd:	50                   	push   %eax
  801bde:	56                   	push   %esi
  801bdf:	e8 82 fd ff ff       	call   801966 <fd_lookup>
  801be4:	83 c4 10             	add    $0x10,%esp
  801be7:	85 c0                	test   %eax,%eax
  801be9:	78 3c                	js     801c27 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801beb:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801bee:	83 ec 08             	sub    $0x8,%esp
  801bf1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf4:	50                   	push   %eax
  801bf5:	ff 33                	push   (%ebx)
  801bf7:	e8 ba fd ff ff       	call   8019b6 <dev_lookup>
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	85 c0                	test   %eax,%eax
  801c01:	78 24                	js     801c27 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801c03:	8b 43 08             	mov    0x8(%ebx),%eax
  801c06:	83 e0 03             	and    $0x3,%eax
  801c09:	83 f8 01             	cmp    $0x1,%eax
  801c0c:	74 20                	je     801c2e <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c11:	8b 40 08             	mov    0x8(%eax),%eax
  801c14:	85 c0                	test   %eax,%eax
  801c16:	74 37                	je     801c4f <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801c18:	83 ec 04             	sub    $0x4,%esp
  801c1b:	ff 75 10             	push   0x10(%ebp)
  801c1e:	ff 75 0c             	push   0xc(%ebp)
  801c21:	53                   	push   %ebx
  801c22:	ff d0                	call   *%eax
  801c24:	83 c4 10             	add    $0x10,%esp
}
  801c27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2a:	5b                   	pop    %ebx
  801c2b:	5e                   	pop    %esi
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801c2e:	a1 18 50 80 00       	mov    0x805018,%eax
  801c33:	8b 40 48             	mov    0x48(%eax),%eax
  801c36:	83 ec 04             	sub    $0x4,%esp
  801c39:	56                   	push   %esi
  801c3a:	50                   	push   %eax
  801c3b:	68 f9 32 80 00       	push   $0x8032f9
  801c40:	e8 10 ed ff ff       	call   800955 <cprintf>
		return -E_INVAL;
  801c45:	83 c4 10             	add    $0x10,%esp
  801c48:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c4d:	eb d8                	jmp    801c27 <read+0x58>
		return -E_NOT_SUPP;
  801c4f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c54:	eb d1                	jmp    801c27 <read+0x58>

00801c56 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	57                   	push   %edi
  801c5a:	56                   	push   %esi
  801c5b:	53                   	push   %ebx
  801c5c:	83 ec 0c             	sub    $0xc,%esp
  801c5f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c62:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801c65:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c6a:	eb 02                	jmp    801c6e <readn+0x18>
  801c6c:	01 c3                	add    %eax,%ebx
  801c6e:	39 f3                	cmp    %esi,%ebx
  801c70:	73 21                	jae    801c93 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801c72:	83 ec 04             	sub    $0x4,%esp
  801c75:	89 f0                	mov    %esi,%eax
  801c77:	29 d8                	sub    %ebx,%eax
  801c79:	50                   	push   %eax
  801c7a:	89 d8                	mov    %ebx,%eax
  801c7c:	03 45 0c             	add    0xc(%ebp),%eax
  801c7f:	50                   	push   %eax
  801c80:	57                   	push   %edi
  801c81:	e8 49 ff ff ff       	call   801bcf <read>
		if (m < 0)
  801c86:	83 c4 10             	add    $0x10,%esp
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	78 04                	js     801c91 <readn+0x3b>
			return m;
		if (m == 0)
  801c8d:	75 dd                	jne    801c6c <readn+0x16>
  801c8f:	eb 02                	jmp    801c93 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801c91:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801c93:	89 d8                	mov    %ebx,%eax
  801c95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c98:	5b                   	pop    %ebx
  801c99:	5e                   	pop    %esi
  801c9a:	5f                   	pop    %edi
  801c9b:	5d                   	pop    %ebp
  801c9c:	c3                   	ret    

00801c9d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	56                   	push   %esi
  801ca1:	53                   	push   %ebx
  801ca2:	83 ec 18             	sub    $0x18,%esp
  801ca5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ca8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cab:	50                   	push   %eax
  801cac:	53                   	push   %ebx
  801cad:	e8 b4 fc ff ff       	call   801966 <fd_lookup>
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	78 37                	js     801cf0 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cb9:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801cbc:	83 ec 08             	sub    $0x8,%esp
  801cbf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc2:	50                   	push   %eax
  801cc3:	ff 36                	push   (%esi)
  801cc5:	e8 ec fc ff ff       	call   8019b6 <dev_lookup>
  801cca:	83 c4 10             	add    $0x10,%esp
  801ccd:	85 c0                	test   %eax,%eax
  801ccf:	78 1f                	js     801cf0 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801cd1:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801cd5:	74 20                	je     801cf7 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cda:	8b 40 0c             	mov    0xc(%eax),%eax
  801cdd:	85 c0                	test   %eax,%eax
  801cdf:	74 37                	je     801d18 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801ce1:	83 ec 04             	sub    $0x4,%esp
  801ce4:	ff 75 10             	push   0x10(%ebp)
  801ce7:	ff 75 0c             	push   0xc(%ebp)
  801cea:	56                   	push   %esi
  801ceb:	ff d0                	call   *%eax
  801ced:	83 c4 10             	add    $0x10,%esp
}
  801cf0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf3:	5b                   	pop    %ebx
  801cf4:	5e                   	pop    %esi
  801cf5:	5d                   	pop    %ebp
  801cf6:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801cf7:	a1 18 50 80 00       	mov    0x805018,%eax
  801cfc:	8b 40 48             	mov    0x48(%eax),%eax
  801cff:	83 ec 04             	sub    $0x4,%esp
  801d02:	53                   	push   %ebx
  801d03:	50                   	push   %eax
  801d04:	68 15 33 80 00       	push   $0x803315
  801d09:	e8 47 ec ff ff       	call   800955 <cprintf>
		return -E_INVAL;
  801d0e:	83 c4 10             	add    $0x10,%esp
  801d11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d16:	eb d8                	jmp    801cf0 <write+0x53>
		return -E_NOT_SUPP;
  801d18:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801d1d:	eb d1                	jmp    801cf0 <write+0x53>

00801d1f <seek>:

int
seek(int fdnum, off_t offset)
{
  801d1f:	55                   	push   %ebp
  801d20:	89 e5                	mov    %esp,%ebp
  801d22:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d28:	50                   	push   %eax
  801d29:	ff 75 08             	push   0x8(%ebp)
  801d2c:	e8 35 fc ff ff       	call   801966 <fd_lookup>
  801d31:	83 c4 10             	add    $0x10,%esp
  801d34:	85 c0                	test   %eax,%eax
  801d36:	78 0e                	js     801d46 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801d38:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801d41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d46:	c9                   	leave  
  801d47:	c3                   	ret    

00801d48 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
  801d4b:	56                   	push   %esi
  801d4c:	53                   	push   %ebx
  801d4d:	83 ec 18             	sub    $0x18,%esp
  801d50:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d53:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d56:	50                   	push   %eax
  801d57:	53                   	push   %ebx
  801d58:	e8 09 fc ff ff       	call   801966 <fd_lookup>
  801d5d:	83 c4 10             	add    $0x10,%esp
  801d60:	85 c0                	test   %eax,%eax
  801d62:	78 34                	js     801d98 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d64:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801d67:	83 ec 08             	sub    $0x8,%esp
  801d6a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d6d:	50                   	push   %eax
  801d6e:	ff 36                	push   (%esi)
  801d70:	e8 41 fc ff ff       	call   8019b6 <dev_lookup>
  801d75:	83 c4 10             	add    $0x10,%esp
  801d78:	85 c0                	test   %eax,%eax
  801d7a:	78 1c                	js     801d98 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801d7c:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801d80:	74 1d                	je     801d9f <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d85:	8b 40 18             	mov    0x18(%eax),%eax
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	74 34                	je     801dc0 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801d8c:	83 ec 08             	sub    $0x8,%esp
  801d8f:	ff 75 0c             	push   0xc(%ebp)
  801d92:	56                   	push   %esi
  801d93:	ff d0                	call   *%eax
  801d95:	83 c4 10             	add    $0x10,%esp
}
  801d98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d9b:	5b                   	pop    %ebx
  801d9c:	5e                   	pop    %esi
  801d9d:	5d                   	pop    %ebp
  801d9e:	c3                   	ret    
			thisenv->env_id, fdnum);
  801d9f:	a1 18 50 80 00       	mov    0x805018,%eax
  801da4:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801da7:	83 ec 04             	sub    $0x4,%esp
  801daa:	53                   	push   %ebx
  801dab:	50                   	push   %eax
  801dac:	68 d8 32 80 00       	push   $0x8032d8
  801db1:	e8 9f eb ff ff       	call   800955 <cprintf>
		return -E_INVAL;
  801db6:	83 c4 10             	add    $0x10,%esp
  801db9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801dbe:	eb d8                	jmp    801d98 <ftruncate+0x50>
		return -E_NOT_SUPP;
  801dc0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801dc5:	eb d1                	jmp    801d98 <ftruncate+0x50>

00801dc7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	56                   	push   %esi
  801dcb:	53                   	push   %ebx
  801dcc:	83 ec 18             	sub    $0x18,%esp
  801dcf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801dd2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dd5:	50                   	push   %eax
  801dd6:	ff 75 08             	push   0x8(%ebp)
  801dd9:	e8 88 fb ff ff       	call   801966 <fd_lookup>
  801dde:	83 c4 10             	add    $0x10,%esp
  801de1:	85 c0                	test   %eax,%eax
  801de3:	78 49                	js     801e2e <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801de5:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801de8:	83 ec 08             	sub    $0x8,%esp
  801deb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dee:	50                   	push   %eax
  801def:	ff 36                	push   (%esi)
  801df1:	e8 c0 fb ff ff       	call   8019b6 <dev_lookup>
  801df6:	83 c4 10             	add    $0x10,%esp
  801df9:	85 c0                	test   %eax,%eax
  801dfb:	78 31                	js     801e2e <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e00:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801e04:	74 2f                	je     801e35 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801e06:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801e09:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801e10:	00 00 00 
	stat->st_isdir = 0;
  801e13:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e1a:	00 00 00 
	stat->st_dev = dev;
  801e1d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801e23:	83 ec 08             	sub    $0x8,%esp
  801e26:	53                   	push   %ebx
  801e27:	56                   	push   %esi
  801e28:	ff 50 14             	call   *0x14(%eax)
  801e2b:	83 c4 10             	add    $0x10,%esp
}
  801e2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e31:	5b                   	pop    %ebx
  801e32:	5e                   	pop    %esi
  801e33:	5d                   	pop    %ebp
  801e34:	c3                   	ret    
		return -E_NOT_SUPP;
  801e35:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801e3a:	eb f2                	jmp    801e2e <fstat+0x67>

00801e3c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	56                   	push   %esi
  801e40:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801e41:	83 ec 08             	sub    $0x8,%esp
  801e44:	6a 00                	push   $0x0
  801e46:	ff 75 08             	push   0x8(%ebp)
  801e49:	e8 e4 01 00 00       	call   802032 <open>
  801e4e:	89 c3                	mov    %eax,%ebx
  801e50:	83 c4 10             	add    $0x10,%esp
  801e53:	85 c0                	test   %eax,%eax
  801e55:	78 1b                	js     801e72 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801e57:	83 ec 08             	sub    $0x8,%esp
  801e5a:	ff 75 0c             	push   0xc(%ebp)
  801e5d:	50                   	push   %eax
  801e5e:	e8 64 ff ff ff       	call   801dc7 <fstat>
  801e63:	89 c6                	mov    %eax,%esi
	close(fd);
  801e65:	89 1c 24             	mov    %ebx,(%esp)
  801e68:	e8 26 fc ff ff       	call   801a93 <close>
	return r;
  801e6d:	83 c4 10             	add    $0x10,%esp
  801e70:	89 f3                	mov    %esi,%ebx
}
  801e72:	89 d8                	mov    %ebx,%eax
  801e74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e77:	5b                   	pop    %ebx
  801e78:	5e                   	pop    %esi
  801e79:	5d                   	pop    %ebp
  801e7a:	c3                   	ret    

00801e7b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801e7b:	55                   	push   %ebp
  801e7c:	89 e5                	mov    %esp,%ebp
  801e7e:	56                   	push   %esi
  801e7f:	53                   	push   %ebx
  801e80:	89 c6                	mov    %eax,%esi
  801e82:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801e84:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  801e8b:	74 27                	je     801eb4 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801e8d:	6a 07                	push   $0x7
  801e8f:	68 00 60 80 00       	push   $0x806000
  801e94:	56                   	push   %esi
  801e95:	ff 35 00 70 80 00    	push   0x807000
  801e9b:	e8 c2 f9 ff ff       	call   801862 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ea0:	83 c4 0c             	add    $0xc,%esp
  801ea3:	6a 00                	push   $0x0
  801ea5:	53                   	push   %ebx
  801ea6:	6a 00                	push   $0x0
  801ea8:	e8 4e f9 ff ff       	call   8017fb <ipc_recv>
}
  801ead:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb0:	5b                   	pop    %ebx
  801eb1:	5e                   	pop    %esi
  801eb2:	5d                   	pop    %ebp
  801eb3:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801eb4:	83 ec 0c             	sub    $0xc,%esp
  801eb7:	6a 01                	push   $0x1
  801eb9:	e8 f8 f9 ff ff       	call   8018b6 <ipc_find_env>
  801ebe:	a3 00 70 80 00       	mov    %eax,0x807000
  801ec3:	83 c4 10             	add    $0x10,%esp
  801ec6:	eb c5                	jmp    801e8d <fsipc+0x12>

00801ec8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ece:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed1:	8b 40 0c             	mov    0xc(%eax),%eax
  801ed4:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801edc:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ee1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ee6:	b8 02 00 00 00       	mov    $0x2,%eax
  801eeb:	e8 8b ff ff ff       	call   801e7b <fsipc>
}
  801ef0:	c9                   	leave  
  801ef1:	c3                   	ret    

00801ef2 <devfile_flush>:
{
  801ef2:	55                   	push   %ebp
  801ef3:	89 e5                	mov    %esp,%ebp
  801ef5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ef8:	8b 45 08             	mov    0x8(%ebp),%eax
  801efb:	8b 40 0c             	mov    0xc(%eax),%eax
  801efe:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801f03:	ba 00 00 00 00       	mov    $0x0,%edx
  801f08:	b8 06 00 00 00       	mov    $0x6,%eax
  801f0d:	e8 69 ff ff ff       	call   801e7b <fsipc>
}
  801f12:	c9                   	leave  
  801f13:	c3                   	ret    

00801f14 <devfile_stat>:
{
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	53                   	push   %ebx
  801f18:	83 ec 04             	sub    $0x4,%esp
  801f1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801f1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f21:	8b 40 0c             	mov    0xc(%eax),%eax
  801f24:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801f29:	ba 00 00 00 00       	mov    $0x0,%edx
  801f2e:	b8 05 00 00 00       	mov    $0x5,%eax
  801f33:	e8 43 ff ff ff       	call   801e7b <fsipc>
  801f38:	85 c0                	test   %eax,%eax
  801f3a:	78 2c                	js     801f68 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801f3c:	83 ec 08             	sub    $0x8,%esp
  801f3f:	68 00 60 80 00       	push   $0x806000
  801f44:	53                   	push   %ebx
  801f45:	e8 e5 ef ff ff       	call   800f2f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801f4a:	a1 80 60 80 00       	mov    0x806080,%eax
  801f4f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801f55:	a1 84 60 80 00       	mov    0x806084,%eax
  801f5a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801f60:	83 c4 10             	add    $0x10,%esp
  801f63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f6b:	c9                   	leave  
  801f6c:	c3                   	ret    

00801f6d <devfile_write>:
{
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	83 ec 0c             	sub    $0xc,%esp
  801f73:	8b 45 10             	mov    0x10(%ebp),%eax
  801f76:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801f7b:	39 d0                	cmp    %edx,%eax
  801f7d:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801f80:	8b 55 08             	mov    0x8(%ebp),%edx
  801f83:	8b 52 0c             	mov    0xc(%edx),%edx
  801f86:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801f8c:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801f91:	50                   	push   %eax
  801f92:	ff 75 0c             	push   0xc(%ebp)
  801f95:	68 08 60 80 00       	push   $0x806008
  801f9a:	e8 26 f1 ff ff       	call   8010c5 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801f9f:	ba 00 00 00 00       	mov    $0x0,%edx
  801fa4:	b8 04 00 00 00       	mov    $0x4,%eax
  801fa9:	e8 cd fe ff ff       	call   801e7b <fsipc>
}
  801fae:	c9                   	leave  
  801faf:	c3                   	ret    

00801fb0 <devfile_read>:
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	56                   	push   %esi
  801fb4:	53                   	push   %ebx
  801fb5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801fb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbb:	8b 40 0c             	mov    0xc(%eax),%eax
  801fbe:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801fc3:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801fc9:	ba 00 00 00 00       	mov    $0x0,%edx
  801fce:	b8 03 00 00 00       	mov    $0x3,%eax
  801fd3:	e8 a3 fe ff ff       	call   801e7b <fsipc>
  801fd8:	89 c3                	mov    %eax,%ebx
  801fda:	85 c0                	test   %eax,%eax
  801fdc:	78 1f                	js     801ffd <devfile_read+0x4d>
	assert(r <= n);
  801fde:	39 f0                	cmp    %esi,%eax
  801fe0:	77 24                	ja     802006 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801fe2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801fe7:	7f 33                	jg     80201c <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801fe9:	83 ec 04             	sub    $0x4,%esp
  801fec:	50                   	push   %eax
  801fed:	68 00 60 80 00       	push   $0x806000
  801ff2:	ff 75 0c             	push   0xc(%ebp)
  801ff5:	e8 cb f0 ff ff       	call   8010c5 <memmove>
	return r;
  801ffa:	83 c4 10             	add    $0x10,%esp
}
  801ffd:	89 d8                	mov    %ebx,%eax
  801fff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802002:	5b                   	pop    %ebx
  802003:	5e                   	pop    %esi
  802004:	5d                   	pop    %ebp
  802005:	c3                   	ret    
	assert(r <= n);
  802006:	68 48 33 80 00       	push   $0x803348
  80200b:	68 4f 33 80 00       	push   $0x80334f
  802010:	6a 7c                	push   $0x7c
  802012:	68 64 33 80 00       	push   $0x803364
  802017:	e8 5e e8 ff ff       	call   80087a <_panic>
	assert(r <= PGSIZE);
  80201c:	68 6f 33 80 00       	push   $0x80336f
  802021:	68 4f 33 80 00       	push   $0x80334f
  802026:	6a 7d                	push   $0x7d
  802028:	68 64 33 80 00       	push   $0x803364
  80202d:	e8 48 e8 ff ff       	call   80087a <_panic>

00802032 <open>:
{
  802032:	55                   	push   %ebp
  802033:	89 e5                	mov    %esp,%ebp
  802035:	56                   	push   %esi
  802036:	53                   	push   %ebx
  802037:	83 ec 1c             	sub    $0x1c,%esp
  80203a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80203d:	56                   	push   %esi
  80203e:	e8 b1 ee ff ff       	call   800ef4 <strlen>
  802043:	83 c4 10             	add    $0x10,%esp
  802046:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80204b:	7f 6c                	jg     8020b9 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80204d:	83 ec 0c             	sub    $0xc,%esp
  802050:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802053:	50                   	push   %eax
  802054:	e8 bd f8 ff ff       	call   801916 <fd_alloc>
  802059:	89 c3                	mov    %eax,%ebx
  80205b:	83 c4 10             	add    $0x10,%esp
  80205e:	85 c0                	test   %eax,%eax
  802060:	78 3c                	js     80209e <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  802062:	83 ec 08             	sub    $0x8,%esp
  802065:	56                   	push   %esi
  802066:	68 00 60 80 00       	push   $0x806000
  80206b:	e8 bf ee ff ff       	call   800f2f <strcpy>
	fsipcbuf.open.req_omode = mode;
  802070:	8b 45 0c             	mov    0xc(%ebp),%eax
  802073:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802078:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80207b:	b8 01 00 00 00       	mov    $0x1,%eax
  802080:	e8 f6 fd ff ff       	call   801e7b <fsipc>
  802085:	89 c3                	mov    %eax,%ebx
  802087:	83 c4 10             	add    $0x10,%esp
  80208a:	85 c0                	test   %eax,%eax
  80208c:	78 19                	js     8020a7 <open+0x75>
	return fd2num(fd);
  80208e:	83 ec 0c             	sub    $0xc,%esp
  802091:	ff 75 f4             	push   -0xc(%ebp)
  802094:	e8 56 f8 ff ff       	call   8018ef <fd2num>
  802099:	89 c3                	mov    %eax,%ebx
  80209b:	83 c4 10             	add    $0x10,%esp
}
  80209e:	89 d8                	mov    %ebx,%eax
  8020a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5d                   	pop    %ebp
  8020a6:	c3                   	ret    
		fd_close(fd, 0);
  8020a7:	83 ec 08             	sub    $0x8,%esp
  8020aa:	6a 00                	push   $0x0
  8020ac:	ff 75 f4             	push   -0xc(%ebp)
  8020af:	e8 58 f9 ff ff       	call   801a0c <fd_close>
		return r;
  8020b4:	83 c4 10             	add    $0x10,%esp
  8020b7:	eb e5                	jmp    80209e <open+0x6c>
		return -E_BAD_PATH;
  8020b9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8020be:	eb de                	jmp    80209e <open+0x6c>

008020c0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8020c0:	55                   	push   %ebp
  8020c1:	89 e5                	mov    %esp,%ebp
  8020c3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8020c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8020cb:	b8 08 00 00 00       	mov    $0x8,%eax
  8020d0:	e8 a6 fd ff ff       	call   801e7b <fsipc>
}
  8020d5:	c9                   	leave  
  8020d6:	c3                   	ret    

008020d7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8020d7:	55                   	push   %ebp
  8020d8:	89 e5                	mov    %esp,%ebp
  8020da:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8020dd:	68 7b 33 80 00       	push   $0x80337b
  8020e2:	ff 75 0c             	push   0xc(%ebp)
  8020e5:	e8 45 ee ff ff       	call   800f2f <strcpy>
	return 0;
}
  8020ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8020ef:	c9                   	leave  
  8020f0:	c3                   	ret    

008020f1 <devsock_close>:
{
  8020f1:	55                   	push   %ebp
  8020f2:	89 e5                	mov    %esp,%ebp
  8020f4:	53                   	push   %ebx
  8020f5:	83 ec 10             	sub    $0x10,%esp
  8020f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8020fb:	53                   	push   %ebx
  8020fc:	e8 98 09 00 00       	call   802a99 <pageref>
  802101:	89 c2                	mov    %eax,%edx
  802103:	83 c4 10             	add    $0x10,%esp
		return 0;
  802106:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  80210b:	83 fa 01             	cmp    $0x1,%edx
  80210e:	74 05                	je     802115 <devsock_close+0x24>
}
  802110:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802113:	c9                   	leave  
  802114:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  802115:	83 ec 0c             	sub    $0xc,%esp
  802118:	ff 73 0c             	push   0xc(%ebx)
  80211b:	e8 b7 02 00 00       	call   8023d7 <nsipc_close>
  802120:	83 c4 10             	add    $0x10,%esp
  802123:	eb eb                	jmp    802110 <devsock_close+0x1f>

00802125 <devsock_write>:
{
  802125:	55                   	push   %ebp
  802126:	89 e5                	mov    %esp,%ebp
  802128:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80212b:	6a 00                	push   $0x0
  80212d:	ff 75 10             	push   0x10(%ebp)
  802130:	ff 75 0c             	push   0xc(%ebp)
  802133:	8b 45 08             	mov    0x8(%ebp),%eax
  802136:	ff 70 0c             	push   0xc(%eax)
  802139:	e8 79 03 00 00       	call   8024b7 <nsipc_send>
}
  80213e:	c9                   	leave  
  80213f:	c3                   	ret    

00802140 <devsock_read>:
{
  802140:	55                   	push   %ebp
  802141:	89 e5                	mov    %esp,%ebp
  802143:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802146:	6a 00                	push   $0x0
  802148:	ff 75 10             	push   0x10(%ebp)
  80214b:	ff 75 0c             	push   0xc(%ebp)
  80214e:	8b 45 08             	mov    0x8(%ebp),%eax
  802151:	ff 70 0c             	push   0xc(%eax)
  802154:	e8 ef 02 00 00       	call   802448 <nsipc_recv>
}
  802159:	c9                   	leave  
  80215a:	c3                   	ret    

0080215b <fd2sockid>:
{
  80215b:	55                   	push   %ebp
  80215c:	89 e5                	mov    %esp,%ebp
  80215e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  802161:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802164:	52                   	push   %edx
  802165:	50                   	push   %eax
  802166:	e8 fb f7 ff ff       	call   801966 <fd_lookup>
  80216b:	83 c4 10             	add    $0x10,%esp
  80216e:	85 c0                	test   %eax,%eax
  802170:	78 10                	js     802182 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  802172:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802175:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  80217b:	39 08                	cmp    %ecx,(%eax)
  80217d:	75 05                	jne    802184 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  80217f:	8b 40 0c             	mov    0xc(%eax),%eax
}
  802182:	c9                   	leave  
  802183:	c3                   	ret    
		return -E_NOT_SUPP;
  802184:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802189:	eb f7                	jmp    802182 <fd2sockid+0x27>

0080218b <alloc_sockfd>:
{
  80218b:	55                   	push   %ebp
  80218c:	89 e5                	mov    %esp,%ebp
  80218e:	56                   	push   %esi
  80218f:	53                   	push   %ebx
  802190:	83 ec 1c             	sub    $0x1c,%esp
  802193:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  802195:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802198:	50                   	push   %eax
  802199:	e8 78 f7 ff ff       	call   801916 <fd_alloc>
  80219e:	89 c3                	mov    %eax,%ebx
  8021a0:	83 c4 10             	add    $0x10,%esp
  8021a3:	85 c0                	test   %eax,%eax
  8021a5:	78 43                	js     8021ea <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8021a7:	83 ec 04             	sub    $0x4,%esp
  8021aa:	68 07 04 00 00       	push   $0x407
  8021af:	ff 75 f4             	push   -0xc(%ebp)
  8021b2:	6a 00                	push   $0x0
  8021b4:	e8 72 f1 ff ff       	call   80132b <sys_page_alloc>
  8021b9:	89 c3                	mov    %eax,%ebx
  8021bb:	83 c4 10             	add    $0x10,%esp
  8021be:	85 c0                	test   %eax,%eax
  8021c0:	78 28                	js     8021ea <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8021c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c5:	8b 15 20 40 80 00    	mov    0x804020,%edx
  8021cb:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8021cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8021d7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8021da:	83 ec 0c             	sub    $0xc,%esp
  8021dd:	50                   	push   %eax
  8021de:	e8 0c f7 ff ff       	call   8018ef <fd2num>
  8021e3:	89 c3                	mov    %eax,%ebx
  8021e5:	83 c4 10             	add    $0x10,%esp
  8021e8:	eb 0c                	jmp    8021f6 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8021ea:	83 ec 0c             	sub    $0xc,%esp
  8021ed:	56                   	push   %esi
  8021ee:	e8 e4 01 00 00       	call   8023d7 <nsipc_close>
		return r;
  8021f3:	83 c4 10             	add    $0x10,%esp
}
  8021f6:	89 d8                	mov    %ebx,%eax
  8021f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021fb:	5b                   	pop    %ebx
  8021fc:	5e                   	pop    %esi
  8021fd:	5d                   	pop    %ebp
  8021fe:	c3                   	ret    

008021ff <accept>:
{
  8021ff:	55                   	push   %ebp
  802200:	89 e5                	mov    %esp,%ebp
  802202:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802205:	8b 45 08             	mov    0x8(%ebp),%eax
  802208:	e8 4e ff ff ff       	call   80215b <fd2sockid>
  80220d:	85 c0                	test   %eax,%eax
  80220f:	78 1b                	js     80222c <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802211:	83 ec 04             	sub    $0x4,%esp
  802214:	ff 75 10             	push   0x10(%ebp)
  802217:	ff 75 0c             	push   0xc(%ebp)
  80221a:	50                   	push   %eax
  80221b:	e8 0e 01 00 00       	call   80232e <nsipc_accept>
  802220:	83 c4 10             	add    $0x10,%esp
  802223:	85 c0                	test   %eax,%eax
  802225:	78 05                	js     80222c <accept+0x2d>
	return alloc_sockfd(r);
  802227:	e8 5f ff ff ff       	call   80218b <alloc_sockfd>
}
  80222c:	c9                   	leave  
  80222d:	c3                   	ret    

0080222e <bind>:
{
  80222e:	55                   	push   %ebp
  80222f:	89 e5                	mov    %esp,%ebp
  802231:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802234:	8b 45 08             	mov    0x8(%ebp),%eax
  802237:	e8 1f ff ff ff       	call   80215b <fd2sockid>
  80223c:	85 c0                	test   %eax,%eax
  80223e:	78 12                	js     802252 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  802240:	83 ec 04             	sub    $0x4,%esp
  802243:	ff 75 10             	push   0x10(%ebp)
  802246:	ff 75 0c             	push   0xc(%ebp)
  802249:	50                   	push   %eax
  80224a:	e8 31 01 00 00       	call   802380 <nsipc_bind>
  80224f:	83 c4 10             	add    $0x10,%esp
}
  802252:	c9                   	leave  
  802253:	c3                   	ret    

00802254 <shutdown>:
{
  802254:	55                   	push   %ebp
  802255:	89 e5                	mov    %esp,%ebp
  802257:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80225a:	8b 45 08             	mov    0x8(%ebp),%eax
  80225d:	e8 f9 fe ff ff       	call   80215b <fd2sockid>
  802262:	85 c0                	test   %eax,%eax
  802264:	78 0f                	js     802275 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  802266:	83 ec 08             	sub    $0x8,%esp
  802269:	ff 75 0c             	push   0xc(%ebp)
  80226c:	50                   	push   %eax
  80226d:	e8 43 01 00 00       	call   8023b5 <nsipc_shutdown>
  802272:	83 c4 10             	add    $0x10,%esp
}
  802275:	c9                   	leave  
  802276:	c3                   	ret    

00802277 <connect>:
{
  802277:	55                   	push   %ebp
  802278:	89 e5                	mov    %esp,%ebp
  80227a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80227d:	8b 45 08             	mov    0x8(%ebp),%eax
  802280:	e8 d6 fe ff ff       	call   80215b <fd2sockid>
  802285:	85 c0                	test   %eax,%eax
  802287:	78 12                	js     80229b <connect+0x24>
	return nsipc_connect(r, name, namelen);
  802289:	83 ec 04             	sub    $0x4,%esp
  80228c:	ff 75 10             	push   0x10(%ebp)
  80228f:	ff 75 0c             	push   0xc(%ebp)
  802292:	50                   	push   %eax
  802293:	e8 59 01 00 00       	call   8023f1 <nsipc_connect>
  802298:	83 c4 10             	add    $0x10,%esp
}
  80229b:	c9                   	leave  
  80229c:	c3                   	ret    

0080229d <listen>:
{
  80229d:	55                   	push   %ebp
  80229e:	89 e5                	mov    %esp,%ebp
  8022a0:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8022a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a6:	e8 b0 fe ff ff       	call   80215b <fd2sockid>
  8022ab:	85 c0                	test   %eax,%eax
  8022ad:	78 0f                	js     8022be <listen+0x21>
	return nsipc_listen(r, backlog);
  8022af:	83 ec 08             	sub    $0x8,%esp
  8022b2:	ff 75 0c             	push   0xc(%ebp)
  8022b5:	50                   	push   %eax
  8022b6:	e8 6b 01 00 00       	call   802426 <nsipc_listen>
  8022bb:	83 c4 10             	add    $0x10,%esp
}
  8022be:	c9                   	leave  
  8022bf:	c3                   	ret    

008022c0 <socket>:

int
socket(int domain, int type, int protocol)
{
  8022c0:	55                   	push   %ebp
  8022c1:	89 e5                	mov    %esp,%ebp
  8022c3:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8022c6:	ff 75 10             	push   0x10(%ebp)
  8022c9:	ff 75 0c             	push   0xc(%ebp)
  8022cc:	ff 75 08             	push   0x8(%ebp)
  8022cf:	e8 41 02 00 00       	call   802515 <nsipc_socket>
  8022d4:	83 c4 10             	add    $0x10,%esp
  8022d7:	85 c0                	test   %eax,%eax
  8022d9:	78 05                	js     8022e0 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8022db:	e8 ab fe ff ff       	call   80218b <alloc_sockfd>
}
  8022e0:	c9                   	leave  
  8022e1:	c3                   	ret    

008022e2 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8022e2:	55                   	push   %ebp
  8022e3:	89 e5                	mov    %esp,%ebp
  8022e5:	53                   	push   %ebx
  8022e6:	83 ec 04             	sub    $0x4,%esp
  8022e9:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8022eb:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  8022f2:	74 26                	je     80231a <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8022f4:	6a 07                	push   $0x7
  8022f6:	68 00 80 80 00       	push   $0x808000
  8022fb:	53                   	push   %ebx
  8022fc:	ff 35 00 90 80 00    	push   0x809000
  802302:	e8 5b f5 ff ff       	call   801862 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802307:	83 c4 0c             	add    $0xc,%esp
  80230a:	6a 00                	push   $0x0
  80230c:	6a 00                	push   $0x0
  80230e:	6a 00                	push   $0x0
  802310:	e8 e6 f4 ff ff       	call   8017fb <ipc_recv>
}
  802315:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802318:	c9                   	leave  
  802319:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80231a:	83 ec 0c             	sub    $0xc,%esp
  80231d:	6a 02                	push   $0x2
  80231f:	e8 92 f5 ff ff       	call   8018b6 <ipc_find_env>
  802324:	a3 00 90 80 00       	mov    %eax,0x809000
  802329:	83 c4 10             	add    $0x10,%esp
  80232c:	eb c6                	jmp    8022f4 <nsipc+0x12>

0080232e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80232e:	55                   	push   %ebp
  80232f:	89 e5                	mov    %esp,%ebp
  802331:	56                   	push   %esi
  802332:	53                   	push   %ebx
  802333:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802336:	8b 45 08             	mov    0x8(%ebp),%eax
  802339:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80233e:	8b 06                	mov    (%esi),%eax
  802340:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802345:	b8 01 00 00 00       	mov    $0x1,%eax
  80234a:	e8 93 ff ff ff       	call   8022e2 <nsipc>
  80234f:	89 c3                	mov    %eax,%ebx
  802351:	85 c0                	test   %eax,%eax
  802353:	79 09                	jns    80235e <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  802355:	89 d8                	mov    %ebx,%eax
  802357:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80235a:	5b                   	pop    %ebx
  80235b:	5e                   	pop    %esi
  80235c:	5d                   	pop    %ebp
  80235d:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80235e:	83 ec 04             	sub    $0x4,%esp
  802361:	ff 35 10 80 80 00    	push   0x808010
  802367:	68 00 80 80 00       	push   $0x808000
  80236c:	ff 75 0c             	push   0xc(%ebp)
  80236f:	e8 51 ed ff ff       	call   8010c5 <memmove>
		*addrlen = ret->ret_addrlen;
  802374:	a1 10 80 80 00       	mov    0x808010,%eax
  802379:	89 06                	mov    %eax,(%esi)
  80237b:	83 c4 10             	add    $0x10,%esp
	return r;
  80237e:	eb d5                	jmp    802355 <nsipc_accept+0x27>

00802380 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802380:	55                   	push   %ebp
  802381:	89 e5                	mov    %esp,%ebp
  802383:	53                   	push   %ebx
  802384:	83 ec 08             	sub    $0x8,%esp
  802387:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80238a:	8b 45 08             	mov    0x8(%ebp),%eax
  80238d:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802392:	53                   	push   %ebx
  802393:	ff 75 0c             	push   0xc(%ebp)
  802396:	68 04 80 80 00       	push   $0x808004
  80239b:	e8 25 ed ff ff       	call   8010c5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8023a0:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  8023a6:	b8 02 00 00 00       	mov    $0x2,%eax
  8023ab:	e8 32 ff ff ff       	call   8022e2 <nsipc>
}
  8023b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023b3:	c9                   	leave  
  8023b4:	c3                   	ret    

008023b5 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8023b5:	55                   	push   %ebp
  8023b6:	89 e5                	mov    %esp,%ebp
  8023b8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8023bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023be:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  8023c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023c6:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  8023cb:	b8 03 00 00 00       	mov    $0x3,%eax
  8023d0:	e8 0d ff ff ff       	call   8022e2 <nsipc>
}
  8023d5:	c9                   	leave  
  8023d6:	c3                   	ret    

008023d7 <nsipc_close>:

int
nsipc_close(int s)
{
  8023d7:	55                   	push   %ebp
  8023d8:	89 e5                	mov    %esp,%ebp
  8023da:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8023dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8023e0:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  8023e5:	b8 04 00 00 00       	mov    $0x4,%eax
  8023ea:	e8 f3 fe ff ff       	call   8022e2 <nsipc>
}
  8023ef:	c9                   	leave  
  8023f0:	c3                   	ret    

008023f1 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8023f1:	55                   	push   %ebp
  8023f2:	89 e5                	mov    %esp,%ebp
  8023f4:	53                   	push   %ebx
  8023f5:	83 ec 08             	sub    $0x8,%esp
  8023f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8023fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023fe:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802403:	53                   	push   %ebx
  802404:	ff 75 0c             	push   0xc(%ebp)
  802407:	68 04 80 80 00       	push   $0x808004
  80240c:	e8 b4 ec ff ff       	call   8010c5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802411:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  802417:	b8 05 00 00 00       	mov    $0x5,%eax
  80241c:	e8 c1 fe ff ff       	call   8022e2 <nsipc>
}
  802421:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802424:	c9                   	leave  
  802425:	c3                   	ret    

00802426 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802426:	55                   	push   %ebp
  802427:	89 e5                	mov    %esp,%ebp
  802429:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80242c:	8b 45 08             	mov    0x8(%ebp),%eax
  80242f:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  802434:	8b 45 0c             	mov    0xc(%ebp),%eax
  802437:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  80243c:	b8 06 00 00 00       	mov    $0x6,%eax
  802441:	e8 9c fe ff ff       	call   8022e2 <nsipc>
}
  802446:	c9                   	leave  
  802447:	c3                   	ret    

00802448 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802448:	55                   	push   %ebp
  802449:	89 e5                	mov    %esp,%ebp
  80244b:	56                   	push   %esi
  80244c:	53                   	push   %ebx
  80244d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802450:	8b 45 08             	mov    0x8(%ebp),%eax
  802453:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  802458:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  80245e:	8b 45 14             	mov    0x14(%ebp),%eax
  802461:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802466:	b8 07 00 00 00       	mov    $0x7,%eax
  80246b:	e8 72 fe ff ff       	call   8022e2 <nsipc>
  802470:	89 c3                	mov    %eax,%ebx
  802472:	85 c0                	test   %eax,%eax
  802474:	78 22                	js     802498 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  802476:	b8 3f 06 00 00       	mov    $0x63f,%eax
  80247b:	39 c6                	cmp    %eax,%esi
  80247d:	0f 4e c6             	cmovle %esi,%eax
  802480:	39 c3                	cmp    %eax,%ebx
  802482:	7f 1d                	jg     8024a1 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802484:	83 ec 04             	sub    $0x4,%esp
  802487:	53                   	push   %ebx
  802488:	68 00 80 80 00       	push   $0x808000
  80248d:	ff 75 0c             	push   0xc(%ebp)
  802490:	e8 30 ec ff ff       	call   8010c5 <memmove>
  802495:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802498:	89 d8                	mov    %ebx,%eax
  80249a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80249d:	5b                   	pop    %ebx
  80249e:	5e                   	pop    %esi
  80249f:	5d                   	pop    %ebp
  8024a0:	c3                   	ret    
		assert(r < 1600 && r <= len);
  8024a1:	68 87 33 80 00       	push   $0x803387
  8024a6:	68 4f 33 80 00       	push   $0x80334f
  8024ab:	6a 62                	push   $0x62
  8024ad:	68 9c 33 80 00       	push   $0x80339c
  8024b2:	e8 c3 e3 ff ff       	call   80087a <_panic>

008024b7 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8024b7:	55                   	push   %ebp
  8024b8:	89 e5                	mov    %esp,%ebp
  8024ba:	53                   	push   %ebx
  8024bb:	83 ec 04             	sub    $0x4,%esp
  8024be:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8024c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8024c4:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  8024c9:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8024cf:	7f 2e                	jg     8024ff <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8024d1:	83 ec 04             	sub    $0x4,%esp
  8024d4:	53                   	push   %ebx
  8024d5:	ff 75 0c             	push   0xc(%ebp)
  8024d8:	68 0c 80 80 00       	push   $0x80800c
  8024dd:	e8 e3 eb ff ff       	call   8010c5 <memmove>
	nsipcbuf.send.req_size = size;
  8024e2:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  8024e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8024eb:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  8024f0:	b8 08 00 00 00       	mov    $0x8,%eax
  8024f5:	e8 e8 fd ff ff       	call   8022e2 <nsipc>
}
  8024fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024fd:	c9                   	leave  
  8024fe:	c3                   	ret    
	assert(size < 1600);
  8024ff:	68 a8 33 80 00       	push   $0x8033a8
  802504:	68 4f 33 80 00       	push   $0x80334f
  802509:	6a 6d                	push   $0x6d
  80250b:	68 9c 33 80 00       	push   $0x80339c
  802510:	e8 65 e3 ff ff       	call   80087a <_panic>

00802515 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802515:	55                   	push   %ebp
  802516:	89 e5                	mov    %esp,%ebp
  802518:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80251b:	8b 45 08             	mov    0x8(%ebp),%eax
  80251e:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  802523:	8b 45 0c             	mov    0xc(%ebp),%eax
  802526:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  80252b:	8b 45 10             	mov    0x10(%ebp),%eax
  80252e:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  802533:	b8 09 00 00 00       	mov    $0x9,%eax
  802538:	e8 a5 fd ff ff       	call   8022e2 <nsipc>
}
  80253d:	c9                   	leave  
  80253e:	c3                   	ret    

0080253f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80253f:	55                   	push   %ebp
  802540:	89 e5                	mov    %esp,%ebp
  802542:	56                   	push   %esi
  802543:	53                   	push   %ebx
  802544:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802547:	83 ec 0c             	sub    $0xc,%esp
  80254a:	ff 75 08             	push   0x8(%ebp)
  80254d:	e8 ad f3 ff ff       	call   8018ff <fd2data>
  802552:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802554:	83 c4 08             	add    $0x8,%esp
  802557:	68 b4 33 80 00       	push   $0x8033b4
  80255c:	53                   	push   %ebx
  80255d:	e8 cd e9 ff ff       	call   800f2f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802562:	8b 46 04             	mov    0x4(%esi),%eax
  802565:	2b 06                	sub    (%esi),%eax
  802567:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80256d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802574:	00 00 00 
	stat->st_dev = &devpipe;
  802577:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  80257e:	40 80 00 
	return 0;
}
  802581:	b8 00 00 00 00       	mov    $0x0,%eax
  802586:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802589:	5b                   	pop    %ebx
  80258a:	5e                   	pop    %esi
  80258b:	5d                   	pop    %ebp
  80258c:	c3                   	ret    

0080258d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80258d:	55                   	push   %ebp
  80258e:	89 e5                	mov    %esp,%ebp
  802590:	53                   	push   %ebx
  802591:	83 ec 0c             	sub    $0xc,%esp
  802594:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802597:	53                   	push   %ebx
  802598:	6a 00                	push   $0x0
  80259a:	e8 11 ee ff ff       	call   8013b0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80259f:	89 1c 24             	mov    %ebx,(%esp)
  8025a2:	e8 58 f3 ff ff       	call   8018ff <fd2data>
  8025a7:	83 c4 08             	add    $0x8,%esp
  8025aa:	50                   	push   %eax
  8025ab:	6a 00                	push   $0x0
  8025ad:	e8 fe ed ff ff       	call   8013b0 <sys_page_unmap>
}
  8025b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8025b5:	c9                   	leave  
  8025b6:	c3                   	ret    

008025b7 <_pipeisclosed>:
{
  8025b7:	55                   	push   %ebp
  8025b8:	89 e5                	mov    %esp,%ebp
  8025ba:	57                   	push   %edi
  8025bb:	56                   	push   %esi
  8025bc:	53                   	push   %ebx
  8025bd:	83 ec 1c             	sub    $0x1c,%esp
  8025c0:	89 c7                	mov    %eax,%edi
  8025c2:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8025c4:	a1 18 50 80 00       	mov    0x805018,%eax
  8025c9:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8025cc:	83 ec 0c             	sub    $0xc,%esp
  8025cf:	57                   	push   %edi
  8025d0:	e8 c4 04 00 00       	call   802a99 <pageref>
  8025d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8025d8:	89 34 24             	mov    %esi,(%esp)
  8025db:	e8 b9 04 00 00       	call   802a99 <pageref>
		nn = thisenv->env_runs;
  8025e0:	8b 15 18 50 80 00    	mov    0x805018,%edx
  8025e6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8025e9:	83 c4 10             	add    $0x10,%esp
  8025ec:	39 cb                	cmp    %ecx,%ebx
  8025ee:	74 1b                	je     80260b <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8025f0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8025f3:	75 cf                	jne    8025c4 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8025f5:	8b 42 58             	mov    0x58(%edx),%eax
  8025f8:	6a 01                	push   $0x1
  8025fa:	50                   	push   %eax
  8025fb:	53                   	push   %ebx
  8025fc:	68 bb 33 80 00       	push   $0x8033bb
  802601:	e8 4f e3 ff ff       	call   800955 <cprintf>
  802606:	83 c4 10             	add    $0x10,%esp
  802609:	eb b9                	jmp    8025c4 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80260b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80260e:	0f 94 c0             	sete   %al
  802611:	0f b6 c0             	movzbl %al,%eax
}
  802614:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802617:	5b                   	pop    %ebx
  802618:	5e                   	pop    %esi
  802619:	5f                   	pop    %edi
  80261a:	5d                   	pop    %ebp
  80261b:	c3                   	ret    

0080261c <devpipe_write>:
{
  80261c:	55                   	push   %ebp
  80261d:	89 e5                	mov    %esp,%ebp
  80261f:	57                   	push   %edi
  802620:	56                   	push   %esi
  802621:	53                   	push   %ebx
  802622:	83 ec 28             	sub    $0x28,%esp
  802625:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802628:	56                   	push   %esi
  802629:	e8 d1 f2 ff ff       	call   8018ff <fd2data>
  80262e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802630:	83 c4 10             	add    $0x10,%esp
  802633:	bf 00 00 00 00       	mov    $0x0,%edi
  802638:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80263b:	75 09                	jne    802646 <devpipe_write+0x2a>
	return i;
  80263d:	89 f8                	mov    %edi,%eax
  80263f:	eb 23                	jmp    802664 <devpipe_write+0x48>
			sys_yield();
  802641:	e8 c6 ec ff ff       	call   80130c <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802646:	8b 43 04             	mov    0x4(%ebx),%eax
  802649:	8b 0b                	mov    (%ebx),%ecx
  80264b:	8d 51 20             	lea    0x20(%ecx),%edx
  80264e:	39 d0                	cmp    %edx,%eax
  802650:	72 1a                	jb     80266c <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  802652:	89 da                	mov    %ebx,%edx
  802654:	89 f0                	mov    %esi,%eax
  802656:	e8 5c ff ff ff       	call   8025b7 <_pipeisclosed>
  80265b:	85 c0                	test   %eax,%eax
  80265d:	74 e2                	je     802641 <devpipe_write+0x25>
				return 0;
  80265f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802664:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802667:	5b                   	pop    %ebx
  802668:	5e                   	pop    %esi
  802669:	5f                   	pop    %edi
  80266a:	5d                   	pop    %ebp
  80266b:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80266c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80266f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802673:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802676:	89 c2                	mov    %eax,%edx
  802678:	c1 fa 1f             	sar    $0x1f,%edx
  80267b:	89 d1                	mov    %edx,%ecx
  80267d:	c1 e9 1b             	shr    $0x1b,%ecx
  802680:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802683:	83 e2 1f             	and    $0x1f,%edx
  802686:	29 ca                	sub    %ecx,%edx
  802688:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80268c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802690:	83 c0 01             	add    $0x1,%eax
  802693:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802696:	83 c7 01             	add    $0x1,%edi
  802699:	eb 9d                	jmp    802638 <devpipe_write+0x1c>

0080269b <devpipe_read>:
{
  80269b:	55                   	push   %ebp
  80269c:	89 e5                	mov    %esp,%ebp
  80269e:	57                   	push   %edi
  80269f:	56                   	push   %esi
  8026a0:	53                   	push   %ebx
  8026a1:	83 ec 18             	sub    $0x18,%esp
  8026a4:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8026a7:	57                   	push   %edi
  8026a8:	e8 52 f2 ff ff       	call   8018ff <fd2data>
  8026ad:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8026af:	83 c4 10             	add    $0x10,%esp
  8026b2:	be 00 00 00 00       	mov    $0x0,%esi
  8026b7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8026ba:	75 13                	jne    8026cf <devpipe_read+0x34>
	return i;
  8026bc:	89 f0                	mov    %esi,%eax
  8026be:	eb 02                	jmp    8026c2 <devpipe_read+0x27>
				return i;
  8026c0:	89 f0                	mov    %esi,%eax
}
  8026c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026c5:	5b                   	pop    %ebx
  8026c6:	5e                   	pop    %esi
  8026c7:	5f                   	pop    %edi
  8026c8:	5d                   	pop    %ebp
  8026c9:	c3                   	ret    
			sys_yield();
  8026ca:	e8 3d ec ff ff       	call   80130c <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8026cf:	8b 03                	mov    (%ebx),%eax
  8026d1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8026d4:	75 18                	jne    8026ee <devpipe_read+0x53>
			if (i > 0)
  8026d6:	85 f6                	test   %esi,%esi
  8026d8:	75 e6                	jne    8026c0 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8026da:	89 da                	mov    %ebx,%edx
  8026dc:	89 f8                	mov    %edi,%eax
  8026de:	e8 d4 fe ff ff       	call   8025b7 <_pipeisclosed>
  8026e3:	85 c0                	test   %eax,%eax
  8026e5:	74 e3                	je     8026ca <devpipe_read+0x2f>
				return 0;
  8026e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8026ec:	eb d4                	jmp    8026c2 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8026ee:	99                   	cltd   
  8026ef:	c1 ea 1b             	shr    $0x1b,%edx
  8026f2:	01 d0                	add    %edx,%eax
  8026f4:	83 e0 1f             	and    $0x1f,%eax
  8026f7:	29 d0                	sub    %edx,%eax
  8026f9:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8026fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802701:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802704:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802707:	83 c6 01             	add    $0x1,%esi
  80270a:	eb ab                	jmp    8026b7 <devpipe_read+0x1c>

0080270c <pipe>:
{
  80270c:	55                   	push   %ebp
  80270d:	89 e5                	mov    %esp,%ebp
  80270f:	56                   	push   %esi
  802710:	53                   	push   %ebx
  802711:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802714:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802717:	50                   	push   %eax
  802718:	e8 f9 f1 ff ff       	call   801916 <fd_alloc>
  80271d:	89 c3                	mov    %eax,%ebx
  80271f:	83 c4 10             	add    $0x10,%esp
  802722:	85 c0                	test   %eax,%eax
  802724:	0f 88 23 01 00 00    	js     80284d <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80272a:	83 ec 04             	sub    $0x4,%esp
  80272d:	68 07 04 00 00       	push   $0x407
  802732:	ff 75 f4             	push   -0xc(%ebp)
  802735:	6a 00                	push   $0x0
  802737:	e8 ef eb ff ff       	call   80132b <sys_page_alloc>
  80273c:	89 c3                	mov    %eax,%ebx
  80273e:	83 c4 10             	add    $0x10,%esp
  802741:	85 c0                	test   %eax,%eax
  802743:	0f 88 04 01 00 00    	js     80284d <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802749:	83 ec 0c             	sub    $0xc,%esp
  80274c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80274f:	50                   	push   %eax
  802750:	e8 c1 f1 ff ff       	call   801916 <fd_alloc>
  802755:	89 c3                	mov    %eax,%ebx
  802757:	83 c4 10             	add    $0x10,%esp
  80275a:	85 c0                	test   %eax,%eax
  80275c:	0f 88 db 00 00 00    	js     80283d <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802762:	83 ec 04             	sub    $0x4,%esp
  802765:	68 07 04 00 00       	push   $0x407
  80276a:	ff 75 f0             	push   -0x10(%ebp)
  80276d:	6a 00                	push   $0x0
  80276f:	e8 b7 eb ff ff       	call   80132b <sys_page_alloc>
  802774:	89 c3                	mov    %eax,%ebx
  802776:	83 c4 10             	add    $0x10,%esp
  802779:	85 c0                	test   %eax,%eax
  80277b:	0f 88 bc 00 00 00    	js     80283d <pipe+0x131>
	va = fd2data(fd0);
  802781:	83 ec 0c             	sub    $0xc,%esp
  802784:	ff 75 f4             	push   -0xc(%ebp)
  802787:	e8 73 f1 ff ff       	call   8018ff <fd2data>
  80278c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80278e:	83 c4 0c             	add    $0xc,%esp
  802791:	68 07 04 00 00       	push   $0x407
  802796:	50                   	push   %eax
  802797:	6a 00                	push   $0x0
  802799:	e8 8d eb ff ff       	call   80132b <sys_page_alloc>
  80279e:	89 c3                	mov    %eax,%ebx
  8027a0:	83 c4 10             	add    $0x10,%esp
  8027a3:	85 c0                	test   %eax,%eax
  8027a5:	0f 88 82 00 00 00    	js     80282d <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8027ab:	83 ec 0c             	sub    $0xc,%esp
  8027ae:	ff 75 f0             	push   -0x10(%ebp)
  8027b1:	e8 49 f1 ff ff       	call   8018ff <fd2data>
  8027b6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8027bd:	50                   	push   %eax
  8027be:	6a 00                	push   $0x0
  8027c0:	56                   	push   %esi
  8027c1:	6a 00                	push   $0x0
  8027c3:	e8 a6 eb ff ff       	call   80136e <sys_page_map>
  8027c8:	89 c3                	mov    %eax,%ebx
  8027ca:	83 c4 20             	add    $0x20,%esp
  8027cd:	85 c0                	test   %eax,%eax
  8027cf:	78 4e                	js     80281f <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8027d1:	a1 3c 40 80 00       	mov    0x80403c,%eax
  8027d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8027d9:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8027db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8027de:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8027e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8027e8:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8027ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8027ed:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8027f4:	83 ec 0c             	sub    $0xc,%esp
  8027f7:	ff 75 f4             	push   -0xc(%ebp)
  8027fa:	e8 f0 f0 ff ff       	call   8018ef <fd2num>
  8027ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802802:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802804:	83 c4 04             	add    $0x4,%esp
  802807:	ff 75 f0             	push   -0x10(%ebp)
  80280a:	e8 e0 f0 ff ff       	call   8018ef <fd2num>
  80280f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802812:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802815:	83 c4 10             	add    $0x10,%esp
  802818:	bb 00 00 00 00       	mov    $0x0,%ebx
  80281d:	eb 2e                	jmp    80284d <pipe+0x141>
	sys_page_unmap(0, va);
  80281f:	83 ec 08             	sub    $0x8,%esp
  802822:	56                   	push   %esi
  802823:	6a 00                	push   $0x0
  802825:	e8 86 eb ff ff       	call   8013b0 <sys_page_unmap>
  80282a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80282d:	83 ec 08             	sub    $0x8,%esp
  802830:	ff 75 f0             	push   -0x10(%ebp)
  802833:	6a 00                	push   $0x0
  802835:	e8 76 eb ff ff       	call   8013b0 <sys_page_unmap>
  80283a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80283d:	83 ec 08             	sub    $0x8,%esp
  802840:	ff 75 f4             	push   -0xc(%ebp)
  802843:	6a 00                	push   $0x0
  802845:	e8 66 eb ff ff       	call   8013b0 <sys_page_unmap>
  80284a:	83 c4 10             	add    $0x10,%esp
}
  80284d:	89 d8                	mov    %ebx,%eax
  80284f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802852:	5b                   	pop    %ebx
  802853:	5e                   	pop    %esi
  802854:	5d                   	pop    %ebp
  802855:	c3                   	ret    

00802856 <pipeisclosed>:
{
  802856:	55                   	push   %ebp
  802857:	89 e5                	mov    %esp,%ebp
  802859:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80285c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80285f:	50                   	push   %eax
  802860:	ff 75 08             	push   0x8(%ebp)
  802863:	e8 fe f0 ff ff       	call   801966 <fd_lookup>
  802868:	83 c4 10             	add    $0x10,%esp
  80286b:	85 c0                	test   %eax,%eax
  80286d:	78 18                	js     802887 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80286f:	83 ec 0c             	sub    $0xc,%esp
  802872:	ff 75 f4             	push   -0xc(%ebp)
  802875:	e8 85 f0 ff ff       	call   8018ff <fd2data>
  80287a:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80287c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80287f:	e8 33 fd ff ff       	call   8025b7 <_pipeisclosed>
  802884:	83 c4 10             	add    $0x10,%esp
}
  802887:	c9                   	leave  
  802888:	c3                   	ret    

00802889 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802889:	b8 00 00 00 00       	mov    $0x0,%eax
  80288e:	c3                   	ret    

0080288f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80288f:	55                   	push   %ebp
  802890:	89 e5                	mov    %esp,%ebp
  802892:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802895:	68 d3 33 80 00       	push   $0x8033d3
  80289a:	ff 75 0c             	push   0xc(%ebp)
  80289d:	e8 8d e6 ff ff       	call   800f2f <strcpy>
	return 0;
}
  8028a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8028a7:	c9                   	leave  
  8028a8:	c3                   	ret    

008028a9 <devcons_write>:
{
  8028a9:	55                   	push   %ebp
  8028aa:	89 e5                	mov    %esp,%ebp
  8028ac:	57                   	push   %edi
  8028ad:	56                   	push   %esi
  8028ae:	53                   	push   %ebx
  8028af:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8028b5:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8028ba:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8028c0:	eb 2e                	jmp    8028f0 <devcons_write+0x47>
		m = n - tot;
  8028c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8028c5:	29 f3                	sub    %esi,%ebx
  8028c7:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8028cc:	39 c3                	cmp    %eax,%ebx
  8028ce:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8028d1:	83 ec 04             	sub    $0x4,%esp
  8028d4:	53                   	push   %ebx
  8028d5:	89 f0                	mov    %esi,%eax
  8028d7:	03 45 0c             	add    0xc(%ebp),%eax
  8028da:	50                   	push   %eax
  8028db:	57                   	push   %edi
  8028dc:	e8 e4 e7 ff ff       	call   8010c5 <memmove>
		sys_cputs(buf, m);
  8028e1:	83 c4 08             	add    $0x8,%esp
  8028e4:	53                   	push   %ebx
  8028e5:	57                   	push   %edi
  8028e6:	e8 84 e9 ff ff       	call   80126f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8028eb:	01 de                	add    %ebx,%esi
  8028ed:	83 c4 10             	add    $0x10,%esp
  8028f0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8028f3:	72 cd                	jb     8028c2 <devcons_write+0x19>
}
  8028f5:	89 f0                	mov    %esi,%eax
  8028f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028fa:	5b                   	pop    %ebx
  8028fb:	5e                   	pop    %esi
  8028fc:	5f                   	pop    %edi
  8028fd:	5d                   	pop    %ebp
  8028fe:	c3                   	ret    

008028ff <devcons_read>:
{
  8028ff:	55                   	push   %ebp
  802900:	89 e5                	mov    %esp,%ebp
  802902:	83 ec 08             	sub    $0x8,%esp
  802905:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80290a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80290e:	75 07                	jne    802917 <devcons_read+0x18>
  802910:	eb 1f                	jmp    802931 <devcons_read+0x32>
		sys_yield();
  802912:	e8 f5 e9 ff ff       	call   80130c <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802917:	e8 71 e9 ff ff       	call   80128d <sys_cgetc>
  80291c:	85 c0                	test   %eax,%eax
  80291e:	74 f2                	je     802912 <devcons_read+0x13>
	if (c < 0)
  802920:	78 0f                	js     802931 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802922:	83 f8 04             	cmp    $0x4,%eax
  802925:	74 0c                	je     802933 <devcons_read+0x34>
	*(char*)vbuf = c;
  802927:	8b 55 0c             	mov    0xc(%ebp),%edx
  80292a:	88 02                	mov    %al,(%edx)
	return 1;
  80292c:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802931:	c9                   	leave  
  802932:	c3                   	ret    
		return 0;
  802933:	b8 00 00 00 00       	mov    $0x0,%eax
  802938:	eb f7                	jmp    802931 <devcons_read+0x32>

0080293a <cputchar>:
{
  80293a:	55                   	push   %ebp
  80293b:	89 e5                	mov    %esp,%ebp
  80293d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802940:	8b 45 08             	mov    0x8(%ebp),%eax
  802943:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802946:	6a 01                	push   $0x1
  802948:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80294b:	50                   	push   %eax
  80294c:	e8 1e e9 ff ff       	call   80126f <sys_cputs>
}
  802951:	83 c4 10             	add    $0x10,%esp
  802954:	c9                   	leave  
  802955:	c3                   	ret    

00802956 <getchar>:
{
  802956:	55                   	push   %ebp
  802957:	89 e5                	mov    %esp,%ebp
  802959:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80295c:	6a 01                	push   $0x1
  80295e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802961:	50                   	push   %eax
  802962:	6a 00                	push   $0x0
  802964:	e8 66 f2 ff ff       	call   801bcf <read>
	if (r < 0)
  802969:	83 c4 10             	add    $0x10,%esp
  80296c:	85 c0                	test   %eax,%eax
  80296e:	78 06                	js     802976 <getchar+0x20>
	if (r < 1)
  802970:	74 06                	je     802978 <getchar+0x22>
	return c;
  802972:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802976:	c9                   	leave  
  802977:	c3                   	ret    
		return -E_EOF;
  802978:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80297d:	eb f7                	jmp    802976 <getchar+0x20>

0080297f <iscons>:
{
  80297f:	55                   	push   %ebp
  802980:	89 e5                	mov    %esp,%ebp
  802982:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802985:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802988:	50                   	push   %eax
  802989:	ff 75 08             	push   0x8(%ebp)
  80298c:	e8 d5 ef ff ff       	call   801966 <fd_lookup>
  802991:	83 c4 10             	add    $0x10,%esp
  802994:	85 c0                	test   %eax,%eax
  802996:	78 11                	js     8029a9 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802998:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80299b:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8029a1:	39 10                	cmp    %edx,(%eax)
  8029a3:	0f 94 c0             	sete   %al
  8029a6:	0f b6 c0             	movzbl %al,%eax
}
  8029a9:	c9                   	leave  
  8029aa:	c3                   	ret    

008029ab <opencons>:
{
  8029ab:	55                   	push   %ebp
  8029ac:	89 e5                	mov    %esp,%ebp
  8029ae:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8029b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029b4:	50                   	push   %eax
  8029b5:	e8 5c ef ff ff       	call   801916 <fd_alloc>
  8029ba:	83 c4 10             	add    $0x10,%esp
  8029bd:	85 c0                	test   %eax,%eax
  8029bf:	78 3a                	js     8029fb <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8029c1:	83 ec 04             	sub    $0x4,%esp
  8029c4:	68 07 04 00 00       	push   $0x407
  8029c9:	ff 75 f4             	push   -0xc(%ebp)
  8029cc:	6a 00                	push   $0x0
  8029ce:	e8 58 e9 ff ff       	call   80132b <sys_page_alloc>
  8029d3:	83 c4 10             	add    $0x10,%esp
  8029d6:	85 c0                	test   %eax,%eax
  8029d8:	78 21                	js     8029fb <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8029da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029dd:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8029e3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8029e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029e8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8029ef:	83 ec 0c             	sub    $0xc,%esp
  8029f2:	50                   	push   %eax
  8029f3:	e8 f7 ee ff ff       	call   8018ef <fd2num>
  8029f8:	83 c4 10             	add    $0x10,%esp
}
  8029fb:	c9                   	leave  
  8029fc:	c3                   	ret    

008029fd <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8029fd:	55                   	push   %ebp
  8029fe:	89 e5                	mov    %esp,%ebp
  802a00:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  802a03:	83 3d 04 90 80 00 00 	cmpl   $0x0,0x809004
  802a0a:	74 0a                	je     802a16 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  802a0f:	a3 04 90 80 00       	mov    %eax,0x809004
}
  802a14:	c9                   	leave  
  802a15:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  802a16:	e8 d2 e8 ff ff       	call   8012ed <sys_getenvid>
  802a1b:	83 ec 04             	sub    $0x4,%esp
  802a1e:	68 07 0e 00 00       	push   $0xe07
  802a23:	68 00 f0 bf ee       	push   $0xeebff000
  802a28:	50                   	push   %eax
  802a29:	e8 fd e8 ff ff       	call   80132b <sys_page_alloc>
		if (r < 0) {
  802a2e:	83 c4 10             	add    $0x10,%esp
  802a31:	85 c0                	test   %eax,%eax
  802a33:	78 2c                	js     802a61 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802a35:	e8 b3 e8 ff ff       	call   8012ed <sys_getenvid>
  802a3a:	83 ec 08             	sub    $0x8,%esp
  802a3d:	68 73 2a 80 00       	push   $0x802a73
  802a42:	50                   	push   %eax
  802a43:	e8 2e ea ff ff       	call   801476 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802a48:	83 c4 10             	add    $0x10,%esp
  802a4b:	85 c0                	test   %eax,%eax
  802a4d:	79 bd                	jns    802a0c <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  802a4f:	50                   	push   %eax
  802a50:	68 20 34 80 00       	push   $0x803420
  802a55:	6a 28                	push   $0x28
  802a57:	68 56 34 80 00       	push   $0x803456
  802a5c:	e8 19 de ff ff       	call   80087a <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802a61:	50                   	push   %eax
  802a62:	68 e0 33 80 00       	push   $0x8033e0
  802a67:	6a 23                	push   $0x23
  802a69:	68 56 34 80 00       	push   $0x803456
  802a6e:	e8 07 de ff ff       	call   80087a <_panic>

00802a73 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802a73:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802a74:	a1 04 90 80 00       	mov    0x809004,%eax
	call *%eax
  802a79:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802a7b:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802a7e:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802a82:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802a85:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802a89:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802a8d:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  802a8f:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802a92:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  802a93:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  802a96:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  802a97:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  802a98:	c3                   	ret    

00802a99 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802a99:	55                   	push   %ebp
  802a9a:	89 e5                	mov    %esp,%ebp
  802a9c:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a9f:	89 c2                	mov    %eax,%edx
  802aa1:	c1 ea 16             	shr    $0x16,%edx
  802aa4:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802aab:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802ab0:	f6 c1 01             	test   $0x1,%cl
  802ab3:	74 1c                	je     802ad1 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802ab5:	c1 e8 0c             	shr    $0xc,%eax
  802ab8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802abf:	a8 01                	test   $0x1,%al
  802ac1:	74 0e                	je     802ad1 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802ac3:	c1 e8 0c             	shr    $0xc,%eax
  802ac6:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802acd:	ef 
  802ace:	0f b7 d2             	movzwl %dx,%edx
}
  802ad1:	89 d0                	mov    %edx,%eax
  802ad3:	5d                   	pop    %ebp
  802ad4:	c3                   	ret    
  802ad5:	66 90                	xchg   %ax,%ax
  802ad7:	66 90                	xchg   %ax,%ax
  802ad9:	66 90                	xchg   %ax,%ax
  802adb:	66 90                	xchg   %ax,%ax
  802add:	66 90                	xchg   %ax,%ax
  802adf:	90                   	nop

00802ae0 <__udivdi3>:
  802ae0:	f3 0f 1e fb          	endbr32 
  802ae4:	55                   	push   %ebp
  802ae5:	57                   	push   %edi
  802ae6:	56                   	push   %esi
  802ae7:	53                   	push   %ebx
  802ae8:	83 ec 1c             	sub    $0x1c,%esp
  802aeb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802aef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802af3:	8b 74 24 34          	mov    0x34(%esp),%esi
  802af7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802afb:	85 c0                	test   %eax,%eax
  802afd:	75 19                	jne    802b18 <__udivdi3+0x38>
  802aff:	39 f3                	cmp    %esi,%ebx
  802b01:	76 4d                	jbe    802b50 <__udivdi3+0x70>
  802b03:	31 ff                	xor    %edi,%edi
  802b05:	89 e8                	mov    %ebp,%eax
  802b07:	89 f2                	mov    %esi,%edx
  802b09:	f7 f3                	div    %ebx
  802b0b:	89 fa                	mov    %edi,%edx
  802b0d:	83 c4 1c             	add    $0x1c,%esp
  802b10:	5b                   	pop    %ebx
  802b11:	5e                   	pop    %esi
  802b12:	5f                   	pop    %edi
  802b13:	5d                   	pop    %ebp
  802b14:	c3                   	ret    
  802b15:	8d 76 00             	lea    0x0(%esi),%esi
  802b18:	39 f0                	cmp    %esi,%eax
  802b1a:	76 14                	jbe    802b30 <__udivdi3+0x50>
  802b1c:	31 ff                	xor    %edi,%edi
  802b1e:	31 c0                	xor    %eax,%eax
  802b20:	89 fa                	mov    %edi,%edx
  802b22:	83 c4 1c             	add    $0x1c,%esp
  802b25:	5b                   	pop    %ebx
  802b26:	5e                   	pop    %esi
  802b27:	5f                   	pop    %edi
  802b28:	5d                   	pop    %ebp
  802b29:	c3                   	ret    
  802b2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b30:	0f bd f8             	bsr    %eax,%edi
  802b33:	83 f7 1f             	xor    $0x1f,%edi
  802b36:	75 48                	jne    802b80 <__udivdi3+0xa0>
  802b38:	39 f0                	cmp    %esi,%eax
  802b3a:	72 06                	jb     802b42 <__udivdi3+0x62>
  802b3c:	31 c0                	xor    %eax,%eax
  802b3e:	39 eb                	cmp    %ebp,%ebx
  802b40:	77 de                	ja     802b20 <__udivdi3+0x40>
  802b42:	b8 01 00 00 00       	mov    $0x1,%eax
  802b47:	eb d7                	jmp    802b20 <__udivdi3+0x40>
  802b49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b50:	89 d9                	mov    %ebx,%ecx
  802b52:	85 db                	test   %ebx,%ebx
  802b54:	75 0b                	jne    802b61 <__udivdi3+0x81>
  802b56:	b8 01 00 00 00       	mov    $0x1,%eax
  802b5b:	31 d2                	xor    %edx,%edx
  802b5d:	f7 f3                	div    %ebx
  802b5f:	89 c1                	mov    %eax,%ecx
  802b61:	31 d2                	xor    %edx,%edx
  802b63:	89 f0                	mov    %esi,%eax
  802b65:	f7 f1                	div    %ecx
  802b67:	89 c6                	mov    %eax,%esi
  802b69:	89 e8                	mov    %ebp,%eax
  802b6b:	89 f7                	mov    %esi,%edi
  802b6d:	f7 f1                	div    %ecx
  802b6f:	89 fa                	mov    %edi,%edx
  802b71:	83 c4 1c             	add    $0x1c,%esp
  802b74:	5b                   	pop    %ebx
  802b75:	5e                   	pop    %esi
  802b76:	5f                   	pop    %edi
  802b77:	5d                   	pop    %ebp
  802b78:	c3                   	ret    
  802b79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b80:	89 f9                	mov    %edi,%ecx
  802b82:	ba 20 00 00 00       	mov    $0x20,%edx
  802b87:	29 fa                	sub    %edi,%edx
  802b89:	d3 e0                	shl    %cl,%eax
  802b8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  802b8f:	89 d1                	mov    %edx,%ecx
  802b91:	89 d8                	mov    %ebx,%eax
  802b93:	d3 e8                	shr    %cl,%eax
  802b95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802b99:	09 c1                	or     %eax,%ecx
  802b9b:	89 f0                	mov    %esi,%eax
  802b9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802ba1:	89 f9                	mov    %edi,%ecx
  802ba3:	d3 e3                	shl    %cl,%ebx
  802ba5:	89 d1                	mov    %edx,%ecx
  802ba7:	d3 e8                	shr    %cl,%eax
  802ba9:	89 f9                	mov    %edi,%ecx
  802bab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802baf:	89 eb                	mov    %ebp,%ebx
  802bb1:	d3 e6                	shl    %cl,%esi
  802bb3:	89 d1                	mov    %edx,%ecx
  802bb5:	d3 eb                	shr    %cl,%ebx
  802bb7:	09 f3                	or     %esi,%ebx
  802bb9:	89 c6                	mov    %eax,%esi
  802bbb:	89 f2                	mov    %esi,%edx
  802bbd:	89 d8                	mov    %ebx,%eax
  802bbf:	f7 74 24 08          	divl   0x8(%esp)
  802bc3:	89 d6                	mov    %edx,%esi
  802bc5:	89 c3                	mov    %eax,%ebx
  802bc7:	f7 64 24 0c          	mull   0xc(%esp)
  802bcb:	39 d6                	cmp    %edx,%esi
  802bcd:	72 19                	jb     802be8 <__udivdi3+0x108>
  802bcf:	89 f9                	mov    %edi,%ecx
  802bd1:	d3 e5                	shl    %cl,%ebp
  802bd3:	39 c5                	cmp    %eax,%ebp
  802bd5:	73 04                	jae    802bdb <__udivdi3+0xfb>
  802bd7:	39 d6                	cmp    %edx,%esi
  802bd9:	74 0d                	je     802be8 <__udivdi3+0x108>
  802bdb:	89 d8                	mov    %ebx,%eax
  802bdd:	31 ff                	xor    %edi,%edi
  802bdf:	e9 3c ff ff ff       	jmp    802b20 <__udivdi3+0x40>
  802be4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802be8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802beb:	31 ff                	xor    %edi,%edi
  802bed:	e9 2e ff ff ff       	jmp    802b20 <__udivdi3+0x40>
  802bf2:	66 90                	xchg   %ax,%ax
  802bf4:	66 90                	xchg   %ax,%ax
  802bf6:	66 90                	xchg   %ax,%ax
  802bf8:	66 90                	xchg   %ax,%ax
  802bfa:	66 90                	xchg   %ax,%ax
  802bfc:	66 90                	xchg   %ax,%ax
  802bfe:	66 90                	xchg   %ax,%ax

00802c00 <__umoddi3>:
  802c00:	f3 0f 1e fb          	endbr32 
  802c04:	55                   	push   %ebp
  802c05:	57                   	push   %edi
  802c06:	56                   	push   %esi
  802c07:	53                   	push   %ebx
  802c08:	83 ec 1c             	sub    $0x1c,%esp
  802c0b:	8b 74 24 30          	mov    0x30(%esp),%esi
  802c0f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802c13:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802c17:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  802c1b:	89 f0                	mov    %esi,%eax
  802c1d:	89 da                	mov    %ebx,%edx
  802c1f:	85 ff                	test   %edi,%edi
  802c21:	75 15                	jne    802c38 <__umoddi3+0x38>
  802c23:	39 dd                	cmp    %ebx,%ebp
  802c25:	76 39                	jbe    802c60 <__umoddi3+0x60>
  802c27:	f7 f5                	div    %ebp
  802c29:	89 d0                	mov    %edx,%eax
  802c2b:	31 d2                	xor    %edx,%edx
  802c2d:	83 c4 1c             	add    $0x1c,%esp
  802c30:	5b                   	pop    %ebx
  802c31:	5e                   	pop    %esi
  802c32:	5f                   	pop    %edi
  802c33:	5d                   	pop    %ebp
  802c34:	c3                   	ret    
  802c35:	8d 76 00             	lea    0x0(%esi),%esi
  802c38:	39 df                	cmp    %ebx,%edi
  802c3a:	77 f1                	ja     802c2d <__umoddi3+0x2d>
  802c3c:	0f bd cf             	bsr    %edi,%ecx
  802c3f:	83 f1 1f             	xor    $0x1f,%ecx
  802c42:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802c46:	75 40                	jne    802c88 <__umoddi3+0x88>
  802c48:	39 df                	cmp    %ebx,%edi
  802c4a:	72 04                	jb     802c50 <__umoddi3+0x50>
  802c4c:	39 f5                	cmp    %esi,%ebp
  802c4e:	77 dd                	ja     802c2d <__umoddi3+0x2d>
  802c50:	89 da                	mov    %ebx,%edx
  802c52:	89 f0                	mov    %esi,%eax
  802c54:	29 e8                	sub    %ebp,%eax
  802c56:	19 fa                	sbb    %edi,%edx
  802c58:	eb d3                	jmp    802c2d <__umoddi3+0x2d>
  802c5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802c60:	89 e9                	mov    %ebp,%ecx
  802c62:	85 ed                	test   %ebp,%ebp
  802c64:	75 0b                	jne    802c71 <__umoddi3+0x71>
  802c66:	b8 01 00 00 00       	mov    $0x1,%eax
  802c6b:	31 d2                	xor    %edx,%edx
  802c6d:	f7 f5                	div    %ebp
  802c6f:	89 c1                	mov    %eax,%ecx
  802c71:	89 d8                	mov    %ebx,%eax
  802c73:	31 d2                	xor    %edx,%edx
  802c75:	f7 f1                	div    %ecx
  802c77:	89 f0                	mov    %esi,%eax
  802c79:	f7 f1                	div    %ecx
  802c7b:	89 d0                	mov    %edx,%eax
  802c7d:	31 d2                	xor    %edx,%edx
  802c7f:	eb ac                	jmp    802c2d <__umoddi3+0x2d>
  802c81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c88:	8b 44 24 04          	mov    0x4(%esp),%eax
  802c8c:	ba 20 00 00 00       	mov    $0x20,%edx
  802c91:	29 c2                	sub    %eax,%edx
  802c93:	89 c1                	mov    %eax,%ecx
  802c95:	89 e8                	mov    %ebp,%eax
  802c97:	d3 e7                	shl    %cl,%edi
  802c99:	89 d1                	mov    %edx,%ecx
  802c9b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802c9f:	d3 e8                	shr    %cl,%eax
  802ca1:	89 c1                	mov    %eax,%ecx
  802ca3:	8b 44 24 04          	mov    0x4(%esp),%eax
  802ca7:	09 f9                	or     %edi,%ecx
  802ca9:	89 df                	mov    %ebx,%edi
  802cab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802caf:	89 c1                	mov    %eax,%ecx
  802cb1:	d3 e5                	shl    %cl,%ebp
  802cb3:	89 d1                	mov    %edx,%ecx
  802cb5:	d3 ef                	shr    %cl,%edi
  802cb7:	89 c1                	mov    %eax,%ecx
  802cb9:	89 f0                	mov    %esi,%eax
  802cbb:	d3 e3                	shl    %cl,%ebx
  802cbd:	89 d1                	mov    %edx,%ecx
  802cbf:	89 fa                	mov    %edi,%edx
  802cc1:	d3 e8                	shr    %cl,%eax
  802cc3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802cc8:	09 d8                	or     %ebx,%eax
  802cca:	f7 74 24 08          	divl   0x8(%esp)
  802cce:	89 d3                	mov    %edx,%ebx
  802cd0:	d3 e6                	shl    %cl,%esi
  802cd2:	f7 e5                	mul    %ebp
  802cd4:	89 c7                	mov    %eax,%edi
  802cd6:	89 d1                	mov    %edx,%ecx
  802cd8:	39 d3                	cmp    %edx,%ebx
  802cda:	72 06                	jb     802ce2 <__umoddi3+0xe2>
  802cdc:	75 0e                	jne    802cec <__umoddi3+0xec>
  802cde:	39 c6                	cmp    %eax,%esi
  802ce0:	73 0a                	jae    802cec <__umoddi3+0xec>
  802ce2:	29 e8                	sub    %ebp,%eax
  802ce4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802ce8:	89 d1                	mov    %edx,%ecx
  802cea:	89 c7                	mov    %eax,%edi
  802cec:	89 f5                	mov    %esi,%ebp
  802cee:	8b 74 24 04          	mov    0x4(%esp),%esi
  802cf2:	29 fd                	sub    %edi,%ebp
  802cf4:	19 cb                	sbb    %ecx,%ebx
  802cf6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802cfb:	89 d8                	mov    %ebx,%eax
  802cfd:	d3 e0                	shl    %cl,%eax
  802cff:	89 f1                	mov    %esi,%ecx
  802d01:	d3 ed                	shr    %cl,%ebp
  802d03:	d3 eb                	shr    %cl,%ebx
  802d05:	09 e8                	or     %ebp,%eax
  802d07:	89 da                	mov    %ebx,%edx
  802d09:	83 c4 1c             	add    $0x1c,%esp
  802d0c:	5b                   	pop    %ebx
  802d0d:	5e                   	pop    %esi
  802d0e:	5f                   	pop    %edi
  802d0f:	5d                   	pop    %ebp
  802d10:	c3                   	ret    
