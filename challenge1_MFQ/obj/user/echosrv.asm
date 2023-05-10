
obj/user/echosrv.debug：     文件格式 elf32-i386


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
  80002c:	e8 b5 04 00 00       	call   8004e6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:
#define BUFFSIZE 32
#define MAXPENDING 5    // Max connection requests

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 30 27 80 00       	push   $0x802730
  80003f:	e8 9a 05 00 00       	call   8005de <cprintf>
	exit();
  800044:	e8 e6 04 00 00       	call   80052f <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <handle_client>:

void
handle_client(int sock)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 30             	sub    $0x30,%esp
  800057:	8b 75 08             	mov    0x8(%ebp),%esi
	char buffer[BUFFSIZE];
	int received = -1;
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80005a:	6a 20                	push   $0x20
  80005c:	8d 45 c8             	lea    -0x38(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	56                   	push   %esi
  800061:	e8 80 14 00 00       	call   8014e6 <read>
  800066:	89 c3                	mov    %eax,%ebx
  800068:	83 c4 10             	add    $0x10,%esp
		die("Failed to receive initial bytes from client");

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
		// Send back received data
		if (write(sock, buffer, received) != received)
  80006b:	8d 7d c8             	lea    -0x38(%ebp),%edi
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80006e:	85 c0                	test   %eax,%eax
  800070:	79 33                	jns    8000a5 <handle_client+0x57>
		die("Failed to receive initial bytes from client");
  800072:	b8 34 27 80 00       	mov    $0x802734,%eax
  800077:	e8 b7 ff ff ff       	call   800033 <die>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
			die("Failed to receive additional bytes from client");
	}
	close(sock);
  80007c:	83 ec 0c             	sub    $0xc,%esp
  80007f:	56                   	push   %esi
  800080:	e8 25 13 00 00       	call   8013aa <close>
}
  800085:	83 c4 10             	add    $0x10,%esp
  800088:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80008b:	5b                   	pop    %ebx
  80008c:	5e                   	pop    %esi
  80008d:	5f                   	pop    %edi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  800090:	83 ec 04             	sub    $0x4,%esp
  800093:	6a 20                	push   $0x20
  800095:	57                   	push   %edi
  800096:	56                   	push   %esi
  800097:	e8 4a 14 00 00       	call   8014e6 <read>
  80009c:	89 c3                	mov    %eax,%ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	78 22                	js     8000c7 <handle_client+0x79>
	while (received > 0) {
  8000a5:	85 db                	test   %ebx,%ebx
  8000a7:	7e d3                	jle    80007c <handle_client+0x2e>
		if (write(sock, buffer, received) != received)
  8000a9:	83 ec 04             	sub    $0x4,%esp
  8000ac:	53                   	push   %ebx
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	e8 00 15 00 00       	call   8015b4 <write>
  8000b4:	83 c4 10             	add    $0x10,%esp
  8000b7:	39 d8                	cmp    %ebx,%eax
  8000b9:	74 d5                	je     800090 <handle_client+0x42>
			die("Failed to send bytes to client");
  8000bb:	b8 60 27 80 00       	mov    $0x802760,%eax
  8000c0:	e8 6e ff ff ff       	call   800033 <die>
  8000c5:	eb c9                	jmp    800090 <handle_client+0x42>
			die("Failed to receive additional bytes from client");
  8000c7:	b8 80 27 80 00       	mov    $0x802780,%eax
  8000cc:	e8 62 ff ff ff       	call   800033 <die>
  8000d1:	eb d2                	jmp    8000a5 <handle_client+0x57>

008000d3 <umain>:

void
umain(int argc, char **argv)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 40             	sub    $0x40,%esp
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8000dc:	6a 06                	push   $0x6
  8000de:	6a 01                	push   $0x1
  8000e0:	6a 02                	push   $0x2
  8000e2:	e8 f0 1a 00 00       	call   801bd7 <socket>
  8000e7:	89 c6                	mov    %eax,%esi
  8000e9:	83 c4 10             	add    $0x10,%esp
  8000ec:	85 c0                	test   %eax,%eax
  8000ee:	0f 88 86 00 00 00    	js     80017a <umain+0xa7>
		die("Failed to create socket");

	cprintf("opened socket\n");
  8000f4:	83 ec 0c             	sub    $0xc,%esp
  8000f7:	68 f8 26 80 00       	push   $0x8026f8
  8000fc:	e8 dd 04 00 00       	call   8005de <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  800101:	83 c4 0c             	add    $0xc,%esp
  800104:	6a 10                	push   $0x10
  800106:	6a 00                	push   $0x0
  800108:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  80010b:	53                   	push   %ebx
  80010c:	e8 f7 0b 00 00       	call   800d08 <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  800111:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = htonl(INADDR_ANY);   // IP address
  800115:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80011c:	e8 8a 01 00 00       	call   8002ab <htonl>
  800121:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  800124:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80012b:	e8 61 01 00 00       	call   800291 <htons>
  800130:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to bind\n");
  800134:	c7 04 24 07 27 80 00 	movl   $0x802707,(%esp)
  80013b:	e8 9e 04 00 00       	call   8005de <cprintf>

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &echoserver,
  800140:	83 c4 0c             	add    $0xc,%esp
  800143:	6a 10                	push   $0x10
  800145:	53                   	push   %ebx
  800146:	56                   	push   %esi
  800147:	e8 f9 19 00 00       	call   801b45 <bind>
  80014c:	83 c4 10             	add    $0x10,%esp
  80014f:	85 c0                	test   %eax,%eax
  800151:	78 36                	js     800189 <umain+0xb6>
		 sizeof(echoserver)) < 0) {
		die("Failed to bind the server socket");
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  800153:	83 ec 08             	sub    $0x8,%esp
  800156:	6a 05                	push   $0x5
  800158:	56                   	push   %esi
  800159:	e8 56 1a 00 00       	call   801bb4 <listen>
  80015e:	83 c4 10             	add    $0x10,%esp
  800161:	85 c0                	test   %eax,%eax
  800163:	78 30                	js     800195 <umain+0xc2>
		die("Failed to listen on server socket");

	cprintf("bound\n");
  800165:	83 ec 0c             	sub    $0xc,%esp
  800168:	68 17 27 80 00       	push   $0x802717
  80016d:	e8 6c 04 00 00       	call   8005de <cprintf>
  800172:	83 c4 10             	add    $0x10,%esp
	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
		// Wait for client connection
		if ((clientsock =
		     accept(serversock, (struct sockaddr *) &echoclient,
  800175:	8d 7d c4             	lea    -0x3c(%ebp),%edi
  800178:	eb 55                	jmp    8001cf <umain+0xfc>
		die("Failed to create socket");
  80017a:	b8 e0 26 80 00       	mov    $0x8026e0,%eax
  80017f:	e8 af fe ff ff       	call   800033 <die>
  800184:	e9 6b ff ff ff       	jmp    8000f4 <umain+0x21>
		die("Failed to bind the server socket");
  800189:	b8 b0 27 80 00       	mov    $0x8027b0,%eax
  80018e:	e8 a0 fe ff ff       	call   800033 <die>
  800193:	eb be                	jmp    800153 <umain+0x80>
		die("Failed to listen on server socket");
  800195:	b8 d4 27 80 00       	mov    $0x8027d4,%eax
  80019a:	e8 94 fe ff ff       	call   800033 <die>
  80019f:	eb c4                	jmp    800165 <umain+0x92>
			    &clientlen)) < 0) {
			die("Failed to accept client connection");
  8001a1:	b8 f8 27 80 00       	mov    $0x8027f8,%eax
  8001a6:	e8 88 fe ff ff       	call   800033 <die>
		}
		cprintf("Client connected: %s\n", inet_ntoa(echoclient.sin_addr));
  8001ab:	83 ec 0c             	sub    $0xc,%esp
  8001ae:	ff 75 cc             	push   -0x34(%ebp)
  8001b1:	e8 39 00 00 00       	call   8001ef <inet_ntoa>
  8001b6:	83 c4 08             	add    $0x8,%esp
  8001b9:	50                   	push   %eax
  8001ba:	68 1e 27 80 00       	push   $0x80271e
  8001bf:	e8 1a 04 00 00       	call   8005de <cprintf>
		handle_client(clientsock);
  8001c4:	89 1c 24             	mov    %ebx,(%esp)
  8001c7:	e8 82 fe ff ff       	call   80004e <handle_client>
	while (1) {
  8001cc:	83 c4 10             	add    $0x10,%esp
		unsigned int clientlen = sizeof(echoclient);
  8001cf:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		     accept(serversock, (struct sockaddr *) &echoclient,
  8001d6:	83 ec 04             	sub    $0x4,%esp
  8001d9:	57                   	push   %edi
  8001da:	8d 45 c8             	lea    -0x38(%ebp),%eax
  8001dd:	50                   	push   %eax
  8001de:	56                   	push   %esi
  8001df:	e8 32 19 00 00       	call   801b16 <accept>
  8001e4:	89 c3                	mov    %eax,%ebx
		if ((clientsock =
  8001e6:	83 c4 10             	add    $0x10,%esp
  8001e9:	85 c0                	test   %eax,%eax
  8001eb:	78 b4                	js     8001a1 <umain+0xce>
  8001ed:	eb bc                	jmp    8001ab <umain+0xd8>

008001ef <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 1c             	sub    $0x1c,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8001f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8001fe:	c6 45 db 00          	movb   $0x0,-0x25(%ebp)
  ap = (u8_t *)&s_addr;
  800202:	8d 75 f0             	lea    -0x10(%ebp),%esi
  rp = str;
  800205:	c7 45 dc 00 40 80 00 	movl   $0x804000,-0x24(%ebp)
  80020c:	eb 32                	jmp    800240 <inet_ntoa+0x51>
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
  80020e:	0f b6 c8             	movzbl %al,%ecx
  800211:	0f b6 4c 0d ed       	movzbl -0x13(%ebp,%ecx,1),%ecx
  800216:	88 0a                	mov    %cl,(%edx)
  800218:	83 c2 01             	add    $0x1,%edx
    while(i--)
  80021b:	83 e8 01             	sub    $0x1,%eax
  80021e:	3c ff                	cmp    $0xff,%al
  800220:	75 ec                	jne    80020e <inet_ntoa+0x1f>
  800222:	0f b6 db             	movzbl %bl,%ebx
  800225:	03 5d dc             	add    -0x24(%ebp),%ebx
    *rp++ = '.';
  800228:	8d 43 01             	lea    0x1(%ebx),%eax
  80022b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80022e:	c6 03 2e             	movb   $0x2e,(%ebx)
  800231:	83 c6 01             	add    $0x1,%esi
  for(n = 0; n < 4; n++) {
  800234:	80 45 db 01          	addb   $0x1,-0x25(%ebp)
  800238:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  80023c:	3c 04                	cmp    $0x4,%al
  80023e:	74 41                	je     800281 <inet_ntoa+0x92>
  rp = str;
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
      rem = *ap % (u8_t)10;
  800245:	0f b6 16             	movzbl (%esi),%edx
      *ap /= (u8_t)10;
  800248:	b8 cd ff ff ff       	mov    $0xffffffcd,%eax
  80024d:	f6 e2                	mul    %dl
  80024f:	66 c1 e8 0b          	shr    $0xb,%ax
  800253:	88 06                	mov    %al,(%esi)
  800255:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  800257:	83 c3 01             	add    $0x1,%ebx
  80025a:	0f b6 f9             	movzbl %cl,%edi
  80025d:	89 7d e0             	mov    %edi,-0x20(%ebp)
      rem = *ap % (u8_t)10;
  800260:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800263:	01 c0                	add    %eax,%eax
  800265:	89 d1                	mov    %edx,%ecx
  800267:	29 c1                	sub    %eax,%ecx
  800269:	89 cf                	mov    %ecx,%edi
      inv[i++] = '0' + rem;
  80026b:	8d 47 30             	lea    0x30(%edi),%eax
  80026e:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800271:	88 44 3d ed          	mov    %al,-0x13(%ebp,%edi,1)
    } while(*ap);
  800275:	80 fa 09             	cmp    $0x9,%dl
  800278:	77 cb                	ja     800245 <inet_ntoa+0x56>
  80027a:	8b 55 dc             	mov    -0x24(%ebp),%edx
      inv[i++] = '0' + rem;
  80027d:	89 d8                	mov    %ebx,%eax
  80027f:	eb 9a                	jmp    80021b <inet_ntoa+0x2c>
    ap++;
  }
  *--rp = 0;
  800281:	c6 03 00             	movb   $0x0,(%ebx)
  return str;
}
  800284:	b8 00 40 80 00       	mov    $0x804000,%eax
  800289:	83 c4 1c             	add    $0x1c,%esp
  80028c:	5b                   	pop    %ebx
  80028d:	5e                   	pop    %esi
  80028e:	5f                   	pop    %edi
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800294:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800298:	66 c1 c0 08          	rol    $0x8,%ax
}
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    

0080029e <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8002a1:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8002a5:	66 c1 c0 08          	rol    $0x8,%ax
  return htons(n);
}
  8002a9:	5d                   	pop    %ebp
  8002aa:	c3                   	ret    

008002ab <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  8002b1:	89 d0                	mov    %edx,%eax
  8002b3:	c1 e0 18             	shl    $0x18,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  8002b6:	89 d1                	mov    %edx,%ecx
  8002b8:	c1 e9 18             	shr    $0x18,%ecx
    ((n & 0xff0000UL) >> 8) |
  8002bb:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  8002bd:	89 d1                	mov    %edx,%ecx
  8002bf:	c1 e1 08             	shl    $0x8,%ecx
  8002c2:	81 e1 00 00 ff 00    	and    $0xff0000,%ecx
    ((n & 0xff0000UL) >> 8) |
  8002c8:	09 c8                	or     %ecx,%eax
  8002ca:	c1 ea 08             	shr    $0x8,%edx
  8002cd:	81 e2 00 ff 00 00    	and    $0xff00,%edx
  8002d3:	09 d0                	or     %edx,%eax
}
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <inet_aton>:
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	57                   	push   %edi
  8002db:	56                   	push   %esi
  8002dc:	53                   	push   %ebx
  8002dd:	83 ec 2c             	sub    $0x2c,%esp
  8002e0:	8b 55 08             	mov    0x8(%ebp),%edx
  c = *cp;
  8002e3:	0f be 02             	movsbl (%edx),%eax
  u32_t *pp = parts;
  8002e6:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8002e9:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8002ec:	e9 a6 00 00 00       	jmp    800397 <inet_aton+0xc0>
      c = *++cp;
  8002f1:	0f b6 42 01          	movzbl 0x1(%edx),%eax
      if (c == 'x' || c == 'X') {
  8002f5:	89 c1                	mov    %eax,%ecx
  8002f7:	83 e1 df             	and    $0xffffffdf,%ecx
  8002fa:	80 f9 58             	cmp    $0x58,%cl
  8002fd:	74 10                	je     80030f <inet_aton+0x38>
      c = *++cp;
  8002ff:	83 c2 01             	add    $0x1,%edx
  800302:	0f be c0             	movsbl %al,%eax
        base = 8;
  800305:	be 08 00 00 00       	mov    $0x8,%esi
  80030a:	e9 a2 00 00 00       	jmp    8003b1 <inet_aton+0xda>
        c = *++cp;
  80030f:	0f be 42 02          	movsbl 0x2(%edx),%eax
  800313:	8d 52 02             	lea    0x2(%edx),%edx
        base = 16;
  800316:	be 10 00 00 00       	mov    $0x10,%esi
  80031b:	e9 91 00 00 00       	jmp    8003b1 <inet_aton+0xda>
        val = (val * base) + (int)(c - '0');
  800320:	0f af fe             	imul   %esi,%edi
  800323:	8d 7c 38 d0          	lea    -0x30(%eax,%edi,1),%edi
        c = *++cp;
  800327:	0f be 02             	movsbl (%edx),%eax
  80032a:	83 c2 01             	add    $0x1,%edx
  80032d:	8d 5a ff             	lea    -0x1(%edx),%ebx
      if (isdigit(c)) {
  800330:	88 45 d7             	mov    %al,-0x29(%ebp)
  800333:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800336:	80 f9 09             	cmp    $0x9,%cl
  800339:	76 e5                	jbe    800320 <inet_aton+0x49>
      } else if (base == 16 && isxdigit(c)) {
  80033b:	83 fe 10             	cmp    $0x10,%esi
  80033e:	75 34                	jne    800374 <inet_aton+0x9d>
  800340:	0f b6 4d d7          	movzbl -0x29(%ebp),%ecx
  800344:	83 e9 61             	sub    $0x61,%ecx
  800347:	88 4d d6             	mov    %cl,-0x2a(%ebp)
  80034a:	0f b6 4d d7          	movzbl -0x29(%ebp),%ecx
  80034e:	83 e1 df             	and    $0xffffffdf,%ecx
  800351:	83 e9 41             	sub    $0x41,%ecx
  800354:	80 f9 05             	cmp    $0x5,%cl
  800357:	77 1b                	ja     800374 <inet_aton+0x9d>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800359:	c1 e7 04             	shl    $0x4,%edi
  80035c:	83 c0 0a             	add    $0xa,%eax
  80035f:	80 7d d6 1a          	cmpb   $0x1a,-0x2a(%ebp)
  800363:	19 c9                	sbb    %ecx,%ecx
  800365:	83 e1 20             	and    $0x20,%ecx
  800368:	83 c1 41             	add    $0x41,%ecx
  80036b:	29 c8                	sub    %ecx,%eax
  80036d:	09 c7                	or     %eax,%edi
        c = *++cp;
  80036f:	0f be 02             	movsbl (%edx),%eax
  800372:	eb b6                	jmp    80032a <inet_aton+0x53>
    if (c == '.') {
  800374:	83 f8 2e             	cmp    $0x2e,%eax
  800377:	75 45                	jne    8003be <inet_aton+0xe7>
      if (pp >= parts + 3)
  800379:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80037c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80037f:	39 c6                	cmp    %eax,%esi
  800381:	0f 84 1b 01 00 00    	je     8004a2 <inet_aton+0x1cb>
      *pp++ = val;
  800387:	83 c6 04             	add    $0x4,%esi
  80038a:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80038d:	89 7e fc             	mov    %edi,-0x4(%esi)
      c = *++cp;
  800390:	8d 53 01             	lea    0x1(%ebx),%edx
  800393:	0f be 43 01          	movsbl 0x1(%ebx),%eax
    if (!isdigit(c))
  800397:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80039a:	80 f9 09             	cmp    $0x9,%cl
  80039d:	0f 87 f8 00 00 00    	ja     80049b <inet_aton+0x1c4>
    base = 10;
  8003a3:	be 0a 00 00 00       	mov    $0xa,%esi
    if (c == '0') {
  8003a8:	83 f8 30             	cmp    $0x30,%eax
  8003ab:	0f 84 40 ff ff ff    	je     8002f1 <inet_aton+0x1a>
  8003b1:	83 c2 01             	add    $0x1,%edx
        base = 8;
  8003b4:	bf 00 00 00 00       	mov    $0x0,%edi
  8003b9:	e9 6f ff ff ff       	jmp    80032d <inet_aton+0x56>
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003be:	0f b6 75 d7          	movzbl -0x29(%ebp),%esi
  8003c2:	85 c0                	test   %eax,%eax
  8003c4:	74 29                	je     8003ef <inet_aton+0x118>
    return (0);
  8003c6:	ba 00 00 00 00       	mov    $0x0,%edx
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003cb:	89 f3                	mov    %esi,%ebx
  8003cd:	80 fb 1f             	cmp    $0x1f,%bl
  8003d0:	0f 86 d1 00 00 00    	jbe    8004a7 <inet_aton+0x1d0>
  8003d6:	84 c0                	test   %al,%al
  8003d8:	0f 88 c9 00 00 00    	js     8004a7 <inet_aton+0x1d0>
  8003de:	83 f8 20             	cmp    $0x20,%eax
  8003e1:	74 0c                	je     8003ef <inet_aton+0x118>
  8003e3:	83 e8 09             	sub    $0x9,%eax
  8003e6:	83 f8 04             	cmp    $0x4,%eax
  8003e9:	0f 87 b8 00 00 00    	ja     8004a7 <inet_aton+0x1d0>
  n = pp - parts + 1;
  8003ef:	8d 55 d8             	lea    -0x28(%ebp),%edx
  8003f2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003f5:	29 d0                	sub    %edx,%eax
  8003f7:	c1 f8 02             	sar    $0x2,%eax
  8003fa:	8d 50 01             	lea    0x1(%eax),%edx
  switch (n) {
  8003fd:	83 f8 02             	cmp    $0x2,%eax
  800400:	74 7a                	je     80047c <inet_aton+0x1a5>
  800402:	83 fa 03             	cmp    $0x3,%edx
  800405:	7f 49                	jg     800450 <inet_aton+0x179>
  800407:	85 d2                	test   %edx,%edx
  800409:	0f 84 98 00 00 00    	je     8004a7 <inet_aton+0x1d0>
  80040f:	83 fa 02             	cmp    $0x2,%edx
  800412:	75 19                	jne    80042d <inet_aton+0x156>
      return (0);
  800414:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xffffffUL)
  800419:	81 ff ff ff ff 00    	cmp    $0xffffff,%edi
  80041f:	0f 87 82 00 00 00    	ja     8004a7 <inet_aton+0x1d0>
    val |= parts[0] << 24;
  800425:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800428:	c1 e0 18             	shl    $0x18,%eax
  80042b:	09 c7                	or     %eax,%edi
  return (1);
  80042d:	ba 01 00 00 00       	mov    $0x1,%edx
  if (addr)
  800432:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800436:	74 6f                	je     8004a7 <inet_aton+0x1d0>
    addr->s_addr = htonl(val);
  800438:	83 ec 0c             	sub    $0xc,%esp
  80043b:	57                   	push   %edi
  80043c:	e8 6a fe ff ff       	call   8002ab <htonl>
  800441:	83 c4 10             	add    $0x10,%esp
  800444:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800447:	89 03                	mov    %eax,(%ebx)
  return (1);
  800449:	ba 01 00 00 00       	mov    $0x1,%edx
  80044e:	eb 57                	jmp    8004a7 <inet_aton+0x1d0>
  switch (n) {
  800450:	83 fa 04             	cmp    $0x4,%edx
  800453:	75 d8                	jne    80042d <inet_aton+0x156>
      return (0);
  800455:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xff)
  80045a:	81 ff ff 00 00 00    	cmp    $0xff,%edi
  800460:	77 45                	ja     8004a7 <inet_aton+0x1d0>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  800462:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800465:	c1 e0 18             	shl    $0x18,%eax
  800468:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80046b:	c1 e2 10             	shl    $0x10,%edx
  80046e:	09 d0                	or     %edx,%eax
  800470:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800473:	c1 e2 08             	shl    $0x8,%edx
  800476:	09 d0                	or     %edx,%eax
  800478:	09 c7                	or     %eax,%edi
    break;
  80047a:	eb b1                	jmp    80042d <inet_aton+0x156>
      return (0);
  80047c:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xffff)
  800481:	81 ff ff ff 00 00    	cmp    $0xffff,%edi
  800487:	77 1e                	ja     8004a7 <inet_aton+0x1d0>
    val |= (parts[0] << 24) | (parts[1] << 16);
  800489:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80048c:	c1 e0 18             	shl    $0x18,%eax
  80048f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800492:	c1 e2 10             	shl    $0x10,%edx
  800495:	09 d0                	or     %edx,%eax
  800497:	09 c7                	or     %eax,%edi
    break;
  800499:	eb 92                	jmp    80042d <inet_aton+0x156>
      return (0);
  80049b:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a0:	eb 05                	jmp    8004a7 <inet_aton+0x1d0>
        return (0);
  8004a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004a7:	89 d0                	mov    %edx,%eax
  8004a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ac:	5b                   	pop    %ebx
  8004ad:	5e                   	pop    %esi
  8004ae:	5f                   	pop    %edi
  8004af:	5d                   	pop    %ebp
  8004b0:	c3                   	ret    

008004b1 <inet_addr>:
{
  8004b1:	55                   	push   %ebp
  8004b2:	89 e5                	mov    %esp,%ebp
  8004b4:	83 ec 20             	sub    $0x20,%esp
  if (inet_aton(cp, &val)) {
  8004b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ba:	50                   	push   %eax
  8004bb:	ff 75 08             	push   0x8(%ebp)
  8004be:	e8 14 fe ff ff       	call   8002d7 <inet_aton>
  8004c3:	83 c4 10             	add    $0x10,%esp
    return (val.s_addr);
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004cd:	0f 45 45 f4          	cmovne -0xc(%ebp),%eax
}
  8004d1:	c9                   	leave  
  8004d2:	c3                   	ret    

008004d3 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8004d3:	55                   	push   %ebp
  8004d4:	89 e5                	mov    %esp,%ebp
  8004d6:	83 ec 14             	sub    $0x14,%esp
  return htonl(n);
  8004d9:	ff 75 08             	push   0x8(%ebp)
  8004dc:	e8 ca fd ff ff       	call   8002ab <htonl>
  8004e1:	83 c4 10             	add    $0x10,%esp
}
  8004e4:	c9                   	leave  
  8004e5:	c3                   	ret    

008004e6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	56                   	push   %esi
  8004ea:	53                   	push   %ebx
  8004eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004ee:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8004f1:	e8 80 0a 00 00       	call   800f76 <sys_getenvid>
  8004f6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004fb:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800501:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800506:	a3 10 40 80 00       	mov    %eax,0x804010

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80050b:	85 db                	test   %ebx,%ebx
  80050d:	7e 07                	jle    800516 <libmain+0x30>
		binaryname = argv[0];
  80050f:	8b 06                	mov    (%esi),%eax
  800511:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	56                   	push   %esi
  80051a:	53                   	push   %ebx
  80051b:	e8 b3 fb ff ff       	call   8000d3 <umain>

	// exit gracefully
	exit();
  800520:	e8 0a 00 00 00       	call   80052f <exit>
}
  800525:	83 c4 10             	add    $0x10,%esp
  800528:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80052b:	5b                   	pop    %ebx
  80052c:	5e                   	pop    %esi
  80052d:	5d                   	pop    %ebp
  80052e:	c3                   	ret    

0080052f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80052f:	55                   	push   %ebp
  800530:	89 e5                	mov    %esp,%ebp
  800532:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800535:	e8 9d 0e 00 00       	call   8013d7 <close_all>
	sys_env_destroy(0);
  80053a:	83 ec 0c             	sub    $0xc,%esp
  80053d:	6a 00                	push   $0x0
  80053f:	e8 f1 09 00 00       	call   800f35 <sys_env_destroy>
}
  800544:	83 c4 10             	add    $0x10,%esp
  800547:	c9                   	leave  
  800548:	c3                   	ret    

00800549 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800549:	55                   	push   %ebp
  80054a:	89 e5                	mov    %esp,%ebp
  80054c:	53                   	push   %ebx
  80054d:	83 ec 04             	sub    $0x4,%esp
  800550:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800553:	8b 13                	mov    (%ebx),%edx
  800555:	8d 42 01             	lea    0x1(%edx),%eax
  800558:	89 03                	mov    %eax,(%ebx)
  80055a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80055d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800561:	3d ff 00 00 00       	cmp    $0xff,%eax
  800566:	74 09                	je     800571 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800568:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80056c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056f:	c9                   	leave  
  800570:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	68 ff 00 00 00       	push   $0xff
  800579:	8d 43 08             	lea    0x8(%ebx),%eax
  80057c:	50                   	push   %eax
  80057d:	e8 76 09 00 00       	call   800ef8 <sys_cputs>
		b->idx = 0;
  800582:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800588:	83 c4 10             	add    $0x10,%esp
  80058b:	eb db                	jmp    800568 <putch+0x1f>

0080058d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80058d:	55                   	push   %ebp
  80058e:	89 e5                	mov    %esp,%ebp
  800590:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800596:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80059d:	00 00 00 
	b.cnt = 0;
  8005a0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005a7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005aa:	ff 75 0c             	push   0xc(%ebp)
  8005ad:	ff 75 08             	push   0x8(%ebp)
  8005b0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005b6:	50                   	push   %eax
  8005b7:	68 49 05 80 00       	push   $0x800549
  8005bc:	e8 14 01 00 00       	call   8006d5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005c1:	83 c4 08             	add    $0x8,%esp
  8005c4:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8005ca:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005d0:	50                   	push   %eax
  8005d1:	e8 22 09 00 00       	call   800ef8 <sys_cputs>

	return b.cnt;
}
  8005d6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005dc:	c9                   	leave  
  8005dd:	c3                   	ret    

