
obj/user/echotest.debug：     文件格式 elf32-i386


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
  80002c:	e8 9b 04 00 00       	call   8004cc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:

const char *msg = "Hello world!\n";

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 c0 26 80 00       	push   $0x8026c0
  80003f:	e8 7d 05 00 00       	call   8005c1 <cprintf>
	exit();
  800044:	e8 c9 04 00 00       	call   800512 <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <umain>:

void umain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 58             	sub    $0x58,%esp
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	cprintf("Connecting to:\n");
  800057:	68 c4 26 80 00       	push   $0x8026c4
  80005c:	e8 60 05 00 00       	call   8005c1 <cprintf>
	cprintf("\tip address %s = %x\n", IPADDR, inet_addr(IPADDR));
  800061:	c7 04 24 d4 26 80 00 	movl   $0x8026d4,(%esp)
  800068:	e8 2a 04 00 00       	call   800497 <inet_addr>
  80006d:	83 c4 0c             	add    $0xc,%esp
  800070:	50                   	push   %eax
  800071:	68 d4 26 80 00       	push   $0x8026d4
  800076:	68 de 26 80 00       	push   $0x8026de
  80007b:	e8 41 05 00 00       	call   8005c1 <cprintf>

	// Create the TCP socket
	if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  800080:	83 c4 0c             	add    $0xc,%esp
  800083:	6a 06                	push   $0x6
  800085:	6a 01                	push   $0x1
  800087:	6a 02                	push   $0x2
  800089:	e8 2c 1b 00 00       	call   801bba <socket>
  80008e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	85 c0                	test   %eax,%eax
  800096:	0f 88 b4 00 00 00    	js     800150 <umain+0x102>
		die("Failed to create socket");

	cprintf("opened socket\n");
  80009c:	83 ec 0c             	sub    $0xc,%esp
  80009f:	68 0b 27 80 00       	push   $0x80270b
  8000a4:	e8 18 05 00 00       	call   8005c1 <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  8000a9:	83 c4 0c             	add    $0xc,%esp
  8000ac:	6a 10                	push   $0x10
  8000ae:	6a 00                	push   $0x0
  8000b0:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8000b3:	53                   	push   %ebx
  8000b4:	e8 32 0c 00 00       	call   800ceb <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  8000b9:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = inet_addr(IPADDR);   // IP address
  8000bd:	c7 04 24 d4 26 80 00 	movl   $0x8026d4,(%esp)
  8000c4:	e8 ce 03 00 00       	call   800497 <inet_addr>
  8000c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  8000cc:	c7 04 24 10 27 00 00 	movl   $0x2710,(%esp)
  8000d3:	e8 9f 01 00 00       	call   800277 <htons>
  8000d8:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to connect to server\n");
  8000dc:	c7 04 24 1a 27 80 00 	movl   $0x80271a,(%esp)
  8000e3:	e8 d9 04 00 00       	call   8005c1 <cprintf>

	// Establish connection
	if (connect(sock, (struct sockaddr *) &echoserver, sizeof(echoserver)) < 0)
  8000e8:	83 c4 0c             	add    $0xc,%esp
  8000eb:	6a 10                	push   $0x10
  8000ed:	53                   	push   %ebx
  8000ee:	ff 75 b4             	push   -0x4c(%ebp)
  8000f1:	e8 7b 1a 00 00       	call   801b71 <connect>
  8000f6:	83 c4 10             	add    $0x10,%esp
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	78 62                	js     80015f <umain+0x111>
		die("Failed to connect with server");

	cprintf("connected to server\n");
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	68 55 27 80 00       	push   $0x802755
  800105:	e8 b7 04 00 00       	call   8005c1 <cprintf>

	// Send the word to the server
	echolen = strlen(msg);
  80010a:	83 c4 04             	add    $0x4,%esp
  80010d:	ff 35 00 30 80 00    	push   0x803000
  800113:	e8 48 0a 00 00       	call   800b60 <strlen>
  800118:	89 c7                	mov    %eax,%edi
  80011a:	89 45 b0             	mov    %eax,-0x50(%ebp)
	if (write(sock, msg, echolen) != echolen)
  80011d:	83 c4 0c             	add    $0xc,%esp
  800120:	50                   	push   %eax
  800121:	ff 35 00 30 80 00    	push   0x803000
  800127:	ff 75 b4             	push   -0x4c(%ebp)
  80012a:	e8 68 14 00 00       	call   801597 <write>
  80012f:	83 c4 10             	add    $0x10,%esp
  800132:	39 c7                	cmp    %eax,%edi
  800134:	75 35                	jne    80016b <umain+0x11d>
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 6a 27 80 00       	push   $0x80276a
  80013e:	e8 7e 04 00 00       	call   8005c1 <cprintf>
	while (received < echolen) {
  800143:	83 c4 10             	add    $0x10,%esp
	int received = 0;
  800146:	be 00 00 00 00       	mov    $0x0,%esi
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  80014b:	8d 7d b8             	lea    -0x48(%ebp),%edi
	while (received < echolen) {
  80014e:	eb 3a                	jmp    80018a <umain+0x13c>
		die("Failed to create socket");
  800150:	b8 f3 26 80 00       	mov    $0x8026f3,%eax
  800155:	e8 d9 fe ff ff       	call   800033 <die>
  80015a:	e9 3d ff ff ff       	jmp    80009c <umain+0x4e>
		die("Failed to connect with server");
  80015f:	b8 37 27 80 00       	mov    $0x802737,%eax
  800164:	e8 ca fe ff ff       	call   800033 <die>
  800169:	eb 92                	jmp    8000fd <umain+0xaf>
		die("Mismatch in number of sent bytes");
  80016b:	b8 84 27 80 00       	mov    $0x802784,%eax
  800170:	e8 be fe ff ff       	call   800033 <die>
  800175:	eb bf                	jmp    800136 <umain+0xe8>
			die("Failed to receive bytes from server");
		}
		received += bytes;
  800177:	01 de                	add    %ebx,%esi
		buffer[bytes] = '\0';        // Assure null terminated string
  800179:	c6 44 1d b8 00       	movb   $0x0,-0x48(%ebp,%ebx,1)
		cprintf(buffer);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	57                   	push   %edi
  800182:	e8 3a 04 00 00       	call   8005c1 <cprintf>
  800187:	83 c4 10             	add    $0x10,%esp
	while (received < echolen) {
  80018a:	3b 75 b0             	cmp    -0x50(%ebp),%esi
  80018d:	73 23                	jae    8001b2 <umain+0x164>
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  80018f:	83 ec 04             	sub    $0x4,%esp
  800192:	6a 1f                	push   $0x1f
  800194:	57                   	push   %edi
  800195:	ff 75 b4             	push   -0x4c(%ebp)
  800198:	e8 2c 13 00 00       	call   8014c9 <read>
  80019d:	89 c3                	mov    %eax,%ebx
  80019f:	83 c4 10             	add    $0x10,%esp
  8001a2:	85 c0                	test   %eax,%eax
  8001a4:	7f d1                	jg     800177 <umain+0x129>
			die("Failed to receive bytes from server");
  8001a6:	b8 a8 27 80 00       	mov    $0x8027a8,%eax
  8001ab:	e8 83 fe ff ff       	call   800033 <die>
  8001b0:	eb c5                	jmp    800177 <umain+0x129>
	}
	cprintf("\n");
  8001b2:	83 ec 0c             	sub    $0xc,%esp
  8001b5:	68 74 27 80 00       	push   $0x802774
  8001ba:	e8 02 04 00 00       	call   8005c1 <cprintf>

	close(sock);
  8001bf:	83 c4 04             	add    $0x4,%esp
  8001c2:	ff 75 b4             	push   -0x4c(%ebp)
  8001c5:	e8 c3 11 00 00       	call   80138d <close>
}
  8001ca:	83 c4 10             	add    $0x10,%esp
  8001cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d0:	5b                   	pop    %ebx
  8001d1:	5e                   	pop    %esi
  8001d2:	5f                   	pop    %edi
  8001d3:	5d                   	pop    %ebp
  8001d4:	c3                   	ret    

008001d5 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	57                   	push   %edi
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	83 ec 1c             	sub    $0x1c,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8001de:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8001e4:	c6 45 db 00          	movb   $0x0,-0x25(%ebp)
  ap = (u8_t *)&s_addr;
  8001e8:	8d 75 f0             	lea    -0x10(%ebp),%esi
  rp = str;
  8001eb:	c7 45 dc 00 40 80 00 	movl   $0x804000,-0x24(%ebp)
  8001f2:	eb 32                	jmp    800226 <inet_ntoa+0x51>
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
  8001f4:	0f b6 c8             	movzbl %al,%ecx
  8001f7:	0f b6 4c 0d ed       	movzbl -0x13(%ebp,%ecx,1),%ecx
  8001fc:	88 0a                	mov    %cl,(%edx)
  8001fe:	83 c2 01             	add    $0x1,%edx
    while(i--)
  800201:	83 e8 01             	sub    $0x1,%eax
  800204:	3c ff                	cmp    $0xff,%al
  800206:	75 ec                	jne    8001f4 <inet_ntoa+0x1f>
  800208:	0f b6 db             	movzbl %bl,%ebx
  80020b:	03 5d dc             	add    -0x24(%ebp),%ebx
    *rp++ = '.';
  80020e:	8d 43 01             	lea    0x1(%ebx),%eax
  800211:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800214:	c6 03 2e             	movb   $0x2e,(%ebx)
  800217:	83 c6 01             	add    $0x1,%esi
  for(n = 0; n < 4; n++) {
  80021a:	80 45 db 01          	addb   $0x1,-0x25(%ebp)
  80021e:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  800222:	3c 04                	cmp    $0x4,%al
  800224:	74 41                	je     800267 <inet_ntoa+0x92>
  rp = str;
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
      rem = *ap % (u8_t)10;
  80022b:	0f b6 16             	movzbl (%esi),%edx
      *ap /= (u8_t)10;
  80022e:	b8 cd ff ff ff       	mov    $0xffffffcd,%eax
  800233:	f6 e2                	mul    %dl
  800235:	66 c1 e8 0b          	shr    $0xb,%ax
  800239:	88 06                	mov    %al,(%esi)
  80023b:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  80023d:	83 c3 01             	add    $0x1,%ebx
  800240:	0f b6 f9             	movzbl %cl,%edi
  800243:	89 7d e0             	mov    %edi,-0x20(%ebp)
      rem = *ap % (u8_t)10;
  800246:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800249:	01 c0                	add    %eax,%eax
  80024b:	89 d1                	mov    %edx,%ecx
  80024d:	29 c1                	sub    %eax,%ecx
  80024f:	89 cf                	mov    %ecx,%edi
      inv[i++] = '0' + rem;
  800251:	8d 47 30             	lea    0x30(%edi),%eax
  800254:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800257:	88 44 3d ed          	mov    %al,-0x13(%ebp,%edi,1)
    } while(*ap);
  80025b:	80 fa 09             	cmp    $0x9,%dl
  80025e:	77 cb                	ja     80022b <inet_ntoa+0x56>
  800260:	8b 55 dc             	mov    -0x24(%ebp),%edx
      inv[i++] = '0' + rem;
  800263:	89 d8                	mov    %ebx,%eax
  800265:	eb 9a                	jmp    800201 <inet_ntoa+0x2c>
    ap++;
  }
  *--rp = 0;
  800267:	c6 03 00             	movb   $0x0,(%ebx)
  return str;
}
  80026a:	b8 00 40 80 00       	mov    $0x804000,%eax
  80026f:	83 c4 1c             	add    $0x1c,%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  80027a:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80027e:	66 c1 c0 08          	rol    $0x8,%ax
}
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    

00800284 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800287:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80028b:	66 c1 c0 08          	rol    $0x8,%ax
  return htons(n);
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  800297:	89 d0                	mov    %edx,%eax
  800299:	c1 e0 18             	shl    $0x18,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  80029c:	89 d1                	mov    %edx,%ecx
  80029e:	c1 e9 18             	shr    $0x18,%ecx
    ((n & 0xff0000UL) >> 8) |
  8002a1:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  8002a3:	89 d1                	mov    %edx,%ecx
  8002a5:	c1 e1 08             	shl    $0x8,%ecx
  8002a8:	81 e1 00 00 ff 00    	and    $0xff0000,%ecx
    ((n & 0xff0000UL) >> 8) |
  8002ae:	09 c8                	or     %ecx,%eax
  8002b0:	c1 ea 08             	shr    $0x8,%edx
  8002b3:	81 e2 00 ff 00 00    	and    $0xff00,%edx
  8002b9:	09 d0                	or     %edx,%eax
}
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <inet_aton>:
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	57                   	push   %edi
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
  8002c3:	83 ec 2c             	sub    $0x2c,%esp
  8002c6:	8b 55 08             	mov    0x8(%ebp),%edx
  c = *cp;
  8002c9:	0f be 02             	movsbl (%edx),%eax
  u32_t *pp = parts;
  8002cc:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8002cf:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8002d2:	e9 a6 00 00 00       	jmp    80037d <inet_aton+0xc0>
      c = *++cp;
  8002d7:	0f b6 42 01          	movzbl 0x1(%edx),%eax
      if (c == 'x' || c == 'X') {
  8002db:	89 c1                	mov    %eax,%ecx
  8002dd:	83 e1 df             	and    $0xffffffdf,%ecx
  8002e0:	80 f9 58             	cmp    $0x58,%cl
  8002e3:	74 10                	je     8002f5 <inet_aton+0x38>
      c = *++cp;
  8002e5:	83 c2 01             	add    $0x1,%edx
  8002e8:	0f be c0             	movsbl %al,%eax
        base = 8;
  8002eb:	be 08 00 00 00       	mov    $0x8,%esi
  8002f0:	e9 a2 00 00 00       	jmp    800397 <inet_aton+0xda>
        c = *++cp;
  8002f5:	0f be 42 02          	movsbl 0x2(%edx),%eax
  8002f9:	8d 52 02             	lea    0x2(%edx),%edx
        base = 16;
  8002fc:	be 10 00 00 00       	mov    $0x10,%esi
  800301:	e9 91 00 00 00       	jmp    800397 <inet_aton+0xda>
        val = (val * base) + (int)(c - '0');
  800306:	0f af fe             	imul   %esi,%edi
  800309:	8d 7c 38 d0          	lea    -0x30(%eax,%edi,1),%edi
        c = *++cp;
  80030d:	0f be 02             	movsbl (%edx),%eax
  800310:	83 c2 01             	add    $0x1,%edx
  800313:	8d 5a ff             	lea    -0x1(%edx),%ebx
      if (isdigit(c)) {
  800316:	88 45 d7             	mov    %al,-0x29(%ebp)
  800319:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80031c:	80 f9 09             	cmp    $0x9,%cl
  80031f:	76 e5                	jbe    800306 <inet_aton+0x49>
      } else if (base == 16 && isxdigit(c)) {
  800321:	83 fe 10             	cmp    $0x10,%esi
  800324:	75 34                	jne    80035a <inet_aton+0x9d>
  800326:	0f b6 4d d7          	movzbl -0x29(%ebp),%ecx
  80032a:	83 e9 61             	sub    $0x61,%ecx
  80032d:	88 4d d6             	mov    %cl,-0x2a(%ebp)
  800330:	0f b6 4d d7          	movzbl -0x29(%ebp),%ecx
  800334:	83 e1 df             	and    $0xffffffdf,%ecx
  800337:	83 e9 41             	sub    $0x41,%ecx
  80033a:	80 f9 05             	cmp    $0x5,%cl
  80033d:	77 1b                	ja     80035a <inet_aton+0x9d>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  80033f:	c1 e7 04             	shl    $0x4,%edi
  800342:	83 c0 0a             	add    $0xa,%eax
  800345:	80 7d d6 1a          	cmpb   $0x1a,-0x2a(%ebp)
  800349:	19 c9                	sbb    %ecx,%ecx
  80034b:	83 e1 20             	and    $0x20,%ecx
  80034e:	83 c1 41             	add    $0x41,%ecx
  800351:	29 c8                	sub    %ecx,%eax
  800353:	09 c7                	or     %eax,%edi
        c = *++cp;
  800355:	0f be 02             	movsbl (%edx),%eax
  800358:	eb b6                	jmp    800310 <inet_aton+0x53>
    if (c == '.') {
  80035a:	83 f8 2e             	cmp    $0x2e,%eax
  80035d:	75 45                	jne    8003a4 <inet_aton+0xe7>
      if (pp >= parts + 3)
  80035f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800362:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800365:	39 c6                	cmp    %eax,%esi
  800367:	0f 84 1b 01 00 00    	je     800488 <inet_aton+0x1cb>
      *pp++ = val;
  80036d:	83 c6 04             	add    $0x4,%esi
  800370:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800373:	89 7e fc             	mov    %edi,-0x4(%esi)
      c = *++cp;
  800376:	8d 53 01             	lea    0x1(%ebx),%edx
  800379:	0f be 43 01          	movsbl 0x1(%ebx),%eax
    if (!isdigit(c))
  80037d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800380:	80 f9 09             	cmp    $0x9,%cl
  800383:	0f 87 f8 00 00 00    	ja     800481 <inet_aton+0x1c4>
    base = 10;
  800389:	be 0a 00 00 00       	mov    $0xa,%esi
    if (c == '0') {
  80038e:	83 f8 30             	cmp    $0x30,%eax
  800391:	0f 84 40 ff ff ff    	je     8002d7 <inet_aton+0x1a>
  800397:	83 c2 01             	add    $0x1,%edx
        base = 8;
  80039a:	bf 00 00 00 00       	mov    $0x0,%edi
  80039f:	e9 6f ff ff ff       	jmp    800313 <inet_aton+0x56>
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003a4:	0f b6 75 d7          	movzbl -0x29(%ebp),%esi
  8003a8:	85 c0                	test   %eax,%eax
  8003aa:	74 29                	je     8003d5 <inet_aton+0x118>
    return (0);
  8003ac:	ba 00 00 00 00       	mov    $0x0,%edx
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003b1:	89 f3                	mov    %esi,%ebx
  8003b3:	80 fb 1f             	cmp    $0x1f,%bl
  8003b6:	0f 86 d1 00 00 00    	jbe    80048d <inet_aton+0x1d0>
  8003bc:	84 c0                	test   %al,%al
  8003be:	0f 88 c9 00 00 00    	js     80048d <inet_aton+0x1d0>
  8003c4:	83 f8 20             	cmp    $0x20,%eax
  8003c7:	74 0c                	je     8003d5 <inet_aton+0x118>
  8003c9:	83 e8 09             	sub    $0x9,%eax
  8003cc:	83 f8 04             	cmp    $0x4,%eax
  8003cf:	0f 87 b8 00 00 00    	ja     80048d <inet_aton+0x1d0>
  n = pp - parts + 1;
  8003d5:	8d 55 d8             	lea    -0x28(%ebp),%edx
  8003d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003db:	29 d0                	sub    %edx,%eax
  8003dd:	c1 f8 02             	sar    $0x2,%eax
  8003e0:	8d 50 01             	lea    0x1(%eax),%edx
  switch (n) {
  8003e3:	83 f8 02             	cmp    $0x2,%eax
  8003e6:	74 7a                	je     800462 <inet_aton+0x1a5>
  8003e8:	83 fa 03             	cmp    $0x3,%edx
  8003eb:	7f 49                	jg     800436 <inet_aton+0x179>
  8003ed:	85 d2                	test   %edx,%edx
  8003ef:	0f 84 98 00 00 00    	je     80048d <inet_aton+0x1d0>
  8003f5:	83 fa 02             	cmp    $0x2,%edx
  8003f8:	75 19                	jne    800413 <inet_aton+0x156>
      return (0);
  8003fa:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xffffffUL)
  8003ff:	81 ff ff ff ff 00    	cmp    $0xffffff,%edi
  800405:	0f 87 82 00 00 00    	ja     80048d <inet_aton+0x1d0>
    val |= parts[0] << 24;
  80040b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80040e:	c1 e0 18             	shl    $0x18,%eax
  800411:	09 c7                	or     %eax,%edi
  return (1);
  800413:	ba 01 00 00 00       	mov    $0x1,%edx
  if (addr)
  800418:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80041c:	74 6f                	je     80048d <inet_aton+0x1d0>
    addr->s_addr = htonl(val);
  80041e:	83 ec 0c             	sub    $0xc,%esp
  800421:	57                   	push   %edi
  800422:	e8 6a fe ff ff       	call   800291 <htonl>
  800427:	83 c4 10             	add    $0x10,%esp
  80042a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80042d:	89 03                	mov    %eax,(%ebx)
  return (1);
  80042f:	ba 01 00 00 00       	mov    $0x1,%edx
  800434:	eb 57                	jmp    80048d <inet_aton+0x1d0>
  switch (n) {
  800436:	83 fa 04             	cmp    $0x4,%edx
  800439:	75 d8                	jne    800413 <inet_aton+0x156>
      return (0);
  80043b:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xff)
  800440:	81 ff ff 00 00 00    	cmp    $0xff,%edi
  800446:	77 45                	ja     80048d <inet_aton+0x1d0>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  800448:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80044b:	c1 e0 18             	shl    $0x18,%eax
  80044e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800451:	c1 e2 10             	shl    $0x10,%edx
  800454:	09 d0                	or     %edx,%eax
  800456:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800459:	c1 e2 08             	shl    $0x8,%edx
  80045c:	09 d0                	or     %edx,%eax
  80045e:	09 c7                	or     %eax,%edi
    break;
  800460:	eb b1                	jmp    800413 <inet_aton+0x156>
      return (0);
  800462:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xffff)
  800467:	81 ff ff ff 00 00    	cmp    $0xffff,%edi
  80046d:	77 1e                	ja     80048d <inet_aton+0x1d0>
    val |= (parts[0] << 24) | (parts[1] << 16);
  80046f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800472:	c1 e0 18             	shl    $0x18,%eax
  800475:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800478:	c1 e2 10             	shl    $0x10,%edx
  80047b:	09 d0                	or     %edx,%eax
  80047d:	09 c7                	or     %eax,%edi
    break;
  80047f:	eb 92                	jmp    800413 <inet_aton+0x156>
      return (0);
  800481:	ba 00 00 00 00       	mov    $0x0,%edx
  800486:	eb 05                	jmp    80048d <inet_aton+0x1d0>
        return (0);
  800488:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80048d:	89 d0                	mov    %edx,%eax
  80048f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800492:	5b                   	pop    %ebx
  800493:	5e                   	pop    %esi
  800494:	5f                   	pop    %edi
  800495:	5d                   	pop    %ebp
  800496:	c3                   	ret    

00800497 <inet_addr>:
{
  800497:	55                   	push   %ebp
  800498:	89 e5                	mov    %esp,%ebp
  80049a:	83 ec 20             	sub    $0x20,%esp
  if (inet_aton(cp, &val)) {
  80049d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004a0:	50                   	push   %eax
  8004a1:	ff 75 08             	push   0x8(%ebp)
  8004a4:	e8 14 fe ff ff       	call   8002bd <inet_aton>
  8004a9:	83 c4 10             	add    $0x10,%esp
    return (val.s_addr);
  8004ac:	85 c0                	test   %eax,%eax
  8004ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004b3:	0f 45 45 f4          	cmovne -0xc(%ebp),%eax
}
  8004b7:	c9                   	leave  
  8004b8:	c3                   	ret    

008004b9 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8004b9:	55                   	push   %ebp
  8004ba:	89 e5                	mov    %esp,%ebp
  8004bc:	83 ec 14             	sub    $0x14,%esp
  return htonl(n);
  8004bf:	ff 75 08             	push   0x8(%ebp)
  8004c2:	e8 ca fd ff ff       	call   800291 <htonl>
  8004c7:	83 c4 10             	add    $0x10,%esp
}
  8004ca:	c9                   	leave  
  8004cb:	c3                   	ret    

008004cc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8004cc:	55                   	push   %ebp
  8004cd:	89 e5                	mov    %esp,%ebp
  8004cf:	56                   	push   %esi
  8004d0:	53                   	push   %ebx
  8004d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8004d7:	e8 7d 0a 00 00       	call   800f59 <sys_getenvid>
  8004dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8004e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004e9:	a3 10 40 80 00       	mov    %eax,0x804010

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004ee:	85 db                	test   %ebx,%ebx
  8004f0:	7e 07                	jle    8004f9 <libmain+0x2d>
		binaryname = argv[0];
  8004f2:	8b 06                	mov    (%esi),%eax
  8004f4:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8004f9:	83 ec 08             	sub    $0x8,%esp
  8004fc:	56                   	push   %esi
  8004fd:	53                   	push   %ebx
  8004fe:	e8 4b fb ff ff       	call   80004e <umain>

	// exit gracefully
	exit();
  800503:	e8 0a 00 00 00       	call   800512 <exit>
}
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80050e:	5b                   	pop    %ebx
  80050f:	5e                   	pop    %esi
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    

00800512 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800518:	e8 9d 0e 00 00       	call   8013ba <close_all>
	sys_env_destroy(0);
  80051d:	83 ec 0c             	sub    $0xc,%esp
  800520:	6a 00                	push   $0x0
  800522:	e8 f1 09 00 00       	call   800f18 <sys_env_destroy>
}
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	c9                   	leave  
  80052b:	c3                   	ret    

0080052c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052c:	55                   	push   %ebp
  80052d:	89 e5                	mov    %esp,%ebp
  80052f:	53                   	push   %ebx
  800530:	83 ec 04             	sub    $0x4,%esp
  800533:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800536:	8b 13                	mov    (%ebx),%edx
  800538:	8d 42 01             	lea    0x1(%edx),%eax
  80053b:	89 03                	mov    %eax,(%ebx)
  80053d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800540:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800544:	3d ff 00 00 00       	cmp    $0xff,%eax
  800549:	74 09                	je     800554 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80054b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80054f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800552:	c9                   	leave  
  800553:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800554:	83 ec 08             	sub    $0x8,%esp
  800557:	68 ff 00 00 00       	push   $0xff
  80055c:	8d 43 08             	lea    0x8(%ebx),%eax
  80055f:	50                   	push   %eax
  800560:	e8 76 09 00 00       	call   800edb <sys_cputs>
		b->idx = 0;
  800565:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb db                	jmp    80054b <putch+0x1f>

00800570 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800570:	55                   	push   %ebp
  800571:	89 e5                	mov    %esp,%ebp
  800573:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800579:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800580:	00 00 00 
	b.cnt = 0;
  800583:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80058a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80058d:	ff 75 0c             	push   0xc(%ebp)
  800590:	ff 75 08             	push   0x8(%ebp)
  800593:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800599:	50                   	push   %eax
  80059a:	68 2c 05 80 00       	push   $0x80052c
  80059f:	e8 14 01 00 00       	call   8006b8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a4:	83 c4 08             	add    $0x8,%esp
  8005a7:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8005ad:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005b3:	50                   	push   %eax
  8005b4:	e8 22 09 00 00       	call   800edb <sys_cputs>

	return b.cnt;
}
  8005b9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005bf:	c9                   	leave  
  8005c0:	c3                   	ret    

