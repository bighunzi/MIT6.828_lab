
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
  800046:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
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
  800065:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80006c:	7e 59                	jle    8000c7 <_gettoken+0x94>
			cprintf("GETTOKEN NULL\n");
  80006e:	83 ec 0c             	sub    $0xc,%esp
  800071:	68 80 32 80 00       	push   $0x803280
  800076:	e8 c9 0a 00 00       	call   800b44 <cprintf>
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	eb 47                	jmp    8000c7 <_gettoken+0x94>
		cprintf("GETTOKEN: %s\n", s);
  800080:	83 ec 08             	sub    $0x8,%esp
  800083:	53                   	push   %ebx
  800084:	68 8f 32 80 00       	push   $0x80328f
  800089:	e8 b6 0a 00 00       	call   800b44 <cprintf>
  80008e:	83 c4 10             	add    $0x10,%esp
  800091:	eb bc                	jmp    80004f <_gettoken+0x1c>
		*s++ = 0;
  800093:	83 c3 01             	add    $0x1,%ebx
  800096:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
	while (strchr(WHITESPACE, *s))
  80009a:	83 ec 08             	sub    $0x8,%esp
  80009d:	0f be 03             	movsbl (%ebx),%eax
  8000a0:	50                   	push   %eax
  8000a1:	68 9d 32 80 00       	push   $0x80329d
  8000a6:	e8 74 12 00 00       	call   80131f <strchr>
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
  8000be:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
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
  8000d4:	68 a2 32 80 00       	push   $0x8032a2
  8000d9:	e8 66 0a 00 00       	call   800b44 <cprintf>
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	eb e4                	jmp    8000c7 <_gettoken+0x94>
	if (strchr(SYMBOLS, *s)) {
  8000e3:	83 ec 08             	sub    $0x8,%esp
  8000e6:	0f be c0             	movsbl %al,%eax
  8000e9:	50                   	push   %eax
  8000ea:	68 b3 32 80 00       	push   $0x8032b3
  8000ef:	e8 2b 12 00 00       	call   80131f <strchr>
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
  80010b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800112:	7e b3                	jle    8000c7 <_gettoken+0x94>
			cprintf("TOK %c\n", t);
  800114:	83 ec 08             	sub    $0x8,%esp
  800117:	56                   	push   %esi
  800118:	68 a7 32 80 00       	push   $0x8032a7
  80011d:	e8 22 0a 00 00       	call   800b44 <cprintf>
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
  80013c:	68 af 32 80 00       	push   $0x8032af
  800141:	e8 d9 11 00 00       	call   80131f <strchr>
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	85 c0                	test   %eax,%eax
  80014b:	74 de                	je     80012b <_gettoken+0xf8>
	*p2 = s;
  80014d:	8b 45 10             	mov    0x10(%ebp),%eax
  800150:	89 18                	mov    %ebx,(%eax)
	return 'w';
  800152:	be 77 00 00 00       	mov    $0x77,%esi
	if (debug > 1) {
  800157:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80015e:	0f 8e 63 ff ff ff    	jle    8000c7 <_gettoken+0x94>
		t = **p2;
  800164:	0f b6 33             	movzbl (%ebx),%esi
		**p2 = 0;
  800167:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  80016a:	83 ec 08             	sub    $0x8,%esp
  80016d:	ff 37                	push   (%edi)
  80016f:	68 bb 32 80 00       	push   $0x8032bb
  800174:	e8 cb 09 00 00       	call   800b44 <cprintf>
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
  80019f:	68 0c 50 80 00       	push   $0x80500c
  8001a4:	68 10 50 80 00       	push   $0x805010
  8001a9:	50                   	push   %eax
  8001aa:	e8 84 fe ff ff       	call   800033 <_gettoken>
  8001af:	a3 08 50 80 00       	mov    %eax,0x805008
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
  8001be:	a1 08 50 80 00       	mov    0x805008,%eax
  8001c3:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001c8:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d1:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001d3:	83 ec 04             	sub    $0x4,%esp
  8001d6:	68 0c 50 80 00       	push   $0x80500c
  8001db:	68 10 50 80 00       	push   $0x805010
  8001e0:	ff 35 0c 50 80 00    	push   0x80500c
  8001e6:	e8 48 fe ff ff       	call   800033 <_gettoken>
  8001eb:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  8001f0:	a1 04 50 80 00       	mov    0x805004,%eax
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
  800266:	e8 9b 20 00 00       	call   802306 <open>
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
  800297:	e8 01 2a 00 00       	call   802c9d <pipe>
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	85 c0                	test   %eax,%eax
  8002a1:	0f 88 41 01 00 00    	js     8003e8 <runcmd+0x1ee>
			if (debug)
  8002a7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8002ae:	0f 85 4f 01 00 00    	jne    800403 <runcmd+0x209>
			if ((r = fork()) < 0) {
  8002b4:	e8 40 16 00 00       	call   8018f9 <fork>
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
  8002e0:	e8 82 1a 00 00       	call   801d67 <close>
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
  800304:	68 c5 32 80 00       	push   $0x8032c5
  800309:	e8 36 08 00 00       	call   800b44 <cprintf>
				exit();
  80030e:	e8 3c 07 00 00       	call   800a4f <exit>
  800313:	83 c4 10             	add    $0x10,%esp
  800316:	eb da                	jmp    8002f2 <runcmd+0xf8>
				cprintf("syntax error: < not followed by word\n");
  800318:	83 ec 0c             	sub    $0xc,%esp
  80031b:	68 10 34 80 00       	push   $0x803410
  800320:	e8 1f 08 00 00       	call   800b44 <cprintf>
				exit();
  800325:	e8 25 07 00 00       	call   800a4f <exit>
  80032a:	83 c4 10             	add    $0x10,%esp
  80032d:	e9 2c ff ff ff       	jmp    80025e <runcmd+0x64>
				cprintf("open %s for read: %e", t, fd);
  800332:	83 ec 04             	sub    $0x4,%esp
  800335:	50                   	push   %eax
  800336:	ff 75 a4             	push   -0x5c(%ebp)
  800339:	68 d9 32 80 00       	push   $0x8032d9
  80033e:	e8 01 08 00 00       	call   800b44 <cprintf>
				exit();
  800343:	e8 07 07 00 00       	call   800a4f <exit>
  800348:	83 c4 10             	add    $0x10,%esp
				dup(fd, 0);
  80034b:	83 ec 08             	sub    $0x8,%esp
  80034e:	6a 00                	push   $0x0
  800350:	53                   	push   %ebx
  800351:	e8 63 1a 00 00       	call   801db9 <dup>
				close(fd);
  800356:	89 1c 24             	mov    %ebx,(%esp)
  800359:	e8 09 1a 00 00       	call   801d67 <close>
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
  800384:	e8 7d 1f 00 00       	call   802306 <open>
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
  8003a0:	68 38 34 80 00       	push   $0x803438
  8003a5:	e8 9a 07 00 00       	call   800b44 <cprintf>
				exit();
  8003aa:	e8 a0 06 00 00       	call   800a4f <exit>
  8003af:	83 c4 10             	add    $0x10,%esp
  8003b2:	eb c5                	jmp    800379 <runcmd+0x17f>
				cprintf("open %s for write: %e", t, fd);
  8003b4:	83 ec 04             	sub    $0x4,%esp
  8003b7:	50                   	push   %eax
  8003b8:	ff 75 a4             	push   -0x5c(%ebp)
  8003bb:	68 ee 32 80 00       	push   $0x8032ee
  8003c0:	e8 7f 07 00 00       	call   800b44 <cprintf>
				exit();
  8003c5:	e8 85 06 00 00       	call   800a4f <exit>
  8003ca:	83 c4 10             	add    $0x10,%esp
				dup(fd, 1);
  8003cd:	83 ec 08             	sub    $0x8,%esp
  8003d0:	6a 01                	push   $0x1
  8003d2:	53                   	push   %ebx
  8003d3:	e8 e1 19 00 00       	call   801db9 <dup>
				close(fd);
  8003d8:	89 1c 24             	mov    %ebx,(%esp)
  8003db:	e8 87 19 00 00       	call   801d67 <close>
  8003e0:	83 c4 10             	add    $0x10,%esp
  8003e3:	e9 33 fe ff ff       	jmp    80021b <runcmd+0x21>
				cprintf("pipe: %e", r);
  8003e8:	83 ec 08             	sub    $0x8,%esp
  8003eb:	50                   	push   %eax
  8003ec:	68 04 33 80 00       	push   $0x803304
  8003f1:	e8 4e 07 00 00       	call   800b44 <cprintf>
				exit();
  8003f6:	e8 54 06 00 00       	call   800a4f <exit>
  8003fb:	83 c4 10             	add    $0x10,%esp
  8003fe:	e9 a4 fe ff ff       	jmp    8002a7 <runcmd+0xad>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  800403:	83 ec 04             	sub    $0x4,%esp
  800406:	ff b5 a0 fb ff ff    	push   -0x460(%ebp)
  80040c:	ff b5 9c fb ff ff    	push   -0x464(%ebp)
  800412:	68 0d 33 80 00       	push   $0x80330d
  800417:	e8 28 07 00 00       	call   800b44 <cprintf>
  80041c:	83 c4 10             	add    $0x10,%esp
  80041f:	e9 90 fe ff ff       	jmp    8002b4 <runcmd+0xba>
				cprintf("fork: %e", r);
  800424:	83 ec 08             	sub    $0x8,%esp
  800427:	50                   	push   %eax
  800428:	68 a8 38 80 00       	push   $0x8038a8
  80042d:	e8 12 07 00 00       	call   800b44 <cprintf>
				exit();
  800432:	e8 18 06 00 00       	call   800a4f <exit>
  800437:	83 c4 10             	add    $0x10,%esp
				if (p[1] != 1) {
  80043a:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800440:	83 f8 01             	cmp    $0x1,%eax
  800443:	0f 85 cc 00 00 00    	jne    800515 <runcmd+0x31b>
				close(p[0]);
  800449:	83 ec 0c             	sub    $0xc,%esp
  80044c:	ff b5 9c fb ff ff    	push   -0x464(%ebp)
  800452:	e8 10 19 00 00       	call   801d67 <close>
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
  800476:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80047d:	0f 85 08 01 00 00    	jne    80058b <runcmd+0x391>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	8d 45 a8             	lea    -0x58(%ebp),%eax
  800489:	50                   	push   %eax
  80048a:	ff 75 a8             	push   -0x58(%ebp)
  80048d:	e8 2c 20 00 00       	call   8024be <spawn>
  800492:	89 c6                	mov    %eax,%esi
  800494:	83 c4 10             	add    $0x10,%esp
  800497:	85 c0                	test   %eax,%eax
  800499:	0f 88 3a 01 00 00    	js     8005d9 <runcmd+0x3df>
	close_all();
  80049f:	e8 f0 18 00 00       	call   801d94 <close_all>
		if (debug)
  8004a4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004ab:	0f 85 75 01 00 00    	jne    800626 <runcmd+0x42c>
		wait(r);
  8004b1:	83 ec 0c             	sub    $0xc,%esp
  8004b4:	56                   	push   %esi
  8004b5:	e8 60 29 00 00       	call   802e1a <wait>
		if (debug)
  8004ba:	83 c4 10             	add    $0x10,%esp
  8004bd:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004c4:	0f 85 7b 01 00 00    	jne    800645 <runcmd+0x44b>
	if (pipe_child) {
  8004ca:	85 db                	test   %ebx,%ebx
  8004cc:	74 19                	je     8004e7 <runcmd+0x2ed>
		wait(pipe_child);
  8004ce:	83 ec 0c             	sub    $0xc,%esp
  8004d1:	53                   	push   %ebx
  8004d2:	e8 43 29 00 00       	call   802e1a <wait>
		if (debug)
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004e1:	0f 85 79 01 00 00    	jne    800660 <runcmd+0x466>
	exit();
  8004e7:	e8 63 05 00 00       	call   800a4f <exit>
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
  8004fa:	e8 ba 18 00 00       	call   801db9 <dup>
					close(p[0]);
  8004ff:	83 c4 04             	add    $0x4,%esp
  800502:	ff b5 9c fb ff ff    	push   -0x464(%ebp)
  800508:	e8 5a 18 00 00       	call   801d67 <close>
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	e9 c2 fd ff ff       	jmp    8002d7 <runcmd+0xdd>
					dup(p[1], 1);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	6a 01                	push   $0x1
  80051a:	50                   	push   %eax
  80051b:	e8 99 18 00 00       	call   801db9 <dup>
					close(p[1]);
  800520:	83 c4 04             	add    $0x4,%esp
  800523:	ff b5 a0 fb ff ff    	push   -0x460(%ebp)
  800529:	e8 39 18 00 00       	call   801d67 <close>
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	e9 13 ff ff ff       	jmp    800449 <runcmd+0x24f>
			panic("bad return %d from gettoken", c);
  800536:	53                   	push   %ebx
  800537:	68 1a 33 80 00       	push   $0x80331a
  80053c:	6a 79                	push   $0x79
  80053e:	68 36 33 80 00       	push   $0x803336
  800543:	e8 21 05 00 00       	call   800a69 <_panic>
		if (debug)
  800548:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80054f:	74 9b                	je     8004ec <runcmd+0x2f2>
			cprintf("EMPTY COMMAND\n");
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	68 40 33 80 00       	push   $0x803340
  800559:	e8 e6 05 00 00       	call   800b44 <cprintf>
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
  80057b:	e8 8e 0c 00 00       	call   80120e <strcpy>
		argv[0] = argv0buf;
  800580:	89 75 a8             	mov    %esi,-0x58(%ebp)
  800583:	83 c4 10             	add    $0x10,%esp
  800586:	e9 e3 fe ff ff       	jmp    80046e <runcmd+0x274>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  80058b:	a1 14 50 80 00       	mov    0x805014,%eax
  800590:	8b 40 48             	mov    0x48(%eax),%eax
  800593:	83 ec 08             	sub    $0x8,%esp
  800596:	50                   	push   %eax
  800597:	68 4f 33 80 00       	push   $0x80334f
  80059c:	e8 a3 05 00 00       	call   800b44 <cprintf>
  8005a1:	8d 75 a8             	lea    -0x58(%ebp),%esi
		for (i = 0; argv[i]; i++)
  8005a4:	83 c4 10             	add    $0x10,%esp
  8005a7:	eb 11                	jmp    8005ba <runcmd+0x3c0>
			cprintf(" %s", argv[i]);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	50                   	push   %eax
  8005ad:	68 d7 33 80 00       	push   $0x8033d7
  8005b2:	e8 8d 05 00 00       	call   800b44 <cprintf>
  8005b7:	83 c4 10             	add    $0x10,%esp
		for (i = 0; argv[i]; i++)
  8005ba:	83 c6 04             	add    $0x4,%esi
  8005bd:	8b 46 fc             	mov    -0x4(%esi),%eax
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	75 e5                	jne    8005a9 <runcmd+0x3af>
		cprintf("\n");
  8005c4:	83 ec 0c             	sub    $0xc,%esp
  8005c7:	68 a0 32 80 00       	push   $0x8032a0
  8005cc:	e8 73 05 00 00       	call   800b44 <cprintf>
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	e9 aa fe ff ff       	jmp    800483 <runcmd+0x289>
		cprintf("spawn %s: %e\n", argv[0], r);
  8005d9:	83 ec 04             	sub    $0x4,%esp
  8005dc:	50                   	push   %eax
  8005dd:	ff 75 a8             	push   -0x58(%ebp)
  8005e0:	68 5d 33 80 00       	push   $0x80335d
  8005e5:	e8 5a 05 00 00       	call   800b44 <cprintf>
	close_all();
  8005ea:	e8 a5 17 00 00       	call   801d94 <close_all>
  8005ef:	83 c4 10             	add    $0x10,%esp
	if (pipe_child) {
  8005f2:	85 db                	test   %ebx,%ebx
  8005f4:	0f 84 ed fe ff ff    	je     8004e7 <runcmd+0x2ed>
		if (debug)
  8005fa:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800601:	0f 84 c7 fe ff ff    	je     8004ce <runcmd+0x2d4>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  800607:	a1 14 50 80 00       	mov    0x805014,%eax
  80060c:	8b 40 48             	mov    0x48(%eax),%eax
  80060f:	83 ec 04             	sub    $0x4,%esp
  800612:	53                   	push   %ebx
  800613:	50                   	push   %eax
  800614:	68 96 33 80 00       	push   $0x803396
  800619:	e8 26 05 00 00       	call   800b44 <cprintf>
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	e9 a8 fe ff ff       	jmp    8004ce <runcmd+0x2d4>
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800626:	a1 14 50 80 00       	mov    0x805014,%eax
  80062b:	8b 40 48             	mov    0x48(%eax),%eax
  80062e:	56                   	push   %esi
  80062f:	ff 75 a8             	push   -0x58(%ebp)
  800632:	50                   	push   %eax
  800633:	68 6b 33 80 00       	push   $0x80336b
  800638:	e8 07 05 00 00       	call   800b44 <cprintf>
  80063d:	83 c4 10             	add    $0x10,%esp
  800640:	e9 6c fe ff ff       	jmp    8004b1 <runcmd+0x2b7>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800645:	a1 14 50 80 00       	mov    0x805014,%eax
  80064a:	8b 40 48             	mov    0x48(%eax),%eax
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	50                   	push   %eax
  800651:	68 80 33 80 00       	push   $0x803380
  800656:	e8 e9 04 00 00       	call   800b44 <cprintf>
  80065b:	83 c4 10             	add    $0x10,%esp
  80065e:	eb 92                	jmp    8005f2 <runcmd+0x3f8>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800660:	a1 14 50 80 00       	mov    0x805014,%eax
  800665:	8b 40 48             	mov    0x48(%eax),%eax
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	50                   	push   %eax
  80066c:	68 80 33 80 00       	push   $0x803380
  800671:	e8 ce 04 00 00       	call   800b44 <cprintf>
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
  800684:	68 60 34 80 00       	push   $0x803460
  800689:	e8 b6 04 00 00       	call   800b44 <cprintf>
	exit();
  80068e:	e8 bc 03 00 00       	call   800a4f <exit>
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
  8006ac:	e8 c8 13 00 00       	call   801a79 <argstart>
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
  8006ca:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
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
  8006de:	e8 c6 13 00 00       	call   801aa9 <argnext>
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
  800713:	bf db 33 80 00       	mov    $0x8033db,%edi
  800718:	b8 00 00 00 00       	mov    $0x0,%eax
  80071d:	0f 44 f8             	cmove  %eax,%edi
  800720:	e9 06 01 00 00       	jmp    80082b <umain+0x193>
		usage();
  800725:	e8 54 ff ff ff       	call   80067e <usage>
  80072a:	eb da                	jmp    800706 <umain+0x6e>
		close(0);
  80072c:	83 ec 0c             	sub    $0xc,%esp
  80072f:	6a 00                	push   $0x0
  800731:	e8 31 16 00 00       	call   801d67 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  800736:	83 c4 08             	add    $0x8,%esp
  800739:	6a 00                	push   $0x0
  80073b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073e:	ff 70 04             	push   0x4(%eax)
  800741:	e8 c0 1b 00 00       	call   802306 <open>
  800746:	83 c4 10             	add    $0x10,%esp
  800749:	85 c0                	test   %eax,%eax
  80074b:	78 1b                	js     800768 <umain+0xd0>
		assert(r == 0);
  80074d:	74 bd                	je     80070c <umain+0x74>
  80074f:	68 bf 33 80 00       	push   $0x8033bf
  800754:	68 c6 33 80 00       	push   $0x8033c6
  800759:	68 2a 01 00 00       	push   $0x12a
  80075e:	68 36 33 80 00       	push   $0x803336
  800763:	e8 01 03 00 00       	call   800a69 <_panic>
			panic("open %s: %e", argv[1], r);
  800768:	83 ec 0c             	sub    $0xc,%esp
  80076b:	50                   	push   %eax
  80076c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076f:	ff 70 04             	push   0x4(%eax)
  800772:	68 b3 33 80 00       	push   $0x8033b3
  800777:	68 29 01 00 00       	push   $0x129
  80077c:	68 36 33 80 00       	push   $0x803336
  800781:	e8 e3 02 00 00       	call   800a69 <_panic>
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
  80079a:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007a1:	75 0a                	jne    8007ad <umain+0x115>
				cprintf("EXITING\n");
			exit();	// end of file
  8007a3:	e8 a7 02 00 00       	call   800a4f <exit>
  8007a8:	e9 94 00 00 00       	jmp    800841 <umain+0x1a9>
				cprintf("EXITING\n");
  8007ad:	83 ec 0c             	sub    $0xc,%esp
  8007b0:	68 de 33 80 00       	push   $0x8033de
  8007b5:	e8 8a 03 00 00       	call   800b44 <cprintf>
  8007ba:	83 c4 10             	add    $0x10,%esp
  8007bd:	eb e4                	jmp    8007a3 <umain+0x10b>
		}
		if (debug)
			cprintf("LINE: %s\n", buf);
  8007bf:	83 ec 08             	sub    $0x8,%esp
  8007c2:	53                   	push   %ebx
  8007c3:	68 e7 33 80 00       	push   $0x8033e7
  8007c8:	e8 77 03 00 00       	call   800b44 <cprintf>
  8007cd:	83 c4 10             	add    $0x10,%esp
  8007d0:	eb 7c                	jmp    80084e <umain+0x1b6>
		if (buf[0] == '#')
			continue;
		if (echocmds)
			printf("# %s\n", buf);
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	53                   	push   %ebx
  8007d6:	68 f1 33 80 00       	push   $0x8033f1
  8007db:	e8 c8 1c 00 00       	call   8024a8 <printf>
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	eb 78                	jmp    80085d <umain+0x1c5>
		if (debug)
			cprintf("BEFORE FORK\n");
  8007e5:	83 ec 0c             	sub    $0xc,%esp
  8007e8:	68 f7 33 80 00       	push   $0x8033f7
  8007ed:	e8 52 03 00 00       	call   800b44 <cprintf>
  8007f2:	83 c4 10             	add    $0x10,%esp
  8007f5:	eb 73                	jmp    80086a <umain+0x1d2>
		if ((r = fork()) < 0)
			panic("fork: %e", r);
  8007f7:	50                   	push   %eax
  8007f8:	68 a8 38 80 00       	push   $0x8038a8
  8007fd:	68 41 01 00 00       	push   $0x141
  800802:	68 36 33 80 00       	push   $0x803336
  800807:	e8 5d 02 00 00       	call   800a69 <_panic>
		if (debug)
			cprintf("FORK: %d\n", r);
  80080c:	83 ec 08             	sub    $0x8,%esp
  80080f:	50                   	push   %eax
  800810:	68 04 34 80 00       	push   $0x803404
  800815:	e8 2a 03 00 00       	call   800b44 <cprintf>
  80081a:	83 c4 10             	add    $0x10,%esp
  80081d:	eb 5f                	jmp    80087e <umain+0x1e6>
		if (r == 0) {
			runcmd(buf);
			exit();
		} else
			wait(r);
  80081f:	83 ec 0c             	sub    $0xc,%esp
  800822:	56                   	push   %esi
  800823:	e8 f2 25 00 00       	call   802e1a <wait>
  800828:	83 c4 10             	add    $0x10,%esp
		buf = readline(interactive ? "$ " : NULL);
  80082b:	83 ec 0c             	sub    $0xc,%esp
  80082e:	57                   	push   %edi
  80082f:	e8 af 08 00 00       	call   8010e3 <readline>
  800834:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	85 c0                	test   %eax,%eax
  80083b:	0f 84 59 ff ff ff    	je     80079a <umain+0x102>
		if (debug)
  800841:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800848:	0f 85 71 ff ff ff    	jne    8007bf <umain+0x127>
		if (buf[0] == '#')
  80084e:	80 3b 23             	cmpb   $0x23,(%ebx)
  800851:	74 d8                	je     80082b <umain+0x193>
		if (echocmds)
  800853:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800857:	0f 85 75 ff ff ff    	jne    8007d2 <umain+0x13a>
		if (debug)
  80085d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800864:	0f 85 7b ff ff ff    	jne    8007e5 <umain+0x14d>
		if ((r = fork()) < 0)
  80086a:	e8 8a 10 00 00       	call   8018f9 <fork>
  80086f:	89 c6                	mov    %eax,%esi
  800871:	85 c0                	test   %eax,%eax
  800873:	78 82                	js     8007f7 <umain+0x15f>
		if (debug)
  800875:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80087c:	75 8e                	jne    80080c <umain+0x174>
		if (r == 0) {
  80087e:	85 f6                	test   %esi,%esi
  800880:	75 9d                	jne    80081f <umain+0x187>
			runcmd(buf);
  800882:	83 ec 0c             	sub    $0xc,%esp
  800885:	53                   	push   %ebx
  800886:	e8 6f f9 ff ff       	call   8001fa <runcmd>
			exit();
  80088b:	e8 bf 01 00 00       	call   800a4f <exit>
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
  8008a1:	68 81 34 80 00       	push   $0x803481
  8008a6:	ff 75 0c             	push   0xc(%ebp)
  8008a9:	e8 60 09 00 00       	call   80120e <strcpy>
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
  8008e8:	e8 b7 0a 00 00       	call   8013a4 <memmove>
		sys_cputs(buf, m);
  8008ed:	83 c4 08             	add    $0x8,%esp
  8008f0:	53                   	push   %ebx
  8008f1:	57                   	push   %edi
  8008f2:	e8 57 0c 00 00       	call   80154e <sys_cputs>
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
  80091e:	e8 c8 0c 00 00       	call   8015eb <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800923:	e8 44 0c 00 00       	call   80156c <sys_cgetc>
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
  800958:	e8 f1 0b 00 00       	call   80154e <sys_cputs>
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
  800970:	e8 2e 15 00 00       	call   801ea3 <read>
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
  800998:	e8 a2 12 00 00       	call   801c3f <fd_lookup>
  80099d:	83 c4 10             	add    $0x10,%esp
  8009a0:	85 c0                	test   %eax,%eax
  8009a2:	78 11                	js     8009b5 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8009a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a7:	8b 15 00 40 80 00    	mov    0x804000,%edx
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
  8009c1:	e8 29 12 00 00       	call   801bef <fd_alloc>
  8009c6:	83 c4 10             	add    $0x10,%esp
  8009c9:	85 c0                	test   %eax,%eax
  8009cb:	78 3a                	js     800a07 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8009cd:	83 ec 04             	sub    $0x4,%esp
  8009d0:	68 07 04 00 00       	push   $0x407
  8009d5:	ff 75 f4             	push   -0xc(%ebp)
  8009d8:	6a 00                	push   $0x0
  8009da:	e8 2b 0c 00 00       	call   80160a <sys_page_alloc>
  8009df:	83 c4 10             	add    $0x10,%esp
  8009e2:	85 c0                	test   %eax,%eax
  8009e4:	78 21                	js     800a07 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8009e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009e9:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8009ef:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8009f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009fb:	83 ec 0c             	sub    $0xc,%esp
  8009fe:	50                   	push   %eax
  8009ff:	e8 c4 11 00 00       	call   801bc8 <fd2num>
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
  800a14:	e8 b3 0b 00 00       	call   8015cc <sys_getenvid>
  800a19:	25 ff 03 00 00       	and    $0x3ff,%eax
  800a1e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800a21:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800a26:	a3 14 50 80 00       	mov    %eax,0x805014

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800a2b:	85 db                	test   %ebx,%ebx
  800a2d:	7e 07                	jle    800a36 <libmain+0x2d>
		binaryname = argv[0];
  800a2f:	8b 06                	mov    (%esi),%eax
  800a31:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  800a36:	83 ec 08             	sub    $0x8,%esp
  800a39:	56                   	push   %esi
  800a3a:	53                   	push   %ebx
  800a3b:	e8 58 fc ff ff       	call   800698 <umain>

	// exit gracefully
	exit();
  800a40:	e8 0a 00 00 00       	call   800a4f <exit>
}
  800a45:	83 c4 10             	add    $0x10,%esp
  800a48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a4b:	5b                   	pop    %ebx
  800a4c:	5e                   	pop    %esi
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a55:	e8 3a 13 00 00       	call   801d94 <close_all>
	sys_env_destroy(0);
  800a5a:	83 ec 0c             	sub    $0xc,%esp
  800a5d:	6a 00                	push   $0x0
  800a5f:	e8 27 0b 00 00       	call   80158b <sys_env_destroy>
}
  800a64:	83 c4 10             	add    $0x10,%esp
  800a67:	c9                   	leave  
  800a68:	c3                   	ret    

00800a69 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a6e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a71:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a77:	e8 50 0b 00 00       	call   8015cc <sys_getenvid>
  800a7c:	83 ec 0c             	sub    $0xc,%esp
  800a7f:	ff 75 0c             	push   0xc(%ebp)
  800a82:	ff 75 08             	push   0x8(%ebp)
  800a85:	56                   	push   %esi
  800a86:	50                   	push   %eax
  800a87:	68 98 34 80 00       	push   $0x803498
  800a8c:	e8 b3 00 00 00       	call   800b44 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a91:	83 c4 18             	add    $0x18,%esp
  800a94:	53                   	push   %ebx
  800a95:	ff 75 10             	push   0x10(%ebp)
  800a98:	e8 56 00 00 00       	call   800af3 <vcprintf>
	cprintf("\n");
  800a9d:	c7 04 24 a0 32 80 00 	movl   $0x8032a0,(%esp)
  800aa4:	e8 9b 00 00 00       	call   800b44 <cprintf>
  800aa9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800aac:	cc                   	int3   
  800aad:	eb fd                	jmp    800aac <_panic+0x43>

00800aaf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	53                   	push   %ebx
  800ab3:	83 ec 04             	sub    $0x4,%esp
  800ab6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800ab9:	8b 13                	mov    (%ebx),%edx
  800abb:	8d 42 01             	lea    0x1(%edx),%eax
  800abe:	89 03                	mov    %eax,(%ebx)
  800ac0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800ac7:	3d ff 00 00 00       	cmp    $0xff,%eax
  800acc:	74 09                	je     800ad7 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800ace:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800ad2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ad5:	c9                   	leave  
  800ad6:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800ad7:	83 ec 08             	sub    $0x8,%esp
  800ada:	68 ff 00 00 00       	push   $0xff
  800adf:	8d 43 08             	lea    0x8(%ebx),%eax
  800ae2:	50                   	push   %eax
  800ae3:	e8 66 0a 00 00       	call   80154e <sys_cputs>
		b->idx = 0;
  800ae8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800aee:	83 c4 10             	add    $0x10,%esp
  800af1:	eb db                	jmp    800ace <putch+0x1f>

00800af3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800afc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800b03:	00 00 00 
	b.cnt = 0;
  800b06:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800b0d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800b10:	ff 75 0c             	push   0xc(%ebp)
  800b13:	ff 75 08             	push   0x8(%ebp)
  800b16:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800b1c:	50                   	push   %eax
  800b1d:	68 af 0a 80 00       	push   $0x800aaf
  800b22:	e8 14 01 00 00       	call   800c3b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800b27:	83 c4 08             	add    $0x8,%esp
  800b2a:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800b30:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b36:	50                   	push   %eax
  800b37:	e8 12 0a 00 00       	call   80154e <sys_cputs>

	return b.cnt;
}
  800b3c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b42:	c9                   	leave  
  800b43:	c3                   	ret    

00800b44 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b4a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b4d:	50                   	push   %eax
  800b4e:	ff 75 08             	push   0x8(%ebp)
  800b51:	e8 9d ff ff ff       	call   800af3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800b56:	c9                   	leave  
  800b57:	c3                   	ret    

00800b58 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
  800b5e:	83 ec 1c             	sub    $0x1c,%esp
  800b61:	89 c7                	mov    %eax,%edi
  800b63:	89 d6                	mov    %edx,%esi
  800b65:	8b 45 08             	mov    0x8(%ebp),%eax
  800b68:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6b:	89 d1                	mov    %edx,%ecx
  800b6d:	89 c2                	mov    %eax,%edx
  800b6f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b72:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b75:	8b 45 10             	mov    0x10(%ebp),%eax
  800b78:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b7e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800b85:	39 c2                	cmp    %eax,%edx
  800b87:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800b8a:	72 3e                	jb     800bca <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b8c:	83 ec 0c             	sub    $0xc,%esp
  800b8f:	ff 75 18             	push   0x18(%ebp)
  800b92:	83 eb 01             	sub    $0x1,%ebx
  800b95:	53                   	push   %ebx
  800b96:	50                   	push   %eax
  800b97:	83 ec 08             	sub    $0x8,%esp
  800b9a:	ff 75 e4             	push   -0x1c(%ebp)
  800b9d:	ff 75 e0             	push   -0x20(%ebp)
  800ba0:	ff 75 dc             	push   -0x24(%ebp)
  800ba3:	ff 75 d8             	push   -0x28(%ebp)
  800ba6:	e8 95 24 00 00       	call   803040 <__udivdi3>
  800bab:	83 c4 18             	add    $0x18,%esp
  800bae:	52                   	push   %edx
  800baf:	50                   	push   %eax
  800bb0:	89 f2                	mov    %esi,%edx
  800bb2:	89 f8                	mov    %edi,%eax
  800bb4:	e8 9f ff ff ff       	call   800b58 <printnum>
  800bb9:	83 c4 20             	add    $0x20,%esp
  800bbc:	eb 13                	jmp    800bd1 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800bbe:	83 ec 08             	sub    $0x8,%esp
  800bc1:	56                   	push   %esi
  800bc2:	ff 75 18             	push   0x18(%ebp)
  800bc5:	ff d7                	call   *%edi
  800bc7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800bca:	83 eb 01             	sub    $0x1,%ebx
  800bcd:	85 db                	test   %ebx,%ebx
  800bcf:	7f ed                	jg     800bbe <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800bd1:	83 ec 08             	sub    $0x8,%esp
  800bd4:	56                   	push   %esi
  800bd5:	83 ec 04             	sub    $0x4,%esp
  800bd8:	ff 75 e4             	push   -0x1c(%ebp)
  800bdb:	ff 75 e0             	push   -0x20(%ebp)
  800bde:	ff 75 dc             	push   -0x24(%ebp)
  800be1:	ff 75 d8             	push   -0x28(%ebp)
  800be4:	e8 77 25 00 00       	call   803160 <__umoddi3>
  800be9:	83 c4 14             	add    $0x14,%esp
  800bec:	0f be 80 bb 34 80 00 	movsbl 0x8034bb(%eax),%eax
  800bf3:	50                   	push   %eax
  800bf4:	ff d7                	call   *%edi
}
  800bf6:	83 c4 10             	add    $0x10,%esp
  800bf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c07:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800c0b:	8b 10                	mov    (%eax),%edx
  800c0d:	3b 50 04             	cmp    0x4(%eax),%edx
  800c10:	73 0a                	jae    800c1c <sprintputch+0x1b>
		*b->buf++ = ch;
  800c12:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c15:	89 08                	mov    %ecx,(%eax)
  800c17:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1a:	88 02                	mov    %al,(%edx)
}
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <printfmt>:
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800c24:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c27:	50                   	push   %eax
  800c28:	ff 75 10             	push   0x10(%ebp)
  800c2b:	ff 75 0c             	push   0xc(%ebp)
  800c2e:	ff 75 08             	push   0x8(%ebp)
  800c31:	e8 05 00 00 00       	call   800c3b <vprintfmt>
}
  800c36:	83 c4 10             	add    $0x10,%esp
  800c39:	c9                   	leave  
  800c3a:	c3                   	ret    