008005de <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005de:	55                   	push   %ebp
  8005df:	89 e5                	mov    %esp,%ebp
  8005e1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005e4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005e7:	50                   	push   %eax
  8005e8:	ff 75 08             	push   0x8(%ebp)
  8005eb:	e8 9d ff ff ff       	call   80058d <vcprintf>
	va_end(ap);

	return cnt;
}
  8005f0:	c9                   	leave  
  8005f1:	c3                   	ret    

008005f2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005f2:	55                   	push   %ebp
  8005f3:	89 e5                	mov    %esp,%ebp
  8005f5:	57                   	push   %edi
  8005f6:	56                   	push   %esi
  8005f7:	53                   	push   %ebx
  8005f8:	83 ec 1c             	sub    $0x1c,%esp
  8005fb:	89 c7                	mov    %eax,%edi
  8005fd:	89 d6                	mov    %edx,%esi
  8005ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800602:	8b 55 0c             	mov    0xc(%ebp),%edx
  800605:	89 d1                	mov    %edx,%ecx
  800607:	89 c2                	mov    %eax,%edx
  800609:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80060f:	8b 45 10             	mov    0x10(%ebp),%eax
  800612:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800615:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800618:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80061f:	39 c2                	cmp    %eax,%edx
  800621:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800624:	72 3e                	jb     800664 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800626:	83 ec 0c             	sub    $0xc,%esp
  800629:	ff 75 18             	push   0x18(%ebp)
  80062c:	83 eb 01             	sub    $0x1,%ebx
  80062f:	53                   	push   %ebx
  800630:	50                   	push   %eax
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	ff 75 e4             	push   -0x1c(%ebp)
  800637:	ff 75 e0             	push   -0x20(%ebp)
  80063a:	ff 75 dc             	push   -0x24(%ebp)
  80063d:	ff 75 d8             	push   -0x28(%ebp)
  800640:	e8 5b 1e 00 00       	call   8024a0 <__udivdi3>
  800645:	83 c4 18             	add    $0x18,%esp
  800648:	52                   	push   %edx
  800649:	50                   	push   %eax
  80064a:	89 f2                	mov    %esi,%edx
  80064c:	89 f8                	mov    %edi,%eax
  80064e:	e8 9f ff ff ff       	call   8005f2 <printnum>
  800653:	83 c4 20             	add    $0x20,%esp
  800656:	eb 13                	jmp    80066b <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	56                   	push   %esi
  80065c:	ff 75 18             	push   0x18(%ebp)
  80065f:	ff d7                	call   *%edi
  800661:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800664:	83 eb 01             	sub    $0x1,%ebx
  800667:	85 db                	test   %ebx,%ebx
  800669:	7f ed                	jg     800658 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	56                   	push   %esi
  80066f:	83 ec 04             	sub    $0x4,%esp
  800672:	ff 75 e4             	push   -0x1c(%ebp)
  800675:	ff 75 e0             	push   -0x20(%ebp)
  800678:	ff 75 dc             	push   -0x24(%ebp)
  80067b:	ff 75 d8             	push   -0x28(%ebp)
  80067e:	e8 3d 1f 00 00       	call   8025c0 <__umoddi3>
  800683:	83 c4 14             	add    $0x14,%esp
  800686:	0f be 80 25 28 80 00 	movsbl 0x802825(%eax),%eax
  80068d:	50                   	push   %eax
  80068e:	ff d7                	call   *%edi
}
  800690:	83 c4 10             	add    $0x10,%esp
  800693:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800696:	5b                   	pop    %ebx
  800697:	5e                   	pop    %esi
  800698:	5f                   	pop    %edi
  800699:	5d                   	pop    %ebp
  80069a:	c3                   	ret    

0080069b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80069b:	55                   	push   %ebp
  80069c:	89 e5                	mov    %esp,%ebp
  80069e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006a1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006a5:	8b 10                	mov    (%eax),%edx
  8006a7:	3b 50 04             	cmp    0x4(%eax),%edx
  8006aa:	73 0a                	jae    8006b6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006ac:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006af:	89 08                	mov    %ecx,(%eax)
  8006b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b4:	88 02                	mov    %al,(%edx)
}
  8006b6:	5d                   	pop    %ebp
  8006b7:	c3                   	ret    

008006b8 <printfmt>:
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8006be:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006c1:	50                   	push   %eax
  8006c2:	ff 75 10             	push   0x10(%ebp)
  8006c5:	ff 75 0c             	push   0xc(%ebp)
  8006c8:	ff 75 08             	push   0x8(%ebp)
  8006cb:	e8 05 00 00 00       	call   8006d5 <vprintfmt>
}
  8006d0:	83 c4 10             	add    $0x10,%esp
  8006d3:	c9                   	leave  
  8006d4:	c3                   	ret    

008006d5 <vprintfmt>:
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	57                   	push   %edi
  8006d9:	56                   	push   %esi
  8006da:	53                   	push   %ebx
  8006db:	83 ec 3c             	sub    $0x3c,%esp
  8006de:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006e7:	eb 0a                	jmp    8006f3 <vprintfmt+0x1e>
			putch(ch, putdat);
  8006e9:	83 ec 08             	sub    $0x8,%esp
  8006ec:	53                   	push   %ebx
  8006ed:	50                   	push   %eax
  8006ee:	ff d6                	call   *%esi
  8006f0:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f3:	83 c7 01             	add    $0x1,%edi
  8006f6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006fa:	83 f8 25             	cmp    $0x25,%eax
  8006fd:	74 0c                	je     80070b <vprintfmt+0x36>
			if (ch == '\0')
  8006ff:	85 c0                	test   %eax,%eax
  800701:	75 e6                	jne    8006e9 <vprintfmt+0x14>
}
  800703:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800706:	5b                   	pop    %ebx
  800707:	5e                   	pop    %esi
  800708:	5f                   	pop    %edi
  800709:	5d                   	pop    %ebp
  80070a:	c3                   	ret    
		padc = ' ';
  80070b:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80070f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800716:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80071d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800724:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800729:	8d 47 01             	lea    0x1(%edi),%eax
  80072c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80072f:	0f b6 17             	movzbl (%edi),%edx
  800732:	8d 42 dd             	lea    -0x23(%edx),%eax
  800735:	3c 55                	cmp    $0x55,%al
  800737:	0f 87 bb 03 00 00    	ja     800af8 <vprintfmt+0x423>
  80073d:	0f b6 c0             	movzbl %al,%eax
  800740:	ff 24 85 60 29 80 00 	jmp    *0x802960(,%eax,4)
  800747:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80074a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80074e:	eb d9                	jmp    800729 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800750:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800753:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800757:	eb d0                	jmp    800729 <vprintfmt+0x54>
  800759:	0f b6 d2             	movzbl %dl,%edx
  80075c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80075f:	b8 00 00 00 00       	mov    $0x0,%eax
  800764:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800767:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80076a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80076e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800771:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800774:	83 f9 09             	cmp    $0x9,%ecx
  800777:	77 55                	ja     8007ce <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800779:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80077c:	eb e9                	jmp    800767 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80077e:	8b 45 14             	mov    0x14(%ebp),%eax
  800781:	8b 00                	mov    (%eax),%eax
  800783:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8d 40 04             	lea    0x4(%eax),%eax
  80078c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80078f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800792:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800796:	79 91                	jns    800729 <vprintfmt+0x54>
				width = precision, precision = -1;
  800798:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80079b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80079e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8007a5:	eb 82                	jmp    800729 <vprintfmt+0x54>
  8007a7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007aa:	85 d2                	test   %edx,%edx
  8007ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b1:	0f 49 c2             	cmovns %edx,%eax
  8007b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8007b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8007ba:	e9 6a ff ff ff       	jmp    800729 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8007bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8007c2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8007c9:	e9 5b ff ff ff       	jmp    800729 <vprintfmt+0x54>
  8007ce:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8007d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d4:	eb bc                	jmp    800792 <vprintfmt+0xbd>
			lflag++;
  8007d6:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8007d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8007dc:	e9 48 ff ff ff       	jmp    800729 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8007e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e4:	8d 78 04             	lea    0x4(%eax),%edi
  8007e7:	83 ec 08             	sub    $0x8,%esp
  8007ea:	53                   	push   %ebx
  8007eb:	ff 30                	push   (%eax)
  8007ed:	ff d6                	call   *%esi
			break;
  8007ef:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8007f2:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8007f5:	e9 9d 02 00 00       	jmp    800a97 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8d 78 04             	lea    0x4(%eax),%edi
  800800:	8b 10                	mov    (%eax),%edx
  800802:	89 d0                	mov    %edx,%eax
  800804:	f7 d8                	neg    %eax
  800806:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800809:	83 f8 0f             	cmp    $0xf,%eax
  80080c:	7f 23                	jg     800831 <vprintfmt+0x15c>
  80080e:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  800815:	85 d2                	test   %edx,%edx
  800817:	74 18                	je     800831 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800819:	52                   	push   %edx
  80081a:	68 f5 2b 80 00       	push   $0x802bf5
  80081f:	53                   	push   %ebx
  800820:	56                   	push   %esi
  800821:	e8 92 fe ff ff       	call   8006b8 <printfmt>
  800826:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800829:	89 7d 14             	mov    %edi,0x14(%ebp)
  80082c:	e9 66 02 00 00       	jmp    800a97 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800831:	50                   	push   %eax
  800832:	68 3d 28 80 00       	push   $0x80283d
  800837:	53                   	push   %ebx
  800838:	56                   	push   %esi
  800839:	e8 7a fe ff ff       	call   8006b8 <printfmt>
  80083e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800841:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800844:	e9 4e 02 00 00       	jmp    800a97 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800849:	8b 45 14             	mov    0x14(%ebp),%eax
  80084c:	83 c0 04             	add    $0x4,%eax
  80084f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800852:	8b 45 14             	mov    0x14(%ebp),%eax
  800855:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800857:	85 d2                	test   %edx,%edx
  800859:	b8 36 28 80 00       	mov    $0x802836,%eax
  80085e:	0f 45 c2             	cmovne %edx,%eax
  800861:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800864:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800868:	7e 06                	jle    800870 <vprintfmt+0x19b>
  80086a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80086e:	75 0d                	jne    80087d <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800870:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800873:	89 c7                	mov    %eax,%edi
  800875:	03 45 e0             	add    -0x20(%ebp),%eax
  800878:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80087b:	eb 55                	jmp    8008d2 <vprintfmt+0x1fd>
  80087d:	83 ec 08             	sub    $0x8,%esp
  800880:	ff 75 d8             	push   -0x28(%ebp)
  800883:	ff 75 cc             	push   -0x34(%ebp)
  800886:	e8 0a 03 00 00       	call   800b95 <strnlen>
  80088b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80088e:	29 c1                	sub    %eax,%ecx
  800890:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800898:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80089c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80089f:	eb 0f                	jmp    8008b0 <vprintfmt+0x1db>
					putch(padc, putdat);
  8008a1:	83 ec 08             	sub    $0x8,%esp
  8008a4:	53                   	push   %ebx
  8008a5:	ff 75 e0             	push   -0x20(%ebp)
  8008a8:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8008aa:	83 ef 01             	sub    $0x1,%edi
  8008ad:	83 c4 10             	add    $0x10,%esp
  8008b0:	85 ff                	test   %edi,%edi
  8008b2:	7f ed                	jg     8008a1 <vprintfmt+0x1cc>
  8008b4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8008b7:	85 d2                	test   %edx,%edx
  8008b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008be:	0f 49 c2             	cmovns %edx,%eax
  8008c1:	29 c2                	sub    %eax,%edx
  8008c3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8008c6:	eb a8                	jmp    800870 <vprintfmt+0x19b>
					putch(ch, putdat);
  8008c8:	83 ec 08             	sub    $0x8,%esp
  8008cb:	53                   	push   %ebx
  8008cc:	52                   	push   %edx
  8008cd:	ff d6                	call   *%esi
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008d5:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008d7:	83 c7 01             	add    $0x1,%edi
  8008da:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008de:	0f be d0             	movsbl %al,%edx
  8008e1:	85 d2                	test   %edx,%edx
  8008e3:	74 4b                	je     800930 <vprintfmt+0x25b>
  8008e5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008e9:	78 06                	js     8008f1 <vprintfmt+0x21c>
  8008eb:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8008ef:	78 1e                	js     80090f <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8008f1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8008f5:	74 d1                	je     8008c8 <vprintfmt+0x1f3>
  8008f7:	0f be c0             	movsbl %al,%eax
  8008fa:	83 e8 20             	sub    $0x20,%eax
  8008fd:	83 f8 5e             	cmp    $0x5e,%eax
  800900:	76 c6                	jbe    8008c8 <vprintfmt+0x1f3>
					putch('?', putdat);
  800902:	83 ec 08             	sub    $0x8,%esp
  800905:	53                   	push   %ebx
  800906:	6a 3f                	push   $0x3f
  800908:	ff d6                	call   *%esi
  80090a:	83 c4 10             	add    $0x10,%esp
  80090d:	eb c3                	jmp    8008d2 <vprintfmt+0x1fd>
  80090f:	89 cf                	mov    %ecx,%edi
  800911:	eb 0e                	jmp    800921 <vprintfmt+0x24c>
				putch(' ', putdat);
  800913:	83 ec 08             	sub    $0x8,%esp
  800916:	53                   	push   %ebx
  800917:	6a 20                	push   $0x20
  800919:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80091b:	83 ef 01             	sub    $0x1,%edi
  80091e:	83 c4 10             	add    $0x10,%esp
  800921:	85 ff                	test   %edi,%edi
  800923:	7f ee                	jg     800913 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800925:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800928:	89 45 14             	mov    %eax,0x14(%ebp)
  80092b:	e9 67 01 00 00       	jmp    800a97 <vprintfmt+0x3c2>
  800930:	89 cf                	mov    %ecx,%edi
  800932:	eb ed                	jmp    800921 <vprintfmt+0x24c>
	if (lflag >= 2)
  800934:	83 f9 01             	cmp    $0x1,%ecx
  800937:	7f 1b                	jg     800954 <vprintfmt+0x27f>
	else if (lflag)
  800939:	85 c9                	test   %ecx,%ecx
  80093b:	74 63                	je     8009a0 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80093d:	8b 45 14             	mov    0x14(%ebp),%eax
  800940:	8b 00                	mov    (%eax),%eax
  800942:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800945:	99                   	cltd   
  800946:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800949:	8b 45 14             	mov    0x14(%ebp),%eax
  80094c:	8d 40 04             	lea    0x4(%eax),%eax
  80094f:	89 45 14             	mov    %eax,0x14(%ebp)
  800952:	eb 17                	jmp    80096b <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800954:	8b 45 14             	mov    0x14(%ebp),%eax
  800957:	8b 50 04             	mov    0x4(%eax),%edx
  80095a:	8b 00                	mov    (%eax),%eax
  80095c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80095f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800962:	8b 45 14             	mov    0x14(%ebp),%eax
  800965:	8d 40 08             	lea    0x8(%eax),%eax
  800968:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80096b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80096e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800971:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800976:	85 c9                	test   %ecx,%ecx
  800978:	0f 89 ff 00 00 00    	jns    800a7d <vprintfmt+0x3a8>
				putch('-', putdat);
  80097e:	83 ec 08             	sub    $0x8,%esp
  800981:	53                   	push   %ebx
  800982:	6a 2d                	push   $0x2d
  800984:	ff d6                	call   *%esi
				num = -(long long) num;
  800986:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800989:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80098c:	f7 da                	neg    %edx
  80098e:	83 d1 00             	adc    $0x0,%ecx
  800991:	f7 d9                	neg    %ecx
  800993:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800996:	bf 0a 00 00 00       	mov    $0xa,%edi
  80099b:	e9 dd 00 00 00       	jmp    800a7d <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8009a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a3:	8b 00                	mov    (%eax),%eax
  8009a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009a8:	99                   	cltd   
  8009a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8009ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8009af:	8d 40 04             	lea    0x4(%eax),%eax
  8009b2:	89 45 14             	mov    %eax,0x14(%ebp)
  8009b5:	eb b4                	jmp    80096b <vprintfmt+0x296>
	if (lflag >= 2)
  8009b7:	83 f9 01             	cmp    $0x1,%ecx
  8009ba:	7f 1e                	jg     8009da <vprintfmt+0x305>
	else if (lflag)
  8009bc:	85 c9                	test   %ecx,%ecx
  8009be:	74 32                	je     8009f2 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8009c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c3:	8b 10                	mov    (%eax),%edx
  8009c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009ca:	8d 40 04             	lea    0x4(%eax),%eax
  8009cd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009d0:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8009d5:	e9 a3 00 00 00       	jmp    800a7d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8009da:	8b 45 14             	mov    0x14(%ebp),%eax
  8009dd:	8b 10                	mov    (%eax),%edx
  8009df:	8b 48 04             	mov    0x4(%eax),%ecx
  8009e2:	8d 40 08             	lea    0x8(%eax),%eax
  8009e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009e8:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8009ed:	e9 8b 00 00 00       	jmp    800a7d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8009f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f5:	8b 10                	mov    (%eax),%edx
  8009f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009fc:	8d 40 04             	lea    0x4(%eax),%eax
  8009ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800a02:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800a07:	eb 74                	jmp    800a7d <vprintfmt+0x3a8>
	if (lflag >= 2)
  800a09:	83 f9 01             	cmp    $0x1,%ecx
  800a0c:	7f 1b                	jg     800a29 <vprintfmt+0x354>
	else if (lflag)
  800a0e:	85 c9                	test   %ecx,%ecx
  800a10:	74 2c                	je     800a3e <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800a12:	8b 45 14             	mov    0x14(%ebp),%eax
  800a15:	8b 10                	mov    (%eax),%edx
  800a17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a1c:	8d 40 04             	lea    0x4(%eax),%eax
  800a1f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a22:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800a27:	eb 54                	jmp    800a7d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800a29:	8b 45 14             	mov    0x14(%ebp),%eax
  800a2c:	8b 10                	mov    (%eax),%edx
  800a2e:	8b 48 04             	mov    0x4(%eax),%ecx
  800a31:	8d 40 08             	lea    0x8(%eax),%eax
  800a34:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a37:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800a3c:	eb 3f                	jmp    800a7d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800a3e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a41:	8b 10                	mov    (%eax),%edx
  800a43:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a48:	8d 40 04             	lea    0x4(%eax),%eax
  800a4b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a4e:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800a53:	eb 28                	jmp    800a7d <vprintfmt+0x3a8>
			putch('0', putdat);
  800a55:	83 ec 08             	sub    $0x8,%esp
  800a58:	53                   	push   %ebx
  800a59:	6a 30                	push   $0x30
  800a5b:	ff d6                	call   *%esi
			putch('x', putdat);
  800a5d:	83 c4 08             	add    $0x8,%esp
  800a60:	53                   	push   %ebx
  800a61:	6a 78                	push   $0x78
  800a63:	ff d6                	call   *%esi
			num = (unsigned long long)
  800a65:	8b 45 14             	mov    0x14(%ebp),%eax
  800a68:	8b 10                	mov    (%eax),%edx
  800a6a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800a6f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800a72:	8d 40 04             	lea    0x4(%eax),%eax
  800a75:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a78:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800a7d:	83 ec 0c             	sub    $0xc,%esp
  800a80:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800a84:	50                   	push   %eax
  800a85:	ff 75 e0             	push   -0x20(%ebp)
  800a88:	57                   	push   %edi
  800a89:	51                   	push   %ecx
  800a8a:	52                   	push   %edx
  800a8b:	89 da                	mov    %ebx,%edx
  800a8d:	89 f0                	mov    %esi,%eax
  800a8f:	e8 5e fb ff ff       	call   8005f2 <printnum>
			break;
  800a94:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800a97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a9a:	e9 54 fc ff ff       	jmp    8006f3 <vprintfmt+0x1e>
	if (lflag >= 2)
  800a9f:	83 f9 01             	cmp    $0x1,%ecx
  800aa2:	7f 1b                	jg     800abf <vprintfmt+0x3ea>
	else if (lflag)
  800aa4:	85 c9                	test   %ecx,%ecx
  800aa6:	74 2c                	je     800ad4 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800aa8:	8b 45 14             	mov    0x14(%ebp),%eax
  800aab:	8b 10                	mov    (%eax),%edx
  800aad:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab2:	8d 40 04             	lea    0x4(%eax),%eax
  800ab5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ab8:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800abd:	eb be                	jmp    800a7d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800abf:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac2:	8b 10                	mov    (%eax),%edx
  800ac4:	8b 48 04             	mov    0x4(%eax),%ecx
  800ac7:	8d 40 08             	lea    0x8(%eax),%eax
  800aca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800acd:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800ad2:	eb a9                	jmp    800a7d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800ad4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad7:	8b 10                	mov    (%eax),%edx
  800ad9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ade:	8d 40 04             	lea    0x4(%eax),%eax
  800ae1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ae4:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800ae9:	eb 92                	jmp    800a7d <vprintfmt+0x3a8>
			putch(ch, putdat);
  800aeb:	83 ec 08             	sub    $0x8,%esp
  800aee:	53                   	push   %ebx
  800aef:	6a 25                	push   $0x25
  800af1:	ff d6                	call   *%esi
			break;
  800af3:	83 c4 10             	add    $0x10,%esp
  800af6:	eb 9f                	jmp    800a97 <vprintfmt+0x3c2>
			putch('%', putdat);
  800af8:	83 ec 08             	sub    $0x8,%esp
  800afb:	53                   	push   %ebx
  800afc:	6a 25                	push   $0x25
  800afe:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b00:	83 c4 10             	add    $0x10,%esp
  800b03:	89 f8                	mov    %edi,%eax
  800b05:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800b09:	74 05                	je     800b10 <vprintfmt+0x43b>
  800b0b:	83 e8 01             	sub    $0x1,%eax
  800b0e:	eb f5                	jmp    800b05 <vprintfmt+0x430>
  800b10:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b13:	eb 82                	jmp    800a97 <vprintfmt+0x3c2>