008005c1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005c1:	55                   	push   %ebp
  8005c2:	89 e5                	mov    %esp,%ebp
  8005c4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005ca:	50                   	push   %eax
  8005cb:	ff 75 08             	push   0x8(%ebp)
  8005ce:	e8 9d ff ff ff       	call   800570 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005d3:	c9                   	leave  
  8005d4:	c3                   	ret    

008005d5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d5:	55                   	push   %ebp
  8005d6:	89 e5                	mov    %esp,%ebp
  8005d8:	57                   	push   %edi
  8005d9:	56                   	push   %esi
  8005da:	53                   	push   %ebx
  8005db:	83 ec 1c             	sub    $0x1c,%esp
  8005de:	89 c7                	mov    %eax,%edi
  8005e0:	89 d6                	mov    %edx,%esi
  8005e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e8:	89 d1                	mov    %edx,%ecx
  8005ea:	89 c2                	mov    %eax,%edx
  8005ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ef:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005fb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800602:	39 c2                	cmp    %eax,%edx
  800604:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800607:	72 3e                	jb     800647 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800609:	83 ec 0c             	sub    $0xc,%esp
  80060c:	ff 75 18             	push   0x18(%ebp)
  80060f:	83 eb 01             	sub    $0x1,%ebx
  800612:	53                   	push   %ebx
  800613:	50                   	push   %eax
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	ff 75 e4             	push   -0x1c(%ebp)
  80061a:	ff 75 e0             	push   -0x20(%ebp)
  80061d:	ff 75 dc             	push   -0x24(%ebp)
  800620:	ff 75 d8             	push   -0x28(%ebp)
  800623:	e8 48 1e 00 00       	call   802470 <__udivdi3>
  800628:	83 c4 18             	add    $0x18,%esp
  80062b:	52                   	push   %edx
  80062c:	50                   	push   %eax
  80062d:	89 f2                	mov    %esi,%edx
  80062f:	89 f8                	mov    %edi,%eax
  800631:	e8 9f ff ff ff       	call   8005d5 <printnum>
  800636:	83 c4 20             	add    $0x20,%esp
  800639:	eb 13                	jmp    80064e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	56                   	push   %esi
  80063f:	ff 75 18             	push   0x18(%ebp)
  800642:	ff d7                	call   *%edi
  800644:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800647:	83 eb 01             	sub    $0x1,%ebx
  80064a:	85 db                	test   %ebx,%ebx
  80064c:	7f ed                	jg     80063b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	56                   	push   %esi
  800652:	83 ec 04             	sub    $0x4,%esp
  800655:	ff 75 e4             	push   -0x1c(%ebp)
  800658:	ff 75 e0             	push   -0x20(%ebp)
  80065b:	ff 75 dc             	push   -0x24(%ebp)
  80065e:	ff 75 d8             	push   -0x28(%ebp)
  800661:	e8 2a 1f 00 00       	call   802590 <__umoddi3>
  800666:	83 c4 14             	add    $0x14,%esp
  800669:	0f be 80 d6 27 80 00 	movsbl 0x8027d6(%eax),%eax
  800670:	50                   	push   %eax
  800671:	ff d7                	call   *%edi
}
  800673:	83 c4 10             	add    $0x10,%esp
  800676:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800679:	5b                   	pop    %ebx
  80067a:	5e                   	pop    %esi
  80067b:	5f                   	pop    %edi
  80067c:	5d                   	pop    %ebp
  80067d:	c3                   	ret    

0080067e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80067e:	55                   	push   %ebp
  80067f:	89 e5                	mov    %esp,%ebp
  800681:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800684:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	3b 50 04             	cmp    0x4(%eax),%edx
  80068d:	73 0a                	jae    800699 <sprintputch+0x1b>
		*b->buf++ = ch;
  80068f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800692:	89 08                	mov    %ecx,(%eax)
  800694:	8b 45 08             	mov    0x8(%ebp),%eax
  800697:	88 02                	mov    %al,(%edx)
}
  800699:	5d                   	pop    %ebp
  80069a:	c3                   	ret    

0080069b <printfmt>:
{
  80069b:	55                   	push   %ebp
  80069c:	89 e5                	mov    %esp,%ebp
  80069e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8006a1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006a4:	50                   	push   %eax
  8006a5:	ff 75 10             	push   0x10(%ebp)
  8006a8:	ff 75 0c             	push   0xc(%ebp)
  8006ab:	ff 75 08             	push   0x8(%ebp)
  8006ae:	e8 05 00 00 00       	call   8006b8 <vprintfmt>
}
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	c9                   	leave  
  8006b7:	c3                   	ret    

008006b8 <vprintfmt>:
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	57                   	push   %edi
  8006bc:	56                   	push   %esi
  8006bd:	53                   	push   %ebx
  8006be:	83 ec 3c             	sub    $0x3c,%esp
  8006c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006ca:	eb 0a                	jmp    8006d6 <vprintfmt+0x1e>
			putch(ch, putdat);
  8006cc:	83 ec 08             	sub    $0x8,%esp
  8006cf:	53                   	push   %ebx
  8006d0:	50                   	push   %eax
  8006d1:	ff d6                	call   *%esi
  8006d3:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d6:	83 c7 01             	add    $0x1,%edi
  8006d9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006dd:	83 f8 25             	cmp    $0x25,%eax
  8006e0:	74 0c                	je     8006ee <vprintfmt+0x36>
			if (ch == '\0')
  8006e2:	85 c0                	test   %eax,%eax
  8006e4:	75 e6                	jne    8006cc <vprintfmt+0x14>
}
  8006e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e9:	5b                   	pop    %ebx
  8006ea:	5e                   	pop    %esi
  8006eb:	5f                   	pop    %edi
  8006ec:	5d                   	pop    %ebp
  8006ed:	c3                   	ret    
		padc = ' ';
  8006ee:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8006f2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8006f9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800700:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800707:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80070c:	8d 47 01             	lea    0x1(%edi),%eax
  80070f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800712:	0f b6 17             	movzbl (%edi),%edx
  800715:	8d 42 dd             	lea    -0x23(%edx),%eax
  800718:	3c 55                	cmp    $0x55,%al
  80071a:	0f 87 bb 03 00 00    	ja     800adb <vprintfmt+0x423>
  800720:	0f b6 c0             	movzbl %al,%eax
  800723:	ff 24 85 20 29 80 00 	jmp    *0x802920(,%eax,4)
  80072a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80072d:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800731:	eb d9                	jmp    80070c <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800733:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800736:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80073a:	eb d0                	jmp    80070c <vprintfmt+0x54>
  80073c:	0f b6 d2             	movzbl %dl,%edx
  80073f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800742:	b8 00 00 00 00       	mov    $0x0,%eax
  800747:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80074a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80074d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800751:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800754:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800757:	83 f9 09             	cmp    $0x9,%ecx
  80075a:	77 55                	ja     8007b1 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80075c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80075f:	eb e9                	jmp    80074a <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800761:	8b 45 14             	mov    0x14(%ebp),%eax
  800764:	8b 00                	mov    (%eax),%eax
  800766:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800769:	8b 45 14             	mov    0x14(%ebp),%eax
  80076c:	8d 40 04             	lea    0x4(%eax),%eax
  80076f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800772:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800775:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800779:	79 91                	jns    80070c <vprintfmt+0x54>
				width = precision, precision = -1;
  80077b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80077e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800781:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800788:	eb 82                	jmp    80070c <vprintfmt+0x54>
  80078a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80078d:	85 d2                	test   %edx,%edx
  80078f:	b8 00 00 00 00       	mov    $0x0,%eax
  800794:	0f 49 c2             	cmovns %edx,%eax
  800797:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80079a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80079d:	e9 6a ff ff ff       	jmp    80070c <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8007a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8007a5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8007ac:	e9 5b ff ff ff       	jmp    80070c <vprintfmt+0x54>
  8007b1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8007b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b7:	eb bc                	jmp    800775 <vprintfmt+0xbd>
			lflag++;
  8007b9:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8007bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8007bf:	e9 48 ff ff ff       	jmp    80070c <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	8d 78 04             	lea    0x4(%eax),%edi
  8007ca:	83 ec 08             	sub    $0x8,%esp
  8007cd:	53                   	push   %ebx
  8007ce:	ff 30                	push   (%eax)
  8007d0:	ff d6                	call   *%esi
			break;
  8007d2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8007d5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8007d8:	e9 9d 02 00 00       	jmp    800a7a <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 78 04             	lea    0x4(%eax),%edi
  8007e3:	8b 10                	mov    (%eax),%edx
  8007e5:	89 d0                	mov    %edx,%eax
  8007e7:	f7 d8                	neg    %eax
  8007e9:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007ec:	83 f8 0f             	cmp    $0xf,%eax
  8007ef:	7f 23                	jg     800814 <vprintfmt+0x15c>
  8007f1:	8b 14 85 80 2a 80 00 	mov    0x802a80(,%eax,4),%edx
  8007f8:	85 d2                	test   %edx,%edx
  8007fa:	74 18                	je     800814 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8007fc:	52                   	push   %edx
  8007fd:	68 b5 2b 80 00       	push   $0x802bb5
  800802:	53                   	push   %ebx
  800803:	56                   	push   %esi
  800804:	e8 92 fe ff ff       	call   80069b <printfmt>
  800809:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80080c:	89 7d 14             	mov    %edi,0x14(%ebp)
  80080f:	e9 66 02 00 00       	jmp    800a7a <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800814:	50                   	push   %eax
  800815:	68 ee 27 80 00       	push   $0x8027ee
  80081a:	53                   	push   %ebx
  80081b:	56                   	push   %esi
  80081c:	e8 7a fe ff ff       	call   80069b <printfmt>
  800821:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800824:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800827:	e9 4e 02 00 00       	jmp    800a7a <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80082c:	8b 45 14             	mov    0x14(%ebp),%eax
  80082f:	83 c0 04             	add    $0x4,%eax
  800832:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800835:	8b 45 14             	mov    0x14(%ebp),%eax
  800838:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80083a:	85 d2                	test   %edx,%edx
  80083c:	b8 e7 27 80 00       	mov    $0x8027e7,%eax
  800841:	0f 45 c2             	cmovne %edx,%eax
  800844:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800847:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80084b:	7e 06                	jle    800853 <vprintfmt+0x19b>
  80084d:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800851:	75 0d                	jne    800860 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800853:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800856:	89 c7                	mov    %eax,%edi
  800858:	03 45 e0             	add    -0x20(%ebp),%eax
  80085b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80085e:	eb 55                	jmp    8008b5 <vprintfmt+0x1fd>
  800860:	83 ec 08             	sub    $0x8,%esp
  800863:	ff 75 d8             	push   -0x28(%ebp)
  800866:	ff 75 cc             	push   -0x34(%ebp)
  800869:	e8 0a 03 00 00       	call   800b78 <strnlen>
  80086e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800871:	29 c1                	sub    %eax,%ecx
  800873:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800876:	83 c4 10             	add    $0x10,%esp
  800879:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80087b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80087f:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800882:	eb 0f                	jmp    800893 <vprintfmt+0x1db>
					putch(padc, putdat);
  800884:	83 ec 08             	sub    $0x8,%esp
  800887:	53                   	push   %ebx
  800888:	ff 75 e0             	push   -0x20(%ebp)
  80088b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80088d:	83 ef 01             	sub    $0x1,%edi
  800890:	83 c4 10             	add    $0x10,%esp
  800893:	85 ff                	test   %edi,%edi
  800895:	7f ed                	jg     800884 <vprintfmt+0x1cc>
  800897:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80089a:	85 d2                	test   %edx,%edx
  80089c:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a1:	0f 49 c2             	cmovns %edx,%eax
  8008a4:	29 c2                	sub    %eax,%edx
  8008a6:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8008a9:	eb a8                	jmp    800853 <vprintfmt+0x19b>
					putch(ch, putdat);
  8008ab:	83 ec 08             	sub    $0x8,%esp
  8008ae:	53                   	push   %ebx
  8008af:	52                   	push   %edx
  8008b0:	ff d6                	call   *%esi
  8008b2:	83 c4 10             	add    $0x10,%esp
  8008b5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008b8:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008ba:	83 c7 01             	add    $0x1,%edi
  8008bd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008c1:	0f be d0             	movsbl %al,%edx
  8008c4:	85 d2                	test   %edx,%edx
  8008c6:	74 4b                	je     800913 <vprintfmt+0x25b>
  8008c8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008cc:	78 06                	js     8008d4 <vprintfmt+0x21c>
  8008ce:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8008d2:	78 1e                	js     8008f2 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8008d4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8008d8:	74 d1                	je     8008ab <vprintfmt+0x1f3>
  8008da:	0f be c0             	movsbl %al,%eax
  8008dd:	83 e8 20             	sub    $0x20,%eax
  8008e0:	83 f8 5e             	cmp    $0x5e,%eax
  8008e3:	76 c6                	jbe    8008ab <vprintfmt+0x1f3>
					putch('?', putdat);
  8008e5:	83 ec 08             	sub    $0x8,%esp
  8008e8:	53                   	push   %ebx
  8008e9:	6a 3f                	push   $0x3f
  8008eb:	ff d6                	call   *%esi
  8008ed:	83 c4 10             	add    $0x10,%esp
  8008f0:	eb c3                	jmp    8008b5 <vprintfmt+0x1fd>
  8008f2:	89 cf                	mov    %ecx,%edi
  8008f4:	eb 0e                	jmp    800904 <vprintfmt+0x24c>
				putch(' ', putdat);
  8008f6:	83 ec 08             	sub    $0x8,%esp
  8008f9:	53                   	push   %ebx
  8008fa:	6a 20                	push   $0x20
  8008fc:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8008fe:	83 ef 01             	sub    $0x1,%edi
  800901:	83 c4 10             	add    $0x10,%esp
  800904:	85 ff                	test   %edi,%edi
  800906:	7f ee                	jg     8008f6 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800908:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80090b:	89 45 14             	mov    %eax,0x14(%ebp)
  80090e:	e9 67 01 00 00       	jmp    800a7a <vprintfmt+0x3c2>
  800913:	89 cf                	mov    %ecx,%edi
  800915:	eb ed                	jmp    800904 <vprintfmt+0x24c>
	if (lflag >= 2)
  800917:	83 f9 01             	cmp    $0x1,%ecx
  80091a:	7f 1b                	jg     800937 <vprintfmt+0x27f>
	else if (lflag)
  80091c:	85 c9                	test   %ecx,%ecx
  80091e:	74 63                	je     800983 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800920:	8b 45 14             	mov    0x14(%ebp),%eax
  800923:	8b 00                	mov    (%eax),%eax
  800925:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800928:	99                   	cltd   
  800929:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80092c:	8b 45 14             	mov    0x14(%ebp),%eax
  80092f:	8d 40 04             	lea    0x4(%eax),%eax
  800932:	89 45 14             	mov    %eax,0x14(%ebp)
  800935:	eb 17                	jmp    80094e <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800937:	8b 45 14             	mov    0x14(%ebp),%eax
  80093a:	8b 50 04             	mov    0x4(%eax),%edx
  80093d:	8b 00                	mov    (%eax),%eax
  80093f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800942:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800945:	8b 45 14             	mov    0x14(%ebp),%eax
  800948:	8d 40 08             	lea    0x8(%eax),%eax
  80094b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80094e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800951:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800954:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800959:	85 c9                	test   %ecx,%ecx
  80095b:	0f 89 ff 00 00 00    	jns    800a60 <vprintfmt+0x3a8>
				putch('-', putdat);
  800961:	83 ec 08             	sub    $0x8,%esp
  800964:	53                   	push   %ebx
  800965:	6a 2d                	push   $0x2d
  800967:	ff d6                	call   *%esi
				num = -(long long) num;
  800969:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80096c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80096f:	f7 da                	neg    %edx
  800971:	83 d1 00             	adc    $0x0,%ecx
  800974:	f7 d9                	neg    %ecx
  800976:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800979:	bf 0a 00 00 00       	mov    $0xa,%edi
  80097e:	e9 dd 00 00 00       	jmp    800a60 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800983:	8b 45 14             	mov    0x14(%ebp),%eax
  800986:	8b 00                	mov    (%eax),%eax
  800988:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80098b:	99                   	cltd   
  80098c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80098f:	8b 45 14             	mov    0x14(%ebp),%eax
  800992:	8d 40 04             	lea    0x4(%eax),%eax
  800995:	89 45 14             	mov    %eax,0x14(%ebp)
  800998:	eb b4                	jmp    80094e <vprintfmt+0x296>
	if (lflag >= 2)
  80099a:	83 f9 01             	cmp    $0x1,%ecx
  80099d:	7f 1e                	jg     8009bd <vprintfmt+0x305>
	else if (lflag)
  80099f:	85 c9                	test   %ecx,%ecx
  8009a1:	74 32                	je     8009d5 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8009a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a6:	8b 10                	mov    (%eax),%edx
  8009a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009ad:	8d 40 04             	lea    0x4(%eax),%eax
  8009b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009b3:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8009b8:	e9 a3 00 00 00       	jmp    800a60 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8009bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c0:	8b 10                	mov    (%eax),%edx
  8009c2:	8b 48 04             	mov    0x4(%eax),%ecx
  8009c5:	8d 40 08             	lea    0x8(%eax),%eax
  8009c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009cb:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8009d0:	e9 8b 00 00 00       	jmp    800a60 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8009d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d8:	8b 10                	mov    (%eax),%edx
  8009da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009df:	8d 40 04             	lea    0x4(%eax),%eax
  8009e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009e5:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8009ea:	eb 74                	jmp    800a60 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8009ec:	83 f9 01             	cmp    $0x1,%ecx
  8009ef:	7f 1b                	jg     800a0c <vprintfmt+0x354>
	else if (lflag)
  8009f1:	85 c9                	test   %ecx,%ecx
  8009f3:	74 2c                	je     800a21 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8009f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f8:	8b 10                	mov    (%eax),%edx
  8009fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009ff:	8d 40 04             	lea    0x4(%eax),%eax
  800a02:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a05:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800a0a:	eb 54                	jmp    800a60 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800a0c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0f:	8b 10                	mov    (%eax),%edx
  800a11:	8b 48 04             	mov    0x4(%eax),%ecx
  800a14:	8d 40 08             	lea    0x8(%eax),%eax
  800a17:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a1a:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800a1f:	eb 3f                	jmp    800a60 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800a21:	8b 45 14             	mov    0x14(%ebp),%eax
  800a24:	8b 10                	mov    (%eax),%edx
  800a26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a2b:	8d 40 04             	lea    0x4(%eax),%eax
  800a2e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a31:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800a36:	eb 28                	jmp    800a60 <vprintfmt+0x3a8>
			putch('0', putdat);
  800a38:	83 ec 08             	sub    $0x8,%esp
  800a3b:	53                   	push   %ebx
  800a3c:	6a 30                	push   $0x30
  800a3e:	ff d6                	call   *%esi
			putch('x', putdat);
  800a40:	83 c4 08             	add    $0x8,%esp
  800a43:	53                   	push   %ebx
  800a44:	6a 78                	push   $0x78
  800a46:	ff d6                	call   *%esi
			num = (unsigned long long)
  800a48:	8b 45 14             	mov    0x14(%ebp),%eax
  800a4b:	8b 10                	mov    (%eax),%edx
  800a4d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800a52:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800a55:	8d 40 04             	lea    0x4(%eax),%eax
  800a58:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a5b:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800a60:	83 ec 0c             	sub    $0xc,%esp
  800a63:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800a67:	50                   	push   %eax
  800a68:	ff 75 e0             	push   -0x20(%ebp)
  800a6b:	57                   	push   %edi
  800a6c:	51                   	push   %ecx
  800a6d:	52                   	push   %edx
  800a6e:	89 da                	mov    %ebx,%edx
  800a70:	89 f0                	mov    %esi,%eax
  800a72:	e8 5e fb ff ff       	call   8005d5 <printnum>
			break;
  800a77:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800a7a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a7d:	e9 54 fc ff ff       	jmp    8006d6 <vprintfmt+0x1e>
	if (lflag >= 2)
  800a82:	83 f9 01             	cmp    $0x1,%ecx
  800a85:	7f 1b                	jg     800aa2 <vprintfmt+0x3ea>
	else if (lflag)
  800a87:	85 c9                	test   %ecx,%ecx
  800a89:	74 2c                	je     800ab7 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800a8b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8e:	8b 10                	mov    (%eax),%edx
  800a90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a95:	8d 40 04             	lea    0x4(%eax),%eax
  800a98:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a9b:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800aa0:	eb be                	jmp    800a60 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800aa2:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa5:	8b 10                	mov    (%eax),%edx
  800aa7:	8b 48 04             	mov    0x4(%eax),%ecx
  800aaa:	8d 40 08             	lea    0x8(%eax),%eax
  800aad:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ab0:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800ab5:	eb a9                	jmp    800a60 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800ab7:	8b 45 14             	mov    0x14(%ebp),%eax
  800aba:	8b 10                	mov    (%eax),%edx
  800abc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac1:	8d 40 04             	lea    0x4(%eax),%eax
  800ac4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ac7:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800acc:	eb 92                	jmp    800a60 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800ace:	83 ec 08             	sub    $0x8,%esp
  800ad1:	53                   	push   %ebx
  800ad2:	6a 25                	push   $0x25
  800ad4:	ff d6                	call   *%esi
			break;
  800ad6:	83 c4 10             	add    $0x10,%esp
  800ad9:	eb 9f                	jmp    800a7a <vprintfmt+0x3c2>
			putch('%', putdat);
  800adb:	83 ec 08             	sub    $0x8,%esp
  800ade:	53                   	push   %ebx
  800adf:	6a 25                	push   $0x25
  800ae1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ae3:	83 c4 10             	add    $0x10,%esp
  800ae6:	89 f8                	mov    %edi,%eax
  800ae8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800aec:	74 05                	je     800af3 <vprintfmt+0x43b>
  800aee:	83 e8 01             	sub    $0x1,%eax
  800af1:	eb f5                	jmp    800ae8 <vprintfmt+0x430>
  800af3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800af6:	eb 82                	jmp    800a7a <vprintfmt+0x3c2>

