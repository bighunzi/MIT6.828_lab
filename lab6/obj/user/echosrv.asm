
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
  80003f:	e8 97 05 00 00       	call   8005db <cprintf>
	exit();
  800044:	e8 e3 04 00 00       	call   80052c <exit>
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
  800061:	e8 7d 14 00 00       	call   8014e3 <read>
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
  800080:	e8 22 13 00 00       	call   8013a7 <close>
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
  800097:	e8 47 14 00 00       	call   8014e3 <read>
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
  8000af:	e8 fd 14 00 00       	call   8015b1 <write>
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
  8000e2:	e8 ed 1a 00 00       	call   801bd4 <socket>
  8000e7:	89 c6                	mov    %eax,%esi
  8000e9:	83 c4 10             	add    $0x10,%esp
  8000ec:	85 c0                	test   %eax,%eax
  8000ee:	0f 88 86 00 00 00    	js     80017a <umain+0xa7>
		die("Failed to create socket");

	cprintf("opened socket\n");
  8000f4:	83 ec 0c             	sub    $0xc,%esp
  8000f7:	68 f8 26 80 00       	push   $0x8026f8
  8000fc:	e8 da 04 00 00       	call   8005db <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  800101:	83 c4 0c             	add    $0xc,%esp
  800104:	6a 10                	push   $0x10
  800106:	6a 00                	push   $0x0
  800108:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  80010b:	53                   	push   %ebx
  80010c:	e8 f4 0b 00 00       	call   800d05 <memset>
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
  80013b:	e8 9b 04 00 00       	call   8005db <cprintf>

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &echoserver,
  800140:	83 c4 0c             	add    $0xc,%esp
  800143:	6a 10                	push   $0x10
  800145:	53                   	push   %ebx
  800146:	56                   	push   %esi
  800147:	e8 f6 19 00 00       	call   801b42 <bind>
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
  800159:	e8 53 1a 00 00       	call   801bb1 <listen>
  80015e:	83 c4 10             	add    $0x10,%esp
  800161:	85 c0                	test   %eax,%eax
  800163:	78 30                	js     800195 <umain+0xc2>
		die("Failed to listen on server socket");

	cprintf("bound\n");
  800165:	83 ec 0c             	sub    $0xc,%esp
  800168:	68 17 27 80 00       	push   $0x802717
  80016d:	e8 69 04 00 00       	call   8005db <cprintf>
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
  8001bf:	e8 17 04 00 00       	call   8005db <cprintf>
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
  8001df:	e8 2f 19 00 00       	call   801b13 <accept>
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
  8004f1:	e8 7d 0a 00 00       	call   800f73 <sys_getenvid>
  8004f6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004fb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8004fe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800503:	a3 10 40 80 00       	mov    %eax,0x804010

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800508:	85 db                	test   %ebx,%ebx
  80050a:	7e 07                	jle    800513 <libmain+0x2d>
		binaryname = argv[0];
  80050c:	8b 06                	mov    (%esi),%eax
  80050e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800513:	83 ec 08             	sub    $0x8,%esp
  800516:	56                   	push   %esi
  800517:	53                   	push   %ebx
  800518:	e8 b6 fb ff ff       	call   8000d3 <umain>

	// exit gracefully
	exit();
  80051d:	e8 0a 00 00 00       	call   80052c <exit>
}
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800528:	5b                   	pop    %ebx
  800529:	5e                   	pop    %esi
  80052a:	5d                   	pop    %ebp
  80052b:	c3                   	ret    

0080052c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80052c:	55                   	push   %ebp
  80052d:	89 e5                	mov    %esp,%ebp
  80052f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800532:	e8 9d 0e 00 00       	call   8013d4 <close_all>
	sys_env_destroy(0);
  800537:	83 ec 0c             	sub    $0xc,%esp
  80053a:	6a 00                	push   $0x0
  80053c:	e8 f1 09 00 00       	call   800f32 <sys_env_destroy>
}
  800541:	83 c4 10             	add    $0x10,%esp
  800544:	c9                   	leave  
  800545:	c3                   	ret    

00800546 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800546:	55                   	push   %ebp
  800547:	89 e5                	mov    %esp,%ebp
  800549:	53                   	push   %ebx
  80054a:	83 ec 04             	sub    $0x4,%esp
  80054d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800550:	8b 13                	mov    (%ebx),%edx
  800552:	8d 42 01             	lea    0x1(%edx),%eax
  800555:	89 03                	mov    %eax,(%ebx)
  800557:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80055a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80055e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800563:	74 09                	je     80056e <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800565:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800569:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056c:	c9                   	leave  
  80056d:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	68 ff 00 00 00       	push   $0xff
  800576:	8d 43 08             	lea    0x8(%ebx),%eax
  800579:	50                   	push   %eax
  80057a:	e8 76 09 00 00       	call   800ef5 <sys_cputs>
		b->idx = 0;
  80057f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800585:	83 c4 10             	add    $0x10,%esp
  800588:	eb db                	jmp    800565 <putch+0x1f>

0080058a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80058a:	55                   	push   %ebp
  80058b:	89 e5                	mov    %esp,%ebp
  80058d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800593:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80059a:	00 00 00 
	b.cnt = 0;
  80059d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005a4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005a7:	ff 75 0c             	push   0xc(%ebp)
  8005aa:	ff 75 08             	push   0x8(%ebp)
  8005ad:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005b3:	50                   	push   %eax
  8005b4:	68 46 05 80 00       	push   $0x800546
  8005b9:	e8 14 01 00 00       	call   8006d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005be:	83 c4 08             	add    $0x8,%esp
  8005c1:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8005c7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005cd:	50                   	push   %eax
  8005ce:	e8 22 09 00 00       	call   800ef5 <sys_cputs>

	return b.cnt;
}
  8005d3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005d9:	c9                   	leave  
  8005da:	c3                   	ret    

008005db <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005db:	55                   	push   %ebp
  8005dc:	89 e5                	mov    %esp,%ebp
  8005de:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005e1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005e4:	50                   	push   %eax
  8005e5:	ff 75 08             	push   0x8(%ebp)
  8005e8:	e8 9d ff ff ff       	call   80058a <vcprintf>
	va_end(ap);

	return cnt;
}
  8005ed:	c9                   	leave  
  8005ee:	c3                   	ret    

008005ef <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005ef:	55                   	push   %ebp
  8005f0:	89 e5                	mov    %esp,%ebp
  8005f2:	57                   	push   %edi
  8005f3:	56                   	push   %esi
  8005f4:	53                   	push   %ebx
  8005f5:	83 ec 1c             	sub    $0x1c,%esp
  8005f8:	89 c7                	mov    %eax,%edi
  8005fa:	89 d6                	mov    %edx,%esi
  8005fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800602:	89 d1                	mov    %edx,%ecx
  800604:	89 c2                	mov    %eax,%edx
  800606:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800609:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80060c:	8b 45 10             	mov    0x10(%ebp),%eax
  80060f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800612:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800615:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80061c:	39 c2                	cmp    %eax,%edx
  80061e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800621:	72 3e                	jb     800661 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800623:	83 ec 0c             	sub    $0xc,%esp
  800626:	ff 75 18             	push   0x18(%ebp)
  800629:	83 eb 01             	sub    $0x1,%ebx
  80062c:	53                   	push   %ebx
  80062d:	50                   	push   %eax
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	ff 75 e4             	push   -0x1c(%ebp)
  800634:	ff 75 e0             	push   -0x20(%ebp)
  800637:	ff 75 dc             	push   -0x24(%ebp)
  80063a:	ff 75 d8             	push   -0x28(%ebp)
  80063d:	e8 4e 1e 00 00       	call   802490 <__udivdi3>
  800642:	83 c4 18             	add    $0x18,%esp
  800645:	52                   	push   %edx
  800646:	50                   	push   %eax
  800647:	89 f2                	mov    %esi,%edx
  800649:	89 f8                	mov    %edi,%eax
  80064b:	e8 9f ff ff ff       	call   8005ef <printnum>
  800650:	83 c4 20             	add    $0x20,%esp
  800653:	eb 13                	jmp    800668 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	56                   	push   %esi
  800659:	ff 75 18             	push   0x18(%ebp)
  80065c:	ff d7                	call   *%edi
  80065e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800661:	83 eb 01             	sub    $0x1,%ebx
  800664:	85 db                	test   %ebx,%ebx
  800666:	7f ed                	jg     800655 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	56                   	push   %esi
  80066c:	83 ec 04             	sub    $0x4,%esp
  80066f:	ff 75 e4             	push   -0x1c(%ebp)
  800672:	ff 75 e0             	push   -0x20(%ebp)
  800675:	ff 75 dc             	push   -0x24(%ebp)
  800678:	ff 75 d8             	push   -0x28(%ebp)
  80067b:	e8 30 1f 00 00       	call   8025b0 <__umoddi3>
  800680:	83 c4 14             	add    $0x14,%esp
  800683:	0f be 80 25 28 80 00 	movsbl 0x802825(%eax),%eax
  80068a:	50                   	push   %eax
  80068b:	ff d7                	call   *%edi
}
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800693:	5b                   	pop    %ebx
  800694:	5e                   	pop    %esi
  800695:	5f                   	pop    %edi
  800696:	5d                   	pop    %ebp
  800697:	c3                   	ret    

00800698 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800698:	55                   	push   %ebp
  800699:	89 e5                	mov    %esp,%ebp
  80069b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80069e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006a2:	8b 10                	mov    (%eax),%edx
  8006a4:	3b 50 04             	cmp    0x4(%eax),%edx
  8006a7:	73 0a                	jae    8006b3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006a9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006ac:	89 08                	mov    %ecx,(%eax)
  8006ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b1:	88 02                	mov    %al,(%edx)
}
  8006b3:	5d                   	pop    %ebp
  8006b4:	c3                   	ret    

008006b5 <printfmt>:
{
  8006b5:	55                   	push   %ebp
  8006b6:	89 e5                	mov    %esp,%ebp
  8006b8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8006bb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006be:	50                   	push   %eax
  8006bf:	ff 75 10             	push   0x10(%ebp)
  8006c2:	ff 75 0c             	push   0xc(%ebp)
  8006c5:	ff 75 08             	push   0x8(%ebp)
  8006c8:	e8 05 00 00 00       	call   8006d2 <vprintfmt>
}
  8006cd:	83 c4 10             	add    $0x10,%esp
  8006d0:	c9                   	leave  
  8006d1:	c3                   	ret    

