
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
  80003f:	e8 80 05 00 00       	call   8005c4 <cprintf>
	exit();
  800044:	e8 cc 04 00 00       	call   800515 <exit>
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
  80005c:	e8 63 05 00 00       	call   8005c4 <cprintf>
	cprintf("\tip address %s = %x\n", IPADDR, inet_addr(IPADDR));
  800061:	c7 04 24 d4 26 80 00 	movl   $0x8026d4,(%esp)
  800068:	e8 2a 04 00 00       	call   800497 <inet_addr>
  80006d:	83 c4 0c             	add    $0xc,%esp
  800070:	50                   	push   %eax
  800071:	68 d4 26 80 00       	push   $0x8026d4
  800076:	68 de 26 80 00       	push   $0x8026de
  80007b:	e8 44 05 00 00       	call   8005c4 <cprintf>

	// Create the TCP socket
	if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  800080:	83 c4 0c             	add    $0xc,%esp
  800083:	6a 06                	push   $0x6
  800085:	6a 01                	push   $0x1
  800087:	6a 02                	push   $0x2
  800089:	e8 2f 1b 00 00       	call   801bbd <socket>
  80008e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	85 c0                	test   %eax,%eax
  800096:	0f 88 b4 00 00 00    	js     800150 <umain+0x102>
		die("Failed to create socket");

	cprintf("opened socket\n");
  80009c:	83 ec 0c             	sub    $0xc,%esp
  80009f:	68 0b 27 80 00       	push   $0x80270b
  8000a4:	e8 1b 05 00 00       	call   8005c4 <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  8000a9:	83 c4 0c             	add    $0xc,%esp
  8000ac:	6a 10                	push   $0x10
  8000ae:	6a 00                	push   $0x0
  8000b0:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8000b3:	53                   	push   %ebx
  8000b4:	e8 35 0c 00 00       	call   800cee <memset>
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
  8000e3:	e8 dc 04 00 00       	call   8005c4 <cprintf>

	// Establish connection
	if (connect(sock, (struct sockaddr *) &echoserver, sizeof(echoserver)) < 0)
  8000e8:	83 c4 0c             	add    $0xc,%esp
  8000eb:	6a 10                	push   $0x10
  8000ed:	53                   	push   %ebx
  8000ee:	ff 75 b4             	push   -0x4c(%ebp)
  8000f1:	e8 7e 1a 00 00       	call   801b74 <connect>
  8000f6:	83 c4 10             	add    $0x10,%esp
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	78 62                	js     80015f <umain+0x111>
		die("Failed to connect with server");

	cprintf("connected to server\n");
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	68 55 27 80 00       	push   $0x802755
  800105:	e8 ba 04 00 00       	call   8005c4 <cprintf>

	// Send the word to the server
	echolen = strlen(msg);
  80010a:	83 c4 04             	add    $0x4,%esp
  80010d:	ff 35 00 30 80 00    	push   0x803000
  800113:	e8 4b 0a 00 00       	call   800b63 <strlen>
  800118:	89 c7                	mov    %eax,%edi
  80011a:	89 45 b0             	mov    %eax,-0x50(%ebp)
	if (write(sock, msg, echolen) != echolen)
  80011d:	83 c4 0c             	add    $0xc,%esp
  800120:	50                   	push   %eax
  800121:	ff 35 00 30 80 00    	push   0x803000
  800127:	ff 75 b4             	push   -0x4c(%ebp)
  80012a:	e8 6b 14 00 00       	call   80159a <write>
  80012f:	83 c4 10             	add    $0x10,%esp
  800132:	39 c7                	cmp    %eax,%edi
  800134:	75 35                	jne    80016b <umain+0x11d>
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 6a 27 80 00       	push   $0x80276a
  80013e:	e8 81 04 00 00       	call   8005c4 <cprintf>
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
  800182:	e8 3d 04 00 00       	call   8005c4 <cprintf>
  800187:	83 c4 10             	add    $0x10,%esp
	while (received < echolen) {
  80018a:	3b 75 b0             	cmp    -0x50(%ebp),%esi
  80018d:	73 23                	jae    8001b2 <umain+0x164>
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  80018f:	83 ec 04             	sub    $0x4,%esp
  800192:	6a 1f                	push   $0x1f
  800194:	57                   	push   %edi
  800195:	ff 75 b4             	push   -0x4c(%ebp)
  800198:	e8 2f 13 00 00       	call   8014cc <read>
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
  8001ba:	e8 05 04 00 00       	call   8005c4 <cprintf>

	close(sock);
  8001bf:	83 c4 04             	add    $0x4,%esp
  8001c2:	ff 75 b4             	push   -0x4c(%ebp)
  8001c5:	e8 c6 11 00 00       	call   801390 <close>
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
  8004d7:	e8 80 0a 00 00       	call   800f5c <sys_getenvid>
  8004dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004e1:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8004e7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004ec:	a3 10 40 80 00       	mov    %eax,0x804010

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004f1:	85 db                	test   %ebx,%ebx
  8004f3:	7e 07                	jle    8004fc <libmain+0x30>
		binaryname = argv[0];
  8004f5:	8b 06                	mov    (%esi),%eax
  8004f7:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	56                   	push   %esi
  800500:	53                   	push   %ebx
  800501:	e8 48 fb ff ff       	call   80004e <umain>

	// exit gracefully
	exit();
  800506:	e8 0a 00 00 00       	call   800515 <exit>
}
  80050b:	83 c4 10             	add    $0x10,%esp
  80050e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800511:	5b                   	pop    %ebx
  800512:	5e                   	pop    %esi
  800513:	5d                   	pop    %ebp
  800514:	c3                   	ret    

00800515 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800515:	55                   	push   %ebp
  800516:	89 e5                	mov    %esp,%ebp
  800518:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80051b:	e8 9d 0e 00 00       	call   8013bd <close_all>
	sys_env_destroy(0);
  800520:	83 ec 0c             	sub    $0xc,%esp
  800523:	6a 00                	push   $0x0
  800525:	e8 f1 09 00 00       	call   800f1b <sys_env_destroy>
}
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	c9                   	leave  
  80052e:	c3                   	ret    

0080052f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052f:	55                   	push   %ebp
  800530:	89 e5                	mov    %esp,%ebp
  800532:	53                   	push   %ebx
  800533:	83 ec 04             	sub    $0x4,%esp
  800536:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800539:	8b 13                	mov    (%ebx),%edx
  80053b:	8d 42 01             	lea    0x1(%edx),%eax
  80053e:	89 03                	mov    %eax,(%ebx)
  800540:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800543:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800547:	3d ff 00 00 00       	cmp    $0xff,%eax
  80054c:	74 09                	je     800557 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80054e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800552:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800555:	c9                   	leave  
  800556:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	68 ff 00 00 00       	push   $0xff
  80055f:	8d 43 08             	lea    0x8(%ebx),%eax
  800562:	50                   	push   %eax
  800563:	e8 76 09 00 00       	call   800ede <sys_cputs>
		b->idx = 0;
  800568:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80056e:	83 c4 10             	add    $0x10,%esp
  800571:	eb db                	jmp    80054e <putch+0x1f>

00800573 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800573:	55                   	push   %ebp
  800574:	89 e5                	mov    %esp,%ebp
  800576:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80057c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800583:	00 00 00 
	b.cnt = 0;
  800586:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80058d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800590:	ff 75 0c             	push   0xc(%ebp)
  800593:	ff 75 08             	push   0x8(%ebp)
  800596:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80059c:	50                   	push   %eax
  80059d:	68 2f 05 80 00       	push   $0x80052f
  8005a2:	e8 14 01 00 00       	call   8006bb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a7:	83 c4 08             	add    $0x8,%esp
  8005aa:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8005b0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005b6:	50                   	push   %eax
  8005b7:	e8 22 09 00 00       	call   800ede <sys_cputs>

	return b.cnt;
}
  8005bc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005c2:	c9                   	leave  
  8005c3:	c3                   	ret    

008005c4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005c4:	55                   	push   %ebp
  8005c5:	89 e5                	mov    %esp,%ebp
  8005c7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005ca:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005cd:	50                   	push   %eax
  8005ce:	ff 75 08             	push   0x8(%ebp)
  8005d1:	e8 9d ff ff ff       	call   800573 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005d6:	c9                   	leave  
  8005d7:	c3                   	ret    

008005d8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d8:	55                   	push   %ebp
  8005d9:	89 e5                	mov    %esp,%ebp
  8005db:	57                   	push   %edi
  8005dc:	56                   	push   %esi
  8005dd:	53                   	push   %ebx
  8005de:	83 ec 1c             	sub    $0x1c,%esp
  8005e1:	89 c7                	mov    %eax,%edi
  8005e3:	89 d6                	mov    %edx,%esi
  8005e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005eb:	89 d1                	mov    %edx,%ecx
  8005ed:	89 c2                	mov    %eax,%edx
  8005ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800605:	39 c2                	cmp    %eax,%edx
  800607:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80060a:	72 3e                	jb     80064a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80060c:	83 ec 0c             	sub    $0xc,%esp
  80060f:	ff 75 18             	push   0x18(%ebp)
  800612:	83 eb 01             	sub    $0x1,%ebx
  800615:	53                   	push   %ebx
  800616:	50                   	push   %eax
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	ff 75 e4             	push   -0x1c(%ebp)
  80061d:	ff 75 e0             	push   -0x20(%ebp)
  800620:	ff 75 dc             	push   -0x24(%ebp)
  800623:	ff 75 d8             	push   -0x28(%ebp)
  800626:	e8 55 1e 00 00       	call   802480 <__udivdi3>
  80062b:	83 c4 18             	add    $0x18,%esp
  80062e:	52                   	push   %edx
  80062f:	50                   	push   %eax
  800630:	89 f2                	mov    %esi,%edx
  800632:	89 f8                	mov    %edi,%eax
  800634:	e8 9f ff ff ff       	call   8005d8 <printnum>
  800639:	83 c4 20             	add    $0x20,%esp
  80063c:	eb 13                	jmp    800651 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	56                   	push   %esi
  800642:	ff 75 18             	push   0x18(%ebp)
  800645:	ff d7                	call   *%edi
  800647:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80064a:	83 eb 01             	sub    $0x1,%ebx
  80064d:	85 db                	test   %ebx,%ebx
  80064f:	7f ed                	jg     80063e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	56                   	push   %esi
  800655:	83 ec 04             	sub    $0x4,%esp
  800658:	ff 75 e4             	push   -0x1c(%ebp)
  80065b:	ff 75 e0             	push   -0x20(%ebp)
  80065e:	ff 75 dc             	push   -0x24(%ebp)
  800661:	ff 75 d8             	push   -0x28(%ebp)
  800664:	e8 37 1f 00 00       	call   8025a0 <__umoddi3>
  800669:	83 c4 14             	add    $0x14,%esp
  80066c:	0f be 80 d6 27 80 00 	movsbl 0x8027d6(%eax),%eax
  800673:	50                   	push   %eax
  800674:	ff d7                	call   *%edi
}
  800676:	83 c4 10             	add    $0x10,%esp
  800679:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067c:	5b                   	pop    %ebx
  80067d:	5e                   	pop    %esi
  80067e:	5f                   	pop    %edi
  80067f:	5d                   	pop    %ebp
  800680:	c3                   	ret    

00800681 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800681:	55                   	push   %ebp
  800682:	89 e5                	mov    %esp,%ebp
  800684:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800687:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80068b:	8b 10                	mov    (%eax),%edx
  80068d:	3b 50 04             	cmp    0x4(%eax),%edx
  800690:	73 0a                	jae    80069c <sprintputch+0x1b>
		*b->buf++ = ch;
  800692:	8d 4a 01             	lea    0x1(%edx),%ecx
  800695:	89 08                	mov    %ecx,(%eax)
  800697:	8b 45 08             	mov    0x8(%ebp),%eax
  80069a:	88 02                	mov    %al,(%edx)
}
  80069c:	5d                   	pop    %ebp
  80069d:	c3                   	ret    

0080069e <printfmt>:
{
  80069e:	55                   	push   %ebp
  80069f:	89 e5                	mov    %esp,%ebp
  8006a1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8006a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006a7:	50                   	push   %eax
  8006a8:	ff 75 10             	push   0x10(%ebp)
  8006ab:	ff 75 0c             	push   0xc(%ebp)
  8006ae:	ff 75 08             	push   0x8(%ebp)
  8006b1:	e8 05 00 00 00       	call   8006bb <vprintfmt>
}
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	c9                   	leave  
  8006ba:	c3                   	ret    