00800af8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	83 ec 18             	sub    $0x18,%esp
  800afe:	8b 45 08             	mov    0x8(%ebp),%eax
  800b01:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b04:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b07:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b0b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b0e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b15:	85 c0                	test   %eax,%eax
  800b17:	74 26                	je     800b3f <vsnprintf+0x47>
  800b19:	85 d2                	test   %edx,%edx
  800b1b:	7e 22                	jle    800b3f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b1d:	ff 75 14             	push   0x14(%ebp)
  800b20:	ff 75 10             	push   0x10(%ebp)
  800b23:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b26:	50                   	push   %eax
  800b27:	68 7e 06 80 00       	push   $0x80067e
  800b2c:	e8 87 fb ff ff       	call   8006b8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b31:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b34:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b3a:	83 c4 10             	add    $0x10,%esp
}
  800b3d:	c9                   	leave  
  800b3e:	c3                   	ret    
		return -E_INVAL;
  800b3f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b44:	eb f7                	jmp    800b3d <vsnprintf+0x45>

00800b46 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b4c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b4f:	50                   	push   %eax
  800b50:	ff 75 10             	push   0x10(%ebp)
  800b53:	ff 75 0c             	push   0xc(%ebp)
  800b56:	ff 75 08             	push   0x8(%ebp)
  800b59:	e8 9a ff ff ff       	call   800af8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b5e:	c9                   	leave  
  800b5f:	c3                   	ret    

00800b60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b66:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6b:	eb 03                	jmp    800b70 <strlen+0x10>
		n++;
  800b6d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800b70:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b74:	75 f7                	jne    800b6d <strlen+0xd>
	return n;
}
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b81:	b8 00 00 00 00       	mov    $0x0,%eax
  800b86:	eb 03                	jmp    800b8b <strnlen+0x13>
		n++;
  800b88:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b8b:	39 d0                	cmp    %edx,%eax
  800b8d:	74 08                	je     800b97 <strnlen+0x1f>
  800b8f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b93:	75 f3                	jne    800b88 <strnlen+0x10>
  800b95:	89 c2                	mov    %eax,%edx
	return n;
}
  800b97:	89 d0                	mov    %edx,%eax
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	53                   	push   %ebx
  800b9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ba5:	b8 00 00 00 00       	mov    $0x0,%eax
  800baa:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800bae:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800bb1:	83 c0 01             	add    $0x1,%eax
  800bb4:	84 d2                	test   %dl,%dl
  800bb6:	75 f2                	jne    800baa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bb8:	89 c8                	mov    %ecx,%eax
  800bba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bbd:	c9                   	leave  
  800bbe:	c3                   	ret    

00800bbf <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 10             	sub    $0x10,%esp
  800bc6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bc9:	53                   	push   %ebx
  800bca:	e8 91 ff ff ff       	call   800b60 <strlen>
  800bcf:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800bd2:	ff 75 0c             	push   0xc(%ebp)
  800bd5:	01 d8                	add    %ebx,%eax
  800bd7:	50                   	push   %eax
  800bd8:	e8 be ff ff ff       	call   800b9b <strcpy>
	return dst;
}
  800bdd:	89 d8                	mov    %ebx,%eax
  800bdf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be2:	c9                   	leave  
  800be3:	c3                   	ret    

00800be4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	8b 75 08             	mov    0x8(%ebp),%esi
  800bec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bef:	89 f3                	mov    %esi,%ebx
  800bf1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bf4:	89 f0                	mov    %esi,%eax
  800bf6:	eb 0f                	jmp    800c07 <strncpy+0x23>
		*dst++ = *src;
  800bf8:	83 c0 01             	add    $0x1,%eax
  800bfb:	0f b6 0a             	movzbl (%edx),%ecx
  800bfe:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c01:	80 f9 01             	cmp    $0x1,%cl
  800c04:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800c07:	39 d8                	cmp    %ebx,%eax
  800c09:	75 ed                	jne    800bf8 <strncpy+0x14>
	}
	return ret;
}
  800c0b:	89 f0                	mov    %esi,%eax
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	8b 75 08             	mov    0x8(%ebp),%esi
  800c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1c:	8b 55 10             	mov    0x10(%ebp),%edx
  800c1f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c21:	85 d2                	test   %edx,%edx
  800c23:	74 21                	je     800c46 <strlcpy+0x35>
  800c25:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c29:	89 f2                	mov    %esi,%edx
  800c2b:	eb 09                	jmp    800c36 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c2d:	83 c1 01             	add    $0x1,%ecx
  800c30:	83 c2 01             	add    $0x1,%edx
  800c33:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800c36:	39 c2                	cmp    %eax,%edx
  800c38:	74 09                	je     800c43 <strlcpy+0x32>
  800c3a:	0f b6 19             	movzbl (%ecx),%ebx
  800c3d:	84 db                	test   %bl,%bl
  800c3f:	75 ec                	jne    800c2d <strlcpy+0x1c>
  800c41:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800c43:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c46:	29 f0                	sub    %esi,%eax
}
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c52:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c55:	eb 06                	jmp    800c5d <strcmp+0x11>
		p++, q++;
  800c57:	83 c1 01             	add    $0x1,%ecx
  800c5a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800c5d:	0f b6 01             	movzbl (%ecx),%eax
  800c60:	84 c0                	test   %al,%al
  800c62:	74 04                	je     800c68 <strcmp+0x1c>
  800c64:	3a 02                	cmp    (%edx),%al
  800c66:	74 ef                	je     800c57 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c68:	0f b6 c0             	movzbl %al,%eax
  800c6b:	0f b6 12             	movzbl (%edx),%edx
  800c6e:	29 d0                	sub    %edx,%eax
}
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	53                   	push   %ebx
  800c76:	8b 45 08             	mov    0x8(%ebp),%eax
  800c79:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c7c:	89 c3                	mov    %eax,%ebx
  800c7e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c81:	eb 06                	jmp    800c89 <strncmp+0x17>
		n--, p++, q++;
  800c83:	83 c0 01             	add    $0x1,%eax
  800c86:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c89:	39 d8                	cmp    %ebx,%eax
  800c8b:	74 18                	je     800ca5 <strncmp+0x33>
  800c8d:	0f b6 08             	movzbl (%eax),%ecx
  800c90:	84 c9                	test   %cl,%cl
  800c92:	74 04                	je     800c98 <strncmp+0x26>
  800c94:	3a 0a                	cmp    (%edx),%cl
  800c96:	74 eb                	je     800c83 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c98:	0f b6 00             	movzbl (%eax),%eax
  800c9b:	0f b6 12             	movzbl (%edx),%edx
  800c9e:	29 d0                	sub    %edx,%eax
}
  800ca0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ca3:	c9                   	leave  
  800ca4:	c3                   	ret    
		return 0;
  800ca5:	b8 00 00 00 00       	mov    $0x0,%eax
  800caa:	eb f4                	jmp    800ca0 <strncmp+0x2e>

00800cac <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cb6:	eb 03                	jmp    800cbb <strchr+0xf>
  800cb8:	83 c0 01             	add    $0x1,%eax
  800cbb:	0f b6 10             	movzbl (%eax),%edx
  800cbe:	84 d2                	test   %dl,%dl
  800cc0:	74 06                	je     800cc8 <strchr+0x1c>
		if (*s == c)
  800cc2:	38 ca                	cmp    %cl,%dl
  800cc4:	75 f2                	jne    800cb8 <strchr+0xc>
  800cc6:	eb 05                	jmp    800ccd <strchr+0x21>
			return (char *) s;
	return 0;
  800cc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cd9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800cdc:	38 ca                	cmp    %cl,%dl
  800cde:	74 09                	je     800ce9 <strfind+0x1a>
  800ce0:	84 d2                	test   %dl,%dl
  800ce2:	74 05                	je     800ce9 <strfind+0x1a>
	for (; *s; s++)
  800ce4:	83 c0 01             	add    $0x1,%eax
  800ce7:	eb f0                	jmp    800cd9 <strfind+0xa>
			break;
	return (char *) s;
}
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	57                   	push   %edi
  800cef:	56                   	push   %esi
  800cf0:	53                   	push   %ebx
  800cf1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cf4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cf7:	85 c9                	test   %ecx,%ecx
  800cf9:	74 2f                	je     800d2a <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cfb:	89 f8                	mov    %edi,%eax
  800cfd:	09 c8                	or     %ecx,%eax
  800cff:	a8 03                	test   $0x3,%al
  800d01:	75 21                	jne    800d24 <memset+0x39>
		c &= 0xFF;
  800d03:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d07:	89 d0                	mov    %edx,%eax
  800d09:	c1 e0 08             	shl    $0x8,%eax
  800d0c:	89 d3                	mov    %edx,%ebx
  800d0e:	c1 e3 18             	shl    $0x18,%ebx
  800d11:	89 d6                	mov    %edx,%esi
  800d13:	c1 e6 10             	shl    $0x10,%esi
  800d16:	09 f3                	or     %esi,%ebx
  800d18:	09 da                	or     %ebx,%edx
  800d1a:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d1c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800d1f:	fc                   	cld    
  800d20:	f3 ab                	rep stos %eax,%es:(%edi)
  800d22:	eb 06                	jmp    800d2a <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d27:	fc                   	cld    
  800d28:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d2a:	89 f8                	mov    %edi,%eax
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    

00800d31 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	57                   	push   %edi
  800d35:	56                   	push   %esi
  800d36:	8b 45 08             	mov    0x8(%ebp),%eax
  800d39:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d3c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d3f:	39 c6                	cmp    %eax,%esi
  800d41:	73 32                	jae    800d75 <memmove+0x44>
  800d43:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d46:	39 c2                	cmp    %eax,%edx
  800d48:	76 2b                	jbe    800d75 <memmove+0x44>
		s += n;
		d += n;
  800d4a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d4d:	89 d6                	mov    %edx,%esi
  800d4f:	09 fe                	or     %edi,%esi
  800d51:	09 ce                	or     %ecx,%esi
  800d53:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d59:	75 0e                	jne    800d69 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d5b:	83 ef 04             	sub    $0x4,%edi
  800d5e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d61:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d64:	fd                   	std    
  800d65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d67:	eb 09                	jmp    800d72 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d69:	83 ef 01             	sub    $0x1,%edi
  800d6c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d6f:	fd                   	std    
  800d70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d72:	fc                   	cld    
  800d73:	eb 1a                	jmp    800d8f <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d75:	89 f2                	mov    %esi,%edx
  800d77:	09 c2                	or     %eax,%edx
  800d79:	09 ca                	or     %ecx,%edx
  800d7b:	f6 c2 03             	test   $0x3,%dl
  800d7e:	75 0a                	jne    800d8a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d80:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d83:	89 c7                	mov    %eax,%edi
  800d85:	fc                   	cld    
  800d86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d88:	eb 05                	jmp    800d8f <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800d8a:	89 c7                	mov    %eax,%edi
  800d8c:	fc                   	cld    
  800d8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d99:	ff 75 10             	push   0x10(%ebp)
  800d9c:	ff 75 0c             	push   0xc(%ebp)
  800d9f:	ff 75 08             	push   0x8(%ebp)
  800da2:	e8 8a ff ff ff       	call   800d31 <memmove>
}
  800da7:	c9                   	leave  
  800da8:	c3                   	ret    

00800da9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
  800dae:	8b 45 08             	mov    0x8(%ebp),%eax
  800db1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db4:	89 c6                	mov    %eax,%esi
  800db6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800db9:	eb 06                	jmp    800dc1 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800dbb:	83 c0 01             	add    $0x1,%eax
  800dbe:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800dc1:	39 f0                	cmp    %esi,%eax
  800dc3:	74 14                	je     800dd9 <memcmp+0x30>
		if (*s1 != *s2)
  800dc5:	0f b6 08             	movzbl (%eax),%ecx
  800dc8:	0f b6 1a             	movzbl (%edx),%ebx
  800dcb:	38 d9                	cmp    %bl,%cl
  800dcd:	74 ec                	je     800dbb <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800dcf:	0f b6 c1             	movzbl %cl,%eax
  800dd2:	0f b6 db             	movzbl %bl,%ebx
  800dd5:	29 d8                	sub    %ebx,%eax
  800dd7:	eb 05                	jmp    800dde <memcmp+0x35>
	}

	return 0;
  800dd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dde:	5b                   	pop    %ebx
  800ddf:	5e                   	pop    %esi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	8b 45 08             	mov    0x8(%ebp),%eax
  800de8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800deb:	89 c2                	mov    %eax,%edx
  800ded:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800df0:	eb 03                	jmp    800df5 <memfind+0x13>
  800df2:	83 c0 01             	add    $0x1,%eax
  800df5:	39 d0                	cmp    %edx,%eax
  800df7:	73 04                	jae    800dfd <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800df9:	38 08                	cmp    %cl,(%eax)
  800dfb:	75 f5                	jne    800df2 <memfind+0x10>
			break;
	return (void *) s;
}
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	57                   	push   %edi
  800e03:	56                   	push   %esi
  800e04:	53                   	push   %ebx
  800e05:	8b 55 08             	mov    0x8(%ebp),%edx
  800e08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e0b:	eb 03                	jmp    800e10 <strtol+0x11>
		s++;
  800e0d:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800e10:	0f b6 02             	movzbl (%edx),%eax
  800e13:	3c 20                	cmp    $0x20,%al
  800e15:	74 f6                	je     800e0d <strtol+0xe>
  800e17:	3c 09                	cmp    $0x9,%al
  800e19:	74 f2                	je     800e0d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800e1b:	3c 2b                	cmp    $0x2b,%al
  800e1d:	74 2a                	je     800e49 <strtol+0x4a>
	int neg = 0;
  800e1f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800e24:	3c 2d                	cmp    $0x2d,%al
  800e26:	74 2b                	je     800e53 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e28:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e2e:	75 0f                	jne    800e3f <strtol+0x40>
  800e30:	80 3a 30             	cmpb   $0x30,(%edx)
  800e33:	74 28                	je     800e5d <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e35:	85 db                	test   %ebx,%ebx
  800e37:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e3c:	0f 44 d8             	cmove  %eax,%ebx
  800e3f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e44:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e47:	eb 46                	jmp    800e8f <strtol+0x90>
		s++;
  800e49:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800e4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800e51:	eb d5                	jmp    800e28 <strtol+0x29>
		s++, neg = 1;
  800e53:	83 c2 01             	add    $0x1,%edx
  800e56:	bf 01 00 00 00       	mov    $0x1,%edi
  800e5b:	eb cb                	jmp    800e28 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e5d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e61:	74 0e                	je     800e71 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800e63:	85 db                	test   %ebx,%ebx
  800e65:	75 d8                	jne    800e3f <strtol+0x40>
		s++, base = 8;
  800e67:	83 c2 01             	add    $0x1,%edx
  800e6a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800e6f:	eb ce                	jmp    800e3f <strtol+0x40>
		s += 2, base = 16;
  800e71:	83 c2 02             	add    $0x2,%edx
  800e74:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e79:	eb c4                	jmp    800e3f <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800e7b:	0f be c0             	movsbl %al,%eax
  800e7e:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e81:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e84:	7d 3a                	jge    800ec0 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800e86:	83 c2 01             	add    $0x1,%edx
  800e89:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800e8d:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800e8f:	0f b6 02             	movzbl (%edx),%eax
  800e92:	8d 70 d0             	lea    -0x30(%eax),%esi
  800e95:	89 f3                	mov    %esi,%ebx
  800e97:	80 fb 09             	cmp    $0x9,%bl
  800e9a:	76 df                	jbe    800e7b <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800e9c:	8d 70 9f             	lea    -0x61(%eax),%esi
  800e9f:	89 f3                	mov    %esi,%ebx
  800ea1:	80 fb 19             	cmp    $0x19,%bl
  800ea4:	77 08                	ja     800eae <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ea6:	0f be c0             	movsbl %al,%eax
  800ea9:	83 e8 57             	sub    $0x57,%eax
  800eac:	eb d3                	jmp    800e81 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800eae:	8d 70 bf             	lea    -0x41(%eax),%esi
  800eb1:	89 f3                	mov    %esi,%ebx
  800eb3:	80 fb 19             	cmp    $0x19,%bl
  800eb6:	77 08                	ja     800ec0 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800eb8:	0f be c0             	movsbl %al,%eax
  800ebb:	83 e8 37             	sub    $0x37,%eax
  800ebe:	eb c1                	jmp    800e81 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ec0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ec4:	74 05                	je     800ecb <strtol+0xcc>
		*endptr = (char *) s;
  800ec6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec9:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ecb:	89 c8                	mov    %ecx,%eax
  800ecd:	f7 d8                	neg    %eax
  800ecf:	85 ff                	test   %edi,%edi
  800ed1:	0f 45 c8             	cmovne %eax,%ecx
}
  800ed4:	89 c8                	mov    %ecx,%eax
  800ed6:	5b                   	pop    %ebx
  800ed7:	5e                   	pop    %esi
  800ed8:	5f                   	pop    %edi
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    