008006d2 <vprintfmt>:
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	57                   	push   %edi
  8006d6:	56                   	push   %esi
  8006d7:	53                   	push   %ebx
  8006d8:	83 ec 3c             	sub    $0x3c,%esp
  8006db:	8b 75 08             	mov    0x8(%ebp),%esi
  8006de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006e4:	eb 0a                	jmp    8006f0 <vprintfmt+0x1e>
			putch(ch, putdat);
  8006e6:	83 ec 08             	sub    $0x8,%esp
  8006e9:	53                   	push   %ebx
  8006ea:	50                   	push   %eax
  8006eb:	ff d6                	call   *%esi
  8006ed:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f0:	83 c7 01             	add    $0x1,%edi
  8006f3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006f7:	83 f8 25             	cmp    $0x25,%eax
  8006fa:	74 0c                	je     800708 <vprintfmt+0x36>
			if (ch == '\0')
  8006fc:	85 c0                	test   %eax,%eax
  8006fe:	75 e6                	jne    8006e6 <vprintfmt+0x14>
}
  800700:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800703:	5b                   	pop    %ebx
  800704:	5e                   	pop    %esi
  800705:	5f                   	pop    %edi
  800706:	5d                   	pop    %ebp
  800707:	c3                   	ret    
		padc = ' ';
  800708:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80070c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800713:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80071a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800721:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8d 47 01             	lea    0x1(%edi),%eax
  800729:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80072c:	0f b6 17             	movzbl (%edi),%edx
  80072f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800732:	3c 55                	cmp    $0x55,%al
  800734:	0f 87 bb 03 00 00    	ja     800af5 <vprintfmt+0x423>
  80073a:	0f b6 c0             	movzbl %al,%eax
  80073d:	ff 24 85 60 29 80 00 	jmp    *0x802960(,%eax,4)
  800744:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800747:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80074b:	eb d9                	jmp    800726 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80074d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800750:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800754:	eb d0                	jmp    800726 <vprintfmt+0x54>
  800756:	0f b6 d2             	movzbl %dl,%edx
  800759:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80075c:	b8 00 00 00 00       	mov    $0x0,%eax
  800761:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800764:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800767:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80076b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80076e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800771:	83 f9 09             	cmp    $0x9,%ecx
  800774:	77 55                	ja     8007cb <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800776:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800779:	eb e9                	jmp    800764 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80077b:	8b 45 14             	mov    0x14(%ebp),%eax
  80077e:	8b 00                	mov    (%eax),%eax
  800780:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8d 40 04             	lea    0x4(%eax),%eax
  800789:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80078c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80078f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800793:	79 91                	jns    800726 <vprintfmt+0x54>
				width = precision, precision = -1;
  800795:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800798:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80079b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8007a2:	eb 82                	jmp    800726 <vprintfmt+0x54>
  8007a4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007a7:	85 d2                	test   %edx,%edx
  8007a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ae:	0f 49 c2             	cmovns %edx,%eax
  8007b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8007b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8007b7:	e9 6a ff ff ff       	jmp    800726 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8007bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8007bf:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8007c6:	e9 5b ff ff ff       	jmp    800726 <vprintfmt+0x54>
  8007cb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8007ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d1:	eb bc                	jmp    80078f <vprintfmt+0xbd>
			lflag++;
  8007d3:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8007d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8007d9:	e9 48 ff ff ff       	jmp    800726 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8007de:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e1:	8d 78 04             	lea    0x4(%eax),%edi
  8007e4:	83 ec 08             	sub    $0x8,%esp
  8007e7:	53                   	push   %ebx
  8007e8:	ff 30                	push   (%eax)
  8007ea:	ff d6                	call   *%esi
			break;
  8007ec:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8007ef:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8007f2:	e9 9d 02 00 00       	jmp    800a94 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8007f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fa:	8d 78 04             	lea    0x4(%eax),%edi
  8007fd:	8b 10                	mov    (%eax),%edx
  8007ff:	89 d0                	mov    %edx,%eax
  800801:	f7 d8                	neg    %eax
  800803:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800806:	83 f8 0f             	cmp    $0xf,%eax
  800809:	7f 23                	jg     80082e <vprintfmt+0x15c>
  80080b:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  800812:	85 d2                	test   %edx,%edx
  800814:	74 18                	je     80082e <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800816:	52                   	push   %edx
  800817:	68 f5 2b 80 00       	push   $0x802bf5
  80081c:	53                   	push   %ebx
  80081d:	56                   	push   %esi
  80081e:	e8 92 fe ff ff       	call   8006b5 <printfmt>
  800823:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800826:	89 7d 14             	mov    %edi,0x14(%ebp)
  800829:	e9 66 02 00 00       	jmp    800a94 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80082e:	50                   	push   %eax
  80082f:	68 3d 28 80 00       	push   $0x80283d
  800834:	53                   	push   %ebx
  800835:	56                   	push   %esi
  800836:	e8 7a fe ff ff       	call   8006b5 <printfmt>
  80083b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80083e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800841:	e9 4e 02 00 00       	jmp    800a94 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800846:	8b 45 14             	mov    0x14(%ebp),%eax
  800849:	83 c0 04             	add    $0x4,%eax
  80084c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80084f:	8b 45 14             	mov    0x14(%ebp),%eax
  800852:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800854:	85 d2                	test   %edx,%edx
  800856:	b8 36 28 80 00       	mov    $0x802836,%eax
  80085b:	0f 45 c2             	cmovne %edx,%eax
  80085e:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800861:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800865:	7e 06                	jle    80086d <vprintfmt+0x19b>
  800867:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80086b:	75 0d                	jne    80087a <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80086d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800870:	89 c7                	mov    %eax,%edi
  800872:	03 45 e0             	add    -0x20(%ebp),%eax
  800875:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800878:	eb 55                	jmp    8008cf <vprintfmt+0x1fd>
  80087a:	83 ec 08             	sub    $0x8,%esp
  80087d:	ff 75 d8             	push   -0x28(%ebp)
  800880:	ff 75 cc             	push   -0x34(%ebp)
  800883:	e8 0a 03 00 00       	call   800b92 <strnlen>
  800888:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80088b:	29 c1                	sub    %eax,%ecx
  80088d:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800890:	83 c4 10             	add    $0x10,%esp
  800893:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800895:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800899:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80089c:	eb 0f                	jmp    8008ad <vprintfmt+0x1db>
					putch(padc, putdat);
  80089e:	83 ec 08             	sub    $0x8,%esp
  8008a1:	53                   	push   %ebx
  8008a2:	ff 75 e0             	push   -0x20(%ebp)
  8008a5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8008a7:	83 ef 01             	sub    $0x1,%edi
  8008aa:	83 c4 10             	add    $0x10,%esp
  8008ad:	85 ff                	test   %edi,%edi
  8008af:	7f ed                	jg     80089e <vprintfmt+0x1cc>
  8008b1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8008b4:	85 d2                	test   %edx,%edx
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bb:	0f 49 c2             	cmovns %edx,%eax
  8008be:	29 c2                	sub    %eax,%edx
  8008c0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8008c3:	eb a8                	jmp    80086d <vprintfmt+0x19b>
					putch(ch, putdat);
  8008c5:	83 ec 08             	sub    $0x8,%esp
  8008c8:	53                   	push   %ebx
  8008c9:	52                   	push   %edx
  8008ca:	ff d6                	call   *%esi
  8008cc:	83 c4 10             	add    $0x10,%esp
  8008cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008d2:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008d4:	83 c7 01             	add    $0x1,%edi
  8008d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008db:	0f be d0             	movsbl %al,%edx
  8008de:	85 d2                	test   %edx,%edx
  8008e0:	74 4b                	je     80092d <vprintfmt+0x25b>
  8008e2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008e6:	78 06                	js     8008ee <vprintfmt+0x21c>
  8008e8:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8008ec:	78 1e                	js     80090c <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8008ee:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8008f2:	74 d1                	je     8008c5 <vprintfmt+0x1f3>
  8008f4:	0f be c0             	movsbl %al,%eax
  8008f7:	83 e8 20             	sub    $0x20,%eax
  8008fa:	83 f8 5e             	cmp    $0x5e,%eax
  8008fd:	76 c6                	jbe    8008c5 <vprintfmt+0x1f3>
					putch('?', putdat);
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	53                   	push   %ebx
  800903:	6a 3f                	push   $0x3f
  800905:	ff d6                	call   *%esi
  800907:	83 c4 10             	add    $0x10,%esp
  80090a:	eb c3                	jmp    8008cf <vprintfmt+0x1fd>
  80090c:	89 cf                	mov    %ecx,%edi
  80090e:	eb 0e                	jmp    80091e <vprintfmt+0x24c>
				putch(' ', putdat);
  800910:	83 ec 08             	sub    $0x8,%esp
  800913:	53                   	push   %ebx
  800914:	6a 20                	push   $0x20
  800916:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800918:	83 ef 01             	sub    $0x1,%edi
  80091b:	83 c4 10             	add    $0x10,%esp
  80091e:	85 ff                	test   %edi,%edi
  800920:	7f ee                	jg     800910 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800922:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800925:	89 45 14             	mov    %eax,0x14(%ebp)
  800928:	e9 67 01 00 00       	jmp    800a94 <vprintfmt+0x3c2>
  80092d:	89 cf                	mov    %ecx,%edi
  80092f:	eb ed                	jmp    80091e <vprintfmt+0x24c>
	if (lflag >= 2)
  800931:	83 f9 01             	cmp    $0x1,%ecx
  800934:	7f 1b                	jg     800951 <vprintfmt+0x27f>
	else if (lflag)
  800936:	85 c9                	test   %ecx,%ecx
  800938:	74 63                	je     80099d <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80093a:	8b 45 14             	mov    0x14(%ebp),%eax
  80093d:	8b 00                	mov    (%eax),%eax
  80093f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800942:	99                   	cltd   
  800943:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800946:	8b 45 14             	mov    0x14(%ebp),%eax
  800949:	8d 40 04             	lea    0x4(%eax),%eax
  80094c:	89 45 14             	mov    %eax,0x14(%ebp)
  80094f:	eb 17                	jmp    800968 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800951:	8b 45 14             	mov    0x14(%ebp),%eax
  800954:	8b 50 04             	mov    0x4(%eax),%edx
  800957:	8b 00                	mov    (%eax),%eax
  800959:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80095c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80095f:	8b 45 14             	mov    0x14(%ebp),%eax
  800962:	8d 40 08             	lea    0x8(%eax),%eax
  800965:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800968:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80096b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80096e:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800973:	85 c9                	test   %ecx,%ecx
  800975:	0f 89 ff 00 00 00    	jns    800a7a <vprintfmt+0x3a8>
				putch('-', putdat);
  80097b:	83 ec 08             	sub    $0x8,%esp
  80097e:	53                   	push   %ebx
  80097f:	6a 2d                	push   $0x2d
  800981:	ff d6                	call   *%esi
				num = -(long long) num;
  800983:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800986:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800989:	f7 da                	neg    %edx
  80098b:	83 d1 00             	adc    $0x0,%ecx
  80098e:	f7 d9                	neg    %ecx
  800990:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800993:	bf 0a 00 00 00       	mov    $0xa,%edi
  800998:	e9 dd 00 00 00       	jmp    800a7a <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80099d:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a0:	8b 00                	mov    (%eax),%eax
  8009a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009a5:	99                   	cltd   
  8009a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8009a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ac:	8d 40 04             	lea    0x4(%eax),%eax
  8009af:	89 45 14             	mov    %eax,0x14(%ebp)
  8009b2:	eb b4                	jmp    800968 <vprintfmt+0x296>
	if (lflag >= 2)
  8009b4:	83 f9 01             	cmp    $0x1,%ecx
  8009b7:	7f 1e                	jg     8009d7 <vprintfmt+0x305>
	else if (lflag)
  8009b9:	85 c9                	test   %ecx,%ecx
  8009bb:	74 32                	je     8009ef <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8009bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c0:	8b 10                	mov    (%eax),%edx
  8009c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009c7:	8d 40 04             	lea    0x4(%eax),%eax
  8009ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009cd:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8009d2:	e9 a3 00 00 00       	jmp    800a7a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8009d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009da:	8b 10                	mov    (%eax),%edx
  8009dc:	8b 48 04             	mov    0x4(%eax),%ecx
  8009df:	8d 40 08             	lea    0x8(%eax),%eax
  8009e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009e5:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8009ea:	e9 8b 00 00 00       	jmp    800a7a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8009ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f2:	8b 10                	mov    (%eax),%edx
  8009f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009f9:	8d 40 04             	lea    0x4(%eax),%eax
  8009fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009ff:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800a04:	eb 74                	jmp    800a7a <vprintfmt+0x3a8>
	if (lflag >= 2)
  800a06:	83 f9 01             	cmp    $0x1,%ecx
  800a09:	7f 1b                	jg     800a26 <vprintfmt+0x354>
	else if (lflag)
  800a0b:	85 c9                	test   %ecx,%ecx
  800a0d:	74 2c                	je     800a3b <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800a0f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a12:	8b 10                	mov    (%eax),%edx
  800a14:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a19:	8d 40 04             	lea    0x4(%eax),%eax
  800a1c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a1f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800a24:	eb 54                	jmp    800a7a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800a26:	8b 45 14             	mov    0x14(%ebp),%eax
  800a29:	8b 10                	mov    (%eax),%edx
  800a2b:	8b 48 04             	mov    0x4(%eax),%ecx
  800a2e:	8d 40 08             	lea    0x8(%eax),%eax
  800a31:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a34:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800a39:	eb 3f                	jmp    800a7a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800a3b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a3e:	8b 10                	mov    (%eax),%edx
  800a40:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a45:	8d 40 04             	lea    0x4(%eax),%eax
  800a48:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a4b:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800a50:	eb 28                	jmp    800a7a <vprintfmt+0x3a8>
			putch('0', putdat);
  800a52:	83 ec 08             	sub    $0x8,%esp
  800a55:	53                   	push   %ebx
  800a56:	6a 30                	push   $0x30
  800a58:	ff d6                	call   *%esi
			putch('x', putdat);
  800a5a:	83 c4 08             	add    $0x8,%esp
  800a5d:	53                   	push   %ebx
  800a5e:	6a 78                	push   $0x78
  800a60:	ff d6                	call   *%esi
			num = (unsigned long long)
  800a62:	8b 45 14             	mov    0x14(%ebp),%eax
  800a65:	8b 10                	mov    (%eax),%edx
  800a67:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800a6c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800a6f:	8d 40 04             	lea    0x4(%eax),%eax
  800a72:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a75:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800a7a:	83 ec 0c             	sub    $0xc,%esp
  800a7d:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800a81:	50                   	push   %eax
  800a82:	ff 75 e0             	push   -0x20(%ebp)
  800a85:	57                   	push   %edi
  800a86:	51                   	push   %ecx
  800a87:	52                   	push   %edx
  800a88:	89 da                	mov    %ebx,%edx
  800a8a:	89 f0                	mov    %esi,%eax
  800a8c:	e8 5e fb ff ff       	call   8005ef <printnum>
			break;
  800a91:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800a94:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a97:	e9 54 fc ff ff       	jmp    8006f0 <vprintfmt+0x1e>
	if (lflag >= 2)
  800a9c:	83 f9 01             	cmp    $0x1,%ecx
  800a9f:	7f 1b                	jg     800abc <vprintfmt+0x3ea>
	else if (lflag)
  800aa1:	85 c9                	test   %ecx,%ecx
  800aa3:	74 2c                	je     800ad1 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800aa5:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa8:	8b 10                	mov    (%eax),%edx
  800aaa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aaf:	8d 40 04             	lea    0x4(%eax),%eax
  800ab2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ab5:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800aba:	eb be                	jmp    800a7a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800abc:	8b 45 14             	mov    0x14(%ebp),%eax
  800abf:	8b 10                	mov    (%eax),%edx
  800ac1:	8b 48 04             	mov    0x4(%eax),%ecx
  800ac4:	8d 40 08             	lea    0x8(%eax),%eax
  800ac7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800aca:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800acf:	eb a9                	jmp    800a7a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800ad1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad4:	8b 10                	mov    (%eax),%edx
  800ad6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800adb:	8d 40 04             	lea    0x4(%eax),%eax
  800ade:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ae1:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800ae6:	eb 92                	jmp    800a7a <vprintfmt+0x3a8>
			putch(ch, putdat);
  800ae8:	83 ec 08             	sub    $0x8,%esp
  800aeb:	53                   	push   %ebx
  800aec:	6a 25                	push   $0x25
  800aee:	ff d6                	call   *%esi
			break;
  800af0:	83 c4 10             	add    $0x10,%esp
  800af3:	eb 9f                	jmp    800a94 <vprintfmt+0x3c2>
			putch('%', putdat);
  800af5:	83 ec 08             	sub    $0x8,%esp
  800af8:	53                   	push   %ebx
  800af9:	6a 25                	push   $0x25
  800afb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800afd:	83 c4 10             	add    $0x10,%esp
  800b00:	89 f8                	mov    %edi,%eax
  800b02:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800b06:	74 05                	je     800b0d <vprintfmt+0x43b>
  800b08:	83 e8 01             	sub    $0x1,%eax
  800b0b:	eb f5                	jmp    800b02 <vprintfmt+0x430>
  800b0d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b10:	eb 82                	jmp    800a94 <vprintfmt+0x3c2>

00800b12 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	83 ec 18             	sub    $0x18,%esp
  800b18:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b21:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b25:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b28:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	74 26                	je     800b59 <vsnprintf+0x47>
  800b33:	85 d2                	test   %edx,%edx
  800b35:	7e 22                	jle    800b59 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b37:	ff 75 14             	push   0x14(%ebp)
  800b3a:	ff 75 10             	push   0x10(%ebp)
  800b3d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b40:	50                   	push   %eax
  800b41:	68 98 06 80 00       	push   $0x800698
  800b46:	e8 87 fb ff ff       	call   8006d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b4e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b54:	83 c4 10             	add    $0x10,%esp
}
  800b57:	c9                   	leave  
  800b58:	c3                   	ret    
		return -E_INVAL;
  800b59:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b5e:	eb f7                	jmp    800b57 <vsnprintf+0x45>

00800b60 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b66:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b69:	50                   	push   %eax
  800b6a:	ff 75 10             	push   0x10(%ebp)
  800b6d:	ff 75 0c             	push   0xc(%ebp)
  800b70:	ff 75 08             	push   0x8(%ebp)
  800b73:	e8 9a ff ff ff       	call   800b12 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b78:	c9                   	leave  
  800b79:	c3                   	ret    

00800b7a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b80:	b8 00 00 00 00       	mov    $0x0,%eax
  800b85:	eb 03                	jmp    800b8a <strlen+0x10>
		n++;
  800b87:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800b8a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b8e:	75 f7                	jne    800b87 <strlen+0xd>
	return n;
}
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b98:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba0:	eb 03                	jmp    800ba5 <strnlen+0x13>
		n++;
  800ba2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ba5:	39 d0                	cmp    %edx,%eax
  800ba7:	74 08                	je     800bb1 <strnlen+0x1f>
  800ba9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800bad:	75 f3                	jne    800ba2 <strnlen+0x10>
  800baf:	89 c2                	mov    %eax,%edx
	return n;
}
  800bb1:	89 d0                	mov    %edx,%eax
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	53                   	push   %ebx
  800bb9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bbc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc4:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800bc8:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800bcb:	83 c0 01             	add    $0x1,%eax
  800bce:	84 d2                	test   %dl,%dl
  800bd0:	75 f2                	jne    800bc4 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bd2:	89 c8                	mov    %ecx,%eax
  800bd4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    

00800bd9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	53                   	push   %ebx
  800bdd:	83 ec 10             	sub    $0x10,%esp
  800be0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800be3:	53                   	push   %ebx
  800be4:	e8 91 ff ff ff       	call   800b7a <strlen>
  800be9:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800bec:	ff 75 0c             	push   0xc(%ebp)
  800bef:	01 d8                	add    %ebx,%eax
  800bf1:	50                   	push   %eax
  800bf2:	e8 be ff ff ff       	call   800bb5 <strcpy>
	return dst;
}
  800bf7:	89 d8                	mov    %ebx,%eax
  800bf9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bfc:	c9                   	leave  
  800bfd:	c3                   	ret    

00800bfe <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	8b 75 08             	mov    0x8(%ebp),%esi
  800c06:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c09:	89 f3                	mov    %esi,%ebx
  800c0b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c0e:	89 f0                	mov    %esi,%eax
  800c10:	eb 0f                	jmp    800c21 <strncpy+0x23>
		*dst++ = *src;
  800c12:	83 c0 01             	add    $0x1,%eax
  800c15:	0f b6 0a             	movzbl (%edx),%ecx
  800c18:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c1b:	80 f9 01             	cmp    $0x1,%cl
  800c1e:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800c21:	39 d8                	cmp    %ebx,%eax
  800c23:	75 ed                	jne    800c12 <strncpy+0x14>
	}
	return ret;
}
  800c25:	89 f0                	mov    %esi,%eax
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	8b 75 08             	mov    0x8(%ebp),%esi
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c36:	8b 55 10             	mov    0x10(%ebp),%edx
  800c39:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c3b:	85 d2                	test   %edx,%edx
  800c3d:	74 21                	je     800c60 <strlcpy+0x35>
  800c3f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c43:	89 f2                	mov    %esi,%edx
  800c45:	eb 09                	jmp    800c50 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c47:	83 c1 01             	add    $0x1,%ecx
  800c4a:	83 c2 01             	add    $0x1,%edx
  800c4d:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800c50:	39 c2                	cmp    %eax,%edx
  800c52:	74 09                	je     800c5d <strlcpy+0x32>
  800c54:	0f b6 19             	movzbl (%ecx),%ebx
  800c57:	84 db                	test   %bl,%bl
  800c59:	75 ec                	jne    800c47 <strlcpy+0x1c>
  800c5b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800c5d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c60:	29 f0                	sub    %esi,%eax
}
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c6f:	eb 06                	jmp    800c77 <strcmp+0x11>
		p++, q++;
  800c71:	83 c1 01             	add    $0x1,%ecx
  800c74:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800c77:	0f b6 01             	movzbl (%ecx),%eax
  800c7a:	84 c0                	test   %al,%al
  800c7c:	74 04                	je     800c82 <strcmp+0x1c>
  800c7e:	3a 02                	cmp    (%edx),%al
  800c80:	74 ef                	je     800c71 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c82:	0f b6 c0             	movzbl %al,%eax
  800c85:	0f b6 12             	movzbl (%edx),%edx
  800c88:	29 d0                	sub    %edx,%eax
}
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	53                   	push   %ebx
  800c90:	8b 45 08             	mov    0x8(%ebp),%eax
  800c93:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c96:	89 c3                	mov    %eax,%ebx
  800c98:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c9b:	eb 06                	jmp    800ca3 <strncmp+0x17>
		n--, p++, q++;
  800c9d:	83 c0 01             	add    $0x1,%eax
  800ca0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ca3:	39 d8                	cmp    %ebx,%eax
  800ca5:	74 18                	je     800cbf <strncmp+0x33>
  800ca7:	0f b6 08             	movzbl (%eax),%ecx
  800caa:	84 c9                	test   %cl,%cl
  800cac:	74 04                	je     800cb2 <strncmp+0x26>
  800cae:	3a 0a                	cmp    (%edx),%cl
  800cb0:	74 eb                	je     800c9d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cb2:	0f b6 00             	movzbl (%eax),%eax
  800cb5:	0f b6 12             	movzbl (%edx),%edx
  800cb8:	29 d0                	sub    %edx,%eax
}
  800cba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cbd:	c9                   	leave  
  800cbe:	c3                   	ret    
		return 0;
  800cbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc4:	eb f4                	jmp    800cba <strncmp+0x2e>

00800cc6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cd0:	eb 03                	jmp    800cd5 <strchr+0xf>
  800cd2:	83 c0 01             	add    $0x1,%eax
  800cd5:	0f b6 10             	movzbl (%eax),%edx
  800cd8:	84 d2                	test   %dl,%dl
  800cda:	74 06                	je     800ce2 <strchr+0x1c>
		if (*s == c)
  800cdc:	38 ca                	cmp    %cl,%dl
  800cde:	75 f2                	jne    800cd2 <strchr+0xc>
  800ce0:	eb 05                	jmp    800ce7 <strchr+0x21>
			return (char *) s;
	return 0;
  800ce2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	8b 45 08             	mov    0x8(%ebp),%eax
  800cef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cf3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800cf6:	38 ca                	cmp    %cl,%dl
  800cf8:	74 09                	je     800d03 <strfind+0x1a>
  800cfa:	84 d2                	test   %dl,%dl
  800cfc:	74 05                	je     800d03 <strfind+0x1a>
	for (; *s; s++)
  800cfe:	83 c0 01             	add    $0x1,%eax
  800d01:	eb f0                	jmp    800cf3 <strfind+0xa>
			break;
	return (char *) s;
}
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
  800d0b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d11:	85 c9                	test   %ecx,%ecx
  800d13:	74 2f                	je     800d44 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d15:	89 f8                	mov    %edi,%eax
  800d17:	09 c8                	or     %ecx,%eax
  800d19:	a8 03                	test   $0x3,%al
  800d1b:	75 21                	jne    800d3e <memset+0x39>
		c &= 0xFF;
  800d1d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d21:	89 d0                	mov    %edx,%eax
  800d23:	c1 e0 08             	shl    $0x8,%eax
  800d26:	89 d3                	mov    %edx,%ebx
  800d28:	c1 e3 18             	shl    $0x18,%ebx
  800d2b:	89 d6                	mov    %edx,%esi
  800d2d:	c1 e6 10             	shl    $0x10,%esi
  800d30:	09 f3                	or     %esi,%ebx
  800d32:	09 da                	or     %ebx,%edx
  800d34:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d36:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800d39:	fc                   	cld    
  800d3a:	f3 ab                	rep stos %eax,%es:(%edi)
  800d3c:	eb 06                	jmp    800d44 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d41:	fc                   	cld    
  800d42:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d44:	89 f8                	mov    %edi,%eax
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	8b 45 08             	mov    0x8(%ebp),%eax
  800d53:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d56:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d59:	39 c6                	cmp    %eax,%esi
  800d5b:	73 32                	jae    800d8f <memmove+0x44>
  800d5d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d60:	39 c2                	cmp    %eax,%edx
  800d62:	76 2b                	jbe    800d8f <memmove+0x44>
		s += n;
		d += n;
  800d64:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d67:	89 d6                	mov    %edx,%esi
  800d69:	09 fe                	or     %edi,%esi
  800d6b:	09 ce                	or     %ecx,%esi
  800d6d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d73:	75 0e                	jne    800d83 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d75:	83 ef 04             	sub    $0x4,%edi
  800d78:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d7b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d7e:	fd                   	std    
  800d7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d81:	eb 09                	jmp    800d8c <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d83:	83 ef 01             	sub    $0x1,%edi
  800d86:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d89:	fd                   	std    
  800d8a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d8c:	fc                   	cld    
  800d8d:	eb 1a                	jmp    800da9 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d8f:	89 f2                	mov    %esi,%edx
  800d91:	09 c2                	or     %eax,%edx
  800d93:	09 ca                	or     %ecx,%edx
  800d95:	f6 c2 03             	test   $0x3,%dl
  800d98:	75 0a                	jne    800da4 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d9a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d9d:	89 c7                	mov    %eax,%edi
  800d9f:	fc                   	cld    
  800da0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800da2:	eb 05                	jmp    800da9 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800da4:	89 c7                	mov    %eax,%edi
  800da6:	fc                   	cld    
  800da7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800db3:	ff 75 10             	push   0x10(%ebp)
  800db6:	ff 75 0c             	push   0xc(%ebp)
  800db9:	ff 75 08             	push   0x8(%ebp)
  800dbc:	e8 8a ff ff ff       	call   800d4b <memmove>
}
  800dc1:	c9                   	leave  
  800dc2:	c3                   	ret    