008006bb <vprintfmt>:
{
  8006bb:	55                   	push   %ebp
  8006bc:	89 e5                	mov    %esp,%ebp
  8006be:	57                   	push   %edi
  8006bf:	56                   	push   %esi
  8006c0:	53                   	push   %ebx
  8006c1:	83 ec 3c             	sub    $0x3c,%esp
  8006c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ca:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006cd:	eb 0a                	jmp    8006d9 <vprintfmt+0x1e>
			putch(ch, putdat);
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	53                   	push   %ebx
  8006d3:	50                   	push   %eax
  8006d4:	ff d6                	call   *%esi
  8006d6:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d9:	83 c7 01             	add    $0x1,%edi
  8006dc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006e0:	83 f8 25             	cmp    $0x25,%eax
  8006e3:	74 0c                	je     8006f1 <vprintfmt+0x36>
			if (ch == '\0')
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	75 e6                	jne    8006cf <vprintfmt+0x14>
}
  8006e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ec:	5b                   	pop    %ebx
  8006ed:	5e                   	pop    %esi
  8006ee:	5f                   	pop    %edi
  8006ef:	5d                   	pop    %ebp
  8006f0:	c3                   	ret    
		padc = ' ';
  8006f1:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8006f5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8006fc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800703:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80070a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80070f:	8d 47 01             	lea    0x1(%edi),%eax
  800712:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800715:	0f b6 17             	movzbl (%edi),%edx
  800718:	8d 42 dd             	lea    -0x23(%edx),%eax
  80071b:	3c 55                	cmp    $0x55,%al
  80071d:	0f 87 bb 03 00 00    	ja     800ade <vprintfmt+0x423>
  800723:	0f b6 c0             	movzbl %al,%eax
  800726:	ff 24 85 20 29 80 00 	jmp    *0x802920(,%eax,4)
  80072d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800730:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800734:	eb d9                	jmp    80070f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800736:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800739:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80073d:	eb d0                	jmp    80070f <vprintfmt+0x54>
  80073f:	0f b6 d2             	movzbl %dl,%edx
  800742:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800745:	b8 00 00 00 00       	mov    $0x0,%eax
  80074a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80074d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800750:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800754:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800757:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80075a:	83 f9 09             	cmp    $0x9,%ecx
  80075d:	77 55                	ja     8007b4 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80075f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800762:	eb e9                	jmp    80074d <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800764:	8b 45 14             	mov    0x14(%ebp),%eax
  800767:	8b 00                	mov    (%eax),%eax
  800769:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8d 40 04             	lea    0x4(%eax),%eax
  800772:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800775:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800778:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80077c:	79 91                	jns    80070f <vprintfmt+0x54>
				width = precision, precision = -1;
  80077e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800781:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800784:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80078b:	eb 82                	jmp    80070f <vprintfmt+0x54>
  80078d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800790:	85 d2                	test   %edx,%edx
  800792:	b8 00 00 00 00       	mov    $0x0,%eax
  800797:	0f 49 c2             	cmovns %edx,%eax
  80079a:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80079d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8007a0:	e9 6a ff ff ff       	jmp    80070f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8007a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8007a8:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8007af:	e9 5b ff ff ff       	jmp    80070f <vprintfmt+0x54>
  8007b4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8007b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ba:	eb bc                	jmp    800778 <vprintfmt+0xbd>
			lflag++;
  8007bc:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8007bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8007c2:	e9 48 ff ff ff       	jmp    80070f <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8007c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ca:	8d 78 04             	lea    0x4(%eax),%edi
  8007cd:	83 ec 08             	sub    $0x8,%esp
  8007d0:	53                   	push   %ebx
  8007d1:	ff 30                	push   (%eax)
  8007d3:	ff d6                	call   *%esi
			break;
  8007d5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8007d8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8007db:	e9 9d 02 00 00       	jmp    800a7d <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8007e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e3:	8d 78 04             	lea    0x4(%eax),%edi
  8007e6:	8b 10                	mov    (%eax),%edx
  8007e8:	89 d0                	mov    %edx,%eax
  8007ea:	f7 d8                	neg    %eax
  8007ec:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007ef:	83 f8 0f             	cmp    $0xf,%eax
  8007f2:	7f 23                	jg     800817 <vprintfmt+0x15c>
  8007f4:	8b 14 85 80 2a 80 00 	mov    0x802a80(,%eax,4),%edx
  8007fb:	85 d2                	test   %edx,%edx
  8007fd:	74 18                	je     800817 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8007ff:	52                   	push   %edx
  800800:	68 b5 2b 80 00       	push   $0x802bb5
  800805:	53                   	push   %ebx
  800806:	56                   	push   %esi
  800807:	e8 92 fe ff ff       	call   80069e <printfmt>
  80080c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80080f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800812:	e9 66 02 00 00       	jmp    800a7d <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800817:	50                   	push   %eax
  800818:	68 ee 27 80 00       	push   $0x8027ee
  80081d:	53                   	push   %ebx
  80081e:	56                   	push   %esi
  80081f:	e8 7a fe ff ff       	call   80069e <printfmt>
  800824:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800827:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80082a:	e9 4e 02 00 00       	jmp    800a7d <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80082f:	8b 45 14             	mov    0x14(%ebp),%eax
  800832:	83 c0 04             	add    $0x4,%eax
  800835:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800838:	8b 45 14             	mov    0x14(%ebp),%eax
  80083b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80083d:	85 d2                	test   %edx,%edx
  80083f:	b8 e7 27 80 00       	mov    $0x8027e7,%eax
  800844:	0f 45 c2             	cmovne %edx,%eax
  800847:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80084a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80084e:	7e 06                	jle    800856 <vprintfmt+0x19b>
  800850:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800854:	75 0d                	jne    800863 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800856:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800859:	89 c7                	mov    %eax,%edi
  80085b:	03 45 e0             	add    -0x20(%ebp),%eax
  80085e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800861:	eb 55                	jmp    8008b8 <vprintfmt+0x1fd>
  800863:	83 ec 08             	sub    $0x8,%esp
  800866:	ff 75 d8             	push   -0x28(%ebp)
  800869:	ff 75 cc             	push   -0x34(%ebp)
  80086c:	e8 0a 03 00 00       	call   800b7b <strnlen>
  800871:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800874:	29 c1                	sub    %eax,%ecx
  800876:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800879:	83 c4 10             	add    $0x10,%esp
  80087c:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80087e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800882:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800885:	eb 0f                	jmp    800896 <vprintfmt+0x1db>
					putch(padc, putdat);
  800887:	83 ec 08             	sub    $0x8,%esp
  80088a:	53                   	push   %ebx
  80088b:	ff 75 e0             	push   -0x20(%ebp)
  80088e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800890:	83 ef 01             	sub    $0x1,%edi
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	85 ff                	test   %edi,%edi
  800898:	7f ed                	jg     800887 <vprintfmt+0x1cc>
  80089a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80089d:	85 d2                	test   %edx,%edx
  80089f:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a4:	0f 49 c2             	cmovns %edx,%eax
  8008a7:	29 c2                	sub    %eax,%edx
  8008a9:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8008ac:	eb a8                	jmp    800856 <vprintfmt+0x19b>
					putch(ch, putdat);
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	53                   	push   %ebx
  8008b2:	52                   	push   %edx
  8008b3:	ff d6                	call   *%esi
  8008b5:	83 c4 10             	add    $0x10,%esp
  8008b8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008bb:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008bd:	83 c7 01             	add    $0x1,%edi
  8008c0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008c4:	0f be d0             	movsbl %al,%edx
  8008c7:	85 d2                	test   %edx,%edx
  8008c9:	74 4b                	je     800916 <vprintfmt+0x25b>
  8008cb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008cf:	78 06                	js     8008d7 <vprintfmt+0x21c>
  8008d1:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8008d5:	78 1e                	js     8008f5 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8008d7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8008db:	74 d1                	je     8008ae <vprintfmt+0x1f3>
  8008dd:	0f be c0             	movsbl %al,%eax
  8008e0:	83 e8 20             	sub    $0x20,%eax
  8008e3:	83 f8 5e             	cmp    $0x5e,%eax
  8008e6:	76 c6                	jbe    8008ae <vprintfmt+0x1f3>
					putch('?', putdat);
  8008e8:	83 ec 08             	sub    $0x8,%esp
  8008eb:	53                   	push   %ebx
  8008ec:	6a 3f                	push   $0x3f
  8008ee:	ff d6                	call   *%esi
  8008f0:	83 c4 10             	add    $0x10,%esp
  8008f3:	eb c3                	jmp    8008b8 <vprintfmt+0x1fd>
  8008f5:	89 cf                	mov    %ecx,%edi
  8008f7:	eb 0e                	jmp    800907 <vprintfmt+0x24c>
				putch(' ', putdat);
  8008f9:	83 ec 08             	sub    $0x8,%esp
  8008fc:	53                   	push   %ebx
  8008fd:	6a 20                	push   $0x20
  8008ff:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800901:	83 ef 01             	sub    $0x1,%edi
  800904:	83 c4 10             	add    $0x10,%esp
  800907:	85 ff                	test   %edi,%edi
  800909:	7f ee                	jg     8008f9 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80090b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80090e:	89 45 14             	mov    %eax,0x14(%ebp)
  800911:	e9 67 01 00 00       	jmp    800a7d <vprintfmt+0x3c2>
  800916:	89 cf                	mov    %ecx,%edi
  800918:	eb ed                	jmp    800907 <vprintfmt+0x24c>
	if (lflag >= 2)
  80091a:	83 f9 01             	cmp    $0x1,%ecx
  80091d:	7f 1b                	jg     80093a <vprintfmt+0x27f>
	else if (lflag)
  80091f:	85 c9                	test   %ecx,%ecx
  800921:	74 63                	je     800986 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800923:	8b 45 14             	mov    0x14(%ebp),%eax
  800926:	8b 00                	mov    (%eax),%eax
  800928:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80092b:	99                   	cltd   
  80092c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80092f:	8b 45 14             	mov    0x14(%ebp),%eax
  800932:	8d 40 04             	lea    0x4(%eax),%eax
  800935:	89 45 14             	mov    %eax,0x14(%ebp)
  800938:	eb 17                	jmp    800951 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80093a:	8b 45 14             	mov    0x14(%ebp),%eax
  80093d:	8b 50 04             	mov    0x4(%eax),%edx
  800940:	8b 00                	mov    (%eax),%eax
  800942:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800945:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800948:	8b 45 14             	mov    0x14(%ebp),%eax
  80094b:	8d 40 08             	lea    0x8(%eax),%eax
  80094e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800951:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800954:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800957:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80095c:	85 c9                	test   %ecx,%ecx
  80095e:	0f 89 ff 00 00 00    	jns    800a63 <vprintfmt+0x3a8>
				putch('-', putdat);
  800964:	83 ec 08             	sub    $0x8,%esp
  800967:	53                   	push   %ebx
  800968:	6a 2d                	push   $0x2d
  80096a:	ff d6                	call   *%esi
				num = -(long long) num;
  80096c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80096f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800972:	f7 da                	neg    %edx
  800974:	83 d1 00             	adc    $0x0,%ecx
  800977:	f7 d9                	neg    %ecx
  800979:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80097c:	bf 0a 00 00 00       	mov    $0xa,%edi
  800981:	e9 dd 00 00 00       	jmp    800a63 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800986:	8b 45 14             	mov    0x14(%ebp),%eax
  800989:	8b 00                	mov    (%eax),%eax
  80098b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80098e:	99                   	cltd   
  80098f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800992:	8b 45 14             	mov    0x14(%ebp),%eax
  800995:	8d 40 04             	lea    0x4(%eax),%eax
  800998:	89 45 14             	mov    %eax,0x14(%ebp)
  80099b:	eb b4                	jmp    800951 <vprintfmt+0x296>
	if (lflag >= 2)
  80099d:	83 f9 01             	cmp    $0x1,%ecx
  8009a0:	7f 1e                	jg     8009c0 <vprintfmt+0x305>
	else if (lflag)
  8009a2:	85 c9                	test   %ecx,%ecx
  8009a4:	74 32                	je     8009d8 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8009a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a9:	8b 10                	mov    (%eax),%edx
  8009ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009b0:	8d 40 04             	lea    0x4(%eax),%eax
  8009b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009b6:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8009bb:	e9 a3 00 00 00       	jmp    800a63 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8009c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c3:	8b 10                	mov    (%eax),%edx
  8009c5:	8b 48 04             	mov    0x4(%eax),%ecx
  8009c8:	8d 40 08             	lea    0x8(%eax),%eax
  8009cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009ce:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8009d3:	e9 8b 00 00 00       	jmp    800a63 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8009d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009db:	8b 10                	mov    (%eax),%edx
  8009dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009e2:	8d 40 04             	lea    0x4(%eax),%eax
  8009e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009e8:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8009ed:	eb 74                	jmp    800a63 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8009ef:	83 f9 01             	cmp    $0x1,%ecx
  8009f2:	7f 1b                	jg     800a0f <vprintfmt+0x354>
	else if (lflag)
  8009f4:	85 c9                	test   %ecx,%ecx
  8009f6:	74 2c                	je     800a24 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8009f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009fb:	8b 10                	mov    (%eax),%edx
  8009fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a02:	8d 40 04             	lea    0x4(%eax),%eax
  800a05:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a08:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800a0d:	eb 54                	jmp    800a63 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800a0f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a12:	8b 10                	mov    (%eax),%edx
  800a14:	8b 48 04             	mov    0x4(%eax),%ecx
  800a17:	8d 40 08             	lea    0x8(%eax),%eax
  800a1a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a1d:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800a22:	eb 3f                	jmp    800a63 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800a24:	8b 45 14             	mov    0x14(%ebp),%eax
  800a27:	8b 10                	mov    (%eax),%edx
  800a29:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a2e:	8d 40 04             	lea    0x4(%eax),%eax
  800a31:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a34:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800a39:	eb 28                	jmp    800a63 <vprintfmt+0x3a8>
			putch('0', putdat);
  800a3b:	83 ec 08             	sub    $0x8,%esp
  800a3e:	53                   	push   %ebx
  800a3f:	6a 30                	push   $0x30
  800a41:	ff d6                	call   *%esi
			putch('x', putdat);
  800a43:	83 c4 08             	add    $0x8,%esp
  800a46:	53                   	push   %ebx
  800a47:	6a 78                	push   $0x78
  800a49:	ff d6                	call   *%esi
			num = (unsigned long long)
  800a4b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a4e:	8b 10                	mov    (%eax),%edx
  800a50:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800a55:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800a58:	8d 40 04             	lea    0x4(%eax),%eax
  800a5b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a5e:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800a63:	83 ec 0c             	sub    $0xc,%esp
  800a66:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800a6a:	50                   	push   %eax
  800a6b:	ff 75 e0             	push   -0x20(%ebp)
  800a6e:	57                   	push   %edi
  800a6f:	51                   	push   %ecx
  800a70:	52                   	push   %edx
  800a71:	89 da                	mov    %ebx,%edx
  800a73:	89 f0                	mov    %esi,%eax
  800a75:	e8 5e fb ff ff       	call   8005d8 <printnum>
			break;
  800a7a:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800a7d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a80:	e9 54 fc ff ff       	jmp    8006d9 <vprintfmt+0x1e>
	if (lflag >= 2)
  800a85:	83 f9 01             	cmp    $0x1,%ecx
  800a88:	7f 1b                	jg     800aa5 <vprintfmt+0x3ea>
	else if (lflag)
  800a8a:	85 c9                	test   %ecx,%ecx
  800a8c:	74 2c                	je     800aba <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800a8e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a91:	8b 10                	mov    (%eax),%edx
  800a93:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a98:	8d 40 04             	lea    0x4(%eax),%eax
  800a9b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a9e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800aa3:	eb be                	jmp    800a63 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800aa5:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa8:	8b 10                	mov    (%eax),%edx
  800aaa:	8b 48 04             	mov    0x4(%eax),%ecx
  800aad:	8d 40 08             	lea    0x8(%eax),%eax
  800ab0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ab3:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800ab8:	eb a9                	jmp    800a63 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800aba:	8b 45 14             	mov    0x14(%ebp),%eax
  800abd:	8b 10                	mov    (%eax),%edx
  800abf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac4:	8d 40 04             	lea    0x4(%eax),%eax
  800ac7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800aca:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800acf:	eb 92                	jmp    800a63 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800ad1:	83 ec 08             	sub    $0x8,%esp
  800ad4:	53                   	push   %ebx
  800ad5:	6a 25                	push   $0x25
  800ad7:	ff d6                	call   *%esi
			break;
  800ad9:	83 c4 10             	add    $0x10,%esp
  800adc:	eb 9f                	jmp    800a7d <vprintfmt+0x3c2>
			putch('%', putdat);
  800ade:	83 ec 08             	sub    $0x8,%esp
  800ae1:	53                   	push   %ebx
  800ae2:	6a 25                	push   $0x25
  800ae4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ae6:	83 c4 10             	add    $0x10,%esp
  800ae9:	89 f8                	mov    %edi,%eax
  800aeb:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800aef:	74 05                	je     800af6 <vprintfmt+0x43b>
  800af1:	83 e8 01             	sub    $0x1,%eax
  800af4:	eb f5                	jmp    800aeb <vprintfmt+0x430>
  800af6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800af9:	eb 82                	jmp    800a7d <vprintfmt+0x3c2>

00800afb <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	83 ec 18             	sub    $0x18,%esp
  800b01:	8b 45 08             	mov    0x8(%ebp),%eax
  800b04:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b07:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b0a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b0e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b11:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b18:	85 c0                	test   %eax,%eax
  800b1a:	74 26                	je     800b42 <vsnprintf+0x47>
  800b1c:	85 d2                	test   %edx,%edx
  800b1e:	7e 22                	jle    800b42 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b20:	ff 75 14             	push   0x14(%ebp)
  800b23:	ff 75 10             	push   0x10(%ebp)
  800b26:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b29:	50                   	push   %eax
  800b2a:	68 81 06 80 00       	push   $0x800681
  800b2f:	e8 87 fb ff ff       	call   8006bb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b34:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b37:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b3d:	83 c4 10             	add    $0x10,%esp
}
  800b40:	c9                   	leave  
  800b41:	c3                   	ret    
		return -E_INVAL;
  800b42:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b47:	eb f7                	jmp    800b40 <vsnprintf+0x45>

00800b49 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b4f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b52:	50                   	push   %eax
  800b53:	ff 75 10             	push   0x10(%ebp)
  800b56:	ff 75 0c             	push   0xc(%ebp)
  800b59:	ff 75 08             	push   0x8(%ebp)
  800b5c:	e8 9a ff ff ff       	call   800afb <vsnprintf>
	va_end(ap);

	return rc;
}
  800b61:	c9                   	leave  
  800b62:	c3                   	ret    

00800b63 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b69:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6e:	eb 03                	jmp    800b73 <strlen+0x10>
		n++;
  800b70:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800b73:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b77:	75 f7                	jne    800b70 <strlen+0xd>
	return n;
}
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b81:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b84:	b8 00 00 00 00       	mov    $0x0,%eax
  800b89:	eb 03                	jmp    800b8e <strnlen+0x13>
		n++;
  800b8b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b8e:	39 d0                	cmp    %edx,%eax
  800b90:	74 08                	je     800b9a <strnlen+0x1f>
  800b92:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b96:	75 f3                	jne    800b8b <strnlen+0x10>
  800b98:	89 c2                	mov    %eax,%edx
	return n;
}
  800b9a:	89 d0                	mov    %edx,%eax
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	53                   	push   %ebx
  800ba2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ba8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bad:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800bb1:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800bb4:	83 c0 01             	add    $0x1,%eax
  800bb7:	84 d2                	test   %dl,%dl
  800bb9:	75 f2                	jne    800bad <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bbb:	89 c8                	mov    %ecx,%eax
  800bbd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc0:	c9                   	leave  
  800bc1:	c3                   	ret    

00800bc2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	53                   	push   %ebx
  800bc6:	83 ec 10             	sub    $0x10,%esp
  800bc9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bcc:	53                   	push   %ebx
  800bcd:	e8 91 ff ff ff       	call   800b63 <strlen>
  800bd2:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800bd5:	ff 75 0c             	push   0xc(%ebp)
  800bd8:	01 d8                	add    %ebx,%eax
  800bda:	50                   	push   %eax
  800bdb:	e8 be ff ff ff       	call   800b9e <strcpy>
	return dst;
}
  800be0:	89 d8                	mov    %ebx,%eax
  800be2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be5:	c9                   	leave  
  800be6:	c3                   	ret    

00800be7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
  800bec:	8b 75 08             	mov    0x8(%ebp),%esi
  800bef:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf2:	89 f3                	mov    %esi,%ebx
  800bf4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bf7:	89 f0                	mov    %esi,%eax
  800bf9:	eb 0f                	jmp    800c0a <strncpy+0x23>
		*dst++ = *src;
  800bfb:	83 c0 01             	add    $0x1,%eax
  800bfe:	0f b6 0a             	movzbl (%edx),%ecx
  800c01:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c04:	80 f9 01             	cmp    $0x1,%cl
  800c07:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800c0a:	39 d8                	cmp    %ebx,%eax
  800c0c:	75 ed                	jne    800bfb <strncpy+0x14>
	}
	return ret;
}
  800c0e:	89 f0                	mov    %esi,%eax
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	8b 75 08             	mov    0x8(%ebp),%esi
  800c1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1f:	8b 55 10             	mov    0x10(%ebp),%edx
  800c22:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c24:	85 d2                	test   %edx,%edx
  800c26:	74 21                	je     800c49 <strlcpy+0x35>
  800c28:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c2c:	89 f2                	mov    %esi,%edx
  800c2e:	eb 09                	jmp    800c39 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c30:	83 c1 01             	add    $0x1,%ecx
  800c33:	83 c2 01             	add    $0x1,%edx
  800c36:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800c39:	39 c2                	cmp    %eax,%edx
  800c3b:	74 09                	je     800c46 <strlcpy+0x32>
  800c3d:	0f b6 19             	movzbl (%ecx),%ebx
  800c40:	84 db                	test   %bl,%bl
  800c42:	75 ec                	jne    800c30 <strlcpy+0x1c>
  800c44:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800c46:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c49:	29 f0                	sub    %esi,%eax
}
  800c4b:	5b                   	pop    %ebx
  800c4c:	5e                   	pop    %esi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c55:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c58:	eb 06                	jmp    800c60 <strcmp+0x11>
		p++, q++;
  800c5a:	83 c1 01             	add    $0x1,%ecx
  800c5d:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800c60:	0f b6 01             	movzbl (%ecx),%eax
  800c63:	84 c0                	test   %al,%al
  800c65:	74 04                	je     800c6b <strcmp+0x1c>
  800c67:	3a 02                	cmp    (%edx),%al
  800c69:	74 ef                	je     800c5a <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c6b:	0f b6 c0             	movzbl %al,%eax
  800c6e:	0f b6 12             	movzbl (%edx),%edx
  800c71:	29 d0                	sub    %edx,%eax
}
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	53                   	push   %ebx
  800c79:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c7f:	89 c3                	mov    %eax,%ebx
  800c81:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c84:	eb 06                	jmp    800c8c <strncmp+0x17>
		n--, p++, q++;
  800c86:	83 c0 01             	add    $0x1,%eax
  800c89:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c8c:	39 d8                	cmp    %ebx,%eax
  800c8e:	74 18                	je     800ca8 <strncmp+0x33>
  800c90:	0f b6 08             	movzbl (%eax),%ecx
  800c93:	84 c9                	test   %cl,%cl
  800c95:	74 04                	je     800c9b <strncmp+0x26>
  800c97:	3a 0a                	cmp    (%edx),%cl
  800c99:	74 eb                	je     800c86 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c9b:	0f b6 00             	movzbl (%eax),%eax
  800c9e:	0f b6 12             	movzbl (%edx),%edx
  800ca1:	29 d0                	sub    %edx,%eax
}
  800ca3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ca6:	c9                   	leave  
  800ca7:	c3                   	ret    
		return 0;
  800ca8:	b8 00 00 00 00       	mov    $0x0,%eax
  800cad:	eb f4                	jmp    800ca3 <strncmp+0x2e>

00800caf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cb9:	eb 03                	jmp    800cbe <strchr+0xf>
  800cbb:	83 c0 01             	add    $0x1,%eax
  800cbe:	0f b6 10             	movzbl (%eax),%edx
  800cc1:	84 d2                	test   %dl,%dl
  800cc3:	74 06                	je     800ccb <strchr+0x1c>
		if (*s == c)
  800cc5:	38 ca                	cmp    %cl,%dl
  800cc7:	75 f2                	jne    800cbb <strchr+0xc>
  800cc9:	eb 05                	jmp    800cd0 <strchr+0x21>
			return (char *) s;
	return 0;
  800ccb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    

