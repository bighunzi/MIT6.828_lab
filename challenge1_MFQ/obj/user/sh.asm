
obj/user/sh.debug：     文件格式 elf32-i386


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
  80002c:	e8 d8 09 00 00       	call   800a09 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int t;

	if (s == 0) {
  800042:	85 db                	test   %ebx,%ebx
  800044:	74 1a                	je     800060 <_gettoken+0x2d>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
	}

	if (debug > 1)
  800046:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  80004d:	7f 31                	jg     800080 <_gettoken+0x4d>
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
  80004f:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	*p2 = 0;
  800055:	8b 45 10             	mov    0x10(%ebp),%eax
  800058:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80005e:	eb 3a                	jmp    80009a <_gettoken+0x67>
		return 0;
  800060:	be 00 00 00 00       	mov    $0x0,%esi
		if (debug > 1)
  800065:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  80006c:	7e 59                	jle    8000c7 <_gettoken+0x94>
			cprintf("GETTOKEN NULL\n");
  80006e:	83 ec 0c             	sub    $0xc,%esp
  800071:	68 60 37 80 00       	push   $0x803760
  800076:	e8 cc 0a 00 00       	call   800b47 <cprintf>
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	eb 47                	jmp    8000c7 <_gettoken+0x94>
		cprintf("GETTOKEN: %s\n", s);
  800080:	83 ec 08             	sub    $0x8,%esp
  800083:	53                   	push   %ebx
  800084:	68 6f 37 80 00       	push   $0x80376f
  800089:	e8 b9 0a 00 00       	call   800b47 <cprintf>
  80008e:	83 c4 10             	add    $0x10,%esp
  800091:	eb bc                	jmp    80004f <_gettoken+0x1c>
		*s++ = 0;
  800093:	83 c3 01             	add    $0x1,%ebx
  800096:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
	while (strchr(WHITESPACE, *s))
  80009a:	83 ec 08             	sub    $0x8,%esp
  80009d:	0f be 03             	movsbl (%ebx),%eax
  8000a0:	50                   	push   %eax
  8000a1:	68 7d 37 80 00       	push   $0x80377d
  8000a6:	e8 77 12 00 00       	call   801322 <strchr>
  8000ab:	83 c4 10             	add    $0x10,%esp
  8000ae:	85 c0                	test   %eax,%eax
  8000b0:	75 e1                	jne    800093 <_gettoken+0x60>
	if (*s == 0) {
  8000b2:	0f b6 03             	movzbl (%ebx),%eax
  8000b5:	84 c0                	test   %al,%al
  8000b7:	75 2a                	jne    8000e3 <_gettoken+0xb0>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000b9:	be 00 00 00 00       	mov    $0x0,%esi
		if (debug > 1)
  8000be:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  8000c5:	7f 0a                	jg     8000d1 <_gettoken+0x9e>
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
}
  8000c7:	89 f0                	mov    %esi,%eax
  8000c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5f                   	pop    %edi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    
			cprintf("EOL\n");
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	68 82 37 80 00       	push   $0x803782
  8000d9:	e8 69 0a 00 00       	call   800b47 <cprintf>
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	eb e4                	jmp    8000c7 <_gettoken+0x94>
	if (strchr(SYMBOLS, *s)) {
  8000e3:	83 ec 08             	sub    $0x8,%esp
  8000e6:	0f be c0             	movsbl %al,%eax
  8000e9:	50                   	push   %eax
  8000ea:	68 93 37 80 00       	push   $0x803793
  8000ef:	e8 2e 12 00 00       	call   801322 <strchr>
  8000f4:	83 c4 10             	add    $0x10,%esp
  8000f7:	85 c0                	test   %eax,%eax
  8000f9:	74 2c                	je     800127 <_gettoken+0xf4>
		t = *s;
  8000fb:	0f be 33             	movsbl (%ebx),%esi
		*p1 = s;
  8000fe:	89 1f                	mov    %ebx,(%edi)
		*s++ = 0;
  800100:	c6 03 00             	movb   $0x0,(%ebx)
  800103:	83 c3 01             	add    $0x1,%ebx
  800106:	8b 45 10             	mov    0x10(%ebp),%eax
  800109:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
  80010b:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800112:	7e b3                	jle    8000c7 <_gettoken+0x94>
			cprintf("TOK %c\n", t);
  800114:	83 ec 08             	sub    $0x8,%esp
  800117:	56                   	push   %esi
  800118:	68 87 37 80 00       	push   $0x803787
  80011d:	e8 25 0a 00 00       	call   800b47 <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb a0                	jmp    8000c7 <_gettoken+0x94>
	*p1 = s;
  800127:	89 1f                	mov    %ebx,(%edi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800129:	eb 03                	jmp    80012e <_gettoken+0xfb>
		s++;
  80012b:	83 c3 01             	add    $0x1,%ebx
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80012e:	0f b6 03             	movzbl (%ebx),%eax
  800131:	84 c0                	test   %al,%al
  800133:	74 18                	je     80014d <_gettoken+0x11a>
  800135:	83 ec 08             	sub    $0x8,%esp
  800138:	0f be c0             	movsbl %al,%eax
  80013b:	50                   	push   %eax
  80013c:	68 8f 37 80 00       	push   $0x80378f
  800141:	e8 dc 11 00 00       	call   801322 <strchr>
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	85 c0                	test   %eax,%eax
  80014b:	74 de                	je     80012b <_gettoken+0xf8>
	*p2 = s;
  80014d:	8b 45 10             	mov    0x10(%ebp),%eax
  800150:	89 18                	mov    %ebx,(%eax)
	return 'w';
  800152:	be 77 00 00 00       	mov    $0x77,%esi
	if (debug > 1) {
  800157:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  80015e:	0f 8e 63 ff ff ff    	jle    8000c7 <_gettoken+0x94>
		t = **p2;
  800164:	0f b6 33             	movzbl (%ebx),%esi
		**p2 = 0;
  800167:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  80016a:	83 ec 08             	sub    $0x8,%esp
  80016d:	ff 37                	push   (%edi)
  80016f:	68 9b 37 80 00       	push   $0x80379b
  800174:	e8 ce 09 00 00       	call   800b47 <cprintf>
		**p2 = t;
  800179:	8b 45 10             	mov    0x10(%ebp),%eax
  80017c:	8b 00                	mov    (%eax),%eax
  80017e:	89 f2                	mov    %esi,%edx
  800180:	88 10                	mov    %dl,(%eax)
  800182:	83 c4 10             	add    $0x10,%esp
	return 'w';
  800185:	be 77 00 00 00       	mov    $0x77,%esi
  80018a:	e9 38 ff ff ff       	jmp    8000c7 <_gettoken+0x94>

0080018f <gettoken>:

int
gettoken(char *s, char **p1)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 22                	je     8001be <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  80019c:	83 ec 04             	sub    $0x4,%esp
  80019f:	68 0c 60 80 00       	push   $0x80600c
  8001a4:	68 10 60 80 00       	push   $0x806010
  8001a9:	50                   	push   %eax
  8001aa:	e8 84 fe ff ff       	call   800033 <_gettoken>
  8001af:	a3 08 60 80 00       	mov    %eax,0x806008
		return 0;
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	c = nc;
	*p1 = np1;
	nc = _gettoken(np2, &np1, &np2);
	return c;
}
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    
	c = nc;
  8001be:	a1 08 60 80 00       	mov    0x806008,%eax
  8001c3:	a3 04 60 80 00       	mov    %eax,0x806004
	*p1 = np1;
  8001c8:	8b 15 10 60 80 00    	mov    0x806010,%edx
  8001ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d1:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001d3:	83 ec 04             	sub    $0x4,%esp
  8001d6:	68 0c 60 80 00       	push   $0x80600c
  8001db:	68 10 60 80 00       	push   $0x806010
  8001e0:	ff 35 0c 60 80 00    	push   0x80600c
  8001e6:	e8 48 fe ff ff       	call   800033 <_gettoken>
  8001eb:	a3 08 60 80 00       	mov    %eax,0x806008
	return c;
  8001f0:	a1 04 60 80 00       	mov    0x806004,%eax
  8001f5:	83 c4 10             	add    $0x10,%esp
  8001f8:	eb c2                	jmp    8001bc <gettoken+0x2d>

008001fa <runcmd>:
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	57                   	push   %edi
  8001fe:	56                   	push   %esi
  8001ff:	53                   	push   %ebx
  800200:	81 ec 64 04 00 00    	sub    $0x464,%esp
	gettoken(s, 0);
  800206:	6a 00                	push   $0x0
  800208:	ff 75 08             	push   0x8(%ebp)
  80020b:	e8 7f ff ff ff       	call   80018f <gettoken>
  800210:	83 c4 10             	add    $0x10,%esp
		switch ((c = gettoken(0, &t))) {
  800213:	8d 75 a4             	lea    -0x5c(%ebp),%esi
	argc = 0;
  800216:	bf 00 00 00 00       	mov    $0x0,%edi
		switch ((c = gettoken(0, &t))) {
  80021b:	83 ec 08             	sub    $0x8,%esp
  80021e:	56                   	push   %esi
  80021f:	6a 00                	push   $0x0
  800221:	e8 69 ff ff ff       	call   80018f <gettoken>
  800226:	89 c3                	mov    %eax,%ebx
  800228:	83 c4 10             	add    $0x10,%esp
  80022b:	83 f8 3e             	cmp    $0x3e,%eax
  80022e:	0f 84 32 01 00 00    	je     800366 <runcmd+0x16c>
  800234:	7f 49                	jg     80027f <runcmd+0x85>
  800236:	85 c0                	test   %eax,%eax
  800238:	0f 84 1c 02 00 00    	je     80045a <runcmd+0x260>
  80023e:	83 f8 3c             	cmp    $0x3c,%eax
  800241:	0f 85 ef 02 00 00    	jne    800536 <runcmd+0x33c>
			if (gettoken(0, &t) != 'w') {
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	6a 00                	push   $0x0
  80024d:	e8 3d ff ff ff       	call   80018f <gettoken>
  800252:	83 c4 10             	add    $0x10,%esp
  800255:	83 f8 77             	cmp    $0x77,%eax
  800258:	0f 85 ba 00 00 00    	jne    800318 <runcmd+0x11e>
			if ((fd = open(t, O_RDONLY)) < 0) {
  80025e:	83 ec 08             	sub    $0x8,%esp
  800261:	6a 00                	push   $0x0
  800263:	ff 75 a4             	push   -0x5c(%ebp)
  800266:	e8 07 21 00 00       	call   802372 <open>
  80026b:	89 c3                	mov    %eax,%ebx
  80026d:	83 c4 10             	add    $0x10,%esp
  800270:	85 c0                	test   %eax,%eax
  800272:	0f 88 ba 00 00 00    	js     800332 <runcmd+0x138>
			if (fd != 0) {
  800278:	74 a1                	je     80021b <runcmd+0x21>
  80027a:	e9 cc 00 00 00       	jmp    80034b <runcmd+0x151>
		switch ((c = gettoken(0, &t))) {
  80027f:	83 f8 77             	cmp    $0x77,%eax
  800282:	74 69                	je     8002ed <runcmd+0xf3>
  800284:	83 f8 7c             	cmp    $0x7c,%eax
  800287:	0f 85 a9 02 00 00    	jne    800536 <runcmd+0x33c>
			if ((r = pipe(p)) < 0) {
  80028d:	83 ec 0c             	sub    $0xc,%esp
  800290:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800296:	50                   	push   %eax
  800297:	e8 d8 2e 00 00       	call   803174 <pipe>
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	85 c0                	test   %eax,%eax
  8002a1:	0f 88 41 01 00 00    	js     8003e8 <runcmd+0x1ee>
			if (debug)
  8002a7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8002ae:	0f 85 4f 01 00 00    	jne    800403 <runcmd+0x209>
			if ((r = fork()) < 0) {
  8002b4:	e8 a4 16 00 00       	call   80195d <fork>
  8002b9:	89 c3                	mov    %eax,%ebx
  8002bb:	85 c0                	test   %eax,%eax
  8002bd:	0f 88 61 01 00 00    	js     800424 <runcmd+0x22a>
			if (r == 0) {
  8002c3:	0f 85 71 01 00 00    	jne    80043a <runcmd+0x240>
				if (p[0] != 0) {
  8002c9:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8002cf:	85 c0                	test   %eax,%eax
  8002d1:	0f 85 1d 02 00 00    	jne    8004f4 <runcmd+0x2fa>
				close(p[1]);
  8002d7:	83 ec 0c             	sub    $0xc,%esp
  8002da:	ff b5 a0 fb ff ff    	push   -0x460(%ebp)
  8002e0:	e8 ee 1a 00 00       	call   801dd3 <close>
				goto again;
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	e9 29 ff ff ff       	jmp    800216 <runcmd+0x1c>
			if (argc == MAXARGS) {
  8002ed:	83 ff 10             	cmp    $0x10,%edi
  8002f0:	74 0f                	je     800301 <runcmd+0x107>
			argv[argc++] = t;
  8002f2:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  8002f5:	89 44 bd a8          	mov    %eax,-0x58(%ebp,%edi,4)
  8002f9:	8d 7f 01             	lea    0x1(%edi),%edi
			break;
  8002fc:	e9 1a ff ff ff       	jmp    80021b <runcmd+0x21>
				cprintf("too many arguments\n");
  800301:	83 ec 0c             	sub    $0xc,%esp
  800304:	68 a5 37 80 00       	push   $0x8037a5
  800309:	e8 39 08 00 00       	call   800b47 <cprintf>
				exit();
  80030e:	e8 3f 07 00 00       	call   800a52 <exit>
  800313:	83 c4 10             	add    $0x10,%esp
  800316:	eb da                	jmp    8002f2 <runcmd+0xf8>
				cprintf("syntax error: < not followed by word\n");
  800318:	83 ec 0c             	sub    $0xc,%esp
  80031b:	68 f0 38 80 00       	push   $0x8038f0
  800320:	e8 22 08 00 00       	call   800b47 <cprintf>
				exit();
  800325:	e8 28 07 00 00       	call   800a52 <exit>
  80032a:	83 c4 10             	add    $0x10,%esp
  80032d:	e9 2c ff ff ff       	jmp    80025e <runcmd+0x64>
				cprintf("open %s for read: %e", t, fd);
  800332:	83 ec 04             	sub    $0x4,%esp
  800335:	50                   	push   %eax
  800336:	ff 75 a4             	push   -0x5c(%ebp)
  800339:	68 b9 37 80 00       	push   $0x8037b9
  80033e:	e8 04 08 00 00       	call   800b47 <cprintf>
				exit();
  800343:	e8 0a 07 00 00       	call   800a52 <exit>
  800348:	83 c4 10             	add    $0x10,%esp
				dup(fd, 0);
  80034b:	83 ec 08             	sub    $0x8,%esp
  80034e:	6a 00                	push   $0x0
  800350:	53                   	push   %ebx
  800351:	e8 cf 1a 00 00       	call   801e25 <dup>
				close(fd);
  800356:	89 1c 24             	mov    %ebx,(%esp)
  800359:	e8 75 1a 00 00       	call   801dd3 <close>
  80035e:	83 c4 10             	add    $0x10,%esp
  800361:	e9 b5 fe ff ff       	jmp    80021b <runcmd+0x21>
			if (gettoken(0, &t) != 'w') {
  800366:	83 ec 08             	sub    $0x8,%esp
  800369:	56                   	push   %esi
  80036a:	6a 00                	push   $0x0
  80036c:	e8 1e fe ff ff       	call   80018f <gettoken>
  800371:	83 c4 10             	add    $0x10,%esp
  800374:	83 f8 77             	cmp    $0x77,%eax
  800377:	75 24                	jne    80039d <runcmd+0x1a3>
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800379:	83 ec 08             	sub    $0x8,%esp
  80037c:	68 01 03 00 00       	push   $0x301
  800381:	ff 75 a4             	push   -0x5c(%ebp)
  800384:	e8 e9 1f 00 00       	call   802372 <open>
  800389:	89 c3                	mov    %eax,%ebx
  80038b:	83 c4 10             	add    $0x10,%esp
  80038e:	85 c0                	test   %eax,%eax
  800390:	78 22                	js     8003b4 <runcmd+0x1ba>
			if (fd != 1) {
  800392:	83 f8 01             	cmp    $0x1,%eax
  800395:	0f 84 80 fe ff ff    	je     80021b <runcmd+0x21>
  80039b:	eb 30                	jmp    8003cd <runcmd+0x1d3>
				cprintf("syntax error: > not followed by word\n");
  80039d:	83 ec 0c             	sub    $0xc,%esp
  8003a0:	68 18 39 80 00       	push   $0x803918
  8003a5:	e8 9d 07 00 00       	call   800b47 <cprintf>
				exit();
  8003aa:	e8 a3 06 00 00       	call   800a52 <exit>
  8003af:	83 c4 10             	add    $0x10,%esp
  8003b2:	eb c5                	jmp    800379 <runcmd+0x17f>
				cprintf("open %s for write: %e", t, fd);
  8003b4:	83 ec 04             	sub    $0x4,%esp
  8003b7:	50                   	push   %eax
  8003b8:	ff 75 a4             	push   -0x5c(%ebp)
  8003bb:	68 ce 37 80 00       	push   $0x8037ce
  8003c0:	e8 82 07 00 00       	call   800b47 <cprintf>
				exit();
  8003c5:	e8 88 06 00 00       	call   800a52 <exit>
  8003ca:	83 c4 10             	add    $0x10,%esp
				dup(fd, 1);
  8003cd:	83 ec 08             	sub    $0x8,%esp
  8003d0:	6a 01                	push   $0x1
  8003d2:	53                   	push   %ebx
  8003d3:	e8 4d 1a 00 00       	call   801e25 <dup>
				close(fd);
  8003d8:	89 1c 24             	mov    %ebx,(%esp)
  8003db:	e8 f3 19 00 00       	call   801dd3 <close>
  8003e0:	83 c4 10             	add    $0x10,%esp
  8003e3:	e9 33 fe ff ff       	jmp    80021b <runcmd+0x21>
				cprintf("pipe: %e", r);
  8003e8:	83 ec 08             	sub    $0x8,%esp
  8003eb:	50                   	push   %eax
  8003ec:	68 e4 37 80 00       	push   $0x8037e4
  8003f1:	e8 51 07 00 00       	call   800b47 <cprintf>
				exit();
  8003f6:	e8 57 06 00 00       	call   800a52 <exit>
  8003fb:	83 c4 10             	add    $0x10,%esp
  8003fe:	e9 a4 fe ff ff       	jmp    8002a7 <runcmd+0xad>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  800403:	83 ec 04             	sub    $0x4,%esp
  800406:	ff b5 a0 fb ff ff    	push   -0x460(%ebp)
  80040c:	ff b5 9c fb ff ff    	push   -0x464(%ebp)
  800412:	68 ed 37 80 00       	push   $0x8037ed
  800417:	e8 2b 07 00 00       	call   800b47 <cprintf>
  80041c:	83 c4 10             	add    $0x10,%esp
  80041f:	e9 90 fe ff ff       	jmp    8002b4 <runcmd+0xba>
				cprintf("fork: %e", r);
  800424:	83 ec 08             	sub    $0x8,%esp
  800427:	50                   	push   %eax
  800428:	68 88 3d 80 00       	push   $0x803d88
  80042d:	e8 15 07 00 00       	call   800b47 <cprintf>
				exit();
  800432:	e8 1b 06 00 00       	call   800a52 <exit>
  800437:	83 c4 10             	add    $0x10,%esp
				if (p[1] != 1) {
  80043a:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800440:	83 f8 01             	cmp    $0x1,%eax
  800443:	0f 85 cc 00 00 00    	jne    800515 <runcmd+0x31b>
				close(p[0]);
  800449:	83 ec 0c             	sub    $0xc,%esp
  80044c:	ff b5 9c fb ff ff    	push   -0x464(%ebp)
  800452:	e8 7c 19 00 00       	call   801dd3 <close>
				goto runit;
  800457:	83 c4 10             	add    $0x10,%esp
	if(argc == 0) {
  80045a:	85 ff                	test   %edi,%edi
  80045c:	0f 84 e6 00 00 00    	je     800548 <runcmd+0x34e>
	if (argv[0][0] != '/') {
  800462:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800465:	80 38 2f             	cmpb   $0x2f,(%eax)
  800468:	0f 85 f5 00 00 00    	jne    800563 <runcmd+0x369>
	argv[argc] = 0;
  80046e:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
  800475:	00 
	if (debug) {
  800476:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80047d:	0f 85 08 01 00 00    	jne    80058b <runcmd+0x391>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	8d 45 a8             	lea    -0x58(%ebp),%eax
  800489:	50                   	push   %eax
  80048a:	ff 75 a8             	push   -0x58(%ebp)
  80048d:	e8 98 20 00 00       	call   80252a <spawn>
  800492:	89 c6                	mov    %eax,%esi
  800494:	83 c4 10             	add    $0x10,%esp
  800497:	85 c0                	test   %eax,%eax
  800499:	0f 88 3a 01 00 00    	js     8005d9 <runcmd+0x3df>
	close_all();
  80049f:	e8 5c 19 00 00       	call   801e00 <close_all>
		if (debug)
  8004a4:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8004ab:	0f 85 75 01 00 00    	jne    800626 <runcmd+0x42c>
		wait(r);
  8004b1:	83 ec 0c             	sub    $0xc,%esp
  8004b4:	56                   	push   %esi
  8004b5:	e8 37 2e 00 00       	call   8032f1 <wait>
		if (debug)
  8004ba:	83 c4 10             	add    $0x10,%esp
  8004bd:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8004c4:	0f 85 7b 01 00 00    	jne    800645 <runcmd+0x44b>
	if (pipe_child) {
  8004ca:	85 db                	test   %ebx,%ebx
  8004cc:	74 19                	je     8004e7 <runcmd+0x2ed>
		wait(pipe_child);
  8004ce:	83 ec 0c             	sub    $0xc,%esp
  8004d1:	53                   	push   %ebx
  8004d2:	e8 1a 2e 00 00       	call   8032f1 <wait>
		if (debug)
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8004e1:	0f 85 79 01 00 00    	jne    800660 <runcmd+0x466>
	exit();
  8004e7:	e8 66 05 00 00       	call   800a52 <exit>
}
  8004ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ef:	5b                   	pop    %ebx
  8004f0:	5e                   	pop    %esi
  8004f1:	5f                   	pop    %edi
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    
					dup(p[0], 0);
  8004f4:	83 ec 08             	sub    $0x8,%esp
  8004f7:	6a 00                	push   $0x0
  8004f9:	50                   	push   %eax
  8004fa:	e8 26 19 00 00       	call   801e25 <dup>
					close(p[0]);
  8004ff:	83 c4 04             	add    $0x4,%esp
  800502:	ff b5 9c fb ff ff    	push   -0x464(%ebp)
  800508:	e8 c6 18 00 00       	call   801dd3 <close>
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	e9 c2 fd ff ff       	jmp    8002d7 <runcmd+0xdd>
					dup(p[1], 1);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	6a 01                	push   $0x1
  80051a:	50                   	push   %eax
  80051b:	e8 05 19 00 00       	call   801e25 <dup>
					close(p[1]);
  800520:	83 c4 04             	add    $0x4,%esp
  800523:	ff b5 a0 fb ff ff    	push   -0x460(%ebp)
  800529:	e8 a5 18 00 00       	call   801dd3 <close>
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	e9 13 ff ff ff       	jmp    800449 <runcmd+0x24f>
			panic("bad return %d from gettoken", c);
  800536:	53                   	push   %ebx
  800537:	68 fa 37 80 00       	push   $0x8037fa
  80053c:	6a 79                	push   $0x79
  80053e:	68 16 38 80 00       	push   $0x803816
  800543:	e8 24 05 00 00       	call   800a6c <_panic>
		if (debug)
  800548:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80054f:	74 9b                	je     8004ec <runcmd+0x2f2>
			cprintf("EMPTY COMMAND\n");
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	68 20 38 80 00       	push   $0x803820
  800559:	e8 e9 05 00 00       	call   800b47 <cprintf>
  80055e:	83 c4 10             	add    $0x10,%esp
  800561:	eb 89                	jmp    8004ec <runcmd+0x2f2>
		argv0buf[0] = '/';
  800563:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	50                   	push   %eax
  80056e:	8d b5 a4 fb ff ff    	lea    -0x45c(%ebp),%esi
  800574:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  80057a:	50                   	push   %eax
  80057b:	e8 91 0c 00 00       	call   801211 <strcpy>
		argv[0] = argv0buf;
  800580:	89 75 a8             	mov    %esi,-0x58(%ebp)
  800583:	83 c4 10             	add    $0x10,%esp
  800586:	e9 e3 fe ff ff       	jmp    80046e <runcmd+0x274>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  80058b:	a1 14 60 80 00       	mov    0x806014,%eax
  800590:	8b 40 58             	mov    0x58(%eax),%eax
  800593:	83 ec 08             	sub    $0x8,%esp
  800596:	50                   	push   %eax
  800597:	68 2f 38 80 00       	push   $0x80382f
  80059c:	e8 a6 05 00 00       	call   800b47 <cprintf>
  8005a1:	8d 75 a8             	lea    -0x58(%ebp),%esi
		for (i = 0; argv[i]; i++)
  8005a4:	83 c4 10             	add    $0x10,%esp
  8005a7:	eb 11                	jmp    8005ba <runcmd+0x3c0>
			cprintf(" %s", argv[i]);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	50                   	push   %eax
  8005ad:	68 b7 38 80 00       	push   $0x8038b7
  8005b2:	e8 90 05 00 00       	call   800b47 <cprintf>
  8005b7:	83 c4 10             	add    $0x10,%esp
		for (i = 0; argv[i]; i++)
  8005ba:	83 c6 04             	add    $0x4,%esi
  8005bd:	8b 46 fc             	mov    -0x4(%esi),%eax
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	75 e5                	jne    8005a9 <runcmd+0x3af>
		cprintf("\n");
  8005c4:	83 ec 0c             	sub    $0xc,%esp
  8005c7:	68 80 37 80 00       	push   $0x803780
  8005cc:	e8 76 05 00 00       	call   800b47 <cprintf>
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	e9 aa fe ff ff       	jmp    800483 <runcmd+0x289>
		cprintf("spawn %s: %e\n", argv[0], r);
  8005d9:	83 ec 04             	sub    $0x4,%esp
  8005dc:	50                   	push   %eax
  8005dd:	ff 75 a8             	push   -0x58(%ebp)
  8005e0:	68 3d 38 80 00       	push   $0x80383d
  8005e5:	e8 5d 05 00 00       	call   800b47 <cprintf>
	close_all();
  8005ea:	e8 11 18 00 00       	call   801e00 <close_all>
  8005ef:	83 c4 10             	add    $0x10,%esp
	if (pipe_child) {
  8005f2:	85 db                	test   %ebx,%ebx
  8005f4:	0f 84 ed fe ff ff    	je     8004e7 <runcmd+0x2ed>
		if (debug)
  8005fa:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800601:	0f 84 c7 fe ff ff    	je     8004ce <runcmd+0x2d4>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  800607:	a1 14 60 80 00       	mov    0x806014,%eax
  80060c:	8b 40 58             	mov    0x58(%eax),%eax
  80060f:	83 ec 04             	sub    $0x4,%esp
  800612:	53                   	push   %ebx
  800613:	50                   	push   %eax
  800614:	68 76 38 80 00       	push   $0x803876
  800619:	e8 29 05 00 00       	call   800b47 <cprintf>
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	e9 a8 fe ff ff       	jmp    8004ce <runcmd+0x2d4>
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800626:	a1 14 60 80 00       	mov    0x806014,%eax
  80062b:	8b 40 58             	mov    0x58(%eax),%eax
  80062e:	56                   	push   %esi
  80062f:	ff 75 a8             	push   -0x58(%ebp)
  800632:	50                   	push   %eax
  800633:	68 4b 38 80 00       	push   $0x80384b
  800638:	e8 0a 05 00 00       	call   800b47 <cprintf>
  80063d:	83 c4 10             	add    $0x10,%esp
  800640:	e9 6c fe ff ff       	jmp    8004b1 <runcmd+0x2b7>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800645:	a1 14 60 80 00       	mov    0x806014,%eax
  80064a:	8b 40 58             	mov    0x58(%eax),%eax
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	50                   	push   %eax
  800651:	68 60 38 80 00       	push   $0x803860
  800656:	e8 ec 04 00 00       	call   800b47 <cprintf>
  80065b:	83 c4 10             	add    $0x10,%esp
  80065e:	eb 92                	jmp    8005f2 <runcmd+0x3f8>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800660:	a1 14 60 80 00       	mov    0x806014,%eax
  800665:	8b 40 58             	mov    0x58(%eax),%eax
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	50                   	push   %eax
  80066c:	68 60 38 80 00       	push   $0x803860
  800671:	e8 d1 04 00 00       	call   800b47 <cprintf>
  800676:	83 c4 10             	add    $0x10,%esp
  800679:	e9 69 fe ff ff       	jmp    8004e7 <runcmd+0x2ed>

0080067e <usage>:


void
usage(void)
{
  80067e:	55                   	push   %ebp
  80067f:	89 e5                	mov    %esp,%ebp
  800681:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800684:	68 40 39 80 00       	push   $0x803940
  800689:	e8 b9 04 00 00       	call   800b47 <cprintf>
	exit();
  80068e:	e8 bf 03 00 00       	call   800a52 <exit>
}
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	c9                   	leave  
  800697:	c3                   	ret    

00800698 <umain>:

void
umain(int argc, char **argv)
{
  800698:	55                   	push   %ebp
  800699:	89 e5                	mov    %esp,%ebp
  80069b:	57                   	push   %edi
  80069c:	56                   	push   %esi
  80069d:	53                   	push   %ebx
  80069e:	83 ec 30             	sub    $0x30,%esp
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  8006a1:	8d 45 d8             	lea    -0x28(%ebp),%eax
  8006a4:	50                   	push   %eax
  8006a5:	ff 75 0c             	push   0xc(%ebp)
  8006a8:	8d 45 08             	lea    0x8(%ebp),%eax
  8006ab:	50                   	push   %eax
  8006ac:	e8 2f 14 00 00       	call   801ae0 <argstart>
	while ((r = argnext(&args)) >= 0)
  8006b1:	83 c4 10             	add    $0x10,%esp
	echocmds = 0;
  8006b4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
	interactive = '?';
  8006bb:	bf 3f 00 00 00       	mov    $0x3f,%edi
	while ((r = argnext(&args)) >= 0)
  8006c0:	8d 5d d8             	lea    -0x28(%ebp),%ebx
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006c3:	be 01 00 00 00       	mov    $0x1,%esi
	while ((r = argnext(&args)) >= 0)
  8006c8:	eb 10                	jmp    8006da <umain+0x42>
			debug++;
  8006ca:	83 05 00 60 80 00 01 	addl   $0x1,0x806000
			break;
  8006d1:	eb 07                	jmp    8006da <umain+0x42>
			interactive = 1;
  8006d3:	89 f7                	mov    %esi,%edi
  8006d5:	eb 03                	jmp    8006da <umain+0x42>
		switch (r) {
  8006d7:	89 75 d4             	mov    %esi,-0x2c(%ebp)
	while ((r = argnext(&args)) >= 0)
  8006da:	83 ec 0c             	sub    $0xc,%esp
  8006dd:	53                   	push   %ebx
  8006de:	e8 2d 14 00 00       	call   801b10 <argnext>
  8006e3:	83 c4 10             	add    $0x10,%esp
  8006e6:	85 c0                	test   %eax,%eax
  8006e8:	78 16                	js     800700 <umain+0x68>
		switch (r) {
  8006ea:	83 f8 69             	cmp    $0x69,%eax
  8006ed:	74 e4                	je     8006d3 <umain+0x3b>
  8006ef:	83 f8 78             	cmp    $0x78,%eax
  8006f2:	74 e3                	je     8006d7 <umain+0x3f>
  8006f4:	83 f8 64             	cmp    $0x64,%eax
  8006f7:	74 d1                	je     8006ca <umain+0x32>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006f9:	e8 80 ff ff ff       	call   80067e <usage>
  8006fe:	eb da                	jmp    8006da <umain+0x42>
		}

	if (argc > 2)
  800700:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  800704:	7f 1f                	jg     800725 <umain+0x8d>
		usage();
	if (argc == 2) {
  800706:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  80070a:	74 20                	je     80072c <umain+0x94>
		close(0);
		if ((r = open(argv[1], O_RDONLY)) < 0)
			panic("open %s: %e", argv[1], r);
		assert(r == 0);
	}
	if (interactive == '?')
  80070c:	83 ff 3f             	cmp    $0x3f,%edi
  80070f:	74 75                	je     800786 <umain+0xee>
  800711:	85 ff                	test   %edi,%edi
  800713:	bf bb 38 80 00       	mov    $0x8038bb,%edi
  800718:	b8 00 00 00 00       	mov    $0x0,%eax
  80071d:	0f 44 f8             	cmove  %eax,%edi
  800720:	e9 06 01 00 00       	jmp    80082b <umain+0x193>
		usage();
  800725:	e8 54 ff ff ff       	call   80067e <usage>
  80072a:	eb da                	jmp    800706 <umain+0x6e>
		close(0);
  80072c:	83 ec 0c             	sub    $0xc,%esp
  80072f:	6a 00                	push   $0x0
  800731:	e8 9d 16 00 00       	call   801dd3 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  800736:	83 c4 08             	add    $0x8,%esp
  800739:	6a 00                	push   $0x0
  80073b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073e:	ff 70 04             	push   0x4(%eax)
  800741:	e8 2c 1c 00 00       	call   802372 <open>
  800746:	83 c4 10             	add    $0x10,%esp
  800749:	85 c0                	test   %eax,%eax
  80074b:	78 1b                	js     800768 <umain+0xd0>
		assert(r == 0);
  80074d:	74 bd                	je     80070c <umain+0x74>
  80074f:	68 9f 38 80 00       	push   $0x80389f
  800754:	68 a6 38 80 00       	push   $0x8038a6
  800759:	68 2a 01 00 00       	push   $0x12a
  80075e:	68 16 38 80 00       	push   $0x803816
  800763:	e8 04 03 00 00       	call   800a6c <_panic>
			panic("open %s: %e", argv[1], r);
  800768:	83 ec 0c             	sub    $0xc,%esp
  80076b:	50                   	push   %eax
  80076c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076f:	ff 70 04             	push   0x4(%eax)
  800772:	68 93 38 80 00       	push   $0x803893
  800777:	68 29 01 00 00       	push   $0x129
  80077c:	68 16 38 80 00       	push   $0x803816
  800781:	e8 e6 02 00 00       	call   800a6c <_panic>
		interactive = iscons(0);
  800786:	83 ec 0c             	sub    $0xc,%esp
  800789:	6a 00                	push   $0x0
  80078b:	e8 fb 01 00 00       	call   80098b <iscons>
  800790:	89 c7                	mov    %eax,%edi
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	e9 77 ff ff ff       	jmp    800711 <umain+0x79>
	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
		if (buf == NULL) {
			if (debug)
  80079a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8007a1:	75 0a                	jne    8007ad <umain+0x115>
				cprintf("EXITING\n");
			exit();	// end of file
  8007a3:	e8 aa 02 00 00       	call   800a52 <exit>
  8007a8:	e9 94 00 00 00       	jmp    800841 <umain+0x1a9>
				cprintf("EXITING\n");
  8007ad:	83 ec 0c             	sub    $0xc,%esp
  8007b0:	68 be 38 80 00       	push   $0x8038be
  8007b5:	e8 8d 03 00 00       	call   800b47 <cprintf>
  8007ba:	83 c4 10             	add    $0x10,%esp
  8007bd:	eb e4                	jmp    8007a3 <umain+0x10b>
		}
		if (debug)
			cprintf("LINE: %s\n", buf);
  8007bf:	83 ec 08             	sub    $0x8,%esp
  8007c2:	53                   	push   %ebx
  8007c3:	68 c7 38 80 00       	push   $0x8038c7
  8007c8:	e8 7a 03 00 00       	call   800b47 <cprintf>
  8007cd:	83 c4 10             	add    $0x10,%esp
  8007d0:	eb 7c                	jmp    80084e <umain+0x1b6>
		if (buf[0] == '#')
			continue;
		if (echocmds)
			printf("# %s\n", buf);
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	53                   	push   %ebx
  8007d6:	68 d1 38 80 00       	push   $0x8038d1
  8007db:	e8 34 1d 00 00       	call   802514 <printf>
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	eb 78                	jmp    80085d <umain+0x1c5>
		if (debug)
			cprintf("BEFORE FORK\n");
  8007e5:	83 ec 0c             	sub    $0xc,%esp
  8007e8:	68 d7 38 80 00       	push   $0x8038d7
  8007ed:	e8 55 03 00 00       	call   800b47 <cprintf>
  8007f2:	83 c4 10             	add    $0x10,%esp
  8007f5:	eb 73                	jmp    80086a <umain+0x1d2>
		if ((r = fork()) < 0)
			panic("fork: %e", r);
  8007f7:	50                   	push   %eax
  8007f8:	68 88 3d 80 00       	push   $0x803d88
  8007fd:	68 41 01 00 00       	push   $0x141
  800802:	68 16 38 80 00       	push   $0x803816
  800807:	e8 60 02 00 00       	call   800a6c <_panic>
		if (debug)
			cprintf("FORK: %d\n", r);
  80080c:	83 ec 08             	sub    $0x8,%esp
  80080f:	50                   	push   %eax
  800810:	68 e4 38 80 00       	push   $0x8038e4
  800815:	e8 2d 03 00 00       	call   800b47 <cprintf>
  80081a:	83 c4 10             	add    $0x10,%esp
  80081d:	eb 5f                	jmp    80087e <umain+0x1e6>
		if (r == 0) {
			runcmd(buf);
			exit();
		} else
			wait(r);
  80081f:	83 ec 0c             	sub    $0xc,%esp
  800822:	56                   	push   %esi
  800823:	e8 c9 2a 00 00       	call   8032f1 <wait>
  800828:	83 c4 10             	add    $0x10,%esp
		buf = readline(interactive ? "$ " : NULL);
  80082b:	83 ec 0c             	sub    $0xc,%esp
  80082e:	57                   	push   %edi
  80082f:	e8 b2 08 00 00       	call   8010e6 <readline>
  800834:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	85 c0                	test   %eax,%eax
  80083b:	0f 84 59 ff ff ff    	je     80079a <umain+0x102>
		if (debug)
  800841:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800848:	0f 85 71 ff ff ff    	jne    8007bf <umain+0x127>
		if (buf[0] == '#')
  80084e:	80 3b 23             	cmpb   $0x23,(%ebx)
  800851:	74 d8                	je     80082b <umain+0x193>
		if (echocmds)
  800853:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800857:	0f 85 75 ff ff ff    	jne    8007d2 <umain+0x13a>
		if (debug)
  80085d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800864:	0f 85 7b ff ff ff    	jne    8007e5 <umain+0x14d>
		if ((r = fork()) < 0)
  80086a:	e8 ee 10 00 00       	call   80195d <fork>
  80086f:	89 c6                	mov    %eax,%esi
  800871:	85 c0                	test   %eax,%eax
  800873:	78 82                	js     8007f7 <umain+0x15f>
		if (debug)
  800875:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80087c:	75 8e                	jne    80080c <umain+0x174>
		if (r == 0) {
  80087e:	85 f6                	test   %esi,%esi
  800880:	75 9d                	jne    80081f <umain+0x187>
			runcmd(buf);
  800882:	83 ec 0c             	sub    $0xc,%esp
  800885:	53                   	push   %ebx
  800886:	e8 6f f9 ff ff       	call   8001fa <runcmd>
			exit();
  80088b:	e8 c2 01 00 00       	call   800a52 <exit>
  800890:	83 c4 10             	add    $0x10,%esp
  800893:	eb 96                	jmp    80082b <umain+0x193>

00800895 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  800895:	b8 00 00 00 00       	mov    $0x0,%eax
  80089a:	c3                   	ret    

0080089b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8008a1:	68 61 39 80 00       	push   $0x803961
  8008a6:	ff 75 0c             	push   0xc(%ebp)
  8008a9:	e8 63 09 00 00       	call   801211 <strcpy>
	return 0;
}
  8008ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b3:	c9                   	leave  
  8008b4:	c3                   	ret    

008008b5 <devcons_write>:
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	57                   	push   %edi
  8008b9:	56                   	push   %esi
  8008ba:	53                   	push   %ebx
  8008bb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8008c1:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8008c6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8008cc:	eb 2e                	jmp    8008fc <devcons_write+0x47>
		m = n - tot;
  8008ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008d1:	29 f3                	sub    %esi,%ebx
  8008d3:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8008d8:	39 c3                	cmp    %eax,%ebx
  8008da:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8008dd:	83 ec 04             	sub    $0x4,%esp
  8008e0:	53                   	push   %ebx
  8008e1:	89 f0                	mov    %esi,%eax
  8008e3:	03 45 0c             	add    0xc(%ebp),%eax
  8008e6:	50                   	push   %eax
  8008e7:	57                   	push   %edi
  8008e8:	e8 ba 0a 00 00       	call   8013a7 <memmove>
		sys_cputs(buf, m);
  8008ed:	83 c4 08             	add    $0x8,%esp
  8008f0:	53                   	push   %ebx
  8008f1:	57                   	push   %edi
  8008f2:	e8 5a 0c 00 00       	call   801551 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8008f7:	01 de                	add    %ebx,%esi
  8008f9:	83 c4 10             	add    $0x10,%esp
  8008fc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8008ff:	72 cd                	jb     8008ce <devcons_write+0x19>
}
  800901:	89 f0                	mov    %esi,%eax
  800903:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5f                   	pop    %edi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <devcons_read>:
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	83 ec 08             	sub    $0x8,%esp
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800916:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80091a:	75 07                	jne    800923 <devcons_read+0x18>
  80091c:	eb 1f                	jmp    80093d <devcons_read+0x32>
		sys_yield();
  80091e:	e8 cb 0c 00 00       	call   8015ee <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800923:	e8 47 0c 00 00       	call   80156f <sys_cgetc>
  800928:	85 c0                	test   %eax,%eax
  80092a:	74 f2                	je     80091e <devcons_read+0x13>
	if (c < 0)
  80092c:	78 0f                	js     80093d <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  80092e:	83 f8 04             	cmp    $0x4,%eax
  800931:	74 0c                	je     80093f <devcons_read+0x34>
	*(char*)vbuf = c;
  800933:	8b 55 0c             	mov    0xc(%ebp),%edx
  800936:	88 02                	mov    %al,(%edx)
	return 1;
  800938:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80093d:	c9                   	leave  
  80093e:	c3                   	ret    
		return 0;
  80093f:	b8 00 00 00 00       	mov    $0x0,%eax
  800944:	eb f7                	jmp    80093d <devcons_read+0x32>

00800946 <cputchar>:
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800952:	6a 01                	push   $0x1
  800954:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800957:	50                   	push   %eax
  800958:	e8 f4 0b 00 00       	call   801551 <sys_cputs>
}
  80095d:	83 c4 10             	add    $0x10,%esp
  800960:	c9                   	leave  
  800961:	c3                   	ret    

00800962 <getchar>:
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800968:	6a 01                	push   $0x1
  80096a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80096d:	50                   	push   %eax
  80096e:	6a 00                	push   $0x0
  800970:	e8 9a 15 00 00       	call   801f0f <read>
	if (r < 0)
  800975:	83 c4 10             	add    $0x10,%esp
  800978:	85 c0                	test   %eax,%eax
  80097a:	78 06                	js     800982 <getchar+0x20>
	if (r < 1)
  80097c:	74 06                	je     800984 <getchar+0x22>
	return c;
  80097e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800982:	c9                   	leave  
  800983:	c3                   	ret    
		return -E_EOF;
  800984:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800989:	eb f7                	jmp    800982 <getchar+0x20>

0080098b <iscons>:
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800991:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800994:	50                   	push   %eax
  800995:	ff 75 08             	push   0x8(%ebp)
  800998:	e8 09 13 00 00       	call   801ca6 <fd_lookup>
  80099d:	83 c4 10             	add    $0x10,%esp
  8009a0:	85 c0                	test   %eax,%eax
  8009a2:	78 11                	js     8009b5 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8009a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a7:	8b 15 00 50 80 00    	mov    0x805000,%edx
  8009ad:	39 10                	cmp    %edx,(%eax)
  8009af:	0f 94 c0             	sete   %al
  8009b2:	0f b6 c0             	movzbl %al,%eax
}
  8009b5:	c9                   	leave  
  8009b6:	c3                   	ret    

008009b7 <opencons>:
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8009bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009c0:	50                   	push   %eax
  8009c1:	e8 90 12 00 00       	call   801c56 <fd_alloc>
  8009c6:	83 c4 10             	add    $0x10,%esp
  8009c9:	85 c0                	test   %eax,%eax
  8009cb:	78 3a                	js     800a07 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8009cd:	83 ec 04             	sub    $0x4,%esp
  8009d0:	68 07 04 00 00       	push   $0x407
  8009d5:	ff 75 f4             	push   -0xc(%ebp)
  8009d8:	6a 00                	push   $0x0
  8009da:	e8 2e 0c 00 00       	call   80160d <sys_page_alloc>
  8009df:	83 c4 10             	add    $0x10,%esp
  8009e2:	85 c0                	test   %eax,%eax
  8009e4:	78 21                	js     800a07 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8009e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009e9:	8b 15 00 50 80 00    	mov    0x805000,%edx
  8009ef:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8009f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009fb:	83 ec 0c             	sub    $0xc,%esp
  8009fe:	50                   	push   %eax
  8009ff:	e8 2b 12 00 00       	call   801c2f <fd2num>
  800a04:	83 c4 10             	add    $0x10,%esp
}
  800a07:	c9                   	leave  
  800a08:	c3                   	ret    

00800a09 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	56                   	push   %esi
  800a0d:	53                   	push   %ebx
  800a0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a11:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800a14:	e8 b6 0b 00 00       	call   8015cf <sys_getenvid>
  800a19:	25 ff 03 00 00       	and    $0x3ff,%eax
  800a1e:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800a24:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800a29:	a3 14 60 80 00       	mov    %eax,0x806014

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800a2e:	85 db                	test   %ebx,%ebx
  800a30:	7e 07                	jle    800a39 <libmain+0x30>
		binaryname = argv[0];
  800a32:	8b 06                	mov    (%esi),%eax
  800a34:	a3 1c 50 80 00       	mov    %eax,0x80501c

	// call user main routine
	umain(argc, argv);
  800a39:	83 ec 08             	sub    $0x8,%esp
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
  800a3e:	e8 55 fc ff ff       	call   800698 <umain>

	// exit gracefully
	exit();
  800a43:	e8 0a 00 00 00       	call   800a52 <exit>
}
  800a48:	83 c4 10             	add    $0x10,%esp
  800a4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a4e:	5b                   	pop    %ebx
  800a4f:	5e                   	pop    %esi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a58:	e8 a3 13 00 00       	call   801e00 <close_all>
	sys_env_destroy(0);
  800a5d:	83 ec 0c             	sub    $0xc,%esp
  800a60:	6a 00                	push   $0x0
  800a62:	e8 27 0b 00 00       	call   80158e <sys_env_destroy>
}
  800a67:	83 c4 10             	add    $0x10,%esp
  800a6a:	c9                   	leave  
  800a6b:	c3                   	ret    

00800a6c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	56                   	push   %esi
  800a70:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a71:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a74:	8b 35 1c 50 80 00    	mov    0x80501c,%esi
  800a7a:	e8 50 0b 00 00       	call   8015cf <sys_getenvid>
  800a7f:	83 ec 0c             	sub    $0xc,%esp
  800a82:	ff 75 0c             	push   0xc(%ebp)
  800a85:	ff 75 08             	push   0x8(%ebp)
  800a88:	56                   	push   %esi
  800a89:	50                   	push   %eax
  800a8a:	68 78 39 80 00       	push   $0x803978
  800a8f:	e8 b3 00 00 00       	call   800b47 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a94:	83 c4 18             	add    $0x18,%esp
  800a97:	53                   	push   %ebx
  800a98:	ff 75 10             	push   0x10(%ebp)
  800a9b:	e8 56 00 00 00       	call   800af6 <vcprintf>
	cprintf("\n");
  800aa0:	c7 04 24 80 37 80 00 	movl   $0x803780,(%esp)
  800aa7:	e8 9b 00 00 00       	call   800b47 <cprintf>
  800aac:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800aaf:	cc                   	int3   
  800ab0:	eb fd                	jmp    800aaf <_panic+0x43>

00800ab2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	53                   	push   %ebx
  800ab6:	83 ec 04             	sub    $0x4,%esp
  800ab9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800abc:	8b 13                	mov    (%ebx),%edx
  800abe:	8d 42 01             	lea    0x1(%edx),%eax
  800ac1:	89 03                	mov    %eax,(%ebx)
  800ac3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800aca:	3d ff 00 00 00       	cmp    $0xff,%eax
  800acf:	74 09                	je     800ada <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800ad1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800ad5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ad8:	c9                   	leave  
  800ad9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800ada:	83 ec 08             	sub    $0x8,%esp
  800add:	68 ff 00 00 00       	push   $0xff
  800ae2:	8d 43 08             	lea    0x8(%ebx),%eax
  800ae5:	50                   	push   %eax
  800ae6:	e8 66 0a 00 00       	call   801551 <sys_cputs>
		b->idx = 0;
  800aeb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800af1:	83 c4 10             	add    $0x10,%esp
  800af4:	eb db                	jmp    800ad1 <putch+0x1f>

00800af6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800aff:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800b06:	00 00 00 
	b.cnt = 0;
  800b09:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800b10:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800b13:	ff 75 0c             	push   0xc(%ebp)
  800b16:	ff 75 08             	push   0x8(%ebp)
  800b19:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800b1f:	50                   	push   %eax
  800b20:	68 b2 0a 80 00       	push   $0x800ab2
  800b25:	e8 14 01 00 00       	call   800c3e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800b2a:	83 c4 08             	add    $0x8,%esp
  800b2d:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800b33:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b39:	50                   	push   %eax
  800b3a:	e8 12 0a 00 00       	call   801551 <sys_cputs>

	return b.cnt;
}
  800b3f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b45:	c9                   	leave  
  800b46:	c3                   	ret    

00800b47 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b4d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b50:	50                   	push   %eax
  800b51:	ff 75 08             	push   0x8(%ebp)
  800b54:	e8 9d ff ff ff       	call   800af6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800b59:	c9                   	leave  
  800b5a:	c3                   	ret    

00800b5b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
  800b61:	83 ec 1c             	sub    $0x1c,%esp
  800b64:	89 c7                	mov    %eax,%edi
  800b66:	89 d6                	mov    %edx,%esi
  800b68:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6e:	89 d1                	mov    %edx,%ecx
  800b70:	89 c2                	mov    %eax,%edx
  800b72:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b75:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b78:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b81:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800b88:	39 c2                	cmp    %eax,%edx
  800b8a:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800b8d:	72 3e                	jb     800bcd <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b8f:	83 ec 0c             	sub    $0xc,%esp
  800b92:	ff 75 18             	push   0x18(%ebp)
  800b95:	83 eb 01             	sub    $0x1,%ebx
  800b98:	53                   	push   %ebx
  800b99:	50                   	push   %eax
  800b9a:	83 ec 08             	sub    $0x8,%esp
  800b9d:	ff 75 e4             	push   -0x1c(%ebp)
  800ba0:	ff 75 e0             	push   -0x20(%ebp)
  800ba3:	ff 75 dc             	push   -0x24(%ebp)
  800ba6:	ff 75 d8             	push   -0x28(%ebp)
  800ba9:	e8 72 29 00 00       	call   803520 <__udivdi3>
  800bae:	83 c4 18             	add    $0x18,%esp
  800bb1:	52                   	push   %edx
  800bb2:	50                   	push   %eax
  800bb3:	89 f2                	mov    %esi,%edx
  800bb5:	89 f8                	mov    %edi,%eax
  800bb7:	e8 9f ff ff ff       	call   800b5b <printnum>
  800bbc:	83 c4 20             	add    $0x20,%esp
  800bbf:	eb 13                	jmp    800bd4 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800bc1:	83 ec 08             	sub    $0x8,%esp
  800bc4:	56                   	push   %esi
  800bc5:	ff 75 18             	push   0x18(%ebp)
  800bc8:	ff d7                	call   *%edi
  800bca:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800bcd:	83 eb 01             	sub    $0x1,%ebx
  800bd0:	85 db                	test   %ebx,%ebx
  800bd2:	7f ed                	jg     800bc1 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800bd4:	83 ec 08             	sub    $0x8,%esp
  800bd7:	56                   	push   %esi
  800bd8:	83 ec 04             	sub    $0x4,%esp
  800bdb:	ff 75 e4             	push   -0x1c(%ebp)
  800bde:	ff 75 e0             	push   -0x20(%ebp)
  800be1:	ff 75 dc             	push   -0x24(%ebp)
  800be4:	ff 75 d8             	push   -0x28(%ebp)
  800be7:	e8 54 2a 00 00       	call   803640 <__umoddi3>
  800bec:	83 c4 14             	add    $0x14,%esp
  800bef:	0f be 80 9b 39 80 00 	movsbl 0x80399b(%eax),%eax
  800bf6:	50                   	push   %eax
  800bf7:	ff d7                	call   *%edi
}
  800bf9:	83 c4 10             	add    $0x10,%esp
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c0a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800c0e:	8b 10                	mov    (%eax),%edx
  800c10:	3b 50 04             	cmp    0x4(%eax),%edx
  800c13:	73 0a                	jae    800c1f <sprintputch+0x1b>
		*b->buf++ = ch;
  800c15:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c18:	89 08                	mov    %ecx,(%eax)
  800c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1d:	88 02                	mov    %al,(%edx)
}
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <printfmt>:
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800c27:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c2a:	50                   	push   %eax
  800c2b:	ff 75 10             	push   0x10(%ebp)
  800c2e:	ff 75 0c             	push   0xc(%ebp)
  800c31:	ff 75 08             	push   0x8(%ebp)
  800c34:	e8 05 00 00 00       	call   800c3e <vprintfmt>
}
  800c39:	83 c4 10             	add    $0x10,%esp
  800c3c:	c9                   	leave  
  800c3d:	c3                   	ret    

00800c3e <vprintfmt>:
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 3c             	sub    $0x3c,%esp
  800c47:	8b 75 08             	mov    0x8(%ebp),%esi
  800c4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c4d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c50:	eb 0a                	jmp    800c5c <vprintfmt+0x1e>
			putch(ch, putdat);
  800c52:	83 ec 08             	sub    $0x8,%esp
  800c55:	53                   	push   %ebx
  800c56:	50                   	push   %eax
  800c57:	ff d6                	call   *%esi
  800c59:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c5c:	83 c7 01             	add    $0x1,%edi
  800c5f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c63:	83 f8 25             	cmp    $0x25,%eax
  800c66:	74 0c                	je     800c74 <vprintfmt+0x36>
			if (ch == '\0')
  800c68:	85 c0                	test   %eax,%eax
  800c6a:	75 e6                	jne    800c52 <vprintfmt+0x14>
}
  800c6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    
		padc = ' ';
  800c74:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800c78:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800c7f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800c86:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800c8d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800c92:	8d 47 01             	lea    0x1(%edi),%eax
  800c95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c98:	0f b6 17             	movzbl (%edi),%edx
  800c9b:	8d 42 dd             	lea    -0x23(%edx),%eax
  800c9e:	3c 55                	cmp    $0x55,%al
  800ca0:	0f 87 bb 03 00 00    	ja     801061 <vprintfmt+0x423>
  800ca6:	0f b6 c0             	movzbl %al,%eax
  800ca9:	ff 24 85 e0 3a 80 00 	jmp    *0x803ae0(,%eax,4)
  800cb0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800cb3:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800cb7:	eb d9                	jmp    800c92 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800cb9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cbc:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800cc0:	eb d0                	jmp    800c92 <vprintfmt+0x54>
  800cc2:	0f b6 d2             	movzbl %dl,%edx
  800cc5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800cc8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ccd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800cd0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800cd3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800cd7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800cda:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800cdd:	83 f9 09             	cmp    $0x9,%ecx
  800ce0:	77 55                	ja     800d37 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800ce2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800ce5:	eb e9                	jmp    800cd0 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800ce7:	8b 45 14             	mov    0x14(%ebp),%eax
  800cea:	8b 00                	mov    (%eax),%eax
  800cec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800cef:	8b 45 14             	mov    0x14(%ebp),%eax
  800cf2:	8d 40 04             	lea    0x4(%eax),%eax
  800cf5:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800cf8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800cfb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800cff:	79 91                	jns    800c92 <vprintfmt+0x54>
				width = precision, precision = -1;
  800d01:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d04:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d07:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800d0e:	eb 82                	jmp    800c92 <vprintfmt+0x54>
  800d10:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800d13:	85 d2                	test   %edx,%edx
  800d15:	b8 00 00 00 00       	mov    $0x0,%eax
  800d1a:	0f 49 c2             	cmovns %edx,%eax
  800d1d:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800d20:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800d23:	e9 6a ff ff ff       	jmp    800c92 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800d28:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800d2b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800d32:	e9 5b ff ff ff       	jmp    800c92 <vprintfmt+0x54>
  800d37:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800d3a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d3d:	eb bc                	jmp    800cfb <vprintfmt+0xbd>
			lflag++;
  800d3f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800d42:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800d45:	e9 48 ff ff ff       	jmp    800c92 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800d4a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d4d:	8d 78 04             	lea    0x4(%eax),%edi
  800d50:	83 ec 08             	sub    $0x8,%esp
  800d53:	53                   	push   %ebx
  800d54:	ff 30                	push   (%eax)
  800d56:	ff d6                	call   *%esi
			break;
  800d58:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800d5b:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800d5e:	e9 9d 02 00 00       	jmp    801000 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800d63:	8b 45 14             	mov    0x14(%ebp),%eax
  800d66:	8d 78 04             	lea    0x4(%eax),%edi
  800d69:	8b 10                	mov    (%eax),%edx
  800d6b:	89 d0                	mov    %edx,%eax
  800d6d:	f7 d8                	neg    %eax
  800d6f:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d72:	83 f8 0f             	cmp    $0xf,%eax
  800d75:	7f 23                	jg     800d9a <vprintfmt+0x15c>
  800d77:	8b 14 85 40 3c 80 00 	mov    0x803c40(,%eax,4),%edx
  800d7e:	85 d2                	test   %edx,%edx
  800d80:	74 18                	je     800d9a <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800d82:	52                   	push   %edx
  800d83:	68 b8 38 80 00       	push   $0x8038b8
  800d88:	53                   	push   %ebx
  800d89:	56                   	push   %esi
  800d8a:	e8 92 fe ff ff       	call   800c21 <printfmt>
  800d8f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800d92:	89 7d 14             	mov    %edi,0x14(%ebp)
  800d95:	e9 66 02 00 00       	jmp    801000 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800d9a:	50                   	push   %eax
  800d9b:	68 b3 39 80 00       	push   $0x8039b3
  800da0:	53                   	push   %ebx
  800da1:	56                   	push   %esi
  800da2:	e8 7a fe ff ff       	call   800c21 <printfmt>
  800da7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800daa:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800dad:	e9 4e 02 00 00       	jmp    801000 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800db2:	8b 45 14             	mov    0x14(%ebp),%eax
  800db5:	83 c0 04             	add    $0x4,%eax
  800db8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800dbb:	8b 45 14             	mov    0x14(%ebp),%eax
  800dbe:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800dc0:	85 d2                	test   %edx,%edx
  800dc2:	b8 ac 39 80 00       	mov    $0x8039ac,%eax
  800dc7:	0f 45 c2             	cmovne %edx,%eax
  800dca:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800dcd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800dd1:	7e 06                	jle    800dd9 <vprintfmt+0x19b>
  800dd3:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800dd7:	75 0d                	jne    800de6 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800dd9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ddc:	89 c7                	mov    %eax,%edi
  800dde:	03 45 e0             	add    -0x20(%ebp),%eax
  800de1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800de4:	eb 55                	jmp    800e3b <vprintfmt+0x1fd>
  800de6:	83 ec 08             	sub    $0x8,%esp
  800de9:	ff 75 d8             	push   -0x28(%ebp)
  800dec:	ff 75 cc             	push   -0x34(%ebp)
  800def:	e8 fa 03 00 00       	call   8011ee <strnlen>
  800df4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800df7:	29 c1                	sub    %eax,%ecx
  800df9:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800dfc:	83 c4 10             	add    $0x10,%esp
  800dff:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800e01:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800e05:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800e08:	eb 0f                	jmp    800e19 <vprintfmt+0x1db>
					putch(padc, putdat);
  800e0a:	83 ec 08             	sub    $0x8,%esp
  800e0d:	53                   	push   %ebx
  800e0e:	ff 75 e0             	push   -0x20(%ebp)
  800e11:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800e13:	83 ef 01             	sub    $0x1,%edi
  800e16:	83 c4 10             	add    $0x10,%esp
  800e19:	85 ff                	test   %edi,%edi
  800e1b:	7f ed                	jg     800e0a <vprintfmt+0x1cc>
  800e1d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800e20:	85 d2                	test   %edx,%edx
  800e22:	b8 00 00 00 00       	mov    $0x0,%eax
  800e27:	0f 49 c2             	cmovns %edx,%eax
  800e2a:	29 c2                	sub    %eax,%edx
  800e2c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800e2f:	eb a8                	jmp    800dd9 <vprintfmt+0x19b>
					putch(ch, putdat);
  800e31:	83 ec 08             	sub    $0x8,%esp
  800e34:	53                   	push   %ebx
  800e35:	52                   	push   %edx
  800e36:	ff d6                	call   *%esi
  800e38:	83 c4 10             	add    $0x10,%esp
  800e3b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800e3e:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e40:	83 c7 01             	add    $0x1,%edi
  800e43:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e47:	0f be d0             	movsbl %al,%edx
  800e4a:	85 d2                	test   %edx,%edx
  800e4c:	74 4b                	je     800e99 <vprintfmt+0x25b>
  800e4e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e52:	78 06                	js     800e5a <vprintfmt+0x21c>
  800e54:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800e58:	78 1e                	js     800e78 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800e5a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800e5e:	74 d1                	je     800e31 <vprintfmt+0x1f3>
  800e60:	0f be c0             	movsbl %al,%eax
  800e63:	83 e8 20             	sub    $0x20,%eax
  800e66:	83 f8 5e             	cmp    $0x5e,%eax
  800e69:	76 c6                	jbe    800e31 <vprintfmt+0x1f3>
					putch('?', putdat);
  800e6b:	83 ec 08             	sub    $0x8,%esp
  800e6e:	53                   	push   %ebx
  800e6f:	6a 3f                	push   $0x3f
  800e71:	ff d6                	call   *%esi
  800e73:	83 c4 10             	add    $0x10,%esp
  800e76:	eb c3                	jmp    800e3b <vprintfmt+0x1fd>
  800e78:	89 cf                	mov    %ecx,%edi
  800e7a:	eb 0e                	jmp    800e8a <vprintfmt+0x24c>
				putch(' ', putdat);
  800e7c:	83 ec 08             	sub    $0x8,%esp
  800e7f:	53                   	push   %ebx
  800e80:	6a 20                	push   $0x20
  800e82:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800e84:	83 ef 01             	sub    $0x1,%edi
  800e87:	83 c4 10             	add    $0x10,%esp
  800e8a:	85 ff                	test   %edi,%edi
  800e8c:	7f ee                	jg     800e7c <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800e8e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800e91:	89 45 14             	mov    %eax,0x14(%ebp)
  800e94:	e9 67 01 00 00       	jmp    801000 <vprintfmt+0x3c2>
  800e99:	89 cf                	mov    %ecx,%edi
  800e9b:	eb ed                	jmp    800e8a <vprintfmt+0x24c>
	if (lflag >= 2)
  800e9d:	83 f9 01             	cmp    $0x1,%ecx
  800ea0:	7f 1b                	jg     800ebd <vprintfmt+0x27f>
	else if (lflag)
  800ea2:	85 c9                	test   %ecx,%ecx
  800ea4:	74 63                	je     800f09 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800ea6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ea9:	8b 00                	mov    (%eax),%eax
  800eab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800eae:	99                   	cltd   
  800eaf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800eb2:	8b 45 14             	mov    0x14(%ebp),%eax
  800eb5:	8d 40 04             	lea    0x4(%eax),%eax
  800eb8:	89 45 14             	mov    %eax,0x14(%ebp)
  800ebb:	eb 17                	jmp    800ed4 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800ebd:	8b 45 14             	mov    0x14(%ebp),%eax
  800ec0:	8b 50 04             	mov    0x4(%eax),%edx
  800ec3:	8b 00                	mov    (%eax),%eax
  800ec5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ec8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ecb:	8b 45 14             	mov    0x14(%ebp),%eax
  800ece:	8d 40 08             	lea    0x8(%eax),%eax
  800ed1:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800ed4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ed7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800eda:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800edf:	85 c9                	test   %ecx,%ecx
  800ee1:	0f 89 ff 00 00 00    	jns    800fe6 <vprintfmt+0x3a8>
				putch('-', putdat);
  800ee7:	83 ec 08             	sub    $0x8,%esp
  800eea:	53                   	push   %ebx
  800eeb:	6a 2d                	push   $0x2d
  800eed:	ff d6                	call   *%esi
				num = -(long long) num;
  800eef:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ef2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800ef5:	f7 da                	neg    %edx
  800ef7:	83 d1 00             	adc    $0x0,%ecx
  800efa:	f7 d9                	neg    %ecx
  800efc:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800eff:	bf 0a 00 00 00       	mov    $0xa,%edi
  800f04:	e9 dd 00 00 00       	jmp    800fe6 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800f09:	8b 45 14             	mov    0x14(%ebp),%eax
  800f0c:	8b 00                	mov    (%eax),%eax
  800f0e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f11:	99                   	cltd   
  800f12:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800f15:	8b 45 14             	mov    0x14(%ebp),%eax
  800f18:	8d 40 04             	lea    0x4(%eax),%eax
  800f1b:	89 45 14             	mov    %eax,0x14(%ebp)
  800f1e:	eb b4                	jmp    800ed4 <vprintfmt+0x296>
	if (lflag >= 2)
  800f20:	83 f9 01             	cmp    $0x1,%ecx
  800f23:	7f 1e                	jg     800f43 <vprintfmt+0x305>
	else if (lflag)
  800f25:	85 c9                	test   %ecx,%ecx
  800f27:	74 32                	je     800f5b <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800f29:	8b 45 14             	mov    0x14(%ebp),%eax
  800f2c:	8b 10                	mov    (%eax),%edx
  800f2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f33:	8d 40 04             	lea    0x4(%eax),%eax
  800f36:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800f39:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800f3e:	e9 a3 00 00 00       	jmp    800fe6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800f43:	8b 45 14             	mov    0x14(%ebp),%eax
  800f46:	8b 10                	mov    (%eax),%edx
  800f48:	8b 48 04             	mov    0x4(%eax),%ecx
  800f4b:	8d 40 08             	lea    0x8(%eax),%eax
  800f4e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800f51:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800f56:	e9 8b 00 00 00       	jmp    800fe6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800f5b:	8b 45 14             	mov    0x14(%ebp),%eax
  800f5e:	8b 10                	mov    (%eax),%edx
  800f60:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f65:	8d 40 04             	lea    0x4(%eax),%eax
  800f68:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800f6b:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800f70:	eb 74                	jmp    800fe6 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800f72:	83 f9 01             	cmp    $0x1,%ecx
  800f75:	7f 1b                	jg     800f92 <vprintfmt+0x354>
	else if (lflag)
  800f77:	85 c9                	test   %ecx,%ecx
  800f79:	74 2c                	je     800fa7 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800f7b:	8b 45 14             	mov    0x14(%ebp),%eax
  800f7e:	8b 10                	mov    (%eax),%edx
  800f80:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f85:	8d 40 04             	lea    0x4(%eax),%eax
  800f88:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800f8b:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800f90:	eb 54                	jmp    800fe6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800f92:	8b 45 14             	mov    0x14(%ebp),%eax
  800f95:	8b 10                	mov    (%eax),%edx
  800f97:	8b 48 04             	mov    0x4(%eax),%ecx
  800f9a:	8d 40 08             	lea    0x8(%eax),%eax
  800f9d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800fa0:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800fa5:	eb 3f                	jmp    800fe6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800fa7:	8b 45 14             	mov    0x14(%ebp),%eax
  800faa:	8b 10                	mov    (%eax),%edx
  800fac:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fb1:	8d 40 04             	lea    0x4(%eax),%eax
  800fb4:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800fb7:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800fbc:	eb 28                	jmp    800fe6 <vprintfmt+0x3a8>
			putch('0', putdat);
  800fbe:	83 ec 08             	sub    $0x8,%esp
  800fc1:	53                   	push   %ebx
  800fc2:	6a 30                	push   $0x30
  800fc4:	ff d6                	call   *%esi
			putch('x', putdat);
  800fc6:	83 c4 08             	add    $0x8,%esp
  800fc9:	53                   	push   %ebx
  800fca:	6a 78                	push   $0x78
  800fcc:	ff d6                	call   *%esi
			num = (unsigned long long)
  800fce:	8b 45 14             	mov    0x14(%ebp),%eax
  800fd1:	8b 10                	mov    (%eax),%edx
  800fd3:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800fd8:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800fdb:	8d 40 04             	lea    0x4(%eax),%eax
  800fde:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800fe1:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800fe6:	83 ec 0c             	sub    $0xc,%esp
  800fe9:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800fed:	50                   	push   %eax
  800fee:	ff 75 e0             	push   -0x20(%ebp)
  800ff1:	57                   	push   %edi
  800ff2:	51                   	push   %ecx
  800ff3:	52                   	push   %edx
  800ff4:	89 da                	mov    %ebx,%edx
  800ff6:	89 f0                	mov    %esi,%eax
  800ff8:	e8 5e fb ff ff       	call   800b5b <printnum>
			break;
  800ffd:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801000:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801003:	e9 54 fc ff ff       	jmp    800c5c <vprintfmt+0x1e>
	if (lflag >= 2)
  801008:	83 f9 01             	cmp    $0x1,%ecx
  80100b:	7f 1b                	jg     801028 <vprintfmt+0x3ea>
	else if (lflag)
  80100d:	85 c9                	test   %ecx,%ecx
  80100f:	74 2c                	je     80103d <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801011:	8b 45 14             	mov    0x14(%ebp),%eax
  801014:	8b 10                	mov    (%eax),%edx
  801016:	b9 00 00 00 00       	mov    $0x0,%ecx
  80101b:	8d 40 04             	lea    0x4(%eax),%eax
  80101e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801021:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801026:	eb be                	jmp    800fe6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801028:	8b 45 14             	mov    0x14(%ebp),%eax
  80102b:	8b 10                	mov    (%eax),%edx
  80102d:	8b 48 04             	mov    0x4(%eax),%ecx
  801030:	8d 40 08             	lea    0x8(%eax),%eax
  801033:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801036:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80103b:	eb a9                	jmp    800fe6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80103d:	8b 45 14             	mov    0x14(%ebp),%eax
  801040:	8b 10                	mov    (%eax),%edx
  801042:	b9 00 00 00 00       	mov    $0x0,%ecx
  801047:	8d 40 04             	lea    0x4(%eax),%eax
  80104a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80104d:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  801052:	eb 92                	jmp    800fe6 <vprintfmt+0x3a8>
			putch(ch, putdat);
  801054:	83 ec 08             	sub    $0x8,%esp
  801057:	53                   	push   %ebx
  801058:	6a 25                	push   $0x25
  80105a:	ff d6                	call   *%esi
			break;
  80105c:	83 c4 10             	add    $0x10,%esp
  80105f:	eb 9f                	jmp    801000 <vprintfmt+0x3c2>
			putch('%', putdat);
  801061:	83 ec 08             	sub    $0x8,%esp
  801064:	53                   	push   %ebx
  801065:	6a 25                	push   $0x25
  801067:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801069:	83 c4 10             	add    $0x10,%esp
  80106c:	89 f8                	mov    %edi,%eax
  80106e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801072:	74 05                	je     801079 <vprintfmt+0x43b>
  801074:	83 e8 01             	sub    $0x1,%eax
  801077:	eb f5                	jmp    80106e <vprintfmt+0x430>
  801079:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80107c:	eb 82                	jmp    801000 <vprintfmt+0x3c2>

0080107e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	83 ec 18             	sub    $0x18,%esp
  801084:	8b 45 08             	mov    0x8(%ebp),%eax
  801087:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80108a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80108d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801091:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801094:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80109b:	85 c0                	test   %eax,%eax
  80109d:	74 26                	je     8010c5 <vsnprintf+0x47>
  80109f:	85 d2                	test   %edx,%edx
  8010a1:	7e 22                	jle    8010c5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8010a3:	ff 75 14             	push   0x14(%ebp)
  8010a6:	ff 75 10             	push   0x10(%ebp)
  8010a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8010ac:	50                   	push   %eax
  8010ad:	68 04 0c 80 00       	push   $0x800c04
  8010b2:	e8 87 fb ff ff       	call   800c3e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8010b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8010ba:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8010bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c0:	83 c4 10             	add    $0x10,%esp
}
  8010c3:	c9                   	leave  
  8010c4:	c3                   	ret    
		return -E_INVAL;
  8010c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010ca:	eb f7                	jmp    8010c3 <vsnprintf+0x45>

008010cc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8010d2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8010d5:	50                   	push   %eax
  8010d6:	ff 75 10             	push   0x10(%ebp)
  8010d9:	ff 75 0c             	push   0xc(%ebp)
  8010dc:	ff 75 08             	push   0x8(%ebp)
  8010df:	e8 9a ff ff ff       	call   80107e <vsnprintf>
	va_end(ap);

	return rc;
}
  8010e4:	c9                   	leave  
  8010e5:	c3                   	ret    

008010e6 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	57                   	push   %edi
  8010ea:	56                   	push   %esi
  8010eb:	53                   	push   %ebx
  8010ec:	83 ec 0c             	sub    $0xc,%esp
  8010ef:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	74 13                	je     801109 <readline+0x23>
		fprintf(1, "%s", prompt);
  8010f6:	83 ec 04             	sub    $0x4,%esp
  8010f9:	50                   	push   %eax
  8010fa:	68 b8 38 80 00       	push   $0x8038b8
  8010ff:	6a 01                	push   $0x1
  801101:	e8 f7 13 00 00       	call   8024fd <fprintf>
  801106:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  801109:	83 ec 0c             	sub    $0xc,%esp
  80110c:	6a 00                	push   $0x0
  80110e:	e8 78 f8 ff ff       	call   80098b <iscons>
  801113:	89 c7                	mov    %eax,%edi
  801115:	83 c4 10             	add    $0x10,%esp
	i = 0;
  801118:	be 00 00 00 00       	mov    $0x0,%esi
  80111d:	eb 4b                	jmp    80116a <readline+0x84>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  80111f:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
  801124:	83 fb f8             	cmp    $0xfffffff8,%ebx
  801127:	75 08                	jne    801131 <readline+0x4b>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  801129:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112c:	5b                   	pop    %ebx
  80112d:	5e                   	pop    %esi
  80112e:	5f                   	pop    %edi
  80112f:	5d                   	pop    %ebp
  801130:	c3                   	ret    
				cprintf("read error: %e\n", c);
  801131:	83 ec 08             	sub    $0x8,%esp
  801134:	53                   	push   %ebx
  801135:	68 9f 3c 80 00       	push   $0x803c9f
  80113a:	e8 08 fa ff ff       	call   800b47 <cprintf>
  80113f:	83 c4 10             	add    $0x10,%esp
			return NULL;
  801142:	b8 00 00 00 00       	mov    $0x0,%eax
  801147:	eb e0                	jmp    801129 <readline+0x43>
			if (echoing)
  801149:	85 ff                	test   %edi,%edi
  80114b:	75 05                	jne    801152 <readline+0x6c>
			i--;
  80114d:	83 ee 01             	sub    $0x1,%esi
  801150:	eb 18                	jmp    80116a <readline+0x84>
				cputchar('\b');
  801152:	83 ec 0c             	sub    $0xc,%esp
  801155:	6a 08                	push   $0x8
  801157:	e8 ea f7 ff ff       	call   800946 <cputchar>
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	eb ec                	jmp    80114d <readline+0x67>
			buf[i++] = c;
  801161:	88 9e 20 60 80 00    	mov    %bl,0x806020(%esi)
  801167:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
  80116a:	e8 f3 f7 ff ff       	call   800962 <getchar>
  80116f:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  801171:	85 c0                	test   %eax,%eax
  801173:	78 aa                	js     80111f <readline+0x39>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  801175:	83 f8 08             	cmp    $0x8,%eax
  801178:	0f 94 c0             	sete   %al
  80117b:	83 fb 7f             	cmp    $0x7f,%ebx
  80117e:	0f 94 c2             	sete   %dl
  801181:	08 d0                	or     %dl,%al
  801183:	74 04                	je     801189 <readline+0xa3>
  801185:	85 f6                	test   %esi,%esi
  801187:	7f c0                	jg     801149 <readline+0x63>
		} else if (c >= ' ' && i < BUFLEN-1) {
  801189:	83 fb 1f             	cmp    $0x1f,%ebx
  80118c:	7e 1a                	jle    8011a8 <readline+0xc2>
  80118e:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  801194:	7f 12                	jg     8011a8 <readline+0xc2>
			if (echoing)
  801196:	85 ff                	test   %edi,%edi
  801198:	74 c7                	je     801161 <readline+0x7b>
				cputchar(c);
  80119a:	83 ec 0c             	sub    $0xc,%esp
  80119d:	53                   	push   %ebx
  80119e:	e8 a3 f7 ff ff       	call   800946 <cputchar>
  8011a3:	83 c4 10             	add    $0x10,%esp
  8011a6:	eb b9                	jmp    801161 <readline+0x7b>
		} else if (c == '\n' || c == '\r') {
  8011a8:	83 fb 0a             	cmp    $0xa,%ebx
  8011ab:	74 05                	je     8011b2 <readline+0xcc>
  8011ad:	83 fb 0d             	cmp    $0xd,%ebx
  8011b0:	75 b8                	jne    80116a <readline+0x84>
			if (echoing)
  8011b2:	85 ff                	test   %edi,%edi
  8011b4:	75 11                	jne    8011c7 <readline+0xe1>
			buf[i] = 0;
  8011b6:	c6 86 20 60 80 00 00 	movb   $0x0,0x806020(%esi)
			return buf;
  8011bd:	b8 20 60 80 00       	mov    $0x806020,%eax
  8011c2:	e9 62 ff ff ff       	jmp    801129 <readline+0x43>
				cputchar('\n');
  8011c7:	83 ec 0c             	sub    $0xc,%esp
  8011ca:	6a 0a                	push   $0xa
  8011cc:	e8 75 f7 ff ff       	call   800946 <cputchar>
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	eb e0                	jmp    8011b6 <readline+0xd0>

008011d6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8011dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e1:	eb 03                	jmp    8011e6 <strlen+0x10>
		n++;
  8011e3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8011e6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8011ea:	75 f7                	jne    8011e3 <strlen+0xd>
	return n;
}
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011fc:	eb 03                	jmp    801201 <strnlen+0x13>
		n++;
  8011fe:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801201:	39 d0                	cmp    %edx,%eax
  801203:	74 08                	je     80120d <strnlen+0x1f>
  801205:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801209:	75 f3                	jne    8011fe <strnlen+0x10>
  80120b:	89 c2                	mov    %eax,%edx
	return n;
}
  80120d:	89 d0                	mov    %edx,%eax
  80120f:	5d                   	pop    %ebp
  801210:	c3                   	ret    

00801211 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	53                   	push   %ebx
  801215:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801218:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80121b:	b8 00 00 00 00       	mov    $0x0,%eax
  801220:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801224:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801227:	83 c0 01             	add    $0x1,%eax
  80122a:	84 d2                	test   %dl,%dl
  80122c:	75 f2                	jne    801220 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80122e:	89 c8                	mov    %ecx,%eax
  801230:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801233:	c9                   	leave  
  801234:	c3                   	ret    

00801235 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	53                   	push   %ebx
  801239:	83 ec 10             	sub    $0x10,%esp
  80123c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80123f:	53                   	push   %ebx
  801240:	e8 91 ff ff ff       	call   8011d6 <strlen>
  801245:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801248:	ff 75 0c             	push   0xc(%ebp)
  80124b:	01 d8                	add    %ebx,%eax
  80124d:	50                   	push   %eax
  80124e:	e8 be ff ff ff       	call   801211 <strcpy>
	return dst;
}
  801253:	89 d8                	mov    %ebx,%eax
  801255:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801258:	c9                   	leave  
  801259:	c3                   	ret    

0080125a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	56                   	push   %esi
  80125e:	53                   	push   %ebx
  80125f:	8b 75 08             	mov    0x8(%ebp),%esi
  801262:	8b 55 0c             	mov    0xc(%ebp),%edx
  801265:	89 f3                	mov    %esi,%ebx
  801267:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80126a:	89 f0                	mov    %esi,%eax
  80126c:	eb 0f                	jmp    80127d <strncpy+0x23>
		*dst++ = *src;
  80126e:	83 c0 01             	add    $0x1,%eax
  801271:	0f b6 0a             	movzbl (%edx),%ecx
  801274:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801277:	80 f9 01             	cmp    $0x1,%cl
  80127a:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80127d:	39 d8                	cmp    %ebx,%eax
  80127f:	75 ed                	jne    80126e <strncpy+0x14>
	}
	return ret;
}
  801281:	89 f0                	mov    %esi,%eax
  801283:	5b                   	pop    %ebx
  801284:	5e                   	pop    %esi
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    

00801287 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	56                   	push   %esi
  80128b:	53                   	push   %ebx
  80128c:	8b 75 08             	mov    0x8(%ebp),%esi
  80128f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801292:	8b 55 10             	mov    0x10(%ebp),%edx
  801295:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801297:	85 d2                	test   %edx,%edx
  801299:	74 21                	je     8012bc <strlcpy+0x35>
  80129b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80129f:	89 f2                	mov    %esi,%edx
  8012a1:	eb 09                	jmp    8012ac <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8012a3:	83 c1 01             	add    $0x1,%ecx
  8012a6:	83 c2 01             	add    $0x1,%edx
  8012a9:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8012ac:	39 c2                	cmp    %eax,%edx
  8012ae:	74 09                	je     8012b9 <strlcpy+0x32>
  8012b0:	0f b6 19             	movzbl (%ecx),%ebx
  8012b3:	84 db                	test   %bl,%bl
  8012b5:	75 ec                	jne    8012a3 <strlcpy+0x1c>
  8012b7:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8012b9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8012bc:	29 f0                	sub    %esi,%eax
}
  8012be:	5b                   	pop    %ebx
  8012bf:	5e                   	pop    %esi
  8012c0:	5d                   	pop    %ebp
  8012c1:	c3                   	ret    

008012c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8012cb:	eb 06                	jmp    8012d3 <strcmp+0x11>
		p++, q++;
  8012cd:	83 c1 01             	add    $0x1,%ecx
  8012d0:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8012d3:	0f b6 01             	movzbl (%ecx),%eax
  8012d6:	84 c0                	test   %al,%al
  8012d8:	74 04                	je     8012de <strcmp+0x1c>
  8012da:	3a 02                	cmp    (%edx),%al
  8012dc:	74 ef                	je     8012cd <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8012de:	0f b6 c0             	movzbl %al,%eax
  8012e1:	0f b6 12             	movzbl (%edx),%edx
  8012e4:	29 d0                	sub    %edx,%eax
}
  8012e6:	5d                   	pop    %ebp
  8012e7:	c3                   	ret    

008012e8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
  8012eb:	53                   	push   %ebx
  8012ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f2:	89 c3                	mov    %eax,%ebx
  8012f4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8012f7:	eb 06                	jmp    8012ff <strncmp+0x17>
		n--, p++, q++;
  8012f9:	83 c0 01             	add    $0x1,%eax
  8012fc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8012ff:	39 d8                	cmp    %ebx,%eax
  801301:	74 18                	je     80131b <strncmp+0x33>
  801303:	0f b6 08             	movzbl (%eax),%ecx
  801306:	84 c9                	test   %cl,%cl
  801308:	74 04                	je     80130e <strncmp+0x26>
  80130a:	3a 0a                	cmp    (%edx),%cl
  80130c:	74 eb                	je     8012f9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80130e:	0f b6 00             	movzbl (%eax),%eax
  801311:	0f b6 12             	movzbl (%edx),%edx
  801314:	29 d0                	sub    %edx,%eax
}
  801316:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801319:	c9                   	leave  
  80131a:	c3                   	ret    
		return 0;
  80131b:	b8 00 00 00 00       	mov    $0x0,%eax
  801320:	eb f4                	jmp    801316 <strncmp+0x2e>

00801322 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	8b 45 08             	mov    0x8(%ebp),%eax
  801328:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80132c:	eb 03                	jmp    801331 <strchr+0xf>
  80132e:	83 c0 01             	add    $0x1,%eax
  801331:	0f b6 10             	movzbl (%eax),%edx
  801334:	84 d2                	test   %dl,%dl
  801336:	74 06                	je     80133e <strchr+0x1c>
		if (*s == c)
  801338:	38 ca                	cmp    %cl,%dl
  80133a:	75 f2                	jne    80132e <strchr+0xc>
  80133c:	eb 05                	jmp    801343 <strchr+0x21>
			return (char *) s;
	return 0;
  80133e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    

00801345 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	8b 45 08             	mov    0x8(%ebp),%eax
  80134b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80134f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801352:	38 ca                	cmp    %cl,%dl
  801354:	74 09                	je     80135f <strfind+0x1a>
  801356:	84 d2                	test   %dl,%dl
  801358:	74 05                	je     80135f <strfind+0x1a>
	for (; *s; s++)
  80135a:	83 c0 01             	add    $0x1,%eax
  80135d:	eb f0                	jmp    80134f <strfind+0xa>
			break;
	return (char *) s;
}
  80135f:	5d                   	pop    %ebp
  801360:	c3                   	ret    