00800dc3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
  800dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dce:	89 c6                	mov    %eax,%esi
  800dd0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dd3:	eb 06                	jmp    800ddb <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800dd5:	83 c0 01             	add    $0x1,%eax
  800dd8:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800ddb:	39 f0                	cmp    %esi,%eax
  800ddd:	74 14                	je     800df3 <memcmp+0x30>
		if (*s1 != *s2)
  800ddf:	0f b6 08             	movzbl (%eax),%ecx
  800de2:	0f b6 1a             	movzbl (%edx),%ebx
  800de5:	38 d9                	cmp    %bl,%cl
  800de7:	74 ec                	je     800dd5 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800de9:	0f b6 c1             	movzbl %cl,%eax
  800dec:	0f b6 db             	movzbl %bl,%ebx
  800def:	29 d8                	sub    %ebx,%eax
  800df1:	eb 05                	jmp    800df8 <memcmp+0x35>
	}

	return 0;
  800df3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	8b 45 08             	mov    0x8(%ebp),%eax
  800e02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e05:	89 c2                	mov    %eax,%edx
  800e07:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e0a:	eb 03                	jmp    800e0f <memfind+0x13>
  800e0c:	83 c0 01             	add    $0x1,%eax
  800e0f:	39 d0                	cmp    %edx,%eax
  800e11:	73 04                	jae    800e17 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e13:	38 08                	cmp    %cl,(%eax)
  800e15:	75 f5                	jne    800e0c <memfind+0x10>
			break;
	return (void *) s;
}
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	57                   	push   %edi
  800e1d:	56                   	push   %esi
  800e1e:	53                   	push   %ebx
  800e1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e22:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e25:	eb 03                	jmp    800e2a <strtol+0x11>
		s++;
  800e27:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800e2a:	0f b6 02             	movzbl (%edx),%eax
  800e2d:	3c 20                	cmp    $0x20,%al
  800e2f:	74 f6                	je     800e27 <strtol+0xe>
  800e31:	3c 09                	cmp    $0x9,%al
  800e33:	74 f2                	je     800e27 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800e35:	3c 2b                	cmp    $0x2b,%al
  800e37:	74 2a                	je     800e63 <strtol+0x4a>
	int neg = 0;
  800e39:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800e3e:	3c 2d                	cmp    $0x2d,%al
  800e40:	74 2b                	je     800e6d <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e42:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e48:	75 0f                	jne    800e59 <strtol+0x40>
  800e4a:	80 3a 30             	cmpb   $0x30,(%edx)
  800e4d:	74 28                	je     800e77 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e4f:	85 db                	test   %ebx,%ebx
  800e51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e56:	0f 44 d8             	cmove  %eax,%ebx
  800e59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e61:	eb 46                	jmp    800ea9 <strtol+0x90>
		s++;
  800e63:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800e66:	bf 00 00 00 00       	mov    $0x0,%edi
  800e6b:	eb d5                	jmp    800e42 <strtol+0x29>
		s++, neg = 1;
  800e6d:	83 c2 01             	add    $0x1,%edx
  800e70:	bf 01 00 00 00       	mov    $0x1,%edi
  800e75:	eb cb                	jmp    800e42 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e77:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e7b:	74 0e                	je     800e8b <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800e7d:	85 db                	test   %ebx,%ebx
  800e7f:	75 d8                	jne    800e59 <strtol+0x40>
		s++, base = 8;
  800e81:	83 c2 01             	add    $0x1,%edx
  800e84:	bb 08 00 00 00       	mov    $0x8,%ebx
  800e89:	eb ce                	jmp    800e59 <strtol+0x40>
		s += 2, base = 16;
  800e8b:	83 c2 02             	add    $0x2,%edx
  800e8e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e93:	eb c4                	jmp    800e59 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800e95:	0f be c0             	movsbl %al,%eax
  800e98:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e9b:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e9e:	7d 3a                	jge    800eda <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ea0:	83 c2 01             	add    $0x1,%edx
  800ea3:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ea7:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ea9:	0f b6 02             	movzbl (%edx),%eax
  800eac:	8d 70 d0             	lea    -0x30(%eax),%esi
  800eaf:	89 f3                	mov    %esi,%ebx
  800eb1:	80 fb 09             	cmp    $0x9,%bl
  800eb4:	76 df                	jbe    800e95 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800eb6:	8d 70 9f             	lea    -0x61(%eax),%esi
  800eb9:	89 f3                	mov    %esi,%ebx
  800ebb:	80 fb 19             	cmp    $0x19,%bl
  800ebe:	77 08                	ja     800ec8 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ec0:	0f be c0             	movsbl %al,%eax
  800ec3:	83 e8 57             	sub    $0x57,%eax
  800ec6:	eb d3                	jmp    800e9b <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ec8:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ecb:	89 f3                	mov    %esi,%ebx
  800ecd:	80 fb 19             	cmp    $0x19,%bl
  800ed0:	77 08                	ja     800eda <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ed2:	0f be c0             	movsbl %al,%eax
  800ed5:	83 e8 37             	sub    $0x37,%eax
  800ed8:	eb c1                	jmp    800e9b <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800eda:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ede:	74 05                	je     800ee5 <strtol+0xcc>
		*endptr = (char *) s;
  800ee0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee3:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ee5:	89 c8                	mov    %ecx,%eax
  800ee7:	f7 d8                	neg    %eax
  800ee9:	85 ff                	test   %edi,%edi
  800eeb:	0f 45 c8             	cmovne %eax,%ecx
}
  800eee:	89 c8                	mov    %ecx,%eax
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	57                   	push   %edi
  800ef9:	56                   	push   %esi
  800efa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800efb:	b8 00 00 00 00       	mov    $0x0,%eax
  800f00:	8b 55 08             	mov    0x8(%ebp),%edx
  800f03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f06:	89 c3                	mov    %eax,%ebx
  800f08:	89 c7                	mov    %eax,%edi
  800f0a:	89 c6                	mov    %eax,%esi
  800f0c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f0e:	5b                   	pop    %ebx
  800f0f:	5e                   	pop    %esi
  800f10:	5f                   	pop    %edi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	57                   	push   %edi
  800f17:	56                   	push   %esi
  800f18:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f19:	ba 00 00 00 00       	mov    $0x0,%edx
  800f1e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f23:	89 d1                	mov    %edx,%ecx
  800f25:	89 d3                	mov    %edx,%ebx
  800f27:	89 d7                	mov    %edx,%edi
  800f29:	89 d6                	mov    %edx,%esi
  800f2b:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f2d:	5b                   	pop    %ebx
  800f2e:	5e                   	pop    %esi
  800f2f:	5f                   	pop    %edi
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    

00800f32 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	57                   	push   %edi
  800f36:	56                   	push   %esi
  800f37:	53                   	push   %ebx
  800f38:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f3b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f40:	8b 55 08             	mov    0x8(%ebp),%edx
  800f43:	b8 03 00 00 00       	mov    $0x3,%eax
  800f48:	89 cb                	mov    %ecx,%ebx
  800f4a:	89 cf                	mov    %ecx,%edi
  800f4c:	89 ce                	mov    %ecx,%esi
  800f4e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f50:	85 c0                	test   %eax,%eax
  800f52:	7f 08                	jg     800f5c <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f57:	5b                   	pop    %ebx
  800f58:	5e                   	pop    %esi
  800f59:	5f                   	pop    %edi
  800f5a:	5d                   	pop    %ebp
  800f5b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5c:	83 ec 0c             	sub    $0xc,%esp
  800f5f:	50                   	push   %eax
  800f60:	6a 03                	push   $0x3
  800f62:	68 1f 2b 80 00       	push   $0x802b1f
  800f67:	6a 2a                	push   $0x2a
  800f69:	68 3c 2b 80 00       	push   $0x802b3c
  800f6e:	e8 9e 13 00 00       	call   802311 <_panic>

00800f73 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	57                   	push   %edi
  800f77:	56                   	push   %esi
  800f78:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f79:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7e:	b8 02 00 00 00       	mov    $0x2,%eax
  800f83:	89 d1                	mov    %edx,%ecx
  800f85:	89 d3                	mov    %edx,%ebx
  800f87:	89 d7                	mov    %edx,%edi
  800f89:	89 d6                	mov    %edx,%esi
  800f8b:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f8d:	5b                   	pop    %ebx
  800f8e:	5e                   	pop    %esi
  800f8f:	5f                   	pop    %edi
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    

00800f92 <sys_yield>:

void
sys_yield(void)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	57                   	push   %edi
  800f96:	56                   	push   %esi
  800f97:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f98:	ba 00 00 00 00       	mov    $0x0,%edx
  800f9d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fa2:	89 d1                	mov    %edx,%ecx
  800fa4:	89 d3                	mov    %edx,%ebx
  800fa6:	89 d7                	mov    %edx,%edi
  800fa8:	89 d6                	mov    %edx,%esi
  800faa:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fac:	5b                   	pop    %ebx
  800fad:	5e                   	pop    %esi
  800fae:	5f                   	pop    %edi
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    

00800fb1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	57                   	push   %edi
  800fb5:	56                   	push   %esi
  800fb6:	53                   	push   %ebx
  800fb7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fba:	be 00 00 00 00       	mov    $0x0,%esi
  800fbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc5:	b8 04 00 00 00       	mov    $0x4,%eax
  800fca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fcd:	89 f7                	mov    %esi,%edi
  800fcf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	7f 08                	jg     800fdd <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd8:	5b                   	pop    %ebx
  800fd9:	5e                   	pop    %esi
  800fda:	5f                   	pop    %edi
  800fdb:	5d                   	pop    %ebp
  800fdc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800fdd:	83 ec 0c             	sub    $0xc,%esp
  800fe0:	50                   	push   %eax
  800fe1:	6a 04                	push   $0x4
  800fe3:	68 1f 2b 80 00       	push   $0x802b1f
  800fe8:	6a 2a                	push   $0x2a
  800fea:	68 3c 2b 80 00       	push   $0x802b3c
  800fef:	e8 1d 13 00 00       	call   802311 <_panic>

00800ff4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	57                   	push   %edi
  800ff8:	56                   	push   %esi
  800ff9:	53                   	push   %ebx
  800ffa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ffd:	8b 55 08             	mov    0x8(%ebp),%edx
  801000:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801003:	b8 05 00 00 00       	mov    $0x5,%eax
  801008:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80100b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80100e:	8b 75 18             	mov    0x18(%ebp),%esi
  801011:	cd 30                	int    $0x30
	if(check && ret > 0)
  801013:	85 c0                	test   %eax,%eax
  801015:	7f 08                	jg     80101f <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801017:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80101a:	5b                   	pop    %ebx
  80101b:	5e                   	pop    %esi
  80101c:	5f                   	pop    %edi
  80101d:	5d                   	pop    %ebp
  80101e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	50                   	push   %eax
  801023:	6a 05                	push   $0x5
  801025:	68 1f 2b 80 00       	push   $0x802b1f
  80102a:	6a 2a                	push   $0x2a
  80102c:	68 3c 2b 80 00       	push   $0x802b3c
  801031:	e8 db 12 00 00       	call   802311 <_panic>

00801036 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	57                   	push   %edi
  80103a:	56                   	push   %esi
  80103b:	53                   	push   %ebx
  80103c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80103f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801044:	8b 55 08             	mov    0x8(%ebp),%edx
  801047:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104a:	b8 06 00 00 00       	mov    $0x6,%eax
  80104f:	89 df                	mov    %ebx,%edi
  801051:	89 de                	mov    %ebx,%esi
  801053:	cd 30                	int    $0x30
	if(check && ret > 0)
  801055:	85 c0                	test   %eax,%eax
  801057:	7f 08                	jg     801061 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801059:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80105c:	5b                   	pop    %ebx
  80105d:	5e                   	pop    %esi
  80105e:	5f                   	pop    %edi
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801061:	83 ec 0c             	sub    $0xc,%esp
  801064:	50                   	push   %eax
  801065:	6a 06                	push   $0x6
  801067:	68 1f 2b 80 00       	push   $0x802b1f
  80106c:	6a 2a                	push   $0x2a
  80106e:	68 3c 2b 80 00       	push   $0x802b3c
  801073:	e8 99 12 00 00       	call   802311 <_panic>

00801078 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	57                   	push   %edi
  80107c:	56                   	push   %esi
  80107d:	53                   	push   %ebx
  80107e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801081:	bb 00 00 00 00       	mov    $0x0,%ebx
  801086:	8b 55 08             	mov    0x8(%ebp),%edx
  801089:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80108c:	b8 08 00 00 00       	mov    $0x8,%eax
  801091:	89 df                	mov    %ebx,%edi
  801093:	89 de                	mov    %ebx,%esi
  801095:	cd 30                	int    $0x30
	if(check && ret > 0)
  801097:	85 c0                	test   %eax,%eax
  801099:	7f 08                	jg     8010a3 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80109b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80109e:	5b                   	pop    %ebx
  80109f:	5e                   	pop    %esi
  8010a0:	5f                   	pop    %edi
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8010a3:	83 ec 0c             	sub    $0xc,%esp
  8010a6:	50                   	push   %eax
  8010a7:	6a 08                	push   $0x8
  8010a9:	68 1f 2b 80 00       	push   $0x802b1f
  8010ae:	6a 2a                	push   $0x2a
  8010b0:	68 3c 2b 80 00       	push   $0x802b3c
  8010b5:	e8 57 12 00 00       	call   802311 <_panic>

008010ba <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	57                   	push   %edi
  8010be:	56                   	push   %esi
  8010bf:	53                   	push   %ebx
  8010c0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ce:	b8 09 00 00 00       	mov    $0x9,%eax
  8010d3:	89 df                	mov    %ebx,%edi
  8010d5:	89 de                	mov    %ebx,%esi
  8010d7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8010d9:	85 c0                	test   %eax,%eax
  8010db:	7f 08                	jg     8010e5 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e0:	5b                   	pop    %ebx
  8010e1:	5e                   	pop    %esi
  8010e2:	5f                   	pop    %edi
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8010e5:	83 ec 0c             	sub    $0xc,%esp
  8010e8:	50                   	push   %eax
  8010e9:	6a 09                	push   $0x9
  8010eb:	68 1f 2b 80 00       	push   $0x802b1f
  8010f0:	6a 2a                	push   $0x2a
  8010f2:	68 3c 2b 80 00       	push   $0x802b3c
  8010f7:	e8 15 12 00 00       	call   802311 <_panic>

008010fc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	57                   	push   %edi
  801100:	56                   	push   %esi
  801101:	53                   	push   %ebx
  801102:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801105:	bb 00 00 00 00       	mov    $0x0,%ebx
  80110a:	8b 55 08             	mov    0x8(%ebp),%edx
  80110d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801110:	b8 0a 00 00 00       	mov    $0xa,%eax
  801115:	89 df                	mov    %ebx,%edi
  801117:	89 de                	mov    %ebx,%esi
  801119:	cd 30                	int    $0x30
	if(check && ret > 0)
  80111b:	85 c0                	test   %eax,%eax
  80111d:	7f 08                	jg     801127 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80111f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801122:	5b                   	pop    %ebx
  801123:	5e                   	pop    %esi
  801124:	5f                   	pop    %edi
  801125:	5d                   	pop    %ebp
  801126:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801127:	83 ec 0c             	sub    $0xc,%esp
  80112a:	50                   	push   %eax
  80112b:	6a 0a                	push   $0xa
  80112d:	68 1f 2b 80 00       	push   $0x802b1f
  801132:	6a 2a                	push   $0x2a
  801134:	68 3c 2b 80 00       	push   $0x802b3c
  801139:	e8 d3 11 00 00       	call   802311 <_panic>