00800cd2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cdc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800cdf:	38 ca                	cmp    %cl,%dl
  800ce1:	74 09                	je     800cec <strfind+0x1a>
  800ce3:	84 d2                	test   %dl,%dl
  800ce5:	74 05                	je     800cec <strfind+0x1a>
	for (; *s; s++)
  800ce7:	83 c0 01             	add    $0x1,%eax
  800cea:	eb f0                	jmp    800cdc <strfind+0xa>
			break;
	return (char *) s;
}
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cf7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cfa:	85 c9                	test   %ecx,%ecx
  800cfc:	74 2f                	je     800d2d <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cfe:	89 f8                	mov    %edi,%eax
  800d00:	09 c8                	or     %ecx,%eax
  800d02:	a8 03                	test   $0x3,%al
  800d04:	75 21                	jne    800d27 <memset+0x39>
		c &= 0xFF;
  800d06:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d0a:	89 d0                	mov    %edx,%eax
  800d0c:	c1 e0 08             	shl    $0x8,%eax
  800d0f:	89 d3                	mov    %edx,%ebx
  800d11:	c1 e3 18             	shl    $0x18,%ebx
  800d14:	89 d6                	mov    %edx,%esi
  800d16:	c1 e6 10             	shl    $0x10,%esi
  800d19:	09 f3                	or     %esi,%ebx
  800d1b:	09 da                	or     %ebx,%edx
  800d1d:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d1f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800d22:	fc                   	cld    
  800d23:	f3 ab                	rep stos %eax,%es:(%edi)
  800d25:	eb 06                	jmp    800d2d <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2a:	fc                   	cld    
  800d2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d2d:	89 f8                	mov    %edi,%eax
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d42:	39 c6                	cmp    %eax,%esi
  800d44:	73 32                	jae    800d78 <memmove+0x44>
  800d46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d49:	39 c2                	cmp    %eax,%edx
  800d4b:	76 2b                	jbe    800d78 <memmove+0x44>
		s += n;
		d += n;
  800d4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d50:	89 d6                	mov    %edx,%esi
  800d52:	09 fe                	or     %edi,%esi
  800d54:	09 ce                	or     %ecx,%esi
  800d56:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d5c:	75 0e                	jne    800d6c <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d5e:	83 ef 04             	sub    $0x4,%edi
  800d61:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d64:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d67:	fd                   	std    
  800d68:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d6a:	eb 09                	jmp    800d75 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d6c:	83 ef 01             	sub    $0x1,%edi
  800d6f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d72:	fd                   	std    
  800d73:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d75:	fc                   	cld    
  800d76:	eb 1a                	jmp    800d92 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d78:	89 f2                	mov    %esi,%edx
  800d7a:	09 c2                	or     %eax,%edx
  800d7c:	09 ca                	or     %ecx,%edx
  800d7e:	f6 c2 03             	test   $0x3,%dl
  800d81:	75 0a                	jne    800d8d <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d83:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d86:	89 c7                	mov    %eax,%edi
  800d88:	fc                   	cld    
  800d89:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d8b:	eb 05                	jmp    800d92 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800d8d:	89 c7                	mov    %eax,%edi
  800d8f:	fc                   	cld    
  800d90:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d9c:	ff 75 10             	push   0x10(%ebp)
  800d9f:	ff 75 0c             	push   0xc(%ebp)
  800da2:	ff 75 08             	push   0x8(%ebp)
  800da5:	e8 8a ff ff ff       	call   800d34 <memmove>
}
  800daa:	c9                   	leave  
  800dab:	c3                   	ret    

00800dac <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	8b 45 08             	mov    0x8(%ebp),%eax
  800db4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db7:	89 c6                	mov    %eax,%esi
  800db9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dbc:	eb 06                	jmp    800dc4 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800dbe:	83 c0 01             	add    $0x1,%eax
  800dc1:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800dc4:	39 f0                	cmp    %esi,%eax
  800dc6:	74 14                	je     800ddc <memcmp+0x30>
		if (*s1 != *s2)
  800dc8:	0f b6 08             	movzbl (%eax),%ecx
  800dcb:	0f b6 1a             	movzbl (%edx),%ebx
  800dce:	38 d9                	cmp    %bl,%cl
  800dd0:	74 ec                	je     800dbe <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800dd2:	0f b6 c1             	movzbl %cl,%eax
  800dd5:	0f b6 db             	movzbl %bl,%ebx
  800dd8:	29 d8                	sub    %ebx,%eax
  800dda:	eb 05                	jmp    800de1 <memcmp+0x35>
	}

	return 0;
  800ddc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	8b 45 08             	mov    0x8(%ebp),%eax
  800deb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800dee:	89 c2                	mov    %eax,%edx
  800df0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800df3:	eb 03                	jmp    800df8 <memfind+0x13>
  800df5:	83 c0 01             	add    $0x1,%eax
  800df8:	39 d0                	cmp    %edx,%eax
  800dfa:	73 04                	jae    800e00 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dfc:	38 08                	cmp    %cl,(%eax)
  800dfe:	75 f5                	jne    800df5 <memfind+0x10>
			break;
	return (void *) s;
}
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e0e:	eb 03                	jmp    800e13 <strtol+0x11>
		s++;
  800e10:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800e13:	0f b6 02             	movzbl (%edx),%eax
  800e16:	3c 20                	cmp    $0x20,%al
  800e18:	74 f6                	je     800e10 <strtol+0xe>
  800e1a:	3c 09                	cmp    $0x9,%al
  800e1c:	74 f2                	je     800e10 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800e1e:	3c 2b                	cmp    $0x2b,%al
  800e20:	74 2a                	je     800e4c <strtol+0x4a>
	int neg = 0;
  800e22:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800e27:	3c 2d                	cmp    $0x2d,%al
  800e29:	74 2b                	je     800e56 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e2b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e31:	75 0f                	jne    800e42 <strtol+0x40>
  800e33:	80 3a 30             	cmpb   $0x30,(%edx)
  800e36:	74 28                	je     800e60 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e38:	85 db                	test   %ebx,%ebx
  800e3a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e3f:	0f 44 d8             	cmove  %eax,%ebx
  800e42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e47:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e4a:	eb 46                	jmp    800e92 <strtol+0x90>
		s++;
  800e4c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800e4f:	bf 00 00 00 00       	mov    $0x0,%edi
  800e54:	eb d5                	jmp    800e2b <strtol+0x29>
		s++, neg = 1;
  800e56:	83 c2 01             	add    $0x1,%edx
  800e59:	bf 01 00 00 00       	mov    $0x1,%edi
  800e5e:	eb cb                	jmp    800e2b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e60:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e64:	74 0e                	je     800e74 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800e66:	85 db                	test   %ebx,%ebx
  800e68:	75 d8                	jne    800e42 <strtol+0x40>
		s++, base = 8;
  800e6a:	83 c2 01             	add    $0x1,%edx
  800e6d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800e72:	eb ce                	jmp    800e42 <strtol+0x40>
		s += 2, base = 16;
  800e74:	83 c2 02             	add    $0x2,%edx
  800e77:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e7c:	eb c4                	jmp    800e42 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800e7e:	0f be c0             	movsbl %al,%eax
  800e81:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e84:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e87:	7d 3a                	jge    800ec3 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800e89:	83 c2 01             	add    $0x1,%edx
  800e8c:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800e90:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800e92:	0f b6 02             	movzbl (%edx),%eax
  800e95:	8d 70 d0             	lea    -0x30(%eax),%esi
  800e98:	89 f3                	mov    %esi,%ebx
  800e9a:	80 fb 09             	cmp    $0x9,%bl
  800e9d:	76 df                	jbe    800e7e <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800e9f:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ea2:	89 f3                	mov    %esi,%ebx
  800ea4:	80 fb 19             	cmp    $0x19,%bl
  800ea7:	77 08                	ja     800eb1 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ea9:	0f be c0             	movsbl %al,%eax
  800eac:	83 e8 57             	sub    $0x57,%eax
  800eaf:	eb d3                	jmp    800e84 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800eb1:	8d 70 bf             	lea    -0x41(%eax),%esi
  800eb4:	89 f3                	mov    %esi,%ebx
  800eb6:	80 fb 19             	cmp    $0x19,%bl
  800eb9:	77 08                	ja     800ec3 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ebb:	0f be c0             	movsbl %al,%eax
  800ebe:	83 e8 37             	sub    $0x37,%eax
  800ec1:	eb c1                	jmp    800e84 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ec3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ec7:	74 05                	je     800ece <strtol+0xcc>
		*endptr = (char *) s;
  800ec9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ecc:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ece:	89 c8                	mov    %ecx,%eax
  800ed0:	f7 d8                	neg    %eax
  800ed2:	85 ff                	test   %edi,%edi
  800ed4:	0f 45 c8             	cmovne %eax,%ecx
}
  800ed7:	89 c8                	mov    %ecx,%eax
  800ed9:	5b                   	pop    %ebx
  800eda:	5e                   	pop    %esi
  800edb:	5f                   	pop    %edi
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    

00800ede <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	57                   	push   %edi
  800ee2:	56                   	push   %esi
  800ee3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ee4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eef:	89 c3                	mov    %eax,%ebx
  800ef1:	89 c7                	mov    %eax,%edi
  800ef3:	89 c6                	mov    %eax,%esi
  800ef5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5f                   	pop    %edi
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <sys_cgetc>:

int
sys_cgetc(void)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	57                   	push   %edi
  800f00:	56                   	push   %esi
  800f01:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f02:	ba 00 00 00 00       	mov    $0x0,%edx
  800f07:	b8 01 00 00 00       	mov    $0x1,%eax
  800f0c:	89 d1                	mov    %edx,%ecx
  800f0e:	89 d3                	mov    %edx,%ebx
  800f10:	89 d7                	mov    %edx,%edi
  800f12:	89 d6                	mov    %edx,%esi
  800f14:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f16:	5b                   	pop    %ebx
  800f17:	5e                   	pop    %esi
  800f18:	5f                   	pop    %edi
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    

00800f1b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	57                   	push   %edi
  800f1f:	56                   	push   %esi
  800f20:	53                   	push   %ebx
  800f21:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f24:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f29:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2c:	b8 03 00 00 00       	mov    $0x3,%eax
  800f31:	89 cb                	mov    %ecx,%ebx
  800f33:	89 cf                	mov    %ecx,%edi
  800f35:	89 ce                	mov    %ecx,%esi
  800f37:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	7f 08                	jg     800f45 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f45:	83 ec 0c             	sub    $0xc,%esp
  800f48:	50                   	push   %eax
  800f49:	6a 03                	push   $0x3
  800f4b:	68 df 2a 80 00       	push   $0x802adf
  800f50:	6a 2a                	push   $0x2a
  800f52:	68 fc 2a 80 00       	push   $0x802afc
  800f57:	e8 9e 13 00 00       	call   8022fa <_panic>

00800f5c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	57                   	push   %edi
  800f60:	56                   	push   %esi
  800f61:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f62:	ba 00 00 00 00       	mov    $0x0,%edx
  800f67:	b8 02 00 00 00       	mov    $0x2,%eax
  800f6c:	89 d1                	mov    %edx,%ecx
  800f6e:	89 d3                	mov    %edx,%ebx
  800f70:	89 d7                	mov    %edx,%edi
  800f72:	89 d6                	mov    %edx,%esi
  800f74:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f76:	5b                   	pop    %ebx
  800f77:	5e                   	pop    %esi
  800f78:	5f                   	pop    %edi
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    

00800f7b <sys_yield>:

void
sys_yield(void)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	57                   	push   %edi
  800f7f:	56                   	push   %esi
  800f80:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f81:	ba 00 00 00 00       	mov    $0x0,%edx
  800f86:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f8b:	89 d1                	mov    %edx,%ecx
  800f8d:	89 d3                	mov    %edx,%ebx
  800f8f:	89 d7                	mov    %edx,%edi
  800f91:	89 d6                	mov    %edx,%esi
  800f93:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5f                   	pop    %edi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    

00800f9a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	57                   	push   %edi
  800f9e:	56                   	push   %esi
  800f9f:	53                   	push   %ebx
  800fa0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fa3:	be 00 00 00 00       	mov    $0x0,%esi
  800fa8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fae:	b8 04 00 00 00       	mov    $0x4,%eax
  800fb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fb6:	89 f7                	mov    %esi,%edi
  800fb8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	7f 08                	jg     800fc6 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc1:	5b                   	pop    %ebx
  800fc2:	5e                   	pop    %esi
  800fc3:	5f                   	pop    %edi
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc6:	83 ec 0c             	sub    $0xc,%esp
  800fc9:	50                   	push   %eax
  800fca:	6a 04                	push   $0x4
  800fcc:	68 df 2a 80 00       	push   $0x802adf
  800fd1:	6a 2a                	push   $0x2a
  800fd3:	68 fc 2a 80 00       	push   $0x802afc
  800fd8:	e8 1d 13 00 00       	call   8022fa <_panic>

00800fdd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	57                   	push   %edi
  800fe1:	56                   	push   %esi
  800fe2:	53                   	push   %ebx
  800fe3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fe6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fec:	b8 05 00 00 00       	mov    $0x5,%eax
  800ff1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ff4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ff7:	8b 75 18             	mov    0x18(%ebp),%esi
  800ffa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	7f 08                	jg     801008 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801000:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801003:	5b                   	pop    %ebx
  801004:	5e                   	pop    %esi
  801005:	5f                   	pop    %edi
  801006:	5d                   	pop    %ebp
  801007:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	50                   	push   %eax
  80100c:	6a 05                	push   $0x5
  80100e:	68 df 2a 80 00       	push   $0x802adf
  801013:	6a 2a                	push   $0x2a
  801015:	68 fc 2a 80 00       	push   $0x802afc
  80101a:	e8 db 12 00 00       	call   8022fa <_panic>

0080101f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	57                   	push   %edi
  801023:	56                   	push   %esi
  801024:	53                   	push   %ebx
  801025:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801028:	bb 00 00 00 00       	mov    $0x0,%ebx
  80102d:	8b 55 08             	mov    0x8(%ebp),%edx
  801030:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801033:	b8 06 00 00 00       	mov    $0x6,%eax
  801038:	89 df                	mov    %ebx,%edi
  80103a:	89 de                	mov    %ebx,%esi
  80103c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80103e:	85 c0                	test   %eax,%eax
  801040:	7f 08                	jg     80104a <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801042:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801045:	5b                   	pop    %ebx
  801046:	5e                   	pop    %esi
  801047:	5f                   	pop    %edi
  801048:	5d                   	pop    %ebp
  801049:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	50                   	push   %eax
  80104e:	6a 06                	push   $0x6
  801050:	68 df 2a 80 00       	push   $0x802adf
  801055:	6a 2a                	push   $0x2a
  801057:	68 fc 2a 80 00       	push   $0x802afc
  80105c:	e8 99 12 00 00       	call   8022fa <_panic>

00801061 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	57                   	push   %edi
  801065:	56                   	push   %esi
  801066:	53                   	push   %ebx
  801067:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80106a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80106f:	8b 55 08             	mov    0x8(%ebp),%edx
  801072:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801075:	b8 08 00 00 00       	mov    $0x8,%eax
  80107a:	89 df                	mov    %ebx,%edi
  80107c:	89 de                	mov    %ebx,%esi
  80107e:	cd 30                	int    $0x30
	if(check && ret > 0)
  801080:	85 c0                	test   %eax,%eax
  801082:	7f 08                	jg     80108c <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801084:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801087:	5b                   	pop    %ebx
  801088:	5e                   	pop    %esi
  801089:	5f                   	pop    %edi
  80108a:	5d                   	pop    %ebp
  80108b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80108c:	83 ec 0c             	sub    $0xc,%esp
  80108f:	50                   	push   %eax
  801090:	6a 08                	push   $0x8
  801092:	68 df 2a 80 00       	push   $0x802adf
  801097:	6a 2a                	push   $0x2a
  801099:	68 fc 2a 80 00       	push   $0x802afc
  80109e:	e8 57 12 00 00       	call   8022fa <_panic>

008010a3 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	57                   	push   %edi
  8010a7:	56                   	push   %esi
  8010a8:	53                   	push   %ebx
  8010a9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b7:	b8 09 00 00 00       	mov    $0x9,%eax
  8010bc:	89 df                	mov    %ebx,%edi
  8010be:	89 de                	mov    %ebx,%esi
  8010c0:	cd 30                	int    $0x30
	if(check && ret > 0)
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	7f 08                	jg     8010ce <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c9:	5b                   	pop    %ebx
  8010ca:	5e                   	pop    %esi
  8010cb:	5f                   	pop    %edi
  8010cc:	5d                   	pop    %ebp
  8010cd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ce:	83 ec 0c             	sub    $0xc,%esp
  8010d1:	50                   	push   %eax
  8010d2:	6a 09                	push   $0x9
  8010d4:	68 df 2a 80 00       	push   $0x802adf
  8010d9:	6a 2a                	push   $0x2a
  8010db:	68 fc 2a 80 00       	push   $0x802afc
  8010e0:	e8 15 12 00 00       	call   8022fa <_panic>

008010e5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	57                   	push   %edi
  8010e9:	56                   	push   %esi
  8010ea:	53                   	push   %ebx
  8010eb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010fe:	89 df                	mov    %ebx,%edi
  801100:	89 de                	mov    %ebx,%esi
  801102:	cd 30                	int    $0x30
	if(check && ret > 0)
  801104:	85 c0                	test   %eax,%eax
  801106:	7f 08                	jg     801110 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801108:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110b:	5b                   	pop    %ebx
  80110c:	5e                   	pop    %esi
  80110d:	5f                   	pop    %edi
  80110e:	5d                   	pop    %ebp
  80110f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801110:	83 ec 0c             	sub    $0xc,%esp
  801113:	50                   	push   %eax
  801114:	6a 0a                	push   $0xa
  801116:	68 df 2a 80 00       	push   $0x802adf
  80111b:	6a 2a                	push   $0x2a
  80111d:	68 fc 2a 80 00       	push   $0x802afc
  801122:	e8 d3 11 00 00       	call   8022fa <_panic>

00801127 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	57                   	push   %edi
  80112b:	56                   	push   %esi
  80112c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80112d:	8b 55 08             	mov    0x8(%ebp),%edx
  801130:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801133:	b8 0c 00 00 00       	mov    $0xc,%eax
  801138:	be 00 00 00 00       	mov    $0x0,%esi
  80113d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801140:	8b 7d 14             	mov    0x14(%ebp),%edi
  801143:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801145:	5b                   	pop    %ebx
  801146:	5e                   	pop    %esi
  801147:	5f                   	pop    %edi
  801148:	5d                   	pop    %ebp
  801149:	c3                   	ret    