00800c3b <vprintfmt>:
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 3c             	sub    $0x3c,%esp
  800c44:	8b 75 08             	mov    0x8(%ebp),%esi
  800c47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c4a:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c4d:	eb 0a                	jmp    800c59 <vprintfmt+0x1e>
			putch(ch, putdat);
  800c4f:	83 ec 08             	sub    $0x8,%esp
  800c52:	53                   	push   %ebx
  800c53:	50                   	push   %eax
  800c54:	ff d6                	call   *%esi
  800c56:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c59:	83 c7 01             	add    $0x1,%edi
  800c5c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c60:	83 f8 25             	cmp    $0x25,%eax
  800c63:	74 0c                	je     800c71 <vprintfmt+0x36>
			if (ch == '\0')
  800c65:	85 c0                	test   %eax,%eax
  800c67:	75 e6                	jne    800c4f <vprintfmt+0x14>
}
  800c69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    
		padc = ' ';
  800c71:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800c75:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800c7c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800c83:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800c8a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800c8f:	8d 47 01             	lea    0x1(%edi),%eax
  800c92:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c95:	0f b6 17             	movzbl (%edi),%edx
  800c98:	8d 42 dd             	lea    -0x23(%edx),%eax
  800c9b:	3c 55                	cmp    $0x55,%al
  800c9d:	0f 87 bb 03 00 00    	ja     80105e <vprintfmt+0x423>
  800ca3:	0f b6 c0             	movzbl %al,%eax
  800ca6:	ff 24 85 00 36 80 00 	jmp    *0x803600(,%eax,4)
  800cad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800cb0:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800cb4:	eb d9                	jmp    800c8f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800cb6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cb9:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800cbd:	eb d0                	jmp    800c8f <vprintfmt+0x54>
  800cbf:	0f b6 d2             	movzbl %dl,%edx
  800cc2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800cc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cca:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800ccd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800cd0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800cd4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800cd7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800cda:	83 f9 09             	cmp    $0x9,%ecx
  800cdd:	77 55                	ja     800d34 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800cdf:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800ce2:	eb e9                	jmp    800ccd <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800ce4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ce7:	8b 00                	mov    (%eax),%eax
  800ce9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800cec:	8b 45 14             	mov    0x14(%ebp),%eax
  800cef:	8d 40 04             	lea    0x4(%eax),%eax
  800cf2:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800cf5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800cf8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800cfc:	79 91                	jns    800c8f <vprintfmt+0x54>
				width = precision, precision = -1;
  800cfe:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d01:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d04:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800d0b:	eb 82                	jmp    800c8f <vprintfmt+0x54>
  800d0d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800d10:	85 d2                	test   %edx,%edx
  800d12:	b8 00 00 00 00       	mov    $0x0,%eax
  800d17:	0f 49 c2             	cmovns %edx,%eax
  800d1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800d1d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800d20:	e9 6a ff ff ff       	jmp    800c8f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800d25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800d28:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800d2f:	e9 5b ff ff ff       	jmp    800c8f <vprintfmt+0x54>
  800d34:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800d37:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d3a:	eb bc                	jmp    800cf8 <vprintfmt+0xbd>
			lflag++;
  800d3c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800d3f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800d42:	e9 48 ff ff ff       	jmp    800c8f <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800d47:	8b 45 14             	mov    0x14(%ebp),%eax
  800d4a:	8d 78 04             	lea    0x4(%eax),%edi
  800d4d:	83 ec 08             	sub    $0x8,%esp
  800d50:	53                   	push   %ebx
  800d51:	ff 30                	push   (%eax)
  800d53:	ff d6                	call   *%esi
			break;
  800d55:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800d58:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800d5b:	e9 9d 02 00 00       	jmp    800ffd <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800d60:	8b 45 14             	mov    0x14(%ebp),%eax
  800d63:	8d 78 04             	lea    0x4(%eax),%edi
  800d66:	8b 10                	mov    (%eax),%edx
  800d68:	89 d0                	mov    %edx,%eax
  800d6a:	f7 d8                	neg    %eax
  800d6c:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d6f:	83 f8 0f             	cmp    $0xf,%eax
  800d72:	7f 23                	jg     800d97 <vprintfmt+0x15c>
  800d74:	8b 14 85 60 37 80 00 	mov    0x803760(,%eax,4),%edx
  800d7b:	85 d2                	test   %edx,%edx
  800d7d:	74 18                	je     800d97 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800d7f:	52                   	push   %edx
  800d80:	68 d8 33 80 00       	push   $0x8033d8
  800d85:	53                   	push   %ebx
  800d86:	56                   	push   %esi
  800d87:	e8 92 fe ff ff       	call   800c1e <printfmt>
  800d8c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800d8f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800d92:	e9 66 02 00 00       	jmp    800ffd <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800d97:	50                   	push   %eax
  800d98:	68 d3 34 80 00       	push   $0x8034d3
  800d9d:	53                   	push   %ebx
  800d9e:	56                   	push   %esi
  800d9f:	e8 7a fe ff ff       	call   800c1e <printfmt>
  800da4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800da7:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800daa:	e9 4e 02 00 00       	jmp    800ffd <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800daf:	8b 45 14             	mov    0x14(%ebp),%eax
  800db2:	83 c0 04             	add    $0x4,%eax
  800db5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800db8:	8b 45 14             	mov    0x14(%ebp),%eax
  800dbb:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800dbd:	85 d2                	test   %edx,%edx
  800dbf:	b8 cc 34 80 00       	mov    $0x8034cc,%eax
  800dc4:	0f 45 c2             	cmovne %edx,%eax
  800dc7:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800dca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800dce:	7e 06                	jle    800dd6 <vprintfmt+0x19b>
  800dd0:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800dd4:	75 0d                	jne    800de3 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800dd6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800dd9:	89 c7                	mov    %eax,%edi
  800ddb:	03 45 e0             	add    -0x20(%ebp),%eax
  800dde:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800de1:	eb 55                	jmp    800e38 <vprintfmt+0x1fd>
  800de3:	83 ec 08             	sub    $0x8,%esp
  800de6:	ff 75 d8             	push   -0x28(%ebp)
  800de9:	ff 75 cc             	push   -0x34(%ebp)
  800dec:	e8 fa 03 00 00       	call   8011eb <strnlen>
  800df1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800df4:	29 c1                	sub    %eax,%ecx
  800df6:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800df9:	83 c4 10             	add    $0x10,%esp
  800dfc:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800dfe:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800e02:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800e05:	eb 0f                	jmp    800e16 <vprintfmt+0x1db>
					putch(padc, putdat);
  800e07:	83 ec 08             	sub    $0x8,%esp
  800e0a:	53                   	push   %ebx
  800e0b:	ff 75 e0             	push   -0x20(%ebp)
  800e0e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800e10:	83 ef 01             	sub    $0x1,%edi
  800e13:	83 c4 10             	add    $0x10,%esp
  800e16:	85 ff                	test   %edi,%edi
  800e18:	7f ed                	jg     800e07 <vprintfmt+0x1cc>
  800e1a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800e1d:	85 d2                	test   %edx,%edx
  800e1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e24:	0f 49 c2             	cmovns %edx,%eax
  800e27:	29 c2                	sub    %eax,%edx
  800e29:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800e2c:	eb a8                	jmp    800dd6 <vprintfmt+0x19b>
					putch(ch, putdat);
  800e2e:	83 ec 08             	sub    $0x8,%esp
  800e31:	53                   	push   %ebx
  800e32:	52                   	push   %edx
  800e33:	ff d6                	call   *%esi
  800e35:	83 c4 10             	add    $0x10,%esp
  800e38:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800e3b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e3d:	83 c7 01             	add    $0x1,%edi
  800e40:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e44:	0f be d0             	movsbl %al,%edx
  800e47:	85 d2                	test   %edx,%edx
  800e49:	74 4b                	je     800e96 <vprintfmt+0x25b>
  800e4b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e4f:	78 06                	js     800e57 <vprintfmt+0x21c>
  800e51:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800e55:	78 1e                	js     800e75 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800e57:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800e5b:	74 d1                	je     800e2e <vprintfmt+0x1f3>
  800e5d:	0f be c0             	movsbl %al,%eax
  800e60:	83 e8 20             	sub    $0x20,%eax
  800e63:	83 f8 5e             	cmp    $0x5e,%eax
  800e66:	76 c6                	jbe    800e2e <vprintfmt+0x1f3>
					putch('?', putdat);
  800e68:	83 ec 08             	sub    $0x8,%esp
  800e6b:	53                   	push   %ebx
  800e6c:	6a 3f                	push   $0x3f
  800e6e:	ff d6                	call   *%esi
  800e70:	83 c4 10             	add    $0x10,%esp
  800e73:	eb c3                	jmp    800e38 <vprintfmt+0x1fd>
  800e75:	89 cf                	mov    %ecx,%edi
  800e77:	eb 0e                	jmp    800e87 <vprintfmt+0x24c>
				putch(' ', putdat);
  800e79:	83 ec 08             	sub    $0x8,%esp
  800e7c:	53                   	push   %ebx
  800e7d:	6a 20                	push   $0x20
  800e7f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800e81:	83 ef 01             	sub    $0x1,%edi
  800e84:	83 c4 10             	add    $0x10,%esp
  800e87:	85 ff                	test   %edi,%edi
  800e89:	7f ee                	jg     800e79 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800e8b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800e8e:	89 45 14             	mov    %eax,0x14(%ebp)
  800e91:	e9 67 01 00 00       	jmp    800ffd <vprintfmt+0x3c2>
  800e96:	89 cf                	mov    %ecx,%edi
  800e98:	eb ed                	jmp    800e87 <vprintfmt+0x24c>
	if (lflag >= 2)
  800e9a:	83 f9 01             	cmp    $0x1,%ecx
  800e9d:	7f 1b                	jg     800eba <vprintfmt+0x27f>
	else if (lflag)
  800e9f:	85 c9                	test   %ecx,%ecx
  800ea1:	74 63                	je     800f06 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800ea3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ea6:	8b 00                	mov    (%eax),%eax
  800ea8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800eab:	99                   	cltd   
  800eac:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800eaf:	8b 45 14             	mov    0x14(%ebp),%eax
  800eb2:	8d 40 04             	lea    0x4(%eax),%eax
  800eb5:	89 45 14             	mov    %eax,0x14(%ebp)
  800eb8:	eb 17                	jmp    800ed1 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800eba:	8b 45 14             	mov    0x14(%ebp),%eax
  800ebd:	8b 50 04             	mov    0x4(%eax),%edx
  800ec0:	8b 00                	mov    (%eax),%eax
  800ec2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ec5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ec8:	8b 45 14             	mov    0x14(%ebp),%eax
  800ecb:	8d 40 08             	lea    0x8(%eax),%eax
  800ece:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800ed1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ed4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800ed7:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800edc:	85 c9                	test   %ecx,%ecx
  800ede:	0f 89 ff 00 00 00    	jns    800fe3 <vprintfmt+0x3a8>
				putch('-', putdat);
  800ee4:	83 ec 08             	sub    $0x8,%esp
  800ee7:	53                   	push   %ebx
  800ee8:	6a 2d                	push   $0x2d
  800eea:	ff d6                	call   *%esi
				num = -(long long) num;
  800eec:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800eef:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800ef2:	f7 da                	neg    %edx
  800ef4:	83 d1 00             	adc    $0x0,%ecx
  800ef7:	f7 d9                	neg    %ecx
  800ef9:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800efc:	bf 0a 00 00 00       	mov    $0xa,%edi
  800f01:	e9 dd 00 00 00       	jmp    800fe3 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800f06:	8b 45 14             	mov    0x14(%ebp),%eax
  800f09:	8b 00                	mov    (%eax),%eax
  800f0b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f0e:	99                   	cltd   
  800f0f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800f12:	8b 45 14             	mov    0x14(%ebp),%eax
  800f15:	8d 40 04             	lea    0x4(%eax),%eax
  800f18:	89 45 14             	mov    %eax,0x14(%ebp)
  800f1b:	eb b4                	jmp    800ed1 <vprintfmt+0x296>
	if (lflag >= 2)
  800f1d:	83 f9 01             	cmp    $0x1,%ecx
  800f20:	7f 1e                	jg     800f40 <vprintfmt+0x305>
	else if (lflag)
  800f22:	85 c9                	test   %ecx,%ecx
  800f24:	74 32                	je     800f58 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800f26:	8b 45 14             	mov    0x14(%ebp),%eax
  800f29:	8b 10                	mov    (%eax),%edx
  800f2b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f30:	8d 40 04             	lea    0x4(%eax),%eax
  800f33:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800f36:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800f3b:	e9 a3 00 00 00       	jmp    800fe3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800f40:	8b 45 14             	mov    0x14(%ebp),%eax
  800f43:	8b 10                	mov    (%eax),%edx
  800f45:	8b 48 04             	mov    0x4(%eax),%ecx
  800f48:	8d 40 08             	lea    0x8(%eax),%eax
  800f4b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800f4e:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800f53:	e9 8b 00 00 00       	jmp    800fe3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800f58:	8b 45 14             	mov    0x14(%ebp),%eax
  800f5b:	8b 10                	mov    (%eax),%edx
  800f5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f62:	8d 40 04             	lea    0x4(%eax),%eax
  800f65:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800f68:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800f6d:	eb 74                	jmp    800fe3 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800f6f:	83 f9 01             	cmp    $0x1,%ecx
  800f72:	7f 1b                	jg     800f8f <vprintfmt+0x354>
	else if (lflag)
  800f74:	85 c9                	test   %ecx,%ecx
  800f76:	74 2c                	je     800fa4 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800f78:	8b 45 14             	mov    0x14(%ebp),%eax
  800f7b:	8b 10                	mov    (%eax),%edx
  800f7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f82:	8d 40 04             	lea    0x4(%eax),%eax
  800f85:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800f88:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800f8d:	eb 54                	jmp    800fe3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800f8f:	8b 45 14             	mov    0x14(%ebp),%eax
  800f92:	8b 10                	mov    (%eax),%edx
  800f94:	8b 48 04             	mov    0x4(%eax),%ecx
  800f97:	8d 40 08             	lea    0x8(%eax),%eax
  800f9a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800f9d:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800fa2:	eb 3f                	jmp    800fe3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800fa4:	8b 45 14             	mov    0x14(%ebp),%eax
  800fa7:	8b 10                	mov    (%eax),%edx
  800fa9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fae:	8d 40 04             	lea    0x4(%eax),%eax
  800fb1:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800fb4:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800fb9:	eb 28                	jmp    800fe3 <vprintfmt+0x3a8>
			putch('0', putdat);
  800fbb:	83 ec 08             	sub    $0x8,%esp
  800fbe:	53                   	push   %ebx
  800fbf:	6a 30                	push   $0x30
  800fc1:	ff d6                	call   *%esi
			putch('x', putdat);
  800fc3:	83 c4 08             	add    $0x8,%esp
  800fc6:	53                   	push   %ebx
  800fc7:	6a 78                	push   $0x78
  800fc9:	ff d6                	call   *%esi
			num = (unsigned long long)
  800fcb:	8b 45 14             	mov    0x14(%ebp),%eax
  800fce:	8b 10                	mov    (%eax),%edx
  800fd0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800fd5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800fd8:	8d 40 04             	lea    0x4(%eax),%eax
  800fdb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800fde:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800fe3:	83 ec 0c             	sub    $0xc,%esp
  800fe6:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800fea:	50                   	push   %eax
  800feb:	ff 75 e0             	push   -0x20(%ebp)
  800fee:	57                   	push   %edi
  800fef:	51                   	push   %ecx
  800ff0:	52                   	push   %edx
  800ff1:	89 da                	mov    %ebx,%edx
  800ff3:	89 f0                	mov    %esi,%eax
  800ff5:	e8 5e fb ff ff       	call   800b58 <printnum>
			break;
  800ffa:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800ffd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801000:	e9 54 fc ff ff       	jmp    800c59 <vprintfmt+0x1e>
	if (lflag >= 2)
  801005:	83 f9 01             	cmp    $0x1,%ecx
  801008:	7f 1b                	jg     801025 <vprintfmt+0x3ea>
	else if (lflag)
  80100a:	85 c9                	test   %ecx,%ecx
  80100c:	74 2c                	je     80103a <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80100e:	8b 45 14             	mov    0x14(%ebp),%eax
  801011:	8b 10                	mov    (%eax),%edx
  801013:	b9 00 00 00 00       	mov    $0x0,%ecx
  801018:	8d 40 04             	lea    0x4(%eax),%eax
  80101b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80101e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801023:	eb be                	jmp    800fe3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801025:	8b 45 14             	mov    0x14(%ebp),%eax
  801028:	8b 10                	mov    (%eax),%edx
  80102a:	8b 48 04             	mov    0x4(%eax),%ecx
  80102d:	8d 40 08             	lea    0x8(%eax),%eax
  801030:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801033:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  801038:	eb a9                	jmp    800fe3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80103a:	8b 45 14             	mov    0x14(%ebp),%eax
  80103d:	8b 10                	mov    (%eax),%edx
  80103f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801044:	8d 40 04             	lea    0x4(%eax),%eax
  801047:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80104a:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80104f:	eb 92                	jmp    800fe3 <vprintfmt+0x3a8>
			putch(ch, putdat);
  801051:	83 ec 08             	sub    $0x8,%esp
  801054:	53                   	push   %ebx
  801055:	6a 25                	push   $0x25
  801057:	ff d6                	call   *%esi
			break;
  801059:	83 c4 10             	add    $0x10,%esp
  80105c:	eb 9f                	jmp    800ffd <vprintfmt+0x3c2>
			putch('%', putdat);
  80105e:	83 ec 08             	sub    $0x8,%esp
  801061:	53                   	push   %ebx
  801062:	6a 25                	push   $0x25
  801064:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801066:	83 c4 10             	add    $0x10,%esp
  801069:	89 f8                	mov    %edi,%eax
  80106b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80106f:	74 05                	je     801076 <vprintfmt+0x43b>
  801071:	83 e8 01             	sub    $0x1,%eax
  801074:	eb f5                	jmp    80106b <vprintfmt+0x430>
  801076:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801079:	eb 82                	jmp    800ffd <vprintfmt+0x3c2>