00800edb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	57                   	push   %edi
  800edf:	56                   	push   %esi
  800ee0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ee1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eec:	89 c3                	mov    %eax,%ebx
  800eee:	89 c7                	mov    %eax,%edi
  800ef0:	89 c6                	mov    %eax,%esi
  800ef2:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	57                   	push   %edi
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eff:	ba 00 00 00 00       	mov    $0x0,%edx
  800f04:	b8 01 00 00 00       	mov    $0x1,%eax
  800f09:	89 d1                	mov    %edx,%ecx
  800f0b:	89 d3                	mov    %edx,%ebx
  800f0d:	89 d7                	mov    %edx,%edi
  800f0f:	89 d6                	mov    %edx,%esi
  800f11:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f13:	5b                   	pop    %ebx
  800f14:	5e                   	pop    %esi
  800f15:	5f                   	pop    %edi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    

00800f18 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	57                   	push   %edi
  800f1c:	56                   	push   %esi
  800f1d:	53                   	push   %ebx
  800f1e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f21:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f26:	8b 55 08             	mov    0x8(%ebp),%edx
  800f29:	b8 03 00 00 00       	mov    $0x3,%eax
  800f2e:	89 cb                	mov    %ecx,%ebx
  800f30:	89 cf                	mov    %ecx,%edi
  800f32:	89 ce                	mov    %ecx,%esi
  800f34:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f36:	85 c0                	test   %eax,%eax
  800f38:	7f 08                	jg     800f42 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f3d:	5b                   	pop    %ebx
  800f3e:	5e                   	pop    %esi
  800f3f:	5f                   	pop    %edi
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f42:	83 ec 0c             	sub    $0xc,%esp
  800f45:	50                   	push   %eax
  800f46:	6a 03                	push   $0x3
  800f48:	68 df 2a 80 00       	push   $0x802adf
  800f4d:	6a 2a                	push   $0x2a
  800f4f:	68 fc 2a 80 00       	push   $0x802afc
  800f54:	e8 9e 13 00 00       	call   8022f7 <_panic>

00800f59 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	57                   	push   %edi
  800f5d:	56                   	push   %esi
  800f5e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f64:	b8 02 00 00 00       	mov    $0x2,%eax
  800f69:	89 d1                	mov    %edx,%ecx
  800f6b:	89 d3                	mov    %edx,%ebx
  800f6d:	89 d7                	mov    %edx,%edi
  800f6f:	89 d6                	mov    %edx,%esi
  800f71:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f73:	5b                   	pop    %ebx
  800f74:	5e                   	pop    %esi
  800f75:	5f                   	pop    %edi
  800f76:	5d                   	pop    %ebp
  800f77:	c3                   	ret    

00800f78 <sys_yield>:

void
sys_yield(void)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	57                   	push   %edi
  800f7c:	56                   	push   %esi
  800f7d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f83:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f88:	89 d1                	mov    %edx,%ecx
  800f8a:	89 d3                	mov    %edx,%ebx
  800f8c:	89 d7                	mov    %edx,%edi
  800f8e:	89 d6                	mov    %edx,%esi
  800f90:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f92:	5b                   	pop    %ebx
  800f93:	5e                   	pop    %esi
  800f94:	5f                   	pop    %edi
  800f95:	5d                   	pop    %ebp
  800f96:	c3                   	ret    

00800f97 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	57                   	push   %edi
  800f9b:	56                   	push   %esi
  800f9c:	53                   	push   %ebx
  800f9d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fa0:	be 00 00 00 00       	mov    $0x0,%esi
  800fa5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fab:	b8 04 00 00 00       	mov    $0x4,%eax
  800fb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fb3:	89 f7                	mov    %esi,%edi
  800fb5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	7f 08                	jg     800fc3 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fbe:	5b                   	pop    %ebx
  800fbf:	5e                   	pop    %esi
  800fc0:	5f                   	pop    %edi
  800fc1:	5d                   	pop    %ebp
  800fc2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc3:	83 ec 0c             	sub    $0xc,%esp
  800fc6:	50                   	push   %eax
  800fc7:	6a 04                	push   $0x4
  800fc9:	68 df 2a 80 00       	push   $0x802adf
  800fce:	6a 2a                	push   $0x2a
  800fd0:	68 fc 2a 80 00       	push   $0x802afc
  800fd5:	e8 1d 13 00 00       	call   8022f7 <_panic>

00800fda <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	57                   	push   %edi
  800fde:	56                   	push   %esi
  800fdf:	53                   	push   %ebx
  800fe0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fe3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe9:	b8 05 00 00 00       	mov    $0x5,%eax
  800fee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ff1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ff4:	8b 75 18             	mov    0x18(%ebp),%esi
  800ff7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	7f 08                	jg     801005 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ffd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801000:	5b                   	pop    %ebx
  801001:	5e                   	pop    %esi
  801002:	5f                   	pop    %edi
  801003:	5d                   	pop    %ebp
  801004:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801005:	83 ec 0c             	sub    $0xc,%esp
  801008:	50                   	push   %eax
  801009:	6a 05                	push   $0x5
  80100b:	68 df 2a 80 00       	push   $0x802adf
  801010:	6a 2a                	push   $0x2a
  801012:	68 fc 2a 80 00       	push   $0x802afc
  801017:	e8 db 12 00 00       	call   8022f7 <_panic>

0080101c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	57                   	push   %edi
  801020:	56                   	push   %esi
  801021:	53                   	push   %ebx
  801022:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801025:	bb 00 00 00 00       	mov    $0x0,%ebx
  80102a:	8b 55 08             	mov    0x8(%ebp),%edx
  80102d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801030:	b8 06 00 00 00       	mov    $0x6,%eax
  801035:	89 df                	mov    %ebx,%edi
  801037:	89 de                	mov    %ebx,%esi
  801039:	cd 30                	int    $0x30
	if(check && ret > 0)
  80103b:	85 c0                	test   %eax,%eax
  80103d:	7f 08                	jg     801047 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80103f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801042:	5b                   	pop    %ebx
  801043:	5e                   	pop    %esi
  801044:	5f                   	pop    %edi
  801045:	5d                   	pop    %ebp
  801046:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801047:	83 ec 0c             	sub    $0xc,%esp
  80104a:	50                   	push   %eax
  80104b:	6a 06                	push   $0x6
  80104d:	68 df 2a 80 00       	push   $0x802adf
  801052:	6a 2a                	push   $0x2a
  801054:	68 fc 2a 80 00       	push   $0x802afc
  801059:	e8 99 12 00 00       	call   8022f7 <_panic>

0080105e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80105e:	55                   	push   %ebp
  80105f:	89 e5                	mov    %esp,%ebp
  801061:	57                   	push   %edi
  801062:	56                   	push   %esi
  801063:	53                   	push   %ebx
  801064:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801067:	bb 00 00 00 00       	mov    $0x0,%ebx
  80106c:	8b 55 08             	mov    0x8(%ebp),%edx
  80106f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801072:	b8 08 00 00 00       	mov    $0x8,%eax
  801077:	89 df                	mov    %ebx,%edi
  801079:	89 de                	mov    %ebx,%esi
  80107b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80107d:	85 c0                	test   %eax,%eax
  80107f:	7f 08                	jg     801089 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801081:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801084:	5b                   	pop    %ebx
  801085:	5e                   	pop    %esi
  801086:	5f                   	pop    %edi
  801087:	5d                   	pop    %ebp
  801088:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801089:	83 ec 0c             	sub    $0xc,%esp
  80108c:	50                   	push   %eax
  80108d:	6a 08                	push   $0x8
  80108f:	68 df 2a 80 00       	push   $0x802adf
  801094:	6a 2a                	push   $0x2a
  801096:	68 fc 2a 80 00       	push   $0x802afc
  80109b:	e8 57 12 00 00       	call   8022f7 <_panic>

008010a0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	57                   	push   %edi
  8010a4:	56                   	push   %esi
  8010a5:	53                   	push   %ebx
  8010a6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b4:	b8 09 00 00 00       	mov    $0x9,%eax
  8010b9:	89 df                	mov    %ebx,%edi
  8010bb:	89 de                	mov    %ebx,%esi
  8010bd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	7f 08                	jg     8010cb <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c6:	5b                   	pop    %ebx
  8010c7:	5e                   	pop    %esi
  8010c8:	5f                   	pop    %edi
  8010c9:	5d                   	pop    %ebp
  8010ca:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8010cb:	83 ec 0c             	sub    $0xc,%esp
  8010ce:	50                   	push   %eax
  8010cf:	6a 09                	push   $0x9
  8010d1:	68 df 2a 80 00       	push   $0x802adf
  8010d6:	6a 2a                	push   $0x2a
  8010d8:	68 fc 2a 80 00       	push   $0x802afc
  8010dd:	e8 15 12 00 00       	call   8022f7 <_panic>

008010e2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	57                   	push   %edi
  8010e6:	56                   	push   %esi
  8010e7:	53                   	push   %ebx
  8010e8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010fb:	89 df                	mov    %ebx,%edi
  8010fd:	89 de                	mov    %ebx,%esi
  8010ff:	cd 30                	int    $0x30
	if(check && ret > 0)
  801101:	85 c0                	test   %eax,%eax
  801103:	7f 08                	jg     80110d <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801108:	5b                   	pop    %ebx
  801109:	5e                   	pop    %esi
  80110a:	5f                   	pop    %edi
  80110b:	5d                   	pop    %ebp
  80110c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80110d:	83 ec 0c             	sub    $0xc,%esp
  801110:	50                   	push   %eax
  801111:	6a 0a                	push   $0xa
  801113:	68 df 2a 80 00       	push   $0x802adf
  801118:	6a 2a                	push   $0x2a
  80111a:	68 fc 2a 80 00       	push   $0x802afc
  80111f:	e8 d3 11 00 00       	call   8022f7 <_panic>

00801124 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	57                   	push   %edi
  801128:	56                   	push   %esi
  801129:	53                   	push   %ebx
	asm volatile("int %1\n"
  80112a:	8b 55 08             	mov    0x8(%ebp),%edx
  80112d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801130:	b8 0c 00 00 00       	mov    $0xc,%eax
  801135:	be 00 00 00 00       	mov    $0x0,%esi
  80113a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80113d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801140:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801142:	5b                   	pop    %ebx
  801143:	5e                   	pop    %esi
  801144:	5f                   	pop    %edi
  801145:	5d                   	pop    %ebp
  801146:	c3                   	ret    

00801147 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	57                   	push   %edi
  80114b:	56                   	push   %esi
  80114c:	53                   	push   %ebx
  80114d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801150:	b9 00 00 00 00       	mov    $0x0,%ecx
  801155:	8b 55 08             	mov    0x8(%ebp),%edx
  801158:	b8 0d 00 00 00       	mov    $0xd,%eax
  80115d:	89 cb                	mov    %ecx,%ebx
  80115f:	89 cf                	mov    %ecx,%edi
  801161:	89 ce                	mov    %ecx,%esi
  801163:	cd 30                	int    $0x30
	if(check && ret > 0)
  801165:	85 c0                	test   %eax,%eax
  801167:	7f 08                	jg     801171 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801169:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116c:	5b                   	pop    %ebx
  80116d:	5e                   	pop    %esi
  80116e:	5f                   	pop    %edi
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801171:	83 ec 0c             	sub    $0xc,%esp
  801174:	50                   	push   %eax
  801175:	6a 0d                	push   $0xd
  801177:	68 df 2a 80 00       	push   $0x802adf
  80117c:	6a 2a                	push   $0x2a
  80117e:	68 fc 2a 80 00       	push   $0x802afc
  801183:	e8 6f 11 00 00       	call   8022f7 <_panic>

00801188 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	57                   	push   %edi
  80118c:	56                   	push   %esi
  80118d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80118e:	ba 00 00 00 00       	mov    $0x0,%edx
  801193:	b8 0e 00 00 00       	mov    $0xe,%eax
  801198:	89 d1                	mov    %edx,%ecx
  80119a:	89 d3                	mov    %edx,%ebx
  80119c:	89 d7                	mov    %edx,%edi
  80119e:	89 d6                	mov    %edx,%esi
  8011a0:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8011a2:	5b                   	pop    %ebx
  8011a3:	5e                   	pop    %esi
  8011a4:	5f                   	pop    %edi
  8011a5:	5d                   	pop    %ebp
  8011a6:	c3                   	ret    

008011a7 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	57                   	push   %edi
  8011ab:	56                   	push   %esi
  8011ac:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b8:	b8 0f 00 00 00       	mov    $0xf,%eax
  8011bd:	89 df                	mov    %ebx,%edi
  8011bf:	89 de                	mov    %ebx,%esi
  8011c1:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  8011c3:	5b                   	pop    %ebx
  8011c4:	5e                   	pop    %esi
  8011c5:	5f                   	pop    %edi
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	57                   	push   %edi
  8011cc:	56                   	push   %esi
  8011cd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d9:	b8 10 00 00 00       	mov    $0x10,%eax
  8011de:	89 df                	mov    %ebx,%edi
  8011e0:	89 de                	mov    %ebx,%esi
  8011e2:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8011e4:	5b                   	pop    %ebx
  8011e5:	5e                   	pop    %esi
  8011e6:	5f                   	pop    %edi
  8011e7:	5d                   	pop    %ebp
  8011e8:	c3                   	ret    

008011e9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ef:	05 00 00 00 30       	add    $0x30000000,%eax
  8011f4:	c1 e8 0c             	shr    $0xc,%eax
}
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ff:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801204:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801209:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801218:	89 c2                	mov    %eax,%edx
  80121a:	c1 ea 16             	shr    $0x16,%edx
  80121d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801224:	f6 c2 01             	test   $0x1,%dl
  801227:	74 29                	je     801252 <fd_alloc+0x42>
  801229:	89 c2                	mov    %eax,%edx
  80122b:	c1 ea 0c             	shr    $0xc,%edx
  80122e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801235:	f6 c2 01             	test   $0x1,%dl
  801238:	74 18                	je     801252 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80123a:	05 00 10 00 00       	add    $0x1000,%eax
  80123f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801244:	75 d2                	jne    801218 <fd_alloc+0x8>
  801246:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80124b:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801250:	eb 05                	jmp    801257 <fd_alloc+0x47>
			return 0;
  801252:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801257:	8b 55 08             	mov    0x8(%ebp),%edx
  80125a:	89 02                	mov    %eax,(%edx)
}
  80125c:	89 c8                	mov    %ecx,%eax
  80125e:	5d                   	pop    %ebp
  80125f:	c3                   	ret    

00801260 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801266:	83 f8 1f             	cmp    $0x1f,%eax
  801269:	77 30                	ja     80129b <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80126b:	c1 e0 0c             	shl    $0xc,%eax
  80126e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801273:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801279:	f6 c2 01             	test   $0x1,%dl
  80127c:	74 24                	je     8012a2 <fd_lookup+0x42>
  80127e:	89 c2                	mov    %eax,%edx
  801280:	c1 ea 0c             	shr    $0xc,%edx
  801283:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80128a:	f6 c2 01             	test   $0x1,%dl
  80128d:	74 1a                	je     8012a9 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80128f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801292:	89 02                	mov    %eax,(%edx)
	return 0;
  801294:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801299:	5d                   	pop    %ebp
  80129a:	c3                   	ret    
		return -E_INVAL;
  80129b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a0:	eb f7                	jmp    801299 <fd_lookup+0x39>
		return -E_INVAL;
  8012a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a7:	eb f0                	jmp    801299 <fd_lookup+0x39>
  8012a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ae:	eb e9                	jmp    801299 <fd_lookup+0x39>

008012b0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	53                   	push   %ebx
  8012b4:	83 ec 04             	sub    $0x4,%esp
  8012b7:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bf:	bb 08 30 80 00       	mov    $0x803008,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8012c4:	39 13                	cmp    %edx,(%ebx)
  8012c6:	74 37                	je     8012ff <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8012c8:	83 c0 01             	add    $0x1,%eax
  8012cb:	8b 1c 85 88 2b 80 00 	mov    0x802b88(,%eax,4),%ebx
  8012d2:	85 db                	test   %ebx,%ebx
  8012d4:	75 ee                	jne    8012c4 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012d6:	a1 10 40 80 00       	mov    0x804010,%eax
  8012db:	8b 40 48             	mov    0x48(%eax),%eax
  8012de:	83 ec 04             	sub    $0x4,%esp
  8012e1:	52                   	push   %edx
  8012e2:	50                   	push   %eax
  8012e3:	68 0c 2b 80 00       	push   $0x802b0c
  8012e8:	e8 d4 f2 ff ff       	call   8005c1 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8012ed:	83 c4 10             	add    $0x10,%esp
  8012f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8012f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f8:	89 1a                	mov    %ebx,(%edx)
}
  8012fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012fd:	c9                   	leave  
  8012fe:	c3                   	ret    
			return 0;
  8012ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801304:	eb ef                	jmp    8012f5 <dev_lookup+0x45>

00801306 <fd_close>:
{
  801306:	55                   	push   %ebp
  801307:	89 e5                	mov    %esp,%ebp
  801309:	57                   	push   %edi
  80130a:	56                   	push   %esi
  80130b:	53                   	push   %ebx
  80130c:	83 ec 24             	sub    $0x24,%esp
  80130f:	8b 75 08             	mov    0x8(%ebp),%esi
  801312:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801315:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801318:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801319:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80131f:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801322:	50                   	push   %eax
  801323:	e8 38 ff ff ff       	call   801260 <fd_lookup>
  801328:	89 c3                	mov    %eax,%ebx
  80132a:	83 c4 10             	add    $0x10,%esp
  80132d:	85 c0                	test   %eax,%eax
  80132f:	78 05                	js     801336 <fd_close+0x30>
	    || fd != fd2)
  801331:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801334:	74 16                	je     80134c <fd_close+0x46>
		return (must_exist ? r : 0);
  801336:	89 f8                	mov    %edi,%eax
  801338:	84 c0                	test   %al,%al
  80133a:	b8 00 00 00 00       	mov    $0x0,%eax
  80133f:	0f 44 d8             	cmove  %eax,%ebx
}
  801342:	89 d8                	mov    %ebx,%eax
  801344:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801347:	5b                   	pop    %ebx
  801348:	5e                   	pop    %esi
  801349:	5f                   	pop    %edi
  80134a:	5d                   	pop    %ebp
  80134b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80134c:	83 ec 08             	sub    $0x8,%esp
  80134f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801352:	50                   	push   %eax
  801353:	ff 36                	push   (%esi)
  801355:	e8 56 ff ff ff       	call   8012b0 <dev_lookup>
  80135a:	89 c3                	mov    %eax,%ebx
  80135c:	83 c4 10             	add    $0x10,%esp
  80135f:	85 c0                	test   %eax,%eax
  801361:	78 1a                	js     80137d <fd_close+0x77>
		if (dev->dev_close)
  801363:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801366:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801369:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80136e:	85 c0                	test   %eax,%eax
  801370:	74 0b                	je     80137d <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801372:	83 ec 0c             	sub    $0xc,%esp
  801375:	56                   	push   %esi
  801376:	ff d0                	call   *%eax
  801378:	89 c3                	mov    %eax,%ebx
  80137a:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80137d:	83 ec 08             	sub    $0x8,%esp
  801380:	56                   	push   %esi
  801381:	6a 00                	push   $0x0
  801383:	e8 94 fc ff ff       	call   80101c <sys_page_unmap>
	return r;
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	eb b5                	jmp    801342 <fd_close+0x3c>