0080114a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
  80114d:	57                   	push   %edi
  80114e:	56                   	push   %esi
  80114f:	53                   	push   %ebx
  801150:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801153:	b9 00 00 00 00       	mov    $0x0,%ecx
  801158:	8b 55 08             	mov    0x8(%ebp),%edx
  80115b:	b8 0d 00 00 00       	mov    $0xd,%eax
  801160:	89 cb                	mov    %ecx,%ebx
  801162:	89 cf                	mov    %ecx,%edi
  801164:	89 ce                	mov    %ecx,%esi
  801166:	cd 30                	int    $0x30
	if(check && ret > 0)
  801168:	85 c0                	test   %eax,%eax
  80116a:	7f 08                	jg     801174 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80116c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116f:	5b                   	pop    %ebx
  801170:	5e                   	pop    %esi
  801171:	5f                   	pop    %edi
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801174:	83 ec 0c             	sub    $0xc,%esp
  801177:	50                   	push   %eax
  801178:	6a 0d                	push   $0xd
  80117a:	68 df 2a 80 00       	push   $0x802adf
  80117f:	6a 2a                	push   $0x2a
  801181:	68 fc 2a 80 00       	push   $0x802afc
  801186:	e8 6f 11 00 00       	call   8022fa <_panic>

0080118b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80118b:	55                   	push   %ebp
  80118c:	89 e5                	mov    %esp,%ebp
  80118e:	57                   	push   %edi
  80118f:	56                   	push   %esi
  801190:	53                   	push   %ebx
	asm volatile("int %1\n"
  801191:	ba 00 00 00 00       	mov    $0x0,%edx
  801196:	b8 0e 00 00 00       	mov    $0xe,%eax
  80119b:	89 d1                	mov    %edx,%ecx
  80119d:	89 d3                	mov    %edx,%ebx
  80119f:	89 d7                	mov    %edx,%edi
  8011a1:	89 d6                	mov    %edx,%esi
  8011a3:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8011a5:	5b                   	pop    %ebx
  8011a6:	5e                   	pop    %esi
  8011a7:	5f                   	pop    %edi
  8011a8:	5d                   	pop    %ebp
  8011a9:	c3                   	ret    

008011aa <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	57                   	push   %edi
  8011ae:	56                   	push   %esi
  8011af:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bb:	b8 0f 00 00 00       	mov    $0xf,%eax
  8011c0:	89 df                	mov    %ebx,%edi
  8011c2:	89 de                	mov    %ebx,%esi
  8011c4:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  8011c6:	5b                   	pop    %ebx
  8011c7:	5e                   	pop    %esi
  8011c8:	5f                   	pop    %edi
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    

008011cb <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	57                   	push   %edi
  8011cf:	56                   	push   %esi
  8011d0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011dc:	b8 10 00 00 00       	mov    $0x10,%eax
  8011e1:	89 df                	mov    %ebx,%edi
  8011e3:	89 de                	mov    %ebx,%esi
  8011e5:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8011e7:	5b                   	pop    %ebx
  8011e8:	5e                   	pop    %esi
  8011e9:	5f                   	pop    %edi
  8011ea:	5d                   	pop    %ebp
  8011eb:	c3                   	ret    

008011ec <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f2:	05 00 00 00 30       	add    $0x30000000,%eax
  8011f7:	c1 e8 0c             	shr    $0xc,%eax
}
  8011fa:	5d                   	pop    %ebp
  8011fb:	c3                   	ret    

008011fc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801202:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801207:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80120c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801211:	5d                   	pop    %ebp
  801212:	c3                   	ret    

00801213 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
  801216:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80121b:	89 c2                	mov    %eax,%edx
  80121d:	c1 ea 16             	shr    $0x16,%edx
  801220:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801227:	f6 c2 01             	test   $0x1,%dl
  80122a:	74 29                	je     801255 <fd_alloc+0x42>
  80122c:	89 c2                	mov    %eax,%edx
  80122e:	c1 ea 0c             	shr    $0xc,%edx
  801231:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801238:	f6 c2 01             	test   $0x1,%dl
  80123b:	74 18                	je     801255 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80123d:	05 00 10 00 00       	add    $0x1000,%eax
  801242:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801247:	75 d2                	jne    80121b <fd_alloc+0x8>
  801249:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80124e:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801253:	eb 05                	jmp    80125a <fd_alloc+0x47>
			return 0;
  801255:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80125a:	8b 55 08             	mov    0x8(%ebp),%edx
  80125d:	89 02                	mov    %eax,(%edx)
}
  80125f:	89 c8                	mov    %ecx,%eax
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    

00801263 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801269:	83 f8 1f             	cmp    $0x1f,%eax
  80126c:	77 30                	ja     80129e <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80126e:	c1 e0 0c             	shl    $0xc,%eax
  801271:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801276:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80127c:	f6 c2 01             	test   $0x1,%dl
  80127f:	74 24                	je     8012a5 <fd_lookup+0x42>
  801281:	89 c2                	mov    %eax,%edx
  801283:	c1 ea 0c             	shr    $0xc,%edx
  801286:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80128d:	f6 c2 01             	test   $0x1,%dl
  801290:	74 1a                	je     8012ac <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801292:	8b 55 0c             	mov    0xc(%ebp),%edx
  801295:	89 02                	mov    %eax,(%edx)
	return 0;
  801297:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    
		return -E_INVAL;
  80129e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a3:	eb f7                	jmp    80129c <fd_lookup+0x39>
		return -E_INVAL;
  8012a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012aa:	eb f0                	jmp    80129c <fd_lookup+0x39>
  8012ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b1:	eb e9                	jmp    80129c <fd_lookup+0x39>

008012b3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	53                   	push   %ebx
  8012b7:	83 ec 04             	sub    $0x4,%esp
  8012ba:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c2:	bb 08 30 80 00       	mov    $0x803008,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8012c7:	39 13                	cmp    %edx,(%ebx)
  8012c9:	74 37                	je     801302 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8012cb:	83 c0 01             	add    $0x1,%eax
  8012ce:	8b 1c 85 88 2b 80 00 	mov    0x802b88(,%eax,4),%ebx
  8012d5:	85 db                	test   %ebx,%ebx
  8012d7:	75 ee                	jne    8012c7 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012d9:	a1 10 40 80 00       	mov    0x804010,%eax
  8012de:	8b 40 58             	mov    0x58(%eax),%eax
  8012e1:	83 ec 04             	sub    $0x4,%esp
  8012e4:	52                   	push   %edx
  8012e5:	50                   	push   %eax
  8012e6:	68 0c 2b 80 00       	push   $0x802b0c
  8012eb:	e8 d4 f2 ff ff       	call   8005c4 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8012f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012fb:	89 1a                	mov    %ebx,(%edx)
}
  8012fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801300:	c9                   	leave  
  801301:	c3                   	ret    
			return 0;
  801302:	b8 00 00 00 00       	mov    $0x0,%eax
  801307:	eb ef                	jmp    8012f8 <dev_lookup+0x45>

00801309 <fd_close>:
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	57                   	push   %edi
  80130d:	56                   	push   %esi
  80130e:	53                   	push   %ebx
  80130f:	83 ec 24             	sub    $0x24,%esp
  801312:	8b 75 08             	mov    0x8(%ebp),%esi
  801315:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801318:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80131b:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80131c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801322:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801325:	50                   	push   %eax
  801326:	e8 38 ff ff ff       	call   801263 <fd_lookup>
  80132b:	89 c3                	mov    %eax,%ebx
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	85 c0                	test   %eax,%eax
  801332:	78 05                	js     801339 <fd_close+0x30>
	    || fd != fd2)
  801334:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801337:	74 16                	je     80134f <fd_close+0x46>
		return (must_exist ? r : 0);
  801339:	89 f8                	mov    %edi,%eax
  80133b:	84 c0                	test   %al,%al
  80133d:	b8 00 00 00 00       	mov    $0x0,%eax
  801342:	0f 44 d8             	cmove  %eax,%ebx
}
  801345:	89 d8                	mov    %ebx,%eax
  801347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80134a:	5b                   	pop    %ebx
  80134b:	5e                   	pop    %esi
  80134c:	5f                   	pop    %edi
  80134d:	5d                   	pop    %ebp
  80134e:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80134f:	83 ec 08             	sub    $0x8,%esp
  801352:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801355:	50                   	push   %eax
  801356:	ff 36                	push   (%esi)
  801358:	e8 56 ff ff ff       	call   8012b3 <dev_lookup>
  80135d:	89 c3                	mov    %eax,%ebx
  80135f:	83 c4 10             	add    $0x10,%esp
  801362:	85 c0                	test   %eax,%eax
  801364:	78 1a                	js     801380 <fd_close+0x77>
		if (dev->dev_close)
  801366:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801369:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80136c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801371:	85 c0                	test   %eax,%eax
  801373:	74 0b                	je     801380 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801375:	83 ec 0c             	sub    $0xc,%esp
  801378:	56                   	push   %esi
  801379:	ff d0                	call   *%eax
  80137b:	89 c3                	mov    %eax,%ebx
  80137d:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801380:	83 ec 08             	sub    $0x8,%esp
  801383:	56                   	push   %esi
  801384:	6a 00                	push   $0x0
  801386:	e8 94 fc ff ff       	call   80101f <sys_page_unmap>
	return r;
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	eb b5                	jmp    801345 <fd_close+0x3c>

00801390 <close>:

int
close(int fdnum)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801396:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801399:	50                   	push   %eax
  80139a:	ff 75 08             	push   0x8(%ebp)
  80139d:	e8 c1 fe ff ff       	call   801263 <fd_lookup>
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	79 02                	jns    8013ab <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8013a9:	c9                   	leave  
  8013aa:	c3                   	ret    
		return fd_close(fd, 1);
  8013ab:	83 ec 08             	sub    $0x8,%esp
  8013ae:	6a 01                	push   $0x1
  8013b0:	ff 75 f4             	push   -0xc(%ebp)
  8013b3:	e8 51 ff ff ff       	call   801309 <fd_close>
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	eb ec                	jmp    8013a9 <close+0x19>

008013bd <close_all>:

void
close_all(void)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	53                   	push   %ebx
  8013c1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013c4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013c9:	83 ec 0c             	sub    $0xc,%esp
  8013cc:	53                   	push   %ebx
  8013cd:	e8 be ff ff ff       	call   801390 <close>
	for (i = 0; i < MAXFD; i++)
  8013d2:	83 c3 01             	add    $0x1,%ebx
  8013d5:	83 c4 10             	add    $0x10,%esp
  8013d8:	83 fb 20             	cmp    $0x20,%ebx
  8013db:	75 ec                	jne    8013c9 <close_all+0xc>
}
  8013dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e0:	c9                   	leave  
  8013e1:	c3                   	ret    

008013e2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013e2:	55                   	push   %ebp
  8013e3:	89 e5                	mov    %esp,%ebp
  8013e5:	57                   	push   %edi
  8013e6:	56                   	push   %esi
  8013e7:	53                   	push   %ebx
  8013e8:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013eb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013ee:	50                   	push   %eax
  8013ef:	ff 75 08             	push   0x8(%ebp)
  8013f2:	e8 6c fe ff ff       	call   801263 <fd_lookup>
  8013f7:	89 c3                	mov    %eax,%ebx
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	85 c0                	test   %eax,%eax
  8013fe:	78 7f                	js     80147f <dup+0x9d>
		return r;
	close(newfdnum);
  801400:	83 ec 0c             	sub    $0xc,%esp
  801403:	ff 75 0c             	push   0xc(%ebp)
  801406:	e8 85 ff ff ff       	call   801390 <close>

	newfd = INDEX2FD(newfdnum);
  80140b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80140e:	c1 e6 0c             	shl    $0xc,%esi
  801411:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80141a:	89 3c 24             	mov    %edi,(%esp)
  80141d:	e8 da fd ff ff       	call   8011fc <fd2data>
  801422:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801424:	89 34 24             	mov    %esi,(%esp)
  801427:	e8 d0 fd ff ff       	call   8011fc <fd2data>
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801432:	89 d8                	mov    %ebx,%eax
  801434:	c1 e8 16             	shr    $0x16,%eax
  801437:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80143e:	a8 01                	test   $0x1,%al
  801440:	74 11                	je     801453 <dup+0x71>
  801442:	89 d8                	mov    %ebx,%eax
  801444:	c1 e8 0c             	shr    $0xc,%eax
  801447:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80144e:	f6 c2 01             	test   $0x1,%dl
  801451:	75 36                	jne    801489 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801453:	89 f8                	mov    %edi,%eax
  801455:	c1 e8 0c             	shr    $0xc,%eax
  801458:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80145f:	83 ec 0c             	sub    $0xc,%esp
  801462:	25 07 0e 00 00       	and    $0xe07,%eax
  801467:	50                   	push   %eax
  801468:	56                   	push   %esi
  801469:	6a 00                	push   $0x0
  80146b:	57                   	push   %edi
  80146c:	6a 00                	push   $0x0
  80146e:	e8 6a fb ff ff       	call   800fdd <sys_page_map>
  801473:	89 c3                	mov    %eax,%ebx
  801475:	83 c4 20             	add    $0x20,%esp
  801478:	85 c0                	test   %eax,%eax
  80147a:	78 33                	js     8014af <dup+0xcd>
		goto err;

	return newfdnum;
  80147c:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80147f:	89 d8                	mov    %ebx,%eax
  801481:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801484:	5b                   	pop    %ebx
  801485:	5e                   	pop    %esi
  801486:	5f                   	pop    %edi
  801487:	5d                   	pop    %ebp
  801488:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801489:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801490:	83 ec 0c             	sub    $0xc,%esp
  801493:	25 07 0e 00 00       	and    $0xe07,%eax
  801498:	50                   	push   %eax
  801499:	ff 75 d4             	push   -0x2c(%ebp)
  80149c:	6a 00                	push   $0x0
  80149e:	53                   	push   %ebx
  80149f:	6a 00                	push   $0x0
  8014a1:	e8 37 fb ff ff       	call   800fdd <sys_page_map>
  8014a6:	89 c3                	mov    %eax,%ebx
  8014a8:	83 c4 20             	add    $0x20,%esp
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	79 a4                	jns    801453 <dup+0x71>
	sys_page_unmap(0, newfd);
  8014af:	83 ec 08             	sub    $0x8,%esp
  8014b2:	56                   	push   %esi
  8014b3:	6a 00                	push   $0x0
  8014b5:	e8 65 fb ff ff       	call   80101f <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014ba:	83 c4 08             	add    $0x8,%esp
  8014bd:	ff 75 d4             	push   -0x2c(%ebp)
  8014c0:	6a 00                	push   $0x0
  8014c2:	e8 58 fb ff ff       	call   80101f <sys_page_unmap>
	return r;
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	eb b3                	jmp    80147f <dup+0x9d>

008014cc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	56                   	push   %esi
  8014d0:	53                   	push   %ebx
  8014d1:	83 ec 18             	sub    $0x18,%esp
  8014d4:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014da:	50                   	push   %eax
  8014db:	56                   	push   %esi
  8014dc:	e8 82 fd ff ff       	call   801263 <fd_lookup>
  8014e1:	83 c4 10             	add    $0x10,%esp
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	78 3c                	js     801524 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e8:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8014eb:	83 ec 08             	sub    $0x8,%esp
  8014ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f1:	50                   	push   %eax
  8014f2:	ff 33                	push   (%ebx)
  8014f4:	e8 ba fd ff ff       	call   8012b3 <dev_lookup>
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	78 24                	js     801524 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801500:	8b 43 08             	mov    0x8(%ebx),%eax
  801503:	83 e0 03             	and    $0x3,%eax
  801506:	83 f8 01             	cmp    $0x1,%eax
  801509:	74 20                	je     80152b <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80150b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150e:	8b 40 08             	mov    0x8(%eax),%eax
  801511:	85 c0                	test   %eax,%eax
  801513:	74 37                	je     80154c <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801515:	83 ec 04             	sub    $0x4,%esp
  801518:	ff 75 10             	push   0x10(%ebp)
  80151b:	ff 75 0c             	push   0xc(%ebp)
  80151e:	53                   	push   %ebx
  80151f:	ff d0                	call   *%eax
  801521:	83 c4 10             	add    $0x10,%esp
}
  801524:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801527:	5b                   	pop    %ebx
  801528:	5e                   	pop    %esi
  801529:	5d                   	pop    %ebp
  80152a:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80152b:	a1 10 40 80 00       	mov    0x804010,%eax
  801530:	8b 40 58             	mov    0x58(%eax),%eax
  801533:	83 ec 04             	sub    $0x4,%esp
  801536:	56                   	push   %esi
  801537:	50                   	push   %eax
  801538:	68 4d 2b 80 00       	push   $0x802b4d
  80153d:	e8 82 f0 ff ff       	call   8005c4 <cprintf>
		return -E_INVAL;
  801542:	83 c4 10             	add    $0x10,%esp
  801545:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80154a:	eb d8                	jmp    801524 <read+0x58>
		return -E_NOT_SUPP;
  80154c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801551:	eb d1                	jmp    801524 <read+0x58>

00801553 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	57                   	push   %edi
  801557:	56                   	push   %esi
  801558:	53                   	push   %ebx
  801559:	83 ec 0c             	sub    $0xc,%esp
  80155c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80155f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801562:	bb 00 00 00 00       	mov    $0x0,%ebx
  801567:	eb 02                	jmp    80156b <readn+0x18>
  801569:	01 c3                	add    %eax,%ebx
  80156b:	39 f3                	cmp    %esi,%ebx
  80156d:	73 21                	jae    801590 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80156f:	83 ec 04             	sub    $0x4,%esp
  801572:	89 f0                	mov    %esi,%eax
  801574:	29 d8                	sub    %ebx,%eax
  801576:	50                   	push   %eax
  801577:	89 d8                	mov    %ebx,%eax
  801579:	03 45 0c             	add    0xc(%ebp),%eax
  80157c:	50                   	push   %eax
  80157d:	57                   	push   %edi
  80157e:	e8 49 ff ff ff       	call   8014cc <read>
		if (m < 0)
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	85 c0                	test   %eax,%eax
  801588:	78 04                	js     80158e <readn+0x3b>
			return m;
		if (m == 0)
  80158a:	75 dd                	jne    801569 <readn+0x16>
  80158c:	eb 02                	jmp    801590 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80158e:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801590:	89 d8                	mov    %ebx,%eax
  801592:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801595:	5b                   	pop    %ebx
  801596:	5e                   	pop    %esi
  801597:	5f                   	pop    %edi
  801598:	5d                   	pop    %ebp
  801599:	c3                   	ret    