0080107b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	83 ec 18             	sub    $0x18,%esp
  801081:	8b 45 08             	mov    0x8(%ebp),%eax
  801084:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801087:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80108a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80108e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801091:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801098:	85 c0                	test   %eax,%eax
  80109a:	74 26                	je     8010c2 <vsnprintf+0x47>
  80109c:	85 d2                	test   %edx,%edx
  80109e:	7e 22                	jle    8010c2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8010a0:	ff 75 14             	push   0x14(%ebp)
  8010a3:	ff 75 10             	push   0x10(%ebp)
  8010a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8010a9:	50                   	push   %eax
  8010aa:	68 01 0c 80 00       	push   $0x800c01
  8010af:	e8 87 fb ff ff       	call   800c3b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8010b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8010b7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8010ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010bd:	83 c4 10             	add    $0x10,%esp
}
  8010c0:	c9                   	leave  
  8010c1:	c3                   	ret    
		return -E_INVAL;
  8010c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010c7:	eb f7                	jmp    8010c0 <vsnprintf+0x45>

008010c9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8010c9:	55                   	push   %ebp
  8010ca:	89 e5                	mov    %esp,%ebp
  8010cc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8010cf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8010d2:	50                   	push   %eax
  8010d3:	ff 75 10             	push   0x10(%ebp)
  8010d6:	ff 75 0c             	push   0xc(%ebp)
  8010d9:	ff 75 08             	push   0x8(%ebp)
  8010dc:	e8 9a ff ff ff       	call   80107b <vsnprintf>
	va_end(ap);

	return rc;
}
  8010e1:	c9                   	leave  
  8010e2:	c3                   	ret    

008010e3 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	57                   	push   %edi
  8010e7:	56                   	push   %esi
  8010e8:	53                   	push   %ebx
  8010e9:	83 ec 0c             	sub    $0xc,%esp
  8010ec:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	74 13                	je     801106 <readline+0x23>
		fprintf(1, "%s", prompt);
  8010f3:	83 ec 04             	sub    $0x4,%esp
  8010f6:	50                   	push   %eax
  8010f7:	68 d8 33 80 00       	push   $0x8033d8
  8010fc:	6a 01                	push   $0x1
  8010fe:	e8 8e 13 00 00       	call   802491 <fprintf>
  801103:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  801106:	83 ec 0c             	sub    $0xc,%esp
  801109:	6a 00                	push   $0x0
  80110b:	e8 7b f8 ff ff       	call   80098b <iscons>
  801110:	89 c7                	mov    %eax,%edi
  801112:	83 c4 10             	add    $0x10,%esp
	i = 0;
  801115:	be 00 00 00 00       	mov    $0x0,%esi
  80111a:	eb 4b                	jmp    801167 <readline+0x84>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  80111c:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
  801121:	83 fb f8             	cmp    $0xfffffff8,%ebx
  801124:	75 08                	jne    80112e <readline+0x4b>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  801126:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801129:	5b                   	pop    %ebx
  80112a:	5e                   	pop    %esi
  80112b:	5f                   	pop    %edi
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    
				cprintf("read error: %e\n", c);
  80112e:	83 ec 08             	sub    $0x8,%esp
  801131:	53                   	push   %ebx
  801132:	68 bf 37 80 00       	push   $0x8037bf
  801137:	e8 08 fa ff ff       	call   800b44 <cprintf>
  80113c:	83 c4 10             	add    $0x10,%esp
			return NULL;
  80113f:	b8 00 00 00 00       	mov    $0x0,%eax
  801144:	eb e0                	jmp    801126 <readline+0x43>
			if (echoing)
  801146:	85 ff                	test   %edi,%edi
  801148:	75 05                	jne    80114f <readline+0x6c>
			i--;
  80114a:	83 ee 01             	sub    $0x1,%esi
  80114d:	eb 18                	jmp    801167 <readline+0x84>
				cputchar('\b');
  80114f:	83 ec 0c             	sub    $0xc,%esp
  801152:	6a 08                	push   $0x8
  801154:	e8 ed f7 ff ff       	call   800946 <cputchar>
  801159:	83 c4 10             	add    $0x10,%esp
  80115c:	eb ec                	jmp    80114a <readline+0x67>
			buf[i++] = c;
  80115e:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  801164:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
  801167:	e8 f6 f7 ff ff       	call   800962 <getchar>
  80116c:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  80116e:	85 c0                	test   %eax,%eax
  801170:	78 aa                	js     80111c <readline+0x39>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  801172:	83 f8 08             	cmp    $0x8,%eax
  801175:	0f 94 c0             	sete   %al
  801178:	83 fb 7f             	cmp    $0x7f,%ebx
  80117b:	0f 94 c2             	sete   %dl
  80117e:	08 d0                	or     %dl,%al
  801180:	74 04                	je     801186 <readline+0xa3>
  801182:	85 f6                	test   %esi,%esi
  801184:	7f c0                	jg     801146 <readline+0x63>
		} else if (c >= ' ' && i < BUFLEN-1) {
  801186:	83 fb 1f             	cmp    $0x1f,%ebx
  801189:	7e 1a                	jle    8011a5 <readline+0xc2>
  80118b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  801191:	7f 12                	jg     8011a5 <readline+0xc2>
			if (echoing)
  801193:	85 ff                	test   %edi,%edi
  801195:	74 c7                	je     80115e <readline+0x7b>
				cputchar(c);
  801197:	83 ec 0c             	sub    $0xc,%esp
  80119a:	53                   	push   %ebx
  80119b:	e8 a6 f7 ff ff       	call   800946 <cputchar>
  8011a0:	83 c4 10             	add    $0x10,%esp
  8011a3:	eb b9                	jmp    80115e <readline+0x7b>
		} else if (c == '\n' || c == '\r') {
  8011a5:	83 fb 0a             	cmp    $0xa,%ebx
  8011a8:	74 05                	je     8011af <readline+0xcc>
  8011aa:	83 fb 0d             	cmp    $0xd,%ebx
  8011ad:	75 b8                	jne    801167 <readline+0x84>
			if (echoing)
  8011af:	85 ff                	test   %edi,%edi
  8011b1:	75 11                	jne    8011c4 <readline+0xe1>
			buf[i] = 0;
  8011b3:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  8011ba:	b8 20 50 80 00       	mov    $0x805020,%eax
  8011bf:	e9 62 ff ff ff       	jmp    801126 <readline+0x43>
				cputchar('\n');
  8011c4:	83 ec 0c             	sub    $0xc,%esp
  8011c7:	6a 0a                	push   $0xa
  8011c9:	e8 78 f7 ff ff       	call   800946 <cputchar>
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	eb e0                	jmp    8011b3 <readline+0xd0>

008011d3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8011d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011de:	eb 03                	jmp    8011e3 <strlen+0x10>
		n++;
  8011e0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8011e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8011e7:	75 f7                	jne    8011e0 <strlen+0xd>
	return n;
}
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    

008011eb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f9:	eb 03                	jmp    8011fe <strnlen+0x13>
		n++;
  8011fb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011fe:	39 d0                	cmp    %edx,%eax
  801200:	74 08                	je     80120a <strnlen+0x1f>
  801202:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801206:	75 f3                	jne    8011fb <strnlen+0x10>
  801208:	89 c2                	mov    %eax,%edx
	return n;
}
  80120a:	89 d0                	mov    %edx,%eax
  80120c:	5d                   	pop    %ebp
  80120d:	c3                   	ret    

0080120e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	53                   	push   %ebx
  801212:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801215:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801218:	b8 00 00 00 00       	mov    $0x0,%eax
  80121d:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801221:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801224:	83 c0 01             	add    $0x1,%eax
  801227:	84 d2                	test   %dl,%dl
  801229:	75 f2                	jne    80121d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80122b:	89 c8                	mov    %ecx,%eax
  80122d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801230:	c9                   	leave  
  801231:	c3                   	ret    

00801232 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	53                   	push   %ebx
  801236:	83 ec 10             	sub    $0x10,%esp
  801239:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80123c:	53                   	push   %ebx
  80123d:	e8 91 ff ff ff       	call   8011d3 <strlen>
  801242:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801245:	ff 75 0c             	push   0xc(%ebp)
  801248:	01 d8                	add    %ebx,%eax
  80124a:	50                   	push   %eax
  80124b:	e8 be ff ff ff       	call   80120e <strcpy>
	return dst;
}
  801250:	89 d8                	mov    %ebx,%eax
  801252:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801255:	c9                   	leave  
  801256:	c3                   	ret    

00801257 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	56                   	push   %esi
  80125b:	53                   	push   %ebx
  80125c:	8b 75 08             	mov    0x8(%ebp),%esi
  80125f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801262:	89 f3                	mov    %esi,%ebx
  801264:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801267:	89 f0                	mov    %esi,%eax
  801269:	eb 0f                	jmp    80127a <strncpy+0x23>
		*dst++ = *src;
  80126b:	83 c0 01             	add    $0x1,%eax
  80126e:	0f b6 0a             	movzbl (%edx),%ecx
  801271:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801274:	80 f9 01             	cmp    $0x1,%cl
  801277:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80127a:	39 d8                	cmp    %ebx,%eax
  80127c:	75 ed                	jne    80126b <strncpy+0x14>
	}
	return ret;
}
  80127e:	89 f0                	mov    %esi,%eax
  801280:	5b                   	pop    %ebx
  801281:	5e                   	pop    %esi
  801282:	5d                   	pop    %ebp
  801283:	c3                   	ret    

00801284 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	56                   	push   %esi
  801288:	53                   	push   %ebx
  801289:	8b 75 08             	mov    0x8(%ebp),%esi
  80128c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128f:	8b 55 10             	mov    0x10(%ebp),%edx
  801292:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801294:	85 d2                	test   %edx,%edx
  801296:	74 21                	je     8012b9 <strlcpy+0x35>
  801298:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80129c:	89 f2                	mov    %esi,%edx
  80129e:	eb 09                	jmp    8012a9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8012a0:	83 c1 01             	add    $0x1,%ecx
  8012a3:	83 c2 01             	add    $0x1,%edx
  8012a6:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8012a9:	39 c2                	cmp    %eax,%edx
  8012ab:	74 09                	je     8012b6 <strlcpy+0x32>
  8012ad:	0f b6 19             	movzbl (%ecx),%ebx
  8012b0:	84 db                	test   %bl,%bl
  8012b2:	75 ec                	jne    8012a0 <strlcpy+0x1c>
  8012b4:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8012b6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8012b9:	29 f0                	sub    %esi,%eax
}
  8012bb:	5b                   	pop    %ebx
  8012bc:	5e                   	pop    %esi
  8012bd:	5d                   	pop    %ebp
  8012be:	c3                   	ret    

008012bf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8012c8:	eb 06                	jmp    8012d0 <strcmp+0x11>
		p++, q++;
  8012ca:	83 c1 01             	add    $0x1,%ecx
  8012cd:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8012d0:	0f b6 01             	movzbl (%ecx),%eax
  8012d3:	84 c0                	test   %al,%al
  8012d5:	74 04                	je     8012db <strcmp+0x1c>
  8012d7:	3a 02                	cmp    (%edx),%al
  8012d9:	74 ef                	je     8012ca <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8012db:	0f b6 c0             	movzbl %al,%eax
  8012de:	0f b6 12             	movzbl (%edx),%edx
  8012e1:	29 d0                	sub    %edx,%eax
}
  8012e3:	5d                   	pop    %ebp
  8012e4:	c3                   	ret    

008012e5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
  8012e8:	53                   	push   %ebx
  8012e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ef:	89 c3                	mov    %eax,%ebx
  8012f1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8012f4:	eb 06                	jmp    8012fc <strncmp+0x17>
		n--, p++, q++;
  8012f6:	83 c0 01             	add    $0x1,%eax
  8012f9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8012fc:	39 d8                	cmp    %ebx,%eax
  8012fe:	74 18                	je     801318 <strncmp+0x33>
  801300:	0f b6 08             	movzbl (%eax),%ecx
  801303:	84 c9                	test   %cl,%cl
  801305:	74 04                	je     80130b <strncmp+0x26>
  801307:	3a 0a                	cmp    (%edx),%cl
  801309:	74 eb                	je     8012f6 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80130b:	0f b6 00             	movzbl (%eax),%eax
  80130e:	0f b6 12             	movzbl (%edx),%edx
  801311:	29 d0                	sub    %edx,%eax
}
  801313:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801316:	c9                   	leave  
  801317:	c3                   	ret    
		return 0;
  801318:	b8 00 00 00 00       	mov    $0x0,%eax
  80131d:	eb f4                	jmp    801313 <strncmp+0x2e>

0080131f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	8b 45 08             	mov    0x8(%ebp),%eax
  801325:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801329:	eb 03                	jmp    80132e <strchr+0xf>
  80132b:	83 c0 01             	add    $0x1,%eax
  80132e:	0f b6 10             	movzbl (%eax),%edx
  801331:	84 d2                	test   %dl,%dl
  801333:	74 06                	je     80133b <strchr+0x1c>
		if (*s == c)
  801335:	38 ca                	cmp    %cl,%dl
  801337:	75 f2                	jne    80132b <strchr+0xc>
  801339:	eb 05                	jmp    801340 <strchr+0x21>
			return (char *) s;
	return 0;
  80133b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801340:	5d                   	pop    %ebp
  801341:	c3                   	ret    

00801342 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	8b 45 08             	mov    0x8(%ebp),%eax
  801348:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80134c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80134f:	38 ca                	cmp    %cl,%dl
  801351:	74 09                	je     80135c <strfind+0x1a>
  801353:	84 d2                	test   %dl,%dl
  801355:	74 05                	je     80135c <strfind+0x1a>
	for (; *s; s++)
  801357:	83 c0 01             	add    $0x1,%eax
  80135a:	eb f0                	jmp    80134c <strfind+0xa>
			break;
	return (char *) s;
}
  80135c:	5d                   	pop    %ebp
  80135d:	c3                   	ret    

0080135e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	57                   	push   %edi
  801362:	56                   	push   %esi
  801363:	53                   	push   %ebx
  801364:	8b 7d 08             	mov    0x8(%ebp),%edi
  801367:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80136a:	85 c9                	test   %ecx,%ecx
  80136c:	74 2f                	je     80139d <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80136e:	89 f8                	mov    %edi,%eax
  801370:	09 c8                	or     %ecx,%eax
  801372:	a8 03                	test   $0x3,%al
  801374:	75 21                	jne    801397 <memset+0x39>
		c &= 0xFF;
  801376:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80137a:	89 d0                	mov    %edx,%eax
  80137c:	c1 e0 08             	shl    $0x8,%eax
  80137f:	89 d3                	mov    %edx,%ebx
  801381:	c1 e3 18             	shl    $0x18,%ebx
  801384:	89 d6                	mov    %edx,%esi
  801386:	c1 e6 10             	shl    $0x10,%esi
  801389:	09 f3                	or     %esi,%ebx
  80138b:	09 da                	or     %ebx,%edx
  80138d:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80138f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801392:	fc                   	cld    
  801393:	f3 ab                	rep stos %eax,%es:(%edi)
  801395:	eb 06                	jmp    80139d <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801397:	8b 45 0c             	mov    0xc(%ebp),%eax
  80139a:	fc                   	cld    
  80139b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80139d:	89 f8                	mov    %edi,%eax
  80139f:	5b                   	pop    %ebx
  8013a0:	5e                   	pop    %esi
  8013a1:	5f                   	pop    %edi
  8013a2:	5d                   	pop    %ebp
  8013a3:	c3                   	ret    

008013a4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	57                   	push   %edi
  8013a8:	56                   	push   %esi
  8013a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ac:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8013b2:	39 c6                	cmp    %eax,%esi
  8013b4:	73 32                	jae    8013e8 <memmove+0x44>
  8013b6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8013b9:	39 c2                	cmp    %eax,%edx
  8013bb:	76 2b                	jbe    8013e8 <memmove+0x44>
		s += n;
		d += n;
  8013bd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013c0:	89 d6                	mov    %edx,%esi
  8013c2:	09 fe                	or     %edi,%esi
  8013c4:	09 ce                	or     %ecx,%esi
  8013c6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8013cc:	75 0e                	jne    8013dc <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8013ce:	83 ef 04             	sub    $0x4,%edi
  8013d1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8013d4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8013d7:	fd                   	std    
  8013d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013da:	eb 09                	jmp    8013e5 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8013dc:	83 ef 01             	sub    $0x1,%edi
  8013df:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8013e2:	fd                   	std    
  8013e3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8013e5:	fc                   	cld    
  8013e6:	eb 1a                	jmp    801402 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013e8:	89 f2                	mov    %esi,%edx
  8013ea:	09 c2                	or     %eax,%edx
  8013ec:	09 ca                	or     %ecx,%edx
  8013ee:	f6 c2 03             	test   $0x3,%dl
  8013f1:	75 0a                	jne    8013fd <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8013f3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8013f6:	89 c7                	mov    %eax,%edi
  8013f8:	fc                   	cld    
  8013f9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013fb:	eb 05                	jmp    801402 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8013fd:	89 c7                	mov    %eax,%edi
  8013ff:	fc                   	cld    
  801400:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801402:	5e                   	pop    %esi
  801403:	5f                   	pop    %edi
  801404:	5d                   	pop    %ebp
  801405:	c3                   	ret    

00801406 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80140c:	ff 75 10             	push   0x10(%ebp)
  80140f:	ff 75 0c             	push   0xc(%ebp)
  801412:	ff 75 08             	push   0x8(%ebp)
  801415:	e8 8a ff ff ff       	call   8013a4 <memmove>
}
  80141a:	c9                   	leave  
  80141b:	c3                   	ret    

0080141c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	56                   	push   %esi
  801420:	53                   	push   %ebx
  801421:	8b 45 08             	mov    0x8(%ebp),%eax
  801424:	8b 55 0c             	mov    0xc(%ebp),%edx
  801427:	89 c6                	mov    %eax,%esi
  801429:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80142c:	eb 06                	jmp    801434 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80142e:	83 c0 01             	add    $0x1,%eax
  801431:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801434:	39 f0                	cmp    %esi,%eax
  801436:	74 14                	je     80144c <memcmp+0x30>
		if (*s1 != *s2)
  801438:	0f b6 08             	movzbl (%eax),%ecx
  80143b:	0f b6 1a             	movzbl (%edx),%ebx
  80143e:	38 d9                	cmp    %bl,%cl
  801440:	74 ec                	je     80142e <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801442:	0f b6 c1             	movzbl %cl,%eax
  801445:	0f b6 db             	movzbl %bl,%ebx
  801448:	29 d8                	sub    %ebx,%eax
  80144a:	eb 05                	jmp    801451 <memcmp+0x35>
	}

	return 0;
  80144c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801451:	5b                   	pop    %ebx
  801452:	5e                   	pop    %esi
  801453:	5d                   	pop    %ebp
  801454:	c3                   	ret    

00801455 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	8b 45 08             	mov    0x8(%ebp),%eax
  80145b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80145e:	89 c2                	mov    %eax,%edx
  801460:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801463:	eb 03                	jmp    801468 <memfind+0x13>
  801465:	83 c0 01             	add    $0x1,%eax
  801468:	39 d0                	cmp    %edx,%eax
  80146a:	73 04                	jae    801470 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80146c:	38 08                	cmp    %cl,(%eax)
  80146e:	75 f5                	jne    801465 <memfind+0x10>
			break;
	return (void *) s;
}
  801470:	5d                   	pop    %ebp
  801471:	c3                   	ret    

00801472 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	57                   	push   %edi
  801476:	56                   	push   %esi
  801477:	53                   	push   %ebx
  801478:	8b 55 08             	mov    0x8(%ebp),%edx
  80147b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80147e:	eb 03                	jmp    801483 <strtol+0x11>
		s++;
  801480:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801483:	0f b6 02             	movzbl (%edx),%eax
  801486:	3c 20                	cmp    $0x20,%al
  801488:	74 f6                	je     801480 <strtol+0xe>
  80148a:	3c 09                	cmp    $0x9,%al
  80148c:	74 f2                	je     801480 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  80148e:	3c 2b                	cmp    $0x2b,%al
  801490:	74 2a                	je     8014bc <strtol+0x4a>
	int neg = 0;
  801492:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801497:	3c 2d                	cmp    $0x2d,%al
  801499:	74 2b                	je     8014c6 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80149b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8014a1:	75 0f                	jne    8014b2 <strtol+0x40>
  8014a3:	80 3a 30             	cmpb   $0x30,(%edx)
  8014a6:	74 28                	je     8014d0 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8014a8:	85 db                	test   %ebx,%ebx
  8014aa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014af:	0f 44 d8             	cmove  %eax,%ebx
  8014b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014b7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8014ba:	eb 46                	jmp    801502 <strtol+0x90>
		s++;
  8014bc:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8014bf:	bf 00 00 00 00       	mov    $0x0,%edi
  8014c4:	eb d5                	jmp    80149b <strtol+0x29>
		s++, neg = 1;
  8014c6:	83 c2 01             	add    $0x1,%edx
  8014c9:	bf 01 00 00 00       	mov    $0x1,%edi
  8014ce:	eb cb                	jmp    80149b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8014d0:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8014d4:	74 0e                	je     8014e4 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8014d6:	85 db                	test   %ebx,%ebx
  8014d8:	75 d8                	jne    8014b2 <strtol+0x40>
		s++, base = 8;
  8014da:	83 c2 01             	add    $0x1,%edx
  8014dd:	bb 08 00 00 00       	mov    $0x8,%ebx
  8014e2:	eb ce                	jmp    8014b2 <strtol+0x40>
		s += 2, base = 16;
  8014e4:	83 c2 02             	add    $0x2,%edx
  8014e7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8014ec:	eb c4                	jmp    8014b2 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8014ee:	0f be c0             	movsbl %al,%eax
  8014f1:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8014f4:	3b 45 10             	cmp    0x10(%ebp),%eax
  8014f7:	7d 3a                	jge    801533 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  8014f9:	83 c2 01             	add    $0x1,%edx
  8014fc:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801500:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801502:	0f b6 02             	movzbl (%edx),%eax
  801505:	8d 70 d0             	lea    -0x30(%eax),%esi
  801508:	89 f3                	mov    %esi,%ebx
  80150a:	80 fb 09             	cmp    $0x9,%bl
  80150d:	76 df                	jbe    8014ee <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  80150f:	8d 70 9f             	lea    -0x61(%eax),%esi
  801512:	89 f3                	mov    %esi,%ebx
  801514:	80 fb 19             	cmp    $0x19,%bl
  801517:	77 08                	ja     801521 <strtol+0xaf>
			dig = *s - 'a' + 10;
  801519:	0f be c0             	movsbl %al,%eax
  80151c:	83 e8 57             	sub    $0x57,%eax
  80151f:	eb d3                	jmp    8014f4 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801521:	8d 70 bf             	lea    -0x41(%eax),%esi
  801524:	89 f3                	mov    %esi,%ebx
  801526:	80 fb 19             	cmp    $0x19,%bl
  801529:	77 08                	ja     801533 <strtol+0xc1>
			dig = *s - 'A' + 10;
  80152b:	0f be c0             	movsbl %al,%eax
  80152e:	83 e8 37             	sub    $0x37,%eax
  801531:	eb c1                	jmp    8014f4 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801533:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801537:	74 05                	je     80153e <strtol+0xcc>
		*endptr = (char *) s;
  801539:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153c:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  80153e:	89 c8                	mov    %ecx,%eax
  801540:	f7 d8                	neg    %eax
  801542:	85 ff                	test   %edi,%edi
  801544:	0f 45 c8             	cmovne %eax,%ecx
}
  801547:	89 c8                	mov    %ecx,%eax
  801549:	5b                   	pop    %ebx
  80154a:	5e                   	pop    %esi
  80154b:	5f                   	pop    %edi
  80154c:	5d                   	pop    %ebp
  80154d:	c3                   	ret    

