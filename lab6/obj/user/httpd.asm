
obj/user/httpd.debug：     文件格式 elf32-i386


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
  80002c:	e8 96 07 00 00       	call   8007c7 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:
	{404, "Not Found"},
};

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 40 2c 80 00       	push   $0x802c40
  80003f:	e8 be 08 00 00       	call   800902 <cprintf>
	exit();
  800044:	e8 c4 07 00 00       	call   80080d <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <send_error>:
	return 0;
}

static int
send_error(struct http_request *req, int code)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	81 ec 0c 02 00 00    	sub    $0x20c,%esp
  80005a:	89 c3                	mov    %eax,%ebx
	char buf[512];
	int r;

	struct error_messages *e = errors;
  80005c:	b8 00 40 80 00       	mov    $0x804000,%eax
	while (e->code != 0 && e->msg != 0) {
  800061:	8b 08                	mov    (%eax),%ecx
  800063:	85 c9                	test   %ecx,%ecx
  800065:	74 52                	je     8000b9 <send_error+0x6b>
		if (e->code == code)
  800067:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
  80006b:	74 09                	je     800076 <send_error+0x28>
  80006d:	39 d1                	cmp    %edx,%ecx
  80006f:	74 05                	je     800076 <send_error+0x28>
			break;
		e++;
  800071:	83 c0 08             	add    $0x8,%eax
  800074:	eb eb                	jmp    800061 <send_error+0x13>
	}

	if (e->code == 0)
		return -1;

	r = snprintf(buf, 512, "HTTP/" HTTP_VERSION" %d %s\r\n"
  800076:	8b 40 04             	mov    0x4(%eax),%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	51                   	push   %ecx
  80007e:	50                   	push   %eax
  80007f:	51                   	push   %ecx
  800080:	68 e0 2c 80 00       	push   $0x802ce0
  800085:	68 00 02 00 00       	push   $0x200
  80008a:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
  800090:	57                   	push   %edi
  800091:	e8 f1 0d 00 00       	call   800e87 <snprintf>
  800096:	89 c6                	mov    %eax,%esi
			       "Content-type: text/html\r\n"
			       "\r\n"
			       "<html><body><p>%d - %s</p></body></html>\r\n",
			       e->code, e->msg, e->code, e->msg);

	if (write(req->sock, buf, r) != r)
  800098:	83 c4 1c             	add    $0x1c,%esp
  80009b:	50                   	push   %eax
  80009c:	57                   	push   %edi
  80009d:	ff 33                	push   (%ebx)
  80009f:	e8 34 18 00 00       	call   8018d8 <write>
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	39 f0                	cmp    %esi,%eax
  8000a9:	0f 95 c0             	setne  %al
  8000ac:	0f b6 c0             	movzbl %al,%eax
  8000af:	f7 d8                	neg    %eax
		return -1;

	return 0;
}
  8000b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b4:	5b                   	pop    %ebx
  8000b5:	5e                   	pop    %esi
  8000b6:	5f                   	pop    %edi
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    
		return -1;
  8000b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8000be:	eb f1                	jmp    8000b1 <send_error+0x63>

008000c0 <handle_client>:
	return r;
}