00800b15 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	83 ec 18             	sub    $0x18,%esp
  800b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b21:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b24:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b28:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b2b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b32:	85 c0                	test   %eax,%eax
  800b34:	74 26                	je     800b5c <vsnprintf+0x47>
  800b36:	85 d2                	test   %edx,%edx
  800b38:	7e 22                	jle    800b5c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b3a:	ff 75 14             	push   0x14(%ebp)
  800b3d:	ff 75 10             	push   0x10(%ebp)
  800b40:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b43:	50                   	push   %eax
  800b44:	68 9b 06 80 00       	push   $0x80069b
  800b49:	e8 87 fb ff ff       	call   8006d5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b51:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b57:	83 c4 10             	add    $0x10,%esp
}
  800b5a:	c9                   	leave  
  800b5b:	c3                   	ret    
		return -E_INVAL;
  800b5c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b61:	eb f7                	jmp    800b5a <vsnprintf+0x45>

00800b63 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b69:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b6c:	50                   	push   %eax
  800b6d:	ff 75 10             	push   0x10(%ebp)
  800b70:	ff 75 0c             	push   0xc(%ebp)
  800b73:	ff 75 08             	push   0x8(%ebp)
  800b76:	e8 9a ff ff ff       	call   800b15 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    

00800b7d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
  800b88:	eb 03                	jmp    800b8d <strlen+0x10>
		n++;
  800b8a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800b8d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b91:	75 f7                	jne    800b8a <strlen+0xd>
	return n;
}
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b9b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba3:	eb 03                	jmp    800ba8 <strnlen+0x13>
		n++;
  800ba5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ba8:	39 d0                	cmp    %edx,%eax
  800baa:	74 08                	je     800bb4 <strnlen+0x1f>
  800bac:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800bb0:	75 f3                	jne    800ba5 <strnlen+0x10>
  800bb2:	89 c2                	mov    %eax,%edx
	return n;
}
  800bb4:	89 d0                	mov    %edx,%eax
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	53                   	push   %ebx
  800bbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc7:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800bcb:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800bce:	83 c0 01             	add    $0x1,%eax
  800bd1:	84 d2                	test   %dl,%dl
  800bd3:	75 f2                	jne    800bc7 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bd5:	89 c8                	mov    %ecx,%eax
  800bd7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bda:	c9                   	leave  
  800bdb:	c3                   	ret    

00800bdc <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	53                   	push   %ebx
  800be0:	83 ec 10             	sub    $0x10,%esp
  800be3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800be6:	53                   	push   %ebx
  800be7:	e8 91 ff ff ff       	call   800b7d <strlen>
  800bec:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800bef:	ff 75 0c             	push   0xc(%ebp)
  800bf2:	01 d8                	add    %ebx,%eax
  800bf4:	50                   	push   %eax
  800bf5:	e8 be ff ff ff       	call   800bb8 <strcpy>
	return dst;
}
  800bfa:	89 d8                	mov    %ebx,%eax
  800bfc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bff:	c9                   	leave  
  800c00:	c3                   	ret    

00800c01 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	8b 75 08             	mov    0x8(%ebp),%esi
  800c09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c0c:	89 f3                	mov    %esi,%ebx
  800c0e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c11:	89 f0                	mov    %esi,%eax
  800c13:	eb 0f                	jmp    800c24 <strncpy+0x23>
		*dst++ = *src;
  800c15:	83 c0 01             	add    $0x1,%eax
  800c18:	0f b6 0a             	movzbl (%edx),%ecx
  800c1b:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c1e:	80 f9 01             	cmp    $0x1,%cl
  800c21:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800c24:	39 d8                	cmp    %ebx,%eax
  800c26:	75 ed                	jne    800c15 <strncpy+0x14>
	}
	return ret;
}
  800c28:	89 f0                	mov    %esi,%eax
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	8b 75 08             	mov    0x8(%ebp),%esi
  800c36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c39:	8b 55 10             	mov    0x10(%ebp),%edx
  800c3c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c3e:	85 d2                	test   %edx,%edx
  800c40:	74 21                	je     800c63 <strlcpy+0x35>
  800c42:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c46:	89 f2                	mov    %esi,%edx
  800c48:	eb 09                	jmp    800c53 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c4a:	83 c1 01             	add    $0x1,%ecx
  800c4d:	83 c2 01             	add    $0x1,%edx
  800c50:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800c53:	39 c2                	cmp    %eax,%edx
  800c55:	74 09                	je     800c60 <strlcpy+0x32>
  800c57:	0f b6 19             	movzbl (%ecx),%ebx
  800c5a:	84 db                	test   %bl,%bl
  800c5c:	75 ec                	jne    800c4a <strlcpy+0x1c>
  800c5e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800c60:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c63:	29 f0                	sub    %esi,%eax
}
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c72:	eb 06                	jmp    800c7a <strcmp+0x11>
		p++, q++;
  800c74:	83 c1 01             	add    $0x1,%ecx
  800c77:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800c7a:	0f b6 01             	movzbl (%ecx),%eax
  800c7d:	84 c0                	test   %al,%al
  800c7f:	74 04                	je     800c85 <strcmp+0x1c>
  800c81:	3a 02                	cmp    (%edx),%al
  800c83:	74 ef                	je     800c74 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c85:	0f b6 c0             	movzbl %al,%eax
  800c88:	0f b6 12             	movzbl (%edx),%edx
  800c8b:	29 d0                	sub    %edx,%eax
}
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	53                   	push   %ebx
  800c93:	8b 45 08             	mov    0x8(%ebp),%eax
  800c96:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c99:	89 c3                	mov    %eax,%ebx
  800c9b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c9e:	eb 06                	jmp    800ca6 <strncmp+0x17>
		n--, p++, q++;
  800ca0:	83 c0 01             	add    $0x1,%eax
  800ca3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ca6:	39 d8                	cmp    %ebx,%eax
  800ca8:	74 18                	je     800cc2 <strncmp+0x33>
  800caa:	0f b6 08             	movzbl (%eax),%ecx
  800cad:	84 c9                	test   %cl,%cl
  800caf:	74 04                	je     800cb5 <strncmp+0x26>
  800cb1:	3a 0a                	cmp    (%edx),%cl
  800cb3:	74 eb                	je     800ca0 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cb5:	0f b6 00             	movzbl (%eax),%eax
  800cb8:	0f b6 12             	movzbl (%edx),%edx
  800cbb:	29 d0                	sub    %edx,%eax
}
  800cbd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cc0:	c9                   	leave  
  800cc1:	c3                   	ret    
		return 0;
  800cc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc7:	eb f4                	jmp    800cbd <strncmp+0x2e>

00800cc9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cd3:	eb 03                	jmp    800cd8 <strchr+0xf>
  800cd5:	83 c0 01             	add    $0x1,%eax
  800cd8:	0f b6 10             	movzbl (%eax),%edx
  800cdb:	84 d2                	test   %dl,%dl
  800cdd:	74 06                	je     800ce5 <strchr+0x1c>
		if (*s == c)
  800cdf:	38 ca                	cmp    %cl,%dl
  800ce1:	75 f2                	jne    800cd5 <strchr+0xc>
  800ce3:	eb 05                	jmp    800cea <strchr+0x21>
			return (char *) s;
	return 0;
  800ce5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cf6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800cf9:	38 ca                	cmp    %cl,%dl
  800cfb:	74 09                	je     800d06 <strfind+0x1a>
  800cfd:	84 d2                	test   %dl,%dl
  800cff:	74 05                	je     800d06 <strfind+0x1a>
	for (; *s; s++)
  800d01:	83 c0 01             	add    $0x1,%eax
  800d04:	eb f0                	jmp    800cf6 <strfind+0xa>
			break;
	return (char *) s;
}
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d11:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d14:	85 c9                	test   %ecx,%ecx
  800d16:	74 2f                	je     800d47 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d18:	89 f8                	mov    %edi,%eax
  800d1a:	09 c8                	or     %ecx,%eax
  800d1c:	a8 03                	test   $0x3,%al
  800d1e:	75 21                	jne    800d41 <memset+0x39>
		c &= 0xFF;
  800d20:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d24:	89 d0                	mov    %edx,%eax
  800d26:	c1 e0 08             	shl    $0x8,%eax
  800d29:	89 d3                	mov    %edx,%ebx
  800d2b:	c1 e3 18             	shl    $0x18,%ebx
  800d2e:	89 d6                	mov    %edx,%esi
  800d30:	c1 e6 10             	shl    $0x10,%esi
  800d33:	09 f3                	or     %esi,%ebx
  800d35:	09 da                	or     %ebx,%edx
  800d37:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d39:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800d3c:	fc                   	cld    
  800d3d:	f3 ab                	rep stos %eax,%es:(%edi)
  800d3f:	eb 06                	jmp    800d47 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d44:	fc                   	cld    
  800d45:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d47:	89 f8                	mov    %edi,%eax
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	8b 45 08             	mov    0x8(%ebp),%eax
  800d56:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d59:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d5c:	39 c6                	cmp    %eax,%esi
  800d5e:	73 32                	jae    800d92 <memmove+0x44>
  800d60:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d63:	39 c2                	cmp    %eax,%edx
  800d65:	76 2b                	jbe    800d92 <memmove+0x44>
		s += n;
		d += n;
  800d67:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d6a:	89 d6                	mov    %edx,%esi
  800d6c:	09 fe                	or     %edi,%esi
  800d6e:	09 ce                	or     %ecx,%esi
  800d70:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d76:	75 0e                	jne    800d86 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d78:	83 ef 04             	sub    $0x4,%edi
  800d7b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d7e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d81:	fd                   	std    
  800d82:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d84:	eb 09                	jmp    800d8f <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d86:	83 ef 01             	sub    $0x1,%edi
  800d89:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d8c:	fd                   	std    
  800d8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d8f:	fc                   	cld    
  800d90:	eb 1a                	jmp    800dac <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d92:	89 f2                	mov    %esi,%edx
  800d94:	09 c2                	or     %eax,%edx
  800d96:	09 ca                	or     %ecx,%edx
  800d98:	f6 c2 03             	test   $0x3,%dl
  800d9b:	75 0a                	jne    800da7 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d9d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800da0:	89 c7                	mov    %eax,%edi
  800da2:	fc                   	cld    
  800da3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800da5:	eb 05                	jmp    800dac <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800da7:	89 c7                	mov    %eax,%edi
  800da9:	fc                   	cld    
  800daa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    

00800db0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800db6:	ff 75 10             	push   0x10(%ebp)
  800db9:	ff 75 0c             	push   0xc(%ebp)
  800dbc:	ff 75 08             	push   0x8(%ebp)
  800dbf:	e8 8a ff ff ff       	call   800d4e <memmove>
}
  800dc4:	c9                   	leave  
  800dc5:	c3                   	ret    