0080154e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
  801551:	57                   	push   %edi
  801552:	56                   	push   %esi
  801553:	53                   	push   %ebx
	asm volatile("int %1\n"
  801554:	b8 00 00 00 00       	mov    $0x0,%eax
  801559:	8b 55 08             	mov    0x8(%ebp),%edx
  80155c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80155f:	89 c3                	mov    %eax,%ebx
  801561:	89 c7                	mov    %eax,%edi
  801563:	89 c6                	mov    %eax,%esi
  801565:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801567:	5b                   	pop    %ebx
  801568:	5e                   	pop    %esi
  801569:	5f                   	pop    %edi
  80156a:	5d                   	pop    %ebp
  80156b:	c3                   	ret    

0080156c <sys_cgetc>:

int
sys_cgetc(void)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	57                   	push   %edi
  801570:	56                   	push   %esi
  801571:	53                   	push   %ebx
	asm volatile("int %1\n"
  801572:	ba 00 00 00 00       	mov    $0x0,%edx
  801577:	b8 01 00 00 00       	mov    $0x1,%eax
  80157c:	89 d1                	mov    %edx,%ecx
  80157e:	89 d3                	mov    %edx,%ebx
  801580:	89 d7                	mov    %edx,%edi
  801582:	89 d6                	mov    %edx,%esi
  801584:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801586:	5b                   	pop    %ebx
  801587:	5e                   	pop    %esi
  801588:	5f                   	pop    %edi
  801589:	5d                   	pop    %ebp
  80158a:	c3                   	ret    

0080158b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	57                   	push   %edi
  80158f:	56                   	push   %esi
  801590:	53                   	push   %ebx
  801591:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801594:	b9 00 00 00 00       	mov    $0x0,%ecx
  801599:	8b 55 08             	mov    0x8(%ebp),%edx
  80159c:	b8 03 00 00 00       	mov    $0x3,%eax
  8015a1:	89 cb                	mov    %ecx,%ebx
  8015a3:	89 cf                	mov    %ecx,%edi
  8015a5:	89 ce                	mov    %ecx,%esi
  8015a7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	7f 08                	jg     8015b5 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8015ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b0:	5b                   	pop    %ebx
  8015b1:	5e                   	pop    %esi
  8015b2:	5f                   	pop    %edi
  8015b3:	5d                   	pop    %ebp
  8015b4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8015b5:	83 ec 0c             	sub    $0xc,%esp
  8015b8:	50                   	push   %eax
  8015b9:	6a 03                	push   $0x3
  8015bb:	68 cf 37 80 00       	push   $0x8037cf
  8015c0:	6a 2a                	push   $0x2a
  8015c2:	68 ec 37 80 00       	push   $0x8037ec
  8015c7:	e8 9d f4 ff ff       	call   800a69 <_panic>

008015cc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	57                   	push   %edi
  8015d0:	56                   	push   %esi
  8015d1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8015d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d7:	b8 02 00 00 00       	mov    $0x2,%eax
  8015dc:	89 d1                	mov    %edx,%ecx
  8015de:	89 d3                	mov    %edx,%ebx
  8015e0:	89 d7                	mov    %edx,%edi
  8015e2:	89 d6                	mov    %edx,%esi
  8015e4:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8015e6:	5b                   	pop    %ebx
  8015e7:	5e                   	pop    %esi
  8015e8:	5f                   	pop    %edi
  8015e9:	5d                   	pop    %ebp
  8015ea:	c3                   	ret    

008015eb <sys_yield>:

void
sys_yield(void)
{
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	57                   	push   %edi
  8015ef:	56                   	push   %esi
  8015f0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8015f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8015fb:	89 d1                	mov    %edx,%ecx
  8015fd:	89 d3                	mov    %edx,%ebx
  8015ff:	89 d7                	mov    %edx,%edi
  801601:	89 d6                	mov    %edx,%esi
  801603:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801605:	5b                   	pop    %ebx
  801606:	5e                   	pop    %esi
  801607:	5f                   	pop    %edi
  801608:	5d                   	pop    %ebp
  801609:	c3                   	ret    

0080160a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	57                   	push   %edi
  80160e:	56                   	push   %esi
  80160f:	53                   	push   %ebx
  801610:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801613:	be 00 00 00 00       	mov    $0x0,%esi
  801618:	8b 55 08             	mov    0x8(%ebp),%edx
  80161b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80161e:	b8 04 00 00 00       	mov    $0x4,%eax
  801623:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801626:	89 f7                	mov    %esi,%edi
  801628:	cd 30                	int    $0x30
	if(check && ret > 0)
  80162a:	85 c0                	test   %eax,%eax
  80162c:	7f 08                	jg     801636 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80162e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801631:	5b                   	pop    %ebx
  801632:	5e                   	pop    %esi
  801633:	5f                   	pop    %edi
  801634:	5d                   	pop    %ebp
  801635:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801636:	83 ec 0c             	sub    $0xc,%esp
  801639:	50                   	push   %eax
  80163a:	6a 04                	push   $0x4
  80163c:	68 cf 37 80 00       	push   $0x8037cf
  801641:	6a 2a                	push   $0x2a
  801643:	68 ec 37 80 00       	push   $0x8037ec
  801648:	e8 1c f4 ff ff       	call   800a69 <_panic>

0080164d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	57                   	push   %edi
  801651:	56                   	push   %esi
  801652:	53                   	push   %ebx
  801653:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801656:	8b 55 08             	mov    0x8(%ebp),%edx
  801659:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80165c:	b8 05 00 00 00       	mov    $0x5,%eax
  801661:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801664:	8b 7d 14             	mov    0x14(%ebp),%edi
  801667:	8b 75 18             	mov    0x18(%ebp),%esi
  80166a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80166c:	85 c0                	test   %eax,%eax
  80166e:	7f 08                	jg     801678 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801670:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801673:	5b                   	pop    %ebx
  801674:	5e                   	pop    %esi
  801675:	5f                   	pop    %edi
  801676:	5d                   	pop    %ebp
  801677:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801678:	83 ec 0c             	sub    $0xc,%esp
  80167b:	50                   	push   %eax
  80167c:	6a 05                	push   $0x5
  80167e:	68 cf 37 80 00       	push   $0x8037cf
  801683:	6a 2a                	push   $0x2a
  801685:	68 ec 37 80 00       	push   $0x8037ec
  80168a:	e8 da f3 ff ff       	call   800a69 <_panic>

0080168f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	57                   	push   %edi
  801693:	56                   	push   %esi
  801694:	53                   	push   %ebx
  801695:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801698:	bb 00 00 00 00       	mov    $0x0,%ebx
  80169d:	8b 55 08             	mov    0x8(%ebp),%edx
  8016a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016a3:	b8 06 00 00 00       	mov    $0x6,%eax
  8016a8:	89 df                	mov    %ebx,%edi
  8016aa:	89 de                	mov    %ebx,%esi
  8016ac:	cd 30                	int    $0x30
	if(check && ret > 0)
  8016ae:	85 c0                	test   %eax,%eax
  8016b0:	7f 08                	jg     8016ba <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8016b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b5:	5b                   	pop    %ebx
  8016b6:	5e                   	pop    %esi
  8016b7:	5f                   	pop    %edi
  8016b8:	5d                   	pop    %ebp
  8016b9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8016ba:	83 ec 0c             	sub    $0xc,%esp
  8016bd:	50                   	push   %eax
  8016be:	6a 06                	push   $0x6
  8016c0:	68 cf 37 80 00       	push   $0x8037cf
  8016c5:	6a 2a                	push   $0x2a
  8016c7:	68 ec 37 80 00       	push   $0x8037ec
  8016cc:	e8 98 f3 ff ff       	call   800a69 <_panic>

008016d1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	57                   	push   %edi
  8016d5:	56                   	push   %esi
  8016d6:	53                   	push   %ebx
  8016d7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8016da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016df:	8b 55 08             	mov    0x8(%ebp),%edx
  8016e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e5:	b8 08 00 00 00       	mov    $0x8,%eax
  8016ea:	89 df                	mov    %ebx,%edi
  8016ec:	89 de                	mov    %ebx,%esi
  8016ee:	cd 30                	int    $0x30
	if(check && ret > 0)
  8016f0:	85 c0                	test   %eax,%eax
  8016f2:	7f 08                	jg     8016fc <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8016f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f7:	5b                   	pop    %ebx
  8016f8:	5e                   	pop    %esi
  8016f9:	5f                   	pop    %edi
  8016fa:	5d                   	pop    %ebp
  8016fb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8016fc:	83 ec 0c             	sub    $0xc,%esp
  8016ff:	50                   	push   %eax
  801700:	6a 08                	push   $0x8
  801702:	68 cf 37 80 00       	push   $0x8037cf
  801707:	6a 2a                	push   $0x2a
  801709:	68 ec 37 80 00       	push   $0x8037ec
  80170e:	e8 56 f3 ff ff       	call   800a69 <_panic>

00801713 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	57                   	push   %edi
  801717:	56                   	push   %esi
  801718:	53                   	push   %ebx
  801719:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80171c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801721:	8b 55 08             	mov    0x8(%ebp),%edx
  801724:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801727:	b8 09 00 00 00       	mov    $0x9,%eax
  80172c:	89 df                	mov    %ebx,%edi
  80172e:	89 de                	mov    %ebx,%esi
  801730:	cd 30                	int    $0x30
	if(check && ret > 0)
  801732:	85 c0                	test   %eax,%eax
  801734:	7f 08                	jg     80173e <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801736:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801739:	5b                   	pop    %ebx
  80173a:	5e                   	pop    %esi
  80173b:	5f                   	pop    %edi
  80173c:	5d                   	pop    %ebp
  80173d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80173e:	83 ec 0c             	sub    $0xc,%esp
  801741:	50                   	push   %eax
  801742:	6a 09                	push   $0x9
  801744:	68 cf 37 80 00       	push   $0x8037cf
  801749:	6a 2a                	push   $0x2a
  80174b:	68 ec 37 80 00       	push   $0x8037ec
  801750:	e8 14 f3 ff ff       	call   800a69 <_panic>

00801755 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	57                   	push   %edi
  801759:	56                   	push   %esi
  80175a:	53                   	push   %ebx
  80175b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80175e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801763:	8b 55 08             	mov    0x8(%ebp),%edx
  801766:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801769:	b8 0a 00 00 00       	mov    $0xa,%eax
  80176e:	89 df                	mov    %ebx,%edi
  801770:	89 de                	mov    %ebx,%esi
  801772:	cd 30                	int    $0x30
	if(check && ret > 0)
  801774:	85 c0                	test   %eax,%eax
  801776:	7f 08                	jg     801780 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801778:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80177b:	5b                   	pop    %ebx
  80177c:	5e                   	pop    %esi
  80177d:	5f                   	pop    %edi
  80177e:	5d                   	pop    %ebp
  80177f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801780:	83 ec 0c             	sub    $0xc,%esp
  801783:	50                   	push   %eax
  801784:	6a 0a                	push   $0xa
  801786:	68 cf 37 80 00       	push   $0x8037cf
  80178b:	6a 2a                	push   $0x2a
  80178d:	68 ec 37 80 00       	push   $0x8037ec
  801792:	e8 d2 f2 ff ff       	call   800a69 <_panic>

00801797 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	57                   	push   %edi
  80179b:	56                   	push   %esi
  80179c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80179d:	8b 55 08             	mov    0x8(%ebp),%edx
  8017a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017a3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8017a8:	be 00 00 00 00       	mov    $0x0,%esi
  8017ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8017b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8017b3:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8017b5:	5b                   	pop    %ebx
  8017b6:	5e                   	pop    %esi
  8017b7:	5f                   	pop    %edi
  8017b8:	5d                   	pop    %ebp
  8017b9:	c3                   	ret    

008017ba <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	57                   	push   %edi
  8017be:	56                   	push   %esi
  8017bf:	53                   	push   %ebx
  8017c0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8017c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8017cb:	b8 0d 00 00 00       	mov    $0xd,%eax
  8017d0:	89 cb                	mov    %ecx,%ebx
  8017d2:	89 cf                	mov    %ecx,%edi
  8017d4:	89 ce                	mov    %ecx,%esi
  8017d6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8017d8:	85 c0                	test   %eax,%eax
  8017da:	7f 08                	jg     8017e4 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8017dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017df:	5b                   	pop    %ebx
  8017e0:	5e                   	pop    %esi
  8017e1:	5f                   	pop    %edi
  8017e2:	5d                   	pop    %ebp
  8017e3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8017e4:	83 ec 0c             	sub    $0xc,%esp
  8017e7:	50                   	push   %eax
  8017e8:	6a 0d                	push   $0xd
  8017ea:	68 cf 37 80 00       	push   $0x8037cf
  8017ef:	6a 2a                	push   $0x2a
  8017f1:	68 ec 37 80 00       	push   $0x8037ec
  8017f6:	e8 6e f2 ff ff       	call   800a69 <_panic>

008017fb <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	56                   	push   %esi
  8017ff:	53                   	push   %ebx
  801800:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801803:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  801805:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801809:	0f 84 8e 00 00 00    	je     80189d <pgfault+0xa2>
  80180f:	89 f0                	mov    %esi,%eax
  801811:	c1 e8 0c             	shr    $0xc,%eax
  801814:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80181b:	f6 c4 08             	test   $0x8,%ah
  80181e:	74 7d                	je     80189d <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  801820:	e8 a7 fd ff ff       	call   8015cc <sys_getenvid>
  801825:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  801827:	83 ec 04             	sub    $0x4,%esp
  80182a:	6a 07                	push   $0x7
  80182c:	68 00 f0 7f 00       	push   $0x7ff000
  801831:	50                   	push   %eax
  801832:	e8 d3 fd ff ff       	call   80160a <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	85 c0                	test   %eax,%eax
  80183c:	78 73                	js     8018b1 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  80183e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  801844:	83 ec 04             	sub    $0x4,%esp
  801847:	68 00 10 00 00       	push   $0x1000
  80184c:	56                   	push   %esi
  80184d:	68 00 f0 7f 00       	push   $0x7ff000
  801852:	e8 4d fb ff ff       	call   8013a4 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  801857:	83 c4 08             	add    $0x8,%esp
  80185a:	56                   	push   %esi
  80185b:	53                   	push   %ebx
  80185c:	e8 2e fe ff ff       	call   80168f <sys_page_unmap>
  801861:	83 c4 10             	add    $0x10,%esp
  801864:	85 c0                	test   %eax,%eax
  801866:	78 5b                	js     8018c3 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  801868:	83 ec 0c             	sub    $0xc,%esp
  80186b:	6a 07                	push   $0x7
  80186d:	56                   	push   %esi
  80186e:	53                   	push   %ebx
  80186f:	68 00 f0 7f 00       	push   $0x7ff000
  801874:	53                   	push   %ebx
  801875:	e8 d3 fd ff ff       	call   80164d <sys_page_map>
  80187a:	83 c4 20             	add    $0x20,%esp
  80187d:	85 c0                	test   %eax,%eax
  80187f:	78 54                	js     8018d5 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  801881:	83 ec 08             	sub    $0x8,%esp
  801884:	68 00 f0 7f 00       	push   $0x7ff000
  801889:	53                   	push   %ebx
  80188a:	e8 00 fe ff ff       	call   80168f <sys_page_unmap>
  80188f:	83 c4 10             	add    $0x10,%esp
  801892:	85 c0                	test   %eax,%eax
  801894:	78 51                	js     8018e7 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  801896:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801899:	5b                   	pop    %ebx
  80189a:	5e                   	pop    %esi
  80189b:	5d                   	pop    %ebp
  80189c:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  80189d:	83 ec 04             	sub    $0x4,%esp
  8018a0:	68 fc 37 80 00       	push   $0x8037fc
  8018a5:	6a 1d                	push   $0x1d
  8018a7:	68 78 38 80 00       	push   $0x803878
  8018ac:	e8 b8 f1 ff ff       	call   800a69 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  8018b1:	50                   	push   %eax
  8018b2:	68 34 38 80 00       	push   $0x803834
  8018b7:	6a 29                	push   $0x29
  8018b9:	68 78 38 80 00       	push   $0x803878
  8018be:	e8 a6 f1 ff ff       	call   800a69 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  8018c3:	50                   	push   %eax
  8018c4:	68 58 38 80 00       	push   $0x803858
  8018c9:	6a 2e                	push   $0x2e
  8018cb:	68 78 38 80 00       	push   $0x803878
  8018d0:	e8 94 f1 ff ff       	call   800a69 <_panic>
		panic("pgfault: page map failed (%e)", r);
  8018d5:	50                   	push   %eax
  8018d6:	68 83 38 80 00       	push   $0x803883
  8018db:	6a 30                	push   $0x30
  8018dd:	68 78 38 80 00       	push   $0x803878
  8018e2:	e8 82 f1 ff ff       	call   800a69 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  8018e7:	50                   	push   %eax
  8018e8:	68 58 38 80 00       	push   $0x803858
  8018ed:	6a 32                	push   $0x32
  8018ef:	68 78 38 80 00       	push   $0x803878
  8018f4:	e8 70 f1 ff ff       	call   800a69 <_panic>

008018f9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	57                   	push   %edi
  8018fd:	56                   	push   %esi
  8018fe:	53                   	push   %ebx
  8018ff:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  801902:	68 fb 17 80 00       	push   $0x8017fb
  801907:	e8 5d 15 00 00       	call   802e69 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80190c:	b8 07 00 00 00       	mov    $0x7,%eax
  801911:	cd 30                	int    $0x30
  801913:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  801916:	83 c4 10             	add    $0x10,%esp
  801919:	85 c0                	test   %eax,%eax
  80191b:	78 2d                	js     80194a <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  80191d:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  801922:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801926:	75 73                	jne    80199b <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  801928:	e8 9f fc ff ff       	call   8015cc <sys_getenvid>
  80192d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801932:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801935:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80193a:	a3 14 50 80 00       	mov    %eax,0x805014
		return 0;
  80193f:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  801942:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801945:	5b                   	pop    %ebx
  801946:	5e                   	pop    %esi
  801947:	5f                   	pop    %edi
  801948:	5d                   	pop    %ebp
  801949:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  80194a:	50                   	push   %eax
  80194b:	68 a1 38 80 00       	push   $0x8038a1
  801950:	6a 78                	push   $0x78
  801952:	68 78 38 80 00       	push   $0x803878
  801957:	e8 0d f1 ff ff       	call   800a69 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  80195c:	83 ec 0c             	sub    $0xc,%esp
  80195f:	ff 75 e4             	push   -0x1c(%ebp)
  801962:	57                   	push   %edi
  801963:	ff 75 dc             	push   -0x24(%ebp)
  801966:	57                   	push   %edi
  801967:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80196a:	56                   	push   %esi
  80196b:	e8 dd fc ff ff       	call   80164d <sys_page_map>
	if(r<0) return r;
  801970:	83 c4 20             	add    $0x20,%esp
  801973:	85 c0                	test   %eax,%eax
  801975:	78 cb                	js     801942 <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  801977:	83 ec 0c             	sub    $0xc,%esp
  80197a:	ff 75 e4             	push   -0x1c(%ebp)
  80197d:	57                   	push   %edi
  80197e:	56                   	push   %esi
  80197f:	57                   	push   %edi
  801980:	56                   	push   %esi
  801981:	e8 c7 fc ff ff       	call   80164d <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  801986:	83 c4 20             	add    $0x20,%esp
  801989:	85 c0                	test   %eax,%eax
  80198b:	78 76                	js     801a03 <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  80198d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801993:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801999:	74 75                	je     801a10 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  80199b:	89 d8                	mov    %ebx,%eax
  80199d:	c1 e8 16             	shr    $0x16,%eax
  8019a0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019a7:	a8 01                	test   $0x1,%al
  8019a9:	74 e2                	je     80198d <fork+0x94>
  8019ab:	89 de                	mov    %ebx,%esi
  8019ad:	c1 ee 0c             	shr    $0xc,%esi
  8019b0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8019b7:	a8 01                	test   $0x1,%al
  8019b9:	74 d2                	je     80198d <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  8019bb:	e8 0c fc ff ff       	call   8015cc <sys_getenvid>
  8019c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  8019c3:	89 f7                	mov    %esi,%edi
  8019c5:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  8019c8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8019cf:	89 c1                	mov    %eax,%ecx
  8019d1:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  8019d7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  8019da:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  8019e1:	f6 c6 04             	test   $0x4,%dh
  8019e4:	0f 85 72 ff ff ff    	jne    80195c <fork+0x63>
		perm &= ~PTE_W;
  8019ea:	25 05 0e 00 00       	and    $0xe05,%eax
  8019ef:	80 cc 08             	or     $0x8,%ah
  8019f2:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  8019f8:	0f 44 c1             	cmove  %ecx,%eax
  8019fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8019fe:	e9 59 ff ff ff       	jmp    80195c <fork+0x63>
  801a03:	ba 00 00 00 00       	mov    $0x0,%edx
  801a08:	0f 4f c2             	cmovg  %edx,%eax
  801a0b:	e9 32 ff ff ff       	jmp    801942 <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801a10:	83 ec 04             	sub    $0x4,%esp
  801a13:	6a 07                	push   $0x7
  801a15:	68 00 f0 bf ee       	push   $0xeebff000
  801a1a:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801a1d:	57                   	push   %edi
  801a1e:	e8 e7 fb ff ff       	call   80160a <sys_page_alloc>
	if(r<0) return r;
  801a23:	83 c4 10             	add    $0x10,%esp
  801a26:	85 c0                	test   %eax,%eax
  801a28:	0f 88 14 ff ff ff    	js     801942 <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801a2e:	83 ec 08             	sub    $0x8,%esp
  801a31:	68 df 2e 80 00       	push   $0x802edf
  801a36:	57                   	push   %edi
  801a37:	e8 19 fd ff ff       	call   801755 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801a3c:	83 c4 10             	add    $0x10,%esp
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	0f 88 fb fe ff ff    	js     801942 <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801a47:	83 ec 08             	sub    $0x8,%esp
  801a4a:	6a 02                	push   $0x2
  801a4c:	57                   	push   %edi
  801a4d:	e8 7f fc ff ff       	call   8016d1 <sys_env_set_status>
	if(r<0) return r;
  801a52:	83 c4 10             	add    $0x10,%esp
	return envid;
  801a55:	85 c0                	test   %eax,%eax
  801a57:	0f 49 c7             	cmovns %edi,%eax
  801a5a:	e9 e3 fe ff ff       	jmp    801942 <fork+0x49>

00801a5f <sfork>:

// Challenge!
int
sfork(void)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801a65:	68 b1 38 80 00       	push   $0x8038b1
  801a6a:	68 a1 00 00 00       	push   $0xa1
  801a6f:	68 78 38 80 00       	push   $0x803878
  801a74:	e8 f0 ef ff ff       	call   800a69 <_panic>

00801a79 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	8b 55 08             	mov    0x8(%ebp),%edx
  801a7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a82:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801a85:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801a87:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801a8a:	83 3a 01             	cmpl   $0x1,(%edx)
  801a8d:	7e 09                	jle    801a98 <argstart+0x1f>
  801a8f:	ba a1 32 80 00       	mov    $0x8032a1,%edx
  801a94:	85 c9                	test   %ecx,%ecx
  801a96:	75 05                	jne    801a9d <argstart+0x24>
  801a98:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9d:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801aa0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    

00801aa9 <argnext>:

int
argnext(struct Argstate *args)
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	53                   	push   %ebx
  801aad:	83 ec 04             	sub    $0x4,%esp
  801ab0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801ab3:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801aba:	8b 43 08             	mov    0x8(%ebx),%eax
  801abd:	85 c0                	test   %eax,%eax
  801abf:	74 74                	je     801b35 <argnext+0x8c>
		return -1;

	if (!*args->curarg) {
  801ac1:	80 38 00             	cmpb   $0x0,(%eax)
  801ac4:	75 48                	jne    801b0e <argnext+0x65>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801ac6:	8b 0b                	mov    (%ebx),%ecx
  801ac8:	83 39 01             	cmpl   $0x1,(%ecx)
  801acb:	74 5a                	je     801b27 <argnext+0x7e>
		    || args->argv[1][0] != '-'
  801acd:	8b 53 04             	mov    0x4(%ebx),%edx
  801ad0:	8b 42 04             	mov    0x4(%edx),%eax
  801ad3:	80 38 2d             	cmpb   $0x2d,(%eax)
  801ad6:	75 4f                	jne    801b27 <argnext+0x7e>
		    || args->argv[1][1] == '\0')
  801ad8:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801adc:	74 49                	je     801b27 <argnext+0x7e>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801ade:	83 c0 01             	add    $0x1,%eax
  801ae1:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801ae4:	83 ec 04             	sub    $0x4,%esp
  801ae7:	8b 01                	mov    (%ecx),%eax
  801ae9:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801af0:	50                   	push   %eax
  801af1:	8d 42 08             	lea    0x8(%edx),%eax
  801af4:	50                   	push   %eax
  801af5:	83 c2 04             	add    $0x4,%edx
  801af8:	52                   	push   %edx
  801af9:	e8 a6 f8 ff ff       	call   8013a4 <memmove>
		(*args->argc)--;
  801afe:	8b 03                	mov    (%ebx),%eax
  801b00:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b03:	8b 43 08             	mov    0x8(%ebx),%eax
  801b06:	83 c4 10             	add    $0x10,%esp
  801b09:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b0c:	74 13                	je     801b21 <argnext+0x78>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801b0e:	8b 43 08             	mov    0x8(%ebx),%eax
  801b11:	0f b6 10             	movzbl (%eax),%edx
	args->curarg++;
  801b14:	83 c0 01             	add    $0x1,%eax
  801b17:	89 43 08             	mov    %eax,0x8(%ebx)
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801b1a:	89 d0                	mov    %edx,%eax
  801b1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b1f:	c9                   	leave  
  801b20:	c3                   	ret    
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b21:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b25:	75 e7                	jne    801b0e <argnext+0x65>
	args->curarg = 0;
  801b27:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801b2e:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b33:	eb e5                	jmp    801b1a <argnext+0x71>
		return -1;
  801b35:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b3a:	eb de                	jmp    801b1a <argnext+0x71>

00801b3c <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	53                   	push   %ebx
  801b40:	83 ec 04             	sub    $0x4,%esp
  801b43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801b46:	8b 43 08             	mov    0x8(%ebx),%eax
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	74 12                	je     801b5f <argnextvalue+0x23>
		return 0;
	if (*args->curarg) {
  801b4d:	80 38 00             	cmpb   $0x0,(%eax)
  801b50:	74 12                	je     801b64 <argnextvalue+0x28>
		args->argvalue = args->curarg;
  801b52:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801b55:	c7 43 08 a1 32 80 00 	movl   $0x8032a1,0x8(%ebx)
		(*args->argc)--;
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
  801b5c:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  801b5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b62:	c9                   	leave  
  801b63:	c3                   	ret    
	} else if (*args->argc > 1) {
  801b64:	8b 13                	mov    (%ebx),%edx
  801b66:	83 3a 01             	cmpl   $0x1,(%edx)
  801b69:	7f 10                	jg     801b7b <argnextvalue+0x3f>
		args->argvalue = 0;
  801b6b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801b72:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  801b79:	eb e1                	jmp    801b5c <argnextvalue+0x20>
		args->argvalue = args->argv[1];
  801b7b:	8b 43 04             	mov    0x4(%ebx),%eax
  801b7e:	8b 48 04             	mov    0x4(%eax),%ecx
  801b81:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b84:	83 ec 04             	sub    $0x4,%esp
  801b87:	8b 12                	mov    (%edx),%edx
  801b89:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801b90:	52                   	push   %edx
  801b91:	8d 50 08             	lea    0x8(%eax),%edx
  801b94:	52                   	push   %edx
  801b95:	83 c0 04             	add    $0x4,%eax
  801b98:	50                   	push   %eax
  801b99:	e8 06 f8 ff ff       	call   8013a4 <memmove>
		(*args->argc)--;
  801b9e:	8b 03                	mov    (%ebx),%eax
  801ba0:	83 28 01             	subl   $0x1,(%eax)
  801ba3:	83 c4 10             	add    $0x10,%esp
  801ba6:	eb b4                	jmp    801b5c <argnextvalue+0x20>

00801ba8 <argvalue>:
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	83 ec 08             	sub    $0x8,%esp
  801bae:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801bb1:	8b 42 0c             	mov    0xc(%edx),%eax
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	74 02                	je     801bba <argvalue+0x12>
}
  801bb8:	c9                   	leave  
  801bb9:	c3                   	ret    
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801bba:	83 ec 0c             	sub    $0xc,%esp
  801bbd:	52                   	push   %edx
  801bbe:	e8 79 ff ff ff       	call   801b3c <argnextvalue>
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	eb f0                	jmp    801bb8 <argvalue+0x10>

00801bc8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801bcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bce:	05 00 00 00 30       	add    $0x30000000,%eax
  801bd3:	c1 e8 0c             	shr    $0xc,%eax
}
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    

00801bd8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bde:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801be3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801be8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801bed:	5d                   	pop    %ebp
  801bee:	c3                   	ret    

00801bef <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801bef:	55                   	push   %ebp
  801bf0:	89 e5                	mov    %esp,%ebp
  801bf2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801bf7:	89 c2                	mov    %eax,%edx
  801bf9:	c1 ea 16             	shr    $0x16,%edx
  801bfc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c03:	f6 c2 01             	test   $0x1,%dl
  801c06:	74 29                	je     801c31 <fd_alloc+0x42>
  801c08:	89 c2                	mov    %eax,%edx
  801c0a:	c1 ea 0c             	shr    $0xc,%edx
  801c0d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c14:	f6 c2 01             	test   $0x1,%dl
  801c17:	74 18                	je     801c31 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801c19:	05 00 10 00 00       	add    $0x1000,%eax
  801c1e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c23:	75 d2                	jne    801bf7 <fd_alloc+0x8>
  801c25:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801c2a:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801c2f:	eb 05                	jmp    801c36 <fd_alloc+0x47>
			return 0;
  801c31:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801c36:	8b 55 08             	mov    0x8(%ebp),%edx
  801c39:	89 02                	mov    %eax,(%edx)
}
  801c3b:	89 c8                	mov    %ecx,%eax
  801c3d:	5d                   	pop    %ebp
  801c3e:	c3                   	ret    

00801c3f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
  801c42:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c45:	83 f8 1f             	cmp    $0x1f,%eax
  801c48:	77 30                	ja     801c7a <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c4a:	c1 e0 0c             	shl    $0xc,%eax
  801c4d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801c52:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801c58:	f6 c2 01             	test   $0x1,%dl
  801c5b:	74 24                	je     801c81 <fd_lookup+0x42>
  801c5d:	89 c2                	mov    %eax,%edx
  801c5f:	c1 ea 0c             	shr    $0xc,%edx
  801c62:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c69:	f6 c2 01             	test   $0x1,%dl
  801c6c:	74 1a                	je     801c88 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801c6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c71:	89 02                	mov    %eax,(%edx)
	return 0;
  801c73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c78:	5d                   	pop    %ebp
  801c79:	c3                   	ret    
		return -E_INVAL;
  801c7a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c7f:	eb f7                	jmp    801c78 <fd_lookup+0x39>
		return -E_INVAL;
  801c81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c86:	eb f0                	jmp    801c78 <fd_lookup+0x39>
  801c88:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c8d:	eb e9                	jmp    801c78 <fd_lookup+0x39>

00801c8f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	53                   	push   %ebx
  801c93:	83 ec 04             	sub    $0x4,%esp
  801c96:	8b 55 08             	mov    0x8(%ebp),%edx
  801c99:	b8 44 39 80 00       	mov    $0x803944,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  801c9e:	bb 20 40 80 00       	mov    $0x804020,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801ca3:	39 13                	cmp    %edx,(%ebx)
  801ca5:	74 32                	je     801cd9 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  801ca7:	83 c0 04             	add    $0x4,%eax
  801caa:	8b 18                	mov    (%eax),%ebx
  801cac:	85 db                	test   %ebx,%ebx
  801cae:	75 f3                	jne    801ca3 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801cb0:	a1 14 50 80 00       	mov    0x805014,%eax
  801cb5:	8b 40 48             	mov    0x48(%eax),%eax
  801cb8:	83 ec 04             	sub    $0x4,%esp
  801cbb:	52                   	push   %edx
  801cbc:	50                   	push   %eax
  801cbd:	68 c8 38 80 00       	push   $0x8038c8
  801cc2:	e8 7d ee ff ff       	call   800b44 <cprintf>
	*dev = 0;
	return -E_INVAL;
  801cc7:	83 c4 10             	add    $0x10,%esp
  801cca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801ccf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cd2:	89 1a                	mov    %ebx,(%edx)
}
  801cd4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd7:	c9                   	leave  
  801cd8:	c3                   	ret    
			return 0;
  801cd9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cde:	eb ef                	jmp    801ccf <dev_lookup+0x40>

