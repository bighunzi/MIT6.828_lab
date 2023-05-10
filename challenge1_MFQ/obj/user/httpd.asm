
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
  80003a:	68 60 2c 80 00       	push   $0x802c60
  80003f:	e8 c1 08 00 00       	call   800905 <cprintf>
	exit();
  800044:	e8 c7 07 00 00       	call   800810 <exit>
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
  800080:	68 00 2d 80 00       	push   $0x802d00
  800085:	68 00 02 00 00       	push   $0x200
  80008a:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
  800090:	57                   	push   %edi
  800091:	e8 f4 0d 00 00       	call   800e8a <snprintf>
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
  80009f:	e8 37 18 00 00       	call   8018db <write>
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
  8000db:	e8 2d 17 00 00       	call   80180d <read>
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
  8000f2:	e8 38 0f 00 00       	call   80102f <memset>

		req->sock = sock;
  8000f7:	89 75 dc             	mov    %esi,-0x24(%ebp)
	if (strncmp(request, "GET ", 4) != 0)
  8000fa:	83 c4 0c             	add    $0xc,%esp
  8000fd:	6a 04                	push   $0x4
  8000ff:	68 80 2c 80 00       	push   $0x802c80
  800104:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  80010a:	50                   	push   %eax
  80010b:	e8 a6 0e 00 00       	call   800fb6 <strncmp>
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	85 c0                	test   %eax,%eax
  800115:	0f 85 bd 02 00 00    	jne    8003d8 <handle_client+0x318>
	request += 4;
  80011b:	8d 9d e0 fd ff ff    	lea    -0x220(%ebp),%ebx
  800121:	eb 1a                	jmp    80013d <handle_client+0x7d>
			panic("failed to read");
  800123:	83 ec 04             	sub    $0x4,%esp
  800126:	68 64 2c 80 00       	push   $0x802c64
  80012b:	68 1a 01 00 00       	push   $0x11a
  800130:	68 73 2c 80 00       	push   $0x802c73
  800135:	e8 f0 06 00 00       	call   80082a <_panic>
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
  800153:	e8 d1 20 00 00       	call   802229 <malloc>
  800158:	89 45 e0             	mov    %eax,-0x20(%ebp)
	memmove(req->url, url, url_len);
  80015b:	83 c4 0c             	add    $0xc,%esp
  80015e:	57                   	push   %edi
  80015f:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  800165:	51                   	push   %ecx
  800166:	50                   	push   %eax
  800167:	e8 09 0f 00 00       	call   801075 <memmove>
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
  800197:	e8 8d 20 00 00       	call   802229 <malloc>
  80019c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	memmove(req->version, version, version_len);
  80019f:	83 c4 0c             	add    $0xc,%esp
  8001a2:	57                   	push   %edi
  8001a3:	53                   	push   %ebx
  8001a4:	50                   	push   %eax
  8001a5:	e8 cb 0e 00 00       	call   801075 <memmove>
	req->version[version_len] = '\0';
  8001aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ad:	c6 04 38 00          	movb   $0x0,(%eax,%edi,1)
	if ( (r = open(req->url, O_RDONLY) )< 0 ) {
  8001b1:	83 c4 08             	add    $0x8,%esp
  8001b4:	6a 00                	push   $0x0
  8001b6:	ff 75 e0             	push   -0x20(%ebp)
  8001b9:	e8 b2 1a 00 00       	call   801c70 <open>
  8001be:	89 c7                	mov    %eax,%edi
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	78 4d                	js     800214 <handle_client+0x154>
	if ( (r = fstat(fd, &st)) < 0) return send_error(req, 404);
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	8d 85 50 fb ff ff    	lea    -0x4b0(%ebp),%eax
  8001d0:	50                   	push   %eax
  8001d1:	57                   	push   %edi
  8001d2:	e8 2e 18 00 00       	call   801a05 <fstat>
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
  800250:	e8 4f 0c 00 00       	call   800ea4 <strlen>
	if (write(req->sock, h->header, len) != len) {
  800255:	83 c4 0c             	add    $0xc,%esp
  800258:	89 85 44 fb ff ff    	mov    %eax,-0x4bc(%ebp)
  80025e:	50                   	push   %eax
  80025f:	ff 73 04             	push   0x4(%ebx)
  800262:	ff 75 dc             	push   -0x24(%ebp)
  800265:	e8 71 16 00 00       	call   8018db <write>
  80026a:	83 c4 10             	add    $0x10,%esp
  80026d:	39 85 44 fb ff ff    	cmp    %eax,-0x4bc(%ebp)
  800273:	0f 85 19 01 00 00    	jne    800392 <handle_client+0x2d2>
	r = snprintf(buf, 64, "Content-Length: %ld\r\n", (long)size);
  800279:	ff b5 40 fb ff ff    	push   -0x4c0(%ebp)
  80027f:	68 b4 2c 80 00       	push   $0x802cb4
  800284:	6a 40                	push   $0x40
  800286:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
  80028c:	50                   	push   %eax
  80028d:	e8 f8 0b 00 00       	call   800e8a <snprintf>
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
  8002ae:	e8 28 16 00 00       	call   8018db <write>
	if ((r = send_size(req, file_size)) < 0)
  8002b3:	83 c4 10             	add    $0x10,%esp
  8002b6:	39 c3                	cmp    %eax,%ebx
  8002b8:	0f 85 a2 00 00 00    	jne    800360 <handle_client+0x2a0>
	r = snprintf(buf, 128, "Content-Type: %s\r\n", type);
  8002be:	68 97 2c 80 00       	push   $0x802c97
  8002c3:	68 a1 2c 80 00       	push   $0x802ca1
  8002c8:	68 80 00 00 00       	push   $0x80
  8002cd:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
  8002d3:	50                   	push   %eax
  8002d4:	e8 b1 0b 00 00       	call   800e8a <snprintf>
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
  8002f5:	e8 e1 15 00 00       	call   8018db <write>
	if ((r = send_content_type(req)) < 0)
  8002fa:	83 c4 10             	add    $0x10,%esp
  8002fd:	39 c3                	cmp    %eax,%ebx
  8002ff:	75 5f                	jne    800360 <handle_client+0x2a0>
	int fin_len = strlen(fin);
  800301:	83 ec 0c             	sub    $0xc,%esp
  800304:	68 c7 2c 80 00       	push   $0x802cc7
  800309:	e8 96 0b 00 00       	call   800ea4 <strlen>
  80030e:	89 c3                	mov    %eax,%ebx
	if (write(req->sock, fin, fin_len) != fin_len)
  800310:	83 c4 0c             	add    $0xc,%esp
  800313:	50                   	push   %eax
  800314:	68 c7 2c 80 00       	push   $0x802cc7
  800319:	ff 75 dc             	push   -0x24(%ebp)
  80031c:	e8 ba 15 00 00       	call   8018db <write>
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
  800338:	e8 d0 14 00 00       	call   80180d <read>
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
  800354:	e8 82 15 00 00       	call   8018db <write>
  800359:	83 c4 10             	add    $0x10,%esp
  80035c:	39 c3                	cmp    %eax,%ebx
  80035e:	75 6c                	jne    8003cc <handle_client+0x30c>
	close(fd);
  800360:	83 ec 0c             	sub    $0xc,%esp
  800363:	57                   	push   %edi
  800364:	e8 68 13 00 00       	call   8016d1 <close>
	return r;
  800369:	83 c4 10             	add    $0x10,%esp
	free(req->url);
  80036c:	83 ec 0c             	sub    $0xc,%esp
  80036f:	ff 75 e0             	push   -0x20(%ebp)
  800372:	e8 06 1e 00 00       	call   80217d <free>
	free(req->version);
  800377:	83 c4 04             	add    $0x4,%esp
  80037a:	ff 75 e4             	push   -0x1c(%ebp)
  80037d:	e8 fb 1d 00 00       	call   80217d <free>

		// no keep alive
		break;
	}

	close(sock);
  800382:	89 34 24             	mov    %esi,(%esp)
  800385:	e8 47 13 00 00       	call   8016d1 <close>
}
  80038a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80038d:	5b                   	pop    %ebx
  80038e:	5e                   	pop    %esi
  80038f:	5f                   	pop    %edi
  800390:	5d                   	pop    %ebp
  800391:	c3                   	ret    
		die("Failed to send bytes to client");
  800392:	b8 7c 2d 80 00       	mov    $0x802d7c,%eax
  800397:	e8 97 fc ff ff       	call   800033 <die>
  80039c:	e9 d8 fe ff ff       	jmp    800279 <handle_client+0x1b9>
		panic("buffer too small!");
  8003a1:	83 ec 04             	sub    $0x4,%esp
  8003a4:	68 85 2c 80 00       	push   $0x802c85
  8003a9:	6a 66                	push   $0x66
  8003ab:	68 73 2c 80 00       	push   $0x802c73
  8003b0:	e8 75 04 00 00       	call   80082a <_panic>
		panic("buffer too small!");
  8003b5:	83 ec 04             	sub    $0x4,%esp
  8003b8:	68 85 2c 80 00       	push   $0x802c85
  8003bd:	68 82 00 00 00       	push   $0x82
  8003c2:	68 73 2c 80 00       	push   $0x802c73
  8003c7:	e8 5e 04 00 00       	call   80082a <_panic>
		die("Failed to send bytes to client");
  8003cc:	b8 7c 2d 80 00       	mov    $0x802d7c,%eax
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
  8003f0:	c7 05 20 40 80 00 ca 	movl   $0x802cca,0x804020
  8003f7:	2c 80 00 

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8003fa:	6a 06                	push   $0x6
  8003fc:	6a 01                	push   $0x1
  8003fe:	6a 02                	push   $0x2
  800400:	e8 f9 1a 00 00       	call   801efe <socket>
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
  800419:	e8 11 0c 00 00       	call   80102f <memset>
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
  800448:	e8 1f 1a 00 00       	call   801e6c <bind>
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
  80045a:	e8 7c 1a 00 00       	call   801edb <listen>
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	85 c0                	test   %eax,%eax
  800464:	78 2d                	js     800493 <umain+0xac>
		die("Failed to listen on server socket");

	cprintf("Waiting for http connections...\n");
  800466:	83 ec 0c             	sub    $0xc,%esp
  800469:	68 e4 2d 80 00       	push   $0x802de4
  80046e:	e8 92 04 00 00       	call   800905 <cprintf>
  800473:	83 c4 10             	add    $0x10,%esp

	while (1) {
		unsigned int clientlen = sizeof(client);
		// Wait for client connection
		if ((clientsock = accept(serversock,
  800476:	8d 7d c4             	lea    -0x3c(%ebp),%edi
  800479:	eb 35                	jmp    8004b0 <umain+0xc9>
		die("Failed to create socket");
  80047b:	b8 d1 2c 80 00       	mov    $0x802cd1,%eax
  800480:	e8 ae fb ff ff       	call   800033 <die>
  800485:	eb 87                	jmp    80040e <umain+0x27>
		die("Failed to bind the server socket");
  800487:	b8 9c 2d 80 00       	mov    $0x802d9c,%eax
  80048c:	e8 a2 fb ff ff       	call   800033 <die>
  800491:	eb c1                	jmp    800454 <umain+0x6d>
		die("Failed to listen on server socket");
  800493:	b8 c0 2d 80 00       	mov    $0x802dc0,%eax
  800498:	e8 96 fb ff ff       	call   800033 <die>
  80049d:	eb c7                	jmp    800466 <umain+0x7f>
					 (struct sockaddr *) &client,
					 &clientlen)) < 0)
		{
			die("Failed to accept client connection");
  80049f:	b8 08 2e 80 00       	mov    $0x802e08,%eax
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
  8004c0:	e8 78 19 00 00       	call   801e3d <accept>
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
  8007d2:	e8 c6 0a 00 00       	call   80129d <sys_getenvid>
  8007d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8007dc:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8007e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8007e7:	a3 10 50 80 00       	mov    %eax,0x805010

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8007ec:	85 db                	test   %ebx,%ebx
  8007ee:	7e 07                	jle    8007f7 <libmain+0x30>
		binaryname = argv[0];
  8007f0:	8b 06                	mov    (%esi),%eax
  8007f2:	a3 20 40 80 00       	mov    %eax,0x804020

	// call user main routine
	umain(argc, argv);
  8007f7:	83 ec 08             	sub    $0x8,%esp
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	e8 e6 fb ff ff       	call   8003e7 <umain>

	// exit gracefully
	exit();
  800801:	e8 0a 00 00 00       	call   800810 <exit>
}
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80080c:	5b                   	pop    %ebx
  80080d:	5e                   	pop    %esi
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800816:	e8 e3 0e 00 00       	call   8016fe <close_all>
	sys_env_destroy(0);
  80081b:	83 ec 0c             	sub    $0xc,%esp
  80081e:	6a 00                	push   $0x0
  800820:	e8 37 0a 00 00       	call   80125c <sys_env_destroy>
}
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	c9                   	leave  
  800829:	c3                   	ret    

0080082a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	56                   	push   %esi
  80082e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80082f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800832:	8b 35 20 40 80 00    	mov    0x804020,%esi
  800838:	e8 60 0a 00 00       	call   80129d <sys_getenvid>
  80083d:	83 ec 0c             	sub    $0xc,%esp
  800840:	ff 75 0c             	push   0xc(%ebp)
  800843:	ff 75 08             	push   0x8(%ebp)
  800846:	56                   	push   %esi
  800847:	50                   	push   %eax
  800848:	68 5c 2e 80 00       	push   $0x802e5c
  80084d:	e8 b3 00 00 00       	call   800905 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800852:	83 c4 18             	add    $0x18,%esp
  800855:	53                   	push   %ebx
  800856:	ff 75 10             	push   0x10(%ebp)
  800859:	e8 56 00 00 00       	call   8008b4 <vcprintf>
	cprintf("\n");
  80085e:	c7 04 24 c8 2c 80 00 	movl   $0x802cc8,(%esp)
  800865:	e8 9b 00 00 00       	call   800905 <cprintf>
  80086a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80086d:	cc                   	int3   
  80086e:	eb fd                	jmp    80086d <_panic+0x43>

00800870 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	53                   	push   %ebx
  800874:	83 ec 04             	sub    $0x4,%esp
  800877:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80087a:	8b 13                	mov    (%ebx),%edx
  80087c:	8d 42 01             	lea    0x1(%edx),%eax
  80087f:	89 03                	mov    %eax,(%ebx)
  800881:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800884:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800888:	3d ff 00 00 00       	cmp    $0xff,%eax
  80088d:	74 09                	je     800898 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80088f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800893:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800896:	c9                   	leave  
  800897:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	68 ff 00 00 00       	push   $0xff
  8008a0:	8d 43 08             	lea    0x8(%ebx),%eax
  8008a3:	50                   	push   %eax
  8008a4:	e8 76 09 00 00       	call   80121f <sys_cputs>
		b->idx = 0;
  8008a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8008af:	83 c4 10             	add    $0x10,%esp
  8008b2:	eb db                	jmp    80088f <putch+0x1f>

008008b4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8008bd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8008c4:	00 00 00 
	b.cnt = 0;
  8008c7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8008ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8008d1:	ff 75 0c             	push   0xc(%ebp)
  8008d4:	ff 75 08             	push   0x8(%ebp)
  8008d7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8008dd:	50                   	push   %eax
  8008de:	68 70 08 80 00       	push   $0x800870
  8008e3:	e8 14 01 00 00       	call   8009fc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8008e8:	83 c4 08             	add    $0x8,%esp
  8008eb:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8008f1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8008f7:	50                   	push   %eax
  8008f8:	e8 22 09 00 00       	call   80121f <sys_cputs>

	return b.cnt;
}
  8008fd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800903:	c9                   	leave  
  800904:	c3                   	ret    

00800905 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80090b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80090e:	50                   	push   %eax
  80090f:	ff 75 08             	push   0x8(%ebp)
  800912:	e8 9d ff ff ff       	call   8008b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800917:	c9                   	leave  
  800918:	c3                   	ret    

00800919 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	57                   	push   %edi
  80091d:	56                   	push   %esi
  80091e:	53                   	push   %ebx
  80091f:	83 ec 1c             	sub    $0x1c,%esp
  800922:	89 c7                	mov    %eax,%edi
  800924:	89 d6                	mov    %edx,%esi
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092c:	89 d1                	mov    %edx,%ecx
  80092e:	89 c2                	mov    %eax,%edx
  800930:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800933:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800936:	8b 45 10             	mov    0x10(%ebp),%eax
  800939:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80093c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80093f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800946:	39 c2                	cmp    %eax,%edx
  800948:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80094b:	72 3e                	jb     80098b <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80094d:	83 ec 0c             	sub    $0xc,%esp
  800950:	ff 75 18             	push   0x18(%ebp)
  800953:	83 eb 01             	sub    $0x1,%ebx
  800956:	53                   	push   %ebx
  800957:	50                   	push   %eax
  800958:	83 ec 08             	sub    $0x8,%esp
  80095b:	ff 75 e4             	push   -0x1c(%ebp)
  80095e:	ff 75 e0             	push   -0x20(%ebp)
  800961:	ff 75 dc             	push   -0x24(%ebp)
  800964:	ff 75 d8             	push   -0x28(%ebp)
  800967:	e8 a4 20 00 00       	call   802a10 <__udivdi3>
  80096c:	83 c4 18             	add    $0x18,%esp
  80096f:	52                   	push   %edx
  800970:	50                   	push   %eax
  800971:	89 f2                	mov    %esi,%edx
  800973:	89 f8                	mov    %edi,%eax
  800975:	e8 9f ff ff ff       	call   800919 <printnum>
  80097a:	83 c4 20             	add    $0x20,%esp
  80097d:	eb 13                	jmp    800992 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80097f:	83 ec 08             	sub    $0x8,%esp
  800982:	56                   	push   %esi
  800983:	ff 75 18             	push   0x18(%ebp)
  800986:	ff d7                	call   *%edi
  800988:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80098b:	83 eb 01             	sub    $0x1,%ebx
  80098e:	85 db                	test   %ebx,%ebx
  800990:	7f ed                	jg     80097f <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800992:	83 ec 08             	sub    $0x8,%esp
  800995:	56                   	push   %esi
  800996:	83 ec 04             	sub    $0x4,%esp
  800999:	ff 75 e4             	push   -0x1c(%ebp)
  80099c:	ff 75 e0             	push   -0x20(%ebp)
  80099f:	ff 75 dc             	push   -0x24(%ebp)
  8009a2:	ff 75 d8             	push   -0x28(%ebp)
  8009a5:	e8 86 21 00 00       	call   802b30 <__umoddi3>
  8009aa:	83 c4 14             	add    $0x14,%esp
  8009ad:	0f be 80 7f 2e 80 00 	movsbl 0x802e7f(%eax),%eax
  8009b4:	50                   	push   %eax
  8009b5:	ff d7                	call   *%edi
}
  8009b7:	83 c4 10             	add    $0x10,%esp
  8009ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009bd:	5b                   	pop    %ebx
  8009be:	5e                   	pop    %esi
  8009bf:	5f                   	pop    %edi
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8009c8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8009cc:	8b 10                	mov    (%eax),%edx
  8009ce:	3b 50 04             	cmp    0x4(%eax),%edx
  8009d1:	73 0a                	jae    8009dd <sprintputch+0x1b>
		*b->buf++ = ch;
  8009d3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009d6:	89 08                	mov    %ecx,(%eax)
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	88 02                	mov    %al,(%edx)
}
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <printfmt>:
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8009e5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8009e8:	50                   	push   %eax
  8009e9:	ff 75 10             	push   0x10(%ebp)
  8009ec:	ff 75 0c             	push   0xc(%ebp)
  8009ef:	ff 75 08             	push   0x8(%ebp)
  8009f2:	e8 05 00 00 00       	call   8009fc <vprintfmt>
}
  8009f7:	83 c4 10             	add    $0x10,%esp
  8009fa:	c9                   	leave  
  8009fb:	c3                   	ret    