0080113e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	57                   	push   %edi
  801142:	56                   	push   %esi
  801143:	53                   	push   %ebx
	asm volatile("int %1\n"
  801144:	8b 55 08             	mov    0x8(%ebp),%edx
  801147:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80114f:	be 00 00 00 00       	mov    $0x0,%esi
  801154:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801157:	8b 7d 14             	mov    0x14(%ebp),%edi
  80115a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80115c:	5b                   	pop    %ebx
  80115d:	5e                   	pop    %esi
  80115e:	5f                   	pop    %edi
  80115f:	5d                   	pop    %ebp
  801160:	c3                   	ret    

00801161 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	57                   	push   %edi
  801165:	56                   	push   %esi
  801166:	53                   	push   %ebx
  801167:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80116a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80116f:	8b 55 08             	mov    0x8(%ebp),%edx
  801172:	b8 0d 00 00 00       	mov    $0xd,%eax
  801177:	89 cb                	mov    %ecx,%ebx
  801179:	89 cf                	mov    %ecx,%edi
  80117b:	89 ce                	mov    %ecx,%esi
  80117d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80117f:	85 c0                	test   %eax,%eax
  801181:	7f 08                	jg     80118b <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801183:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801186:	5b                   	pop    %ebx
  801187:	5e                   	pop    %esi
  801188:	5f                   	pop    %edi
  801189:	5d                   	pop    %ebp
  80118a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80118b:	83 ec 0c             	sub    $0xc,%esp
  80118e:	50                   	push   %eax
  80118f:	6a 0d                	push   $0xd
  801191:	68 1f 2b 80 00       	push   $0x802b1f
  801196:	6a 2a                	push   $0x2a
  801198:	68 3c 2b 80 00       	push   $0x802b3c
  80119d:	e8 6f 11 00 00       	call   802311 <_panic>

008011a2 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8011a2:	55                   	push   %ebp
  8011a3:	89 e5                	mov    %esp,%ebp
  8011a5:	57                   	push   %edi
  8011a6:	56                   	push   %esi
  8011a7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ad:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011b2:	89 d1                	mov    %edx,%ecx
  8011b4:	89 d3                	mov    %edx,%ebx
  8011b6:	89 d7                	mov    %edx,%edi
  8011b8:	89 d6                	mov    %edx,%esi
  8011ba:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8011bc:	5b                   	pop    %ebx
  8011bd:	5e                   	pop    %esi
  8011be:	5f                   	pop    %edi
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    

008011c1 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	57                   	push   %edi
  8011c5:	56                   	push   %esi
  8011c6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d2:	b8 0f 00 00 00       	mov    $0xf,%eax
  8011d7:	89 df                	mov    %ebx,%edi
  8011d9:	89 de                	mov    %ebx,%esi
  8011db:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  8011dd:	5b                   	pop    %ebx
  8011de:	5e                   	pop    %esi
  8011df:	5f                   	pop    %edi
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	57                   	push   %edi
  8011e6:	56                   	push   %esi
  8011e7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f3:	b8 10 00 00 00       	mov    $0x10,%eax
  8011f8:	89 df                	mov    %ebx,%edi
  8011fa:	89 de                	mov    %ebx,%esi
  8011fc:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8011fe:	5b                   	pop    %ebx
  8011ff:	5e                   	pop    %esi
  801200:	5f                   	pop    %edi
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    

00801203 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801206:	8b 45 08             	mov    0x8(%ebp),%eax
  801209:	05 00 00 00 30       	add    $0x30000000,%eax
  80120e:	c1 e8 0c             	shr    $0xc,%eax
}
  801211:	5d                   	pop    %ebp
  801212:	c3                   	ret    

00801213 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801216:	8b 45 08             	mov    0x8(%ebp),%eax
  801219:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80121e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801223:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801228:	5d                   	pop    %ebp
  801229:	c3                   	ret    

0080122a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
  80122d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801232:	89 c2                	mov    %eax,%edx
  801234:	c1 ea 16             	shr    $0x16,%edx
  801237:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80123e:	f6 c2 01             	test   $0x1,%dl
  801241:	74 29                	je     80126c <fd_alloc+0x42>
  801243:	89 c2                	mov    %eax,%edx
  801245:	c1 ea 0c             	shr    $0xc,%edx
  801248:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80124f:	f6 c2 01             	test   $0x1,%dl
  801252:	74 18                	je     80126c <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801254:	05 00 10 00 00       	add    $0x1000,%eax
  801259:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80125e:	75 d2                	jne    801232 <fd_alloc+0x8>
  801260:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801265:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80126a:	eb 05                	jmp    801271 <fd_alloc+0x47>
			return 0;
  80126c:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801271:	8b 55 08             	mov    0x8(%ebp),%edx
  801274:	89 02                	mov    %eax,(%edx)
}
  801276:	89 c8                	mov    %ecx,%eax
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801280:	83 f8 1f             	cmp    $0x1f,%eax
  801283:	77 30                	ja     8012b5 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801285:	c1 e0 0c             	shl    $0xc,%eax
  801288:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80128d:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801293:	f6 c2 01             	test   $0x1,%dl
  801296:	74 24                	je     8012bc <fd_lookup+0x42>
  801298:	89 c2                	mov    %eax,%edx
  80129a:	c1 ea 0c             	shr    $0xc,%edx
  80129d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a4:	f6 c2 01             	test   $0x1,%dl
  8012a7:	74 1a                	je     8012c3 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ac:	89 02                	mov    %eax,(%edx)
	return 0;
  8012ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    
		return -E_INVAL;
  8012b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ba:	eb f7                	jmp    8012b3 <fd_lookup+0x39>
		return -E_INVAL;
  8012bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c1:	eb f0                	jmp    8012b3 <fd_lookup+0x39>
  8012c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c8:	eb e9                	jmp    8012b3 <fd_lookup+0x39>

008012ca <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	53                   	push   %ebx
  8012ce:	83 ec 04             	sub    $0x4,%esp
  8012d1:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d9:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8012de:	39 13                	cmp    %edx,(%ebx)
  8012e0:	74 37                	je     801319 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8012e2:	83 c0 01             	add    $0x1,%eax
  8012e5:	8b 1c 85 c8 2b 80 00 	mov    0x802bc8(,%eax,4),%ebx
  8012ec:	85 db                	test   %ebx,%ebx
  8012ee:	75 ee                	jne    8012de <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012f0:	a1 10 40 80 00       	mov    0x804010,%eax
  8012f5:	8b 40 48             	mov    0x48(%eax),%eax
  8012f8:	83 ec 04             	sub    $0x4,%esp
  8012fb:	52                   	push   %edx
  8012fc:	50                   	push   %eax
  8012fd:	68 4c 2b 80 00       	push   $0x802b4c
  801302:	e8 d4 f2 ff ff       	call   8005db <cprintf>
	*dev = 0;
	return -E_INVAL;
  801307:	83 c4 10             	add    $0x10,%esp
  80130a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  80130f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801312:	89 1a                	mov    %ebx,(%edx)
}
  801314:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801317:	c9                   	leave  
  801318:	c3                   	ret    
			return 0;
  801319:	b8 00 00 00 00       	mov    $0x0,%eax
  80131e:	eb ef                	jmp    80130f <dev_lookup+0x45>

00801320 <fd_close>:
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	57                   	push   %edi
  801324:	56                   	push   %esi
  801325:	53                   	push   %ebx
  801326:	83 ec 24             	sub    $0x24,%esp
  801329:	8b 75 08             	mov    0x8(%ebp),%esi
  80132c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80132f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801332:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801333:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801339:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80133c:	50                   	push   %eax
  80133d:	e8 38 ff ff ff       	call   80127a <fd_lookup>
  801342:	89 c3                	mov    %eax,%ebx
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	78 05                	js     801350 <fd_close+0x30>
	    || fd != fd2)
  80134b:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80134e:	74 16                	je     801366 <fd_close+0x46>
		return (must_exist ? r : 0);
  801350:	89 f8                	mov    %edi,%eax
  801352:	84 c0                	test   %al,%al
  801354:	b8 00 00 00 00       	mov    $0x0,%eax
  801359:	0f 44 d8             	cmove  %eax,%ebx
}
  80135c:	89 d8                	mov    %ebx,%eax
  80135e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801361:	5b                   	pop    %ebx
  801362:	5e                   	pop    %esi
  801363:	5f                   	pop    %edi
  801364:	5d                   	pop    %ebp
  801365:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80136c:	50                   	push   %eax
  80136d:	ff 36                	push   (%esi)
  80136f:	e8 56 ff ff ff       	call   8012ca <dev_lookup>
  801374:	89 c3                	mov    %eax,%ebx
  801376:	83 c4 10             	add    $0x10,%esp
  801379:	85 c0                	test   %eax,%eax
  80137b:	78 1a                	js     801397 <fd_close+0x77>
		if (dev->dev_close)
  80137d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801380:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801383:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801388:	85 c0                	test   %eax,%eax
  80138a:	74 0b                	je     801397 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80138c:	83 ec 0c             	sub    $0xc,%esp
  80138f:	56                   	push   %esi
  801390:	ff d0                	call   *%eax
  801392:	89 c3                	mov    %eax,%ebx
  801394:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801397:	83 ec 08             	sub    $0x8,%esp
  80139a:	56                   	push   %esi
  80139b:	6a 00                	push   $0x0
  80139d:	e8 94 fc ff ff       	call   801036 <sys_page_unmap>
	return r;
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	eb b5                	jmp    80135c <fd_close+0x3c>

008013a7 <close>:

int
close(int fdnum)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b0:	50                   	push   %eax
  8013b1:	ff 75 08             	push   0x8(%ebp)
  8013b4:	e8 c1 fe ff ff       	call   80127a <fd_lookup>
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	79 02                	jns    8013c2 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8013c0:	c9                   	leave  
  8013c1:	c3                   	ret    
		return fd_close(fd, 1);
  8013c2:	83 ec 08             	sub    $0x8,%esp
  8013c5:	6a 01                	push   $0x1
  8013c7:	ff 75 f4             	push   -0xc(%ebp)
  8013ca:	e8 51 ff ff ff       	call   801320 <fd_close>
  8013cf:	83 c4 10             	add    $0x10,%esp
  8013d2:	eb ec                	jmp    8013c0 <close+0x19>

008013d4 <close_all>:

void
close_all(void)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	53                   	push   %ebx
  8013d8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013db:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013e0:	83 ec 0c             	sub    $0xc,%esp
  8013e3:	53                   	push   %ebx
  8013e4:	e8 be ff ff ff       	call   8013a7 <close>
	for (i = 0; i < MAXFD; i++)
  8013e9:	83 c3 01             	add    $0x1,%ebx
  8013ec:	83 c4 10             	add    $0x10,%esp
  8013ef:	83 fb 20             	cmp    $0x20,%ebx
  8013f2:	75 ec                	jne    8013e0 <close_all+0xc>
}
  8013f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f7:	c9                   	leave  
  8013f8:	c3                   	ret    

008013f9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013f9:	55                   	push   %ebp
  8013fa:	89 e5                	mov    %esp,%ebp
  8013fc:	57                   	push   %edi
  8013fd:	56                   	push   %esi
  8013fe:	53                   	push   %ebx
  8013ff:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801402:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801405:	50                   	push   %eax
  801406:	ff 75 08             	push   0x8(%ebp)
  801409:	e8 6c fe ff ff       	call   80127a <fd_lookup>
  80140e:	89 c3                	mov    %eax,%ebx
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	85 c0                	test   %eax,%eax
  801415:	78 7f                	js     801496 <dup+0x9d>
		return r;
	close(newfdnum);
  801417:	83 ec 0c             	sub    $0xc,%esp
  80141a:	ff 75 0c             	push   0xc(%ebp)
  80141d:	e8 85 ff ff ff       	call   8013a7 <close>

	newfd = INDEX2FD(newfdnum);
  801422:	8b 75 0c             	mov    0xc(%ebp),%esi
  801425:	c1 e6 0c             	shl    $0xc,%esi
  801428:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80142e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801431:	89 3c 24             	mov    %edi,(%esp)
  801434:	e8 da fd ff ff       	call   801213 <fd2data>
  801439:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80143b:	89 34 24             	mov    %esi,(%esp)
  80143e:	e8 d0 fd ff ff       	call   801213 <fd2data>
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801449:	89 d8                	mov    %ebx,%eax
  80144b:	c1 e8 16             	shr    $0x16,%eax
  80144e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801455:	a8 01                	test   $0x1,%al
  801457:	74 11                	je     80146a <dup+0x71>
  801459:	89 d8                	mov    %ebx,%eax
  80145b:	c1 e8 0c             	shr    $0xc,%eax
  80145e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801465:	f6 c2 01             	test   $0x1,%dl
  801468:	75 36                	jne    8014a0 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80146a:	89 f8                	mov    %edi,%eax
  80146c:	c1 e8 0c             	shr    $0xc,%eax
  80146f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801476:	83 ec 0c             	sub    $0xc,%esp
  801479:	25 07 0e 00 00       	and    $0xe07,%eax
  80147e:	50                   	push   %eax
  80147f:	56                   	push   %esi
  801480:	6a 00                	push   $0x0
  801482:	57                   	push   %edi
  801483:	6a 00                	push   $0x0
  801485:	e8 6a fb ff ff       	call   800ff4 <sys_page_map>
  80148a:	89 c3                	mov    %eax,%ebx
  80148c:	83 c4 20             	add    $0x20,%esp
  80148f:	85 c0                	test   %eax,%eax
  801491:	78 33                	js     8014c6 <dup+0xcd>
		goto err;

	return newfdnum;
  801493:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801496:	89 d8                	mov    %ebx,%eax
  801498:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149b:	5b                   	pop    %ebx
  80149c:	5e                   	pop    %esi
  80149d:	5f                   	pop    %edi
  80149e:	5d                   	pop    %ebp
  80149f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014a0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014a7:	83 ec 0c             	sub    $0xc,%esp
  8014aa:	25 07 0e 00 00       	and    $0xe07,%eax
  8014af:	50                   	push   %eax
  8014b0:	ff 75 d4             	push   -0x2c(%ebp)
  8014b3:	6a 00                	push   $0x0
  8014b5:	53                   	push   %ebx
  8014b6:	6a 00                	push   $0x0
  8014b8:	e8 37 fb ff ff       	call   800ff4 <sys_page_map>
  8014bd:	89 c3                	mov    %eax,%ebx
  8014bf:	83 c4 20             	add    $0x20,%esp
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	79 a4                	jns    80146a <dup+0x71>
	sys_page_unmap(0, newfd);
  8014c6:	83 ec 08             	sub    $0x8,%esp
  8014c9:	56                   	push   %esi
  8014ca:	6a 00                	push   $0x0
  8014cc:	e8 65 fb ff ff       	call   801036 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014d1:	83 c4 08             	add    $0x8,%esp
  8014d4:	ff 75 d4             	push   -0x2c(%ebp)
  8014d7:	6a 00                	push   $0x0
  8014d9:	e8 58 fb ff ff       	call   801036 <sys_page_unmap>
	return r;
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	eb b3                	jmp    801496 <dup+0x9d>

008014e3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	56                   	push   %esi
  8014e7:	53                   	push   %ebx
  8014e8:	83 ec 18             	sub    $0x18,%esp
  8014eb:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f1:	50                   	push   %eax
  8014f2:	56                   	push   %esi
  8014f3:	e8 82 fd ff ff       	call   80127a <fd_lookup>
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	78 3c                	js     80153b <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ff:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801502:	83 ec 08             	sub    $0x8,%esp
  801505:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801508:	50                   	push   %eax
  801509:	ff 33                	push   (%ebx)
  80150b:	e8 ba fd ff ff       	call   8012ca <dev_lookup>
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	85 c0                	test   %eax,%eax
  801515:	78 24                	js     80153b <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801517:	8b 43 08             	mov    0x8(%ebx),%eax
  80151a:	83 e0 03             	and    $0x3,%eax
  80151d:	83 f8 01             	cmp    $0x1,%eax
  801520:	74 20                	je     801542 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801522:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801525:	8b 40 08             	mov    0x8(%eax),%eax
  801528:	85 c0                	test   %eax,%eax
  80152a:	74 37                	je     801563 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80152c:	83 ec 04             	sub    $0x4,%esp
  80152f:	ff 75 10             	push   0x10(%ebp)
  801532:	ff 75 0c             	push   0xc(%ebp)
  801535:	53                   	push   %ebx
  801536:	ff d0                	call   *%eax
  801538:	83 c4 10             	add    $0x10,%esp
}
  80153b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80153e:	5b                   	pop    %ebx
  80153f:	5e                   	pop    %esi
  801540:	5d                   	pop    %ebp
  801541:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801542:	a1 10 40 80 00       	mov    0x804010,%eax
  801547:	8b 40 48             	mov    0x48(%eax),%eax
  80154a:	83 ec 04             	sub    $0x4,%esp
  80154d:	56                   	push   %esi
  80154e:	50                   	push   %eax
  80154f:	68 8d 2b 80 00       	push   $0x802b8d
  801554:	e8 82 f0 ff ff       	call   8005db <cprintf>
		return -E_INVAL;
  801559:	83 c4 10             	add    $0x10,%esp
  80155c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801561:	eb d8                	jmp    80153b <read+0x58>
		return -E_NOT_SUPP;
  801563:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801568:	eb d1                	jmp    80153b <read+0x58>

0080156a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	57                   	push   %edi
  80156e:	56                   	push   %esi
  80156f:	53                   	push   %ebx
  801570:	83 ec 0c             	sub    $0xc,%esp
  801573:	8b 7d 08             	mov    0x8(%ebp),%edi
  801576:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801579:	bb 00 00 00 00       	mov    $0x0,%ebx
  80157e:	eb 02                	jmp    801582 <readn+0x18>
  801580:	01 c3                	add    %eax,%ebx
  801582:	39 f3                	cmp    %esi,%ebx
  801584:	73 21                	jae    8015a7 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801586:	83 ec 04             	sub    $0x4,%esp
  801589:	89 f0                	mov    %esi,%eax
  80158b:	29 d8                	sub    %ebx,%eax
  80158d:	50                   	push   %eax
  80158e:	89 d8                	mov    %ebx,%eax
  801590:	03 45 0c             	add    0xc(%ebp),%eax
  801593:	50                   	push   %eax
  801594:	57                   	push   %edi
  801595:	e8 49 ff ff ff       	call   8014e3 <read>
		if (m < 0)
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 04                	js     8015a5 <readn+0x3b>
			return m;
		if (m == 0)
  8015a1:	75 dd                	jne    801580 <readn+0x16>
  8015a3:	eb 02                	jmp    8015a7 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a5:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8015a7:	89 d8                	mov    %ebx,%eax
  8015a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ac:	5b                   	pop    %ebx
  8015ad:	5e                   	pop    %esi
  8015ae:	5f                   	pop    %edi
  8015af:	5d                   	pop    %ebp
  8015b0:	c3                   	ret    

008015b1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	56                   	push   %esi
  8015b5:	53                   	push   %ebx
  8015b6:	83 ec 18             	sub    $0x18,%esp
  8015b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015bf:	50                   	push   %eax
  8015c0:	53                   	push   %ebx
  8015c1:	e8 b4 fc ff ff       	call   80127a <fd_lookup>
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	78 37                	js     801604 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cd:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d6:	50                   	push   %eax
  8015d7:	ff 36                	push   (%esi)
  8015d9:	e8 ec fc ff ff       	call   8012ca <dev_lookup>
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	78 1f                	js     801604 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015e5:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8015e9:	74 20                	je     80160b <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	74 37                	je     80162c <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015f5:	83 ec 04             	sub    $0x4,%esp
  8015f8:	ff 75 10             	push   0x10(%ebp)
  8015fb:	ff 75 0c             	push   0xc(%ebp)
  8015fe:	56                   	push   %esi
  8015ff:	ff d0                	call   *%eax
  801601:	83 c4 10             	add    $0x10,%esp
}
  801604:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801607:	5b                   	pop    %ebx
  801608:	5e                   	pop    %esi
  801609:	5d                   	pop    %ebp
  80160a:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80160b:	a1 10 40 80 00       	mov    0x804010,%eax
  801610:	8b 40 48             	mov    0x48(%eax),%eax
  801613:	83 ec 04             	sub    $0x4,%esp
  801616:	53                   	push   %ebx
  801617:	50                   	push   %eax
  801618:	68 a9 2b 80 00       	push   $0x802ba9
  80161d:	e8 b9 ef ff ff       	call   8005db <cprintf>
		return -E_INVAL;
  801622:	83 c4 10             	add    $0x10,%esp
  801625:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80162a:	eb d8                	jmp    801604 <write+0x53>
		return -E_NOT_SUPP;
  80162c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801631:	eb d1                	jmp    801604 <write+0x53>