00801ce0 <fd_close>:
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	57                   	push   %edi
  801ce4:	56                   	push   %esi
  801ce5:	53                   	push   %ebx
  801ce6:	83 ec 24             	sub    $0x24,%esp
  801ce9:	8b 75 08             	mov    0x8(%ebp),%esi
  801cec:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801cef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801cf2:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801cf3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801cf9:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801cfc:	50                   	push   %eax
  801cfd:	e8 3d ff ff ff       	call   801c3f <fd_lookup>
  801d02:	89 c3                	mov    %eax,%ebx
  801d04:	83 c4 10             	add    $0x10,%esp
  801d07:	85 c0                	test   %eax,%eax
  801d09:	78 05                	js     801d10 <fd_close+0x30>
	    || fd != fd2)
  801d0b:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801d0e:	74 16                	je     801d26 <fd_close+0x46>
		return (must_exist ? r : 0);
  801d10:	89 f8                	mov    %edi,%eax
  801d12:	84 c0                	test   %al,%al
  801d14:	b8 00 00 00 00       	mov    $0x0,%eax
  801d19:	0f 44 d8             	cmove  %eax,%ebx
}
  801d1c:	89 d8                	mov    %ebx,%eax
  801d1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d21:	5b                   	pop    %ebx
  801d22:	5e                   	pop    %esi
  801d23:	5f                   	pop    %edi
  801d24:	5d                   	pop    %ebp
  801d25:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d26:	83 ec 08             	sub    $0x8,%esp
  801d29:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801d2c:	50                   	push   %eax
  801d2d:	ff 36                	push   (%esi)
  801d2f:	e8 5b ff ff ff       	call   801c8f <dev_lookup>
  801d34:	89 c3                	mov    %eax,%ebx
  801d36:	83 c4 10             	add    $0x10,%esp
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	78 1a                	js     801d57 <fd_close+0x77>
		if (dev->dev_close)
  801d3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d40:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801d43:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801d48:	85 c0                	test   %eax,%eax
  801d4a:	74 0b                	je     801d57 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801d4c:	83 ec 0c             	sub    $0xc,%esp
  801d4f:	56                   	push   %esi
  801d50:	ff d0                	call   *%eax
  801d52:	89 c3                	mov    %eax,%ebx
  801d54:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801d57:	83 ec 08             	sub    $0x8,%esp
  801d5a:	56                   	push   %esi
  801d5b:	6a 00                	push   $0x0
  801d5d:	e8 2d f9 ff ff       	call   80168f <sys_page_unmap>
	return r;
  801d62:	83 c4 10             	add    $0x10,%esp
  801d65:	eb b5                	jmp    801d1c <fd_close+0x3c>

00801d67 <close>:

int
close(int fdnum)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d70:	50                   	push   %eax
  801d71:	ff 75 08             	push   0x8(%ebp)
  801d74:	e8 c6 fe ff ff       	call   801c3f <fd_lookup>
  801d79:	83 c4 10             	add    $0x10,%esp
  801d7c:	85 c0                	test   %eax,%eax
  801d7e:	79 02                	jns    801d82 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801d80:	c9                   	leave  
  801d81:	c3                   	ret    
		return fd_close(fd, 1);
  801d82:	83 ec 08             	sub    $0x8,%esp
  801d85:	6a 01                	push   $0x1
  801d87:	ff 75 f4             	push   -0xc(%ebp)
  801d8a:	e8 51 ff ff ff       	call   801ce0 <fd_close>
  801d8f:	83 c4 10             	add    $0x10,%esp
  801d92:	eb ec                	jmp    801d80 <close+0x19>

00801d94 <close_all>:

void
close_all(void)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	53                   	push   %ebx
  801d98:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801d9b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801da0:	83 ec 0c             	sub    $0xc,%esp
  801da3:	53                   	push   %ebx
  801da4:	e8 be ff ff ff       	call   801d67 <close>
	for (i = 0; i < MAXFD; i++)
  801da9:	83 c3 01             	add    $0x1,%ebx
  801dac:	83 c4 10             	add    $0x10,%esp
  801daf:	83 fb 20             	cmp    $0x20,%ebx
  801db2:	75 ec                	jne    801da0 <close_all+0xc>
}
  801db4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801db7:	c9                   	leave  
  801db8:	c3                   	ret    

00801db9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	57                   	push   %edi
  801dbd:	56                   	push   %esi
  801dbe:	53                   	push   %ebx
  801dbf:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801dc2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801dc5:	50                   	push   %eax
  801dc6:	ff 75 08             	push   0x8(%ebp)
  801dc9:	e8 71 fe ff ff       	call   801c3f <fd_lookup>
  801dce:	89 c3                	mov    %eax,%ebx
  801dd0:	83 c4 10             	add    $0x10,%esp
  801dd3:	85 c0                	test   %eax,%eax
  801dd5:	78 7f                	js     801e56 <dup+0x9d>
		return r;
	close(newfdnum);
  801dd7:	83 ec 0c             	sub    $0xc,%esp
  801dda:	ff 75 0c             	push   0xc(%ebp)
  801ddd:	e8 85 ff ff ff       	call   801d67 <close>

	newfd = INDEX2FD(newfdnum);
  801de2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801de5:	c1 e6 0c             	shl    $0xc,%esi
  801de8:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801dee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801df1:	89 3c 24             	mov    %edi,(%esp)
  801df4:	e8 df fd ff ff       	call   801bd8 <fd2data>
  801df9:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801dfb:	89 34 24             	mov    %esi,(%esp)
  801dfe:	e8 d5 fd ff ff       	call   801bd8 <fd2data>
  801e03:	83 c4 10             	add    $0x10,%esp
  801e06:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801e09:	89 d8                	mov    %ebx,%eax
  801e0b:	c1 e8 16             	shr    $0x16,%eax
  801e0e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e15:	a8 01                	test   $0x1,%al
  801e17:	74 11                	je     801e2a <dup+0x71>
  801e19:	89 d8                	mov    %ebx,%eax
  801e1b:	c1 e8 0c             	shr    $0xc,%eax
  801e1e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e25:	f6 c2 01             	test   $0x1,%dl
  801e28:	75 36                	jne    801e60 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e2a:	89 f8                	mov    %edi,%eax
  801e2c:	c1 e8 0c             	shr    $0xc,%eax
  801e2f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e36:	83 ec 0c             	sub    $0xc,%esp
  801e39:	25 07 0e 00 00       	and    $0xe07,%eax
  801e3e:	50                   	push   %eax
  801e3f:	56                   	push   %esi
  801e40:	6a 00                	push   $0x0
  801e42:	57                   	push   %edi
  801e43:	6a 00                	push   $0x0
  801e45:	e8 03 f8 ff ff       	call   80164d <sys_page_map>
  801e4a:	89 c3                	mov    %eax,%ebx
  801e4c:	83 c4 20             	add    $0x20,%esp
  801e4f:	85 c0                	test   %eax,%eax
  801e51:	78 33                	js     801e86 <dup+0xcd>
		goto err;

	return newfdnum;
  801e53:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801e56:	89 d8                	mov    %ebx,%eax
  801e58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e5b:	5b                   	pop    %ebx
  801e5c:	5e                   	pop    %esi
  801e5d:	5f                   	pop    %edi
  801e5e:	5d                   	pop    %ebp
  801e5f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e60:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e67:	83 ec 0c             	sub    $0xc,%esp
  801e6a:	25 07 0e 00 00       	and    $0xe07,%eax
  801e6f:	50                   	push   %eax
  801e70:	ff 75 d4             	push   -0x2c(%ebp)
  801e73:	6a 00                	push   $0x0
  801e75:	53                   	push   %ebx
  801e76:	6a 00                	push   $0x0
  801e78:	e8 d0 f7 ff ff       	call   80164d <sys_page_map>
  801e7d:	89 c3                	mov    %eax,%ebx
  801e7f:	83 c4 20             	add    $0x20,%esp
  801e82:	85 c0                	test   %eax,%eax
  801e84:	79 a4                	jns    801e2a <dup+0x71>
	sys_page_unmap(0, newfd);
  801e86:	83 ec 08             	sub    $0x8,%esp
  801e89:	56                   	push   %esi
  801e8a:	6a 00                	push   $0x0
  801e8c:	e8 fe f7 ff ff       	call   80168f <sys_page_unmap>
	sys_page_unmap(0, nva);
  801e91:	83 c4 08             	add    $0x8,%esp
  801e94:	ff 75 d4             	push   -0x2c(%ebp)
  801e97:	6a 00                	push   $0x0
  801e99:	e8 f1 f7 ff ff       	call   80168f <sys_page_unmap>
	return r;
  801e9e:	83 c4 10             	add    $0x10,%esp
  801ea1:	eb b3                	jmp    801e56 <dup+0x9d>

00801ea3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801ea3:	55                   	push   %ebp
  801ea4:	89 e5                	mov    %esp,%ebp
  801ea6:	56                   	push   %esi
  801ea7:	53                   	push   %ebx
  801ea8:	83 ec 18             	sub    $0x18,%esp
  801eab:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801eae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801eb1:	50                   	push   %eax
  801eb2:	56                   	push   %esi
  801eb3:	e8 87 fd ff ff       	call   801c3f <fd_lookup>
  801eb8:	83 c4 10             	add    $0x10,%esp
  801ebb:	85 c0                	test   %eax,%eax
  801ebd:	78 3c                	js     801efb <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ebf:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801ec2:	83 ec 08             	sub    $0x8,%esp
  801ec5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec8:	50                   	push   %eax
  801ec9:	ff 33                	push   (%ebx)
  801ecb:	e8 bf fd ff ff       	call   801c8f <dev_lookup>
  801ed0:	83 c4 10             	add    $0x10,%esp
  801ed3:	85 c0                	test   %eax,%eax
  801ed5:	78 24                	js     801efb <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801ed7:	8b 43 08             	mov    0x8(%ebx),%eax
  801eda:	83 e0 03             	and    $0x3,%eax
  801edd:	83 f8 01             	cmp    $0x1,%eax
  801ee0:	74 20                	je     801f02 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee5:	8b 40 08             	mov    0x8(%eax),%eax
  801ee8:	85 c0                	test   %eax,%eax
  801eea:	74 37                	je     801f23 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801eec:	83 ec 04             	sub    $0x4,%esp
  801eef:	ff 75 10             	push   0x10(%ebp)
  801ef2:	ff 75 0c             	push   0xc(%ebp)
  801ef5:	53                   	push   %ebx
  801ef6:	ff d0                	call   *%eax
  801ef8:	83 c4 10             	add    $0x10,%esp
}
  801efb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801efe:	5b                   	pop    %ebx
  801eff:	5e                   	pop    %esi
  801f00:	5d                   	pop    %ebp
  801f01:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801f02:	a1 14 50 80 00       	mov    0x805014,%eax
  801f07:	8b 40 48             	mov    0x48(%eax),%eax
  801f0a:	83 ec 04             	sub    $0x4,%esp
  801f0d:	56                   	push   %esi
  801f0e:	50                   	push   %eax
  801f0f:	68 09 39 80 00       	push   $0x803909
  801f14:	e8 2b ec ff ff       	call   800b44 <cprintf>
		return -E_INVAL;
  801f19:	83 c4 10             	add    $0x10,%esp
  801f1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f21:	eb d8                	jmp    801efb <read+0x58>
		return -E_NOT_SUPP;
  801f23:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801f28:	eb d1                	jmp    801efb <read+0x58>

00801f2a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	57                   	push   %edi
  801f2e:	56                   	push   %esi
  801f2f:	53                   	push   %ebx
  801f30:	83 ec 0c             	sub    $0xc,%esp
  801f33:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f36:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f39:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f3e:	eb 02                	jmp    801f42 <readn+0x18>
  801f40:	01 c3                	add    %eax,%ebx
  801f42:	39 f3                	cmp    %esi,%ebx
  801f44:	73 21                	jae    801f67 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f46:	83 ec 04             	sub    $0x4,%esp
  801f49:	89 f0                	mov    %esi,%eax
  801f4b:	29 d8                	sub    %ebx,%eax
  801f4d:	50                   	push   %eax
  801f4e:	89 d8                	mov    %ebx,%eax
  801f50:	03 45 0c             	add    0xc(%ebp),%eax
  801f53:	50                   	push   %eax
  801f54:	57                   	push   %edi
  801f55:	e8 49 ff ff ff       	call   801ea3 <read>
		if (m < 0)
  801f5a:	83 c4 10             	add    $0x10,%esp
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	78 04                	js     801f65 <readn+0x3b>
			return m;
		if (m == 0)
  801f61:	75 dd                	jne    801f40 <readn+0x16>
  801f63:	eb 02                	jmp    801f67 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f65:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801f67:	89 d8                	mov    %ebx,%eax
  801f69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6c:	5b                   	pop    %ebx
  801f6d:	5e                   	pop    %esi
  801f6e:	5f                   	pop    %edi
  801f6f:	5d                   	pop    %ebp
  801f70:	c3                   	ret    

00801f71 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801f71:	55                   	push   %ebp
  801f72:	89 e5                	mov    %esp,%ebp
  801f74:	56                   	push   %esi
  801f75:	53                   	push   %ebx
  801f76:	83 ec 18             	sub    $0x18,%esp
  801f79:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f7c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f7f:	50                   	push   %eax
  801f80:	53                   	push   %ebx
  801f81:	e8 b9 fc ff ff       	call   801c3f <fd_lookup>
  801f86:	83 c4 10             	add    $0x10,%esp
  801f89:	85 c0                	test   %eax,%eax
  801f8b:	78 37                	js     801fc4 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f8d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801f90:	83 ec 08             	sub    $0x8,%esp
  801f93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f96:	50                   	push   %eax
  801f97:	ff 36                	push   (%esi)
  801f99:	e8 f1 fc ff ff       	call   801c8f <dev_lookup>
  801f9e:	83 c4 10             	add    $0x10,%esp
  801fa1:	85 c0                	test   %eax,%eax
  801fa3:	78 1f                	js     801fc4 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801fa5:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801fa9:	74 20                	je     801fcb <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fae:	8b 40 0c             	mov    0xc(%eax),%eax
  801fb1:	85 c0                	test   %eax,%eax
  801fb3:	74 37                	je     801fec <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801fb5:	83 ec 04             	sub    $0x4,%esp
  801fb8:	ff 75 10             	push   0x10(%ebp)
  801fbb:	ff 75 0c             	push   0xc(%ebp)
  801fbe:	56                   	push   %esi
  801fbf:	ff d0                	call   *%eax
  801fc1:	83 c4 10             	add    $0x10,%esp
}
  801fc4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fc7:	5b                   	pop    %ebx
  801fc8:	5e                   	pop    %esi
  801fc9:	5d                   	pop    %ebp
  801fca:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801fcb:	a1 14 50 80 00       	mov    0x805014,%eax
  801fd0:	8b 40 48             	mov    0x48(%eax),%eax
  801fd3:	83 ec 04             	sub    $0x4,%esp
  801fd6:	53                   	push   %ebx
  801fd7:	50                   	push   %eax
  801fd8:	68 25 39 80 00       	push   $0x803925
  801fdd:	e8 62 eb ff ff       	call   800b44 <cprintf>
		return -E_INVAL;
  801fe2:	83 c4 10             	add    $0x10,%esp
  801fe5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801fea:	eb d8                	jmp    801fc4 <write+0x53>
		return -E_NOT_SUPP;
  801fec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801ff1:	eb d1                	jmp    801fc4 <write+0x53>

00801ff3 <seek>:

int
seek(int fdnum, off_t offset)
{
  801ff3:	55                   	push   %ebp
  801ff4:	89 e5                	mov    %esp,%ebp
  801ff6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ff9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ffc:	50                   	push   %eax
  801ffd:	ff 75 08             	push   0x8(%ebp)
  802000:	e8 3a fc ff ff       	call   801c3f <fd_lookup>
  802005:	83 c4 10             	add    $0x10,%esp
  802008:	85 c0                	test   %eax,%eax
  80200a:	78 0e                	js     80201a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80200c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80200f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802012:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802015:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80201a:	c9                   	leave  
  80201b:	c3                   	ret    

0080201c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	56                   	push   %esi
  802020:	53                   	push   %ebx
  802021:	83 ec 18             	sub    $0x18,%esp
  802024:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802027:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80202a:	50                   	push   %eax
  80202b:	53                   	push   %ebx
  80202c:	e8 0e fc ff ff       	call   801c3f <fd_lookup>
  802031:	83 c4 10             	add    $0x10,%esp
  802034:	85 c0                	test   %eax,%eax
  802036:	78 34                	js     80206c <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802038:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80203b:	83 ec 08             	sub    $0x8,%esp
  80203e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802041:	50                   	push   %eax
  802042:	ff 36                	push   (%esi)
  802044:	e8 46 fc ff ff       	call   801c8f <dev_lookup>
  802049:	83 c4 10             	add    $0x10,%esp
  80204c:	85 c0                	test   %eax,%eax
  80204e:	78 1c                	js     80206c <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802050:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  802054:	74 1d                	je     802073 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  802056:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802059:	8b 40 18             	mov    0x18(%eax),%eax
  80205c:	85 c0                	test   %eax,%eax
  80205e:	74 34                	je     802094 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802060:	83 ec 08             	sub    $0x8,%esp
  802063:	ff 75 0c             	push   0xc(%ebp)
  802066:	56                   	push   %esi
  802067:	ff d0                	call   *%eax
  802069:	83 c4 10             	add    $0x10,%esp
}
  80206c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80206f:	5b                   	pop    %ebx
  802070:	5e                   	pop    %esi
  802071:	5d                   	pop    %ebp
  802072:	c3                   	ret    
			thisenv->env_id, fdnum);
  802073:	a1 14 50 80 00       	mov    0x805014,%eax
  802078:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80207b:	83 ec 04             	sub    $0x4,%esp
  80207e:	53                   	push   %ebx
  80207f:	50                   	push   %eax
  802080:	68 e8 38 80 00       	push   $0x8038e8
  802085:	e8 ba ea ff ff       	call   800b44 <cprintf>
		return -E_INVAL;
  80208a:	83 c4 10             	add    $0x10,%esp
  80208d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802092:	eb d8                	jmp    80206c <ftruncate+0x50>
		return -E_NOT_SUPP;
  802094:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802099:	eb d1                	jmp    80206c <ftruncate+0x50>