static void
handle_client(int sock)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
  8000c6:	81 ec c0 04 00 00    	sub    $0x4c0,%esp
  8000cc:	89 c6                	mov    %eax,%esi
	struct http_request *req = &con_d;

	while (1)
	{
		// Receive message
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  8000ce:	68 00 02 00 00       	push   $0x200
  8000d3:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  8000d9:	50                   	push   %eax
  8000da:	56                   	push   %esi
  8000db:	e8 2a 17 00 00       	call   80180a <read>
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	85 c0                	test   %eax,%eax
  8000e5:	78 3c                	js     800123 <handle_client+0x63>
			panic("failed to read");

		memset(req, 0, sizeof(*req));
  8000e7:	83 ec 04             	sub    $0x4,%esp
  8000ea:	6a 0c                	push   $0xc
  8000ec:	6a 00                	push   $0x0
  8000ee:	8d 45 dc             	lea    -0x24(%ebp),%eax
  8000f1:	50                   	push   %eax
  8000f2:	e8 35 0f 00 00       	call   80102c <memset>

		req->sock = sock;
  8000f7:	89 75 dc             	mov    %esi,-0x24(%ebp)
	if (strncmp(request, "GET ", 4) != 0)
  8000fa:	83 c4 0c             	add    $0xc,%esp
  8000fd:	6a 04                	push   $0x4
  8000ff:	68 60 2c 80 00       	push   $0x802c60
  800104:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  80010a:	50                   	push   %eax
  80010b:	e8 a3 0e 00 00       	call   800fb3 <strncmp>
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	85 c0                	test   %eax,%eax
  800115:	0f 85 bd 02 00 00    	jne    8003d8 <handle_client+0x318>
	request += 4;
  80011b:	8d 9d e0 fd ff ff    	lea    -0x220(%ebp),%ebx
  800121:	eb 1a                	jmp    80013d <handle_client+0x7d>
			panic("failed to read");
  800123:	83 ec 04             	sub    $0x4,%esp
  800126:	68 44 2c 80 00       	push   $0x802c44
  80012b:	68 1a 01 00 00       	push   $0x11a
  800130:	68 53 2c 80 00       	push   $0x802c53
  800135:	e8 ed 06 00 00       	call   800827 <_panic>
		request++;
  80013a:	83 c3 01             	add    $0x1,%ebx
	while (*request && *request != ' ')
  80013d:	f6 03 df             	testb  $0xdf,(%ebx)
  800140:	75 f8                	jne    80013a <handle_client+0x7a>
	url_len = request - url;
  800142:	89 df                	mov    %ebx,%edi
  800144:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
  80014a:	29 c7                	sub    %eax,%edi
	req->url = malloc(url_len + 1);
  80014c:	83 ec 0c             	sub    $0xc,%esp
  80014f:	8d 47 01             	lea    0x1(%edi),%eax
  800152:	50                   	push   %eax
  800153:	e8 ce 20 00 00       	call   802226 <malloc>
  800158:	89 45 e0             	mov    %eax,-0x20(%ebp)
	memmove(req->url, url, url_len);
  80015b:	83 c4 0c             	add    $0xc,%esp
  80015e:	57                   	push   %edi
  80015f:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  800165:	51                   	push   %ecx
  800166:	50                   	push   %eax
  800167:	e8 06 0f 00 00       	call   801072 <memmove>
	req->url[url_len] = '\0';
  80016c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80016f:	c6 04 38 00          	movb   $0x0,(%eax,%edi,1)
	request++;
  800173:	83 c3 01             	add    $0x1,%ebx
	while (*request && *request != '\n')
  800176:	83 c4 10             	add    $0x10,%esp
	request++;
  800179:	89 d8                	mov    %ebx,%eax
	while (*request && *request != '\n')
  80017b:	eb 03                	jmp    800180 <handle_client+0xc0>
		request++;
  80017d:	83 c0 01             	add    $0x1,%eax
	while (*request && *request != '\n')
  800180:	0f b6 10             	movzbl (%eax),%edx
  800183:	84 d2                	test   %dl,%dl
  800185:	74 05                	je     80018c <handle_client+0xcc>
  800187:	80 fa 0a             	cmp    $0xa,%dl
  80018a:	75 f1                	jne    80017d <handle_client+0xbd>
	version_len = request - version;
  80018c:	29 d8                	sub    %ebx,%eax
  80018e:	89 c7                	mov    %eax,%edi
	req->version = malloc(version_len + 1);
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	8d 40 01             	lea    0x1(%eax),%eax
  800196:	50                   	push   %eax
  800197:	e8 8a 20 00 00       	call   802226 <malloc>
  80019c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	memmove(req->version, version, version_len);
  80019f:	83 c4 0c             	add    $0xc,%esp
  8001a2:	57                   	push   %edi
  8001a3:	53                   	push   %ebx
  8001a4:	50                   	push   %eax
  8001a5:	e8 c8 0e 00 00       	call   801072 <memmove>
	req->version[version_len] = '\0';
  8001aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ad:	c6 04 38 00          	movb   $0x0,(%eax,%edi,1)
	if ( (r = open(req->url, O_RDONLY) )< 0 ) {
  8001b1:	83 c4 08             	add    $0x8,%esp
  8001b4:	6a 00                	push   $0x0
  8001b6:	ff 75 e0             	push   -0x20(%ebp)
  8001b9:	e8 af 1a 00 00       	call   801c6d <open>
  8001be:	89 c7                	mov    %eax,%edi
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	78 4d                	js     800214 <handle_client+0x154>
	if ( (r = fstat(fd, &st)) < 0) return send_error(req, 404);
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	8d 85 50 fb ff ff    	lea    -0x4b0(%ebp),%eax
  8001d0:	50                   	push   %eax
  8001d1:	57                   	push   %edi
  8001d2:	e8 2b 18 00 00       	call   801a02 <fstat>
  8001d7:	83 c4 10             	add    $0x10,%esp
  8001da:	85 c0                	test   %eax,%eax
  8001dc:	78 48                	js     800226 <handle_client+0x166>
	if (st.st_isdir) return send_error(req, 404);
  8001de:	83 bd d4 fb ff ff 00 	cmpl   $0x0,-0x42c(%ebp)
  8001e5:	75 51                	jne    800238 <handle_client+0x178>
	file_size = st.st_size;
  8001e7:	8b 85 d0 fb ff ff    	mov    -0x430(%ebp),%eax
  8001ed:	89 85 40 fb ff ff    	mov    %eax,-0x4c0(%ebp)
	struct responce_header *h = headers;
  8001f3:	bb 10 40 80 00       	mov    $0x804010,%ebx
	while (h->code != 0 && h->header!= 0) {
  8001f8:	8b 03                	mov    (%ebx),%eax
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	0f 84 5e 01 00 00    	je     800360 <handle_client+0x2a0>
		if (h->code == code)
  800202:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  800206:	74 42                	je     80024a <handle_client+0x18a>
  800208:	3d c8 00 00 00       	cmp    $0xc8,%eax
  80020d:	74 3b                	je     80024a <handle_client+0x18a>
		h++;
  80020f:	83 c3 08             	add    $0x8,%ebx
  800212:	eb e4                	jmp    8001f8 <handle_client+0x138>
		return  send_error(req, 404);
  800214:	ba 94 01 00 00       	mov    $0x194,%edx
  800219:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80021c:	e8 2d fe ff ff       	call   80004e <send_error>
  800221:	e9 46 01 00 00       	jmp    80036c <handle_client+0x2ac>
	if ( (r = fstat(fd, &st)) < 0) return send_error(req, 404);
  800226:	ba 94 01 00 00       	mov    $0x194,%edx
  80022b:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80022e:	e8 1b fe ff ff       	call   80004e <send_error>
  800233:	e9 34 01 00 00       	jmp    80036c <handle_client+0x2ac>
	if (st.st_isdir) return send_error(req, 404);
  800238:	ba 94 01 00 00       	mov    $0x194,%edx
  80023d:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800240:	e8 09 fe ff ff       	call   80004e <send_error>
  800245:	e9 22 01 00 00       	jmp    80036c <handle_client+0x2ac>
	int len = strlen(h->header);
  80024a:	83 ec 0c             	sub    $0xc,%esp
  80024d:	ff 73 04             	push   0x4(%ebx)
  800250:	e8 4c 0c 00 00       	call   800ea1 <strlen>
	if (write(req->sock, h->header, len) != len) {
  800255:	83 c4 0c             	add    $0xc,%esp
  800258:	89 85 44 fb ff ff    	mov    %eax,-0x4bc(%ebp)
  80025e:	50                   	push   %eax
  80025f:	ff 73 04             	push   0x4(%ebx)
  800262:	ff 75 dc             	push   -0x24(%ebp)
  800265:	e8 6e 16 00 00       	call   8018d8 <write>
  80026a:	83 c4 10             	add    $0x10,%esp
  80026d:	39 85 44 fb ff ff    	cmp    %eax,-0x4bc(%ebp)
  800273:	0f 85 19 01 00 00    	jne    800392 <handle_client+0x2d2>
	r = snprintf(buf, 64, "Content-Length: %ld\r\n", (long)size);
  800279:	ff b5 40 fb ff ff    	push   -0x4c0(%ebp)
  80027f:	68 94 2c 80 00       	push   $0x802c94
  800284:	6a 40                	push   $0x40
  800286:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
  80028c:	50                   	push   %eax
  80028d:	e8 f5 0b 00 00       	call   800e87 <snprintf>
  800292:	89 c3                	mov    %eax,%ebx
	if (r > 63)
  800294:	83 c4 10             	add    $0x10,%esp
  800297:	83 f8 3f             	cmp    $0x3f,%eax
  80029a:	0f 8f 01 01 00 00    	jg     8003a1 <handle_client+0x2e1>
	if (write(req->sock, buf, r) != r)
  8002a0:	83 ec 04             	sub    $0x4,%esp
  8002a3:	53                   	push   %ebx
  8002a4:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
  8002aa:	50                   	push   %eax
  8002ab:	ff 75 dc             	push   -0x24(%ebp)
  8002ae:	e8 25 16 00 00       	call   8018d8 <write>
	if ((r = send_size(req, file_size)) < 0)
  8002b3:	83 c4 10             	add    $0x10,%esp
  8002b6:	39 c3                	cmp    %eax,%ebx
  8002b8:	0f 85 a2 00 00 00    	jne    800360 <handle_client+0x2a0>
	r = snprintf(buf, 128, "Content-Type: %s\r\n", type);
  8002be:	68 77 2c 80 00       	push   $0x802c77
  8002c3:	68 81 2c 80 00       	push   $0x802c81
  8002c8:	68 80 00 00 00       	push   $0x80
  8002cd:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
  8002d3:	50                   	push   %eax
  8002d4:	e8 ae 0b 00 00       	call   800e87 <snprintf>
  8002d9:	89 c3                	mov    %eax,%ebx
	if (r > 127)
  8002db:	83 c4 10             	add    $0x10,%esp
  8002de:	83 f8 7f             	cmp    $0x7f,%eax
  8002e1:	0f 8f ce 00 00 00    	jg     8003b5 <handle_client+0x2f5>
	if (write(req->sock, buf, r) != r)
  8002e7:	83 ec 04             	sub    $0x4,%esp
  8002ea:	50                   	push   %eax
  8002eb:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
  8002f1:	50                   	push   %eax
  8002f2:	ff 75 dc             	push   -0x24(%ebp)
  8002f5:	e8 de 15 00 00       	call   8018d8 <write>
	if ((r = send_content_type(req)) < 0)
  8002fa:	83 c4 10             	add    $0x10,%esp
  8002fd:	39 c3                	cmp    %eax,%ebx
  8002ff:	75 5f                	jne    800360 <handle_client+0x2a0>
	int fin_len = strlen(fin);
  800301:	83 ec 0c             	sub    $0xc,%esp
  800304:	68 a7 2c 80 00       	push   $0x802ca7
  800309:	e8 93 0b 00 00       	call   800ea1 <strlen>
  80030e:	89 c3                	mov    %eax,%ebx
	if (write(req->sock, fin, fin_len) != fin_len)
  800310:	83 c4 0c             	add    $0xc,%esp
  800313:	50                   	push   %eax
  800314:	68 a7 2c 80 00       	push   $0x802ca7
  800319:	ff 75 dc             	push   -0x24(%ebp)
  80031c:	e8 b7 15 00 00       	call   8018d8 <write>
	if ((r = send_header_fin(req)) < 0)
  800321:	83 c4 10             	add    $0x10,%esp
  800324:	39 c3                	cmp    %eax,%ebx
  800326:	75 38                	jne    800360 <handle_client+0x2a0>
	if ( (r = read(fd, buf, BUFFSIZE)) < 0 )  return -1;
  800328:	83 ec 04             	sub    $0x4,%esp
  80032b:	68 00 02 00 00       	push   $0x200
  800330:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
  800336:	50                   	push   %eax
  800337:	57                   	push   %edi
  800338:	e8 cd 14 00 00       	call   80180a <read>
  80033d:	89 c3                	mov    %eax,%ebx
  80033f:	83 c4 10             	add    $0x10,%esp
  800342:	85 c0                	test   %eax,%eax
  800344:	78 1a                	js     800360 <handle_client+0x2a0>
	if ( write(req->sock, buf, len) != len) {
  800346:	83 ec 04             	sub    $0x4,%esp
  800349:	50                   	push   %eax
  80034a:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
  800350:	50                   	push   %eax
  800351:	ff 75 dc             	push   -0x24(%ebp)
  800354:	e8 7f 15 00 00       	call   8018d8 <write>
  800359:	83 c4 10             	add    $0x10,%esp
  80035c:	39 c3                	cmp    %eax,%ebx
  80035e:	75 6c                	jne    8003cc <handle_client+0x30c>
	close(fd);
  800360:	83 ec 0c             	sub    $0xc,%esp
  800363:	57                   	push   %edi
  800364:	e8 65 13 00 00       	call   8016ce <close>
	return r;
  800369:	83 c4 10             	add    $0x10,%esp
	free(req->url);
  80036c:	83 ec 0c             	sub    $0xc,%esp
  80036f:	ff 75 e0             	push   -0x20(%ebp)
  800372:	e8 03 1e 00 00       	call   80217a <free>
	free(req->version);
  800377:	83 c4 04             	add    $0x4,%esp
  80037a:	ff 75 e4             	push   -0x1c(%ebp)
  80037d:	e8 f8 1d 00 00       	call   80217a <free>

		// no keep alive
		break;
	}

	close(sock);
  800382:	89 34 24             	mov    %esi,(%esp)
  800385:	e8 44 13 00 00       	call   8016ce <close>
}
  80038a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80038d:	5b                   	pop    %ebx
  80038e:	5e                   	pop    %esi
  80038f:	5f                   	pop    %edi
  800390:	5d                   	pop    %ebp
  800391:	c3                   	ret    
		die("Failed to send bytes to client");
  800392:	b8 5c 2d 80 00       	mov    $0x802d5c,%eax
  800397:	e8 97 fc ff ff       	call   800033 <die>
  80039c:	e9 d8 fe ff ff       	jmp    800279 <handle_client+0x1b9>
		panic("buffer too small!");
  8003a1:	83 ec 04             	sub    $0x4,%esp
  8003a4:	68 65 2c 80 00       	push   $0x802c65
  8003a9:	6a 66                	push   $0x66
  8003ab:	68 53 2c 80 00       	push   $0x802c53
  8003b0:	e8 72 04 00 00       	call   800827 <_panic>
		panic("buffer too small!");
  8003b5:	83 ec 04             	sub    $0x4,%esp
  8003b8:	68 65 2c 80 00       	push   $0x802c65
  8003bd:	68 82 00 00 00       	push   $0x82
  8003c2:	68 53 2c 80 00       	push   $0x802c53
  8003c7:	e8 5b 04 00 00       	call   800827 <_panic>
		die("Failed to send bytes to client");
  8003cc:	b8 5c 2d 80 00       	mov    $0x802d5c,%eax
  8003d1:	e8 5d fc ff ff       	call   800033 <die>
  8003d6:	eb 88                	jmp    800360 <handle_client+0x2a0>
			send_error(req, 400);
  8003d8:	ba 90 01 00 00       	mov    $0x190,%edx
  8003dd:	8d 45 dc             	lea    -0x24(%ebp),%eax
  8003e0:	e8 69 fc ff ff       	call   80004e <send_error>
  8003e5:	eb 85                	jmp    80036c <handle_client+0x2ac>

008003e7 <umain>:

void
umain(int argc, char **argv)
{
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
  8003ea:	57                   	push   %edi
  8003eb:	56                   	push   %esi
  8003ec:	53                   	push   %ebx
  8003ed:	83 ec 40             	sub    $0x40,%esp
	int serversock, clientsock;
	struct sockaddr_in server, client;

	binaryname = "jhttpd";
  8003f0:	c7 05 20 40 80 00 aa 	movl   $0x802caa,0x804020
  8003f7:	2c 80 00 

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8003fa:	6a 06                	push   $0x6
  8003fc:	6a 01                	push   $0x1
  8003fe:	6a 02                	push   $0x2
  800400:	e8 f6 1a 00 00       	call   801efb <socket>
  800405:	89 c6                	mov    %eax,%esi
  800407:	83 c4 10             	add    $0x10,%esp
  80040a:	85 c0                	test   %eax,%eax
  80040c:	78 6d                	js     80047b <umain+0x94>
		die("Failed to create socket");

	// Construct the server sockaddr_in structure
	memset(&server, 0, sizeof(server));		// Clear struct
  80040e:	83 ec 04             	sub    $0x4,%esp
  800411:	6a 10                	push   $0x10
  800413:	6a 00                	push   $0x0
  800415:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800418:	53                   	push   %ebx
  800419:	e8 0e 0c 00 00       	call   80102c <memset>
	server.sin_family = AF_INET;			// Internet/IP
  80041e:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	server.sin_addr.s_addr = htonl(INADDR_ANY);	// IP address
  800422:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800429:	e8 5e 01 00 00       	call   80058c <htonl>
  80042e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	server.sin_port = htons(PORT);			// server port
  800431:	c7 04 24 50 00 00 00 	movl   $0x50,(%esp)
  800438:	e8 35 01 00 00       	call   800572 <htons>
  80043d:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &server,
  800441:	83 c4 0c             	add    $0xc,%esp
  800444:	6a 10                	push   $0x10
  800446:	53                   	push   %ebx
  800447:	56                   	push   %esi
  800448:	e8 1c 1a 00 00       	call   801e69 <bind>
  80044d:	83 c4 10             	add    $0x10,%esp
  800450:	85 c0                	test   %eax,%eax
  800452:	78 33                	js     800487 <umain+0xa0>
	{
		die("Failed to bind the server socket");
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  800454:	83 ec 08             	sub    $0x8,%esp
  800457:	6a 05                	push   $0x5
  800459:	56                   	push   %esi
  80045a:	e8 79 1a 00 00       	call   801ed8 <listen>
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	85 c0                	test   %eax,%eax
  800464:	78 2d                	js     800493 <umain+0xac>
		die("Failed to listen on server socket");

	cprintf("Waiting for http connections...\n");
  800466:	83 ec 0c             	sub    $0xc,%esp
  800469:	68 c4 2d 80 00       	push   $0x802dc4
  80046e:	e8 8f 04 00 00       	call   800902 <cprintf>
  800473:	83 c4 10             	add    $0x10,%esp

	while (1) {
		unsigned int clientlen = sizeof(client);
		// Wait for client connection
		if ((clientsock = accept(serversock,
  800476:	8d 7d c4             	lea    -0x3c(%ebp),%edi
  800479:	eb 35                	jmp    8004b0 <umain+0xc9>
		die("Failed to create socket");
  80047b:	b8 b1 2c 80 00       	mov    $0x802cb1,%eax
  800480:	e8 ae fb ff ff       	call   800033 <die>
  800485:	eb 87                	jmp    80040e <umain+0x27>
		die("Failed to bind the server socket");
  800487:	b8 7c 2d 80 00       	mov    $0x802d7c,%eax
  80048c:	e8 a2 fb ff ff       	call   800033 <die>
  800491:	eb c1                	jmp    800454 <umain+0x6d>
		die("Failed to listen on server socket");
  800493:	b8 a0 2d 80 00       	mov    $0x802da0,%eax
  800498:	e8 96 fb ff ff       	call   800033 <die>
  80049d:	eb c7                	jmp    800466 <umain+0x7f>
					 (struct sockaddr *) &client,
					 &clientlen)) < 0)
		{
			die("Failed to accept client connection");
  80049f:	b8 e8 2d 80 00       	mov    $0x802de8,%eax
  8004a4:	e8 8a fb ff ff       	call   800033 <die>
		}
		handle_client(clientsock);
  8004a9:	89 d8                	mov    %ebx,%eax
  8004ab:	e8 10 fc ff ff       	call   8000c0 <handle_client>
		unsigned int clientlen = sizeof(client);
  8004b0:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		if ((clientsock = accept(serversock,
  8004b7:	83 ec 04             	sub    $0x4,%esp
  8004ba:	57                   	push   %edi
  8004bb:	8d 45 c8             	lea    -0x38(%ebp),%eax
  8004be:	50                   	push   %eax
  8004bf:	56                   	push   %esi
  8004c0:	e8 75 19 00 00       	call   801e3a <accept>
  8004c5:	89 c3                	mov    %eax,%ebx
  8004c7:	83 c4 10             	add    $0x10,%esp
  8004ca:	85 c0                	test   %eax,%eax
  8004cc:	78 d1                	js     80049f <umain+0xb8>
  8004ce:	eb d9                	jmp    8004a9 <umain+0xc2>

008004d0 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	57                   	push   %edi
  8004d4:	56                   	push   %esi
  8004d5:	53                   	push   %ebx
  8004d6:	83 ec 1c             	sub    $0x1c,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8004d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8004df:	c6 45 db 00          	movb   $0x0,-0x25(%ebp)
  ap = (u8_t *)&s_addr;
  8004e3:	8d 75 f0             	lea    -0x10(%ebp),%esi
  rp = str;
  8004e6:	c7 45 dc 00 50 80 00 	movl   $0x805000,-0x24(%ebp)
  8004ed:	eb 32                	jmp    800521 <inet_ntoa+0x51>
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
  8004ef:	0f b6 c8             	movzbl %al,%ecx
  8004f2:	0f b6 4c 0d ed       	movzbl -0x13(%ebp,%ecx,1),%ecx
  8004f7:	88 0a                	mov    %cl,(%edx)
  8004f9:	83 c2 01             	add    $0x1,%edx
    while(i--)
  8004fc:	83 e8 01             	sub    $0x1,%eax
  8004ff:	3c ff                	cmp    $0xff,%al
  800501:	75 ec                	jne    8004ef <inet_ntoa+0x1f>
  800503:	0f b6 db             	movzbl %bl,%ebx
  800506:	03 5d dc             	add    -0x24(%ebp),%ebx
    *rp++ = '.';
  800509:	8d 43 01             	lea    0x1(%ebx),%eax
  80050c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80050f:	c6 03 2e             	movb   $0x2e,(%ebx)
  800512:	83 c6 01             	add    $0x1,%esi
  for(n = 0; n < 4; n++) {
  800515:	80 45 db 01          	addb   $0x1,-0x25(%ebp)
  800519:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  80051d:	3c 04                	cmp    $0x4,%al
  80051f:	74 41                	je     800562 <inet_ntoa+0x92>
  rp = str;
  800521:	bb 00 00 00 00       	mov    $0x0,%ebx
      rem = *ap % (u8_t)10;
  800526:	0f b6 16             	movzbl (%esi),%edx
      *ap /= (u8_t)10;
  800529:	b8 cd ff ff ff       	mov    $0xffffffcd,%eax
  80052e:	f6 e2                	mul    %dl
  800530:	66 c1 e8 0b          	shr    $0xb,%ax
  800534:	88 06                	mov    %al,(%esi)
  800536:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  800538:	83 c3 01             	add    $0x1,%ebx
  80053b:	0f b6 f9             	movzbl %cl,%edi
  80053e:	89 7d e0             	mov    %edi,-0x20(%ebp)
      rem = *ap % (u8_t)10;
  800541:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800544:	01 c0                	add    %eax,%eax
  800546:	89 d1                	mov    %edx,%ecx
  800548:	29 c1                	sub    %eax,%ecx
  80054a:	89 cf                	mov    %ecx,%edi
      inv[i++] = '0' + rem;
  80054c:	8d 47 30             	lea    0x30(%edi),%eax
  80054f:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800552:	88 44 3d ed          	mov    %al,-0x13(%ebp,%edi,1)
    } while(*ap);
  800556:	80 fa 09             	cmp    $0x9,%dl
  800559:	77 cb                	ja     800526 <inet_ntoa+0x56>
  80055b:	8b 55 dc             	mov    -0x24(%ebp),%edx
      inv[i++] = '0' + rem;
  80055e:	89 d8                	mov    %ebx,%eax
  800560:	eb 9a                	jmp    8004fc <inet_ntoa+0x2c>
    ap++;
  }
  *--rp = 0;
  800562:	c6 03 00             	movb   $0x0,(%ebx)
  return str;
}
  800565:	b8 00 50 80 00       	mov    $0x805000,%eax
  80056a:	83 c4 1c             	add    $0x1c,%esp
  80056d:	5b                   	pop    %ebx
  80056e:	5e                   	pop    %esi
  80056f:	5f                   	pop    %edi
  800570:	5d                   	pop    %ebp
  800571:	c3                   	ret    

00800572 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  800572:	55                   	push   %ebp
  800573:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800575:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800579:	66 c1 c0 08          	rol    $0x8,%ax
}
  80057d:	5d                   	pop    %ebp
  80057e:	c3                   	ret    

0080057f <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  80057f:	55                   	push   %ebp
  800580:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800582:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800586:	66 c1 c0 08          	rol    $0x8,%ax
  return htons(n);
}
  80058a:	5d                   	pop    %ebp
  80058b:	c3                   	ret    

0080058c <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  80058c:	55                   	push   %ebp
  80058d:	89 e5                	mov    %esp,%ebp
  80058f:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  800592:	89 d0                	mov    %edx,%eax
  800594:	c1 e0 18             	shl    $0x18,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  800597:	89 d1                	mov    %edx,%ecx
  800599:	c1 e9 18             	shr    $0x18,%ecx
    ((n & 0xff0000UL) >> 8) |
  80059c:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  80059e:	89 d1                	mov    %edx,%ecx
  8005a0:	c1 e1 08             	shl    $0x8,%ecx
  8005a3:	81 e1 00 00 ff 00    	and    $0xff0000,%ecx
    ((n & 0xff0000UL) >> 8) |
  8005a9:	09 c8                	or     %ecx,%eax
  8005ab:	c1 ea 08             	shr    $0x8,%edx
  8005ae:	81 e2 00 ff 00 00    	and    $0xff00,%edx
  8005b4:	09 d0                	or     %edx,%eax
}
  8005b6:	5d                   	pop    %ebp
  8005b7:	c3                   	ret    

008005b8 <inet_aton>:
{
  8005b8:	55                   	push   %ebp
  8005b9:	89 e5                	mov    %esp,%ebp
  8005bb:	57                   	push   %edi
  8005bc:	56                   	push   %esi
  8005bd:	53                   	push   %ebx
  8005be:	83 ec 2c             	sub    $0x2c,%esp
  8005c1:	8b 55 08             	mov    0x8(%ebp),%edx
  c = *cp;
  8005c4:	0f be 02             	movsbl (%edx),%eax
  u32_t *pp = parts;
  8005c7:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8005ca:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8005cd:	e9 a6 00 00 00       	jmp    800678 <inet_aton+0xc0>
      c = *++cp;
  8005d2:	0f b6 42 01          	movzbl 0x1(%edx),%eax
      if (c == 'x' || c == 'X') {
  8005d6:	89 c1                	mov    %eax,%ecx
  8005d8:	83 e1 df             	and    $0xffffffdf,%ecx
  8005db:	80 f9 58             	cmp    $0x58,%cl
  8005de:	74 10                	je     8005f0 <inet_aton+0x38>
      c = *++cp;
  8005e0:	83 c2 01             	add    $0x1,%edx
  8005e3:	0f be c0             	movsbl %al,%eax
        base = 8;
  8005e6:	be 08 00 00 00       	mov    $0x8,%esi
  8005eb:	e9 a2 00 00 00       	jmp    800692 <inet_aton+0xda>
        c = *++cp;
  8005f0:	0f be 42 02          	movsbl 0x2(%edx),%eax
  8005f4:	8d 52 02             	lea    0x2(%edx),%edx
        base = 16;
  8005f7:	be 10 00 00 00       	mov    $0x10,%esi
  8005fc:	e9 91 00 00 00       	jmp    800692 <inet_aton+0xda>
        val = (val * base) + (int)(c - '0');
  800601:	0f af fe             	imul   %esi,%edi
  800604:	8d 7c 38 d0          	lea    -0x30(%eax,%edi,1),%edi
        c = *++cp;
  800608:	0f be 02             	movsbl (%edx),%eax
  80060b:	83 c2 01             	add    $0x1,%edx
  80060e:	8d 5a ff             	lea    -0x1(%edx),%ebx
      if (isdigit(c)) {
  800611:	88 45 d7             	mov    %al,-0x29(%ebp)
  800614:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800617:	80 f9 09             	cmp    $0x9,%cl
  80061a:	76 e5                	jbe    800601 <inet_aton+0x49>
      } else if (base == 16 && isxdigit(c)) {
  80061c:	83 fe 10             	cmp    $0x10,%esi
  80061f:	75 34                	jne    800655 <inet_aton+0x9d>
  800621:	0f b6 4d d7          	movzbl -0x29(%ebp),%ecx
  800625:	83 e9 61             	sub    $0x61,%ecx
  800628:	88 4d d6             	mov    %cl,-0x2a(%ebp)
  80062b:	0f b6 4d d7          	movzbl -0x29(%ebp),%ecx
  80062f:	83 e1 df             	and    $0xffffffdf,%ecx
  800632:	83 e9 41             	sub    $0x41,%ecx
  800635:	80 f9 05             	cmp    $0x5,%cl
  800638:	77 1b                	ja     800655 <inet_aton+0x9d>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  80063a:	c1 e7 04             	shl    $0x4,%edi
  80063d:	83 c0 0a             	add    $0xa,%eax
  800640:	80 7d d6 1a          	cmpb   $0x1a,-0x2a(%ebp)
  800644:	19 c9                	sbb    %ecx,%ecx
  800646:	83 e1 20             	and    $0x20,%ecx
  800649:	83 c1 41             	add    $0x41,%ecx
  80064c:	29 c8                	sub    %ecx,%eax
  80064e:	09 c7                	or     %eax,%edi
        c = *++cp;
  800650:	0f be 02             	movsbl (%edx),%eax
  800653:	eb b6                	jmp    80060b <inet_aton+0x53>
    if (c == '.') {
  800655:	83 f8 2e             	cmp    $0x2e,%eax
  800658:	75 45                	jne    80069f <inet_aton+0xe7>
      if (pp >= parts + 3)
  80065a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80065d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800660:	39 c6                	cmp    %eax,%esi
  800662:	0f 84 1b 01 00 00    	je     800783 <inet_aton+0x1cb>
      *pp++ = val;
  800668:	83 c6 04             	add    $0x4,%esi
  80066b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80066e:	89 7e fc             	mov    %edi,-0x4(%esi)
      c = *++cp;
  800671:	8d 53 01             	lea    0x1(%ebx),%edx
  800674:	0f be 43 01          	movsbl 0x1(%ebx),%eax
    if (!isdigit(c))
  800678:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80067b:	80 f9 09             	cmp    $0x9,%cl
  80067e:	0f 87 f8 00 00 00    	ja     80077c <inet_aton+0x1c4>
    base = 10;
  800684:	be 0a 00 00 00       	mov    $0xa,%esi
    if (c == '0') {
  800689:	83 f8 30             	cmp    $0x30,%eax
  80068c:	0f 84 40 ff ff ff    	je     8005d2 <inet_aton+0x1a>
  800692:	83 c2 01             	add    $0x1,%edx
        base = 8;
  800695:	bf 00 00 00 00       	mov    $0x0,%edi
  80069a:	e9 6f ff ff ff       	jmp    80060e <inet_aton+0x56>
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80069f:	0f b6 75 d7          	movzbl -0x29(%ebp),%esi
  8006a3:	85 c0                	test   %eax,%eax
  8006a5:	74 29                	je     8006d0 <inet_aton+0x118>
    return (0);
  8006a7:	ba 00 00 00 00       	mov    $0x0,%edx
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8006ac:	89 f3                	mov    %esi,%ebx
  8006ae:	80 fb 1f             	cmp    $0x1f,%bl
  8006b1:	0f 86 d1 00 00 00    	jbe    800788 <inet_aton+0x1d0>
  8006b7:	84 c0                	test   %al,%al
  8006b9:	0f 88 c9 00 00 00    	js     800788 <inet_aton+0x1d0>
  8006bf:	83 f8 20             	cmp    $0x20,%eax
  8006c2:	74 0c                	je     8006d0 <inet_aton+0x118>
  8006c4:	83 e8 09             	sub    $0x9,%eax
  8006c7:	83 f8 04             	cmp    $0x4,%eax
  8006ca:	0f 87 b8 00 00 00    	ja     800788 <inet_aton+0x1d0>
  n = pp - parts + 1;
  8006d0:	8d 55 d8             	lea    -0x28(%ebp),%edx
  8006d3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006d6:	29 d0                	sub    %edx,%eax
  8006d8:	c1 f8 02             	sar    $0x2,%eax
  8006db:	8d 50 01             	lea    0x1(%eax),%edx
  switch (n) {
  8006de:	83 f8 02             	cmp    $0x2,%eax
  8006e1:	74 7a                	je     80075d <inet_aton+0x1a5>
  8006e3:	83 fa 03             	cmp    $0x3,%edx
  8006e6:	7f 49                	jg     800731 <inet_aton+0x179>
  8006e8:	85 d2                	test   %edx,%edx
  8006ea:	0f 84 98 00 00 00    	je     800788 <inet_aton+0x1d0>
  8006f0:	83 fa 02             	cmp    $0x2,%edx
  8006f3:	75 19                	jne    80070e <inet_aton+0x156>
      return (0);
  8006f5:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xffffffUL)
  8006fa:	81 ff ff ff ff 00    	cmp    $0xffffff,%edi
  800700:	0f 87 82 00 00 00    	ja     800788 <inet_aton+0x1d0>
    val |= parts[0] << 24;
  800706:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800709:	c1 e0 18             	shl    $0x18,%eax
  80070c:	09 c7                	or     %eax,%edi
  return (1);
  80070e:	ba 01 00 00 00       	mov    $0x1,%edx
  if (addr)
  800713:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800717:	74 6f                	je     800788 <inet_aton+0x1d0>
    addr->s_addr = htonl(val);
  800719:	83 ec 0c             	sub    $0xc,%esp
  80071c:	57                   	push   %edi
  80071d:	e8 6a fe ff ff       	call   80058c <htonl>
  800722:	83 c4 10             	add    $0x10,%esp
  800725:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800728:	89 03                	mov    %eax,(%ebx)
  return (1);
  80072a:	ba 01 00 00 00       	mov    $0x1,%edx
  80072f:	eb 57                	jmp    800788 <inet_aton+0x1d0>
  switch (n) {
  800731:	83 fa 04             	cmp    $0x4,%edx
  800734:	75 d8                	jne    80070e <inet_aton+0x156>
      return (0);
  800736:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xff)
  80073b:	81 ff ff 00 00 00    	cmp    $0xff,%edi
  800741:	77 45                	ja     800788 <inet_aton+0x1d0>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  800743:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800746:	c1 e0 18             	shl    $0x18,%eax
  800749:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80074c:	c1 e2 10             	shl    $0x10,%edx
  80074f:	09 d0                	or     %edx,%eax
  800751:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800754:	c1 e2 08             	shl    $0x8,%edx
  800757:	09 d0                	or     %edx,%eax
  800759:	09 c7                	or     %eax,%edi
    break;
  80075b:	eb b1                	jmp    80070e <inet_aton+0x156>
      return (0);
  80075d:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xffff)
  800762:	81 ff ff ff 00 00    	cmp    $0xffff,%edi
  800768:	77 1e                	ja     800788 <inet_aton+0x1d0>
    val |= (parts[0] << 24) | (parts[1] << 16);
  80076a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80076d:	c1 e0 18             	shl    $0x18,%eax
  800770:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800773:	c1 e2 10             	shl    $0x10,%edx
  800776:	09 d0                	or     %edx,%eax
  800778:	09 c7                	or     %eax,%edi
    break;
  80077a:	eb 92                	jmp    80070e <inet_aton+0x156>
      return (0);
  80077c:	ba 00 00 00 00       	mov    $0x0,%edx
  800781:	eb 05                	jmp    800788 <inet_aton+0x1d0>
        return (0);
  800783:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800788:	89 d0                	mov    %edx,%eax
  80078a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078d:	5b                   	pop    %ebx
  80078e:	5e                   	pop    %esi
  80078f:	5f                   	pop    %edi
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <inet_addr>:
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	83 ec 20             	sub    $0x20,%esp
  if (inet_aton(cp, &val)) {
  800798:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80079b:	50                   	push   %eax
  80079c:	ff 75 08             	push   0x8(%ebp)
  80079f:	e8 14 fe ff ff       	call   8005b8 <inet_aton>
  8007a4:	83 c4 10             	add    $0x10,%esp
    return (val.s_addr);
  8007a7:	85 c0                	test   %eax,%eax
  8007a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8007ae:	0f 45 45 f4          	cmovne -0xc(%ebp),%eax
}
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 14             	sub    $0x14,%esp
  return htonl(n);
  8007ba:	ff 75 08             	push   0x8(%ebp)
  8007bd:	e8 ca fd ff ff       	call   80058c <htonl>
  8007c2:	83 c4 10             	add    $0x10,%esp
}
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	56                   	push   %esi
  8007cb:	53                   	push   %ebx
  8007cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007cf:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8007d2:	e8 c3 0a 00 00       	call   80129a <sys_getenvid>
  8007d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8007dc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8007df:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8007e4:	a3 10 50 80 00       	mov    %eax,0x805010

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8007e9:	85 db                	test   %ebx,%ebx
  8007eb:	7e 07                	jle    8007f4 <libmain+0x2d>
		binaryname = argv[0];
  8007ed:	8b 06                	mov    (%esi),%eax
  8007ef:	a3 20 40 80 00       	mov    %eax,0x804020

	// call user main routine
	umain(argc, argv);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	56                   	push   %esi
  8007f8:	53                   	push   %ebx
  8007f9:	e8 e9 fb ff ff       	call   8003e7 <umain>

	// exit gracefully
	exit();
  8007fe:	e8 0a 00 00 00       	call   80080d <exit>
}
  800803:	83 c4 10             	add    $0x10,%esp
  800806:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800809:	5b                   	pop    %ebx
  80080a:	5e                   	pop    %esi
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800813:	e8 e3 0e 00 00       	call   8016fb <close_all>
	sys_env_destroy(0);
  800818:	83 ec 0c             	sub    $0xc,%esp
  80081b:	6a 00                	push   $0x0
  80081d:	e8 37 0a 00 00       	call   801259 <sys_env_destroy>
}
  800822:	83 c4 10             	add    $0x10,%esp
  800825:	c9                   	leave  
  800826:	c3                   	ret    

00800827 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	56                   	push   %esi
  80082b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80082c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80082f:	8b 35 20 40 80 00    	mov    0x804020,%esi
  800835:	e8 60 0a 00 00       	call   80129a <sys_getenvid>
  80083a:	83 ec 0c             	sub    $0xc,%esp
  80083d:	ff 75 0c             	push   0xc(%ebp)
  800840:	ff 75 08             	push   0x8(%ebp)
  800843:	56                   	push   %esi
  800844:	50                   	push   %eax
  800845:	68 3c 2e 80 00       	push   $0x802e3c
  80084a:	e8 b3 00 00 00       	call   800902 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80084f:	83 c4 18             	add    $0x18,%esp
  800852:	53                   	push   %ebx
  800853:	ff 75 10             	push   0x10(%ebp)
  800856:	e8 56 00 00 00       	call   8008b1 <vcprintf>
	cprintf("\n");
  80085b:	c7 04 24 a8 2c 80 00 	movl   $0x802ca8,(%esp)
  800862:	e8 9b 00 00 00       	call   800902 <cprintf>
  800867:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80086a:	cc                   	int3   
  80086b:	eb fd                	jmp    80086a <_panic+0x43>

0080086d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	53                   	push   %ebx
  800871:	83 ec 04             	sub    $0x4,%esp
  800874:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800877:	8b 13                	mov    (%ebx),%edx
  800879:	8d 42 01             	lea    0x1(%edx),%eax
  80087c:	89 03                	mov    %eax,(%ebx)
  80087e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800881:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800885:	3d ff 00 00 00       	cmp    $0xff,%eax
  80088a:	74 09                	je     800895 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80088c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800890:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800893:	c9                   	leave  
  800894:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800895:	83 ec 08             	sub    $0x8,%esp
  800898:	68 ff 00 00 00       	push   $0xff
  80089d:	8d 43 08             	lea    0x8(%ebx),%eax
  8008a0:	50                   	push   %eax
  8008a1:	e8 76 09 00 00       	call   80121c <sys_cputs>
		b->idx = 0;
  8008a6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8008ac:	83 c4 10             	add    $0x10,%esp
  8008af:	eb db                	jmp    80088c <putch+0x1f>

008008b1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8008ba:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8008c1:	00 00 00 
	b.cnt = 0;
  8008c4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8008cb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8008ce:	ff 75 0c             	push   0xc(%ebp)
  8008d1:	ff 75 08             	push   0x8(%ebp)
  8008d4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8008da:	50                   	push   %eax
  8008db:	68 6d 08 80 00       	push   $0x80086d
  8008e0:	e8 14 01 00 00       	call   8009f9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8008e5:	83 c4 08             	add    $0x8,%esp
  8008e8:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8008ee:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8008f4:	50                   	push   %eax
  8008f5:	e8 22 09 00 00       	call   80121c <sys_cputs>

	return b.cnt;
}
  8008fa:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800900:	c9                   	leave  
  800901:	c3                   	ret    

00800902 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800908:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80090b:	50                   	push   %eax
  80090c:	ff 75 08             	push   0x8(%ebp)
  80090f:	e8 9d ff ff ff       	call   8008b1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800914:	c9                   	leave  
  800915:	c3                   	ret    

00800916 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	57                   	push   %edi
  80091a:	56                   	push   %esi
  80091b:	53                   	push   %ebx
  80091c:	83 ec 1c             	sub    $0x1c,%esp
  80091f:	89 c7                	mov    %eax,%edi
  800921:	89 d6                	mov    %edx,%esi
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
  800929:	89 d1                	mov    %edx,%ecx
  80092b:	89 c2                	mov    %eax,%edx
  80092d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800930:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800933:	8b 45 10             	mov    0x10(%ebp),%eax
  800936:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800939:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80093c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800943:	39 c2                	cmp    %eax,%edx
  800945:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800948:	72 3e                	jb     800988 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80094a:	83 ec 0c             	sub    $0xc,%esp
  80094d:	ff 75 18             	push   0x18(%ebp)
  800950:	83 eb 01             	sub    $0x1,%ebx
  800953:	53                   	push   %ebx
  800954:	50                   	push   %eax
  800955:	83 ec 08             	sub    $0x8,%esp
  800958:	ff 75 e4             	push   -0x1c(%ebp)
  80095b:	ff 75 e0             	push   -0x20(%ebp)
  80095e:	ff 75 dc             	push   -0x24(%ebp)
  800961:	ff 75 d8             	push   -0x28(%ebp)
  800964:	e8 97 20 00 00       	call   802a00 <__udivdi3>
  800969:	83 c4 18             	add    $0x18,%esp
  80096c:	52                   	push   %edx
  80096d:	50                   	push   %eax
  80096e:	89 f2                	mov    %esi,%edx
  800970:	89 f8                	mov    %edi,%eax
  800972:	e8 9f ff ff ff       	call   800916 <printnum>
  800977:	83 c4 20             	add    $0x20,%esp
  80097a:	eb 13                	jmp    80098f <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80097c:	83 ec 08             	sub    $0x8,%esp
  80097f:	56                   	push   %esi
  800980:	ff 75 18             	push   0x18(%ebp)
  800983:	ff d7                	call   *%edi
  800985:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800988:	83 eb 01             	sub    $0x1,%ebx
  80098b:	85 db                	test   %ebx,%ebx
  80098d:	7f ed                	jg     80097c <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80098f:	83 ec 08             	sub    $0x8,%esp
  800992:	56                   	push   %esi
  800993:	83 ec 04             	sub    $0x4,%esp
  800996:	ff 75 e4             	push   -0x1c(%ebp)
  800999:	ff 75 e0             	push   -0x20(%ebp)
  80099c:	ff 75 dc             	push   -0x24(%ebp)
  80099f:	ff 75 d8             	push   -0x28(%ebp)
  8009a2:	e8 79 21 00 00       	call   802b20 <__umoddi3>
  8009a7:	83 c4 14             	add    $0x14,%esp
  8009aa:	0f be 80 5f 2e 80 00 	movsbl 0x802e5f(%eax),%eax
  8009b1:	50                   	push   %eax
  8009b2:	ff d7                	call   *%edi
}
  8009b4:	83 c4 10             	add    $0x10,%esp
  8009b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009ba:	5b                   	pop    %ebx
  8009bb:	5e                   	pop    %esi
  8009bc:	5f                   	pop    %edi
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8009c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8009c9:	8b 10                	mov    (%eax),%edx
  8009cb:	3b 50 04             	cmp    0x4(%eax),%edx
  8009ce:	73 0a                	jae    8009da <sprintputch+0x1b>
		*b->buf++ = ch;
  8009d0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009d3:	89 08                	mov    %ecx,(%eax)
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	88 02                	mov    %al,(%edx)
}
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <printfmt>:
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8009e2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8009e5:	50                   	push   %eax
  8009e6:	ff 75 10             	push   0x10(%ebp)
  8009e9:	ff 75 0c             	push   0xc(%ebp)
  8009ec:	ff 75 08             	push   0x8(%ebp)
  8009ef:	e8 05 00 00 00       	call   8009f9 <vprintfmt>
}
  8009f4:	83 c4 10             	add    $0x10,%esp
  8009f7:	c9                   	leave  
  8009f8:	c3                   	ret    

008009f9 <vprintfmt>:
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	57                   	push   %edi
  8009fd:	56                   	push   %esi
  8009fe:	53                   	push   %ebx
  8009ff:	83 ec 3c             	sub    $0x3c,%esp
  800a02:	8b 75 08             	mov    0x8(%ebp),%esi
  800a05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a08:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a0b:	eb 0a                	jmp    800a17 <vprintfmt+0x1e>
			putch(ch, putdat);
  800a0d:	83 ec 08             	sub    $0x8,%esp
  800a10:	53                   	push   %ebx
  800a11:	50                   	push   %eax
  800a12:	ff d6                	call   *%esi
  800a14:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a17:	83 c7 01             	add    $0x1,%edi
  800a1a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a1e:	83 f8 25             	cmp    $0x25,%eax
  800a21:	74 0c                	je     800a2f <vprintfmt+0x36>
			if (ch == '\0')
  800a23:	85 c0                	test   %eax,%eax
  800a25:	75 e6                	jne    800a0d <vprintfmt+0x14>
}
  800a27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a2a:	5b                   	pop    %ebx
  800a2b:	5e                   	pop    %esi
  800a2c:	5f                   	pop    %edi
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    
		padc = ' ';
  800a2f:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800a33:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800a3a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800a41:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800a48:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800a4d:	8d 47 01             	lea    0x1(%edi),%eax
  800a50:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a53:	0f b6 17             	movzbl (%edi),%edx
  800a56:	8d 42 dd             	lea    -0x23(%edx),%eax
  800a59:	3c 55                	cmp    $0x55,%al
  800a5b:	0f 87 bb 03 00 00    	ja     800e1c <vprintfmt+0x423>
  800a61:	0f b6 c0             	movzbl %al,%eax
  800a64:	ff 24 85 a0 2f 80 00 	jmp    *0x802fa0(,%eax,4)
  800a6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800a6e:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800a72:	eb d9                	jmp    800a4d <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800a74:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a77:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800a7b:	eb d0                	jmp    800a4d <vprintfmt+0x54>
  800a7d:	0f b6 d2             	movzbl %dl,%edx
  800a80:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
  800a88:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800a8b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800a8e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800a92:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800a95:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800a98:	83 f9 09             	cmp    $0x9,%ecx
  800a9b:	77 55                	ja     800af2 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800a9d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800aa0:	eb e9                	jmp    800a8b <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800aa2:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa5:	8b 00                	mov    (%eax),%eax
  800aa7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aaa:	8b 45 14             	mov    0x14(%ebp),%eax
  800aad:	8d 40 04             	lea    0x4(%eax),%eax
  800ab0:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800ab3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800ab6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800aba:	79 91                	jns    800a4d <vprintfmt+0x54>
				width = precision, precision = -1;
  800abc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800abf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ac2:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800ac9:	eb 82                	jmp    800a4d <vprintfmt+0x54>
  800acb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800ace:	85 d2                	test   %edx,%edx
  800ad0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad5:	0f 49 c2             	cmovns %edx,%eax
  800ad8:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800adb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800ade:	e9 6a ff ff ff       	jmp    800a4d <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800ae3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800ae6:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800aed:	e9 5b ff ff ff       	jmp    800a4d <vprintfmt+0x54>
  800af2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800af5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800af8:	eb bc                	jmp    800ab6 <vprintfmt+0xbd>
			lflag++;
  800afa:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800afd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800b00:	e9 48 ff ff ff       	jmp    800a4d <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800b05:	8b 45 14             	mov    0x14(%ebp),%eax
  800b08:	8d 78 04             	lea    0x4(%eax),%edi
  800b0b:	83 ec 08             	sub    $0x8,%esp
  800b0e:	53                   	push   %ebx
  800b0f:	ff 30                	push   (%eax)
  800b11:	ff d6                	call   *%esi
			break;
  800b13:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800b16:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800b19:	e9 9d 02 00 00       	jmp    800dbb <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800b1e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b21:	8d 78 04             	lea    0x4(%eax),%edi
  800b24:	8b 10                	mov    (%eax),%edx
  800b26:	89 d0                	mov    %edx,%eax
  800b28:	f7 d8                	neg    %eax
  800b2a:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b2d:	83 f8 0f             	cmp    $0xf,%eax
  800b30:	7f 23                	jg     800b55 <vprintfmt+0x15c>
  800b32:	8b 14 85 00 31 80 00 	mov    0x803100(,%eax,4),%edx
  800b39:	85 d2                	test   %edx,%edx
  800b3b:	74 18                	je     800b55 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800b3d:	52                   	push   %edx
  800b3e:	68 35 32 80 00       	push   $0x803235
  800b43:	53                   	push   %ebx
  800b44:	56                   	push   %esi
  800b45:	e8 92 fe ff ff       	call   8009dc <printfmt>
  800b4a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800b4d:	89 7d 14             	mov    %edi,0x14(%ebp)
  800b50:	e9 66 02 00 00       	jmp    800dbb <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800b55:	50                   	push   %eax
  800b56:	68 77 2e 80 00       	push   $0x802e77
  800b5b:	53                   	push   %ebx
  800b5c:	56                   	push   %esi
  800b5d:	e8 7a fe ff ff       	call   8009dc <printfmt>
  800b62:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800b65:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800b68:	e9 4e 02 00 00       	jmp    800dbb <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800b6d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b70:	83 c0 04             	add    $0x4,%eax
  800b73:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800b76:	8b 45 14             	mov    0x14(%ebp),%eax
  800b79:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800b7b:	85 d2                	test   %edx,%edx
  800b7d:	b8 70 2e 80 00       	mov    $0x802e70,%eax
  800b82:	0f 45 c2             	cmovne %edx,%eax
  800b85:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800b88:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b8c:	7e 06                	jle    800b94 <vprintfmt+0x19b>
  800b8e:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800b92:	75 0d                	jne    800ba1 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b94:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800b97:	89 c7                	mov    %eax,%edi
  800b99:	03 45 e0             	add    -0x20(%ebp),%eax
  800b9c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b9f:	eb 55                	jmp    800bf6 <vprintfmt+0x1fd>
  800ba1:	83 ec 08             	sub    $0x8,%esp
  800ba4:	ff 75 d8             	push   -0x28(%ebp)
  800ba7:	ff 75 cc             	push   -0x34(%ebp)
  800baa:	e8 0a 03 00 00       	call   800eb9 <strnlen>
  800baf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800bb2:	29 c1                	sub    %eax,%ecx
  800bb4:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800bb7:	83 c4 10             	add    $0x10,%esp
  800bba:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800bbc:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800bc0:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800bc3:	eb 0f                	jmp    800bd4 <vprintfmt+0x1db>
					putch(padc, putdat);
  800bc5:	83 ec 08             	sub    $0x8,%esp
  800bc8:	53                   	push   %ebx
  800bc9:	ff 75 e0             	push   -0x20(%ebp)
  800bcc:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800bce:	83 ef 01             	sub    $0x1,%edi
  800bd1:	83 c4 10             	add    $0x10,%esp
  800bd4:	85 ff                	test   %edi,%edi
  800bd6:	7f ed                	jg     800bc5 <vprintfmt+0x1cc>
  800bd8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800bdb:	85 d2                	test   %edx,%edx
  800bdd:	b8 00 00 00 00       	mov    $0x0,%eax
  800be2:	0f 49 c2             	cmovns %edx,%eax
  800be5:	29 c2                	sub    %eax,%edx
  800be7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800bea:	eb a8                	jmp    800b94 <vprintfmt+0x19b>
					putch(ch, putdat);
  800bec:	83 ec 08             	sub    $0x8,%esp
  800bef:	53                   	push   %ebx
  800bf0:	52                   	push   %edx
  800bf1:	ff d6                	call   *%esi
  800bf3:	83 c4 10             	add    $0x10,%esp
  800bf6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800bf9:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bfb:	83 c7 01             	add    $0x1,%edi
  800bfe:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c02:	0f be d0             	movsbl %al,%edx
  800c05:	85 d2                	test   %edx,%edx
  800c07:	74 4b                	je     800c54 <vprintfmt+0x25b>
  800c09:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800c0d:	78 06                	js     800c15 <vprintfmt+0x21c>
  800c0f:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800c13:	78 1e                	js     800c33 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800c15:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800c19:	74 d1                	je     800bec <vprintfmt+0x1f3>
  800c1b:	0f be c0             	movsbl %al,%eax
  800c1e:	83 e8 20             	sub    $0x20,%eax
  800c21:	83 f8 5e             	cmp    $0x5e,%eax
  800c24:	76 c6                	jbe    800bec <vprintfmt+0x1f3>
					putch('?', putdat);
  800c26:	83 ec 08             	sub    $0x8,%esp
  800c29:	53                   	push   %ebx
  800c2a:	6a 3f                	push   $0x3f
  800c2c:	ff d6                	call   *%esi
  800c2e:	83 c4 10             	add    $0x10,%esp
  800c31:	eb c3                	jmp    800bf6 <vprintfmt+0x1fd>
  800c33:	89 cf                	mov    %ecx,%edi
  800c35:	eb 0e                	jmp    800c45 <vprintfmt+0x24c>
				putch(' ', putdat);
  800c37:	83 ec 08             	sub    $0x8,%esp
  800c3a:	53                   	push   %ebx
  800c3b:	6a 20                	push   $0x20
  800c3d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800c3f:	83 ef 01             	sub    $0x1,%edi
  800c42:	83 c4 10             	add    $0x10,%esp
  800c45:	85 ff                	test   %edi,%edi
  800c47:	7f ee                	jg     800c37 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800c49:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800c4c:	89 45 14             	mov    %eax,0x14(%ebp)
  800c4f:	e9 67 01 00 00       	jmp    800dbb <vprintfmt+0x3c2>
  800c54:	89 cf                	mov    %ecx,%edi
  800c56:	eb ed                	jmp    800c45 <vprintfmt+0x24c>
	if (lflag >= 2)
  800c58:	83 f9 01             	cmp    $0x1,%ecx
  800c5b:	7f 1b                	jg     800c78 <vprintfmt+0x27f>
	else if (lflag)
  800c5d:	85 c9                	test   %ecx,%ecx
  800c5f:	74 63                	je     800cc4 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800c61:	8b 45 14             	mov    0x14(%ebp),%eax
  800c64:	8b 00                	mov    (%eax),%eax
  800c66:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c69:	99                   	cltd   
  800c6a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800c6d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c70:	8d 40 04             	lea    0x4(%eax),%eax
  800c73:	89 45 14             	mov    %eax,0x14(%ebp)
  800c76:	eb 17                	jmp    800c8f <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800c78:	8b 45 14             	mov    0x14(%ebp),%eax
  800c7b:	8b 50 04             	mov    0x4(%eax),%edx
  800c7e:	8b 00                	mov    (%eax),%eax
  800c80:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c83:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800c86:	8b 45 14             	mov    0x14(%ebp),%eax
  800c89:	8d 40 08             	lea    0x8(%eax),%eax
  800c8c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800c8f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800c92:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800c95:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800c9a:	85 c9                	test   %ecx,%ecx
  800c9c:	0f 89 ff 00 00 00    	jns    800da1 <vprintfmt+0x3a8>
				putch('-', putdat);
  800ca2:	83 ec 08             	sub    $0x8,%esp
  800ca5:	53                   	push   %ebx
  800ca6:	6a 2d                	push   $0x2d
  800ca8:	ff d6                	call   *%esi
				num = -(long long) num;
  800caa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800cad:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800cb0:	f7 da                	neg    %edx
  800cb2:	83 d1 00             	adc    $0x0,%ecx
  800cb5:	f7 d9                	neg    %ecx
  800cb7:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800cba:	bf 0a 00 00 00       	mov    $0xa,%edi
  800cbf:	e9 dd 00 00 00       	jmp    800da1 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800cc4:	8b 45 14             	mov    0x14(%ebp),%eax
  800cc7:	8b 00                	mov    (%eax),%eax
  800cc9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ccc:	99                   	cltd   
  800ccd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800cd0:	8b 45 14             	mov    0x14(%ebp),%eax
  800cd3:	8d 40 04             	lea    0x4(%eax),%eax
  800cd6:	89 45 14             	mov    %eax,0x14(%ebp)
  800cd9:	eb b4                	jmp    800c8f <vprintfmt+0x296>
	if (lflag >= 2)
  800cdb:	83 f9 01             	cmp    $0x1,%ecx
  800cde:	7f 1e                	jg     800cfe <vprintfmt+0x305>
	else if (lflag)
  800ce0:	85 c9                	test   %ecx,%ecx
  800ce2:	74 32                	je     800d16 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800ce4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ce7:	8b 10                	mov    (%eax),%edx
  800ce9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cee:	8d 40 04             	lea    0x4(%eax),%eax
  800cf1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800cf4:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800cf9:	e9 a3 00 00 00       	jmp    800da1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800cfe:	8b 45 14             	mov    0x14(%ebp),%eax
  800d01:	8b 10                	mov    (%eax),%edx
  800d03:	8b 48 04             	mov    0x4(%eax),%ecx
  800d06:	8d 40 08             	lea    0x8(%eax),%eax
  800d09:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800d0c:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800d11:	e9 8b 00 00 00       	jmp    800da1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800d16:	8b 45 14             	mov    0x14(%ebp),%eax
  800d19:	8b 10                	mov    (%eax),%edx
  800d1b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d20:	8d 40 04             	lea    0x4(%eax),%eax
  800d23:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800d26:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800d2b:	eb 74                	jmp    800da1 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800d2d:	83 f9 01             	cmp    $0x1,%ecx
  800d30:	7f 1b                	jg     800d4d <vprintfmt+0x354>
	else if (lflag)
  800d32:	85 c9                	test   %ecx,%ecx
  800d34:	74 2c                	je     800d62 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800d36:	8b 45 14             	mov    0x14(%ebp),%eax
  800d39:	8b 10                	mov    (%eax),%edx
  800d3b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d40:	8d 40 04             	lea    0x4(%eax),%eax
  800d43:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800d46:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800d4b:	eb 54                	jmp    800da1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800d4d:	8b 45 14             	mov    0x14(%ebp),%eax
  800d50:	8b 10                	mov    (%eax),%edx
  800d52:	8b 48 04             	mov    0x4(%eax),%ecx
  800d55:	8d 40 08             	lea    0x8(%eax),%eax
  800d58:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800d5b:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800d60:	eb 3f                	jmp    800da1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800d62:	8b 45 14             	mov    0x14(%ebp),%eax
  800d65:	8b 10                	mov    (%eax),%edx
  800d67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6c:	8d 40 04             	lea    0x4(%eax),%eax
  800d6f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800d72:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800d77:	eb 28                	jmp    800da1 <vprintfmt+0x3a8>
			putch('0', putdat);
  800d79:	83 ec 08             	sub    $0x8,%esp
  800d7c:	53                   	push   %ebx
  800d7d:	6a 30                	push   $0x30
  800d7f:	ff d6                	call   *%esi
			putch('x', putdat);
  800d81:	83 c4 08             	add    $0x8,%esp
  800d84:	53                   	push   %ebx
  800d85:	6a 78                	push   $0x78
  800d87:	ff d6                	call   *%esi
			num = (unsigned long long)
  800d89:	8b 45 14             	mov    0x14(%ebp),%eax
  800d8c:	8b 10                	mov    (%eax),%edx
  800d8e:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800d93:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800d96:	8d 40 04             	lea    0x4(%eax),%eax
  800d99:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800d9c:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800da1:	83 ec 0c             	sub    $0xc,%esp
  800da4:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800da8:	50                   	push   %eax
  800da9:	ff 75 e0             	push   -0x20(%ebp)
  800dac:	57                   	push   %edi
  800dad:	51                   	push   %ecx
  800dae:	52                   	push   %edx
  800daf:	89 da                	mov    %ebx,%edx
  800db1:	89 f0                	mov    %esi,%eax
  800db3:	e8 5e fb ff ff       	call   800916 <printnum>
			break;
  800db8:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800dbb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800dbe:	e9 54 fc ff ff       	jmp    800a17 <vprintfmt+0x1e>
	if (lflag >= 2)
  800dc3:	83 f9 01             	cmp    $0x1,%ecx
  800dc6:	7f 1b                	jg     800de3 <vprintfmt+0x3ea>
	else if (lflag)
  800dc8:	85 c9                	test   %ecx,%ecx
  800dca:	74 2c                	je     800df8 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800dcc:	8b 45 14             	mov    0x14(%ebp),%eax
  800dcf:	8b 10                	mov    (%eax),%edx
  800dd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd6:	8d 40 04             	lea    0x4(%eax),%eax
  800dd9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ddc:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800de1:	eb be                	jmp    800da1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800de3:	8b 45 14             	mov    0x14(%ebp),%eax
  800de6:	8b 10                	mov    (%eax),%edx
  800de8:	8b 48 04             	mov    0x4(%eax),%ecx
  800deb:	8d 40 08             	lea    0x8(%eax),%eax
  800dee:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800df1:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800df6:	eb a9                	jmp    800da1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800df8:	8b 45 14             	mov    0x14(%ebp),%eax
  800dfb:	8b 10                	mov    (%eax),%edx
  800dfd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e02:	8d 40 04             	lea    0x4(%eax),%eax
  800e05:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800e08:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800e0d:	eb 92                	jmp    800da1 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800e0f:	83 ec 08             	sub    $0x8,%esp
  800e12:	53                   	push   %ebx
  800e13:	6a 25                	push   $0x25
  800e15:	ff d6                	call   *%esi
			break;
  800e17:	83 c4 10             	add    $0x10,%esp
  800e1a:	eb 9f                	jmp    800dbb <vprintfmt+0x3c2>
			putch('%', putdat);
  800e1c:	83 ec 08             	sub    $0x8,%esp
  800e1f:	53                   	push   %ebx
  800e20:	6a 25                	push   $0x25
  800e22:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800e24:	83 c4 10             	add    $0x10,%esp
  800e27:	89 f8                	mov    %edi,%eax
  800e29:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800e2d:	74 05                	je     800e34 <vprintfmt+0x43b>
  800e2f:	83 e8 01             	sub    $0x1,%eax
  800e32:	eb f5                	jmp    800e29 <vprintfmt+0x430>
  800e34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e37:	eb 82                	jmp    800dbb <vprintfmt+0x3c2>