00801361 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	57                   	push   %edi
  801365:	56                   	push   %esi
  801366:	53                   	push   %ebx
  801367:	8b 7d 08             	mov    0x8(%ebp),%edi
  80136a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80136d:	85 c9                	test   %ecx,%ecx
  80136f:	74 2f                	je     8013a0 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801371:	89 f8                	mov    %edi,%eax
  801373:	09 c8                	or     %ecx,%eax
  801375:	a8 03                	test   $0x3,%al
  801377:	75 21                	jne    80139a <memset+0x39>
		c &= 0xFF;
  801379:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80137d:	89 d0                	mov    %edx,%eax
  80137f:	c1 e0 08             	shl    $0x8,%eax
  801382:	89 d3                	mov    %edx,%ebx
  801384:	c1 e3 18             	shl    $0x18,%ebx
  801387:	89 d6                	mov    %edx,%esi
  801389:	c1 e6 10             	shl    $0x10,%esi
  80138c:	09 f3                	or     %esi,%ebx
  80138e:	09 da                	or     %ebx,%edx
  801390:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801392:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801395:	fc                   	cld    
  801396:	f3 ab                	rep stos %eax,%es:(%edi)
  801398:	eb 06                	jmp    8013a0 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80139a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80139d:	fc                   	cld    
  80139e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8013a0:	89 f8                	mov    %edi,%eax
  8013a2:	5b                   	pop    %ebx
  8013a3:	5e                   	pop    %esi
  8013a4:	5f                   	pop    %edi
  8013a5:	5d                   	pop    %ebp
  8013a6:	c3                   	ret    