0080209b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80209b:	55                   	push   %ebp
  80209c:	89 e5                	mov    %esp,%ebp
  80209e:	56                   	push   %esi
  80209f:	53                   	push   %ebx
  8020a0:	83 ec 18             	sub    $0x18,%esp
  8020a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020a9:	50                   	push   %eax
  8020aa:	ff 75 08             	push   0x8(%ebp)
  8020ad:	e8 8d fb ff ff       	call   801c3f <fd_lookup>
  8020b2:	83 c4 10             	add    $0x10,%esp
  8020b5:	85 c0                	test   %eax,%eax
  8020b7:	78 49                	js     802102 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020b9:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8020bc:	83 ec 08             	sub    $0x8,%esp
  8020bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020c2:	50                   	push   %eax
  8020c3:	ff 36                	push   (%esi)
  8020c5:	e8 c5 fb ff ff       	call   801c8f <dev_lookup>
  8020ca:	83 c4 10             	add    $0x10,%esp
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	78 31                	js     802102 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8020d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8020d8:	74 2f                	je     802109 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8020da:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8020dd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8020e4:	00 00 00 
	stat->st_isdir = 0;
  8020e7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8020ee:	00 00 00 
	stat->st_dev = dev;
  8020f1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8020f7:	83 ec 08             	sub    $0x8,%esp
  8020fa:	53                   	push   %ebx
  8020fb:	56                   	push   %esi
  8020fc:	ff 50 14             	call   *0x14(%eax)
  8020ff:	83 c4 10             	add    $0x10,%esp
}
  802102:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802105:	5b                   	pop    %ebx
  802106:	5e                   	pop    %esi
  802107:	5d                   	pop    %ebp
  802108:	c3                   	ret    
		return -E_NOT_SUPP;
  802109:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80210e:	eb f2                	jmp    802102 <fstat+0x67>

00802110 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
  802113:	56                   	push   %esi
  802114:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802115:	83 ec 08             	sub    $0x8,%esp
  802118:	6a 00                	push   $0x0
  80211a:	ff 75 08             	push   0x8(%ebp)
  80211d:	e8 e4 01 00 00       	call   802306 <open>
  802122:	89 c3                	mov    %eax,%ebx
  802124:	83 c4 10             	add    $0x10,%esp
  802127:	85 c0                	test   %eax,%eax
  802129:	78 1b                	js     802146 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80212b:	83 ec 08             	sub    $0x8,%esp
  80212e:	ff 75 0c             	push   0xc(%ebp)
  802131:	50                   	push   %eax
  802132:	e8 64 ff ff ff       	call   80209b <fstat>
  802137:	89 c6                	mov    %eax,%esi
	close(fd);
  802139:	89 1c 24             	mov    %ebx,(%esp)
  80213c:	e8 26 fc ff ff       	call   801d67 <close>
	return r;
  802141:	83 c4 10             	add    $0x10,%esp
  802144:	89 f3                	mov    %esi,%ebx
}
  802146:	89 d8                	mov    %ebx,%eax
  802148:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80214b:	5b                   	pop    %ebx
  80214c:	5e                   	pop    %esi
  80214d:	5d                   	pop    %ebp
  80214e:	c3                   	ret    

0080214f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80214f:	55                   	push   %ebp
  802150:	89 e5                	mov    %esp,%ebp
  802152:	56                   	push   %esi
  802153:	53                   	push   %ebx
  802154:	89 c6                	mov    %eax,%esi
  802156:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802158:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80215f:	74 27                	je     802188 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802161:	6a 07                	push   $0x7
  802163:	68 00 60 80 00       	push   $0x806000
  802168:	56                   	push   %esi
  802169:	ff 35 00 70 80 00    	push   0x807000
  80216f:	e8 f8 0d 00 00       	call   802f6c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802174:	83 c4 0c             	add    $0xc,%esp
  802177:	6a 00                	push   $0x0
  802179:	53                   	push   %ebx
  80217a:	6a 00                	push   $0x0
  80217c:	e8 84 0d 00 00       	call   802f05 <ipc_recv>
}
  802181:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802184:	5b                   	pop    %ebx
  802185:	5e                   	pop    %esi
  802186:	5d                   	pop    %ebp
  802187:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802188:	83 ec 0c             	sub    $0xc,%esp
  80218b:	6a 01                	push   $0x1
  80218d:	e8 2e 0e 00 00       	call   802fc0 <ipc_find_env>
  802192:	a3 00 70 80 00       	mov    %eax,0x807000
  802197:	83 c4 10             	add    $0x10,%esp
  80219a:	eb c5                	jmp    802161 <fsipc+0x12>

0080219c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
  80219f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8021a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8021a8:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8021ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021b0:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8021b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8021ba:	b8 02 00 00 00       	mov    $0x2,%eax
  8021bf:	e8 8b ff ff ff       	call   80214f <fsipc>
}
  8021c4:	c9                   	leave  
  8021c5:	c3                   	ret    

008021c6 <devfile_flush>:
{
  8021c6:	55                   	push   %ebp
  8021c7:	89 e5                	mov    %esp,%ebp
  8021c9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8021cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8021d2:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8021d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8021dc:	b8 06 00 00 00       	mov    $0x6,%eax
  8021e1:	e8 69 ff ff ff       	call   80214f <fsipc>
}
  8021e6:	c9                   	leave  
  8021e7:	c3                   	ret    

008021e8 <devfile_stat>:
{
  8021e8:	55                   	push   %ebp
  8021e9:	89 e5                	mov    %esp,%ebp
  8021eb:	53                   	push   %ebx
  8021ec:	83 ec 04             	sub    $0x4,%esp
  8021ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8021f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8021f8:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8021fd:	ba 00 00 00 00       	mov    $0x0,%edx
  802202:	b8 05 00 00 00       	mov    $0x5,%eax
  802207:	e8 43 ff ff ff       	call   80214f <fsipc>
  80220c:	85 c0                	test   %eax,%eax
  80220e:	78 2c                	js     80223c <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802210:	83 ec 08             	sub    $0x8,%esp
  802213:	68 00 60 80 00       	push   $0x806000
  802218:	53                   	push   %ebx
  802219:	e8 f0 ef ff ff       	call   80120e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80221e:	a1 80 60 80 00       	mov    0x806080,%eax
  802223:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802229:	a1 84 60 80 00       	mov    0x806084,%eax
  80222e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802234:	83 c4 10             	add    $0x10,%esp
  802237:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80223c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80223f:	c9                   	leave  
  802240:	c3                   	ret    

00802241 <devfile_write>:
{
  802241:	55                   	push   %ebp
  802242:	89 e5                	mov    %esp,%ebp
  802244:	83 ec 0c             	sub    $0xc,%esp
  802247:	8b 45 10             	mov    0x10(%ebp),%eax
  80224a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80224f:	39 d0                	cmp    %edx,%eax
  802251:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802254:	8b 55 08             	mov    0x8(%ebp),%edx
  802257:	8b 52 0c             	mov    0xc(%edx),%edx
  80225a:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  802260:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802265:	50                   	push   %eax
  802266:	ff 75 0c             	push   0xc(%ebp)
  802269:	68 08 60 80 00       	push   $0x806008
  80226e:	e8 31 f1 ff ff       	call   8013a4 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  802273:	ba 00 00 00 00       	mov    $0x0,%edx
  802278:	b8 04 00 00 00       	mov    $0x4,%eax
  80227d:	e8 cd fe ff ff       	call   80214f <fsipc>
}
  802282:	c9                   	leave  
  802283:	c3                   	ret    

00802284 <devfile_read>:
{
  802284:	55                   	push   %ebp
  802285:	89 e5                	mov    %esp,%ebp
  802287:	56                   	push   %esi
  802288:	53                   	push   %ebx
  802289:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80228c:	8b 45 08             	mov    0x8(%ebp),%eax
  80228f:	8b 40 0c             	mov    0xc(%eax),%eax
  802292:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  802297:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80229d:	ba 00 00 00 00       	mov    $0x0,%edx
  8022a2:	b8 03 00 00 00       	mov    $0x3,%eax
  8022a7:	e8 a3 fe ff ff       	call   80214f <fsipc>
  8022ac:	89 c3                	mov    %eax,%ebx
  8022ae:	85 c0                	test   %eax,%eax
  8022b0:	78 1f                	js     8022d1 <devfile_read+0x4d>
	assert(r <= n);
  8022b2:	39 f0                	cmp    %esi,%eax
  8022b4:	77 24                	ja     8022da <devfile_read+0x56>
	assert(r <= PGSIZE);
  8022b6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8022bb:	7f 33                	jg     8022f0 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8022bd:	83 ec 04             	sub    $0x4,%esp
  8022c0:	50                   	push   %eax
  8022c1:	68 00 60 80 00       	push   $0x806000
  8022c6:	ff 75 0c             	push   0xc(%ebp)
  8022c9:	e8 d6 f0 ff ff       	call   8013a4 <memmove>
	return r;
  8022ce:	83 c4 10             	add    $0x10,%esp
}
  8022d1:	89 d8                	mov    %ebx,%eax
  8022d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022d6:	5b                   	pop    %ebx
  8022d7:	5e                   	pop    %esi
  8022d8:	5d                   	pop    %ebp
  8022d9:	c3                   	ret    
	assert(r <= n);
  8022da:	68 54 39 80 00       	push   $0x803954
  8022df:	68 c6 33 80 00       	push   $0x8033c6
  8022e4:	6a 7c                	push   $0x7c
  8022e6:	68 5b 39 80 00       	push   $0x80395b
  8022eb:	e8 79 e7 ff ff       	call   800a69 <_panic>
	assert(r <= PGSIZE);
  8022f0:	68 66 39 80 00       	push   $0x803966
  8022f5:	68 c6 33 80 00       	push   $0x8033c6
  8022fa:	6a 7d                	push   $0x7d
  8022fc:	68 5b 39 80 00       	push   $0x80395b
  802301:	e8 63 e7 ff ff       	call   800a69 <_panic>

00802306 <open>:
{
  802306:	55                   	push   %ebp
  802307:	89 e5                	mov    %esp,%ebp
  802309:	56                   	push   %esi
  80230a:	53                   	push   %ebx
  80230b:	83 ec 1c             	sub    $0x1c,%esp
  80230e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  802311:	56                   	push   %esi
  802312:	e8 bc ee ff ff       	call   8011d3 <strlen>
  802317:	83 c4 10             	add    $0x10,%esp
  80231a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80231f:	7f 6c                	jg     80238d <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  802321:	83 ec 0c             	sub    $0xc,%esp
  802324:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802327:	50                   	push   %eax
  802328:	e8 c2 f8 ff ff       	call   801bef <fd_alloc>
  80232d:	89 c3                	mov    %eax,%ebx
  80232f:	83 c4 10             	add    $0x10,%esp
  802332:	85 c0                	test   %eax,%eax
  802334:	78 3c                	js     802372 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  802336:	83 ec 08             	sub    $0x8,%esp
  802339:	56                   	push   %esi
  80233a:	68 00 60 80 00       	push   $0x806000
  80233f:	e8 ca ee ff ff       	call   80120e <strcpy>
	fsipcbuf.open.req_omode = mode;
  802344:	8b 45 0c             	mov    0xc(%ebp),%eax
  802347:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80234c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80234f:	b8 01 00 00 00       	mov    $0x1,%eax
  802354:	e8 f6 fd ff ff       	call   80214f <fsipc>
  802359:	89 c3                	mov    %eax,%ebx
  80235b:	83 c4 10             	add    $0x10,%esp
  80235e:	85 c0                	test   %eax,%eax
  802360:	78 19                	js     80237b <open+0x75>
	return fd2num(fd);
  802362:	83 ec 0c             	sub    $0xc,%esp
  802365:	ff 75 f4             	push   -0xc(%ebp)
  802368:	e8 5b f8 ff ff       	call   801bc8 <fd2num>
  80236d:	89 c3                	mov    %eax,%ebx
  80236f:	83 c4 10             	add    $0x10,%esp
}
  802372:	89 d8                	mov    %ebx,%eax
  802374:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802377:	5b                   	pop    %ebx
  802378:	5e                   	pop    %esi
  802379:	5d                   	pop    %ebp
  80237a:	c3                   	ret    
		fd_close(fd, 0);
  80237b:	83 ec 08             	sub    $0x8,%esp
  80237e:	6a 00                	push   $0x0
  802380:	ff 75 f4             	push   -0xc(%ebp)
  802383:	e8 58 f9 ff ff       	call   801ce0 <fd_close>
		return r;
  802388:	83 c4 10             	add    $0x10,%esp
  80238b:	eb e5                	jmp    802372 <open+0x6c>
		return -E_BAD_PATH;
  80238d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  802392:	eb de                	jmp    802372 <open+0x6c>

00802394 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802394:	55                   	push   %ebp
  802395:	89 e5                	mov    %esp,%ebp
  802397:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80239a:	ba 00 00 00 00       	mov    $0x0,%edx
  80239f:	b8 08 00 00 00       	mov    $0x8,%eax
  8023a4:	e8 a6 fd ff ff       	call   80214f <fsipc>
}
  8023a9:	c9                   	leave  
  8023aa:	c3                   	ret    

008023ab <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8023ab:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8023af:	7f 01                	jg     8023b2 <writebuf+0x7>
  8023b1:	c3                   	ret    
{
  8023b2:	55                   	push   %ebp
  8023b3:	89 e5                	mov    %esp,%ebp
  8023b5:	53                   	push   %ebx
  8023b6:	83 ec 08             	sub    $0x8,%esp
  8023b9:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  8023bb:	ff 70 04             	push   0x4(%eax)
  8023be:	8d 40 10             	lea    0x10(%eax),%eax
  8023c1:	50                   	push   %eax
  8023c2:	ff 33                	push   (%ebx)
  8023c4:	e8 a8 fb ff ff       	call   801f71 <write>
		if (result > 0)
  8023c9:	83 c4 10             	add    $0x10,%esp
  8023cc:	85 c0                	test   %eax,%eax
  8023ce:	7e 03                	jle    8023d3 <writebuf+0x28>
			b->result += result;
  8023d0:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8023d3:	39 43 04             	cmp    %eax,0x4(%ebx)
  8023d6:	74 0d                	je     8023e5 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  8023d8:	85 c0                	test   %eax,%eax
  8023da:	ba 00 00 00 00       	mov    $0x0,%edx
  8023df:	0f 4f c2             	cmovg  %edx,%eax
  8023e2:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8023e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023e8:	c9                   	leave  
  8023e9:	c3                   	ret    

008023ea <putch>:

static void
putch(int ch, void *thunk)
{
  8023ea:	55                   	push   %ebp
  8023eb:	89 e5                	mov    %esp,%ebp
  8023ed:	53                   	push   %ebx
  8023ee:	83 ec 04             	sub    $0x4,%esp
  8023f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8023f4:	8b 53 04             	mov    0x4(%ebx),%edx
  8023f7:	8d 42 01             	lea    0x1(%edx),%eax
  8023fa:	89 43 04             	mov    %eax,0x4(%ebx)
  8023fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802400:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  802404:	3d 00 01 00 00       	cmp    $0x100,%eax
  802409:	74 05                	je     802410 <putch+0x26>
		writebuf(b);
		b->idx = 0;
	}
}
  80240b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80240e:	c9                   	leave  
  80240f:	c3                   	ret    
		writebuf(b);
  802410:	89 d8                	mov    %ebx,%eax
  802412:	e8 94 ff ff ff       	call   8023ab <writebuf>
		b->idx = 0;
  802417:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  80241e:	eb eb                	jmp    80240b <putch+0x21>

00802420 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  802420:	55                   	push   %ebp
  802421:	89 e5                	mov    %esp,%ebp
  802423:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  802429:	8b 45 08             	mov    0x8(%ebp),%eax
  80242c:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802432:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802439:	00 00 00 
	b.result = 0;
  80243c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802443:	00 00 00 
	b.error = 1;
  802446:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80244d:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  802450:	ff 75 10             	push   0x10(%ebp)
  802453:	ff 75 0c             	push   0xc(%ebp)
  802456:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80245c:	50                   	push   %eax
  80245d:	68 ea 23 80 00       	push   $0x8023ea
  802462:	e8 d4 e7 ff ff       	call   800c3b <vprintfmt>
	if (b.idx > 0)
  802467:	83 c4 10             	add    $0x10,%esp
  80246a:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  802471:	7f 11                	jg     802484 <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  802473:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802479:	85 c0                	test   %eax,%eax
  80247b:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  802482:	c9                   	leave  
  802483:	c3                   	ret    
		writebuf(&b);
  802484:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80248a:	e8 1c ff ff ff       	call   8023ab <writebuf>
  80248f:	eb e2                	jmp    802473 <vfprintf+0x53>

00802491 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802491:	55                   	push   %ebp
  802492:	89 e5                	mov    %esp,%ebp
  802494:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802497:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80249a:	50                   	push   %eax
  80249b:	ff 75 0c             	push   0xc(%ebp)
  80249e:	ff 75 08             	push   0x8(%ebp)
  8024a1:	e8 7a ff ff ff       	call   802420 <vfprintf>
	va_end(ap);

	return cnt;
}
  8024a6:	c9                   	leave  
  8024a7:	c3                   	ret    

008024a8 <printf>:

int
printf(const char *fmt, ...)
{
  8024a8:	55                   	push   %ebp
  8024a9:	89 e5                	mov    %esp,%ebp
  8024ab:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8024b1:	50                   	push   %eax
  8024b2:	ff 75 08             	push   0x8(%ebp)
  8024b5:	6a 01                	push   $0x1
  8024b7:	e8 64 ff ff ff       	call   802420 <vfprintf>
	va_end(ap);

	return cnt;
}
  8024bc:	c9                   	leave  
  8024bd:	c3                   	ret    