00800dc6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
  800dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dce:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd1:	89 c6                	mov    %eax,%esi
  800dd3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dd6:	eb 06                	jmp    800dde <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800dd8:	83 c0 01             	add    $0x1,%eax
  800ddb:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800dde:	39 f0                	cmp    %esi,%eax
  800de0:	74 14                	je     800df6 <memcmp+0x30>
		if (*s1 != *s2)
  800de2:	0f b6 08             	movzbl (%eax),%ecx
  800de5:	0f b6 1a             	movzbl (%edx),%ebx
  800de8:	38 d9                	cmp    %bl,%cl
  800dea:	74 ec                	je     800dd8 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800dec:	0f b6 c1             	movzbl %cl,%eax
  800def:	0f b6 db             	movzbl %bl,%ebx
  800df2:	29 d8                	sub    %ebx,%eax
  800df4:	eb 05                	jmp    800dfb <memcmp+0x35>
	}

	return 0;
  800df6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	8b 45 08             	mov    0x8(%ebp),%eax
  800e05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e08:	89 c2                	mov    %eax,%edx
  800e0a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e0d:	eb 03                	jmp    800e12 <memfind+0x13>
  800e0f:	83 c0 01             	add    $0x1,%eax
  800e12:	39 d0                	cmp    %edx,%eax
  800e14:	73 04                	jae    800e1a <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e16:	38 08                	cmp    %cl,(%eax)
  800e18:	75 f5                	jne    800e0f <memfind+0x10>
			break;
	return (void *) s;
}
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	57                   	push   %edi
  800e20:	56                   	push   %esi
  800e21:	53                   	push   %ebx
  800e22:	8b 55 08             	mov    0x8(%ebp),%edx
  800e25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e28:	eb 03                	jmp    800e2d <strtol+0x11>
		s++;
  800e2a:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800e2d:	0f b6 02             	movzbl (%edx),%eax
  800e30:	3c 20                	cmp    $0x20,%al
  800e32:	74 f6                	je     800e2a <strtol+0xe>
  800e34:	3c 09                	cmp    $0x9,%al
  800e36:	74 f2                	je     800e2a <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800e38:	3c 2b                	cmp    $0x2b,%al
  800e3a:	74 2a                	je     800e66 <strtol+0x4a>
	int neg = 0;
  800e3c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800e41:	3c 2d                	cmp    $0x2d,%al
  800e43:	74 2b                	je     800e70 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e45:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e4b:	75 0f                	jne    800e5c <strtol+0x40>
  800e4d:	80 3a 30             	cmpb   $0x30,(%edx)
  800e50:	74 28                	je     800e7a <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e52:	85 db                	test   %ebx,%ebx
  800e54:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e59:	0f 44 d8             	cmove  %eax,%ebx
  800e5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e61:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e64:	eb 46                	jmp    800eac <strtol+0x90>
		s++;
  800e66:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800e69:	bf 00 00 00 00       	mov    $0x0,%edi
  800e6e:	eb d5                	jmp    800e45 <strtol+0x29>
		s++, neg = 1;
  800e70:	83 c2 01             	add    $0x1,%edx
  800e73:	bf 01 00 00 00       	mov    $0x1,%edi
  800e78:	eb cb                	jmp    800e45 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e7a:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e7e:	74 0e                	je     800e8e <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800e80:	85 db                	test   %ebx,%ebx
  800e82:	75 d8                	jne    800e5c <strtol+0x40>
		s++, base = 8;
  800e84:	83 c2 01             	add    $0x1,%edx
  800e87:	bb 08 00 00 00       	mov    $0x8,%ebx
  800e8c:	eb ce                	jmp    800e5c <strtol+0x40>
		s += 2, base = 16;
  800e8e:	83 c2 02             	add    $0x2,%edx
  800e91:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e96:	eb c4                	jmp    800e5c <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800e98:	0f be c0             	movsbl %al,%eax
  800e9b:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e9e:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ea1:	7d 3a                	jge    800edd <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ea3:	83 c2 01             	add    $0x1,%edx
  800ea6:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800eaa:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800eac:	0f b6 02             	movzbl (%edx),%eax
  800eaf:	8d 70 d0             	lea    -0x30(%eax),%esi
  800eb2:	89 f3                	mov    %esi,%ebx
  800eb4:	80 fb 09             	cmp    $0x9,%bl
  800eb7:	76 df                	jbe    800e98 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800eb9:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ebc:	89 f3                	mov    %esi,%ebx
  800ebe:	80 fb 19             	cmp    $0x19,%bl
  800ec1:	77 08                	ja     800ecb <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ec3:	0f be c0             	movsbl %al,%eax
  800ec6:	83 e8 57             	sub    $0x57,%eax
  800ec9:	eb d3                	jmp    800e9e <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ecb:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ece:	89 f3                	mov    %esi,%ebx
  800ed0:	80 fb 19             	cmp    $0x19,%bl
  800ed3:	77 08                	ja     800edd <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ed5:	0f be c0             	movsbl %al,%eax
  800ed8:	83 e8 37             	sub    $0x37,%eax
  800edb:	eb c1                	jmp    800e9e <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800edd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ee1:	74 05                	je     800ee8 <strtol+0xcc>
		*endptr = (char *) s;
  800ee3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee6:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ee8:	89 c8                	mov    %ecx,%eax
  800eea:	f7 d8                	neg    %eax
  800eec:	85 ff                	test   %edi,%edi
  800eee:	0f 45 c8             	cmovne %eax,%ecx
}
  800ef1:	89 c8                	mov    %ecx,%eax
  800ef3:	5b                   	pop    %ebx
  800ef4:	5e                   	pop    %esi
  800ef5:	5f                   	pop    %edi
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	57                   	push   %edi
  800efc:	56                   	push   %esi
  800efd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800efe:	b8 00 00 00 00       	mov    $0x0,%eax
  800f03:	8b 55 08             	mov    0x8(%ebp),%edx
  800f06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f09:	89 c3                	mov    %eax,%ebx
  800f0b:	89 c7                	mov    %eax,%edi
  800f0d:	89 c6                	mov    %eax,%esi
  800f0f:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f11:	5b                   	pop    %ebx
  800f12:	5e                   	pop    %esi
  800f13:	5f                   	pop    %edi
  800f14:	5d                   	pop    %ebp
  800f15:	c3                   	ret    

00800f16 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	57                   	push   %edi
  800f1a:	56                   	push   %esi
  800f1b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f21:	b8 01 00 00 00       	mov    $0x1,%eax
  800f26:	89 d1                	mov    %edx,%ecx
  800f28:	89 d3                	mov    %edx,%ebx
  800f2a:	89 d7                	mov    %edx,%edi
  800f2c:	89 d6                	mov    %edx,%esi
  800f2e:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	57                   	push   %edi
  800f39:	56                   	push   %esi
  800f3a:	53                   	push   %ebx
  800f3b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f43:	8b 55 08             	mov    0x8(%ebp),%edx
  800f46:	b8 03 00 00 00       	mov    $0x3,%eax
  800f4b:	89 cb                	mov    %ecx,%ebx
  800f4d:	89 cf                	mov    %ecx,%edi
  800f4f:	89 ce                	mov    %ecx,%esi
  800f51:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f53:	85 c0                	test   %eax,%eax
  800f55:	7f 08                	jg     800f5f <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f5a:	5b                   	pop    %ebx
  800f5b:	5e                   	pop    %esi
  800f5c:	5f                   	pop    %edi
  800f5d:	5d                   	pop    %ebp
  800f5e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5f:	83 ec 0c             	sub    $0xc,%esp
  800f62:	50                   	push   %eax
  800f63:	6a 03                	push   $0x3
  800f65:	68 1f 2b 80 00       	push   $0x802b1f
  800f6a:	6a 2a                	push   $0x2a
  800f6c:	68 3c 2b 80 00       	push   $0x802b3c
  800f71:	e8 9e 13 00 00       	call   802314 <_panic>

00800f76 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	57                   	push   %edi
  800f7a:	56                   	push   %esi
  800f7b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f81:	b8 02 00 00 00       	mov    $0x2,%eax
  800f86:	89 d1                	mov    %edx,%ecx
  800f88:	89 d3                	mov    %edx,%ebx
  800f8a:	89 d7                	mov    %edx,%edi
  800f8c:	89 d6                	mov    %edx,%esi
  800f8e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f90:	5b                   	pop    %ebx
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    

00800f95 <sys_yield>:

void
sys_yield(void)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	57                   	push   %edi
  800f99:	56                   	push   %esi
  800f9a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fa5:	89 d1                	mov    %edx,%ecx
  800fa7:	89 d3                	mov    %edx,%ebx
  800fa9:	89 d7                	mov    %edx,%edi
  800fab:	89 d6                	mov    %edx,%esi
  800fad:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800faf:	5b                   	pop    %ebx
  800fb0:	5e                   	pop    %esi
  800fb1:	5f                   	pop    %edi
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    

00800fb4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	57                   	push   %edi
  800fb8:	56                   	push   %esi
  800fb9:	53                   	push   %ebx
  800fba:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fbd:	be 00 00 00 00       	mov    $0x0,%esi
  800fc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc8:	b8 04 00 00 00       	mov    $0x4,%eax
  800fcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fd0:	89 f7                	mov    %esi,%edi
  800fd2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	7f 08                	jg     800fe0 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fdb:	5b                   	pop    %ebx
  800fdc:	5e                   	pop    %esi
  800fdd:	5f                   	pop    %edi
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe0:	83 ec 0c             	sub    $0xc,%esp
  800fe3:	50                   	push   %eax
  800fe4:	6a 04                	push   $0x4
  800fe6:	68 1f 2b 80 00       	push   $0x802b1f
  800feb:	6a 2a                	push   $0x2a
  800fed:	68 3c 2b 80 00       	push   $0x802b3c
  800ff2:	e8 1d 13 00 00       	call   802314 <_panic>

00800ff7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	57                   	push   %edi
  800ffb:	56                   	push   %esi
  800ffc:	53                   	push   %ebx
  800ffd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801000:	8b 55 08             	mov    0x8(%ebp),%edx
  801003:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801006:	b8 05 00 00 00       	mov    $0x5,%eax
  80100b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80100e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801011:	8b 75 18             	mov    0x18(%ebp),%esi
  801014:	cd 30                	int    $0x30
	if(check && ret > 0)
  801016:	85 c0                	test   %eax,%eax
  801018:	7f 08                	jg     801022 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80101a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80101d:	5b                   	pop    %ebx
  80101e:	5e                   	pop    %esi
  80101f:	5f                   	pop    %edi
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801022:	83 ec 0c             	sub    $0xc,%esp
  801025:	50                   	push   %eax
  801026:	6a 05                	push   $0x5
  801028:	68 1f 2b 80 00       	push   $0x802b1f
  80102d:	6a 2a                	push   $0x2a
  80102f:	68 3c 2b 80 00       	push   $0x802b3c
  801034:	e8 db 12 00 00       	call   802314 <_panic>

00801039 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	57                   	push   %edi
  80103d:	56                   	push   %esi
  80103e:	53                   	push   %ebx
  80103f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801042:	bb 00 00 00 00       	mov    $0x0,%ebx
  801047:	8b 55 08             	mov    0x8(%ebp),%edx
  80104a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104d:	b8 06 00 00 00       	mov    $0x6,%eax
  801052:	89 df                	mov    %ebx,%edi
  801054:	89 de                	mov    %ebx,%esi
  801056:	cd 30                	int    $0x30
	if(check && ret > 0)
  801058:	85 c0                	test   %eax,%eax
  80105a:	7f 08                	jg     801064 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80105c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80105f:	5b                   	pop    %ebx
  801060:	5e                   	pop    %esi
  801061:	5f                   	pop    %edi
  801062:	5d                   	pop    %ebp
  801063:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801064:	83 ec 0c             	sub    $0xc,%esp
  801067:	50                   	push   %eax
  801068:	6a 06                	push   $0x6
  80106a:	68 1f 2b 80 00       	push   $0x802b1f
  80106f:	6a 2a                	push   $0x2a
  801071:	68 3c 2b 80 00       	push   $0x802b3c
  801076:	e8 99 12 00 00       	call   802314 <_panic>

0080107b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	57                   	push   %edi
  80107f:	56                   	push   %esi
  801080:	53                   	push   %ebx
  801081:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801084:	bb 00 00 00 00       	mov    $0x0,%ebx
  801089:	8b 55 08             	mov    0x8(%ebp),%edx
  80108c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80108f:	b8 08 00 00 00       	mov    $0x8,%eax
  801094:	89 df                	mov    %ebx,%edi
  801096:	89 de                	mov    %ebx,%esi
  801098:	cd 30                	int    $0x30
	if(check && ret > 0)
  80109a:	85 c0                	test   %eax,%eax
  80109c:	7f 08                	jg     8010a6 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80109e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5f                   	pop    %edi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8010a6:	83 ec 0c             	sub    $0xc,%esp
  8010a9:	50                   	push   %eax
  8010aa:	6a 08                	push   $0x8
  8010ac:	68 1f 2b 80 00       	push   $0x802b1f
  8010b1:	6a 2a                	push   $0x2a
  8010b3:	68 3c 2b 80 00       	push   $0x802b3c
  8010b8:	e8 57 12 00 00       	call   802314 <_panic>

008010bd <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	57                   	push   %edi
  8010c1:	56                   	push   %esi
  8010c2:	53                   	push   %ebx
  8010c3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d1:	b8 09 00 00 00       	mov    $0x9,%eax
  8010d6:	89 df                	mov    %ebx,%edi
  8010d8:	89 de                	mov    %ebx,%esi
  8010da:	cd 30                	int    $0x30
	if(check && ret > 0)
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	7f 08                	jg     8010e8 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e3:	5b                   	pop    %ebx
  8010e4:	5e                   	pop    %esi
  8010e5:	5f                   	pop    %edi
  8010e6:	5d                   	pop    %ebp
  8010e7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8010e8:	83 ec 0c             	sub    $0xc,%esp
  8010eb:	50                   	push   %eax
  8010ec:	6a 09                	push   $0x9
  8010ee:	68 1f 2b 80 00       	push   $0x802b1f
  8010f3:	6a 2a                	push   $0x2a
  8010f5:	68 3c 2b 80 00       	push   $0x802b3c
  8010fa:	e8 15 12 00 00       	call   802314 <_panic>

008010ff <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	57                   	push   %edi
  801103:	56                   	push   %esi
  801104:	53                   	push   %ebx
  801105:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801108:	bb 00 00 00 00       	mov    $0x0,%ebx
  80110d:	8b 55 08             	mov    0x8(%ebp),%edx
  801110:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801113:	b8 0a 00 00 00       	mov    $0xa,%eax
  801118:	89 df                	mov    %ebx,%edi
  80111a:	89 de                	mov    %ebx,%esi
  80111c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80111e:	85 c0                	test   %eax,%eax
  801120:	7f 08                	jg     80112a <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801122:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801125:	5b                   	pop    %ebx
  801126:	5e                   	pop    %esi
  801127:	5f                   	pop    %edi
  801128:	5d                   	pop    %ebp
  801129:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80112a:	83 ec 0c             	sub    $0xc,%esp
  80112d:	50                   	push   %eax
  80112e:	6a 0a                	push   $0xa
  801130:	68 1f 2b 80 00       	push   $0x802b1f
  801135:	6a 2a                	push   $0x2a
  801137:	68 3c 2b 80 00       	push   $0x802b3c
  80113c:	e8 d3 11 00 00       	call   802314 <_panic>

00801141 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	57                   	push   %edi
  801145:	56                   	push   %esi
  801146:	53                   	push   %ebx
	asm volatile("int %1\n"
  801147:	8b 55 08             	mov    0x8(%ebp),%edx
  80114a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114d:	b8 0c 00 00 00       	mov    $0xc,%eax
  801152:	be 00 00 00 00       	mov    $0x0,%esi
  801157:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80115a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80115d:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80115f:	5b                   	pop    %ebx
  801160:	5e                   	pop    %esi
  801161:	5f                   	pop    %edi
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	57                   	push   %edi
  801168:	56                   	push   %esi
  801169:	53                   	push   %ebx
  80116a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80116d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801172:	8b 55 08             	mov    0x8(%ebp),%edx
  801175:	b8 0d 00 00 00       	mov    $0xd,%eax
  80117a:	89 cb                	mov    %ecx,%ebx
  80117c:	89 cf                	mov    %ecx,%edi
  80117e:	89 ce                	mov    %ecx,%esi
  801180:	cd 30                	int    $0x30
	if(check && ret > 0)
  801182:	85 c0                	test   %eax,%eax
  801184:	7f 08                	jg     80118e <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801186:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801189:	5b                   	pop    %ebx
  80118a:	5e                   	pop    %esi
  80118b:	5f                   	pop    %edi
  80118c:	5d                   	pop    %ebp
  80118d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80118e:	83 ec 0c             	sub    $0xc,%esp
  801191:	50                   	push   %eax
  801192:	6a 0d                	push   $0xd
  801194:	68 1f 2b 80 00       	push   $0x802b1f
  801199:	6a 2a                	push   $0x2a
  80119b:	68 3c 2b 80 00       	push   $0x802b3c
  8011a0:	e8 6f 11 00 00       	call   802314 <_panic>

008011a5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	57                   	push   %edi
  8011a9:	56                   	push   %esi
  8011aa:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b0:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011b5:	89 d1                	mov    %edx,%ecx
  8011b7:	89 d3                	mov    %edx,%ebx
  8011b9:	89 d7                	mov    %edx,%edi
  8011bb:	89 d6                	mov    %edx,%esi
  8011bd:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8011bf:	5b                   	pop    %ebx
  8011c0:	5e                   	pop    %esi
  8011c1:	5f                   	pop    %edi
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	57                   	push   %edi
  8011c8:	56                   	push   %esi
  8011c9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d5:	b8 0f 00 00 00       	mov    $0xf,%eax
  8011da:	89 df                	mov    %ebx,%edi
  8011dc:	89 de                	mov    %ebx,%esi
  8011de:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  8011e0:	5b                   	pop    %ebx
  8011e1:	5e                   	pop    %esi
  8011e2:	5f                   	pop    %edi
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	57                   	push   %edi
  8011e9:	56                   	push   %esi
  8011ea:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f6:	b8 10 00 00 00       	mov    $0x10,%eax
  8011fb:	89 df                	mov    %ebx,%edi
  8011fd:	89 de                	mov    %ebx,%esi
  8011ff:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  801201:	5b                   	pop    %ebx
  801202:	5e                   	pop    %esi
  801203:	5f                   	pop    %edi
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    

00801206 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801209:	8b 45 08             	mov    0x8(%ebp),%eax
  80120c:	05 00 00 00 30       	add    $0x30000000,%eax
  801211:	c1 e8 0c             	shr    $0xc,%eax
}
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801219:	8b 45 08             	mov    0x8(%ebp),%eax
  80121c:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801221:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801226:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801235:	89 c2                	mov    %eax,%edx
  801237:	c1 ea 16             	shr    $0x16,%edx
  80123a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801241:	f6 c2 01             	test   $0x1,%dl
  801244:	74 29                	je     80126f <fd_alloc+0x42>
  801246:	89 c2                	mov    %eax,%edx
  801248:	c1 ea 0c             	shr    $0xc,%edx
  80124b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801252:	f6 c2 01             	test   $0x1,%dl
  801255:	74 18                	je     80126f <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801257:	05 00 10 00 00       	add    $0x1000,%eax
  80125c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801261:	75 d2                	jne    801235 <fd_alloc+0x8>
  801263:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801268:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80126d:	eb 05                	jmp    801274 <fd_alloc+0x47>
			return 0;
  80126f:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801274:	8b 55 08             	mov    0x8(%ebp),%edx
  801277:	89 02                	mov    %eax,(%edx)
}
  801279:	89 c8                	mov    %ecx,%eax
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    

0080127d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801283:	83 f8 1f             	cmp    $0x1f,%eax
  801286:	77 30                	ja     8012b8 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801288:	c1 e0 0c             	shl    $0xc,%eax
  80128b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801290:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801296:	f6 c2 01             	test   $0x1,%dl
  801299:	74 24                	je     8012bf <fd_lookup+0x42>
  80129b:	89 c2                	mov    %eax,%edx
  80129d:	c1 ea 0c             	shr    $0xc,%edx
  8012a0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a7:	f6 c2 01             	test   $0x1,%dl
  8012aa:	74 1a                	je     8012c6 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012af:	89 02                	mov    %eax,(%edx)
	return 0;
  8012b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012b6:	5d                   	pop    %ebp
  8012b7:	c3                   	ret    
		return -E_INVAL;
  8012b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012bd:	eb f7                	jmp    8012b6 <fd_lookup+0x39>
		return -E_INVAL;
  8012bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c4:	eb f0                	jmp    8012b6 <fd_lookup+0x39>
  8012c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012cb:	eb e9                	jmp    8012b6 <fd_lookup+0x39>

008012cd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	53                   	push   %ebx
  8012d1:	83 ec 04             	sub    $0x4,%esp
  8012d4:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8012dc:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8012e1:	39 13                	cmp    %edx,(%ebx)
  8012e3:	74 37                	je     80131c <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8012e5:	83 c0 01             	add    $0x1,%eax
  8012e8:	8b 1c 85 c8 2b 80 00 	mov    0x802bc8(,%eax,4),%ebx
  8012ef:	85 db                	test   %ebx,%ebx
  8012f1:	75 ee                	jne    8012e1 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012f3:	a1 10 40 80 00       	mov    0x804010,%eax
  8012f8:	8b 40 58             	mov    0x58(%eax),%eax
  8012fb:	83 ec 04             	sub    $0x4,%esp
  8012fe:	52                   	push   %edx
  8012ff:	50                   	push   %eax
  801300:	68 4c 2b 80 00       	push   $0x802b4c
  801305:	e8 d4 f2 ff ff       	call   8005de <cprintf>
	*dev = 0;
	return -E_INVAL;
  80130a:	83 c4 10             	add    $0x10,%esp
  80130d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801312:	8b 55 0c             	mov    0xc(%ebp),%edx
  801315:	89 1a                	mov    %ebx,(%edx)
}
  801317:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131a:	c9                   	leave  
  80131b:	c3                   	ret    
			return 0;
  80131c:	b8 00 00 00 00       	mov    $0x0,%eax
  801321:	eb ef                	jmp    801312 <dev_lookup+0x45>

00801323 <fd_close>:
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	57                   	push   %edi
  801327:	56                   	push   %esi
  801328:	53                   	push   %ebx
  801329:	83 ec 24             	sub    $0x24,%esp
  80132c:	8b 75 08             	mov    0x8(%ebp),%esi
  80132f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801332:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801335:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801336:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80133c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80133f:	50                   	push   %eax
  801340:	e8 38 ff ff ff       	call   80127d <fd_lookup>
  801345:	89 c3                	mov    %eax,%ebx
  801347:	83 c4 10             	add    $0x10,%esp
  80134a:	85 c0                	test   %eax,%eax
  80134c:	78 05                	js     801353 <fd_close+0x30>
	    || fd != fd2)
  80134e:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801351:	74 16                	je     801369 <fd_close+0x46>
		return (must_exist ? r : 0);
  801353:	89 f8                	mov    %edi,%eax
  801355:	84 c0                	test   %al,%al
  801357:	b8 00 00 00 00       	mov    $0x0,%eax
  80135c:	0f 44 d8             	cmove  %eax,%ebx
}
  80135f:	89 d8                	mov    %ebx,%eax
  801361:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801364:	5b                   	pop    %ebx
  801365:	5e                   	pop    %esi
  801366:	5f                   	pop    %edi
  801367:	5d                   	pop    %ebp
  801368:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801369:	83 ec 08             	sub    $0x8,%esp
  80136c:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80136f:	50                   	push   %eax
  801370:	ff 36                	push   (%esi)
  801372:	e8 56 ff ff ff       	call   8012cd <dev_lookup>
  801377:	89 c3                	mov    %eax,%ebx
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	85 c0                	test   %eax,%eax
  80137e:	78 1a                	js     80139a <fd_close+0x77>
		if (dev->dev_close)
  801380:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801383:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801386:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80138b:	85 c0                	test   %eax,%eax
  80138d:	74 0b                	je     80139a <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80138f:	83 ec 0c             	sub    $0xc,%esp
  801392:	56                   	push   %esi
  801393:	ff d0                	call   *%eax
  801395:	89 c3                	mov    %eax,%ebx
  801397:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80139a:	83 ec 08             	sub    $0x8,%esp
  80139d:	56                   	push   %esi
  80139e:	6a 00                	push   $0x0
  8013a0:	e8 94 fc ff ff       	call   801039 <sys_page_unmap>
	return r;
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	eb b5                	jmp    80135f <fd_close+0x3c>