008013a7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	57                   	push   %edi
  8013ab:	56                   	push   %esi
  8013ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8013af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8013b5:	39 c6                	cmp    %eax,%esi
  8013b7:	73 32                	jae    8013eb <memmove+0x44>
  8013b9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8013bc:	39 c2                	cmp    %eax,%edx
  8013be:	76 2b                	jbe    8013eb <memmove+0x44>
		s += n;
		d += n;
  8013c0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013c3:	89 d6                	mov    %edx,%esi
  8013c5:	09 fe                	or     %edi,%esi
  8013c7:	09 ce                	or     %ecx,%esi
  8013c9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8013cf:	75 0e                	jne    8013df <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8013d1:	83 ef 04             	sub    $0x4,%edi
  8013d4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8013d7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8013da:	fd                   	std    
  8013db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013dd:	eb 09                	jmp    8013e8 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8013df:	83 ef 01             	sub    $0x1,%edi
  8013e2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8013e5:	fd                   	std    
  8013e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8013e8:	fc                   	cld    
  8013e9:	eb 1a                	jmp    801405 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013eb:	89 f2                	mov    %esi,%edx
  8013ed:	09 c2                	or     %eax,%edx
  8013ef:	09 ca                	or     %ecx,%edx
  8013f1:	f6 c2 03             	test   $0x3,%dl
  8013f4:	75 0a                	jne    801400 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8013f6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8013f9:	89 c7                	mov    %eax,%edi
  8013fb:	fc                   	cld    
  8013fc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013fe:	eb 05                	jmp    801405 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801400:	89 c7                	mov    %eax,%edi
  801402:	fc                   	cld    
  801403:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801405:	5e                   	pop    %esi
  801406:	5f                   	pop    %edi
  801407:	5d                   	pop    %ebp
  801408:	c3                   	ret    

00801409 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801409:	55                   	push   %ebp
  80140a:	89 e5                	mov    %esp,%ebp
  80140c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80140f:	ff 75 10             	push   0x10(%ebp)
  801412:	ff 75 0c             	push   0xc(%ebp)
  801415:	ff 75 08             	push   0x8(%ebp)
  801418:	e8 8a ff ff ff       	call   8013a7 <memmove>
}
  80141d:	c9                   	leave  
  80141e:	c3                   	ret    

0080141f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	56                   	push   %esi
  801423:	53                   	push   %ebx
  801424:	8b 45 08             	mov    0x8(%ebp),%eax
  801427:	8b 55 0c             	mov    0xc(%ebp),%edx
  80142a:	89 c6                	mov    %eax,%esi
  80142c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80142f:	eb 06                	jmp    801437 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801431:	83 c0 01             	add    $0x1,%eax
  801434:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801437:	39 f0                	cmp    %esi,%eax
  801439:	74 14                	je     80144f <memcmp+0x30>
		if (*s1 != *s2)
  80143b:	0f b6 08             	movzbl (%eax),%ecx
  80143e:	0f b6 1a             	movzbl (%edx),%ebx
  801441:	38 d9                	cmp    %bl,%cl
  801443:	74 ec                	je     801431 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801445:	0f b6 c1             	movzbl %cl,%eax
  801448:	0f b6 db             	movzbl %bl,%ebx
  80144b:	29 d8                	sub    %ebx,%eax
  80144d:	eb 05                	jmp    801454 <memcmp+0x35>
	}

	return 0;
  80144f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801454:	5b                   	pop    %ebx
  801455:	5e                   	pop    %esi
  801456:	5d                   	pop    %ebp
  801457:	c3                   	ret    

00801458 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	8b 45 08             	mov    0x8(%ebp),%eax
  80145e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801461:	89 c2                	mov    %eax,%edx
  801463:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801466:	eb 03                	jmp    80146b <memfind+0x13>
  801468:	83 c0 01             	add    $0x1,%eax
  80146b:	39 d0                	cmp    %edx,%eax
  80146d:	73 04                	jae    801473 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80146f:	38 08                	cmp    %cl,(%eax)
  801471:	75 f5                	jne    801468 <memfind+0x10>
			break;
	return (void *) s;
}
  801473:	5d                   	pop    %ebp
  801474:	c3                   	ret    