008024be <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8024be:	55                   	push   %ebp
  8024bf:	89 e5                	mov    %esp,%ebp
  8024c1:	57                   	push   %edi
  8024c2:	56                   	push   %esi
  8024c3:	53                   	push   %ebx
  8024c4:	81 ec 84 02 00 00    	sub    $0x284,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8024ca:	6a 00                	push   $0x0
  8024cc:	ff 75 08             	push   0x8(%ebp)
  8024cf:	e8 32 fe ff ff       	call   802306 <open>
  8024d4:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8024da:	83 c4 10             	add    $0x10,%esp
  8024dd:	85 c0                	test   %eax,%eax
  8024df:	0f 88 aa 04 00 00    	js     80298f <spawn+0x4d1>
  8024e5:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8024e7:	83 ec 04             	sub    $0x4,%esp
  8024ea:	68 00 02 00 00       	push   $0x200
  8024ef:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8024f5:	50                   	push   %eax
  8024f6:	57                   	push   %edi
  8024f7:	e8 2e fa ff ff       	call   801f2a <readn>
  8024fc:	83 c4 10             	add    $0x10,%esp
  8024ff:	3d 00 02 00 00       	cmp    $0x200,%eax
  802504:	75 57                	jne    80255d <spawn+0x9f>
	    || elf->e_magic != ELF_MAGIC) {
  802506:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80250d:	45 4c 46 
  802510:	75 4b                	jne    80255d <spawn+0x9f>
  802512:	b8 07 00 00 00       	mov    $0x7,%eax
  802517:	cd 30                	int    $0x30
  802519:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80251f:	85 c0                	test   %eax,%eax
  802521:	0f 88 5c 04 00 00    	js     802983 <spawn+0x4c5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802527:	25 ff 03 00 00       	and    $0x3ff,%eax
  80252c:	6b f0 7c             	imul   $0x7c,%eax,%esi
  80252f:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  802535:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80253b:	b9 11 00 00 00       	mov    $0x11,%ecx
  802540:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802542:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802548:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80254e:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  802553:	be 00 00 00 00       	mov    $0x0,%esi
  802558:	8b 7d 0c             	mov    0xc(%ebp),%edi
	for (argc = 0; argv[argc] != 0; argc++)
  80255b:	eb 4b                	jmp    8025a8 <spawn+0xea>
		close(fd);
  80255d:	83 ec 0c             	sub    $0xc,%esp
  802560:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  802566:	e8 fc f7 ff ff       	call   801d67 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80256b:	83 c4 0c             	add    $0xc,%esp
  80256e:	68 7f 45 4c 46       	push   $0x464c457f
  802573:	ff b5 e8 fd ff ff    	push   -0x218(%ebp)
  802579:	68 72 39 80 00       	push   $0x803972
  80257e:	e8 c1 e5 ff ff       	call   800b44 <cprintf>
		return -E_NOT_EXEC;
  802583:	83 c4 10             	add    $0x10,%esp
  802586:	c7 85 8c fd ff ff f2 	movl   $0xfffffff2,-0x274(%ebp)
  80258d:	ff ff ff 
  802590:	e9 fa 03 00 00       	jmp    80298f <spawn+0x4d1>
		string_size += strlen(argv[argc]) + 1;
  802595:	83 ec 0c             	sub    $0xc,%esp
  802598:	50                   	push   %eax
  802599:	e8 35 ec ff ff       	call   8011d3 <strlen>
  80259e:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8025a2:	83 c3 01             	add    $0x1,%ebx
  8025a5:	83 c4 10             	add    $0x10,%esp
  8025a8:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8025af:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8025b2:	85 c0                	test   %eax,%eax
  8025b4:	75 df                	jne    802595 <spawn+0xd7>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8025b6:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  8025bc:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  8025c2:	b8 00 10 40 00       	mov    $0x401000,%eax
  8025c7:	29 f0                	sub    %esi,%eax
  8025c9:	89 c7                	mov    %eax,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8025cb:	89 c2                	mov    %eax,%edx
  8025cd:	83 e2 fc             	and    $0xfffffffc,%edx
  8025d0:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8025d7:	29 c2                	sub    %eax,%edx
  8025d9:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8025df:	8d 42 f8             	lea    -0x8(%edx),%eax
  8025e2:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8025e7:	0f 86 14 04 00 00    	jbe    802a01 <spawn+0x543>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8025ed:	83 ec 04             	sub    $0x4,%esp
  8025f0:	6a 07                	push   $0x7
  8025f2:	68 00 00 40 00       	push   $0x400000
  8025f7:	6a 00                	push   $0x0
  8025f9:	e8 0c f0 ff ff       	call   80160a <sys_page_alloc>
  8025fe:	83 c4 10             	add    $0x10,%esp
  802601:	85 c0                	test   %eax,%eax
  802603:	0f 88 fd 03 00 00    	js     802a06 <spawn+0x548>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802609:	be 00 00 00 00       	mov    $0x0,%esi
  80260e:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802614:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802617:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  80261d:	7e 32                	jle    802651 <spawn+0x193>
		argv_store[i] = UTEMP2USTACK(string_store);
  80261f:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802625:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80262b:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80262e:	83 ec 08             	sub    $0x8,%esp
  802631:	ff 34 b3             	push   (%ebx,%esi,4)
  802634:	57                   	push   %edi
  802635:	e8 d4 eb ff ff       	call   80120e <strcpy>
		string_store += strlen(argv[i]) + 1;
  80263a:	83 c4 04             	add    $0x4,%esp
  80263d:	ff 34 b3             	push   (%ebx,%esi,4)
  802640:	e8 8e eb ff ff       	call   8011d3 <strlen>
  802645:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  802649:	83 c6 01             	add    $0x1,%esi
  80264c:	83 c4 10             	add    $0x10,%esp
  80264f:	eb c6                	jmp    802617 <spawn+0x159>
	}
	argv_store[argc] = 0;
  802651:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802657:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  80265d:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802664:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80266a:	0f 85 8c 00 00 00    	jne    8026fc <spawn+0x23e>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802670:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802676:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  80267c:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  80267f:	89 c8                	mov    %ecx,%eax
  802681:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  802687:	89 79 f8             	mov    %edi,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80268a:	2d 08 30 80 11       	sub    $0x11803008,%eax
  80268f:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802695:	83 ec 0c             	sub    $0xc,%esp
  802698:	6a 07                	push   $0x7
  80269a:	68 00 d0 bf ee       	push   $0xeebfd000
  80269f:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  8026a5:	68 00 00 40 00       	push   $0x400000
  8026aa:	6a 00                	push   $0x0
  8026ac:	e8 9c ef ff ff       	call   80164d <sys_page_map>
  8026b1:	89 c3                	mov    %eax,%ebx
  8026b3:	83 c4 20             	add    $0x20,%esp
  8026b6:	85 c0                	test   %eax,%eax
  8026b8:	0f 88 50 03 00 00    	js     802a0e <spawn+0x550>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8026be:	83 ec 08             	sub    $0x8,%esp
  8026c1:	68 00 00 40 00       	push   $0x400000
  8026c6:	6a 00                	push   $0x0
  8026c8:	e8 c2 ef ff ff       	call   80168f <sys_page_unmap>
  8026cd:	89 c3                	mov    %eax,%ebx
  8026cf:	83 c4 10             	add    $0x10,%esp
  8026d2:	85 c0                	test   %eax,%eax
  8026d4:	0f 88 34 03 00 00    	js     802a0e <spawn+0x550>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8026da:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8026e0:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8026e7:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8026ed:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8026f4:	00 00 00 
  8026f7:	e9 4e 01 00 00       	jmp    80284a <spawn+0x38c>
	assert(string_store == (char*)UTEMP + PGSIZE);
  8026fc:	68 fc 39 80 00       	push   $0x8039fc
  802701:	68 c6 33 80 00       	push   $0x8033c6
  802706:	68 f2 00 00 00       	push   $0xf2
  80270b:	68 8c 39 80 00       	push   $0x80398c
  802710:	e8 54 e3 ff ff       	call   800a69 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802715:	83 ec 04             	sub    $0x4,%esp
  802718:	6a 07                	push   $0x7
  80271a:	68 00 00 40 00       	push   $0x400000
  80271f:	6a 00                	push   $0x0
  802721:	e8 e4 ee ff ff       	call   80160a <sys_page_alloc>
  802726:	83 c4 10             	add    $0x10,%esp
  802729:	85 c0                	test   %eax,%eax
  80272b:	0f 88 6c 02 00 00    	js     80299d <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802731:	83 ec 08             	sub    $0x8,%esp
  802734:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80273a:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  802740:	50                   	push   %eax
  802741:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  802747:	e8 a7 f8 ff ff       	call   801ff3 <seek>
  80274c:	83 c4 10             	add    $0x10,%esp
  80274f:	85 c0                	test   %eax,%eax
  802751:	0f 88 4d 02 00 00    	js     8029a4 <spawn+0x4e6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802757:	83 ec 04             	sub    $0x4,%esp
  80275a:	89 f8                	mov    %edi,%eax
  80275c:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  802762:	ba 00 10 00 00       	mov    $0x1000,%edx
  802767:	39 d0                	cmp    %edx,%eax
  802769:	0f 47 c2             	cmova  %edx,%eax
  80276c:	50                   	push   %eax
  80276d:	68 00 00 40 00       	push   $0x400000
  802772:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  802778:	e8 ad f7 ff ff       	call   801f2a <readn>
  80277d:	83 c4 10             	add    $0x10,%esp
  802780:	85 c0                	test   %eax,%eax
  802782:	0f 88 23 02 00 00    	js     8029ab <spawn+0x4ed>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802788:	83 ec 0c             	sub    $0xc,%esp
  80278b:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  802791:	56                   	push   %esi
  802792:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  802798:	68 00 00 40 00       	push   $0x400000
  80279d:	6a 00                	push   $0x0
  80279f:	e8 a9 ee ff ff       	call   80164d <sys_page_map>
  8027a4:	83 c4 20             	add    $0x20,%esp
  8027a7:	85 c0                	test   %eax,%eax
  8027a9:	78 7c                	js     802827 <spawn+0x369>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  8027ab:	83 ec 08             	sub    $0x8,%esp
  8027ae:	68 00 00 40 00       	push   $0x400000
  8027b3:	6a 00                	push   $0x0
  8027b5:	e8 d5 ee ff ff       	call   80168f <sys_page_unmap>
  8027ba:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  8027bd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8027c3:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8027c9:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8027cf:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  8027d5:	76 65                	jbe    80283c <spawn+0x37e>
		if (i >= filesz) {
  8027d7:	39 df                	cmp    %ebx,%edi
  8027d9:	0f 87 36 ff ff ff    	ja     802715 <spawn+0x257>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8027df:	83 ec 04             	sub    $0x4,%esp
  8027e2:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  8027e8:	56                   	push   %esi
  8027e9:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  8027ef:	e8 16 ee ff ff       	call   80160a <sys_page_alloc>
  8027f4:	83 c4 10             	add    $0x10,%esp
  8027f7:	85 c0                	test   %eax,%eax
  8027f9:	79 c2                	jns    8027bd <spawn+0x2ff>
  8027fb:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  8027fd:	83 ec 0c             	sub    $0xc,%esp
  802800:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  802806:	e8 80 ed ff ff       	call   80158b <sys_env_destroy>
	close(fd);
  80280b:	83 c4 04             	add    $0x4,%esp
  80280e:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  802814:	e8 4e f5 ff ff       	call   801d67 <close>
	return r;
  802819:	83 c4 10             	add    $0x10,%esp
  80281c:	89 bd 8c fd ff ff    	mov    %edi,-0x274(%ebp)
  802822:	e9 68 01 00 00       	jmp    80298f <spawn+0x4d1>
				panic("spawn: sys_page_map data: %e", r);
  802827:	50                   	push   %eax
  802828:	68 98 39 80 00       	push   $0x803998
  80282d:	68 25 01 00 00       	push   $0x125
  802832:	68 8c 39 80 00       	push   $0x80398c
  802837:	e8 2d e2 ff ff       	call   800a69 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80283c:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  802843:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  80284a:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802851:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  802857:	7e 67                	jle    8028c0 <spawn+0x402>
		if (ph->p_type != ELF_PROG_LOAD)
  802859:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  80285f:	83 39 01             	cmpl   $0x1,(%ecx)
  802862:	75 d8                	jne    80283c <spawn+0x37e>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802864:	8b 41 18             	mov    0x18(%ecx),%eax
  802867:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80286d:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802870:	83 f8 01             	cmp    $0x1,%eax
  802873:	19 c0                	sbb    %eax,%eax
  802875:	83 e0 fe             	and    $0xfffffffe,%eax
  802878:	83 c0 07             	add    $0x7,%eax
  80287b:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802881:	8b 51 04             	mov    0x4(%ecx),%edx
  802884:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  80288a:	8b 79 10             	mov    0x10(%ecx),%edi
  80288d:	8b 59 14             	mov    0x14(%ecx),%ebx
  802890:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802896:	8b 71 08             	mov    0x8(%ecx),%esi
	if ((i = PGOFF(va))) {
  802899:	89 f0                	mov    %esi,%eax
  80289b:	25 ff 0f 00 00       	and    $0xfff,%eax
  8028a0:	74 14                	je     8028b6 <spawn+0x3f8>
		va -= i;
  8028a2:	29 c6                	sub    %eax,%esi
		memsz += i;
  8028a4:	01 c3                	add    %eax,%ebx
  8028a6:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  8028ac:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8028ae:	29 c2                	sub    %eax,%edx
  8028b0:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  8028b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8028bb:	e9 09 ff ff ff       	jmp    8027c9 <spawn+0x30b>
	close(fd);
  8028c0:	83 ec 0c             	sub    $0xc,%esp
  8028c3:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  8028c9:	e8 99 f4 ff ff       	call   801d67 <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	envid_t this_envid = sys_getenvid();//父进程号
  8028ce:	e8 f9 ec ff ff       	call   8015cc <sys_getenvid>
  8028d3:	89 c6                	mov    %eax,%esi
  8028d5:	83 c4 10             	add    $0x10,%esp
	
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  8028d8:	bb 00 00 80 00       	mov    $0x800000,%ebx
  8028dd:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  8028e3:	eb 12                	jmp    8028f7 <spawn+0x439>
  8028e5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8028eb:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8028f1:	0f 84 bb 00 00 00    	je     8029b2 <spawn+0x4f4>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE ) ) {
  8028f7:	89 d8                	mov    %ebx,%eax
  8028f9:	c1 e8 16             	shr    $0x16,%eax
  8028fc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802903:	a8 01                	test   $0x1,%al
  802905:	74 de                	je     8028e5 <spawn+0x427>
  802907:	89 d8                	mov    %ebx,%eax
  802909:	c1 e8 0c             	shr    $0xc,%eax
  80290c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802913:	f6 c2 01             	test   $0x1,%dl
  802916:	74 cd                	je     8028e5 <spawn+0x427>
  802918:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80291f:	f6 c6 04             	test   $0x4,%dh
  802922:	74 c1                	je     8028e5 <spawn+0x427>
			//Copy the mappings
			if( (r=sys_page_map(this_envid , (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL ) )< 0 ) 
  802924:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80292b:	83 ec 0c             	sub    $0xc,%esp
  80292e:	25 07 0e 00 00       	and    $0xe07,%eax
  802933:	50                   	push   %eax
  802934:	53                   	push   %ebx
  802935:	57                   	push   %edi
  802936:	53                   	push   %ebx
  802937:	56                   	push   %esi
  802938:	e8 10 ed ff ff       	call   80164d <sys_page_map>
  80293d:	83 c4 20             	add    $0x20,%esp
  802940:	85 c0                	test   %eax,%eax
  802942:	79 a1                	jns    8028e5 <spawn+0x427>
		panic("copy_shared_pages: %e", r);
  802944:	50                   	push   %eax
  802945:	68 e6 39 80 00       	push   $0x8039e6
  80294a:	68 82 00 00 00       	push   $0x82
  80294f:	68 8c 39 80 00       	push   $0x80398c
  802954:	e8 10 e1 ff ff       	call   800a69 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  802959:	50                   	push   %eax
  80295a:	68 b5 39 80 00       	push   $0x8039b5
  80295f:	68 86 00 00 00       	push   $0x86
  802964:	68 8c 39 80 00       	push   $0x80398c
  802969:	e8 fb e0 ff ff       	call   800a69 <_panic>
		panic("sys_env_set_status: %e", r);
  80296e:	50                   	push   %eax
  80296f:	68 cf 39 80 00       	push   $0x8039cf
  802974:	68 89 00 00 00       	push   $0x89
  802979:	68 8c 39 80 00       	push   $0x80398c
  80297e:	e8 e6 e0 ff ff       	call   800a69 <_panic>
		return r;
  802983:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802989:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
}
  80298f:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802995:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802998:	5b                   	pop    %ebx
  802999:	5e                   	pop    %esi
  80299a:	5f                   	pop    %edi
  80299b:	5d                   	pop    %ebp
  80299c:	c3                   	ret    
  80299d:	89 c7                	mov    %eax,%edi
  80299f:	e9 59 fe ff ff       	jmp    8027fd <spawn+0x33f>
  8029a4:	89 c7                	mov    %eax,%edi
  8029a6:	e9 52 fe ff ff       	jmp    8027fd <spawn+0x33f>
  8029ab:	89 c7                	mov    %eax,%edi
  8029ad:	e9 4b fe ff ff       	jmp    8027fd <spawn+0x33f>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8029b2:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8029b9:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8029bc:	83 ec 08             	sub    $0x8,%esp
  8029bf:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8029c5:	50                   	push   %eax
  8029c6:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  8029cc:	e8 42 ed ff ff       	call   801713 <sys_env_set_trapframe>
  8029d1:	83 c4 10             	add    $0x10,%esp
  8029d4:	85 c0                	test   %eax,%eax
  8029d6:	78 81                	js     802959 <spawn+0x49b>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8029d8:	83 ec 08             	sub    $0x8,%esp
  8029db:	6a 02                	push   $0x2
  8029dd:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  8029e3:	e8 e9 ec ff ff       	call   8016d1 <sys_env_set_status>
  8029e8:	83 c4 10             	add    $0x10,%esp
  8029eb:	85 c0                	test   %eax,%eax
  8029ed:	0f 88 7b ff ff ff    	js     80296e <spawn+0x4b0>
	return child;
  8029f3:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8029f9:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8029ff:	eb 8e                	jmp    80298f <spawn+0x4d1>
		return -E_NO_MEM;
  802a01:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  802a06:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802a0c:	eb 81                	jmp    80298f <spawn+0x4d1>
	sys_page_unmap(0, UTEMP);
  802a0e:	83 ec 08             	sub    $0x8,%esp
  802a11:	68 00 00 40 00       	push   $0x400000
  802a16:	6a 00                	push   $0x0
  802a18:	e8 72 ec ff ff       	call   80168f <sys_page_unmap>
  802a1d:	83 c4 10             	add    $0x10,%esp
  802a20:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  802a26:	e9 64 ff ff ff       	jmp    80298f <spawn+0x4d1>

00802a2b <spawnl>:
{
  802a2b:	55                   	push   %ebp
  802a2c:	89 e5                	mov    %esp,%ebp
  802a2e:	56                   	push   %esi
  802a2f:	53                   	push   %ebx
	va_start(vl, arg0);
  802a30:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  802a33:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  802a38:	eb 05                	jmp    802a3f <spawnl+0x14>
		argc++;
  802a3a:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  802a3d:	89 ca                	mov    %ecx,%edx
  802a3f:	8d 4a 04             	lea    0x4(%edx),%ecx
  802a42:	83 3a 00             	cmpl   $0x0,(%edx)
  802a45:	75 f3                	jne    802a3a <spawnl+0xf>
	const char *argv[argc+2];
  802a47:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  802a4e:	89 d3                	mov    %edx,%ebx
  802a50:	83 e3 f0             	and    $0xfffffff0,%ebx
  802a53:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  802a59:	89 e1                	mov    %esp,%ecx
  802a5b:	29 d1                	sub    %edx,%ecx
  802a5d:	39 cc                	cmp    %ecx,%esp
  802a5f:	74 10                	je     802a71 <spawnl+0x46>
  802a61:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  802a67:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  802a6e:	00 
  802a6f:	eb ec                	jmp    802a5d <spawnl+0x32>
  802a71:	89 da                	mov    %ebx,%edx
  802a73:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  802a79:	29 d4                	sub    %edx,%esp
  802a7b:	85 d2                	test   %edx,%edx
  802a7d:	74 05                	je     802a84 <spawnl+0x59>
  802a7f:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  802a84:	8d 5c 24 03          	lea    0x3(%esp),%ebx
  802a88:	89 da                	mov    %ebx,%edx
  802a8a:	c1 ea 02             	shr    $0x2,%edx
  802a8d:	83 e3 fc             	and    $0xfffffffc,%ebx
	argv[0] = arg0;
  802a90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a93:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802a9a:	c7 44 83 04 00 00 00 	movl   $0x0,0x4(%ebx,%eax,4)
  802aa1:	00 
	va_start(vl, arg0);
  802aa2:	8d 4d 10             	lea    0x10(%ebp),%ecx
  802aa5:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  802aa7:	b8 00 00 00 00       	mov    $0x0,%eax
  802aac:	eb 0b                	jmp    802ab9 <spawnl+0x8e>
		argv[i+1] = va_arg(vl, const char *);
  802aae:	83 c0 01             	add    $0x1,%eax
  802ab1:	8b 31                	mov    (%ecx),%esi
  802ab3:	89 34 83             	mov    %esi,(%ebx,%eax,4)
  802ab6:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  802ab9:	39 d0                	cmp    %edx,%eax
  802abb:	75 f1                	jne    802aae <spawnl+0x83>
	return spawn(prog, argv);
  802abd:	83 ec 08             	sub    $0x8,%esp
  802ac0:	53                   	push   %ebx
  802ac1:	ff 75 08             	push   0x8(%ebp)
  802ac4:	e8 f5 f9 ff ff       	call   8024be <spawn>
}
  802ac9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802acc:	5b                   	pop    %ebx
  802acd:	5e                   	pop    %esi
  802ace:	5d                   	pop    %ebp
  802acf:	c3                   	ret    

00802ad0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802ad0:	55                   	push   %ebp
  802ad1:	89 e5                	mov    %esp,%ebp
  802ad3:	56                   	push   %esi
  802ad4:	53                   	push   %ebx
  802ad5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802ad8:	83 ec 0c             	sub    $0xc,%esp
  802adb:	ff 75 08             	push   0x8(%ebp)
  802ade:	e8 f5 f0 ff ff       	call   801bd8 <fd2data>
  802ae3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802ae5:	83 c4 08             	add    $0x8,%esp
  802ae8:	68 22 3a 80 00       	push   $0x803a22
  802aed:	53                   	push   %ebx
  802aee:	e8 1b e7 ff ff       	call   80120e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802af3:	8b 46 04             	mov    0x4(%esi),%eax
  802af6:	2b 06                	sub    (%esi),%eax
  802af8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802afe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802b05:	00 00 00 
	stat->st_dev = &devpipe;
  802b08:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802b0f:	40 80 00 
	return 0;
}
  802b12:	b8 00 00 00 00       	mov    $0x0,%eax
  802b17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b1a:	5b                   	pop    %ebx
  802b1b:	5e                   	pop    %esi
  802b1c:	5d                   	pop    %ebp
  802b1d:	c3                   	ret    

00802b1e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802b1e:	55                   	push   %ebp
  802b1f:	89 e5                	mov    %esp,%ebp
  802b21:	53                   	push   %ebx
  802b22:	83 ec 0c             	sub    $0xc,%esp
  802b25:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802b28:	53                   	push   %ebx
  802b29:	6a 00                	push   $0x0
  802b2b:	e8 5f eb ff ff       	call   80168f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802b30:	89 1c 24             	mov    %ebx,(%esp)
  802b33:	e8 a0 f0 ff ff       	call   801bd8 <fd2data>
  802b38:	83 c4 08             	add    $0x8,%esp
  802b3b:	50                   	push   %eax
  802b3c:	6a 00                	push   $0x0
  802b3e:	e8 4c eb ff ff       	call   80168f <sys_page_unmap>
}
  802b43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b46:	c9                   	leave  
  802b47:	c3                   	ret    

00802b48 <_pipeisclosed>:
{
  802b48:	55                   	push   %ebp
  802b49:	89 e5                	mov    %esp,%ebp
  802b4b:	57                   	push   %edi
  802b4c:	56                   	push   %esi
  802b4d:	53                   	push   %ebx
  802b4e:	83 ec 1c             	sub    $0x1c,%esp
  802b51:	89 c7                	mov    %eax,%edi
  802b53:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802b55:	a1 14 50 80 00       	mov    0x805014,%eax
  802b5a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802b5d:	83 ec 0c             	sub    $0xc,%esp
  802b60:	57                   	push   %edi
  802b61:	e8 93 04 00 00       	call   802ff9 <pageref>
  802b66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802b69:	89 34 24             	mov    %esi,(%esp)
  802b6c:	e8 88 04 00 00       	call   802ff9 <pageref>
		nn = thisenv->env_runs;
  802b71:	8b 15 14 50 80 00    	mov    0x805014,%edx
  802b77:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802b7a:	83 c4 10             	add    $0x10,%esp
  802b7d:	39 cb                	cmp    %ecx,%ebx
  802b7f:	74 1b                	je     802b9c <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802b81:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802b84:	75 cf                	jne    802b55 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802b86:	8b 42 58             	mov    0x58(%edx),%eax
  802b89:	6a 01                	push   $0x1
  802b8b:	50                   	push   %eax
  802b8c:	53                   	push   %ebx
  802b8d:	68 29 3a 80 00       	push   $0x803a29
  802b92:	e8 ad df ff ff       	call   800b44 <cprintf>
  802b97:	83 c4 10             	add    $0x10,%esp
  802b9a:	eb b9                	jmp    802b55 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802b9c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802b9f:	0f 94 c0             	sete   %al
  802ba2:	0f b6 c0             	movzbl %al,%eax
}
  802ba5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ba8:	5b                   	pop    %ebx
  802ba9:	5e                   	pop    %esi
  802baa:	5f                   	pop    %edi
  802bab:	5d                   	pop    %ebp
  802bac:	c3                   	ret    

00802bad <devpipe_write>:
{
  802bad:	55                   	push   %ebp
  802bae:	89 e5                	mov    %esp,%ebp
  802bb0:	57                   	push   %edi
  802bb1:	56                   	push   %esi
  802bb2:	53                   	push   %ebx
  802bb3:	83 ec 28             	sub    $0x28,%esp
  802bb6:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802bb9:	56                   	push   %esi
  802bba:	e8 19 f0 ff ff       	call   801bd8 <fd2data>
  802bbf:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802bc1:	83 c4 10             	add    $0x10,%esp
  802bc4:	bf 00 00 00 00       	mov    $0x0,%edi
  802bc9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802bcc:	75 09                	jne    802bd7 <devpipe_write+0x2a>
	return i;
  802bce:	89 f8                	mov    %edi,%eax
  802bd0:	eb 23                	jmp    802bf5 <devpipe_write+0x48>
			sys_yield();
  802bd2:	e8 14 ea ff ff       	call   8015eb <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802bd7:	8b 43 04             	mov    0x4(%ebx),%eax
  802bda:	8b 0b                	mov    (%ebx),%ecx
  802bdc:	8d 51 20             	lea    0x20(%ecx),%edx
  802bdf:	39 d0                	cmp    %edx,%eax
  802be1:	72 1a                	jb     802bfd <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  802be3:	89 da                	mov    %ebx,%edx
  802be5:	89 f0                	mov    %esi,%eax
  802be7:	e8 5c ff ff ff       	call   802b48 <_pipeisclosed>
  802bec:	85 c0                	test   %eax,%eax
  802bee:	74 e2                	je     802bd2 <devpipe_write+0x25>
				return 0;
  802bf0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802bf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802bf8:	5b                   	pop    %ebx
  802bf9:	5e                   	pop    %esi
  802bfa:	5f                   	pop    %edi
  802bfb:	5d                   	pop    %ebp
  802bfc:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c00:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802c04:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802c07:	89 c2                	mov    %eax,%edx
  802c09:	c1 fa 1f             	sar    $0x1f,%edx
  802c0c:	89 d1                	mov    %edx,%ecx
  802c0e:	c1 e9 1b             	shr    $0x1b,%ecx
  802c11:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802c14:	83 e2 1f             	and    $0x1f,%edx
  802c17:	29 ca                	sub    %ecx,%edx
  802c19:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802c1d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802c21:	83 c0 01             	add    $0x1,%eax
  802c24:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802c27:	83 c7 01             	add    $0x1,%edi
  802c2a:	eb 9d                	jmp    802bc9 <devpipe_write+0x1c>

00802c2c <devpipe_read>:
{
  802c2c:	55                   	push   %ebp
  802c2d:	89 e5                	mov    %esp,%ebp
  802c2f:	57                   	push   %edi
  802c30:	56                   	push   %esi
  802c31:	53                   	push   %ebx
  802c32:	83 ec 18             	sub    $0x18,%esp
  802c35:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802c38:	57                   	push   %edi
  802c39:	e8 9a ef ff ff       	call   801bd8 <fd2data>
  802c3e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802c40:	83 c4 10             	add    $0x10,%esp
  802c43:	be 00 00 00 00       	mov    $0x0,%esi
  802c48:	3b 75 10             	cmp    0x10(%ebp),%esi
  802c4b:	75 13                	jne    802c60 <devpipe_read+0x34>
	return i;
  802c4d:	89 f0                	mov    %esi,%eax
  802c4f:	eb 02                	jmp    802c53 <devpipe_read+0x27>
				return i;
  802c51:	89 f0                	mov    %esi,%eax
}
  802c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c56:	5b                   	pop    %ebx
  802c57:	5e                   	pop    %esi
  802c58:	5f                   	pop    %edi
  802c59:	5d                   	pop    %ebp
  802c5a:	c3                   	ret    
			sys_yield();
  802c5b:	e8 8b e9 ff ff       	call   8015eb <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802c60:	8b 03                	mov    (%ebx),%eax
  802c62:	3b 43 04             	cmp    0x4(%ebx),%eax
  802c65:	75 18                	jne    802c7f <devpipe_read+0x53>
			if (i > 0)
  802c67:	85 f6                	test   %esi,%esi
  802c69:	75 e6                	jne    802c51 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  802c6b:	89 da                	mov    %ebx,%edx
  802c6d:	89 f8                	mov    %edi,%eax
  802c6f:	e8 d4 fe ff ff       	call   802b48 <_pipeisclosed>
  802c74:	85 c0                	test   %eax,%eax
  802c76:	74 e3                	je     802c5b <devpipe_read+0x2f>
				return 0;
  802c78:	b8 00 00 00 00       	mov    $0x0,%eax
  802c7d:	eb d4                	jmp    802c53 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802c7f:	99                   	cltd   
  802c80:	c1 ea 1b             	shr    $0x1b,%edx
  802c83:	01 d0                	add    %edx,%eax
  802c85:	83 e0 1f             	and    $0x1f,%eax
  802c88:	29 d0                	sub    %edx,%eax
  802c8a:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802c8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c92:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802c95:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802c98:	83 c6 01             	add    $0x1,%esi
  802c9b:	eb ab                	jmp    802c48 <devpipe_read+0x1c>

00802c9d <pipe>:
{
  802c9d:	55                   	push   %ebp
  802c9e:	89 e5                	mov    %esp,%ebp
  802ca0:	56                   	push   %esi
  802ca1:	53                   	push   %ebx
  802ca2:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802ca5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ca8:	50                   	push   %eax
  802ca9:	e8 41 ef ff ff       	call   801bef <fd_alloc>
  802cae:	89 c3                	mov    %eax,%ebx
  802cb0:	83 c4 10             	add    $0x10,%esp
  802cb3:	85 c0                	test   %eax,%eax
  802cb5:	0f 88 23 01 00 00    	js     802dde <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802cbb:	83 ec 04             	sub    $0x4,%esp
  802cbe:	68 07 04 00 00       	push   $0x407
  802cc3:	ff 75 f4             	push   -0xc(%ebp)
  802cc6:	6a 00                	push   $0x0
  802cc8:	e8 3d e9 ff ff       	call   80160a <sys_page_alloc>
  802ccd:	89 c3                	mov    %eax,%ebx
  802ccf:	83 c4 10             	add    $0x10,%esp
  802cd2:	85 c0                	test   %eax,%eax
  802cd4:	0f 88 04 01 00 00    	js     802dde <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802cda:	83 ec 0c             	sub    $0xc,%esp
  802cdd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802ce0:	50                   	push   %eax
  802ce1:	e8 09 ef ff ff       	call   801bef <fd_alloc>
  802ce6:	89 c3                	mov    %eax,%ebx
  802ce8:	83 c4 10             	add    $0x10,%esp
  802ceb:	85 c0                	test   %eax,%eax
  802ced:	0f 88 db 00 00 00    	js     802dce <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802cf3:	83 ec 04             	sub    $0x4,%esp
  802cf6:	68 07 04 00 00       	push   $0x407
  802cfb:	ff 75 f0             	push   -0x10(%ebp)
  802cfe:	6a 00                	push   $0x0
  802d00:	e8 05 e9 ff ff       	call   80160a <sys_page_alloc>
  802d05:	89 c3                	mov    %eax,%ebx
  802d07:	83 c4 10             	add    $0x10,%esp
  802d0a:	85 c0                	test   %eax,%eax
  802d0c:	0f 88 bc 00 00 00    	js     802dce <pipe+0x131>
	va = fd2data(fd0);
  802d12:	83 ec 0c             	sub    $0xc,%esp
  802d15:	ff 75 f4             	push   -0xc(%ebp)
  802d18:	e8 bb ee ff ff       	call   801bd8 <fd2data>
  802d1d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d1f:	83 c4 0c             	add    $0xc,%esp
  802d22:	68 07 04 00 00       	push   $0x407
  802d27:	50                   	push   %eax
  802d28:	6a 00                	push   $0x0
  802d2a:	e8 db e8 ff ff       	call   80160a <sys_page_alloc>
  802d2f:	89 c3                	mov    %eax,%ebx
  802d31:	83 c4 10             	add    $0x10,%esp
  802d34:	85 c0                	test   %eax,%eax
  802d36:	0f 88 82 00 00 00    	js     802dbe <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d3c:	83 ec 0c             	sub    $0xc,%esp
  802d3f:	ff 75 f0             	push   -0x10(%ebp)
  802d42:	e8 91 ee ff ff       	call   801bd8 <fd2data>
  802d47:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802d4e:	50                   	push   %eax
  802d4f:	6a 00                	push   $0x0
  802d51:	56                   	push   %esi
  802d52:	6a 00                	push   $0x0
  802d54:	e8 f4 e8 ff ff       	call   80164d <sys_page_map>
  802d59:	89 c3                	mov    %eax,%ebx
  802d5b:	83 c4 20             	add    $0x20,%esp
  802d5e:	85 c0                	test   %eax,%eax
  802d60:	78 4e                	js     802db0 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  802d62:	a1 3c 40 80 00       	mov    0x80403c,%eax
  802d67:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d6a:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802d6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d6f:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802d76:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802d79:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802d7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d7e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802d85:	83 ec 0c             	sub    $0xc,%esp
  802d88:	ff 75 f4             	push   -0xc(%ebp)
  802d8b:	e8 38 ee ff ff       	call   801bc8 <fd2num>
  802d90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d93:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802d95:	83 c4 04             	add    $0x4,%esp
  802d98:	ff 75 f0             	push   -0x10(%ebp)
  802d9b:	e8 28 ee ff ff       	call   801bc8 <fd2num>
  802da0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802da3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802da6:	83 c4 10             	add    $0x10,%esp
  802da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  802dae:	eb 2e                	jmp    802dde <pipe+0x141>
	sys_page_unmap(0, va);
  802db0:	83 ec 08             	sub    $0x8,%esp
  802db3:	56                   	push   %esi
  802db4:	6a 00                	push   $0x0
  802db6:	e8 d4 e8 ff ff       	call   80168f <sys_page_unmap>
  802dbb:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802dbe:	83 ec 08             	sub    $0x8,%esp
  802dc1:	ff 75 f0             	push   -0x10(%ebp)
  802dc4:	6a 00                	push   $0x0
  802dc6:	e8 c4 e8 ff ff       	call   80168f <sys_page_unmap>
  802dcb:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802dce:	83 ec 08             	sub    $0x8,%esp
  802dd1:	ff 75 f4             	push   -0xc(%ebp)
  802dd4:	6a 00                	push   $0x0
  802dd6:	e8 b4 e8 ff ff       	call   80168f <sys_page_unmap>
  802ddb:	83 c4 10             	add    $0x10,%esp
}
  802dde:	89 d8                	mov    %ebx,%eax
  802de0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802de3:	5b                   	pop    %ebx
  802de4:	5e                   	pop    %esi
  802de5:	5d                   	pop    %ebp
  802de6:	c3                   	ret    

00802de7 <pipeisclosed>:
{
  802de7:	55                   	push   %ebp
  802de8:	89 e5                	mov    %esp,%ebp
  802dea:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802ded:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802df0:	50                   	push   %eax
  802df1:	ff 75 08             	push   0x8(%ebp)
  802df4:	e8 46 ee ff ff       	call   801c3f <fd_lookup>
  802df9:	83 c4 10             	add    $0x10,%esp
  802dfc:	85 c0                	test   %eax,%eax
  802dfe:	78 18                	js     802e18 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802e00:	83 ec 0c             	sub    $0xc,%esp
  802e03:	ff 75 f4             	push   -0xc(%ebp)
  802e06:	e8 cd ed ff ff       	call   801bd8 <fd2data>
  802e0b:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e10:	e8 33 fd ff ff       	call   802b48 <_pipeisclosed>
  802e15:	83 c4 10             	add    $0x10,%esp
}
  802e18:	c9                   	leave  
  802e19:	c3                   	ret    

00802e1a <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802e1a:	55                   	push   %ebp
  802e1b:	89 e5                	mov    %esp,%ebp
  802e1d:	56                   	push   %esi
  802e1e:	53                   	push   %ebx
  802e1f:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802e22:	85 f6                	test   %esi,%esi
  802e24:	74 13                	je     802e39 <wait+0x1f>
	e = &envs[ENVX(envid)];
  802e26:	89 f3                	mov    %esi,%ebx
  802e28:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e2e:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802e31:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802e37:	eb 1b                	jmp    802e54 <wait+0x3a>
	assert(envid != 0);
  802e39:	68 41 3a 80 00       	push   $0x803a41
  802e3e:	68 c6 33 80 00       	push   $0x8033c6
  802e43:	6a 09                	push   $0x9
  802e45:	68 4c 3a 80 00       	push   $0x803a4c
  802e4a:	e8 1a dc ff ff       	call   800a69 <_panic>
		sys_yield();
  802e4f:	e8 97 e7 ff ff       	call   8015eb <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e54:	8b 43 48             	mov    0x48(%ebx),%eax
  802e57:	39 f0                	cmp    %esi,%eax
  802e59:	75 07                	jne    802e62 <wait+0x48>
  802e5b:	8b 43 54             	mov    0x54(%ebx),%eax
  802e5e:	85 c0                	test   %eax,%eax
  802e60:	75 ed                	jne    802e4f <wait+0x35>
}
  802e62:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e65:	5b                   	pop    %ebx
  802e66:	5e                   	pop    %esi
  802e67:	5d                   	pop    %ebp
  802e68:	c3                   	ret    