00801633 <seek>:

int
seek(int fdnum, off_t offset)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801639:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163c:	50                   	push   %eax
  80163d:	ff 75 08             	push   0x8(%ebp)
  801640:	e8 35 fc ff ff       	call   80127a <fd_lookup>
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	85 c0                	test   %eax,%eax
  80164a:	78 0e                	js     80165a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80164c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80164f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801652:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801655:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	56                   	push   %esi
  801660:	53                   	push   %ebx
  801661:	83 ec 18             	sub    $0x18,%esp
  801664:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801667:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80166a:	50                   	push   %eax
  80166b:	53                   	push   %ebx
  80166c:	e8 09 fc ff ff       	call   80127a <fd_lookup>
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	85 c0                	test   %eax,%eax
  801676:	78 34                	js     8016ac <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801678:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80167b:	83 ec 08             	sub    $0x8,%esp
  80167e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801681:	50                   	push   %eax
  801682:	ff 36                	push   (%esi)
  801684:	e8 41 fc ff ff       	call   8012ca <dev_lookup>
  801689:	83 c4 10             	add    $0x10,%esp
  80168c:	85 c0                	test   %eax,%eax
  80168e:	78 1c                	js     8016ac <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801690:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801694:	74 1d                	je     8016b3 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801696:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801699:	8b 40 18             	mov    0x18(%eax),%eax
  80169c:	85 c0                	test   %eax,%eax
  80169e:	74 34                	je     8016d4 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016a0:	83 ec 08             	sub    $0x8,%esp
  8016a3:	ff 75 0c             	push   0xc(%ebp)
  8016a6:	56                   	push   %esi
  8016a7:	ff d0                	call   *%eax
  8016a9:	83 c4 10             	add    $0x10,%esp
}
  8016ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016af:	5b                   	pop    %ebx
  8016b0:	5e                   	pop    %esi
  8016b1:	5d                   	pop    %ebp
  8016b2:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016b3:	a1 10 40 80 00       	mov    0x804010,%eax
  8016b8:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016bb:	83 ec 04             	sub    $0x4,%esp
  8016be:	53                   	push   %ebx
  8016bf:	50                   	push   %eax
  8016c0:	68 6c 2b 80 00       	push   $0x802b6c
  8016c5:	e8 11 ef ff ff       	call   8005db <cprintf>
		return -E_INVAL;
  8016ca:	83 c4 10             	add    $0x10,%esp
  8016cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016d2:	eb d8                	jmp    8016ac <ftruncate+0x50>
		return -E_NOT_SUPP;
  8016d4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016d9:	eb d1                	jmp    8016ac <ftruncate+0x50>

008016db <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	56                   	push   %esi
  8016df:	53                   	push   %ebx
  8016e0:	83 ec 18             	sub    $0x18,%esp
  8016e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e9:	50                   	push   %eax
  8016ea:	ff 75 08             	push   0x8(%ebp)
  8016ed:	e8 88 fb ff ff       	call   80127a <fd_lookup>
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	78 49                	js     801742 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f9:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8016fc:	83 ec 08             	sub    $0x8,%esp
  8016ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801702:	50                   	push   %eax
  801703:	ff 36                	push   (%esi)
  801705:	e8 c0 fb ff ff       	call   8012ca <dev_lookup>
  80170a:	83 c4 10             	add    $0x10,%esp
  80170d:	85 c0                	test   %eax,%eax
  80170f:	78 31                	js     801742 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801711:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801714:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801718:	74 2f                	je     801749 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80171a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80171d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801724:	00 00 00 
	stat->st_isdir = 0;
  801727:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80172e:	00 00 00 
	stat->st_dev = dev;
  801731:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801737:	83 ec 08             	sub    $0x8,%esp
  80173a:	53                   	push   %ebx
  80173b:	56                   	push   %esi
  80173c:	ff 50 14             	call   *0x14(%eax)
  80173f:	83 c4 10             	add    $0x10,%esp
}
  801742:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801745:	5b                   	pop    %ebx
  801746:	5e                   	pop    %esi
  801747:	5d                   	pop    %ebp
  801748:	c3                   	ret    
		return -E_NOT_SUPP;
  801749:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80174e:	eb f2                	jmp    801742 <fstat+0x67>

00801750 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	56                   	push   %esi
  801754:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801755:	83 ec 08             	sub    $0x8,%esp
  801758:	6a 00                	push   $0x0
  80175a:	ff 75 08             	push   0x8(%ebp)
  80175d:	e8 e4 01 00 00       	call   801946 <open>
  801762:	89 c3                	mov    %eax,%ebx
  801764:	83 c4 10             	add    $0x10,%esp
  801767:	85 c0                	test   %eax,%eax
  801769:	78 1b                	js     801786 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80176b:	83 ec 08             	sub    $0x8,%esp
  80176e:	ff 75 0c             	push   0xc(%ebp)
  801771:	50                   	push   %eax
  801772:	e8 64 ff ff ff       	call   8016db <fstat>
  801777:	89 c6                	mov    %eax,%esi
	close(fd);
  801779:	89 1c 24             	mov    %ebx,(%esp)
  80177c:	e8 26 fc ff ff       	call   8013a7 <close>
	return r;
  801781:	83 c4 10             	add    $0x10,%esp
  801784:	89 f3                	mov    %esi,%ebx
}
  801786:	89 d8                	mov    %ebx,%eax
  801788:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178b:	5b                   	pop    %ebx
  80178c:	5e                   	pop    %esi
  80178d:	5d                   	pop    %ebp
  80178e:	c3                   	ret    

0080178f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	56                   	push   %esi
  801793:	53                   	push   %ebx
  801794:	89 c6                	mov    %eax,%esi
  801796:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801798:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80179f:	74 27                	je     8017c8 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017a1:	6a 07                	push   $0x7
  8017a3:	68 00 50 80 00       	push   $0x805000
  8017a8:	56                   	push   %esi
  8017a9:	ff 35 00 60 80 00    	push   0x806000
  8017af:	e8 0a 0c 00 00       	call   8023be <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017b4:	83 c4 0c             	add    $0xc,%esp
  8017b7:	6a 00                	push   $0x0
  8017b9:	53                   	push   %ebx
  8017ba:	6a 00                	push   $0x0
  8017bc:	e8 96 0b 00 00       	call   802357 <ipc_recv>
}
  8017c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c4:	5b                   	pop    %ebx
  8017c5:	5e                   	pop    %esi
  8017c6:	5d                   	pop    %ebp
  8017c7:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017c8:	83 ec 0c             	sub    $0xc,%esp
  8017cb:	6a 01                	push   $0x1
  8017cd:	e8 40 0c 00 00       	call   802412 <ipc_find_env>
  8017d2:	a3 00 60 80 00       	mov    %eax,0x806000
  8017d7:	83 c4 10             	add    $0x10,%esp
  8017da:	eb c5                	jmp    8017a1 <fsipc+0x12>

008017dc <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fa:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ff:	e8 8b ff ff ff       	call   80178f <fsipc>
}
  801804:	c9                   	leave  
  801805:	c3                   	ret    

00801806 <devfile_flush>:
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80180c:	8b 45 08             	mov    0x8(%ebp),%eax
  80180f:	8b 40 0c             	mov    0xc(%eax),%eax
  801812:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801817:	ba 00 00 00 00       	mov    $0x0,%edx
  80181c:	b8 06 00 00 00       	mov    $0x6,%eax
  801821:	e8 69 ff ff ff       	call   80178f <fsipc>
}
  801826:	c9                   	leave  
  801827:	c3                   	ret    

00801828 <devfile_stat>:
{
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	53                   	push   %ebx
  80182c:	83 ec 04             	sub    $0x4,%esp
  80182f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801832:	8b 45 08             	mov    0x8(%ebp),%eax
  801835:	8b 40 0c             	mov    0xc(%eax),%eax
  801838:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80183d:	ba 00 00 00 00       	mov    $0x0,%edx
  801842:	b8 05 00 00 00       	mov    $0x5,%eax
  801847:	e8 43 ff ff ff       	call   80178f <fsipc>
  80184c:	85 c0                	test   %eax,%eax
  80184e:	78 2c                	js     80187c <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801850:	83 ec 08             	sub    $0x8,%esp
  801853:	68 00 50 80 00       	push   $0x805000
  801858:	53                   	push   %ebx
  801859:	e8 57 f3 ff ff       	call   800bb5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80185e:	a1 80 50 80 00       	mov    0x805080,%eax
  801863:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801869:	a1 84 50 80 00       	mov    0x805084,%eax
  80186e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801874:	83 c4 10             	add    $0x10,%esp
  801877:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80187c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187f:	c9                   	leave  
  801880:	c3                   	ret    

00801881 <devfile_write>:
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	83 ec 0c             	sub    $0xc,%esp
  801887:	8b 45 10             	mov    0x10(%ebp),%eax
  80188a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80188f:	39 d0                	cmp    %edx,%eax
  801891:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801894:	8b 55 08             	mov    0x8(%ebp),%edx
  801897:	8b 52 0c             	mov    0xc(%edx),%edx
  80189a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018a0:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018a5:	50                   	push   %eax
  8018a6:	ff 75 0c             	push   0xc(%ebp)
  8018a9:	68 08 50 80 00       	push   $0x805008
  8018ae:	e8 98 f4 ff ff       	call   800d4b <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8018b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b8:	b8 04 00 00 00       	mov    $0x4,%eax
  8018bd:	e8 cd fe ff ff       	call   80178f <fsipc>
}
  8018c2:	c9                   	leave  
  8018c3:	c3                   	ret    

008018c4 <devfile_read>:
{
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	56                   	push   %esi
  8018c8:	53                   	push   %ebx
  8018c9:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018d7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e2:	b8 03 00 00 00       	mov    $0x3,%eax
  8018e7:	e8 a3 fe ff ff       	call   80178f <fsipc>
  8018ec:	89 c3                	mov    %eax,%ebx
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	78 1f                	js     801911 <devfile_read+0x4d>
	assert(r <= n);
  8018f2:	39 f0                	cmp    %esi,%eax
  8018f4:	77 24                	ja     80191a <devfile_read+0x56>
	assert(r <= PGSIZE);
  8018f6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018fb:	7f 33                	jg     801930 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018fd:	83 ec 04             	sub    $0x4,%esp
  801900:	50                   	push   %eax
  801901:	68 00 50 80 00       	push   $0x805000
  801906:	ff 75 0c             	push   0xc(%ebp)
  801909:	e8 3d f4 ff ff       	call   800d4b <memmove>
	return r;
  80190e:	83 c4 10             	add    $0x10,%esp
}
  801911:	89 d8                	mov    %ebx,%eax
  801913:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801916:	5b                   	pop    %ebx
  801917:	5e                   	pop    %esi
  801918:	5d                   	pop    %ebp
  801919:	c3                   	ret    
	assert(r <= n);
  80191a:	68 dc 2b 80 00       	push   $0x802bdc
  80191f:	68 e3 2b 80 00       	push   $0x802be3
  801924:	6a 7c                	push   $0x7c
  801926:	68 f8 2b 80 00       	push   $0x802bf8
  80192b:	e8 e1 09 00 00       	call   802311 <_panic>
	assert(r <= PGSIZE);
  801930:	68 03 2c 80 00       	push   $0x802c03
  801935:	68 e3 2b 80 00       	push   $0x802be3
  80193a:	6a 7d                	push   $0x7d
  80193c:	68 f8 2b 80 00       	push   $0x802bf8
  801941:	e8 cb 09 00 00       	call   802311 <_panic>

00801946 <open>:
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	56                   	push   %esi
  80194a:	53                   	push   %ebx
  80194b:	83 ec 1c             	sub    $0x1c,%esp
  80194e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801951:	56                   	push   %esi
  801952:	e8 23 f2 ff ff       	call   800b7a <strlen>
  801957:	83 c4 10             	add    $0x10,%esp
  80195a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80195f:	7f 6c                	jg     8019cd <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801961:	83 ec 0c             	sub    $0xc,%esp
  801964:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801967:	50                   	push   %eax
  801968:	e8 bd f8 ff ff       	call   80122a <fd_alloc>
  80196d:	89 c3                	mov    %eax,%ebx
  80196f:	83 c4 10             	add    $0x10,%esp
  801972:	85 c0                	test   %eax,%eax
  801974:	78 3c                	js     8019b2 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801976:	83 ec 08             	sub    $0x8,%esp
  801979:	56                   	push   %esi
  80197a:	68 00 50 80 00       	push   $0x805000
  80197f:	e8 31 f2 ff ff       	call   800bb5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801984:	8b 45 0c             	mov    0xc(%ebp),%eax
  801987:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80198c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80198f:	b8 01 00 00 00       	mov    $0x1,%eax
  801994:	e8 f6 fd ff ff       	call   80178f <fsipc>
  801999:	89 c3                	mov    %eax,%ebx
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 19                	js     8019bb <open+0x75>
	return fd2num(fd);
  8019a2:	83 ec 0c             	sub    $0xc,%esp
  8019a5:	ff 75 f4             	push   -0xc(%ebp)
  8019a8:	e8 56 f8 ff ff       	call   801203 <fd2num>
  8019ad:	89 c3                	mov    %eax,%ebx
  8019af:	83 c4 10             	add    $0x10,%esp
}
  8019b2:	89 d8                	mov    %ebx,%eax
  8019b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b7:	5b                   	pop    %ebx
  8019b8:	5e                   	pop    %esi
  8019b9:	5d                   	pop    %ebp
  8019ba:	c3                   	ret    
		fd_close(fd, 0);
  8019bb:	83 ec 08             	sub    $0x8,%esp
  8019be:	6a 00                	push   $0x0
  8019c0:	ff 75 f4             	push   -0xc(%ebp)
  8019c3:	e8 58 f9 ff ff       	call   801320 <fd_close>
		return r;
  8019c8:	83 c4 10             	add    $0x10,%esp
  8019cb:	eb e5                	jmp    8019b2 <open+0x6c>
		return -E_BAD_PATH;
  8019cd:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019d2:	eb de                	jmp    8019b2 <open+0x6c>

008019d4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019da:	ba 00 00 00 00       	mov    $0x0,%edx
  8019df:	b8 08 00 00 00       	mov    $0x8,%eax
  8019e4:	e8 a6 fd ff ff       	call   80178f <fsipc>
}
  8019e9:	c9                   	leave  
  8019ea:	c3                   	ret    

008019eb <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019f1:	68 0f 2c 80 00       	push   $0x802c0f
  8019f6:	ff 75 0c             	push   0xc(%ebp)
  8019f9:	e8 b7 f1 ff ff       	call   800bb5 <strcpy>
	return 0;
}
  8019fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801a03:	c9                   	leave  
  801a04:	c3                   	ret    

00801a05 <devsock_close>:
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	53                   	push   %ebx
  801a09:	83 ec 10             	sub    $0x10,%esp
  801a0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a0f:	53                   	push   %ebx
  801a10:	e8 36 0a 00 00       	call   80244b <pageref>
  801a15:	89 c2                	mov    %eax,%edx
  801a17:	83 c4 10             	add    $0x10,%esp
		return 0;
  801a1a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801a1f:	83 fa 01             	cmp    $0x1,%edx
  801a22:	74 05                	je     801a29 <devsock_close+0x24>
}
  801a24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a27:	c9                   	leave  
  801a28:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801a29:	83 ec 0c             	sub    $0xc,%esp
  801a2c:	ff 73 0c             	push   0xc(%ebx)
  801a2f:	e8 b7 02 00 00       	call   801ceb <nsipc_close>
  801a34:	83 c4 10             	add    $0x10,%esp
  801a37:	eb eb                	jmp    801a24 <devsock_close+0x1f>

00801a39 <devsock_write>:
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a3f:	6a 00                	push   $0x0
  801a41:	ff 75 10             	push   0x10(%ebp)
  801a44:	ff 75 0c             	push   0xc(%ebp)
  801a47:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4a:	ff 70 0c             	push   0xc(%eax)
  801a4d:	e8 79 03 00 00       	call   801dcb <nsipc_send>
}
  801a52:	c9                   	leave  
  801a53:	c3                   	ret    

00801a54 <devsock_read>:
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a5a:	6a 00                	push   $0x0
  801a5c:	ff 75 10             	push   0x10(%ebp)
  801a5f:	ff 75 0c             	push   0xc(%ebp)
  801a62:	8b 45 08             	mov    0x8(%ebp),%eax
  801a65:	ff 70 0c             	push   0xc(%eax)
  801a68:	e8 ef 02 00 00       	call   801d5c <nsipc_recv>
}
  801a6d:	c9                   	leave  
  801a6e:	c3                   	ret    

00801a6f <fd2sockid>:
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a75:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a78:	52                   	push   %edx
  801a79:	50                   	push   %eax
  801a7a:	e8 fb f7 ff ff       	call   80127a <fd_lookup>
  801a7f:	83 c4 10             	add    $0x10,%esp
  801a82:	85 c0                	test   %eax,%eax
  801a84:	78 10                	js     801a96 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a89:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a8f:	39 08                	cmp    %ecx,(%eax)
  801a91:	75 05                	jne    801a98 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801a93:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801a96:	c9                   	leave  
  801a97:	c3                   	ret    
		return -E_NOT_SUPP;
  801a98:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a9d:	eb f7                	jmp    801a96 <fd2sockid+0x27>