00801475 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	57                   	push   %edi
  801479:	56                   	push   %esi
  80147a:	53                   	push   %ebx
  80147b:	8b 55 08             	mov    0x8(%ebp),%edx
  80147e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801481:	eb 03                	jmp    801486 <strtol+0x11>
		s++;
  801483:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801486:	0f b6 02             	movzbl (%edx),%eax
  801489:	3c 20                	cmp    $0x20,%al
  80148b:	74 f6                	je     801483 <strtol+0xe>
  80148d:	3c 09                	cmp    $0x9,%al
  80148f:	74 f2                	je     801483 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801491:	3c 2b                	cmp    $0x2b,%al
  801493:	74 2a                	je     8014bf <strtol+0x4a>
	int neg = 0;
  801495:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80149a:	3c 2d                	cmp    $0x2d,%al
  80149c:	74 2b                	je     8014c9 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80149e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8014a4:	75 0f                	jne    8014b5 <strtol+0x40>
  8014a6:	80 3a 30             	cmpb   $0x30,(%edx)
  8014a9:	74 28                	je     8014d3 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8014ab:	85 db                	test   %ebx,%ebx
  8014ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014b2:	0f 44 d8             	cmove  %eax,%ebx
  8014b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014ba:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8014bd:	eb 46                	jmp    801505 <strtol+0x90>
		s++;
  8014bf:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8014c2:	bf 00 00 00 00       	mov    $0x0,%edi
  8014c7:	eb d5                	jmp    80149e <strtol+0x29>
		s++, neg = 1;
  8014c9:	83 c2 01             	add    $0x1,%edx
  8014cc:	bf 01 00 00 00       	mov    $0x1,%edi
  8014d1:	eb cb                	jmp    80149e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8014d3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8014d7:	74 0e                	je     8014e7 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8014d9:	85 db                	test   %ebx,%ebx
  8014db:	75 d8                	jne    8014b5 <strtol+0x40>
		s++, base = 8;
  8014dd:	83 c2 01             	add    $0x1,%edx
  8014e0:	bb 08 00 00 00       	mov    $0x8,%ebx
  8014e5:	eb ce                	jmp    8014b5 <strtol+0x40>
		s += 2, base = 16;
  8014e7:	83 c2 02             	add    $0x2,%edx
  8014ea:	bb 10 00 00 00       	mov    $0x10,%ebx
  8014ef:	eb c4                	jmp    8014b5 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8014f1:	0f be c0             	movsbl %al,%eax
  8014f4:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8014f7:	3b 45 10             	cmp    0x10(%ebp),%eax
  8014fa:	7d 3a                	jge    801536 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  8014fc:	83 c2 01             	add    $0x1,%edx
  8014ff:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801503:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801505:	0f b6 02             	movzbl (%edx),%eax
  801508:	8d 70 d0             	lea    -0x30(%eax),%esi
  80150b:	89 f3                	mov    %esi,%ebx
  80150d:	80 fb 09             	cmp    $0x9,%bl
  801510:	76 df                	jbe    8014f1 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801512:	8d 70 9f             	lea    -0x61(%eax),%esi
  801515:	89 f3                	mov    %esi,%ebx
  801517:	80 fb 19             	cmp    $0x19,%bl
  80151a:	77 08                	ja     801524 <strtol+0xaf>
			dig = *s - 'a' + 10;
  80151c:	0f be c0             	movsbl %al,%eax
  80151f:	83 e8 57             	sub    $0x57,%eax
  801522:	eb d3                	jmp    8014f7 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801524:	8d 70 bf             	lea    -0x41(%eax),%esi
  801527:	89 f3                	mov    %esi,%ebx
  801529:	80 fb 19             	cmp    $0x19,%bl
  80152c:	77 08                	ja     801536 <strtol+0xc1>
			dig = *s - 'A' + 10;
  80152e:	0f be c0             	movsbl %al,%eax
  801531:	83 e8 37             	sub    $0x37,%eax
  801534:	eb c1                	jmp    8014f7 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801536:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80153a:	74 05                	je     801541 <strtol+0xcc>
		*endptr = (char *) s;
  80153c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153f:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801541:	89 c8                	mov    %ecx,%eax
  801543:	f7 d8                	neg    %eax
  801545:	85 ff                	test   %edi,%edi
  801547:	0f 45 c8             	cmovne %eax,%ecx
}
  80154a:	89 c8                	mov    %ecx,%eax
  80154c:	5b                   	pop    %ebx
  80154d:	5e                   	pop    %esi
  80154e:	5f                   	pop    %edi
  80154f:	5d                   	pop    %ebp
  801550:	c3                   	ret    

00801551 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	57                   	push   %edi
  801555:	56                   	push   %esi
  801556:	53                   	push   %ebx
	asm volatile("int %1\n"
  801557:	b8 00 00 00 00       	mov    $0x0,%eax
  80155c:	8b 55 08             	mov    0x8(%ebp),%edx
  80155f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801562:	89 c3                	mov    %eax,%ebx
  801564:	89 c7                	mov    %eax,%edi
  801566:	89 c6                	mov    %eax,%esi
  801568:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80156a:	5b                   	pop    %ebx
  80156b:	5e                   	pop    %esi
  80156c:	5f                   	pop    %edi
  80156d:	5d                   	pop    %ebp
  80156e:	c3                   	ret    

0080156f <sys_cgetc>:

int
sys_cgetc(void)
{
  80156f:	55                   	push   %ebp
  801570:	89 e5                	mov    %esp,%ebp
  801572:	57                   	push   %edi
  801573:	56                   	push   %esi
  801574:	53                   	push   %ebx
	asm volatile("int %1\n"
  801575:	ba 00 00 00 00       	mov    $0x0,%edx
  80157a:	b8 01 00 00 00       	mov    $0x1,%eax
  80157f:	89 d1                	mov    %edx,%ecx
  801581:	89 d3                	mov    %edx,%ebx
  801583:	89 d7                	mov    %edx,%edi
  801585:	89 d6                	mov    %edx,%esi
  801587:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801589:	5b                   	pop    %ebx
  80158a:	5e                   	pop    %esi
  80158b:	5f                   	pop    %edi
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    

0080158e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	57                   	push   %edi
  801592:	56                   	push   %esi
  801593:	53                   	push   %ebx
  801594:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801597:	b9 00 00 00 00       	mov    $0x0,%ecx
  80159c:	8b 55 08             	mov    0x8(%ebp),%edx
  80159f:	b8 03 00 00 00       	mov    $0x3,%eax
  8015a4:	89 cb                	mov    %ecx,%ebx
  8015a6:	89 cf                	mov    %ecx,%edi
  8015a8:	89 ce                	mov    %ecx,%esi
  8015aa:	cd 30                	int    $0x30
	if(check && ret > 0)
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	7f 08                	jg     8015b8 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8015b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b3:	5b                   	pop    %ebx
  8015b4:	5e                   	pop    %esi
  8015b5:	5f                   	pop    %edi
  8015b6:	5d                   	pop    %ebp
  8015b7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8015b8:	83 ec 0c             	sub    $0xc,%esp
  8015bb:	50                   	push   %eax
  8015bc:	6a 03                	push   $0x3
  8015be:	68 af 3c 80 00       	push   $0x803caf
  8015c3:	6a 2a                	push   $0x2a
  8015c5:	68 cc 3c 80 00       	push   $0x803ccc
  8015ca:	e8 9d f4 ff ff       	call   800a6c <_panic>

008015cf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	57                   	push   %edi
  8015d3:	56                   	push   %esi
  8015d4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8015d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015da:	b8 02 00 00 00       	mov    $0x2,%eax
  8015df:	89 d1                	mov    %edx,%ecx
  8015e1:	89 d3                	mov    %edx,%ebx
  8015e3:	89 d7                	mov    %edx,%edi
  8015e5:	89 d6                	mov    %edx,%esi
  8015e7:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8015e9:	5b                   	pop    %ebx
  8015ea:	5e                   	pop    %esi
  8015eb:	5f                   	pop    %edi
  8015ec:	5d                   	pop    %ebp
  8015ed:	c3                   	ret    

008015ee <sys_yield>:

void
sys_yield(void)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	57                   	push   %edi
  8015f2:	56                   	push   %esi
  8015f3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8015f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8015fe:	89 d1                	mov    %edx,%ecx
  801600:	89 d3                	mov    %edx,%ebx
  801602:	89 d7                	mov    %edx,%edi
  801604:	89 d6                	mov    %edx,%esi
  801606:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801608:	5b                   	pop    %ebx
  801609:	5e                   	pop    %esi
  80160a:	5f                   	pop    %edi
  80160b:	5d                   	pop    %ebp
  80160c:	c3                   	ret    

0080160d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80160d:	55                   	push   %ebp
  80160e:	89 e5                	mov    %esp,%ebp
  801610:	57                   	push   %edi
  801611:	56                   	push   %esi
  801612:	53                   	push   %ebx
  801613:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801616:	be 00 00 00 00       	mov    $0x0,%esi
  80161b:	8b 55 08             	mov    0x8(%ebp),%edx
  80161e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801621:	b8 04 00 00 00       	mov    $0x4,%eax
  801626:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801629:	89 f7                	mov    %esi,%edi
  80162b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80162d:	85 c0                	test   %eax,%eax
  80162f:	7f 08                	jg     801639 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801631:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801634:	5b                   	pop    %ebx
  801635:	5e                   	pop    %esi
  801636:	5f                   	pop    %edi
  801637:	5d                   	pop    %ebp
  801638:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801639:	83 ec 0c             	sub    $0xc,%esp
  80163c:	50                   	push   %eax
  80163d:	6a 04                	push   $0x4
  80163f:	68 af 3c 80 00       	push   $0x803caf
  801644:	6a 2a                	push   $0x2a
  801646:	68 cc 3c 80 00       	push   $0x803ccc
  80164b:	e8 1c f4 ff ff       	call   800a6c <_panic>

00801650 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	57                   	push   %edi
  801654:	56                   	push   %esi
  801655:	53                   	push   %ebx
  801656:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801659:	8b 55 08             	mov    0x8(%ebp),%edx
  80165c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80165f:	b8 05 00 00 00       	mov    $0x5,%eax
  801664:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801667:	8b 7d 14             	mov    0x14(%ebp),%edi
  80166a:	8b 75 18             	mov    0x18(%ebp),%esi
  80166d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80166f:	85 c0                	test   %eax,%eax
  801671:	7f 08                	jg     80167b <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801673:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801676:	5b                   	pop    %ebx
  801677:	5e                   	pop    %esi
  801678:	5f                   	pop    %edi
  801679:	5d                   	pop    %ebp
  80167a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80167b:	83 ec 0c             	sub    $0xc,%esp
  80167e:	50                   	push   %eax
  80167f:	6a 05                	push   $0x5
  801681:	68 af 3c 80 00       	push   $0x803caf
  801686:	6a 2a                	push   $0x2a
  801688:	68 cc 3c 80 00       	push   $0x803ccc
  80168d:	e8 da f3 ff ff       	call   800a6c <_panic>

00801692 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	57                   	push   %edi
  801696:	56                   	push   %esi
  801697:	53                   	push   %ebx
  801698:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80169b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8016a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016a6:	b8 06 00 00 00       	mov    $0x6,%eax
  8016ab:	89 df                	mov    %ebx,%edi
  8016ad:	89 de                	mov    %ebx,%esi
  8016af:	cd 30                	int    $0x30
	if(check && ret > 0)
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	7f 08                	jg     8016bd <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8016b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b8:	5b                   	pop    %ebx
  8016b9:	5e                   	pop    %esi
  8016ba:	5f                   	pop    %edi
  8016bb:	5d                   	pop    %ebp
  8016bc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8016bd:	83 ec 0c             	sub    $0xc,%esp
  8016c0:	50                   	push   %eax
  8016c1:	6a 06                	push   $0x6
  8016c3:	68 af 3c 80 00       	push   $0x803caf
  8016c8:	6a 2a                	push   $0x2a
  8016ca:	68 cc 3c 80 00       	push   $0x803ccc
  8016cf:	e8 98 f3 ff ff       	call   800a6c <_panic>

008016d4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	57                   	push   %edi
  8016d8:	56                   	push   %esi
  8016d9:	53                   	push   %ebx
  8016da:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8016dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8016e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e8:	b8 08 00 00 00       	mov    $0x8,%eax
  8016ed:	89 df                	mov    %ebx,%edi
  8016ef:	89 de                	mov    %ebx,%esi
  8016f1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	7f 08                	jg     8016ff <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8016f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016fa:	5b                   	pop    %ebx
  8016fb:	5e                   	pop    %esi
  8016fc:	5f                   	pop    %edi
  8016fd:	5d                   	pop    %ebp
  8016fe:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8016ff:	83 ec 0c             	sub    $0xc,%esp
  801702:	50                   	push   %eax
  801703:	6a 08                	push   $0x8
  801705:	68 af 3c 80 00       	push   $0x803caf
  80170a:	6a 2a                	push   $0x2a
  80170c:	68 cc 3c 80 00       	push   $0x803ccc
  801711:	e8 56 f3 ff ff       	call   800a6c <_panic>

00801716 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	57                   	push   %edi
  80171a:	56                   	push   %esi
  80171b:	53                   	push   %ebx
  80171c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80171f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801724:	8b 55 08             	mov    0x8(%ebp),%edx
  801727:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172a:	b8 09 00 00 00       	mov    $0x9,%eax
  80172f:	89 df                	mov    %ebx,%edi
  801731:	89 de                	mov    %ebx,%esi
  801733:	cd 30                	int    $0x30
	if(check && ret > 0)
  801735:	85 c0                	test   %eax,%eax
  801737:	7f 08                	jg     801741 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801739:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80173c:	5b                   	pop    %ebx
  80173d:	5e                   	pop    %esi
  80173e:	5f                   	pop    %edi
  80173f:	5d                   	pop    %ebp
  801740:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801741:	83 ec 0c             	sub    $0xc,%esp
  801744:	50                   	push   %eax
  801745:	6a 09                	push   $0x9
  801747:	68 af 3c 80 00       	push   $0x803caf
  80174c:	6a 2a                	push   $0x2a
  80174e:	68 cc 3c 80 00       	push   $0x803ccc
  801753:	e8 14 f3 ff ff       	call   800a6c <_panic>

00801758 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	57                   	push   %edi
  80175c:	56                   	push   %esi
  80175d:	53                   	push   %ebx
  80175e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801761:	bb 00 00 00 00       	mov    $0x0,%ebx
  801766:	8b 55 08             	mov    0x8(%ebp),%edx
  801769:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80176c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801771:	89 df                	mov    %ebx,%edi
  801773:	89 de                	mov    %ebx,%esi
  801775:	cd 30                	int    $0x30
	if(check && ret > 0)
  801777:	85 c0                	test   %eax,%eax
  801779:	7f 08                	jg     801783 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80177b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80177e:	5b                   	pop    %ebx
  80177f:	5e                   	pop    %esi
  801780:	5f                   	pop    %edi
  801781:	5d                   	pop    %ebp
  801782:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801783:	83 ec 0c             	sub    $0xc,%esp
  801786:	50                   	push   %eax
  801787:	6a 0a                	push   $0xa
  801789:	68 af 3c 80 00       	push   $0x803caf
  80178e:	6a 2a                	push   $0x2a
  801790:	68 cc 3c 80 00       	push   $0x803ccc
  801795:	e8 d2 f2 ff ff       	call   800a6c <_panic>

0080179a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	57                   	push   %edi
  80179e:	56                   	push   %esi
  80179f:	53                   	push   %ebx
	asm volatile("int %1\n"
  8017a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8017a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017a6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8017ab:	be 00 00 00 00       	mov    $0x0,%esi
  8017b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8017b3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8017b6:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8017b8:	5b                   	pop    %ebx
  8017b9:	5e                   	pop    %esi
  8017ba:	5f                   	pop    %edi
  8017bb:	5d                   	pop    %ebp
  8017bc:	c3                   	ret    

008017bd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	57                   	push   %edi
  8017c1:	56                   	push   %esi
  8017c2:	53                   	push   %ebx
  8017c3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8017c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8017ce:	b8 0d 00 00 00       	mov    $0xd,%eax
  8017d3:	89 cb                	mov    %ecx,%ebx
  8017d5:	89 cf                	mov    %ecx,%edi
  8017d7:	89 ce                	mov    %ecx,%esi
  8017d9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	7f 08                	jg     8017e7 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8017df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e2:	5b                   	pop    %ebx
  8017e3:	5e                   	pop    %esi
  8017e4:	5f                   	pop    %edi
  8017e5:	5d                   	pop    %ebp
  8017e6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8017e7:	83 ec 0c             	sub    $0xc,%esp
  8017ea:	50                   	push   %eax
  8017eb:	6a 0d                	push   $0xd
  8017ed:	68 af 3c 80 00       	push   $0x803caf
  8017f2:	6a 2a                	push   $0x2a
  8017f4:	68 cc 3c 80 00       	push   $0x803ccc
  8017f9:	e8 6e f2 ff ff       	call   800a6c <_panic>

008017fe <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	57                   	push   %edi
  801802:	56                   	push   %esi
  801803:	53                   	push   %ebx
	asm volatile("int %1\n"
  801804:	ba 00 00 00 00       	mov    $0x0,%edx
  801809:	b8 0e 00 00 00       	mov    $0xe,%eax
  80180e:	89 d1                	mov    %edx,%ecx
  801810:	89 d3                	mov    %edx,%ebx
  801812:	89 d7                	mov    %edx,%edi
  801814:	89 d6                	mov    %edx,%esi
  801816:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801818:	5b                   	pop    %ebx
  801819:	5e                   	pop    %esi
  80181a:	5f                   	pop    %edi
  80181b:	5d                   	pop    %ebp
  80181c:	c3                   	ret    

0080181d <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	57                   	push   %edi
  801821:	56                   	push   %esi
  801822:	53                   	push   %ebx
	asm volatile("int %1\n"
  801823:	bb 00 00 00 00       	mov    $0x0,%ebx
  801828:	8b 55 08             	mov    0x8(%ebp),%edx
  80182b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80182e:	b8 0f 00 00 00       	mov    $0xf,%eax
  801833:	89 df                	mov    %ebx,%edi
  801835:	89 de                	mov    %ebx,%esi
  801837:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  801839:	5b                   	pop    %ebx
  80183a:	5e                   	pop    %esi
  80183b:	5f                   	pop    %edi
  80183c:	5d                   	pop    %ebp
  80183d:	c3                   	ret    

0080183e <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	57                   	push   %edi
  801842:	56                   	push   %esi
  801843:	53                   	push   %ebx
	asm volatile("int %1\n"
  801844:	bb 00 00 00 00       	mov    $0x0,%ebx
  801849:	8b 55 08             	mov    0x8(%ebp),%edx
  80184c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80184f:	b8 10 00 00 00       	mov    $0x10,%eax
  801854:	89 df                	mov    %ebx,%edi
  801856:	89 de                	mov    %ebx,%esi
  801858:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  80185a:	5b                   	pop    %ebx
  80185b:	5e                   	pop    %esi
  80185c:	5f                   	pop    %edi
  80185d:	5d                   	pop    %ebp
  80185e:	c3                   	ret    

0080185f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	56                   	push   %esi
  801863:	53                   	push   %ebx
  801864:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801867:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  801869:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80186d:	0f 84 8e 00 00 00    	je     801901 <pgfault+0xa2>
  801873:	89 f0                	mov    %esi,%eax
  801875:	c1 e8 0c             	shr    $0xc,%eax
  801878:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80187f:	f6 c4 08             	test   $0x8,%ah
  801882:	74 7d                	je     801901 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  801884:	e8 46 fd ff ff       	call   8015cf <sys_getenvid>
  801889:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  80188b:	83 ec 04             	sub    $0x4,%esp
  80188e:	6a 07                	push   $0x7
  801890:	68 00 f0 7f 00       	push   $0x7ff000
  801895:	50                   	push   %eax
  801896:	e8 72 fd ff ff       	call   80160d <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	85 c0                	test   %eax,%eax
  8018a0:	78 73                	js     801915 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  8018a2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  8018a8:	83 ec 04             	sub    $0x4,%esp
  8018ab:	68 00 10 00 00       	push   $0x1000
  8018b0:	56                   	push   %esi
  8018b1:	68 00 f0 7f 00       	push   $0x7ff000
  8018b6:	e8 ec fa ff ff       	call   8013a7 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  8018bb:	83 c4 08             	add    $0x8,%esp
  8018be:	56                   	push   %esi
  8018bf:	53                   	push   %ebx
  8018c0:	e8 cd fd ff ff       	call   801692 <sys_page_unmap>
  8018c5:	83 c4 10             	add    $0x10,%esp
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	78 5b                	js     801927 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  8018cc:	83 ec 0c             	sub    $0xc,%esp
  8018cf:	6a 07                	push   $0x7
  8018d1:	56                   	push   %esi
  8018d2:	53                   	push   %ebx
  8018d3:	68 00 f0 7f 00       	push   $0x7ff000
  8018d8:	53                   	push   %ebx
  8018d9:	e8 72 fd ff ff       	call   801650 <sys_page_map>
  8018de:	83 c4 20             	add    $0x20,%esp
  8018e1:	85 c0                	test   %eax,%eax
  8018e3:	78 54                	js     801939 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  8018e5:	83 ec 08             	sub    $0x8,%esp
  8018e8:	68 00 f0 7f 00       	push   $0x7ff000
  8018ed:	53                   	push   %ebx
  8018ee:	e8 9f fd ff ff       	call   801692 <sys_page_unmap>
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	85 c0                	test   %eax,%eax
  8018f8:	78 51                	js     80194b <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  8018fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fd:	5b                   	pop    %ebx
  8018fe:	5e                   	pop    %esi
  8018ff:	5d                   	pop    %ebp
  801900:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  801901:	83 ec 04             	sub    $0x4,%esp
  801904:	68 dc 3c 80 00       	push   $0x803cdc
  801909:	6a 1d                	push   $0x1d
  80190b:	68 58 3d 80 00       	push   $0x803d58
  801910:	e8 57 f1 ff ff       	call   800a6c <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  801915:	50                   	push   %eax
  801916:	68 14 3d 80 00       	push   $0x803d14
  80191b:	6a 29                	push   $0x29
  80191d:	68 58 3d 80 00       	push   $0x803d58
  801922:	e8 45 f1 ff ff       	call   800a6c <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  801927:	50                   	push   %eax
  801928:	68 38 3d 80 00       	push   $0x803d38
  80192d:	6a 2e                	push   $0x2e
  80192f:	68 58 3d 80 00       	push   $0x803d58
  801934:	e8 33 f1 ff ff       	call   800a6c <_panic>
		panic("pgfault: page map failed (%e)", r);
  801939:	50                   	push   %eax
  80193a:	68 63 3d 80 00       	push   $0x803d63
  80193f:	6a 30                	push   $0x30
  801941:	68 58 3d 80 00       	push   $0x803d58
  801946:	e8 21 f1 ff ff       	call   800a6c <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  80194b:	50                   	push   %eax
  80194c:	68 38 3d 80 00       	push   $0x803d38
  801951:	6a 32                	push   $0x32
  801953:	68 58 3d 80 00       	push   $0x803d58
  801958:	e8 0f f1 ff ff       	call   800a6c <_panic>

0080195d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80195d:	55                   	push   %ebp
  80195e:	89 e5                	mov    %esp,%ebp
  801960:	57                   	push   %edi
  801961:	56                   	push   %esi
  801962:	53                   	push   %ebx
  801963:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  801966:	68 5f 18 80 00       	push   $0x80185f
  80196b:	e8 d3 19 00 00       	call   803343 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801970:	b8 07 00 00 00       	mov    $0x7,%eax
  801975:	cd 30                	int    $0x30
  801977:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  80197a:	83 c4 10             	add    $0x10,%esp
  80197d:	85 c0                	test   %eax,%eax
  80197f:	78 30                	js     8019b1 <fork+0x54>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801981:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  801986:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80198a:	75 76                	jne    801a02 <fork+0xa5>
		thisenv = &envs[ENVX(sys_getenvid())];
  80198c:	e8 3e fc ff ff       	call   8015cf <sys_getenvid>
  801991:	25 ff 03 00 00       	and    $0x3ff,%eax
  801996:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80199c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8019a1:	a3 14 60 80 00       	mov    %eax,0x806014
		return 0;
  8019a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  8019a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ac:	5b                   	pop    %ebx
  8019ad:	5e                   	pop    %esi
  8019ae:	5f                   	pop    %edi
  8019af:	5d                   	pop    %ebp
  8019b0:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  8019b1:	50                   	push   %eax
  8019b2:	68 81 3d 80 00       	push   $0x803d81
  8019b7:	6a 78                	push   $0x78
  8019b9:	68 58 3d 80 00       	push   $0x803d58
  8019be:	e8 a9 f0 ff ff       	call   800a6c <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  8019c3:	83 ec 0c             	sub    $0xc,%esp
  8019c6:	ff 75 e4             	push   -0x1c(%ebp)
  8019c9:	57                   	push   %edi
  8019ca:	ff 75 dc             	push   -0x24(%ebp)
  8019cd:	57                   	push   %edi
  8019ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8019d1:	56                   	push   %esi
  8019d2:	e8 79 fc ff ff       	call   801650 <sys_page_map>
	if(r<0) return r;
  8019d7:	83 c4 20             	add    $0x20,%esp
  8019da:	85 c0                	test   %eax,%eax
  8019dc:	78 cb                	js     8019a9 <fork+0x4c>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  8019de:	83 ec 0c             	sub    $0xc,%esp
  8019e1:	ff 75 e4             	push   -0x1c(%ebp)
  8019e4:	57                   	push   %edi
  8019e5:	56                   	push   %esi
  8019e6:	57                   	push   %edi
  8019e7:	56                   	push   %esi
  8019e8:	e8 63 fc ff ff       	call   801650 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  8019ed:	83 c4 20             	add    $0x20,%esp
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	78 76                	js     801a6a <fork+0x10d>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  8019f4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019fa:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801a00:	74 75                	je     801a77 <fork+0x11a>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  801a02:	89 d8                	mov    %ebx,%eax
  801a04:	c1 e8 16             	shr    $0x16,%eax
  801a07:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a0e:	a8 01                	test   $0x1,%al
  801a10:	74 e2                	je     8019f4 <fork+0x97>
  801a12:	89 de                	mov    %ebx,%esi
  801a14:	c1 ee 0c             	shr    $0xc,%esi
  801a17:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801a1e:	a8 01                	test   $0x1,%al
  801a20:	74 d2                	je     8019f4 <fork+0x97>
	envid_t this_envid = sys_getenvid();//父进程号
  801a22:	e8 a8 fb ff ff       	call   8015cf <sys_getenvid>
  801a27:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  801a2a:	89 f7                	mov    %esi,%edi
  801a2c:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  801a2f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801a36:	89 c1                	mov    %eax,%ecx
  801a38:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801a3e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  801a41:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  801a48:	f6 c6 04             	test   $0x4,%dh
  801a4b:	0f 85 72 ff ff ff    	jne    8019c3 <fork+0x66>
		perm &= ~PTE_W;
  801a51:	25 05 0e 00 00       	and    $0xe05,%eax
  801a56:	80 cc 08             	or     $0x8,%ah
  801a59:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  801a5f:	0f 44 c1             	cmove  %ecx,%eax
  801a62:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a65:	e9 59 ff ff ff       	jmp    8019c3 <fork+0x66>
  801a6a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6f:	0f 4f c2             	cmovg  %edx,%eax
  801a72:	e9 32 ff ff ff       	jmp    8019a9 <fork+0x4c>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801a77:	83 ec 04             	sub    $0x4,%esp
  801a7a:	6a 07                	push   $0x7
  801a7c:	68 00 f0 bf ee       	push   $0xeebff000
  801a81:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801a84:	57                   	push   %edi
  801a85:	e8 83 fb ff ff       	call   80160d <sys_page_alloc>
	if(r<0) return r;
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	85 c0                	test   %eax,%eax
  801a8f:	0f 88 14 ff ff ff    	js     8019a9 <fork+0x4c>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801a95:	83 ec 08             	sub    $0x8,%esp
  801a98:	68 b9 33 80 00       	push   $0x8033b9
  801a9d:	57                   	push   %edi
  801a9e:	e8 b5 fc ff ff       	call   801758 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	85 c0                	test   %eax,%eax
  801aa8:	0f 88 fb fe ff ff    	js     8019a9 <fork+0x4c>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801aae:	83 ec 08             	sub    $0x8,%esp
  801ab1:	6a 02                	push   $0x2
  801ab3:	57                   	push   %edi
  801ab4:	e8 1b fc ff ff       	call   8016d4 <sys_env_set_status>
	if(r<0) return r;
  801ab9:	83 c4 10             	add    $0x10,%esp
	return envid;
  801abc:	85 c0                	test   %eax,%eax
  801abe:	0f 49 c7             	cmovns %edi,%eax
  801ac1:	e9 e3 fe ff ff       	jmp    8019a9 <fork+0x4c>

00801ac6 <sfork>:

// Challenge!
int
sfork(void)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801acc:	68 91 3d 80 00       	push   $0x803d91
  801ad1:	68 a1 00 00 00       	push   $0xa1
  801ad6:	68 58 3d 80 00       	push   $0x803d58
  801adb:	e8 8c ef ff ff       	call   800a6c <_panic>

00801ae0 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	8b 55 08             	mov    0x8(%ebp),%edx
  801ae6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae9:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801aec:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801aee:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801af1:	83 3a 01             	cmpl   $0x1,(%edx)
  801af4:	7e 09                	jle    801aff <argstart+0x1f>
  801af6:	ba 81 37 80 00       	mov    $0x803781,%edx
  801afb:	85 c9                	test   %ecx,%ecx
  801afd:	75 05                	jne    801b04 <argstart+0x24>
  801aff:	ba 00 00 00 00       	mov    $0x0,%edx
  801b04:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801b07:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801b0e:	5d                   	pop    %ebp
  801b0f:	c3                   	ret    

00801b10 <argnext>:

int
argnext(struct Argstate *args)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	53                   	push   %ebx
  801b14:	83 ec 04             	sub    $0x4,%esp
  801b17:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801b1a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801b21:	8b 43 08             	mov    0x8(%ebx),%eax
  801b24:	85 c0                	test   %eax,%eax
  801b26:	74 74                	je     801b9c <argnext+0x8c>
		return -1;

	if (!*args->curarg) {
  801b28:	80 38 00             	cmpb   $0x0,(%eax)
  801b2b:	75 48                	jne    801b75 <argnext+0x65>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801b2d:	8b 0b                	mov    (%ebx),%ecx
  801b2f:	83 39 01             	cmpl   $0x1,(%ecx)
  801b32:	74 5a                	je     801b8e <argnext+0x7e>
		    || args->argv[1][0] != '-'
  801b34:	8b 53 04             	mov    0x4(%ebx),%edx
  801b37:	8b 42 04             	mov    0x4(%edx),%eax
  801b3a:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b3d:	75 4f                	jne    801b8e <argnext+0x7e>
		    || args->argv[1][1] == '\0')
  801b3f:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b43:	74 49                	je     801b8e <argnext+0x7e>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801b45:	83 c0 01             	add    $0x1,%eax
  801b48:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b4b:	83 ec 04             	sub    $0x4,%esp
  801b4e:	8b 01                	mov    (%ecx),%eax
  801b50:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801b57:	50                   	push   %eax
  801b58:	8d 42 08             	lea    0x8(%edx),%eax
  801b5b:	50                   	push   %eax
  801b5c:	83 c2 04             	add    $0x4,%edx
  801b5f:	52                   	push   %edx
  801b60:	e8 42 f8 ff ff       	call   8013a7 <memmove>
		(*args->argc)--;
  801b65:	8b 03                	mov    (%ebx),%eax
  801b67:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b6a:	8b 43 08             	mov    0x8(%ebx),%eax
  801b6d:	83 c4 10             	add    $0x10,%esp
  801b70:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b73:	74 13                	je     801b88 <argnext+0x78>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801b75:	8b 43 08             	mov    0x8(%ebx),%eax
  801b78:	0f b6 10             	movzbl (%eax),%edx
	args->curarg++;
  801b7b:	83 c0 01             	add    $0x1,%eax
  801b7e:	89 43 08             	mov    %eax,0x8(%ebx)
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801b81:	89 d0                	mov    %edx,%eax
  801b83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b86:	c9                   	leave  
  801b87:	c3                   	ret    
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b88:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b8c:	75 e7                	jne    801b75 <argnext+0x65>
	args->curarg = 0;
  801b8e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801b95:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b9a:	eb e5                	jmp    801b81 <argnext+0x71>
		return -1;
  801b9c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801ba1:	eb de                	jmp    801b81 <argnext+0x71>

00801ba3 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	53                   	push   %ebx
  801ba7:	83 ec 04             	sub    $0x4,%esp
  801baa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801bad:	8b 43 08             	mov    0x8(%ebx),%eax
  801bb0:	85 c0                	test   %eax,%eax
  801bb2:	74 12                	je     801bc6 <argnextvalue+0x23>
		return 0;
	if (*args->curarg) {
  801bb4:	80 38 00             	cmpb   $0x0,(%eax)
  801bb7:	74 12                	je     801bcb <argnextvalue+0x28>
		args->argvalue = args->curarg;
  801bb9:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801bbc:	c7 43 08 81 37 80 00 	movl   $0x803781,0x8(%ebx)
		(*args->argc)--;
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
  801bc3:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  801bc6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc9:	c9                   	leave  
  801bca:	c3                   	ret    
	} else if (*args->argc > 1) {
  801bcb:	8b 13                	mov    (%ebx),%edx
  801bcd:	83 3a 01             	cmpl   $0x1,(%edx)
  801bd0:	7f 10                	jg     801be2 <argnextvalue+0x3f>
		args->argvalue = 0;
  801bd2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801bd9:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  801be0:	eb e1                	jmp    801bc3 <argnextvalue+0x20>
		args->argvalue = args->argv[1];
  801be2:	8b 43 04             	mov    0x4(%ebx),%eax
  801be5:	8b 48 04             	mov    0x4(%eax),%ecx
  801be8:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801beb:	83 ec 04             	sub    $0x4,%esp
  801bee:	8b 12                	mov    (%edx),%edx
  801bf0:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801bf7:	52                   	push   %edx
  801bf8:	8d 50 08             	lea    0x8(%eax),%edx
  801bfb:	52                   	push   %edx
  801bfc:	83 c0 04             	add    $0x4,%eax
  801bff:	50                   	push   %eax
  801c00:	e8 a2 f7 ff ff       	call   8013a7 <memmove>
		(*args->argc)--;
  801c05:	8b 03                	mov    (%ebx),%eax
  801c07:	83 28 01             	subl   $0x1,(%eax)
  801c0a:	83 c4 10             	add    $0x10,%esp
  801c0d:	eb b4                	jmp    801bc3 <argnextvalue+0x20>

00801c0f <argvalue>:
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	83 ec 08             	sub    $0x8,%esp
  801c15:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801c18:	8b 42 0c             	mov    0xc(%edx),%eax
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	74 02                	je     801c21 <argvalue+0x12>
}
  801c1f:	c9                   	leave  
  801c20:	c3                   	ret    
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801c21:	83 ec 0c             	sub    $0xc,%esp
  801c24:	52                   	push   %edx
  801c25:	e8 79 ff ff ff       	call   801ba3 <argnextvalue>
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	eb f0                	jmp    801c1f <argvalue+0x10>

00801c2f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c2f:	55                   	push   %ebp
  801c30:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c32:	8b 45 08             	mov    0x8(%ebp),%eax
  801c35:	05 00 00 00 30       	add    $0x30000000,%eax
  801c3a:	c1 e8 0c             	shr    $0xc,%eax
}
  801c3d:	5d                   	pop    %ebp
  801c3e:	c3                   	ret    

00801c3f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c42:	8b 45 08             	mov    0x8(%ebp),%eax
  801c45:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801c4a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801c4f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801c54:	5d                   	pop    %ebp
  801c55:	c3                   	ret    

00801c56 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801c5e:	89 c2                	mov    %eax,%edx
  801c60:	c1 ea 16             	shr    $0x16,%edx
  801c63:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c6a:	f6 c2 01             	test   $0x1,%dl
  801c6d:	74 29                	je     801c98 <fd_alloc+0x42>
  801c6f:	89 c2                	mov    %eax,%edx
  801c71:	c1 ea 0c             	shr    $0xc,%edx
  801c74:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c7b:	f6 c2 01             	test   $0x1,%dl
  801c7e:	74 18                	je     801c98 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801c80:	05 00 10 00 00       	add    $0x1000,%eax
  801c85:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c8a:	75 d2                	jne    801c5e <fd_alloc+0x8>
  801c8c:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801c91:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801c96:	eb 05                	jmp    801c9d <fd_alloc+0x47>
			return 0;
  801c98:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  801ca0:	89 02                	mov    %eax,(%edx)
}
  801ca2:	89 c8                	mov    %ecx,%eax
  801ca4:	5d                   	pop    %ebp
  801ca5:	c3                   	ret    

00801ca6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801cac:	83 f8 1f             	cmp    $0x1f,%eax
  801caf:	77 30                	ja     801ce1 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801cb1:	c1 e0 0c             	shl    $0xc,%eax
  801cb4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801cb9:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801cbf:	f6 c2 01             	test   $0x1,%dl
  801cc2:	74 24                	je     801ce8 <fd_lookup+0x42>
  801cc4:	89 c2                	mov    %eax,%edx
  801cc6:	c1 ea 0c             	shr    $0xc,%edx
  801cc9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801cd0:	f6 c2 01             	test   $0x1,%dl
  801cd3:	74 1a                	je     801cef <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801cd5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cd8:	89 02                	mov    %eax,(%edx)
	return 0;
  801cda:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cdf:	5d                   	pop    %ebp
  801ce0:	c3                   	ret    
		return -E_INVAL;
  801ce1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ce6:	eb f7                	jmp    801cdf <fd_lookup+0x39>
		return -E_INVAL;
  801ce8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ced:	eb f0                	jmp    801cdf <fd_lookup+0x39>
  801cef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801cf4:	eb e9                	jmp    801cdf <fd_lookup+0x39>

00801cf6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	53                   	push   %ebx
  801cfa:	83 ec 04             	sub    $0x4,%esp
  801cfd:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801d00:	b8 00 00 00 00       	mov    $0x0,%eax
  801d05:	bb 20 50 80 00       	mov    $0x805020,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801d0a:	39 13                	cmp    %edx,(%ebx)
  801d0c:	74 37                	je     801d45 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  801d0e:	83 c0 01             	add    $0x1,%eax
  801d11:	8b 1c 85 24 3e 80 00 	mov    0x803e24(,%eax,4),%ebx
  801d18:	85 db                	test   %ebx,%ebx
  801d1a:	75 ee                	jne    801d0a <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801d1c:	a1 14 60 80 00       	mov    0x806014,%eax
  801d21:	8b 40 58             	mov    0x58(%eax),%eax
  801d24:	83 ec 04             	sub    $0x4,%esp
  801d27:	52                   	push   %edx
  801d28:	50                   	push   %eax
  801d29:	68 a8 3d 80 00       	push   $0x803da8
  801d2e:	e8 14 ee ff ff       	call   800b47 <cprintf>
	*dev = 0;
	return -E_INVAL;
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801d3b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d3e:	89 1a                	mov    %ebx,(%edx)
}
  801d40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d43:	c9                   	leave  
  801d44:	c3                   	ret    
			return 0;
  801d45:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4a:	eb ef                	jmp    801d3b <dev_lookup+0x45>

00801d4c <fd_close>:
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	57                   	push   %edi
  801d50:	56                   	push   %esi
  801d51:	53                   	push   %ebx
  801d52:	83 ec 24             	sub    $0x24,%esp
  801d55:	8b 75 08             	mov    0x8(%ebp),%esi
  801d58:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d5b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d5e:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801d5f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801d65:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d68:	50                   	push   %eax
  801d69:	e8 38 ff ff ff       	call   801ca6 <fd_lookup>
  801d6e:	89 c3                	mov    %eax,%ebx
  801d70:	83 c4 10             	add    $0x10,%esp
  801d73:	85 c0                	test   %eax,%eax
  801d75:	78 05                	js     801d7c <fd_close+0x30>
	    || fd != fd2)
  801d77:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801d7a:	74 16                	je     801d92 <fd_close+0x46>
		return (must_exist ? r : 0);
  801d7c:	89 f8                	mov    %edi,%eax
  801d7e:	84 c0                	test   %al,%al
  801d80:	b8 00 00 00 00       	mov    $0x0,%eax
  801d85:	0f 44 d8             	cmove  %eax,%ebx
}
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d8d:	5b                   	pop    %ebx
  801d8e:	5e                   	pop    %esi
  801d8f:	5f                   	pop    %edi
  801d90:	5d                   	pop    %ebp
  801d91:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d92:	83 ec 08             	sub    $0x8,%esp
  801d95:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801d98:	50                   	push   %eax
  801d99:	ff 36                	push   (%esi)
  801d9b:	e8 56 ff ff ff       	call   801cf6 <dev_lookup>
  801da0:	89 c3                	mov    %eax,%ebx
  801da2:	83 c4 10             	add    $0x10,%esp
  801da5:	85 c0                	test   %eax,%eax
  801da7:	78 1a                	js     801dc3 <fd_close+0x77>
		if (dev->dev_close)
  801da9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801dac:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801daf:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801db4:	85 c0                	test   %eax,%eax
  801db6:	74 0b                	je     801dc3 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801db8:	83 ec 0c             	sub    $0xc,%esp
  801dbb:	56                   	push   %esi
  801dbc:	ff d0                	call   *%eax
  801dbe:	89 c3                	mov    %eax,%ebx
  801dc0:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801dc3:	83 ec 08             	sub    $0x8,%esp
  801dc6:	56                   	push   %esi
  801dc7:	6a 00                	push   $0x0
  801dc9:	e8 c4 f8 ff ff       	call   801692 <sys_page_unmap>
	return r;
  801dce:	83 c4 10             	add    $0x10,%esp
  801dd1:	eb b5                	jmp    801d88 <fd_close+0x3c>

00801dd3 <close>:

int
close(int fdnum)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ddc:	50                   	push   %eax
  801ddd:	ff 75 08             	push   0x8(%ebp)
  801de0:	e8 c1 fe ff ff       	call   801ca6 <fd_lookup>
  801de5:	83 c4 10             	add    $0x10,%esp
  801de8:	85 c0                	test   %eax,%eax
  801dea:	79 02                	jns    801dee <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801dec:	c9                   	leave  
  801ded:	c3                   	ret    
		return fd_close(fd, 1);
  801dee:	83 ec 08             	sub    $0x8,%esp
  801df1:	6a 01                	push   $0x1
  801df3:	ff 75 f4             	push   -0xc(%ebp)
  801df6:	e8 51 ff ff ff       	call   801d4c <fd_close>
  801dfb:	83 c4 10             	add    $0x10,%esp
  801dfe:	eb ec                	jmp    801dec <close+0x19>

00801e00 <close_all>:

void
close_all(void)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	53                   	push   %ebx
  801e04:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801e07:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801e0c:	83 ec 0c             	sub    $0xc,%esp
  801e0f:	53                   	push   %ebx
  801e10:	e8 be ff ff ff       	call   801dd3 <close>
	for (i = 0; i < MAXFD; i++)
  801e15:	83 c3 01             	add    $0x1,%ebx
  801e18:	83 c4 10             	add    $0x10,%esp
  801e1b:	83 fb 20             	cmp    $0x20,%ebx
  801e1e:	75 ec                	jne    801e0c <close_all+0xc>
}
  801e20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e23:	c9                   	leave  
  801e24:	c3                   	ret    

00801e25 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801e25:	55                   	push   %ebp
  801e26:	89 e5                	mov    %esp,%ebp
  801e28:	57                   	push   %edi
  801e29:	56                   	push   %esi
  801e2a:	53                   	push   %ebx
  801e2b:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e2e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e31:	50                   	push   %eax
  801e32:	ff 75 08             	push   0x8(%ebp)
  801e35:	e8 6c fe ff ff       	call   801ca6 <fd_lookup>
  801e3a:	89 c3                	mov    %eax,%ebx
  801e3c:	83 c4 10             	add    $0x10,%esp
  801e3f:	85 c0                	test   %eax,%eax
  801e41:	78 7f                	js     801ec2 <dup+0x9d>
		return r;
	close(newfdnum);
  801e43:	83 ec 0c             	sub    $0xc,%esp
  801e46:	ff 75 0c             	push   0xc(%ebp)
  801e49:	e8 85 ff ff ff       	call   801dd3 <close>

	newfd = INDEX2FD(newfdnum);
  801e4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e51:	c1 e6 0c             	shl    $0xc,%esi
  801e54:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801e5a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e5d:	89 3c 24             	mov    %edi,(%esp)
  801e60:	e8 da fd ff ff       	call   801c3f <fd2data>
  801e65:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801e67:	89 34 24             	mov    %esi,(%esp)
  801e6a:	e8 d0 fd ff ff       	call   801c3f <fd2data>
  801e6f:	83 c4 10             	add    $0x10,%esp
  801e72:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801e75:	89 d8                	mov    %ebx,%eax
  801e77:	c1 e8 16             	shr    $0x16,%eax
  801e7a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e81:	a8 01                	test   $0x1,%al
  801e83:	74 11                	je     801e96 <dup+0x71>
  801e85:	89 d8                	mov    %ebx,%eax
  801e87:	c1 e8 0c             	shr    $0xc,%eax
  801e8a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e91:	f6 c2 01             	test   $0x1,%dl
  801e94:	75 36                	jne    801ecc <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e96:	89 f8                	mov    %edi,%eax
  801e98:	c1 e8 0c             	shr    $0xc,%eax
  801e9b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ea2:	83 ec 0c             	sub    $0xc,%esp
  801ea5:	25 07 0e 00 00       	and    $0xe07,%eax
  801eaa:	50                   	push   %eax
  801eab:	56                   	push   %esi
  801eac:	6a 00                	push   $0x0
  801eae:	57                   	push   %edi
  801eaf:	6a 00                	push   $0x0
  801eb1:	e8 9a f7 ff ff       	call   801650 <sys_page_map>
  801eb6:	89 c3                	mov    %eax,%ebx
  801eb8:	83 c4 20             	add    $0x20,%esp
  801ebb:	85 c0                	test   %eax,%eax
  801ebd:	78 33                	js     801ef2 <dup+0xcd>
		goto err;

	return newfdnum;
  801ebf:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801ec2:	89 d8                	mov    %ebx,%eax
  801ec4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec7:	5b                   	pop    %ebx
  801ec8:	5e                   	pop    %esi
  801ec9:	5f                   	pop    %edi
  801eca:	5d                   	pop    %ebp
  801ecb:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801ecc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ed3:	83 ec 0c             	sub    $0xc,%esp
  801ed6:	25 07 0e 00 00       	and    $0xe07,%eax
  801edb:	50                   	push   %eax
  801edc:	ff 75 d4             	push   -0x2c(%ebp)
  801edf:	6a 00                	push   $0x0
  801ee1:	53                   	push   %ebx
  801ee2:	6a 00                	push   $0x0
  801ee4:	e8 67 f7 ff ff       	call   801650 <sys_page_map>
  801ee9:	89 c3                	mov    %eax,%ebx
  801eeb:	83 c4 20             	add    $0x20,%esp
  801eee:	85 c0                	test   %eax,%eax
  801ef0:	79 a4                	jns    801e96 <dup+0x71>
	sys_page_unmap(0, newfd);
  801ef2:	83 ec 08             	sub    $0x8,%esp
  801ef5:	56                   	push   %esi
  801ef6:	6a 00                	push   $0x0
  801ef8:	e8 95 f7 ff ff       	call   801692 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801efd:	83 c4 08             	add    $0x8,%esp
  801f00:	ff 75 d4             	push   -0x2c(%ebp)
  801f03:	6a 00                	push   $0x0
  801f05:	e8 88 f7 ff ff       	call   801692 <sys_page_unmap>
	return r;
  801f0a:	83 c4 10             	add    $0x10,%esp
  801f0d:	eb b3                	jmp    801ec2 <dup+0x9d>

00801f0f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	56                   	push   %esi
  801f13:	53                   	push   %ebx
  801f14:	83 ec 18             	sub    $0x18,%esp
  801f17:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f1a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f1d:	50                   	push   %eax
  801f1e:	56                   	push   %esi
  801f1f:	e8 82 fd ff ff       	call   801ca6 <fd_lookup>
  801f24:	83 c4 10             	add    $0x10,%esp
  801f27:	85 c0                	test   %eax,%eax
  801f29:	78 3c                	js     801f67 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f2b:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801f2e:	83 ec 08             	sub    $0x8,%esp
  801f31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f34:	50                   	push   %eax
  801f35:	ff 33                	push   (%ebx)
  801f37:	e8 ba fd ff ff       	call   801cf6 <dev_lookup>
  801f3c:	83 c4 10             	add    $0x10,%esp
  801f3f:	85 c0                	test   %eax,%eax
  801f41:	78 24                	js     801f67 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801f43:	8b 43 08             	mov    0x8(%ebx),%eax
  801f46:	83 e0 03             	and    $0x3,%eax
  801f49:	83 f8 01             	cmp    $0x1,%eax
  801f4c:	74 20                	je     801f6e <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f51:	8b 40 08             	mov    0x8(%eax),%eax
  801f54:	85 c0                	test   %eax,%eax
  801f56:	74 37                	je     801f8f <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801f58:	83 ec 04             	sub    $0x4,%esp
  801f5b:	ff 75 10             	push   0x10(%ebp)
  801f5e:	ff 75 0c             	push   0xc(%ebp)
  801f61:	53                   	push   %ebx
  801f62:	ff d0                	call   *%eax
  801f64:	83 c4 10             	add    $0x10,%esp
}
  801f67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f6a:	5b                   	pop    %ebx
  801f6b:	5e                   	pop    %esi
  801f6c:	5d                   	pop    %ebp
  801f6d:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801f6e:	a1 14 60 80 00       	mov    0x806014,%eax
  801f73:	8b 40 58             	mov    0x58(%eax),%eax
  801f76:	83 ec 04             	sub    $0x4,%esp
  801f79:	56                   	push   %esi
  801f7a:	50                   	push   %eax
  801f7b:	68 e9 3d 80 00       	push   $0x803de9
  801f80:	e8 c2 eb ff ff       	call   800b47 <cprintf>
		return -E_INVAL;
  801f85:	83 c4 10             	add    $0x10,%esp
  801f88:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f8d:	eb d8                	jmp    801f67 <read+0x58>
		return -E_NOT_SUPP;
  801f8f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801f94:	eb d1                	jmp    801f67 <read+0x58>