008013aa <close>:

int
close(int fdnum)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b3:	50                   	push   %eax
  8013b4:	ff 75 08             	push   0x8(%ebp)
  8013b7:	e8 c1 fe ff ff       	call   80127d <fd_lookup>
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	79 02                	jns    8013c5 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    
		return fd_close(fd, 1);
  8013c5:	83 ec 08             	sub    $0x8,%esp
  8013c8:	6a 01                	push   $0x1
  8013ca:	ff 75 f4             	push   -0xc(%ebp)
  8013cd:	e8 51 ff ff ff       	call   801323 <fd_close>
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	eb ec                	jmp    8013c3 <close+0x19>

008013d7 <close_all>:

void
close_all(void)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	53                   	push   %ebx
  8013db:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013de:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013e3:	83 ec 0c             	sub    $0xc,%esp
  8013e6:	53                   	push   %ebx
  8013e7:	e8 be ff ff ff       	call   8013aa <close>
	for (i = 0; i < MAXFD; i++)
  8013ec:	83 c3 01             	add    $0x1,%ebx
  8013ef:	83 c4 10             	add    $0x10,%esp
  8013f2:	83 fb 20             	cmp    $0x20,%ebx
  8013f5:	75 ec                	jne    8013e3 <close_all+0xc>
}
  8013f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fa:	c9                   	leave  
  8013fb:	c3                   	ret    

008013fc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	57                   	push   %edi
  801400:	56                   	push   %esi
  801401:	53                   	push   %ebx
  801402:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801405:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801408:	50                   	push   %eax
  801409:	ff 75 08             	push   0x8(%ebp)
  80140c:	e8 6c fe ff ff       	call   80127d <fd_lookup>
  801411:	89 c3                	mov    %eax,%ebx
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	78 7f                	js     801499 <dup+0x9d>
		return r;
	close(newfdnum);
  80141a:	83 ec 0c             	sub    $0xc,%esp
  80141d:	ff 75 0c             	push   0xc(%ebp)
  801420:	e8 85 ff ff ff       	call   8013aa <close>

	newfd = INDEX2FD(newfdnum);
  801425:	8b 75 0c             	mov    0xc(%ebp),%esi
  801428:	c1 e6 0c             	shl    $0xc,%esi
  80142b:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801434:	89 3c 24             	mov    %edi,(%esp)
  801437:	e8 da fd ff ff       	call   801216 <fd2data>
  80143c:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80143e:	89 34 24             	mov    %esi,(%esp)
  801441:	e8 d0 fd ff ff       	call   801216 <fd2data>
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80144c:	89 d8                	mov    %ebx,%eax
  80144e:	c1 e8 16             	shr    $0x16,%eax
  801451:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801458:	a8 01                	test   $0x1,%al
  80145a:	74 11                	je     80146d <dup+0x71>
  80145c:	89 d8                	mov    %ebx,%eax
  80145e:	c1 e8 0c             	shr    $0xc,%eax
  801461:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801468:	f6 c2 01             	test   $0x1,%dl
  80146b:	75 36                	jne    8014a3 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80146d:	89 f8                	mov    %edi,%eax
  80146f:	c1 e8 0c             	shr    $0xc,%eax
  801472:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801479:	83 ec 0c             	sub    $0xc,%esp
  80147c:	25 07 0e 00 00       	and    $0xe07,%eax
  801481:	50                   	push   %eax
  801482:	56                   	push   %esi
  801483:	6a 00                	push   $0x0
  801485:	57                   	push   %edi
  801486:	6a 00                	push   $0x0
  801488:	e8 6a fb ff ff       	call   800ff7 <sys_page_map>
  80148d:	89 c3                	mov    %eax,%ebx
  80148f:	83 c4 20             	add    $0x20,%esp
  801492:	85 c0                	test   %eax,%eax
  801494:	78 33                	js     8014c9 <dup+0xcd>
		goto err;

	return newfdnum;
  801496:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801499:	89 d8                	mov    %ebx,%eax
  80149b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149e:	5b                   	pop    %ebx
  80149f:	5e                   	pop    %esi
  8014a0:	5f                   	pop    %edi
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014a3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014aa:	83 ec 0c             	sub    $0xc,%esp
  8014ad:	25 07 0e 00 00       	and    $0xe07,%eax
  8014b2:	50                   	push   %eax
  8014b3:	ff 75 d4             	push   -0x2c(%ebp)
  8014b6:	6a 00                	push   $0x0
  8014b8:	53                   	push   %ebx
  8014b9:	6a 00                	push   $0x0
  8014bb:	e8 37 fb ff ff       	call   800ff7 <sys_page_map>
  8014c0:	89 c3                	mov    %eax,%ebx
  8014c2:	83 c4 20             	add    $0x20,%esp
  8014c5:	85 c0                	test   %eax,%eax
  8014c7:	79 a4                	jns    80146d <dup+0x71>
	sys_page_unmap(0, newfd);
  8014c9:	83 ec 08             	sub    $0x8,%esp
  8014cc:	56                   	push   %esi
  8014cd:	6a 00                	push   $0x0
  8014cf:	e8 65 fb ff ff       	call   801039 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014d4:	83 c4 08             	add    $0x8,%esp
  8014d7:	ff 75 d4             	push   -0x2c(%ebp)
  8014da:	6a 00                	push   $0x0
  8014dc:	e8 58 fb ff ff       	call   801039 <sys_page_unmap>
	return r;
  8014e1:	83 c4 10             	add    $0x10,%esp
  8014e4:	eb b3                	jmp    801499 <dup+0x9d>

008014e6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	56                   	push   %esi
  8014ea:	53                   	push   %ebx
  8014eb:	83 ec 18             	sub    $0x18,%esp
  8014ee:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f4:	50                   	push   %eax
  8014f5:	56                   	push   %esi
  8014f6:	e8 82 fd ff ff       	call   80127d <fd_lookup>
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	85 c0                	test   %eax,%eax
  801500:	78 3c                	js     80153e <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801502:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801505:	83 ec 08             	sub    $0x8,%esp
  801508:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150b:	50                   	push   %eax
  80150c:	ff 33                	push   (%ebx)
  80150e:	e8 ba fd ff ff       	call   8012cd <dev_lookup>
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	85 c0                	test   %eax,%eax
  801518:	78 24                	js     80153e <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80151a:	8b 43 08             	mov    0x8(%ebx),%eax
  80151d:	83 e0 03             	and    $0x3,%eax
  801520:	83 f8 01             	cmp    $0x1,%eax
  801523:	74 20                	je     801545 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801525:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801528:	8b 40 08             	mov    0x8(%eax),%eax
  80152b:	85 c0                	test   %eax,%eax
  80152d:	74 37                	je     801566 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80152f:	83 ec 04             	sub    $0x4,%esp
  801532:	ff 75 10             	push   0x10(%ebp)
  801535:	ff 75 0c             	push   0xc(%ebp)
  801538:	53                   	push   %ebx
  801539:	ff d0                	call   *%eax
  80153b:	83 c4 10             	add    $0x10,%esp
}
  80153e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801541:	5b                   	pop    %ebx
  801542:	5e                   	pop    %esi
  801543:	5d                   	pop    %ebp
  801544:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801545:	a1 10 40 80 00       	mov    0x804010,%eax
  80154a:	8b 40 58             	mov    0x58(%eax),%eax
  80154d:	83 ec 04             	sub    $0x4,%esp
  801550:	56                   	push   %esi
  801551:	50                   	push   %eax
  801552:	68 8d 2b 80 00       	push   $0x802b8d
  801557:	e8 82 f0 ff ff       	call   8005de <cprintf>
		return -E_INVAL;
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801564:	eb d8                	jmp    80153e <read+0x58>
		return -E_NOT_SUPP;
  801566:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80156b:	eb d1                	jmp    80153e <read+0x58>

0080156d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80156d:	55                   	push   %ebp
  80156e:	89 e5                	mov    %esp,%ebp
  801570:	57                   	push   %edi
  801571:	56                   	push   %esi
  801572:	53                   	push   %ebx
  801573:	83 ec 0c             	sub    $0xc,%esp
  801576:	8b 7d 08             	mov    0x8(%ebp),%edi
  801579:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80157c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801581:	eb 02                	jmp    801585 <readn+0x18>
  801583:	01 c3                	add    %eax,%ebx
  801585:	39 f3                	cmp    %esi,%ebx
  801587:	73 21                	jae    8015aa <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801589:	83 ec 04             	sub    $0x4,%esp
  80158c:	89 f0                	mov    %esi,%eax
  80158e:	29 d8                	sub    %ebx,%eax
  801590:	50                   	push   %eax
  801591:	89 d8                	mov    %ebx,%eax
  801593:	03 45 0c             	add    0xc(%ebp),%eax
  801596:	50                   	push   %eax
  801597:	57                   	push   %edi
  801598:	e8 49 ff ff ff       	call   8014e6 <read>
		if (m < 0)
  80159d:	83 c4 10             	add    $0x10,%esp
  8015a0:	85 c0                	test   %eax,%eax
  8015a2:	78 04                	js     8015a8 <readn+0x3b>
			return m;
		if (m == 0)
  8015a4:	75 dd                	jne    801583 <readn+0x16>
  8015a6:	eb 02                	jmp    8015aa <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a8:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8015aa:	89 d8                	mov    %ebx,%eax
  8015ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015af:	5b                   	pop    %ebx
  8015b0:	5e                   	pop    %esi
  8015b1:	5f                   	pop    %edi
  8015b2:	5d                   	pop    %ebp
  8015b3:	c3                   	ret    

008015b4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	56                   	push   %esi
  8015b8:	53                   	push   %ebx
  8015b9:	83 ec 18             	sub    $0x18,%esp
  8015bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c2:	50                   	push   %eax
  8015c3:	53                   	push   %ebx
  8015c4:	e8 b4 fc ff ff       	call   80127d <fd_lookup>
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	78 37                	js     801607 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d0:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015d3:	83 ec 08             	sub    $0x8,%esp
  8015d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d9:	50                   	push   %eax
  8015da:	ff 36                	push   (%esi)
  8015dc:	e8 ec fc ff ff       	call   8012cd <dev_lookup>
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 1f                	js     801607 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015e8:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8015ec:	74 20                	je     80160e <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	74 37                	je     80162f <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015f8:	83 ec 04             	sub    $0x4,%esp
  8015fb:	ff 75 10             	push   0x10(%ebp)
  8015fe:	ff 75 0c             	push   0xc(%ebp)
  801601:	56                   	push   %esi
  801602:	ff d0                	call   *%eax
  801604:	83 c4 10             	add    $0x10,%esp
}
  801607:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80160a:	5b                   	pop    %ebx
  80160b:	5e                   	pop    %esi
  80160c:	5d                   	pop    %ebp
  80160d:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80160e:	a1 10 40 80 00       	mov    0x804010,%eax
  801613:	8b 40 58             	mov    0x58(%eax),%eax
  801616:	83 ec 04             	sub    $0x4,%esp
  801619:	53                   	push   %ebx
  80161a:	50                   	push   %eax
  80161b:	68 a9 2b 80 00       	push   $0x802ba9
  801620:	e8 b9 ef ff ff       	call   8005de <cprintf>
		return -E_INVAL;
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80162d:	eb d8                	jmp    801607 <write+0x53>
		return -E_NOT_SUPP;
  80162f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801634:	eb d1                	jmp    801607 <write+0x53>

00801636 <seek>:

int
seek(int fdnum, off_t offset)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80163c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163f:	50                   	push   %eax
  801640:	ff 75 08             	push   0x8(%ebp)
  801643:	e8 35 fc ff ff       	call   80127d <fd_lookup>
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	85 c0                	test   %eax,%eax
  80164d:	78 0e                	js     80165d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80164f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801652:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801655:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801658:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80165d:	c9                   	leave  
  80165e:	c3                   	ret    

0080165f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	56                   	push   %esi
  801663:	53                   	push   %ebx
  801664:	83 ec 18             	sub    $0x18,%esp
  801667:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80166a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80166d:	50                   	push   %eax
  80166e:	53                   	push   %ebx
  80166f:	e8 09 fc ff ff       	call   80127d <fd_lookup>
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	85 c0                	test   %eax,%eax
  801679:	78 34                	js     8016af <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167b:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80167e:	83 ec 08             	sub    $0x8,%esp
  801681:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801684:	50                   	push   %eax
  801685:	ff 36                	push   (%esi)
  801687:	e8 41 fc ff ff       	call   8012cd <dev_lookup>
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	85 c0                	test   %eax,%eax
  801691:	78 1c                	js     8016af <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801693:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801697:	74 1d                	je     8016b6 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801699:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169c:	8b 40 18             	mov    0x18(%eax),%eax
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	74 34                	je     8016d7 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016a3:	83 ec 08             	sub    $0x8,%esp
  8016a6:	ff 75 0c             	push   0xc(%ebp)
  8016a9:	56                   	push   %esi
  8016aa:	ff d0                	call   *%eax
  8016ac:	83 c4 10             	add    $0x10,%esp
}
  8016af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b2:	5b                   	pop    %ebx
  8016b3:	5e                   	pop    %esi
  8016b4:	5d                   	pop    %ebp
  8016b5:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016b6:	a1 10 40 80 00       	mov    0x804010,%eax
  8016bb:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016be:	83 ec 04             	sub    $0x4,%esp
  8016c1:	53                   	push   %ebx
  8016c2:	50                   	push   %eax
  8016c3:	68 6c 2b 80 00       	push   $0x802b6c
  8016c8:	e8 11 ef ff ff       	call   8005de <cprintf>
		return -E_INVAL;
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016d5:	eb d8                	jmp    8016af <ftruncate+0x50>
		return -E_NOT_SUPP;
  8016d7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016dc:	eb d1                	jmp    8016af <ftruncate+0x50>

008016de <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	56                   	push   %esi
  8016e2:	53                   	push   %ebx
  8016e3:	83 ec 18             	sub    $0x18,%esp
  8016e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ec:	50                   	push   %eax
  8016ed:	ff 75 08             	push   0x8(%ebp)
  8016f0:	e8 88 fb ff ff       	call   80127d <fd_lookup>
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	85 c0                	test   %eax,%eax
  8016fa:	78 49                	js     801745 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fc:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8016ff:	83 ec 08             	sub    $0x8,%esp
  801702:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801705:	50                   	push   %eax
  801706:	ff 36                	push   (%esi)
  801708:	e8 c0 fb ff ff       	call   8012cd <dev_lookup>
  80170d:	83 c4 10             	add    $0x10,%esp
  801710:	85 c0                	test   %eax,%eax
  801712:	78 31                	js     801745 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801714:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801717:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80171b:	74 2f                	je     80174c <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80171d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801720:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801727:	00 00 00 
	stat->st_isdir = 0;
  80172a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801731:	00 00 00 
	stat->st_dev = dev;
  801734:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80173a:	83 ec 08             	sub    $0x8,%esp
  80173d:	53                   	push   %ebx
  80173e:	56                   	push   %esi
  80173f:	ff 50 14             	call   *0x14(%eax)
  801742:	83 c4 10             	add    $0x10,%esp
}
  801745:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801748:	5b                   	pop    %ebx
  801749:	5e                   	pop    %esi
  80174a:	5d                   	pop    %ebp
  80174b:	c3                   	ret    
		return -E_NOT_SUPP;
  80174c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801751:	eb f2                	jmp    801745 <fstat+0x67>

00801753 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	56                   	push   %esi
  801757:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801758:	83 ec 08             	sub    $0x8,%esp
  80175b:	6a 00                	push   $0x0
  80175d:	ff 75 08             	push   0x8(%ebp)
  801760:	e8 e4 01 00 00       	call   801949 <open>
  801765:	89 c3                	mov    %eax,%ebx
  801767:	83 c4 10             	add    $0x10,%esp
  80176a:	85 c0                	test   %eax,%eax
  80176c:	78 1b                	js     801789 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80176e:	83 ec 08             	sub    $0x8,%esp
  801771:	ff 75 0c             	push   0xc(%ebp)
  801774:	50                   	push   %eax
  801775:	e8 64 ff ff ff       	call   8016de <fstat>
  80177a:	89 c6                	mov    %eax,%esi
	close(fd);
  80177c:	89 1c 24             	mov    %ebx,(%esp)
  80177f:	e8 26 fc ff ff       	call   8013aa <close>
	return r;
  801784:	83 c4 10             	add    $0x10,%esp
  801787:	89 f3                	mov    %esi,%ebx
}
  801789:	89 d8                	mov    %ebx,%eax
  80178b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178e:	5b                   	pop    %ebx
  80178f:	5e                   	pop    %esi
  801790:	5d                   	pop    %ebp
  801791:	c3                   	ret    

00801792 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801792:	55                   	push   %ebp
  801793:	89 e5                	mov    %esp,%ebp
  801795:	56                   	push   %esi
  801796:	53                   	push   %ebx
  801797:	89 c6                	mov    %eax,%esi
  801799:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80179b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8017a2:	74 27                	je     8017cb <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017a4:	6a 07                	push   $0x7
  8017a6:	68 00 50 80 00       	push   $0x805000
  8017ab:	56                   	push   %esi
  8017ac:	ff 35 00 60 80 00    	push   0x806000
  8017b2:	e8 13 0c 00 00       	call   8023ca <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017b7:	83 c4 0c             	add    $0xc,%esp
  8017ba:	6a 00                	push   $0x0
  8017bc:	53                   	push   %ebx
  8017bd:	6a 00                	push   $0x0
  8017bf:	e8 96 0b 00 00       	call   80235a <ipc_recv>
}
  8017c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c7:	5b                   	pop    %ebx
  8017c8:	5e                   	pop    %esi
  8017c9:	5d                   	pop    %ebp
  8017ca:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017cb:	83 ec 0c             	sub    $0xc,%esp
  8017ce:	6a 01                	push   $0x1
  8017d0:	e8 49 0c 00 00       	call   80241e <ipc_find_env>
  8017d5:	a3 00 60 80 00       	mov    %eax,0x806000
  8017da:	83 c4 10             	add    $0x10,%esp
  8017dd:	eb c5                	jmp    8017a4 <fsipc+0x12>

008017df <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017eb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fd:	b8 02 00 00 00       	mov    $0x2,%eax
  801802:	e8 8b ff ff ff       	call   801792 <fsipc>
}
  801807:	c9                   	leave  
  801808:	c3                   	ret    

00801809 <devfile_flush>:
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80180f:	8b 45 08             	mov    0x8(%ebp),%eax
  801812:	8b 40 0c             	mov    0xc(%eax),%eax
  801815:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80181a:	ba 00 00 00 00       	mov    $0x0,%edx
  80181f:	b8 06 00 00 00       	mov    $0x6,%eax
  801824:	e8 69 ff ff ff       	call   801792 <fsipc>
}
  801829:	c9                   	leave  
  80182a:	c3                   	ret    

0080182b <devfile_stat>:
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	53                   	push   %ebx
  80182f:	83 ec 04             	sub    $0x4,%esp
  801832:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801835:	8b 45 08             	mov    0x8(%ebp),%eax
  801838:	8b 40 0c             	mov    0xc(%eax),%eax
  80183b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801840:	ba 00 00 00 00       	mov    $0x0,%edx
  801845:	b8 05 00 00 00       	mov    $0x5,%eax
  80184a:	e8 43 ff ff ff       	call   801792 <fsipc>
  80184f:	85 c0                	test   %eax,%eax
  801851:	78 2c                	js     80187f <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801853:	83 ec 08             	sub    $0x8,%esp
  801856:	68 00 50 80 00       	push   $0x805000
  80185b:	53                   	push   %ebx
  80185c:	e8 57 f3 ff ff       	call   800bb8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801861:	a1 80 50 80 00       	mov    0x805080,%eax
  801866:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80186c:	a1 84 50 80 00       	mov    0x805084,%eax
  801871:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80187f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801882:	c9                   	leave  
  801883:	c3                   	ret    

00801884 <devfile_write>:
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	83 ec 0c             	sub    $0xc,%esp
  80188a:	8b 45 10             	mov    0x10(%ebp),%eax
  80188d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801892:	39 d0                	cmp    %edx,%eax
  801894:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801897:	8b 55 08             	mov    0x8(%ebp),%edx
  80189a:	8b 52 0c             	mov    0xc(%edx),%edx
  80189d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018a3:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018a8:	50                   	push   %eax
  8018a9:	ff 75 0c             	push   0xc(%ebp)
  8018ac:	68 08 50 80 00       	push   $0x805008
  8018b1:	e8 98 f4 ff ff       	call   800d4e <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8018b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bb:	b8 04 00 00 00       	mov    $0x4,%eax
  8018c0:	e8 cd fe ff ff       	call   801792 <fsipc>
}
  8018c5:	c9                   	leave  
  8018c6:	c3                   	ret    