0080159a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	56                   	push   %esi
  80159e:	53                   	push   %ebx
  80159f:	83 ec 18             	sub    $0x18,%esp
  8015a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a8:	50                   	push   %eax
  8015a9:	53                   	push   %ebx
  8015aa:	e8 b4 fc ff ff       	call   801263 <fd_lookup>
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	78 37                	js     8015ed <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015b9:	83 ec 08             	sub    $0x8,%esp
  8015bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bf:	50                   	push   %eax
  8015c0:	ff 36                	push   (%esi)
  8015c2:	e8 ec fc ff ff       	call   8012b3 <dev_lookup>
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	85 c0                	test   %eax,%eax
  8015cc:	78 1f                	js     8015ed <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ce:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8015d2:	74 20                	je     8015f4 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	74 37                	je     801615 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015de:	83 ec 04             	sub    $0x4,%esp
  8015e1:	ff 75 10             	push   0x10(%ebp)
  8015e4:	ff 75 0c             	push   0xc(%ebp)
  8015e7:	56                   	push   %esi
  8015e8:	ff d0                	call   *%eax
  8015ea:	83 c4 10             	add    $0x10,%esp
}
  8015ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f0:	5b                   	pop    %ebx
  8015f1:	5e                   	pop    %esi
  8015f2:	5d                   	pop    %ebp
  8015f3:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f4:	a1 10 40 80 00       	mov    0x804010,%eax
  8015f9:	8b 40 58             	mov    0x58(%eax),%eax
  8015fc:	83 ec 04             	sub    $0x4,%esp
  8015ff:	53                   	push   %ebx
  801600:	50                   	push   %eax
  801601:	68 69 2b 80 00       	push   $0x802b69
  801606:	e8 b9 ef ff ff       	call   8005c4 <cprintf>
		return -E_INVAL;
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801613:	eb d8                	jmp    8015ed <write+0x53>
		return -E_NOT_SUPP;
  801615:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80161a:	eb d1                	jmp    8015ed <write+0x53>

0080161c <seek>:

int
seek(int fdnum, off_t offset)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801622:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801625:	50                   	push   %eax
  801626:	ff 75 08             	push   0x8(%ebp)
  801629:	e8 35 fc ff ff       	call   801263 <fd_lookup>
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	85 c0                	test   %eax,%eax
  801633:	78 0e                	js     801643 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801635:	8b 55 0c             	mov    0xc(%ebp),%edx
  801638:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80163b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80163e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801643:	c9                   	leave  
  801644:	c3                   	ret    

00801645 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	56                   	push   %esi
  801649:	53                   	push   %ebx
  80164a:	83 ec 18             	sub    $0x18,%esp
  80164d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801650:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801653:	50                   	push   %eax
  801654:	53                   	push   %ebx
  801655:	e8 09 fc ff ff       	call   801263 <fd_lookup>
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	85 c0                	test   %eax,%eax
  80165f:	78 34                	js     801695 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801661:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801664:	83 ec 08             	sub    $0x8,%esp
  801667:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166a:	50                   	push   %eax
  80166b:	ff 36                	push   (%esi)
  80166d:	e8 41 fc ff ff       	call   8012b3 <dev_lookup>
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	85 c0                	test   %eax,%eax
  801677:	78 1c                	js     801695 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801679:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80167d:	74 1d                	je     80169c <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80167f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801682:	8b 40 18             	mov    0x18(%eax),%eax
  801685:	85 c0                	test   %eax,%eax
  801687:	74 34                	je     8016bd <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801689:	83 ec 08             	sub    $0x8,%esp
  80168c:	ff 75 0c             	push   0xc(%ebp)
  80168f:	56                   	push   %esi
  801690:	ff d0                	call   *%eax
  801692:	83 c4 10             	add    $0x10,%esp
}
  801695:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801698:	5b                   	pop    %ebx
  801699:	5e                   	pop    %esi
  80169a:	5d                   	pop    %ebp
  80169b:	c3                   	ret    
			thisenv->env_id, fdnum);
  80169c:	a1 10 40 80 00       	mov    0x804010,%eax
  8016a1:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016a4:	83 ec 04             	sub    $0x4,%esp
  8016a7:	53                   	push   %ebx
  8016a8:	50                   	push   %eax
  8016a9:	68 2c 2b 80 00       	push   $0x802b2c
  8016ae:	e8 11 ef ff ff       	call   8005c4 <cprintf>
		return -E_INVAL;
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016bb:	eb d8                	jmp    801695 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8016bd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016c2:	eb d1                	jmp    801695 <ftruncate+0x50>

008016c4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	56                   	push   %esi
  8016c8:	53                   	push   %ebx
  8016c9:	83 ec 18             	sub    $0x18,%esp
  8016cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d2:	50                   	push   %eax
  8016d3:	ff 75 08             	push   0x8(%ebp)
  8016d6:	e8 88 fb ff ff       	call   801263 <fd_lookup>
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	78 49                	js     80172b <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8016e5:	83 ec 08             	sub    $0x8,%esp
  8016e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016eb:	50                   	push   %eax
  8016ec:	ff 36                	push   (%esi)
  8016ee:	e8 c0 fb ff ff       	call   8012b3 <dev_lookup>
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	78 31                	js     80172b <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8016fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016fd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801701:	74 2f                	je     801732 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801703:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801706:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80170d:	00 00 00 
	stat->st_isdir = 0;
  801710:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801717:	00 00 00 
	stat->st_dev = dev;
  80171a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801720:	83 ec 08             	sub    $0x8,%esp
  801723:	53                   	push   %ebx
  801724:	56                   	push   %esi
  801725:	ff 50 14             	call   *0x14(%eax)
  801728:	83 c4 10             	add    $0x10,%esp
}
  80172b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172e:	5b                   	pop    %ebx
  80172f:	5e                   	pop    %esi
  801730:	5d                   	pop    %ebp
  801731:	c3                   	ret    
		return -E_NOT_SUPP;
  801732:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801737:	eb f2                	jmp    80172b <fstat+0x67>

00801739 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	56                   	push   %esi
  80173d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80173e:	83 ec 08             	sub    $0x8,%esp
  801741:	6a 00                	push   $0x0
  801743:	ff 75 08             	push   0x8(%ebp)
  801746:	e8 e4 01 00 00       	call   80192f <open>
  80174b:	89 c3                	mov    %eax,%ebx
  80174d:	83 c4 10             	add    $0x10,%esp
  801750:	85 c0                	test   %eax,%eax
  801752:	78 1b                	js     80176f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801754:	83 ec 08             	sub    $0x8,%esp
  801757:	ff 75 0c             	push   0xc(%ebp)
  80175a:	50                   	push   %eax
  80175b:	e8 64 ff ff ff       	call   8016c4 <fstat>
  801760:	89 c6                	mov    %eax,%esi
	close(fd);
  801762:	89 1c 24             	mov    %ebx,(%esp)
  801765:	e8 26 fc ff ff       	call   801390 <close>
	return r;
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	89 f3                	mov    %esi,%ebx
}
  80176f:	89 d8                	mov    %ebx,%eax
  801771:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801774:	5b                   	pop    %ebx
  801775:	5e                   	pop    %esi
  801776:	5d                   	pop    %ebp
  801777:	c3                   	ret    

00801778 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	56                   	push   %esi
  80177c:	53                   	push   %ebx
  80177d:	89 c6                	mov    %eax,%esi
  80177f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801781:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801788:	74 27                	je     8017b1 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80178a:	6a 07                	push   $0x7
  80178c:	68 00 50 80 00       	push   $0x805000
  801791:	56                   	push   %esi
  801792:	ff 35 00 60 80 00    	push   0x806000
  801798:	e8 13 0c 00 00       	call   8023b0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80179d:	83 c4 0c             	add    $0xc,%esp
  8017a0:	6a 00                	push   $0x0
  8017a2:	53                   	push   %ebx
  8017a3:	6a 00                	push   $0x0
  8017a5:	e8 96 0b 00 00       	call   802340 <ipc_recv>
}
  8017aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ad:	5b                   	pop    %ebx
  8017ae:	5e                   	pop    %esi
  8017af:	5d                   	pop    %ebp
  8017b0:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017b1:	83 ec 0c             	sub    $0xc,%esp
  8017b4:	6a 01                	push   $0x1
  8017b6:	e8 49 0c 00 00       	call   802404 <ipc_find_env>
  8017bb:	a3 00 60 80 00       	mov    %eax,0x806000
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	eb c5                	jmp    80178a <fsipc+0x12>

008017c5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017de:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e3:	b8 02 00 00 00       	mov    $0x2,%eax
  8017e8:	e8 8b ff ff ff       	call   801778 <fsipc>
}
  8017ed:	c9                   	leave  
  8017ee:	c3                   	ret    

008017ef <devfile_flush>:
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017fb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801800:	ba 00 00 00 00       	mov    $0x0,%edx
  801805:	b8 06 00 00 00       	mov    $0x6,%eax
  80180a:	e8 69 ff ff ff       	call   801778 <fsipc>
}
  80180f:	c9                   	leave  
  801810:	c3                   	ret    

00801811 <devfile_stat>:
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	53                   	push   %ebx
  801815:	83 ec 04             	sub    $0x4,%esp
  801818:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80181b:	8b 45 08             	mov    0x8(%ebp),%eax
  80181e:	8b 40 0c             	mov    0xc(%eax),%eax
  801821:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801826:	ba 00 00 00 00       	mov    $0x0,%edx
  80182b:	b8 05 00 00 00       	mov    $0x5,%eax
  801830:	e8 43 ff ff ff       	call   801778 <fsipc>
  801835:	85 c0                	test   %eax,%eax
  801837:	78 2c                	js     801865 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801839:	83 ec 08             	sub    $0x8,%esp
  80183c:	68 00 50 80 00       	push   $0x805000
  801841:	53                   	push   %ebx
  801842:	e8 57 f3 ff ff       	call   800b9e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801847:	a1 80 50 80 00       	mov    0x805080,%eax
  80184c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801852:	a1 84 50 80 00       	mov    0x805084,%eax
  801857:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80185d:	83 c4 10             	add    $0x10,%esp
  801860:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801865:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801868:	c9                   	leave  
  801869:	c3                   	ret    

0080186a <devfile_write>:
{
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	83 ec 0c             	sub    $0xc,%esp
  801870:	8b 45 10             	mov    0x10(%ebp),%eax
  801873:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801878:	39 d0                	cmp    %edx,%eax
  80187a:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80187d:	8b 55 08             	mov    0x8(%ebp),%edx
  801880:	8b 52 0c             	mov    0xc(%edx),%edx
  801883:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801889:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80188e:	50                   	push   %eax
  80188f:	ff 75 0c             	push   0xc(%ebp)
  801892:	68 08 50 80 00       	push   $0x805008
  801897:	e8 98 f4 ff ff       	call   800d34 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80189c:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a1:	b8 04 00 00 00       	mov    $0x4,%eax
  8018a6:	e8 cd fe ff ff       	call   801778 <fsipc>
}
  8018ab:	c9                   	leave  
  8018ac:	c3                   	ret    

008018ad <devfile_read>:
{
  8018ad:	55                   	push   %ebp
  8018ae:	89 e5                	mov    %esp,%ebp
  8018b0:	56                   	push   %esi
  8018b1:	53                   	push   %ebx
  8018b2:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018bb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018c0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cb:	b8 03 00 00 00       	mov    $0x3,%eax
  8018d0:	e8 a3 fe ff ff       	call   801778 <fsipc>
  8018d5:	89 c3                	mov    %eax,%ebx
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	78 1f                	js     8018fa <devfile_read+0x4d>
	assert(r <= n);
  8018db:	39 f0                	cmp    %esi,%eax
  8018dd:	77 24                	ja     801903 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8018df:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018e4:	7f 33                	jg     801919 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018e6:	83 ec 04             	sub    $0x4,%esp
  8018e9:	50                   	push   %eax
  8018ea:	68 00 50 80 00       	push   $0x805000
  8018ef:	ff 75 0c             	push   0xc(%ebp)
  8018f2:	e8 3d f4 ff ff       	call   800d34 <memmove>
	return r;
  8018f7:	83 c4 10             	add    $0x10,%esp
}
  8018fa:	89 d8                	mov    %ebx,%eax
  8018fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ff:	5b                   	pop    %ebx
  801900:	5e                   	pop    %esi
  801901:	5d                   	pop    %ebp
  801902:	c3                   	ret    
	assert(r <= n);
  801903:	68 9c 2b 80 00       	push   $0x802b9c
  801908:	68 a3 2b 80 00       	push   $0x802ba3
  80190d:	6a 7c                	push   $0x7c
  80190f:	68 b8 2b 80 00       	push   $0x802bb8
  801914:	e8 e1 09 00 00       	call   8022fa <_panic>
	assert(r <= PGSIZE);
  801919:	68 c3 2b 80 00       	push   $0x802bc3
  80191e:	68 a3 2b 80 00       	push   $0x802ba3
  801923:	6a 7d                	push   $0x7d
  801925:	68 b8 2b 80 00       	push   $0x802bb8
  80192a:	e8 cb 09 00 00       	call   8022fa <_panic>

0080192f <open>:
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	56                   	push   %esi
  801933:	53                   	push   %ebx
  801934:	83 ec 1c             	sub    $0x1c,%esp
  801937:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80193a:	56                   	push   %esi
  80193b:	e8 23 f2 ff ff       	call   800b63 <strlen>
  801940:	83 c4 10             	add    $0x10,%esp
  801943:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801948:	7f 6c                	jg     8019b6 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80194a:	83 ec 0c             	sub    $0xc,%esp
  80194d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801950:	50                   	push   %eax
  801951:	e8 bd f8 ff ff       	call   801213 <fd_alloc>
  801956:	89 c3                	mov    %eax,%ebx
  801958:	83 c4 10             	add    $0x10,%esp
  80195b:	85 c0                	test   %eax,%eax
  80195d:	78 3c                	js     80199b <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80195f:	83 ec 08             	sub    $0x8,%esp
  801962:	56                   	push   %esi
  801963:	68 00 50 80 00       	push   $0x805000
  801968:	e8 31 f2 ff ff       	call   800b9e <strcpy>
	fsipcbuf.open.req_omode = mode;
  80196d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801970:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801975:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801978:	b8 01 00 00 00       	mov    $0x1,%eax
  80197d:	e8 f6 fd ff ff       	call   801778 <fsipc>
  801982:	89 c3                	mov    %eax,%ebx
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	85 c0                	test   %eax,%eax
  801989:	78 19                	js     8019a4 <open+0x75>
	return fd2num(fd);
  80198b:	83 ec 0c             	sub    $0xc,%esp
  80198e:	ff 75 f4             	push   -0xc(%ebp)
  801991:	e8 56 f8 ff ff       	call   8011ec <fd2num>
  801996:	89 c3                	mov    %eax,%ebx
  801998:	83 c4 10             	add    $0x10,%esp
}
  80199b:	89 d8                	mov    %ebx,%eax
  80199d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a0:	5b                   	pop    %ebx
  8019a1:	5e                   	pop    %esi
  8019a2:	5d                   	pop    %ebp
  8019a3:	c3                   	ret    
		fd_close(fd, 0);
  8019a4:	83 ec 08             	sub    $0x8,%esp
  8019a7:	6a 00                	push   $0x0
  8019a9:	ff 75 f4             	push   -0xc(%ebp)
  8019ac:	e8 58 f9 ff ff       	call   801309 <fd_close>
		return r;
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	eb e5                	jmp    80199b <open+0x6c>
		return -E_BAD_PATH;
  8019b6:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019bb:	eb de                	jmp    80199b <open+0x6c>

008019bd <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c8:	b8 08 00 00 00       	mov    $0x8,%eax
  8019cd:	e8 a6 fd ff ff       	call   801778 <fsipc>
}
  8019d2:	c9                   	leave  
  8019d3:	c3                   	ret    

008019d4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019da:	68 cf 2b 80 00       	push   $0x802bcf
  8019df:	ff 75 0c             	push   0xc(%ebp)
  8019e2:	e8 b7 f1 ff ff       	call   800b9e <strcpy>
	return 0;
}
  8019e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ec:	c9                   	leave  
  8019ed:	c3                   	ret    

008019ee <devsock_close>:
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	53                   	push   %ebx
  8019f2:	83 ec 10             	sub    $0x10,%esp
  8019f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019f8:	53                   	push   %ebx
  8019f9:	e8 45 0a 00 00       	call   802443 <pageref>
  8019fe:	89 c2                	mov    %eax,%edx
  801a00:	83 c4 10             	add    $0x10,%esp
		return 0;
  801a03:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801a08:	83 fa 01             	cmp    $0x1,%edx
  801a0b:	74 05                	je     801a12 <devsock_close+0x24>
}
  801a0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a10:	c9                   	leave  
  801a11:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801a12:	83 ec 0c             	sub    $0xc,%esp
  801a15:	ff 73 0c             	push   0xc(%ebx)
  801a18:	e8 b7 02 00 00       	call   801cd4 <nsipc_close>
  801a1d:	83 c4 10             	add    $0x10,%esp
  801a20:	eb eb                	jmp    801a0d <devsock_close+0x1f>

00801a22 <devsock_write>:
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a28:	6a 00                	push   $0x0
  801a2a:	ff 75 10             	push   0x10(%ebp)
  801a2d:	ff 75 0c             	push   0xc(%ebp)
  801a30:	8b 45 08             	mov    0x8(%ebp),%eax
  801a33:	ff 70 0c             	push   0xc(%eax)
  801a36:	e8 79 03 00 00       	call   801db4 <nsipc_send>
}
  801a3b:	c9                   	leave  
  801a3c:	c3                   	ret    

00801a3d <devsock_read>:
{
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a43:	6a 00                	push   $0x0
  801a45:	ff 75 10             	push   0x10(%ebp)
  801a48:	ff 75 0c             	push   0xc(%ebp)
  801a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4e:	ff 70 0c             	push   0xc(%eax)
  801a51:	e8 ef 02 00 00       	call   801d45 <nsipc_recv>
}
  801a56:	c9                   	leave  
  801a57:	c3                   	ret    

00801a58 <fd2sockid>:
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a5e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a61:	52                   	push   %edx
  801a62:	50                   	push   %eax
  801a63:	e8 fb f7 ff ff       	call   801263 <fd_lookup>
  801a68:	83 c4 10             	add    $0x10,%esp
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	78 10                	js     801a7f <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a72:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  801a78:	39 08                	cmp    %ecx,(%eax)
  801a7a:	75 05                	jne    801a81 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801a7c:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801a7f:	c9                   	leave  
  801a80:	c3                   	ret    
		return -E_NOT_SUPP;
  801a81:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a86:	eb f7                	jmp    801a7f <fd2sockid+0x27>