00801f96 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f96:	55                   	push   %ebp
  801f97:	89 e5                	mov    %esp,%ebp
  801f99:	57                   	push   %edi
  801f9a:	56                   	push   %esi
  801f9b:	53                   	push   %ebx
  801f9c:	83 ec 0c             	sub    $0xc,%esp
  801f9f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fa2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801fa5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801faa:	eb 02                	jmp    801fae <readn+0x18>
  801fac:	01 c3                	add    %eax,%ebx
  801fae:	39 f3                	cmp    %esi,%ebx
  801fb0:	73 21                	jae    801fd3 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801fb2:	83 ec 04             	sub    $0x4,%esp
  801fb5:	89 f0                	mov    %esi,%eax
  801fb7:	29 d8                	sub    %ebx,%eax
  801fb9:	50                   	push   %eax
  801fba:	89 d8                	mov    %ebx,%eax
  801fbc:	03 45 0c             	add    0xc(%ebp),%eax
  801fbf:	50                   	push   %eax
  801fc0:	57                   	push   %edi
  801fc1:	e8 49 ff ff ff       	call   801f0f <read>
		if (m < 0)
  801fc6:	83 c4 10             	add    $0x10,%esp
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	78 04                	js     801fd1 <readn+0x3b>
			return m;
		if (m == 0)
  801fcd:	75 dd                	jne    801fac <readn+0x16>
  801fcf:	eb 02                	jmp    801fd3 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801fd1:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801fd3:	89 d8                	mov    %ebx,%eax
  801fd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd8:	5b                   	pop    %ebx
  801fd9:	5e                   	pop    %esi
  801fda:	5f                   	pop    %edi
  801fdb:	5d                   	pop    %ebp
  801fdc:	c3                   	ret    

00801fdd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801fdd:	55                   	push   %ebp
  801fde:	89 e5                	mov    %esp,%ebp
  801fe0:	56                   	push   %esi
  801fe1:	53                   	push   %ebx
  801fe2:	83 ec 18             	sub    $0x18,%esp
  801fe5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fe8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801feb:	50                   	push   %eax
  801fec:	53                   	push   %ebx
  801fed:	e8 b4 fc ff ff       	call   801ca6 <fd_lookup>
  801ff2:	83 c4 10             	add    $0x10,%esp
  801ff5:	85 c0                	test   %eax,%eax
  801ff7:	78 37                	js     802030 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ff9:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801ffc:	83 ec 08             	sub    $0x8,%esp
  801fff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802002:	50                   	push   %eax
  802003:	ff 36                	push   (%esi)
  802005:	e8 ec fc ff ff       	call   801cf6 <dev_lookup>
  80200a:	83 c4 10             	add    $0x10,%esp
  80200d:	85 c0                	test   %eax,%eax
  80200f:	78 1f                	js     802030 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802011:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  802015:	74 20                	je     802037 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802017:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201a:	8b 40 0c             	mov    0xc(%eax),%eax
  80201d:	85 c0                	test   %eax,%eax
  80201f:	74 37                	je     802058 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802021:	83 ec 04             	sub    $0x4,%esp
  802024:	ff 75 10             	push   0x10(%ebp)
  802027:	ff 75 0c             	push   0xc(%ebp)
  80202a:	56                   	push   %esi
  80202b:	ff d0                	call   *%eax
  80202d:	83 c4 10             	add    $0x10,%esp
}
  802030:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802033:	5b                   	pop    %ebx
  802034:	5e                   	pop    %esi
  802035:	5d                   	pop    %ebp
  802036:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802037:	a1 14 60 80 00       	mov    0x806014,%eax
  80203c:	8b 40 58             	mov    0x58(%eax),%eax
  80203f:	83 ec 04             	sub    $0x4,%esp
  802042:	53                   	push   %ebx
  802043:	50                   	push   %eax
  802044:	68 05 3e 80 00       	push   $0x803e05
  802049:	e8 f9 ea ff ff       	call   800b47 <cprintf>
		return -E_INVAL;
  80204e:	83 c4 10             	add    $0x10,%esp
  802051:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802056:	eb d8                	jmp    802030 <write+0x53>
		return -E_NOT_SUPP;
  802058:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80205d:	eb d1                	jmp    802030 <write+0x53>

0080205f <seek>:

int
seek(int fdnum, off_t offset)
{
  80205f:	55                   	push   %ebp
  802060:	89 e5                	mov    %esp,%ebp
  802062:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802065:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802068:	50                   	push   %eax
  802069:	ff 75 08             	push   0x8(%ebp)
  80206c:	e8 35 fc ff ff       	call   801ca6 <fd_lookup>
  802071:	83 c4 10             	add    $0x10,%esp
  802074:	85 c0                	test   %eax,%eax
  802076:	78 0e                	js     802086 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802078:	8b 55 0c             	mov    0xc(%ebp),%edx
  80207b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802081:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802086:	c9                   	leave  
  802087:	c3                   	ret    

00802088 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802088:	55                   	push   %ebp
  802089:	89 e5                	mov    %esp,%ebp
  80208b:	56                   	push   %esi
  80208c:	53                   	push   %ebx
  80208d:	83 ec 18             	sub    $0x18,%esp
  802090:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802093:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802096:	50                   	push   %eax
  802097:	53                   	push   %ebx
  802098:	e8 09 fc ff ff       	call   801ca6 <fd_lookup>
  80209d:	83 c4 10             	add    $0x10,%esp
  8020a0:	85 c0                	test   %eax,%eax
  8020a2:	78 34                	js     8020d8 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020a4:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8020a7:	83 ec 08             	sub    $0x8,%esp
  8020aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ad:	50                   	push   %eax
  8020ae:	ff 36                	push   (%esi)
  8020b0:	e8 41 fc ff ff       	call   801cf6 <dev_lookup>
  8020b5:	83 c4 10             	add    $0x10,%esp
  8020b8:	85 c0                	test   %eax,%eax
  8020ba:	78 1c                	js     8020d8 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8020bc:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8020c0:	74 1d                	je     8020df <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8020c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c5:	8b 40 18             	mov    0x18(%eax),%eax
  8020c8:	85 c0                	test   %eax,%eax
  8020ca:	74 34                	je     802100 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8020cc:	83 ec 08             	sub    $0x8,%esp
  8020cf:	ff 75 0c             	push   0xc(%ebp)
  8020d2:	56                   	push   %esi
  8020d3:	ff d0                	call   *%eax
  8020d5:	83 c4 10             	add    $0x10,%esp
}
  8020d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020db:	5b                   	pop    %ebx
  8020dc:	5e                   	pop    %esi
  8020dd:	5d                   	pop    %ebp
  8020de:	c3                   	ret    
			thisenv->env_id, fdnum);
  8020df:	a1 14 60 80 00       	mov    0x806014,%eax
  8020e4:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8020e7:	83 ec 04             	sub    $0x4,%esp
  8020ea:	53                   	push   %ebx
  8020eb:	50                   	push   %eax
  8020ec:	68 c8 3d 80 00       	push   $0x803dc8
  8020f1:	e8 51 ea ff ff       	call   800b47 <cprintf>
		return -E_INVAL;
  8020f6:	83 c4 10             	add    $0x10,%esp
  8020f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8020fe:	eb d8                	jmp    8020d8 <ftruncate+0x50>
		return -E_NOT_SUPP;
  802100:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802105:	eb d1                	jmp    8020d8 <ftruncate+0x50>

00802107 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802107:	55                   	push   %ebp
  802108:	89 e5                	mov    %esp,%ebp
  80210a:	56                   	push   %esi
  80210b:	53                   	push   %ebx
  80210c:	83 ec 18             	sub    $0x18,%esp
  80210f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802112:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802115:	50                   	push   %eax
  802116:	ff 75 08             	push   0x8(%ebp)
  802119:	e8 88 fb ff ff       	call   801ca6 <fd_lookup>
  80211e:	83 c4 10             	add    $0x10,%esp
  802121:	85 c0                	test   %eax,%eax
  802123:	78 49                	js     80216e <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802125:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802128:	83 ec 08             	sub    $0x8,%esp
  80212b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80212e:	50                   	push   %eax
  80212f:	ff 36                	push   (%esi)
  802131:	e8 c0 fb ff ff       	call   801cf6 <dev_lookup>
  802136:	83 c4 10             	add    $0x10,%esp
  802139:	85 c0                	test   %eax,%eax
  80213b:	78 31                	js     80216e <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80213d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802140:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802144:	74 2f                	je     802175 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802146:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802149:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802150:	00 00 00 
	stat->st_isdir = 0;
  802153:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80215a:	00 00 00 
	stat->st_dev = dev;
  80215d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802163:	83 ec 08             	sub    $0x8,%esp
  802166:	53                   	push   %ebx
  802167:	56                   	push   %esi
  802168:	ff 50 14             	call   *0x14(%eax)
  80216b:	83 c4 10             	add    $0x10,%esp
}
  80216e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802171:	5b                   	pop    %ebx
  802172:	5e                   	pop    %esi
  802173:	5d                   	pop    %ebp
  802174:	c3                   	ret    
		return -E_NOT_SUPP;
  802175:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80217a:	eb f2                	jmp    80216e <fstat+0x67>

0080217c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80217c:	55                   	push   %ebp
  80217d:	89 e5                	mov    %esp,%ebp
  80217f:	56                   	push   %esi
  802180:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802181:	83 ec 08             	sub    $0x8,%esp
  802184:	6a 00                	push   $0x0
  802186:	ff 75 08             	push   0x8(%ebp)
  802189:	e8 e4 01 00 00       	call   802372 <open>
  80218e:	89 c3                	mov    %eax,%ebx
  802190:	83 c4 10             	add    $0x10,%esp
  802193:	85 c0                	test   %eax,%eax
  802195:	78 1b                	js     8021b2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802197:	83 ec 08             	sub    $0x8,%esp
  80219a:	ff 75 0c             	push   0xc(%ebp)
  80219d:	50                   	push   %eax
  80219e:	e8 64 ff ff ff       	call   802107 <fstat>
  8021a3:	89 c6                	mov    %eax,%esi
	close(fd);
  8021a5:	89 1c 24             	mov    %ebx,(%esp)
  8021a8:	e8 26 fc ff ff       	call   801dd3 <close>
	return r;
  8021ad:	83 c4 10             	add    $0x10,%esp
  8021b0:	89 f3                	mov    %esi,%ebx
}
  8021b2:	89 d8                	mov    %ebx,%eax
  8021b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021b7:	5b                   	pop    %ebx
  8021b8:	5e                   	pop    %esi
  8021b9:	5d                   	pop    %ebp
  8021ba:	c3                   	ret    

008021bb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8021bb:	55                   	push   %ebp
  8021bc:	89 e5                	mov    %esp,%ebp
  8021be:	56                   	push   %esi
  8021bf:	53                   	push   %ebx
  8021c0:	89 c6                	mov    %eax,%esi
  8021c2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8021c4:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8021cb:	74 27                	je     8021f4 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8021cd:	6a 07                	push   $0x7
  8021cf:	68 00 70 80 00       	push   $0x807000
  8021d4:	56                   	push   %esi
  8021d5:	ff 35 00 80 80 00    	push   0x808000
  8021db:	e8 6f 12 00 00       	call   80344f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8021e0:	83 c4 0c             	add    $0xc,%esp
  8021e3:	6a 00                	push   $0x0
  8021e5:	53                   	push   %ebx
  8021e6:	6a 00                	push   $0x0
  8021e8:	e8 f2 11 00 00       	call   8033df <ipc_recv>
}
  8021ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021f0:	5b                   	pop    %ebx
  8021f1:	5e                   	pop    %esi
  8021f2:	5d                   	pop    %ebp
  8021f3:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8021f4:	83 ec 0c             	sub    $0xc,%esp
  8021f7:	6a 01                	push   $0x1
  8021f9:	e8 a5 12 00 00       	call   8034a3 <ipc_find_env>
  8021fe:	a3 00 80 80 00       	mov    %eax,0x808000
  802203:	83 c4 10             	add    $0x10,%esp
  802206:	eb c5                	jmp    8021cd <fsipc+0x12>

00802208 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802208:	55                   	push   %ebp
  802209:	89 e5                	mov    %esp,%ebp
  80220b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80220e:	8b 45 08             	mov    0x8(%ebp),%eax
  802211:	8b 40 0c             	mov    0xc(%eax),%eax
  802214:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  802219:	8b 45 0c             	mov    0xc(%ebp),%eax
  80221c:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802221:	ba 00 00 00 00       	mov    $0x0,%edx
  802226:	b8 02 00 00 00       	mov    $0x2,%eax
  80222b:	e8 8b ff ff ff       	call   8021bb <fsipc>
}
  802230:	c9                   	leave  
  802231:	c3                   	ret    

00802232 <devfile_flush>:
{
  802232:	55                   	push   %ebp
  802233:	89 e5                	mov    %esp,%ebp
  802235:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802238:	8b 45 08             	mov    0x8(%ebp),%eax
  80223b:	8b 40 0c             	mov    0xc(%eax),%eax
  80223e:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  802243:	ba 00 00 00 00       	mov    $0x0,%edx
  802248:	b8 06 00 00 00       	mov    $0x6,%eax
  80224d:	e8 69 ff ff ff       	call   8021bb <fsipc>
}
  802252:	c9                   	leave  
  802253:	c3                   	ret    