008018c7 <devfile_read>:
{
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	56                   	push   %esi
  8018cb:	53                   	push   %ebx
  8018cc:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018da:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8018ea:	e8 a3 fe ff ff       	call   801792 <fsipc>
  8018ef:	89 c3                	mov    %eax,%ebx
  8018f1:	85 c0                	test   %eax,%eax
  8018f3:	78 1f                	js     801914 <devfile_read+0x4d>
	assert(r <= n);
  8018f5:	39 f0                	cmp    %esi,%eax
  8018f7:	77 24                	ja     80191d <devfile_read+0x56>
	assert(r <= PGSIZE);
  8018f9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018fe:	7f 33                	jg     801933 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801900:	83 ec 04             	sub    $0x4,%esp
  801903:	50                   	push   %eax
  801904:	68 00 50 80 00       	push   $0x805000
  801909:	ff 75 0c             	push   0xc(%ebp)
  80190c:	e8 3d f4 ff ff       	call   800d4e <memmove>
	return r;
  801911:	83 c4 10             	add    $0x10,%esp
}
  801914:	89 d8                	mov    %ebx,%eax
  801916:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801919:	5b                   	pop    %ebx
  80191a:	5e                   	pop    %esi
  80191b:	5d                   	pop    %ebp
  80191c:	c3                   	ret    
	assert(r <= n);
  80191d:	68 dc 2b 80 00       	push   $0x802bdc
  801922:	68 e3 2b 80 00       	push   $0x802be3
  801927:	6a 7c                	push   $0x7c
  801929:	68 f8 2b 80 00       	push   $0x802bf8
  80192e:	e8 e1 09 00 00       	call   802314 <_panic>
	assert(r <= PGSIZE);
  801933:	68 03 2c 80 00       	push   $0x802c03
  801938:	68 e3 2b 80 00       	push   $0x802be3
  80193d:	6a 7d                	push   $0x7d
  80193f:	68 f8 2b 80 00       	push   $0x802bf8
  801944:	e8 cb 09 00 00       	call   802314 <_panic>

00801949 <open>:
{
  801949:	55                   	push   %ebp
  80194a:	89 e5                	mov    %esp,%ebp
  80194c:	56                   	push   %esi
  80194d:	53                   	push   %ebx
  80194e:	83 ec 1c             	sub    $0x1c,%esp
  801951:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801954:	56                   	push   %esi
  801955:	e8 23 f2 ff ff       	call   800b7d <strlen>
  80195a:	83 c4 10             	add    $0x10,%esp
  80195d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801962:	7f 6c                	jg     8019d0 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801964:	83 ec 0c             	sub    $0xc,%esp
  801967:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196a:	50                   	push   %eax
  80196b:	e8 bd f8 ff ff       	call   80122d <fd_alloc>
  801970:	89 c3                	mov    %eax,%ebx
  801972:	83 c4 10             	add    $0x10,%esp
  801975:	85 c0                	test   %eax,%eax
  801977:	78 3c                	js     8019b5 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801979:	83 ec 08             	sub    $0x8,%esp
  80197c:	56                   	push   %esi
  80197d:	68 00 50 80 00       	push   $0x805000
  801982:	e8 31 f2 ff ff       	call   800bb8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801987:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198a:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80198f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801992:	b8 01 00 00 00       	mov    $0x1,%eax
  801997:	e8 f6 fd ff ff       	call   801792 <fsipc>
  80199c:	89 c3                	mov    %eax,%ebx
  80199e:	83 c4 10             	add    $0x10,%esp
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	78 19                	js     8019be <open+0x75>
	return fd2num(fd);
  8019a5:	83 ec 0c             	sub    $0xc,%esp
  8019a8:	ff 75 f4             	push   -0xc(%ebp)
  8019ab:	e8 56 f8 ff ff       	call   801206 <fd2num>
  8019b0:	89 c3                	mov    %eax,%ebx
  8019b2:	83 c4 10             	add    $0x10,%esp
}
  8019b5:	89 d8                	mov    %ebx,%eax
  8019b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ba:	5b                   	pop    %ebx
  8019bb:	5e                   	pop    %esi
  8019bc:	5d                   	pop    %ebp
  8019bd:	c3                   	ret    
		fd_close(fd, 0);
  8019be:	83 ec 08             	sub    $0x8,%esp
  8019c1:	6a 00                	push   $0x0
  8019c3:	ff 75 f4             	push   -0xc(%ebp)
  8019c6:	e8 58 f9 ff ff       	call   801323 <fd_close>
		return r;
  8019cb:	83 c4 10             	add    $0x10,%esp
  8019ce:	eb e5                	jmp    8019b5 <open+0x6c>
		return -E_BAD_PATH;
  8019d0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019d5:	eb de                	jmp    8019b5 <open+0x6c>

008019d7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019d7:	55                   	push   %ebp
  8019d8:	89 e5                	mov    %esp,%ebp
  8019da:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e2:	b8 08 00 00 00       	mov    $0x8,%eax
  8019e7:	e8 a6 fd ff ff       	call   801792 <fsipc>
}
  8019ec:	c9                   	leave  
  8019ed:	c3                   	ret    

008019ee <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019f4:	68 0f 2c 80 00       	push   $0x802c0f
  8019f9:	ff 75 0c             	push   0xc(%ebp)
  8019fc:	e8 b7 f1 ff ff       	call   800bb8 <strcpy>
	return 0;
}
  801a01:	b8 00 00 00 00       	mov    $0x0,%eax
  801a06:	c9                   	leave  
  801a07:	c3                   	ret    

00801a08 <devsock_close>:
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	53                   	push   %ebx
  801a0c:	83 ec 10             	sub    $0x10,%esp
  801a0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a12:	53                   	push   %ebx
  801a13:	e8 45 0a 00 00       	call   80245d <pageref>
  801a18:	89 c2                	mov    %eax,%edx
  801a1a:	83 c4 10             	add    $0x10,%esp
		return 0;
  801a1d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801a22:	83 fa 01             	cmp    $0x1,%edx
  801a25:	74 05                	je     801a2c <devsock_close+0x24>
}
  801a27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2a:	c9                   	leave  
  801a2b:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801a2c:	83 ec 0c             	sub    $0xc,%esp
  801a2f:	ff 73 0c             	push   0xc(%ebx)
  801a32:	e8 b7 02 00 00       	call   801cee <nsipc_close>
  801a37:	83 c4 10             	add    $0x10,%esp
  801a3a:	eb eb                	jmp    801a27 <devsock_close+0x1f>

00801a3c <devsock_write>:
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a42:	6a 00                	push   $0x0
  801a44:	ff 75 10             	push   0x10(%ebp)
  801a47:	ff 75 0c             	push   0xc(%ebp)
  801a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4d:	ff 70 0c             	push   0xc(%eax)
  801a50:	e8 79 03 00 00       	call   801dce <nsipc_send>
}
  801a55:	c9                   	leave  
  801a56:	c3                   	ret    

00801a57 <devsock_read>:
{
  801a57:	55                   	push   %ebp
  801a58:	89 e5                	mov    %esp,%ebp
  801a5a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a5d:	6a 00                	push   $0x0
  801a5f:	ff 75 10             	push   0x10(%ebp)
  801a62:	ff 75 0c             	push   0xc(%ebp)
  801a65:	8b 45 08             	mov    0x8(%ebp),%eax
  801a68:	ff 70 0c             	push   0xc(%eax)
  801a6b:	e8 ef 02 00 00       	call   801d5f <nsipc_recv>
}
  801a70:	c9                   	leave  
  801a71:	c3                   	ret    

00801a72 <fd2sockid>:
{
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a78:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a7b:	52                   	push   %edx
  801a7c:	50                   	push   %eax
  801a7d:	e8 fb f7 ff ff       	call   80127d <fd_lookup>
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	85 c0                	test   %eax,%eax
  801a87:	78 10                	js     801a99 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8c:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a92:	39 08                	cmp    %ecx,(%eax)
  801a94:	75 05                	jne    801a9b <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801a96:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801a99:	c9                   	leave  
  801a9a:	c3                   	ret    
		return -E_NOT_SUPP;
  801a9b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801aa0:	eb f7                	jmp    801a99 <fd2sockid+0x27>

00801aa2 <alloc_sockfd>:
{
  801aa2:	55                   	push   %ebp
  801aa3:	89 e5                	mov    %esp,%ebp
  801aa5:	56                   	push   %esi
  801aa6:	53                   	push   %ebx
  801aa7:	83 ec 1c             	sub    $0x1c,%esp
  801aaa:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801aac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aaf:	50                   	push   %eax
  801ab0:	e8 78 f7 ff ff       	call   80122d <fd_alloc>
  801ab5:	89 c3                	mov    %eax,%ebx
  801ab7:	83 c4 10             	add    $0x10,%esp
  801aba:	85 c0                	test   %eax,%eax
  801abc:	78 43                	js     801b01 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801abe:	83 ec 04             	sub    $0x4,%esp
  801ac1:	68 07 04 00 00       	push   $0x407
  801ac6:	ff 75 f4             	push   -0xc(%ebp)
  801ac9:	6a 00                	push   $0x0
  801acb:	e8 e4 f4 ff ff       	call   800fb4 <sys_page_alloc>
  801ad0:	89 c3                	mov    %eax,%ebx
  801ad2:	83 c4 10             	add    $0x10,%esp
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	78 28                	js     801b01 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801adc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ae2:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801aee:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801af1:	83 ec 0c             	sub    $0xc,%esp
  801af4:	50                   	push   %eax
  801af5:	e8 0c f7 ff ff       	call   801206 <fd2num>
  801afa:	89 c3                	mov    %eax,%ebx
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	eb 0c                	jmp    801b0d <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801b01:	83 ec 0c             	sub    $0xc,%esp
  801b04:	56                   	push   %esi
  801b05:	e8 e4 01 00 00       	call   801cee <nsipc_close>
		return r;
  801b0a:	83 c4 10             	add    $0x10,%esp
}
  801b0d:	89 d8                	mov    %ebx,%eax
  801b0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b12:	5b                   	pop    %ebx
  801b13:	5e                   	pop    %esi
  801b14:	5d                   	pop    %ebp
  801b15:	c3                   	ret    

00801b16 <accept>:
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1f:	e8 4e ff ff ff       	call   801a72 <fd2sockid>
  801b24:	85 c0                	test   %eax,%eax
  801b26:	78 1b                	js     801b43 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b28:	83 ec 04             	sub    $0x4,%esp
  801b2b:	ff 75 10             	push   0x10(%ebp)
  801b2e:	ff 75 0c             	push   0xc(%ebp)
  801b31:	50                   	push   %eax
  801b32:	e8 0e 01 00 00       	call   801c45 <nsipc_accept>
  801b37:	83 c4 10             	add    $0x10,%esp
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	78 05                	js     801b43 <accept+0x2d>
	return alloc_sockfd(r);
  801b3e:	e8 5f ff ff ff       	call   801aa2 <alloc_sockfd>
}
  801b43:	c9                   	leave  
  801b44:	c3                   	ret    

00801b45 <bind>:
{
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4e:	e8 1f ff ff ff       	call   801a72 <fd2sockid>
  801b53:	85 c0                	test   %eax,%eax
  801b55:	78 12                	js     801b69 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801b57:	83 ec 04             	sub    $0x4,%esp
  801b5a:	ff 75 10             	push   0x10(%ebp)
  801b5d:	ff 75 0c             	push   0xc(%ebp)
  801b60:	50                   	push   %eax
  801b61:	e8 31 01 00 00       	call   801c97 <nsipc_bind>
  801b66:	83 c4 10             	add    $0x10,%esp
}
  801b69:	c9                   	leave  
  801b6a:	c3                   	ret    

00801b6b <shutdown>:
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b71:	8b 45 08             	mov    0x8(%ebp),%eax
  801b74:	e8 f9 fe ff ff       	call   801a72 <fd2sockid>
  801b79:	85 c0                	test   %eax,%eax
  801b7b:	78 0f                	js     801b8c <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801b7d:	83 ec 08             	sub    $0x8,%esp
  801b80:	ff 75 0c             	push   0xc(%ebp)
  801b83:	50                   	push   %eax
  801b84:	e8 43 01 00 00       	call   801ccc <nsipc_shutdown>
  801b89:	83 c4 10             	add    $0x10,%esp
}
  801b8c:	c9                   	leave  
  801b8d:	c3                   	ret    

00801b8e <connect>:
{
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b94:	8b 45 08             	mov    0x8(%ebp),%eax
  801b97:	e8 d6 fe ff ff       	call   801a72 <fd2sockid>
  801b9c:	85 c0                	test   %eax,%eax
  801b9e:	78 12                	js     801bb2 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801ba0:	83 ec 04             	sub    $0x4,%esp
  801ba3:	ff 75 10             	push   0x10(%ebp)
  801ba6:	ff 75 0c             	push   0xc(%ebp)
  801ba9:	50                   	push   %eax
  801baa:	e8 59 01 00 00       	call   801d08 <nsipc_connect>
  801baf:	83 c4 10             	add    $0x10,%esp
}
  801bb2:	c9                   	leave  
  801bb3:	c3                   	ret    

00801bb4 <listen>:
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bba:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbd:	e8 b0 fe ff ff       	call   801a72 <fd2sockid>
  801bc2:	85 c0                	test   %eax,%eax
  801bc4:	78 0f                	js     801bd5 <listen+0x21>
	return nsipc_listen(r, backlog);
  801bc6:	83 ec 08             	sub    $0x8,%esp
  801bc9:	ff 75 0c             	push   0xc(%ebp)
  801bcc:	50                   	push   %eax
  801bcd:	e8 6b 01 00 00       	call   801d3d <nsipc_listen>
  801bd2:	83 c4 10             	add    $0x10,%esp
}
  801bd5:	c9                   	leave  
  801bd6:	c3                   	ret    

00801bd7 <socket>:

int
socket(int domain, int type, int protocol)
{
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bdd:	ff 75 10             	push   0x10(%ebp)
  801be0:	ff 75 0c             	push   0xc(%ebp)
  801be3:	ff 75 08             	push   0x8(%ebp)
  801be6:	e8 41 02 00 00       	call   801e2c <nsipc_socket>
  801beb:	83 c4 10             	add    $0x10,%esp
  801bee:	85 c0                	test   %eax,%eax
  801bf0:	78 05                	js     801bf7 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bf2:	e8 ab fe ff ff       	call   801aa2 <alloc_sockfd>
}
  801bf7:	c9                   	leave  
  801bf8:	c3                   	ret    

00801bf9 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	53                   	push   %ebx
  801bfd:	83 ec 04             	sub    $0x4,%esp
  801c00:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c02:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801c09:	74 26                	je     801c31 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c0b:	6a 07                	push   $0x7
  801c0d:	68 00 70 80 00       	push   $0x807000
  801c12:	53                   	push   %ebx
  801c13:	ff 35 00 80 80 00    	push   0x808000
  801c19:	e8 ac 07 00 00       	call   8023ca <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c1e:	83 c4 0c             	add    $0xc,%esp
  801c21:	6a 00                	push   $0x0
  801c23:	6a 00                	push   $0x0
  801c25:	6a 00                	push   $0x0
  801c27:	e8 2e 07 00 00       	call   80235a <ipc_recv>
}
  801c2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c2f:	c9                   	leave  
  801c30:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c31:	83 ec 0c             	sub    $0xc,%esp
  801c34:	6a 02                	push   $0x2
  801c36:	e8 e3 07 00 00       	call   80241e <ipc_find_env>
  801c3b:	a3 00 80 80 00       	mov    %eax,0x808000
  801c40:	83 c4 10             	add    $0x10,%esp
  801c43:	eb c6                	jmp    801c0b <nsipc+0x12>

00801c45 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	56                   	push   %esi
  801c49:	53                   	push   %ebx
  801c4a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c50:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c55:	8b 06                	mov    (%esi),%eax
  801c57:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c5c:	b8 01 00 00 00       	mov    $0x1,%eax
  801c61:	e8 93 ff ff ff       	call   801bf9 <nsipc>
  801c66:	89 c3                	mov    %eax,%ebx
  801c68:	85 c0                	test   %eax,%eax
  801c6a:	79 09                	jns    801c75 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801c6c:	89 d8                	mov    %ebx,%eax
  801c6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c71:	5b                   	pop    %ebx
  801c72:	5e                   	pop    %esi
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c75:	83 ec 04             	sub    $0x4,%esp
  801c78:	ff 35 10 70 80 00    	push   0x807010
  801c7e:	68 00 70 80 00       	push   $0x807000
  801c83:	ff 75 0c             	push   0xc(%ebp)
  801c86:	e8 c3 f0 ff ff       	call   800d4e <memmove>
		*addrlen = ret->ret_addrlen;
  801c8b:	a1 10 70 80 00       	mov    0x807010,%eax
  801c90:	89 06                	mov    %eax,(%esi)
  801c92:	83 c4 10             	add    $0x10,%esp
	return r;
  801c95:	eb d5                	jmp    801c6c <nsipc_accept+0x27>

00801c97 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	53                   	push   %ebx
  801c9b:	83 ec 08             	sub    $0x8,%esp
  801c9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca4:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ca9:	53                   	push   %ebx
  801caa:	ff 75 0c             	push   0xc(%ebp)
  801cad:	68 04 70 80 00       	push   $0x807004
  801cb2:	e8 97 f0 ff ff       	call   800d4e <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801cb7:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801cbd:	b8 02 00 00 00       	mov    $0x2,%eax
  801cc2:	e8 32 ff ff ff       	call   801bf9 <nsipc>
}
  801cc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cca:	c9                   	leave  
  801ccb:	c3                   	ret    

00801ccc <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801cda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cdd:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801ce2:	b8 03 00 00 00       	mov    $0x3,%eax
  801ce7:	e8 0d ff ff ff       	call   801bf9 <nsipc>
}
  801cec:	c9                   	leave  
  801ced:	c3                   	ret    

00801cee <nsipc_close>:

int
nsipc_close(int s)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf7:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801cfc:	b8 04 00 00 00       	mov    $0x4,%eax
  801d01:	e8 f3 fe ff ff       	call   801bf9 <nsipc>
}
  801d06:	c9                   	leave  
  801d07:	c3                   	ret    

00801d08 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	53                   	push   %ebx
  801d0c:	83 ec 08             	sub    $0x8,%esp
  801d0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d12:	8b 45 08             	mov    0x8(%ebp),%eax
  801d15:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d1a:	53                   	push   %ebx
  801d1b:	ff 75 0c             	push   0xc(%ebp)
  801d1e:	68 04 70 80 00       	push   $0x807004
  801d23:	e8 26 f0 ff ff       	call   800d4e <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d28:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801d2e:	b8 05 00 00 00       	mov    $0x5,%eax
  801d33:	e8 c1 fe ff ff       	call   801bf9 <nsipc>
}
  801d38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d3b:	c9                   	leave  
  801d3c:	c3                   	ret    

00801d3d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d3d:	55                   	push   %ebp
  801d3e:	89 e5                	mov    %esp,%ebp
  801d40:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d43:	8b 45 08             	mov    0x8(%ebp),%eax
  801d46:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801d4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d4e:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801d53:	b8 06 00 00 00       	mov    $0x6,%eax
  801d58:	e8 9c fe ff ff       	call   801bf9 <nsipc>
}
  801d5d:	c9                   	leave  
  801d5e:	c3                   	ret    

00801d5f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	56                   	push   %esi
  801d63:	53                   	push   %ebx
  801d64:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d67:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801d6f:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801d75:	8b 45 14             	mov    0x14(%ebp),%eax
  801d78:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d7d:	b8 07 00 00 00       	mov    $0x7,%eax
  801d82:	e8 72 fe ff ff       	call   801bf9 <nsipc>
  801d87:	89 c3                	mov    %eax,%ebx
  801d89:	85 c0                	test   %eax,%eax
  801d8b:	78 22                	js     801daf <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801d8d:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801d92:	39 c6                	cmp    %eax,%esi
  801d94:	0f 4e c6             	cmovle %esi,%eax
  801d97:	39 c3                	cmp    %eax,%ebx
  801d99:	7f 1d                	jg     801db8 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d9b:	83 ec 04             	sub    $0x4,%esp
  801d9e:	53                   	push   %ebx
  801d9f:	68 00 70 80 00       	push   $0x807000
  801da4:	ff 75 0c             	push   0xc(%ebp)
  801da7:	e8 a2 ef ff ff       	call   800d4e <memmove>
  801dac:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801daf:	89 d8                	mov    %ebx,%eax
  801db1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db4:	5b                   	pop    %ebx
  801db5:	5e                   	pop    %esi
  801db6:	5d                   	pop    %ebp
  801db7:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801db8:	68 1b 2c 80 00       	push   $0x802c1b
  801dbd:	68 e3 2b 80 00       	push   $0x802be3
  801dc2:	6a 62                	push   $0x62
  801dc4:	68 30 2c 80 00       	push   $0x802c30
  801dc9:	e8 46 05 00 00       	call   802314 <_panic>

00801dce <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801dce:	55                   	push   %ebp
  801dcf:	89 e5                	mov    %esp,%ebp
  801dd1:	53                   	push   %ebx
  801dd2:	83 ec 04             	sub    $0x4,%esp
  801dd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddb:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801de0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801de6:	7f 2e                	jg     801e16 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801de8:	83 ec 04             	sub    $0x4,%esp
  801deb:	53                   	push   %ebx
  801dec:	ff 75 0c             	push   0xc(%ebp)
  801def:	68 0c 70 80 00       	push   $0x80700c
  801df4:	e8 55 ef ff ff       	call   800d4e <memmove>
	nsipcbuf.send.req_size = size;
  801df9:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801dff:	8b 45 14             	mov    0x14(%ebp),%eax
  801e02:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801e07:	b8 08 00 00 00       	mov    $0x8,%eax
  801e0c:	e8 e8 fd ff ff       	call   801bf9 <nsipc>
}
  801e11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e14:	c9                   	leave  
  801e15:	c3                   	ret    
	assert(size < 1600);
  801e16:	68 3c 2c 80 00       	push   $0x802c3c
  801e1b:	68 e3 2b 80 00       	push   $0x802be3
  801e20:	6a 6d                	push   $0x6d
  801e22:	68 30 2c 80 00       	push   $0x802c30
  801e27:	e8 e8 04 00 00       	call   802314 <_panic>