00801a9f <alloc_sockfd>:
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	56                   	push   %esi
  801aa3:	53                   	push   %ebx
  801aa4:	83 ec 1c             	sub    $0x1c,%esp
  801aa7:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801aa9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aac:	50                   	push   %eax
  801aad:	e8 78 f7 ff ff       	call   80122a <fd_alloc>
  801ab2:	89 c3                	mov    %eax,%ebx
  801ab4:	83 c4 10             	add    $0x10,%esp
  801ab7:	85 c0                	test   %eax,%eax
  801ab9:	78 43                	js     801afe <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801abb:	83 ec 04             	sub    $0x4,%esp
  801abe:	68 07 04 00 00       	push   $0x407
  801ac3:	ff 75 f4             	push   -0xc(%ebp)
  801ac6:	6a 00                	push   $0x0
  801ac8:	e8 e4 f4 ff ff       	call   800fb1 <sys_page_alloc>
  801acd:	89 c3                	mov    %eax,%ebx
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	78 28                	js     801afe <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801adf:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801aeb:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801aee:	83 ec 0c             	sub    $0xc,%esp
  801af1:	50                   	push   %eax
  801af2:	e8 0c f7 ff ff       	call   801203 <fd2num>
  801af7:	89 c3                	mov    %eax,%ebx
  801af9:	83 c4 10             	add    $0x10,%esp
  801afc:	eb 0c                	jmp    801b0a <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801afe:	83 ec 0c             	sub    $0xc,%esp
  801b01:	56                   	push   %esi
  801b02:	e8 e4 01 00 00       	call   801ceb <nsipc_close>
		return r;
  801b07:	83 c4 10             	add    $0x10,%esp
}
  801b0a:	89 d8                	mov    %ebx,%eax
  801b0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b0f:	5b                   	pop    %ebx
  801b10:	5e                   	pop    %esi
  801b11:	5d                   	pop    %ebp
  801b12:	c3                   	ret    

00801b13 <accept>:
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b19:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1c:	e8 4e ff ff ff       	call   801a6f <fd2sockid>
  801b21:	85 c0                	test   %eax,%eax
  801b23:	78 1b                	js     801b40 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b25:	83 ec 04             	sub    $0x4,%esp
  801b28:	ff 75 10             	push   0x10(%ebp)
  801b2b:	ff 75 0c             	push   0xc(%ebp)
  801b2e:	50                   	push   %eax
  801b2f:	e8 0e 01 00 00       	call   801c42 <nsipc_accept>
  801b34:	83 c4 10             	add    $0x10,%esp
  801b37:	85 c0                	test   %eax,%eax
  801b39:	78 05                	js     801b40 <accept+0x2d>
	return alloc_sockfd(r);
  801b3b:	e8 5f ff ff ff       	call   801a9f <alloc_sockfd>
}
  801b40:	c9                   	leave  
  801b41:	c3                   	ret    

00801b42 <bind>:
{
  801b42:	55                   	push   %ebp
  801b43:	89 e5                	mov    %esp,%ebp
  801b45:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b48:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4b:	e8 1f ff ff ff       	call   801a6f <fd2sockid>
  801b50:	85 c0                	test   %eax,%eax
  801b52:	78 12                	js     801b66 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801b54:	83 ec 04             	sub    $0x4,%esp
  801b57:	ff 75 10             	push   0x10(%ebp)
  801b5a:	ff 75 0c             	push   0xc(%ebp)
  801b5d:	50                   	push   %eax
  801b5e:	e8 31 01 00 00       	call   801c94 <nsipc_bind>
  801b63:	83 c4 10             	add    $0x10,%esp
}
  801b66:	c9                   	leave  
  801b67:	c3                   	ret    

00801b68 <shutdown>:
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b71:	e8 f9 fe ff ff       	call   801a6f <fd2sockid>
  801b76:	85 c0                	test   %eax,%eax
  801b78:	78 0f                	js     801b89 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801b7a:	83 ec 08             	sub    $0x8,%esp
  801b7d:	ff 75 0c             	push   0xc(%ebp)
  801b80:	50                   	push   %eax
  801b81:	e8 43 01 00 00       	call   801cc9 <nsipc_shutdown>
  801b86:	83 c4 10             	add    $0x10,%esp
}
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    

00801b8b <connect>:
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b91:	8b 45 08             	mov    0x8(%ebp),%eax
  801b94:	e8 d6 fe ff ff       	call   801a6f <fd2sockid>
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	78 12                	js     801baf <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801b9d:	83 ec 04             	sub    $0x4,%esp
  801ba0:	ff 75 10             	push   0x10(%ebp)
  801ba3:	ff 75 0c             	push   0xc(%ebp)
  801ba6:	50                   	push   %eax
  801ba7:	e8 59 01 00 00       	call   801d05 <nsipc_connect>
  801bac:	83 c4 10             	add    $0x10,%esp
}
  801baf:	c9                   	leave  
  801bb0:	c3                   	ret    

00801bb1 <listen>:
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bba:	e8 b0 fe ff ff       	call   801a6f <fd2sockid>
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	78 0f                	js     801bd2 <listen+0x21>
	return nsipc_listen(r, backlog);
  801bc3:	83 ec 08             	sub    $0x8,%esp
  801bc6:	ff 75 0c             	push   0xc(%ebp)
  801bc9:	50                   	push   %eax
  801bca:	e8 6b 01 00 00       	call   801d3a <nsipc_listen>
  801bcf:	83 c4 10             	add    $0x10,%esp
}
  801bd2:	c9                   	leave  
  801bd3:	c3                   	ret    

00801bd4 <socket>:

int
socket(int domain, int type, int protocol)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bda:	ff 75 10             	push   0x10(%ebp)
  801bdd:	ff 75 0c             	push   0xc(%ebp)
  801be0:	ff 75 08             	push   0x8(%ebp)
  801be3:	e8 41 02 00 00       	call   801e29 <nsipc_socket>
  801be8:	83 c4 10             	add    $0x10,%esp
  801beb:	85 c0                	test   %eax,%eax
  801bed:	78 05                	js     801bf4 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bef:	e8 ab fe ff ff       	call   801a9f <alloc_sockfd>
}
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    

00801bf6 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	53                   	push   %ebx
  801bfa:	83 ec 04             	sub    $0x4,%esp
  801bfd:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bff:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801c06:	74 26                	je     801c2e <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c08:	6a 07                	push   $0x7
  801c0a:	68 00 70 80 00       	push   $0x807000
  801c0f:	53                   	push   %ebx
  801c10:	ff 35 00 80 80 00    	push   0x808000
  801c16:	e8 a3 07 00 00       	call   8023be <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c1b:	83 c4 0c             	add    $0xc,%esp
  801c1e:	6a 00                	push   $0x0
  801c20:	6a 00                	push   $0x0
  801c22:	6a 00                	push   $0x0
  801c24:	e8 2e 07 00 00       	call   802357 <ipc_recv>
}
  801c29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c2c:	c9                   	leave  
  801c2d:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c2e:	83 ec 0c             	sub    $0xc,%esp
  801c31:	6a 02                	push   $0x2
  801c33:	e8 da 07 00 00       	call   802412 <ipc_find_env>
  801c38:	a3 00 80 80 00       	mov    %eax,0x808000
  801c3d:	83 c4 10             	add    $0x10,%esp
  801c40:	eb c6                	jmp    801c08 <nsipc+0x12>

00801c42 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	56                   	push   %esi
  801c46:	53                   	push   %ebx
  801c47:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c52:	8b 06                	mov    (%esi),%eax
  801c54:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c59:	b8 01 00 00 00       	mov    $0x1,%eax
  801c5e:	e8 93 ff ff ff       	call   801bf6 <nsipc>
  801c63:	89 c3                	mov    %eax,%ebx
  801c65:	85 c0                	test   %eax,%eax
  801c67:	79 09                	jns    801c72 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801c69:	89 d8                	mov    %ebx,%eax
  801c6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c6e:	5b                   	pop    %ebx
  801c6f:	5e                   	pop    %esi
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c72:	83 ec 04             	sub    $0x4,%esp
  801c75:	ff 35 10 70 80 00    	push   0x807010
  801c7b:	68 00 70 80 00       	push   $0x807000
  801c80:	ff 75 0c             	push   0xc(%ebp)
  801c83:	e8 c3 f0 ff ff       	call   800d4b <memmove>
		*addrlen = ret->ret_addrlen;
  801c88:	a1 10 70 80 00       	mov    0x807010,%eax
  801c8d:	89 06                	mov    %eax,(%esi)
  801c8f:	83 c4 10             	add    $0x10,%esp
	return r;
  801c92:	eb d5                	jmp    801c69 <nsipc_accept+0x27>

00801c94 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	53                   	push   %ebx
  801c98:	83 ec 08             	sub    $0x8,%esp
  801c9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca1:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ca6:	53                   	push   %ebx
  801ca7:	ff 75 0c             	push   0xc(%ebp)
  801caa:	68 04 70 80 00       	push   $0x807004
  801caf:	e8 97 f0 ff ff       	call   800d4b <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801cb4:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801cba:	b8 02 00 00 00       	mov    $0x2,%eax
  801cbf:	e8 32 ff ff ff       	call   801bf6 <nsipc>
}
  801cc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc7:	c9                   	leave  
  801cc8:	c3                   	ret    

00801cc9 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cc9:	55                   	push   %ebp
  801cca:	89 e5                	mov    %esp,%ebp
  801ccc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801cd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cda:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801cdf:	b8 03 00 00 00       	mov    $0x3,%eax
  801ce4:	e8 0d ff ff ff       	call   801bf6 <nsipc>
}
  801ce9:	c9                   	leave  
  801cea:	c3                   	ret    

00801ceb <nsipc_close>:

int
nsipc_close(int s)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf4:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801cf9:	b8 04 00 00 00       	mov    $0x4,%eax
  801cfe:	e8 f3 fe ff ff       	call   801bf6 <nsipc>
}
  801d03:	c9                   	leave  
  801d04:	c3                   	ret    

00801d05 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	53                   	push   %ebx
  801d09:	83 ec 08             	sub    $0x8,%esp
  801d0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d12:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d17:	53                   	push   %ebx
  801d18:	ff 75 0c             	push   0xc(%ebp)
  801d1b:	68 04 70 80 00       	push   $0x807004
  801d20:	e8 26 f0 ff ff       	call   800d4b <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d25:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801d2b:	b8 05 00 00 00       	mov    $0x5,%eax
  801d30:	e8 c1 fe ff ff       	call   801bf6 <nsipc>
}
  801d35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d38:	c9                   	leave  
  801d39:	c3                   	ret    

00801d3a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d40:	8b 45 08             	mov    0x8(%ebp),%eax
  801d43:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801d48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d4b:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801d50:	b8 06 00 00 00       	mov    $0x6,%eax
  801d55:	e8 9c fe ff ff       	call   801bf6 <nsipc>
}
  801d5a:	c9                   	leave  
  801d5b:	c3                   	ret    

00801d5c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	56                   	push   %esi
  801d60:	53                   	push   %ebx
  801d61:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d64:	8b 45 08             	mov    0x8(%ebp),%eax
  801d67:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801d6c:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801d72:	8b 45 14             	mov    0x14(%ebp),%eax
  801d75:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d7a:	b8 07 00 00 00       	mov    $0x7,%eax
  801d7f:	e8 72 fe ff ff       	call   801bf6 <nsipc>
  801d84:	89 c3                	mov    %eax,%ebx
  801d86:	85 c0                	test   %eax,%eax
  801d88:	78 22                	js     801dac <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801d8a:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801d8f:	39 c6                	cmp    %eax,%esi
  801d91:	0f 4e c6             	cmovle %esi,%eax
  801d94:	39 c3                	cmp    %eax,%ebx
  801d96:	7f 1d                	jg     801db5 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d98:	83 ec 04             	sub    $0x4,%esp
  801d9b:	53                   	push   %ebx
  801d9c:	68 00 70 80 00       	push   $0x807000
  801da1:	ff 75 0c             	push   0xc(%ebp)
  801da4:	e8 a2 ef ff ff       	call   800d4b <memmove>
  801da9:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801dac:	89 d8                	mov    %ebx,%eax
  801dae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db1:	5b                   	pop    %ebx
  801db2:	5e                   	pop    %esi
  801db3:	5d                   	pop    %ebp
  801db4:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801db5:	68 1b 2c 80 00       	push   $0x802c1b
  801dba:	68 e3 2b 80 00       	push   $0x802be3
  801dbf:	6a 62                	push   $0x62
  801dc1:	68 30 2c 80 00       	push   $0x802c30
  801dc6:	e8 46 05 00 00       	call   802311 <_panic>

00801dcb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	53                   	push   %ebx
  801dcf:	83 ec 04             	sub    $0x4,%esp
  801dd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801dd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd8:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801ddd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801de3:	7f 2e                	jg     801e13 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801de5:	83 ec 04             	sub    $0x4,%esp
  801de8:	53                   	push   %ebx
  801de9:	ff 75 0c             	push   0xc(%ebp)
  801dec:	68 0c 70 80 00       	push   $0x80700c
  801df1:	e8 55 ef ff ff       	call   800d4b <memmove>
	nsipcbuf.send.req_size = size;
  801df6:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801dfc:	8b 45 14             	mov    0x14(%ebp),%eax
  801dff:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801e04:	b8 08 00 00 00       	mov    $0x8,%eax
  801e09:	e8 e8 fd ff ff       	call   801bf6 <nsipc>
}
  801e0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e11:	c9                   	leave  
  801e12:	c3                   	ret    
	assert(size < 1600);
  801e13:	68 3c 2c 80 00       	push   $0x802c3c
  801e18:	68 e3 2b 80 00       	push   $0x802be3
  801e1d:	6a 6d                	push   $0x6d
  801e1f:	68 30 2c 80 00       	push   $0x802c30
  801e24:	e8 e8 04 00 00       	call   802311 <_panic>

00801e29 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e29:	55                   	push   %ebp
  801e2a:	89 e5                	mov    %esp,%ebp
  801e2c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e32:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801e37:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3a:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801e3f:	8b 45 10             	mov    0x10(%ebp),%eax
  801e42:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801e47:	b8 09 00 00 00       	mov    $0x9,%eax
  801e4c:	e8 a5 fd ff ff       	call   801bf6 <nsipc>
}
  801e51:	c9                   	leave  
  801e52:	c3                   	ret    

00801e53 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	56                   	push   %esi
  801e57:	53                   	push   %ebx
  801e58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e5b:	83 ec 0c             	sub    $0xc,%esp
  801e5e:	ff 75 08             	push   0x8(%ebp)
  801e61:	e8 ad f3 ff ff       	call   801213 <fd2data>
  801e66:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e68:	83 c4 08             	add    $0x8,%esp
  801e6b:	68 48 2c 80 00       	push   $0x802c48
  801e70:	53                   	push   %ebx
  801e71:	e8 3f ed ff ff       	call   800bb5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e76:	8b 46 04             	mov    0x4(%esi),%eax
  801e79:	2b 06                	sub    (%esi),%eax
  801e7b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e81:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e88:	00 00 00 
	stat->st_dev = &devpipe;
  801e8b:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e92:	30 80 00 
	return 0;
}
  801e95:	b8 00 00 00 00       	mov    $0x0,%eax
  801e9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e9d:	5b                   	pop    %ebx
  801e9e:	5e                   	pop    %esi
  801e9f:	5d                   	pop    %ebp
  801ea0:	c3                   	ret    

00801ea1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	53                   	push   %ebx
  801ea5:	83 ec 0c             	sub    $0xc,%esp
  801ea8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801eab:	53                   	push   %ebx
  801eac:	6a 00                	push   $0x0
  801eae:	e8 83 f1 ff ff       	call   801036 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801eb3:	89 1c 24             	mov    %ebx,(%esp)
  801eb6:	e8 58 f3 ff ff       	call   801213 <fd2data>
  801ebb:	83 c4 08             	add    $0x8,%esp
  801ebe:	50                   	push   %eax
  801ebf:	6a 00                	push   $0x0
  801ec1:	e8 70 f1 ff ff       	call   801036 <sys_page_unmap>
}
  801ec6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ec9:	c9                   	leave  
  801eca:	c3                   	ret    

00801ecb <_pipeisclosed>:
{
  801ecb:	55                   	push   %ebp
  801ecc:	89 e5                	mov    %esp,%ebp
  801ece:	57                   	push   %edi
  801ecf:	56                   	push   %esi
  801ed0:	53                   	push   %ebx
  801ed1:	83 ec 1c             	sub    $0x1c,%esp
  801ed4:	89 c7                	mov    %eax,%edi
  801ed6:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801ed8:	a1 10 40 80 00       	mov    0x804010,%eax
  801edd:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ee0:	83 ec 0c             	sub    $0xc,%esp
  801ee3:	57                   	push   %edi
  801ee4:	e8 62 05 00 00       	call   80244b <pageref>
  801ee9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801eec:	89 34 24             	mov    %esi,(%esp)
  801eef:	e8 57 05 00 00       	call   80244b <pageref>
		nn = thisenv->env_runs;
  801ef4:	8b 15 10 40 80 00    	mov    0x804010,%edx
  801efa:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801efd:	83 c4 10             	add    $0x10,%esp
  801f00:	39 cb                	cmp    %ecx,%ebx
  801f02:	74 1b                	je     801f1f <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801f04:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f07:	75 cf                	jne    801ed8 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f09:	8b 42 58             	mov    0x58(%edx),%eax
  801f0c:	6a 01                	push   $0x1
  801f0e:	50                   	push   %eax
  801f0f:	53                   	push   %ebx
  801f10:	68 4f 2c 80 00       	push   $0x802c4f
  801f15:	e8 c1 e6 ff ff       	call   8005db <cprintf>
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	eb b9                	jmp    801ed8 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801f1f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f22:	0f 94 c0             	sete   %al
  801f25:	0f b6 c0             	movzbl %al,%eax
}
  801f28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f2b:	5b                   	pop    %ebx
  801f2c:	5e                   	pop    %esi
  801f2d:	5f                   	pop    %edi
  801f2e:	5d                   	pop    %ebp
  801f2f:	c3                   	ret    