00802254 <devfile_stat>:
{
  802254:	55                   	push   %ebp
  802255:	89 e5                	mov    %esp,%ebp
  802257:	53                   	push   %ebx
  802258:	83 ec 04             	sub    $0x4,%esp
  80225b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80225e:	8b 45 08             	mov    0x8(%ebp),%eax
  802261:	8b 40 0c             	mov    0xc(%eax),%eax
  802264:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802269:	ba 00 00 00 00       	mov    $0x0,%edx
  80226e:	b8 05 00 00 00       	mov    $0x5,%eax
  802273:	e8 43 ff ff ff       	call   8021bb <fsipc>
  802278:	85 c0                	test   %eax,%eax
  80227a:	78 2c                	js     8022a8 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80227c:	83 ec 08             	sub    $0x8,%esp
  80227f:	68 00 70 80 00       	push   $0x807000
  802284:	53                   	push   %ebx
  802285:	e8 87 ef ff ff       	call   801211 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80228a:	a1 80 70 80 00       	mov    0x807080,%eax
  80228f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802295:	a1 84 70 80 00       	mov    0x807084,%eax
  80229a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8022a0:	83 c4 10             	add    $0x10,%esp
  8022a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022ab:	c9                   	leave  
  8022ac:	c3                   	ret    

008022ad <devfile_write>:
{
  8022ad:	55                   	push   %ebp
  8022ae:	89 e5                	mov    %esp,%ebp
  8022b0:	83 ec 0c             	sub    $0xc,%esp
  8022b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8022b6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8022bb:	39 d0                	cmp    %edx,%eax
  8022bd:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8022c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8022c3:	8b 52 0c             	mov    0xc(%edx),%edx
  8022c6:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  8022cc:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8022d1:	50                   	push   %eax
  8022d2:	ff 75 0c             	push   0xc(%ebp)
  8022d5:	68 08 70 80 00       	push   $0x807008
  8022da:	e8 c8 f0 ff ff       	call   8013a7 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8022df:	ba 00 00 00 00       	mov    $0x0,%edx
  8022e4:	b8 04 00 00 00       	mov    $0x4,%eax
  8022e9:	e8 cd fe ff ff       	call   8021bb <fsipc>
}
  8022ee:	c9                   	leave  
  8022ef:	c3                   	ret    

008022f0 <devfile_read>:
{
  8022f0:	55                   	push   %ebp
  8022f1:	89 e5                	mov    %esp,%ebp
  8022f3:	56                   	push   %esi
  8022f4:	53                   	push   %ebx
  8022f5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8022f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8022fe:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  802303:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802309:	ba 00 00 00 00       	mov    $0x0,%edx
  80230e:	b8 03 00 00 00       	mov    $0x3,%eax
  802313:	e8 a3 fe ff ff       	call   8021bb <fsipc>
  802318:	89 c3                	mov    %eax,%ebx
  80231a:	85 c0                	test   %eax,%eax
  80231c:	78 1f                	js     80233d <devfile_read+0x4d>
	assert(r <= n);
  80231e:	39 f0                	cmp    %esi,%eax
  802320:	77 24                	ja     802346 <devfile_read+0x56>
	assert(r <= PGSIZE);
  802322:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802327:	7f 33                	jg     80235c <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802329:	83 ec 04             	sub    $0x4,%esp
  80232c:	50                   	push   %eax
  80232d:	68 00 70 80 00       	push   $0x807000
  802332:	ff 75 0c             	push   0xc(%ebp)
  802335:	e8 6d f0 ff ff       	call   8013a7 <memmove>
	return r;
  80233a:	83 c4 10             	add    $0x10,%esp
}
  80233d:	89 d8                	mov    %ebx,%eax
  80233f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802342:	5b                   	pop    %ebx
  802343:	5e                   	pop    %esi
  802344:	5d                   	pop    %ebp
  802345:	c3                   	ret    
	assert(r <= n);
  802346:	68 38 3e 80 00       	push   $0x803e38
  80234b:	68 a6 38 80 00       	push   $0x8038a6
  802350:	6a 7c                	push   $0x7c
  802352:	68 3f 3e 80 00       	push   $0x803e3f
  802357:	e8 10 e7 ff ff       	call   800a6c <_panic>
	assert(r <= PGSIZE);
  80235c:	68 4a 3e 80 00       	push   $0x803e4a
  802361:	68 a6 38 80 00       	push   $0x8038a6
  802366:	6a 7d                	push   $0x7d
  802368:	68 3f 3e 80 00       	push   $0x803e3f
  80236d:	e8 fa e6 ff ff       	call   800a6c <_panic>

00802372 <open>:
{
  802372:	55                   	push   %ebp
  802373:	89 e5                	mov    %esp,%ebp
  802375:	56                   	push   %esi
  802376:	53                   	push   %ebx
  802377:	83 ec 1c             	sub    $0x1c,%esp
  80237a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80237d:	56                   	push   %esi
  80237e:	e8 53 ee ff ff       	call   8011d6 <strlen>
  802383:	83 c4 10             	add    $0x10,%esp
  802386:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80238b:	7f 6c                	jg     8023f9 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80238d:	83 ec 0c             	sub    $0xc,%esp
  802390:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802393:	50                   	push   %eax
  802394:	e8 bd f8 ff ff       	call   801c56 <fd_alloc>
  802399:	89 c3                	mov    %eax,%ebx
  80239b:	83 c4 10             	add    $0x10,%esp
  80239e:	85 c0                	test   %eax,%eax
  8023a0:	78 3c                	js     8023de <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8023a2:	83 ec 08             	sub    $0x8,%esp
  8023a5:	56                   	push   %esi
  8023a6:	68 00 70 80 00       	push   $0x807000
  8023ab:	e8 61 ee ff ff       	call   801211 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8023b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023b3:	a3 00 74 80 00       	mov    %eax,0x807400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8023b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023bb:	b8 01 00 00 00       	mov    $0x1,%eax
  8023c0:	e8 f6 fd ff ff       	call   8021bb <fsipc>
  8023c5:	89 c3                	mov    %eax,%ebx
  8023c7:	83 c4 10             	add    $0x10,%esp
  8023ca:	85 c0                	test   %eax,%eax
  8023cc:	78 19                	js     8023e7 <open+0x75>
	return fd2num(fd);
  8023ce:	83 ec 0c             	sub    $0xc,%esp
  8023d1:	ff 75 f4             	push   -0xc(%ebp)
  8023d4:	e8 56 f8 ff ff       	call   801c2f <fd2num>
  8023d9:	89 c3                	mov    %eax,%ebx
  8023db:	83 c4 10             	add    $0x10,%esp
}
  8023de:	89 d8                	mov    %ebx,%eax
  8023e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023e3:	5b                   	pop    %ebx
  8023e4:	5e                   	pop    %esi
  8023e5:	5d                   	pop    %ebp
  8023e6:	c3                   	ret    
		fd_close(fd, 0);
  8023e7:	83 ec 08             	sub    $0x8,%esp
  8023ea:	6a 00                	push   $0x0
  8023ec:	ff 75 f4             	push   -0xc(%ebp)
  8023ef:	e8 58 f9 ff ff       	call   801d4c <fd_close>
		return r;
  8023f4:	83 c4 10             	add    $0x10,%esp
  8023f7:	eb e5                	jmp    8023de <open+0x6c>
		return -E_BAD_PATH;
  8023f9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8023fe:	eb de                	jmp    8023de <open+0x6c>

00802400 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802400:	55                   	push   %ebp
  802401:	89 e5                	mov    %esp,%ebp
  802403:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802406:	ba 00 00 00 00       	mov    $0x0,%edx
  80240b:	b8 08 00 00 00       	mov    $0x8,%eax
  802410:	e8 a6 fd ff ff       	call   8021bb <fsipc>
}
  802415:	c9                   	leave  
  802416:	c3                   	ret    

00802417 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  802417:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80241b:	7f 01                	jg     80241e <writebuf+0x7>
  80241d:	c3                   	ret    
{
  80241e:	55                   	push   %ebp
  80241f:	89 e5                	mov    %esp,%ebp
  802421:	53                   	push   %ebx
  802422:	83 ec 08             	sub    $0x8,%esp
  802425:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  802427:	ff 70 04             	push   0x4(%eax)
  80242a:	8d 40 10             	lea    0x10(%eax),%eax
  80242d:	50                   	push   %eax
  80242e:	ff 33                	push   (%ebx)
  802430:	e8 a8 fb ff ff       	call   801fdd <write>
		if (result > 0)
  802435:	83 c4 10             	add    $0x10,%esp
  802438:	85 c0                	test   %eax,%eax
  80243a:	7e 03                	jle    80243f <writebuf+0x28>
			b->result += result;
  80243c:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80243f:	39 43 04             	cmp    %eax,0x4(%ebx)
  802442:	74 0d                	je     802451 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  802444:	85 c0                	test   %eax,%eax
  802446:	ba 00 00 00 00       	mov    $0x0,%edx
  80244b:	0f 4f c2             	cmovg  %edx,%eax
  80244e:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  802451:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802454:	c9                   	leave  
  802455:	c3                   	ret    

00802456 <putch>:

static void
putch(int ch, void *thunk)
{
  802456:	55                   	push   %ebp
  802457:	89 e5                	mov    %esp,%ebp
  802459:	53                   	push   %ebx
  80245a:	83 ec 04             	sub    $0x4,%esp
  80245d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802460:	8b 53 04             	mov    0x4(%ebx),%edx
  802463:	8d 42 01             	lea    0x1(%edx),%eax
  802466:	89 43 04             	mov    %eax,0x4(%ebx)
  802469:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80246c:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  802470:	3d 00 01 00 00       	cmp    $0x100,%eax
  802475:	74 05                	je     80247c <putch+0x26>
		writebuf(b);
		b->idx = 0;
	}
}
  802477:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80247a:	c9                   	leave  
  80247b:	c3                   	ret    
		writebuf(b);
  80247c:	89 d8                	mov    %ebx,%eax
  80247e:	e8 94 ff ff ff       	call   802417 <writebuf>
		b->idx = 0;
  802483:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  80248a:	eb eb                	jmp    802477 <putch+0x21>

0080248c <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80248c:	55                   	push   %ebp
  80248d:	89 e5                	mov    %esp,%ebp
  80248f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  802495:	8b 45 08             	mov    0x8(%ebp),%eax
  802498:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80249e:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8024a5:	00 00 00 
	b.result = 0;
  8024a8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8024af:	00 00 00 
	b.error = 1;
  8024b2:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8024b9:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8024bc:	ff 75 10             	push   0x10(%ebp)
  8024bf:	ff 75 0c             	push   0xc(%ebp)
  8024c2:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024c8:	50                   	push   %eax
  8024c9:	68 56 24 80 00       	push   $0x802456
  8024ce:	e8 6b e7 ff ff       	call   800c3e <vprintfmt>
	if (b.idx > 0)
  8024d3:	83 c4 10             	add    $0x10,%esp
  8024d6:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8024dd:	7f 11                	jg     8024f0 <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  8024df:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8024e5:	85 c0                	test   %eax,%eax
  8024e7:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8024ee:	c9                   	leave  
  8024ef:	c3                   	ret    
		writebuf(&b);
  8024f0:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024f6:	e8 1c ff ff ff       	call   802417 <writebuf>
  8024fb:	eb e2                	jmp    8024df <vfprintf+0x53>

008024fd <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8024fd:	55                   	push   %ebp
  8024fe:	89 e5                	mov    %esp,%ebp
  802500:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802503:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802506:	50                   	push   %eax
  802507:	ff 75 0c             	push   0xc(%ebp)
  80250a:	ff 75 08             	push   0x8(%ebp)
  80250d:	e8 7a ff ff ff       	call   80248c <vfprintf>
	va_end(ap);

	return cnt;
}
  802512:	c9                   	leave  
  802513:	c3                   	ret    

00802514 <printf>:

int
printf(const char *fmt, ...)
{
  802514:	55                   	push   %ebp
  802515:	89 e5                	mov    %esp,%ebp
  802517:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80251a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80251d:	50                   	push   %eax
  80251e:	ff 75 08             	push   0x8(%ebp)
  802521:	6a 01                	push   $0x1
  802523:	e8 64 ff ff ff       	call   80248c <vfprintf>
	va_end(ap);

	return cnt;
}
  802528:	c9                   	leave  
  802529:	c3                   	ret    

0080252a <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80252a:	55                   	push   %ebp
  80252b:	89 e5                	mov    %esp,%ebp
  80252d:	57                   	push   %edi
  80252e:	56                   	push   %esi
  80252f:	53                   	push   %ebx
  802530:	81 ec 84 02 00 00    	sub    $0x284,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  802536:	6a 00                	push   $0x0
  802538:	ff 75 08             	push   0x8(%ebp)
  80253b:	e8 32 fe ff ff       	call   802372 <open>
  802540:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802546:	83 c4 10             	add    $0x10,%esp
  802549:	85 c0                	test   %eax,%eax
  80254b:	0f 88 ad 04 00 00    	js     8029fe <spawn+0x4d4>
  802551:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802553:	83 ec 04             	sub    $0x4,%esp
  802556:	68 00 02 00 00       	push   $0x200
  80255b:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802561:	50                   	push   %eax
  802562:	57                   	push   %edi
  802563:	e8 2e fa ff ff       	call   801f96 <readn>
  802568:	83 c4 10             	add    $0x10,%esp
  80256b:	3d 00 02 00 00       	cmp    $0x200,%eax
  802570:	75 5a                	jne    8025cc <spawn+0xa2>
	    || elf->e_magic != ELF_MAGIC) {
  802572:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802579:	45 4c 46 
  80257c:	75 4e                	jne    8025cc <spawn+0xa2>
  80257e:	b8 07 00 00 00       	mov    $0x7,%eax
  802583:	cd 30                	int    $0x30
  802585:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80258b:	85 c0                	test   %eax,%eax
  80258d:	0f 88 5f 04 00 00    	js     8029f2 <spawn+0x4c8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802593:	25 ff 03 00 00       	and    $0x3ff,%eax
  802598:	69 f0 8c 00 00 00    	imul   $0x8c,%eax,%esi
  80259e:	81 c6 10 00 c0 ee    	add    $0xeec00010,%esi
  8025a4:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8025aa:	b9 11 00 00 00       	mov    $0x11,%ecx
  8025af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8025b1:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8025b7:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025bd:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  8025c2:	be 00 00 00 00       	mov    $0x0,%esi
  8025c7:	8b 7d 0c             	mov    0xc(%ebp),%edi
	for (argc = 0; argv[argc] != 0; argc++)
  8025ca:	eb 4b                	jmp    802617 <spawn+0xed>
		close(fd);
  8025cc:	83 ec 0c             	sub    $0xc,%esp
  8025cf:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  8025d5:	e8 f9 f7 ff ff       	call   801dd3 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8025da:	83 c4 0c             	add    $0xc,%esp
  8025dd:	68 7f 45 4c 46       	push   $0x464c457f
  8025e2:	ff b5 e8 fd ff ff    	push   -0x218(%ebp)
  8025e8:	68 56 3e 80 00       	push   $0x803e56
  8025ed:	e8 55 e5 ff ff       	call   800b47 <cprintf>
		return -E_NOT_EXEC;
  8025f2:	83 c4 10             	add    $0x10,%esp
  8025f5:	c7 85 8c fd ff ff f2 	movl   $0xfffffff2,-0x274(%ebp)
  8025fc:	ff ff ff 
  8025ff:	e9 fa 03 00 00       	jmp    8029fe <spawn+0x4d4>
		string_size += strlen(argv[argc]) + 1;
  802604:	83 ec 0c             	sub    $0xc,%esp
  802607:	50                   	push   %eax
  802608:	e8 c9 eb ff ff       	call   8011d6 <strlen>
  80260d:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  802611:	83 c3 01             	add    $0x1,%ebx
  802614:	83 c4 10             	add    $0x10,%esp
  802617:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80261e:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  802621:	85 c0                	test   %eax,%eax
  802623:	75 df                	jne    802604 <spawn+0xda>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802625:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  80262b:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  802631:	b8 00 10 40 00       	mov    $0x401000,%eax
  802636:	29 f0                	sub    %esi,%eax
  802638:	89 c7                	mov    %eax,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80263a:	89 c2                	mov    %eax,%edx
  80263c:	83 e2 fc             	and    $0xfffffffc,%edx
  80263f:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  802646:	29 c2                	sub    %eax,%edx
  802648:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80264e:	8d 42 f8             	lea    -0x8(%edx),%eax
  802651:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802656:	0f 86 14 04 00 00    	jbe    802a70 <spawn+0x546>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80265c:	83 ec 04             	sub    $0x4,%esp
  80265f:	6a 07                	push   $0x7
  802661:	68 00 00 40 00       	push   $0x400000
  802666:	6a 00                	push   $0x0
  802668:	e8 a0 ef ff ff       	call   80160d <sys_page_alloc>
  80266d:	83 c4 10             	add    $0x10,%esp
  802670:	85 c0                	test   %eax,%eax
  802672:	0f 88 fd 03 00 00    	js     802a75 <spawn+0x54b>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802678:	be 00 00 00 00       	mov    $0x0,%esi
  80267d:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802683:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802686:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  80268c:	7e 32                	jle    8026c0 <spawn+0x196>
		argv_store[i] = UTEMP2USTACK(string_store);
  80268e:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802694:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80269a:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80269d:	83 ec 08             	sub    $0x8,%esp
  8026a0:	ff 34 b3             	push   (%ebx,%esi,4)
  8026a3:	57                   	push   %edi
  8026a4:	e8 68 eb ff ff       	call   801211 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8026a9:	83 c4 04             	add    $0x4,%esp
  8026ac:	ff 34 b3             	push   (%ebx,%esi,4)
  8026af:	e8 22 eb ff ff       	call   8011d6 <strlen>
  8026b4:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  8026b8:	83 c6 01             	add    $0x1,%esi
  8026bb:	83 c4 10             	add    $0x10,%esp
  8026be:	eb c6                	jmp    802686 <spawn+0x15c>
	}
	argv_store[argc] = 0;
  8026c0:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8026c6:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8026cc:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8026d3:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8026d9:	0f 85 8c 00 00 00    	jne    80276b <spawn+0x241>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8026df:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8026e5:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  8026eb:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  8026ee:	89 c8                	mov    %ecx,%eax
  8026f0:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  8026f6:	89 79 f8             	mov    %edi,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8026f9:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8026fe:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802704:	83 ec 0c             	sub    $0xc,%esp
  802707:	6a 07                	push   $0x7
  802709:	68 00 d0 bf ee       	push   $0xeebfd000
  80270e:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  802714:	68 00 00 40 00       	push   $0x400000
  802719:	6a 00                	push   $0x0
  80271b:	e8 30 ef ff ff       	call   801650 <sys_page_map>
  802720:	89 c3                	mov    %eax,%ebx
  802722:	83 c4 20             	add    $0x20,%esp
  802725:	85 c0                	test   %eax,%eax
  802727:	0f 88 50 03 00 00    	js     802a7d <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80272d:	83 ec 08             	sub    $0x8,%esp
  802730:	68 00 00 40 00       	push   $0x400000
  802735:	6a 00                	push   $0x0
  802737:	e8 56 ef ff ff       	call   801692 <sys_page_unmap>
  80273c:	89 c3                	mov    %eax,%ebx
  80273e:	83 c4 10             	add    $0x10,%esp
  802741:	85 c0                	test   %eax,%eax
  802743:	0f 88 34 03 00 00    	js     802a7d <spawn+0x553>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802749:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80274f:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  802756:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80275c:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  802763:	00 00 00 
  802766:	e9 4e 01 00 00       	jmp    8028b9 <spawn+0x38f>
	assert(string_store == (char*)UTEMP + PGSIZE);
  80276b:	68 e0 3e 80 00       	push   $0x803ee0
  802770:	68 a6 38 80 00       	push   $0x8038a6
  802775:	68 f2 00 00 00       	push   $0xf2
  80277a:	68 70 3e 80 00       	push   $0x803e70
  80277f:	e8 e8 e2 ff ff       	call   800a6c <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802784:	83 ec 04             	sub    $0x4,%esp
  802787:	6a 07                	push   $0x7
  802789:	68 00 00 40 00       	push   $0x400000
  80278e:	6a 00                	push   $0x0
  802790:	e8 78 ee ff ff       	call   80160d <sys_page_alloc>
  802795:	83 c4 10             	add    $0x10,%esp
  802798:	85 c0                	test   %eax,%eax
  80279a:	0f 88 6c 02 00 00    	js     802a0c <spawn+0x4e2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8027a0:	83 ec 08             	sub    $0x8,%esp
  8027a3:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8027a9:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8027af:	50                   	push   %eax
  8027b0:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  8027b6:	e8 a4 f8 ff ff       	call   80205f <seek>
  8027bb:	83 c4 10             	add    $0x10,%esp
  8027be:	85 c0                	test   %eax,%eax
  8027c0:	0f 88 4d 02 00 00    	js     802a13 <spawn+0x4e9>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8027c6:	83 ec 04             	sub    $0x4,%esp
  8027c9:	89 f8                	mov    %edi,%eax
  8027cb:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8027d1:	ba 00 10 00 00       	mov    $0x1000,%edx
  8027d6:	39 d0                	cmp    %edx,%eax
  8027d8:	0f 47 c2             	cmova  %edx,%eax
  8027db:	50                   	push   %eax
  8027dc:	68 00 00 40 00       	push   $0x400000
  8027e1:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  8027e7:	e8 aa f7 ff ff       	call   801f96 <readn>
  8027ec:	83 c4 10             	add    $0x10,%esp
  8027ef:	85 c0                	test   %eax,%eax
  8027f1:	0f 88 23 02 00 00    	js     802a1a <spawn+0x4f0>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8027f7:	83 ec 0c             	sub    $0xc,%esp
  8027fa:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  802800:	56                   	push   %esi
  802801:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  802807:	68 00 00 40 00       	push   $0x400000
  80280c:	6a 00                	push   $0x0
  80280e:	e8 3d ee ff ff       	call   801650 <sys_page_map>
  802813:	83 c4 20             	add    $0x20,%esp
  802816:	85 c0                	test   %eax,%eax
  802818:	78 7c                	js     802896 <spawn+0x36c>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  80281a:	83 ec 08             	sub    $0x8,%esp
  80281d:	68 00 00 40 00       	push   $0x400000
  802822:	6a 00                	push   $0x0
  802824:	e8 69 ee ff ff       	call   801692 <sys_page_unmap>
  802829:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  80282c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802832:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802838:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80283e:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  802844:	76 65                	jbe    8028ab <spawn+0x381>
		if (i >= filesz) {
  802846:	39 df                	cmp    %ebx,%edi
  802848:	0f 87 36 ff ff ff    	ja     802784 <spawn+0x25a>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80284e:	83 ec 04             	sub    $0x4,%esp
  802851:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  802857:	56                   	push   %esi
  802858:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  80285e:	e8 aa ed ff ff       	call   80160d <sys_page_alloc>
  802863:	83 c4 10             	add    $0x10,%esp
  802866:	85 c0                	test   %eax,%eax
  802868:	79 c2                	jns    80282c <spawn+0x302>
  80286a:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  80286c:	83 ec 0c             	sub    $0xc,%esp
  80286f:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  802875:	e8 14 ed ff ff       	call   80158e <sys_env_destroy>
	close(fd);
  80287a:	83 c4 04             	add    $0x4,%esp
  80287d:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  802883:	e8 4b f5 ff ff       	call   801dd3 <close>
	return r;
  802888:	83 c4 10             	add    $0x10,%esp
  80288b:	89 bd 8c fd ff ff    	mov    %edi,-0x274(%ebp)
  802891:	e9 68 01 00 00       	jmp    8029fe <spawn+0x4d4>
				panic("spawn: sys_page_map data: %e", r);
  802896:	50                   	push   %eax
  802897:	68 7c 3e 80 00       	push   $0x803e7c
  80289c:	68 25 01 00 00       	push   $0x125
  8028a1:	68 70 3e 80 00       	push   $0x803e70
  8028a6:	e8 c1 e1 ff ff       	call   800a6c <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8028ab:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  8028b2:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  8028b9:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8028c0:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  8028c6:	7e 67                	jle    80292f <spawn+0x405>
		if (ph->p_type != ELF_PROG_LOAD)
  8028c8:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  8028ce:	83 39 01             	cmpl   $0x1,(%ecx)
  8028d1:	75 d8                	jne    8028ab <spawn+0x381>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8028d3:	8b 41 18             	mov    0x18(%ecx),%eax
  8028d6:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8028dc:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8028df:	83 f8 01             	cmp    $0x1,%eax
  8028e2:	19 c0                	sbb    %eax,%eax
  8028e4:	83 e0 fe             	and    $0xfffffffe,%eax
  8028e7:	83 c0 07             	add    $0x7,%eax
  8028ea:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8028f0:	8b 51 04             	mov    0x4(%ecx),%edx
  8028f3:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  8028f9:	8b 79 10             	mov    0x10(%ecx),%edi
  8028fc:	8b 59 14             	mov    0x14(%ecx),%ebx
  8028ff:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802905:	8b 71 08             	mov    0x8(%ecx),%esi
	if ((i = PGOFF(va))) {
  802908:	89 f0                	mov    %esi,%eax
  80290a:	25 ff 0f 00 00       	and    $0xfff,%eax
  80290f:	74 14                	je     802925 <spawn+0x3fb>
		va -= i;
  802911:	29 c6                	sub    %eax,%esi
		memsz += i;
  802913:	01 c3                	add    %eax,%ebx
  802915:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  80291b:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80291d:	29 c2                	sub    %eax,%edx
  80291f:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  802925:	bb 00 00 00 00       	mov    $0x0,%ebx
  80292a:	e9 09 ff ff ff       	jmp    802838 <spawn+0x30e>
	close(fd);
  80292f:	83 ec 0c             	sub    $0xc,%esp
  802932:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  802938:	e8 96 f4 ff ff       	call   801dd3 <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	envid_t this_envid = sys_getenvid();//父进程号
  80293d:	e8 8d ec ff ff       	call   8015cf <sys_getenvid>
  802942:	89 c6                	mov    %eax,%esi
  802944:	83 c4 10             	add    $0x10,%esp
	
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  802947:	bb 00 00 80 00       	mov    $0x800000,%ebx
  80294c:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  802952:	eb 12                	jmp    802966 <spawn+0x43c>
  802954:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80295a:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  802960:	0f 84 bb 00 00 00    	je     802a21 <spawn+0x4f7>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE ) ) {
  802966:	89 d8                	mov    %ebx,%eax
  802968:	c1 e8 16             	shr    $0x16,%eax
  80296b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802972:	a8 01                	test   $0x1,%al
  802974:	74 de                	je     802954 <spawn+0x42a>
  802976:	89 d8                	mov    %ebx,%eax
  802978:	c1 e8 0c             	shr    $0xc,%eax
  80297b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802982:	f6 c2 01             	test   $0x1,%dl
  802985:	74 cd                	je     802954 <spawn+0x42a>
  802987:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80298e:	f6 c6 04             	test   $0x4,%dh
  802991:	74 c1                	je     802954 <spawn+0x42a>
			//Copy the mappings
			if( (r=sys_page_map(this_envid , (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL ) )< 0 ) 
  802993:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80299a:	83 ec 0c             	sub    $0xc,%esp
  80299d:	25 07 0e 00 00       	and    $0xe07,%eax
  8029a2:	50                   	push   %eax
  8029a3:	53                   	push   %ebx
  8029a4:	57                   	push   %edi
  8029a5:	53                   	push   %ebx
  8029a6:	56                   	push   %esi
  8029a7:	e8 a4 ec ff ff       	call   801650 <sys_page_map>
  8029ac:	83 c4 20             	add    $0x20,%esp
  8029af:	85 c0                	test   %eax,%eax
  8029b1:	79 a1                	jns    802954 <spawn+0x42a>
		panic("copy_shared_pages: %e", r);
  8029b3:	50                   	push   %eax
  8029b4:	68 ca 3e 80 00       	push   $0x803eca
  8029b9:	68 82 00 00 00       	push   $0x82
  8029be:	68 70 3e 80 00       	push   $0x803e70
  8029c3:	e8 a4 e0 ff ff       	call   800a6c <_panic>
		panic("sys_env_set_trapframe: %e", r);
  8029c8:	50                   	push   %eax
  8029c9:	68 99 3e 80 00       	push   $0x803e99
  8029ce:	68 86 00 00 00       	push   $0x86
  8029d3:	68 70 3e 80 00       	push   $0x803e70
  8029d8:	e8 8f e0 ff ff       	call   800a6c <_panic>
		panic("sys_env_set_status: %e", r);
  8029dd:	50                   	push   %eax
  8029de:	68 b3 3e 80 00       	push   $0x803eb3
  8029e3:	68 89 00 00 00       	push   $0x89
  8029e8:	68 70 3e 80 00       	push   $0x803e70
  8029ed:	e8 7a e0 ff ff       	call   800a6c <_panic>
		return r;
  8029f2:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8029f8:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
}
  8029fe:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802a04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a07:	5b                   	pop    %ebx
  802a08:	5e                   	pop    %esi
  802a09:	5f                   	pop    %edi
  802a0a:	5d                   	pop    %ebp
  802a0b:	c3                   	ret    
  802a0c:	89 c7                	mov    %eax,%edi
  802a0e:	e9 59 fe ff ff       	jmp    80286c <spawn+0x342>
  802a13:	89 c7                	mov    %eax,%edi
  802a15:	e9 52 fe ff ff       	jmp    80286c <spawn+0x342>
  802a1a:	89 c7                	mov    %eax,%edi
  802a1c:	e9 4b fe ff ff       	jmp    80286c <spawn+0x342>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802a21:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802a28:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802a2b:	83 ec 08             	sub    $0x8,%esp
  802a2e:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802a34:	50                   	push   %eax
  802a35:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  802a3b:	e8 d6 ec ff ff       	call   801716 <sys_env_set_trapframe>
  802a40:	83 c4 10             	add    $0x10,%esp
  802a43:	85 c0                	test   %eax,%eax
  802a45:	78 81                	js     8029c8 <spawn+0x49e>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802a47:	83 ec 08             	sub    $0x8,%esp
  802a4a:	6a 02                	push   $0x2
  802a4c:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  802a52:	e8 7d ec ff ff       	call   8016d4 <sys_env_set_status>
  802a57:	83 c4 10             	add    $0x10,%esp
  802a5a:	85 c0                	test   %eax,%eax
  802a5c:	0f 88 7b ff ff ff    	js     8029dd <spawn+0x4b3>
	return child;
  802a62:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802a68:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802a6e:	eb 8e                	jmp    8029fe <spawn+0x4d4>
		return -E_NO_MEM;
  802a70:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  802a75:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802a7b:	eb 81                	jmp    8029fe <spawn+0x4d4>
	sys_page_unmap(0, UTEMP);
  802a7d:	83 ec 08             	sub    $0x8,%esp
  802a80:	68 00 00 40 00       	push   $0x400000
  802a85:	6a 00                	push   $0x0
  802a87:	e8 06 ec ff ff       	call   801692 <sys_page_unmap>
  802a8c:	83 c4 10             	add    $0x10,%esp
  802a8f:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  802a95:	e9 64 ff ff ff       	jmp    8029fe <spawn+0x4d4>

00802a9a <spawnl>:
{
  802a9a:	55                   	push   %ebp
  802a9b:	89 e5                	mov    %esp,%ebp
  802a9d:	56                   	push   %esi
  802a9e:	53                   	push   %ebx
	va_start(vl, arg0);
  802a9f:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  802aa2:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  802aa7:	eb 05                	jmp    802aae <spawnl+0x14>
		argc++;
  802aa9:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  802aac:	89 ca                	mov    %ecx,%edx
  802aae:	8d 4a 04             	lea    0x4(%edx),%ecx
  802ab1:	83 3a 00             	cmpl   $0x0,(%edx)
  802ab4:	75 f3                	jne    802aa9 <spawnl+0xf>
	const char *argv[argc+2];
  802ab6:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  802abd:	89 d3                	mov    %edx,%ebx
  802abf:	83 e3 f0             	and    $0xfffffff0,%ebx
  802ac2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  802ac8:	89 e1                	mov    %esp,%ecx
  802aca:	29 d1                	sub    %edx,%ecx
  802acc:	39 cc                	cmp    %ecx,%esp
  802ace:	74 10                	je     802ae0 <spawnl+0x46>
  802ad0:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  802ad6:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  802add:	00 
  802ade:	eb ec                	jmp    802acc <spawnl+0x32>
  802ae0:	89 da                	mov    %ebx,%edx
  802ae2:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  802ae8:	29 d4                	sub    %edx,%esp
  802aea:	85 d2                	test   %edx,%edx
  802aec:	74 05                	je     802af3 <spawnl+0x59>
  802aee:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  802af3:	8d 5c 24 03          	lea    0x3(%esp),%ebx
  802af7:	89 da                	mov    %ebx,%edx
  802af9:	c1 ea 02             	shr    $0x2,%edx
  802afc:	83 e3 fc             	and    $0xfffffffc,%ebx
	argv[0] = arg0;
  802aff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b02:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802b09:	c7 44 83 04 00 00 00 	movl   $0x0,0x4(%ebx,%eax,4)
  802b10:	00 
	va_start(vl, arg0);
  802b11:	8d 4d 10             	lea    0x10(%ebp),%ecx
  802b14:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  802b16:	b8 00 00 00 00       	mov    $0x0,%eax
  802b1b:	eb 0b                	jmp    802b28 <spawnl+0x8e>
		argv[i+1] = va_arg(vl, const char *);
  802b1d:	83 c0 01             	add    $0x1,%eax
  802b20:	8b 31                	mov    (%ecx),%esi
  802b22:	89 34 83             	mov    %esi,(%ebx,%eax,4)
  802b25:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  802b28:	39 d0                	cmp    %edx,%eax
  802b2a:	75 f1                	jne    802b1d <spawnl+0x83>
	return spawn(prog, argv);
  802b2c:	83 ec 08             	sub    $0x8,%esp
  802b2f:	53                   	push   %ebx
  802b30:	ff 75 08             	push   0x8(%ebp)
  802b33:	e8 f2 f9 ff ff       	call   80252a <spawn>
}
  802b38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b3b:	5b                   	pop    %ebx
  802b3c:	5e                   	pop    %esi
  802b3d:	5d                   	pop    %ebp
  802b3e:	c3                   	ret    

00802b3f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802b3f:	55                   	push   %ebp
  802b40:	89 e5                	mov    %esp,%ebp
  802b42:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  802b45:	68 06 3f 80 00       	push   $0x803f06
  802b4a:	ff 75 0c             	push   0xc(%ebp)
  802b4d:	e8 bf e6 ff ff       	call   801211 <strcpy>
	return 0;
}
  802b52:	b8 00 00 00 00       	mov    $0x0,%eax
  802b57:	c9                   	leave  
  802b58:	c3                   	ret    