00801e2c <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e2c:	55                   	push   %ebp
  801e2d:	89 e5                	mov    %esp,%ebp
  801e2f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e32:	8b 45 08             	mov    0x8(%ebp),%eax
  801e35:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801e3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3d:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801e42:	8b 45 10             	mov    0x10(%ebp),%eax
  801e45:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801e4a:	b8 09 00 00 00       	mov    $0x9,%eax
  801e4f:	e8 a5 fd ff ff       	call   801bf9 <nsipc>
}
  801e54:	c9                   	leave  
  801e55:	c3                   	ret    

00801e56 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e56:	55                   	push   %ebp
  801e57:	89 e5                	mov    %esp,%ebp
  801e59:	56                   	push   %esi
  801e5a:	53                   	push   %ebx
  801e5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e5e:	83 ec 0c             	sub    $0xc,%esp
  801e61:	ff 75 08             	push   0x8(%ebp)
  801e64:	e8 ad f3 ff ff       	call   801216 <fd2data>
  801e69:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e6b:	83 c4 08             	add    $0x8,%esp
  801e6e:	68 48 2c 80 00       	push   $0x802c48
  801e73:	53                   	push   %ebx
  801e74:	e8 3f ed ff ff       	call   800bb8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e79:	8b 46 04             	mov    0x4(%esi),%eax
  801e7c:	2b 06                	sub    (%esi),%eax
  801e7e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e84:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e8b:	00 00 00 
	stat->st_dev = &devpipe;
  801e8e:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e95:	30 80 00 
	return 0;
}
  801e98:	b8 00 00 00 00       	mov    $0x0,%eax
  801e9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea0:	5b                   	pop    %ebx
  801ea1:	5e                   	pop    %esi
  801ea2:	5d                   	pop    %ebp
  801ea3:	c3                   	ret    

00801ea4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	53                   	push   %ebx
  801ea8:	83 ec 0c             	sub    $0xc,%esp
  801eab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801eae:	53                   	push   %ebx
  801eaf:	6a 00                	push   $0x0
  801eb1:	e8 83 f1 ff ff       	call   801039 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801eb6:	89 1c 24             	mov    %ebx,(%esp)
  801eb9:	e8 58 f3 ff ff       	call   801216 <fd2data>
  801ebe:	83 c4 08             	add    $0x8,%esp
  801ec1:	50                   	push   %eax
  801ec2:	6a 00                	push   $0x0
  801ec4:	e8 70 f1 ff ff       	call   801039 <sys_page_unmap>
}
  801ec9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ecc:	c9                   	leave  
  801ecd:	c3                   	ret    

00801ece <_pipeisclosed>:
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	57                   	push   %edi
  801ed2:	56                   	push   %esi
  801ed3:	53                   	push   %ebx
  801ed4:	83 ec 1c             	sub    $0x1c,%esp
  801ed7:	89 c7                	mov    %eax,%edi
  801ed9:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801edb:	a1 10 40 80 00       	mov    0x804010,%eax
  801ee0:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ee3:	83 ec 0c             	sub    $0xc,%esp
  801ee6:	57                   	push   %edi
  801ee7:	e8 71 05 00 00       	call   80245d <pageref>
  801eec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801eef:	89 34 24             	mov    %esi,(%esp)
  801ef2:	e8 66 05 00 00       	call   80245d <pageref>
		nn = thisenv->env_runs;
  801ef7:	8b 15 10 40 80 00    	mov    0x804010,%edx
  801efd:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801f00:	83 c4 10             	add    $0x10,%esp
  801f03:	39 cb                	cmp    %ecx,%ebx
  801f05:	74 1b                	je     801f22 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801f07:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f0a:	75 cf                	jne    801edb <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f0c:	8b 42 68             	mov    0x68(%edx),%eax
  801f0f:	6a 01                	push   $0x1
  801f11:	50                   	push   %eax
  801f12:	53                   	push   %ebx
  801f13:	68 4f 2c 80 00       	push   $0x802c4f
  801f18:	e8 c1 e6 ff ff       	call   8005de <cprintf>
  801f1d:	83 c4 10             	add    $0x10,%esp
  801f20:	eb b9                	jmp    801edb <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801f22:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f25:	0f 94 c0             	sete   %al
  801f28:	0f b6 c0             	movzbl %al,%eax
}
  801f2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f2e:	5b                   	pop    %ebx
  801f2f:	5e                   	pop    %esi
  801f30:	5f                   	pop    %edi
  801f31:	5d                   	pop    %ebp
  801f32:	c3                   	ret    

00801f33 <devpipe_write>:
{
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	57                   	push   %edi
  801f37:	56                   	push   %esi
  801f38:	53                   	push   %ebx
  801f39:	83 ec 28             	sub    $0x28,%esp
  801f3c:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801f3f:	56                   	push   %esi
  801f40:	e8 d1 f2 ff ff       	call   801216 <fd2data>
  801f45:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f47:	83 c4 10             	add    $0x10,%esp
  801f4a:	bf 00 00 00 00       	mov    $0x0,%edi
  801f4f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f52:	75 09                	jne    801f5d <devpipe_write+0x2a>
	return i;
  801f54:	89 f8                	mov    %edi,%eax
  801f56:	eb 23                	jmp    801f7b <devpipe_write+0x48>
			sys_yield();
  801f58:	e8 38 f0 ff ff       	call   800f95 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f5d:	8b 43 04             	mov    0x4(%ebx),%eax
  801f60:	8b 0b                	mov    (%ebx),%ecx
  801f62:	8d 51 20             	lea    0x20(%ecx),%edx
  801f65:	39 d0                	cmp    %edx,%eax
  801f67:	72 1a                	jb     801f83 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801f69:	89 da                	mov    %ebx,%edx
  801f6b:	89 f0                	mov    %esi,%eax
  801f6d:	e8 5c ff ff ff       	call   801ece <_pipeisclosed>
  801f72:	85 c0                	test   %eax,%eax
  801f74:	74 e2                	je     801f58 <devpipe_write+0x25>
				return 0;
  801f76:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7e:	5b                   	pop    %ebx
  801f7f:	5e                   	pop    %esi
  801f80:	5f                   	pop    %edi
  801f81:	5d                   	pop    %ebp
  801f82:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f86:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f8a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f8d:	89 c2                	mov    %eax,%edx
  801f8f:	c1 fa 1f             	sar    $0x1f,%edx
  801f92:	89 d1                	mov    %edx,%ecx
  801f94:	c1 e9 1b             	shr    $0x1b,%ecx
  801f97:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f9a:	83 e2 1f             	and    $0x1f,%edx
  801f9d:	29 ca                	sub    %ecx,%edx
  801f9f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fa3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fa7:	83 c0 01             	add    $0x1,%eax
  801faa:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801fad:	83 c7 01             	add    $0x1,%edi
  801fb0:	eb 9d                	jmp    801f4f <devpipe_write+0x1c>

00801fb2 <devpipe_read>:
{
  801fb2:	55                   	push   %ebp
  801fb3:	89 e5                	mov    %esp,%ebp
  801fb5:	57                   	push   %edi
  801fb6:	56                   	push   %esi
  801fb7:	53                   	push   %ebx
  801fb8:	83 ec 18             	sub    $0x18,%esp
  801fbb:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801fbe:	57                   	push   %edi
  801fbf:	e8 52 f2 ff ff       	call   801216 <fd2data>
  801fc4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801fc6:	83 c4 10             	add    $0x10,%esp
  801fc9:	be 00 00 00 00       	mov    $0x0,%esi
  801fce:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fd1:	75 13                	jne    801fe6 <devpipe_read+0x34>
	return i;
  801fd3:	89 f0                	mov    %esi,%eax
  801fd5:	eb 02                	jmp    801fd9 <devpipe_read+0x27>
				return i;
  801fd7:	89 f0                	mov    %esi,%eax
}
  801fd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fdc:	5b                   	pop    %ebx
  801fdd:	5e                   	pop    %esi
  801fde:	5f                   	pop    %edi
  801fdf:	5d                   	pop    %ebp
  801fe0:	c3                   	ret    
			sys_yield();
  801fe1:	e8 af ef ff ff       	call   800f95 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801fe6:	8b 03                	mov    (%ebx),%eax
  801fe8:	3b 43 04             	cmp    0x4(%ebx),%eax
  801feb:	75 18                	jne    802005 <devpipe_read+0x53>
			if (i > 0)
  801fed:	85 f6                	test   %esi,%esi
  801fef:	75 e6                	jne    801fd7 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801ff1:	89 da                	mov    %ebx,%edx
  801ff3:	89 f8                	mov    %edi,%eax
  801ff5:	e8 d4 fe ff ff       	call   801ece <_pipeisclosed>
  801ffa:	85 c0                	test   %eax,%eax
  801ffc:	74 e3                	je     801fe1 <devpipe_read+0x2f>
				return 0;
  801ffe:	b8 00 00 00 00       	mov    $0x0,%eax
  802003:	eb d4                	jmp    801fd9 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802005:	99                   	cltd   
  802006:	c1 ea 1b             	shr    $0x1b,%edx
  802009:	01 d0                	add    %edx,%eax
  80200b:	83 e0 1f             	and    $0x1f,%eax
  80200e:	29 d0                	sub    %edx,%eax
  802010:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802015:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802018:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80201b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80201e:	83 c6 01             	add    $0x1,%esi
  802021:	eb ab                	jmp    801fce <devpipe_read+0x1c>

00802023 <pipe>:
{
  802023:	55                   	push   %ebp
  802024:	89 e5                	mov    %esp,%ebp
  802026:	56                   	push   %esi
  802027:	53                   	push   %ebx
  802028:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80202b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80202e:	50                   	push   %eax
  80202f:	e8 f9 f1 ff ff       	call   80122d <fd_alloc>
  802034:	89 c3                	mov    %eax,%ebx
  802036:	83 c4 10             	add    $0x10,%esp
  802039:	85 c0                	test   %eax,%eax
  80203b:	0f 88 23 01 00 00    	js     802164 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802041:	83 ec 04             	sub    $0x4,%esp
  802044:	68 07 04 00 00       	push   $0x407
  802049:	ff 75 f4             	push   -0xc(%ebp)
  80204c:	6a 00                	push   $0x0
  80204e:	e8 61 ef ff ff       	call   800fb4 <sys_page_alloc>
  802053:	89 c3                	mov    %eax,%ebx
  802055:	83 c4 10             	add    $0x10,%esp
  802058:	85 c0                	test   %eax,%eax
  80205a:	0f 88 04 01 00 00    	js     802164 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802060:	83 ec 0c             	sub    $0xc,%esp
  802063:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802066:	50                   	push   %eax
  802067:	e8 c1 f1 ff ff       	call   80122d <fd_alloc>
  80206c:	89 c3                	mov    %eax,%ebx
  80206e:	83 c4 10             	add    $0x10,%esp
  802071:	85 c0                	test   %eax,%eax
  802073:	0f 88 db 00 00 00    	js     802154 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802079:	83 ec 04             	sub    $0x4,%esp
  80207c:	68 07 04 00 00       	push   $0x407
  802081:	ff 75 f0             	push   -0x10(%ebp)
  802084:	6a 00                	push   $0x0
  802086:	e8 29 ef ff ff       	call   800fb4 <sys_page_alloc>
  80208b:	89 c3                	mov    %eax,%ebx
  80208d:	83 c4 10             	add    $0x10,%esp
  802090:	85 c0                	test   %eax,%eax
  802092:	0f 88 bc 00 00 00    	js     802154 <pipe+0x131>
	va = fd2data(fd0);
  802098:	83 ec 0c             	sub    $0xc,%esp
  80209b:	ff 75 f4             	push   -0xc(%ebp)
  80209e:	e8 73 f1 ff ff       	call   801216 <fd2data>
  8020a3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020a5:	83 c4 0c             	add    $0xc,%esp
  8020a8:	68 07 04 00 00       	push   $0x407
  8020ad:	50                   	push   %eax
  8020ae:	6a 00                	push   $0x0
  8020b0:	e8 ff ee ff ff       	call   800fb4 <sys_page_alloc>
  8020b5:	89 c3                	mov    %eax,%ebx
  8020b7:	83 c4 10             	add    $0x10,%esp
  8020ba:	85 c0                	test   %eax,%eax
  8020bc:	0f 88 82 00 00 00    	js     802144 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020c2:	83 ec 0c             	sub    $0xc,%esp
  8020c5:	ff 75 f0             	push   -0x10(%ebp)
  8020c8:	e8 49 f1 ff ff       	call   801216 <fd2data>
  8020cd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020d4:	50                   	push   %eax
  8020d5:	6a 00                	push   $0x0
  8020d7:	56                   	push   %esi
  8020d8:	6a 00                	push   $0x0
  8020da:	e8 18 ef ff ff       	call   800ff7 <sys_page_map>
  8020df:	89 c3                	mov    %eax,%ebx
  8020e1:	83 c4 20             	add    $0x20,%esp
  8020e4:	85 c0                	test   %eax,%eax
  8020e6:	78 4e                	js     802136 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8020e8:	a1 3c 30 80 00       	mov    0x80303c,%eax
  8020ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020f0:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8020f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020f5:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8020fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020ff:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802101:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802104:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80210b:	83 ec 0c             	sub    $0xc,%esp
  80210e:	ff 75 f4             	push   -0xc(%ebp)
  802111:	e8 f0 f0 ff ff       	call   801206 <fd2num>
  802116:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802119:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80211b:	83 c4 04             	add    $0x4,%esp
  80211e:	ff 75 f0             	push   -0x10(%ebp)
  802121:	e8 e0 f0 ff ff       	call   801206 <fd2num>
  802126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802129:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80212c:	83 c4 10             	add    $0x10,%esp
  80212f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802134:	eb 2e                	jmp    802164 <pipe+0x141>
	sys_page_unmap(0, va);
  802136:	83 ec 08             	sub    $0x8,%esp
  802139:	56                   	push   %esi
  80213a:	6a 00                	push   $0x0
  80213c:	e8 f8 ee ff ff       	call   801039 <sys_page_unmap>
  802141:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802144:	83 ec 08             	sub    $0x8,%esp
  802147:	ff 75 f0             	push   -0x10(%ebp)
  80214a:	6a 00                	push   $0x0
  80214c:	e8 e8 ee ff ff       	call   801039 <sys_page_unmap>
  802151:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802154:	83 ec 08             	sub    $0x8,%esp
  802157:	ff 75 f4             	push   -0xc(%ebp)
  80215a:	6a 00                	push   $0x0
  80215c:	e8 d8 ee ff ff       	call   801039 <sys_page_unmap>
  802161:	83 c4 10             	add    $0x10,%esp
}
  802164:	89 d8                	mov    %ebx,%eax
  802166:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802169:	5b                   	pop    %ebx
  80216a:	5e                   	pop    %esi
  80216b:	5d                   	pop    %ebp
  80216c:	c3                   	ret    

0080216d <pipeisclosed>:
{
  80216d:	55                   	push   %ebp
  80216e:	89 e5                	mov    %esp,%ebp
  802170:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802173:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802176:	50                   	push   %eax
  802177:	ff 75 08             	push   0x8(%ebp)
  80217a:	e8 fe f0 ff ff       	call   80127d <fd_lookup>
  80217f:	83 c4 10             	add    $0x10,%esp
  802182:	85 c0                	test   %eax,%eax
  802184:	78 18                	js     80219e <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802186:	83 ec 0c             	sub    $0xc,%esp
  802189:	ff 75 f4             	push   -0xc(%ebp)
  80218c:	e8 85 f0 ff ff       	call   801216 <fd2data>
  802191:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802193:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802196:	e8 33 fd ff ff       	call   801ece <_pipeisclosed>
  80219b:	83 c4 10             	add    $0x10,%esp
}
  80219e:	c9                   	leave  
  80219f:	c3                   	ret    

008021a0 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  8021a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a5:	c3                   	ret    

008021a6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021a6:	55                   	push   %ebp
  8021a7:	89 e5                	mov    %esp,%ebp
  8021a9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021ac:	68 67 2c 80 00       	push   $0x802c67
  8021b1:	ff 75 0c             	push   0xc(%ebp)
  8021b4:	e8 ff e9 ff ff       	call   800bb8 <strcpy>
	return 0;
}
  8021b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8021be:	c9                   	leave  
  8021bf:	c3                   	ret    

008021c0 <devcons_write>:
{
  8021c0:	55                   	push   %ebp
  8021c1:	89 e5                	mov    %esp,%ebp
  8021c3:	57                   	push   %edi
  8021c4:	56                   	push   %esi
  8021c5:	53                   	push   %ebx
  8021c6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8021cc:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8021d1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8021d7:	eb 2e                	jmp    802207 <devcons_write+0x47>
		m = n - tot;
  8021d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021dc:	29 f3                	sub    %esi,%ebx
  8021de:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8021e3:	39 c3                	cmp    %eax,%ebx
  8021e5:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8021e8:	83 ec 04             	sub    $0x4,%esp
  8021eb:	53                   	push   %ebx
  8021ec:	89 f0                	mov    %esi,%eax
  8021ee:	03 45 0c             	add    0xc(%ebp),%eax
  8021f1:	50                   	push   %eax
  8021f2:	57                   	push   %edi
  8021f3:	e8 56 eb ff ff       	call   800d4e <memmove>
		sys_cputs(buf, m);
  8021f8:	83 c4 08             	add    $0x8,%esp
  8021fb:	53                   	push   %ebx
  8021fc:	57                   	push   %edi
  8021fd:	e8 f6 ec ff ff       	call   800ef8 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802202:	01 de                	add    %ebx,%esi
  802204:	83 c4 10             	add    $0x10,%esp
  802207:	3b 75 10             	cmp    0x10(%ebp),%esi
  80220a:	72 cd                	jb     8021d9 <devcons_write+0x19>
}
  80220c:	89 f0                	mov    %esi,%eax
  80220e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802211:	5b                   	pop    %ebx
  802212:	5e                   	pop    %esi
  802213:	5f                   	pop    %edi
  802214:	5d                   	pop    %ebp
  802215:	c3                   	ret    