008009fc <vprintfmt>:
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	57                   	push   %edi
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	83 ec 3c             	sub    $0x3c,%esp
  800a05:	8b 75 08             	mov    0x8(%ebp),%esi
  800a08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a0b:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a0e:	eb 0a                	jmp    800a1a <vprintfmt+0x1e>
			putch(ch, putdat);
  800a10:	83 ec 08             	sub    $0x8,%esp
  800a13:	53                   	push   %ebx
  800a14:	50                   	push   %eax
  800a15:	ff d6                	call   *%esi
  800a17:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a1a:	83 c7 01             	add    $0x1,%edi
  800a1d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a21:	83 f8 25             	cmp    $0x25,%eax
  800a24:	74 0c                	je     800a32 <vprintfmt+0x36>
			if (ch == '\0')
  800a26:	85 c0                	test   %eax,%eax
  800a28:	75 e6                	jne    800a10 <vprintfmt+0x14>
}
  800a2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a2d:	5b                   	pop    %ebx
  800a2e:	5e                   	pop    %esi
  800a2f:	5f                   	pop    %edi
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    
		padc = ' ';
  800a32:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800a36:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800a3d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800a44:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800a4b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800a50:	8d 47 01             	lea    0x1(%edi),%eax
  800a53:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a56:	0f b6 17             	movzbl (%edi),%edx
  800a59:	8d 42 dd             	lea    -0x23(%edx),%eax
  800a5c:	3c 55                	cmp    $0x55,%al
  800a5e:	0f 87 bb 03 00 00    	ja     800e1f <vprintfmt+0x423>
  800a64:	0f b6 c0             	movzbl %al,%eax
  800a67:	ff 24 85 c0 2f 80 00 	jmp    *0x802fc0(,%eax,4)
  800a6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800a71:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800a75:	eb d9                	jmp    800a50 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800a77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a7a:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800a7e:	eb d0                	jmp    800a50 <vprintfmt+0x54>
  800a80:	0f b6 d2             	movzbl %dl,%edx
  800a83:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800a86:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800a8e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800a91:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800a95:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800a98:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800a9b:	83 f9 09             	cmp    $0x9,%ecx
  800a9e:	77 55                	ja     800af5 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800aa0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800aa3:	eb e9                	jmp    800a8e <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800aa5:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa8:	8b 00                	mov    (%eax),%eax
  800aaa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aad:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab0:	8d 40 04             	lea    0x4(%eax),%eax
  800ab3:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800ab6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800ab9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800abd:	79 91                	jns    800a50 <vprintfmt+0x54>
				width = precision, precision = -1;
  800abf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ac2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ac5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800acc:	eb 82                	jmp    800a50 <vprintfmt+0x54>
  800ace:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800ad1:	85 d2                	test   %edx,%edx
  800ad3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad8:	0f 49 c2             	cmovns %edx,%eax
  800adb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800ade:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800ae1:	e9 6a ff ff ff       	jmp    800a50 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800ae6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800ae9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800af0:	e9 5b ff ff ff       	jmp    800a50 <vprintfmt+0x54>
  800af5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800af8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800afb:	eb bc                	jmp    800ab9 <vprintfmt+0xbd>
			lflag++;
  800afd:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800b00:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800b03:	e9 48 ff ff ff       	jmp    800a50 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800b08:	8b 45 14             	mov    0x14(%ebp),%eax
  800b0b:	8d 78 04             	lea    0x4(%eax),%edi
  800b0e:	83 ec 08             	sub    $0x8,%esp
  800b11:	53                   	push   %ebx
  800b12:	ff 30                	push   (%eax)
  800b14:	ff d6                	call   *%esi
			break;
  800b16:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800b19:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800b1c:	e9 9d 02 00 00       	jmp    800dbe <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800b21:	8b 45 14             	mov    0x14(%ebp),%eax
  800b24:	8d 78 04             	lea    0x4(%eax),%edi
  800b27:	8b 10                	mov    (%eax),%edx
  800b29:	89 d0                	mov    %edx,%eax
  800b2b:	f7 d8                	neg    %eax
  800b2d:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b30:	83 f8 0f             	cmp    $0xf,%eax
  800b33:	7f 23                	jg     800b58 <vprintfmt+0x15c>
  800b35:	8b 14 85 20 31 80 00 	mov    0x803120(,%eax,4),%edx
  800b3c:	85 d2                	test   %edx,%edx
  800b3e:	74 18                	je     800b58 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800b40:	52                   	push   %edx
  800b41:	68 55 32 80 00       	push   $0x803255
  800b46:	53                   	push   %ebx
  800b47:	56                   	push   %esi
  800b48:	e8 92 fe ff ff       	call   8009df <printfmt>
  800b4d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800b50:	89 7d 14             	mov    %edi,0x14(%ebp)
  800b53:	e9 66 02 00 00       	jmp    800dbe <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800b58:	50                   	push   %eax
  800b59:	68 97 2e 80 00       	push   $0x802e97
  800b5e:	53                   	push   %ebx
  800b5f:	56                   	push   %esi
  800b60:	e8 7a fe ff ff       	call   8009df <printfmt>
  800b65:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800b68:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800b6b:	e9 4e 02 00 00       	jmp    800dbe <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800b70:	8b 45 14             	mov    0x14(%ebp),%eax
  800b73:	83 c0 04             	add    $0x4,%eax
  800b76:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800b79:	8b 45 14             	mov    0x14(%ebp),%eax
  800b7c:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800b7e:	85 d2                	test   %edx,%edx
  800b80:	b8 90 2e 80 00       	mov    $0x802e90,%eax
  800b85:	0f 45 c2             	cmovne %edx,%eax
  800b88:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800b8b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b8f:	7e 06                	jle    800b97 <vprintfmt+0x19b>
  800b91:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800b95:	75 0d                	jne    800ba4 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b97:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800b9a:	89 c7                	mov    %eax,%edi
  800b9c:	03 45 e0             	add    -0x20(%ebp),%eax
  800b9f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ba2:	eb 55                	jmp    800bf9 <vprintfmt+0x1fd>
  800ba4:	83 ec 08             	sub    $0x8,%esp
  800ba7:	ff 75 d8             	push   -0x28(%ebp)
  800baa:	ff 75 cc             	push   -0x34(%ebp)
  800bad:	e8 0a 03 00 00       	call   800ebc <strnlen>
  800bb2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800bb5:	29 c1                	sub    %eax,%ecx
  800bb7:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800bba:	83 c4 10             	add    $0x10,%esp
  800bbd:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800bbf:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800bc3:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800bc6:	eb 0f                	jmp    800bd7 <vprintfmt+0x1db>
					putch(padc, putdat);
  800bc8:	83 ec 08             	sub    $0x8,%esp
  800bcb:	53                   	push   %ebx
  800bcc:	ff 75 e0             	push   -0x20(%ebp)
  800bcf:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800bd1:	83 ef 01             	sub    $0x1,%edi
  800bd4:	83 c4 10             	add    $0x10,%esp
  800bd7:	85 ff                	test   %edi,%edi
  800bd9:	7f ed                	jg     800bc8 <vprintfmt+0x1cc>
  800bdb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800bde:	85 d2                	test   %edx,%edx
  800be0:	b8 00 00 00 00       	mov    $0x0,%eax
  800be5:	0f 49 c2             	cmovns %edx,%eax
  800be8:	29 c2                	sub    %eax,%edx
  800bea:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800bed:	eb a8                	jmp    800b97 <vprintfmt+0x19b>
					putch(ch, putdat);
  800bef:	83 ec 08             	sub    $0x8,%esp
  800bf2:	53                   	push   %ebx
  800bf3:	52                   	push   %edx
  800bf4:	ff d6                	call   *%esi
  800bf6:	83 c4 10             	add    $0x10,%esp
  800bf9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800bfc:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bfe:	83 c7 01             	add    $0x1,%edi
  800c01:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c05:	0f be d0             	movsbl %al,%edx
  800c08:	85 d2                	test   %edx,%edx
  800c0a:	74 4b                	je     800c57 <vprintfmt+0x25b>
  800c0c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800c10:	78 06                	js     800c18 <vprintfmt+0x21c>
  800c12:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800c16:	78 1e                	js     800c36 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800c18:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800c1c:	74 d1                	je     800bef <vprintfmt+0x1f3>
  800c1e:	0f be c0             	movsbl %al,%eax
  800c21:	83 e8 20             	sub    $0x20,%eax
  800c24:	83 f8 5e             	cmp    $0x5e,%eax
  800c27:	76 c6                	jbe    800bef <vprintfmt+0x1f3>
					putch('?', putdat);
  800c29:	83 ec 08             	sub    $0x8,%esp
  800c2c:	53                   	push   %ebx
  800c2d:	6a 3f                	push   $0x3f
  800c2f:	ff d6                	call   *%esi
  800c31:	83 c4 10             	add    $0x10,%esp
  800c34:	eb c3                	jmp    800bf9 <vprintfmt+0x1fd>
  800c36:	89 cf                	mov    %ecx,%edi
  800c38:	eb 0e                	jmp    800c48 <vprintfmt+0x24c>
				putch(' ', putdat);
  800c3a:	83 ec 08             	sub    $0x8,%esp
  800c3d:	53                   	push   %ebx
  800c3e:	6a 20                	push   $0x20
  800c40:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800c42:	83 ef 01             	sub    $0x1,%edi
  800c45:	83 c4 10             	add    $0x10,%esp
  800c48:	85 ff                	test   %edi,%edi
  800c4a:	7f ee                	jg     800c3a <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800c4c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800c4f:	89 45 14             	mov    %eax,0x14(%ebp)
  800c52:	e9 67 01 00 00       	jmp    800dbe <vprintfmt+0x3c2>
  800c57:	89 cf                	mov    %ecx,%edi
  800c59:	eb ed                	jmp    800c48 <vprintfmt+0x24c>
	if (lflag >= 2)
  800c5b:	83 f9 01             	cmp    $0x1,%ecx
  800c5e:	7f 1b                	jg     800c7b <vprintfmt+0x27f>
	else if (lflag)
  800c60:	85 c9                	test   %ecx,%ecx
  800c62:	74 63                	je     800cc7 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800c64:	8b 45 14             	mov    0x14(%ebp),%eax
  800c67:	8b 00                	mov    (%eax),%eax
  800c69:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c6c:	99                   	cltd   
  800c6d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800c70:	8b 45 14             	mov    0x14(%ebp),%eax
  800c73:	8d 40 04             	lea    0x4(%eax),%eax
  800c76:	89 45 14             	mov    %eax,0x14(%ebp)
  800c79:	eb 17                	jmp    800c92 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800c7b:	8b 45 14             	mov    0x14(%ebp),%eax
  800c7e:	8b 50 04             	mov    0x4(%eax),%edx
  800c81:	8b 00                	mov    (%eax),%eax
  800c83:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c86:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800c89:	8b 45 14             	mov    0x14(%ebp),%eax
  800c8c:	8d 40 08             	lea    0x8(%eax),%eax
  800c8f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800c92:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800c95:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800c98:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800c9d:	85 c9                	test   %ecx,%ecx
  800c9f:	0f 89 ff 00 00 00    	jns    800da4 <vprintfmt+0x3a8>
				putch('-', putdat);
  800ca5:	83 ec 08             	sub    $0x8,%esp
  800ca8:	53                   	push   %ebx
  800ca9:	6a 2d                	push   $0x2d
  800cab:	ff d6                	call   *%esi
				num = -(long long) num;
  800cad:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800cb0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800cb3:	f7 da                	neg    %edx
  800cb5:	83 d1 00             	adc    $0x0,%ecx
  800cb8:	f7 d9                	neg    %ecx
  800cba:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800cbd:	bf 0a 00 00 00       	mov    $0xa,%edi
  800cc2:	e9 dd 00 00 00       	jmp    800da4 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800cc7:	8b 45 14             	mov    0x14(%ebp),%eax
  800cca:	8b 00                	mov    (%eax),%eax
  800ccc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ccf:	99                   	cltd   
  800cd0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800cd3:	8b 45 14             	mov    0x14(%ebp),%eax
  800cd6:	8d 40 04             	lea    0x4(%eax),%eax
  800cd9:	89 45 14             	mov    %eax,0x14(%ebp)
  800cdc:	eb b4                	jmp    800c92 <vprintfmt+0x296>
	if (lflag >= 2)
  800cde:	83 f9 01             	cmp    $0x1,%ecx
  800ce1:	7f 1e                	jg     800d01 <vprintfmt+0x305>
	else if (lflag)
  800ce3:	85 c9                	test   %ecx,%ecx
  800ce5:	74 32                	je     800d19 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800ce7:	8b 45 14             	mov    0x14(%ebp),%eax
  800cea:	8b 10                	mov    (%eax),%edx
  800cec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf1:	8d 40 04             	lea    0x4(%eax),%eax
  800cf4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800cf7:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800cfc:	e9 a3 00 00 00       	jmp    800da4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800d01:	8b 45 14             	mov    0x14(%ebp),%eax
  800d04:	8b 10                	mov    (%eax),%edx
  800d06:	8b 48 04             	mov    0x4(%eax),%ecx
  800d09:	8d 40 08             	lea    0x8(%eax),%eax
  800d0c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800d0f:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800d14:	e9 8b 00 00 00       	jmp    800da4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800d19:	8b 45 14             	mov    0x14(%ebp),%eax
  800d1c:	8b 10                	mov    (%eax),%edx
  800d1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d23:	8d 40 04             	lea    0x4(%eax),%eax
  800d26:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800d29:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800d2e:	eb 74                	jmp    800da4 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800d30:	83 f9 01             	cmp    $0x1,%ecx
  800d33:	7f 1b                	jg     800d50 <vprintfmt+0x354>
	else if (lflag)
  800d35:	85 c9                	test   %ecx,%ecx
  800d37:	74 2c                	je     800d65 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800d39:	8b 45 14             	mov    0x14(%ebp),%eax
  800d3c:	8b 10                	mov    (%eax),%edx
  800d3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d43:	8d 40 04             	lea    0x4(%eax),%eax
  800d46:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800d49:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800d4e:	eb 54                	jmp    800da4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800d50:	8b 45 14             	mov    0x14(%ebp),%eax
  800d53:	8b 10                	mov    (%eax),%edx
  800d55:	8b 48 04             	mov    0x4(%eax),%ecx
  800d58:	8d 40 08             	lea    0x8(%eax),%eax
  800d5b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800d5e:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800d63:	eb 3f                	jmp    800da4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800d65:	8b 45 14             	mov    0x14(%ebp),%eax
  800d68:	8b 10                	mov    (%eax),%edx
  800d6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6f:	8d 40 04             	lea    0x4(%eax),%eax
  800d72:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800d75:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800d7a:	eb 28                	jmp    800da4 <vprintfmt+0x3a8>
			putch('0', putdat);
  800d7c:	83 ec 08             	sub    $0x8,%esp
  800d7f:	53                   	push   %ebx
  800d80:	6a 30                	push   $0x30
  800d82:	ff d6                	call   *%esi
			putch('x', putdat);
  800d84:	83 c4 08             	add    $0x8,%esp
  800d87:	53                   	push   %ebx
  800d88:	6a 78                	push   $0x78
  800d8a:	ff d6                	call   *%esi
			num = (unsigned long long)
  800d8c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d8f:	8b 10                	mov    (%eax),%edx
  800d91:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800d96:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800d99:	8d 40 04             	lea    0x4(%eax),%eax
  800d9c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800d9f:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800da4:	83 ec 0c             	sub    $0xc,%esp
  800da7:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800dab:	50                   	push   %eax
  800dac:	ff 75 e0             	push   -0x20(%ebp)
  800daf:	57                   	push   %edi
  800db0:	51                   	push   %ecx
  800db1:	52                   	push   %edx
  800db2:	89 da                	mov    %ebx,%edx
  800db4:	89 f0                	mov    %esi,%eax
  800db6:	e8 5e fb ff ff       	call   800919 <printnum>
			break;
  800dbb:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800dbe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800dc1:	e9 54 fc ff ff       	jmp    800a1a <vprintfmt+0x1e>
	if (lflag >= 2)
  800dc6:	83 f9 01             	cmp    $0x1,%ecx
  800dc9:	7f 1b                	jg     800de6 <vprintfmt+0x3ea>
	else if (lflag)
  800dcb:	85 c9                	test   %ecx,%ecx
  800dcd:	74 2c                	je     800dfb <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800dcf:	8b 45 14             	mov    0x14(%ebp),%eax
  800dd2:	8b 10                	mov    (%eax),%edx
  800dd4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd9:	8d 40 04             	lea    0x4(%eax),%eax
  800ddc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ddf:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800de4:	eb be                	jmp    800da4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800de6:	8b 45 14             	mov    0x14(%ebp),%eax
  800de9:	8b 10                	mov    (%eax),%edx
  800deb:	8b 48 04             	mov    0x4(%eax),%ecx
  800dee:	8d 40 08             	lea    0x8(%eax),%eax
  800df1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800df4:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800df9:	eb a9                	jmp    800da4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800dfb:	8b 45 14             	mov    0x14(%ebp),%eax
  800dfe:	8b 10                	mov    (%eax),%edx
  800e00:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e05:	8d 40 04             	lea    0x4(%eax),%eax
  800e08:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800e0b:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800e10:	eb 92                	jmp    800da4 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800e12:	83 ec 08             	sub    $0x8,%esp
  800e15:	53                   	push   %ebx
  800e16:	6a 25                	push   $0x25
  800e18:	ff d6                	call   *%esi
			break;
  800e1a:	83 c4 10             	add    $0x10,%esp
  800e1d:	eb 9f                	jmp    800dbe <vprintfmt+0x3c2>
			putch('%', putdat);
  800e1f:	83 ec 08             	sub    $0x8,%esp
  800e22:	53                   	push   %ebx
  800e23:	6a 25                	push   $0x25
  800e25:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800e27:	83 c4 10             	add    $0x10,%esp
  800e2a:	89 f8                	mov    %edi,%eax
  800e2c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800e30:	74 05                	je     800e37 <vprintfmt+0x43b>
  800e32:	83 e8 01             	sub    $0x1,%eax
  800e35:	eb f5                	jmp    800e2c <vprintfmt+0x430>
  800e37:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e3a:	eb 82                	jmp    800dbe <vprintfmt+0x3c2>

00800e3c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	83 ec 18             	sub    $0x18,%esp
  800e42:	8b 45 08             	mov    0x8(%ebp),%eax
  800e45:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800e48:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e4b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800e4f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800e52:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	74 26                	je     800e83 <vsnprintf+0x47>
  800e5d:	85 d2                	test   %edx,%edx
  800e5f:	7e 22                	jle    800e83 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800e61:	ff 75 14             	push   0x14(%ebp)
  800e64:	ff 75 10             	push   0x10(%ebp)
  800e67:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e6a:	50                   	push   %eax
  800e6b:	68 c2 09 80 00       	push   $0x8009c2
  800e70:	e8 87 fb ff ff       	call   8009fc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800e75:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e78:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7e:	83 c4 10             	add    $0x10,%esp
}
  800e81:	c9                   	leave  
  800e82:	c3                   	ret    
		return -E_INVAL;
  800e83:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e88:	eb f7                	jmp    800e81 <vsnprintf+0x45>

00800e8a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800e90:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800e93:	50                   	push   %eax
  800e94:	ff 75 10             	push   0x10(%ebp)
  800e97:	ff 75 0c             	push   0xc(%ebp)
  800e9a:	ff 75 08             	push   0x8(%ebp)
  800e9d:	e8 9a ff ff ff       	call   800e3c <vsnprintf>
	va_end(ap);

	return rc;
}
  800ea2:	c9                   	leave  
  800ea3:	c3                   	ret    

00800ea4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800eaa:	b8 00 00 00 00       	mov    $0x0,%eax
  800eaf:	eb 03                	jmp    800eb4 <strlen+0x10>
		n++;
  800eb1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800eb4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800eb8:	75 f7                	jne    800eb1 <strlen+0xd>
	return n;
}
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eca:	eb 03                	jmp    800ecf <strnlen+0x13>
		n++;
  800ecc:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ecf:	39 d0                	cmp    %edx,%eax
  800ed1:	74 08                	je     800edb <strnlen+0x1f>
  800ed3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800ed7:	75 f3                	jne    800ecc <strnlen+0x10>
  800ed9:	89 c2                	mov    %eax,%edx
	return n;
}
  800edb:	89 d0                	mov    %edx,%eax
  800edd:	5d                   	pop    %ebp
  800ede:	c3                   	ret    

00800edf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	53                   	push   %ebx
  800ee3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ee9:	b8 00 00 00 00       	mov    $0x0,%eax
  800eee:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800ef2:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800ef5:	83 c0 01             	add    $0x1,%eax
  800ef8:	84 d2                	test   %dl,%dl
  800efa:	75 f2                	jne    800eee <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800efc:	89 c8                	mov    %ecx,%eax
  800efe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f01:	c9                   	leave  
  800f02:	c3                   	ret    

00800f03 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	53                   	push   %ebx
  800f07:	83 ec 10             	sub    $0x10,%esp
  800f0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800f0d:	53                   	push   %ebx
  800f0e:	e8 91 ff ff ff       	call   800ea4 <strlen>
  800f13:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800f16:	ff 75 0c             	push   0xc(%ebp)
  800f19:	01 d8                	add    %ebx,%eax
  800f1b:	50                   	push   %eax
  800f1c:	e8 be ff ff ff       	call   800edf <strcpy>
	return dst;
}
  800f21:	89 d8                	mov    %ebx,%eax
  800f23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f26:	c9                   	leave  
  800f27:	c3                   	ret    

00800f28 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	56                   	push   %esi
  800f2c:	53                   	push   %ebx
  800f2d:	8b 75 08             	mov    0x8(%ebp),%esi
  800f30:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f33:	89 f3                	mov    %esi,%ebx
  800f35:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f38:	89 f0                	mov    %esi,%eax
  800f3a:	eb 0f                	jmp    800f4b <strncpy+0x23>
		*dst++ = *src;
  800f3c:	83 c0 01             	add    $0x1,%eax
  800f3f:	0f b6 0a             	movzbl (%edx),%ecx
  800f42:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800f45:	80 f9 01             	cmp    $0x1,%cl
  800f48:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800f4b:	39 d8                	cmp    %ebx,%eax
  800f4d:	75 ed                	jne    800f3c <strncpy+0x14>
	}
	return ret;
}
  800f4f:	89 f0                	mov    %esi,%eax
  800f51:	5b                   	pop    %ebx
  800f52:	5e                   	pop    %esi
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    

00800f55 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	56                   	push   %esi
  800f59:	53                   	push   %ebx
  800f5a:	8b 75 08             	mov    0x8(%ebp),%esi
  800f5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f60:	8b 55 10             	mov    0x10(%ebp),%edx
  800f63:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f65:	85 d2                	test   %edx,%edx
  800f67:	74 21                	je     800f8a <strlcpy+0x35>
  800f69:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800f6d:	89 f2                	mov    %esi,%edx
  800f6f:	eb 09                	jmp    800f7a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800f71:	83 c1 01             	add    $0x1,%ecx
  800f74:	83 c2 01             	add    $0x1,%edx
  800f77:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800f7a:	39 c2                	cmp    %eax,%edx
  800f7c:	74 09                	je     800f87 <strlcpy+0x32>
  800f7e:	0f b6 19             	movzbl (%ecx),%ebx
  800f81:	84 db                	test   %bl,%bl
  800f83:	75 ec                	jne    800f71 <strlcpy+0x1c>
  800f85:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800f87:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800f8a:	29 f0                	sub    %esi,%eax
}
  800f8c:	5b                   	pop    %ebx
  800f8d:	5e                   	pop    %esi
  800f8e:	5d                   	pop    %ebp
  800f8f:	c3                   	ret    

00800f90 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f96:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800f99:	eb 06                	jmp    800fa1 <strcmp+0x11>
		p++, q++;
  800f9b:	83 c1 01             	add    $0x1,%ecx
  800f9e:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800fa1:	0f b6 01             	movzbl (%ecx),%eax
  800fa4:	84 c0                	test   %al,%al
  800fa6:	74 04                	je     800fac <strcmp+0x1c>
  800fa8:	3a 02                	cmp    (%edx),%al
  800faa:	74 ef                	je     800f9b <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800fac:	0f b6 c0             	movzbl %al,%eax
  800faf:	0f b6 12             	movzbl (%edx),%edx
  800fb2:	29 d0                	sub    %edx,%eax
}
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    