00800e39 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	83 ec 18             	sub    $0x18,%esp
  800e3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e42:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800e45:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e48:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800e4c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800e4f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800e56:	85 c0                	test   %eax,%eax
  800e58:	74 26                	je     800e80 <vsnprintf+0x47>
  800e5a:	85 d2                	test   %edx,%edx
  800e5c:	7e 22                	jle    800e80 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800e5e:	ff 75 14             	push   0x14(%ebp)
  800e61:	ff 75 10             	push   0x10(%ebp)
  800e64:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e67:	50                   	push   %eax
  800e68:	68 bf 09 80 00       	push   $0x8009bf
  800e6d:	e8 87 fb ff ff       	call   8009f9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800e72:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e75:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7b:	83 c4 10             	add    $0x10,%esp
}
  800e7e:	c9                   	leave  
  800e7f:	c3                   	ret    
		return -E_INVAL;
  800e80:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e85:	eb f7                	jmp    800e7e <vsnprintf+0x45>

00800e87 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800e8d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800e90:	50                   	push   %eax
  800e91:	ff 75 10             	push   0x10(%ebp)
  800e94:	ff 75 0c             	push   0xc(%ebp)
  800e97:	ff 75 08             	push   0x8(%ebp)
  800e9a:	e8 9a ff ff ff       	call   800e39 <vsnprintf>
	va_end(ap);

	return rc;
}
  800e9f:	c9                   	leave  
  800ea0:	c3                   	ret    

00800ea1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ea7:	b8 00 00 00 00       	mov    $0x0,%eax
  800eac:	eb 03                	jmp    800eb1 <strlen+0x10>
		n++;
  800eae:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800eb1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800eb5:	75 f7                	jne    800eae <strlen+0xd>
	return n;
}
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebf:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ec2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec7:	eb 03                	jmp    800ecc <strnlen+0x13>
		n++;
  800ec9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ecc:	39 d0                	cmp    %edx,%eax
  800ece:	74 08                	je     800ed8 <strnlen+0x1f>
  800ed0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800ed4:	75 f3                	jne    800ec9 <strnlen+0x10>
  800ed6:	89 c2                	mov    %eax,%edx
	return n;
}
  800ed8:	89 d0                	mov    %edx,%eax
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	53                   	push   %ebx
  800ee0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ee6:	b8 00 00 00 00       	mov    $0x0,%eax
  800eeb:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800eef:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800ef2:	83 c0 01             	add    $0x1,%eax
  800ef5:	84 d2                	test   %dl,%dl
  800ef7:	75 f2                	jne    800eeb <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ef9:	89 c8                	mov    %ecx,%eax
  800efb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800efe:	c9                   	leave  
  800eff:	c3                   	ret    

00800f00 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	53                   	push   %ebx
  800f04:	83 ec 10             	sub    $0x10,%esp
  800f07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800f0a:	53                   	push   %ebx
  800f0b:	e8 91 ff ff ff       	call   800ea1 <strlen>
  800f10:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800f13:	ff 75 0c             	push   0xc(%ebp)
  800f16:	01 d8                	add    %ebx,%eax
  800f18:	50                   	push   %eax
  800f19:	e8 be ff ff ff       	call   800edc <strcpy>
	return dst;
}
  800f1e:	89 d8                	mov    %ebx,%eax
  800f20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f23:	c9                   	leave  
  800f24:	c3                   	ret    

00800f25 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	56                   	push   %esi
  800f29:	53                   	push   %ebx
  800f2a:	8b 75 08             	mov    0x8(%ebp),%esi
  800f2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f30:	89 f3                	mov    %esi,%ebx
  800f32:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f35:	89 f0                	mov    %esi,%eax
  800f37:	eb 0f                	jmp    800f48 <strncpy+0x23>
		*dst++ = *src;
  800f39:	83 c0 01             	add    $0x1,%eax
  800f3c:	0f b6 0a             	movzbl (%edx),%ecx
  800f3f:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800f42:	80 f9 01             	cmp    $0x1,%cl
  800f45:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800f48:	39 d8                	cmp    %ebx,%eax
  800f4a:	75 ed                	jne    800f39 <strncpy+0x14>
	}
	return ret;
}
  800f4c:	89 f0                	mov    %esi,%eax
  800f4e:	5b                   	pop    %ebx
  800f4f:	5e                   	pop    %esi
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    

00800f52 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	56                   	push   %esi
  800f56:	53                   	push   %ebx
  800f57:	8b 75 08             	mov    0x8(%ebp),%esi
  800f5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5d:	8b 55 10             	mov    0x10(%ebp),%edx
  800f60:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f62:	85 d2                	test   %edx,%edx
  800f64:	74 21                	je     800f87 <strlcpy+0x35>
  800f66:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800f6a:	89 f2                	mov    %esi,%edx
  800f6c:	eb 09                	jmp    800f77 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800f6e:	83 c1 01             	add    $0x1,%ecx
  800f71:	83 c2 01             	add    $0x1,%edx
  800f74:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800f77:	39 c2                	cmp    %eax,%edx
  800f79:	74 09                	je     800f84 <strlcpy+0x32>
  800f7b:	0f b6 19             	movzbl (%ecx),%ebx
  800f7e:	84 db                	test   %bl,%bl
  800f80:	75 ec                	jne    800f6e <strlcpy+0x1c>
  800f82:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800f84:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800f87:	29 f0                	sub    %esi,%eax
}
  800f89:	5b                   	pop    %ebx
  800f8a:	5e                   	pop    %esi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f93:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800f96:	eb 06                	jmp    800f9e <strcmp+0x11>
		p++, q++;
  800f98:	83 c1 01             	add    $0x1,%ecx
  800f9b:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800f9e:	0f b6 01             	movzbl (%ecx),%eax
  800fa1:	84 c0                	test   %al,%al
  800fa3:	74 04                	je     800fa9 <strcmp+0x1c>
  800fa5:	3a 02                	cmp    (%edx),%al
  800fa7:	74 ef                	je     800f98 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800fa9:	0f b6 c0             	movzbl %al,%eax
  800fac:	0f b6 12             	movzbl (%edx),%edx
  800faf:	29 d0                	sub    %edx,%eax
}
  800fb1:	5d                   	pop    %ebp
  800fb2:	c3                   	ret    

00800fb3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	53                   	push   %ebx
  800fb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fba:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fbd:	89 c3                	mov    %eax,%ebx
  800fbf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800fc2:	eb 06                	jmp    800fca <strncmp+0x17>
		n--, p++, q++;
  800fc4:	83 c0 01             	add    $0x1,%eax
  800fc7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800fca:	39 d8                	cmp    %ebx,%eax
  800fcc:	74 18                	je     800fe6 <strncmp+0x33>
  800fce:	0f b6 08             	movzbl (%eax),%ecx
  800fd1:	84 c9                	test   %cl,%cl
  800fd3:	74 04                	je     800fd9 <strncmp+0x26>
  800fd5:	3a 0a                	cmp    (%edx),%cl
  800fd7:	74 eb                	je     800fc4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800fd9:	0f b6 00             	movzbl (%eax),%eax
  800fdc:	0f b6 12             	movzbl (%edx),%edx
  800fdf:	29 d0                	sub    %edx,%eax
}
  800fe1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe4:	c9                   	leave  
  800fe5:	c3                   	ret    
		return 0;
  800fe6:	b8 00 00 00 00       	mov    $0x0,%eax
  800feb:	eb f4                	jmp    800fe1 <strncmp+0x2e>

00800fed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ff7:	eb 03                	jmp    800ffc <strchr+0xf>
  800ff9:	83 c0 01             	add    $0x1,%eax
  800ffc:	0f b6 10             	movzbl (%eax),%edx
  800fff:	84 d2                	test   %dl,%dl
  801001:	74 06                	je     801009 <strchr+0x1c>
		if (*s == c)
  801003:	38 ca                	cmp    %cl,%dl
  801005:	75 f2                	jne    800ff9 <strchr+0xc>
  801007:	eb 05                	jmp    80100e <strchr+0x21>
			return (char *) s;
	return 0;
  801009:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	8b 45 08             	mov    0x8(%ebp),%eax
  801016:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80101a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80101d:	38 ca                	cmp    %cl,%dl
  80101f:	74 09                	je     80102a <strfind+0x1a>
  801021:	84 d2                	test   %dl,%dl
  801023:	74 05                	je     80102a <strfind+0x1a>
	for (; *s; s++)
  801025:	83 c0 01             	add    $0x1,%eax
  801028:	eb f0                	jmp    80101a <strfind+0xa>
			break;
	return (char *) s;
}
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    

0080102c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	57                   	push   %edi
  801030:	56                   	push   %esi
  801031:	53                   	push   %ebx
  801032:	8b 7d 08             	mov    0x8(%ebp),%edi
  801035:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801038:	85 c9                	test   %ecx,%ecx
  80103a:	74 2f                	je     80106b <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80103c:	89 f8                	mov    %edi,%eax
  80103e:	09 c8                	or     %ecx,%eax
  801040:	a8 03                	test   $0x3,%al
  801042:	75 21                	jne    801065 <memset+0x39>
		c &= 0xFF;
  801044:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801048:	89 d0                	mov    %edx,%eax
  80104a:	c1 e0 08             	shl    $0x8,%eax
  80104d:	89 d3                	mov    %edx,%ebx
  80104f:	c1 e3 18             	shl    $0x18,%ebx
  801052:	89 d6                	mov    %edx,%esi
  801054:	c1 e6 10             	shl    $0x10,%esi
  801057:	09 f3                	or     %esi,%ebx
  801059:	09 da                	or     %ebx,%edx
  80105b:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80105d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801060:	fc                   	cld    
  801061:	f3 ab                	rep stos %eax,%es:(%edi)
  801063:	eb 06                	jmp    80106b <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801065:	8b 45 0c             	mov    0xc(%ebp),%eax
  801068:	fc                   	cld    
  801069:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80106b:	89 f8                	mov    %edi,%eax
  80106d:	5b                   	pop    %ebx
  80106e:	5e                   	pop    %esi
  80106f:	5f                   	pop    %edi
  801070:	5d                   	pop    %ebp
  801071:	c3                   	ret    