00802216 <devcons_read>:
{
  802216:	55                   	push   %ebp
  802217:	89 e5                	mov    %esp,%ebp
  802219:	83 ec 08             	sub    $0x8,%esp
  80221c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802221:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802225:	75 07                	jne    80222e <devcons_read+0x18>
  802227:	eb 1f                	jmp    802248 <devcons_read+0x32>
		sys_yield();
  802229:	e8 67 ed ff ff       	call   800f95 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80222e:	e8 e3 ec ff ff       	call   800f16 <sys_cgetc>
  802233:	85 c0                	test   %eax,%eax
  802235:	74 f2                	je     802229 <devcons_read+0x13>
	if (c < 0)
  802237:	78 0f                	js     802248 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802239:	83 f8 04             	cmp    $0x4,%eax
  80223c:	74 0c                	je     80224a <devcons_read+0x34>
	*(char*)vbuf = c;
  80223e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802241:	88 02                	mov    %al,(%edx)
	return 1;
  802243:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802248:	c9                   	leave  
  802249:	c3                   	ret    
		return 0;
  80224a:	b8 00 00 00 00       	mov    $0x0,%eax
  80224f:	eb f7                	jmp    802248 <devcons_read+0x32>

00802251 <cputchar>:
{
  802251:	55                   	push   %ebp
  802252:	89 e5                	mov    %esp,%ebp
  802254:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802257:	8b 45 08             	mov    0x8(%ebp),%eax
  80225a:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80225d:	6a 01                	push   $0x1
  80225f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802262:	50                   	push   %eax
  802263:	e8 90 ec ff ff       	call   800ef8 <sys_cputs>
}
  802268:	83 c4 10             	add    $0x10,%esp
  80226b:	c9                   	leave  
  80226c:	c3                   	ret    

0080226d <getchar>:
{
  80226d:	55                   	push   %ebp
  80226e:	89 e5                	mov    %esp,%ebp
  802270:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802273:	6a 01                	push   $0x1
  802275:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802278:	50                   	push   %eax
  802279:	6a 00                	push   $0x0
  80227b:	e8 66 f2 ff ff       	call   8014e6 <read>
	if (r < 0)
  802280:	83 c4 10             	add    $0x10,%esp
  802283:	85 c0                	test   %eax,%eax
  802285:	78 06                	js     80228d <getchar+0x20>
	if (r < 1)
  802287:	74 06                	je     80228f <getchar+0x22>
	return c;
  802289:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80228d:	c9                   	leave  
  80228e:	c3                   	ret    
		return -E_EOF;
  80228f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802294:	eb f7                	jmp    80228d <getchar+0x20>

00802296 <iscons>:
{
  802296:	55                   	push   %ebp
  802297:	89 e5                	mov    %esp,%ebp
  802299:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80229c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80229f:	50                   	push   %eax
  8022a0:	ff 75 08             	push   0x8(%ebp)
  8022a3:	e8 d5 ef ff ff       	call   80127d <fd_lookup>
  8022a8:	83 c4 10             	add    $0x10,%esp
  8022ab:	85 c0                	test   %eax,%eax
  8022ad:	78 11                	js     8022c0 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8022af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b2:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022b8:	39 10                	cmp    %edx,(%eax)
  8022ba:	0f 94 c0             	sete   %al
  8022bd:	0f b6 c0             	movzbl %al,%eax
}
  8022c0:	c9                   	leave  
  8022c1:	c3                   	ret    

008022c2 <opencons>:
{
  8022c2:	55                   	push   %ebp
  8022c3:	89 e5                	mov    %esp,%ebp
  8022c5:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8022c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022cb:	50                   	push   %eax
  8022cc:	e8 5c ef ff ff       	call   80122d <fd_alloc>
  8022d1:	83 c4 10             	add    $0x10,%esp
  8022d4:	85 c0                	test   %eax,%eax
  8022d6:	78 3a                	js     802312 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022d8:	83 ec 04             	sub    $0x4,%esp
  8022db:	68 07 04 00 00       	push   $0x407
  8022e0:	ff 75 f4             	push   -0xc(%ebp)
  8022e3:	6a 00                	push   $0x0
  8022e5:	e8 ca ec ff ff       	call   800fb4 <sys_page_alloc>
  8022ea:	83 c4 10             	add    $0x10,%esp
  8022ed:	85 c0                	test   %eax,%eax
  8022ef:	78 21                	js     802312 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8022f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022fa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ff:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802306:	83 ec 0c             	sub    $0xc,%esp
  802309:	50                   	push   %eax
  80230a:	e8 f7 ee ff ff       	call   801206 <fd2num>
  80230f:	83 c4 10             	add    $0x10,%esp
}
  802312:	c9                   	leave  
  802313:	c3                   	ret    

00802314 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802314:	55                   	push   %ebp
  802315:	89 e5                	mov    %esp,%ebp
  802317:	56                   	push   %esi
  802318:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802319:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80231c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802322:	e8 4f ec ff ff       	call   800f76 <sys_getenvid>
  802327:	83 ec 0c             	sub    $0xc,%esp
  80232a:	ff 75 0c             	push   0xc(%ebp)
  80232d:	ff 75 08             	push   0x8(%ebp)
  802330:	56                   	push   %esi
  802331:	50                   	push   %eax
  802332:	68 74 2c 80 00       	push   $0x802c74
  802337:	e8 a2 e2 ff ff       	call   8005de <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80233c:	83 c4 18             	add    $0x18,%esp
  80233f:	53                   	push   %ebx
  802340:	ff 75 10             	push   0x10(%ebp)
  802343:	e8 45 e2 ff ff       	call   80058d <vcprintf>
	cprintf("\n");
  802348:	c7 04 24 60 2c 80 00 	movl   $0x802c60,(%esp)
  80234f:	e8 8a e2 ff ff       	call   8005de <cprintf>
  802354:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802357:	cc                   	int3   
  802358:	eb fd                	jmp    802357 <_panic+0x43>

0080235a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80235a:	55                   	push   %ebp
  80235b:	89 e5                	mov    %esp,%ebp
  80235d:	56                   	push   %esi
  80235e:	53                   	push   %ebx
  80235f:	8b 75 08             	mov    0x8(%ebp),%esi
  802362:	8b 45 0c             	mov    0xc(%ebp),%eax
  802365:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  802368:	85 c0                	test   %eax,%eax
  80236a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80236f:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802372:	83 ec 0c             	sub    $0xc,%esp
  802375:	50                   	push   %eax
  802376:	e8 e9 ed ff ff       	call   801164 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  80237b:	83 c4 10             	add    $0x10,%esp
  80237e:	85 f6                	test   %esi,%esi
  802380:	74 17                	je     802399 <ipc_recv+0x3f>
  802382:	ba 00 00 00 00       	mov    $0x0,%edx
  802387:	85 c0                	test   %eax,%eax
  802389:	78 0c                	js     802397 <ipc_recv+0x3d>
  80238b:	8b 15 10 40 80 00    	mov    0x804010,%edx
  802391:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  802397:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802399:	85 db                	test   %ebx,%ebx
  80239b:	74 17                	je     8023b4 <ipc_recv+0x5a>
  80239d:	ba 00 00 00 00       	mov    $0x0,%edx
  8023a2:	85 c0                	test   %eax,%eax
  8023a4:	78 0c                	js     8023b2 <ipc_recv+0x58>
  8023a6:	8b 15 10 40 80 00    	mov    0x804010,%edx
  8023ac:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  8023b2:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8023b4:	85 c0                	test   %eax,%eax
  8023b6:	78 0b                	js     8023c3 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  8023b8:	a1 10 40 80 00       	mov    0x804010,%eax
  8023bd:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  8023c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023c6:	5b                   	pop    %ebx
  8023c7:	5e                   	pop    %esi
  8023c8:	5d                   	pop    %ebp
  8023c9:	c3                   	ret    

008023ca <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023ca:	55                   	push   %ebp
  8023cb:	89 e5                	mov    %esp,%ebp
  8023cd:	57                   	push   %edi
  8023ce:	56                   	push   %esi
  8023cf:	53                   	push   %ebx
  8023d0:	83 ec 0c             	sub    $0xc,%esp
  8023d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023d6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8023dc:	85 db                	test   %ebx,%ebx
  8023de:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023e3:	0f 44 d8             	cmove  %eax,%ebx
  8023e6:	eb 05                	jmp    8023ed <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8023e8:	e8 a8 eb ff ff       	call   800f95 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8023ed:	ff 75 14             	push   0x14(%ebp)
  8023f0:	53                   	push   %ebx
  8023f1:	56                   	push   %esi
  8023f2:	57                   	push   %edi
  8023f3:	e8 49 ed ff ff       	call   801141 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8023f8:	83 c4 10             	add    $0x10,%esp
  8023fb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023fe:	74 e8                	je     8023e8 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802400:	85 c0                	test   %eax,%eax
  802402:	78 08                	js     80240c <ipc_send+0x42>
	}while (r<0);

}
  802404:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802407:	5b                   	pop    %ebx
  802408:	5e                   	pop    %esi
  802409:	5f                   	pop    %edi
  80240a:	5d                   	pop    %ebp
  80240b:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80240c:	50                   	push   %eax
  80240d:	68 97 2c 80 00       	push   $0x802c97
  802412:	6a 3d                	push   $0x3d
  802414:	68 ab 2c 80 00       	push   $0x802cab
  802419:	e8 f6 fe ff ff       	call   802314 <_panic>

0080241e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80241e:	55                   	push   %ebp
  80241f:	89 e5                	mov    %esp,%ebp
  802421:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802424:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802429:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  80242f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802435:	8b 52 60             	mov    0x60(%edx),%edx
  802438:	39 ca                	cmp    %ecx,%edx
  80243a:	74 11                	je     80244d <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  80243c:	83 c0 01             	add    $0x1,%eax
  80243f:	3d 00 04 00 00       	cmp    $0x400,%eax
  802444:	75 e3                	jne    802429 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802446:	b8 00 00 00 00       	mov    $0x0,%eax
  80244b:	eb 0e                	jmp    80245b <ipc_find_env+0x3d>
			return envs[i].env_id;
  80244d:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  802453:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802458:	8b 40 58             	mov    0x58(%eax),%eax
}
  80245b:	5d                   	pop    %ebp
  80245c:	c3                   	ret    

0080245d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80245d:	55                   	push   %ebp
  80245e:	89 e5                	mov    %esp,%ebp
  802460:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802463:	89 c2                	mov    %eax,%edx
  802465:	c1 ea 16             	shr    $0x16,%edx
  802468:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80246f:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802474:	f6 c1 01             	test   $0x1,%cl
  802477:	74 1c                	je     802495 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802479:	c1 e8 0c             	shr    $0xc,%eax
  80247c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802483:	a8 01                	test   $0x1,%al
  802485:	74 0e                	je     802495 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802487:	c1 e8 0c             	shr    $0xc,%eax
  80248a:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802491:	ef 
  802492:	0f b7 d2             	movzwl %dx,%edx
}
  802495:	89 d0                	mov    %edx,%eax
  802497:	5d                   	pop    %ebp
  802498:	c3                   	ret    
  802499:	66 90                	xchg   %ax,%ax
  80249b:	66 90                	xchg   %ax,%ax
  80249d:	66 90                	xchg   %ax,%ax
  80249f:	90                   	nop

008024a0 <__udivdi3>:
  8024a0:	f3 0f 1e fb          	endbr32 
  8024a4:	55                   	push   %ebp
  8024a5:	57                   	push   %edi
  8024a6:	56                   	push   %esi
  8024a7:	53                   	push   %ebx
  8024a8:	83 ec 1c             	sub    $0x1c,%esp
  8024ab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8024af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8024b3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8024bb:	85 c0                	test   %eax,%eax
  8024bd:	75 19                	jne    8024d8 <__udivdi3+0x38>
  8024bf:	39 f3                	cmp    %esi,%ebx
  8024c1:	76 4d                	jbe    802510 <__udivdi3+0x70>
  8024c3:	31 ff                	xor    %edi,%edi
  8024c5:	89 e8                	mov    %ebp,%eax
  8024c7:	89 f2                	mov    %esi,%edx
  8024c9:	f7 f3                	div    %ebx
  8024cb:	89 fa                	mov    %edi,%edx
  8024cd:	83 c4 1c             	add    $0x1c,%esp
  8024d0:	5b                   	pop    %ebx
  8024d1:	5e                   	pop    %esi
  8024d2:	5f                   	pop    %edi
  8024d3:	5d                   	pop    %ebp
  8024d4:	c3                   	ret    
  8024d5:	8d 76 00             	lea    0x0(%esi),%esi
  8024d8:	39 f0                	cmp    %esi,%eax
  8024da:	76 14                	jbe    8024f0 <__udivdi3+0x50>
  8024dc:	31 ff                	xor    %edi,%edi
  8024de:	31 c0                	xor    %eax,%eax
  8024e0:	89 fa                	mov    %edi,%edx
  8024e2:	83 c4 1c             	add    $0x1c,%esp
  8024e5:	5b                   	pop    %ebx
  8024e6:	5e                   	pop    %esi
  8024e7:	5f                   	pop    %edi
  8024e8:	5d                   	pop    %ebp
  8024e9:	c3                   	ret    
  8024ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024f0:	0f bd f8             	bsr    %eax,%edi
  8024f3:	83 f7 1f             	xor    $0x1f,%edi
  8024f6:	75 48                	jne    802540 <__udivdi3+0xa0>
  8024f8:	39 f0                	cmp    %esi,%eax
  8024fa:	72 06                	jb     802502 <__udivdi3+0x62>
  8024fc:	31 c0                	xor    %eax,%eax
  8024fe:	39 eb                	cmp    %ebp,%ebx
  802500:	77 de                	ja     8024e0 <__udivdi3+0x40>
  802502:	b8 01 00 00 00       	mov    $0x1,%eax
  802507:	eb d7                	jmp    8024e0 <__udivdi3+0x40>
  802509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802510:	89 d9                	mov    %ebx,%ecx
  802512:	85 db                	test   %ebx,%ebx
  802514:	75 0b                	jne    802521 <__udivdi3+0x81>
  802516:	b8 01 00 00 00       	mov    $0x1,%eax
  80251b:	31 d2                	xor    %edx,%edx
  80251d:	f7 f3                	div    %ebx
  80251f:	89 c1                	mov    %eax,%ecx
  802521:	31 d2                	xor    %edx,%edx
  802523:	89 f0                	mov    %esi,%eax
  802525:	f7 f1                	div    %ecx
  802527:	89 c6                	mov    %eax,%esi
  802529:	89 e8                	mov    %ebp,%eax
  80252b:	89 f7                	mov    %esi,%edi
  80252d:	f7 f1                	div    %ecx
  80252f:	89 fa                	mov    %edi,%edx
  802531:	83 c4 1c             	add    $0x1c,%esp
  802534:	5b                   	pop    %ebx
  802535:	5e                   	pop    %esi
  802536:	5f                   	pop    %edi
  802537:	5d                   	pop    %ebp
  802538:	c3                   	ret    
  802539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802540:	89 f9                	mov    %edi,%ecx
  802542:	ba 20 00 00 00       	mov    $0x20,%edx
  802547:	29 fa                	sub    %edi,%edx
  802549:	d3 e0                	shl    %cl,%eax
  80254b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80254f:	89 d1                	mov    %edx,%ecx
  802551:	89 d8                	mov    %ebx,%eax
  802553:	d3 e8                	shr    %cl,%eax
  802555:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802559:	09 c1                	or     %eax,%ecx
  80255b:	89 f0                	mov    %esi,%eax
  80255d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802561:	89 f9                	mov    %edi,%ecx
  802563:	d3 e3                	shl    %cl,%ebx
  802565:	89 d1                	mov    %edx,%ecx
  802567:	d3 e8                	shr    %cl,%eax
  802569:	89 f9                	mov    %edi,%ecx
  80256b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80256f:	89 eb                	mov    %ebp,%ebx
  802571:	d3 e6                	shl    %cl,%esi
  802573:	89 d1                	mov    %edx,%ecx
  802575:	d3 eb                	shr    %cl,%ebx
  802577:	09 f3                	or     %esi,%ebx
  802579:	89 c6                	mov    %eax,%esi
  80257b:	89 f2                	mov    %esi,%edx
  80257d:	89 d8                	mov    %ebx,%eax
  80257f:	f7 74 24 08          	divl   0x8(%esp)
  802583:	89 d6                	mov    %edx,%esi
  802585:	89 c3                	mov    %eax,%ebx
  802587:	f7 64 24 0c          	mull   0xc(%esp)
  80258b:	39 d6                	cmp    %edx,%esi
  80258d:	72 19                	jb     8025a8 <__udivdi3+0x108>
  80258f:	89 f9                	mov    %edi,%ecx
  802591:	d3 e5                	shl    %cl,%ebp
  802593:	39 c5                	cmp    %eax,%ebp
  802595:	73 04                	jae    80259b <__udivdi3+0xfb>
  802597:	39 d6                	cmp    %edx,%esi
  802599:	74 0d                	je     8025a8 <__udivdi3+0x108>
  80259b:	89 d8                	mov    %ebx,%eax
  80259d:	31 ff                	xor    %edi,%edi
  80259f:	e9 3c ff ff ff       	jmp    8024e0 <__udivdi3+0x40>
  8025a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025a8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8025ab:	31 ff                	xor    %edi,%edi
  8025ad:	e9 2e ff ff ff       	jmp    8024e0 <__udivdi3+0x40>
  8025b2:	66 90                	xchg   %ax,%ax
  8025b4:	66 90                	xchg   %ax,%ax
  8025b6:	66 90                	xchg   %ax,%ax
  8025b8:	66 90                	xchg   %ax,%ax
  8025ba:	66 90                	xchg   %ax,%ax
  8025bc:	66 90                	xchg   %ax,%ax
  8025be:	66 90                	xchg   %ax,%ax

008025c0 <__umoddi3>:
  8025c0:	f3 0f 1e fb          	endbr32 
  8025c4:	55                   	push   %ebp
  8025c5:	57                   	push   %edi
  8025c6:	56                   	push   %esi
  8025c7:	53                   	push   %ebx
  8025c8:	83 ec 1c             	sub    $0x1c,%esp
  8025cb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8025cf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8025d3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8025d7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8025db:	89 f0                	mov    %esi,%eax
  8025dd:	89 da                	mov    %ebx,%edx
  8025df:	85 ff                	test   %edi,%edi
  8025e1:	75 15                	jne    8025f8 <__umoddi3+0x38>
  8025e3:	39 dd                	cmp    %ebx,%ebp
  8025e5:	76 39                	jbe    802620 <__umoddi3+0x60>
  8025e7:	f7 f5                	div    %ebp
  8025e9:	89 d0                	mov    %edx,%eax
  8025eb:	31 d2                	xor    %edx,%edx
  8025ed:	83 c4 1c             	add    $0x1c,%esp
  8025f0:	5b                   	pop    %ebx
  8025f1:	5e                   	pop    %esi
  8025f2:	5f                   	pop    %edi
  8025f3:	5d                   	pop    %ebp
  8025f4:	c3                   	ret    
  8025f5:	8d 76 00             	lea    0x0(%esi),%esi
  8025f8:	39 df                	cmp    %ebx,%edi
  8025fa:	77 f1                	ja     8025ed <__umoddi3+0x2d>
  8025fc:	0f bd cf             	bsr    %edi,%ecx
  8025ff:	83 f1 1f             	xor    $0x1f,%ecx
  802602:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802606:	75 40                	jne    802648 <__umoddi3+0x88>
  802608:	39 df                	cmp    %ebx,%edi
  80260a:	72 04                	jb     802610 <__umoddi3+0x50>
  80260c:	39 f5                	cmp    %esi,%ebp
  80260e:	77 dd                	ja     8025ed <__umoddi3+0x2d>
  802610:	89 da                	mov    %ebx,%edx
  802612:	89 f0                	mov    %esi,%eax
  802614:	29 e8                	sub    %ebp,%eax
  802616:	19 fa                	sbb    %edi,%edx
  802618:	eb d3                	jmp    8025ed <__umoddi3+0x2d>
  80261a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802620:	89 e9                	mov    %ebp,%ecx
  802622:	85 ed                	test   %ebp,%ebp
  802624:	75 0b                	jne    802631 <__umoddi3+0x71>
  802626:	b8 01 00 00 00       	mov    $0x1,%eax
  80262b:	31 d2                	xor    %edx,%edx
  80262d:	f7 f5                	div    %ebp
  80262f:	89 c1                	mov    %eax,%ecx
  802631:	89 d8                	mov    %ebx,%eax
  802633:	31 d2                	xor    %edx,%edx
  802635:	f7 f1                	div    %ecx
  802637:	89 f0                	mov    %esi,%eax
  802639:	f7 f1                	div    %ecx
  80263b:	89 d0                	mov    %edx,%eax
  80263d:	31 d2                	xor    %edx,%edx
  80263f:	eb ac                	jmp    8025ed <__umoddi3+0x2d>
  802641:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802648:	8b 44 24 04          	mov    0x4(%esp),%eax
  80264c:	ba 20 00 00 00       	mov    $0x20,%edx
  802651:	29 c2                	sub    %eax,%edx
  802653:	89 c1                	mov    %eax,%ecx
  802655:	89 e8                	mov    %ebp,%eax
  802657:	d3 e7                	shl    %cl,%edi
  802659:	89 d1                	mov    %edx,%ecx
  80265b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80265f:	d3 e8                	shr    %cl,%eax
  802661:	89 c1                	mov    %eax,%ecx
  802663:	8b 44 24 04          	mov    0x4(%esp),%eax
  802667:	09 f9                	or     %edi,%ecx
  802669:	89 df                	mov    %ebx,%edi
  80266b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80266f:	89 c1                	mov    %eax,%ecx
  802671:	d3 e5                	shl    %cl,%ebp
  802673:	89 d1                	mov    %edx,%ecx
  802675:	d3 ef                	shr    %cl,%edi
  802677:	89 c1                	mov    %eax,%ecx
  802679:	89 f0                	mov    %esi,%eax
  80267b:	d3 e3                	shl    %cl,%ebx
  80267d:	89 d1                	mov    %edx,%ecx
  80267f:	89 fa                	mov    %edi,%edx
  802681:	d3 e8                	shr    %cl,%eax
  802683:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802688:	09 d8                	or     %ebx,%eax
  80268a:	f7 74 24 08          	divl   0x8(%esp)
  80268e:	89 d3                	mov    %edx,%ebx
  802690:	d3 e6                	shl    %cl,%esi
  802692:	f7 e5                	mul    %ebp
  802694:	89 c7                	mov    %eax,%edi
  802696:	89 d1                	mov    %edx,%ecx
  802698:	39 d3                	cmp    %edx,%ebx
  80269a:	72 06                	jb     8026a2 <__umoddi3+0xe2>
  80269c:	75 0e                	jne    8026ac <__umoddi3+0xec>
  80269e:	39 c6                	cmp    %eax,%esi
  8026a0:	73 0a                	jae    8026ac <__umoddi3+0xec>
  8026a2:	29 e8                	sub    %ebp,%eax
  8026a4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8026a8:	89 d1                	mov    %edx,%ecx
  8026aa:	89 c7                	mov    %eax,%edi
  8026ac:	89 f5                	mov    %esi,%ebp
  8026ae:	8b 74 24 04          	mov    0x4(%esp),%esi
  8026b2:	29 fd                	sub    %edi,%ebp
  8026b4:	19 cb                	sbb    %ecx,%ebx
  8026b6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8026bb:	89 d8                	mov    %ebx,%eax
  8026bd:	d3 e0                	shl    %cl,%eax
  8026bf:	89 f1                	mov    %esi,%ecx
  8026c1:	d3 ed                	shr    %cl,%ebp
  8026c3:	d3 eb                	shr    %cl,%ebx
  8026c5:	09 e8                	or     %ebp,%eax
  8026c7:	89 da                	mov    %ebx,%edx
  8026c9:	83 c4 1c             	add    $0x1c,%esp
  8026cc:	5b                   	pop    %ebx
  8026cd:	5e                   	pop    %esi
  8026ce:	5f                   	pop    %edi
  8026cf:	5d                   	pop    %ebp
  8026d0:	c3                   	ret    