00800fb6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	53                   	push   %ebx
  800fba:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc0:	89 c3                	mov    %eax,%ebx
  800fc2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800fc5:	eb 06                	jmp    800fcd <strncmp+0x17>
		n--, p++, q++;
  800fc7:	83 c0 01             	add    $0x1,%eax
  800fca:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800fcd:	39 d8                	cmp    %ebx,%eax
  800fcf:	74 18                	je     800fe9 <strncmp+0x33>
  800fd1:	0f b6 08             	movzbl (%eax),%ecx
  800fd4:	84 c9                	test   %cl,%cl
  800fd6:	74 04                	je     800fdc <strncmp+0x26>
  800fd8:	3a 0a                	cmp    (%edx),%cl
  800fda:	74 eb                	je     800fc7 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800fdc:	0f b6 00             	movzbl (%eax),%eax
  800fdf:	0f b6 12             	movzbl (%edx),%edx
  800fe2:	29 d0                	sub    %edx,%eax
}
  800fe4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe7:	c9                   	leave  
  800fe8:	c3                   	ret    
		return 0;
  800fe9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fee:	eb f4                	jmp    800fe4 <strncmp+0x2e>

00800ff0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ffa:	eb 03                	jmp    800fff <strchr+0xf>
  800ffc:	83 c0 01             	add    $0x1,%eax
  800fff:	0f b6 10             	movzbl (%eax),%edx
  801002:	84 d2                	test   %dl,%dl
  801004:	74 06                	je     80100c <strchr+0x1c>
		if (*s == c)
  801006:	38 ca                	cmp    %cl,%dl
  801008:	75 f2                	jne    800ffc <strchr+0xc>
  80100a:	eb 05                	jmp    801011 <strchr+0x21>
			return (char *) s;
	return 0;
  80100c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801011:	5d                   	pop    %ebp
  801012:	c3                   	ret    

00801013 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	8b 45 08             	mov    0x8(%ebp),%eax
  801019:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80101d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801020:	38 ca                	cmp    %cl,%dl
  801022:	74 09                	je     80102d <strfind+0x1a>
  801024:	84 d2                	test   %dl,%dl
  801026:	74 05                	je     80102d <strfind+0x1a>
	for (; *s; s++)
  801028:	83 c0 01             	add    $0x1,%eax
  80102b:	eb f0                	jmp    80101d <strfind+0xa>
			break;
	return (char *) s;
}
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    

0080102f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	57                   	push   %edi
  801033:	56                   	push   %esi
  801034:	53                   	push   %ebx
  801035:	8b 7d 08             	mov    0x8(%ebp),%edi
  801038:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80103b:	85 c9                	test   %ecx,%ecx
  80103d:	74 2f                	je     80106e <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80103f:	89 f8                	mov    %edi,%eax
  801041:	09 c8                	or     %ecx,%eax
  801043:	a8 03                	test   $0x3,%al
  801045:	75 21                	jne    801068 <memset+0x39>
		c &= 0xFF;
  801047:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80104b:	89 d0                	mov    %edx,%eax
  80104d:	c1 e0 08             	shl    $0x8,%eax
  801050:	89 d3                	mov    %edx,%ebx
  801052:	c1 e3 18             	shl    $0x18,%ebx
  801055:	89 d6                	mov    %edx,%esi
  801057:	c1 e6 10             	shl    $0x10,%esi
  80105a:	09 f3                	or     %esi,%ebx
  80105c:	09 da                	or     %ebx,%edx
  80105e:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801060:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801063:	fc                   	cld    
  801064:	f3 ab                	rep stos %eax,%es:(%edi)
  801066:	eb 06                	jmp    80106e <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801068:	8b 45 0c             	mov    0xc(%ebp),%eax
  80106b:	fc                   	cld    
  80106c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80106e:	89 f8                	mov    %edi,%eax
  801070:	5b                   	pop    %ebx
  801071:	5e                   	pop    %esi
  801072:	5f                   	pop    %edi
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    

00801075 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	57                   	push   %edi
  801079:	56                   	push   %esi
  80107a:	8b 45 08             	mov    0x8(%ebp),%eax
  80107d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801080:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801083:	39 c6                	cmp    %eax,%esi
  801085:	73 32                	jae    8010b9 <memmove+0x44>
  801087:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80108a:	39 c2                	cmp    %eax,%edx
  80108c:	76 2b                	jbe    8010b9 <memmove+0x44>
		s += n;
		d += n;
  80108e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801091:	89 d6                	mov    %edx,%esi
  801093:	09 fe                	or     %edi,%esi
  801095:	09 ce                	or     %ecx,%esi
  801097:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80109d:	75 0e                	jne    8010ad <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80109f:	83 ef 04             	sub    $0x4,%edi
  8010a2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8010a5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8010a8:	fd                   	std    
  8010a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8010ab:	eb 09                	jmp    8010b6 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8010ad:	83 ef 01             	sub    $0x1,%edi
  8010b0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8010b3:	fd                   	std    
  8010b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8010b6:	fc                   	cld    
  8010b7:	eb 1a                	jmp    8010d3 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8010b9:	89 f2                	mov    %esi,%edx
  8010bb:	09 c2                	or     %eax,%edx
  8010bd:	09 ca                	or     %ecx,%edx
  8010bf:	f6 c2 03             	test   $0x3,%dl
  8010c2:	75 0a                	jne    8010ce <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8010c4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8010c7:	89 c7                	mov    %eax,%edi
  8010c9:	fc                   	cld    
  8010ca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8010cc:	eb 05                	jmp    8010d3 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8010ce:	89 c7                	mov    %eax,%edi
  8010d0:	fc                   	cld    
  8010d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8010d3:	5e                   	pop    %esi
  8010d4:	5f                   	pop    %edi
  8010d5:	5d                   	pop    %ebp
  8010d6:	c3                   	ret    

008010d7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8010dd:	ff 75 10             	push   0x10(%ebp)
  8010e0:	ff 75 0c             	push   0xc(%ebp)
  8010e3:	ff 75 08             	push   0x8(%ebp)
  8010e6:	e8 8a ff ff ff       	call   801075 <memmove>
}
  8010eb:	c9                   	leave  
  8010ec:	c3                   	ret    

008010ed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	56                   	push   %esi
  8010f1:	53                   	push   %ebx
  8010f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f8:	89 c6                	mov    %eax,%esi
  8010fa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010fd:	eb 06                	jmp    801105 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8010ff:	83 c0 01             	add    $0x1,%eax
  801102:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801105:	39 f0                	cmp    %esi,%eax
  801107:	74 14                	je     80111d <memcmp+0x30>
		if (*s1 != *s2)
  801109:	0f b6 08             	movzbl (%eax),%ecx
  80110c:	0f b6 1a             	movzbl (%edx),%ebx
  80110f:	38 d9                	cmp    %bl,%cl
  801111:	74 ec                	je     8010ff <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801113:	0f b6 c1             	movzbl %cl,%eax
  801116:	0f b6 db             	movzbl %bl,%ebx
  801119:	29 d8                	sub    %ebx,%eax
  80111b:	eb 05                	jmp    801122 <memcmp+0x35>
	}

	return 0;
  80111d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801122:	5b                   	pop    %ebx
  801123:	5e                   	pop    %esi
  801124:	5d                   	pop    %ebp
  801125:	c3                   	ret    

00801126 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	8b 45 08             	mov    0x8(%ebp),%eax
  80112c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80112f:	89 c2                	mov    %eax,%edx
  801131:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801134:	eb 03                	jmp    801139 <memfind+0x13>
  801136:	83 c0 01             	add    $0x1,%eax
  801139:	39 d0                	cmp    %edx,%eax
  80113b:	73 04                	jae    801141 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80113d:	38 08                	cmp    %cl,(%eax)
  80113f:	75 f5                	jne    801136 <memfind+0x10>
			break;
	return (void *) s;
}
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	57                   	push   %edi
  801147:	56                   	push   %esi
  801148:	53                   	push   %ebx
  801149:	8b 55 08             	mov    0x8(%ebp),%edx
  80114c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80114f:	eb 03                	jmp    801154 <strtol+0x11>
		s++;
  801151:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801154:	0f b6 02             	movzbl (%edx),%eax
  801157:	3c 20                	cmp    $0x20,%al
  801159:	74 f6                	je     801151 <strtol+0xe>
  80115b:	3c 09                	cmp    $0x9,%al
  80115d:	74 f2                	je     801151 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  80115f:	3c 2b                	cmp    $0x2b,%al
  801161:	74 2a                	je     80118d <strtol+0x4a>
	int neg = 0;
  801163:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801168:	3c 2d                	cmp    $0x2d,%al
  80116a:	74 2b                	je     801197 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80116c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801172:	75 0f                	jne    801183 <strtol+0x40>
  801174:	80 3a 30             	cmpb   $0x30,(%edx)
  801177:	74 28                	je     8011a1 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801179:	85 db                	test   %ebx,%ebx
  80117b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801180:	0f 44 d8             	cmove  %eax,%ebx
  801183:	b9 00 00 00 00       	mov    $0x0,%ecx
  801188:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80118b:	eb 46                	jmp    8011d3 <strtol+0x90>
		s++;
  80118d:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801190:	bf 00 00 00 00       	mov    $0x0,%edi
  801195:	eb d5                	jmp    80116c <strtol+0x29>
		s++, neg = 1;
  801197:	83 c2 01             	add    $0x1,%edx
  80119a:	bf 01 00 00 00       	mov    $0x1,%edi
  80119f:	eb cb                	jmp    80116c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8011a1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8011a5:	74 0e                	je     8011b5 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8011a7:	85 db                	test   %ebx,%ebx
  8011a9:	75 d8                	jne    801183 <strtol+0x40>
		s++, base = 8;
  8011ab:	83 c2 01             	add    $0x1,%edx
  8011ae:	bb 08 00 00 00       	mov    $0x8,%ebx
  8011b3:	eb ce                	jmp    801183 <strtol+0x40>
		s += 2, base = 16;
  8011b5:	83 c2 02             	add    $0x2,%edx
  8011b8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8011bd:	eb c4                	jmp    801183 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8011bf:	0f be c0             	movsbl %al,%eax
  8011c2:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8011c5:	3b 45 10             	cmp    0x10(%ebp),%eax
  8011c8:	7d 3a                	jge    801204 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  8011ca:	83 c2 01             	add    $0x1,%edx
  8011cd:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  8011d1:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  8011d3:	0f b6 02             	movzbl (%edx),%eax
  8011d6:	8d 70 d0             	lea    -0x30(%eax),%esi
  8011d9:	89 f3                	mov    %esi,%ebx
  8011db:	80 fb 09             	cmp    $0x9,%bl
  8011de:	76 df                	jbe    8011bf <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  8011e0:	8d 70 9f             	lea    -0x61(%eax),%esi
  8011e3:	89 f3                	mov    %esi,%ebx
  8011e5:	80 fb 19             	cmp    $0x19,%bl
  8011e8:	77 08                	ja     8011f2 <strtol+0xaf>
			dig = *s - 'a' + 10;
  8011ea:	0f be c0             	movsbl %al,%eax
  8011ed:	83 e8 57             	sub    $0x57,%eax
  8011f0:	eb d3                	jmp    8011c5 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8011f2:	8d 70 bf             	lea    -0x41(%eax),%esi
  8011f5:	89 f3                	mov    %esi,%ebx
  8011f7:	80 fb 19             	cmp    $0x19,%bl
  8011fa:	77 08                	ja     801204 <strtol+0xc1>
			dig = *s - 'A' + 10;
  8011fc:	0f be c0             	movsbl %al,%eax
  8011ff:	83 e8 37             	sub    $0x37,%eax
  801202:	eb c1                	jmp    8011c5 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801204:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801208:	74 05                	je     80120f <strtol+0xcc>
		*endptr = (char *) s;
  80120a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80120d:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  80120f:	89 c8                	mov    %ecx,%eax
  801211:	f7 d8                	neg    %eax
  801213:	85 ff                	test   %edi,%edi
  801215:	0f 45 c8             	cmovne %eax,%ecx
}
  801218:	89 c8                	mov    %ecx,%eax
  80121a:	5b                   	pop    %ebx
  80121b:	5e                   	pop    %esi
  80121c:	5f                   	pop    %edi
  80121d:	5d                   	pop    %ebp
  80121e:	c3                   	ret    

0080121f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	57                   	push   %edi
  801223:	56                   	push   %esi
  801224:	53                   	push   %ebx
	asm volatile("int %1\n"
  801225:	b8 00 00 00 00       	mov    $0x0,%eax
  80122a:	8b 55 08             	mov    0x8(%ebp),%edx
  80122d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801230:	89 c3                	mov    %eax,%ebx
  801232:	89 c7                	mov    %eax,%edi
  801234:	89 c6                	mov    %eax,%esi
  801236:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801238:	5b                   	pop    %ebx
  801239:	5e                   	pop    %esi
  80123a:	5f                   	pop    %edi
  80123b:	5d                   	pop    %ebp
  80123c:	c3                   	ret    

0080123d <sys_cgetc>:

int
sys_cgetc(void)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	57                   	push   %edi
  801241:	56                   	push   %esi
  801242:	53                   	push   %ebx
	asm volatile("int %1\n"
  801243:	ba 00 00 00 00       	mov    $0x0,%edx
  801248:	b8 01 00 00 00       	mov    $0x1,%eax
  80124d:	89 d1                	mov    %edx,%ecx
  80124f:	89 d3                	mov    %edx,%ebx
  801251:	89 d7                	mov    %edx,%edi
  801253:	89 d6                	mov    %edx,%esi
  801255:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801257:	5b                   	pop    %ebx
  801258:	5e                   	pop    %esi
  801259:	5f                   	pop    %edi
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    

0080125c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	57                   	push   %edi
  801260:	56                   	push   %esi
  801261:	53                   	push   %ebx
  801262:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801265:	b9 00 00 00 00       	mov    $0x0,%ecx
  80126a:	8b 55 08             	mov    0x8(%ebp),%edx
  80126d:	b8 03 00 00 00       	mov    $0x3,%eax
  801272:	89 cb                	mov    %ecx,%ebx
  801274:	89 cf                	mov    %ecx,%edi
  801276:	89 ce                	mov    %ecx,%esi
  801278:	cd 30                	int    $0x30
	if(check && ret > 0)
  80127a:	85 c0                	test   %eax,%eax
  80127c:	7f 08                	jg     801286 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80127e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801281:	5b                   	pop    %ebx
  801282:	5e                   	pop    %esi
  801283:	5f                   	pop    %edi
  801284:	5d                   	pop    %ebp
  801285:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801286:	83 ec 0c             	sub    $0xc,%esp
  801289:	50                   	push   %eax
  80128a:	6a 03                	push   $0x3
  80128c:	68 7f 31 80 00       	push   $0x80317f
  801291:	6a 2a                	push   $0x2a
  801293:	68 9c 31 80 00       	push   $0x80319c
  801298:	e8 8d f5 ff ff       	call   80082a <_panic>

0080129d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	57                   	push   %edi
  8012a1:	56                   	push   %esi
  8012a2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8012a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a8:	b8 02 00 00 00       	mov    $0x2,%eax
  8012ad:	89 d1                	mov    %edx,%ecx
  8012af:	89 d3                	mov    %edx,%ebx
  8012b1:	89 d7                	mov    %edx,%edi
  8012b3:	89 d6                	mov    %edx,%esi
  8012b5:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8012b7:	5b                   	pop    %ebx
  8012b8:	5e                   	pop    %esi
  8012b9:	5f                   	pop    %edi
  8012ba:	5d                   	pop    %ebp
  8012bb:	c3                   	ret    

008012bc <sys_yield>:

void
sys_yield(void)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	57                   	push   %edi
  8012c0:	56                   	push   %esi
  8012c1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8012c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012cc:	89 d1                	mov    %edx,%ecx
  8012ce:	89 d3                	mov    %edx,%ebx
  8012d0:	89 d7                	mov    %edx,%edi
  8012d2:	89 d6                	mov    %edx,%esi
  8012d4:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8012d6:	5b                   	pop    %ebx
  8012d7:	5e                   	pop    %esi
  8012d8:	5f                   	pop    %edi
  8012d9:	5d                   	pop    %ebp
  8012da:	c3                   	ret    

008012db <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8012db:	55                   	push   %ebp
  8012dc:	89 e5                	mov    %esp,%ebp
  8012de:	57                   	push   %edi
  8012df:	56                   	push   %esi
  8012e0:	53                   	push   %ebx
  8012e1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012e4:	be 00 00 00 00       	mov    $0x0,%esi
  8012e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ef:	b8 04 00 00 00       	mov    $0x4,%eax
  8012f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012f7:	89 f7                	mov    %esi,%edi
  8012f9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	7f 08                	jg     801307 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8012ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801302:	5b                   	pop    %ebx
  801303:	5e                   	pop    %esi
  801304:	5f                   	pop    %edi
  801305:	5d                   	pop    %ebp
  801306:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801307:	83 ec 0c             	sub    $0xc,%esp
  80130a:	50                   	push   %eax
  80130b:	6a 04                	push   $0x4
  80130d:	68 7f 31 80 00       	push   $0x80317f
  801312:	6a 2a                	push   $0x2a
  801314:	68 9c 31 80 00       	push   $0x80319c
  801319:	e8 0c f5 ff ff       	call   80082a <_panic>

0080131e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	57                   	push   %edi
  801322:	56                   	push   %esi
  801323:	53                   	push   %ebx
  801324:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801327:	8b 55 08             	mov    0x8(%ebp),%edx
  80132a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80132d:	b8 05 00 00 00       	mov    $0x5,%eax
  801332:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801335:	8b 7d 14             	mov    0x14(%ebp),%edi
  801338:	8b 75 18             	mov    0x18(%ebp),%esi
  80133b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80133d:	85 c0                	test   %eax,%eax
  80133f:	7f 08                	jg     801349 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801341:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801344:	5b                   	pop    %ebx
  801345:	5e                   	pop    %esi
  801346:	5f                   	pop    %edi
  801347:	5d                   	pop    %ebp
  801348:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801349:	83 ec 0c             	sub    $0xc,%esp
  80134c:	50                   	push   %eax
  80134d:	6a 05                	push   $0x5
  80134f:	68 7f 31 80 00       	push   $0x80317f
  801354:	6a 2a                	push   $0x2a
  801356:	68 9c 31 80 00       	push   $0x80319c
  80135b:	e8 ca f4 ff ff       	call   80082a <_panic>

00801360 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	57                   	push   %edi
  801364:	56                   	push   %esi
  801365:	53                   	push   %ebx
  801366:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801369:	bb 00 00 00 00       	mov    $0x0,%ebx
  80136e:	8b 55 08             	mov    0x8(%ebp),%edx
  801371:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801374:	b8 06 00 00 00       	mov    $0x6,%eax
  801379:	89 df                	mov    %ebx,%edi
  80137b:	89 de                	mov    %ebx,%esi
  80137d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80137f:	85 c0                	test   %eax,%eax
  801381:	7f 08                	jg     80138b <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801383:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801386:	5b                   	pop    %ebx
  801387:	5e                   	pop    %esi
  801388:	5f                   	pop    %edi
  801389:	5d                   	pop    %ebp
  80138a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80138b:	83 ec 0c             	sub    $0xc,%esp
  80138e:	50                   	push   %eax
  80138f:	6a 06                	push   $0x6
  801391:	68 7f 31 80 00       	push   $0x80317f
  801396:	6a 2a                	push   $0x2a
  801398:	68 9c 31 80 00       	push   $0x80319c
  80139d:	e8 88 f4 ff ff       	call   80082a <_panic>

008013a2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	57                   	push   %edi
  8013a6:	56                   	push   %esi
  8013a7:	53                   	push   %ebx
  8013a8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8013ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8013b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b6:	b8 08 00 00 00       	mov    $0x8,%eax
  8013bb:	89 df                	mov    %ebx,%edi
  8013bd:	89 de                	mov    %ebx,%esi
  8013bf:	cd 30                	int    $0x30
	if(check && ret > 0)
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	7f 08                	jg     8013cd <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c8:	5b                   	pop    %ebx
  8013c9:	5e                   	pop    %esi
  8013ca:	5f                   	pop    %edi
  8013cb:	5d                   	pop    %ebp
  8013cc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8013cd:	83 ec 0c             	sub    $0xc,%esp
  8013d0:	50                   	push   %eax
  8013d1:	6a 08                	push   $0x8
  8013d3:	68 7f 31 80 00       	push   $0x80317f
  8013d8:	6a 2a                	push   $0x2a
  8013da:	68 9c 31 80 00       	push   $0x80319c
  8013df:	e8 46 f4 ff ff       	call   80082a <_panic>

008013e4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	57                   	push   %edi
  8013e8:	56                   	push   %esi
  8013e9:	53                   	push   %ebx
  8013ea:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8013ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f8:	b8 09 00 00 00       	mov    $0x9,%eax
  8013fd:	89 df                	mov    %ebx,%edi
  8013ff:	89 de                	mov    %ebx,%esi
  801401:	cd 30                	int    $0x30
	if(check && ret > 0)
  801403:	85 c0                	test   %eax,%eax
  801405:	7f 08                	jg     80140f <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801407:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80140a:	5b                   	pop    %ebx
  80140b:	5e                   	pop    %esi
  80140c:	5f                   	pop    %edi
  80140d:	5d                   	pop    %ebp
  80140e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80140f:	83 ec 0c             	sub    $0xc,%esp
  801412:	50                   	push   %eax
  801413:	6a 09                	push   $0x9
  801415:	68 7f 31 80 00       	push   $0x80317f
  80141a:	6a 2a                	push   $0x2a
  80141c:	68 9c 31 80 00       	push   $0x80319c
  801421:	e8 04 f4 ff ff       	call   80082a <_panic>

00801426 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	57                   	push   %edi
  80142a:	56                   	push   %esi
  80142b:	53                   	push   %ebx
  80142c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80142f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801434:	8b 55 08             	mov    0x8(%ebp),%edx
  801437:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80143a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80143f:	89 df                	mov    %ebx,%edi
  801441:	89 de                	mov    %ebx,%esi
  801443:	cd 30                	int    $0x30
	if(check && ret > 0)
  801445:	85 c0                	test   %eax,%eax
  801447:	7f 08                	jg     801451 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801449:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80144c:	5b                   	pop    %ebx
  80144d:	5e                   	pop    %esi
  80144e:	5f                   	pop    %edi
  80144f:	5d                   	pop    %ebp
  801450:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801451:	83 ec 0c             	sub    $0xc,%esp
  801454:	50                   	push   %eax
  801455:	6a 0a                	push   $0xa
  801457:	68 7f 31 80 00       	push   $0x80317f
  80145c:	6a 2a                	push   $0x2a
  80145e:	68 9c 31 80 00       	push   $0x80319c
  801463:	e8 c2 f3 ff ff       	call   80082a <_panic>

00801468 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	57                   	push   %edi
  80146c:	56                   	push   %esi
  80146d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80146e:	8b 55 08             	mov    0x8(%ebp),%edx
  801471:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801474:	b8 0c 00 00 00       	mov    $0xc,%eax
  801479:	be 00 00 00 00       	mov    $0x0,%esi
  80147e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801481:	8b 7d 14             	mov    0x14(%ebp),%edi
  801484:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801486:	5b                   	pop    %ebx
  801487:	5e                   	pop    %esi
  801488:	5f                   	pop    %edi
  801489:	5d                   	pop    %ebp
  80148a:	c3                   	ret    

0080148b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	57                   	push   %edi
  80148f:	56                   	push   %esi
  801490:	53                   	push   %ebx
  801491:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801494:	b9 00 00 00 00       	mov    $0x0,%ecx
  801499:	8b 55 08             	mov    0x8(%ebp),%edx
  80149c:	b8 0d 00 00 00       	mov    $0xd,%eax
  8014a1:	89 cb                	mov    %ecx,%ebx
  8014a3:	89 cf                	mov    %ecx,%edi
  8014a5:	89 ce                	mov    %ecx,%esi
  8014a7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	7f 08                	jg     8014b5 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8014ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b0:	5b                   	pop    %ebx
  8014b1:	5e                   	pop    %esi
  8014b2:	5f                   	pop    %edi
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8014b5:	83 ec 0c             	sub    $0xc,%esp
  8014b8:	50                   	push   %eax
  8014b9:	6a 0d                	push   $0xd
  8014bb:	68 7f 31 80 00       	push   $0x80317f
  8014c0:	6a 2a                	push   $0x2a
  8014c2:	68 9c 31 80 00       	push   $0x80319c
  8014c7:	e8 5e f3 ff ff       	call   80082a <_panic>

008014cc <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	57                   	push   %edi
  8014d0:	56                   	push   %esi
  8014d1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8014d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d7:	b8 0e 00 00 00       	mov    $0xe,%eax
  8014dc:	89 d1                	mov    %edx,%ecx
  8014de:	89 d3                	mov    %edx,%ebx
  8014e0:	89 d7                	mov    %edx,%edi
  8014e2:	89 d6                	mov    %edx,%esi
  8014e4:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8014e6:	5b                   	pop    %ebx
  8014e7:	5e                   	pop    %esi
  8014e8:	5f                   	pop    %edi
  8014e9:	5d                   	pop    %ebp
  8014ea:	c3                   	ret    

008014eb <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	57                   	push   %edi
  8014ef:	56                   	push   %esi
  8014f0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8014f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014fc:	b8 0f 00 00 00       	mov    $0xf,%eax
  801501:	89 df                	mov    %ebx,%edi
  801503:	89 de                	mov    %ebx,%esi
  801505:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  801507:	5b                   	pop    %ebx
  801508:	5e                   	pop    %esi
  801509:	5f                   	pop    %edi
  80150a:	5d                   	pop    %ebp
  80150b:	c3                   	ret    

0080150c <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	57                   	push   %edi
  801510:	56                   	push   %esi
  801511:	53                   	push   %ebx
	asm volatile("int %1\n"
  801512:	bb 00 00 00 00       	mov    $0x0,%ebx
  801517:	8b 55 08             	mov    0x8(%ebp),%edx
  80151a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80151d:	b8 10 00 00 00       	mov    $0x10,%eax
  801522:	89 df                	mov    %ebx,%edi
  801524:	89 de                	mov    %ebx,%esi
  801526:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  801528:	5b                   	pop    %ebx
  801529:	5e                   	pop    %esi
  80152a:	5f                   	pop    %edi
  80152b:	5d                   	pop    %ebp
  80152c:	c3                   	ret    

0080152d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801530:	8b 45 08             	mov    0x8(%ebp),%eax
  801533:	05 00 00 00 30       	add    $0x30000000,%eax
  801538:	c1 e8 0c             	shr    $0xc,%eax
}
  80153b:	5d                   	pop    %ebp
  80153c:	c3                   	ret    

0080153d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801540:	8b 45 08             	mov    0x8(%ebp),%eax
  801543:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801548:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80154d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801552:	5d                   	pop    %ebp
  801553:	c3                   	ret    

00801554 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80155c:	89 c2                	mov    %eax,%edx
  80155e:	c1 ea 16             	shr    $0x16,%edx
  801561:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801568:	f6 c2 01             	test   $0x1,%dl
  80156b:	74 29                	je     801596 <fd_alloc+0x42>
  80156d:	89 c2                	mov    %eax,%edx
  80156f:	c1 ea 0c             	shr    $0xc,%edx
  801572:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801579:	f6 c2 01             	test   $0x1,%dl
  80157c:	74 18                	je     801596 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80157e:	05 00 10 00 00       	add    $0x1000,%eax
  801583:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801588:	75 d2                	jne    80155c <fd_alloc+0x8>
  80158a:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80158f:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801594:	eb 05                	jmp    80159b <fd_alloc+0x47>
			return 0;
  801596:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80159b:	8b 55 08             	mov    0x8(%ebp),%edx
  80159e:	89 02                	mov    %eax,(%edx)
}
  8015a0:	89 c8                	mov    %ecx,%eax
  8015a2:	5d                   	pop    %ebp
  8015a3:	c3                   	ret    

008015a4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8015aa:	83 f8 1f             	cmp    $0x1f,%eax
  8015ad:	77 30                	ja     8015df <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8015af:	c1 e0 0c             	shl    $0xc,%eax
  8015b2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8015b7:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8015bd:	f6 c2 01             	test   $0x1,%dl
  8015c0:	74 24                	je     8015e6 <fd_lookup+0x42>
  8015c2:	89 c2                	mov    %eax,%edx
  8015c4:	c1 ea 0c             	shr    $0xc,%edx
  8015c7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015ce:	f6 c2 01             	test   $0x1,%dl
  8015d1:	74 1a                	je     8015ed <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d6:	89 02                	mov    %eax,(%edx)
	return 0;
  8015d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015dd:	5d                   	pop    %ebp
  8015de:	c3                   	ret    
		return -E_INVAL;
  8015df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015e4:	eb f7                	jmp    8015dd <fd_lookup+0x39>
		return -E_INVAL;
  8015e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015eb:	eb f0                	jmp    8015dd <fd_lookup+0x39>
  8015ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f2:	eb e9                	jmp    8015dd <fd_lookup+0x39>

008015f4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	53                   	push   %ebx
  8015f8:	83 ec 04             	sub    $0x4,%esp
  8015fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8015fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801603:	bb 24 40 80 00       	mov    $0x804024,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801608:	39 13                	cmp    %edx,(%ebx)
  80160a:	74 37                	je     801643 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  80160c:	83 c0 01             	add    $0x1,%eax
  80160f:	8b 1c 85 28 32 80 00 	mov    0x803228(,%eax,4),%ebx
  801616:	85 db                	test   %ebx,%ebx
  801618:	75 ee                	jne    801608 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80161a:	a1 10 50 80 00       	mov    0x805010,%eax
  80161f:	8b 40 58             	mov    0x58(%eax),%eax
  801622:	83 ec 04             	sub    $0x4,%esp
  801625:	52                   	push   %edx
  801626:	50                   	push   %eax
  801627:	68 ac 31 80 00       	push   $0x8031ac
  80162c:	e8 d4 f2 ff ff       	call   800905 <cprintf>
	*dev = 0;
	return -E_INVAL;
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801639:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163c:	89 1a                	mov    %ebx,(%edx)
}
  80163e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801641:	c9                   	leave  
  801642:	c3                   	ret    
			return 0;
  801643:	b8 00 00 00 00       	mov    $0x0,%eax
  801648:	eb ef                	jmp    801639 <dev_lookup+0x45>