00801072 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	57                   	push   %edi
  801076:	56                   	push   %esi
  801077:	8b 45 08             	mov    0x8(%ebp),%eax
  80107a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80107d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801080:	39 c6                	cmp    %eax,%esi
  801082:	73 32                	jae    8010b6 <memmove+0x44>
  801084:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801087:	39 c2                	cmp    %eax,%edx
  801089:	76 2b                	jbe    8010b6 <memmove+0x44>
		s += n;
		d += n;
  80108b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80108e:	89 d6                	mov    %edx,%esi
  801090:	09 fe                	or     %edi,%esi
  801092:	09 ce                	or     %ecx,%esi
  801094:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80109a:	75 0e                	jne    8010aa <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80109c:	83 ef 04             	sub    $0x4,%edi
  80109f:	8d 72 fc             	lea    -0x4(%edx),%esi
  8010a2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8010a5:	fd                   	std    
  8010a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8010a8:	eb 09                	jmp    8010b3 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8010aa:	83 ef 01             	sub    $0x1,%edi
  8010ad:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8010b0:	fd                   	std    
  8010b1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8010b3:	fc                   	cld    
  8010b4:	eb 1a                	jmp    8010d0 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8010b6:	89 f2                	mov    %esi,%edx
  8010b8:	09 c2                	or     %eax,%edx
  8010ba:	09 ca                	or     %ecx,%edx
  8010bc:	f6 c2 03             	test   $0x3,%dl
  8010bf:	75 0a                	jne    8010cb <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8010c1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8010c4:	89 c7                	mov    %eax,%edi
  8010c6:	fc                   	cld    
  8010c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8010c9:	eb 05                	jmp    8010d0 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8010cb:	89 c7                	mov    %eax,%edi
  8010cd:	fc                   	cld    
  8010ce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8010d0:	5e                   	pop    %esi
  8010d1:	5f                   	pop    %edi
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8010da:	ff 75 10             	push   0x10(%ebp)
  8010dd:	ff 75 0c             	push   0xc(%ebp)
  8010e0:	ff 75 08             	push   0x8(%ebp)
  8010e3:	e8 8a ff ff ff       	call   801072 <memmove>
}
  8010e8:	c9                   	leave  
  8010e9:	c3                   	ret    

008010ea <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	56                   	push   %esi
  8010ee:	53                   	push   %ebx
  8010ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f5:	89 c6                	mov    %eax,%esi
  8010f7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010fa:	eb 06                	jmp    801102 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8010fc:	83 c0 01             	add    $0x1,%eax
  8010ff:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801102:	39 f0                	cmp    %esi,%eax
  801104:	74 14                	je     80111a <memcmp+0x30>
		if (*s1 != *s2)
  801106:	0f b6 08             	movzbl (%eax),%ecx
  801109:	0f b6 1a             	movzbl (%edx),%ebx
  80110c:	38 d9                	cmp    %bl,%cl
  80110e:	74 ec                	je     8010fc <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801110:	0f b6 c1             	movzbl %cl,%eax
  801113:	0f b6 db             	movzbl %bl,%ebx
  801116:	29 d8                	sub    %ebx,%eax
  801118:	eb 05                	jmp    80111f <memcmp+0x35>
	}

	return 0;
  80111a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80111f:	5b                   	pop    %ebx
  801120:	5e                   	pop    %esi
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    

00801123 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	8b 45 08             	mov    0x8(%ebp),%eax
  801129:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80112c:	89 c2                	mov    %eax,%edx
  80112e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801131:	eb 03                	jmp    801136 <memfind+0x13>
  801133:	83 c0 01             	add    $0x1,%eax
  801136:	39 d0                	cmp    %edx,%eax
  801138:	73 04                	jae    80113e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80113a:	38 08                	cmp    %cl,(%eax)
  80113c:	75 f5                	jne    801133 <memfind+0x10>
			break;
	return (void *) s;
}
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    

00801140 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	57                   	push   %edi
  801144:	56                   	push   %esi
  801145:	53                   	push   %ebx
  801146:	8b 55 08             	mov    0x8(%ebp),%edx
  801149:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80114c:	eb 03                	jmp    801151 <strtol+0x11>
		s++;
  80114e:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801151:	0f b6 02             	movzbl (%edx),%eax
  801154:	3c 20                	cmp    $0x20,%al
  801156:	74 f6                	je     80114e <strtol+0xe>
  801158:	3c 09                	cmp    $0x9,%al
  80115a:	74 f2                	je     80114e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  80115c:	3c 2b                	cmp    $0x2b,%al
  80115e:	74 2a                	je     80118a <strtol+0x4a>
	int neg = 0;
  801160:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801165:	3c 2d                	cmp    $0x2d,%al
  801167:	74 2b                	je     801194 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801169:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80116f:	75 0f                	jne    801180 <strtol+0x40>
  801171:	80 3a 30             	cmpb   $0x30,(%edx)
  801174:	74 28                	je     80119e <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801176:	85 db                	test   %ebx,%ebx
  801178:	b8 0a 00 00 00       	mov    $0xa,%eax
  80117d:	0f 44 d8             	cmove  %eax,%ebx
  801180:	b9 00 00 00 00       	mov    $0x0,%ecx
  801185:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801188:	eb 46                	jmp    8011d0 <strtol+0x90>
		s++;
  80118a:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  80118d:	bf 00 00 00 00       	mov    $0x0,%edi
  801192:	eb d5                	jmp    801169 <strtol+0x29>
		s++, neg = 1;
  801194:	83 c2 01             	add    $0x1,%edx
  801197:	bf 01 00 00 00       	mov    $0x1,%edi
  80119c:	eb cb                	jmp    801169 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80119e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8011a2:	74 0e                	je     8011b2 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8011a4:	85 db                	test   %ebx,%ebx
  8011a6:	75 d8                	jne    801180 <strtol+0x40>
		s++, base = 8;
  8011a8:	83 c2 01             	add    $0x1,%edx
  8011ab:	bb 08 00 00 00       	mov    $0x8,%ebx
  8011b0:	eb ce                	jmp    801180 <strtol+0x40>
		s += 2, base = 16;
  8011b2:	83 c2 02             	add    $0x2,%edx
  8011b5:	bb 10 00 00 00       	mov    $0x10,%ebx
  8011ba:	eb c4                	jmp    801180 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8011bc:	0f be c0             	movsbl %al,%eax
  8011bf:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8011c2:	3b 45 10             	cmp    0x10(%ebp),%eax
  8011c5:	7d 3a                	jge    801201 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  8011c7:	83 c2 01             	add    $0x1,%edx
  8011ca:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  8011ce:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  8011d0:	0f b6 02             	movzbl (%edx),%eax
  8011d3:	8d 70 d0             	lea    -0x30(%eax),%esi
  8011d6:	89 f3                	mov    %esi,%ebx
  8011d8:	80 fb 09             	cmp    $0x9,%bl
  8011db:	76 df                	jbe    8011bc <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  8011dd:	8d 70 9f             	lea    -0x61(%eax),%esi
  8011e0:	89 f3                	mov    %esi,%ebx
  8011e2:	80 fb 19             	cmp    $0x19,%bl
  8011e5:	77 08                	ja     8011ef <strtol+0xaf>
			dig = *s - 'a' + 10;
  8011e7:	0f be c0             	movsbl %al,%eax
  8011ea:	83 e8 57             	sub    $0x57,%eax
  8011ed:	eb d3                	jmp    8011c2 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8011ef:	8d 70 bf             	lea    -0x41(%eax),%esi
  8011f2:	89 f3                	mov    %esi,%ebx
  8011f4:	80 fb 19             	cmp    $0x19,%bl
  8011f7:	77 08                	ja     801201 <strtol+0xc1>
			dig = *s - 'A' + 10;
  8011f9:	0f be c0             	movsbl %al,%eax
  8011fc:	83 e8 37             	sub    $0x37,%eax
  8011ff:	eb c1                	jmp    8011c2 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801201:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801205:	74 05                	je     80120c <strtol+0xcc>
		*endptr = (char *) s;
  801207:	8b 45 0c             	mov    0xc(%ebp),%eax
  80120a:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  80120c:	89 c8                	mov    %ecx,%eax
  80120e:	f7 d8                	neg    %eax
  801210:	85 ff                	test   %edi,%edi
  801212:	0f 45 c8             	cmovne %eax,%ecx
}
  801215:	89 c8                	mov    %ecx,%eax
  801217:	5b                   	pop    %ebx
  801218:	5e                   	pop    %esi
  801219:	5f                   	pop    %edi
  80121a:	5d                   	pop    %ebp
  80121b:	c3                   	ret    

0080121c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	57                   	push   %edi
  801220:	56                   	push   %esi
  801221:	53                   	push   %ebx
	asm volatile("int %1\n"
  801222:	b8 00 00 00 00       	mov    $0x0,%eax
  801227:	8b 55 08             	mov    0x8(%ebp),%edx
  80122a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80122d:	89 c3                	mov    %eax,%ebx
  80122f:	89 c7                	mov    %eax,%edi
  801231:	89 c6                	mov    %eax,%esi
  801233:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801235:	5b                   	pop    %ebx
  801236:	5e                   	pop    %esi
  801237:	5f                   	pop    %edi
  801238:	5d                   	pop    %ebp
  801239:	c3                   	ret    

0080123a <sys_cgetc>:

int
sys_cgetc(void)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	57                   	push   %edi
  80123e:	56                   	push   %esi
  80123f:	53                   	push   %ebx
	asm volatile("int %1\n"
  801240:	ba 00 00 00 00       	mov    $0x0,%edx
  801245:	b8 01 00 00 00       	mov    $0x1,%eax
  80124a:	89 d1                	mov    %edx,%ecx
  80124c:	89 d3                	mov    %edx,%ebx
  80124e:	89 d7                	mov    %edx,%edi
  801250:	89 d6                	mov    %edx,%esi
  801252:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801254:	5b                   	pop    %ebx
  801255:	5e                   	pop    %esi
  801256:	5f                   	pop    %edi
  801257:	5d                   	pop    %ebp
  801258:	c3                   	ret    

00801259 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	57                   	push   %edi
  80125d:	56                   	push   %esi
  80125e:	53                   	push   %ebx
  80125f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801262:	b9 00 00 00 00       	mov    $0x0,%ecx
  801267:	8b 55 08             	mov    0x8(%ebp),%edx
  80126a:	b8 03 00 00 00       	mov    $0x3,%eax
  80126f:	89 cb                	mov    %ecx,%ebx
  801271:	89 cf                	mov    %ecx,%edi
  801273:	89 ce                	mov    %ecx,%esi
  801275:	cd 30                	int    $0x30
	if(check && ret > 0)
  801277:	85 c0                	test   %eax,%eax
  801279:	7f 08                	jg     801283 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80127b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127e:	5b                   	pop    %ebx
  80127f:	5e                   	pop    %esi
  801280:	5f                   	pop    %edi
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801283:	83 ec 0c             	sub    $0xc,%esp
  801286:	50                   	push   %eax
  801287:	6a 03                	push   $0x3
  801289:	68 5f 31 80 00       	push   $0x80315f
  80128e:	6a 2a                	push   $0x2a
  801290:	68 7c 31 80 00       	push   $0x80317c
  801295:	e8 8d f5 ff ff       	call   800827 <_panic>

0080129a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	57                   	push   %edi
  80129e:	56                   	push   %esi
  80129f:	53                   	push   %ebx
	asm volatile("int %1\n"
  8012a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a5:	b8 02 00 00 00       	mov    $0x2,%eax
  8012aa:	89 d1                	mov    %edx,%ecx
  8012ac:	89 d3                	mov    %edx,%ebx
  8012ae:	89 d7                	mov    %edx,%edi
  8012b0:	89 d6                	mov    %edx,%esi
  8012b2:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8012b4:	5b                   	pop    %ebx
  8012b5:	5e                   	pop    %esi
  8012b6:	5f                   	pop    %edi
  8012b7:	5d                   	pop    %ebp
  8012b8:	c3                   	ret    

008012b9 <sys_yield>:

void
sys_yield(void)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	57                   	push   %edi
  8012bd:	56                   	push   %esi
  8012be:	53                   	push   %ebx
	asm volatile("int %1\n"
  8012bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012c9:	89 d1                	mov    %edx,%ecx
  8012cb:	89 d3                	mov    %edx,%ebx
  8012cd:	89 d7                	mov    %edx,%edi
  8012cf:	89 d6                	mov    %edx,%esi
  8012d1:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8012d3:	5b                   	pop    %ebx
  8012d4:	5e                   	pop    %esi
  8012d5:	5f                   	pop    %edi
  8012d6:	5d                   	pop    %ebp
  8012d7:	c3                   	ret    

008012d8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	57                   	push   %edi
  8012dc:	56                   	push   %esi
  8012dd:	53                   	push   %ebx
  8012de:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012e1:	be 00 00 00 00       	mov    $0x0,%esi
  8012e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ec:	b8 04 00 00 00       	mov    $0x4,%eax
  8012f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012f4:	89 f7                	mov    %esi,%edi
  8012f6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012f8:	85 c0                	test   %eax,%eax
  8012fa:	7f 08                	jg     801304 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8012fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ff:	5b                   	pop    %ebx
  801300:	5e                   	pop    %esi
  801301:	5f                   	pop    %edi
  801302:	5d                   	pop    %ebp
  801303:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801304:	83 ec 0c             	sub    $0xc,%esp
  801307:	50                   	push   %eax
  801308:	6a 04                	push   $0x4
  80130a:	68 5f 31 80 00       	push   $0x80315f
  80130f:	6a 2a                	push   $0x2a
  801311:	68 7c 31 80 00       	push   $0x80317c
  801316:	e8 0c f5 ff ff       	call   800827 <_panic>

0080131b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
  80131e:	57                   	push   %edi
  80131f:	56                   	push   %esi
  801320:	53                   	push   %ebx
  801321:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801324:	8b 55 08             	mov    0x8(%ebp),%edx
  801327:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80132a:	b8 05 00 00 00       	mov    $0x5,%eax
  80132f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801332:	8b 7d 14             	mov    0x14(%ebp),%edi
  801335:	8b 75 18             	mov    0x18(%ebp),%esi
  801338:	cd 30                	int    $0x30
	if(check && ret > 0)
  80133a:	85 c0                	test   %eax,%eax
  80133c:	7f 08                	jg     801346 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80133e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801341:	5b                   	pop    %ebx
  801342:	5e                   	pop    %esi
  801343:	5f                   	pop    %edi
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801346:	83 ec 0c             	sub    $0xc,%esp
  801349:	50                   	push   %eax
  80134a:	6a 05                	push   $0x5
  80134c:	68 5f 31 80 00       	push   $0x80315f
  801351:	6a 2a                	push   $0x2a
  801353:	68 7c 31 80 00       	push   $0x80317c
  801358:	e8 ca f4 ff ff       	call   800827 <_panic>

0080135d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	57                   	push   %edi
  801361:	56                   	push   %esi
  801362:	53                   	push   %ebx
  801363:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801366:	bb 00 00 00 00       	mov    $0x0,%ebx
  80136b:	8b 55 08             	mov    0x8(%ebp),%edx
  80136e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801371:	b8 06 00 00 00       	mov    $0x6,%eax
  801376:	89 df                	mov    %ebx,%edi
  801378:	89 de                	mov    %ebx,%esi
  80137a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80137c:	85 c0                	test   %eax,%eax
  80137e:	7f 08                	jg     801388 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801380:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801383:	5b                   	pop    %ebx
  801384:	5e                   	pop    %esi
  801385:	5f                   	pop    %edi
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801388:	83 ec 0c             	sub    $0xc,%esp
  80138b:	50                   	push   %eax
  80138c:	6a 06                	push   $0x6
  80138e:	68 5f 31 80 00       	push   $0x80315f
  801393:	6a 2a                	push   $0x2a
  801395:	68 7c 31 80 00       	push   $0x80317c
  80139a:	e8 88 f4 ff ff       	call   800827 <_panic>

0080139f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	57                   	push   %edi
  8013a3:	56                   	push   %esi
  8013a4:	53                   	push   %ebx
  8013a5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8013a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8013b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b3:	b8 08 00 00 00       	mov    $0x8,%eax
  8013b8:	89 df                	mov    %ebx,%edi
  8013ba:	89 de                	mov    %ebx,%esi
  8013bc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	7f 08                	jg     8013ca <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c5:	5b                   	pop    %ebx
  8013c6:	5e                   	pop    %esi
  8013c7:	5f                   	pop    %edi
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8013ca:	83 ec 0c             	sub    $0xc,%esp
  8013cd:	50                   	push   %eax
  8013ce:	6a 08                	push   $0x8
  8013d0:	68 5f 31 80 00       	push   $0x80315f
  8013d5:	6a 2a                	push   $0x2a
  8013d7:	68 7c 31 80 00       	push   $0x80317c
  8013dc:	e8 46 f4 ff ff       	call   800827 <_panic>

008013e1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8013e1:	55                   	push   %ebp
  8013e2:	89 e5                	mov    %esp,%ebp
  8013e4:	57                   	push   %edi
  8013e5:	56                   	push   %esi
  8013e6:	53                   	push   %ebx
  8013e7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8013ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f5:	b8 09 00 00 00       	mov    $0x9,%eax
  8013fa:	89 df                	mov    %ebx,%edi
  8013fc:	89 de                	mov    %ebx,%esi
  8013fe:	cd 30                	int    $0x30
	if(check && ret > 0)
  801400:	85 c0                	test   %eax,%eax
  801402:	7f 08                	jg     80140c <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801404:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801407:	5b                   	pop    %ebx
  801408:	5e                   	pop    %esi
  801409:	5f                   	pop    %edi
  80140a:	5d                   	pop    %ebp
  80140b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80140c:	83 ec 0c             	sub    $0xc,%esp
  80140f:	50                   	push   %eax
  801410:	6a 09                	push   $0x9
  801412:	68 5f 31 80 00       	push   $0x80315f
  801417:	6a 2a                	push   $0x2a
  801419:	68 7c 31 80 00       	push   $0x80317c
  80141e:	e8 04 f4 ff ff       	call   800827 <_panic>

00801423 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	57                   	push   %edi
  801427:	56                   	push   %esi
  801428:	53                   	push   %ebx
  801429:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80142c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801431:	8b 55 08             	mov    0x8(%ebp),%edx
  801434:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801437:	b8 0a 00 00 00       	mov    $0xa,%eax
  80143c:	89 df                	mov    %ebx,%edi
  80143e:	89 de                	mov    %ebx,%esi
  801440:	cd 30                	int    $0x30
	if(check && ret > 0)
  801442:	85 c0                	test   %eax,%eax
  801444:	7f 08                	jg     80144e <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801446:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801449:	5b                   	pop    %ebx
  80144a:	5e                   	pop    %esi
  80144b:	5f                   	pop    %edi
  80144c:	5d                   	pop    %ebp
  80144d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80144e:	83 ec 0c             	sub    $0xc,%esp
  801451:	50                   	push   %eax
  801452:	6a 0a                	push   $0xa
  801454:	68 5f 31 80 00       	push   $0x80315f
  801459:	6a 2a                	push   $0x2a
  80145b:	68 7c 31 80 00       	push   $0x80317c
  801460:	e8 c2 f3 ff ff       	call   800827 <_panic>

00801465 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	57                   	push   %edi
  801469:	56                   	push   %esi
  80146a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80146b:	8b 55 08             	mov    0x8(%ebp),%edx
  80146e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801471:	b8 0c 00 00 00       	mov    $0xc,%eax
  801476:	be 00 00 00 00       	mov    $0x0,%esi
  80147b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80147e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801481:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801483:	5b                   	pop    %ebx
  801484:	5e                   	pop    %esi
  801485:	5f                   	pop    %edi
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    

00801488 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	57                   	push   %edi
  80148c:	56                   	push   %esi
  80148d:	53                   	push   %ebx
  80148e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801491:	b9 00 00 00 00       	mov    $0x0,%ecx
  801496:	8b 55 08             	mov    0x8(%ebp),%edx
  801499:	b8 0d 00 00 00       	mov    $0xd,%eax
  80149e:	89 cb                	mov    %ecx,%ebx
  8014a0:	89 cf                	mov    %ecx,%edi
  8014a2:	89 ce                	mov    %ecx,%esi
  8014a4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	7f 08                	jg     8014b2 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8014aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ad:	5b                   	pop    %ebx
  8014ae:	5e                   	pop    %esi
  8014af:	5f                   	pop    %edi
  8014b0:	5d                   	pop    %ebp
  8014b1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8014b2:	83 ec 0c             	sub    $0xc,%esp
  8014b5:	50                   	push   %eax
  8014b6:	6a 0d                	push   $0xd
  8014b8:	68 5f 31 80 00       	push   $0x80315f
  8014bd:	6a 2a                	push   $0x2a
  8014bf:	68 7c 31 80 00       	push   $0x80317c
  8014c4:	e8 5e f3 ff ff       	call   800827 <_panic>

008014c9 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8014c9:	55                   	push   %ebp
  8014ca:	89 e5                	mov    %esp,%ebp
  8014cc:	57                   	push   %edi
  8014cd:	56                   	push   %esi
  8014ce:	53                   	push   %ebx
	asm volatile("int %1\n"
  8014cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d4:	b8 0e 00 00 00       	mov    $0xe,%eax
  8014d9:	89 d1                	mov    %edx,%ecx
  8014db:	89 d3                	mov    %edx,%ebx
  8014dd:	89 d7                	mov    %edx,%edi
  8014df:	89 d6                	mov    %edx,%esi
  8014e1:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8014e3:	5b                   	pop    %ebx
  8014e4:	5e                   	pop    %esi
  8014e5:	5f                   	pop    %edi
  8014e6:	5d                   	pop    %ebp
  8014e7:	c3                   	ret    

008014e8 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	57                   	push   %edi
  8014ec:	56                   	push   %esi
  8014ed:	53                   	push   %ebx
	asm volatile("int %1\n"
  8014ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014f9:	b8 0f 00 00 00       	mov    $0xf,%eax
  8014fe:	89 df                	mov    %ebx,%edi
  801500:	89 de                	mov    %ebx,%esi
  801502:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  801504:	5b                   	pop    %ebx
  801505:	5e                   	pop    %esi
  801506:	5f                   	pop    %edi
  801507:	5d                   	pop    %ebp
  801508:	c3                   	ret    

00801509 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	57                   	push   %edi
  80150d:	56                   	push   %esi
  80150e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80150f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801514:	8b 55 08             	mov    0x8(%ebp),%edx
  801517:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80151a:	b8 10 00 00 00       	mov    $0x10,%eax
  80151f:	89 df                	mov    %ebx,%edi
  801521:	89 de                	mov    %ebx,%esi
  801523:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  801525:	5b                   	pop    %ebx
  801526:	5e                   	pop    %esi
  801527:	5f                   	pop    %edi
  801528:	5d                   	pop    %ebp
  801529:	c3                   	ret    

0080152a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80152d:	8b 45 08             	mov    0x8(%ebp),%eax
  801530:	05 00 00 00 30       	add    $0x30000000,%eax
  801535:	c1 e8 0c             	shr    $0xc,%eax
}
  801538:	5d                   	pop    %ebp
  801539:	c3                   	ret    

0080153a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80153d:	8b 45 08             	mov    0x8(%ebp),%eax
  801540:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801545:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80154a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80154f:	5d                   	pop    %ebp
  801550:	c3                   	ret    

00801551 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801559:	89 c2                	mov    %eax,%edx
  80155b:	c1 ea 16             	shr    $0x16,%edx
  80155e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801565:	f6 c2 01             	test   $0x1,%dl
  801568:	74 29                	je     801593 <fd_alloc+0x42>
  80156a:	89 c2                	mov    %eax,%edx
  80156c:	c1 ea 0c             	shr    $0xc,%edx
  80156f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801576:	f6 c2 01             	test   $0x1,%dl
  801579:	74 18                	je     801593 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80157b:	05 00 10 00 00       	add    $0x1000,%eax
  801580:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801585:	75 d2                	jne    801559 <fd_alloc+0x8>
  801587:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80158c:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801591:	eb 05                	jmp    801598 <fd_alloc+0x47>
			return 0;
  801593:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801598:	8b 55 08             	mov    0x8(%ebp),%edx
  80159b:	89 02                	mov    %eax,(%edx)
}
  80159d:	89 c8                	mov    %ecx,%eax
  80159f:	5d                   	pop    %ebp
  8015a0:	c3                   	ret    

008015a1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8015a7:	83 f8 1f             	cmp    $0x1f,%eax
  8015aa:	77 30                	ja     8015dc <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8015ac:	c1 e0 0c             	shl    $0xc,%eax
  8015af:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8015b4:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8015ba:	f6 c2 01             	test   $0x1,%dl
  8015bd:	74 24                	je     8015e3 <fd_lookup+0x42>
  8015bf:	89 c2                	mov    %eax,%edx
  8015c1:	c1 ea 0c             	shr    $0xc,%edx
  8015c4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015cb:	f6 c2 01             	test   $0x1,%dl
  8015ce:	74 1a                	je     8015ea <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d3:	89 02                	mov    %eax,(%edx)
	return 0;
  8015d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015da:	5d                   	pop    %ebp
  8015db:	c3                   	ret    
		return -E_INVAL;
  8015dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015e1:	eb f7                	jmp    8015da <fd_lookup+0x39>
		return -E_INVAL;
  8015e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015e8:	eb f0                	jmp    8015da <fd_lookup+0x39>
  8015ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ef:	eb e9                	jmp    8015da <fd_lookup+0x39>

008015f1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015f1:	55                   	push   %ebp
  8015f2:	89 e5                	mov    %esp,%ebp
  8015f4:	53                   	push   %ebx
  8015f5:	83 ec 04             	sub    $0x4,%esp
  8015f8:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8015fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801600:	bb 24 40 80 00       	mov    $0x804024,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801605:	39 13                	cmp    %edx,(%ebx)
  801607:	74 37                	je     801640 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  801609:	83 c0 01             	add    $0x1,%eax
  80160c:	8b 1c 85 08 32 80 00 	mov    0x803208(,%eax,4),%ebx
  801613:	85 db                	test   %ebx,%ebx
  801615:	75 ee                	jne    801605 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801617:	a1 10 50 80 00       	mov    0x805010,%eax
  80161c:	8b 40 48             	mov    0x48(%eax),%eax
  80161f:	83 ec 04             	sub    $0x4,%esp
  801622:	52                   	push   %edx
  801623:	50                   	push   %eax
  801624:	68 8c 31 80 00       	push   $0x80318c
  801629:	e8 d4 f2 ff ff       	call   800902 <cprintf>
	*dev = 0;
	return -E_INVAL;
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801636:	8b 55 0c             	mov    0xc(%ebp),%edx
  801639:	89 1a                	mov    %ebx,(%edx)
}
  80163b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163e:	c9                   	leave  
  80163f:	c3                   	ret    
			return 0;
  801640:	b8 00 00 00 00       	mov    $0x0,%eax
  801645:	eb ef                	jmp    801636 <dev_lookup+0x45>

00801647 <fd_close>:
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	57                   	push   %edi
  80164b:	56                   	push   %esi
  80164c:	53                   	push   %ebx
  80164d:	83 ec 24             	sub    $0x24,%esp
  801650:	8b 75 08             	mov    0x8(%ebp),%esi
  801653:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801656:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801659:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80165a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801660:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801663:	50                   	push   %eax
  801664:	e8 38 ff ff ff       	call   8015a1 <fd_lookup>
  801669:	89 c3                	mov    %eax,%ebx
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	85 c0                	test   %eax,%eax
  801670:	78 05                	js     801677 <fd_close+0x30>
	    || fd != fd2)
  801672:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801675:	74 16                	je     80168d <fd_close+0x46>
		return (must_exist ? r : 0);
  801677:	89 f8                	mov    %edi,%eax
  801679:	84 c0                	test   %al,%al
  80167b:	b8 00 00 00 00       	mov    $0x0,%eax
  801680:	0f 44 d8             	cmove  %eax,%ebx
}
  801683:	89 d8                	mov    %ebx,%eax
  801685:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801688:	5b                   	pop    %ebx
  801689:	5e                   	pop    %esi
  80168a:	5f                   	pop    %edi
  80168b:	5d                   	pop    %ebp
  80168c:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80168d:	83 ec 08             	sub    $0x8,%esp
  801690:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801693:	50                   	push   %eax
  801694:	ff 36                	push   (%esi)
  801696:	e8 56 ff ff ff       	call   8015f1 <dev_lookup>
  80169b:	89 c3                	mov    %eax,%ebx
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	85 c0                	test   %eax,%eax
  8016a2:	78 1a                	js     8016be <fd_close+0x77>
		if (dev->dev_close)
  8016a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016a7:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8016aa:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	74 0b                	je     8016be <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8016b3:	83 ec 0c             	sub    $0xc,%esp
  8016b6:	56                   	push   %esi
  8016b7:	ff d0                	call   *%eax
  8016b9:	89 c3                	mov    %eax,%ebx
  8016bb:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8016be:	83 ec 08             	sub    $0x8,%esp
  8016c1:	56                   	push   %esi
  8016c2:	6a 00                	push   $0x0
  8016c4:	e8 94 fc ff ff       	call   80135d <sys_page_unmap>
	return r;
  8016c9:	83 c4 10             	add    $0x10,%esp
  8016cc:	eb b5                	jmp    801683 <fd_close+0x3c>

008016ce <close>:

int
close(int fdnum)
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d7:	50                   	push   %eax
  8016d8:	ff 75 08             	push   0x8(%ebp)
  8016db:	e8 c1 fe ff ff       	call   8015a1 <fd_lookup>
  8016e0:	83 c4 10             	add    $0x10,%esp
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	79 02                	jns    8016e9 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8016e7:	c9                   	leave  
  8016e8:	c3                   	ret    
		return fd_close(fd, 1);
  8016e9:	83 ec 08             	sub    $0x8,%esp
  8016ec:	6a 01                	push   $0x1
  8016ee:	ff 75 f4             	push   -0xc(%ebp)
  8016f1:	e8 51 ff ff ff       	call   801647 <fd_close>
  8016f6:	83 c4 10             	add    $0x10,%esp
  8016f9:	eb ec                	jmp    8016e7 <close+0x19>

008016fb <close_all>:

void
close_all(void)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	53                   	push   %ebx
  8016ff:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801702:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801707:	83 ec 0c             	sub    $0xc,%esp
  80170a:	53                   	push   %ebx
  80170b:	e8 be ff ff ff       	call   8016ce <close>
	for (i = 0; i < MAXFD; i++)
  801710:	83 c3 01             	add    $0x1,%ebx
  801713:	83 c4 10             	add    $0x10,%esp
  801716:	83 fb 20             	cmp    $0x20,%ebx
  801719:	75 ec                	jne    801707 <close_all+0xc>
}
  80171b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171e:	c9                   	leave  
  80171f:	c3                   	ret    