00802b59 <devsock_close>:
{
  802b59:	55                   	push   %ebp
  802b5a:	89 e5                	mov    %esp,%ebp
  802b5c:	53                   	push   %ebx
  802b5d:	83 ec 10             	sub    $0x10,%esp
  802b60:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802b63:	53                   	push   %ebx
  802b64:	e8 79 09 00 00       	call   8034e2 <pageref>
  802b69:	89 c2                	mov    %eax,%edx
  802b6b:	83 c4 10             	add    $0x10,%esp
		return 0;
  802b6e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  802b73:	83 fa 01             	cmp    $0x1,%edx
  802b76:	74 05                	je     802b7d <devsock_close+0x24>
}
  802b78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b7b:	c9                   	leave  
  802b7c:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  802b7d:	83 ec 0c             	sub    $0xc,%esp
  802b80:	ff 73 0c             	push   0xc(%ebx)
  802b83:	e8 b7 02 00 00       	call   802e3f <nsipc_close>
  802b88:	83 c4 10             	add    $0x10,%esp
  802b8b:	eb eb                	jmp    802b78 <devsock_close+0x1f>

00802b8d <devsock_write>:
{
  802b8d:	55                   	push   %ebp
  802b8e:	89 e5                	mov    %esp,%ebp
  802b90:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802b93:	6a 00                	push   $0x0
  802b95:	ff 75 10             	push   0x10(%ebp)
  802b98:	ff 75 0c             	push   0xc(%ebp)
  802b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  802b9e:	ff 70 0c             	push   0xc(%eax)
  802ba1:	e8 79 03 00 00       	call   802f1f <nsipc_send>
}
  802ba6:	c9                   	leave  
  802ba7:	c3                   	ret    

00802ba8 <devsock_read>:
{
  802ba8:	55                   	push   %ebp
  802ba9:	89 e5                	mov    %esp,%ebp
  802bab:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802bae:	6a 00                	push   $0x0
  802bb0:	ff 75 10             	push   0x10(%ebp)
  802bb3:	ff 75 0c             	push   0xc(%ebp)
  802bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  802bb9:	ff 70 0c             	push   0xc(%eax)
  802bbc:	e8 ef 02 00 00       	call   802eb0 <nsipc_recv>
}
  802bc1:	c9                   	leave  
  802bc2:	c3                   	ret    

00802bc3 <fd2sockid>:
{
  802bc3:	55                   	push   %ebp
  802bc4:	89 e5                	mov    %esp,%ebp
  802bc6:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  802bc9:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802bcc:	52                   	push   %edx
  802bcd:	50                   	push   %eax
  802bce:	e8 d3 f0 ff ff       	call   801ca6 <fd_lookup>
  802bd3:	83 c4 10             	add    $0x10,%esp
  802bd6:	85 c0                	test   %eax,%eax
  802bd8:	78 10                	js     802bea <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  802bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802bdd:	8b 0d 3c 50 80 00    	mov    0x80503c,%ecx
  802be3:	39 08                	cmp    %ecx,(%eax)
  802be5:	75 05                	jne    802bec <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  802be7:	8b 40 0c             	mov    0xc(%eax),%eax
}
  802bea:	c9                   	leave  
  802beb:	c3                   	ret    
		return -E_NOT_SUPP;
  802bec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802bf1:	eb f7                	jmp    802bea <fd2sockid+0x27>

00802bf3 <alloc_sockfd>:
{
  802bf3:	55                   	push   %ebp
  802bf4:	89 e5                	mov    %esp,%ebp
  802bf6:	56                   	push   %esi
  802bf7:	53                   	push   %ebx
  802bf8:	83 ec 1c             	sub    $0x1c,%esp
  802bfb:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  802bfd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c00:	50                   	push   %eax
  802c01:	e8 50 f0 ff ff       	call   801c56 <fd_alloc>
  802c06:	89 c3                	mov    %eax,%ebx
  802c08:	83 c4 10             	add    $0x10,%esp
  802c0b:	85 c0                	test   %eax,%eax
  802c0d:	78 43                	js     802c52 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802c0f:	83 ec 04             	sub    $0x4,%esp
  802c12:	68 07 04 00 00       	push   $0x407
  802c17:	ff 75 f4             	push   -0xc(%ebp)
  802c1a:	6a 00                	push   $0x0
  802c1c:	e8 ec e9 ff ff       	call   80160d <sys_page_alloc>
  802c21:	89 c3                	mov    %eax,%ebx
  802c23:	83 c4 10             	add    $0x10,%esp
  802c26:	85 c0                	test   %eax,%eax
  802c28:	78 28                	js     802c52 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  802c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c2d:	8b 15 3c 50 80 00    	mov    0x80503c,%edx
  802c33:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c38:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802c3f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802c42:	83 ec 0c             	sub    $0xc,%esp
  802c45:	50                   	push   %eax
  802c46:	e8 e4 ef ff ff       	call   801c2f <fd2num>
  802c4b:	89 c3                	mov    %eax,%ebx
  802c4d:	83 c4 10             	add    $0x10,%esp
  802c50:	eb 0c                	jmp    802c5e <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  802c52:	83 ec 0c             	sub    $0xc,%esp
  802c55:	56                   	push   %esi
  802c56:	e8 e4 01 00 00       	call   802e3f <nsipc_close>
		return r;
  802c5b:	83 c4 10             	add    $0x10,%esp
}
  802c5e:	89 d8                	mov    %ebx,%eax
  802c60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802c63:	5b                   	pop    %ebx
  802c64:	5e                   	pop    %esi
  802c65:	5d                   	pop    %ebp
  802c66:	c3                   	ret    

00802c67 <accept>:
{
  802c67:	55                   	push   %ebp
  802c68:	89 e5                	mov    %esp,%ebp
  802c6a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  802c70:	e8 4e ff ff ff       	call   802bc3 <fd2sockid>
  802c75:	85 c0                	test   %eax,%eax
  802c77:	78 1b                	js     802c94 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802c79:	83 ec 04             	sub    $0x4,%esp
  802c7c:	ff 75 10             	push   0x10(%ebp)
  802c7f:	ff 75 0c             	push   0xc(%ebp)
  802c82:	50                   	push   %eax
  802c83:	e8 0e 01 00 00       	call   802d96 <nsipc_accept>
  802c88:	83 c4 10             	add    $0x10,%esp
  802c8b:	85 c0                	test   %eax,%eax
  802c8d:	78 05                	js     802c94 <accept+0x2d>
	return alloc_sockfd(r);
  802c8f:	e8 5f ff ff ff       	call   802bf3 <alloc_sockfd>
}
  802c94:	c9                   	leave  
  802c95:	c3                   	ret    

00802c96 <bind>:
{
  802c96:	55                   	push   %ebp
  802c97:	89 e5                	mov    %esp,%ebp
  802c99:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802c9c:	8b 45 08             	mov    0x8(%ebp),%eax
  802c9f:	e8 1f ff ff ff       	call   802bc3 <fd2sockid>
  802ca4:	85 c0                	test   %eax,%eax
  802ca6:	78 12                	js     802cba <bind+0x24>
	return nsipc_bind(r, name, namelen);
  802ca8:	83 ec 04             	sub    $0x4,%esp
  802cab:	ff 75 10             	push   0x10(%ebp)
  802cae:	ff 75 0c             	push   0xc(%ebp)
  802cb1:	50                   	push   %eax
  802cb2:	e8 31 01 00 00       	call   802de8 <nsipc_bind>
  802cb7:	83 c4 10             	add    $0x10,%esp
}
  802cba:	c9                   	leave  
  802cbb:	c3                   	ret    

00802cbc <shutdown>:
{
  802cbc:	55                   	push   %ebp
  802cbd:	89 e5                	mov    %esp,%ebp
  802cbf:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  802cc5:	e8 f9 fe ff ff       	call   802bc3 <fd2sockid>
  802cca:	85 c0                	test   %eax,%eax
  802ccc:	78 0f                	js     802cdd <shutdown+0x21>
	return nsipc_shutdown(r, how);
  802cce:	83 ec 08             	sub    $0x8,%esp
  802cd1:	ff 75 0c             	push   0xc(%ebp)
  802cd4:	50                   	push   %eax
  802cd5:	e8 43 01 00 00       	call   802e1d <nsipc_shutdown>
  802cda:	83 c4 10             	add    $0x10,%esp
}
  802cdd:	c9                   	leave  
  802cde:	c3                   	ret    

00802cdf <connect>:
{
  802cdf:	55                   	push   %ebp
  802ce0:	89 e5                	mov    %esp,%ebp
  802ce2:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802ce5:	8b 45 08             	mov    0x8(%ebp),%eax
  802ce8:	e8 d6 fe ff ff       	call   802bc3 <fd2sockid>
  802ced:	85 c0                	test   %eax,%eax
  802cef:	78 12                	js     802d03 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  802cf1:	83 ec 04             	sub    $0x4,%esp
  802cf4:	ff 75 10             	push   0x10(%ebp)
  802cf7:	ff 75 0c             	push   0xc(%ebp)
  802cfa:	50                   	push   %eax
  802cfb:	e8 59 01 00 00       	call   802e59 <nsipc_connect>
  802d00:	83 c4 10             	add    $0x10,%esp
}
  802d03:	c9                   	leave  
  802d04:	c3                   	ret    

00802d05 <listen>:
{
  802d05:	55                   	push   %ebp
  802d06:	89 e5                	mov    %esp,%ebp
  802d08:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  802d0e:	e8 b0 fe ff ff       	call   802bc3 <fd2sockid>
  802d13:	85 c0                	test   %eax,%eax
  802d15:	78 0f                	js     802d26 <listen+0x21>
	return nsipc_listen(r, backlog);
  802d17:	83 ec 08             	sub    $0x8,%esp
  802d1a:	ff 75 0c             	push   0xc(%ebp)
  802d1d:	50                   	push   %eax
  802d1e:	e8 6b 01 00 00       	call   802e8e <nsipc_listen>
  802d23:	83 c4 10             	add    $0x10,%esp
}
  802d26:	c9                   	leave  
  802d27:	c3                   	ret    

00802d28 <socket>:

int
socket(int domain, int type, int protocol)
{
  802d28:	55                   	push   %ebp
  802d29:	89 e5                	mov    %esp,%ebp
  802d2b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802d2e:	ff 75 10             	push   0x10(%ebp)
  802d31:	ff 75 0c             	push   0xc(%ebp)
  802d34:	ff 75 08             	push   0x8(%ebp)
  802d37:	e8 41 02 00 00       	call   802f7d <nsipc_socket>
  802d3c:	83 c4 10             	add    $0x10,%esp
  802d3f:	85 c0                	test   %eax,%eax
  802d41:	78 05                	js     802d48 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802d43:	e8 ab fe ff ff       	call   802bf3 <alloc_sockfd>
}
  802d48:	c9                   	leave  
  802d49:	c3                   	ret    

00802d4a <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802d4a:	55                   	push   %ebp
  802d4b:	89 e5                	mov    %esp,%ebp
  802d4d:	53                   	push   %ebx
  802d4e:	83 ec 04             	sub    $0x4,%esp
  802d51:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802d53:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802d5a:	74 26                	je     802d82 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802d5c:	6a 07                	push   $0x7
  802d5e:	68 00 90 80 00       	push   $0x809000
  802d63:	53                   	push   %ebx
  802d64:	ff 35 00 a0 80 00    	push   0x80a000
  802d6a:	e8 e0 06 00 00       	call   80344f <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802d6f:	83 c4 0c             	add    $0xc,%esp
  802d72:	6a 00                	push   $0x0
  802d74:	6a 00                	push   $0x0
  802d76:	6a 00                	push   $0x0
  802d78:	e8 62 06 00 00       	call   8033df <ipc_recv>
}
  802d7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d80:	c9                   	leave  
  802d81:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802d82:	83 ec 0c             	sub    $0xc,%esp
  802d85:	6a 02                	push   $0x2
  802d87:	e8 17 07 00 00       	call   8034a3 <ipc_find_env>
  802d8c:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802d91:	83 c4 10             	add    $0x10,%esp
  802d94:	eb c6                	jmp    802d5c <nsipc+0x12>

00802d96 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802d96:	55                   	push   %ebp
  802d97:	89 e5                	mov    %esp,%ebp
  802d99:	56                   	push   %esi
  802d9a:	53                   	push   %ebx
  802d9b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802d9e:	8b 45 08             	mov    0x8(%ebp),%eax
  802da1:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802da6:	8b 06                	mov    (%esi),%eax
  802da8:	a3 04 90 80 00       	mov    %eax,0x809004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802dad:	b8 01 00 00 00       	mov    $0x1,%eax
  802db2:	e8 93 ff ff ff       	call   802d4a <nsipc>
  802db7:	89 c3                	mov    %eax,%ebx
  802db9:	85 c0                	test   %eax,%eax
  802dbb:	79 09                	jns    802dc6 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  802dbd:	89 d8                	mov    %ebx,%eax
  802dbf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802dc2:	5b                   	pop    %ebx
  802dc3:	5e                   	pop    %esi
  802dc4:	5d                   	pop    %ebp
  802dc5:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802dc6:	83 ec 04             	sub    $0x4,%esp
  802dc9:	ff 35 10 90 80 00    	push   0x809010
  802dcf:	68 00 90 80 00       	push   $0x809000
  802dd4:	ff 75 0c             	push   0xc(%ebp)
  802dd7:	e8 cb e5 ff ff       	call   8013a7 <memmove>
		*addrlen = ret->ret_addrlen;
  802ddc:	a1 10 90 80 00       	mov    0x809010,%eax
  802de1:	89 06                	mov    %eax,(%esi)
  802de3:	83 c4 10             	add    $0x10,%esp
	return r;
  802de6:	eb d5                	jmp    802dbd <nsipc_accept+0x27>

00802de8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802de8:	55                   	push   %ebp
  802de9:	89 e5                	mov    %esp,%ebp
  802deb:	53                   	push   %ebx
  802dec:	83 ec 08             	sub    $0x8,%esp
  802def:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802df2:	8b 45 08             	mov    0x8(%ebp),%eax
  802df5:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802dfa:	53                   	push   %ebx
  802dfb:	ff 75 0c             	push   0xc(%ebp)
  802dfe:	68 04 90 80 00       	push   $0x809004
  802e03:	e8 9f e5 ff ff       	call   8013a7 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802e08:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_BIND);
  802e0e:	b8 02 00 00 00       	mov    $0x2,%eax
  802e13:	e8 32 ff ff ff       	call   802d4a <nsipc>
}
  802e18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e1b:	c9                   	leave  
  802e1c:	c3                   	ret    

00802e1d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802e1d:	55                   	push   %ebp
  802e1e:	89 e5                	mov    %esp,%ebp
  802e20:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802e23:	8b 45 08             	mov    0x8(%ebp),%eax
  802e26:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.shutdown.req_how = how;
  802e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e2e:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_SHUTDOWN);
  802e33:	b8 03 00 00 00       	mov    $0x3,%eax
  802e38:	e8 0d ff ff ff       	call   802d4a <nsipc>
}
  802e3d:	c9                   	leave  
  802e3e:	c3                   	ret    

00802e3f <nsipc_close>:

int
nsipc_close(int s)
{
  802e3f:	55                   	push   %ebp
  802e40:	89 e5                	mov    %esp,%ebp
  802e42:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802e45:	8b 45 08             	mov    0x8(%ebp),%eax
  802e48:	a3 00 90 80 00       	mov    %eax,0x809000
	return nsipc(NSREQ_CLOSE);
  802e4d:	b8 04 00 00 00       	mov    $0x4,%eax
  802e52:	e8 f3 fe ff ff       	call   802d4a <nsipc>
}
  802e57:	c9                   	leave  
  802e58:	c3                   	ret    

00802e59 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802e59:	55                   	push   %ebp
  802e5a:	89 e5                	mov    %esp,%ebp
  802e5c:	53                   	push   %ebx
  802e5d:	83 ec 08             	sub    $0x8,%esp
  802e60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802e63:	8b 45 08             	mov    0x8(%ebp),%eax
  802e66:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802e6b:	53                   	push   %ebx
  802e6c:	ff 75 0c             	push   0xc(%ebp)
  802e6f:	68 04 90 80 00       	push   $0x809004
  802e74:	e8 2e e5 ff ff       	call   8013a7 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802e79:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_CONNECT);
  802e7f:	b8 05 00 00 00       	mov    $0x5,%eax
  802e84:	e8 c1 fe ff ff       	call   802d4a <nsipc>
}
  802e89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e8c:	c9                   	leave  
  802e8d:	c3                   	ret    

00802e8e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802e8e:	55                   	push   %ebp
  802e8f:	89 e5                	mov    %esp,%ebp
  802e91:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802e94:	8b 45 08             	mov    0x8(%ebp),%eax
  802e97:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.listen.req_backlog = backlog;
  802e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e9f:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_LISTEN);
  802ea4:	b8 06 00 00 00       	mov    $0x6,%eax
  802ea9:	e8 9c fe ff ff       	call   802d4a <nsipc>
}
  802eae:	c9                   	leave  
  802eaf:	c3                   	ret    

00802eb0 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802eb0:	55                   	push   %ebp
  802eb1:	89 e5                	mov    %esp,%ebp
  802eb3:	56                   	push   %esi
  802eb4:	53                   	push   %ebx
  802eb5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802eb8:	8b 45 08             	mov    0x8(%ebp),%eax
  802ebb:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.recv.req_len = len;
  802ec0:	89 35 04 90 80 00    	mov    %esi,0x809004
	nsipcbuf.recv.req_flags = flags;
  802ec6:	8b 45 14             	mov    0x14(%ebp),%eax
  802ec9:	a3 08 90 80 00       	mov    %eax,0x809008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802ece:	b8 07 00 00 00       	mov    $0x7,%eax
  802ed3:	e8 72 fe ff ff       	call   802d4a <nsipc>
  802ed8:	89 c3                	mov    %eax,%ebx
  802eda:	85 c0                	test   %eax,%eax
  802edc:	78 22                	js     802f00 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  802ede:	b8 3f 06 00 00       	mov    $0x63f,%eax
  802ee3:	39 c6                	cmp    %eax,%esi
  802ee5:	0f 4e c6             	cmovle %esi,%eax
  802ee8:	39 c3                	cmp    %eax,%ebx
  802eea:	7f 1d                	jg     802f09 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802eec:	83 ec 04             	sub    $0x4,%esp
  802eef:	53                   	push   %ebx
  802ef0:	68 00 90 80 00       	push   $0x809000
  802ef5:	ff 75 0c             	push   0xc(%ebp)
  802ef8:	e8 aa e4 ff ff       	call   8013a7 <memmove>
  802efd:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802f00:	89 d8                	mov    %ebx,%eax
  802f02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f05:	5b                   	pop    %ebx
  802f06:	5e                   	pop    %esi
  802f07:	5d                   	pop    %ebp
  802f08:	c3                   	ret    
		assert(r < 1600 && r <= len);
  802f09:	68 12 3f 80 00       	push   $0x803f12
  802f0e:	68 a6 38 80 00       	push   $0x8038a6
  802f13:	6a 62                	push   $0x62
  802f15:	68 27 3f 80 00       	push   $0x803f27
  802f1a:	e8 4d db ff ff       	call   800a6c <_panic>

00802f1f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802f1f:	55                   	push   %ebp
  802f20:	89 e5                	mov    %esp,%ebp
  802f22:	53                   	push   %ebx
  802f23:	83 ec 04             	sub    $0x4,%esp
  802f26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802f29:	8b 45 08             	mov    0x8(%ebp),%eax
  802f2c:	a3 00 90 80 00       	mov    %eax,0x809000
	assert(size < 1600);
  802f31:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802f37:	7f 2e                	jg     802f67 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802f39:	83 ec 04             	sub    $0x4,%esp
  802f3c:	53                   	push   %ebx
  802f3d:	ff 75 0c             	push   0xc(%ebp)
  802f40:	68 0c 90 80 00       	push   $0x80900c
  802f45:	e8 5d e4 ff ff       	call   8013a7 <memmove>
	nsipcbuf.send.req_size = size;
  802f4a:	89 1d 04 90 80 00    	mov    %ebx,0x809004
	nsipcbuf.send.req_flags = flags;
  802f50:	8b 45 14             	mov    0x14(%ebp),%eax
  802f53:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SEND);
  802f58:	b8 08 00 00 00       	mov    $0x8,%eax
  802f5d:	e8 e8 fd ff ff       	call   802d4a <nsipc>
}
  802f62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f65:	c9                   	leave  
  802f66:	c3                   	ret    
	assert(size < 1600);
  802f67:	68 33 3f 80 00       	push   $0x803f33
  802f6c:	68 a6 38 80 00       	push   $0x8038a6
  802f71:	6a 6d                	push   $0x6d
  802f73:	68 27 3f 80 00       	push   $0x803f27
  802f78:	e8 ef da ff ff       	call   800a6c <_panic>

00802f7d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802f7d:	55                   	push   %ebp
  802f7e:	89 e5                	mov    %esp,%ebp
  802f80:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802f83:	8b 45 08             	mov    0x8(%ebp),%eax
  802f86:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.socket.req_type = type;
  802f8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f8e:	a3 04 90 80 00       	mov    %eax,0x809004
	nsipcbuf.socket.req_protocol = protocol;
  802f93:	8b 45 10             	mov    0x10(%ebp),%eax
  802f96:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SOCKET);
  802f9b:	b8 09 00 00 00       	mov    $0x9,%eax
  802fa0:	e8 a5 fd ff ff       	call   802d4a <nsipc>
}
  802fa5:	c9                   	leave  
  802fa6:	c3                   	ret    

00802fa7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802fa7:	55                   	push   %ebp
  802fa8:	89 e5                	mov    %esp,%ebp
  802faa:	56                   	push   %esi
  802fab:	53                   	push   %ebx
  802fac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802faf:	83 ec 0c             	sub    $0xc,%esp
  802fb2:	ff 75 08             	push   0x8(%ebp)
  802fb5:	e8 85 ec ff ff       	call   801c3f <fd2data>
  802fba:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802fbc:	83 c4 08             	add    $0x8,%esp
  802fbf:	68 3f 3f 80 00       	push   $0x803f3f
  802fc4:	53                   	push   %ebx
  802fc5:	e8 47 e2 ff ff       	call   801211 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802fca:	8b 46 04             	mov    0x4(%esi),%eax
  802fcd:	2b 06                	sub    (%esi),%eax
  802fcf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802fd5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802fdc:	00 00 00 
	stat->st_dev = &devpipe;
  802fdf:	c7 83 88 00 00 00 58 	movl   $0x805058,0x88(%ebx)
  802fe6:	50 80 00 
	return 0;
}
  802fe9:	b8 00 00 00 00       	mov    $0x0,%eax
  802fee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ff1:	5b                   	pop    %ebx
  802ff2:	5e                   	pop    %esi
  802ff3:	5d                   	pop    %ebp
  802ff4:	c3                   	ret    

00802ff5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802ff5:	55                   	push   %ebp
  802ff6:	89 e5                	mov    %esp,%ebp
  802ff8:	53                   	push   %ebx
  802ff9:	83 ec 0c             	sub    $0xc,%esp
  802ffc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802fff:	53                   	push   %ebx
  803000:	6a 00                	push   $0x0
  803002:	e8 8b e6 ff ff       	call   801692 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  803007:	89 1c 24             	mov    %ebx,(%esp)
  80300a:	e8 30 ec ff ff       	call   801c3f <fd2data>
  80300f:	83 c4 08             	add    $0x8,%esp
  803012:	50                   	push   %eax
  803013:	6a 00                	push   $0x0
  803015:	e8 78 e6 ff ff       	call   801692 <sys_page_unmap>
}
  80301a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80301d:	c9                   	leave  
  80301e:	c3                   	ret    

0080301f <_pipeisclosed>:
{
  80301f:	55                   	push   %ebp
  803020:	89 e5                	mov    %esp,%ebp
  803022:	57                   	push   %edi
  803023:	56                   	push   %esi
  803024:	53                   	push   %ebx
  803025:	83 ec 1c             	sub    $0x1c,%esp
  803028:	89 c7                	mov    %eax,%edi
  80302a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80302c:	a1 14 60 80 00       	mov    0x806014,%eax
  803031:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  803034:	83 ec 0c             	sub    $0xc,%esp
  803037:	57                   	push   %edi
  803038:	e8 a5 04 00 00       	call   8034e2 <pageref>
  80303d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  803040:	89 34 24             	mov    %esi,(%esp)
  803043:	e8 9a 04 00 00       	call   8034e2 <pageref>
		nn = thisenv->env_runs;
  803048:	8b 15 14 60 80 00    	mov    0x806014,%edx
  80304e:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  803051:	83 c4 10             	add    $0x10,%esp
  803054:	39 cb                	cmp    %ecx,%ebx
  803056:	74 1b                	je     803073 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  803058:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80305b:	75 cf                	jne    80302c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80305d:	8b 42 68             	mov    0x68(%edx),%eax
  803060:	6a 01                	push   $0x1
  803062:	50                   	push   %eax
  803063:	53                   	push   %ebx
  803064:	68 46 3f 80 00       	push   $0x803f46
  803069:	e8 d9 da ff ff       	call   800b47 <cprintf>
  80306e:	83 c4 10             	add    $0x10,%esp
  803071:	eb b9                	jmp    80302c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  803073:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  803076:	0f 94 c0             	sete   %al
  803079:	0f b6 c0             	movzbl %al,%eax
}
  80307c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80307f:	5b                   	pop    %ebx
  803080:	5e                   	pop    %esi
  803081:	5f                   	pop    %edi
  803082:	5d                   	pop    %ebp
  803083:	c3                   	ret    