0080164a <fd_close>:
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	57                   	push   %edi
  80164e:	56                   	push   %esi
  80164f:	53                   	push   %ebx
  801650:	83 ec 24             	sub    $0x24,%esp
  801653:	8b 75 08             	mov    0x8(%ebp),%esi
  801656:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801659:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80165c:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80165d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801663:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801666:	50                   	push   %eax
  801667:	e8 38 ff ff ff       	call   8015a4 <fd_lookup>
  80166c:	89 c3                	mov    %eax,%ebx
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	85 c0                	test   %eax,%eax
  801673:	78 05                	js     80167a <fd_close+0x30>
	    || fd != fd2)
  801675:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801678:	74 16                	je     801690 <fd_close+0x46>
		return (must_exist ? r : 0);
  80167a:	89 f8                	mov    %edi,%eax
  80167c:	84 c0                	test   %al,%al
  80167e:	b8 00 00 00 00       	mov    $0x0,%eax
  801683:	0f 44 d8             	cmove  %eax,%ebx
}
  801686:	89 d8                	mov    %ebx,%eax
  801688:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168b:	5b                   	pop    %ebx
  80168c:	5e                   	pop    %esi
  80168d:	5f                   	pop    %edi
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801690:	83 ec 08             	sub    $0x8,%esp
  801693:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801696:	50                   	push   %eax
  801697:	ff 36                	push   (%esi)
  801699:	e8 56 ff ff ff       	call   8015f4 <dev_lookup>
  80169e:	89 c3                	mov    %eax,%ebx
  8016a0:	83 c4 10             	add    $0x10,%esp
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	78 1a                	js     8016c1 <fd_close+0x77>
		if (dev->dev_close)
  8016a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016aa:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8016ad:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8016b2:	85 c0                	test   %eax,%eax
  8016b4:	74 0b                	je     8016c1 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8016b6:	83 ec 0c             	sub    $0xc,%esp
  8016b9:	56                   	push   %esi
  8016ba:	ff d0                	call   *%eax
  8016bc:	89 c3                	mov    %eax,%ebx
  8016be:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8016c1:	83 ec 08             	sub    $0x8,%esp
  8016c4:	56                   	push   %esi
  8016c5:	6a 00                	push   $0x0
  8016c7:	e8 94 fc ff ff       	call   801360 <sys_page_unmap>
	return r;
  8016cc:	83 c4 10             	add    $0x10,%esp
  8016cf:	eb b5                	jmp    801686 <fd_close+0x3c>

008016d1 <close>:

int
close(int fdnum)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016da:	50                   	push   %eax
  8016db:	ff 75 08             	push   0x8(%ebp)
  8016de:	e8 c1 fe ff ff       	call   8015a4 <fd_lookup>
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	85 c0                	test   %eax,%eax
  8016e8:	79 02                	jns    8016ec <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8016ea:	c9                   	leave  
  8016eb:	c3                   	ret    
		return fd_close(fd, 1);
  8016ec:	83 ec 08             	sub    $0x8,%esp
  8016ef:	6a 01                	push   $0x1
  8016f1:	ff 75 f4             	push   -0xc(%ebp)
  8016f4:	e8 51 ff ff ff       	call   80164a <fd_close>
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	eb ec                	jmp    8016ea <close+0x19>

008016fe <close_all>:

void
close_all(void)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	53                   	push   %ebx
  801702:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801705:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80170a:	83 ec 0c             	sub    $0xc,%esp
  80170d:	53                   	push   %ebx
  80170e:	e8 be ff ff ff       	call   8016d1 <close>
	for (i = 0; i < MAXFD; i++)
  801713:	83 c3 01             	add    $0x1,%ebx
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	83 fb 20             	cmp    $0x20,%ebx
  80171c:	75 ec                	jne    80170a <close_all+0xc>
}
  80171e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801721:	c9                   	leave  
  801722:	c3                   	ret    

00801723 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	57                   	push   %edi
  801727:	56                   	push   %esi
  801728:	53                   	push   %ebx
  801729:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80172c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80172f:	50                   	push   %eax
  801730:	ff 75 08             	push   0x8(%ebp)
  801733:	e8 6c fe ff ff       	call   8015a4 <fd_lookup>
  801738:	89 c3                	mov    %eax,%ebx
  80173a:	83 c4 10             	add    $0x10,%esp
  80173d:	85 c0                	test   %eax,%eax
  80173f:	78 7f                	js     8017c0 <dup+0x9d>
		return r;
	close(newfdnum);
  801741:	83 ec 0c             	sub    $0xc,%esp
  801744:	ff 75 0c             	push   0xc(%ebp)
  801747:	e8 85 ff ff ff       	call   8016d1 <close>

	newfd = INDEX2FD(newfdnum);
  80174c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80174f:	c1 e6 0c             	shl    $0xc,%esi
  801752:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801758:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80175b:	89 3c 24             	mov    %edi,(%esp)
  80175e:	e8 da fd ff ff       	call   80153d <fd2data>
  801763:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801765:	89 34 24             	mov    %esi,(%esp)
  801768:	e8 d0 fd ff ff       	call   80153d <fd2data>
  80176d:	83 c4 10             	add    $0x10,%esp
  801770:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801773:	89 d8                	mov    %ebx,%eax
  801775:	c1 e8 16             	shr    $0x16,%eax
  801778:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80177f:	a8 01                	test   $0x1,%al
  801781:	74 11                	je     801794 <dup+0x71>
  801783:	89 d8                	mov    %ebx,%eax
  801785:	c1 e8 0c             	shr    $0xc,%eax
  801788:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80178f:	f6 c2 01             	test   $0x1,%dl
  801792:	75 36                	jne    8017ca <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801794:	89 f8                	mov    %edi,%eax
  801796:	c1 e8 0c             	shr    $0xc,%eax
  801799:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017a0:	83 ec 0c             	sub    $0xc,%esp
  8017a3:	25 07 0e 00 00       	and    $0xe07,%eax
  8017a8:	50                   	push   %eax
  8017a9:	56                   	push   %esi
  8017aa:	6a 00                	push   $0x0
  8017ac:	57                   	push   %edi
  8017ad:	6a 00                	push   $0x0
  8017af:	e8 6a fb ff ff       	call   80131e <sys_page_map>
  8017b4:	89 c3                	mov    %eax,%ebx
  8017b6:	83 c4 20             	add    $0x20,%esp
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	78 33                	js     8017f0 <dup+0xcd>
		goto err;

	return newfdnum;
  8017bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8017c0:	89 d8                	mov    %ebx,%eax
  8017c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c5:	5b                   	pop    %ebx
  8017c6:	5e                   	pop    %esi
  8017c7:	5f                   	pop    %edi
  8017c8:	5d                   	pop    %ebp
  8017c9:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8017ca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017d1:	83 ec 0c             	sub    $0xc,%esp
  8017d4:	25 07 0e 00 00       	and    $0xe07,%eax
  8017d9:	50                   	push   %eax
  8017da:	ff 75 d4             	push   -0x2c(%ebp)
  8017dd:	6a 00                	push   $0x0
  8017df:	53                   	push   %ebx
  8017e0:	6a 00                	push   $0x0
  8017e2:	e8 37 fb ff ff       	call   80131e <sys_page_map>
  8017e7:	89 c3                	mov    %eax,%ebx
  8017e9:	83 c4 20             	add    $0x20,%esp
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	79 a4                	jns    801794 <dup+0x71>
	sys_page_unmap(0, newfd);
  8017f0:	83 ec 08             	sub    $0x8,%esp
  8017f3:	56                   	push   %esi
  8017f4:	6a 00                	push   $0x0
  8017f6:	e8 65 fb ff ff       	call   801360 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017fb:	83 c4 08             	add    $0x8,%esp
  8017fe:	ff 75 d4             	push   -0x2c(%ebp)
  801801:	6a 00                	push   $0x0
  801803:	e8 58 fb ff ff       	call   801360 <sys_page_unmap>
	return r;
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	eb b3                	jmp    8017c0 <dup+0x9d>

0080180d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	56                   	push   %esi
  801811:	53                   	push   %ebx
  801812:	83 ec 18             	sub    $0x18,%esp
  801815:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801818:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181b:	50                   	push   %eax
  80181c:	56                   	push   %esi
  80181d:	e8 82 fd ff ff       	call   8015a4 <fd_lookup>
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	85 c0                	test   %eax,%eax
  801827:	78 3c                	js     801865 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801829:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80182c:	83 ec 08             	sub    $0x8,%esp
  80182f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801832:	50                   	push   %eax
  801833:	ff 33                	push   (%ebx)
  801835:	e8 ba fd ff ff       	call   8015f4 <dev_lookup>
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	85 c0                	test   %eax,%eax
  80183f:	78 24                	js     801865 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801841:	8b 43 08             	mov    0x8(%ebx),%eax
  801844:	83 e0 03             	and    $0x3,%eax
  801847:	83 f8 01             	cmp    $0x1,%eax
  80184a:	74 20                	je     80186c <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80184c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80184f:	8b 40 08             	mov    0x8(%eax),%eax
  801852:	85 c0                	test   %eax,%eax
  801854:	74 37                	je     80188d <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801856:	83 ec 04             	sub    $0x4,%esp
  801859:	ff 75 10             	push   0x10(%ebp)
  80185c:	ff 75 0c             	push   0xc(%ebp)
  80185f:	53                   	push   %ebx
  801860:	ff d0                	call   *%eax
  801862:	83 c4 10             	add    $0x10,%esp
}
  801865:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801868:	5b                   	pop    %ebx
  801869:	5e                   	pop    %esi
  80186a:	5d                   	pop    %ebp
  80186b:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80186c:	a1 10 50 80 00       	mov    0x805010,%eax
  801871:	8b 40 58             	mov    0x58(%eax),%eax
  801874:	83 ec 04             	sub    $0x4,%esp
  801877:	56                   	push   %esi
  801878:	50                   	push   %eax
  801879:	68 ed 31 80 00       	push   $0x8031ed
  80187e:	e8 82 f0 ff ff       	call   800905 <cprintf>
		return -E_INVAL;
  801883:	83 c4 10             	add    $0x10,%esp
  801886:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80188b:	eb d8                	jmp    801865 <read+0x58>
		return -E_NOT_SUPP;
  80188d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801892:	eb d1                	jmp    801865 <read+0x58>

00801894 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	57                   	push   %edi
  801898:	56                   	push   %esi
  801899:	53                   	push   %ebx
  80189a:	83 ec 0c             	sub    $0xc,%esp
  80189d:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018a0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018a8:	eb 02                	jmp    8018ac <readn+0x18>
  8018aa:	01 c3                	add    %eax,%ebx
  8018ac:	39 f3                	cmp    %esi,%ebx
  8018ae:	73 21                	jae    8018d1 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018b0:	83 ec 04             	sub    $0x4,%esp
  8018b3:	89 f0                	mov    %esi,%eax
  8018b5:	29 d8                	sub    %ebx,%eax
  8018b7:	50                   	push   %eax
  8018b8:	89 d8                	mov    %ebx,%eax
  8018ba:	03 45 0c             	add    0xc(%ebp),%eax
  8018bd:	50                   	push   %eax
  8018be:	57                   	push   %edi
  8018bf:	e8 49 ff ff ff       	call   80180d <read>
		if (m < 0)
  8018c4:	83 c4 10             	add    $0x10,%esp
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	78 04                	js     8018cf <readn+0x3b>
			return m;
		if (m == 0)
  8018cb:	75 dd                	jne    8018aa <readn+0x16>
  8018cd:	eb 02                	jmp    8018d1 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018cf:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8018d1:	89 d8                	mov    %ebx,%eax
  8018d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018d6:	5b                   	pop    %ebx
  8018d7:	5e                   	pop    %esi
  8018d8:	5f                   	pop    %edi
  8018d9:	5d                   	pop    %ebp
  8018da:	c3                   	ret    

008018db <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	56                   	push   %esi
  8018df:	53                   	push   %ebx
  8018e0:	83 ec 18             	sub    $0x18,%esp
  8018e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e9:	50                   	push   %eax
  8018ea:	53                   	push   %ebx
  8018eb:	e8 b4 fc ff ff       	call   8015a4 <fd_lookup>
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	78 37                	js     80192e <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f7:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8018fa:	83 ec 08             	sub    $0x8,%esp
  8018fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801900:	50                   	push   %eax
  801901:	ff 36                	push   (%esi)
  801903:	e8 ec fc ff ff       	call   8015f4 <dev_lookup>
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	85 c0                	test   %eax,%eax
  80190d:	78 1f                	js     80192e <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80190f:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801913:	74 20                	je     801935 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801915:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801918:	8b 40 0c             	mov    0xc(%eax),%eax
  80191b:	85 c0                	test   %eax,%eax
  80191d:	74 37                	je     801956 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80191f:	83 ec 04             	sub    $0x4,%esp
  801922:	ff 75 10             	push   0x10(%ebp)
  801925:	ff 75 0c             	push   0xc(%ebp)
  801928:	56                   	push   %esi
  801929:	ff d0                	call   *%eax
  80192b:	83 c4 10             	add    $0x10,%esp
}
  80192e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801931:	5b                   	pop    %ebx
  801932:	5e                   	pop    %esi
  801933:	5d                   	pop    %ebp
  801934:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801935:	a1 10 50 80 00       	mov    0x805010,%eax
  80193a:	8b 40 58             	mov    0x58(%eax),%eax
  80193d:	83 ec 04             	sub    $0x4,%esp
  801940:	53                   	push   %ebx
  801941:	50                   	push   %eax
  801942:	68 09 32 80 00       	push   $0x803209
  801947:	e8 b9 ef ff ff       	call   800905 <cprintf>
		return -E_INVAL;
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801954:	eb d8                	jmp    80192e <write+0x53>
		return -E_NOT_SUPP;
  801956:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80195b:	eb d1                	jmp    80192e <write+0x53>

0080195d <seek>:

int
seek(int fdnum, off_t offset)
{
  80195d:	55                   	push   %ebp
  80195e:	89 e5                	mov    %esp,%ebp
  801960:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801963:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801966:	50                   	push   %eax
  801967:	ff 75 08             	push   0x8(%ebp)
  80196a:	e8 35 fc ff ff       	call   8015a4 <fd_lookup>
  80196f:	83 c4 10             	add    $0x10,%esp
  801972:	85 c0                	test   %eax,%eax
  801974:	78 0e                	js     801984 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801976:	8b 55 0c             	mov    0xc(%ebp),%edx
  801979:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80197c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80197f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801984:	c9                   	leave  
  801985:	c3                   	ret    

00801986 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	56                   	push   %esi
  80198a:	53                   	push   %ebx
  80198b:	83 ec 18             	sub    $0x18,%esp
  80198e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801991:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801994:	50                   	push   %eax
  801995:	53                   	push   %ebx
  801996:	e8 09 fc ff ff       	call   8015a4 <fd_lookup>
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 34                	js     8019d6 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019a2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8019a5:	83 ec 08             	sub    $0x8,%esp
  8019a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ab:	50                   	push   %eax
  8019ac:	ff 36                	push   (%esi)
  8019ae:	e8 41 fc ff ff       	call   8015f4 <dev_lookup>
  8019b3:	83 c4 10             	add    $0x10,%esp
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	78 1c                	js     8019d6 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019ba:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8019be:	74 1d                	je     8019dd <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8019c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c3:	8b 40 18             	mov    0x18(%eax),%eax
  8019c6:	85 c0                	test   %eax,%eax
  8019c8:	74 34                	je     8019fe <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019ca:	83 ec 08             	sub    $0x8,%esp
  8019cd:	ff 75 0c             	push   0xc(%ebp)
  8019d0:	56                   	push   %esi
  8019d1:	ff d0                	call   *%eax
  8019d3:	83 c4 10             	add    $0x10,%esp
}
  8019d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d9:	5b                   	pop    %ebx
  8019da:	5e                   	pop    %esi
  8019db:	5d                   	pop    %ebp
  8019dc:	c3                   	ret    
			thisenv->env_id, fdnum);
  8019dd:	a1 10 50 80 00       	mov    0x805010,%eax
  8019e2:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019e5:	83 ec 04             	sub    $0x4,%esp
  8019e8:	53                   	push   %ebx
  8019e9:	50                   	push   %eax
  8019ea:	68 cc 31 80 00       	push   $0x8031cc
  8019ef:	e8 11 ef ff ff       	call   800905 <cprintf>
		return -E_INVAL;
  8019f4:	83 c4 10             	add    $0x10,%esp
  8019f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019fc:	eb d8                	jmp    8019d6 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8019fe:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a03:	eb d1                	jmp    8019d6 <ftruncate+0x50>

00801a05 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	56                   	push   %esi
  801a09:	53                   	push   %ebx
  801a0a:	83 ec 18             	sub    $0x18,%esp
  801a0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a10:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a13:	50                   	push   %eax
  801a14:	ff 75 08             	push   0x8(%ebp)
  801a17:	e8 88 fb ff ff       	call   8015a4 <fd_lookup>
  801a1c:	83 c4 10             	add    $0x10,%esp
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	78 49                	js     801a6c <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a23:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801a26:	83 ec 08             	sub    $0x8,%esp
  801a29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a2c:	50                   	push   %eax
  801a2d:	ff 36                	push   (%esi)
  801a2f:	e8 c0 fb ff ff       	call   8015f4 <dev_lookup>
  801a34:	83 c4 10             	add    $0x10,%esp
  801a37:	85 c0                	test   %eax,%eax
  801a39:	78 31                	js     801a6c <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a3e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a42:	74 2f                	je     801a73 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a44:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a47:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a4e:	00 00 00 
	stat->st_isdir = 0;
  801a51:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a58:	00 00 00 
	stat->st_dev = dev;
  801a5b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a61:	83 ec 08             	sub    $0x8,%esp
  801a64:	53                   	push   %ebx
  801a65:	56                   	push   %esi
  801a66:	ff 50 14             	call   *0x14(%eax)
  801a69:	83 c4 10             	add    $0x10,%esp
}
  801a6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6f:	5b                   	pop    %ebx
  801a70:	5e                   	pop    %esi
  801a71:	5d                   	pop    %ebp
  801a72:	c3                   	ret    
		return -E_NOT_SUPP;
  801a73:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a78:	eb f2                	jmp    801a6c <fstat+0x67>

00801a7a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
  801a7d:	56                   	push   %esi
  801a7e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a7f:	83 ec 08             	sub    $0x8,%esp
  801a82:	6a 00                	push   $0x0
  801a84:	ff 75 08             	push   0x8(%ebp)
  801a87:	e8 e4 01 00 00       	call   801c70 <open>
  801a8c:	89 c3                	mov    %eax,%ebx
  801a8e:	83 c4 10             	add    $0x10,%esp
  801a91:	85 c0                	test   %eax,%eax
  801a93:	78 1b                	js     801ab0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a95:	83 ec 08             	sub    $0x8,%esp
  801a98:	ff 75 0c             	push   0xc(%ebp)
  801a9b:	50                   	push   %eax
  801a9c:	e8 64 ff ff ff       	call   801a05 <fstat>
  801aa1:	89 c6                	mov    %eax,%esi
	close(fd);
  801aa3:	89 1c 24             	mov    %ebx,(%esp)
  801aa6:	e8 26 fc ff ff       	call   8016d1 <close>
	return r;
  801aab:	83 c4 10             	add    $0x10,%esp
  801aae:	89 f3                	mov    %esi,%ebx
}
  801ab0:	89 d8                	mov    %ebx,%eax
  801ab2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab5:	5b                   	pop    %ebx
  801ab6:	5e                   	pop    %esi
  801ab7:	5d                   	pop    %ebp
  801ab8:	c3                   	ret    

00801ab9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	56                   	push   %esi
  801abd:	53                   	push   %ebx
  801abe:	89 c6                	mov    %eax,%esi
  801ac0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801ac2:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  801ac9:	74 27                	je     801af2 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801acb:	6a 07                	push   $0x7
  801acd:	68 00 60 80 00       	push   $0x806000
  801ad2:	56                   	push   %esi
  801ad3:	ff 35 00 70 80 00    	push   0x807000
  801ad9:	e8 59 0e 00 00       	call   802937 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ade:	83 c4 0c             	add    $0xc,%esp
  801ae1:	6a 00                	push   $0x0
  801ae3:	53                   	push   %ebx
  801ae4:	6a 00                	push   $0x0
  801ae6:	e8 dc 0d 00 00       	call   8028c7 <ipc_recv>
}
  801aeb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aee:	5b                   	pop    %ebx
  801aef:	5e                   	pop    %esi
  801af0:	5d                   	pop    %ebp
  801af1:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801af2:	83 ec 0c             	sub    $0xc,%esp
  801af5:	6a 01                	push   $0x1
  801af7:	e8 8f 0e 00 00       	call   80298b <ipc_find_env>
  801afc:	a3 00 70 80 00       	mov    %eax,0x807000
  801b01:	83 c4 10             	add    $0x10,%esp
  801b04:	eb c5                	jmp    801acb <fsipc+0x12>

00801b06 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b12:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801b17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1a:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b1f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b24:	b8 02 00 00 00       	mov    $0x2,%eax
  801b29:	e8 8b ff ff ff       	call   801ab9 <fsipc>
}
  801b2e:	c9                   	leave  
  801b2f:	c3                   	ret    

00801b30 <devfile_flush>:
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b36:	8b 45 08             	mov    0x8(%ebp),%eax
  801b39:	8b 40 0c             	mov    0xc(%eax),%eax
  801b3c:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b41:	ba 00 00 00 00       	mov    $0x0,%edx
  801b46:	b8 06 00 00 00       	mov    $0x6,%eax
  801b4b:	e8 69 ff ff ff       	call   801ab9 <fsipc>
}
  801b50:	c9                   	leave  
  801b51:	c3                   	ret    

00801b52 <devfile_stat>:
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	53                   	push   %ebx
  801b56:	83 ec 04             	sub    $0x4,%esp
  801b59:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b62:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b67:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6c:	b8 05 00 00 00       	mov    $0x5,%eax
  801b71:	e8 43 ff ff ff       	call   801ab9 <fsipc>
  801b76:	85 c0                	test   %eax,%eax
  801b78:	78 2c                	js     801ba6 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b7a:	83 ec 08             	sub    $0x8,%esp
  801b7d:	68 00 60 80 00       	push   $0x806000
  801b82:	53                   	push   %ebx
  801b83:	e8 57 f3 ff ff       	call   800edf <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b88:	a1 80 60 80 00       	mov    0x806080,%eax
  801b8d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b93:	a1 84 60 80 00       	mov    0x806084,%eax
  801b98:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b9e:	83 c4 10             	add    $0x10,%esp
  801ba1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ba6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba9:	c9                   	leave  
  801baa:	c3                   	ret    

00801bab <devfile_write>:
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	83 ec 0c             	sub    $0xc,%esp
  801bb1:	8b 45 10             	mov    0x10(%ebp),%eax
  801bb4:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801bb9:	39 d0                	cmp    %edx,%eax
  801bbb:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801bbe:	8b 55 08             	mov    0x8(%ebp),%edx
  801bc1:	8b 52 0c             	mov    0xc(%edx),%edx
  801bc4:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801bca:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801bcf:	50                   	push   %eax
  801bd0:	ff 75 0c             	push   0xc(%ebp)
  801bd3:	68 08 60 80 00       	push   $0x806008
  801bd8:	e8 98 f4 ff ff       	call   801075 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801bdd:	ba 00 00 00 00       	mov    $0x0,%edx
  801be2:	b8 04 00 00 00       	mov    $0x4,%eax
  801be7:	e8 cd fe ff ff       	call   801ab9 <fsipc>
}
  801bec:	c9                   	leave  
  801bed:	c3                   	ret    

00801bee <devfile_read>:
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	56                   	push   %esi
  801bf2:	53                   	push   %ebx
  801bf3:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf9:	8b 40 0c             	mov    0xc(%eax),%eax
  801bfc:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801c01:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c07:	ba 00 00 00 00       	mov    $0x0,%edx
  801c0c:	b8 03 00 00 00       	mov    $0x3,%eax
  801c11:	e8 a3 fe ff ff       	call   801ab9 <fsipc>
  801c16:	89 c3                	mov    %eax,%ebx
  801c18:	85 c0                	test   %eax,%eax
  801c1a:	78 1f                	js     801c3b <devfile_read+0x4d>
	assert(r <= n);
  801c1c:	39 f0                	cmp    %esi,%eax
  801c1e:	77 24                	ja     801c44 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801c20:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c25:	7f 33                	jg     801c5a <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c27:	83 ec 04             	sub    $0x4,%esp
  801c2a:	50                   	push   %eax
  801c2b:	68 00 60 80 00       	push   $0x806000
  801c30:	ff 75 0c             	push   0xc(%ebp)
  801c33:	e8 3d f4 ff ff       	call   801075 <memmove>
	return r;
  801c38:	83 c4 10             	add    $0x10,%esp
}
  801c3b:	89 d8                	mov    %ebx,%eax
  801c3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c40:	5b                   	pop    %ebx
  801c41:	5e                   	pop    %esi
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    
	assert(r <= n);
  801c44:	68 3c 32 80 00       	push   $0x80323c
  801c49:	68 43 32 80 00       	push   $0x803243
  801c4e:	6a 7c                	push   $0x7c
  801c50:	68 58 32 80 00       	push   $0x803258
  801c55:	e8 d0 eb ff ff       	call   80082a <_panic>
	assert(r <= PGSIZE);
  801c5a:	68 63 32 80 00       	push   $0x803263
  801c5f:	68 43 32 80 00       	push   $0x803243
  801c64:	6a 7d                	push   $0x7d
  801c66:	68 58 32 80 00       	push   $0x803258
  801c6b:	e8 ba eb ff ff       	call   80082a <_panic>

00801c70 <open>:
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	56                   	push   %esi
  801c74:	53                   	push   %ebx
  801c75:	83 ec 1c             	sub    $0x1c,%esp
  801c78:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801c7b:	56                   	push   %esi
  801c7c:	e8 23 f2 ff ff       	call   800ea4 <strlen>
  801c81:	83 c4 10             	add    $0x10,%esp
  801c84:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c89:	7f 6c                	jg     801cf7 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801c8b:	83 ec 0c             	sub    $0xc,%esp
  801c8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c91:	50                   	push   %eax
  801c92:	e8 bd f8 ff ff       	call   801554 <fd_alloc>
  801c97:	89 c3                	mov    %eax,%ebx
  801c99:	83 c4 10             	add    $0x10,%esp
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	78 3c                	js     801cdc <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801ca0:	83 ec 08             	sub    $0x8,%esp
  801ca3:	56                   	push   %esi
  801ca4:	68 00 60 80 00       	push   $0x806000
  801ca9:	e8 31 f2 ff ff       	call   800edf <strcpy>
	fsipcbuf.open.req_omode = mode;
  801cae:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb1:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801cb6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cb9:	b8 01 00 00 00       	mov    $0x1,%eax
  801cbe:	e8 f6 fd ff ff       	call   801ab9 <fsipc>
  801cc3:	89 c3                	mov    %eax,%ebx
  801cc5:	83 c4 10             	add    $0x10,%esp
  801cc8:	85 c0                	test   %eax,%eax
  801cca:	78 19                	js     801ce5 <open+0x75>
	return fd2num(fd);
  801ccc:	83 ec 0c             	sub    $0xc,%esp
  801ccf:	ff 75 f4             	push   -0xc(%ebp)
  801cd2:	e8 56 f8 ff ff       	call   80152d <fd2num>
  801cd7:	89 c3                	mov    %eax,%ebx
  801cd9:	83 c4 10             	add    $0x10,%esp
}
  801cdc:	89 d8                	mov    %ebx,%eax
  801cde:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce1:	5b                   	pop    %ebx
  801ce2:	5e                   	pop    %esi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    
		fd_close(fd, 0);
  801ce5:	83 ec 08             	sub    $0x8,%esp
  801ce8:	6a 00                	push   $0x0
  801cea:	ff 75 f4             	push   -0xc(%ebp)
  801ced:	e8 58 f9 ff ff       	call   80164a <fd_close>
		return r;
  801cf2:	83 c4 10             	add    $0x10,%esp
  801cf5:	eb e5                	jmp    801cdc <open+0x6c>
		return -E_BAD_PATH;
  801cf7:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801cfc:	eb de                	jmp    801cdc <open+0x6c>

00801cfe <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d04:	ba 00 00 00 00       	mov    $0x0,%edx
  801d09:	b8 08 00 00 00       	mov    $0x8,%eax
  801d0e:	e8 a6 fd ff ff       	call   801ab9 <fsipc>
}
  801d13:	c9                   	leave  
  801d14:	c3                   	ret    

00801d15 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801d1b:	68 6f 32 80 00       	push   $0x80326f
  801d20:	ff 75 0c             	push   0xc(%ebp)
  801d23:	e8 b7 f1 ff ff       	call   800edf <strcpy>
	return 0;
}
  801d28:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2d:	c9                   	leave  
  801d2e:	c3                   	ret    

00801d2f <devsock_close>:
{
  801d2f:	55                   	push   %ebp
  801d30:	89 e5                	mov    %esp,%ebp
  801d32:	53                   	push   %ebx
  801d33:	83 ec 10             	sub    $0x10,%esp
  801d36:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d39:	53                   	push   %ebx
  801d3a:	e8 8b 0c 00 00       	call   8029ca <pageref>
  801d3f:	89 c2                	mov    %eax,%edx
  801d41:	83 c4 10             	add    $0x10,%esp
		return 0;
  801d44:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801d49:	83 fa 01             	cmp    $0x1,%edx
  801d4c:	74 05                	je     801d53 <devsock_close+0x24>
}
  801d4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d51:	c9                   	leave  
  801d52:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801d53:	83 ec 0c             	sub    $0xc,%esp
  801d56:	ff 73 0c             	push   0xc(%ebx)
  801d59:	e8 b7 02 00 00       	call   802015 <nsipc_close>
  801d5e:	83 c4 10             	add    $0x10,%esp
  801d61:	eb eb                	jmp    801d4e <devsock_close+0x1f>

00801d63 <devsock_write>:
{
  801d63:	55                   	push   %ebp
  801d64:	89 e5                	mov    %esp,%ebp
  801d66:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d69:	6a 00                	push   $0x0
  801d6b:	ff 75 10             	push   0x10(%ebp)
  801d6e:	ff 75 0c             	push   0xc(%ebp)
  801d71:	8b 45 08             	mov    0x8(%ebp),%eax
  801d74:	ff 70 0c             	push   0xc(%eax)
  801d77:	e8 79 03 00 00       	call   8020f5 <nsipc_send>
}
  801d7c:	c9                   	leave  
  801d7d:	c3                   	ret    

00801d7e <devsock_read>:
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d84:	6a 00                	push   $0x0
  801d86:	ff 75 10             	push   0x10(%ebp)
  801d89:	ff 75 0c             	push   0xc(%ebp)
  801d8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8f:	ff 70 0c             	push   0xc(%eax)
  801d92:	e8 ef 02 00 00       	call   802086 <nsipc_recv>
}
  801d97:	c9                   	leave  
  801d98:	c3                   	ret    

00801d99 <fd2sockid>:
{
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
  801d9c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d9f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801da2:	52                   	push   %edx
  801da3:	50                   	push   %eax
  801da4:	e8 fb f7 ff ff       	call   8015a4 <fd_lookup>
  801da9:	83 c4 10             	add    $0x10,%esp
  801dac:	85 c0                	test   %eax,%eax
  801dae:	78 10                	js     801dc0 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db3:	8b 0d 40 40 80 00    	mov    0x804040,%ecx
  801db9:	39 08                	cmp    %ecx,(%eax)
  801dbb:	75 05                	jne    801dc2 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801dbd:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801dc0:	c9                   	leave  
  801dc1:	c3                   	ret    
		return -E_NOT_SUPP;
  801dc2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801dc7:	eb f7                	jmp    801dc0 <fd2sockid+0x27>

00801dc9 <alloc_sockfd>:
{
  801dc9:	55                   	push   %ebp
  801dca:	89 e5                	mov    %esp,%ebp
  801dcc:	56                   	push   %esi
  801dcd:	53                   	push   %ebx
  801dce:	83 ec 1c             	sub    $0x1c,%esp
  801dd1:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801dd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd6:	50                   	push   %eax
  801dd7:	e8 78 f7 ff ff       	call   801554 <fd_alloc>
  801ddc:	89 c3                	mov    %eax,%ebx
  801dde:	83 c4 10             	add    $0x10,%esp
  801de1:	85 c0                	test   %eax,%eax
  801de3:	78 43                	js     801e28 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801de5:	83 ec 04             	sub    $0x4,%esp
  801de8:	68 07 04 00 00       	push   $0x407
  801ded:	ff 75 f4             	push   -0xc(%ebp)
  801df0:	6a 00                	push   $0x0
  801df2:	e8 e4 f4 ff ff       	call   8012db <sys_page_alloc>
  801df7:	89 c3                	mov    %eax,%ebx
  801df9:	83 c4 10             	add    $0x10,%esp
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	78 28                	js     801e28 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e03:	8b 15 40 40 80 00    	mov    0x804040,%edx
  801e09:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801e15:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801e18:	83 ec 0c             	sub    $0xc,%esp
  801e1b:	50                   	push   %eax
  801e1c:	e8 0c f7 ff ff       	call   80152d <fd2num>
  801e21:	89 c3                	mov    %eax,%ebx
  801e23:	83 c4 10             	add    $0x10,%esp
  801e26:	eb 0c                	jmp    801e34 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801e28:	83 ec 0c             	sub    $0xc,%esp
  801e2b:	56                   	push   %esi
  801e2c:	e8 e4 01 00 00       	call   802015 <nsipc_close>
		return r;
  801e31:	83 c4 10             	add    $0x10,%esp
}
  801e34:	89 d8                	mov    %ebx,%eax
  801e36:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e39:	5b                   	pop    %ebx
  801e3a:	5e                   	pop    %esi
  801e3b:	5d                   	pop    %ebp
  801e3c:	c3                   	ret    

00801e3d <accept>:
{
  801e3d:	55                   	push   %ebp
  801e3e:	89 e5                	mov    %esp,%ebp
  801e40:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e43:	8b 45 08             	mov    0x8(%ebp),%eax
  801e46:	e8 4e ff ff ff       	call   801d99 <fd2sockid>
  801e4b:	85 c0                	test   %eax,%eax
  801e4d:	78 1b                	js     801e6a <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e4f:	83 ec 04             	sub    $0x4,%esp
  801e52:	ff 75 10             	push   0x10(%ebp)
  801e55:	ff 75 0c             	push   0xc(%ebp)
  801e58:	50                   	push   %eax
  801e59:	e8 0e 01 00 00       	call   801f6c <nsipc_accept>
  801e5e:	83 c4 10             	add    $0x10,%esp
  801e61:	85 c0                	test   %eax,%eax
  801e63:	78 05                	js     801e6a <accept+0x2d>
	return alloc_sockfd(r);
  801e65:	e8 5f ff ff ff       	call   801dc9 <alloc_sockfd>
}
  801e6a:	c9                   	leave  
  801e6b:	c3                   	ret    

00801e6c <bind>:
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e72:	8b 45 08             	mov    0x8(%ebp),%eax
  801e75:	e8 1f ff ff ff       	call   801d99 <fd2sockid>
  801e7a:	85 c0                	test   %eax,%eax
  801e7c:	78 12                	js     801e90 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801e7e:	83 ec 04             	sub    $0x4,%esp
  801e81:	ff 75 10             	push   0x10(%ebp)
  801e84:	ff 75 0c             	push   0xc(%ebp)
  801e87:	50                   	push   %eax
  801e88:	e8 31 01 00 00       	call   801fbe <nsipc_bind>
  801e8d:	83 c4 10             	add    $0x10,%esp
}
  801e90:	c9                   	leave  
  801e91:	c3                   	ret    