0080138d <close>:

int
close(int fdnum)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801393:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801396:	50                   	push   %eax
  801397:	ff 75 08             	push   0x8(%ebp)
  80139a:	e8 c1 fe ff ff       	call   801260 <fd_lookup>
  80139f:	83 c4 10             	add    $0x10,%esp
  8013a2:	85 c0                	test   %eax,%eax
  8013a4:	79 02                	jns    8013a8 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8013a6:	c9                   	leave  
  8013a7:	c3                   	ret    
		return fd_close(fd, 1);
  8013a8:	83 ec 08             	sub    $0x8,%esp
  8013ab:	6a 01                	push   $0x1
  8013ad:	ff 75 f4             	push   -0xc(%ebp)
  8013b0:	e8 51 ff ff ff       	call   801306 <fd_close>
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	eb ec                	jmp    8013a6 <close+0x19>

008013ba <close_all>:

void
close_all(void)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	53                   	push   %ebx
  8013be:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013c1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013c6:	83 ec 0c             	sub    $0xc,%esp
  8013c9:	53                   	push   %ebx
  8013ca:	e8 be ff ff ff       	call   80138d <close>
	for (i = 0; i < MAXFD; i++)
  8013cf:	83 c3 01             	add    $0x1,%ebx
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	83 fb 20             	cmp    $0x20,%ebx
  8013d8:	75 ec                	jne    8013c6 <close_all+0xc>
}
  8013da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013dd:	c9                   	leave  
  8013de:	c3                   	ret    

008013df <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	57                   	push   %edi
  8013e3:	56                   	push   %esi
  8013e4:	53                   	push   %ebx
  8013e5:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013e8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013eb:	50                   	push   %eax
  8013ec:	ff 75 08             	push   0x8(%ebp)
  8013ef:	e8 6c fe ff ff       	call   801260 <fd_lookup>
  8013f4:	89 c3                	mov    %eax,%ebx
  8013f6:	83 c4 10             	add    $0x10,%esp
  8013f9:	85 c0                	test   %eax,%eax
  8013fb:	78 7f                	js     80147c <dup+0x9d>
		return r;
	close(newfdnum);
  8013fd:	83 ec 0c             	sub    $0xc,%esp
  801400:	ff 75 0c             	push   0xc(%ebp)
  801403:	e8 85 ff ff ff       	call   80138d <close>

	newfd = INDEX2FD(newfdnum);
  801408:	8b 75 0c             	mov    0xc(%ebp),%esi
  80140b:	c1 e6 0c             	shl    $0xc,%esi
  80140e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801417:	89 3c 24             	mov    %edi,(%esp)
  80141a:	e8 da fd ff ff       	call   8011f9 <fd2data>
  80141f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801421:	89 34 24             	mov    %esi,(%esp)
  801424:	e8 d0 fd ff ff       	call   8011f9 <fd2data>
  801429:	83 c4 10             	add    $0x10,%esp
  80142c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80142f:	89 d8                	mov    %ebx,%eax
  801431:	c1 e8 16             	shr    $0x16,%eax
  801434:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80143b:	a8 01                	test   $0x1,%al
  80143d:	74 11                	je     801450 <dup+0x71>
  80143f:	89 d8                	mov    %ebx,%eax
  801441:	c1 e8 0c             	shr    $0xc,%eax
  801444:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80144b:	f6 c2 01             	test   $0x1,%dl
  80144e:	75 36                	jne    801486 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801450:	89 f8                	mov    %edi,%eax
  801452:	c1 e8 0c             	shr    $0xc,%eax
  801455:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80145c:	83 ec 0c             	sub    $0xc,%esp
  80145f:	25 07 0e 00 00       	and    $0xe07,%eax
  801464:	50                   	push   %eax
  801465:	56                   	push   %esi
  801466:	6a 00                	push   $0x0
  801468:	57                   	push   %edi
  801469:	6a 00                	push   $0x0
  80146b:	e8 6a fb ff ff       	call   800fda <sys_page_map>
  801470:	89 c3                	mov    %eax,%ebx
  801472:	83 c4 20             	add    $0x20,%esp
  801475:	85 c0                	test   %eax,%eax
  801477:	78 33                	js     8014ac <dup+0xcd>
		goto err;

	return newfdnum;
  801479:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80147c:	89 d8                	mov    %ebx,%eax
  80147e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801481:	5b                   	pop    %ebx
  801482:	5e                   	pop    %esi
  801483:	5f                   	pop    %edi
  801484:	5d                   	pop    %ebp
  801485:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801486:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80148d:	83 ec 0c             	sub    $0xc,%esp
  801490:	25 07 0e 00 00       	and    $0xe07,%eax
  801495:	50                   	push   %eax
  801496:	ff 75 d4             	push   -0x2c(%ebp)
  801499:	6a 00                	push   $0x0
  80149b:	53                   	push   %ebx
  80149c:	6a 00                	push   $0x0
  80149e:	e8 37 fb ff ff       	call   800fda <sys_page_map>
  8014a3:	89 c3                	mov    %eax,%ebx
  8014a5:	83 c4 20             	add    $0x20,%esp
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	79 a4                	jns    801450 <dup+0x71>
	sys_page_unmap(0, newfd);
  8014ac:	83 ec 08             	sub    $0x8,%esp
  8014af:	56                   	push   %esi
  8014b0:	6a 00                	push   $0x0
  8014b2:	e8 65 fb ff ff       	call   80101c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014b7:	83 c4 08             	add    $0x8,%esp
  8014ba:	ff 75 d4             	push   -0x2c(%ebp)
  8014bd:	6a 00                	push   $0x0
  8014bf:	e8 58 fb ff ff       	call   80101c <sys_page_unmap>
	return r;
  8014c4:	83 c4 10             	add    $0x10,%esp
  8014c7:	eb b3                	jmp    80147c <dup+0x9d>

008014c9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014c9:	55                   	push   %ebp
  8014ca:	89 e5                	mov    %esp,%ebp
  8014cc:	56                   	push   %esi
  8014cd:	53                   	push   %ebx
  8014ce:	83 ec 18             	sub    $0x18,%esp
  8014d1:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d7:	50                   	push   %eax
  8014d8:	56                   	push   %esi
  8014d9:	e8 82 fd ff ff       	call   801260 <fd_lookup>
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	78 3c                	js     801521 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e5:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8014e8:	83 ec 08             	sub    $0x8,%esp
  8014eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ee:	50                   	push   %eax
  8014ef:	ff 33                	push   (%ebx)
  8014f1:	e8 ba fd ff ff       	call   8012b0 <dev_lookup>
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	78 24                	js     801521 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014fd:	8b 43 08             	mov    0x8(%ebx),%eax
  801500:	83 e0 03             	and    $0x3,%eax
  801503:	83 f8 01             	cmp    $0x1,%eax
  801506:	74 20                	je     801528 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801508:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150b:	8b 40 08             	mov    0x8(%eax),%eax
  80150e:	85 c0                	test   %eax,%eax
  801510:	74 37                	je     801549 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801512:	83 ec 04             	sub    $0x4,%esp
  801515:	ff 75 10             	push   0x10(%ebp)
  801518:	ff 75 0c             	push   0xc(%ebp)
  80151b:	53                   	push   %ebx
  80151c:	ff d0                	call   *%eax
  80151e:	83 c4 10             	add    $0x10,%esp
}
  801521:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801524:	5b                   	pop    %ebx
  801525:	5e                   	pop    %esi
  801526:	5d                   	pop    %ebp
  801527:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801528:	a1 10 40 80 00       	mov    0x804010,%eax
  80152d:	8b 40 48             	mov    0x48(%eax),%eax
  801530:	83 ec 04             	sub    $0x4,%esp
  801533:	56                   	push   %esi
  801534:	50                   	push   %eax
  801535:	68 4d 2b 80 00       	push   $0x802b4d
  80153a:	e8 82 f0 ff ff       	call   8005c1 <cprintf>
		return -E_INVAL;
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801547:	eb d8                	jmp    801521 <read+0x58>
		return -E_NOT_SUPP;
  801549:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80154e:	eb d1                	jmp    801521 <read+0x58>

00801550 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	57                   	push   %edi
  801554:	56                   	push   %esi
  801555:	53                   	push   %ebx
  801556:	83 ec 0c             	sub    $0xc,%esp
  801559:	8b 7d 08             	mov    0x8(%ebp),%edi
  80155c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80155f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801564:	eb 02                	jmp    801568 <readn+0x18>
  801566:	01 c3                	add    %eax,%ebx
  801568:	39 f3                	cmp    %esi,%ebx
  80156a:	73 21                	jae    80158d <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80156c:	83 ec 04             	sub    $0x4,%esp
  80156f:	89 f0                	mov    %esi,%eax
  801571:	29 d8                	sub    %ebx,%eax
  801573:	50                   	push   %eax
  801574:	89 d8                	mov    %ebx,%eax
  801576:	03 45 0c             	add    0xc(%ebp),%eax
  801579:	50                   	push   %eax
  80157a:	57                   	push   %edi
  80157b:	e8 49 ff ff ff       	call   8014c9 <read>
		if (m < 0)
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	85 c0                	test   %eax,%eax
  801585:	78 04                	js     80158b <readn+0x3b>
			return m;
		if (m == 0)
  801587:	75 dd                	jne    801566 <readn+0x16>
  801589:	eb 02                	jmp    80158d <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80158b:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80158d:	89 d8                	mov    %ebx,%eax
  80158f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801592:	5b                   	pop    %ebx
  801593:	5e                   	pop    %esi
  801594:	5f                   	pop    %edi
  801595:	5d                   	pop    %ebp
  801596:	c3                   	ret    

00801597 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	56                   	push   %esi
  80159b:	53                   	push   %ebx
  80159c:	83 ec 18             	sub    $0x18,%esp
  80159f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a5:	50                   	push   %eax
  8015a6:	53                   	push   %ebx
  8015a7:	e8 b4 fc ff ff       	call   801260 <fd_lookup>
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 37                	js     8015ea <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b3:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015b6:	83 ec 08             	sub    $0x8,%esp
  8015b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bc:	50                   	push   %eax
  8015bd:	ff 36                	push   (%esi)
  8015bf:	e8 ec fc ff ff       	call   8012b0 <dev_lookup>
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	78 1f                	js     8015ea <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015cb:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8015cf:	74 20                	je     8015f1 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	74 37                	je     801612 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015db:	83 ec 04             	sub    $0x4,%esp
  8015de:	ff 75 10             	push   0x10(%ebp)
  8015e1:	ff 75 0c             	push   0xc(%ebp)
  8015e4:	56                   	push   %esi
  8015e5:	ff d0                	call   *%eax
  8015e7:	83 c4 10             	add    $0x10,%esp
}
  8015ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ed:	5b                   	pop    %ebx
  8015ee:	5e                   	pop    %esi
  8015ef:	5d                   	pop    %ebp
  8015f0:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f1:	a1 10 40 80 00       	mov    0x804010,%eax
  8015f6:	8b 40 48             	mov    0x48(%eax),%eax
  8015f9:	83 ec 04             	sub    $0x4,%esp
  8015fc:	53                   	push   %ebx
  8015fd:	50                   	push   %eax
  8015fe:	68 69 2b 80 00       	push   $0x802b69
  801603:	e8 b9 ef ff ff       	call   8005c1 <cprintf>
		return -E_INVAL;
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801610:	eb d8                	jmp    8015ea <write+0x53>
		return -E_NOT_SUPP;
  801612:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801617:	eb d1                	jmp    8015ea <write+0x53>

00801619 <seek>:

int
seek(int fdnum, off_t offset)
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80161f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801622:	50                   	push   %eax
  801623:	ff 75 08             	push   0x8(%ebp)
  801626:	e8 35 fc ff ff       	call   801260 <fd_lookup>
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	85 c0                	test   %eax,%eax
  801630:	78 0e                	js     801640 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801632:	8b 55 0c             	mov    0xc(%ebp),%edx
  801635:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801638:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80163b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801640:	c9                   	leave  
  801641:	c3                   	ret    

00801642 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801642:	55                   	push   %ebp
  801643:	89 e5                	mov    %esp,%ebp
  801645:	56                   	push   %esi
  801646:	53                   	push   %ebx
  801647:	83 ec 18             	sub    $0x18,%esp
  80164a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801650:	50                   	push   %eax
  801651:	53                   	push   %ebx
  801652:	e8 09 fc ff ff       	call   801260 <fd_lookup>
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	85 c0                	test   %eax,%eax
  80165c:	78 34                	js     801692 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801661:	83 ec 08             	sub    $0x8,%esp
  801664:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801667:	50                   	push   %eax
  801668:	ff 36                	push   (%esi)
  80166a:	e8 41 fc ff ff       	call   8012b0 <dev_lookup>
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	85 c0                	test   %eax,%eax
  801674:	78 1c                	js     801692 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801676:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80167a:	74 1d                	je     801699 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80167c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167f:	8b 40 18             	mov    0x18(%eax),%eax
  801682:	85 c0                	test   %eax,%eax
  801684:	74 34                	je     8016ba <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801686:	83 ec 08             	sub    $0x8,%esp
  801689:	ff 75 0c             	push   0xc(%ebp)
  80168c:	56                   	push   %esi
  80168d:	ff d0                	call   *%eax
  80168f:	83 c4 10             	add    $0x10,%esp
}
  801692:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801695:	5b                   	pop    %ebx
  801696:	5e                   	pop    %esi
  801697:	5d                   	pop    %ebp
  801698:	c3                   	ret    
			thisenv->env_id, fdnum);
  801699:	a1 10 40 80 00       	mov    0x804010,%eax
  80169e:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016a1:	83 ec 04             	sub    $0x4,%esp
  8016a4:	53                   	push   %ebx
  8016a5:	50                   	push   %eax
  8016a6:	68 2c 2b 80 00       	push   $0x802b2c
  8016ab:	e8 11 ef ff ff       	call   8005c1 <cprintf>
		return -E_INVAL;
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016b8:	eb d8                	jmp    801692 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8016ba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016bf:	eb d1                	jmp    801692 <ftruncate+0x50>

008016c1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	56                   	push   %esi
  8016c5:	53                   	push   %ebx
  8016c6:	83 ec 18             	sub    $0x18,%esp
  8016c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016cf:	50                   	push   %eax
  8016d0:	ff 75 08             	push   0x8(%ebp)
  8016d3:	e8 88 fb ff ff       	call   801260 <fd_lookup>
  8016d8:	83 c4 10             	add    $0x10,%esp
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	78 49                	js     801728 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016df:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8016e2:	83 ec 08             	sub    $0x8,%esp
  8016e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e8:	50                   	push   %eax
  8016e9:	ff 36                	push   (%esi)
  8016eb:	e8 c0 fb ff ff       	call   8012b0 <dev_lookup>
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	78 31                	js     801728 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8016f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016fa:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016fe:	74 2f                	je     80172f <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801700:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801703:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80170a:	00 00 00 
	stat->st_isdir = 0;
  80170d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801714:	00 00 00 
	stat->st_dev = dev;
  801717:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80171d:	83 ec 08             	sub    $0x8,%esp
  801720:	53                   	push   %ebx
  801721:	56                   	push   %esi
  801722:	ff 50 14             	call   *0x14(%eax)
  801725:	83 c4 10             	add    $0x10,%esp
}
  801728:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172b:	5b                   	pop    %ebx
  80172c:	5e                   	pop    %esi
  80172d:	5d                   	pop    %ebp
  80172e:	c3                   	ret    
		return -E_NOT_SUPP;
  80172f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801734:	eb f2                	jmp    801728 <fstat+0x67>

00801736 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	56                   	push   %esi
  80173a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80173b:	83 ec 08             	sub    $0x8,%esp
  80173e:	6a 00                	push   $0x0
  801740:	ff 75 08             	push   0x8(%ebp)
  801743:	e8 e4 01 00 00       	call   80192c <open>
  801748:	89 c3                	mov    %eax,%ebx
  80174a:	83 c4 10             	add    $0x10,%esp
  80174d:	85 c0                	test   %eax,%eax
  80174f:	78 1b                	js     80176c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801751:	83 ec 08             	sub    $0x8,%esp
  801754:	ff 75 0c             	push   0xc(%ebp)
  801757:	50                   	push   %eax
  801758:	e8 64 ff ff ff       	call   8016c1 <fstat>
  80175d:	89 c6                	mov    %eax,%esi
	close(fd);
  80175f:	89 1c 24             	mov    %ebx,(%esp)
  801762:	e8 26 fc ff ff       	call   80138d <close>
	return r;
  801767:	83 c4 10             	add    $0x10,%esp
  80176a:	89 f3                	mov    %esi,%ebx
}
  80176c:	89 d8                	mov    %ebx,%eax
  80176e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801771:	5b                   	pop    %ebx
  801772:	5e                   	pop    %esi
  801773:	5d                   	pop    %ebp
  801774:	c3                   	ret    

00801775 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	56                   	push   %esi
  801779:	53                   	push   %ebx
  80177a:	89 c6                	mov    %eax,%esi
  80177c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80177e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801785:	74 27                	je     8017ae <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801787:	6a 07                	push   $0x7
  801789:	68 00 50 80 00       	push   $0x805000
  80178e:	56                   	push   %esi
  80178f:	ff 35 00 60 80 00    	push   0x806000
  801795:	e8 0a 0c 00 00       	call   8023a4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80179a:	83 c4 0c             	add    $0xc,%esp
  80179d:	6a 00                	push   $0x0
  80179f:	53                   	push   %ebx
  8017a0:	6a 00                	push   $0x0
  8017a2:	e8 96 0b 00 00       	call   80233d <ipc_recv>
}
  8017a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017aa:	5b                   	pop    %ebx
  8017ab:	5e                   	pop    %esi
  8017ac:	5d                   	pop    %ebp
  8017ad:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017ae:	83 ec 0c             	sub    $0xc,%esp
  8017b1:	6a 01                	push   $0x1
  8017b3:	e8 40 0c 00 00       	call   8023f8 <ipc_find_env>
  8017b8:	a3 00 60 80 00       	mov    %eax,0x806000
  8017bd:	83 c4 10             	add    $0x10,%esp
  8017c0:	eb c5                	jmp    801787 <fsipc+0x12>

008017c2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ce:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017db:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e0:	b8 02 00 00 00       	mov    $0x2,%eax
  8017e5:	e8 8b ff ff ff       	call   801775 <fsipc>
}
  8017ea:	c9                   	leave  
  8017eb:	c3                   	ret    

008017ec <devfile_flush>:
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801802:	b8 06 00 00 00       	mov    $0x6,%eax
  801807:	e8 69 ff ff ff       	call   801775 <fsipc>
}
  80180c:	c9                   	leave  
  80180d:	c3                   	ret    

0080180e <devfile_stat>:
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	53                   	push   %ebx
  801812:	83 ec 04             	sub    $0x4,%esp
  801815:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801818:	8b 45 08             	mov    0x8(%ebp),%eax
  80181b:	8b 40 0c             	mov    0xc(%eax),%eax
  80181e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801823:	ba 00 00 00 00       	mov    $0x0,%edx
  801828:	b8 05 00 00 00       	mov    $0x5,%eax
  80182d:	e8 43 ff ff ff       	call   801775 <fsipc>
  801832:	85 c0                	test   %eax,%eax
  801834:	78 2c                	js     801862 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801836:	83 ec 08             	sub    $0x8,%esp
  801839:	68 00 50 80 00       	push   $0x805000
  80183e:	53                   	push   %ebx
  80183f:	e8 57 f3 ff ff       	call   800b9b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801844:	a1 80 50 80 00       	mov    0x805080,%eax
  801849:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80184f:	a1 84 50 80 00       	mov    0x805084,%eax
  801854:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80185a:	83 c4 10             	add    $0x10,%esp
  80185d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801862:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801865:	c9                   	leave  
  801866:	c3                   	ret    

00801867 <devfile_write>:
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	83 ec 0c             	sub    $0xc,%esp
  80186d:	8b 45 10             	mov    0x10(%ebp),%eax
  801870:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801875:	39 d0                	cmp    %edx,%eax
  801877:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80187a:	8b 55 08             	mov    0x8(%ebp),%edx
  80187d:	8b 52 0c             	mov    0xc(%edx),%edx
  801880:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801886:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80188b:	50                   	push   %eax
  80188c:	ff 75 0c             	push   0xc(%ebp)
  80188f:	68 08 50 80 00       	push   $0x805008
  801894:	e8 98 f4 ff ff       	call   800d31 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801899:	ba 00 00 00 00       	mov    $0x0,%edx
  80189e:	b8 04 00 00 00       	mov    $0x4,%eax
  8018a3:	e8 cd fe ff ff       	call   801775 <fsipc>
}
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    