00801f30 <devpipe_write>:
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	57                   	push   %edi
  801f34:	56                   	push   %esi
  801f35:	53                   	push   %ebx
  801f36:	83 ec 28             	sub    $0x28,%esp
  801f39:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801f3c:	56                   	push   %esi
  801f3d:	e8 d1 f2 ff ff       	call   801213 <fd2data>
  801f42:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f44:	83 c4 10             	add    $0x10,%esp
  801f47:	bf 00 00 00 00       	mov    $0x0,%edi
  801f4c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f4f:	75 09                	jne    801f5a <devpipe_write+0x2a>
	return i;
  801f51:	89 f8                	mov    %edi,%eax
  801f53:	eb 23                	jmp    801f78 <devpipe_write+0x48>
			sys_yield();
  801f55:	e8 38 f0 ff ff       	call   800f92 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f5a:	8b 43 04             	mov    0x4(%ebx),%eax
  801f5d:	8b 0b                	mov    (%ebx),%ecx
  801f5f:	8d 51 20             	lea    0x20(%ecx),%edx
  801f62:	39 d0                	cmp    %edx,%eax
  801f64:	72 1a                	jb     801f80 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801f66:	89 da                	mov    %ebx,%edx
  801f68:	89 f0                	mov    %esi,%eax
  801f6a:	e8 5c ff ff ff       	call   801ecb <_pipeisclosed>
  801f6f:	85 c0                	test   %eax,%eax
  801f71:	74 e2                	je     801f55 <devpipe_write+0x25>
				return 0;
  801f73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7b:	5b                   	pop    %ebx
  801f7c:	5e                   	pop    %esi
  801f7d:	5f                   	pop    %edi
  801f7e:	5d                   	pop    %ebp
  801f7f:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f83:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f87:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f8a:	89 c2                	mov    %eax,%edx
  801f8c:	c1 fa 1f             	sar    $0x1f,%edx
  801f8f:	89 d1                	mov    %edx,%ecx
  801f91:	c1 e9 1b             	shr    $0x1b,%ecx
  801f94:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f97:	83 e2 1f             	and    $0x1f,%edx
  801f9a:	29 ca                	sub    %ecx,%edx
  801f9c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fa0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fa4:	83 c0 01             	add    $0x1,%eax
  801fa7:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801faa:	83 c7 01             	add    $0x1,%edi
  801fad:	eb 9d                	jmp    801f4c <devpipe_write+0x1c>

00801faf <devpipe_read>:
{
  801faf:	55                   	push   %ebp
  801fb0:	89 e5                	mov    %esp,%ebp
  801fb2:	57                   	push   %edi
  801fb3:	56                   	push   %esi
  801fb4:	53                   	push   %ebx
  801fb5:	83 ec 18             	sub    $0x18,%esp
  801fb8:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801fbb:	57                   	push   %edi
  801fbc:	e8 52 f2 ff ff       	call   801213 <fd2data>
  801fc1:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801fc3:	83 c4 10             	add    $0x10,%esp
  801fc6:	be 00 00 00 00       	mov    $0x0,%esi
  801fcb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fce:	75 13                	jne    801fe3 <devpipe_read+0x34>
	return i;
  801fd0:	89 f0                	mov    %esi,%eax
  801fd2:	eb 02                	jmp    801fd6 <devpipe_read+0x27>
				return i;
  801fd4:	89 f0                	mov    %esi,%eax
}
  801fd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd9:	5b                   	pop    %ebx
  801fda:	5e                   	pop    %esi
  801fdb:	5f                   	pop    %edi
  801fdc:	5d                   	pop    %ebp
  801fdd:	c3                   	ret    
			sys_yield();
  801fde:	e8 af ef ff ff       	call   800f92 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801fe3:	8b 03                	mov    (%ebx),%eax
  801fe5:	3b 43 04             	cmp    0x4(%ebx),%eax
  801fe8:	75 18                	jne    802002 <devpipe_read+0x53>
			if (i > 0)
  801fea:	85 f6                	test   %esi,%esi
  801fec:	75 e6                	jne    801fd4 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801fee:	89 da                	mov    %ebx,%edx
  801ff0:	89 f8                	mov    %edi,%eax
  801ff2:	e8 d4 fe ff ff       	call   801ecb <_pipeisclosed>
  801ff7:	85 c0                	test   %eax,%eax
  801ff9:	74 e3                	je     801fde <devpipe_read+0x2f>
				return 0;
  801ffb:	b8 00 00 00 00       	mov    $0x0,%eax
  802000:	eb d4                	jmp    801fd6 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802002:	99                   	cltd   
  802003:	c1 ea 1b             	shr    $0x1b,%edx
  802006:	01 d0                	add    %edx,%eax
  802008:	83 e0 1f             	and    $0x1f,%eax
  80200b:	29 d0                	sub    %edx,%eax
  80200d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802012:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802015:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802018:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80201b:	83 c6 01             	add    $0x1,%esi
  80201e:	eb ab                	jmp    801fcb <devpipe_read+0x1c>

00802020 <pipe>:
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	56                   	push   %esi
  802024:	53                   	push   %ebx
  802025:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802028:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80202b:	50                   	push   %eax
  80202c:	e8 f9 f1 ff ff       	call   80122a <fd_alloc>
  802031:	89 c3                	mov    %eax,%ebx
  802033:	83 c4 10             	add    $0x10,%esp
  802036:	85 c0                	test   %eax,%eax
  802038:	0f 88 23 01 00 00    	js     802161 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80203e:	83 ec 04             	sub    $0x4,%esp
  802041:	68 07 04 00 00       	push   $0x407
  802046:	ff 75 f4             	push   -0xc(%ebp)
  802049:	6a 00                	push   $0x0
  80204b:	e8 61 ef ff ff       	call   800fb1 <sys_page_alloc>
  802050:	89 c3                	mov    %eax,%ebx
  802052:	83 c4 10             	add    $0x10,%esp
  802055:	85 c0                	test   %eax,%eax
  802057:	0f 88 04 01 00 00    	js     802161 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  80205d:	83 ec 0c             	sub    $0xc,%esp
  802060:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802063:	50                   	push   %eax
  802064:	e8 c1 f1 ff ff       	call   80122a <fd_alloc>
  802069:	89 c3                	mov    %eax,%ebx
  80206b:	83 c4 10             	add    $0x10,%esp
  80206e:	85 c0                	test   %eax,%eax
  802070:	0f 88 db 00 00 00    	js     802151 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802076:	83 ec 04             	sub    $0x4,%esp
  802079:	68 07 04 00 00       	push   $0x407
  80207e:	ff 75 f0             	push   -0x10(%ebp)
  802081:	6a 00                	push   $0x0
  802083:	e8 29 ef ff ff       	call   800fb1 <sys_page_alloc>
  802088:	89 c3                	mov    %eax,%ebx
  80208a:	83 c4 10             	add    $0x10,%esp
  80208d:	85 c0                	test   %eax,%eax
  80208f:	0f 88 bc 00 00 00    	js     802151 <pipe+0x131>
	va = fd2data(fd0);
  802095:	83 ec 0c             	sub    $0xc,%esp
  802098:	ff 75 f4             	push   -0xc(%ebp)
  80209b:	e8 73 f1 ff ff       	call   801213 <fd2data>
  8020a0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020a2:	83 c4 0c             	add    $0xc,%esp
  8020a5:	68 07 04 00 00       	push   $0x407
  8020aa:	50                   	push   %eax
  8020ab:	6a 00                	push   $0x0
  8020ad:	e8 ff ee ff ff       	call   800fb1 <sys_page_alloc>
  8020b2:	89 c3                	mov    %eax,%ebx
  8020b4:	83 c4 10             	add    $0x10,%esp
  8020b7:	85 c0                	test   %eax,%eax
  8020b9:	0f 88 82 00 00 00    	js     802141 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020bf:	83 ec 0c             	sub    $0xc,%esp
  8020c2:	ff 75 f0             	push   -0x10(%ebp)
  8020c5:	e8 49 f1 ff ff       	call   801213 <fd2data>
  8020ca:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020d1:	50                   	push   %eax
  8020d2:	6a 00                	push   $0x0
  8020d4:	56                   	push   %esi
  8020d5:	6a 00                	push   $0x0
  8020d7:	e8 18 ef ff ff       	call   800ff4 <sys_page_map>
  8020dc:	89 c3                	mov    %eax,%ebx
  8020de:	83 c4 20             	add    $0x20,%esp
  8020e1:	85 c0                	test   %eax,%eax
  8020e3:	78 4e                	js     802133 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8020e5:	a1 3c 30 80 00       	mov    0x80303c,%eax
  8020ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020ed:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8020ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020f2:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8020f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020fc:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8020fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802101:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802108:	83 ec 0c             	sub    $0xc,%esp
  80210b:	ff 75 f4             	push   -0xc(%ebp)
  80210e:	e8 f0 f0 ff ff       	call   801203 <fd2num>
  802113:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802116:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802118:	83 c4 04             	add    $0x4,%esp
  80211b:	ff 75 f0             	push   -0x10(%ebp)
  80211e:	e8 e0 f0 ff ff       	call   801203 <fd2num>
  802123:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802126:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802129:	83 c4 10             	add    $0x10,%esp
  80212c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802131:	eb 2e                	jmp    802161 <pipe+0x141>
	sys_page_unmap(0, va);
  802133:	83 ec 08             	sub    $0x8,%esp
  802136:	56                   	push   %esi
  802137:	6a 00                	push   $0x0
  802139:	e8 f8 ee ff ff       	call   801036 <sys_page_unmap>
  80213e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802141:	83 ec 08             	sub    $0x8,%esp
  802144:	ff 75 f0             	push   -0x10(%ebp)
  802147:	6a 00                	push   $0x0
  802149:	e8 e8 ee ff ff       	call   801036 <sys_page_unmap>
  80214e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802151:	83 ec 08             	sub    $0x8,%esp
  802154:	ff 75 f4             	push   -0xc(%ebp)
  802157:	6a 00                	push   $0x0
  802159:	e8 d8 ee ff ff       	call   801036 <sys_page_unmap>
  80215e:	83 c4 10             	add    $0x10,%esp
}
  802161:	89 d8                	mov    %ebx,%eax
  802163:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802166:	5b                   	pop    %ebx
  802167:	5e                   	pop    %esi
  802168:	5d                   	pop    %ebp
  802169:	c3                   	ret    

0080216a <pipeisclosed>:
{
  80216a:	55                   	push   %ebp
  80216b:	89 e5                	mov    %esp,%ebp
  80216d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802170:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802173:	50                   	push   %eax
  802174:	ff 75 08             	push   0x8(%ebp)
  802177:	e8 fe f0 ff ff       	call   80127a <fd_lookup>
  80217c:	83 c4 10             	add    $0x10,%esp
  80217f:	85 c0                	test   %eax,%eax
  802181:	78 18                	js     80219b <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802183:	83 ec 0c             	sub    $0xc,%esp
  802186:	ff 75 f4             	push   -0xc(%ebp)
  802189:	e8 85 f0 ff ff       	call   801213 <fd2data>
  80218e:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802190:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802193:	e8 33 fd ff ff       	call   801ecb <_pipeisclosed>
  802198:	83 c4 10             	add    $0x10,%esp
}
  80219b:	c9                   	leave  
  80219c:	c3                   	ret    

0080219d <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80219d:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a2:	c3                   	ret    

008021a3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021a3:	55                   	push   %ebp
  8021a4:	89 e5                	mov    %esp,%ebp
  8021a6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021a9:	68 67 2c 80 00       	push   $0x802c67
  8021ae:	ff 75 0c             	push   0xc(%ebp)
  8021b1:	e8 ff e9 ff ff       	call   800bb5 <strcpy>
	return 0;
}
  8021b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8021bb:	c9                   	leave  
  8021bc:	c3                   	ret    

008021bd <devcons_write>:
{
  8021bd:	55                   	push   %ebp
  8021be:	89 e5                	mov    %esp,%ebp
  8021c0:	57                   	push   %edi
  8021c1:	56                   	push   %esi
  8021c2:	53                   	push   %ebx
  8021c3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8021c9:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8021ce:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8021d4:	eb 2e                	jmp    802204 <devcons_write+0x47>
		m = n - tot;
  8021d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021d9:	29 f3                	sub    %esi,%ebx
  8021db:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8021e0:	39 c3                	cmp    %eax,%ebx
  8021e2:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8021e5:	83 ec 04             	sub    $0x4,%esp
  8021e8:	53                   	push   %ebx
  8021e9:	89 f0                	mov    %esi,%eax
  8021eb:	03 45 0c             	add    0xc(%ebp),%eax
  8021ee:	50                   	push   %eax
  8021ef:	57                   	push   %edi
  8021f0:	e8 56 eb ff ff       	call   800d4b <memmove>
		sys_cputs(buf, m);
  8021f5:	83 c4 08             	add    $0x8,%esp
  8021f8:	53                   	push   %ebx
  8021f9:	57                   	push   %edi
  8021fa:	e8 f6 ec ff ff       	call   800ef5 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8021ff:	01 de                	add    %ebx,%esi
  802201:	83 c4 10             	add    $0x10,%esp
  802204:	3b 75 10             	cmp    0x10(%ebp),%esi
  802207:	72 cd                	jb     8021d6 <devcons_write+0x19>
}
  802209:	89 f0                	mov    %esi,%eax
  80220b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80220e:	5b                   	pop    %ebx
  80220f:	5e                   	pop    %esi
  802210:	5f                   	pop    %edi
  802211:	5d                   	pop    %ebp
  802212:	c3                   	ret    

00802213 <devcons_read>:
{
  802213:	55                   	push   %ebp
  802214:	89 e5                	mov    %esp,%ebp
  802216:	83 ec 08             	sub    $0x8,%esp
  802219:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80221e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802222:	75 07                	jne    80222b <devcons_read+0x18>
  802224:	eb 1f                	jmp    802245 <devcons_read+0x32>
		sys_yield();
  802226:	e8 67 ed ff ff       	call   800f92 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80222b:	e8 e3 ec ff ff       	call   800f13 <sys_cgetc>
  802230:	85 c0                	test   %eax,%eax
  802232:	74 f2                	je     802226 <devcons_read+0x13>
	if (c < 0)
  802234:	78 0f                	js     802245 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802236:	83 f8 04             	cmp    $0x4,%eax
  802239:	74 0c                	je     802247 <devcons_read+0x34>
	*(char*)vbuf = c;
  80223b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80223e:	88 02                	mov    %al,(%edx)
	return 1;
  802240:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802245:	c9                   	leave  
  802246:	c3                   	ret    
		return 0;
  802247:	b8 00 00 00 00       	mov    $0x0,%eax
  80224c:	eb f7                	jmp    802245 <devcons_read+0x32>

0080224e <cputchar>:
{
  80224e:	55                   	push   %ebp
  80224f:	89 e5                	mov    %esp,%ebp
  802251:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802254:	8b 45 08             	mov    0x8(%ebp),%eax
  802257:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80225a:	6a 01                	push   $0x1
  80225c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80225f:	50                   	push   %eax
  802260:	e8 90 ec ff ff       	call   800ef5 <sys_cputs>
}
  802265:	83 c4 10             	add    $0x10,%esp
  802268:	c9                   	leave  
  802269:	c3                   	ret    

0080226a <getchar>:
{
  80226a:	55                   	push   %ebp
  80226b:	89 e5                	mov    %esp,%ebp
  80226d:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802270:	6a 01                	push   $0x1
  802272:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802275:	50                   	push   %eax
  802276:	6a 00                	push   $0x0
  802278:	e8 66 f2 ff ff       	call   8014e3 <read>
	if (r < 0)
  80227d:	83 c4 10             	add    $0x10,%esp
  802280:	85 c0                	test   %eax,%eax
  802282:	78 06                	js     80228a <getchar+0x20>
	if (r < 1)
  802284:	74 06                	je     80228c <getchar+0x22>
	return c;
  802286:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80228a:	c9                   	leave  
  80228b:	c3                   	ret    
		return -E_EOF;
  80228c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802291:	eb f7                	jmp    80228a <getchar+0x20>

00802293 <iscons>:
{
  802293:	55                   	push   %ebp
  802294:	89 e5                	mov    %esp,%ebp
  802296:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802299:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80229c:	50                   	push   %eax
  80229d:	ff 75 08             	push   0x8(%ebp)
  8022a0:	e8 d5 ef ff ff       	call   80127a <fd_lookup>
  8022a5:	83 c4 10             	add    $0x10,%esp
  8022a8:	85 c0                	test   %eax,%eax
  8022aa:	78 11                	js     8022bd <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8022ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022af:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022b5:	39 10                	cmp    %edx,(%eax)
  8022b7:	0f 94 c0             	sete   %al
  8022ba:	0f b6 c0             	movzbl %al,%eax
}
  8022bd:	c9                   	leave  
  8022be:	c3                   	ret    

008022bf <opencons>:
{
  8022bf:	55                   	push   %ebp
  8022c0:	89 e5                	mov    %esp,%ebp
  8022c2:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8022c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022c8:	50                   	push   %eax
  8022c9:	e8 5c ef ff ff       	call   80122a <fd_alloc>
  8022ce:	83 c4 10             	add    $0x10,%esp
  8022d1:	85 c0                	test   %eax,%eax
  8022d3:	78 3a                	js     80230f <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022d5:	83 ec 04             	sub    $0x4,%esp
  8022d8:	68 07 04 00 00       	push   $0x407
  8022dd:	ff 75 f4             	push   -0xc(%ebp)
  8022e0:	6a 00                	push   $0x0
  8022e2:	e8 ca ec ff ff       	call   800fb1 <sys_page_alloc>
  8022e7:	83 c4 10             	add    $0x10,%esp
  8022ea:	85 c0                	test   %eax,%eax
  8022ec:	78 21                	js     80230f <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8022ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f1:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022f7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022fc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802303:	83 ec 0c             	sub    $0xc,%esp
  802306:	50                   	push   %eax
  802307:	e8 f7 ee ff ff       	call   801203 <fd2num>
  80230c:	83 c4 10             	add    $0x10,%esp
}
  80230f:	c9                   	leave  
  802310:	c3                   	ret    

00802311 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802311:	55                   	push   %ebp
  802312:	89 e5                	mov    %esp,%ebp
  802314:	56                   	push   %esi
  802315:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802316:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802319:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80231f:	e8 4f ec ff ff       	call   800f73 <sys_getenvid>
  802324:	83 ec 0c             	sub    $0xc,%esp
  802327:	ff 75 0c             	push   0xc(%ebp)
  80232a:	ff 75 08             	push   0x8(%ebp)
  80232d:	56                   	push   %esi
  80232e:	50                   	push   %eax
  80232f:	68 74 2c 80 00       	push   $0x802c74
  802334:	e8 a2 e2 ff ff       	call   8005db <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802339:	83 c4 18             	add    $0x18,%esp
  80233c:	53                   	push   %ebx
  80233d:	ff 75 10             	push   0x10(%ebp)
  802340:	e8 45 e2 ff ff       	call   80058a <vcprintf>
	cprintf("\n");
  802345:	c7 04 24 60 2c 80 00 	movl   $0x802c60,(%esp)
  80234c:	e8 8a e2 ff ff       	call   8005db <cprintf>
  802351:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802354:	cc                   	int3   
  802355:	eb fd                	jmp    802354 <_panic+0x43>

00802357 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802357:	55                   	push   %ebp
  802358:	89 e5                	mov    %esp,%ebp
  80235a:	56                   	push   %esi
  80235b:	53                   	push   %ebx
  80235c:	8b 75 08             	mov    0x8(%ebp),%esi
  80235f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802362:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  802365:	85 c0                	test   %eax,%eax
  802367:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80236c:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  80236f:	83 ec 0c             	sub    $0xc,%esp
  802372:	50                   	push   %eax
  802373:	e8 e9 ed ff ff       	call   801161 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802378:	83 c4 10             	add    $0x10,%esp
  80237b:	85 f6                	test   %esi,%esi
  80237d:	74 14                	je     802393 <ipc_recv+0x3c>
  80237f:	ba 00 00 00 00       	mov    $0x0,%edx
  802384:	85 c0                	test   %eax,%eax
  802386:	78 09                	js     802391 <ipc_recv+0x3a>
  802388:	8b 15 10 40 80 00    	mov    0x804010,%edx
  80238e:	8b 52 74             	mov    0x74(%edx),%edx
  802391:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802393:	85 db                	test   %ebx,%ebx
  802395:	74 14                	je     8023ab <ipc_recv+0x54>
  802397:	ba 00 00 00 00       	mov    $0x0,%edx
  80239c:	85 c0                	test   %eax,%eax
  80239e:	78 09                	js     8023a9 <ipc_recv+0x52>
  8023a0:	8b 15 10 40 80 00    	mov    0x804010,%edx
  8023a6:	8b 52 78             	mov    0x78(%edx),%edx
  8023a9:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8023ab:	85 c0                	test   %eax,%eax
  8023ad:	78 08                	js     8023b7 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  8023af:	a1 10 40 80 00       	mov    0x804010,%eax
  8023b4:	8b 40 70             	mov    0x70(%eax),%eax
}
  8023b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023ba:	5b                   	pop    %ebx
  8023bb:	5e                   	pop    %esi
  8023bc:	5d                   	pop    %ebp
  8023bd:	c3                   	ret    

008023be <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023be:	55                   	push   %ebp
  8023bf:	89 e5                	mov    %esp,%ebp
  8023c1:	57                   	push   %edi
  8023c2:	56                   	push   %esi
  8023c3:	53                   	push   %ebx
  8023c4:	83 ec 0c             	sub    $0xc,%esp
  8023c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023ca:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8023d0:	85 db                	test   %ebx,%ebx
  8023d2:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023d7:	0f 44 d8             	cmove  %eax,%ebx
  8023da:	eb 05                	jmp    8023e1 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8023dc:	e8 b1 eb ff ff       	call   800f92 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8023e1:	ff 75 14             	push   0x14(%ebp)
  8023e4:	53                   	push   %ebx
  8023e5:	56                   	push   %esi
  8023e6:	57                   	push   %edi
  8023e7:	e8 52 ed ff ff       	call   80113e <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8023ec:	83 c4 10             	add    $0x10,%esp
  8023ef:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023f2:	74 e8                	je     8023dc <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8023f4:	85 c0                	test   %eax,%eax
  8023f6:	78 08                	js     802400 <ipc_send+0x42>
	}while (r<0);

}
  8023f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023fb:	5b                   	pop    %ebx
  8023fc:	5e                   	pop    %esi
  8023fd:	5f                   	pop    %edi
  8023fe:	5d                   	pop    %ebp
  8023ff:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802400:	50                   	push   %eax
  802401:	68 97 2c 80 00       	push   $0x802c97
  802406:	6a 3d                	push   $0x3d
  802408:	68 ab 2c 80 00       	push   $0x802cab
  80240d:	e8 ff fe ff ff       	call   802311 <_panic>