00803084 <devpipe_write>:
{
  803084:	55                   	push   %ebp
  803085:	89 e5                	mov    %esp,%ebp
  803087:	57                   	push   %edi
  803088:	56                   	push   %esi
  803089:	53                   	push   %ebx
  80308a:	83 ec 28             	sub    $0x28,%esp
  80308d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  803090:	56                   	push   %esi
  803091:	e8 a9 eb ff ff       	call   801c3f <fd2data>
  803096:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  803098:	83 c4 10             	add    $0x10,%esp
  80309b:	bf 00 00 00 00       	mov    $0x0,%edi
  8030a0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8030a3:	75 09                	jne    8030ae <devpipe_write+0x2a>
	return i;
  8030a5:	89 f8                	mov    %edi,%eax
  8030a7:	eb 23                	jmp    8030cc <devpipe_write+0x48>
			sys_yield();
  8030a9:	e8 40 e5 ff ff       	call   8015ee <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8030ae:	8b 43 04             	mov    0x4(%ebx),%eax
  8030b1:	8b 0b                	mov    (%ebx),%ecx
  8030b3:	8d 51 20             	lea    0x20(%ecx),%edx
  8030b6:	39 d0                	cmp    %edx,%eax
  8030b8:	72 1a                	jb     8030d4 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  8030ba:	89 da                	mov    %ebx,%edx
  8030bc:	89 f0                	mov    %esi,%eax
  8030be:	e8 5c ff ff ff       	call   80301f <_pipeisclosed>
  8030c3:	85 c0                	test   %eax,%eax
  8030c5:	74 e2                	je     8030a9 <devpipe_write+0x25>
				return 0;
  8030c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8030cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8030cf:	5b                   	pop    %ebx
  8030d0:	5e                   	pop    %esi
  8030d1:	5f                   	pop    %edi
  8030d2:	5d                   	pop    %ebp
  8030d3:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8030d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8030d7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8030db:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8030de:	89 c2                	mov    %eax,%edx
  8030e0:	c1 fa 1f             	sar    $0x1f,%edx
  8030e3:	89 d1                	mov    %edx,%ecx
  8030e5:	c1 e9 1b             	shr    $0x1b,%ecx
  8030e8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8030eb:	83 e2 1f             	and    $0x1f,%edx
  8030ee:	29 ca                	sub    %ecx,%edx
  8030f0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8030f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8030f8:	83 c0 01             	add    $0x1,%eax
  8030fb:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8030fe:	83 c7 01             	add    $0x1,%edi
  803101:	eb 9d                	jmp    8030a0 <devpipe_write+0x1c>

00803103 <devpipe_read>:
{
  803103:	55                   	push   %ebp
  803104:	89 e5                	mov    %esp,%ebp
  803106:	57                   	push   %edi
  803107:	56                   	push   %esi
  803108:	53                   	push   %ebx
  803109:	83 ec 18             	sub    $0x18,%esp
  80310c:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80310f:	57                   	push   %edi
  803110:	e8 2a eb ff ff       	call   801c3f <fd2data>
  803115:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  803117:	83 c4 10             	add    $0x10,%esp
  80311a:	be 00 00 00 00       	mov    $0x0,%esi
  80311f:	3b 75 10             	cmp    0x10(%ebp),%esi
  803122:	75 13                	jne    803137 <devpipe_read+0x34>
	return i;
  803124:	89 f0                	mov    %esi,%eax
  803126:	eb 02                	jmp    80312a <devpipe_read+0x27>
				return i;
  803128:	89 f0                	mov    %esi,%eax
}
  80312a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80312d:	5b                   	pop    %ebx
  80312e:	5e                   	pop    %esi
  80312f:	5f                   	pop    %edi
  803130:	5d                   	pop    %ebp
  803131:	c3                   	ret    
			sys_yield();
  803132:	e8 b7 e4 ff ff       	call   8015ee <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  803137:	8b 03                	mov    (%ebx),%eax
  803139:	3b 43 04             	cmp    0x4(%ebx),%eax
  80313c:	75 18                	jne    803156 <devpipe_read+0x53>
			if (i > 0)
  80313e:	85 f6                	test   %esi,%esi
  803140:	75 e6                	jne    803128 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  803142:	89 da                	mov    %ebx,%edx
  803144:	89 f8                	mov    %edi,%eax
  803146:	e8 d4 fe ff ff       	call   80301f <_pipeisclosed>
  80314b:	85 c0                	test   %eax,%eax
  80314d:	74 e3                	je     803132 <devpipe_read+0x2f>
				return 0;
  80314f:	b8 00 00 00 00       	mov    $0x0,%eax
  803154:	eb d4                	jmp    80312a <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803156:	99                   	cltd   
  803157:	c1 ea 1b             	shr    $0x1b,%edx
  80315a:	01 d0                	add    %edx,%eax
  80315c:	83 e0 1f             	and    $0x1f,%eax
  80315f:	29 d0                	sub    %edx,%eax
  803161:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  803166:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803169:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80316c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80316f:	83 c6 01             	add    $0x1,%esi
  803172:	eb ab                	jmp    80311f <devpipe_read+0x1c>

00803174 <pipe>:
{
  803174:	55                   	push   %ebp
  803175:	89 e5                	mov    %esp,%ebp
  803177:	56                   	push   %esi
  803178:	53                   	push   %ebx
  803179:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80317c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80317f:	50                   	push   %eax
  803180:	e8 d1 ea ff ff       	call   801c56 <fd_alloc>
  803185:	89 c3                	mov    %eax,%ebx
  803187:	83 c4 10             	add    $0x10,%esp
  80318a:	85 c0                	test   %eax,%eax
  80318c:	0f 88 23 01 00 00    	js     8032b5 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803192:	83 ec 04             	sub    $0x4,%esp
  803195:	68 07 04 00 00       	push   $0x407
  80319a:	ff 75 f4             	push   -0xc(%ebp)
  80319d:	6a 00                	push   $0x0
  80319f:	e8 69 e4 ff ff       	call   80160d <sys_page_alloc>
  8031a4:	89 c3                	mov    %eax,%ebx
  8031a6:	83 c4 10             	add    $0x10,%esp
  8031a9:	85 c0                	test   %eax,%eax
  8031ab:	0f 88 04 01 00 00    	js     8032b5 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  8031b1:	83 ec 0c             	sub    $0xc,%esp
  8031b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8031b7:	50                   	push   %eax
  8031b8:	e8 99 ea ff ff       	call   801c56 <fd_alloc>
  8031bd:	89 c3                	mov    %eax,%ebx
  8031bf:	83 c4 10             	add    $0x10,%esp
  8031c2:	85 c0                	test   %eax,%eax
  8031c4:	0f 88 db 00 00 00    	js     8032a5 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8031ca:	83 ec 04             	sub    $0x4,%esp
  8031cd:	68 07 04 00 00       	push   $0x407
  8031d2:	ff 75 f0             	push   -0x10(%ebp)
  8031d5:	6a 00                	push   $0x0
  8031d7:	e8 31 e4 ff ff       	call   80160d <sys_page_alloc>
  8031dc:	89 c3                	mov    %eax,%ebx
  8031de:	83 c4 10             	add    $0x10,%esp
  8031e1:	85 c0                	test   %eax,%eax
  8031e3:	0f 88 bc 00 00 00    	js     8032a5 <pipe+0x131>
	va = fd2data(fd0);
  8031e9:	83 ec 0c             	sub    $0xc,%esp
  8031ec:	ff 75 f4             	push   -0xc(%ebp)
  8031ef:	e8 4b ea ff ff       	call   801c3f <fd2data>
  8031f4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8031f6:	83 c4 0c             	add    $0xc,%esp
  8031f9:	68 07 04 00 00       	push   $0x407
  8031fe:	50                   	push   %eax
  8031ff:	6a 00                	push   $0x0
  803201:	e8 07 e4 ff ff       	call   80160d <sys_page_alloc>
  803206:	89 c3                	mov    %eax,%ebx
  803208:	83 c4 10             	add    $0x10,%esp
  80320b:	85 c0                	test   %eax,%eax
  80320d:	0f 88 82 00 00 00    	js     803295 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803213:	83 ec 0c             	sub    $0xc,%esp
  803216:	ff 75 f0             	push   -0x10(%ebp)
  803219:	e8 21 ea ff ff       	call   801c3f <fd2data>
  80321e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803225:	50                   	push   %eax
  803226:	6a 00                	push   $0x0
  803228:	56                   	push   %esi
  803229:	6a 00                	push   $0x0
  80322b:	e8 20 e4 ff ff       	call   801650 <sys_page_map>
  803230:	89 c3                	mov    %eax,%ebx
  803232:	83 c4 20             	add    $0x20,%esp
  803235:	85 c0                	test   %eax,%eax
  803237:	78 4e                	js     803287 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  803239:	a1 58 50 80 00       	mov    0x805058,%eax
  80323e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803241:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  803243:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803246:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80324d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  803250:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  803252:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803255:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80325c:	83 ec 0c             	sub    $0xc,%esp
  80325f:	ff 75 f4             	push   -0xc(%ebp)
  803262:	e8 c8 e9 ff ff       	call   801c2f <fd2num>
  803267:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80326a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80326c:	83 c4 04             	add    $0x4,%esp
  80326f:	ff 75 f0             	push   -0x10(%ebp)
  803272:	e8 b8 e9 ff ff       	call   801c2f <fd2num>
  803277:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80327a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80327d:	83 c4 10             	add    $0x10,%esp
  803280:	bb 00 00 00 00       	mov    $0x0,%ebx
  803285:	eb 2e                	jmp    8032b5 <pipe+0x141>
	sys_page_unmap(0, va);
  803287:	83 ec 08             	sub    $0x8,%esp
  80328a:	56                   	push   %esi
  80328b:	6a 00                	push   $0x0
  80328d:	e8 00 e4 ff ff       	call   801692 <sys_page_unmap>
  803292:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  803295:	83 ec 08             	sub    $0x8,%esp
  803298:	ff 75 f0             	push   -0x10(%ebp)
  80329b:	6a 00                	push   $0x0
  80329d:	e8 f0 e3 ff ff       	call   801692 <sys_page_unmap>
  8032a2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8032a5:	83 ec 08             	sub    $0x8,%esp
  8032a8:	ff 75 f4             	push   -0xc(%ebp)
  8032ab:	6a 00                	push   $0x0
  8032ad:	e8 e0 e3 ff ff       	call   801692 <sys_page_unmap>
  8032b2:	83 c4 10             	add    $0x10,%esp
}
  8032b5:	89 d8                	mov    %ebx,%eax
  8032b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8032ba:	5b                   	pop    %ebx
  8032bb:	5e                   	pop    %esi
  8032bc:	5d                   	pop    %ebp
  8032bd:	c3                   	ret    

008032be <pipeisclosed>:
{
  8032be:	55                   	push   %ebp
  8032bf:	89 e5                	mov    %esp,%ebp
  8032c1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8032c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8032c7:	50                   	push   %eax
  8032c8:	ff 75 08             	push   0x8(%ebp)
  8032cb:	e8 d6 e9 ff ff       	call   801ca6 <fd_lookup>
  8032d0:	83 c4 10             	add    $0x10,%esp
  8032d3:	85 c0                	test   %eax,%eax
  8032d5:	78 18                	js     8032ef <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8032d7:	83 ec 0c             	sub    $0xc,%esp
  8032da:	ff 75 f4             	push   -0xc(%ebp)
  8032dd:	e8 5d e9 ff ff       	call   801c3f <fd2data>
  8032e2:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8032e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8032e7:	e8 33 fd ff ff       	call   80301f <_pipeisclosed>
  8032ec:	83 c4 10             	add    $0x10,%esp
}
  8032ef:	c9                   	leave  
  8032f0:	c3                   	ret    

008032f1 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8032f1:	55                   	push   %ebp
  8032f2:	89 e5                	mov    %esp,%ebp
  8032f4:	56                   	push   %esi
  8032f5:	53                   	push   %ebx
  8032f6:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8032f9:	85 f6                	test   %esi,%esi
  8032fb:	74 16                	je     803313 <wait+0x22>
	e = &envs[ENVX(envid)];
  8032fd:	89 f3                	mov    %esi,%ebx
  8032ff:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  803305:	69 db 8c 00 00 00    	imul   $0x8c,%ebx,%ebx
  80330b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  803311:	eb 1b                	jmp    80332e <wait+0x3d>
	assert(envid != 0);
  803313:	68 5e 3f 80 00       	push   $0x803f5e
  803318:	68 a6 38 80 00       	push   $0x8038a6
  80331d:	6a 09                	push   $0x9
  80331f:	68 69 3f 80 00       	push   $0x803f69
  803324:	e8 43 d7 ff ff       	call   800a6c <_panic>
		sys_yield();
  803329:	e8 c0 e2 ff ff       	call   8015ee <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80332e:	8b 43 58             	mov    0x58(%ebx),%eax
  803331:	39 f0                	cmp    %esi,%eax
  803333:	75 07                	jne    80333c <wait+0x4b>
  803335:	8b 43 64             	mov    0x64(%ebx),%eax
  803338:	85 c0                	test   %eax,%eax
  80333a:	75 ed                	jne    803329 <wait+0x38>
}
  80333c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80333f:	5b                   	pop    %ebx
  803340:	5e                   	pop    %esi
  803341:	5d                   	pop    %ebp
  803342:	c3                   	ret    

00803343 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  803343:	55                   	push   %ebp
  803344:	89 e5                	mov    %esp,%ebp
  803346:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  803349:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  803350:	74 0a                	je     80335c <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  803352:	8b 45 08             	mov    0x8(%ebp),%eax
  803355:	a3 04 a0 80 00       	mov    %eax,0x80a004
}
  80335a:	c9                   	leave  
  80335b:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  80335c:	e8 6e e2 ff ff       	call   8015cf <sys_getenvid>
  803361:	83 ec 04             	sub    $0x4,%esp
  803364:	68 07 0e 00 00       	push   $0xe07
  803369:	68 00 f0 bf ee       	push   $0xeebff000
  80336e:	50                   	push   %eax
  80336f:	e8 99 e2 ff ff       	call   80160d <sys_page_alloc>
		if (r < 0) {
  803374:	83 c4 10             	add    $0x10,%esp
  803377:	85 c0                	test   %eax,%eax
  803379:	78 2c                	js     8033a7 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80337b:	e8 4f e2 ff ff       	call   8015cf <sys_getenvid>
  803380:	83 ec 08             	sub    $0x8,%esp
  803383:	68 b9 33 80 00       	push   $0x8033b9
  803388:	50                   	push   %eax
  803389:	e8 ca e3 ff ff       	call   801758 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80338e:	83 c4 10             	add    $0x10,%esp
  803391:	85 c0                	test   %eax,%eax
  803393:	79 bd                	jns    803352 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  803395:	50                   	push   %eax
  803396:	68 b4 3f 80 00       	push   $0x803fb4
  80339b:	6a 28                	push   $0x28
  80339d:	68 ea 3f 80 00       	push   $0x803fea
  8033a2:	e8 c5 d6 ff ff       	call   800a6c <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  8033a7:	50                   	push   %eax
  8033a8:	68 74 3f 80 00       	push   $0x803f74
  8033ad:	6a 23                	push   $0x23
  8033af:	68 ea 3f 80 00       	push   $0x803fea
  8033b4:	e8 b3 d6 ff ff       	call   800a6c <_panic>

008033b9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8033b9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8033ba:	a1 04 a0 80 00       	mov    0x80a004,%eax
	call *%eax
  8033bf:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8033c1:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  8033c4:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  8033c8:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  8033cb:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  8033cf:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  8033d3:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  8033d5:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  8033d8:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  8033d9:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  8033dc:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  8033dd:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  8033de:	c3                   	ret    

008033df <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8033df:	55                   	push   %ebp
  8033e0:	89 e5                	mov    %esp,%ebp
  8033e2:	56                   	push   %esi
  8033e3:	53                   	push   %ebx
  8033e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8033e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8033ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8033ed:	85 c0                	test   %eax,%eax
  8033ef:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8033f4:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8033f7:	83 ec 0c             	sub    $0xc,%esp
  8033fa:	50                   	push   %eax
  8033fb:	e8 bd e3 ff ff       	call   8017bd <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  803400:	83 c4 10             	add    $0x10,%esp
  803403:	85 f6                	test   %esi,%esi
  803405:	74 17                	je     80341e <ipc_recv+0x3f>
  803407:	ba 00 00 00 00       	mov    $0x0,%edx
  80340c:	85 c0                	test   %eax,%eax
  80340e:	78 0c                	js     80341c <ipc_recv+0x3d>
  803410:	8b 15 14 60 80 00    	mov    0x806014,%edx
  803416:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  80341c:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  80341e:	85 db                	test   %ebx,%ebx
  803420:	74 17                	je     803439 <ipc_recv+0x5a>
  803422:	ba 00 00 00 00       	mov    $0x0,%edx
  803427:	85 c0                	test   %eax,%eax
  803429:	78 0c                	js     803437 <ipc_recv+0x58>
  80342b:	8b 15 14 60 80 00    	mov    0x806014,%edx
  803431:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  803437:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  803439:	85 c0                	test   %eax,%eax
  80343b:	78 0b                	js     803448 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  80343d:	a1 14 60 80 00       	mov    0x806014,%eax
  803442:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  803448:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80344b:	5b                   	pop    %ebx
  80344c:	5e                   	pop    %esi
  80344d:	5d                   	pop    %ebp
  80344e:	c3                   	ret    

0080344f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80344f:	55                   	push   %ebp
  803450:	89 e5                	mov    %esp,%ebp
  803452:	57                   	push   %edi
  803453:	56                   	push   %esi
  803454:	53                   	push   %ebx
  803455:	83 ec 0c             	sub    $0xc,%esp
  803458:	8b 7d 08             	mov    0x8(%ebp),%edi
  80345b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80345e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  803461:	85 db                	test   %ebx,%ebx
  803463:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  803468:	0f 44 d8             	cmove  %eax,%ebx
  80346b:	eb 05                	jmp    803472 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80346d:	e8 7c e1 ff ff       	call   8015ee <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  803472:	ff 75 14             	push   0x14(%ebp)
  803475:	53                   	push   %ebx
  803476:	56                   	push   %esi
  803477:	57                   	push   %edi
  803478:	e8 1d e3 ff ff       	call   80179a <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80347d:	83 c4 10             	add    $0x10,%esp
  803480:	83 f8 f9             	cmp    $0xfffffff9,%eax
  803483:	74 e8                	je     80346d <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  803485:	85 c0                	test   %eax,%eax
  803487:	78 08                	js     803491 <ipc_send+0x42>
	}while (r<0);

}
  803489:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80348c:	5b                   	pop    %ebx
  80348d:	5e                   	pop    %esi
  80348e:	5f                   	pop    %edi
  80348f:	5d                   	pop    %ebp
  803490:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  803491:	50                   	push   %eax
  803492:	68 f8 3f 80 00       	push   $0x803ff8
  803497:	6a 3d                	push   $0x3d
  803499:	68 0c 40 80 00       	push   $0x80400c
  80349e:	e8 c9 d5 ff ff       	call   800a6c <_panic>

008034a3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8034a3:	55                   	push   %ebp
  8034a4:	89 e5                	mov    %esp,%ebp
  8034a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8034a9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8034ae:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  8034b4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8034ba:	8b 52 60             	mov    0x60(%edx),%edx
  8034bd:	39 ca                	cmp    %ecx,%edx
  8034bf:	74 11                	je     8034d2 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  8034c1:	83 c0 01             	add    $0x1,%eax
  8034c4:	3d 00 04 00 00       	cmp    $0x400,%eax
  8034c9:	75 e3                	jne    8034ae <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8034cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8034d0:	eb 0e                	jmp    8034e0 <ipc_find_env+0x3d>
			return envs[i].env_id;
  8034d2:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8034d8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8034dd:	8b 40 58             	mov    0x58(%eax),%eax
}
  8034e0:	5d                   	pop    %ebp
  8034e1:	c3                   	ret    

008034e2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8034e2:	55                   	push   %ebp
  8034e3:	89 e5                	mov    %esp,%ebp
  8034e5:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8034e8:	89 c2                	mov    %eax,%edx
  8034ea:	c1 ea 16             	shr    $0x16,%edx
  8034ed:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8034f4:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8034f9:	f6 c1 01             	test   $0x1,%cl
  8034fc:	74 1c                	je     80351a <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8034fe:	c1 e8 0c             	shr    $0xc,%eax
  803501:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  803508:	a8 01                	test   $0x1,%al
  80350a:	74 0e                	je     80351a <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80350c:	c1 e8 0c             	shr    $0xc,%eax
  80350f:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  803516:	ef 
  803517:	0f b7 d2             	movzwl %dx,%edx
}
  80351a:	89 d0                	mov    %edx,%eax
  80351c:	5d                   	pop    %ebp
  80351d:	c3                   	ret    
  80351e:	66 90                	xchg   %ax,%ax

00803520 <__udivdi3>:
  803520:	f3 0f 1e fb          	endbr32 
  803524:	55                   	push   %ebp
  803525:	57                   	push   %edi
  803526:	56                   	push   %esi
  803527:	53                   	push   %ebx
  803528:	83 ec 1c             	sub    $0x1c,%esp
  80352b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80352f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  803533:	8b 74 24 34          	mov    0x34(%esp),%esi
  803537:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80353b:	85 c0                	test   %eax,%eax
  80353d:	75 19                	jne    803558 <__udivdi3+0x38>
  80353f:	39 f3                	cmp    %esi,%ebx
  803541:	76 4d                	jbe    803590 <__udivdi3+0x70>
  803543:	31 ff                	xor    %edi,%edi
  803545:	89 e8                	mov    %ebp,%eax
  803547:	89 f2                	mov    %esi,%edx
  803549:	f7 f3                	div    %ebx
  80354b:	89 fa                	mov    %edi,%edx
  80354d:	83 c4 1c             	add    $0x1c,%esp
  803550:	5b                   	pop    %ebx
  803551:	5e                   	pop    %esi
  803552:	5f                   	pop    %edi
  803553:	5d                   	pop    %ebp
  803554:	c3                   	ret    
  803555:	8d 76 00             	lea    0x0(%esi),%esi
  803558:	39 f0                	cmp    %esi,%eax
  80355a:	76 14                	jbe    803570 <__udivdi3+0x50>
  80355c:	31 ff                	xor    %edi,%edi
  80355e:	31 c0                	xor    %eax,%eax
  803560:	89 fa                	mov    %edi,%edx
  803562:	83 c4 1c             	add    $0x1c,%esp
  803565:	5b                   	pop    %ebx
  803566:	5e                   	pop    %esi
  803567:	5f                   	pop    %edi
  803568:	5d                   	pop    %ebp
  803569:	c3                   	ret    
  80356a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803570:	0f bd f8             	bsr    %eax,%edi
  803573:	83 f7 1f             	xor    $0x1f,%edi
  803576:	75 48                	jne    8035c0 <__udivdi3+0xa0>
  803578:	39 f0                	cmp    %esi,%eax
  80357a:	72 06                	jb     803582 <__udivdi3+0x62>
  80357c:	31 c0                	xor    %eax,%eax
  80357e:	39 eb                	cmp    %ebp,%ebx
  803580:	77 de                	ja     803560 <__udivdi3+0x40>
  803582:	b8 01 00 00 00       	mov    $0x1,%eax
  803587:	eb d7                	jmp    803560 <__udivdi3+0x40>
  803589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803590:	89 d9                	mov    %ebx,%ecx
  803592:	85 db                	test   %ebx,%ebx
  803594:	75 0b                	jne    8035a1 <__udivdi3+0x81>
  803596:	b8 01 00 00 00       	mov    $0x1,%eax
  80359b:	31 d2                	xor    %edx,%edx
  80359d:	f7 f3                	div    %ebx
  80359f:	89 c1                	mov    %eax,%ecx
  8035a1:	31 d2                	xor    %edx,%edx
  8035a3:	89 f0                	mov    %esi,%eax
  8035a5:	f7 f1                	div    %ecx
  8035a7:	89 c6                	mov    %eax,%esi
  8035a9:	89 e8                	mov    %ebp,%eax
  8035ab:	89 f7                	mov    %esi,%edi
  8035ad:	f7 f1                	div    %ecx
  8035af:	89 fa                	mov    %edi,%edx
  8035b1:	83 c4 1c             	add    $0x1c,%esp
  8035b4:	5b                   	pop    %ebx
  8035b5:	5e                   	pop    %esi
  8035b6:	5f                   	pop    %edi
  8035b7:	5d                   	pop    %ebp
  8035b8:	c3                   	ret    
  8035b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8035c0:	89 f9                	mov    %edi,%ecx
  8035c2:	ba 20 00 00 00       	mov    $0x20,%edx
  8035c7:	29 fa                	sub    %edi,%edx
  8035c9:	d3 e0                	shl    %cl,%eax
  8035cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8035cf:	89 d1                	mov    %edx,%ecx
  8035d1:	89 d8                	mov    %ebx,%eax
  8035d3:	d3 e8                	shr    %cl,%eax
  8035d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8035d9:	09 c1                	or     %eax,%ecx
  8035db:	89 f0                	mov    %esi,%eax
  8035dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8035e1:	89 f9                	mov    %edi,%ecx
  8035e3:	d3 e3                	shl    %cl,%ebx
  8035e5:	89 d1                	mov    %edx,%ecx
  8035e7:	d3 e8                	shr    %cl,%eax
  8035e9:	89 f9                	mov    %edi,%ecx
  8035eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8035ef:	89 eb                	mov    %ebp,%ebx
  8035f1:	d3 e6                	shl    %cl,%esi
  8035f3:	89 d1                	mov    %edx,%ecx
  8035f5:	d3 eb                	shr    %cl,%ebx
  8035f7:	09 f3                	or     %esi,%ebx
  8035f9:	89 c6                	mov    %eax,%esi
  8035fb:	89 f2                	mov    %esi,%edx
  8035fd:	89 d8                	mov    %ebx,%eax
  8035ff:	f7 74 24 08          	divl   0x8(%esp)
  803603:	89 d6                	mov    %edx,%esi
  803605:	89 c3                	mov    %eax,%ebx
  803607:	f7 64 24 0c          	mull   0xc(%esp)
  80360b:	39 d6                	cmp    %edx,%esi
  80360d:	72 19                	jb     803628 <__udivdi3+0x108>
  80360f:	89 f9                	mov    %edi,%ecx
  803611:	d3 e5                	shl    %cl,%ebp
  803613:	39 c5                	cmp    %eax,%ebp
  803615:	73 04                	jae    80361b <__udivdi3+0xfb>
  803617:	39 d6                	cmp    %edx,%esi
  803619:	74 0d                	je     803628 <__udivdi3+0x108>
  80361b:	89 d8                	mov    %ebx,%eax
  80361d:	31 ff                	xor    %edi,%edi
  80361f:	e9 3c ff ff ff       	jmp    803560 <__udivdi3+0x40>
  803624:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803628:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80362b:	31 ff                	xor    %edi,%edi
  80362d:	e9 2e ff ff ff       	jmp    803560 <__udivdi3+0x40>
  803632:	66 90                	xchg   %ax,%ax
  803634:	66 90                	xchg   %ax,%ax
  803636:	66 90                	xchg   %ax,%ax
  803638:	66 90                	xchg   %ax,%ax
  80363a:	66 90                	xchg   %ax,%ax
  80363c:	66 90                	xchg   %ax,%ax
  80363e:	66 90                	xchg   %ax,%ax

00803640 <__umoddi3>:
  803640:	f3 0f 1e fb          	endbr32 
  803644:	55                   	push   %ebp
  803645:	57                   	push   %edi
  803646:	56                   	push   %esi
  803647:	53                   	push   %ebx
  803648:	83 ec 1c             	sub    $0x1c,%esp
  80364b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80364f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  803653:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  803657:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80365b:	89 f0                	mov    %esi,%eax
  80365d:	89 da                	mov    %ebx,%edx
  80365f:	85 ff                	test   %edi,%edi
  803661:	75 15                	jne    803678 <__umoddi3+0x38>
  803663:	39 dd                	cmp    %ebx,%ebp
  803665:	76 39                	jbe    8036a0 <__umoddi3+0x60>
  803667:	f7 f5                	div    %ebp
  803669:	89 d0                	mov    %edx,%eax
  80366b:	31 d2                	xor    %edx,%edx
  80366d:	83 c4 1c             	add    $0x1c,%esp
  803670:	5b                   	pop    %ebx
  803671:	5e                   	pop    %esi
  803672:	5f                   	pop    %edi
  803673:	5d                   	pop    %ebp
  803674:	c3                   	ret    
  803675:	8d 76 00             	lea    0x0(%esi),%esi
  803678:	39 df                	cmp    %ebx,%edi
  80367a:	77 f1                	ja     80366d <__umoddi3+0x2d>
  80367c:	0f bd cf             	bsr    %edi,%ecx
  80367f:	83 f1 1f             	xor    $0x1f,%ecx
  803682:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803686:	75 40                	jne    8036c8 <__umoddi3+0x88>
  803688:	39 df                	cmp    %ebx,%edi
  80368a:	72 04                	jb     803690 <__umoddi3+0x50>
  80368c:	39 f5                	cmp    %esi,%ebp
  80368e:	77 dd                	ja     80366d <__umoddi3+0x2d>
  803690:	89 da                	mov    %ebx,%edx
  803692:	89 f0                	mov    %esi,%eax
  803694:	29 e8                	sub    %ebp,%eax
  803696:	19 fa                	sbb    %edi,%edx
  803698:	eb d3                	jmp    80366d <__umoddi3+0x2d>
  80369a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8036a0:	89 e9                	mov    %ebp,%ecx
  8036a2:	85 ed                	test   %ebp,%ebp
  8036a4:	75 0b                	jne    8036b1 <__umoddi3+0x71>
  8036a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8036ab:	31 d2                	xor    %edx,%edx
  8036ad:	f7 f5                	div    %ebp
  8036af:	89 c1                	mov    %eax,%ecx
  8036b1:	89 d8                	mov    %ebx,%eax
  8036b3:	31 d2                	xor    %edx,%edx
  8036b5:	f7 f1                	div    %ecx
  8036b7:	89 f0                	mov    %esi,%eax
  8036b9:	f7 f1                	div    %ecx
  8036bb:	89 d0                	mov    %edx,%eax
  8036bd:	31 d2                	xor    %edx,%edx
  8036bf:	eb ac                	jmp    80366d <__umoddi3+0x2d>
  8036c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8036c8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8036cc:	ba 20 00 00 00       	mov    $0x20,%edx
  8036d1:	29 c2                	sub    %eax,%edx
  8036d3:	89 c1                	mov    %eax,%ecx
  8036d5:	89 e8                	mov    %ebp,%eax
  8036d7:	d3 e7                	shl    %cl,%edi
  8036d9:	89 d1                	mov    %edx,%ecx
  8036db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8036df:	d3 e8                	shr    %cl,%eax
  8036e1:	89 c1                	mov    %eax,%ecx
  8036e3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8036e7:	09 f9                	or     %edi,%ecx
  8036e9:	89 df                	mov    %ebx,%edi
  8036eb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8036ef:	89 c1                	mov    %eax,%ecx
  8036f1:	d3 e5                	shl    %cl,%ebp
  8036f3:	89 d1                	mov    %edx,%ecx
  8036f5:	d3 ef                	shr    %cl,%edi
  8036f7:	89 c1                	mov    %eax,%ecx
  8036f9:	89 f0                	mov    %esi,%eax
  8036fb:	d3 e3                	shl    %cl,%ebx
  8036fd:	89 d1                	mov    %edx,%ecx
  8036ff:	89 fa                	mov    %edi,%edx
  803701:	d3 e8                	shr    %cl,%eax
  803703:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  803708:	09 d8                	or     %ebx,%eax
  80370a:	f7 74 24 08          	divl   0x8(%esp)
  80370e:	89 d3                	mov    %edx,%ebx
  803710:	d3 e6                	shl    %cl,%esi
  803712:	f7 e5                	mul    %ebp
  803714:	89 c7                	mov    %eax,%edi
  803716:	89 d1                	mov    %edx,%ecx
  803718:	39 d3                	cmp    %edx,%ebx
  80371a:	72 06                	jb     803722 <__umoddi3+0xe2>
  80371c:	75 0e                	jne    80372c <__umoddi3+0xec>
  80371e:	39 c6                	cmp    %eax,%esi
  803720:	73 0a                	jae    80372c <__umoddi3+0xec>
  803722:	29 e8                	sub    %ebp,%eax
  803724:	1b 54 24 08          	sbb    0x8(%esp),%edx
  803728:	89 d1                	mov    %edx,%ecx
  80372a:	89 c7                	mov    %eax,%edi
  80372c:	89 f5                	mov    %esi,%ebp
  80372e:	8b 74 24 04          	mov    0x4(%esp),%esi
  803732:	29 fd                	sub    %edi,%ebp
  803734:	19 cb                	sbb    %ecx,%ebx
  803736:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80373b:	89 d8                	mov    %ebx,%eax
  80373d:	d3 e0                	shl    %cl,%eax
  80373f:	89 f1                	mov    %esi,%ecx
  803741:	d3 ed                	shr    %cl,%ebp
  803743:	d3 eb                	shr    %cl,%ebx
  803745:	09 e8                	or     %ebp,%eax
  803747:	89 da                	mov    %ebx,%edx
  803749:	83 c4 1c             	add    $0x1c,%esp
  80374c:	5b                   	pop    %ebx
  80374d:	5e                   	pop    %esi
  80374e:	5f                   	pop    %edi
  80374f:	5d                   	pop    %ebp
  803750:	c3                   	ret    