00801a88 <alloc_sockfd>:
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	56                   	push   %esi
  801a8c:	53                   	push   %ebx
  801a8d:	83 ec 1c             	sub    $0x1c,%esp
  801a90:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801a92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a95:	50                   	push   %eax
  801a96:	e8 78 f7 ff ff       	call   801213 <fd_alloc>
  801a9b:	89 c3                	mov    %eax,%ebx
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	78 43                	js     801ae7 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801aa4:	83 ec 04             	sub    $0x4,%esp
  801aa7:	68 07 04 00 00       	push   $0x407
  801aac:	ff 75 f4             	push   -0xc(%ebp)
  801aaf:	6a 00                	push   $0x0
  801ab1:	e8 e4 f4 ff ff       	call   800f9a <sys_page_alloc>
  801ab6:	89 c3                	mov    %eax,%ebx
  801ab8:	83 c4 10             	add    $0x10,%esp
  801abb:	85 c0                	test   %eax,%eax
  801abd:	78 28                	js     801ae7 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac2:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801ac8:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ad4:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ad7:	83 ec 0c             	sub    $0xc,%esp
  801ada:	50                   	push   %eax
  801adb:	e8 0c f7 ff ff       	call   8011ec <fd2num>
  801ae0:	89 c3                	mov    %eax,%ebx
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	eb 0c                	jmp    801af3 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801ae7:	83 ec 0c             	sub    $0xc,%esp
  801aea:	56                   	push   %esi
  801aeb:	e8 e4 01 00 00       	call   801cd4 <nsipc_close>
		return r;
  801af0:	83 c4 10             	add    $0x10,%esp
}
  801af3:	89 d8                	mov    %ebx,%eax
  801af5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af8:	5b                   	pop    %ebx
  801af9:	5e                   	pop    %esi
  801afa:	5d                   	pop    %ebp
  801afb:	c3                   	ret    

00801afc <accept>:
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b02:	8b 45 08             	mov    0x8(%ebp),%eax
  801b05:	e8 4e ff ff ff       	call   801a58 <fd2sockid>
  801b0a:	85 c0                	test   %eax,%eax
  801b0c:	78 1b                	js     801b29 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b0e:	83 ec 04             	sub    $0x4,%esp
  801b11:	ff 75 10             	push   0x10(%ebp)
  801b14:	ff 75 0c             	push   0xc(%ebp)
  801b17:	50                   	push   %eax
  801b18:	e8 0e 01 00 00       	call   801c2b <nsipc_accept>
  801b1d:	83 c4 10             	add    $0x10,%esp
  801b20:	85 c0                	test   %eax,%eax
  801b22:	78 05                	js     801b29 <accept+0x2d>
	return alloc_sockfd(r);
  801b24:	e8 5f ff ff ff       	call   801a88 <alloc_sockfd>
}
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    

00801b2b <bind>:
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b31:	8b 45 08             	mov    0x8(%ebp),%eax
  801b34:	e8 1f ff ff ff       	call   801a58 <fd2sockid>
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	78 12                	js     801b4f <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801b3d:	83 ec 04             	sub    $0x4,%esp
  801b40:	ff 75 10             	push   0x10(%ebp)
  801b43:	ff 75 0c             	push   0xc(%ebp)
  801b46:	50                   	push   %eax
  801b47:	e8 31 01 00 00       	call   801c7d <nsipc_bind>
  801b4c:	83 c4 10             	add    $0x10,%esp
}
  801b4f:	c9                   	leave  
  801b50:	c3                   	ret    

00801b51 <shutdown>:
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b57:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5a:	e8 f9 fe ff ff       	call   801a58 <fd2sockid>
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	78 0f                	js     801b72 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801b63:	83 ec 08             	sub    $0x8,%esp
  801b66:	ff 75 0c             	push   0xc(%ebp)
  801b69:	50                   	push   %eax
  801b6a:	e8 43 01 00 00       	call   801cb2 <nsipc_shutdown>
  801b6f:	83 c4 10             	add    $0x10,%esp
}
  801b72:	c9                   	leave  
  801b73:	c3                   	ret    

00801b74 <connect>:
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7d:	e8 d6 fe ff ff       	call   801a58 <fd2sockid>
  801b82:	85 c0                	test   %eax,%eax
  801b84:	78 12                	js     801b98 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801b86:	83 ec 04             	sub    $0x4,%esp
  801b89:	ff 75 10             	push   0x10(%ebp)
  801b8c:	ff 75 0c             	push   0xc(%ebp)
  801b8f:	50                   	push   %eax
  801b90:	e8 59 01 00 00       	call   801cee <nsipc_connect>
  801b95:	83 c4 10             	add    $0x10,%esp
}
  801b98:	c9                   	leave  
  801b99:	c3                   	ret    

00801b9a <listen>:
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba3:	e8 b0 fe ff ff       	call   801a58 <fd2sockid>
  801ba8:	85 c0                	test   %eax,%eax
  801baa:	78 0f                	js     801bbb <listen+0x21>
	return nsipc_listen(r, backlog);
  801bac:	83 ec 08             	sub    $0x8,%esp
  801baf:	ff 75 0c             	push   0xc(%ebp)
  801bb2:	50                   	push   %eax
  801bb3:	e8 6b 01 00 00       	call   801d23 <nsipc_listen>
  801bb8:	83 c4 10             	add    $0x10,%esp
}
  801bbb:	c9                   	leave  
  801bbc:	c3                   	ret    

00801bbd <socket>:

int
socket(int domain, int type, int protocol)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bc3:	ff 75 10             	push   0x10(%ebp)
  801bc6:	ff 75 0c             	push   0xc(%ebp)
  801bc9:	ff 75 08             	push   0x8(%ebp)
  801bcc:	e8 41 02 00 00       	call   801e12 <nsipc_socket>
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	78 05                	js     801bdd <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bd8:	e8 ab fe ff ff       	call   801a88 <alloc_sockfd>
}
  801bdd:	c9                   	leave  
  801bde:	c3                   	ret    

00801bdf <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	53                   	push   %ebx
  801be3:	83 ec 04             	sub    $0x4,%esp
  801be6:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801be8:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801bef:	74 26                	je     801c17 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bf1:	6a 07                	push   $0x7
  801bf3:	68 00 70 80 00       	push   $0x807000
  801bf8:	53                   	push   %ebx
  801bf9:	ff 35 00 80 80 00    	push   0x808000
  801bff:	e8 ac 07 00 00       	call   8023b0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c04:	83 c4 0c             	add    $0xc,%esp
  801c07:	6a 00                	push   $0x0
  801c09:	6a 00                	push   $0x0
  801c0b:	6a 00                	push   $0x0
  801c0d:	e8 2e 07 00 00       	call   802340 <ipc_recv>
}
  801c12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c15:	c9                   	leave  
  801c16:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c17:	83 ec 0c             	sub    $0xc,%esp
  801c1a:	6a 02                	push   $0x2
  801c1c:	e8 e3 07 00 00       	call   802404 <ipc_find_env>
  801c21:	a3 00 80 80 00       	mov    %eax,0x808000
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	eb c6                	jmp    801bf1 <nsipc+0x12>

00801c2b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	56                   	push   %esi
  801c2f:	53                   	push   %ebx
  801c30:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c33:	8b 45 08             	mov    0x8(%ebp),%eax
  801c36:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c3b:	8b 06                	mov    (%esi),%eax
  801c3d:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c42:	b8 01 00 00 00       	mov    $0x1,%eax
  801c47:	e8 93 ff ff ff       	call   801bdf <nsipc>
  801c4c:	89 c3                	mov    %eax,%ebx
  801c4e:	85 c0                	test   %eax,%eax
  801c50:	79 09                	jns    801c5b <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801c52:	89 d8                	mov    %ebx,%eax
  801c54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c57:	5b                   	pop    %ebx
  801c58:	5e                   	pop    %esi
  801c59:	5d                   	pop    %ebp
  801c5a:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c5b:	83 ec 04             	sub    $0x4,%esp
  801c5e:	ff 35 10 70 80 00    	push   0x807010
  801c64:	68 00 70 80 00       	push   $0x807000
  801c69:	ff 75 0c             	push   0xc(%ebp)
  801c6c:	e8 c3 f0 ff ff       	call   800d34 <memmove>
		*addrlen = ret->ret_addrlen;
  801c71:	a1 10 70 80 00       	mov    0x807010,%eax
  801c76:	89 06                	mov    %eax,(%esi)
  801c78:	83 c4 10             	add    $0x10,%esp
	return r;
  801c7b:	eb d5                	jmp    801c52 <nsipc_accept+0x27>

00801c7d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c7d:	55                   	push   %ebp
  801c7e:	89 e5                	mov    %esp,%ebp
  801c80:	53                   	push   %ebx
  801c81:	83 ec 08             	sub    $0x8,%esp
  801c84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c87:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8a:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c8f:	53                   	push   %ebx
  801c90:	ff 75 0c             	push   0xc(%ebp)
  801c93:	68 04 70 80 00       	push   $0x807004
  801c98:	e8 97 f0 ff ff       	call   800d34 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c9d:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801ca3:	b8 02 00 00 00       	mov    $0x2,%eax
  801ca8:	e8 32 ff ff ff       	call   801bdf <nsipc>
}
  801cad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cb0:	c9                   	leave  
  801cb1:	c3                   	ret    

00801cb2 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801cc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc3:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801cc8:	b8 03 00 00 00       	mov    $0x3,%eax
  801ccd:	e8 0d ff ff ff       	call   801bdf <nsipc>
}
  801cd2:	c9                   	leave  
  801cd3:	c3                   	ret    

00801cd4 <nsipc_close>:

int
nsipc_close(int s)
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cda:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdd:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801ce2:	b8 04 00 00 00       	mov    $0x4,%eax
  801ce7:	e8 f3 fe ff ff       	call   801bdf <nsipc>
}
  801cec:	c9                   	leave  
  801ced:	c3                   	ret    

00801cee <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	53                   	push   %ebx
  801cf2:	83 ec 08             	sub    $0x8,%esp
  801cf5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfb:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d00:	53                   	push   %ebx
  801d01:	ff 75 0c             	push   0xc(%ebp)
  801d04:	68 04 70 80 00       	push   $0x807004
  801d09:	e8 26 f0 ff ff       	call   800d34 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d0e:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801d14:	b8 05 00 00 00       	mov    $0x5,%eax
  801d19:	e8 c1 fe ff ff       	call   801bdf <nsipc>
}
  801d1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d21:	c9                   	leave  
  801d22:	c3                   	ret    

00801d23 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d29:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801d31:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d34:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801d39:	b8 06 00 00 00       	mov    $0x6,%eax
  801d3e:	e8 9c fe ff ff       	call   801bdf <nsipc>
}
  801d43:	c9                   	leave  
  801d44:	c3                   	ret    

00801d45 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
  801d48:	56                   	push   %esi
  801d49:	53                   	push   %ebx
  801d4a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d50:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801d55:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801d5b:	8b 45 14             	mov    0x14(%ebp),%eax
  801d5e:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d63:	b8 07 00 00 00       	mov    $0x7,%eax
  801d68:	e8 72 fe ff ff       	call   801bdf <nsipc>
  801d6d:	89 c3                	mov    %eax,%ebx
  801d6f:	85 c0                	test   %eax,%eax
  801d71:	78 22                	js     801d95 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801d73:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801d78:	39 c6                	cmp    %eax,%esi
  801d7a:	0f 4e c6             	cmovle %esi,%eax
  801d7d:	39 c3                	cmp    %eax,%ebx
  801d7f:	7f 1d                	jg     801d9e <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d81:	83 ec 04             	sub    $0x4,%esp
  801d84:	53                   	push   %ebx
  801d85:	68 00 70 80 00       	push   $0x807000
  801d8a:	ff 75 0c             	push   0xc(%ebp)
  801d8d:	e8 a2 ef ff ff       	call   800d34 <memmove>
  801d92:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d95:	89 d8                	mov    %ebx,%eax
  801d97:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d9a:	5b                   	pop    %ebx
  801d9b:	5e                   	pop    %esi
  801d9c:	5d                   	pop    %ebp
  801d9d:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801d9e:	68 db 2b 80 00       	push   $0x802bdb
  801da3:	68 a3 2b 80 00       	push   $0x802ba3
  801da8:	6a 62                	push   $0x62
  801daa:	68 f0 2b 80 00       	push   $0x802bf0
  801daf:	e8 46 05 00 00       	call   8022fa <_panic>

00801db4 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	53                   	push   %ebx
  801db8:	83 ec 04             	sub    $0x4,%esp
  801dbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc1:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801dc6:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dcc:	7f 2e                	jg     801dfc <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801dce:	83 ec 04             	sub    $0x4,%esp
  801dd1:	53                   	push   %ebx
  801dd2:	ff 75 0c             	push   0xc(%ebp)
  801dd5:	68 0c 70 80 00       	push   $0x80700c
  801dda:	e8 55 ef ff ff       	call   800d34 <memmove>
	nsipcbuf.send.req_size = size;
  801ddf:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801de5:	8b 45 14             	mov    0x14(%ebp),%eax
  801de8:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801ded:	b8 08 00 00 00       	mov    $0x8,%eax
  801df2:	e8 e8 fd ff ff       	call   801bdf <nsipc>
}
  801df7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dfa:	c9                   	leave  
  801dfb:	c3                   	ret    
	assert(size < 1600);
  801dfc:	68 fc 2b 80 00       	push   $0x802bfc
  801e01:	68 a3 2b 80 00       	push   $0x802ba3
  801e06:	6a 6d                	push   $0x6d
  801e08:	68 f0 2b 80 00       	push   $0x802bf0
  801e0d:	e8 e8 04 00 00       	call   8022fa <_panic>

00801e12 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e18:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801e20:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e23:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801e28:	8b 45 10             	mov    0x10(%ebp),%eax
  801e2b:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801e30:	b8 09 00 00 00       	mov    $0x9,%eax
  801e35:	e8 a5 fd ff ff       	call   801bdf <nsipc>
}
  801e3a:	c9                   	leave  
  801e3b:	c3                   	ret    

00801e3c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	56                   	push   %esi
  801e40:	53                   	push   %ebx
  801e41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e44:	83 ec 0c             	sub    $0xc,%esp
  801e47:	ff 75 08             	push   0x8(%ebp)
  801e4a:	e8 ad f3 ff ff       	call   8011fc <fd2data>
  801e4f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e51:	83 c4 08             	add    $0x8,%esp
  801e54:	68 08 2c 80 00       	push   $0x802c08
  801e59:	53                   	push   %ebx
  801e5a:	e8 3f ed ff ff       	call   800b9e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e5f:	8b 46 04             	mov    0x4(%esi),%eax
  801e62:	2b 06                	sub    (%esi),%eax
  801e64:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e6a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e71:	00 00 00 
	stat->st_dev = &devpipe;
  801e74:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801e7b:	30 80 00 
	return 0;
}
  801e7e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e86:	5b                   	pop    %ebx
  801e87:	5e                   	pop    %esi
  801e88:	5d                   	pop    %ebp
  801e89:	c3                   	ret    

00801e8a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e8a:	55                   	push   %ebp
  801e8b:	89 e5                	mov    %esp,%ebp
  801e8d:	53                   	push   %ebx
  801e8e:	83 ec 0c             	sub    $0xc,%esp
  801e91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e94:	53                   	push   %ebx
  801e95:	6a 00                	push   $0x0
  801e97:	e8 83 f1 ff ff       	call   80101f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e9c:	89 1c 24             	mov    %ebx,(%esp)
  801e9f:	e8 58 f3 ff ff       	call   8011fc <fd2data>
  801ea4:	83 c4 08             	add    $0x8,%esp
  801ea7:	50                   	push   %eax
  801ea8:	6a 00                	push   $0x0
  801eaa:	e8 70 f1 ff ff       	call   80101f <sys_page_unmap>
}
  801eaf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eb2:	c9                   	leave  
  801eb3:	c3                   	ret    

00801eb4 <_pipeisclosed>:
{
  801eb4:	55                   	push   %ebp
  801eb5:	89 e5                	mov    %esp,%ebp
  801eb7:	57                   	push   %edi
  801eb8:	56                   	push   %esi
  801eb9:	53                   	push   %ebx
  801eba:	83 ec 1c             	sub    $0x1c,%esp
  801ebd:	89 c7                	mov    %eax,%edi
  801ebf:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801ec1:	a1 10 40 80 00       	mov    0x804010,%eax
  801ec6:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ec9:	83 ec 0c             	sub    $0xc,%esp
  801ecc:	57                   	push   %edi
  801ecd:	e8 71 05 00 00       	call   802443 <pageref>
  801ed2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ed5:	89 34 24             	mov    %esi,(%esp)
  801ed8:	e8 66 05 00 00       	call   802443 <pageref>
		nn = thisenv->env_runs;
  801edd:	8b 15 10 40 80 00    	mov    0x804010,%edx
  801ee3:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801ee6:	83 c4 10             	add    $0x10,%esp
  801ee9:	39 cb                	cmp    %ecx,%ebx
  801eeb:	74 1b                	je     801f08 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801eed:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ef0:	75 cf                	jne    801ec1 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ef2:	8b 42 68             	mov    0x68(%edx),%eax
  801ef5:	6a 01                	push   $0x1
  801ef7:	50                   	push   %eax
  801ef8:	53                   	push   %ebx
  801ef9:	68 0f 2c 80 00       	push   $0x802c0f
  801efe:	e8 c1 e6 ff ff       	call   8005c4 <cprintf>
  801f03:	83 c4 10             	add    $0x10,%esp
  801f06:	eb b9                	jmp    801ec1 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801f08:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f0b:	0f 94 c0             	sete   %al
  801f0e:	0f b6 c0             	movzbl %al,%eax
}
  801f11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f14:	5b                   	pop    %ebx
  801f15:	5e                   	pop    %esi
  801f16:	5f                   	pop    %edi
  801f17:	5d                   	pop    %ebp
  801f18:	c3                   	ret    