008018aa <devfile_read>:
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	56                   	push   %esi
  8018ae:	53                   	push   %ebx
  8018af:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018bd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c8:	b8 03 00 00 00       	mov    $0x3,%eax
  8018cd:	e8 a3 fe ff ff       	call   801775 <fsipc>
  8018d2:	89 c3                	mov    %eax,%ebx
  8018d4:	85 c0                	test   %eax,%eax
  8018d6:	78 1f                	js     8018f7 <devfile_read+0x4d>
	assert(r <= n);
  8018d8:	39 f0                	cmp    %esi,%eax
  8018da:	77 24                	ja     801900 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8018dc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018e1:	7f 33                	jg     801916 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018e3:	83 ec 04             	sub    $0x4,%esp
  8018e6:	50                   	push   %eax
  8018e7:	68 00 50 80 00       	push   $0x805000
  8018ec:	ff 75 0c             	push   0xc(%ebp)
  8018ef:	e8 3d f4 ff ff       	call   800d31 <memmove>
	return r;
  8018f4:	83 c4 10             	add    $0x10,%esp
}
  8018f7:	89 d8                	mov    %ebx,%eax
  8018f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fc:	5b                   	pop    %ebx
  8018fd:	5e                   	pop    %esi
  8018fe:	5d                   	pop    %ebp
  8018ff:	c3                   	ret    
	assert(r <= n);
  801900:	68 9c 2b 80 00       	push   $0x802b9c
  801905:	68 a3 2b 80 00       	push   $0x802ba3
  80190a:	6a 7c                	push   $0x7c
  80190c:	68 b8 2b 80 00       	push   $0x802bb8
  801911:	e8 e1 09 00 00       	call   8022f7 <_panic>
	assert(r <= PGSIZE);
  801916:	68 c3 2b 80 00       	push   $0x802bc3
  80191b:	68 a3 2b 80 00       	push   $0x802ba3
  801920:	6a 7d                	push   $0x7d
  801922:	68 b8 2b 80 00       	push   $0x802bb8
  801927:	e8 cb 09 00 00       	call   8022f7 <_panic>

0080192c <open>:
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	56                   	push   %esi
  801930:	53                   	push   %ebx
  801931:	83 ec 1c             	sub    $0x1c,%esp
  801934:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801937:	56                   	push   %esi
  801938:	e8 23 f2 ff ff       	call   800b60 <strlen>
  80193d:	83 c4 10             	add    $0x10,%esp
  801940:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801945:	7f 6c                	jg     8019b3 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801947:	83 ec 0c             	sub    $0xc,%esp
  80194a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194d:	50                   	push   %eax
  80194e:	e8 bd f8 ff ff       	call   801210 <fd_alloc>
  801953:	89 c3                	mov    %eax,%ebx
  801955:	83 c4 10             	add    $0x10,%esp
  801958:	85 c0                	test   %eax,%eax
  80195a:	78 3c                	js     801998 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80195c:	83 ec 08             	sub    $0x8,%esp
  80195f:	56                   	push   %esi
  801960:	68 00 50 80 00       	push   $0x805000
  801965:	e8 31 f2 ff ff       	call   800b9b <strcpy>
	fsipcbuf.open.req_omode = mode;
  80196a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196d:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801972:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801975:	b8 01 00 00 00       	mov    $0x1,%eax
  80197a:	e8 f6 fd ff ff       	call   801775 <fsipc>
  80197f:	89 c3                	mov    %eax,%ebx
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	85 c0                	test   %eax,%eax
  801986:	78 19                	js     8019a1 <open+0x75>
	return fd2num(fd);
  801988:	83 ec 0c             	sub    $0xc,%esp
  80198b:	ff 75 f4             	push   -0xc(%ebp)
  80198e:	e8 56 f8 ff ff       	call   8011e9 <fd2num>
  801993:	89 c3                	mov    %eax,%ebx
  801995:	83 c4 10             	add    $0x10,%esp
}
  801998:	89 d8                	mov    %ebx,%eax
  80199a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199d:	5b                   	pop    %ebx
  80199e:	5e                   	pop    %esi
  80199f:	5d                   	pop    %ebp
  8019a0:	c3                   	ret    
		fd_close(fd, 0);
  8019a1:	83 ec 08             	sub    $0x8,%esp
  8019a4:	6a 00                	push   $0x0
  8019a6:	ff 75 f4             	push   -0xc(%ebp)
  8019a9:	e8 58 f9 ff ff       	call   801306 <fd_close>
		return r;
  8019ae:	83 c4 10             	add    $0x10,%esp
  8019b1:	eb e5                	jmp    801998 <open+0x6c>
		return -E_BAD_PATH;
  8019b3:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019b8:	eb de                	jmp    801998 <open+0x6c>

008019ba <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c5:	b8 08 00 00 00       	mov    $0x8,%eax
  8019ca:	e8 a6 fd ff ff       	call   801775 <fsipc>
}
  8019cf:	c9                   	leave  
  8019d0:	c3                   	ret    

008019d1 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019d1:	55                   	push   %ebp
  8019d2:	89 e5                	mov    %esp,%ebp
  8019d4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019d7:	68 cf 2b 80 00       	push   $0x802bcf
  8019dc:	ff 75 0c             	push   0xc(%ebp)
  8019df:	e8 b7 f1 ff ff       	call   800b9b <strcpy>
	return 0;
}
  8019e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e9:	c9                   	leave  
  8019ea:	c3                   	ret    

008019eb <devsock_close>:
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	53                   	push   %ebx
  8019ef:	83 ec 10             	sub    $0x10,%esp
  8019f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019f5:	53                   	push   %ebx
  8019f6:	e8 36 0a 00 00       	call   802431 <pageref>
  8019fb:	89 c2                	mov    %eax,%edx
  8019fd:	83 c4 10             	add    $0x10,%esp
		return 0;
  801a00:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801a05:	83 fa 01             	cmp    $0x1,%edx
  801a08:	74 05                	je     801a0f <devsock_close+0x24>
}
  801a0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0d:	c9                   	leave  
  801a0e:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801a0f:	83 ec 0c             	sub    $0xc,%esp
  801a12:	ff 73 0c             	push   0xc(%ebx)
  801a15:	e8 b7 02 00 00       	call   801cd1 <nsipc_close>
  801a1a:	83 c4 10             	add    $0x10,%esp
  801a1d:	eb eb                	jmp    801a0a <devsock_close+0x1f>

00801a1f <devsock_write>:
{
  801a1f:	55                   	push   %ebp
  801a20:	89 e5                	mov    %esp,%ebp
  801a22:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a25:	6a 00                	push   $0x0
  801a27:	ff 75 10             	push   0x10(%ebp)
  801a2a:	ff 75 0c             	push   0xc(%ebp)
  801a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a30:	ff 70 0c             	push   0xc(%eax)
  801a33:	e8 79 03 00 00       	call   801db1 <nsipc_send>
}
  801a38:	c9                   	leave  
  801a39:	c3                   	ret    

00801a3a <devsock_read>:
{
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a40:	6a 00                	push   $0x0
  801a42:	ff 75 10             	push   0x10(%ebp)
  801a45:	ff 75 0c             	push   0xc(%ebp)
  801a48:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4b:	ff 70 0c             	push   0xc(%eax)
  801a4e:	e8 ef 02 00 00       	call   801d42 <nsipc_recv>
}
  801a53:	c9                   	leave  
  801a54:	c3                   	ret    

00801a55 <fd2sockid>:
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a5b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a5e:	52                   	push   %edx
  801a5f:	50                   	push   %eax
  801a60:	e8 fb f7 ff ff       	call   801260 <fd_lookup>
  801a65:	83 c4 10             	add    $0x10,%esp
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	78 10                	js     801a7c <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6f:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  801a75:	39 08                	cmp    %ecx,(%eax)
  801a77:	75 05                	jne    801a7e <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801a79:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801a7c:	c9                   	leave  
  801a7d:	c3                   	ret    
		return -E_NOT_SUPP;
  801a7e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a83:	eb f7                	jmp    801a7c <fd2sockid+0x27>

00801a85 <alloc_sockfd>:
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
  801a88:	56                   	push   %esi
  801a89:	53                   	push   %ebx
  801a8a:	83 ec 1c             	sub    $0x1c,%esp
  801a8d:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801a8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a92:	50                   	push   %eax
  801a93:	e8 78 f7 ff ff       	call   801210 <fd_alloc>
  801a98:	89 c3                	mov    %eax,%ebx
  801a9a:	83 c4 10             	add    $0x10,%esp
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	78 43                	js     801ae4 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801aa1:	83 ec 04             	sub    $0x4,%esp
  801aa4:	68 07 04 00 00       	push   $0x407
  801aa9:	ff 75 f4             	push   -0xc(%ebp)
  801aac:	6a 00                	push   $0x0
  801aae:	e8 e4 f4 ff ff       	call   800f97 <sys_page_alloc>
  801ab3:	89 c3                	mov    %eax,%ebx
  801ab5:	83 c4 10             	add    $0x10,%esp
  801ab8:	85 c0                	test   %eax,%eax
  801aba:	78 28                	js     801ae4 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abf:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801ac5:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aca:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ad1:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ad4:	83 ec 0c             	sub    $0xc,%esp
  801ad7:	50                   	push   %eax
  801ad8:	e8 0c f7 ff ff       	call   8011e9 <fd2num>
  801add:	89 c3                	mov    %eax,%ebx
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	eb 0c                	jmp    801af0 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801ae4:	83 ec 0c             	sub    $0xc,%esp
  801ae7:	56                   	push   %esi
  801ae8:	e8 e4 01 00 00       	call   801cd1 <nsipc_close>
		return r;
  801aed:	83 c4 10             	add    $0x10,%esp
}
  801af0:	89 d8                	mov    %ebx,%eax
  801af2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af5:	5b                   	pop    %ebx
  801af6:	5e                   	pop    %esi
  801af7:	5d                   	pop    %ebp
  801af8:	c3                   	ret    

00801af9 <accept>:
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801aff:	8b 45 08             	mov    0x8(%ebp),%eax
  801b02:	e8 4e ff ff ff       	call   801a55 <fd2sockid>
  801b07:	85 c0                	test   %eax,%eax
  801b09:	78 1b                	js     801b26 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b0b:	83 ec 04             	sub    $0x4,%esp
  801b0e:	ff 75 10             	push   0x10(%ebp)
  801b11:	ff 75 0c             	push   0xc(%ebp)
  801b14:	50                   	push   %eax
  801b15:	e8 0e 01 00 00       	call   801c28 <nsipc_accept>
  801b1a:	83 c4 10             	add    $0x10,%esp
  801b1d:	85 c0                	test   %eax,%eax
  801b1f:	78 05                	js     801b26 <accept+0x2d>
	return alloc_sockfd(r);
  801b21:	e8 5f ff ff ff       	call   801a85 <alloc_sockfd>
}
  801b26:	c9                   	leave  
  801b27:	c3                   	ret    

00801b28 <bind>:
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b31:	e8 1f ff ff ff       	call   801a55 <fd2sockid>
  801b36:	85 c0                	test   %eax,%eax
  801b38:	78 12                	js     801b4c <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801b3a:	83 ec 04             	sub    $0x4,%esp
  801b3d:	ff 75 10             	push   0x10(%ebp)
  801b40:	ff 75 0c             	push   0xc(%ebp)
  801b43:	50                   	push   %eax
  801b44:	e8 31 01 00 00       	call   801c7a <nsipc_bind>
  801b49:	83 c4 10             	add    $0x10,%esp
}
  801b4c:	c9                   	leave  
  801b4d:	c3                   	ret    

00801b4e <shutdown>:
{
  801b4e:	55                   	push   %ebp
  801b4f:	89 e5                	mov    %esp,%ebp
  801b51:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b54:	8b 45 08             	mov    0x8(%ebp),%eax
  801b57:	e8 f9 fe ff ff       	call   801a55 <fd2sockid>
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	78 0f                	js     801b6f <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801b60:	83 ec 08             	sub    $0x8,%esp
  801b63:	ff 75 0c             	push   0xc(%ebp)
  801b66:	50                   	push   %eax
  801b67:	e8 43 01 00 00       	call   801caf <nsipc_shutdown>
  801b6c:	83 c4 10             	add    $0x10,%esp
}
  801b6f:	c9                   	leave  
  801b70:	c3                   	ret    

00801b71 <connect>:
{
  801b71:	55                   	push   %ebp
  801b72:	89 e5                	mov    %esp,%ebp
  801b74:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b77:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7a:	e8 d6 fe ff ff       	call   801a55 <fd2sockid>
  801b7f:	85 c0                	test   %eax,%eax
  801b81:	78 12                	js     801b95 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801b83:	83 ec 04             	sub    $0x4,%esp
  801b86:	ff 75 10             	push   0x10(%ebp)
  801b89:	ff 75 0c             	push   0xc(%ebp)
  801b8c:	50                   	push   %eax
  801b8d:	e8 59 01 00 00       	call   801ceb <nsipc_connect>
  801b92:	83 c4 10             	add    $0x10,%esp
}
  801b95:	c9                   	leave  
  801b96:	c3                   	ret    

00801b97 <listen>:
{
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba0:	e8 b0 fe ff ff       	call   801a55 <fd2sockid>
  801ba5:	85 c0                	test   %eax,%eax
  801ba7:	78 0f                	js     801bb8 <listen+0x21>
	return nsipc_listen(r, backlog);
  801ba9:	83 ec 08             	sub    $0x8,%esp
  801bac:	ff 75 0c             	push   0xc(%ebp)
  801baf:	50                   	push   %eax
  801bb0:	e8 6b 01 00 00       	call   801d20 <nsipc_listen>
  801bb5:	83 c4 10             	add    $0x10,%esp
}
  801bb8:	c9                   	leave  
  801bb9:	c3                   	ret    

00801bba <socket>:

int
socket(int domain, int type, int protocol)
{
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bc0:	ff 75 10             	push   0x10(%ebp)
  801bc3:	ff 75 0c             	push   0xc(%ebp)
  801bc6:	ff 75 08             	push   0x8(%ebp)
  801bc9:	e8 41 02 00 00       	call   801e0f <nsipc_socket>
  801bce:	83 c4 10             	add    $0x10,%esp
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	78 05                	js     801bda <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bd5:	e8 ab fe ff ff       	call   801a85 <alloc_sockfd>
}
  801bda:	c9                   	leave  
  801bdb:	c3                   	ret    

00801bdc <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bdc:	55                   	push   %ebp
  801bdd:	89 e5                	mov    %esp,%ebp
  801bdf:	53                   	push   %ebx
  801be0:	83 ec 04             	sub    $0x4,%esp
  801be3:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801be5:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801bec:	74 26                	je     801c14 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bee:	6a 07                	push   $0x7
  801bf0:	68 00 70 80 00       	push   $0x807000
  801bf5:	53                   	push   %ebx
  801bf6:	ff 35 00 80 80 00    	push   0x808000
  801bfc:	e8 a3 07 00 00       	call   8023a4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c01:	83 c4 0c             	add    $0xc,%esp
  801c04:	6a 00                	push   $0x0
  801c06:	6a 00                	push   $0x0
  801c08:	6a 00                	push   $0x0
  801c0a:	e8 2e 07 00 00       	call   80233d <ipc_recv>
}
  801c0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c12:	c9                   	leave  
  801c13:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c14:	83 ec 0c             	sub    $0xc,%esp
  801c17:	6a 02                	push   $0x2
  801c19:	e8 da 07 00 00       	call   8023f8 <ipc_find_env>
  801c1e:	a3 00 80 80 00       	mov    %eax,0x808000
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	eb c6                	jmp    801bee <nsipc+0x12>

00801c28 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	56                   	push   %esi
  801c2c:	53                   	push   %ebx
  801c2d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c30:	8b 45 08             	mov    0x8(%ebp),%eax
  801c33:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c38:	8b 06                	mov    (%esi),%eax
  801c3a:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c3f:	b8 01 00 00 00       	mov    $0x1,%eax
  801c44:	e8 93 ff ff ff       	call   801bdc <nsipc>
  801c49:	89 c3                	mov    %eax,%ebx
  801c4b:	85 c0                	test   %eax,%eax
  801c4d:	79 09                	jns    801c58 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801c4f:	89 d8                	mov    %ebx,%eax
  801c51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c54:	5b                   	pop    %ebx
  801c55:	5e                   	pop    %esi
  801c56:	5d                   	pop    %ebp
  801c57:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c58:	83 ec 04             	sub    $0x4,%esp
  801c5b:	ff 35 10 70 80 00    	push   0x807010
  801c61:	68 00 70 80 00       	push   $0x807000
  801c66:	ff 75 0c             	push   0xc(%ebp)
  801c69:	e8 c3 f0 ff ff       	call   800d31 <memmove>
		*addrlen = ret->ret_addrlen;
  801c6e:	a1 10 70 80 00       	mov    0x807010,%eax
  801c73:	89 06                	mov    %eax,(%esi)
  801c75:	83 c4 10             	add    $0x10,%esp
	return r;
  801c78:	eb d5                	jmp    801c4f <nsipc_accept+0x27>

00801c7a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	53                   	push   %ebx
  801c7e:	83 ec 08             	sub    $0x8,%esp
  801c81:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c84:	8b 45 08             	mov    0x8(%ebp),%eax
  801c87:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c8c:	53                   	push   %ebx
  801c8d:	ff 75 0c             	push   0xc(%ebp)
  801c90:	68 04 70 80 00       	push   $0x807004
  801c95:	e8 97 f0 ff ff       	call   800d31 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c9a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801ca0:	b8 02 00 00 00       	mov    $0x2,%eax
  801ca5:	e8 32 ff ff ff       	call   801bdc <nsipc>
}
  801caa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cad:	c9                   	leave  
  801cae:	c3                   	ret    

00801caf <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801cbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc0:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801cc5:	b8 03 00 00 00       	mov    $0x3,%eax
  801cca:	e8 0d ff ff ff       	call   801bdc <nsipc>
}
  801ccf:	c9                   	leave  
  801cd0:	c3                   	ret    

00801cd1 <nsipc_close>:

int
nsipc_close(int s)
{
  801cd1:	55                   	push   %ebp
  801cd2:	89 e5                	mov    %esp,%ebp
  801cd4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cda:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801cdf:	b8 04 00 00 00       	mov    $0x4,%eax
  801ce4:	e8 f3 fe ff ff       	call   801bdc <nsipc>
}
  801ce9:	c9                   	leave  
  801cea:	c3                   	ret    

00801ceb <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	53                   	push   %ebx
  801cef:	83 ec 08             	sub    $0x8,%esp
  801cf2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf8:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cfd:	53                   	push   %ebx
  801cfe:	ff 75 0c             	push   0xc(%ebp)
  801d01:	68 04 70 80 00       	push   $0x807004
  801d06:	e8 26 f0 ff ff       	call   800d31 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d0b:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801d11:	b8 05 00 00 00       	mov    $0x5,%eax
  801d16:	e8 c1 fe ff ff       	call   801bdc <nsipc>
}
  801d1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d1e:	c9                   	leave  
  801d1f:	c3                   	ret    

00801d20 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d26:	8b 45 08             	mov    0x8(%ebp),%eax
  801d29:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d31:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801d36:	b8 06 00 00 00       	mov    $0x6,%eax
  801d3b:	e8 9c fe ff ff       	call   801bdc <nsipc>
}
  801d40:	c9                   	leave  
  801d41:	c3                   	ret    

00801d42 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
  801d45:	56                   	push   %esi
  801d46:	53                   	push   %ebx
  801d47:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801d52:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801d58:	8b 45 14             	mov    0x14(%ebp),%eax
  801d5b:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d60:	b8 07 00 00 00       	mov    $0x7,%eax
  801d65:	e8 72 fe ff ff       	call   801bdc <nsipc>
  801d6a:	89 c3                	mov    %eax,%ebx
  801d6c:	85 c0                	test   %eax,%eax
  801d6e:	78 22                	js     801d92 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801d70:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801d75:	39 c6                	cmp    %eax,%esi
  801d77:	0f 4e c6             	cmovle %esi,%eax
  801d7a:	39 c3                	cmp    %eax,%ebx
  801d7c:	7f 1d                	jg     801d9b <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d7e:	83 ec 04             	sub    $0x4,%esp
  801d81:	53                   	push   %ebx
  801d82:	68 00 70 80 00       	push   $0x807000
  801d87:	ff 75 0c             	push   0xc(%ebp)
  801d8a:	e8 a2 ef ff ff       	call   800d31 <memmove>
  801d8f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d92:	89 d8                	mov    %ebx,%eax
  801d94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d97:	5b                   	pop    %ebx
  801d98:	5e                   	pop    %esi
  801d99:	5d                   	pop    %ebp
  801d9a:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801d9b:	68 db 2b 80 00       	push   $0x802bdb
  801da0:	68 a3 2b 80 00       	push   $0x802ba3
  801da5:	6a 62                	push   $0x62
  801da7:	68 f0 2b 80 00       	push   $0x802bf0
  801dac:	e8 46 05 00 00       	call   8022f7 <_panic>

00801db1 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
  801db4:	53                   	push   %ebx
  801db5:	83 ec 04             	sub    $0x4,%esp
  801db8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbe:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801dc3:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dc9:	7f 2e                	jg     801df9 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801dcb:	83 ec 04             	sub    $0x4,%esp
  801dce:	53                   	push   %ebx
  801dcf:	ff 75 0c             	push   0xc(%ebp)
  801dd2:	68 0c 70 80 00       	push   $0x80700c
  801dd7:	e8 55 ef ff ff       	call   800d31 <memmove>
	nsipcbuf.send.req_size = size;
  801ddc:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801de2:	8b 45 14             	mov    0x14(%ebp),%eax
  801de5:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801dea:	b8 08 00 00 00       	mov    $0x8,%eax
  801def:	e8 e8 fd ff ff       	call   801bdc <nsipc>
}
  801df4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801df7:	c9                   	leave  
  801df8:	c3                   	ret    
	assert(size < 1600);
  801df9:	68 fc 2b 80 00       	push   $0x802bfc
  801dfe:	68 a3 2b 80 00       	push   $0x802ba3
  801e03:	6a 6d                	push   $0x6d
  801e05:	68 f0 2b 80 00       	push   $0x802bf0
  801e0a:	e8 e8 04 00 00       	call   8022f7 <_panic>