00801e92 <shutdown>:
{
  801e92:	55                   	push   %ebp
  801e93:	89 e5                	mov    %esp,%ebp
  801e95:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e98:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9b:	e8 f9 fe ff ff       	call   801d99 <fd2sockid>
  801ea0:	85 c0                	test   %eax,%eax
  801ea2:	78 0f                	js     801eb3 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801ea4:	83 ec 08             	sub    $0x8,%esp
  801ea7:	ff 75 0c             	push   0xc(%ebp)
  801eaa:	50                   	push   %eax
  801eab:	e8 43 01 00 00       	call   801ff3 <nsipc_shutdown>
  801eb0:	83 c4 10             	add    $0x10,%esp
}
  801eb3:	c9                   	leave  
  801eb4:	c3                   	ret    

00801eb5 <connect>:
{
  801eb5:	55                   	push   %ebp
  801eb6:	89 e5                	mov    %esp,%ebp
  801eb8:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebe:	e8 d6 fe ff ff       	call   801d99 <fd2sockid>
  801ec3:	85 c0                	test   %eax,%eax
  801ec5:	78 12                	js     801ed9 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801ec7:	83 ec 04             	sub    $0x4,%esp
  801eca:	ff 75 10             	push   0x10(%ebp)
  801ecd:	ff 75 0c             	push   0xc(%ebp)
  801ed0:	50                   	push   %eax
  801ed1:	e8 59 01 00 00       	call   80202f <nsipc_connect>
  801ed6:	83 c4 10             	add    $0x10,%esp
}
  801ed9:	c9                   	leave  
  801eda:	c3                   	ret    

00801edb <listen>:
{
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
  801ede:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ee1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee4:	e8 b0 fe ff ff       	call   801d99 <fd2sockid>
  801ee9:	85 c0                	test   %eax,%eax
  801eeb:	78 0f                	js     801efc <listen+0x21>
	return nsipc_listen(r, backlog);
  801eed:	83 ec 08             	sub    $0x8,%esp
  801ef0:	ff 75 0c             	push   0xc(%ebp)
  801ef3:	50                   	push   %eax
  801ef4:	e8 6b 01 00 00       	call   802064 <nsipc_listen>
  801ef9:	83 c4 10             	add    $0x10,%esp
}
  801efc:	c9                   	leave  
  801efd:	c3                   	ret    

00801efe <socket>:

int
socket(int domain, int type, int protocol)
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f04:	ff 75 10             	push   0x10(%ebp)
  801f07:	ff 75 0c             	push   0xc(%ebp)
  801f0a:	ff 75 08             	push   0x8(%ebp)
  801f0d:	e8 41 02 00 00       	call   802153 <nsipc_socket>
  801f12:	83 c4 10             	add    $0x10,%esp
  801f15:	85 c0                	test   %eax,%eax
  801f17:	78 05                	js     801f1e <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801f19:	e8 ab fe ff ff       	call   801dc9 <alloc_sockfd>
}
  801f1e:	c9                   	leave  
  801f1f:	c3                   	ret    

00801f20 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f20:	55                   	push   %ebp
  801f21:	89 e5                	mov    %esp,%ebp
  801f23:	53                   	push   %ebx
  801f24:	83 ec 04             	sub    $0x4,%esp
  801f27:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801f29:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  801f30:	74 26                	je     801f58 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f32:	6a 07                	push   $0x7
  801f34:	68 00 80 80 00       	push   $0x808000
  801f39:	53                   	push   %ebx
  801f3a:	ff 35 00 90 80 00    	push   0x809000
  801f40:	e8 f2 09 00 00       	call   802937 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f45:	83 c4 0c             	add    $0xc,%esp
  801f48:	6a 00                	push   $0x0
  801f4a:	6a 00                	push   $0x0
  801f4c:	6a 00                	push   $0x0
  801f4e:	e8 74 09 00 00       	call   8028c7 <ipc_recv>
}
  801f53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f56:	c9                   	leave  
  801f57:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f58:	83 ec 0c             	sub    $0xc,%esp
  801f5b:	6a 02                	push   $0x2
  801f5d:	e8 29 0a 00 00       	call   80298b <ipc_find_env>
  801f62:	a3 00 90 80 00       	mov    %eax,0x809000
  801f67:	83 c4 10             	add    $0x10,%esp
  801f6a:	eb c6                	jmp    801f32 <nsipc+0x12>

00801f6c <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	56                   	push   %esi
  801f70:	53                   	push   %ebx
  801f71:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f74:	8b 45 08             	mov    0x8(%ebp),%eax
  801f77:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f7c:	8b 06                	mov    (%esi),%eax
  801f7e:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f83:	b8 01 00 00 00       	mov    $0x1,%eax
  801f88:	e8 93 ff ff ff       	call   801f20 <nsipc>
  801f8d:	89 c3                	mov    %eax,%ebx
  801f8f:	85 c0                	test   %eax,%eax
  801f91:	79 09                	jns    801f9c <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801f93:	89 d8                	mov    %ebx,%eax
  801f95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f98:	5b                   	pop    %ebx
  801f99:	5e                   	pop    %esi
  801f9a:	5d                   	pop    %ebp
  801f9b:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f9c:	83 ec 04             	sub    $0x4,%esp
  801f9f:	ff 35 10 80 80 00    	push   0x808010
  801fa5:	68 00 80 80 00       	push   $0x808000
  801faa:	ff 75 0c             	push   0xc(%ebp)
  801fad:	e8 c3 f0 ff ff       	call   801075 <memmove>
		*addrlen = ret->ret_addrlen;
  801fb2:	a1 10 80 80 00       	mov    0x808010,%eax
  801fb7:	89 06                	mov    %eax,(%esi)
  801fb9:	83 c4 10             	add    $0x10,%esp
	return r;
  801fbc:	eb d5                	jmp    801f93 <nsipc_accept+0x27>

00801fbe <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801fbe:	55                   	push   %ebp
  801fbf:	89 e5                	mov    %esp,%ebp
  801fc1:	53                   	push   %ebx
  801fc2:	83 ec 08             	sub    $0x8,%esp
  801fc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801fc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801fcb:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801fd0:	53                   	push   %ebx
  801fd1:	ff 75 0c             	push   0xc(%ebp)
  801fd4:	68 04 80 80 00       	push   $0x808004
  801fd9:	e8 97 f0 ff ff       	call   801075 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801fde:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  801fe4:	b8 02 00 00 00       	mov    $0x2,%eax
  801fe9:	e8 32 ff ff ff       	call   801f20 <nsipc>
}
  801fee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ff1:	c9                   	leave  
  801ff2:	c3                   	ret    

00801ff3 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ff3:	55                   	push   %ebp
  801ff4:	89 e5                	mov    %esp,%ebp
  801ff6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ff9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ffc:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  802001:	8b 45 0c             	mov    0xc(%ebp),%eax
  802004:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  802009:	b8 03 00 00 00       	mov    $0x3,%eax
  80200e:	e8 0d ff ff ff       	call   801f20 <nsipc>
}
  802013:	c9                   	leave  
  802014:	c3                   	ret    

00802015 <nsipc_close>:

int
nsipc_close(int s)
{
  802015:	55                   	push   %ebp
  802016:	89 e5                	mov    %esp,%ebp
  802018:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80201b:	8b 45 08             	mov    0x8(%ebp),%eax
  80201e:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  802023:	b8 04 00 00 00       	mov    $0x4,%eax
  802028:	e8 f3 fe ff ff       	call   801f20 <nsipc>
}
  80202d:	c9                   	leave  
  80202e:	c3                   	ret    

0080202f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80202f:	55                   	push   %ebp
  802030:	89 e5                	mov    %esp,%ebp
  802032:	53                   	push   %ebx
  802033:	83 ec 08             	sub    $0x8,%esp
  802036:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802039:	8b 45 08             	mov    0x8(%ebp),%eax
  80203c:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802041:	53                   	push   %ebx
  802042:	ff 75 0c             	push   0xc(%ebp)
  802045:	68 04 80 80 00       	push   $0x808004
  80204a:	e8 26 f0 ff ff       	call   801075 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80204f:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  802055:	b8 05 00 00 00       	mov    $0x5,%eax
  80205a:	e8 c1 fe ff ff       	call   801f20 <nsipc>
}
  80205f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802062:	c9                   	leave  
  802063:	c3                   	ret    

00802064 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802064:	55                   	push   %ebp
  802065:	89 e5                	mov    %esp,%ebp
  802067:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80206a:	8b 45 08             	mov    0x8(%ebp),%eax
  80206d:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  802072:	8b 45 0c             	mov    0xc(%ebp),%eax
  802075:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  80207a:	b8 06 00 00 00       	mov    $0x6,%eax
  80207f:	e8 9c fe ff ff       	call   801f20 <nsipc>
}
  802084:	c9                   	leave  
  802085:	c3                   	ret    

00802086 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
  802089:	56                   	push   %esi
  80208a:	53                   	push   %ebx
  80208b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80208e:	8b 45 08             	mov    0x8(%ebp),%eax
  802091:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  802096:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  80209c:	8b 45 14             	mov    0x14(%ebp),%eax
  80209f:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8020a4:	b8 07 00 00 00       	mov    $0x7,%eax
  8020a9:	e8 72 fe ff ff       	call   801f20 <nsipc>
  8020ae:	89 c3                	mov    %eax,%ebx
  8020b0:	85 c0                	test   %eax,%eax
  8020b2:	78 22                	js     8020d6 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  8020b4:	b8 3f 06 00 00       	mov    $0x63f,%eax
  8020b9:	39 c6                	cmp    %eax,%esi
  8020bb:	0f 4e c6             	cmovle %esi,%eax
  8020be:	39 c3                	cmp    %eax,%ebx
  8020c0:	7f 1d                	jg     8020df <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8020c2:	83 ec 04             	sub    $0x4,%esp
  8020c5:	53                   	push   %ebx
  8020c6:	68 00 80 80 00       	push   $0x808000
  8020cb:	ff 75 0c             	push   0xc(%ebp)
  8020ce:	e8 a2 ef ff ff       	call   801075 <memmove>
  8020d3:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8020d6:	89 d8                	mov    %ebx,%eax
  8020d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020db:	5b                   	pop    %ebx
  8020dc:	5e                   	pop    %esi
  8020dd:	5d                   	pop    %ebp
  8020de:	c3                   	ret    
		assert(r < 1600 && r <= len);
  8020df:	68 7b 32 80 00       	push   $0x80327b
  8020e4:	68 43 32 80 00       	push   $0x803243
  8020e9:	6a 62                	push   $0x62
  8020eb:	68 90 32 80 00       	push   $0x803290
  8020f0:	e8 35 e7 ff ff       	call   80082a <_panic>

008020f5 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8020f5:	55                   	push   %ebp
  8020f6:	89 e5                	mov    %esp,%ebp
  8020f8:	53                   	push   %ebx
  8020f9:	83 ec 04             	sub    $0x4,%esp
  8020fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8020ff:	8b 45 08             	mov    0x8(%ebp),%eax
  802102:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  802107:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80210d:	7f 2e                	jg     80213d <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80210f:	83 ec 04             	sub    $0x4,%esp
  802112:	53                   	push   %ebx
  802113:	ff 75 0c             	push   0xc(%ebp)
  802116:	68 0c 80 80 00       	push   $0x80800c
  80211b:	e8 55 ef ff ff       	call   801075 <memmove>
	nsipcbuf.send.req_size = size;
  802120:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  802126:	8b 45 14             	mov    0x14(%ebp),%eax
  802129:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  80212e:	b8 08 00 00 00       	mov    $0x8,%eax
  802133:	e8 e8 fd ff ff       	call   801f20 <nsipc>
}
  802138:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80213b:	c9                   	leave  
  80213c:	c3                   	ret    
	assert(size < 1600);
  80213d:	68 9c 32 80 00       	push   $0x80329c
  802142:	68 43 32 80 00       	push   $0x803243
  802147:	6a 6d                	push   $0x6d
  802149:	68 90 32 80 00       	push   $0x803290
  80214e:	e8 d7 e6 ff ff       	call   80082a <_panic>

00802153 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802153:	55                   	push   %ebp
  802154:	89 e5                	mov    %esp,%ebp
  802156:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802159:	8b 45 08             	mov    0x8(%ebp),%eax
  80215c:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  802161:	8b 45 0c             	mov    0xc(%ebp),%eax
  802164:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  802169:	8b 45 10             	mov    0x10(%ebp),%eax
  80216c:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  802171:	b8 09 00 00 00       	mov    $0x9,%eax
  802176:	e8 a5 fd ff ff       	call   801f20 <nsipc>
}
  80217b:	c9                   	leave  
  80217c:	c3                   	ret    

0080217d <free>:
	return v;
}

void
free(void *v)
{
  80217d:	55                   	push   %ebp
  80217e:	89 e5                	mov    %esp,%ebp
  802180:	53                   	push   %ebx
  802181:	83 ec 04             	sub    $0x4,%esp
  802184:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint8_t *c;
	uint32_t *ref;

	if (v == 0)
  802187:	85 db                	test   %ebx,%ebx
  802189:	0f 84 85 00 00 00    	je     802214 <free+0x97>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);
  80218f:	8d 83 00 00 00 f8    	lea    -0x8000000(%ebx),%eax
  802195:	3d ff ff ff 07       	cmp    $0x7ffffff,%eax
  80219a:	77 51                	ja     8021ed <free+0x70>

	c = ROUNDDOWN(v, PGSIZE);
  80219c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  8021a2:	89 d8                	mov    %ebx,%eax
  8021a4:	c1 e8 0c             	shr    $0xc,%eax
  8021a7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8021ae:	f6 c4 02             	test   $0x2,%ah
  8021b1:	74 50                	je     802203 <free+0x86>
		sys_page_unmap(0, c);
  8021b3:	83 ec 08             	sub    $0x8,%esp
  8021b6:	53                   	push   %ebx
  8021b7:	6a 00                	push   $0x0
  8021b9:	e8 a2 f1 ff ff       	call   801360 <sys_page_unmap>
		c += PGSIZE;
  8021be:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(mbegin <= c && c < mend);
  8021c4:	8d 83 00 00 00 f8    	lea    -0x8000000(%ebx),%eax
  8021ca:	83 c4 10             	add    $0x10,%esp
  8021cd:	3d ff ff ff 07       	cmp    $0x7ffffff,%eax
  8021d2:	76 ce                	jbe    8021a2 <free+0x25>
  8021d4:	68 e3 32 80 00       	push   $0x8032e3
  8021d9:	68 43 32 80 00       	push   $0x803243
  8021de:	68 81 00 00 00       	push   $0x81
  8021e3:	68 d6 32 80 00       	push   $0x8032d6
  8021e8:	e8 3d e6 ff ff       	call   80082a <_panic>
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);
  8021ed:	68 a8 32 80 00       	push   $0x8032a8
  8021f2:	68 43 32 80 00       	push   $0x803243
  8021f7:	6a 7a                	push   $0x7a
  8021f9:	68 d6 32 80 00       	push   $0x8032d6
  8021fe:	e8 27 e6 ff ff       	call   80082a <_panic>
	/*
	 * c is just a piece of this page, so dec the ref count
	 * and maybe free the page.
	 */
	ref = (uint32_t*) (c + PGSIZE - 4);
	if (--(*ref) == 0)
  802203:	8b 83 fc 0f 00 00    	mov    0xffc(%ebx),%eax
  802209:	83 e8 01             	sub    $0x1,%eax
  80220c:	89 83 fc 0f 00 00    	mov    %eax,0xffc(%ebx)
  802212:	74 05                	je     802219 <free+0x9c>
		sys_page_unmap(0, c);
}
  802214:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802217:	c9                   	leave  
  802218:	c3                   	ret    
		sys_page_unmap(0, c);
  802219:	83 ec 08             	sub    $0x8,%esp
  80221c:	53                   	push   %ebx
  80221d:	6a 00                	push   $0x0
  80221f:	e8 3c f1 ff ff       	call   801360 <sys_page_unmap>
  802224:	83 c4 10             	add    $0x10,%esp
  802227:	eb eb                	jmp    802214 <free+0x97>