00801720 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	57                   	push   %edi
  801724:	56                   	push   %esi
  801725:	53                   	push   %ebx
  801726:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801729:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80172c:	50                   	push   %eax
  80172d:	ff 75 08             	push   0x8(%ebp)
  801730:	e8 6c fe ff ff       	call   8015a1 <fd_lookup>
  801735:	89 c3                	mov    %eax,%ebx
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	85 c0                	test   %eax,%eax
  80173c:	78 7f                	js     8017bd <dup+0x9d>
		return r;
	close(newfdnum);
  80173e:	83 ec 0c             	sub    $0xc,%esp
  801741:	ff 75 0c             	push   0xc(%ebp)
  801744:	e8 85 ff ff ff       	call   8016ce <close>

	newfd = INDEX2FD(newfdnum);
  801749:	8b 75 0c             	mov    0xc(%ebp),%esi
  80174c:	c1 e6 0c             	shl    $0xc,%esi
  80174f:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801755:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801758:	89 3c 24             	mov    %edi,(%esp)
  80175b:	e8 da fd ff ff       	call   80153a <fd2data>
  801760:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801762:	89 34 24             	mov    %esi,(%esp)
  801765:	e8 d0 fd ff ff       	call   80153a <fd2data>
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801770:	89 d8                	mov    %ebx,%eax
  801772:	c1 e8 16             	shr    $0x16,%eax
  801775:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80177c:	a8 01                	test   $0x1,%al
  80177e:	74 11                	je     801791 <dup+0x71>
  801780:	89 d8                	mov    %ebx,%eax
  801782:	c1 e8 0c             	shr    $0xc,%eax
  801785:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80178c:	f6 c2 01             	test   $0x1,%dl
  80178f:	75 36                	jne    8017c7 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801791:	89 f8                	mov    %edi,%eax
  801793:	c1 e8 0c             	shr    $0xc,%eax
  801796:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80179d:	83 ec 0c             	sub    $0xc,%esp
  8017a0:	25 07 0e 00 00       	and    $0xe07,%eax
  8017a5:	50                   	push   %eax
  8017a6:	56                   	push   %esi
  8017a7:	6a 00                	push   $0x0
  8017a9:	57                   	push   %edi
  8017aa:	6a 00                	push   $0x0
  8017ac:	e8 6a fb ff ff       	call   80131b <sys_page_map>
  8017b1:	89 c3                	mov    %eax,%ebx
  8017b3:	83 c4 20             	add    $0x20,%esp
  8017b6:	85 c0                	test   %eax,%eax
  8017b8:	78 33                	js     8017ed <dup+0xcd>
		goto err;

	return newfdnum;
  8017ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8017bd:	89 d8                	mov    %ebx,%eax
  8017bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c2:	5b                   	pop    %ebx
  8017c3:	5e                   	pop    %esi
  8017c4:	5f                   	pop    %edi
  8017c5:	5d                   	pop    %ebp
  8017c6:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8017c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017ce:	83 ec 0c             	sub    $0xc,%esp
  8017d1:	25 07 0e 00 00       	and    $0xe07,%eax
  8017d6:	50                   	push   %eax
  8017d7:	ff 75 d4             	push   -0x2c(%ebp)
  8017da:	6a 00                	push   $0x0
  8017dc:	53                   	push   %ebx
  8017dd:	6a 00                	push   $0x0
  8017df:	e8 37 fb ff ff       	call   80131b <sys_page_map>
  8017e4:	89 c3                	mov    %eax,%ebx
  8017e6:	83 c4 20             	add    $0x20,%esp
  8017e9:	85 c0                	test   %eax,%eax
  8017eb:	79 a4                	jns    801791 <dup+0x71>
	sys_page_unmap(0, newfd);
  8017ed:	83 ec 08             	sub    $0x8,%esp
  8017f0:	56                   	push   %esi
  8017f1:	6a 00                	push   $0x0
  8017f3:	e8 65 fb ff ff       	call   80135d <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017f8:	83 c4 08             	add    $0x8,%esp
  8017fb:	ff 75 d4             	push   -0x2c(%ebp)
  8017fe:	6a 00                	push   $0x0
  801800:	e8 58 fb ff ff       	call   80135d <sys_page_unmap>
	return r;
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	eb b3                	jmp    8017bd <dup+0x9d>

0080180a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	56                   	push   %esi
  80180e:	53                   	push   %ebx
  80180f:	83 ec 18             	sub    $0x18,%esp
  801812:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801815:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801818:	50                   	push   %eax
  801819:	56                   	push   %esi
  80181a:	e8 82 fd ff ff       	call   8015a1 <fd_lookup>
  80181f:	83 c4 10             	add    $0x10,%esp
  801822:	85 c0                	test   %eax,%eax
  801824:	78 3c                	js     801862 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801826:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801829:	83 ec 08             	sub    $0x8,%esp
  80182c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182f:	50                   	push   %eax
  801830:	ff 33                	push   (%ebx)
  801832:	e8 ba fd ff ff       	call   8015f1 <dev_lookup>
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	85 c0                	test   %eax,%eax
  80183c:	78 24                	js     801862 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80183e:	8b 43 08             	mov    0x8(%ebx),%eax
  801841:	83 e0 03             	and    $0x3,%eax
  801844:	83 f8 01             	cmp    $0x1,%eax
  801847:	74 20                	je     801869 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801849:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80184c:	8b 40 08             	mov    0x8(%eax),%eax
  80184f:	85 c0                	test   %eax,%eax
  801851:	74 37                	je     80188a <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801853:	83 ec 04             	sub    $0x4,%esp
  801856:	ff 75 10             	push   0x10(%ebp)
  801859:	ff 75 0c             	push   0xc(%ebp)
  80185c:	53                   	push   %ebx
  80185d:	ff d0                	call   *%eax
  80185f:	83 c4 10             	add    $0x10,%esp
}
  801862:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801865:	5b                   	pop    %ebx
  801866:	5e                   	pop    %esi
  801867:	5d                   	pop    %ebp
  801868:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801869:	a1 10 50 80 00       	mov    0x805010,%eax
  80186e:	8b 40 48             	mov    0x48(%eax),%eax
  801871:	83 ec 04             	sub    $0x4,%esp
  801874:	56                   	push   %esi
  801875:	50                   	push   %eax
  801876:	68 cd 31 80 00       	push   $0x8031cd
  80187b:	e8 82 f0 ff ff       	call   800902 <cprintf>
		return -E_INVAL;
  801880:	83 c4 10             	add    $0x10,%esp
  801883:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801888:	eb d8                	jmp    801862 <read+0x58>
		return -E_NOT_SUPP;
  80188a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80188f:	eb d1                	jmp    801862 <read+0x58>

00801891 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	57                   	push   %edi
  801895:	56                   	push   %esi
  801896:	53                   	push   %ebx
  801897:	83 ec 0c             	sub    $0xc,%esp
  80189a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80189d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018a5:	eb 02                	jmp    8018a9 <readn+0x18>
  8018a7:	01 c3                	add    %eax,%ebx
  8018a9:	39 f3                	cmp    %esi,%ebx
  8018ab:	73 21                	jae    8018ce <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018ad:	83 ec 04             	sub    $0x4,%esp
  8018b0:	89 f0                	mov    %esi,%eax
  8018b2:	29 d8                	sub    %ebx,%eax
  8018b4:	50                   	push   %eax
  8018b5:	89 d8                	mov    %ebx,%eax
  8018b7:	03 45 0c             	add    0xc(%ebp),%eax
  8018ba:	50                   	push   %eax
  8018bb:	57                   	push   %edi
  8018bc:	e8 49 ff ff ff       	call   80180a <read>
		if (m < 0)
  8018c1:	83 c4 10             	add    $0x10,%esp
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	78 04                	js     8018cc <readn+0x3b>
			return m;
		if (m == 0)
  8018c8:	75 dd                	jne    8018a7 <readn+0x16>
  8018ca:	eb 02                	jmp    8018ce <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018cc:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8018ce:	89 d8                	mov    %ebx,%eax
  8018d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018d3:	5b                   	pop    %ebx
  8018d4:	5e                   	pop    %esi
  8018d5:	5f                   	pop    %edi
  8018d6:	5d                   	pop    %ebp
  8018d7:	c3                   	ret    

008018d8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	56                   	push   %esi
  8018dc:	53                   	push   %ebx
  8018dd:	83 ec 18             	sub    $0x18,%esp
  8018e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e6:	50                   	push   %eax
  8018e7:	53                   	push   %ebx
  8018e8:	e8 b4 fc ff ff       	call   8015a1 <fd_lookup>
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	78 37                	js     80192b <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f4:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8018f7:	83 ec 08             	sub    $0x8,%esp
  8018fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018fd:	50                   	push   %eax
  8018fe:	ff 36                	push   (%esi)
  801900:	e8 ec fc ff ff       	call   8015f1 <dev_lookup>
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	85 c0                	test   %eax,%eax
  80190a:	78 1f                	js     80192b <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80190c:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801910:	74 20                	je     801932 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801912:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801915:	8b 40 0c             	mov    0xc(%eax),%eax
  801918:	85 c0                	test   %eax,%eax
  80191a:	74 37                	je     801953 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80191c:	83 ec 04             	sub    $0x4,%esp
  80191f:	ff 75 10             	push   0x10(%ebp)
  801922:	ff 75 0c             	push   0xc(%ebp)
  801925:	56                   	push   %esi
  801926:	ff d0                	call   *%eax
  801928:	83 c4 10             	add    $0x10,%esp
}
  80192b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192e:	5b                   	pop    %ebx
  80192f:	5e                   	pop    %esi
  801930:	5d                   	pop    %ebp
  801931:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801932:	a1 10 50 80 00       	mov    0x805010,%eax
  801937:	8b 40 48             	mov    0x48(%eax),%eax
  80193a:	83 ec 04             	sub    $0x4,%esp
  80193d:	53                   	push   %ebx
  80193e:	50                   	push   %eax
  80193f:	68 e9 31 80 00       	push   $0x8031e9
  801944:	e8 b9 ef ff ff       	call   800902 <cprintf>
		return -E_INVAL;
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801951:	eb d8                	jmp    80192b <write+0x53>
		return -E_NOT_SUPP;
  801953:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801958:	eb d1                	jmp    80192b <write+0x53>

0080195a <seek>:

int
seek(int fdnum, off_t offset)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801960:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801963:	50                   	push   %eax
  801964:	ff 75 08             	push   0x8(%ebp)
  801967:	e8 35 fc ff ff       	call   8015a1 <fd_lookup>
  80196c:	83 c4 10             	add    $0x10,%esp
  80196f:	85 c0                	test   %eax,%eax
  801971:	78 0e                	js     801981 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801973:	8b 55 0c             	mov    0xc(%ebp),%edx
  801976:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801979:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80197c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801981:	c9                   	leave  
  801982:	c3                   	ret    

00801983 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	56                   	push   %esi
  801987:	53                   	push   %ebx
  801988:	83 ec 18             	sub    $0x18,%esp
  80198b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80198e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801991:	50                   	push   %eax
  801992:	53                   	push   %ebx
  801993:	e8 09 fc ff ff       	call   8015a1 <fd_lookup>
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	85 c0                	test   %eax,%eax
  80199d:	78 34                	js     8019d3 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80199f:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8019a2:	83 ec 08             	sub    $0x8,%esp
  8019a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a8:	50                   	push   %eax
  8019a9:	ff 36                	push   (%esi)
  8019ab:	e8 41 fc ff ff       	call   8015f1 <dev_lookup>
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	78 1c                	js     8019d3 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019b7:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8019bb:	74 1d                	je     8019da <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8019bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c0:	8b 40 18             	mov    0x18(%eax),%eax
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	74 34                	je     8019fb <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019c7:	83 ec 08             	sub    $0x8,%esp
  8019ca:	ff 75 0c             	push   0xc(%ebp)
  8019cd:	56                   	push   %esi
  8019ce:	ff d0                	call   *%eax
  8019d0:	83 c4 10             	add    $0x10,%esp
}
  8019d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d6:	5b                   	pop    %ebx
  8019d7:	5e                   	pop    %esi
  8019d8:	5d                   	pop    %ebp
  8019d9:	c3                   	ret    
			thisenv->env_id, fdnum);
  8019da:	a1 10 50 80 00       	mov    0x805010,%eax
  8019df:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019e2:	83 ec 04             	sub    $0x4,%esp
  8019e5:	53                   	push   %ebx
  8019e6:	50                   	push   %eax
  8019e7:	68 ac 31 80 00       	push   $0x8031ac
  8019ec:	e8 11 ef ff ff       	call   800902 <cprintf>
		return -E_INVAL;
  8019f1:	83 c4 10             	add    $0x10,%esp
  8019f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019f9:	eb d8                	jmp    8019d3 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8019fb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a00:	eb d1                	jmp    8019d3 <ftruncate+0x50>

00801a02 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	56                   	push   %esi
  801a06:	53                   	push   %ebx
  801a07:	83 ec 18             	sub    $0x18,%esp
  801a0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a0d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a10:	50                   	push   %eax
  801a11:	ff 75 08             	push   0x8(%ebp)
  801a14:	e8 88 fb ff ff       	call   8015a1 <fd_lookup>
  801a19:	83 c4 10             	add    $0x10,%esp
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	78 49                	js     801a69 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a20:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801a23:	83 ec 08             	sub    $0x8,%esp
  801a26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a29:	50                   	push   %eax
  801a2a:	ff 36                	push   (%esi)
  801a2c:	e8 c0 fb ff ff       	call   8015f1 <dev_lookup>
  801a31:	83 c4 10             	add    $0x10,%esp
  801a34:	85 c0                	test   %eax,%eax
  801a36:	78 31                	js     801a69 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a3b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a3f:	74 2f                	je     801a70 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a41:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a44:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a4b:	00 00 00 
	stat->st_isdir = 0;
  801a4e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a55:	00 00 00 
	stat->st_dev = dev;
  801a58:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a5e:	83 ec 08             	sub    $0x8,%esp
  801a61:	53                   	push   %ebx
  801a62:	56                   	push   %esi
  801a63:	ff 50 14             	call   *0x14(%eax)
  801a66:	83 c4 10             	add    $0x10,%esp
}
  801a69:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6c:	5b                   	pop    %ebx
  801a6d:	5e                   	pop    %esi
  801a6e:	5d                   	pop    %ebp
  801a6f:	c3                   	ret    
		return -E_NOT_SUPP;
  801a70:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a75:	eb f2                	jmp    801a69 <fstat+0x67>

00801a77 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a77:	55                   	push   %ebp
  801a78:	89 e5                	mov    %esp,%ebp
  801a7a:	56                   	push   %esi
  801a7b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a7c:	83 ec 08             	sub    $0x8,%esp
  801a7f:	6a 00                	push   $0x0
  801a81:	ff 75 08             	push   0x8(%ebp)
  801a84:	e8 e4 01 00 00       	call   801c6d <open>
  801a89:	89 c3                	mov    %eax,%ebx
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	78 1b                	js     801aad <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a92:	83 ec 08             	sub    $0x8,%esp
  801a95:	ff 75 0c             	push   0xc(%ebp)
  801a98:	50                   	push   %eax
  801a99:	e8 64 ff ff ff       	call   801a02 <fstat>
  801a9e:	89 c6                	mov    %eax,%esi
	close(fd);
  801aa0:	89 1c 24             	mov    %ebx,(%esp)
  801aa3:	e8 26 fc ff ff       	call   8016ce <close>
	return r;
  801aa8:	83 c4 10             	add    $0x10,%esp
  801aab:	89 f3                	mov    %esi,%ebx
}
  801aad:	89 d8                	mov    %ebx,%eax
  801aaf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab2:	5b                   	pop    %ebx
  801ab3:	5e                   	pop    %esi
  801ab4:	5d                   	pop    %ebp
  801ab5:	c3                   	ret    

00801ab6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	56                   	push   %esi
  801aba:	53                   	push   %ebx
  801abb:	89 c6                	mov    %eax,%esi
  801abd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801abf:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  801ac6:	74 27                	je     801aef <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ac8:	6a 07                	push   $0x7
  801aca:	68 00 60 80 00       	push   $0x806000
  801acf:	56                   	push   %esi
  801ad0:	ff 35 00 70 80 00    	push   0x807000
  801ad6:	e8 50 0e 00 00       	call   80292b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801adb:	83 c4 0c             	add    $0xc,%esp
  801ade:	6a 00                	push   $0x0
  801ae0:	53                   	push   %ebx
  801ae1:	6a 00                	push   $0x0
  801ae3:	e8 dc 0d 00 00       	call   8028c4 <ipc_recv>
}
  801ae8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aeb:	5b                   	pop    %ebx
  801aec:	5e                   	pop    %esi
  801aed:	5d                   	pop    %ebp
  801aee:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801aef:	83 ec 0c             	sub    $0xc,%esp
  801af2:	6a 01                	push   $0x1
  801af4:	e8 86 0e 00 00       	call   80297f <ipc_find_env>
  801af9:	a3 00 70 80 00       	mov    %eax,0x807000
  801afe:	83 c4 10             	add    $0x10,%esp
  801b01:	eb c5                	jmp    801ac8 <fsipc+0x12>

00801b03 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b03:	55                   	push   %ebp
  801b04:	89 e5                	mov    %esp,%ebp
  801b06:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b09:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b0f:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801b14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b17:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b1c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b21:	b8 02 00 00 00       	mov    $0x2,%eax
  801b26:	e8 8b ff ff ff       	call   801ab6 <fsipc>
}
  801b2b:	c9                   	leave  
  801b2c:	c3                   	ret    

00801b2d <devfile_flush>:
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b33:	8b 45 08             	mov    0x8(%ebp),%eax
  801b36:	8b 40 0c             	mov    0xc(%eax),%eax
  801b39:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b3e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b43:	b8 06 00 00 00       	mov    $0x6,%eax
  801b48:	e8 69 ff ff ff       	call   801ab6 <fsipc>
}
  801b4d:	c9                   	leave  
  801b4e:	c3                   	ret    

00801b4f <devfile_stat>:
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	53                   	push   %ebx
  801b53:	83 ec 04             	sub    $0x4,%esp
  801b56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b59:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b5f:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b64:	ba 00 00 00 00       	mov    $0x0,%edx
  801b69:	b8 05 00 00 00       	mov    $0x5,%eax
  801b6e:	e8 43 ff ff ff       	call   801ab6 <fsipc>
  801b73:	85 c0                	test   %eax,%eax
  801b75:	78 2c                	js     801ba3 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b77:	83 ec 08             	sub    $0x8,%esp
  801b7a:	68 00 60 80 00       	push   $0x806000
  801b7f:	53                   	push   %ebx
  801b80:	e8 57 f3 ff ff       	call   800edc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b85:	a1 80 60 80 00       	mov    0x806080,%eax
  801b8a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b90:	a1 84 60 80 00       	mov    0x806084,%eax
  801b95:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ba3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba6:	c9                   	leave  
  801ba7:	c3                   	ret    

00801ba8 <devfile_write>:
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	83 ec 0c             	sub    $0xc,%esp
  801bae:	8b 45 10             	mov    0x10(%ebp),%eax
  801bb1:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801bb6:	39 d0                	cmp    %edx,%eax
  801bb8:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801bbb:	8b 55 08             	mov    0x8(%ebp),%edx
  801bbe:	8b 52 0c             	mov    0xc(%edx),%edx
  801bc1:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801bc7:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801bcc:	50                   	push   %eax
  801bcd:	ff 75 0c             	push   0xc(%ebp)
  801bd0:	68 08 60 80 00       	push   $0x806008
  801bd5:	e8 98 f4 ff ff       	call   801072 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801bda:	ba 00 00 00 00       	mov    $0x0,%edx
  801bdf:	b8 04 00 00 00       	mov    $0x4,%eax
  801be4:	e8 cd fe ff ff       	call   801ab6 <fsipc>
}
  801be9:	c9                   	leave  
  801bea:	c3                   	ret    