00801e0f <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e15:	8b 45 08             	mov    0x8(%ebp),%eax
  801e18:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801e1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e20:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801e25:	8b 45 10             	mov    0x10(%ebp),%eax
  801e28:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801e2d:	b8 09 00 00 00       	mov    $0x9,%eax
  801e32:	e8 a5 fd ff ff       	call   801bdc <nsipc>
}
  801e37:	c9                   	leave  
  801e38:	c3                   	ret    

00801e39 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e39:	55                   	push   %ebp
  801e3a:	89 e5                	mov    %esp,%ebp
  801e3c:	56                   	push   %esi
  801e3d:	53                   	push   %ebx
  801e3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e41:	83 ec 0c             	sub    $0xc,%esp
  801e44:	ff 75 08             	push   0x8(%ebp)
  801e47:	e8 ad f3 ff ff       	call   8011f9 <fd2data>
  801e4c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e4e:	83 c4 08             	add    $0x8,%esp
  801e51:	68 08 2c 80 00       	push   $0x802c08
  801e56:	53                   	push   %ebx
  801e57:	e8 3f ed ff ff       	call   800b9b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e5c:	8b 46 04             	mov    0x4(%esi),%eax
  801e5f:	2b 06                	sub    (%esi),%eax
  801e61:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e67:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e6e:	00 00 00 
	stat->st_dev = &devpipe;
  801e71:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801e78:	30 80 00 
	return 0;
}
  801e7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e83:	5b                   	pop    %ebx
  801e84:	5e                   	pop    %esi
  801e85:	5d                   	pop    %ebp
  801e86:	c3                   	ret    

00801e87 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	53                   	push   %ebx
  801e8b:	83 ec 0c             	sub    $0xc,%esp
  801e8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e91:	53                   	push   %ebx
  801e92:	6a 00                	push   $0x0
  801e94:	e8 83 f1 ff ff       	call   80101c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e99:	89 1c 24             	mov    %ebx,(%esp)
  801e9c:	e8 58 f3 ff ff       	call   8011f9 <fd2data>
  801ea1:	83 c4 08             	add    $0x8,%esp
  801ea4:	50                   	push   %eax
  801ea5:	6a 00                	push   $0x0
  801ea7:	e8 70 f1 ff ff       	call   80101c <sys_page_unmap>
}
  801eac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eaf:	c9                   	leave  
  801eb0:	c3                   	ret    

00801eb1 <_pipeisclosed>:
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	57                   	push   %edi
  801eb5:	56                   	push   %esi
  801eb6:	53                   	push   %ebx
  801eb7:	83 ec 1c             	sub    $0x1c,%esp
  801eba:	89 c7                	mov    %eax,%edi
  801ebc:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801ebe:	a1 10 40 80 00       	mov    0x804010,%eax
  801ec3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ec6:	83 ec 0c             	sub    $0xc,%esp
  801ec9:	57                   	push   %edi
  801eca:	e8 62 05 00 00       	call   802431 <pageref>
  801ecf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ed2:	89 34 24             	mov    %esi,(%esp)
  801ed5:	e8 57 05 00 00       	call   802431 <pageref>
		nn = thisenv->env_runs;
  801eda:	8b 15 10 40 80 00    	mov    0x804010,%edx
  801ee0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ee3:	83 c4 10             	add    $0x10,%esp
  801ee6:	39 cb                	cmp    %ecx,%ebx
  801ee8:	74 1b                	je     801f05 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801eea:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801eed:	75 cf                	jne    801ebe <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801eef:	8b 42 58             	mov    0x58(%edx),%eax
  801ef2:	6a 01                	push   $0x1
  801ef4:	50                   	push   %eax
  801ef5:	53                   	push   %ebx
  801ef6:	68 0f 2c 80 00       	push   $0x802c0f
  801efb:	e8 c1 e6 ff ff       	call   8005c1 <cprintf>
  801f00:	83 c4 10             	add    $0x10,%esp
  801f03:	eb b9                	jmp    801ebe <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801f05:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f08:	0f 94 c0             	sete   %al
  801f0b:	0f b6 c0             	movzbl %al,%eax
}
  801f0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f11:	5b                   	pop    %ebx
  801f12:	5e                   	pop    %esi
  801f13:	5f                   	pop    %edi
  801f14:	5d                   	pop    %ebp
  801f15:	c3                   	ret    

00801f16 <devpipe_write>:
{
  801f16:	55                   	push   %ebp
  801f17:	89 e5                	mov    %esp,%ebp
  801f19:	57                   	push   %edi
  801f1a:	56                   	push   %esi
  801f1b:	53                   	push   %ebx
  801f1c:	83 ec 28             	sub    $0x28,%esp
  801f1f:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801f22:	56                   	push   %esi
  801f23:	e8 d1 f2 ff ff       	call   8011f9 <fd2data>
  801f28:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f2a:	83 c4 10             	add    $0x10,%esp
  801f2d:	bf 00 00 00 00       	mov    $0x0,%edi
  801f32:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f35:	75 09                	jne    801f40 <devpipe_write+0x2a>
	return i;
  801f37:	89 f8                	mov    %edi,%eax
  801f39:	eb 23                	jmp    801f5e <devpipe_write+0x48>
			sys_yield();
  801f3b:	e8 38 f0 ff ff       	call   800f78 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f40:	8b 43 04             	mov    0x4(%ebx),%eax
  801f43:	8b 0b                	mov    (%ebx),%ecx
  801f45:	8d 51 20             	lea    0x20(%ecx),%edx
  801f48:	39 d0                	cmp    %edx,%eax
  801f4a:	72 1a                	jb     801f66 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801f4c:	89 da                	mov    %ebx,%edx
  801f4e:	89 f0                	mov    %esi,%eax
  801f50:	e8 5c ff ff ff       	call   801eb1 <_pipeisclosed>
  801f55:	85 c0                	test   %eax,%eax
  801f57:	74 e2                	je     801f3b <devpipe_write+0x25>
				return 0;
  801f59:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f61:	5b                   	pop    %ebx
  801f62:	5e                   	pop    %esi
  801f63:	5f                   	pop    %edi
  801f64:	5d                   	pop    %ebp
  801f65:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f69:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f6d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f70:	89 c2                	mov    %eax,%edx
  801f72:	c1 fa 1f             	sar    $0x1f,%edx
  801f75:	89 d1                	mov    %edx,%ecx
  801f77:	c1 e9 1b             	shr    $0x1b,%ecx
  801f7a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f7d:	83 e2 1f             	and    $0x1f,%edx
  801f80:	29 ca                	sub    %ecx,%edx
  801f82:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f86:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f8a:	83 c0 01             	add    $0x1,%eax
  801f8d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801f90:	83 c7 01             	add    $0x1,%edi
  801f93:	eb 9d                	jmp    801f32 <devpipe_write+0x1c>

00801f95 <devpipe_read>:
{
  801f95:	55                   	push   %ebp
  801f96:	89 e5                	mov    %esp,%ebp
  801f98:	57                   	push   %edi
  801f99:	56                   	push   %esi
  801f9a:	53                   	push   %ebx
  801f9b:	83 ec 18             	sub    $0x18,%esp
  801f9e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801fa1:	57                   	push   %edi
  801fa2:	e8 52 f2 ff ff       	call   8011f9 <fd2data>
  801fa7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801fa9:	83 c4 10             	add    $0x10,%esp
  801fac:	be 00 00 00 00       	mov    $0x0,%esi
  801fb1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fb4:	75 13                	jne    801fc9 <devpipe_read+0x34>
	return i;
  801fb6:	89 f0                	mov    %esi,%eax
  801fb8:	eb 02                	jmp    801fbc <devpipe_read+0x27>
				return i;
  801fba:	89 f0                	mov    %esi,%eax
}
  801fbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fbf:	5b                   	pop    %ebx
  801fc0:	5e                   	pop    %esi
  801fc1:	5f                   	pop    %edi
  801fc2:	5d                   	pop    %ebp
  801fc3:	c3                   	ret    
			sys_yield();
  801fc4:	e8 af ef ff ff       	call   800f78 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801fc9:	8b 03                	mov    (%ebx),%eax
  801fcb:	3b 43 04             	cmp    0x4(%ebx),%eax
  801fce:	75 18                	jne    801fe8 <devpipe_read+0x53>
			if (i > 0)
  801fd0:	85 f6                	test   %esi,%esi
  801fd2:	75 e6                	jne    801fba <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801fd4:	89 da                	mov    %ebx,%edx
  801fd6:	89 f8                	mov    %edi,%eax
  801fd8:	e8 d4 fe ff ff       	call   801eb1 <_pipeisclosed>
  801fdd:	85 c0                	test   %eax,%eax
  801fdf:	74 e3                	je     801fc4 <devpipe_read+0x2f>
				return 0;
  801fe1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe6:	eb d4                	jmp    801fbc <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fe8:	99                   	cltd   
  801fe9:	c1 ea 1b             	shr    $0x1b,%edx
  801fec:	01 d0                	add    %edx,%eax
  801fee:	83 e0 1f             	and    $0x1f,%eax
  801ff1:	29 d0                	sub    %edx,%eax
  801ff3:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ff8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ffb:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ffe:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802001:	83 c6 01             	add    $0x1,%esi
  802004:	eb ab                	jmp    801fb1 <devpipe_read+0x1c>

00802006 <pipe>:
{
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	56                   	push   %esi
  80200a:	53                   	push   %ebx
  80200b:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80200e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802011:	50                   	push   %eax
  802012:	e8 f9 f1 ff ff       	call   801210 <fd_alloc>
  802017:	89 c3                	mov    %eax,%ebx
  802019:	83 c4 10             	add    $0x10,%esp
  80201c:	85 c0                	test   %eax,%eax
  80201e:	0f 88 23 01 00 00    	js     802147 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802024:	83 ec 04             	sub    $0x4,%esp
  802027:	68 07 04 00 00       	push   $0x407
  80202c:	ff 75 f4             	push   -0xc(%ebp)
  80202f:	6a 00                	push   $0x0
  802031:	e8 61 ef ff ff       	call   800f97 <sys_page_alloc>
  802036:	89 c3                	mov    %eax,%ebx
  802038:	83 c4 10             	add    $0x10,%esp
  80203b:	85 c0                	test   %eax,%eax
  80203d:	0f 88 04 01 00 00    	js     802147 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802043:	83 ec 0c             	sub    $0xc,%esp
  802046:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802049:	50                   	push   %eax
  80204a:	e8 c1 f1 ff ff       	call   801210 <fd_alloc>
  80204f:	89 c3                	mov    %eax,%ebx
  802051:	83 c4 10             	add    $0x10,%esp
  802054:	85 c0                	test   %eax,%eax
  802056:	0f 88 db 00 00 00    	js     802137 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80205c:	83 ec 04             	sub    $0x4,%esp
  80205f:	68 07 04 00 00       	push   $0x407
  802064:	ff 75 f0             	push   -0x10(%ebp)
  802067:	6a 00                	push   $0x0
  802069:	e8 29 ef ff ff       	call   800f97 <sys_page_alloc>
  80206e:	89 c3                	mov    %eax,%ebx
  802070:	83 c4 10             	add    $0x10,%esp
  802073:	85 c0                	test   %eax,%eax
  802075:	0f 88 bc 00 00 00    	js     802137 <pipe+0x131>
	va = fd2data(fd0);
  80207b:	83 ec 0c             	sub    $0xc,%esp
  80207e:	ff 75 f4             	push   -0xc(%ebp)
  802081:	e8 73 f1 ff ff       	call   8011f9 <fd2data>
  802086:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802088:	83 c4 0c             	add    $0xc,%esp
  80208b:	68 07 04 00 00       	push   $0x407
  802090:	50                   	push   %eax
  802091:	6a 00                	push   $0x0
  802093:	e8 ff ee ff ff       	call   800f97 <sys_page_alloc>
  802098:	89 c3                	mov    %eax,%ebx
  80209a:	83 c4 10             	add    $0x10,%esp
  80209d:	85 c0                	test   %eax,%eax
  80209f:	0f 88 82 00 00 00    	js     802127 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020a5:	83 ec 0c             	sub    $0xc,%esp
  8020a8:	ff 75 f0             	push   -0x10(%ebp)
  8020ab:	e8 49 f1 ff ff       	call   8011f9 <fd2data>
  8020b0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020b7:	50                   	push   %eax
  8020b8:	6a 00                	push   $0x0
  8020ba:	56                   	push   %esi
  8020bb:	6a 00                	push   $0x0
  8020bd:	e8 18 ef ff ff       	call   800fda <sys_page_map>
  8020c2:	89 c3                	mov    %eax,%ebx
  8020c4:	83 c4 20             	add    $0x20,%esp
  8020c7:	85 c0                	test   %eax,%eax
  8020c9:	78 4e                	js     802119 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8020cb:	a1 40 30 80 00       	mov    0x803040,%eax
  8020d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020d3:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8020d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020d8:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8020df:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020e2:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8020e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020e7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8020ee:	83 ec 0c             	sub    $0xc,%esp
  8020f1:	ff 75 f4             	push   -0xc(%ebp)
  8020f4:	e8 f0 f0 ff ff       	call   8011e9 <fd2num>
  8020f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020fc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020fe:	83 c4 04             	add    $0x4,%esp
  802101:	ff 75 f0             	push   -0x10(%ebp)
  802104:	e8 e0 f0 ff ff       	call   8011e9 <fd2num>
  802109:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80210c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80210f:	83 c4 10             	add    $0x10,%esp
  802112:	bb 00 00 00 00       	mov    $0x0,%ebx
  802117:	eb 2e                	jmp    802147 <pipe+0x141>
	sys_page_unmap(0, va);
  802119:	83 ec 08             	sub    $0x8,%esp
  80211c:	56                   	push   %esi
  80211d:	6a 00                	push   $0x0
  80211f:	e8 f8 ee ff ff       	call   80101c <sys_page_unmap>
  802124:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802127:	83 ec 08             	sub    $0x8,%esp
  80212a:	ff 75 f0             	push   -0x10(%ebp)
  80212d:	6a 00                	push   $0x0
  80212f:	e8 e8 ee ff ff       	call   80101c <sys_page_unmap>
  802134:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802137:	83 ec 08             	sub    $0x8,%esp
  80213a:	ff 75 f4             	push   -0xc(%ebp)
  80213d:	6a 00                	push   $0x0
  80213f:	e8 d8 ee ff ff       	call   80101c <sys_page_unmap>
  802144:	83 c4 10             	add    $0x10,%esp
}
  802147:	89 d8                	mov    %ebx,%eax
  802149:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80214c:	5b                   	pop    %ebx
  80214d:	5e                   	pop    %esi
  80214e:	5d                   	pop    %ebp
  80214f:	c3                   	ret    

00802150 <pipeisclosed>:
{
  802150:	55                   	push   %ebp
  802151:	89 e5                	mov    %esp,%ebp
  802153:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802156:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802159:	50                   	push   %eax
  80215a:	ff 75 08             	push   0x8(%ebp)
  80215d:	e8 fe f0 ff ff       	call   801260 <fd_lookup>
  802162:	83 c4 10             	add    $0x10,%esp
  802165:	85 c0                	test   %eax,%eax
  802167:	78 18                	js     802181 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802169:	83 ec 0c             	sub    $0xc,%esp
  80216c:	ff 75 f4             	push   -0xc(%ebp)
  80216f:	e8 85 f0 ff ff       	call   8011f9 <fd2data>
  802174:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802176:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802179:	e8 33 fd ff ff       	call   801eb1 <_pipeisclosed>
  80217e:	83 c4 10             	add    $0x10,%esp
}
  802181:	c9                   	leave  
  802182:	c3                   	ret    

00802183 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802183:	b8 00 00 00 00       	mov    $0x0,%eax
  802188:	c3                   	ret    

00802189 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802189:	55                   	push   %ebp
  80218a:	89 e5                	mov    %esp,%ebp
  80218c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80218f:	68 27 2c 80 00       	push   $0x802c27
  802194:	ff 75 0c             	push   0xc(%ebp)
  802197:	e8 ff e9 ff ff       	call   800b9b <strcpy>
	return 0;
}
  80219c:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a1:	c9                   	leave  
  8021a2:	c3                   	ret    

008021a3 <devcons_write>:
{
  8021a3:	55                   	push   %ebp
  8021a4:	89 e5                	mov    %esp,%ebp
  8021a6:	57                   	push   %edi
  8021a7:	56                   	push   %esi
  8021a8:	53                   	push   %ebx
  8021a9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8021af:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8021b4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8021ba:	eb 2e                	jmp    8021ea <devcons_write+0x47>
		m = n - tot;
  8021bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021bf:	29 f3                	sub    %esi,%ebx
  8021c1:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8021c6:	39 c3                	cmp    %eax,%ebx
  8021c8:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8021cb:	83 ec 04             	sub    $0x4,%esp
  8021ce:	53                   	push   %ebx
  8021cf:	89 f0                	mov    %esi,%eax
  8021d1:	03 45 0c             	add    0xc(%ebp),%eax
  8021d4:	50                   	push   %eax
  8021d5:	57                   	push   %edi
  8021d6:	e8 56 eb ff ff       	call   800d31 <memmove>
		sys_cputs(buf, m);
  8021db:	83 c4 08             	add    $0x8,%esp
  8021de:	53                   	push   %ebx
  8021df:	57                   	push   %edi
  8021e0:	e8 f6 ec ff ff       	call   800edb <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8021e5:	01 de                	add    %ebx,%esi
  8021e7:	83 c4 10             	add    $0x10,%esp
  8021ea:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021ed:	72 cd                	jb     8021bc <devcons_write+0x19>
}
  8021ef:	89 f0                	mov    %esi,%eax
  8021f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021f4:	5b                   	pop    %ebx
  8021f5:	5e                   	pop    %esi
  8021f6:	5f                   	pop    %edi
  8021f7:	5d                   	pop    %ebp
  8021f8:	c3                   	ret    