00802229 <malloc>:
{
  802229:	55                   	push   %ebp
  80222a:	89 e5                	mov    %esp,%ebp
  80222c:	57                   	push   %edi
  80222d:	56                   	push   %esi
  80222e:	53                   	push   %ebx
  80222f:	83 ec 1c             	sub    $0x1c,%esp
	if (mptr == 0)
  802232:	a1 04 90 80 00       	mov    0x809004,%eax
  802237:	85 c0                	test   %eax,%eax
  802239:	74 72                	je     8022ad <malloc+0x84>
	n = ROUNDUP(n, 4);
  80223b:	8b 75 08             	mov    0x8(%ebp),%esi
  80223e:	8d 56 03             	lea    0x3(%esi),%edx
  802241:	83 e2 fc             	and    $0xfffffffc,%edx
  802244:	89 d7                	mov    %edx,%edi
  802246:	89 55 e0             	mov    %edx,-0x20(%ebp)
	if (n >= MAXMALLOC)
  802249:	81 fa ff ff 0f 00    	cmp    $0xfffff,%edx
  80224f:	0f 87 3f 01 00 00    	ja     802394 <malloc+0x16b>
	if ((uintptr_t) mptr % PGSIZE){
  802255:	a9 ff 0f 00 00       	test   $0xfff,%eax
  80225a:	74 30                	je     80228c <malloc+0x63>
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
  80225c:	89 c3                	mov    %eax,%ebx
  80225e:	c1 eb 0c             	shr    $0xc,%ebx
  802261:	8d 54 10 03          	lea    0x3(%eax,%edx,1),%edx
  802265:	c1 ea 0c             	shr    $0xc,%edx
  802268:	39 d3                	cmp    %edx,%ebx
  80226a:	74 64                	je     8022d0 <malloc+0xa7>
		free(mptr);	/* drop reference to this page */
  80226c:	83 ec 0c             	sub    $0xc,%esp
  80226f:	50                   	push   %eax
  802270:	e8 08 ff ff ff       	call   80217d <free>
		mptr = ROUNDDOWN(mptr + PGSIZE, PGSIZE);
  802275:	a1 04 90 80 00       	mov    0x809004,%eax
  80227a:	05 00 10 00 00       	add    $0x1000,%eax
  80227f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802284:	a3 04 90 80 00       	mov    %eax,0x809004
  802289:	83 c4 10             	add    $0x10,%esp
  80228c:	8b 0d 04 90 80 00    	mov    0x809004,%ecx
{
  802292:	c7 45 dc 02 00 00 00 	movl   $0x2,-0x24(%ebp)
  802299:	be 00 00 00 00       	mov    $0x0,%esi
  80229e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022a1:	8d 78 04             	lea    0x4(%eax),%edi
  8022a4:	89 cb                	mov    %ecx,%ebx
  8022a6:	01 f9                	add    %edi,%ecx
  8022a8:	e9 91 00 00 00       	jmp    80233e <malloc+0x115>
		mptr = mbegin;
  8022ad:	c7 05 04 90 80 00 00 	movl   $0x8000000,0x809004
  8022b4:	00 00 08 
	n = ROUNDUP(n, 4);
  8022b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8022ba:	8d 56 03             	lea    0x3(%esi),%edx
  8022bd:	83 e2 fc             	and    $0xfffffffc,%edx
  8022c0:	89 55 e0             	mov    %edx,-0x20(%ebp)
	if (n >= MAXMALLOC)
  8022c3:	81 fa ff ff 0f 00    	cmp    $0xfffff,%edx
  8022c9:	76 c1                	jbe    80228c <malloc+0x63>
  8022cb:	e9 31 01 00 00       	jmp    802401 <malloc+0x1d8>
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
  8022d0:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  8022d6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
			(*ref)++;
  8022dc:	83 42 fc 01          	addl   $0x1,-0x4(%edx)
			mptr += n;
  8022e0:	89 fa                	mov    %edi,%edx
  8022e2:	01 c2                	add    %eax,%edx
  8022e4:	89 15 04 90 80 00    	mov    %edx,0x809004
			return v;
  8022ea:	e9 12 01 00 00       	jmp    802401 <malloc+0x1d8>
	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  8022ef:	05 00 10 00 00       	add    $0x1000,%eax
  8022f4:	39 c8                	cmp    %ecx,%eax
  8022f6:	0f 83 9f 00 00 00    	jae    80239b <malloc+0x172>
		if (va >= (uintptr_t) mend
  8022fc:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
  802301:	77 22                	ja     802325 <malloc+0xfc>
		    || ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)))
  802303:	89 c2                	mov    %eax,%edx
  802305:	c1 ea 16             	shr    $0x16,%edx
  802308:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80230f:	f6 c2 01             	test   $0x1,%dl
  802312:	74 db                	je     8022ef <malloc+0xc6>
  802314:	89 c2                	mov    %eax,%edx
  802316:	c1 ea 0c             	shr    $0xc,%edx
  802319:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802320:	f6 c2 01             	test   $0x1,%dl
  802323:	74 ca                	je     8022ef <malloc+0xc6>
		if (mptr == mend) {
  802325:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80232b:	81 c1 00 10 00 00    	add    $0x1000,%ecx
  802331:	be 01 00 00 00       	mov    $0x1,%esi
  802336:	81 fb 00 00 00 10    	cmp    $0x10000000,%ebx
  80233c:	74 07                	je     802345 <malloc+0x11c>
  80233e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  802341:	89 d8                	mov    %ebx,%eax
  802343:	eb af                	jmp    8022f4 <malloc+0xcb>
			mptr = mbegin;
  802345:	b9 00 00 00 08       	mov    $0x8000000,%ecx
			if (++nwrap == 2)
  80234a:	83 6d dc 01          	subl   $0x1,-0x24(%ebp)
  80234e:	0f 85 50 ff ff ff    	jne    8022a4 <malloc+0x7b>
  802354:	c7 05 04 90 80 00 00 	movl   $0x8000000,0x809004
  80235b:	00 00 08 
				return 0;	/* out of address space */
  80235e:	b8 00 00 00 00       	mov    $0x0,%eax
  802363:	e9 99 00 00 00       	jmp    802401 <malloc+0x1d8>
  802368:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80236b:	eb 1c                	jmp    802389 <malloc+0x160>
				sys_page_unmap(0, mptr + i);
  80236d:	83 ec 08             	sub    $0x8,%esp
  802370:	89 f0                	mov    %esi,%eax
  802372:	03 05 04 90 80 00    	add    0x809004,%eax
  802378:	50                   	push   %eax
  802379:	6a 00                	push   $0x0
  80237b:	e8 e0 ef ff ff       	call   801360 <sys_page_unmap>
			for (; i >= 0; i -= PGSIZE)
  802380:	81 ee 00 10 00 00    	sub    $0x1000,%esi
  802386:	83 c4 10             	add    $0x10,%esp
  802389:	85 f6                	test   %esi,%esi
  80238b:	79 e0                	jns    80236d <malloc+0x144>
			return 0;	/* out of physical memory */
  80238d:	b8 00 00 00 00       	mov    $0x0,%eax
  802392:	eb 6d                	jmp    802401 <malloc+0x1d8>
		return 0;
  802394:	b8 00 00 00 00       	mov    $0x0,%eax
  802399:	eb 66                	jmp    802401 <malloc+0x1d8>
  80239b:	89 f0                	mov    %esi,%eax
  80239d:	84 c0                	test   %al,%al
  80239f:	74 08                	je     8023a9 <malloc+0x180>
  8023a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023a4:	a3 04 90 80 00       	mov    %eax,0x809004
	for (i = 0; i < n + 4; i += PGSIZE){
  8023a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8023ae:	89 de                	mov    %ebx,%esi
  8023b0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  8023b3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
  8023b9:	83 ec 04             	sub    $0x4,%esp
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  8023bc:	39 fb                	cmp    %edi,%ebx
  8023be:	0f 92 c0             	setb   %al
  8023c1:	0f b6 c0             	movzbl %al,%eax
  8023c4:	c1 e0 09             	shl    $0x9,%eax
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
  8023c7:	83 c8 07             	or     $0x7,%eax
  8023ca:	50                   	push   %eax
  8023cb:	89 f0                	mov    %esi,%eax
  8023cd:	03 05 04 90 80 00    	add    0x809004,%eax
  8023d3:	50                   	push   %eax
  8023d4:	6a 00                	push   $0x0
  8023d6:	e8 00 ef ff ff       	call   8012db <sys_page_alloc>
  8023db:	83 c4 10             	add    $0x10,%esp
  8023de:	85 c0                	test   %eax,%eax
  8023e0:	78 86                	js     802368 <malloc+0x13f>
	for (i = 0; i < n + 4; i += PGSIZE){
  8023e2:	39 fb                	cmp    %edi,%ebx
  8023e4:	72 c8                	jb     8023ae <malloc+0x185>
	ref = (uint32_t*) (mptr + i - 4);
  8023e6:	a1 04 90 80 00       	mov    0x809004,%eax
	*ref = 2;	/* reference for mptr, reference for returned block */
  8023eb:	c7 84 30 fc 0f 00 00 	movl   $0x2,0xffc(%eax,%esi,1)
  8023f2:	02 00 00 00 
	mptr += n;
  8023f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8023f9:	01 c2                	add    %eax,%edx
  8023fb:	89 15 04 90 80 00    	mov    %edx,0x809004
}
  802401:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802404:	5b                   	pop    %ebx
  802405:	5e                   	pop    %esi
  802406:	5f                   	pop    %edi
  802407:	5d                   	pop    %ebp
  802408:	c3                   	ret    

00802409 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802409:	55                   	push   %ebp
  80240a:	89 e5                	mov    %esp,%ebp
  80240c:	56                   	push   %esi
  80240d:	53                   	push   %ebx
  80240e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802411:	83 ec 0c             	sub    $0xc,%esp
  802414:	ff 75 08             	push   0x8(%ebp)
  802417:	e8 21 f1 ff ff       	call   80153d <fd2data>
  80241c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80241e:	83 c4 08             	add    $0x8,%esp
  802421:	68 fb 32 80 00       	push   $0x8032fb
  802426:	53                   	push   %ebx
  802427:	e8 b3 ea ff ff       	call   800edf <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80242c:	8b 46 04             	mov    0x4(%esi),%eax
  80242f:	2b 06                	sub    (%esi),%eax
  802431:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802437:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80243e:	00 00 00 
	stat->st_dev = &devpipe;
  802441:	c7 83 88 00 00 00 5c 	movl   $0x80405c,0x88(%ebx)
  802448:	40 80 00 
	return 0;
}
  80244b:	b8 00 00 00 00       	mov    $0x0,%eax
  802450:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802453:	5b                   	pop    %ebx
  802454:	5e                   	pop    %esi
  802455:	5d                   	pop    %ebp
  802456:	c3                   	ret    

00802457 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802457:	55                   	push   %ebp
  802458:	89 e5                	mov    %esp,%ebp
  80245a:	53                   	push   %ebx
  80245b:	83 ec 0c             	sub    $0xc,%esp
  80245e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802461:	53                   	push   %ebx
  802462:	6a 00                	push   $0x0
  802464:	e8 f7 ee ff ff       	call   801360 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802469:	89 1c 24             	mov    %ebx,(%esp)
  80246c:	e8 cc f0 ff ff       	call   80153d <fd2data>
  802471:	83 c4 08             	add    $0x8,%esp
  802474:	50                   	push   %eax
  802475:	6a 00                	push   $0x0
  802477:	e8 e4 ee ff ff       	call   801360 <sys_page_unmap>
}
  80247c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80247f:	c9                   	leave  
  802480:	c3                   	ret    

00802481 <_pipeisclosed>:
{
  802481:	55                   	push   %ebp
  802482:	89 e5                	mov    %esp,%ebp
  802484:	57                   	push   %edi
  802485:	56                   	push   %esi
  802486:	53                   	push   %ebx
  802487:	83 ec 1c             	sub    $0x1c,%esp
  80248a:	89 c7                	mov    %eax,%edi
  80248c:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80248e:	a1 10 50 80 00       	mov    0x805010,%eax
  802493:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802496:	83 ec 0c             	sub    $0xc,%esp
  802499:	57                   	push   %edi
  80249a:	e8 2b 05 00 00       	call   8029ca <pageref>
  80249f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8024a2:	89 34 24             	mov    %esi,(%esp)
  8024a5:	e8 20 05 00 00       	call   8029ca <pageref>
		nn = thisenv->env_runs;
  8024aa:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8024b0:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  8024b3:	83 c4 10             	add    $0x10,%esp
  8024b6:	39 cb                	cmp    %ecx,%ebx
  8024b8:	74 1b                	je     8024d5 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8024ba:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8024bd:	75 cf                	jne    80248e <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8024bf:	8b 42 68             	mov    0x68(%edx),%eax
  8024c2:	6a 01                	push   $0x1
  8024c4:	50                   	push   %eax
  8024c5:	53                   	push   %ebx
  8024c6:	68 02 33 80 00       	push   $0x803302
  8024cb:	e8 35 e4 ff ff       	call   800905 <cprintf>
  8024d0:	83 c4 10             	add    $0x10,%esp
  8024d3:	eb b9                	jmp    80248e <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8024d5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8024d8:	0f 94 c0             	sete   %al
  8024db:	0f b6 c0             	movzbl %al,%eax
}
  8024de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024e1:	5b                   	pop    %ebx
  8024e2:	5e                   	pop    %esi
  8024e3:	5f                   	pop    %edi
  8024e4:	5d                   	pop    %ebp
  8024e5:	c3                   	ret    

008024e6 <devpipe_write>:
{
  8024e6:	55                   	push   %ebp
  8024e7:	89 e5                	mov    %esp,%ebp
  8024e9:	57                   	push   %edi
  8024ea:	56                   	push   %esi
  8024eb:	53                   	push   %ebx
  8024ec:	83 ec 28             	sub    $0x28,%esp
  8024ef:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8024f2:	56                   	push   %esi
  8024f3:	e8 45 f0 ff ff       	call   80153d <fd2data>
  8024f8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8024fa:	83 c4 10             	add    $0x10,%esp
  8024fd:	bf 00 00 00 00       	mov    $0x0,%edi
  802502:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802505:	75 09                	jne    802510 <devpipe_write+0x2a>
	return i;
  802507:	89 f8                	mov    %edi,%eax
  802509:	eb 23                	jmp    80252e <devpipe_write+0x48>
			sys_yield();
  80250b:	e8 ac ed ff ff       	call   8012bc <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802510:	8b 43 04             	mov    0x4(%ebx),%eax
  802513:	8b 0b                	mov    (%ebx),%ecx
  802515:	8d 51 20             	lea    0x20(%ecx),%edx
  802518:	39 d0                	cmp    %edx,%eax
  80251a:	72 1a                	jb     802536 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80251c:	89 da                	mov    %ebx,%edx
  80251e:	89 f0                	mov    %esi,%eax
  802520:	e8 5c ff ff ff       	call   802481 <_pipeisclosed>
  802525:	85 c0                	test   %eax,%eax
  802527:	74 e2                	je     80250b <devpipe_write+0x25>
				return 0;
  802529:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80252e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802531:	5b                   	pop    %ebx
  802532:	5e                   	pop    %esi
  802533:	5f                   	pop    %edi
  802534:	5d                   	pop    %ebp
  802535:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802536:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802539:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80253d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802540:	89 c2                	mov    %eax,%edx
  802542:	c1 fa 1f             	sar    $0x1f,%edx
  802545:	89 d1                	mov    %edx,%ecx
  802547:	c1 e9 1b             	shr    $0x1b,%ecx
  80254a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80254d:	83 e2 1f             	and    $0x1f,%edx
  802550:	29 ca                	sub    %ecx,%edx
  802552:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802556:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80255a:	83 c0 01             	add    $0x1,%eax
  80255d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802560:	83 c7 01             	add    $0x1,%edi
  802563:	eb 9d                	jmp    802502 <devpipe_write+0x1c>

00802565 <devpipe_read>:
{
  802565:	55                   	push   %ebp
  802566:	89 e5                	mov    %esp,%ebp
  802568:	57                   	push   %edi
  802569:	56                   	push   %esi
  80256a:	53                   	push   %ebx
  80256b:	83 ec 18             	sub    $0x18,%esp
  80256e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802571:	57                   	push   %edi
  802572:	e8 c6 ef ff ff       	call   80153d <fd2data>
  802577:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802579:	83 c4 10             	add    $0x10,%esp
  80257c:	be 00 00 00 00       	mov    $0x0,%esi
  802581:	3b 75 10             	cmp    0x10(%ebp),%esi
  802584:	75 13                	jne    802599 <devpipe_read+0x34>
	return i;
  802586:	89 f0                	mov    %esi,%eax
  802588:	eb 02                	jmp    80258c <devpipe_read+0x27>
				return i;
  80258a:	89 f0                	mov    %esi,%eax
}
  80258c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80258f:	5b                   	pop    %ebx
  802590:	5e                   	pop    %esi
  802591:	5f                   	pop    %edi
  802592:	5d                   	pop    %ebp
  802593:	c3                   	ret    
			sys_yield();
  802594:	e8 23 ed ff ff       	call   8012bc <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802599:	8b 03                	mov    (%ebx),%eax
  80259b:	3b 43 04             	cmp    0x4(%ebx),%eax
  80259e:	75 18                	jne    8025b8 <devpipe_read+0x53>
			if (i > 0)
  8025a0:	85 f6                	test   %esi,%esi
  8025a2:	75 e6                	jne    80258a <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8025a4:	89 da                	mov    %ebx,%edx
  8025a6:	89 f8                	mov    %edi,%eax
  8025a8:	e8 d4 fe ff ff       	call   802481 <_pipeisclosed>
  8025ad:	85 c0                	test   %eax,%eax
  8025af:	74 e3                	je     802594 <devpipe_read+0x2f>
				return 0;
  8025b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8025b6:	eb d4                	jmp    80258c <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8025b8:	99                   	cltd   
  8025b9:	c1 ea 1b             	shr    $0x1b,%edx
  8025bc:	01 d0                	add    %edx,%eax
  8025be:	83 e0 1f             	and    $0x1f,%eax
  8025c1:	29 d0                	sub    %edx,%eax
  8025c3:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8025c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025cb:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8025ce:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8025d1:	83 c6 01             	add    $0x1,%esi
  8025d4:	eb ab                	jmp    802581 <devpipe_read+0x1c>

008025d6 <pipe>:
{
  8025d6:	55                   	push   %ebp
  8025d7:	89 e5                	mov    %esp,%ebp
  8025d9:	56                   	push   %esi
  8025da:	53                   	push   %ebx
  8025db:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8025de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025e1:	50                   	push   %eax
  8025e2:	e8 6d ef ff ff       	call   801554 <fd_alloc>
  8025e7:	89 c3                	mov    %eax,%ebx
  8025e9:	83 c4 10             	add    $0x10,%esp
  8025ec:	85 c0                	test   %eax,%eax
  8025ee:	0f 88 23 01 00 00    	js     802717 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025f4:	83 ec 04             	sub    $0x4,%esp
  8025f7:	68 07 04 00 00       	push   $0x407
  8025fc:	ff 75 f4             	push   -0xc(%ebp)
  8025ff:	6a 00                	push   $0x0
  802601:	e8 d5 ec ff ff       	call   8012db <sys_page_alloc>
  802606:	89 c3                	mov    %eax,%ebx
  802608:	83 c4 10             	add    $0x10,%esp
  80260b:	85 c0                	test   %eax,%eax
  80260d:	0f 88 04 01 00 00    	js     802717 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802613:	83 ec 0c             	sub    $0xc,%esp
  802616:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802619:	50                   	push   %eax
  80261a:	e8 35 ef ff ff       	call   801554 <fd_alloc>
  80261f:	89 c3                	mov    %eax,%ebx
  802621:	83 c4 10             	add    $0x10,%esp
  802624:	85 c0                	test   %eax,%eax
  802626:	0f 88 db 00 00 00    	js     802707 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80262c:	83 ec 04             	sub    $0x4,%esp
  80262f:	68 07 04 00 00       	push   $0x407
  802634:	ff 75 f0             	push   -0x10(%ebp)
  802637:	6a 00                	push   $0x0
  802639:	e8 9d ec ff ff       	call   8012db <sys_page_alloc>
  80263e:	89 c3                	mov    %eax,%ebx
  802640:	83 c4 10             	add    $0x10,%esp
  802643:	85 c0                	test   %eax,%eax
  802645:	0f 88 bc 00 00 00    	js     802707 <pipe+0x131>
	va = fd2data(fd0);
  80264b:	83 ec 0c             	sub    $0xc,%esp
  80264e:	ff 75 f4             	push   -0xc(%ebp)
  802651:	e8 e7 ee ff ff       	call   80153d <fd2data>
  802656:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802658:	83 c4 0c             	add    $0xc,%esp
  80265b:	68 07 04 00 00       	push   $0x407
  802660:	50                   	push   %eax
  802661:	6a 00                	push   $0x0
  802663:	e8 73 ec ff ff       	call   8012db <sys_page_alloc>
  802668:	89 c3                	mov    %eax,%ebx
  80266a:	83 c4 10             	add    $0x10,%esp
  80266d:	85 c0                	test   %eax,%eax
  80266f:	0f 88 82 00 00 00    	js     8026f7 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802675:	83 ec 0c             	sub    $0xc,%esp
  802678:	ff 75 f0             	push   -0x10(%ebp)
  80267b:	e8 bd ee ff ff       	call   80153d <fd2data>
  802680:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802687:	50                   	push   %eax
  802688:	6a 00                	push   $0x0
  80268a:	56                   	push   %esi
  80268b:	6a 00                	push   $0x0
  80268d:	e8 8c ec ff ff       	call   80131e <sys_page_map>
  802692:	89 c3                	mov    %eax,%ebx
  802694:	83 c4 20             	add    $0x20,%esp
  802697:	85 c0                	test   %eax,%eax
  802699:	78 4e                	js     8026e9 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80269b:	a1 5c 40 80 00       	mov    0x80405c,%eax
  8026a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8026a3:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8026a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8026a8:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8026af:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026b2:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8026b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026b7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8026be:	83 ec 0c             	sub    $0xc,%esp
  8026c1:	ff 75 f4             	push   -0xc(%ebp)
  8026c4:	e8 64 ee ff ff       	call   80152d <fd2num>
  8026c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026cc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8026ce:	83 c4 04             	add    $0x4,%esp
  8026d1:	ff 75 f0             	push   -0x10(%ebp)
  8026d4:	e8 54 ee ff ff       	call   80152d <fd2num>
  8026d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026dc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8026df:	83 c4 10             	add    $0x10,%esp
  8026e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026e7:	eb 2e                	jmp    802717 <pipe+0x141>
	sys_page_unmap(0, va);
  8026e9:	83 ec 08             	sub    $0x8,%esp
  8026ec:	56                   	push   %esi
  8026ed:	6a 00                	push   $0x0
  8026ef:	e8 6c ec ff ff       	call   801360 <sys_page_unmap>
  8026f4:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8026f7:	83 ec 08             	sub    $0x8,%esp
  8026fa:	ff 75 f0             	push   -0x10(%ebp)
  8026fd:	6a 00                	push   $0x0
  8026ff:	e8 5c ec ff ff       	call   801360 <sys_page_unmap>
  802704:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802707:	83 ec 08             	sub    $0x8,%esp
  80270a:	ff 75 f4             	push   -0xc(%ebp)
  80270d:	6a 00                	push   $0x0
  80270f:	e8 4c ec ff ff       	call   801360 <sys_page_unmap>
  802714:	83 c4 10             	add    $0x10,%esp
}
  802717:	89 d8                	mov    %ebx,%eax
  802719:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80271c:	5b                   	pop    %ebx
  80271d:	5e                   	pop    %esi
  80271e:	5d                   	pop    %ebp
  80271f:	c3                   	ret    

00802720 <pipeisclosed>:
{
  802720:	55                   	push   %ebp
  802721:	89 e5                	mov    %esp,%ebp
  802723:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802726:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802729:	50                   	push   %eax
  80272a:	ff 75 08             	push   0x8(%ebp)
  80272d:	e8 72 ee ff ff       	call   8015a4 <fd_lookup>
  802732:	83 c4 10             	add    $0x10,%esp
  802735:	85 c0                	test   %eax,%eax
  802737:	78 18                	js     802751 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802739:	83 ec 0c             	sub    $0xc,%esp
  80273c:	ff 75 f4             	push   -0xc(%ebp)
  80273f:	e8 f9 ed ff ff       	call   80153d <fd2data>
  802744:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802746:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802749:	e8 33 fd ff ff       	call   802481 <_pipeisclosed>
  80274e:	83 c4 10             	add    $0x10,%esp
}
  802751:	c9                   	leave  
  802752:	c3                   	ret    

00802753 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802753:	b8 00 00 00 00       	mov    $0x0,%eax
  802758:	c3                   	ret    

00802759 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802759:	55                   	push   %ebp
  80275a:	89 e5                	mov    %esp,%ebp
  80275c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80275f:	68 1a 33 80 00       	push   $0x80331a
  802764:	ff 75 0c             	push   0xc(%ebp)
  802767:	e8 73 e7 ff ff       	call   800edf <strcpy>
	return 0;
}
  80276c:	b8 00 00 00 00       	mov    $0x0,%eax
  802771:	c9                   	leave  
  802772:	c3                   	ret    

00802773 <devcons_write>:
{
  802773:	55                   	push   %ebp
  802774:	89 e5                	mov    %esp,%ebp
  802776:	57                   	push   %edi
  802777:	56                   	push   %esi
  802778:	53                   	push   %ebx
  802779:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80277f:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802784:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80278a:	eb 2e                	jmp    8027ba <devcons_write+0x47>
		m = n - tot;
  80278c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80278f:	29 f3                	sub    %esi,%ebx
  802791:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802796:	39 c3                	cmp    %eax,%ebx
  802798:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80279b:	83 ec 04             	sub    $0x4,%esp
  80279e:	53                   	push   %ebx
  80279f:	89 f0                	mov    %esi,%eax
  8027a1:	03 45 0c             	add    0xc(%ebp),%eax
  8027a4:	50                   	push   %eax
  8027a5:	57                   	push   %edi
  8027a6:	e8 ca e8 ff ff       	call   801075 <memmove>
		sys_cputs(buf, m);
  8027ab:	83 c4 08             	add    $0x8,%esp
  8027ae:	53                   	push   %ebx
  8027af:	57                   	push   %edi
  8027b0:	e8 6a ea ff ff       	call   80121f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8027b5:	01 de                	add    %ebx,%esi
  8027b7:	83 c4 10             	add    $0x10,%esp
  8027ba:	3b 75 10             	cmp    0x10(%ebp),%esi
  8027bd:	72 cd                	jb     80278c <devcons_write+0x19>
}
  8027bf:	89 f0                	mov    %esi,%eax
  8027c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027c4:	5b                   	pop    %ebx
  8027c5:	5e                   	pop    %esi
  8027c6:	5f                   	pop    %edi
  8027c7:	5d                   	pop    %ebp
  8027c8:	c3                   	ret    

008027c9 <devcons_read>:
{
  8027c9:	55                   	push   %ebp
  8027ca:	89 e5                	mov    %esp,%ebp
  8027cc:	83 ec 08             	sub    $0x8,%esp
  8027cf:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8027d4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8027d8:	75 07                	jne    8027e1 <devcons_read+0x18>
  8027da:	eb 1f                	jmp    8027fb <devcons_read+0x32>
		sys_yield();
  8027dc:	e8 db ea ff ff       	call   8012bc <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8027e1:	e8 57 ea ff ff       	call   80123d <sys_cgetc>
  8027e6:	85 c0                	test   %eax,%eax
  8027e8:	74 f2                	je     8027dc <devcons_read+0x13>
	if (c < 0)
  8027ea:	78 0f                	js     8027fb <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8027ec:	83 f8 04             	cmp    $0x4,%eax
  8027ef:	74 0c                	je     8027fd <devcons_read+0x34>
	*(char*)vbuf = c;
  8027f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8027f4:	88 02                	mov    %al,(%edx)
	return 1;
  8027f6:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8027fb:	c9                   	leave  
  8027fc:	c3                   	ret    
		return 0;
  8027fd:	b8 00 00 00 00       	mov    $0x0,%eax
  802802:	eb f7                	jmp    8027fb <devcons_read+0x32>

00802804 <cputchar>:
{
  802804:	55                   	push   %ebp
  802805:	89 e5                	mov    %esp,%ebp
  802807:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80280a:	8b 45 08             	mov    0x8(%ebp),%eax
  80280d:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802810:	6a 01                	push   $0x1
  802812:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802815:	50                   	push   %eax
  802816:	e8 04 ea ff ff       	call   80121f <sys_cputs>
}
  80281b:	83 c4 10             	add    $0x10,%esp
  80281e:	c9                   	leave  
  80281f:	c3                   	ret    

00802820 <getchar>:
{
  802820:	55                   	push   %ebp
  802821:	89 e5                	mov    %esp,%ebp
  802823:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802826:	6a 01                	push   $0x1
  802828:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80282b:	50                   	push   %eax
  80282c:	6a 00                	push   $0x0
  80282e:	e8 da ef ff ff       	call   80180d <read>
	if (r < 0)
  802833:	83 c4 10             	add    $0x10,%esp
  802836:	85 c0                	test   %eax,%eax
  802838:	78 06                	js     802840 <getchar+0x20>
	if (r < 1)
  80283a:	74 06                	je     802842 <getchar+0x22>
	return c;
  80283c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802840:	c9                   	leave  
  802841:	c3                   	ret    
		return -E_EOF;
  802842:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802847:	eb f7                	jmp    802840 <getchar+0x20>

00802849 <iscons>:
{
  802849:	55                   	push   %ebp
  80284a:	89 e5                	mov    %esp,%ebp
  80284c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80284f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802852:	50                   	push   %eax
  802853:	ff 75 08             	push   0x8(%ebp)
  802856:	e8 49 ed ff ff       	call   8015a4 <fd_lookup>
  80285b:	83 c4 10             	add    $0x10,%esp
  80285e:	85 c0                	test   %eax,%eax
  802860:	78 11                	js     802873 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802862:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802865:	8b 15 78 40 80 00    	mov    0x804078,%edx
  80286b:	39 10                	cmp    %edx,(%eax)
  80286d:	0f 94 c0             	sete   %al
  802870:	0f b6 c0             	movzbl %al,%eax
}
  802873:	c9                   	leave  
  802874:	c3                   	ret    

00802875 <opencons>:
{
  802875:	55                   	push   %ebp
  802876:	89 e5                	mov    %esp,%ebp
  802878:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80287b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80287e:	50                   	push   %eax
  80287f:	e8 d0 ec ff ff       	call   801554 <fd_alloc>
  802884:	83 c4 10             	add    $0x10,%esp
  802887:	85 c0                	test   %eax,%eax
  802889:	78 3a                	js     8028c5 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80288b:	83 ec 04             	sub    $0x4,%esp
  80288e:	68 07 04 00 00       	push   $0x407
  802893:	ff 75 f4             	push   -0xc(%ebp)
  802896:	6a 00                	push   $0x0
  802898:	e8 3e ea ff ff       	call   8012db <sys_page_alloc>
  80289d:	83 c4 10             	add    $0x10,%esp
  8028a0:	85 c0                	test   %eax,%eax
  8028a2:	78 21                	js     8028c5 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8028a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028a7:	8b 15 78 40 80 00    	mov    0x804078,%edx
  8028ad:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8028af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028b2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8028b9:	83 ec 0c             	sub    $0xc,%esp
  8028bc:	50                   	push   %eax
  8028bd:	e8 6b ec ff ff       	call   80152d <fd2num>
  8028c2:	83 c4 10             	add    $0x10,%esp
}
  8028c5:	c9                   	leave  
  8028c6:	c3                   	ret    

008028c7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8028c7:	55                   	push   %ebp
  8028c8:	89 e5                	mov    %esp,%ebp
  8028ca:	56                   	push   %esi
  8028cb:	53                   	push   %ebx
  8028cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8028cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8028d5:	85 c0                	test   %eax,%eax
  8028d7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8028dc:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8028df:	83 ec 0c             	sub    $0xc,%esp
  8028e2:	50                   	push   %eax
  8028e3:	e8 a3 eb ff ff       	call   80148b <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8028e8:	83 c4 10             	add    $0x10,%esp
  8028eb:	85 f6                	test   %esi,%esi
  8028ed:	74 17                	je     802906 <ipc_recv+0x3f>
  8028ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8028f4:	85 c0                	test   %eax,%eax
  8028f6:	78 0c                	js     802904 <ipc_recv+0x3d>
  8028f8:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8028fe:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  802904:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802906:	85 db                	test   %ebx,%ebx
  802908:	74 17                	je     802921 <ipc_recv+0x5a>
  80290a:	ba 00 00 00 00       	mov    $0x0,%edx
  80290f:	85 c0                	test   %eax,%eax
  802911:	78 0c                	js     80291f <ipc_recv+0x58>
  802913:	8b 15 10 50 80 00    	mov    0x805010,%edx
  802919:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  80291f:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802921:	85 c0                	test   %eax,%eax
  802923:	78 0b                	js     802930 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  802925:	a1 10 50 80 00       	mov    0x805010,%eax
  80292a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  802930:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802933:	5b                   	pop    %ebx
  802934:	5e                   	pop    %esi
  802935:	5d                   	pop    %ebp
  802936:	c3                   	ret    

00802937 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802937:	55                   	push   %ebp
  802938:	89 e5                	mov    %esp,%ebp
  80293a:	57                   	push   %edi
  80293b:	56                   	push   %esi
  80293c:	53                   	push   %ebx
  80293d:	83 ec 0c             	sub    $0xc,%esp
  802940:	8b 7d 08             	mov    0x8(%ebp),%edi
  802943:	8b 75 0c             	mov    0xc(%ebp),%esi
  802946:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802949:	85 db                	test   %ebx,%ebx
  80294b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802950:	0f 44 d8             	cmove  %eax,%ebx
  802953:	eb 05                	jmp    80295a <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802955:	e8 62 e9 ff ff       	call   8012bc <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80295a:	ff 75 14             	push   0x14(%ebp)
  80295d:	53                   	push   %ebx
  80295e:	56                   	push   %esi
  80295f:	57                   	push   %edi
  802960:	e8 03 eb ff ff       	call   801468 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802965:	83 c4 10             	add    $0x10,%esp
  802968:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80296b:	74 e8                	je     802955 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80296d:	85 c0                	test   %eax,%eax
  80296f:	78 08                	js     802979 <ipc_send+0x42>
	}while (r<0);

}
  802971:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802974:	5b                   	pop    %ebx
  802975:	5e                   	pop    %esi
  802976:	5f                   	pop    %edi
  802977:	5d                   	pop    %ebp
  802978:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802979:	50                   	push   %eax
  80297a:	68 26 33 80 00       	push   $0x803326
  80297f:	6a 3d                	push   $0x3d
  802981:	68 3a 33 80 00       	push   $0x80333a
  802986:	e8 9f de ff ff       	call   80082a <_panic>

0080298b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80298b:	55                   	push   %ebp
  80298c:	89 e5                	mov    %esp,%ebp
  80298e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802991:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802996:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  80299c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8029a2:	8b 52 60             	mov    0x60(%edx),%edx
  8029a5:	39 ca                	cmp    %ecx,%edx
  8029a7:	74 11                	je     8029ba <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  8029a9:	83 c0 01             	add    $0x1,%eax
  8029ac:	3d 00 04 00 00       	cmp    $0x400,%eax
  8029b1:	75 e3                	jne    802996 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8029b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8029b8:	eb 0e                	jmp    8029c8 <ipc_find_env+0x3d>
			return envs[i].env_id;
  8029ba:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8029c0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8029c5:	8b 40 58             	mov    0x58(%eax),%eax
}
  8029c8:	5d                   	pop    %ebp
  8029c9:	c3                   	ret    