00801beb <devfile_read>:
{
  801beb:	55                   	push   %ebp
  801bec:	89 e5                	mov    %esp,%ebp
  801bee:	56                   	push   %esi
  801bef:	53                   	push   %ebx
  801bf0:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bf3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf6:	8b 40 0c             	mov    0xc(%eax),%eax
  801bf9:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801bfe:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c04:	ba 00 00 00 00       	mov    $0x0,%edx
  801c09:	b8 03 00 00 00       	mov    $0x3,%eax
  801c0e:	e8 a3 fe ff ff       	call   801ab6 <fsipc>
  801c13:	89 c3                	mov    %eax,%ebx
  801c15:	85 c0                	test   %eax,%eax
  801c17:	78 1f                	js     801c38 <devfile_read+0x4d>
	assert(r <= n);
  801c19:	39 f0                	cmp    %esi,%eax
  801c1b:	77 24                	ja     801c41 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801c1d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c22:	7f 33                	jg     801c57 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c24:	83 ec 04             	sub    $0x4,%esp
  801c27:	50                   	push   %eax
  801c28:	68 00 60 80 00       	push   $0x806000
  801c2d:	ff 75 0c             	push   0xc(%ebp)
  801c30:	e8 3d f4 ff ff       	call   801072 <memmove>
	return r;
  801c35:	83 c4 10             	add    $0x10,%esp
}
  801c38:	89 d8                	mov    %ebx,%eax
  801c3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c3d:	5b                   	pop    %ebx
  801c3e:	5e                   	pop    %esi
  801c3f:	5d                   	pop    %ebp
  801c40:	c3                   	ret    
	assert(r <= n);
  801c41:	68 1c 32 80 00       	push   $0x80321c
  801c46:	68 23 32 80 00       	push   $0x803223
  801c4b:	6a 7c                	push   $0x7c
  801c4d:	68 38 32 80 00       	push   $0x803238
  801c52:	e8 d0 eb ff ff       	call   800827 <_panic>
	assert(r <= PGSIZE);
  801c57:	68 43 32 80 00       	push   $0x803243
  801c5c:	68 23 32 80 00       	push   $0x803223
  801c61:	6a 7d                	push   $0x7d
  801c63:	68 38 32 80 00       	push   $0x803238
  801c68:	e8 ba eb ff ff       	call   800827 <_panic>

00801c6d <open>:
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	56                   	push   %esi
  801c71:	53                   	push   %ebx
  801c72:	83 ec 1c             	sub    $0x1c,%esp
  801c75:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801c78:	56                   	push   %esi
  801c79:	e8 23 f2 ff ff       	call   800ea1 <strlen>
  801c7e:	83 c4 10             	add    $0x10,%esp
  801c81:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c86:	7f 6c                	jg     801cf4 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801c88:	83 ec 0c             	sub    $0xc,%esp
  801c8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8e:	50                   	push   %eax
  801c8f:	e8 bd f8 ff ff       	call   801551 <fd_alloc>
  801c94:	89 c3                	mov    %eax,%ebx
  801c96:	83 c4 10             	add    $0x10,%esp
  801c99:	85 c0                	test   %eax,%eax
  801c9b:	78 3c                	js     801cd9 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801c9d:	83 ec 08             	sub    $0x8,%esp
  801ca0:	56                   	push   %esi
  801ca1:	68 00 60 80 00       	push   $0x806000
  801ca6:	e8 31 f2 ff ff       	call   800edc <strcpy>
	fsipcbuf.open.req_omode = mode;
  801cab:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cae:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801cb3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cbb:	e8 f6 fd ff ff       	call   801ab6 <fsipc>
  801cc0:	89 c3                	mov    %eax,%ebx
  801cc2:	83 c4 10             	add    $0x10,%esp
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	78 19                	js     801ce2 <open+0x75>
	return fd2num(fd);
  801cc9:	83 ec 0c             	sub    $0xc,%esp
  801ccc:	ff 75 f4             	push   -0xc(%ebp)
  801ccf:	e8 56 f8 ff ff       	call   80152a <fd2num>
  801cd4:	89 c3                	mov    %eax,%ebx
  801cd6:	83 c4 10             	add    $0x10,%esp
}
  801cd9:	89 d8                	mov    %ebx,%eax
  801cdb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cde:	5b                   	pop    %ebx
  801cdf:	5e                   	pop    %esi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    
		fd_close(fd, 0);
  801ce2:	83 ec 08             	sub    $0x8,%esp
  801ce5:	6a 00                	push   $0x0
  801ce7:	ff 75 f4             	push   -0xc(%ebp)
  801cea:	e8 58 f9 ff ff       	call   801647 <fd_close>
		return r;
  801cef:	83 c4 10             	add    $0x10,%esp
  801cf2:	eb e5                	jmp    801cd9 <open+0x6c>
		return -E_BAD_PATH;
  801cf4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801cf9:	eb de                	jmp    801cd9 <open+0x6c>

00801cfb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d01:	ba 00 00 00 00       	mov    $0x0,%edx
  801d06:	b8 08 00 00 00       	mov    $0x8,%eax
  801d0b:	e8 a6 fd ff ff       	call   801ab6 <fsipc>
}
  801d10:	c9                   	leave  
  801d11:	c3                   	ret    

00801d12 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801d18:	68 4f 32 80 00       	push   $0x80324f
  801d1d:	ff 75 0c             	push   0xc(%ebp)
  801d20:	e8 b7 f1 ff ff       	call   800edc <strcpy>
	return 0;
}
  801d25:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2a:	c9                   	leave  
  801d2b:	c3                   	ret    

00801d2c <devsock_close>:
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	53                   	push   %ebx
  801d30:	83 ec 10             	sub    $0x10,%esp
  801d33:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d36:	53                   	push   %ebx
  801d37:	e8 7c 0c 00 00       	call   8029b8 <pageref>
  801d3c:	89 c2                	mov    %eax,%edx
  801d3e:	83 c4 10             	add    $0x10,%esp
		return 0;
  801d41:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801d46:	83 fa 01             	cmp    $0x1,%edx
  801d49:	74 05                	je     801d50 <devsock_close+0x24>
}
  801d4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d4e:	c9                   	leave  
  801d4f:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801d50:	83 ec 0c             	sub    $0xc,%esp
  801d53:	ff 73 0c             	push   0xc(%ebx)
  801d56:	e8 b7 02 00 00       	call   802012 <nsipc_close>
  801d5b:	83 c4 10             	add    $0x10,%esp
  801d5e:	eb eb                	jmp    801d4b <devsock_close+0x1f>

00801d60 <devsock_write>:
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d66:	6a 00                	push   $0x0
  801d68:	ff 75 10             	push   0x10(%ebp)
  801d6b:	ff 75 0c             	push   0xc(%ebp)
  801d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d71:	ff 70 0c             	push   0xc(%eax)
  801d74:	e8 79 03 00 00       	call   8020f2 <nsipc_send>
}
  801d79:	c9                   	leave  
  801d7a:	c3                   	ret    

00801d7b <devsock_read>:
{
  801d7b:	55                   	push   %ebp
  801d7c:	89 e5                	mov    %esp,%ebp
  801d7e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d81:	6a 00                	push   $0x0
  801d83:	ff 75 10             	push   0x10(%ebp)
  801d86:	ff 75 0c             	push   0xc(%ebp)
  801d89:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8c:	ff 70 0c             	push   0xc(%eax)
  801d8f:	e8 ef 02 00 00       	call   802083 <nsipc_recv>
}
  801d94:	c9                   	leave  
  801d95:	c3                   	ret    

00801d96 <fd2sockid>:
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d9c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d9f:	52                   	push   %edx
  801da0:	50                   	push   %eax
  801da1:	e8 fb f7 ff ff       	call   8015a1 <fd_lookup>
  801da6:	83 c4 10             	add    $0x10,%esp
  801da9:	85 c0                	test   %eax,%eax
  801dab:	78 10                	js     801dbd <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db0:	8b 0d 40 40 80 00    	mov    0x804040,%ecx
  801db6:	39 08                	cmp    %ecx,(%eax)
  801db8:	75 05                	jne    801dbf <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801dba:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801dbd:	c9                   	leave  
  801dbe:	c3                   	ret    
		return -E_NOT_SUPP;
  801dbf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801dc4:	eb f7                	jmp    801dbd <fd2sockid+0x27>

00801dc6 <alloc_sockfd>:
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	56                   	push   %esi
  801dca:	53                   	push   %ebx
  801dcb:	83 ec 1c             	sub    $0x1c,%esp
  801dce:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801dd0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd3:	50                   	push   %eax
  801dd4:	e8 78 f7 ff ff       	call   801551 <fd_alloc>
  801dd9:	89 c3                	mov    %eax,%ebx
  801ddb:	83 c4 10             	add    $0x10,%esp
  801dde:	85 c0                	test   %eax,%eax
  801de0:	78 43                	js     801e25 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801de2:	83 ec 04             	sub    $0x4,%esp
  801de5:	68 07 04 00 00       	push   $0x407
  801dea:	ff 75 f4             	push   -0xc(%ebp)
  801ded:	6a 00                	push   $0x0
  801def:	e8 e4 f4 ff ff       	call   8012d8 <sys_page_alloc>
  801df4:	89 c3                	mov    %eax,%ebx
  801df6:	83 c4 10             	add    $0x10,%esp
  801df9:	85 c0                	test   %eax,%eax
  801dfb:	78 28                	js     801e25 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e00:	8b 15 40 40 80 00    	mov    0x804040,%edx
  801e06:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801e12:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801e15:	83 ec 0c             	sub    $0xc,%esp
  801e18:	50                   	push   %eax
  801e19:	e8 0c f7 ff ff       	call   80152a <fd2num>
  801e1e:	89 c3                	mov    %eax,%ebx
  801e20:	83 c4 10             	add    $0x10,%esp
  801e23:	eb 0c                	jmp    801e31 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801e25:	83 ec 0c             	sub    $0xc,%esp
  801e28:	56                   	push   %esi
  801e29:	e8 e4 01 00 00       	call   802012 <nsipc_close>
		return r;
  801e2e:	83 c4 10             	add    $0x10,%esp
}
  801e31:	89 d8                	mov    %ebx,%eax
  801e33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e36:	5b                   	pop    %ebx
  801e37:	5e                   	pop    %esi
  801e38:	5d                   	pop    %ebp
  801e39:	c3                   	ret    

00801e3a <accept>:
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e40:	8b 45 08             	mov    0x8(%ebp),%eax
  801e43:	e8 4e ff ff ff       	call   801d96 <fd2sockid>
  801e48:	85 c0                	test   %eax,%eax
  801e4a:	78 1b                	js     801e67 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e4c:	83 ec 04             	sub    $0x4,%esp
  801e4f:	ff 75 10             	push   0x10(%ebp)
  801e52:	ff 75 0c             	push   0xc(%ebp)
  801e55:	50                   	push   %eax
  801e56:	e8 0e 01 00 00       	call   801f69 <nsipc_accept>
  801e5b:	83 c4 10             	add    $0x10,%esp
  801e5e:	85 c0                	test   %eax,%eax
  801e60:	78 05                	js     801e67 <accept+0x2d>
	return alloc_sockfd(r);
  801e62:	e8 5f ff ff ff       	call   801dc6 <alloc_sockfd>
}
  801e67:	c9                   	leave  
  801e68:	c3                   	ret    

00801e69 <bind>:
{
  801e69:	55                   	push   %ebp
  801e6a:	89 e5                	mov    %esp,%ebp
  801e6c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e72:	e8 1f ff ff ff       	call   801d96 <fd2sockid>
  801e77:	85 c0                	test   %eax,%eax
  801e79:	78 12                	js     801e8d <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801e7b:	83 ec 04             	sub    $0x4,%esp
  801e7e:	ff 75 10             	push   0x10(%ebp)
  801e81:	ff 75 0c             	push   0xc(%ebp)
  801e84:	50                   	push   %eax
  801e85:	e8 31 01 00 00       	call   801fbb <nsipc_bind>
  801e8a:	83 c4 10             	add    $0x10,%esp
}
  801e8d:	c9                   	leave  
  801e8e:	c3                   	ret    

00801e8f <shutdown>:
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
  801e92:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e95:	8b 45 08             	mov    0x8(%ebp),%eax
  801e98:	e8 f9 fe ff ff       	call   801d96 <fd2sockid>
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	78 0f                	js     801eb0 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801ea1:	83 ec 08             	sub    $0x8,%esp
  801ea4:	ff 75 0c             	push   0xc(%ebp)
  801ea7:	50                   	push   %eax
  801ea8:	e8 43 01 00 00       	call   801ff0 <nsipc_shutdown>
  801ead:	83 c4 10             	add    $0x10,%esp
}
  801eb0:	c9                   	leave  
  801eb1:	c3                   	ret    

00801eb2 <connect>:
{
  801eb2:	55                   	push   %ebp
  801eb3:	89 e5                	mov    %esp,%ebp
  801eb5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801eb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebb:	e8 d6 fe ff ff       	call   801d96 <fd2sockid>
  801ec0:	85 c0                	test   %eax,%eax
  801ec2:	78 12                	js     801ed6 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801ec4:	83 ec 04             	sub    $0x4,%esp
  801ec7:	ff 75 10             	push   0x10(%ebp)
  801eca:	ff 75 0c             	push   0xc(%ebp)
  801ecd:	50                   	push   %eax
  801ece:	e8 59 01 00 00       	call   80202c <nsipc_connect>
  801ed3:	83 c4 10             	add    $0x10,%esp
}
  801ed6:	c9                   	leave  
  801ed7:	c3                   	ret    

00801ed8 <listen>:
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ede:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee1:	e8 b0 fe ff ff       	call   801d96 <fd2sockid>
  801ee6:	85 c0                	test   %eax,%eax
  801ee8:	78 0f                	js     801ef9 <listen+0x21>
	return nsipc_listen(r, backlog);
  801eea:	83 ec 08             	sub    $0x8,%esp
  801eed:	ff 75 0c             	push   0xc(%ebp)
  801ef0:	50                   	push   %eax
  801ef1:	e8 6b 01 00 00       	call   802061 <nsipc_listen>
  801ef6:	83 c4 10             	add    $0x10,%esp
}
  801ef9:	c9                   	leave  
  801efa:	c3                   	ret    

00801efb <socket>:

int
socket(int domain, int type, int protocol)
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f01:	ff 75 10             	push   0x10(%ebp)
  801f04:	ff 75 0c             	push   0xc(%ebp)
  801f07:	ff 75 08             	push   0x8(%ebp)
  801f0a:	e8 41 02 00 00       	call   802150 <nsipc_socket>
  801f0f:	83 c4 10             	add    $0x10,%esp
  801f12:	85 c0                	test   %eax,%eax
  801f14:	78 05                	js     801f1b <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801f16:	e8 ab fe ff ff       	call   801dc6 <alloc_sockfd>
}
  801f1b:	c9                   	leave  
  801f1c:	c3                   	ret    

00801f1d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f1d:	55                   	push   %ebp
  801f1e:	89 e5                	mov    %esp,%ebp
  801f20:	53                   	push   %ebx
  801f21:	83 ec 04             	sub    $0x4,%esp
  801f24:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801f26:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  801f2d:	74 26                	je     801f55 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f2f:	6a 07                	push   $0x7
  801f31:	68 00 80 80 00       	push   $0x808000
  801f36:	53                   	push   %ebx
  801f37:	ff 35 00 90 80 00    	push   0x809000
  801f3d:	e8 e9 09 00 00       	call   80292b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f42:	83 c4 0c             	add    $0xc,%esp
  801f45:	6a 00                	push   $0x0
  801f47:	6a 00                	push   $0x0
  801f49:	6a 00                	push   $0x0
  801f4b:	e8 74 09 00 00       	call   8028c4 <ipc_recv>
}
  801f50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f53:	c9                   	leave  
  801f54:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f55:	83 ec 0c             	sub    $0xc,%esp
  801f58:	6a 02                	push   $0x2
  801f5a:	e8 20 0a 00 00       	call   80297f <ipc_find_env>
  801f5f:	a3 00 90 80 00       	mov    %eax,0x809000
  801f64:	83 c4 10             	add    $0x10,%esp
  801f67:	eb c6                	jmp    801f2f <nsipc+0x12>

00801f69 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f69:	55                   	push   %ebp
  801f6a:	89 e5                	mov    %esp,%ebp
  801f6c:	56                   	push   %esi
  801f6d:	53                   	push   %ebx
  801f6e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f71:	8b 45 08             	mov    0x8(%ebp),%eax
  801f74:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f79:	8b 06                	mov    (%esi),%eax
  801f7b:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f80:	b8 01 00 00 00       	mov    $0x1,%eax
  801f85:	e8 93 ff ff ff       	call   801f1d <nsipc>
  801f8a:	89 c3                	mov    %eax,%ebx
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	79 09                	jns    801f99 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801f90:	89 d8                	mov    %ebx,%eax
  801f92:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f95:	5b                   	pop    %ebx
  801f96:	5e                   	pop    %esi
  801f97:	5d                   	pop    %ebp
  801f98:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f99:	83 ec 04             	sub    $0x4,%esp
  801f9c:	ff 35 10 80 80 00    	push   0x808010
  801fa2:	68 00 80 80 00       	push   $0x808000
  801fa7:	ff 75 0c             	push   0xc(%ebp)
  801faa:	e8 c3 f0 ff ff       	call   801072 <memmove>
		*addrlen = ret->ret_addrlen;
  801faf:	a1 10 80 80 00       	mov    0x808010,%eax
  801fb4:	89 06                	mov    %eax,(%esi)
  801fb6:	83 c4 10             	add    $0x10,%esp
	return r;
  801fb9:	eb d5                	jmp    801f90 <nsipc_accept+0x27>

00801fbb <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	53                   	push   %ebx
  801fbf:	83 ec 08             	sub    $0x8,%esp
  801fc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801fc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc8:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801fcd:	53                   	push   %ebx
  801fce:	ff 75 0c             	push   0xc(%ebp)
  801fd1:	68 04 80 80 00       	push   $0x808004
  801fd6:	e8 97 f0 ff ff       	call   801072 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801fdb:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  801fe1:	b8 02 00 00 00       	mov    $0x2,%eax
  801fe6:	e8 32 ff ff ff       	call   801f1d <nsipc>
}
  801feb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fee:	c9                   	leave  
  801fef:	c3                   	ret    

00801ff0 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ff6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff9:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  801ffe:	8b 45 0c             	mov    0xc(%ebp),%eax
  802001:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  802006:	b8 03 00 00 00       	mov    $0x3,%eax
  80200b:	e8 0d ff ff ff       	call   801f1d <nsipc>
}
  802010:	c9                   	leave  
  802011:	c3                   	ret    

00802012 <nsipc_close>:

int
nsipc_close(int s)
{
  802012:	55                   	push   %ebp
  802013:	89 e5                	mov    %esp,%ebp
  802015:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802018:	8b 45 08             	mov    0x8(%ebp),%eax
  80201b:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  802020:	b8 04 00 00 00       	mov    $0x4,%eax
  802025:	e8 f3 fe ff ff       	call   801f1d <nsipc>
}
  80202a:	c9                   	leave  
  80202b:	c3                   	ret    

0080202c <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80202c:	55                   	push   %ebp
  80202d:	89 e5                	mov    %esp,%ebp
  80202f:	53                   	push   %ebx
  802030:	83 ec 08             	sub    $0x8,%esp
  802033:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802036:	8b 45 08             	mov    0x8(%ebp),%eax
  802039:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80203e:	53                   	push   %ebx
  80203f:	ff 75 0c             	push   0xc(%ebp)
  802042:	68 04 80 80 00       	push   $0x808004
  802047:	e8 26 f0 ff ff       	call   801072 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80204c:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  802052:	b8 05 00 00 00       	mov    $0x5,%eax
  802057:	e8 c1 fe ff ff       	call   801f1d <nsipc>
}
  80205c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80205f:	c9                   	leave  
  802060:	c3                   	ret    

00802061 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802061:	55                   	push   %ebp
  802062:	89 e5                	mov    %esp,%ebp
  802064:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802067:	8b 45 08             	mov    0x8(%ebp),%eax
  80206a:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  80206f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802072:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  802077:	b8 06 00 00 00       	mov    $0x6,%eax
  80207c:	e8 9c fe ff ff       	call   801f1d <nsipc>
}
  802081:	c9                   	leave  
  802082:	c3                   	ret    

00802083 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802083:	55                   	push   %ebp
  802084:	89 e5                	mov    %esp,%ebp
  802086:	56                   	push   %esi
  802087:	53                   	push   %ebx
  802088:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80208b:	8b 45 08             	mov    0x8(%ebp),%eax
  80208e:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  802093:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  802099:	8b 45 14             	mov    0x14(%ebp),%eax
  80209c:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8020a1:	b8 07 00 00 00       	mov    $0x7,%eax
  8020a6:	e8 72 fe ff ff       	call   801f1d <nsipc>
  8020ab:	89 c3                	mov    %eax,%ebx
  8020ad:	85 c0                	test   %eax,%eax
  8020af:	78 22                	js     8020d3 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  8020b1:	b8 3f 06 00 00       	mov    $0x63f,%eax
  8020b6:	39 c6                	cmp    %eax,%esi
  8020b8:	0f 4e c6             	cmovle %esi,%eax
  8020bb:	39 c3                	cmp    %eax,%ebx
  8020bd:	7f 1d                	jg     8020dc <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8020bf:	83 ec 04             	sub    $0x4,%esp
  8020c2:	53                   	push   %ebx
  8020c3:	68 00 80 80 00       	push   $0x808000
  8020c8:	ff 75 0c             	push   0xc(%ebp)
  8020cb:	e8 a2 ef ff ff       	call   801072 <memmove>
  8020d0:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8020d3:	89 d8                	mov    %ebx,%eax
  8020d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020d8:	5b                   	pop    %ebx
  8020d9:	5e                   	pop    %esi
  8020da:	5d                   	pop    %ebp
  8020db:	c3                   	ret    
		assert(r < 1600 && r <= len);
  8020dc:	68 5b 32 80 00       	push   $0x80325b
  8020e1:	68 23 32 80 00       	push   $0x803223
  8020e6:	6a 62                	push   $0x62
  8020e8:	68 70 32 80 00       	push   $0x803270
  8020ed:	e8 35 e7 ff ff       	call   800827 <_panic>

008020f2 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8020f2:	55                   	push   %ebp
  8020f3:	89 e5                	mov    %esp,%ebp
  8020f5:	53                   	push   %ebx
  8020f6:	83 ec 04             	sub    $0x4,%esp
  8020f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8020fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ff:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  802104:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80210a:	7f 2e                	jg     80213a <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80210c:	83 ec 04             	sub    $0x4,%esp
  80210f:	53                   	push   %ebx
  802110:	ff 75 0c             	push   0xc(%ebp)
  802113:	68 0c 80 80 00       	push   $0x80800c
  802118:	e8 55 ef ff ff       	call   801072 <memmove>
	nsipcbuf.send.req_size = size;
  80211d:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  802123:	8b 45 14             	mov    0x14(%ebp),%eax
  802126:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  80212b:	b8 08 00 00 00       	mov    $0x8,%eax
  802130:	e8 e8 fd ff ff       	call   801f1d <nsipc>
}
  802135:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802138:	c9                   	leave  
  802139:	c3                   	ret    
	assert(size < 1600);
  80213a:	68 7c 32 80 00       	push   $0x80327c
  80213f:	68 23 32 80 00       	push   $0x803223
  802144:	6a 6d                	push   $0x6d
  802146:	68 70 32 80 00       	push   $0x803270
  80214b:	e8 d7 e6 ff ff       	call   800827 <_panic>

00802150 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802150:	55                   	push   %ebp
  802151:	89 e5                	mov    %esp,%ebp
  802153:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802156:	8b 45 08             	mov    0x8(%ebp),%eax
  802159:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  80215e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802161:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  802166:	8b 45 10             	mov    0x10(%ebp),%eax
  802169:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  80216e:	b8 09 00 00 00       	mov    $0x9,%eax
  802173:	e8 a5 fd ff ff       	call   801f1d <nsipc>
}
  802178:	c9                   	leave  
  802179:	c3                   	ret    

0080217a <free>:
	return v;
}

void
free(void *v)
{
  80217a:	55                   	push   %ebp
  80217b:	89 e5                	mov    %esp,%ebp
  80217d:	53                   	push   %ebx
  80217e:	83 ec 04             	sub    $0x4,%esp
  802181:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint8_t *c;
	uint32_t *ref;

	if (v == 0)
  802184:	85 db                	test   %ebx,%ebx
  802186:	0f 84 85 00 00 00    	je     802211 <free+0x97>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);
  80218c:	8d 83 00 00 00 f8    	lea    -0x8000000(%ebx),%eax
  802192:	3d ff ff ff 07       	cmp    $0x7ffffff,%eax
  802197:	77 51                	ja     8021ea <free+0x70>

	c = ROUNDDOWN(v, PGSIZE);
  802199:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  80219f:	89 d8                	mov    %ebx,%eax
  8021a1:	c1 e8 0c             	shr    $0xc,%eax
  8021a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8021ab:	f6 c4 02             	test   $0x2,%ah
  8021ae:	74 50                	je     802200 <free+0x86>
		sys_page_unmap(0, c);
  8021b0:	83 ec 08             	sub    $0x8,%esp
  8021b3:	53                   	push   %ebx
  8021b4:	6a 00                	push   $0x0
  8021b6:	e8 a2 f1 ff ff       	call   80135d <sys_page_unmap>
		c += PGSIZE;
  8021bb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(mbegin <= c && c < mend);
  8021c1:	8d 83 00 00 00 f8    	lea    -0x8000000(%ebx),%eax
  8021c7:	83 c4 10             	add    $0x10,%esp
  8021ca:	3d ff ff ff 07       	cmp    $0x7ffffff,%eax
  8021cf:	76 ce                	jbe    80219f <free+0x25>
  8021d1:	68 c3 32 80 00       	push   $0x8032c3
  8021d6:	68 23 32 80 00       	push   $0x803223
  8021db:	68 81 00 00 00       	push   $0x81
  8021e0:	68 b6 32 80 00       	push   $0x8032b6
  8021e5:	e8 3d e6 ff ff       	call   800827 <_panic>
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);
  8021ea:	68 88 32 80 00       	push   $0x803288
  8021ef:	68 23 32 80 00       	push   $0x803223
  8021f4:	6a 7a                	push   $0x7a
  8021f6:	68 b6 32 80 00       	push   $0x8032b6
  8021fb:	e8 27 e6 ff ff       	call   800827 <_panic>
	/*
	 * c is just a piece of this page, so dec the ref count
	 * and maybe free the page.
	 */
	ref = (uint32_t*) (c + PGSIZE - 4);
	if (--(*ref) == 0)
  802200:	8b 83 fc 0f 00 00    	mov    0xffc(%ebx),%eax
  802206:	83 e8 01             	sub    $0x1,%eax
  802209:	89 83 fc 0f 00 00    	mov    %eax,0xffc(%ebx)
  80220f:	74 05                	je     802216 <free+0x9c>
		sys_page_unmap(0, c);
}
  802211:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802214:	c9                   	leave  
  802215:	c3                   	ret    
		sys_page_unmap(0, c);
  802216:	83 ec 08             	sub    $0x8,%esp
  802219:	53                   	push   %ebx
  80221a:	6a 00                	push   $0x0
  80221c:	e8 3c f1 ff ff       	call   80135d <sys_page_unmap>
  802221:	83 c4 10             	add    $0x10,%esp
  802224:	eb eb                	jmp    802211 <free+0x97>