008021f9 <devcons_read>:
{
  8021f9:	55                   	push   %ebp
  8021fa:	89 e5                	mov    %esp,%ebp
  8021fc:	83 ec 08             	sub    $0x8,%esp
  8021ff:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802204:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802208:	75 07                	jne    802211 <devcons_read+0x18>
  80220a:	eb 1f                	jmp    80222b <devcons_read+0x32>
		sys_yield();
  80220c:	e8 67 ed ff ff       	call   800f78 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802211:	e8 e3 ec ff ff       	call   800ef9 <sys_cgetc>
  802216:	85 c0                	test   %eax,%eax
  802218:	74 f2                	je     80220c <devcons_read+0x13>
	if (c < 0)
  80221a:	78 0f                	js     80222b <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  80221c:	83 f8 04             	cmp    $0x4,%eax
  80221f:	74 0c                	je     80222d <devcons_read+0x34>
	*(char*)vbuf = c;
  802221:	8b 55 0c             	mov    0xc(%ebp),%edx
  802224:	88 02                	mov    %al,(%edx)
	return 1;
  802226:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80222b:	c9                   	leave  
  80222c:	c3                   	ret    
		return 0;
  80222d:	b8 00 00 00 00       	mov    $0x0,%eax
  802232:	eb f7                	jmp    80222b <devcons_read+0x32>

00802234 <cputchar>:
{
  802234:	55                   	push   %ebp
  802235:	89 e5                	mov    %esp,%ebp
  802237:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80223a:	8b 45 08             	mov    0x8(%ebp),%eax
  80223d:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802240:	6a 01                	push   $0x1
  802242:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802245:	50                   	push   %eax
  802246:	e8 90 ec ff ff       	call   800edb <sys_cputs>
}
  80224b:	83 c4 10             	add    $0x10,%esp
  80224e:	c9                   	leave  
  80224f:	c3                   	ret    

00802250 <getchar>:
{
  802250:	55                   	push   %ebp
  802251:	89 e5                	mov    %esp,%ebp
  802253:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802256:	6a 01                	push   $0x1
  802258:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80225b:	50                   	push   %eax
  80225c:	6a 00                	push   $0x0
  80225e:	e8 66 f2 ff ff       	call   8014c9 <read>
	if (r < 0)
  802263:	83 c4 10             	add    $0x10,%esp
  802266:	85 c0                	test   %eax,%eax
  802268:	78 06                	js     802270 <getchar+0x20>
	if (r < 1)
  80226a:	74 06                	je     802272 <getchar+0x22>
	return c;
  80226c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802270:	c9                   	leave  
  802271:	c3                   	ret    
		return -E_EOF;
  802272:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802277:	eb f7                	jmp    802270 <getchar+0x20>

00802279 <iscons>:
{
  802279:	55                   	push   %ebp
  80227a:	89 e5                	mov    %esp,%ebp
  80227c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80227f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802282:	50                   	push   %eax
  802283:	ff 75 08             	push   0x8(%ebp)
  802286:	e8 d5 ef ff ff       	call   801260 <fd_lookup>
  80228b:	83 c4 10             	add    $0x10,%esp
  80228e:	85 c0                	test   %eax,%eax
  802290:	78 11                	js     8022a3 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802292:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802295:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  80229b:	39 10                	cmp    %edx,(%eax)
  80229d:	0f 94 c0             	sete   %al
  8022a0:	0f b6 c0             	movzbl %al,%eax
}
  8022a3:	c9                   	leave  
  8022a4:	c3                   	ret    

008022a5 <opencons>:
{
  8022a5:	55                   	push   %ebp
  8022a6:	89 e5                	mov    %esp,%ebp
  8022a8:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8022ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022ae:	50                   	push   %eax
  8022af:	e8 5c ef ff ff       	call   801210 <fd_alloc>
  8022b4:	83 c4 10             	add    $0x10,%esp
  8022b7:	85 c0                	test   %eax,%eax
  8022b9:	78 3a                	js     8022f5 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022bb:	83 ec 04             	sub    $0x4,%esp
  8022be:	68 07 04 00 00       	push   $0x407
  8022c3:	ff 75 f4             	push   -0xc(%ebp)
  8022c6:	6a 00                	push   $0x0
  8022c8:	e8 ca ec ff ff       	call   800f97 <sys_page_alloc>
  8022cd:	83 c4 10             	add    $0x10,%esp
  8022d0:	85 c0                	test   %eax,%eax
  8022d2:	78 21                	js     8022f5 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8022d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d7:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8022dd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022e9:	83 ec 0c             	sub    $0xc,%esp
  8022ec:	50                   	push   %eax
  8022ed:	e8 f7 ee ff ff       	call   8011e9 <fd2num>
  8022f2:	83 c4 10             	add    $0x10,%esp
}
  8022f5:	c9                   	leave  
  8022f6:	c3                   	ret    

008022f7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8022f7:	55                   	push   %ebp
  8022f8:	89 e5                	mov    %esp,%ebp
  8022fa:	56                   	push   %esi
  8022fb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8022fc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8022ff:	8b 35 04 30 80 00    	mov    0x803004,%esi
  802305:	e8 4f ec ff ff       	call   800f59 <sys_getenvid>
  80230a:	83 ec 0c             	sub    $0xc,%esp
  80230d:	ff 75 0c             	push   0xc(%ebp)
  802310:	ff 75 08             	push   0x8(%ebp)
  802313:	56                   	push   %esi
  802314:	50                   	push   %eax
  802315:	68 34 2c 80 00       	push   $0x802c34
  80231a:	e8 a2 e2 ff ff       	call   8005c1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80231f:	83 c4 18             	add    $0x18,%esp
  802322:	53                   	push   %ebx
  802323:	ff 75 10             	push   0x10(%ebp)
  802326:	e8 45 e2 ff ff       	call   800570 <vcprintf>
	cprintf("\n");
  80232b:	c7 04 24 74 27 80 00 	movl   $0x802774,(%esp)
  802332:	e8 8a e2 ff ff       	call   8005c1 <cprintf>
  802337:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80233a:	cc                   	int3   
  80233b:	eb fd                	jmp    80233a <_panic+0x43>

0080233d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80233d:	55                   	push   %ebp
  80233e:	89 e5                	mov    %esp,%ebp
  802340:	56                   	push   %esi
  802341:	53                   	push   %ebx
  802342:	8b 75 08             	mov    0x8(%ebp),%esi
  802345:	8b 45 0c             	mov    0xc(%ebp),%eax
  802348:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80234b:	85 c0                	test   %eax,%eax
  80234d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802352:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802355:	83 ec 0c             	sub    $0xc,%esp
  802358:	50                   	push   %eax
  802359:	e8 e9 ed ff ff       	call   801147 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  80235e:	83 c4 10             	add    $0x10,%esp
  802361:	85 f6                	test   %esi,%esi
  802363:	74 14                	je     802379 <ipc_recv+0x3c>
  802365:	ba 00 00 00 00       	mov    $0x0,%edx
  80236a:	85 c0                	test   %eax,%eax
  80236c:	78 09                	js     802377 <ipc_recv+0x3a>
  80236e:	8b 15 10 40 80 00    	mov    0x804010,%edx
  802374:	8b 52 74             	mov    0x74(%edx),%edx
  802377:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802379:	85 db                	test   %ebx,%ebx
  80237b:	74 14                	je     802391 <ipc_recv+0x54>
  80237d:	ba 00 00 00 00       	mov    $0x0,%edx
  802382:	85 c0                	test   %eax,%eax
  802384:	78 09                	js     80238f <ipc_recv+0x52>
  802386:	8b 15 10 40 80 00    	mov    0x804010,%edx
  80238c:	8b 52 78             	mov    0x78(%edx),%edx
  80238f:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802391:	85 c0                	test   %eax,%eax
  802393:	78 08                	js     80239d <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  802395:	a1 10 40 80 00       	mov    0x804010,%eax
  80239a:	8b 40 70             	mov    0x70(%eax),%eax
}
  80239d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023a0:	5b                   	pop    %ebx
  8023a1:	5e                   	pop    %esi
  8023a2:	5d                   	pop    %ebp
  8023a3:	c3                   	ret    

008023a4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023a4:	55                   	push   %ebp
  8023a5:	89 e5                	mov    %esp,%ebp
  8023a7:	57                   	push   %edi
  8023a8:	56                   	push   %esi
  8023a9:	53                   	push   %ebx
  8023aa:	83 ec 0c             	sub    $0xc,%esp
  8023ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8023b6:	85 db                	test   %ebx,%ebx
  8023b8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023bd:	0f 44 d8             	cmove  %eax,%ebx
  8023c0:	eb 05                	jmp    8023c7 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8023c2:	e8 b1 eb ff ff       	call   800f78 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8023c7:	ff 75 14             	push   0x14(%ebp)
  8023ca:	53                   	push   %ebx
  8023cb:	56                   	push   %esi
  8023cc:	57                   	push   %edi
  8023cd:	e8 52 ed ff ff       	call   801124 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8023d2:	83 c4 10             	add    $0x10,%esp
  8023d5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023d8:	74 e8                	je     8023c2 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8023da:	85 c0                	test   %eax,%eax
  8023dc:	78 08                	js     8023e6 <ipc_send+0x42>
	}while (r<0);

}
  8023de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023e1:	5b                   	pop    %ebx
  8023e2:	5e                   	pop    %esi
  8023e3:	5f                   	pop    %edi
  8023e4:	5d                   	pop    %ebp
  8023e5:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8023e6:	50                   	push   %eax
  8023e7:	68 57 2c 80 00       	push   $0x802c57
  8023ec:	6a 3d                	push   $0x3d
  8023ee:	68 6b 2c 80 00       	push   $0x802c6b
  8023f3:	e8 ff fe ff ff       	call   8022f7 <_panic>

008023f8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023f8:	55                   	push   %ebp
  8023f9:	89 e5                	mov    %esp,%ebp
  8023fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023fe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802403:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802406:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80240c:	8b 52 50             	mov    0x50(%edx),%edx
  80240f:	39 ca                	cmp    %ecx,%edx
  802411:	74 11                	je     802424 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802413:	83 c0 01             	add    $0x1,%eax
  802416:	3d 00 04 00 00       	cmp    $0x400,%eax
  80241b:	75 e6                	jne    802403 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80241d:	b8 00 00 00 00       	mov    $0x0,%eax
  802422:	eb 0b                	jmp    80242f <ipc_find_env+0x37>
			return envs[i].env_id;
  802424:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802427:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80242c:	8b 40 48             	mov    0x48(%eax),%eax
}
  80242f:	5d                   	pop    %ebp
  802430:	c3                   	ret    

00802431 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802431:	55                   	push   %ebp
  802432:	89 e5                	mov    %esp,%ebp
  802434:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802437:	89 c2                	mov    %eax,%edx
  802439:	c1 ea 16             	shr    $0x16,%edx
  80243c:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802443:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802448:	f6 c1 01             	test   $0x1,%cl
  80244b:	74 1c                	je     802469 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  80244d:	c1 e8 0c             	shr    $0xc,%eax
  802450:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802457:	a8 01                	test   $0x1,%al
  802459:	74 0e                	je     802469 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80245b:	c1 e8 0c             	shr    $0xc,%eax
  80245e:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802465:	ef 
  802466:	0f b7 d2             	movzwl %dx,%edx
}
  802469:	89 d0                	mov    %edx,%eax
  80246b:	5d                   	pop    %ebp
  80246c:	c3                   	ret    
  80246d:	66 90                	xchg   %ax,%ax
  80246f:	90                   	nop

00802470 <__udivdi3>:
  802470:	f3 0f 1e fb          	endbr32 
  802474:	55                   	push   %ebp
  802475:	57                   	push   %edi
  802476:	56                   	push   %esi
  802477:	53                   	push   %ebx
  802478:	83 ec 1c             	sub    $0x1c,%esp
  80247b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80247f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802483:	8b 74 24 34          	mov    0x34(%esp),%esi
  802487:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80248b:	85 c0                	test   %eax,%eax
  80248d:	75 19                	jne    8024a8 <__udivdi3+0x38>
  80248f:	39 f3                	cmp    %esi,%ebx
  802491:	76 4d                	jbe    8024e0 <__udivdi3+0x70>
  802493:	31 ff                	xor    %edi,%edi
  802495:	89 e8                	mov    %ebp,%eax
  802497:	89 f2                	mov    %esi,%edx
  802499:	f7 f3                	div    %ebx
  80249b:	89 fa                	mov    %edi,%edx
  80249d:	83 c4 1c             	add    $0x1c,%esp
  8024a0:	5b                   	pop    %ebx
  8024a1:	5e                   	pop    %esi
  8024a2:	5f                   	pop    %edi
  8024a3:	5d                   	pop    %ebp
  8024a4:	c3                   	ret    
  8024a5:	8d 76 00             	lea    0x0(%esi),%esi
  8024a8:	39 f0                	cmp    %esi,%eax
  8024aa:	76 14                	jbe    8024c0 <__udivdi3+0x50>
  8024ac:	31 ff                	xor    %edi,%edi
  8024ae:	31 c0                	xor    %eax,%eax
  8024b0:	89 fa                	mov    %edi,%edx
  8024b2:	83 c4 1c             	add    $0x1c,%esp
  8024b5:	5b                   	pop    %ebx
  8024b6:	5e                   	pop    %esi
  8024b7:	5f                   	pop    %edi
  8024b8:	5d                   	pop    %ebp
  8024b9:	c3                   	ret    
  8024ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024c0:	0f bd f8             	bsr    %eax,%edi
  8024c3:	83 f7 1f             	xor    $0x1f,%edi
  8024c6:	75 48                	jne    802510 <__udivdi3+0xa0>
  8024c8:	39 f0                	cmp    %esi,%eax
  8024ca:	72 06                	jb     8024d2 <__udivdi3+0x62>
  8024cc:	31 c0                	xor    %eax,%eax
  8024ce:	39 eb                	cmp    %ebp,%ebx
  8024d0:	77 de                	ja     8024b0 <__udivdi3+0x40>
  8024d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8024d7:	eb d7                	jmp    8024b0 <__udivdi3+0x40>
  8024d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024e0:	89 d9                	mov    %ebx,%ecx
  8024e2:	85 db                	test   %ebx,%ebx
  8024e4:	75 0b                	jne    8024f1 <__udivdi3+0x81>
  8024e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024eb:	31 d2                	xor    %edx,%edx
  8024ed:	f7 f3                	div    %ebx
  8024ef:	89 c1                	mov    %eax,%ecx
  8024f1:	31 d2                	xor    %edx,%edx
  8024f3:	89 f0                	mov    %esi,%eax
  8024f5:	f7 f1                	div    %ecx
  8024f7:	89 c6                	mov    %eax,%esi
  8024f9:	89 e8                	mov    %ebp,%eax
  8024fb:	89 f7                	mov    %esi,%edi
  8024fd:	f7 f1                	div    %ecx
  8024ff:	89 fa                	mov    %edi,%edx
  802501:	83 c4 1c             	add    $0x1c,%esp
  802504:	5b                   	pop    %ebx
  802505:	5e                   	pop    %esi
  802506:	5f                   	pop    %edi
  802507:	5d                   	pop    %ebp
  802508:	c3                   	ret    
  802509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802510:	89 f9                	mov    %edi,%ecx
  802512:	ba 20 00 00 00       	mov    $0x20,%edx
  802517:	29 fa                	sub    %edi,%edx
  802519:	d3 e0                	shl    %cl,%eax
  80251b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80251f:	89 d1                	mov    %edx,%ecx
  802521:	89 d8                	mov    %ebx,%eax
  802523:	d3 e8                	shr    %cl,%eax
  802525:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802529:	09 c1                	or     %eax,%ecx
  80252b:	89 f0                	mov    %esi,%eax
  80252d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802531:	89 f9                	mov    %edi,%ecx
  802533:	d3 e3                	shl    %cl,%ebx
  802535:	89 d1                	mov    %edx,%ecx
  802537:	d3 e8                	shr    %cl,%eax
  802539:	89 f9                	mov    %edi,%ecx
  80253b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80253f:	89 eb                	mov    %ebp,%ebx
  802541:	d3 e6                	shl    %cl,%esi
  802543:	89 d1                	mov    %edx,%ecx
  802545:	d3 eb                	shr    %cl,%ebx
  802547:	09 f3                	or     %esi,%ebx
  802549:	89 c6                	mov    %eax,%esi
  80254b:	89 f2                	mov    %esi,%edx
  80254d:	89 d8                	mov    %ebx,%eax
  80254f:	f7 74 24 08          	divl   0x8(%esp)
  802553:	89 d6                	mov    %edx,%esi
  802555:	89 c3                	mov    %eax,%ebx
  802557:	f7 64 24 0c          	mull   0xc(%esp)
  80255b:	39 d6                	cmp    %edx,%esi
  80255d:	72 19                	jb     802578 <__udivdi3+0x108>
  80255f:	89 f9                	mov    %edi,%ecx
  802561:	d3 e5                	shl    %cl,%ebp
  802563:	39 c5                	cmp    %eax,%ebp
  802565:	73 04                	jae    80256b <__udivdi3+0xfb>
  802567:	39 d6                	cmp    %edx,%esi
  802569:	74 0d                	je     802578 <__udivdi3+0x108>
  80256b:	89 d8                	mov    %ebx,%eax
  80256d:	31 ff                	xor    %edi,%edi
  80256f:	e9 3c ff ff ff       	jmp    8024b0 <__udivdi3+0x40>
  802574:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802578:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80257b:	31 ff                	xor    %edi,%edi
  80257d:	e9 2e ff ff ff       	jmp    8024b0 <__udivdi3+0x40>
  802582:	66 90                	xchg   %ax,%ax
  802584:	66 90                	xchg   %ax,%ax
  802586:	66 90                	xchg   %ax,%ax
  802588:	66 90                	xchg   %ax,%ax
  80258a:	66 90                	xchg   %ax,%ax
  80258c:	66 90                	xchg   %ax,%ax
  80258e:	66 90                	xchg   %ax,%ax

00802590 <__umoddi3>:
  802590:	f3 0f 1e fb          	endbr32 
  802594:	55                   	push   %ebp
  802595:	57                   	push   %edi
  802596:	56                   	push   %esi
  802597:	53                   	push   %ebx
  802598:	83 ec 1c             	sub    $0x1c,%esp
  80259b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80259f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8025a3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8025a7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8025ab:	89 f0                	mov    %esi,%eax
  8025ad:	89 da                	mov    %ebx,%edx
  8025af:	85 ff                	test   %edi,%edi
  8025b1:	75 15                	jne    8025c8 <__umoddi3+0x38>
  8025b3:	39 dd                	cmp    %ebx,%ebp
  8025b5:	76 39                	jbe    8025f0 <__umoddi3+0x60>
  8025b7:	f7 f5                	div    %ebp
  8025b9:	89 d0                	mov    %edx,%eax
  8025bb:	31 d2                	xor    %edx,%edx
  8025bd:	83 c4 1c             	add    $0x1c,%esp
  8025c0:	5b                   	pop    %ebx
  8025c1:	5e                   	pop    %esi
  8025c2:	5f                   	pop    %edi
  8025c3:	5d                   	pop    %ebp
  8025c4:	c3                   	ret    
  8025c5:	8d 76 00             	lea    0x0(%esi),%esi
  8025c8:	39 df                	cmp    %ebx,%edi
  8025ca:	77 f1                	ja     8025bd <__umoddi3+0x2d>
  8025cc:	0f bd cf             	bsr    %edi,%ecx
  8025cf:	83 f1 1f             	xor    $0x1f,%ecx
  8025d2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8025d6:	75 40                	jne    802618 <__umoddi3+0x88>
  8025d8:	39 df                	cmp    %ebx,%edi
  8025da:	72 04                	jb     8025e0 <__umoddi3+0x50>
  8025dc:	39 f5                	cmp    %esi,%ebp
  8025de:	77 dd                	ja     8025bd <__umoddi3+0x2d>
  8025e0:	89 da                	mov    %ebx,%edx
  8025e2:	89 f0                	mov    %esi,%eax
  8025e4:	29 e8                	sub    %ebp,%eax
  8025e6:	19 fa                	sbb    %edi,%edx
  8025e8:	eb d3                	jmp    8025bd <__umoddi3+0x2d>
  8025ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025f0:	89 e9                	mov    %ebp,%ecx
  8025f2:	85 ed                	test   %ebp,%ebp
  8025f4:	75 0b                	jne    802601 <__umoddi3+0x71>
  8025f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025fb:	31 d2                	xor    %edx,%edx
  8025fd:	f7 f5                	div    %ebp
  8025ff:	89 c1                	mov    %eax,%ecx
  802601:	89 d8                	mov    %ebx,%eax
  802603:	31 d2                	xor    %edx,%edx
  802605:	f7 f1                	div    %ecx
  802607:	89 f0                	mov    %esi,%eax
  802609:	f7 f1                	div    %ecx
  80260b:	89 d0                	mov    %edx,%eax
  80260d:	31 d2                	xor    %edx,%edx
  80260f:	eb ac                	jmp    8025bd <__umoddi3+0x2d>
  802611:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802618:	8b 44 24 04          	mov    0x4(%esp),%eax
  80261c:	ba 20 00 00 00       	mov    $0x20,%edx
  802621:	29 c2                	sub    %eax,%edx
  802623:	89 c1                	mov    %eax,%ecx
  802625:	89 e8                	mov    %ebp,%eax
  802627:	d3 e7                	shl    %cl,%edi
  802629:	89 d1                	mov    %edx,%ecx
  80262b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80262f:	d3 e8                	shr    %cl,%eax
  802631:	89 c1                	mov    %eax,%ecx
  802633:	8b 44 24 04          	mov    0x4(%esp),%eax
  802637:	09 f9                	or     %edi,%ecx
  802639:	89 df                	mov    %ebx,%edi
  80263b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80263f:	89 c1                	mov    %eax,%ecx
  802641:	d3 e5                	shl    %cl,%ebp
  802643:	89 d1                	mov    %edx,%ecx
  802645:	d3 ef                	shr    %cl,%edi
  802647:	89 c1                	mov    %eax,%ecx
  802649:	89 f0                	mov    %esi,%eax
  80264b:	d3 e3                	shl    %cl,%ebx
  80264d:	89 d1                	mov    %edx,%ecx
  80264f:	89 fa                	mov    %edi,%edx
  802651:	d3 e8                	shr    %cl,%eax
  802653:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802658:	09 d8                	or     %ebx,%eax
  80265a:	f7 74 24 08          	divl   0x8(%esp)
  80265e:	89 d3                	mov    %edx,%ebx
  802660:	d3 e6                	shl    %cl,%esi
  802662:	f7 e5                	mul    %ebp
  802664:	89 c7                	mov    %eax,%edi
  802666:	89 d1                	mov    %edx,%ecx
  802668:	39 d3                	cmp    %edx,%ebx
  80266a:	72 06                	jb     802672 <__umoddi3+0xe2>
  80266c:	75 0e                	jne    80267c <__umoddi3+0xec>
  80266e:	39 c6                	cmp    %eax,%esi
  802670:	73 0a                	jae    80267c <__umoddi3+0xec>
  802672:	29 e8                	sub    %ebp,%eax
  802674:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802678:	89 d1                	mov    %edx,%ecx
  80267a:	89 c7                	mov    %eax,%edi
  80267c:	89 f5                	mov    %esi,%ebp
  80267e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802682:	29 fd                	sub    %edi,%ebp
  802684:	19 cb                	sbb    %ecx,%ebx
  802686:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80268b:	89 d8                	mov    %ebx,%eax
  80268d:	d3 e0                	shl    %cl,%eax
  80268f:	89 f1                	mov    %esi,%ecx
  802691:	d3 ed                	shr    %cl,%ebp
  802693:	d3 eb                	shr    %cl,%ebx
  802695:	09 e8                	or     %ebp,%eax
  802697:	89 da                	mov    %ebx,%edx
  802699:	83 c4 1c             	add    $0x1c,%esp
  80269c:	5b                   	pop    %ebx
  80269d:	5e                   	pop    %esi
  80269e:	5f                   	pop    %edi
  80269f:	5d                   	pop    %ebp
  8026a0:	c3                   	ret    