00801f19 <devpipe_write>:
{
  801f19:	55                   	push   %ebp
  801f1a:	89 e5                	mov    %esp,%ebp
  801f1c:	57                   	push   %edi
  801f1d:	56                   	push   %esi
  801f1e:	53                   	push   %ebx
  801f1f:	83 ec 28             	sub    $0x28,%esp
  801f22:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801f25:	56                   	push   %esi
  801f26:	e8 d1 f2 ff ff       	call   8011fc <fd2data>
  801f2b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f2d:	83 c4 10             	add    $0x10,%esp
  801f30:	bf 00 00 00 00       	mov    $0x0,%edi
  801f35:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f38:	75 09                	jne    801f43 <devpipe_write+0x2a>
	return i;
  801f3a:	89 f8                	mov    %edi,%eax
  801f3c:	eb 23                	jmp    801f61 <devpipe_write+0x48>
			sys_yield();
  801f3e:	e8 38 f0 ff ff       	call   800f7b <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f43:	8b 43 04             	mov    0x4(%ebx),%eax
  801f46:	8b 0b                	mov    (%ebx),%ecx
  801f48:	8d 51 20             	lea    0x20(%ecx),%edx
  801f4b:	39 d0                	cmp    %edx,%eax
  801f4d:	72 1a                	jb     801f69 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801f4f:	89 da                	mov    %ebx,%edx
  801f51:	89 f0                	mov    %esi,%eax
  801f53:	e8 5c ff ff ff       	call   801eb4 <_pipeisclosed>
  801f58:	85 c0                	test   %eax,%eax
  801f5a:	74 e2                	je     801f3e <devpipe_write+0x25>
				return 0;
  801f5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f64:	5b                   	pop    %ebx
  801f65:	5e                   	pop    %esi
  801f66:	5f                   	pop    %edi
  801f67:	5d                   	pop    %ebp
  801f68:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f6c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f70:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f73:	89 c2                	mov    %eax,%edx
  801f75:	c1 fa 1f             	sar    $0x1f,%edx
  801f78:	89 d1                	mov    %edx,%ecx
  801f7a:	c1 e9 1b             	shr    $0x1b,%ecx
  801f7d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f80:	83 e2 1f             	and    $0x1f,%edx
  801f83:	29 ca                	sub    %ecx,%edx
  801f85:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f89:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f8d:	83 c0 01             	add    $0x1,%eax
  801f90:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801f93:	83 c7 01             	add    $0x1,%edi
  801f96:	eb 9d                	jmp    801f35 <devpipe_write+0x1c>

00801f98 <devpipe_read>:
{
  801f98:	55                   	push   %ebp
  801f99:	89 e5                	mov    %esp,%ebp
  801f9b:	57                   	push   %edi
  801f9c:	56                   	push   %esi
  801f9d:	53                   	push   %ebx
  801f9e:	83 ec 18             	sub    $0x18,%esp
  801fa1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801fa4:	57                   	push   %edi
  801fa5:	e8 52 f2 ff ff       	call   8011fc <fd2data>
  801faa:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801fac:	83 c4 10             	add    $0x10,%esp
  801faf:	be 00 00 00 00       	mov    $0x0,%esi
  801fb4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fb7:	75 13                	jne    801fcc <devpipe_read+0x34>
	return i;
  801fb9:	89 f0                	mov    %esi,%eax
  801fbb:	eb 02                	jmp    801fbf <devpipe_read+0x27>
				return i;
  801fbd:	89 f0                	mov    %esi,%eax
}
  801fbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc2:	5b                   	pop    %ebx
  801fc3:	5e                   	pop    %esi
  801fc4:	5f                   	pop    %edi
  801fc5:	5d                   	pop    %ebp
  801fc6:	c3                   	ret    
			sys_yield();
  801fc7:	e8 af ef ff ff       	call   800f7b <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801fcc:	8b 03                	mov    (%ebx),%eax
  801fce:	3b 43 04             	cmp    0x4(%ebx),%eax
  801fd1:	75 18                	jne    801feb <devpipe_read+0x53>
			if (i > 0)
  801fd3:	85 f6                	test   %esi,%esi
  801fd5:	75 e6                	jne    801fbd <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801fd7:	89 da                	mov    %ebx,%edx
  801fd9:	89 f8                	mov    %edi,%eax
  801fdb:	e8 d4 fe ff ff       	call   801eb4 <_pipeisclosed>
  801fe0:	85 c0                	test   %eax,%eax
  801fe2:	74 e3                	je     801fc7 <devpipe_read+0x2f>
				return 0;
  801fe4:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe9:	eb d4                	jmp    801fbf <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801feb:	99                   	cltd   
  801fec:	c1 ea 1b             	shr    $0x1b,%edx
  801fef:	01 d0                	add    %edx,%eax
  801ff1:	83 e0 1f             	and    $0x1f,%eax
  801ff4:	29 d0                	sub    %edx,%eax
  801ff6:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ffb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ffe:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802001:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802004:	83 c6 01             	add    $0x1,%esi
  802007:	eb ab                	jmp    801fb4 <devpipe_read+0x1c>

00802009 <pipe>:
{
  802009:	55                   	push   %ebp
  80200a:	89 e5                	mov    %esp,%ebp
  80200c:	56                   	push   %esi
  80200d:	53                   	push   %ebx
  80200e:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802011:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802014:	50                   	push   %eax
  802015:	e8 f9 f1 ff ff       	call   801213 <fd_alloc>
  80201a:	89 c3                	mov    %eax,%ebx
  80201c:	83 c4 10             	add    $0x10,%esp
  80201f:	85 c0                	test   %eax,%eax
  802021:	0f 88 23 01 00 00    	js     80214a <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802027:	83 ec 04             	sub    $0x4,%esp
  80202a:	68 07 04 00 00       	push   $0x407
  80202f:	ff 75 f4             	push   -0xc(%ebp)
  802032:	6a 00                	push   $0x0
  802034:	e8 61 ef ff ff       	call   800f9a <sys_page_alloc>
  802039:	89 c3                	mov    %eax,%ebx
  80203b:	83 c4 10             	add    $0x10,%esp
  80203e:	85 c0                	test   %eax,%eax
  802040:	0f 88 04 01 00 00    	js     80214a <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802046:	83 ec 0c             	sub    $0xc,%esp
  802049:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80204c:	50                   	push   %eax
  80204d:	e8 c1 f1 ff ff       	call   801213 <fd_alloc>
  802052:	89 c3                	mov    %eax,%ebx
  802054:	83 c4 10             	add    $0x10,%esp
  802057:	85 c0                	test   %eax,%eax
  802059:	0f 88 db 00 00 00    	js     80213a <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80205f:	83 ec 04             	sub    $0x4,%esp
  802062:	68 07 04 00 00       	push   $0x407
  802067:	ff 75 f0             	push   -0x10(%ebp)
  80206a:	6a 00                	push   $0x0
  80206c:	e8 29 ef ff ff       	call   800f9a <sys_page_alloc>
  802071:	89 c3                	mov    %eax,%ebx
  802073:	83 c4 10             	add    $0x10,%esp
  802076:	85 c0                	test   %eax,%eax
  802078:	0f 88 bc 00 00 00    	js     80213a <pipe+0x131>
	va = fd2data(fd0);
  80207e:	83 ec 0c             	sub    $0xc,%esp
  802081:	ff 75 f4             	push   -0xc(%ebp)
  802084:	e8 73 f1 ff ff       	call   8011fc <fd2data>
  802089:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80208b:	83 c4 0c             	add    $0xc,%esp
  80208e:	68 07 04 00 00       	push   $0x407
  802093:	50                   	push   %eax
  802094:	6a 00                	push   $0x0
  802096:	e8 ff ee ff ff       	call   800f9a <sys_page_alloc>
  80209b:	89 c3                	mov    %eax,%ebx
  80209d:	83 c4 10             	add    $0x10,%esp
  8020a0:	85 c0                	test   %eax,%eax
  8020a2:	0f 88 82 00 00 00    	js     80212a <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020a8:	83 ec 0c             	sub    $0xc,%esp
  8020ab:	ff 75 f0             	push   -0x10(%ebp)
  8020ae:	e8 49 f1 ff ff       	call   8011fc <fd2data>
  8020b3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020ba:	50                   	push   %eax
  8020bb:	6a 00                	push   $0x0
  8020bd:	56                   	push   %esi
  8020be:	6a 00                	push   $0x0
  8020c0:	e8 18 ef ff ff       	call   800fdd <sys_page_map>
  8020c5:	89 c3                	mov    %eax,%ebx
  8020c7:	83 c4 20             	add    $0x20,%esp
  8020ca:	85 c0                	test   %eax,%eax
  8020cc:	78 4e                	js     80211c <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8020ce:	a1 40 30 80 00       	mov    0x803040,%eax
  8020d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020d6:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8020d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020db:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8020e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020e5:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8020e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020ea:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8020f1:	83 ec 0c             	sub    $0xc,%esp
  8020f4:	ff 75 f4             	push   -0xc(%ebp)
  8020f7:	e8 f0 f0 ff ff       	call   8011ec <fd2num>
  8020fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020ff:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802101:	83 c4 04             	add    $0x4,%esp
  802104:	ff 75 f0             	push   -0x10(%ebp)
  802107:	e8 e0 f0 ff ff       	call   8011ec <fd2num>
  80210c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80210f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802112:	83 c4 10             	add    $0x10,%esp
  802115:	bb 00 00 00 00       	mov    $0x0,%ebx
  80211a:	eb 2e                	jmp    80214a <pipe+0x141>
	sys_page_unmap(0, va);
  80211c:	83 ec 08             	sub    $0x8,%esp
  80211f:	56                   	push   %esi
  802120:	6a 00                	push   $0x0
  802122:	e8 f8 ee ff ff       	call   80101f <sys_page_unmap>
  802127:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80212a:	83 ec 08             	sub    $0x8,%esp
  80212d:	ff 75 f0             	push   -0x10(%ebp)
  802130:	6a 00                	push   $0x0
  802132:	e8 e8 ee ff ff       	call   80101f <sys_page_unmap>
  802137:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80213a:	83 ec 08             	sub    $0x8,%esp
  80213d:	ff 75 f4             	push   -0xc(%ebp)
  802140:	6a 00                	push   $0x0
  802142:	e8 d8 ee ff ff       	call   80101f <sys_page_unmap>
  802147:	83 c4 10             	add    $0x10,%esp
}
  80214a:	89 d8                	mov    %ebx,%eax
  80214c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80214f:	5b                   	pop    %ebx
  802150:	5e                   	pop    %esi
  802151:	5d                   	pop    %ebp
  802152:	c3                   	ret    

00802153 <pipeisclosed>:
{
  802153:	55                   	push   %ebp
  802154:	89 e5                	mov    %esp,%ebp
  802156:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802159:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80215c:	50                   	push   %eax
  80215d:	ff 75 08             	push   0x8(%ebp)
  802160:	e8 fe f0 ff ff       	call   801263 <fd_lookup>
  802165:	83 c4 10             	add    $0x10,%esp
  802168:	85 c0                	test   %eax,%eax
  80216a:	78 18                	js     802184 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80216c:	83 ec 0c             	sub    $0xc,%esp
  80216f:	ff 75 f4             	push   -0xc(%ebp)
  802172:	e8 85 f0 ff ff       	call   8011fc <fd2data>
  802177:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802179:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80217c:	e8 33 fd ff ff       	call   801eb4 <_pipeisclosed>
  802181:	83 c4 10             	add    $0x10,%esp
}
  802184:	c9                   	leave  
  802185:	c3                   	ret    

00802186 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802186:	b8 00 00 00 00       	mov    $0x0,%eax
  80218b:	c3                   	ret    

0080218c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802192:	68 27 2c 80 00       	push   $0x802c27
  802197:	ff 75 0c             	push   0xc(%ebp)
  80219a:	e8 ff e9 ff ff       	call   800b9e <strcpy>
	return 0;
}
  80219f:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a4:	c9                   	leave  
  8021a5:	c3                   	ret    

008021a6 <devcons_write>:
{
  8021a6:	55                   	push   %ebp
  8021a7:	89 e5                	mov    %esp,%ebp
  8021a9:	57                   	push   %edi
  8021aa:	56                   	push   %esi
  8021ab:	53                   	push   %ebx
  8021ac:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8021b2:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8021b7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8021bd:	eb 2e                	jmp    8021ed <devcons_write+0x47>
		m = n - tot;
  8021bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021c2:	29 f3                	sub    %esi,%ebx
  8021c4:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8021c9:	39 c3                	cmp    %eax,%ebx
  8021cb:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8021ce:	83 ec 04             	sub    $0x4,%esp
  8021d1:	53                   	push   %ebx
  8021d2:	89 f0                	mov    %esi,%eax
  8021d4:	03 45 0c             	add    0xc(%ebp),%eax
  8021d7:	50                   	push   %eax
  8021d8:	57                   	push   %edi
  8021d9:	e8 56 eb ff ff       	call   800d34 <memmove>
		sys_cputs(buf, m);
  8021de:	83 c4 08             	add    $0x8,%esp
  8021e1:	53                   	push   %ebx
  8021e2:	57                   	push   %edi
  8021e3:	e8 f6 ec ff ff       	call   800ede <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8021e8:	01 de                	add    %ebx,%esi
  8021ea:	83 c4 10             	add    $0x10,%esp
  8021ed:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021f0:	72 cd                	jb     8021bf <devcons_write+0x19>
}
  8021f2:	89 f0                	mov    %esi,%eax
  8021f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021f7:	5b                   	pop    %ebx
  8021f8:	5e                   	pop    %esi
  8021f9:	5f                   	pop    %edi
  8021fa:	5d                   	pop    %ebp
  8021fb:	c3                   	ret    

008021fc <devcons_read>:
{
  8021fc:	55                   	push   %ebp
  8021fd:	89 e5                	mov    %esp,%ebp
  8021ff:	83 ec 08             	sub    $0x8,%esp
  802202:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802207:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80220b:	75 07                	jne    802214 <devcons_read+0x18>
  80220d:	eb 1f                	jmp    80222e <devcons_read+0x32>
		sys_yield();
  80220f:	e8 67 ed ff ff       	call   800f7b <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802214:	e8 e3 ec ff ff       	call   800efc <sys_cgetc>
  802219:	85 c0                	test   %eax,%eax
  80221b:	74 f2                	je     80220f <devcons_read+0x13>
	if (c < 0)
  80221d:	78 0f                	js     80222e <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  80221f:	83 f8 04             	cmp    $0x4,%eax
  802222:	74 0c                	je     802230 <devcons_read+0x34>
	*(char*)vbuf = c;
  802224:	8b 55 0c             	mov    0xc(%ebp),%edx
  802227:	88 02                	mov    %al,(%edx)
	return 1;
  802229:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80222e:	c9                   	leave  
  80222f:	c3                   	ret    
		return 0;
  802230:	b8 00 00 00 00       	mov    $0x0,%eax
  802235:	eb f7                	jmp    80222e <devcons_read+0x32>

00802237 <cputchar>:
{
  802237:	55                   	push   %ebp
  802238:	89 e5                	mov    %esp,%ebp
  80223a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80223d:	8b 45 08             	mov    0x8(%ebp),%eax
  802240:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802243:	6a 01                	push   $0x1
  802245:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802248:	50                   	push   %eax
  802249:	e8 90 ec ff ff       	call   800ede <sys_cputs>
}
  80224e:	83 c4 10             	add    $0x10,%esp
  802251:	c9                   	leave  
  802252:	c3                   	ret    

00802253 <getchar>:
{
  802253:	55                   	push   %ebp
  802254:	89 e5                	mov    %esp,%ebp
  802256:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802259:	6a 01                	push   $0x1
  80225b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80225e:	50                   	push   %eax
  80225f:	6a 00                	push   $0x0
  802261:	e8 66 f2 ff ff       	call   8014cc <read>
	if (r < 0)
  802266:	83 c4 10             	add    $0x10,%esp
  802269:	85 c0                	test   %eax,%eax
  80226b:	78 06                	js     802273 <getchar+0x20>
	if (r < 1)
  80226d:	74 06                	je     802275 <getchar+0x22>
	return c;
  80226f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802273:	c9                   	leave  
  802274:	c3                   	ret    
		return -E_EOF;
  802275:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80227a:	eb f7                	jmp    802273 <getchar+0x20>

0080227c <iscons>:
{
  80227c:	55                   	push   %ebp
  80227d:	89 e5                	mov    %esp,%ebp
  80227f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802282:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802285:	50                   	push   %eax
  802286:	ff 75 08             	push   0x8(%ebp)
  802289:	e8 d5 ef ff ff       	call   801263 <fd_lookup>
  80228e:	83 c4 10             	add    $0x10,%esp
  802291:	85 c0                	test   %eax,%eax
  802293:	78 11                	js     8022a6 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802295:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802298:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  80229e:	39 10                	cmp    %edx,(%eax)
  8022a0:	0f 94 c0             	sete   %al
  8022a3:	0f b6 c0             	movzbl %al,%eax
}
  8022a6:	c9                   	leave  
  8022a7:	c3                   	ret    

008022a8 <opencons>:
{
  8022a8:	55                   	push   %ebp
  8022a9:	89 e5                	mov    %esp,%ebp
  8022ab:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8022ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022b1:	50                   	push   %eax
  8022b2:	e8 5c ef ff ff       	call   801213 <fd_alloc>
  8022b7:	83 c4 10             	add    $0x10,%esp
  8022ba:	85 c0                	test   %eax,%eax
  8022bc:	78 3a                	js     8022f8 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022be:	83 ec 04             	sub    $0x4,%esp
  8022c1:	68 07 04 00 00       	push   $0x407
  8022c6:	ff 75 f4             	push   -0xc(%ebp)
  8022c9:	6a 00                	push   $0x0
  8022cb:	e8 ca ec ff ff       	call   800f9a <sys_page_alloc>
  8022d0:	83 c4 10             	add    $0x10,%esp
  8022d3:	85 c0                	test   %eax,%eax
  8022d5:	78 21                	js     8022f8 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8022d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022da:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8022e0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022ec:	83 ec 0c             	sub    $0xc,%esp
  8022ef:	50                   	push   %eax
  8022f0:	e8 f7 ee ff ff       	call   8011ec <fd2num>
  8022f5:	83 c4 10             	add    $0x10,%esp
}
  8022f8:	c9                   	leave  
  8022f9:	c3                   	ret    

008022fa <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8022fa:	55                   	push   %ebp
  8022fb:	89 e5                	mov    %esp,%ebp
  8022fd:	56                   	push   %esi
  8022fe:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8022ff:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802302:	8b 35 04 30 80 00    	mov    0x803004,%esi
  802308:	e8 4f ec ff ff       	call   800f5c <sys_getenvid>
  80230d:	83 ec 0c             	sub    $0xc,%esp
  802310:	ff 75 0c             	push   0xc(%ebp)
  802313:	ff 75 08             	push   0x8(%ebp)
  802316:	56                   	push   %esi
  802317:	50                   	push   %eax
  802318:	68 34 2c 80 00       	push   $0x802c34
  80231d:	e8 a2 e2 ff ff       	call   8005c4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802322:	83 c4 18             	add    $0x18,%esp
  802325:	53                   	push   %ebx
  802326:	ff 75 10             	push   0x10(%ebp)
  802329:	e8 45 e2 ff ff       	call   800573 <vcprintf>
	cprintf("\n");
  80232e:	c7 04 24 74 27 80 00 	movl   $0x802774,(%esp)
  802335:	e8 8a e2 ff ff       	call   8005c4 <cprintf>
  80233a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80233d:	cc                   	int3   
  80233e:	eb fd                	jmp    80233d <_panic+0x43>

00802340 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802340:	55                   	push   %ebp
  802341:	89 e5                	mov    %esp,%ebp
  802343:	56                   	push   %esi
  802344:	53                   	push   %ebx
  802345:	8b 75 08             	mov    0x8(%ebp),%esi
  802348:	8b 45 0c             	mov    0xc(%ebp),%eax
  80234b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80234e:	85 c0                	test   %eax,%eax
  802350:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802355:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802358:	83 ec 0c             	sub    $0xc,%esp
  80235b:	50                   	push   %eax
  80235c:	e8 e9 ed ff ff       	call   80114a <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802361:	83 c4 10             	add    $0x10,%esp
  802364:	85 f6                	test   %esi,%esi
  802366:	74 17                	je     80237f <ipc_recv+0x3f>
  802368:	ba 00 00 00 00       	mov    $0x0,%edx
  80236d:	85 c0                	test   %eax,%eax
  80236f:	78 0c                	js     80237d <ipc_recv+0x3d>
  802371:	8b 15 10 40 80 00    	mov    0x804010,%edx
  802377:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  80237d:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  80237f:	85 db                	test   %ebx,%ebx
  802381:	74 17                	je     80239a <ipc_recv+0x5a>
  802383:	ba 00 00 00 00       	mov    $0x0,%edx
  802388:	85 c0                	test   %eax,%eax
  80238a:	78 0c                	js     802398 <ipc_recv+0x58>
  80238c:	8b 15 10 40 80 00    	mov    0x804010,%edx
  802392:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  802398:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  80239a:	85 c0                	test   %eax,%eax
  80239c:	78 0b                	js     8023a9 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  80239e:	a1 10 40 80 00       	mov    0x804010,%eax
  8023a3:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  8023a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023ac:	5b                   	pop    %ebx
  8023ad:	5e                   	pop    %esi
  8023ae:	5d                   	pop    %ebp
  8023af:	c3                   	ret    

008023b0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023b0:	55                   	push   %ebp
  8023b1:	89 e5                	mov    %esp,%ebp
  8023b3:	57                   	push   %edi
  8023b4:	56                   	push   %esi
  8023b5:	53                   	push   %ebx
  8023b6:	83 ec 0c             	sub    $0xc,%esp
  8023b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8023c2:	85 db                	test   %ebx,%ebx
  8023c4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023c9:	0f 44 d8             	cmove  %eax,%ebx
  8023cc:	eb 05                	jmp    8023d3 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8023ce:	e8 a8 eb ff ff       	call   800f7b <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8023d3:	ff 75 14             	push   0x14(%ebp)
  8023d6:	53                   	push   %ebx
  8023d7:	56                   	push   %esi
  8023d8:	57                   	push   %edi
  8023d9:	e8 49 ed ff ff       	call   801127 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8023de:	83 c4 10             	add    $0x10,%esp
  8023e1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023e4:	74 e8                	je     8023ce <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8023e6:	85 c0                	test   %eax,%eax
  8023e8:	78 08                	js     8023f2 <ipc_send+0x42>
	}while (r<0);

}
  8023ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023ed:	5b                   	pop    %ebx
  8023ee:	5e                   	pop    %esi
  8023ef:	5f                   	pop    %edi
  8023f0:	5d                   	pop    %ebp
  8023f1:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8023f2:	50                   	push   %eax
  8023f3:	68 57 2c 80 00       	push   $0x802c57
  8023f8:	6a 3d                	push   $0x3d
  8023fa:	68 6b 2c 80 00       	push   $0x802c6b
  8023ff:	e8 f6 fe ff ff       	call   8022fa <_panic>