008029ca <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8029ca:	55                   	push   %ebp
  8029cb:	89 e5                	mov    %esp,%ebp
  8029cd:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029d0:	89 c2                	mov    %eax,%edx
  8029d2:	c1 ea 16             	shr    $0x16,%edx
  8029d5:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8029dc:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8029e1:	f6 c1 01             	test   $0x1,%cl
  8029e4:	74 1c                	je     802a02 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8029e6:	c1 e8 0c             	shr    $0xc,%eax
  8029e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8029f0:	a8 01                	test   $0x1,%al
  8029f2:	74 0e                	je     802a02 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8029f4:	c1 e8 0c             	shr    $0xc,%eax
  8029f7:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8029fe:	ef 
  8029ff:	0f b7 d2             	movzwl %dx,%edx
}
  802a02:	89 d0                	mov    %edx,%eax
  802a04:	5d                   	pop    %ebp
  802a05:	c3                   	ret    
  802a06:	66 90                	xchg   %ax,%ax
  802a08:	66 90                	xchg   %ax,%ax
  802a0a:	66 90                	xchg   %ax,%ax
  802a0c:	66 90                	xchg   %ax,%ax
  802a0e:	66 90                	xchg   %ax,%ax

00802a10 <__udivdi3>:
  802a10:	f3 0f 1e fb          	endbr32 
  802a14:	55                   	push   %ebp
  802a15:	57                   	push   %edi
  802a16:	56                   	push   %esi
  802a17:	53                   	push   %ebx
  802a18:	83 ec 1c             	sub    $0x1c,%esp
  802a1b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802a1f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802a23:	8b 74 24 34          	mov    0x34(%esp),%esi
  802a27:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802a2b:	85 c0                	test   %eax,%eax
  802a2d:	75 19                	jne    802a48 <__udivdi3+0x38>
  802a2f:	39 f3                	cmp    %esi,%ebx
  802a31:	76 4d                	jbe    802a80 <__udivdi3+0x70>
  802a33:	31 ff                	xor    %edi,%edi
  802a35:	89 e8                	mov    %ebp,%eax
  802a37:	89 f2                	mov    %esi,%edx
  802a39:	f7 f3                	div    %ebx
  802a3b:	89 fa                	mov    %edi,%edx
  802a3d:	83 c4 1c             	add    $0x1c,%esp
  802a40:	5b                   	pop    %ebx
  802a41:	5e                   	pop    %esi
  802a42:	5f                   	pop    %edi
  802a43:	5d                   	pop    %ebp
  802a44:	c3                   	ret    
  802a45:	8d 76 00             	lea    0x0(%esi),%esi
  802a48:	39 f0                	cmp    %esi,%eax
  802a4a:	76 14                	jbe    802a60 <__udivdi3+0x50>
  802a4c:	31 ff                	xor    %edi,%edi
  802a4e:	31 c0                	xor    %eax,%eax
  802a50:	89 fa                	mov    %edi,%edx
  802a52:	83 c4 1c             	add    $0x1c,%esp
  802a55:	5b                   	pop    %ebx
  802a56:	5e                   	pop    %esi
  802a57:	5f                   	pop    %edi
  802a58:	5d                   	pop    %ebp
  802a59:	c3                   	ret    
  802a5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802a60:	0f bd f8             	bsr    %eax,%edi
  802a63:	83 f7 1f             	xor    $0x1f,%edi
  802a66:	75 48                	jne    802ab0 <__udivdi3+0xa0>
  802a68:	39 f0                	cmp    %esi,%eax
  802a6a:	72 06                	jb     802a72 <__udivdi3+0x62>
  802a6c:	31 c0                	xor    %eax,%eax
  802a6e:	39 eb                	cmp    %ebp,%ebx
  802a70:	77 de                	ja     802a50 <__udivdi3+0x40>
  802a72:	b8 01 00 00 00       	mov    $0x1,%eax
  802a77:	eb d7                	jmp    802a50 <__udivdi3+0x40>
  802a79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a80:	89 d9                	mov    %ebx,%ecx
  802a82:	85 db                	test   %ebx,%ebx
  802a84:	75 0b                	jne    802a91 <__udivdi3+0x81>
  802a86:	b8 01 00 00 00       	mov    $0x1,%eax
  802a8b:	31 d2                	xor    %edx,%edx
  802a8d:	f7 f3                	div    %ebx
  802a8f:	89 c1                	mov    %eax,%ecx
  802a91:	31 d2                	xor    %edx,%edx
  802a93:	89 f0                	mov    %esi,%eax
  802a95:	f7 f1                	div    %ecx
  802a97:	89 c6                	mov    %eax,%esi
  802a99:	89 e8                	mov    %ebp,%eax
  802a9b:	89 f7                	mov    %esi,%edi
  802a9d:	f7 f1                	div    %ecx
  802a9f:	89 fa                	mov    %edi,%edx
  802aa1:	83 c4 1c             	add    $0x1c,%esp
  802aa4:	5b                   	pop    %ebx
  802aa5:	5e                   	pop    %esi
  802aa6:	5f                   	pop    %edi
  802aa7:	5d                   	pop    %ebp
  802aa8:	c3                   	ret    
  802aa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ab0:	89 f9                	mov    %edi,%ecx
  802ab2:	ba 20 00 00 00       	mov    $0x20,%edx
  802ab7:	29 fa                	sub    %edi,%edx
  802ab9:	d3 e0                	shl    %cl,%eax
  802abb:	89 44 24 08          	mov    %eax,0x8(%esp)
  802abf:	89 d1                	mov    %edx,%ecx
  802ac1:	89 d8                	mov    %ebx,%eax
  802ac3:	d3 e8                	shr    %cl,%eax
  802ac5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802ac9:	09 c1                	or     %eax,%ecx
  802acb:	89 f0                	mov    %esi,%eax
  802acd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802ad1:	89 f9                	mov    %edi,%ecx
  802ad3:	d3 e3                	shl    %cl,%ebx
  802ad5:	89 d1                	mov    %edx,%ecx
  802ad7:	d3 e8                	shr    %cl,%eax
  802ad9:	89 f9                	mov    %edi,%ecx
  802adb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802adf:	89 eb                	mov    %ebp,%ebx
  802ae1:	d3 e6                	shl    %cl,%esi
  802ae3:	89 d1                	mov    %edx,%ecx
  802ae5:	d3 eb                	shr    %cl,%ebx
  802ae7:	09 f3                	or     %esi,%ebx
  802ae9:	89 c6                	mov    %eax,%esi
  802aeb:	89 f2                	mov    %esi,%edx
  802aed:	89 d8                	mov    %ebx,%eax
  802aef:	f7 74 24 08          	divl   0x8(%esp)
  802af3:	89 d6                	mov    %edx,%esi
  802af5:	89 c3                	mov    %eax,%ebx
  802af7:	f7 64 24 0c          	mull   0xc(%esp)
  802afb:	39 d6                	cmp    %edx,%esi
  802afd:	72 19                	jb     802b18 <__udivdi3+0x108>
  802aff:	89 f9                	mov    %edi,%ecx
  802b01:	d3 e5                	shl    %cl,%ebp
  802b03:	39 c5                	cmp    %eax,%ebp
  802b05:	73 04                	jae    802b0b <__udivdi3+0xfb>
  802b07:	39 d6                	cmp    %edx,%esi
  802b09:	74 0d                	je     802b18 <__udivdi3+0x108>
  802b0b:	89 d8                	mov    %ebx,%eax
  802b0d:	31 ff                	xor    %edi,%edi
  802b0f:	e9 3c ff ff ff       	jmp    802a50 <__udivdi3+0x40>
  802b14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b18:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802b1b:	31 ff                	xor    %edi,%edi
  802b1d:	e9 2e ff ff ff       	jmp    802a50 <__udivdi3+0x40>
  802b22:	66 90                	xchg   %ax,%ax
  802b24:	66 90                	xchg   %ax,%ax
  802b26:	66 90                	xchg   %ax,%ax
  802b28:	66 90                	xchg   %ax,%ax
  802b2a:	66 90                	xchg   %ax,%ax
  802b2c:	66 90                	xchg   %ax,%ax
  802b2e:	66 90                	xchg   %ax,%ax

00802b30 <__umoddi3>:
  802b30:	f3 0f 1e fb          	endbr32 
  802b34:	55                   	push   %ebp
  802b35:	57                   	push   %edi
  802b36:	56                   	push   %esi
  802b37:	53                   	push   %ebx
  802b38:	83 ec 1c             	sub    $0x1c,%esp
  802b3b:	8b 74 24 30          	mov    0x30(%esp),%esi
  802b3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802b43:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802b47:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  802b4b:	89 f0                	mov    %esi,%eax
  802b4d:	89 da                	mov    %ebx,%edx
  802b4f:	85 ff                	test   %edi,%edi
  802b51:	75 15                	jne    802b68 <__umoddi3+0x38>
  802b53:	39 dd                	cmp    %ebx,%ebp
  802b55:	76 39                	jbe    802b90 <__umoddi3+0x60>
  802b57:	f7 f5                	div    %ebp
  802b59:	89 d0                	mov    %edx,%eax
  802b5b:	31 d2                	xor    %edx,%edx
  802b5d:	83 c4 1c             	add    $0x1c,%esp
  802b60:	5b                   	pop    %ebx
  802b61:	5e                   	pop    %esi
  802b62:	5f                   	pop    %edi
  802b63:	5d                   	pop    %ebp
  802b64:	c3                   	ret    
  802b65:	8d 76 00             	lea    0x0(%esi),%esi
  802b68:	39 df                	cmp    %ebx,%edi
  802b6a:	77 f1                	ja     802b5d <__umoddi3+0x2d>
  802b6c:	0f bd cf             	bsr    %edi,%ecx
  802b6f:	83 f1 1f             	xor    $0x1f,%ecx
  802b72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802b76:	75 40                	jne    802bb8 <__umoddi3+0x88>
  802b78:	39 df                	cmp    %ebx,%edi
  802b7a:	72 04                	jb     802b80 <__umoddi3+0x50>
  802b7c:	39 f5                	cmp    %esi,%ebp
  802b7e:	77 dd                	ja     802b5d <__umoddi3+0x2d>
  802b80:	89 da                	mov    %ebx,%edx
  802b82:	89 f0                	mov    %esi,%eax
  802b84:	29 e8                	sub    %ebp,%eax
  802b86:	19 fa                	sbb    %edi,%edx
  802b88:	eb d3                	jmp    802b5d <__umoddi3+0x2d>
  802b8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b90:	89 e9                	mov    %ebp,%ecx
  802b92:	85 ed                	test   %ebp,%ebp
  802b94:	75 0b                	jne    802ba1 <__umoddi3+0x71>
  802b96:	b8 01 00 00 00       	mov    $0x1,%eax
  802b9b:	31 d2                	xor    %edx,%edx
  802b9d:	f7 f5                	div    %ebp
  802b9f:	89 c1                	mov    %eax,%ecx
  802ba1:	89 d8                	mov    %ebx,%eax
  802ba3:	31 d2                	xor    %edx,%edx
  802ba5:	f7 f1                	div    %ecx
  802ba7:	89 f0                	mov    %esi,%eax
  802ba9:	f7 f1                	div    %ecx
  802bab:	89 d0                	mov    %edx,%eax
  802bad:	31 d2                	xor    %edx,%edx
  802baf:	eb ac                	jmp    802b5d <__umoddi3+0x2d>
  802bb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802bb8:	8b 44 24 04          	mov    0x4(%esp),%eax
  802bbc:	ba 20 00 00 00       	mov    $0x20,%edx
  802bc1:	29 c2                	sub    %eax,%edx
  802bc3:	89 c1                	mov    %eax,%ecx
  802bc5:	89 e8                	mov    %ebp,%eax
  802bc7:	d3 e7                	shl    %cl,%edi
  802bc9:	89 d1                	mov    %edx,%ecx
  802bcb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802bcf:	d3 e8                	shr    %cl,%eax
  802bd1:	89 c1                	mov    %eax,%ecx
  802bd3:	8b 44 24 04          	mov    0x4(%esp),%eax
  802bd7:	09 f9                	or     %edi,%ecx
  802bd9:	89 df                	mov    %ebx,%edi
  802bdb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802bdf:	89 c1                	mov    %eax,%ecx
  802be1:	d3 e5                	shl    %cl,%ebp
  802be3:	89 d1                	mov    %edx,%ecx
  802be5:	d3 ef                	shr    %cl,%edi
  802be7:	89 c1                	mov    %eax,%ecx
  802be9:	89 f0                	mov    %esi,%eax
  802beb:	d3 e3                	shl    %cl,%ebx
  802bed:	89 d1                	mov    %edx,%ecx
  802bef:	89 fa                	mov    %edi,%edx
  802bf1:	d3 e8                	shr    %cl,%eax
  802bf3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802bf8:	09 d8                	or     %ebx,%eax
  802bfa:	f7 74 24 08          	divl   0x8(%esp)
  802bfe:	89 d3                	mov    %edx,%ebx
  802c00:	d3 e6                	shl    %cl,%esi
  802c02:	f7 e5                	mul    %ebp
  802c04:	89 c7                	mov    %eax,%edi
  802c06:	89 d1                	mov    %edx,%ecx
  802c08:	39 d3                	cmp    %edx,%ebx
  802c0a:	72 06                	jb     802c12 <__umoddi3+0xe2>
  802c0c:	75 0e                	jne    802c1c <__umoddi3+0xec>
  802c0e:	39 c6                	cmp    %eax,%esi
  802c10:	73 0a                	jae    802c1c <__umoddi3+0xec>
  802c12:	29 e8                	sub    %ebp,%eax
  802c14:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802c18:	89 d1                	mov    %edx,%ecx
  802c1a:	89 c7                	mov    %eax,%edi
  802c1c:	89 f5                	mov    %esi,%ebp
  802c1e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802c22:	29 fd                	sub    %edi,%ebp
  802c24:	19 cb                	sbb    %ecx,%ebx
  802c26:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802c2b:	89 d8                	mov    %ebx,%eax
  802c2d:	d3 e0                	shl    %cl,%eax
  802c2f:	89 f1                	mov    %esi,%ecx
  802c31:	d3 ed                	shr    %cl,%ebp
  802c33:	d3 eb                	shr    %cl,%ebx
  802c35:	09 e8                	or     %ebp,%eax
  802c37:	89 da                	mov    %ebx,%edx
  802c39:	83 c4 1c             	add    $0x1c,%esp
  802c3c:	5b                   	pop    %ebx
  802c3d:	5e                   	pop    %esi
  802c3e:	5f                   	pop    %edi
  802c3f:	5d                   	pop    %ebp
  802c40:	c3                   	ret    