00802412 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802412:	55                   	push   %ebp
  802413:	89 e5                	mov    %esp,%ebp
  802415:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802418:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80241d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802420:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802426:	8b 52 50             	mov    0x50(%edx),%edx
  802429:	39 ca                	cmp    %ecx,%edx
  80242b:	74 11                	je     80243e <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  80242d:	83 c0 01             	add    $0x1,%eax
  802430:	3d 00 04 00 00       	cmp    $0x400,%eax
  802435:	75 e6                	jne    80241d <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802437:	b8 00 00 00 00       	mov    $0x0,%eax
  80243c:	eb 0b                	jmp    802449 <ipc_find_env+0x37>
			return envs[i].env_id;
  80243e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802441:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802446:	8b 40 48             	mov    0x48(%eax),%eax
}
  802449:	5d                   	pop    %ebp
  80244a:	c3                   	ret    

0080244b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80244b:	55                   	push   %ebp
  80244c:	89 e5                	mov    %esp,%ebp
  80244e:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802451:	89 c2                	mov    %eax,%edx
  802453:	c1 ea 16             	shr    $0x16,%edx
  802456:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80245d:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802462:	f6 c1 01             	test   $0x1,%cl
  802465:	74 1c                	je     802483 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802467:	c1 e8 0c             	shr    $0xc,%eax
  80246a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802471:	a8 01                	test   $0x1,%al
  802473:	74 0e                	je     802483 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802475:	c1 e8 0c             	shr    $0xc,%eax
  802478:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80247f:	ef 
  802480:	0f b7 d2             	movzwl %dx,%edx
}
  802483:	89 d0                	mov    %edx,%eax
  802485:	5d                   	pop    %ebp
  802486:	c3                   	ret    
  802487:	66 90                	xchg   %ax,%ax
  802489:	66 90                	xchg   %ax,%ax
  80248b:	66 90                	xchg   %ax,%ax
  80248d:	66 90                	xchg   %ax,%ax
  80248f:	90                   	nop

00802490 <__udivdi3>:
  802490:	f3 0f 1e fb          	endbr32 
  802494:	55                   	push   %ebp
  802495:	57                   	push   %edi
  802496:	56                   	push   %esi
  802497:	53                   	push   %ebx
  802498:	83 ec 1c             	sub    $0x1c,%esp
  80249b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80249f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8024a3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8024ab:	85 c0                	test   %eax,%eax
  8024ad:	75 19                	jne    8024c8 <__udivdi3+0x38>
  8024af:	39 f3                	cmp    %esi,%ebx
  8024b1:	76 4d                	jbe    802500 <__udivdi3+0x70>
  8024b3:	31 ff                	xor    %edi,%edi
  8024b5:	89 e8                	mov    %ebp,%eax
  8024b7:	89 f2                	mov    %esi,%edx
  8024b9:	f7 f3                	div    %ebx
  8024bb:	89 fa                	mov    %edi,%edx
  8024bd:	83 c4 1c             	add    $0x1c,%esp
  8024c0:	5b                   	pop    %ebx
  8024c1:	5e                   	pop    %esi
  8024c2:	5f                   	pop    %edi
  8024c3:	5d                   	pop    %ebp
  8024c4:	c3                   	ret    
  8024c5:	8d 76 00             	lea    0x0(%esi),%esi
  8024c8:	39 f0                	cmp    %esi,%eax
  8024ca:	76 14                	jbe    8024e0 <__udivdi3+0x50>
  8024cc:	31 ff                	xor    %edi,%edi
  8024ce:	31 c0                	xor    %eax,%eax
  8024d0:	89 fa                	mov    %edi,%edx
  8024d2:	83 c4 1c             	add    $0x1c,%esp
  8024d5:	5b                   	pop    %ebx
  8024d6:	5e                   	pop    %esi
  8024d7:	5f                   	pop    %edi
  8024d8:	5d                   	pop    %ebp
  8024d9:	c3                   	ret    
  8024da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024e0:	0f bd f8             	bsr    %eax,%edi
  8024e3:	83 f7 1f             	xor    $0x1f,%edi
  8024e6:	75 48                	jne    802530 <__udivdi3+0xa0>
  8024e8:	39 f0                	cmp    %esi,%eax
  8024ea:	72 06                	jb     8024f2 <__udivdi3+0x62>
  8024ec:	31 c0                	xor    %eax,%eax
  8024ee:	39 eb                	cmp    %ebp,%ebx
  8024f0:	77 de                	ja     8024d0 <__udivdi3+0x40>
  8024f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8024f7:	eb d7                	jmp    8024d0 <__udivdi3+0x40>
  8024f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802500:	89 d9                	mov    %ebx,%ecx
  802502:	85 db                	test   %ebx,%ebx
  802504:	75 0b                	jne    802511 <__udivdi3+0x81>
  802506:	b8 01 00 00 00       	mov    $0x1,%eax
  80250b:	31 d2                	xor    %edx,%edx
  80250d:	f7 f3                	div    %ebx
  80250f:	89 c1                	mov    %eax,%ecx
  802511:	31 d2                	xor    %edx,%edx
  802513:	89 f0                	mov    %esi,%eax
  802515:	f7 f1                	div    %ecx
  802517:	89 c6                	mov    %eax,%esi
  802519:	89 e8                	mov    %ebp,%eax
  80251b:	89 f7                	mov    %esi,%edi
  80251d:	f7 f1                	div    %ecx
  80251f:	89 fa                	mov    %edi,%edx
  802521:	83 c4 1c             	add    $0x1c,%esp
  802524:	5b                   	pop    %ebx
  802525:	5e                   	pop    %esi
  802526:	5f                   	pop    %edi
  802527:	5d                   	pop    %ebp
  802528:	c3                   	ret    
  802529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802530:	89 f9                	mov    %edi,%ecx
  802532:	ba 20 00 00 00       	mov    $0x20,%edx
  802537:	29 fa                	sub    %edi,%edx
  802539:	d3 e0                	shl    %cl,%eax
  80253b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80253f:	89 d1                	mov    %edx,%ecx
  802541:	89 d8                	mov    %ebx,%eax
  802543:	d3 e8                	shr    %cl,%eax
  802545:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802549:	09 c1                	or     %eax,%ecx
  80254b:	89 f0                	mov    %esi,%eax
  80254d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802551:	89 f9                	mov    %edi,%ecx
  802553:	d3 e3                	shl    %cl,%ebx
  802555:	89 d1                	mov    %edx,%ecx
  802557:	d3 e8                	shr    %cl,%eax
  802559:	89 f9                	mov    %edi,%ecx
  80255b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80255f:	89 eb                	mov    %ebp,%ebx
  802561:	d3 e6                	shl    %cl,%esi
  802563:	89 d1                	mov    %edx,%ecx
  802565:	d3 eb                	shr    %cl,%ebx
  802567:	09 f3                	or     %esi,%ebx
  802569:	89 c6                	mov    %eax,%esi
  80256b:	89 f2                	mov    %esi,%edx
  80256d:	89 d8                	mov    %ebx,%eax
  80256f:	f7 74 24 08          	divl   0x8(%esp)
  802573:	89 d6                	mov    %edx,%esi
  802575:	89 c3                	mov    %eax,%ebx
  802577:	f7 64 24 0c          	mull   0xc(%esp)
  80257b:	39 d6                	cmp    %edx,%esi
  80257d:	72 19                	jb     802598 <__udivdi3+0x108>
  80257f:	89 f9                	mov    %edi,%ecx
  802581:	d3 e5                	shl    %cl,%ebp
  802583:	39 c5                	cmp    %eax,%ebp
  802585:	73 04                	jae    80258b <__udivdi3+0xfb>
  802587:	39 d6                	cmp    %edx,%esi
  802589:	74 0d                	je     802598 <__udivdi3+0x108>
  80258b:	89 d8                	mov    %ebx,%eax
  80258d:	31 ff                	xor    %edi,%edi
  80258f:	e9 3c ff ff ff       	jmp    8024d0 <__udivdi3+0x40>
  802594:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802598:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80259b:	31 ff                	xor    %edi,%edi
  80259d:	e9 2e ff ff ff       	jmp    8024d0 <__udivdi3+0x40>
  8025a2:	66 90                	xchg   %ax,%ax
  8025a4:	66 90                	xchg   %ax,%ax
  8025a6:	66 90                	xchg   %ax,%ax
  8025a8:	66 90                	xchg   %ax,%ax
  8025aa:	66 90                	xchg   %ax,%ax
  8025ac:	66 90                	xchg   %ax,%ax
  8025ae:	66 90                	xchg   %ax,%ax

008025b0 <__umoddi3>:
  8025b0:	f3 0f 1e fb          	endbr32 
  8025b4:	55                   	push   %ebp
  8025b5:	57                   	push   %edi
  8025b6:	56                   	push   %esi
  8025b7:	53                   	push   %ebx
  8025b8:	83 ec 1c             	sub    $0x1c,%esp
  8025bb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8025bf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8025c3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8025c7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8025cb:	89 f0                	mov    %esi,%eax
  8025cd:	89 da                	mov    %ebx,%edx
  8025cf:	85 ff                	test   %edi,%edi
  8025d1:	75 15                	jne    8025e8 <__umoddi3+0x38>
  8025d3:	39 dd                	cmp    %ebx,%ebp
  8025d5:	76 39                	jbe    802610 <__umoddi3+0x60>
  8025d7:	f7 f5                	div    %ebp
  8025d9:	89 d0                	mov    %edx,%eax
  8025db:	31 d2                	xor    %edx,%edx
  8025dd:	83 c4 1c             	add    $0x1c,%esp
  8025e0:	5b                   	pop    %ebx
  8025e1:	5e                   	pop    %esi
  8025e2:	5f                   	pop    %edi
  8025e3:	5d                   	pop    %ebp
  8025e4:	c3                   	ret    
  8025e5:	8d 76 00             	lea    0x0(%esi),%esi
  8025e8:	39 df                	cmp    %ebx,%edi
  8025ea:	77 f1                	ja     8025dd <__umoddi3+0x2d>
  8025ec:	0f bd cf             	bsr    %edi,%ecx
  8025ef:	83 f1 1f             	xor    $0x1f,%ecx
  8025f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8025f6:	75 40                	jne    802638 <__umoddi3+0x88>
  8025f8:	39 df                	cmp    %ebx,%edi
  8025fa:	72 04                	jb     802600 <__umoddi3+0x50>
  8025fc:	39 f5                	cmp    %esi,%ebp
  8025fe:	77 dd                	ja     8025dd <__umoddi3+0x2d>
  802600:	89 da                	mov    %ebx,%edx
  802602:	89 f0                	mov    %esi,%eax
  802604:	29 e8                	sub    %ebp,%eax
  802606:	19 fa                	sbb    %edi,%edx
  802608:	eb d3                	jmp    8025dd <__umoddi3+0x2d>
  80260a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802610:	89 e9                	mov    %ebp,%ecx
  802612:	85 ed                	test   %ebp,%ebp
  802614:	75 0b                	jne    802621 <__umoddi3+0x71>
  802616:	b8 01 00 00 00       	mov    $0x1,%eax
  80261b:	31 d2                	xor    %edx,%edx
  80261d:	f7 f5                	div    %ebp
  80261f:	89 c1                	mov    %eax,%ecx
  802621:	89 d8                	mov    %ebx,%eax
  802623:	31 d2                	xor    %edx,%edx
  802625:	f7 f1                	div    %ecx
  802627:	89 f0                	mov    %esi,%eax
  802629:	f7 f1                	div    %ecx
  80262b:	89 d0                	mov    %edx,%eax
  80262d:	31 d2                	xor    %edx,%edx
  80262f:	eb ac                	jmp    8025dd <__umoddi3+0x2d>
  802631:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802638:	8b 44 24 04          	mov    0x4(%esp),%eax
  80263c:	ba 20 00 00 00       	mov    $0x20,%edx
  802641:	29 c2                	sub    %eax,%edx
  802643:	89 c1                	mov    %eax,%ecx
  802645:	89 e8                	mov    %ebp,%eax
  802647:	d3 e7                	shl    %cl,%edi
  802649:	89 d1                	mov    %edx,%ecx
  80264b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80264f:	d3 e8                	shr    %cl,%eax
  802651:	89 c1                	mov    %eax,%ecx
  802653:	8b 44 24 04          	mov    0x4(%esp),%eax
  802657:	09 f9                	or     %edi,%ecx
  802659:	89 df                	mov    %ebx,%edi
  80265b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80265f:	89 c1                	mov    %eax,%ecx
  802661:	d3 e5                	shl    %cl,%ebp
  802663:	89 d1                	mov    %edx,%ecx
  802665:	d3 ef                	shr    %cl,%edi
  802667:	89 c1                	mov    %eax,%ecx
  802669:	89 f0                	mov    %esi,%eax
  80266b:	d3 e3                	shl    %cl,%ebx
  80266d:	89 d1                	mov    %edx,%ecx
  80266f:	89 fa                	mov    %edi,%edx
  802671:	d3 e8                	shr    %cl,%eax
  802673:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802678:	09 d8                	or     %ebx,%eax
  80267a:	f7 74 24 08          	divl   0x8(%esp)
  80267e:	89 d3                	mov    %edx,%ebx
  802680:	d3 e6                	shl    %cl,%esi
  802682:	f7 e5                	mul    %ebp
  802684:	89 c7                	mov    %eax,%edi
  802686:	89 d1                	mov    %edx,%ecx
  802688:	39 d3                	cmp    %edx,%ebx
  80268a:	72 06                	jb     802692 <__umoddi3+0xe2>
  80268c:	75 0e                	jne    80269c <__umoddi3+0xec>
  80268e:	39 c6                	cmp    %eax,%esi
  802690:	73 0a                	jae    80269c <__umoddi3+0xec>
  802692:	29 e8                	sub    %ebp,%eax
  802694:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802698:	89 d1                	mov    %edx,%ecx
  80269a:	89 c7                	mov    %eax,%edi
  80269c:	89 f5                	mov    %esi,%ebp
  80269e:	8b 74 24 04          	mov    0x4(%esp),%esi
  8026a2:	29 fd                	sub    %edi,%ebp
  8026a4:	19 cb                	sbb    %ecx,%ebx
  8026a6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8026ab:	89 d8                	mov    %ebx,%eax
  8026ad:	d3 e0                	shl    %cl,%eax
  8026af:	89 f1                	mov    %esi,%ecx
  8026b1:	d3 ed                	shr    %cl,%ebp
  8026b3:	d3 eb                	shr    %cl,%ebx
  8026b5:	09 e8                	or     %ebp,%eax
  8026b7:	89 da                	mov    %ebx,%edx
  8026b9:	83 c4 1c             	add    $0x1c,%esp
  8026bc:	5b                   	pop    %ebx
  8026bd:	5e                   	pop    %esi
  8026be:	5f                   	pop    %edi
  8026bf:	5d                   	pop    %ebp
  8026c0:	c3                   	ret    