00802226 <malloc>:
{
  802226:	55                   	push   %ebp
  802227:	89 e5                	mov    %esp,%ebp
  802229:	57                   	push   %edi
  80222a:	56                   	push   %esi
  80222b:	53                   	push   %ebx
  80222c:	83 ec 1c             	sub    $0x1c,%esp
	if (mptr == 0)
  80222f:	a1 04 90 80 00       	mov    0x809004,%eax
  802234:	85 c0                	test   %eax,%eax
  802236:	74 72                	je     8022aa <malloc+0x84>
	n = ROUNDUP(n, 4);
  802238:	8b 75 08             	mov    0x8(%ebp),%esi
  80223b:	8d 56 03             	lea    0x3(%esi),%edx
  80223e:	83 e2 fc             	and    $0xfffffffc,%edx
  802241:	89 d7                	mov    %edx,%edi
  802243:	89 55 e0             	mov    %edx,-0x20(%ebp)
	if (n >= MAXMALLOC)
  802246:	81 fa ff ff 0f 00    	cmp    $0xfffff,%edx
  80224c:	0f 87 3f 01 00 00    	ja     802391 <malloc+0x16b>
	if ((uintptr_t) mptr % PGSIZE){
  802252:	a9 ff 0f 00 00       	test   $0xfff,%eax
  802257:	74 30                	je     802289 <malloc+0x63>
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
  802259:	89 c3                	mov    %eax,%ebx
  80225b:	c1 eb 0c             	shr    $0xc,%ebx
  80225e:	8d 54 10 03          	lea    0x3(%eax,%edx,1),%edx
  802262:	c1 ea 0c             	shr    $0xc,%edx
  802265:	39 d3                	cmp    %edx,%ebx
  802267:	74 64                	je     8022cd <malloc+0xa7>
		free(mptr);	/* drop reference to this page */
  802269:	83 ec 0c             	sub    $0xc,%esp
  80226c:	50                   	push   %eax
  80226d:	e8 08 ff ff ff       	call   80217a <free>
		mptr = ROUNDDOWN(mptr + PGSIZE, PGSIZE);
  802272:	a1 04 90 80 00       	mov    0x809004,%eax
  802277:	05 00 10 00 00       	add    $0x1000,%eax
  80227c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802281:	a3 04 90 80 00       	mov    %eax,0x809004
  802286:	83 c4 10             	add    $0x10,%esp
  802289:	8b 0d 04 90 80 00    	mov    0x809004,%ecx
{
  80228f:	c7 45 dc 02 00 00 00 	movl   $0x2,-0x24(%ebp)
  802296:	be 00 00 00 00       	mov    $0x0,%esi
  80229b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80229e:	8d 78 04             	lea    0x4(%eax),%edi
  8022a1:	89 cb                	mov    %ecx,%ebx
  8022a3:	01 f9                	add    %edi,%ecx
  8022a5:	e9 91 00 00 00       	jmp    80233b <malloc+0x115>
		mptr = mbegin;
  8022aa:	c7 05 04 90 80 00 00 	movl   $0x8000000,0x809004
  8022b1:	00 00 08 
	n = ROUNDUP(n, 4);
  8022b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8022b7:	8d 56 03             	lea    0x3(%esi),%edx
  8022ba:	83 e2 fc             	and    $0xfffffffc,%edx
  8022bd:	89 55 e0             	mov    %edx,-0x20(%ebp)
	if (n >= MAXMALLOC)
  8022c0:	81 fa ff ff 0f 00    	cmp    $0xfffff,%edx
  8022c6:	76 c1                	jbe    802289 <malloc+0x63>
  8022c8:	e9 31 01 00 00       	jmp    8023fe <malloc+0x1d8>
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
  8022cd:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  8022d3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
			(*ref)++;
  8022d9:	83 42 fc 01          	addl   $0x1,-0x4(%edx)
			mptr += n;
  8022dd:	89 fa                	mov    %edi,%edx
  8022df:	01 c2                	add    %eax,%edx
  8022e1:	89 15 04 90 80 00    	mov    %edx,0x809004
			return v;
  8022e7:	e9 12 01 00 00       	jmp    8023fe <malloc+0x1d8>
	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  8022ec:	05 00 10 00 00       	add    $0x1000,%eax
  8022f1:	39 c8                	cmp    %ecx,%eax
  8022f3:	0f 83 9f 00 00 00    	jae    802398 <malloc+0x172>
		if (va >= (uintptr_t) mend
  8022f9:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
  8022fe:	77 22                	ja     802322 <malloc+0xfc>
		    || ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)))
  802300:	89 c2                	mov    %eax,%edx
  802302:	c1 ea 16             	shr    $0x16,%edx
  802305:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80230c:	f6 c2 01             	test   $0x1,%dl
  80230f:	74 db                	je     8022ec <malloc+0xc6>
  802311:	89 c2                	mov    %eax,%edx
  802313:	c1 ea 0c             	shr    $0xc,%edx
  802316:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80231d:	f6 c2 01             	test   $0x1,%dl
  802320:	74 ca                	je     8022ec <malloc+0xc6>
		if (mptr == mend) {
  802322:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802328:	81 c1 00 10 00 00    	add    $0x1000,%ecx
  80232e:	be 01 00 00 00       	mov    $0x1,%esi
  802333:	81 fb 00 00 00 10    	cmp    $0x10000000,%ebx
  802339:	74 07                	je     802342 <malloc+0x11c>
  80233b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  80233e:	89 d8                	mov    %ebx,%eax
  802340:	eb af                	jmp    8022f1 <malloc+0xcb>
			mptr = mbegin;
  802342:	b9 00 00 00 08       	mov    $0x8000000,%ecx
			if (++nwrap == 2)
  802347:	83 6d dc 01          	subl   $0x1,-0x24(%ebp)
  80234b:	0f 85 50 ff ff ff    	jne    8022a1 <malloc+0x7b>
  802351:	c7 05 04 90 80 00 00 	movl   $0x8000000,0x809004
  802358:	00 00 08 
				return 0;	/* out of address space */
  80235b:	b8 00 00 00 00       	mov    $0x0,%eax
  802360:	e9 99 00 00 00       	jmp    8023fe <malloc+0x1d8>
  802365:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802368:	eb 1c                	jmp    802386 <malloc+0x160>
				sys_page_unmap(0, mptr + i);
  80236a:	83 ec 08             	sub    $0x8,%esp
  80236d:	89 f0                	mov    %esi,%eax
  80236f:	03 05 04 90 80 00    	add    0x809004,%eax
  802375:	50                   	push   %eax
  802376:	6a 00                	push   $0x0
  802378:	e8 e0 ef ff ff       	call   80135d <sys_page_unmap>
			for (; i >= 0; i -= PGSIZE)
  80237d:	81 ee 00 10 00 00    	sub    $0x1000,%esi
  802383:	83 c4 10             	add    $0x10,%esp
  802386:	85 f6                	test   %esi,%esi
  802388:	79 e0                	jns    80236a <malloc+0x144>
			return 0;	/* out of physical memory */
  80238a:	b8 00 00 00 00       	mov    $0x0,%eax
  80238f:	eb 6d                	jmp    8023fe <malloc+0x1d8>
		return 0;
  802391:	b8 00 00 00 00       	mov    $0x0,%eax
  802396:	eb 66                	jmp    8023fe <malloc+0x1d8>
  802398:	89 f0                	mov    %esi,%eax
  80239a:	84 c0                	test   %al,%al
  80239c:	74 08                	je     8023a6 <malloc+0x180>
  80239e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023a1:	a3 04 90 80 00       	mov    %eax,0x809004
	for (i = 0; i < n + 4; i += PGSIZE){
  8023a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8023ab:	89 de                	mov    %ebx,%esi
  8023ad:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  8023b0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
  8023b6:	83 ec 04             	sub    $0x4,%esp
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  8023b9:	39 fb                	cmp    %edi,%ebx
  8023bb:	0f 92 c0             	setb   %al
  8023be:	0f b6 c0             	movzbl %al,%eax
  8023c1:	c1 e0 09             	shl    $0x9,%eax
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
  8023c4:	83 c8 07             	or     $0x7,%eax
  8023c7:	50                   	push   %eax
  8023c8:	89 f0                	mov    %esi,%eax
  8023ca:	03 05 04 90 80 00    	add    0x809004,%eax
  8023d0:	50                   	push   %eax
  8023d1:	6a 00                	push   $0x0
  8023d3:	e8 00 ef ff ff       	call   8012d8 <sys_page_alloc>
  8023d8:	83 c4 10             	add    $0x10,%esp
  8023db:	85 c0                	test   %eax,%eax
  8023dd:	78 86                	js     802365 <malloc+0x13f>
	for (i = 0; i < n + 4; i += PGSIZE){
  8023df:	39 fb                	cmp    %edi,%ebx
  8023e1:	72 c8                	jb     8023ab <malloc+0x185>
	ref = (uint32_t*) (mptr + i - 4);
  8023e3:	a1 04 90 80 00       	mov    0x809004,%eax
	*ref = 2;	/* reference for mptr, reference for returned block */
  8023e8:	c7 84 30 fc 0f 00 00 	movl   $0x2,0xffc(%eax,%esi,1)
  8023ef:	02 00 00 00 
	mptr += n;
  8023f3:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8023f6:	01 c2                	add    %eax,%edx
  8023f8:	89 15 04 90 80 00    	mov    %edx,0x809004
}
  8023fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802401:	5b                   	pop    %ebx
  802402:	5e                   	pop    %esi
  802403:	5f                   	pop    %edi
  802404:	5d                   	pop    %ebp
  802405:	c3                   	ret    

00802406 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802406:	55                   	push   %ebp
  802407:	89 e5                	mov    %esp,%ebp
  802409:	56                   	push   %esi
  80240a:	53                   	push   %ebx
  80240b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80240e:	83 ec 0c             	sub    $0xc,%esp
  802411:	ff 75 08             	push   0x8(%ebp)
  802414:	e8 21 f1 ff ff       	call   80153a <fd2data>
  802419:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80241b:	83 c4 08             	add    $0x8,%esp
  80241e:	68 db 32 80 00       	push   $0x8032db
  802423:	53                   	push   %ebx
  802424:	e8 b3 ea ff ff       	call   800edc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802429:	8b 46 04             	mov    0x4(%esi),%eax
  80242c:	2b 06                	sub    (%esi),%eax
  80242e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802434:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80243b:	00 00 00 
	stat->st_dev = &devpipe;
  80243e:	c7 83 88 00 00 00 5c 	movl   $0x80405c,0x88(%ebx)
  802445:	40 80 00 
	return 0;
}
  802448:	b8 00 00 00 00       	mov    $0x0,%eax
  80244d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802450:	5b                   	pop    %ebx
  802451:	5e                   	pop    %esi
  802452:	5d                   	pop    %ebp
  802453:	c3                   	ret    

00802454 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802454:	55                   	push   %ebp
  802455:	89 e5                	mov    %esp,%ebp
  802457:	53                   	push   %ebx
  802458:	83 ec 0c             	sub    $0xc,%esp
  80245b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80245e:	53                   	push   %ebx
  80245f:	6a 00                	push   $0x0
  802461:	e8 f7 ee ff ff       	call   80135d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802466:	89 1c 24             	mov    %ebx,(%esp)
  802469:	e8 cc f0 ff ff       	call   80153a <fd2data>
  80246e:	83 c4 08             	add    $0x8,%esp
  802471:	50                   	push   %eax
  802472:	6a 00                	push   $0x0
  802474:	e8 e4 ee ff ff       	call   80135d <sys_page_unmap>
}
  802479:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80247c:	c9                   	leave  
  80247d:	c3                   	ret    

0080247e <_pipeisclosed>:
{
  80247e:	55                   	push   %ebp
  80247f:	89 e5                	mov    %esp,%ebp
  802481:	57                   	push   %edi
  802482:	56                   	push   %esi
  802483:	53                   	push   %ebx
  802484:	83 ec 1c             	sub    $0x1c,%esp
  802487:	89 c7                	mov    %eax,%edi
  802489:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80248b:	a1 10 50 80 00       	mov    0x805010,%eax
  802490:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802493:	83 ec 0c             	sub    $0xc,%esp
  802496:	57                   	push   %edi
  802497:	e8 1c 05 00 00       	call   8029b8 <pageref>
  80249c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80249f:	89 34 24             	mov    %esi,(%esp)
  8024a2:	e8 11 05 00 00       	call   8029b8 <pageref>
		nn = thisenv->env_runs;
  8024a7:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8024ad:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8024b0:	83 c4 10             	add    $0x10,%esp
  8024b3:	39 cb                	cmp    %ecx,%ebx
  8024b5:	74 1b                	je     8024d2 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8024b7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8024ba:	75 cf                	jne    80248b <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8024bc:	8b 42 58             	mov    0x58(%edx),%eax
  8024bf:	6a 01                	push   $0x1
  8024c1:	50                   	push   %eax
  8024c2:	53                   	push   %ebx
  8024c3:	68 e2 32 80 00       	push   $0x8032e2
  8024c8:	e8 35 e4 ff ff       	call   800902 <cprintf>
  8024cd:	83 c4 10             	add    $0x10,%esp
  8024d0:	eb b9                	jmp    80248b <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8024d2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8024d5:	0f 94 c0             	sete   %al
  8024d8:	0f b6 c0             	movzbl %al,%eax
}
  8024db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024de:	5b                   	pop    %ebx
  8024df:	5e                   	pop    %esi
  8024e0:	5f                   	pop    %edi
  8024e1:	5d                   	pop    %ebp
  8024e2:	c3                   	ret    

008024e3 <devpipe_write>:
{
  8024e3:	55                   	push   %ebp
  8024e4:	89 e5                	mov    %esp,%ebp
  8024e6:	57                   	push   %edi
  8024e7:	56                   	push   %esi
  8024e8:	53                   	push   %ebx
  8024e9:	83 ec 28             	sub    $0x28,%esp
  8024ec:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8024ef:	56                   	push   %esi
  8024f0:	e8 45 f0 ff ff       	call   80153a <fd2data>
  8024f5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8024f7:	83 c4 10             	add    $0x10,%esp
  8024fa:	bf 00 00 00 00       	mov    $0x0,%edi
  8024ff:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802502:	75 09                	jne    80250d <devpipe_write+0x2a>
	return i;
  802504:	89 f8                	mov    %edi,%eax
  802506:	eb 23                	jmp    80252b <devpipe_write+0x48>
			sys_yield();
  802508:	e8 ac ed ff ff       	call   8012b9 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80250d:	8b 43 04             	mov    0x4(%ebx),%eax
  802510:	8b 0b                	mov    (%ebx),%ecx
  802512:	8d 51 20             	lea    0x20(%ecx),%edx
  802515:	39 d0                	cmp    %edx,%eax
  802517:	72 1a                	jb     802533 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  802519:	89 da                	mov    %ebx,%edx
  80251b:	89 f0                	mov    %esi,%eax
  80251d:	e8 5c ff ff ff       	call   80247e <_pipeisclosed>
  802522:	85 c0                	test   %eax,%eax
  802524:	74 e2                	je     802508 <devpipe_write+0x25>
				return 0;
  802526:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80252b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80252e:	5b                   	pop    %ebx
  80252f:	5e                   	pop    %esi
  802530:	5f                   	pop    %edi
  802531:	5d                   	pop    %ebp
  802532:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802533:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802536:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80253a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80253d:	89 c2                	mov    %eax,%edx
  80253f:	c1 fa 1f             	sar    $0x1f,%edx
  802542:	89 d1                	mov    %edx,%ecx
  802544:	c1 e9 1b             	shr    $0x1b,%ecx
  802547:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80254a:	83 e2 1f             	and    $0x1f,%edx
  80254d:	29 ca                	sub    %ecx,%edx
  80254f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802553:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802557:	83 c0 01             	add    $0x1,%eax
  80255a:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80255d:	83 c7 01             	add    $0x1,%edi
  802560:	eb 9d                	jmp    8024ff <devpipe_write+0x1c>

00802562 <devpipe_read>:
{
  802562:	55                   	push   %ebp
  802563:	89 e5                	mov    %esp,%ebp
  802565:	57                   	push   %edi
  802566:	56                   	push   %esi
  802567:	53                   	push   %ebx
  802568:	83 ec 18             	sub    $0x18,%esp
  80256b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80256e:	57                   	push   %edi
  80256f:	e8 c6 ef ff ff       	call   80153a <fd2data>
  802574:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802576:	83 c4 10             	add    $0x10,%esp
  802579:	be 00 00 00 00       	mov    $0x0,%esi
  80257e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802581:	75 13                	jne    802596 <devpipe_read+0x34>
	return i;
  802583:	89 f0                	mov    %esi,%eax
  802585:	eb 02                	jmp    802589 <devpipe_read+0x27>
				return i;
  802587:	89 f0                	mov    %esi,%eax
}
  802589:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80258c:	5b                   	pop    %ebx
  80258d:	5e                   	pop    %esi
  80258e:	5f                   	pop    %edi
  80258f:	5d                   	pop    %ebp
  802590:	c3                   	ret    
			sys_yield();
  802591:	e8 23 ed ff ff       	call   8012b9 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802596:	8b 03                	mov    (%ebx),%eax
  802598:	3b 43 04             	cmp    0x4(%ebx),%eax
  80259b:	75 18                	jne    8025b5 <devpipe_read+0x53>
			if (i > 0)
  80259d:	85 f6                	test   %esi,%esi
  80259f:	75 e6                	jne    802587 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8025a1:	89 da                	mov    %ebx,%edx
  8025a3:	89 f8                	mov    %edi,%eax
  8025a5:	e8 d4 fe ff ff       	call   80247e <_pipeisclosed>
  8025aa:	85 c0                	test   %eax,%eax
  8025ac:	74 e3                	je     802591 <devpipe_read+0x2f>
				return 0;
  8025ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8025b3:	eb d4                	jmp    802589 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8025b5:	99                   	cltd   
  8025b6:	c1 ea 1b             	shr    $0x1b,%edx
  8025b9:	01 d0                	add    %edx,%eax
  8025bb:	83 e0 1f             	and    $0x1f,%eax
  8025be:	29 d0                	sub    %edx,%eax
  8025c0:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8025c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025c8:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8025cb:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8025ce:	83 c6 01             	add    $0x1,%esi
  8025d1:	eb ab                	jmp    80257e <devpipe_read+0x1c>

008025d3 <pipe>:
{
  8025d3:	55                   	push   %ebp
  8025d4:	89 e5                	mov    %esp,%ebp
  8025d6:	56                   	push   %esi
  8025d7:	53                   	push   %ebx
  8025d8:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8025db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025de:	50                   	push   %eax
  8025df:	e8 6d ef ff ff       	call   801551 <fd_alloc>
  8025e4:	89 c3                	mov    %eax,%ebx
  8025e6:	83 c4 10             	add    $0x10,%esp
  8025e9:	85 c0                	test   %eax,%eax
  8025eb:	0f 88 23 01 00 00    	js     802714 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025f1:	83 ec 04             	sub    $0x4,%esp
  8025f4:	68 07 04 00 00       	push   $0x407
  8025f9:	ff 75 f4             	push   -0xc(%ebp)
  8025fc:	6a 00                	push   $0x0
  8025fe:	e8 d5 ec ff ff       	call   8012d8 <sys_page_alloc>
  802603:	89 c3                	mov    %eax,%ebx
  802605:	83 c4 10             	add    $0x10,%esp
  802608:	85 c0                	test   %eax,%eax
  80260a:	0f 88 04 01 00 00    	js     802714 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802610:	83 ec 0c             	sub    $0xc,%esp
  802613:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802616:	50                   	push   %eax
  802617:	e8 35 ef ff ff       	call   801551 <fd_alloc>
  80261c:	89 c3                	mov    %eax,%ebx
  80261e:	83 c4 10             	add    $0x10,%esp
  802621:	85 c0                	test   %eax,%eax
  802623:	0f 88 db 00 00 00    	js     802704 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802629:	83 ec 04             	sub    $0x4,%esp
  80262c:	68 07 04 00 00       	push   $0x407
  802631:	ff 75 f0             	push   -0x10(%ebp)
  802634:	6a 00                	push   $0x0
  802636:	e8 9d ec ff ff       	call   8012d8 <sys_page_alloc>
  80263b:	89 c3                	mov    %eax,%ebx
  80263d:	83 c4 10             	add    $0x10,%esp
  802640:	85 c0                	test   %eax,%eax
  802642:	0f 88 bc 00 00 00    	js     802704 <pipe+0x131>
	va = fd2data(fd0);
  802648:	83 ec 0c             	sub    $0xc,%esp
  80264b:	ff 75 f4             	push   -0xc(%ebp)
  80264e:	e8 e7 ee ff ff       	call   80153a <fd2data>
  802653:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802655:	83 c4 0c             	add    $0xc,%esp
  802658:	68 07 04 00 00       	push   $0x407
  80265d:	50                   	push   %eax
  80265e:	6a 00                	push   $0x0
  802660:	e8 73 ec ff ff       	call   8012d8 <sys_page_alloc>
  802665:	89 c3                	mov    %eax,%ebx
  802667:	83 c4 10             	add    $0x10,%esp
  80266a:	85 c0                	test   %eax,%eax
  80266c:	0f 88 82 00 00 00    	js     8026f4 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802672:	83 ec 0c             	sub    $0xc,%esp
  802675:	ff 75 f0             	push   -0x10(%ebp)
  802678:	e8 bd ee ff ff       	call   80153a <fd2data>
  80267d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802684:	50                   	push   %eax
  802685:	6a 00                	push   $0x0
  802687:	56                   	push   %esi
  802688:	6a 00                	push   $0x0
  80268a:	e8 8c ec ff ff       	call   80131b <sys_page_map>
  80268f:	89 c3                	mov    %eax,%ebx
  802691:	83 c4 20             	add    $0x20,%esp
  802694:	85 c0                	test   %eax,%eax
  802696:	78 4e                	js     8026e6 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  802698:	a1 5c 40 80 00       	mov    0x80405c,%eax
  80269d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8026a0:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8026a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8026a5:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8026ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026af:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8026b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026b4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8026bb:	83 ec 0c             	sub    $0xc,%esp
  8026be:	ff 75 f4             	push   -0xc(%ebp)
  8026c1:	e8 64 ee ff ff       	call   80152a <fd2num>
  8026c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026c9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8026cb:	83 c4 04             	add    $0x4,%esp
  8026ce:	ff 75 f0             	push   -0x10(%ebp)
  8026d1:	e8 54 ee ff ff       	call   80152a <fd2num>
  8026d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026d9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8026dc:	83 c4 10             	add    $0x10,%esp
  8026df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026e4:	eb 2e                	jmp    802714 <pipe+0x141>
	sys_page_unmap(0, va);
  8026e6:	83 ec 08             	sub    $0x8,%esp
  8026e9:	56                   	push   %esi
  8026ea:	6a 00                	push   $0x0
  8026ec:	e8 6c ec ff ff       	call   80135d <sys_page_unmap>
  8026f1:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8026f4:	83 ec 08             	sub    $0x8,%esp
  8026f7:	ff 75 f0             	push   -0x10(%ebp)
  8026fa:	6a 00                	push   $0x0
  8026fc:	e8 5c ec ff ff       	call   80135d <sys_page_unmap>
  802701:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802704:	83 ec 08             	sub    $0x8,%esp
  802707:	ff 75 f4             	push   -0xc(%ebp)
  80270a:	6a 00                	push   $0x0
  80270c:	e8 4c ec ff ff       	call   80135d <sys_page_unmap>
  802711:	83 c4 10             	add    $0x10,%esp
}
  802714:	89 d8                	mov    %ebx,%eax
  802716:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802719:	5b                   	pop    %ebx
  80271a:	5e                   	pop    %esi
  80271b:	5d                   	pop    %ebp
  80271c:	c3                   	ret    

0080271d <pipeisclosed>:
{
  80271d:	55                   	push   %ebp
  80271e:	89 e5                	mov    %esp,%ebp
  802720:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802723:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802726:	50                   	push   %eax
  802727:	ff 75 08             	push   0x8(%ebp)
  80272a:	e8 72 ee ff ff       	call   8015a1 <fd_lookup>
  80272f:	83 c4 10             	add    $0x10,%esp
  802732:	85 c0                	test   %eax,%eax
  802734:	78 18                	js     80274e <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802736:	83 ec 0c             	sub    $0xc,%esp
  802739:	ff 75 f4             	push   -0xc(%ebp)
  80273c:	e8 f9 ed ff ff       	call   80153a <fd2data>
  802741:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802743:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802746:	e8 33 fd ff ff       	call   80247e <_pipeisclosed>
  80274b:	83 c4 10             	add    $0x10,%esp
}
  80274e:	c9                   	leave  
  80274f:	c3                   	ret    

00802750 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802750:	b8 00 00 00 00       	mov    $0x0,%eax
  802755:	c3                   	ret    

00802756 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802756:	55                   	push   %ebp
  802757:	89 e5                	mov    %esp,%ebp
  802759:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80275c:	68 fa 32 80 00       	push   $0x8032fa
  802761:	ff 75 0c             	push   0xc(%ebp)
  802764:	e8 73 e7 ff ff       	call   800edc <strcpy>
	return 0;
}
  802769:	b8 00 00 00 00       	mov    $0x0,%eax
  80276e:	c9                   	leave  
  80276f:	c3                   	ret    

00802770 <devcons_write>:
{
  802770:	55                   	push   %ebp
  802771:	89 e5                	mov    %esp,%ebp
  802773:	57                   	push   %edi
  802774:	56                   	push   %esi
  802775:	53                   	push   %ebx
  802776:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80277c:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802781:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802787:	eb 2e                	jmp    8027b7 <devcons_write+0x47>
		m = n - tot;
  802789:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80278c:	29 f3                	sub    %esi,%ebx
  80278e:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802793:	39 c3                	cmp    %eax,%ebx
  802795:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802798:	83 ec 04             	sub    $0x4,%esp
  80279b:	53                   	push   %ebx
  80279c:	89 f0                	mov    %esi,%eax
  80279e:	03 45 0c             	add    0xc(%ebp),%eax
  8027a1:	50                   	push   %eax
  8027a2:	57                   	push   %edi
  8027a3:	e8 ca e8 ff ff       	call   801072 <memmove>
		sys_cputs(buf, m);
  8027a8:	83 c4 08             	add    $0x8,%esp
  8027ab:	53                   	push   %ebx
  8027ac:	57                   	push   %edi
  8027ad:	e8 6a ea ff ff       	call   80121c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8027b2:	01 de                	add    %ebx,%esi
  8027b4:	83 c4 10             	add    $0x10,%esp
  8027b7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8027ba:	72 cd                	jb     802789 <devcons_write+0x19>
}
  8027bc:	89 f0                	mov    %esi,%eax
  8027be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027c1:	5b                   	pop    %ebx
  8027c2:	5e                   	pop    %esi
  8027c3:	5f                   	pop    %edi
  8027c4:	5d                   	pop    %ebp
  8027c5:	c3                   	ret    

008027c6 <devcons_read>:
{
  8027c6:	55                   	push   %ebp
  8027c7:	89 e5                	mov    %esp,%ebp
  8027c9:	83 ec 08             	sub    $0x8,%esp
  8027cc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8027d1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8027d5:	75 07                	jne    8027de <devcons_read+0x18>
  8027d7:	eb 1f                	jmp    8027f8 <devcons_read+0x32>
		sys_yield();
  8027d9:	e8 db ea ff ff       	call   8012b9 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8027de:	e8 57 ea ff ff       	call   80123a <sys_cgetc>
  8027e3:	85 c0                	test   %eax,%eax
  8027e5:	74 f2                	je     8027d9 <devcons_read+0x13>
	if (c < 0)
  8027e7:	78 0f                	js     8027f8 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8027e9:	83 f8 04             	cmp    $0x4,%eax
  8027ec:	74 0c                	je     8027fa <devcons_read+0x34>
	*(char*)vbuf = c;
  8027ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8027f1:	88 02                	mov    %al,(%edx)
	return 1;
  8027f3:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8027f8:	c9                   	leave  
  8027f9:	c3                   	ret    
		return 0;
  8027fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8027ff:	eb f7                	jmp    8027f8 <devcons_read+0x32>

00802801 <cputchar>:
{
  802801:	55                   	push   %ebp
  802802:	89 e5                	mov    %esp,%ebp
  802804:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802807:	8b 45 08             	mov    0x8(%ebp),%eax
  80280a:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80280d:	6a 01                	push   $0x1
  80280f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802812:	50                   	push   %eax
  802813:	e8 04 ea ff ff       	call   80121c <sys_cputs>
}
  802818:	83 c4 10             	add    $0x10,%esp
  80281b:	c9                   	leave  
  80281c:	c3                   	ret    

0080281d <getchar>:
{
  80281d:	55                   	push   %ebp
  80281e:	89 e5                	mov    %esp,%ebp
  802820:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802823:	6a 01                	push   $0x1
  802825:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802828:	50                   	push   %eax
  802829:	6a 00                	push   $0x0
  80282b:	e8 da ef ff ff       	call   80180a <read>
	if (r < 0)
  802830:	83 c4 10             	add    $0x10,%esp
  802833:	85 c0                	test   %eax,%eax
  802835:	78 06                	js     80283d <getchar+0x20>
	if (r < 1)
  802837:	74 06                	je     80283f <getchar+0x22>
	return c;
  802839:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80283d:	c9                   	leave  
  80283e:	c3                   	ret    
		return -E_EOF;
  80283f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802844:	eb f7                	jmp    80283d <getchar+0x20>

00802846 <iscons>:
{
  802846:	55                   	push   %ebp
  802847:	89 e5                	mov    %esp,%ebp
  802849:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80284c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80284f:	50                   	push   %eax
  802850:	ff 75 08             	push   0x8(%ebp)
  802853:	e8 49 ed ff ff       	call   8015a1 <fd_lookup>
  802858:	83 c4 10             	add    $0x10,%esp
  80285b:	85 c0                	test   %eax,%eax
  80285d:	78 11                	js     802870 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80285f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802862:	8b 15 78 40 80 00    	mov    0x804078,%edx
  802868:	39 10                	cmp    %edx,(%eax)
  80286a:	0f 94 c0             	sete   %al
  80286d:	0f b6 c0             	movzbl %al,%eax
}
  802870:	c9                   	leave  
  802871:	c3                   	ret    

00802872 <opencons>:
{
  802872:	55                   	push   %ebp
  802873:	89 e5                	mov    %esp,%ebp
  802875:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802878:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80287b:	50                   	push   %eax
  80287c:	e8 d0 ec ff ff       	call   801551 <fd_alloc>
  802881:	83 c4 10             	add    $0x10,%esp
  802884:	85 c0                	test   %eax,%eax
  802886:	78 3a                	js     8028c2 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802888:	83 ec 04             	sub    $0x4,%esp
  80288b:	68 07 04 00 00       	push   $0x407
  802890:	ff 75 f4             	push   -0xc(%ebp)
  802893:	6a 00                	push   $0x0
  802895:	e8 3e ea ff ff       	call   8012d8 <sys_page_alloc>
  80289a:	83 c4 10             	add    $0x10,%esp
  80289d:	85 c0                	test   %eax,%eax
  80289f:	78 21                	js     8028c2 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8028a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028a4:	8b 15 78 40 80 00    	mov    0x804078,%edx
  8028aa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8028ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028af:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8028b6:	83 ec 0c             	sub    $0xc,%esp
  8028b9:	50                   	push   %eax
  8028ba:	e8 6b ec ff ff       	call   80152a <fd2num>
  8028bf:	83 c4 10             	add    $0x10,%esp
}
  8028c2:	c9                   	leave  
  8028c3:	c3                   	ret    

008028c4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8028c4:	55                   	push   %ebp
  8028c5:	89 e5                	mov    %esp,%ebp
  8028c7:	56                   	push   %esi
  8028c8:	53                   	push   %ebx
  8028c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8028cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8028d2:	85 c0                	test   %eax,%eax
  8028d4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8028d9:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8028dc:	83 ec 0c             	sub    $0xc,%esp
  8028df:	50                   	push   %eax
  8028e0:	e8 a3 eb ff ff       	call   801488 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8028e5:	83 c4 10             	add    $0x10,%esp
  8028e8:	85 f6                	test   %esi,%esi
  8028ea:	74 14                	je     802900 <ipc_recv+0x3c>
  8028ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8028f1:	85 c0                	test   %eax,%eax
  8028f3:	78 09                	js     8028fe <ipc_recv+0x3a>
  8028f5:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8028fb:	8b 52 74             	mov    0x74(%edx),%edx
  8028fe:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802900:	85 db                	test   %ebx,%ebx
  802902:	74 14                	je     802918 <ipc_recv+0x54>
  802904:	ba 00 00 00 00       	mov    $0x0,%edx
  802909:	85 c0                	test   %eax,%eax
  80290b:	78 09                	js     802916 <ipc_recv+0x52>
  80290d:	8b 15 10 50 80 00    	mov    0x805010,%edx
  802913:	8b 52 78             	mov    0x78(%edx),%edx
  802916:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802918:	85 c0                	test   %eax,%eax
  80291a:	78 08                	js     802924 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  80291c:	a1 10 50 80 00       	mov    0x805010,%eax
  802921:	8b 40 70             	mov    0x70(%eax),%eax
}
  802924:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802927:	5b                   	pop    %ebx
  802928:	5e                   	pop    %esi
  802929:	5d                   	pop    %ebp
  80292a:	c3                   	ret    

0080292b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80292b:	55                   	push   %ebp
  80292c:	89 e5                	mov    %esp,%ebp
  80292e:	57                   	push   %edi
  80292f:	56                   	push   %esi
  802930:	53                   	push   %ebx
  802931:	83 ec 0c             	sub    $0xc,%esp
  802934:	8b 7d 08             	mov    0x8(%ebp),%edi
  802937:	8b 75 0c             	mov    0xc(%ebp),%esi
  80293a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  80293d:	85 db                	test   %ebx,%ebx
  80293f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802944:	0f 44 d8             	cmove  %eax,%ebx
  802947:	eb 05                	jmp    80294e <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802949:	e8 6b e9 ff ff       	call   8012b9 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80294e:	ff 75 14             	push   0x14(%ebp)
  802951:	53                   	push   %ebx
  802952:	56                   	push   %esi
  802953:	57                   	push   %edi
  802954:	e8 0c eb ff ff       	call   801465 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802959:	83 c4 10             	add    $0x10,%esp
  80295c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80295f:	74 e8                	je     802949 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802961:	85 c0                	test   %eax,%eax
  802963:	78 08                	js     80296d <ipc_send+0x42>
	}while (r<0);

}
  802965:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802968:	5b                   	pop    %ebx
  802969:	5e                   	pop    %esi
  80296a:	5f                   	pop    %edi
  80296b:	5d                   	pop    %ebp
  80296c:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80296d:	50                   	push   %eax
  80296e:	68 06 33 80 00       	push   $0x803306
  802973:	6a 3d                	push   $0x3d
  802975:	68 1a 33 80 00       	push   $0x80331a
  80297a:	e8 a8 de ff ff       	call   800827 <_panic>