00802e69 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802e69:	55                   	push   %ebp
  802e6a:	89 e5                	mov    %esp,%ebp
  802e6c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  802e6f:	83 3d 04 70 80 00 00 	cmpl   $0x0,0x807004
  802e76:	74 0a                	je     802e82 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802e78:	8b 45 08             	mov    0x8(%ebp),%eax
  802e7b:	a3 04 70 80 00       	mov    %eax,0x807004
}
  802e80:	c9                   	leave  
  802e81:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  802e82:	e8 45 e7 ff ff       	call   8015cc <sys_getenvid>
  802e87:	83 ec 04             	sub    $0x4,%esp
  802e8a:	68 07 0e 00 00       	push   $0xe07
  802e8f:	68 00 f0 bf ee       	push   $0xeebff000
  802e94:	50                   	push   %eax
  802e95:	e8 70 e7 ff ff       	call   80160a <sys_page_alloc>
		if (r < 0) {
  802e9a:	83 c4 10             	add    $0x10,%esp
  802e9d:	85 c0                	test   %eax,%eax
  802e9f:	78 2c                	js     802ecd <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802ea1:	e8 26 e7 ff ff       	call   8015cc <sys_getenvid>
  802ea6:	83 ec 08             	sub    $0x8,%esp
  802ea9:	68 df 2e 80 00       	push   $0x802edf
  802eae:	50                   	push   %eax
  802eaf:	e8 a1 e8 ff ff       	call   801755 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802eb4:	83 c4 10             	add    $0x10,%esp
  802eb7:	85 c0                	test   %eax,%eax
  802eb9:	79 bd                	jns    802e78 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  802ebb:	50                   	push   %eax
  802ebc:	68 98 3a 80 00       	push   $0x803a98
  802ec1:	6a 28                	push   $0x28
  802ec3:	68 ce 3a 80 00       	push   $0x803ace
  802ec8:	e8 9c db ff ff       	call   800a69 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802ecd:	50                   	push   %eax
  802ece:	68 58 3a 80 00       	push   $0x803a58
  802ed3:	6a 23                	push   $0x23
  802ed5:	68 ce 3a 80 00       	push   $0x803ace
  802eda:	e8 8a db ff ff       	call   800a69 <_panic>

00802edf <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802edf:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802ee0:	a1 04 70 80 00       	mov    0x807004,%eax
	call *%eax
  802ee5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802ee7:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802eea:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802eee:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802ef1:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802ef5:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802ef9:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  802efb:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802efe:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  802eff:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  802f02:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  802f03:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  802f04:	c3                   	ret    

00802f05 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802f05:	55                   	push   %ebp
  802f06:	89 e5                	mov    %esp,%ebp
  802f08:	56                   	push   %esi
  802f09:	53                   	push   %ebx
  802f0a:	8b 75 08             	mov    0x8(%ebp),%esi
  802f0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  802f13:	85 c0                	test   %eax,%eax
  802f15:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802f1a:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802f1d:	83 ec 0c             	sub    $0xc,%esp
  802f20:	50                   	push   %eax
  802f21:	e8 94 e8 ff ff       	call   8017ba <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802f26:	83 c4 10             	add    $0x10,%esp
  802f29:	85 f6                	test   %esi,%esi
  802f2b:	74 14                	je     802f41 <ipc_recv+0x3c>
  802f2d:	ba 00 00 00 00       	mov    $0x0,%edx
  802f32:	85 c0                	test   %eax,%eax
  802f34:	78 09                	js     802f3f <ipc_recv+0x3a>
  802f36:	8b 15 14 50 80 00    	mov    0x805014,%edx
  802f3c:	8b 52 74             	mov    0x74(%edx),%edx
  802f3f:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802f41:	85 db                	test   %ebx,%ebx
  802f43:	74 14                	je     802f59 <ipc_recv+0x54>
  802f45:	ba 00 00 00 00       	mov    $0x0,%edx
  802f4a:	85 c0                	test   %eax,%eax
  802f4c:	78 09                	js     802f57 <ipc_recv+0x52>
  802f4e:	8b 15 14 50 80 00    	mov    0x805014,%edx
  802f54:	8b 52 78             	mov    0x78(%edx),%edx
  802f57:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802f59:	85 c0                	test   %eax,%eax
  802f5b:	78 08                	js     802f65 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  802f5d:	a1 14 50 80 00       	mov    0x805014,%eax
  802f62:	8b 40 70             	mov    0x70(%eax),%eax
}
  802f65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f68:	5b                   	pop    %ebx
  802f69:	5e                   	pop    %esi
  802f6a:	5d                   	pop    %ebp
  802f6b:	c3                   	ret    

00802f6c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802f6c:	55                   	push   %ebp
  802f6d:	89 e5                	mov    %esp,%ebp
  802f6f:	57                   	push   %edi
  802f70:	56                   	push   %esi
  802f71:	53                   	push   %ebx
  802f72:	83 ec 0c             	sub    $0xc,%esp
  802f75:	8b 7d 08             	mov    0x8(%ebp),%edi
  802f78:	8b 75 0c             	mov    0xc(%ebp),%esi
  802f7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802f7e:	85 db                	test   %ebx,%ebx
  802f80:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802f85:	0f 44 d8             	cmove  %eax,%ebx
  802f88:	eb 05                	jmp    802f8f <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802f8a:	e8 5c e6 ff ff       	call   8015eb <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802f8f:	ff 75 14             	push   0x14(%ebp)
  802f92:	53                   	push   %ebx
  802f93:	56                   	push   %esi
  802f94:	57                   	push   %edi
  802f95:	e8 fd e7 ff ff       	call   801797 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802f9a:	83 c4 10             	add    $0x10,%esp
  802f9d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802fa0:	74 e8                	je     802f8a <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802fa2:	85 c0                	test   %eax,%eax
  802fa4:	78 08                	js     802fae <ipc_send+0x42>
	}while (r<0);

}
  802fa6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802fa9:	5b                   	pop    %ebx
  802faa:	5e                   	pop    %esi
  802fab:	5f                   	pop    %edi
  802fac:	5d                   	pop    %ebp
  802fad:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802fae:	50                   	push   %eax
  802faf:	68 dc 3a 80 00       	push   $0x803adc
  802fb4:	6a 3d                	push   $0x3d
  802fb6:	68 f0 3a 80 00       	push   $0x803af0
  802fbb:	e8 a9 da ff ff       	call   800a69 <_panic>

00802fc0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802fc0:	55                   	push   %ebp
  802fc1:	89 e5                	mov    %esp,%ebp
  802fc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802fc6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802fcb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802fce:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802fd4:	8b 52 50             	mov    0x50(%edx),%edx
  802fd7:	39 ca                	cmp    %ecx,%edx
  802fd9:	74 11                	je     802fec <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802fdb:	83 c0 01             	add    $0x1,%eax
  802fde:	3d 00 04 00 00       	cmp    $0x400,%eax
  802fe3:	75 e6                	jne    802fcb <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802fe5:	b8 00 00 00 00       	mov    $0x0,%eax
  802fea:	eb 0b                	jmp    802ff7 <ipc_find_env+0x37>
			return envs[i].env_id;
  802fec:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802fef:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802ff4:	8b 40 48             	mov    0x48(%eax),%eax
}
  802ff7:	5d                   	pop    %ebp
  802ff8:	c3                   	ret    

00802ff9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802ff9:	55                   	push   %ebp
  802ffa:	89 e5                	mov    %esp,%ebp
  802ffc:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802fff:	89 c2                	mov    %eax,%edx
  803001:	c1 ea 16             	shr    $0x16,%edx
  803004:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80300b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  803010:	f6 c1 01             	test   $0x1,%cl
  803013:	74 1c                	je     803031 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  803015:	c1 e8 0c             	shr    $0xc,%eax
  803018:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80301f:	a8 01                	test   $0x1,%al
  803021:	74 0e                	je     803031 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803023:	c1 e8 0c             	shr    $0xc,%eax
  803026:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80302d:	ef 
  80302e:	0f b7 d2             	movzwl %dx,%edx
}
  803031:	89 d0                	mov    %edx,%eax
  803033:	5d                   	pop    %ebp
  803034:	c3                   	ret    
  803035:	66 90                	xchg   %ax,%ax
  803037:	66 90                	xchg   %ax,%ax
  803039:	66 90                	xchg   %ax,%ax
  80303b:	66 90                	xchg   %ax,%ax
  80303d:	66 90                	xchg   %ax,%ax
  80303f:	90                   	nop

00803040 <__udivdi3>:
  803040:	f3 0f 1e fb          	endbr32 
  803044:	55                   	push   %ebp
  803045:	57                   	push   %edi
  803046:	56                   	push   %esi
  803047:	53                   	push   %ebx
  803048:	83 ec 1c             	sub    $0x1c,%esp
  80304b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80304f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  803053:	8b 74 24 34          	mov    0x34(%esp),%esi
  803057:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80305b:	85 c0                	test   %eax,%eax
  80305d:	75 19                	jne    803078 <__udivdi3+0x38>
  80305f:	39 f3                	cmp    %esi,%ebx
  803061:	76 4d                	jbe    8030b0 <__udivdi3+0x70>
  803063:	31 ff                	xor    %edi,%edi
  803065:	89 e8                	mov    %ebp,%eax
  803067:	89 f2                	mov    %esi,%edx
  803069:	f7 f3                	div    %ebx
  80306b:	89 fa                	mov    %edi,%edx
  80306d:	83 c4 1c             	add    $0x1c,%esp
  803070:	5b                   	pop    %ebx
  803071:	5e                   	pop    %esi
  803072:	5f                   	pop    %edi
  803073:	5d                   	pop    %ebp
  803074:	c3                   	ret    
  803075:	8d 76 00             	lea    0x0(%esi),%esi
  803078:	39 f0                	cmp    %esi,%eax
  80307a:	76 14                	jbe    803090 <__udivdi3+0x50>
  80307c:	31 ff                	xor    %edi,%edi
  80307e:	31 c0                	xor    %eax,%eax
  803080:	89 fa                	mov    %edi,%edx
  803082:	83 c4 1c             	add    $0x1c,%esp
  803085:	5b                   	pop    %ebx
  803086:	5e                   	pop    %esi
  803087:	5f                   	pop    %edi
  803088:	5d                   	pop    %ebp
  803089:	c3                   	ret    
  80308a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803090:	0f bd f8             	bsr    %eax,%edi
  803093:	83 f7 1f             	xor    $0x1f,%edi
  803096:	75 48                	jne    8030e0 <__udivdi3+0xa0>
  803098:	39 f0                	cmp    %esi,%eax
  80309a:	72 06                	jb     8030a2 <__udivdi3+0x62>
  80309c:	31 c0                	xor    %eax,%eax
  80309e:	39 eb                	cmp    %ebp,%ebx
  8030a0:	77 de                	ja     803080 <__udivdi3+0x40>
  8030a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8030a7:	eb d7                	jmp    803080 <__udivdi3+0x40>
  8030a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8030b0:	89 d9                	mov    %ebx,%ecx
  8030b2:	85 db                	test   %ebx,%ebx
  8030b4:	75 0b                	jne    8030c1 <__udivdi3+0x81>
  8030b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8030bb:	31 d2                	xor    %edx,%edx
  8030bd:	f7 f3                	div    %ebx
  8030bf:	89 c1                	mov    %eax,%ecx
  8030c1:	31 d2                	xor    %edx,%edx
  8030c3:	89 f0                	mov    %esi,%eax
  8030c5:	f7 f1                	div    %ecx
  8030c7:	89 c6                	mov    %eax,%esi
  8030c9:	89 e8                	mov    %ebp,%eax
  8030cb:	89 f7                	mov    %esi,%edi
  8030cd:	f7 f1                	div    %ecx
  8030cf:	89 fa                	mov    %edi,%edx
  8030d1:	83 c4 1c             	add    $0x1c,%esp
  8030d4:	5b                   	pop    %ebx
  8030d5:	5e                   	pop    %esi
  8030d6:	5f                   	pop    %edi
  8030d7:	5d                   	pop    %ebp
  8030d8:	c3                   	ret    
  8030d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8030e0:	89 f9                	mov    %edi,%ecx
  8030e2:	ba 20 00 00 00       	mov    $0x20,%edx
  8030e7:	29 fa                	sub    %edi,%edx
  8030e9:	d3 e0                	shl    %cl,%eax
  8030eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8030ef:	89 d1                	mov    %edx,%ecx
  8030f1:	89 d8                	mov    %ebx,%eax
  8030f3:	d3 e8                	shr    %cl,%eax
  8030f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8030f9:	09 c1                	or     %eax,%ecx
  8030fb:	89 f0                	mov    %esi,%eax
  8030fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803101:	89 f9                	mov    %edi,%ecx
  803103:	d3 e3                	shl    %cl,%ebx
  803105:	89 d1                	mov    %edx,%ecx
  803107:	d3 e8                	shr    %cl,%eax
  803109:	89 f9                	mov    %edi,%ecx
  80310b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80310f:	89 eb                	mov    %ebp,%ebx
  803111:	d3 e6                	shl    %cl,%esi
  803113:	89 d1                	mov    %edx,%ecx
  803115:	d3 eb                	shr    %cl,%ebx
  803117:	09 f3                	or     %esi,%ebx
  803119:	89 c6                	mov    %eax,%esi
  80311b:	89 f2                	mov    %esi,%edx
  80311d:	89 d8                	mov    %ebx,%eax
  80311f:	f7 74 24 08          	divl   0x8(%esp)
  803123:	89 d6                	mov    %edx,%esi
  803125:	89 c3                	mov    %eax,%ebx
  803127:	f7 64 24 0c          	mull   0xc(%esp)
  80312b:	39 d6                	cmp    %edx,%esi
  80312d:	72 19                	jb     803148 <__udivdi3+0x108>
  80312f:	89 f9                	mov    %edi,%ecx
  803131:	d3 e5                	shl    %cl,%ebp
  803133:	39 c5                	cmp    %eax,%ebp
  803135:	73 04                	jae    80313b <__udivdi3+0xfb>
  803137:	39 d6                	cmp    %edx,%esi
  803139:	74 0d                	je     803148 <__udivdi3+0x108>
  80313b:	89 d8                	mov    %ebx,%eax
  80313d:	31 ff                	xor    %edi,%edi
  80313f:	e9 3c ff ff ff       	jmp    803080 <__udivdi3+0x40>
  803144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803148:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80314b:	31 ff                	xor    %edi,%edi
  80314d:	e9 2e ff ff ff       	jmp    803080 <__udivdi3+0x40>
  803152:	66 90                	xchg   %ax,%ax
  803154:	66 90                	xchg   %ax,%ax
  803156:	66 90                	xchg   %ax,%ax
  803158:	66 90                	xchg   %ax,%ax
  80315a:	66 90                	xchg   %ax,%ax
  80315c:	66 90                	xchg   %ax,%ax
  80315e:	66 90                	xchg   %ax,%ax

00803160 <__umoddi3>:
  803160:	f3 0f 1e fb          	endbr32 
  803164:	55                   	push   %ebp
  803165:	57                   	push   %edi
  803166:	56                   	push   %esi
  803167:	53                   	push   %ebx
  803168:	83 ec 1c             	sub    $0x1c,%esp
  80316b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80316f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  803173:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  803177:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80317b:	89 f0                	mov    %esi,%eax
  80317d:	89 da                	mov    %ebx,%edx
  80317f:	85 ff                	test   %edi,%edi
  803181:	75 15                	jne    803198 <__umoddi3+0x38>
  803183:	39 dd                	cmp    %ebx,%ebp
  803185:	76 39                	jbe    8031c0 <__umoddi3+0x60>
  803187:	f7 f5                	div    %ebp
  803189:	89 d0                	mov    %edx,%eax
  80318b:	31 d2                	xor    %edx,%edx
  80318d:	83 c4 1c             	add    $0x1c,%esp
  803190:	5b                   	pop    %ebx
  803191:	5e                   	pop    %esi
  803192:	5f                   	pop    %edi
  803193:	5d                   	pop    %ebp
  803194:	c3                   	ret    
  803195:	8d 76 00             	lea    0x0(%esi),%esi
  803198:	39 df                	cmp    %ebx,%edi
  80319a:	77 f1                	ja     80318d <__umoddi3+0x2d>
  80319c:	0f bd cf             	bsr    %edi,%ecx
  80319f:	83 f1 1f             	xor    $0x1f,%ecx
  8031a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8031a6:	75 40                	jne    8031e8 <__umoddi3+0x88>
  8031a8:	39 df                	cmp    %ebx,%edi
  8031aa:	72 04                	jb     8031b0 <__umoddi3+0x50>
  8031ac:	39 f5                	cmp    %esi,%ebp
  8031ae:	77 dd                	ja     80318d <__umoddi3+0x2d>
  8031b0:	89 da                	mov    %ebx,%edx
  8031b2:	89 f0                	mov    %esi,%eax
  8031b4:	29 e8                	sub    %ebp,%eax
  8031b6:	19 fa                	sbb    %edi,%edx
  8031b8:	eb d3                	jmp    80318d <__umoddi3+0x2d>
  8031ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8031c0:	89 e9                	mov    %ebp,%ecx
  8031c2:	85 ed                	test   %ebp,%ebp
  8031c4:	75 0b                	jne    8031d1 <__umoddi3+0x71>
  8031c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8031cb:	31 d2                	xor    %edx,%edx
  8031cd:	f7 f5                	div    %ebp
  8031cf:	89 c1                	mov    %eax,%ecx
  8031d1:	89 d8                	mov    %ebx,%eax
  8031d3:	31 d2                	xor    %edx,%edx
  8031d5:	f7 f1                	div    %ecx
  8031d7:	89 f0                	mov    %esi,%eax
  8031d9:	f7 f1                	div    %ecx
  8031db:	89 d0                	mov    %edx,%eax
  8031dd:	31 d2                	xor    %edx,%edx
  8031df:	eb ac                	jmp    80318d <__umoddi3+0x2d>
  8031e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8031e8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8031ec:	ba 20 00 00 00       	mov    $0x20,%edx
  8031f1:	29 c2                	sub    %eax,%edx
  8031f3:	89 c1                	mov    %eax,%ecx
  8031f5:	89 e8                	mov    %ebp,%eax
  8031f7:	d3 e7                	shl    %cl,%edi
  8031f9:	89 d1                	mov    %edx,%ecx
  8031fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8031ff:	d3 e8                	shr    %cl,%eax
  803201:	89 c1                	mov    %eax,%ecx
  803203:	8b 44 24 04          	mov    0x4(%esp),%eax
  803207:	09 f9                	or     %edi,%ecx
  803209:	89 df                	mov    %ebx,%edi
  80320b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80320f:	89 c1                	mov    %eax,%ecx
  803211:	d3 e5                	shl    %cl,%ebp
  803213:	89 d1                	mov    %edx,%ecx
  803215:	d3 ef                	shr    %cl,%edi
  803217:	89 c1                	mov    %eax,%ecx
  803219:	89 f0                	mov    %esi,%eax
  80321b:	d3 e3                	shl    %cl,%ebx
  80321d:	89 d1                	mov    %edx,%ecx
  80321f:	89 fa                	mov    %edi,%edx
  803221:	d3 e8                	shr    %cl,%eax
  803223:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  803228:	09 d8                	or     %ebx,%eax
  80322a:	f7 74 24 08          	divl   0x8(%esp)
  80322e:	89 d3                	mov    %edx,%ebx
  803230:	d3 e6                	shl    %cl,%esi
  803232:	f7 e5                	mul    %ebp
  803234:	89 c7                	mov    %eax,%edi
  803236:	89 d1                	mov    %edx,%ecx
  803238:	39 d3                	cmp    %edx,%ebx
  80323a:	72 06                	jb     803242 <__umoddi3+0xe2>
  80323c:	75 0e                	jne    80324c <__umoddi3+0xec>
  80323e:	39 c6                	cmp    %eax,%esi
  803240:	73 0a                	jae    80324c <__umoddi3+0xec>
  803242:	29 e8                	sub    %ebp,%eax
  803244:	1b 54 24 08          	sbb    0x8(%esp),%edx
  803248:	89 d1                	mov    %edx,%ecx
  80324a:	89 c7                	mov    %eax,%edi
  80324c:	89 f5                	mov    %esi,%ebp
  80324e:	8b 74 24 04          	mov    0x4(%esp),%esi
  803252:	29 fd                	sub    %edi,%ebp
  803254:	19 cb                	sbb    %ecx,%ebx
  803256:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80325b:	89 d8                	mov    %ebx,%eax
  80325d:	d3 e0                	shl    %cl,%eax
  80325f:	89 f1                	mov    %esi,%ecx
  803261:	d3 ed                	shr    %cl,%ebp
  803263:	d3 eb                	shr    %cl,%ebx
  803265:	09 e8                	or     %ebp,%eax
  803267:	89 da                	mov    %ebx,%edx
  803269:	83 c4 1c             	add    $0x1c,%esp
  80326c:	5b                   	pop    %ebx
  80326d:	5e                   	pop    %esi
  80326e:	5f                   	pop    %edi
  80326f:	5d                   	pop    %ebp
  803270:	c3                   	ret    