00802404 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802404:	55                   	push   %ebp
  802405:	89 e5                	mov    %esp,%ebp
  802407:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80240a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80240f:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  802415:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80241b:	8b 52 60             	mov    0x60(%edx),%edx
  80241e:	39 ca                	cmp    %ecx,%edx
  802420:	74 11                	je     802433 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  802422:	83 c0 01             	add    $0x1,%eax
  802425:	3d 00 04 00 00       	cmp    $0x400,%eax
  80242a:	75 e3                	jne    80240f <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80242c:	b8 00 00 00 00       	mov    $0x0,%eax
  802431:	eb 0e                	jmp    802441 <ipc_find_env+0x3d>
			return envs[i].env_id;
  802433:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  802439:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80243e:	8b 40 58             	mov    0x58(%eax),%eax
}
  802441:	5d                   	pop    %ebp
  802442:	c3                   	ret    

00802443 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802443:	55                   	push   %ebp
  802444:	89 e5                	mov    %esp,%ebp
  802446:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802449:	89 c2                	mov    %eax,%edx
  80244b:	c1 ea 16             	shr    $0x16,%edx
  80244e:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802455:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80245a:	f6 c1 01             	test   $0x1,%cl
  80245d:	74 1c                	je     80247b <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  80245f:	c1 e8 0c             	shr    $0xc,%eax
  802462:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802469:	a8 01                	test   $0x1,%al
  80246b:	74 0e                	je     80247b <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80246d:	c1 e8 0c             	shr    $0xc,%eax
  802470:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802477:	ef 
  802478:	0f b7 d2             	movzwl %dx,%edx
}
  80247b:	89 d0                	mov    %edx,%eax
  80247d:	5d                   	pop    %ebp
  80247e:	c3                   	ret    
  80247f:	90                   	nop

00802480 <__udivdi3>:
  802480:	f3 0f 1e fb          	endbr32 
  802484:	55                   	push   %ebp
  802485:	57                   	push   %edi
  802486:	56                   	push   %esi
  802487:	53                   	push   %ebx
  802488:	83 ec 1c             	sub    $0x1c,%esp
  80248b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80248f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802493:	8b 74 24 34          	mov    0x34(%esp),%esi
  802497:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80249b:	85 c0                	test   %eax,%eax
  80249d:	75 19                	jne    8024b8 <__udivdi3+0x38>
  80249f:	39 f3                	cmp    %esi,%ebx
  8024a1:	76 4d                	jbe    8024f0 <__udivdi3+0x70>
  8024a3:	31 ff                	xor    %edi,%edi
  8024a5:	89 e8                	mov    %ebp,%eax
  8024a7:	89 f2                	mov    %esi,%edx
  8024a9:	f7 f3                	div    %ebx
  8024ab:	89 fa                	mov    %edi,%edx
  8024ad:	83 c4 1c             	add    $0x1c,%esp
  8024b0:	5b                   	pop    %ebx
  8024b1:	5e                   	pop    %esi
  8024b2:	5f                   	pop    %edi
  8024b3:	5d                   	pop    %ebp
  8024b4:	c3                   	ret    
  8024b5:	8d 76 00             	lea    0x0(%esi),%esi
  8024b8:	39 f0                	cmp    %esi,%eax
  8024ba:	76 14                	jbe    8024d0 <__udivdi3+0x50>
  8024bc:	31 ff                	xor    %edi,%edi
  8024be:	31 c0                	xor    %eax,%eax
  8024c0:	89 fa                	mov    %edi,%edx
  8024c2:	83 c4 1c             	add    $0x1c,%esp
  8024c5:	5b                   	pop    %ebx
  8024c6:	5e                   	pop    %esi
  8024c7:	5f                   	pop    %edi
  8024c8:	5d                   	pop    %ebp
  8024c9:	c3                   	ret    
  8024ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024d0:	0f bd f8             	bsr    %eax,%edi
  8024d3:	83 f7 1f             	xor    $0x1f,%edi
  8024d6:	75 48                	jne    802520 <__udivdi3+0xa0>
  8024d8:	39 f0                	cmp    %esi,%eax
  8024da:	72 06                	jb     8024e2 <__udivdi3+0x62>
  8024dc:	31 c0                	xor    %eax,%eax
  8024de:	39 eb                	cmp    %ebp,%ebx
  8024e0:	77 de                	ja     8024c0 <__udivdi3+0x40>
  8024e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8024e7:	eb d7                	jmp    8024c0 <__udivdi3+0x40>
  8024e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024f0:	89 d9                	mov    %ebx,%ecx
  8024f2:	85 db                	test   %ebx,%ebx
  8024f4:	75 0b                	jne    802501 <__udivdi3+0x81>
  8024f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024fb:	31 d2                	xor    %edx,%edx
  8024fd:	f7 f3                	div    %ebx
  8024ff:	89 c1                	mov    %eax,%ecx
  802501:	31 d2                	xor    %edx,%edx
  802503:	89 f0                	mov    %esi,%eax
  802505:	f7 f1                	div    %ecx
  802507:	89 c6                	mov    %eax,%esi
  802509:	89 e8                	mov    %ebp,%eax
  80250b:	89 f7                	mov    %esi,%edi
  80250d:	f7 f1                	div    %ecx
  80250f:	89 fa                	mov    %edi,%edx
  802511:	83 c4 1c             	add    $0x1c,%esp
  802514:	5b                   	pop    %ebx
  802515:	5e                   	pop    %esi
  802516:	5f                   	pop    %edi
  802517:	5d                   	pop    %ebp
  802518:	c3                   	ret    
  802519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802520:	89 f9                	mov    %edi,%ecx
  802522:	ba 20 00 00 00       	mov    $0x20,%edx
  802527:	29 fa                	sub    %edi,%edx
  802529:	d3 e0                	shl    %cl,%eax
  80252b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80252f:	89 d1                	mov    %edx,%ecx
  802531:	89 d8                	mov    %ebx,%eax
  802533:	d3 e8                	shr    %cl,%eax
  802535:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802539:	09 c1                	or     %eax,%ecx
  80253b:	89 f0                	mov    %esi,%eax
  80253d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802541:	89 f9                	mov    %edi,%ecx
  802543:	d3 e3                	shl    %cl,%ebx
  802545:	89 d1                	mov    %edx,%ecx
  802547:	d3 e8                	shr    %cl,%eax
  802549:	89 f9                	mov    %edi,%ecx
  80254b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80254f:	89 eb                	mov    %ebp,%ebx
  802551:	d3 e6                	shl    %cl,%esi
  802553:	89 d1                	mov    %edx,%ecx
  802555:	d3 eb                	shr    %cl,%ebx
  802557:	09 f3                	or     %esi,%ebx
  802559:	89 c6                	mov    %eax,%esi
  80255b:	89 f2                	mov    %esi,%edx
  80255d:	89 d8                	mov    %ebx,%eax
  80255f:	f7 74 24 08          	divl   0x8(%esp)
  802563:	89 d6                	mov    %edx,%esi
  802565:	89 c3                	mov    %eax,%ebx
  802567:	f7 64 24 0c          	mull   0xc(%esp)
  80256b:	39 d6                	cmp    %edx,%esi
  80256d:	72 19                	jb     802588 <__udivdi3+0x108>
  80256f:	89 f9                	mov    %edi,%ecx
  802571:	d3 e5                	shl    %cl,%ebp
  802573:	39 c5                	cmp    %eax,%ebp
  802575:	73 04                	jae    80257b <__udivdi3+0xfb>
  802577:	39 d6                	cmp    %edx,%esi
  802579:	74 0d                	je     802588 <__udivdi3+0x108>
  80257b:	89 d8                	mov    %ebx,%eax
  80257d:	31 ff                	xor    %edi,%edi
  80257f:	e9 3c ff ff ff       	jmp    8024c0 <__udivdi3+0x40>
  802584:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802588:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80258b:	31 ff                	xor    %edi,%edi
  80258d:	e9 2e ff ff ff       	jmp    8024c0 <__udivdi3+0x40>
  802592:	66 90                	xchg   %ax,%ax
  802594:	66 90                	xchg   %ax,%ax
  802596:	66 90                	xchg   %ax,%ax
  802598:	66 90                	xchg   %ax,%ax
  80259a:	66 90                	xchg   %ax,%ax
  80259c:	66 90                	xchg   %ax,%ax
  80259e:	66 90                	xchg   %ax,%ax

008025a0 <__umoddi3>:
  8025a0:	f3 0f 1e fb          	endbr32 
  8025a4:	55                   	push   %ebp
  8025a5:	57                   	push   %edi
  8025a6:	56                   	push   %esi
  8025a7:	53                   	push   %ebx
  8025a8:	83 ec 1c             	sub    $0x1c,%esp
  8025ab:	8b 74 24 30          	mov    0x30(%esp),%esi
  8025af:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8025b3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8025b7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8025bb:	89 f0                	mov    %esi,%eax
  8025bd:	89 da                	mov    %ebx,%edx
  8025bf:	85 ff                	test   %edi,%edi
  8025c1:	75 15                	jne    8025d8 <__umoddi3+0x38>
  8025c3:	39 dd                	cmp    %ebx,%ebp
  8025c5:	76 39                	jbe    802600 <__umoddi3+0x60>
  8025c7:	f7 f5                	div    %ebp
  8025c9:	89 d0                	mov    %edx,%eax
  8025cb:	31 d2                	xor    %edx,%edx
  8025cd:	83 c4 1c             	add    $0x1c,%esp
  8025d0:	5b                   	pop    %ebx
  8025d1:	5e                   	pop    %esi
  8025d2:	5f                   	pop    %edi
  8025d3:	5d                   	pop    %ebp
  8025d4:	c3                   	ret    
  8025d5:	8d 76 00             	lea    0x0(%esi),%esi
  8025d8:	39 df                	cmp    %ebx,%edi
  8025da:	77 f1                	ja     8025cd <__umoddi3+0x2d>
  8025dc:	0f bd cf             	bsr    %edi,%ecx
  8025df:	83 f1 1f             	xor    $0x1f,%ecx
  8025e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8025e6:	75 40                	jne    802628 <__umoddi3+0x88>
  8025e8:	39 df                	cmp    %ebx,%edi
  8025ea:	72 04                	jb     8025f0 <__umoddi3+0x50>
  8025ec:	39 f5                	cmp    %esi,%ebp
  8025ee:	77 dd                	ja     8025cd <__umoddi3+0x2d>
  8025f0:	89 da                	mov    %ebx,%edx
  8025f2:	89 f0                	mov    %esi,%eax
  8025f4:	29 e8                	sub    %ebp,%eax
  8025f6:	19 fa                	sbb    %edi,%edx
  8025f8:	eb d3                	jmp    8025cd <__umoddi3+0x2d>
  8025fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802600:	89 e9                	mov    %ebp,%ecx
  802602:	85 ed                	test   %ebp,%ebp
  802604:	75 0b                	jne    802611 <__umoddi3+0x71>
  802606:	b8 01 00 00 00       	mov    $0x1,%eax
  80260b:	31 d2                	xor    %edx,%edx
  80260d:	f7 f5                	div    %ebp
  80260f:	89 c1                	mov    %eax,%ecx
  802611:	89 d8                	mov    %ebx,%eax
  802613:	31 d2                	xor    %edx,%edx
  802615:	f7 f1                	div    %ecx
  802617:	89 f0                	mov    %esi,%eax
  802619:	f7 f1                	div    %ecx
  80261b:	89 d0                	mov    %edx,%eax
  80261d:	31 d2                	xor    %edx,%edx
  80261f:	eb ac                	jmp    8025cd <__umoddi3+0x2d>
  802621:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802628:	8b 44 24 04          	mov    0x4(%esp),%eax
  80262c:	ba 20 00 00 00       	mov    $0x20,%edx
  802631:	29 c2                	sub    %eax,%edx
  802633:	89 c1                	mov    %eax,%ecx
  802635:	89 e8                	mov    %ebp,%eax
  802637:	d3 e7                	shl    %cl,%edi
  802639:	89 d1                	mov    %edx,%ecx
  80263b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80263f:	d3 e8                	shr    %cl,%eax
  802641:	89 c1                	mov    %eax,%ecx
  802643:	8b 44 24 04          	mov    0x4(%esp),%eax
  802647:	09 f9                	or     %edi,%ecx
  802649:	89 df                	mov    %ebx,%edi
  80264b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80264f:	89 c1                	mov    %eax,%ecx
  802651:	d3 e5                	shl    %cl,%ebp
  802653:	89 d1                	mov    %edx,%ecx
  802655:	d3 ef                	shr    %cl,%edi
  802657:	89 c1                	mov    %eax,%ecx
  802659:	89 f0                	mov    %esi,%eax
  80265b:	d3 e3                	shl    %cl,%ebx
  80265d:	89 d1                	mov    %edx,%ecx
  80265f:	89 fa                	mov    %edi,%edx
  802661:	d3 e8                	shr    %cl,%eax
  802663:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802668:	09 d8                	or     %ebx,%eax
  80266a:	f7 74 24 08          	divl   0x8(%esp)
  80266e:	89 d3                	mov    %edx,%ebx
  802670:	d3 e6                	shl    %cl,%esi
  802672:	f7 e5                	mul    %ebp
  802674:	89 c7                	mov    %eax,%edi
  802676:	89 d1                	mov    %edx,%ecx
  802678:	39 d3                	cmp    %edx,%ebx
  80267a:	72 06                	jb     802682 <__umoddi3+0xe2>
  80267c:	75 0e                	jne    80268c <__umoddi3+0xec>
  80267e:	39 c6                	cmp    %eax,%esi
  802680:	73 0a                	jae    80268c <__umoddi3+0xec>
  802682:	29 e8                	sub    %ebp,%eax
  802684:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802688:	89 d1                	mov    %edx,%ecx
  80268a:	89 c7                	mov    %eax,%edi
  80268c:	89 f5                	mov    %esi,%ebp
  80268e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802692:	29 fd                	sub    %edi,%ebp
  802694:	19 cb                	sbb    %ecx,%ebx
  802696:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80269b:	89 d8                	mov    %ebx,%eax
  80269d:	d3 e0                	shl    %cl,%eax
  80269f:	89 f1                	mov    %esi,%ecx
  8026a1:	d3 ed                	shr    %cl,%ebp
  8026a3:	d3 eb                	shr    %cl,%ebx
  8026a5:	09 e8                	or     %ebp,%eax
  8026a7:	89 da                	mov    %ebx,%edx
  8026a9:	83 c4 1c             	add    $0x1c,%esp
  8026ac:	5b                   	pop    %ebx
  8026ad:	5e                   	pop    %esi
  8026ae:	5f                   	pop    %edi
  8026af:	5d                   	pop    %ebp
  8026b0:	c3                   	ret    