0080297f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80297f:	55                   	push   %ebp
  802980:	89 e5                	mov    %esp,%ebp
  802982:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802985:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80298a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80298d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802993:	8b 52 50             	mov    0x50(%edx),%edx
  802996:	39 ca                	cmp    %ecx,%edx
  802998:	74 11                	je     8029ab <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  80299a:	83 c0 01             	add    $0x1,%eax
  80299d:	3d 00 04 00 00       	cmp    $0x400,%eax
  8029a2:	75 e6                	jne    80298a <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8029a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8029a9:	eb 0b                	jmp    8029b6 <ipc_find_env+0x37>
			return envs[i].env_id;
  8029ab:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8029ae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8029b3:	8b 40 48             	mov    0x48(%eax),%eax
}
  8029b6:	5d                   	pop    %ebp
  8029b7:	c3                   	ret    

008029b8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8029b8:	55                   	push   %ebp
  8029b9:	89 e5                	mov    %esp,%ebp
  8029bb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029be:	89 c2                	mov    %eax,%edx
  8029c0:	c1 ea 16             	shr    $0x16,%edx
  8029c3:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8029ca:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8029cf:	f6 c1 01             	test   $0x1,%cl
  8029d2:	74 1c                	je     8029f0 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8029d4:	c1 e8 0c             	shr    $0xc,%eax
  8029d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8029de:	a8 01                	test   $0x1,%al
  8029e0:	74 0e                	je     8029f0 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8029e2:	c1 e8 0c             	shr    $0xc,%eax
  8029e5:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8029ec:	ef 
  8029ed:	0f b7 d2             	movzwl %dx,%edx
}
  8029f0:	89 d0                	mov    %edx,%eax
  8029f2:	5d                   	pop    %ebp
  8029f3:	c3                   	ret    
  8029f4:	66 90                	xchg   %ax,%ax
  8029f6:	66 90                	xchg   %ax,%ax
  8029f8:	66 90                	xchg   %ax,%ax
  8029fa:	66 90                	xchg   %ax,%ax
  8029fc:	66 90                	xchg   %ax,%ax
  8029fe:	66 90                	xchg   %ax,%ax

00802a00 <__udivdi3>:
  802a00:	f3 0f 1e fb          	endbr32 
  802a04:	55                   	push   %ebp
  802a05:	57                   	push   %edi
  802a06:	56                   	push   %esi
  802a07:	53                   	push   %ebx
  802a08:	83 ec 1c             	sub    $0x1c,%esp
  802a0b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802a0f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802a13:	8b 74 24 34          	mov    0x34(%esp),%esi
  802a17:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802a1b:	85 c0                	test   %eax,%eax
  802a1d:	75 19                	jne    802a38 <__udivdi3+0x38>
  802a1f:	39 f3                	cmp    %esi,%ebx
  802a21:	76 4d                	jbe    802a70 <__udivdi3+0x70>
  802a23:	31 ff                	xor    %edi,%edi
  802a25:	89 e8                	mov    %ebp,%eax
  802a27:	89 f2                	mov    %esi,%edx
  802a29:	f7 f3                	div    %ebx
  802a2b:	89 fa                	mov    %edi,%edx
  802a2d:	83 c4 1c             	add    $0x1c,%esp
  802a30:	5b                   	pop    %ebx
  802a31:	5e                   	pop    %esi
  802a32:	5f                   	pop    %edi
  802a33:	5d                   	pop    %ebp
  802a34:	c3                   	ret    
  802a35:	8d 76 00             	lea    0x0(%esi),%esi
  802a38:	39 f0                	cmp    %esi,%eax
  802a3a:	76 14                	jbe    802a50 <__udivdi3+0x50>
  802a3c:	31 ff                	xor    %edi,%edi
  802a3e:	31 c0                	xor    %eax,%eax
  802a40:	89 fa                	mov    %edi,%edx
  802a42:	83 c4 1c             	add    $0x1c,%esp
  802a45:	5b                   	pop    %ebx
  802a46:	5e                   	pop    %esi
  802a47:	5f                   	pop    %edi
  802a48:	5d                   	pop    %ebp
  802a49:	c3                   	ret    
  802a4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802a50:	0f bd f8             	bsr    %eax,%edi
  802a53:	83 f7 1f             	xor    $0x1f,%edi
  802a56:	75 48                	jne    802aa0 <__udivdi3+0xa0>
  802a58:	39 f0                	cmp    %esi,%eax
  802a5a:	72 06                	jb     802a62 <__udivdi3+0x62>
  802a5c:	31 c0                	xor    %eax,%eax
  802a5e:	39 eb                	cmp    %ebp,%ebx
  802a60:	77 de                	ja     802a40 <__udivdi3+0x40>
  802a62:	b8 01 00 00 00       	mov    $0x1,%eax
  802a67:	eb d7                	jmp    802a40 <__udivdi3+0x40>
  802a69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a70:	89 d9                	mov    %ebx,%ecx
  802a72:	85 db                	test   %ebx,%ebx
  802a74:	75 0b                	jne    802a81 <__udivdi3+0x81>
  802a76:	b8 01 00 00 00       	mov    $0x1,%eax
  802a7b:	31 d2                	xor    %edx,%edx
  802a7d:	f7 f3                	div    %ebx
  802a7f:	89 c1                	mov    %eax,%ecx
  802a81:	31 d2                	xor    %edx,%edx
  802a83:	89 f0                	mov    %esi,%eax
  802a85:	f7 f1                	div    %ecx
  802a87:	89 c6                	mov    %eax,%esi
  802a89:	89 e8                	mov    %ebp,%eax
  802a8b:	89 f7                	mov    %esi,%edi
  802a8d:	f7 f1                	div    %ecx
  802a8f:	89 fa                	mov    %edi,%edx
  802a91:	83 c4 1c             	add    $0x1c,%esp
  802a94:	5b                   	pop    %ebx
  802a95:	5e                   	pop    %esi
  802a96:	5f                   	pop    %edi
  802a97:	5d                   	pop    %ebp
  802a98:	c3                   	ret    
  802a99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802aa0:	89 f9                	mov    %edi,%ecx
  802aa2:	ba 20 00 00 00       	mov    $0x20,%edx
  802aa7:	29 fa                	sub    %edi,%edx
  802aa9:	d3 e0                	shl    %cl,%eax
  802aab:	89 44 24 08          	mov    %eax,0x8(%esp)
  802aaf:	89 d1                	mov    %edx,%ecx
  802ab1:	89 d8                	mov    %ebx,%eax
  802ab3:	d3 e8                	shr    %cl,%eax
  802ab5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802ab9:	09 c1                	or     %eax,%ecx
  802abb:	89 f0                	mov    %esi,%eax
  802abd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802ac1:	89 f9                	mov    %edi,%ecx
  802ac3:	d3 e3                	shl    %cl,%ebx
  802ac5:	89 d1                	mov    %edx,%ecx
  802ac7:	d3 e8                	shr    %cl,%eax
  802ac9:	89 f9                	mov    %edi,%ecx
  802acb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802acf:	89 eb                	mov    %ebp,%ebx
  802ad1:	d3 e6                	shl    %cl,%esi
  802ad3:	89 d1                	mov    %edx,%ecx
  802ad5:	d3 eb                	shr    %cl,%ebx
  802ad7:	09 f3                	or     %esi,%ebx
  802ad9:	89 c6                	mov    %eax,%esi
  802adb:	89 f2                	mov    %esi,%edx
  802add:	89 d8                	mov    %ebx,%eax
  802adf:	f7 74 24 08          	divl   0x8(%esp)
  802ae3:	89 d6                	mov    %edx,%esi
  802ae5:	89 c3                	mov    %eax,%ebx
  802ae7:	f7 64 24 0c          	mull   0xc(%esp)
  802aeb:	39 d6                	cmp    %edx,%esi
  802aed:	72 19                	jb     802b08 <__udivdi3+0x108>
  802aef:	89 f9                	mov    %edi,%ecx
  802af1:	d3 e5                	shl    %cl,%ebp
  802af3:	39 c5                	cmp    %eax,%ebp
  802af5:	73 04                	jae    802afb <__udivdi3+0xfb>
  802af7:	39 d6                	cmp    %edx,%esi
  802af9:	74 0d                	je     802b08 <__udivdi3+0x108>
  802afb:	89 d8                	mov    %ebx,%eax
  802afd:	31 ff                	xor    %edi,%edi
  802aff:	e9 3c ff ff ff       	jmp    802a40 <__udivdi3+0x40>
  802b04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b08:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802b0b:	31 ff                	xor    %edi,%edi
  802b0d:	e9 2e ff ff ff       	jmp    802a40 <__udivdi3+0x40>
  802b12:	66 90                	xchg   %ax,%ax
  802b14:	66 90                	xchg   %ax,%ax
  802b16:	66 90                	xchg   %ax,%ax
  802b18:	66 90                	xchg   %ax,%ax
  802b1a:	66 90                	xchg   %ax,%ax
  802b1c:	66 90                	xchg   %ax,%ax
  802b1e:	66 90                	xchg   %ax,%ax

00802b20 <__umoddi3>:
  802b20:	f3 0f 1e fb          	endbr32 
  802b24:	55                   	push   %ebp
  802b25:	57                   	push   %edi
  802b26:	56                   	push   %esi
  802b27:	53                   	push   %ebx
  802b28:	83 ec 1c             	sub    $0x1c,%esp
  802b2b:	8b 74 24 30          	mov    0x30(%esp),%esi
  802b2f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802b33:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802b37:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  802b3b:	89 f0                	mov    %esi,%eax
  802b3d:	89 da                	mov    %ebx,%edx
  802b3f:	85 ff                	test   %edi,%edi
  802b41:	75 15                	jne    802b58 <__umoddi3+0x38>
  802b43:	39 dd                	cmp    %ebx,%ebp
  802b45:	76 39                	jbe    802b80 <__umoddi3+0x60>
  802b47:	f7 f5                	div    %ebp
  802b49:	89 d0                	mov    %edx,%eax
  802b4b:	31 d2                	xor    %edx,%edx
  802b4d:	83 c4 1c             	add    $0x1c,%esp
  802b50:	5b                   	pop    %ebx
  802b51:	5e                   	pop    %esi
  802b52:	5f                   	pop    %edi
  802b53:	5d                   	pop    %ebp
  802b54:	c3                   	ret    
  802b55:	8d 76 00             	lea    0x0(%esi),%esi
  802b58:	39 df                	cmp    %ebx,%edi
  802b5a:	77 f1                	ja     802b4d <__umoddi3+0x2d>
  802b5c:	0f bd cf             	bsr    %edi,%ecx
  802b5f:	83 f1 1f             	xor    $0x1f,%ecx
  802b62:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802b66:	75 40                	jne    802ba8 <__umoddi3+0x88>
  802b68:	39 df                	cmp    %ebx,%edi
  802b6a:	72 04                	jb     802b70 <__umoddi3+0x50>
  802b6c:	39 f5                	cmp    %esi,%ebp
  802b6e:	77 dd                	ja     802b4d <__umoddi3+0x2d>
  802b70:	89 da                	mov    %ebx,%edx
  802b72:	89 f0                	mov    %esi,%eax
  802b74:	29 e8                	sub    %ebp,%eax
  802b76:	19 fa                	sbb    %edi,%edx
  802b78:	eb d3                	jmp    802b4d <__umoddi3+0x2d>
  802b7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b80:	89 e9                	mov    %ebp,%ecx
  802b82:	85 ed                	test   %ebp,%ebp
  802b84:	75 0b                	jne    802b91 <__umoddi3+0x71>
  802b86:	b8 01 00 00 00       	mov    $0x1,%eax
  802b8b:	31 d2                	xor    %edx,%edx
  802b8d:	f7 f5                	div    %ebp
  802b8f:	89 c1                	mov    %eax,%ecx
  802b91:	89 d8                	mov    %ebx,%eax
  802b93:	31 d2                	xor    %edx,%edx
  802b95:	f7 f1                	div    %ecx
  802b97:	89 f0                	mov    %esi,%eax
  802b99:	f7 f1                	div    %ecx
  802b9b:	89 d0                	mov    %edx,%eax
  802b9d:	31 d2                	xor    %edx,%edx
  802b9f:	eb ac                	jmp    802b4d <__umoddi3+0x2d>
  802ba1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ba8:	8b 44 24 04          	mov    0x4(%esp),%eax
  802bac:	ba 20 00 00 00       	mov    $0x20,%edx
  802bb1:	29 c2                	sub    %eax,%edx
  802bb3:	89 c1                	mov    %eax,%ecx
  802bb5:	89 e8                	mov    %ebp,%eax
  802bb7:	d3 e7                	shl    %cl,%edi
  802bb9:	89 d1                	mov    %edx,%ecx
  802bbb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802bbf:	d3 e8                	shr    %cl,%eax
  802bc1:	89 c1                	mov    %eax,%ecx
  802bc3:	8b 44 24 04          	mov    0x4(%esp),%eax
  802bc7:	09 f9                	or     %edi,%ecx
  802bc9:	89 df                	mov    %ebx,%edi
  802bcb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802bcf:	89 c1                	mov    %eax,%ecx
  802bd1:	d3 e5                	shl    %cl,%ebp
  802bd3:	89 d1                	mov    %edx,%ecx
  802bd5:	d3 ef                	shr    %cl,%edi
  802bd7:	89 c1                	mov    %eax,%ecx
  802bd9:	89 f0                	mov    %esi,%eax
  802bdb:	d3 e3                	shl    %cl,%ebx
  802bdd:	89 d1                	mov    %edx,%ecx
  802bdf:	89 fa                	mov    %edi,%edx
  802be1:	d3 e8                	shr    %cl,%eax
  802be3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802be8:	09 d8                	or     %ebx,%eax
  802bea:	f7 74 24 08          	divl   0x8(%esp)
  802bee:	89 d3                	mov    %edx,%ebx
  802bf0:	d3 e6                	shl    %cl,%esi
  802bf2:	f7 e5                	mul    %ebp
  802bf4:	89 c7                	mov    %eax,%edi
  802bf6:	89 d1                	mov    %edx,%ecx
  802bf8:	39 d3                	cmp    %edx,%ebx
  802bfa:	72 06                	jb     802c02 <__umoddi3+0xe2>
  802bfc:	75 0e                	jne    802c0c <__umoddi3+0xec>
  802bfe:	39 c6                	cmp    %eax,%esi
  802c00:	73 0a                	jae    802c0c <__umoddi3+0xec>
  802c02:	29 e8                	sub    %ebp,%eax
  802c04:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802c08:	89 d1                	mov    %edx,%ecx
  802c0a:	89 c7                	mov    %eax,%edi
  802c0c:	89 f5                	mov    %esi,%ebp
  802c0e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802c12:	29 fd                	sub    %edi,%ebp
  802c14:	19 cb                	sbb    %ecx,%ebx
  802c16:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802c1b:	89 d8                	mov    %ebx,%eax
  802c1d:	d3 e0                	shl    %cl,%eax
  802c1f:	89 f1                	mov    %esi,%ecx
  802c21:	d3 ed                	shr    %cl,%ebp
  802c23:	d3 eb                	shr    %cl,%ebx
  802c25:	09 e8                	or     %ebp,%eax
  802c27:	89 da                	mov    %ebx,%edx
  802c29:	83 c4 1c             	add    $0x1c,%esp
  802c2c:	5b                   	pop    %ebx
  802c2d:	5e                   	pop    %esi
  802c2e:	5f                   	pop    %edi
  802c2f:	5d                   	pop    %ebp
  802c30:	c3                   	ret    
