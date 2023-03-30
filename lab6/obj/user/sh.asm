
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
  800076:	e8 c9 0a 00 00       	call   800b44 <cprintf>
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	eb 47                	jmp    8000c7 <_gettoken+0x94>
		cprintf("GETTOKEN: %s\n", s);
  800080:	83 ec 08             	sub    $0x8,%esp
  800083:	53                   	push   %ebx
  800084:	68 6f 37 80 00       	push   $0x80376f
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
  8000a1:	68 7d 37 80 00       	push   $0x80377d
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
  8000d9:	e8 66 0a 00 00       	call   800b44 <cprintf>
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	eb e4                	jmp    8000c7 <_gettoken+0x94>
	if (strchr(SYMBOLS, *s)) {
  8000e3:	83 ec 08             	sub    $0x8,%esp
  8000e6:	0f be c0             	movsbl %al,%eax
  8000e9:	50                   	push   %eax
  8000ea:	68 93 37 80 00       	push   $0x803793
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
  80010b:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800112:	7e b3                	jle    8000c7 <_gettoken+0x94>
			cprintf("TOK %c\n", t);
  800114:	83 ec 08             	sub    $0x8,%esp
  800117:	56                   	push   %esi
  800118:	68 87 37 80 00       	push   $0x803787
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
  80013c:	68 8f 37 80 00       	push   $0x80378f
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
  800266:	e8 01 21 00 00       	call   80236c <open>
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
  800297:	e8 cf 2e 00 00       	call   80316b <pipe>
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	85 c0                	test   %eax,%eax
  8002a1:	0f 88 41 01 00 00    	js     8003e8 <runcmd+0x1ee>
			if (debug)
  8002a7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8002ae:	0f 85 4f 01 00 00    	jne    800403 <runcmd+0x209>
			if ((r = fork()) < 0) {
  8002b4:	e8 a1 16 00 00       	call   80195a <fork>
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
  8002e0:	e8 e8 1a 00 00       	call   801dcd <close>
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
  800309:	e8 36 08 00 00       	call   800b44 <cprintf>
				exit();
  80030e:	e8 3c 07 00 00       	call   800a4f <exit>
  800313:	83 c4 10             	add    $0x10,%esp
  800316:	eb da                	jmp    8002f2 <runcmd+0xf8>
				cprintf("syntax error: < not followed by word\n");
  800318:	83 ec 0c             	sub    $0xc,%esp
  80031b:	68 f0 38 80 00       	push   $0x8038f0
  800320:	e8 1f 08 00 00       	call   800b44 <cprintf>
				exit();
  800325:	e8 25 07 00 00       	call   800a4f <exit>
  80032a:	83 c4 10             	add    $0x10,%esp
  80032d:	e9 2c ff ff ff       	jmp    80025e <runcmd+0x64>
				cprintf("open %s for read: %e", t, fd);
  800332:	83 ec 04             	sub    $0x4,%esp
  800335:	50                   	push   %eax
  800336:	ff 75 a4             	push   -0x5c(%ebp)
  800339:	68 b9 37 80 00       	push   $0x8037b9
  80033e:	e8 01 08 00 00       	call   800b44 <cprintf>
				exit();
  800343:	e8 07 07 00 00       	call   800a4f <exit>
  800348:	83 c4 10             	add    $0x10,%esp
				dup(fd, 0);
  80034b:	83 ec 08             	sub    $0x8,%esp
  80034e:	6a 00                	push   $0x0
  800350:	53                   	push   %ebx
  800351:	e8 c9 1a 00 00       	call   801e1f <dup>
				close(fd);
  800356:	89 1c 24             	mov    %ebx,(%esp)
  800359:	e8 6f 1a 00 00       	call   801dcd <close>
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
  800384:	e8 e3 1f 00 00       	call   80236c <open>
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
  8003a5:	e8 9a 07 00 00       	call   800b44 <cprintf>
				exit();
  8003aa:	e8 a0 06 00 00       	call   800a4f <exit>
  8003af:	83 c4 10             	add    $0x10,%esp
  8003b2:	eb c5                	jmp    800379 <runcmd+0x17f>
				cprintf("open %s for write: %e", t, fd);
  8003b4:	83 ec 04             	sub    $0x4,%esp
  8003b7:	50                   	push   %eax
  8003b8:	ff 75 a4             	push   -0x5c(%ebp)
  8003bb:	68 ce 37 80 00       	push   $0x8037ce
  8003c0:	e8 7f 07 00 00       	call   800b44 <cprintf>
				exit();
  8003c5:	e8 85 06 00 00       	call   800a4f <exit>
  8003ca:	83 c4 10             	add    $0x10,%esp
				dup(fd, 1);
  8003cd:	83 ec 08             	sub    $0x8,%esp
  8003d0:	6a 01                	push   $0x1
  8003d2:	53                   	push   %ebx
  8003d3:	e8 47 1a 00 00       	call   801e1f <dup>
				close(fd);
  8003d8:	89 1c 24             	mov    %ebx,(%esp)
  8003db:	e8 ed 19 00 00       	call   801dcd <close>
  8003e0:	83 c4 10             	add    $0x10,%esp
  8003e3:	e9 33 fe ff ff       	jmp    80021b <runcmd+0x21>
				cprintf("pipe: %e", r);
  8003e8:	83 ec 08             	sub    $0x8,%esp
  8003eb:	50                   	push   %eax
  8003ec:	68 e4 37 80 00       	push   $0x8037e4
  8003f1:	e8 4e 07 00 00       	call   800b44 <cprintf>
				exit();
  8003f6:	e8 54 06 00 00       	call   800a4f <exit>
  8003fb:	83 c4 10             	add    $0x10,%esp
  8003fe:	e9 a4 fe ff ff       	jmp    8002a7 <runcmd+0xad>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  800403:	83 ec 04             	sub    $0x4,%esp
  800406:	ff b5 a0 fb ff ff    	push   -0x460(%ebp)
  80040c:	ff b5 9c fb ff ff    	push   -0x464(%ebp)
  800412:	68 ed 37 80 00       	push   $0x8037ed
  800417:	e8 28 07 00 00       	call   800b44 <cprintf>
  80041c:	83 c4 10             	add    $0x10,%esp
  80041f:	e9 90 fe ff ff       	jmp    8002b4 <runcmd+0xba>
				cprintf("fork: %e", r);
  800424:	83 ec 08             	sub    $0x8,%esp
  800427:	50                   	push   %eax
  800428:	68 88 3d 80 00       	push   $0x803d88
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
  800452:	e8 76 19 00 00       	call   801dcd <close>
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
  80048d:	e8 92 20 00 00       	call   802524 <spawn>
  800492:	89 c6                	mov    %eax,%esi
  800494:	83 c4 10             	add    $0x10,%esp
  800497:	85 c0                	test   %eax,%eax
  800499:	0f 88 3a 01 00 00    	js     8005d9 <runcmd+0x3df>
	close_all();
  80049f:	e8 56 19 00 00       	call   801dfa <close_all>
		if (debug)
  8004a4:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8004ab:	0f 85 75 01 00 00    	jne    800626 <runcmd+0x42c>
		wait(r);
  8004b1:	83 ec 0c             	sub    $0xc,%esp
  8004b4:	56                   	push   %esi
  8004b5:	e8 2e 2e 00 00       	call   8032e8 <wait>
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
  8004d2:	e8 11 2e 00 00       	call   8032e8 <wait>
		if (debug)
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
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
  8004fa:	e8 20 19 00 00       	call   801e1f <dup>
					close(p[0]);
  8004ff:	83 c4 04             	add    $0x4,%esp
  800502:	ff b5 9c fb ff ff    	push   -0x464(%ebp)
  800508:	e8 c0 18 00 00       	call   801dcd <close>
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	e9 c2 fd ff ff       	jmp    8002d7 <runcmd+0xdd>
					dup(p[1], 1);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	6a 01                	push   $0x1
  80051a:	50                   	push   %eax
  80051b:	e8 ff 18 00 00       	call   801e1f <dup>
					close(p[1]);
  800520:	83 c4 04             	add    $0x4,%esp
  800523:	ff b5 a0 fb ff ff    	push   -0x460(%ebp)
  800529:	e8 9f 18 00 00       	call   801dcd <close>
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	e9 13 ff ff ff       	jmp    800449 <runcmd+0x24f>
			panic("bad return %d from gettoken", c);
  800536:	53                   	push   %ebx
  800537:	68 fa 37 80 00       	push   $0x8037fa
  80053c:	6a 79                	push   $0x79
  80053e:	68 16 38 80 00       	push   $0x803816
  800543:	e8 21 05 00 00       	call   800a69 <_panic>
		if (debug)
  800548:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80054f:	74 9b                	je     8004ec <runcmd+0x2f2>
			cprintf("EMPTY COMMAND\n");
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	68 20 38 80 00       	push   $0x803820
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
  80058b:	a1 14 60 80 00       	mov    0x806014,%eax
  800590:	8b 40 48             	mov    0x48(%eax),%eax
  800593:	83 ec 08             	sub    $0x8,%esp
  800596:	50                   	push   %eax
  800597:	68 2f 38 80 00       	push   $0x80382f
  80059c:	e8 a3 05 00 00       	call   800b44 <cprintf>
  8005a1:	8d 75 a8             	lea    -0x58(%ebp),%esi
		for (i = 0; argv[i]; i++)
  8005a4:	83 c4 10             	add    $0x10,%esp
  8005a7:	eb 11                	jmp    8005ba <runcmd+0x3c0>
			cprintf(" %s", argv[i]);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	50                   	push   %eax
  8005ad:	68 b7 38 80 00       	push   $0x8038b7
  8005b2:	e8 8d 05 00 00       	call   800b44 <cprintf>
  8005b7:	83 c4 10             	add    $0x10,%esp
		for (i = 0; argv[i]; i++)
  8005ba:	83 c6 04             	add    $0x4,%esi
  8005bd:	8b 46 fc             	mov    -0x4(%esi),%eax
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	75 e5                	jne    8005a9 <runcmd+0x3af>
		cprintf("\n");
  8005c4:	83 ec 0c             	sub    $0xc,%esp
  8005c7:	68 80 37 80 00       	push   $0x803780
  8005cc:	e8 73 05 00 00       	call   800b44 <cprintf>
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	e9 aa fe ff ff       	jmp    800483 <runcmd+0x289>
		cprintf("spawn %s: %e\n", argv[0], r);
  8005d9:	83 ec 04             	sub    $0x4,%esp
  8005dc:	50                   	push   %eax
  8005dd:	ff 75 a8             	push   -0x58(%ebp)
  8005e0:	68 3d 38 80 00       	push   $0x80383d
  8005e5:	e8 5a 05 00 00       	call   800b44 <cprintf>
	close_all();
  8005ea:	e8 0b 18 00 00       	call   801dfa <close_all>
  8005ef:	83 c4 10             	add    $0x10,%esp
	if (pipe_child) {
  8005f2:	85 db                	test   %ebx,%ebx
  8005f4:	0f 84 ed fe ff ff    	je     8004e7 <runcmd+0x2ed>
		if (debug)
  8005fa:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800601:	0f 84 c7 fe ff ff    	je     8004ce <runcmd+0x2d4>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  800607:	a1 14 60 80 00       	mov    0x806014,%eax
  80060c:	8b 40 48             	mov    0x48(%eax),%eax
  80060f:	83 ec 04             	sub    $0x4,%esp
  800612:	53                   	push   %ebx
  800613:	50                   	push   %eax
  800614:	68 76 38 80 00       	push   $0x803876
  800619:	e8 26 05 00 00       	call   800b44 <cprintf>
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	e9 a8 fe ff ff       	jmp    8004ce <runcmd+0x2d4>
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800626:	a1 14 60 80 00       	mov    0x806014,%eax
  80062b:	8b 40 48             	mov    0x48(%eax),%eax
  80062e:	56                   	push   %esi
  80062f:	ff 75 a8             	push   -0x58(%ebp)
  800632:	50                   	push   %eax
  800633:	68 4b 38 80 00       	push   $0x80384b
  800638:	e8 07 05 00 00       	call   800b44 <cprintf>
  80063d:	83 c4 10             	add    $0x10,%esp
  800640:	e9 6c fe ff ff       	jmp    8004b1 <runcmd+0x2b7>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800645:	a1 14 60 80 00       	mov    0x806014,%eax
  80064a:	8b 40 48             	mov    0x48(%eax),%eax
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	50                   	push   %eax
  800651:	68 60 38 80 00       	push   $0x803860
  800656:	e8 e9 04 00 00       	call   800b44 <cprintf>
  80065b:	83 c4 10             	add    $0x10,%esp
  80065e:	eb 92                	jmp    8005f2 <runcmd+0x3f8>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800660:	a1 14 60 80 00       	mov    0x806014,%eax
  800665:	8b 40 48             	mov    0x48(%eax),%eax
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	50                   	push   %eax
  80066c:	68 60 38 80 00       	push   $0x803860
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
  800684:	68 40 39 80 00       	push   $0x803940
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
  8006ac:	e8 29 14 00 00       	call   801ada <argstart>
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
  8006de:	e8 27 14 00 00       	call   801b0a <argnext>
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
  800731:	e8 97 16 00 00       	call   801dcd <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  800736:	83 c4 08             	add    $0x8,%esp
  800739:	6a 00                	push   $0x0
  80073b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073e:	ff 70 04             	push   0x4(%eax)
  800741:	e8 26 1c 00 00       	call   80236c <open>
  800746:	83 c4 10             	add    $0x10,%esp
  800749:	85 c0                	test   %eax,%eax
  80074b:	78 1b                	js     800768 <umain+0xd0>
		assert(r == 0);
  80074d:	74 bd                	je     80070c <umain+0x74>
  80074f:	68 9f 38 80 00       	push   $0x80389f
  800754:	68 a6 38 80 00       	push   $0x8038a6
  800759:	68 2a 01 00 00       	push   $0x12a
  80075e:	68 16 38 80 00       	push   $0x803816
  800763:	e8 01 03 00 00       	call   800a69 <_panic>
			panic("open %s: %e", argv[1], r);
  800768:	83 ec 0c             	sub    $0xc,%esp
  80076b:	50                   	push   %eax
  80076c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076f:	ff 70 04             	push   0x4(%eax)
  800772:	68 93 38 80 00       	push   $0x803893
  800777:	68 29 01 00 00       	push   $0x129
  80077c:	68 16 38 80 00       	push   $0x803816
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
  80079a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8007a1:	75 0a                	jne    8007ad <umain+0x115>
				cprintf("EXITING\n");
			exit();	// end of file
  8007a3:	e8 a7 02 00 00       	call   800a4f <exit>
  8007a8:	e9 94 00 00 00       	jmp    800841 <umain+0x1a9>
				cprintf("EXITING\n");
  8007ad:	83 ec 0c             	sub    $0xc,%esp
  8007b0:	68 be 38 80 00       	push   $0x8038be
  8007b5:	e8 8a 03 00 00       	call   800b44 <cprintf>
  8007ba:	83 c4 10             	add    $0x10,%esp
  8007bd:	eb e4                	jmp    8007a3 <umain+0x10b>
		}
		if (debug)
			cprintf("LINE: %s\n", buf);
  8007bf:	83 ec 08             	sub    $0x8,%esp
  8007c2:	53                   	push   %ebx
  8007c3:	68 c7 38 80 00       	push   $0x8038c7
  8007c8:	e8 77 03 00 00       	call   800b44 <cprintf>
  8007cd:	83 c4 10             	add    $0x10,%esp
  8007d0:	eb 7c                	jmp    80084e <umain+0x1b6>
		if (buf[0] == '#')
			continue;
		if (echocmds)
			printf("# %s\n", buf);
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	53                   	push   %ebx
  8007d6:	68 d1 38 80 00       	push   $0x8038d1
  8007db:	e8 2e 1d 00 00       	call   80250e <printf>
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	eb 78                	jmp    80085d <umain+0x1c5>
		if (debug)
			cprintf("BEFORE FORK\n");
  8007e5:	83 ec 0c             	sub    $0xc,%esp
  8007e8:	68 d7 38 80 00       	push   $0x8038d7
  8007ed:	e8 52 03 00 00       	call   800b44 <cprintf>
  8007f2:	83 c4 10             	add    $0x10,%esp
  8007f5:	eb 73                	jmp    80086a <umain+0x1d2>
		if ((r = fork()) < 0)
			panic("fork: %e", r);
  8007f7:	50                   	push   %eax
  8007f8:	68 88 3d 80 00       	push   $0x803d88
  8007fd:	68 41 01 00 00       	push   $0x141
  800802:	68 16 38 80 00       	push   $0x803816
  800807:	e8 5d 02 00 00       	call   800a69 <_panic>
		if (debug)
			cprintf("FORK: %d\n", r);
  80080c:	83 ec 08             	sub    $0x8,%esp
  80080f:	50                   	push   %eax
  800810:	68 e4 38 80 00       	push   $0x8038e4
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
  800823:	e8 c0 2a 00 00       	call   8032e8 <wait>
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
  80086a:	e8 eb 10 00 00       	call   80195a <fork>
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
  8008a1:	68 61 39 80 00       	push   $0x803961
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
  800970:	e8 94 15 00 00       	call   801f09 <read>
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
  800998:	e8 03 13 00 00       	call   801ca0 <fd_lookup>
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
  8009c1:	e8 8a 12 00 00       	call   801c50 <fd_alloc>
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
  8009e9:	8b 15 00 50 80 00    	mov    0x805000,%edx
  8009ef:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8009f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009fb:	83 ec 0c             	sub    $0xc,%esp
  8009fe:	50                   	push   %eax
  8009ff:	e8 25 12 00 00       	call   801c29 <fd2num>
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
  800a26:	a3 14 60 80 00       	mov    %eax,0x806014

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800a2b:	85 db                	test   %ebx,%ebx
  800a2d:	7e 07                	jle    800a36 <libmain+0x2d>
		binaryname = argv[0];
  800a2f:	8b 06                	mov    (%esi),%eax
  800a31:	a3 1c 50 80 00       	mov    %eax,0x80501c

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
  800a55:	e8 a0 13 00 00       	call   801dfa <close_all>
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
  800a71:	8b 35 1c 50 80 00    	mov    0x80501c,%esi
  800a77:	e8 50 0b 00 00       	call   8015cc <sys_getenvid>
  800a7c:	83 ec 0c             	sub    $0xc,%esp
  800a7f:	ff 75 0c             	push   0xc(%ebp)
  800a82:	ff 75 08             	push   0x8(%ebp)
  800a85:	56                   	push   %esi
  800a86:	50                   	push   %eax
  800a87:	68 78 39 80 00       	push   $0x803978
  800a8c:	e8 b3 00 00 00       	call   800b44 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a91:	83 c4 18             	add    $0x18,%esp
  800a94:	53                   	push   %ebx
  800a95:	ff 75 10             	push   0x10(%ebp)
  800a98:	e8 56 00 00 00       	call   800af3 <vcprintf>
	cprintf("\n");
  800a9d:	c7 04 24 80 37 80 00 	movl   $0x803780,(%esp)
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
  800ba6:	e8 65 29 00 00       	call   803510 <__udivdi3>
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
  800be4:	e8 47 2a 00 00       	call   803630 <__umoddi3>
  800be9:	83 c4 14             	add    $0x14,%esp
  800bec:	0f be 80 9b 39 80 00 	movsbl 0x80399b(%eax),%eax
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
  800ca6:	ff 24 85 e0 3a 80 00 	jmp    *0x803ae0(,%eax,4)
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
  800d74:	8b 14 85 40 3c 80 00 	mov    0x803c40(,%eax,4),%edx
  800d7b:	85 d2                	test   %edx,%edx
  800d7d:	74 18                	je     800d97 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800d7f:	52                   	push   %edx
  800d80:	68 b8 38 80 00       	push   $0x8038b8
  800d85:	53                   	push   %ebx
  800d86:	56                   	push   %esi
  800d87:	e8 92 fe ff ff       	call   800c1e <printfmt>
  800d8c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800d8f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800d92:	e9 66 02 00 00       	jmp    800ffd <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800d97:	50                   	push   %eax
  800d98:	68 b3 39 80 00       	push   $0x8039b3
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
  800dbf:	b8 ac 39 80 00       	mov    $0x8039ac,%eax
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
  8010f7:	68 b8 38 80 00       	push   $0x8038b8
  8010fc:	6a 01                	push   $0x1
  8010fe:	e8 f4 13 00 00       	call   8024f7 <fprintf>
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
  801132:	68 9f 3c 80 00       	push   $0x803c9f
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
  80115e:	88 9e 20 60 80 00    	mov    %bl,0x806020(%esi)
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
  8011b3:	c6 86 20 60 80 00 00 	movb   $0x0,0x806020(%esi)
			return buf;
  8011ba:	b8 20 60 80 00       	mov    $0x806020,%eax
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
  8015bb:	68 af 3c 80 00       	push   $0x803caf
  8015c0:	6a 2a                	push   $0x2a
  8015c2:	68 cc 3c 80 00       	push   $0x803ccc
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
  80163c:	68 af 3c 80 00       	push   $0x803caf
  801641:	6a 2a                	push   $0x2a
  801643:	68 cc 3c 80 00       	push   $0x803ccc
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
  80167e:	68 af 3c 80 00       	push   $0x803caf
  801683:	6a 2a                	push   $0x2a
  801685:	68 cc 3c 80 00       	push   $0x803ccc
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
  8016c0:	68 af 3c 80 00       	push   $0x803caf
  8016c5:	6a 2a                	push   $0x2a
  8016c7:	68 cc 3c 80 00       	push   $0x803ccc
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
  801702:	68 af 3c 80 00       	push   $0x803caf
  801707:	6a 2a                	push   $0x2a
  801709:	68 cc 3c 80 00       	push   $0x803ccc
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
  801744:	68 af 3c 80 00       	push   $0x803caf
  801749:	6a 2a                	push   $0x2a
  80174b:	68 cc 3c 80 00       	push   $0x803ccc
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
  801786:	68 af 3c 80 00       	push   $0x803caf
  80178b:	6a 2a                	push   $0x2a
  80178d:	68 cc 3c 80 00       	push   $0x803ccc
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
  8017ea:	68 af 3c 80 00       	push   $0x803caf
  8017ef:	6a 2a                	push   $0x2a
  8017f1:	68 cc 3c 80 00       	push   $0x803ccc
  8017f6:	e8 6e f2 ff ff       	call   800a69 <_panic>

008017fb <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	57                   	push   %edi
  8017ff:	56                   	push   %esi
  801800:	53                   	push   %ebx
	asm volatile("int %1\n"
  801801:	ba 00 00 00 00       	mov    $0x0,%edx
  801806:	b8 0e 00 00 00       	mov    $0xe,%eax
  80180b:	89 d1                	mov    %edx,%ecx
  80180d:	89 d3                	mov    %edx,%ebx
  80180f:	89 d7                	mov    %edx,%edi
  801811:	89 d6                	mov    %edx,%esi
  801813:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801815:	5b                   	pop    %ebx
  801816:	5e                   	pop    %esi
  801817:	5f                   	pop    %edi
  801818:	5d                   	pop    %ebp
  801819:	c3                   	ret    

0080181a <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	57                   	push   %edi
  80181e:	56                   	push   %esi
  80181f:	53                   	push   %ebx
	asm volatile("int %1\n"
  801820:	bb 00 00 00 00       	mov    $0x0,%ebx
  801825:	8b 55 08             	mov    0x8(%ebp),%edx
  801828:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80182b:	b8 0f 00 00 00       	mov    $0xf,%eax
  801830:	89 df                	mov    %ebx,%edi
  801832:	89 de                	mov    %ebx,%esi
  801834:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  801836:	5b                   	pop    %ebx
  801837:	5e                   	pop    %esi
  801838:	5f                   	pop    %edi
  801839:	5d                   	pop    %ebp
  80183a:	c3                   	ret    

0080183b <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  80183b:	55                   	push   %ebp
  80183c:	89 e5                	mov    %esp,%ebp
  80183e:	57                   	push   %edi
  80183f:	56                   	push   %esi
  801840:	53                   	push   %ebx
	asm volatile("int %1\n"
  801841:	bb 00 00 00 00       	mov    $0x0,%ebx
  801846:	8b 55 08             	mov    0x8(%ebp),%edx
  801849:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80184c:	b8 10 00 00 00       	mov    $0x10,%eax
  801851:	89 df                	mov    %ebx,%edi
  801853:	89 de                	mov    %ebx,%esi
  801855:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  801857:	5b                   	pop    %ebx
  801858:	5e                   	pop    %esi
  801859:	5f                   	pop    %edi
  80185a:	5d                   	pop    %ebp
  80185b:	c3                   	ret    

0080185c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	56                   	push   %esi
  801860:	53                   	push   %ebx
  801861:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801864:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  801866:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80186a:	0f 84 8e 00 00 00    	je     8018fe <pgfault+0xa2>
  801870:	89 f0                	mov    %esi,%eax
  801872:	c1 e8 0c             	shr    $0xc,%eax
  801875:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80187c:	f6 c4 08             	test   $0x8,%ah
  80187f:	74 7d                	je     8018fe <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  801881:	e8 46 fd ff ff       	call   8015cc <sys_getenvid>
  801886:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  801888:	83 ec 04             	sub    $0x4,%esp
  80188b:	6a 07                	push   $0x7
  80188d:	68 00 f0 7f 00       	push   $0x7ff000
  801892:	50                   	push   %eax
  801893:	e8 72 fd ff ff       	call   80160a <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  801898:	83 c4 10             	add    $0x10,%esp
  80189b:	85 c0                	test   %eax,%eax
  80189d:	78 73                	js     801912 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  80189f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  8018a5:	83 ec 04             	sub    $0x4,%esp
  8018a8:	68 00 10 00 00       	push   $0x1000
  8018ad:	56                   	push   %esi
  8018ae:	68 00 f0 7f 00       	push   $0x7ff000
  8018b3:	e8 ec fa ff ff       	call   8013a4 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  8018b8:	83 c4 08             	add    $0x8,%esp
  8018bb:	56                   	push   %esi
  8018bc:	53                   	push   %ebx
  8018bd:	e8 cd fd ff ff       	call   80168f <sys_page_unmap>
  8018c2:	83 c4 10             	add    $0x10,%esp
  8018c5:	85 c0                	test   %eax,%eax
  8018c7:	78 5b                	js     801924 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  8018c9:	83 ec 0c             	sub    $0xc,%esp
  8018cc:	6a 07                	push   $0x7
  8018ce:	56                   	push   %esi
  8018cf:	53                   	push   %ebx
  8018d0:	68 00 f0 7f 00       	push   $0x7ff000
  8018d5:	53                   	push   %ebx
  8018d6:	e8 72 fd ff ff       	call   80164d <sys_page_map>
  8018db:	83 c4 20             	add    $0x20,%esp
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	78 54                	js     801936 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  8018e2:	83 ec 08             	sub    $0x8,%esp
  8018e5:	68 00 f0 7f 00       	push   $0x7ff000
  8018ea:	53                   	push   %ebx
  8018eb:	e8 9f fd ff ff       	call   80168f <sys_page_unmap>
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	78 51                	js     801948 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  8018f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fa:	5b                   	pop    %ebx
  8018fb:	5e                   	pop    %esi
  8018fc:	5d                   	pop    %ebp
  8018fd:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  8018fe:	83 ec 04             	sub    $0x4,%esp
  801901:	68 dc 3c 80 00       	push   $0x803cdc
  801906:	6a 1d                	push   $0x1d
  801908:	68 58 3d 80 00       	push   $0x803d58
  80190d:	e8 57 f1 ff ff       	call   800a69 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  801912:	50                   	push   %eax
  801913:	68 14 3d 80 00       	push   $0x803d14
  801918:	6a 29                	push   $0x29
  80191a:	68 58 3d 80 00       	push   $0x803d58
  80191f:	e8 45 f1 ff ff       	call   800a69 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  801924:	50                   	push   %eax
  801925:	68 38 3d 80 00       	push   $0x803d38
  80192a:	6a 2e                	push   $0x2e
  80192c:	68 58 3d 80 00       	push   $0x803d58
  801931:	e8 33 f1 ff ff       	call   800a69 <_panic>
		panic("pgfault: page map failed (%e)", r);
  801936:	50                   	push   %eax
  801937:	68 63 3d 80 00       	push   $0x803d63
  80193c:	6a 30                	push   $0x30
  80193e:	68 58 3d 80 00       	push   $0x803d58
  801943:	e8 21 f1 ff ff       	call   800a69 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  801948:	50                   	push   %eax
  801949:	68 38 3d 80 00       	push   $0x803d38
  80194e:	6a 32                	push   $0x32
  801950:	68 58 3d 80 00       	push   $0x803d58
  801955:	e8 0f f1 ff ff       	call   800a69 <_panic>

0080195a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	57                   	push   %edi
  80195e:	56                   	push   %esi
  80195f:	53                   	push   %ebx
  801960:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  801963:	68 5c 18 80 00       	push   $0x80185c
  801968:	e8 ca 19 00 00       	call   803337 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80196d:	b8 07 00 00 00       	mov    $0x7,%eax
  801972:	cd 30                	int    $0x30
  801974:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  801977:	83 c4 10             	add    $0x10,%esp
  80197a:	85 c0                	test   %eax,%eax
  80197c:	78 2d                	js     8019ab <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  80197e:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  801983:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801987:	75 73                	jne    8019fc <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  801989:	e8 3e fc ff ff       	call   8015cc <sys_getenvid>
  80198e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801993:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801996:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80199b:	a3 14 60 80 00       	mov    %eax,0x806014
		return 0;
  8019a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  8019a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019a6:	5b                   	pop    %ebx
  8019a7:	5e                   	pop    %esi
  8019a8:	5f                   	pop    %edi
  8019a9:	5d                   	pop    %ebp
  8019aa:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  8019ab:	50                   	push   %eax
  8019ac:	68 81 3d 80 00       	push   $0x803d81
  8019b1:	6a 78                	push   $0x78
  8019b3:	68 58 3d 80 00       	push   $0x803d58
  8019b8:	e8 ac f0 ff ff       	call   800a69 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  8019bd:	83 ec 0c             	sub    $0xc,%esp
  8019c0:	ff 75 e4             	push   -0x1c(%ebp)
  8019c3:	57                   	push   %edi
  8019c4:	ff 75 dc             	push   -0x24(%ebp)
  8019c7:	57                   	push   %edi
  8019c8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8019cb:	56                   	push   %esi
  8019cc:	e8 7c fc ff ff       	call   80164d <sys_page_map>
	if(r<0) return r;
  8019d1:	83 c4 20             	add    $0x20,%esp
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	78 cb                	js     8019a3 <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  8019d8:	83 ec 0c             	sub    $0xc,%esp
  8019db:	ff 75 e4             	push   -0x1c(%ebp)
  8019de:	57                   	push   %edi
  8019df:	56                   	push   %esi
  8019e0:	57                   	push   %edi
  8019e1:	56                   	push   %esi
  8019e2:	e8 66 fc ff ff       	call   80164d <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  8019e7:	83 c4 20             	add    $0x20,%esp
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	78 76                	js     801a64 <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  8019ee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019f4:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8019fa:	74 75                	je     801a71 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  8019fc:	89 d8                	mov    %ebx,%eax
  8019fe:	c1 e8 16             	shr    $0x16,%eax
  801a01:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a08:	a8 01                	test   $0x1,%al
  801a0a:	74 e2                	je     8019ee <fork+0x94>
  801a0c:	89 de                	mov    %ebx,%esi
  801a0e:	c1 ee 0c             	shr    $0xc,%esi
  801a11:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801a18:	a8 01                	test   $0x1,%al
  801a1a:	74 d2                	je     8019ee <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  801a1c:	e8 ab fb ff ff       	call   8015cc <sys_getenvid>
  801a21:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  801a24:	89 f7                	mov    %esi,%edi
  801a26:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  801a29:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801a30:	89 c1                	mov    %eax,%ecx
  801a32:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801a38:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  801a3b:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  801a42:	f6 c6 04             	test   $0x4,%dh
  801a45:	0f 85 72 ff ff ff    	jne    8019bd <fork+0x63>
		perm &= ~PTE_W;
  801a4b:	25 05 0e 00 00       	and    $0xe05,%eax
  801a50:	80 cc 08             	or     $0x8,%ah
  801a53:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  801a59:	0f 44 c1             	cmove  %ecx,%eax
  801a5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a5f:	e9 59 ff ff ff       	jmp    8019bd <fork+0x63>
  801a64:	ba 00 00 00 00       	mov    $0x0,%edx
  801a69:	0f 4f c2             	cmovg  %edx,%eax
  801a6c:	e9 32 ff ff ff       	jmp    8019a3 <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801a71:	83 ec 04             	sub    $0x4,%esp
  801a74:	6a 07                	push   $0x7
  801a76:	68 00 f0 bf ee       	push   $0xeebff000
  801a7b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801a7e:	57                   	push   %edi
  801a7f:	e8 86 fb ff ff       	call   80160a <sys_page_alloc>
	if(r<0) return r;
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	85 c0                	test   %eax,%eax
  801a89:	0f 88 14 ff ff ff    	js     8019a3 <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801a8f:	83 ec 08             	sub    $0x8,%esp
  801a92:	68 ad 33 80 00       	push   $0x8033ad
  801a97:	57                   	push   %edi
  801a98:	e8 b8 fc ff ff       	call   801755 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	0f 88 fb fe ff ff    	js     8019a3 <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801aa8:	83 ec 08             	sub    $0x8,%esp
  801aab:	6a 02                	push   $0x2
  801aad:	57                   	push   %edi
  801aae:	e8 1e fc ff ff       	call   8016d1 <sys_env_set_status>
	if(r<0) return r;
  801ab3:	83 c4 10             	add    $0x10,%esp
	return envid;
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	0f 49 c7             	cmovns %edi,%eax
  801abb:	e9 e3 fe ff ff       	jmp    8019a3 <fork+0x49>

00801ac0 <sfork>:

// Challenge!
int
sfork(void)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801ac6:	68 91 3d 80 00       	push   $0x803d91
  801acb:	68 a1 00 00 00       	push   $0xa1
  801ad0:	68 58 3d 80 00       	push   $0x803d58
  801ad5:	e8 8f ef ff ff       	call   800a69 <_panic>

00801ada <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	8b 55 08             	mov    0x8(%ebp),%edx
  801ae0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae3:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801ae6:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801ae8:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801aeb:	83 3a 01             	cmpl   $0x1,(%edx)
  801aee:	7e 09                	jle    801af9 <argstart+0x1f>
  801af0:	ba 81 37 80 00       	mov    $0x803781,%edx
  801af5:	85 c9                	test   %ecx,%ecx
  801af7:	75 05                	jne    801afe <argstart+0x24>
  801af9:	ba 00 00 00 00       	mov    $0x0,%edx
  801afe:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801b01:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801b08:	5d                   	pop    %ebp
  801b09:	c3                   	ret    

00801b0a <argnext>:

int
argnext(struct Argstate *args)
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	53                   	push   %ebx
  801b0e:	83 ec 04             	sub    $0x4,%esp
  801b11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801b14:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801b1b:	8b 43 08             	mov    0x8(%ebx),%eax
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	74 74                	je     801b96 <argnext+0x8c>
		return -1;

	if (!*args->curarg) {
  801b22:	80 38 00             	cmpb   $0x0,(%eax)
  801b25:	75 48                	jne    801b6f <argnext+0x65>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801b27:	8b 0b                	mov    (%ebx),%ecx
  801b29:	83 39 01             	cmpl   $0x1,(%ecx)
  801b2c:	74 5a                	je     801b88 <argnext+0x7e>
		    || args->argv[1][0] != '-'
  801b2e:	8b 53 04             	mov    0x4(%ebx),%edx
  801b31:	8b 42 04             	mov    0x4(%edx),%eax
  801b34:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b37:	75 4f                	jne    801b88 <argnext+0x7e>
		    || args->argv[1][1] == '\0')
  801b39:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b3d:	74 49                	je     801b88 <argnext+0x7e>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801b3f:	83 c0 01             	add    $0x1,%eax
  801b42:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b45:	83 ec 04             	sub    $0x4,%esp
  801b48:	8b 01                	mov    (%ecx),%eax
  801b4a:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801b51:	50                   	push   %eax
  801b52:	8d 42 08             	lea    0x8(%edx),%eax
  801b55:	50                   	push   %eax
  801b56:	83 c2 04             	add    $0x4,%edx
  801b59:	52                   	push   %edx
  801b5a:	e8 45 f8 ff ff       	call   8013a4 <memmove>
		(*args->argc)--;
  801b5f:	8b 03                	mov    (%ebx),%eax
  801b61:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b64:	8b 43 08             	mov    0x8(%ebx),%eax
  801b67:	83 c4 10             	add    $0x10,%esp
  801b6a:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b6d:	74 13                	je     801b82 <argnext+0x78>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801b6f:	8b 43 08             	mov    0x8(%ebx),%eax
  801b72:	0f b6 10             	movzbl (%eax),%edx
	args->curarg++;
  801b75:	83 c0 01             	add    $0x1,%eax
  801b78:	89 43 08             	mov    %eax,0x8(%ebx)
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801b7b:	89 d0                	mov    %edx,%eax
  801b7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b80:	c9                   	leave  
  801b81:	c3                   	ret    
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b82:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b86:	75 e7                	jne    801b6f <argnext+0x65>
	args->curarg = 0;
  801b88:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801b8f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b94:	eb e5                	jmp    801b7b <argnext+0x71>
		return -1;
  801b96:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b9b:	eb de                	jmp    801b7b <argnext+0x71>

00801b9d <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	53                   	push   %ebx
  801ba1:	83 ec 04             	sub    $0x4,%esp
  801ba4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801ba7:	8b 43 08             	mov    0x8(%ebx),%eax
  801baa:	85 c0                	test   %eax,%eax
  801bac:	74 12                	je     801bc0 <argnextvalue+0x23>
		return 0;
	if (*args->curarg) {
  801bae:	80 38 00             	cmpb   $0x0,(%eax)
  801bb1:	74 12                	je     801bc5 <argnextvalue+0x28>
		args->argvalue = args->curarg;
  801bb3:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801bb6:	c7 43 08 81 37 80 00 	movl   $0x803781,0x8(%ebx)
		(*args->argc)--;
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
  801bbd:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  801bc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc3:	c9                   	leave  
  801bc4:	c3                   	ret    
	} else if (*args->argc > 1) {
  801bc5:	8b 13                	mov    (%ebx),%edx
  801bc7:	83 3a 01             	cmpl   $0x1,(%edx)
  801bca:	7f 10                	jg     801bdc <argnextvalue+0x3f>
		args->argvalue = 0;
  801bcc:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801bd3:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  801bda:	eb e1                	jmp    801bbd <argnextvalue+0x20>
		args->argvalue = args->argv[1];
  801bdc:	8b 43 04             	mov    0x4(%ebx),%eax
  801bdf:	8b 48 04             	mov    0x4(%eax),%ecx
  801be2:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801be5:	83 ec 04             	sub    $0x4,%esp
  801be8:	8b 12                	mov    (%edx),%edx
  801bea:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801bf1:	52                   	push   %edx
  801bf2:	8d 50 08             	lea    0x8(%eax),%edx
  801bf5:	52                   	push   %edx
  801bf6:	83 c0 04             	add    $0x4,%eax
  801bf9:	50                   	push   %eax
  801bfa:	e8 a5 f7 ff ff       	call   8013a4 <memmove>
		(*args->argc)--;
  801bff:	8b 03                	mov    (%ebx),%eax
  801c01:	83 28 01             	subl   $0x1,(%eax)
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	eb b4                	jmp    801bbd <argnextvalue+0x20>

00801c09 <argvalue>:
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	83 ec 08             	sub    $0x8,%esp
  801c0f:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801c12:	8b 42 0c             	mov    0xc(%edx),%eax
  801c15:	85 c0                	test   %eax,%eax
  801c17:	74 02                	je     801c1b <argvalue+0x12>
}
  801c19:	c9                   	leave  
  801c1a:	c3                   	ret    
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801c1b:	83 ec 0c             	sub    $0xc,%esp
  801c1e:	52                   	push   %edx
  801c1f:	e8 79 ff ff ff       	call   801b9d <argnextvalue>
  801c24:	83 c4 10             	add    $0x10,%esp
  801c27:	eb f0                	jmp    801c19 <argvalue+0x10>

00801c29 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2f:	05 00 00 00 30       	add    $0x30000000,%eax
  801c34:	c1 e8 0c             	shr    $0xc,%eax
}
  801c37:	5d                   	pop    %ebp
  801c38:	c3                   	ret    

00801c39 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3f:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801c44:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801c49:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801c4e:	5d                   	pop    %ebp
  801c4f:	c3                   	ret    

00801c50 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801c58:	89 c2                	mov    %eax,%edx
  801c5a:	c1 ea 16             	shr    $0x16,%edx
  801c5d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c64:	f6 c2 01             	test   $0x1,%dl
  801c67:	74 29                	je     801c92 <fd_alloc+0x42>
  801c69:	89 c2                	mov    %eax,%edx
  801c6b:	c1 ea 0c             	shr    $0xc,%edx
  801c6e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c75:	f6 c2 01             	test   $0x1,%dl
  801c78:	74 18                	je     801c92 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801c7a:	05 00 10 00 00       	add    $0x1000,%eax
  801c7f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c84:	75 d2                	jne    801c58 <fd_alloc+0x8>
  801c86:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801c8b:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801c90:	eb 05                	jmp    801c97 <fd_alloc+0x47>
			return 0;
  801c92:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801c97:	8b 55 08             	mov    0x8(%ebp),%edx
  801c9a:	89 02                	mov    %eax,(%edx)
}
  801c9c:	89 c8                	mov    %ecx,%eax
  801c9e:	5d                   	pop    %ebp
  801c9f:	c3                   	ret    

00801ca0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801ca6:	83 f8 1f             	cmp    $0x1f,%eax
  801ca9:	77 30                	ja     801cdb <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801cab:	c1 e0 0c             	shl    $0xc,%eax
  801cae:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801cb3:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801cb9:	f6 c2 01             	test   $0x1,%dl
  801cbc:	74 24                	je     801ce2 <fd_lookup+0x42>
  801cbe:	89 c2                	mov    %eax,%edx
  801cc0:	c1 ea 0c             	shr    $0xc,%edx
  801cc3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801cca:	f6 c2 01             	test   $0x1,%dl
  801ccd:	74 1a                	je     801ce9 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801ccf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cd2:	89 02                	mov    %eax,(%edx)
	return 0;
  801cd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cd9:	5d                   	pop    %ebp
  801cda:	c3                   	ret    
		return -E_INVAL;
  801cdb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ce0:	eb f7                	jmp    801cd9 <fd_lookup+0x39>
		return -E_INVAL;
  801ce2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ce7:	eb f0                	jmp    801cd9 <fd_lookup+0x39>
  801ce9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801cee:	eb e9                	jmp    801cd9 <fd_lookup+0x39>

00801cf0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	53                   	push   %ebx
  801cf4:	83 ec 04             	sub    $0x4,%esp
  801cf7:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801cfa:	b8 00 00 00 00       	mov    $0x0,%eax
  801cff:	bb 20 50 80 00       	mov    $0x805020,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801d04:	39 13                	cmp    %edx,(%ebx)
  801d06:	74 37                	je     801d3f <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  801d08:	83 c0 01             	add    $0x1,%eax
  801d0b:	8b 1c 85 24 3e 80 00 	mov    0x803e24(,%eax,4),%ebx
  801d12:	85 db                	test   %ebx,%ebx
  801d14:	75 ee                	jne    801d04 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801d16:	a1 14 60 80 00       	mov    0x806014,%eax
  801d1b:	8b 40 48             	mov    0x48(%eax),%eax
  801d1e:	83 ec 04             	sub    $0x4,%esp
  801d21:	52                   	push   %edx
  801d22:	50                   	push   %eax
  801d23:	68 a8 3d 80 00       	push   $0x803da8
  801d28:	e8 17 ee ff ff       	call   800b44 <cprintf>
	*dev = 0;
	return -E_INVAL;
  801d2d:	83 c4 10             	add    $0x10,%esp
  801d30:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801d35:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d38:	89 1a                	mov    %ebx,(%edx)
}
  801d3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d3d:	c9                   	leave  
  801d3e:	c3                   	ret    
			return 0;
  801d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d44:	eb ef                	jmp    801d35 <dev_lookup+0x45>

00801d46 <fd_close>:
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	57                   	push   %edi
  801d4a:	56                   	push   %esi
  801d4b:	53                   	push   %ebx
  801d4c:	83 ec 24             	sub    $0x24,%esp
  801d4f:	8b 75 08             	mov    0x8(%ebp),%esi
  801d52:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d55:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d58:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801d59:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801d5f:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d62:	50                   	push   %eax
  801d63:	e8 38 ff ff ff       	call   801ca0 <fd_lookup>
  801d68:	89 c3                	mov    %eax,%ebx
  801d6a:	83 c4 10             	add    $0x10,%esp
  801d6d:	85 c0                	test   %eax,%eax
  801d6f:	78 05                	js     801d76 <fd_close+0x30>
	    || fd != fd2)
  801d71:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801d74:	74 16                	je     801d8c <fd_close+0x46>
		return (must_exist ? r : 0);
  801d76:	89 f8                	mov    %edi,%eax
  801d78:	84 c0                	test   %al,%al
  801d7a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7f:	0f 44 d8             	cmove  %eax,%ebx
}
  801d82:	89 d8                	mov    %ebx,%eax
  801d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d87:	5b                   	pop    %ebx
  801d88:	5e                   	pop    %esi
  801d89:	5f                   	pop    %edi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d8c:	83 ec 08             	sub    $0x8,%esp
  801d8f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801d92:	50                   	push   %eax
  801d93:	ff 36                	push   (%esi)
  801d95:	e8 56 ff ff ff       	call   801cf0 <dev_lookup>
  801d9a:	89 c3                	mov    %eax,%ebx
  801d9c:	83 c4 10             	add    $0x10,%esp
  801d9f:	85 c0                	test   %eax,%eax
  801da1:	78 1a                	js     801dbd <fd_close+0x77>
		if (dev->dev_close)
  801da3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801da6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801da9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801dae:	85 c0                	test   %eax,%eax
  801db0:	74 0b                	je     801dbd <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801db2:	83 ec 0c             	sub    $0xc,%esp
  801db5:	56                   	push   %esi
  801db6:	ff d0                	call   *%eax
  801db8:	89 c3                	mov    %eax,%ebx
  801dba:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801dbd:	83 ec 08             	sub    $0x8,%esp
  801dc0:	56                   	push   %esi
  801dc1:	6a 00                	push   $0x0
  801dc3:	e8 c7 f8 ff ff       	call   80168f <sys_page_unmap>
	return r;
  801dc8:	83 c4 10             	add    $0x10,%esp
  801dcb:	eb b5                	jmp    801d82 <fd_close+0x3c>

00801dcd <close>:

int
close(int fdnum)
{
  801dcd:	55                   	push   %ebp
  801dce:	89 e5                	mov    %esp,%ebp
  801dd0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd6:	50                   	push   %eax
  801dd7:	ff 75 08             	push   0x8(%ebp)
  801dda:	e8 c1 fe ff ff       	call   801ca0 <fd_lookup>
  801ddf:	83 c4 10             	add    $0x10,%esp
  801de2:	85 c0                	test   %eax,%eax
  801de4:	79 02                	jns    801de8 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801de6:	c9                   	leave  
  801de7:	c3                   	ret    
		return fd_close(fd, 1);
  801de8:	83 ec 08             	sub    $0x8,%esp
  801deb:	6a 01                	push   $0x1
  801ded:	ff 75 f4             	push   -0xc(%ebp)
  801df0:	e8 51 ff ff ff       	call   801d46 <fd_close>
  801df5:	83 c4 10             	add    $0x10,%esp
  801df8:	eb ec                	jmp    801de6 <close+0x19>

00801dfa <close_all>:

void
close_all(void)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	53                   	push   %ebx
  801dfe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801e01:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801e06:	83 ec 0c             	sub    $0xc,%esp
  801e09:	53                   	push   %ebx
  801e0a:	e8 be ff ff ff       	call   801dcd <close>
	for (i = 0; i < MAXFD; i++)
  801e0f:	83 c3 01             	add    $0x1,%ebx
  801e12:	83 c4 10             	add    $0x10,%esp
  801e15:	83 fb 20             	cmp    $0x20,%ebx
  801e18:	75 ec                	jne    801e06 <close_all+0xc>
}
  801e1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e1d:	c9                   	leave  
  801e1e:	c3                   	ret    

00801e1f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801e1f:	55                   	push   %ebp
  801e20:	89 e5                	mov    %esp,%ebp
  801e22:	57                   	push   %edi
  801e23:	56                   	push   %esi
  801e24:	53                   	push   %ebx
  801e25:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e28:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e2b:	50                   	push   %eax
  801e2c:	ff 75 08             	push   0x8(%ebp)
  801e2f:	e8 6c fe ff ff       	call   801ca0 <fd_lookup>
  801e34:	89 c3                	mov    %eax,%ebx
  801e36:	83 c4 10             	add    $0x10,%esp
  801e39:	85 c0                	test   %eax,%eax
  801e3b:	78 7f                	js     801ebc <dup+0x9d>
		return r;
	close(newfdnum);
  801e3d:	83 ec 0c             	sub    $0xc,%esp
  801e40:	ff 75 0c             	push   0xc(%ebp)
  801e43:	e8 85 ff ff ff       	call   801dcd <close>

	newfd = INDEX2FD(newfdnum);
  801e48:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e4b:	c1 e6 0c             	shl    $0xc,%esi
  801e4e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801e54:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e57:	89 3c 24             	mov    %edi,(%esp)
  801e5a:	e8 da fd ff ff       	call   801c39 <fd2data>
  801e5f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801e61:	89 34 24             	mov    %esi,(%esp)
  801e64:	e8 d0 fd ff ff       	call   801c39 <fd2data>
  801e69:	83 c4 10             	add    $0x10,%esp
  801e6c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801e6f:	89 d8                	mov    %ebx,%eax
  801e71:	c1 e8 16             	shr    $0x16,%eax
  801e74:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e7b:	a8 01                	test   $0x1,%al
  801e7d:	74 11                	je     801e90 <dup+0x71>
  801e7f:	89 d8                	mov    %ebx,%eax
  801e81:	c1 e8 0c             	shr    $0xc,%eax
  801e84:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e8b:	f6 c2 01             	test   $0x1,%dl
  801e8e:	75 36                	jne    801ec6 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e90:	89 f8                	mov    %edi,%eax
  801e92:	c1 e8 0c             	shr    $0xc,%eax
  801e95:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e9c:	83 ec 0c             	sub    $0xc,%esp
  801e9f:	25 07 0e 00 00       	and    $0xe07,%eax
  801ea4:	50                   	push   %eax
  801ea5:	56                   	push   %esi
  801ea6:	6a 00                	push   $0x0
  801ea8:	57                   	push   %edi
  801ea9:	6a 00                	push   $0x0
  801eab:	e8 9d f7 ff ff       	call   80164d <sys_page_map>
  801eb0:	89 c3                	mov    %eax,%ebx
  801eb2:	83 c4 20             	add    $0x20,%esp
  801eb5:	85 c0                	test   %eax,%eax
  801eb7:	78 33                	js     801eec <dup+0xcd>
		goto err;

	return newfdnum;
  801eb9:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801ebc:	89 d8                	mov    %ebx,%eax
  801ebe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec1:	5b                   	pop    %ebx
  801ec2:	5e                   	pop    %esi
  801ec3:	5f                   	pop    %edi
  801ec4:	5d                   	pop    %ebp
  801ec5:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801ec6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ecd:	83 ec 0c             	sub    $0xc,%esp
  801ed0:	25 07 0e 00 00       	and    $0xe07,%eax
  801ed5:	50                   	push   %eax
  801ed6:	ff 75 d4             	push   -0x2c(%ebp)
  801ed9:	6a 00                	push   $0x0
  801edb:	53                   	push   %ebx
  801edc:	6a 00                	push   $0x0
  801ede:	e8 6a f7 ff ff       	call   80164d <sys_page_map>
  801ee3:	89 c3                	mov    %eax,%ebx
  801ee5:	83 c4 20             	add    $0x20,%esp
  801ee8:	85 c0                	test   %eax,%eax
  801eea:	79 a4                	jns    801e90 <dup+0x71>
	sys_page_unmap(0, newfd);
  801eec:	83 ec 08             	sub    $0x8,%esp
  801eef:	56                   	push   %esi
  801ef0:	6a 00                	push   $0x0
  801ef2:	e8 98 f7 ff ff       	call   80168f <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ef7:	83 c4 08             	add    $0x8,%esp
  801efa:	ff 75 d4             	push   -0x2c(%ebp)
  801efd:	6a 00                	push   $0x0
  801eff:	e8 8b f7 ff ff       	call   80168f <sys_page_unmap>
	return r;
  801f04:	83 c4 10             	add    $0x10,%esp
  801f07:	eb b3                	jmp    801ebc <dup+0x9d>

00801f09 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	56                   	push   %esi
  801f0d:	53                   	push   %ebx
  801f0e:	83 ec 18             	sub    $0x18,%esp
  801f11:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f14:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f17:	50                   	push   %eax
  801f18:	56                   	push   %esi
  801f19:	e8 82 fd ff ff       	call   801ca0 <fd_lookup>
  801f1e:	83 c4 10             	add    $0x10,%esp
  801f21:	85 c0                	test   %eax,%eax
  801f23:	78 3c                	js     801f61 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f25:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801f28:	83 ec 08             	sub    $0x8,%esp
  801f2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f2e:	50                   	push   %eax
  801f2f:	ff 33                	push   (%ebx)
  801f31:	e8 ba fd ff ff       	call   801cf0 <dev_lookup>
  801f36:	83 c4 10             	add    $0x10,%esp
  801f39:	85 c0                	test   %eax,%eax
  801f3b:	78 24                	js     801f61 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801f3d:	8b 43 08             	mov    0x8(%ebx),%eax
  801f40:	83 e0 03             	and    $0x3,%eax
  801f43:	83 f8 01             	cmp    $0x1,%eax
  801f46:	74 20                	je     801f68 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f4b:	8b 40 08             	mov    0x8(%eax),%eax
  801f4e:	85 c0                	test   %eax,%eax
  801f50:	74 37                	je     801f89 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801f52:	83 ec 04             	sub    $0x4,%esp
  801f55:	ff 75 10             	push   0x10(%ebp)
  801f58:	ff 75 0c             	push   0xc(%ebp)
  801f5b:	53                   	push   %ebx
  801f5c:	ff d0                	call   *%eax
  801f5e:	83 c4 10             	add    $0x10,%esp
}
  801f61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f64:	5b                   	pop    %ebx
  801f65:	5e                   	pop    %esi
  801f66:	5d                   	pop    %ebp
  801f67:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801f68:	a1 14 60 80 00       	mov    0x806014,%eax
  801f6d:	8b 40 48             	mov    0x48(%eax),%eax
  801f70:	83 ec 04             	sub    $0x4,%esp
  801f73:	56                   	push   %esi
  801f74:	50                   	push   %eax
  801f75:	68 e9 3d 80 00       	push   $0x803de9
  801f7a:	e8 c5 eb ff ff       	call   800b44 <cprintf>
		return -E_INVAL;
  801f7f:	83 c4 10             	add    $0x10,%esp
  801f82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f87:	eb d8                	jmp    801f61 <read+0x58>
		return -E_NOT_SUPP;
  801f89:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801f8e:	eb d1                	jmp    801f61 <read+0x58>

00801f90 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	57                   	push   %edi
  801f94:	56                   	push   %esi
  801f95:	53                   	push   %ebx
  801f96:	83 ec 0c             	sub    $0xc,%esp
  801f99:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f9c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fa4:	eb 02                	jmp    801fa8 <readn+0x18>
  801fa6:	01 c3                	add    %eax,%ebx
  801fa8:	39 f3                	cmp    %esi,%ebx
  801faa:	73 21                	jae    801fcd <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801fac:	83 ec 04             	sub    $0x4,%esp
  801faf:	89 f0                	mov    %esi,%eax
  801fb1:	29 d8                	sub    %ebx,%eax
  801fb3:	50                   	push   %eax
  801fb4:	89 d8                	mov    %ebx,%eax
  801fb6:	03 45 0c             	add    0xc(%ebp),%eax
  801fb9:	50                   	push   %eax
  801fba:	57                   	push   %edi
  801fbb:	e8 49 ff ff ff       	call   801f09 <read>
		if (m < 0)
  801fc0:	83 c4 10             	add    $0x10,%esp
  801fc3:	85 c0                	test   %eax,%eax
  801fc5:	78 04                	js     801fcb <readn+0x3b>
			return m;
		if (m == 0)
  801fc7:	75 dd                	jne    801fa6 <readn+0x16>
  801fc9:	eb 02                	jmp    801fcd <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801fcb:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801fcd:	89 d8                	mov    %ebx,%eax
  801fcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd2:	5b                   	pop    %ebx
  801fd3:	5e                   	pop    %esi
  801fd4:	5f                   	pop    %edi
  801fd5:	5d                   	pop    %ebp
  801fd6:	c3                   	ret    

00801fd7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801fd7:	55                   	push   %ebp
  801fd8:	89 e5                	mov    %esp,%ebp
  801fda:	56                   	push   %esi
  801fdb:	53                   	push   %ebx
  801fdc:	83 ec 18             	sub    $0x18,%esp
  801fdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fe2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fe5:	50                   	push   %eax
  801fe6:	53                   	push   %ebx
  801fe7:	e8 b4 fc ff ff       	call   801ca0 <fd_lookup>
  801fec:	83 c4 10             	add    $0x10,%esp
  801fef:	85 c0                	test   %eax,%eax
  801ff1:	78 37                	js     80202a <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ff3:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801ff6:	83 ec 08             	sub    $0x8,%esp
  801ff9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ffc:	50                   	push   %eax
  801ffd:	ff 36                	push   (%esi)
  801fff:	e8 ec fc ff ff       	call   801cf0 <dev_lookup>
  802004:	83 c4 10             	add    $0x10,%esp
  802007:	85 c0                	test   %eax,%eax
  802009:	78 1f                	js     80202a <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80200b:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80200f:	74 20                	je     802031 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802011:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802014:	8b 40 0c             	mov    0xc(%eax),%eax
  802017:	85 c0                	test   %eax,%eax
  802019:	74 37                	je     802052 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80201b:	83 ec 04             	sub    $0x4,%esp
  80201e:	ff 75 10             	push   0x10(%ebp)
  802021:	ff 75 0c             	push   0xc(%ebp)
  802024:	56                   	push   %esi
  802025:	ff d0                	call   *%eax
  802027:	83 c4 10             	add    $0x10,%esp
}
  80202a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80202d:	5b                   	pop    %ebx
  80202e:	5e                   	pop    %esi
  80202f:	5d                   	pop    %ebp
  802030:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802031:	a1 14 60 80 00       	mov    0x806014,%eax
  802036:	8b 40 48             	mov    0x48(%eax),%eax
  802039:	83 ec 04             	sub    $0x4,%esp
  80203c:	53                   	push   %ebx
  80203d:	50                   	push   %eax
  80203e:	68 05 3e 80 00       	push   $0x803e05
  802043:	e8 fc ea ff ff       	call   800b44 <cprintf>
		return -E_INVAL;
  802048:	83 c4 10             	add    $0x10,%esp
  80204b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802050:	eb d8                	jmp    80202a <write+0x53>
		return -E_NOT_SUPP;
  802052:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802057:	eb d1                	jmp    80202a <write+0x53>

00802059 <seek>:

int
seek(int fdnum, off_t offset)
{
  802059:	55                   	push   %ebp
  80205a:	89 e5                	mov    %esp,%ebp
  80205c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80205f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802062:	50                   	push   %eax
  802063:	ff 75 08             	push   0x8(%ebp)
  802066:	e8 35 fc ff ff       	call   801ca0 <fd_lookup>
  80206b:	83 c4 10             	add    $0x10,%esp
  80206e:	85 c0                	test   %eax,%eax
  802070:	78 0e                	js     802080 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802072:	8b 55 0c             	mov    0xc(%ebp),%edx
  802075:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802078:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80207b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802080:	c9                   	leave  
  802081:	c3                   	ret    

00802082 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802082:	55                   	push   %ebp
  802083:	89 e5                	mov    %esp,%ebp
  802085:	56                   	push   %esi
  802086:	53                   	push   %ebx
  802087:	83 ec 18             	sub    $0x18,%esp
  80208a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80208d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802090:	50                   	push   %eax
  802091:	53                   	push   %ebx
  802092:	e8 09 fc ff ff       	call   801ca0 <fd_lookup>
  802097:	83 c4 10             	add    $0x10,%esp
  80209a:	85 c0                	test   %eax,%eax
  80209c:	78 34                	js     8020d2 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80209e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8020a1:	83 ec 08             	sub    $0x8,%esp
  8020a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a7:	50                   	push   %eax
  8020a8:	ff 36                	push   (%esi)
  8020aa:	e8 41 fc ff ff       	call   801cf0 <dev_lookup>
  8020af:	83 c4 10             	add    $0x10,%esp
  8020b2:	85 c0                	test   %eax,%eax
  8020b4:	78 1c                	js     8020d2 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8020b6:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8020ba:	74 1d                	je     8020d9 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8020bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020bf:	8b 40 18             	mov    0x18(%eax),%eax
  8020c2:	85 c0                	test   %eax,%eax
  8020c4:	74 34                	je     8020fa <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8020c6:	83 ec 08             	sub    $0x8,%esp
  8020c9:	ff 75 0c             	push   0xc(%ebp)
  8020cc:	56                   	push   %esi
  8020cd:	ff d0                	call   *%eax
  8020cf:	83 c4 10             	add    $0x10,%esp
}
  8020d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020d5:	5b                   	pop    %ebx
  8020d6:	5e                   	pop    %esi
  8020d7:	5d                   	pop    %ebp
  8020d8:	c3                   	ret    
			thisenv->env_id, fdnum);
  8020d9:	a1 14 60 80 00       	mov    0x806014,%eax
  8020de:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8020e1:	83 ec 04             	sub    $0x4,%esp
  8020e4:	53                   	push   %ebx
  8020e5:	50                   	push   %eax
  8020e6:	68 c8 3d 80 00       	push   $0x803dc8
  8020eb:	e8 54 ea ff ff       	call   800b44 <cprintf>
		return -E_INVAL;
  8020f0:	83 c4 10             	add    $0x10,%esp
  8020f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8020f8:	eb d8                	jmp    8020d2 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8020fa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8020ff:	eb d1                	jmp    8020d2 <ftruncate+0x50>

00802101 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802101:	55                   	push   %ebp
  802102:	89 e5                	mov    %esp,%ebp
  802104:	56                   	push   %esi
  802105:	53                   	push   %ebx
  802106:	83 ec 18             	sub    $0x18,%esp
  802109:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80210c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80210f:	50                   	push   %eax
  802110:	ff 75 08             	push   0x8(%ebp)
  802113:	e8 88 fb ff ff       	call   801ca0 <fd_lookup>
  802118:	83 c4 10             	add    $0x10,%esp
  80211b:	85 c0                	test   %eax,%eax
  80211d:	78 49                	js     802168 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80211f:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802122:	83 ec 08             	sub    $0x8,%esp
  802125:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802128:	50                   	push   %eax
  802129:	ff 36                	push   (%esi)
  80212b:	e8 c0 fb ff ff       	call   801cf0 <dev_lookup>
  802130:	83 c4 10             	add    $0x10,%esp
  802133:	85 c0                	test   %eax,%eax
  802135:	78 31                	js     802168 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  802137:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80213e:	74 2f                	je     80216f <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802140:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802143:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80214a:	00 00 00 
	stat->st_isdir = 0;
  80214d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802154:	00 00 00 
	stat->st_dev = dev;
  802157:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80215d:	83 ec 08             	sub    $0x8,%esp
  802160:	53                   	push   %ebx
  802161:	56                   	push   %esi
  802162:	ff 50 14             	call   *0x14(%eax)
  802165:	83 c4 10             	add    $0x10,%esp
}
  802168:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80216b:	5b                   	pop    %ebx
  80216c:	5e                   	pop    %esi
  80216d:	5d                   	pop    %ebp
  80216e:	c3                   	ret    
		return -E_NOT_SUPP;
  80216f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802174:	eb f2                	jmp    802168 <fstat+0x67>

00802176 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802176:	55                   	push   %ebp
  802177:	89 e5                	mov    %esp,%ebp
  802179:	56                   	push   %esi
  80217a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80217b:	83 ec 08             	sub    $0x8,%esp
  80217e:	6a 00                	push   $0x0
  802180:	ff 75 08             	push   0x8(%ebp)
  802183:	e8 e4 01 00 00       	call   80236c <open>
  802188:	89 c3                	mov    %eax,%ebx
  80218a:	83 c4 10             	add    $0x10,%esp
  80218d:	85 c0                	test   %eax,%eax
  80218f:	78 1b                	js     8021ac <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802191:	83 ec 08             	sub    $0x8,%esp
  802194:	ff 75 0c             	push   0xc(%ebp)
  802197:	50                   	push   %eax
  802198:	e8 64 ff ff ff       	call   802101 <fstat>
  80219d:	89 c6                	mov    %eax,%esi
	close(fd);
  80219f:	89 1c 24             	mov    %ebx,(%esp)
  8021a2:	e8 26 fc ff ff       	call   801dcd <close>
	return r;
  8021a7:	83 c4 10             	add    $0x10,%esp
  8021aa:	89 f3                	mov    %esi,%ebx
}
  8021ac:	89 d8                	mov    %ebx,%eax
  8021ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021b1:	5b                   	pop    %ebx
  8021b2:	5e                   	pop    %esi
  8021b3:	5d                   	pop    %ebp
  8021b4:	c3                   	ret    

008021b5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8021b5:	55                   	push   %ebp
  8021b6:	89 e5                	mov    %esp,%ebp
  8021b8:	56                   	push   %esi
  8021b9:	53                   	push   %ebx
  8021ba:	89 c6                	mov    %eax,%esi
  8021bc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8021be:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8021c5:	74 27                	je     8021ee <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8021c7:	6a 07                	push   $0x7
  8021c9:	68 00 70 80 00       	push   $0x807000
  8021ce:	56                   	push   %esi
  8021cf:	ff 35 00 80 80 00    	push   0x808000
  8021d5:	e8 60 12 00 00       	call   80343a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8021da:	83 c4 0c             	add    $0xc,%esp
  8021dd:	6a 00                	push   $0x0
  8021df:	53                   	push   %ebx
  8021e0:	6a 00                	push   $0x0
  8021e2:	e8 ec 11 00 00       	call   8033d3 <ipc_recv>
}
  8021e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021ea:	5b                   	pop    %ebx
  8021eb:	5e                   	pop    %esi
  8021ec:	5d                   	pop    %ebp
  8021ed:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8021ee:	83 ec 0c             	sub    $0xc,%esp
  8021f1:	6a 01                	push   $0x1
  8021f3:	e8 96 12 00 00       	call   80348e <ipc_find_env>
  8021f8:	a3 00 80 80 00       	mov    %eax,0x808000
  8021fd:	83 c4 10             	add    $0x10,%esp
  802200:	eb c5                	jmp    8021c7 <fsipc+0x12>

00802202 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802202:	55                   	push   %ebp
  802203:	89 e5                	mov    %esp,%ebp
  802205:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802208:	8b 45 08             	mov    0x8(%ebp),%eax
  80220b:	8b 40 0c             	mov    0xc(%eax),%eax
  80220e:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  802213:	8b 45 0c             	mov    0xc(%ebp),%eax
  802216:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80221b:	ba 00 00 00 00       	mov    $0x0,%edx
  802220:	b8 02 00 00 00       	mov    $0x2,%eax
  802225:	e8 8b ff ff ff       	call   8021b5 <fsipc>
}
  80222a:	c9                   	leave  
  80222b:	c3                   	ret    

0080222c <devfile_flush>:
{
  80222c:	55                   	push   %ebp
  80222d:	89 e5                	mov    %esp,%ebp
  80222f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802232:	8b 45 08             	mov    0x8(%ebp),%eax
  802235:	8b 40 0c             	mov    0xc(%eax),%eax
  802238:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  80223d:	ba 00 00 00 00       	mov    $0x0,%edx
  802242:	b8 06 00 00 00       	mov    $0x6,%eax
  802247:	e8 69 ff ff ff       	call   8021b5 <fsipc>
}
  80224c:	c9                   	leave  
  80224d:	c3                   	ret    

0080224e <devfile_stat>:
{
  80224e:	55                   	push   %ebp
  80224f:	89 e5                	mov    %esp,%ebp
  802251:	53                   	push   %ebx
  802252:	83 ec 04             	sub    $0x4,%esp
  802255:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802258:	8b 45 08             	mov    0x8(%ebp),%eax
  80225b:	8b 40 0c             	mov    0xc(%eax),%eax
  80225e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802263:	ba 00 00 00 00       	mov    $0x0,%edx
  802268:	b8 05 00 00 00       	mov    $0x5,%eax
  80226d:	e8 43 ff ff ff       	call   8021b5 <fsipc>
  802272:	85 c0                	test   %eax,%eax
  802274:	78 2c                	js     8022a2 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802276:	83 ec 08             	sub    $0x8,%esp
  802279:	68 00 70 80 00       	push   $0x807000
  80227e:	53                   	push   %ebx
  80227f:	e8 8a ef ff ff       	call   80120e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802284:	a1 80 70 80 00       	mov    0x807080,%eax
  802289:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80228f:	a1 84 70 80 00       	mov    0x807084,%eax
  802294:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80229a:	83 c4 10             	add    $0x10,%esp
  80229d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022a5:	c9                   	leave  
  8022a6:	c3                   	ret    

008022a7 <devfile_write>:
{
  8022a7:	55                   	push   %ebp
  8022a8:	89 e5                	mov    %esp,%ebp
  8022aa:	83 ec 0c             	sub    $0xc,%esp
  8022ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8022b0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8022b5:	39 d0                	cmp    %edx,%eax
  8022b7:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8022ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8022bd:	8b 52 0c             	mov    0xc(%edx),%edx
  8022c0:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  8022c6:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8022cb:	50                   	push   %eax
  8022cc:	ff 75 0c             	push   0xc(%ebp)
  8022cf:	68 08 70 80 00       	push   $0x807008
  8022d4:	e8 cb f0 ff ff       	call   8013a4 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8022d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8022de:	b8 04 00 00 00       	mov    $0x4,%eax
  8022e3:	e8 cd fe ff ff       	call   8021b5 <fsipc>
}
  8022e8:	c9                   	leave  
  8022e9:	c3                   	ret    

008022ea <devfile_read>:
{
  8022ea:	55                   	push   %ebp
  8022eb:	89 e5                	mov    %esp,%ebp
  8022ed:	56                   	push   %esi
  8022ee:	53                   	push   %ebx
  8022ef:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8022f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8022f8:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8022fd:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802303:	ba 00 00 00 00       	mov    $0x0,%edx
  802308:	b8 03 00 00 00       	mov    $0x3,%eax
  80230d:	e8 a3 fe ff ff       	call   8021b5 <fsipc>
  802312:	89 c3                	mov    %eax,%ebx
  802314:	85 c0                	test   %eax,%eax
  802316:	78 1f                	js     802337 <devfile_read+0x4d>
	assert(r <= n);
  802318:	39 f0                	cmp    %esi,%eax
  80231a:	77 24                	ja     802340 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80231c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802321:	7f 33                	jg     802356 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802323:	83 ec 04             	sub    $0x4,%esp
  802326:	50                   	push   %eax
  802327:	68 00 70 80 00       	push   $0x807000
  80232c:	ff 75 0c             	push   0xc(%ebp)
  80232f:	e8 70 f0 ff ff       	call   8013a4 <memmove>
	return r;
  802334:	83 c4 10             	add    $0x10,%esp
}
  802337:	89 d8                	mov    %ebx,%eax
  802339:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80233c:	5b                   	pop    %ebx
  80233d:	5e                   	pop    %esi
  80233e:	5d                   	pop    %ebp
  80233f:	c3                   	ret    
	assert(r <= n);
  802340:	68 38 3e 80 00       	push   $0x803e38
  802345:	68 a6 38 80 00       	push   $0x8038a6
  80234a:	6a 7c                	push   $0x7c
  80234c:	68 3f 3e 80 00       	push   $0x803e3f
  802351:	e8 13 e7 ff ff       	call   800a69 <_panic>
	assert(r <= PGSIZE);
  802356:	68 4a 3e 80 00       	push   $0x803e4a
  80235b:	68 a6 38 80 00       	push   $0x8038a6
  802360:	6a 7d                	push   $0x7d
  802362:	68 3f 3e 80 00       	push   $0x803e3f
  802367:	e8 fd e6 ff ff       	call   800a69 <_panic>

0080236c <open>:
{
  80236c:	55                   	push   %ebp
  80236d:	89 e5                	mov    %esp,%ebp
  80236f:	56                   	push   %esi
  802370:	53                   	push   %ebx
  802371:	83 ec 1c             	sub    $0x1c,%esp
  802374:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  802377:	56                   	push   %esi
  802378:	e8 56 ee ff ff       	call   8011d3 <strlen>
  80237d:	83 c4 10             	add    $0x10,%esp
  802380:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802385:	7f 6c                	jg     8023f3 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  802387:	83 ec 0c             	sub    $0xc,%esp
  80238a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80238d:	50                   	push   %eax
  80238e:	e8 bd f8 ff ff       	call   801c50 <fd_alloc>
  802393:	89 c3                	mov    %eax,%ebx
  802395:	83 c4 10             	add    $0x10,%esp
  802398:	85 c0                	test   %eax,%eax
  80239a:	78 3c                	js     8023d8 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80239c:	83 ec 08             	sub    $0x8,%esp
  80239f:	56                   	push   %esi
  8023a0:	68 00 70 80 00       	push   $0x807000
  8023a5:	e8 64 ee ff ff       	call   80120e <strcpy>
	fsipcbuf.open.req_omode = mode;
  8023aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023ad:	a3 00 74 80 00       	mov    %eax,0x807400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8023b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8023ba:	e8 f6 fd ff ff       	call   8021b5 <fsipc>
  8023bf:	89 c3                	mov    %eax,%ebx
  8023c1:	83 c4 10             	add    $0x10,%esp
  8023c4:	85 c0                	test   %eax,%eax
  8023c6:	78 19                	js     8023e1 <open+0x75>
	return fd2num(fd);
  8023c8:	83 ec 0c             	sub    $0xc,%esp
  8023cb:	ff 75 f4             	push   -0xc(%ebp)
  8023ce:	e8 56 f8 ff ff       	call   801c29 <fd2num>
  8023d3:	89 c3                	mov    %eax,%ebx
  8023d5:	83 c4 10             	add    $0x10,%esp
}
  8023d8:	89 d8                	mov    %ebx,%eax
  8023da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023dd:	5b                   	pop    %ebx
  8023de:	5e                   	pop    %esi
  8023df:	5d                   	pop    %ebp
  8023e0:	c3                   	ret    
		fd_close(fd, 0);
  8023e1:	83 ec 08             	sub    $0x8,%esp
  8023e4:	6a 00                	push   $0x0
  8023e6:	ff 75 f4             	push   -0xc(%ebp)
  8023e9:	e8 58 f9 ff ff       	call   801d46 <fd_close>
		return r;
  8023ee:	83 c4 10             	add    $0x10,%esp
  8023f1:	eb e5                	jmp    8023d8 <open+0x6c>
		return -E_BAD_PATH;
  8023f3:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8023f8:	eb de                	jmp    8023d8 <open+0x6c>

008023fa <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8023fa:	55                   	push   %ebp
  8023fb:	89 e5                	mov    %esp,%ebp
  8023fd:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802400:	ba 00 00 00 00       	mov    $0x0,%edx
  802405:	b8 08 00 00 00       	mov    $0x8,%eax
  80240a:	e8 a6 fd ff ff       	call   8021b5 <fsipc>
}
  80240f:	c9                   	leave  
  802410:	c3                   	ret    

00802411 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  802411:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802415:	7f 01                	jg     802418 <writebuf+0x7>
  802417:	c3                   	ret    
{
  802418:	55                   	push   %ebp
  802419:	89 e5                	mov    %esp,%ebp
  80241b:	53                   	push   %ebx
  80241c:	83 ec 08             	sub    $0x8,%esp
  80241f:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  802421:	ff 70 04             	push   0x4(%eax)
  802424:	8d 40 10             	lea    0x10(%eax),%eax
  802427:	50                   	push   %eax
  802428:	ff 33                	push   (%ebx)
  80242a:	e8 a8 fb ff ff       	call   801fd7 <write>
		if (result > 0)
  80242f:	83 c4 10             	add    $0x10,%esp
  802432:	85 c0                	test   %eax,%eax
  802434:	7e 03                	jle    802439 <writebuf+0x28>
			b->result += result;
  802436:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  802439:	39 43 04             	cmp    %eax,0x4(%ebx)
  80243c:	74 0d                	je     80244b <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  80243e:	85 c0                	test   %eax,%eax
  802440:	ba 00 00 00 00       	mov    $0x0,%edx
  802445:	0f 4f c2             	cmovg  %edx,%eax
  802448:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80244b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80244e:	c9                   	leave  
  80244f:	c3                   	ret    

00802450 <putch>:

static void
putch(int ch, void *thunk)
{
  802450:	55                   	push   %ebp
  802451:	89 e5                	mov    %esp,%ebp
  802453:	53                   	push   %ebx
  802454:	83 ec 04             	sub    $0x4,%esp
  802457:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80245a:	8b 53 04             	mov    0x4(%ebx),%edx
  80245d:	8d 42 01             	lea    0x1(%edx),%eax
  802460:	89 43 04             	mov    %eax,0x4(%ebx)
  802463:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802466:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80246a:	3d 00 01 00 00       	cmp    $0x100,%eax
  80246f:	74 05                	je     802476 <putch+0x26>
		writebuf(b);
		b->idx = 0;
	}
}
  802471:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802474:	c9                   	leave  
  802475:	c3                   	ret    
		writebuf(b);
  802476:	89 d8                	mov    %ebx,%eax
  802478:	e8 94 ff ff ff       	call   802411 <writebuf>
		b->idx = 0;
  80247d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  802484:	eb eb                	jmp    802471 <putch+0x21>

00802486 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  802486:	55                   	push   %ebp
  802487:	89 e5                	mov    %esp,%ebp
  802489:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80248f:	8b 45 08             	mov    0x8(%ebp),%eax
  802492:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802498:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80249f:	00 00 00 
	b.result = 0;
  8024a2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8024a9:	00 00 00 
	b.error = 1;
  8024ac:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8024b3:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8024b6:	ff 75 10             	push   0x10(%ebp)
  8024b9:	ff 75 0c             	push   0xc(%ebp)
  8024bc:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024c2:	50                   	push   %eax
  8024c3:	68 50 24 80 00       	push   $0x802450
  8024c8:	e8 6e e7 ff ff       	call   800c3b <vprintfmt>
	if (b.idx > 0)
  8024cd:	83 c4 10             	add    $0x10,%esp
  8024d0:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8024d7:	7f 11                	jg     8024ea <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  8024d9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8024df:	85 c0                	test   %eax,%eax
  8024e1:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8024e8:	c9                   	leave  
  8024e9:	c3                   	ret    
		writebuf(&b);
  8024ea:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024f0:	e8 1c ff ff ff       	call   802411 <writebuf>
  8024f5:	eb e2                	jmp    8024d9 <vfprintf+0x53>

008024f7 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8024f7:	55                   	push   %ebp
  8024f8:	89 e5                	mov    %esp,%ebp
  8024fa:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024fd:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802500:	50                   	push   %eax
  802501:	ff 75 0c             	push   0xc(%ebp)
  802504:	ff 75 08             	push   0x8(%ebp)
  802507:	e8 7a ff ff ff       	call   802486 <vfprintf>
	va_end(ap);

	return cnt;
}
  80250c:	c9                   	leave  
  80250d:	c3                   	ret    

0080250e <printf>:

int
printf(const char *fmt, ...)
{
  80250e:	55                   	push   %ebp
  80250f:	89 e5                	mov    %esp,%ebp
  802511:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802514:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802517:	50                   	push   %eax
  802518:	ff 75 08             	push   0x8(%ebp)
  80251b:	6a 01                	push   $0x1
  80251d:	e8 64 ff ff ff       	call   802486 <vfprintf>
	va_end(ap);

	return cnt;
}
  802522:	c9                   	leave  
  802523:	c3                   	ret    

00802524 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  802524:	55                   	push   %ebp
  802525:	89 e5                	mov    %esp,%ebp
  802527:	57                   	push   %edi
  802528:	56                   	push   %esi
  802529:	53                   	push   %ebx
  80252a:	81 ec 84 02 00 00    	sub    $0x284,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  802530:	6a 00                	push   $0x0
  802532:	ff 75 08             	push   0x8(%ebp)
  802535:	e8 32 fe ff ff       	call   80236c <open>
  80253a:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802540:	83 c4 10             	add    $0x10,%esp
  802543:	85 c0                	test   %eax,%eax
  802545:	0f 88 aa 04 00 00    	js     8029f5 <spawn+0x4d1>
  80254b:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80254d:	83 ec 04             	sub    $0x4,%esp
  802550:	68 00 02 00 00       	push   $0x200
  802555:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80255b:	50                   	push   %eax
  80255c:	57                   	push   %edi
  80255d:	e8 2e fa ff ff       	call   801f90 <readn>
  802562:	83 c4 10             	add    $0x10,%esp
  802565:	3d 00 02 00 00       	cmp    $0x200,%eax
  80256a:	75 57                	jne    8025c3 <spawn+0x9f>
	    || elf->e_magic != ELF_MAGIC) {
  80256c:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802573:	45 4c 46 
  802576:	75 4b                	jne    8025c3 <spawn+0x9f>
  802578:	b8 07 00 00 00       	mov    $0x7,%eax
  80257d:	cd 30                	int    $0x30
  80257f:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802585:	85 c0                	test   %eax,%eax
  802587:	0f 88 5c 04 00 00    	js     8029e9 <spawn+0x4c5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80258d:	25 ff 03 00 00       	and    $0x3ff,%eax
  802592:	6b f0 7c             	imul   $0x7c,%eax,%esi
  802595:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80259b:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8025a1:	b9 11 00 00 00       	mov    $0x11,%ecx
  8025a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8025a8:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8025ae:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025b4:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  8025b9:	be 00 00 00 00       	mov    $0x0,%esi
  8025be:	8b 7d 0c             	mov    0xc(%ebp),%edi
	for (argc = 0; argv[argc] != 0; argc++)
  8025c1:	eb 4b                	jmp    80260e <spawn+0xea>
		close(fd);
  8025c3:	83 ec 0c             	sub    $0xc,%esp
  8025c6:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  8025cc:	e8 fc f7 ff ff       	call   801dcd <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8025d1:	83 c4 0c             	add    $0xc,%esp
  8025d4:	68 7f 45 4c 46       	push   $0x464c457f
  8025d9:	ff b5 e8 fd ff ff    	push   -0x218(%ebp)
  8025df:	68 56 3e 80 00       	push   $0x803e56
  8025e4:	e8 5b e5 ff ff       	call   800b44 <cprintf>
		return -E_NOT_EXEC;
  8025e9:	83 c4 10             	add    $0x10,%esp
  8025ec:	c7 85 8c fd ff ff f2 	movl   $0xfffffff2,-0x274(%ebp)
  8025f3:	ff ff ff 
  8025f6:	e9 fa 03 00 00       	jmp    8029f5 <spawn+0x4d1>
		string_size += strlen(argv[argc]) + 1;
  8025fb:	83 ec 0c             	sub    $0xc,%esp
  8025fe:	50                   	push   %eax
  8025ff:	e8 cf eb ff ff       	call   8011d3 <strlen>
  802604:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  802608:	83 c3 01             	add    $0x1,%ebx
  80260b:	83 c4 10             	add    $0x10,%esp
  80260e:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  802615:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  802618:	85 c0                	test   %eax,%eax
  80261a:	75 df                	jne    8025fb <spawn+0xd7>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80261c:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  802622:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  802628:	b8 00 10 40 00       	mov    $0x401000,%eax
  80262d:	29 f0                	sub    %esi,%eax
  80262f:	89 c7                	mov    %eax,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802631:	89 c2                	mov    %eax,%edx
  802633:	83 e2 fc             	and    $0xfffffffc,%edx
  802636:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80263d:	29 c2                	sub    %eax,%edx
  80263f:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802645:	8d 42 f8             	lea    -0x8(%edx),%eax
  802648:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80264d:	0f 86 14 04 00 00    	jbe    802a67 <spawn+0x543>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802653:	83 ec 04             	sub    $0x4,%esp
  802656:	6a 07                	push   $0x7
  802658:	68 00 00 40 00       	push   $0x400000
  80265d:	6a 00                	push   $0x0
  80265f:	e8 a6 ef ff ff       	call   80160a <sys_page_alloc>
  802664:	83 c4 10             	add    $0x10,%esp
  802667:	85 c0                	test   %eax,%eax
  802669:	0f 88 fd 03 00 00    	js     802a6c <spawn+0x548>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80266f:	be 00 00 00 00       	mov    $0x0,%esi
  802674:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80267a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80267d:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  802683:	7e 32                	jle    8026b7 <spawn+0x193>
		argv_store[i] = UTEMP2USTACK(string_store);
  802685:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80268b:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802691:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  802694:	83 ec 08             	sub    $0x8,%esp
  802697:	ff 34 b3             	push   (%ebx,%esi,4)
  80269a:	57                   	push   %edi
  80269b:	e8 6e eb ff ff       	call   80120e <strcpy>
		string_store += strlen(argv[i]) + 1;
  8026a0:	83 c4 04             	add    $0x4,%esp
  8026a3:	ff 34 b3             	push   (%ebx,%esi,4)
  8026a6:	e8 28 eb ff ff       	call   8011d3 <strlen>
  8026ab:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  8026af:	83 c6 01             	add    $0x1,%esi
  8026b2:	83 c4 10             	add    $0x10,%esp
  8026b5:	eb c6                	jmp    80267d <spawn+0x159>
	}
	argv_store[argc] = 0;
  8026b7:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8026bd:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8026c3:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8026ca:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8026d0:	0f 85 8c 00 00 00    	jne    802762 <spawn+0x23e>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8026d6:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8026dc:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  8026e2:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  8026e5:	89 c8                	mov    %ecx,%eax
  8026e7:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  8026ed:	89 79 f8             	mov    %edi,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8026f0:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8026f5:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8026fb:	83 ec 0c             	sub    $0xc,%esp
  8026fe:	6a 07                	push   $0x7
  802700:	68 00 d0 bf ee       	push   $0xeebfd000
  802705:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  80270b:	68 00 00 40 00       	push   $0x400000
  802710:	6a 00                	push   $0x0
  802712:	e8 36 ef ff ff       	call   80164d <sys_page_map>
  802717:	89 c3                	mov    %eax,%ebx
  802719:	83 c4 20             	add    $0x20,%esp
  80271c:	85 c0                	test   %eax,%eax
  80271e:	0f 88 50 03 00 00    	js     802a74 <spawn+0x550>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802724:	83 ec 08             	sub    $0x8,%esp
  802727:	68 00 00 40 00       	push   $0x400000
  80272c:	6a 00                	push   $0x0
  80272e:	e8 5c ef ff ff       	call   80168f <sys_page_unmap>
  802733:	89 c3                	mov    %eax,%ebx
  802735:	83 c4 10             	add    $0x10,%esp
  802738:	85 c0                	test   %eax,%eax
  80273a:	0f 88 34 03 00 00    	js     802a74 <spawn+0x550>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802740:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802746:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80274d:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802753:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  80275a:	00 00 00 
  80275d:	e9 4e 01 00 00       	jmp    8028b0 <spawn+0x38c>
	assert(string_store == (char*)UTEMP + PGSIZE);
  802762:	68 e0 3e 80 00       	push   $0x803ee0
  802767:	68 a6 38 80 00       	push   $0x8038a6
  80276c:	68 f2 00 00 00       	push   $0xf2
  802771:	68 70 3e 80 00       	push   $0x803e70
  802776:	e8 ee e2 ff ff       	call   800a69 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80277b:	83 ec 04             	sub    $0x4,%esp
  80277e:	6a 07                	push   $0x7
  802780:	68 00 00 40 00       	push   $0x400000
  802785:	6a 00                	push   $0x0
  802787:	e8 7e ee ff ff       	call   80160a <sys_page_alloc>
  80278c:	83 c4 10             	add    $0x10,%esp
  80278f:	85 c0                	test   %eax,%eax
  802791:	0f 88 6c 02 00 00    	js     802a03 <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802797:	83 ec 08             	sub    $0x8,%esp
  80279a:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8027a0:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8027a6:	50                   	push   %eax
  8027a7:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  8027ad:	e8 a7 f8 ff ff       	call   802059 <seek>
  8027b2:	83 c4 10             	add    $0x10,%esp
  8027b5:	85 c0                	test   %eax,%eax
  8027b7:	0f 88 4d 02 00 00    	js     802a0a <spawn+0x4e6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8027bd:	83 ec 04             	sub    $0x4,%esp
  8027c0:	89 f8                	mov    %edi,%eax
  8027c2:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8027c8:	ba 00 10 00 00       	mov    $0x1000,%edx
  8027cd:	39 d0                	cmp    %edx,%eax
  8027cf:	0f 47 c2             	cmova  %edx,%eax
  8027d2:	50                   	push   %eax
  8027d3:	68 00 00 40 00       	push   $0x400000
  8027d8:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  8027de:	e8 ad f7 ff ff       	call   801f90 <readn>
  8027e3:	83 c4 10             	add    $0x10,%esp
  8027e6:	85 c0                	test   %eax,%eax
  8027e8:	0f 88 23 02 00 00    	js     802a11 <spawn+0x4ed>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8027ee:	83 ec 0c             	sub    $0xc,%esp
  8027f1:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  8027f7:	56                   	push   %esi
  8027f8:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  8027fe:	68 00 00 40 00       	push   $0x400000
  802803:	6a 00                	push   $0x0
  802805:	e8 43 ee ff ff       	call   80164d <sys_page_map>
  80280a:	83 c4 20             	add    $0x20,%esp
  80280d:	85 c0                	test   %eax,%eax
  80280f:	78 7c                	js     80288d <spawn+0x369>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  802811:	83 ec 08             	sub    $0x8,%esp
  802814:	68 00 00 40 00       	push   $0x400000
  802819:	6a 00                	push   $0x0
  80281b:	e8 6f ee ff ff       	call   80168f <sys_page_unmap>
  802820:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  802823:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802829:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80282f:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802835:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  80283b:	76 65                	jbe    8028a2 <spawn+0x37e>
		if (i >= filesz) {
  80283d:	39 df                	cmp    %ebx,%edi
  80283f:	0f 87 36 ff ff ff    	ja     80277b <spawn+0x257>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802845:	83 ec 04             	sub    $0x4,%esp
  802848:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  80284e:	56                   	push   %esi
  80284f:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  802855:	e8 b0 ed ff ff       	call   80160a <sys_page_alloc>
  80285a:	83 c4 10             	add    $0x10,%esp
  80285d:	85 c0                	test   %eax,%eax
  80285f:	79 c2                	jns    802823 <spawn+0x2ff>
  802861:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  802863:	83 ec 0c             	sub    $0xc,%esp
  802866:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  80286c:	e8 1a ed ff ff       	call   80158b <sys_env_destroy>
	close(fd);
  802871:	83 c4 04             	add    $0x4,%esp
  802874:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  80287a:	e8 4e f5 ff ff       	call   801dcd <close>
	return r;
  80287f:	83 c4 10             	add    $0x10,%esp
  802882:	89 bd 8c fd ff ff    	mov    %edi,-0x274(%ebp)
  802888:	e9 68 01 00 00       	jmp    8029f5 <spawn+0x4d1>
				panic("spawn: sys_page_map data: %e", r);
  80288d:	50                   	push   %eax
  80288e:	68 7c 3e 80 00       	push   $0x803e7c
  802893:	68 25 01 00 00       	push   $0x125
  802898:	68 70 3e 80 00       	push   $0x803e70
  80289d:	e8 c7 e1 ff ff       	call   800a69 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8028a2:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  8028a9:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  8028b0:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8028b7:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  8028bd:	7e 67                	jle    802926 <spawn+0x402>
		if (ph->p_type != ELF_PROG_LOAD)
  8028bf:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  8028c5:	83 39 01             	cmpl   $0x1,(%ecx)
  8028c8:	75 d8                	jne    8028a2 <spawn+0x37e>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8028ca:	8b 41 18             	mov    0x18(%ecx),%eax
  8028cd:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8028d3:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8028d6:	83 f8 01             	cmp    $0x1,%eax
  8028d9:	19 c0                	sbb    %eax,%eax
  8028db:	83 e0 fe             	and    $0xfffffffe,%eax
  8028de:	83 c0 07             	add    $0x7,%eax
  8028e1:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8028e7:	8b 51 04             	mov    0x4(%ecx),%edx
  8028ea:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  8028f0:	8b 79 10             	mov    0x10(%ecx),%edi
  8028f3:	8b 59 14             	mov    0x14(%ecx),%ebx
  8028f6:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8028fc:	8b 71 08             	mov    0x8(%ecx),%esi
	if ((i = PGOFF(va))) {
  8028ff:	89 f0                	mov    %esi,%eax
  802901:	25 ff 0f 00 00       	and    $0xfff,%eax
  802906:	74 14                	je     80291c <spawn+0x3f8>
		va -= i;
  802908:	29 c6                	sub    %eax,%esi
		memsz += i;
  80290a:	01 c3                	add    %eax,%ebx
  80290c:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  802912:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  802914:	29 c2                	sub    %eax,%edx
  802916:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  80291c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802921:	e9 09 ff ff ff       	jmp    80282f <spawn+0x30b>
	close(fd);
  802926:	83 ec 0c             	sub    $0xc,%esp
  802929:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  80292f:	e8 99 f4 ff ff       	call   801dcd <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	envid_t this_envid = sys_getenvid();//父进程号
  802934:	e8 93 ec ff ff       	call   8015cc <sys_getenvid>
  802939:	89 c6                	mov    %eax,%esi
  80293b:	83 c4 10             	add    $0x10,%esp
	
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  80293e:	bb 00 00 80 00       	mov    $0x800000,%ebx
  802943:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  802949:	eb 12                	jmp    80295d <spawn+0x439>
  80294b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802951:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  802957:	0f 84 bb 00 00 00    	je     802a18 <spawn+0x4f4>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE ) ) {
  80295d:	89 d8                	mov    %ebx,%eax
  80295f:	c1 e8 16             	shr    $0x16,%eax
  802962:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802969:	a8 01                	test   $0x1,%al
  80296b:	74 de                	je     80294b <spawn+0x427>
  80296d:	89 d8                	mov    %ebx,%eax
  80296f:	c1 e8 0c             	shr    $0xc,%eax
  802972:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802979:	f6 c2 01             	test   $0x1,%dl
  80297c:	74 cd                	je     80294b <spawn+0x427>
  80297e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802985:	f6 c6 04             	test   $0x4,%dh
  802988:	74 c1                	je     80294b <spawn+0x427>
			//Copy the mappings
			if( (r=sys_page_map(this_envid , (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL ) )< 0 ) 
  80298a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802991:	83 ec 0c             	sub    $0xc,%esp
  802994:	25 07 0e 00 00       	and    $0xe07,%eax
  802999:	50                   	push   %eax
  80299a:	53                   	push   %ebx
  80299b:	57                   	push   %edi
  80299c:	53                   	push   %ebx
  80299d:	56                   	push   %esi
  80299e:	e8 aa ec ff ff       	call   80164d <sys_page_map>
  8029a3:	83 c4 20             	add    $0x20,%esp
  8029a6:	85 c0                	test   %eax,%eax
  8029a8:	79 a1                	jns    80294b <spawn+0x427>
		panic("copy_shared_pages: %e", r);
  8029aa:	50                   	push   %eax
  8029ab:	68 ca 3e 80 00       	push   $0x803eca
  8029b0:	68 82 00 00 00       	push   $0x82
  8029b5:	68 70 3e 80 00       	push   $0x803e70
  8029ba:	e8 aa e0 ff ff       	call   800a69 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  8029bf:	50                   	push   %eax
  8029c0:	68 99 3e 80 00       	push   $0x803e99
  8029c5:	68 86 00 00 00       	push   $0x86
  8029ca:	68 70 3e 80 00       	push   $0x803e70
  8029cf:	e8 95 e0 ff ff       	call   800a69 <_panic>
		panic("sys_env_set_status: %e", r);
  8029d4:	50                   	push   %eax
  8029d5:	68 b3 3e 80 00       	push   $0x803eb3
  8029da:	68 89 00 00 00       	push   $0x89
  8029df:	68 70 3e 80 00       	push   $0x803e70
  8029e4:	e8 80 e0 ff ff       	call   800a69 <_panic>
		return r;
  8029e9:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8029ef:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
}
  8029f5:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8029fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8029fe:	5b                   	pop    %ebx
  8029ff:	5e                   	pop    %esi
  802a00:	5f                   	pop    %edi
  802a01:	5d                   	pop    %ebp
  802a02:	c3                   	ret    
  802a03:	89 c7                	mov    %eax,%edi
  802a05:	e9 59 fe ff ff       	jmp    802863 <spawn+0x33f>
  802a0a:	89 c7                	mov    %eax,%edi
  802a0c:	e9 52 fe ff ff       	jmp    802863 <spawn+0x33f>
  802a11:	89 c7                	mov    %eax,%edi
  802a13:	e9 4b fe ff ff       	jmp    802863 <spawn+0x33f>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802a18:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802a1f:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802a22:	83 ec 08             	sub    $0x8,%esp
  802a25:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802a2b:	50                   	push   %eax
  802a2c:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  802a32:	e8 dc ec ff ff       	call   801713 <sys_env_set_trapframe>
  802a37:	83 c4 10             	add    $0x10,%esp
  802a3a:	85 c0                	test   %eax,%eax
  802a3c:	78 81                	js     8029bf <spawn+0x49b>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802a3e:	83 ec 08             	sub    $0x8,%esp
  802a41:	6a 02                	push   $0x2
  802a43:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  802a49:	e8 83 ec ff ff       	call   8016d1 <sys_env_set_status>
  802a4e:	83 c4 10             	add    $0x10,%esp
  802a51:	85 c0                	test   %eax,%eax
  802a53:	0f 88 7b ff ff ff    	js     8029d4 <spawn+0x4b0>
	return child;
  802a59:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802a5f:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802a65:	eb 8e                	jmp    8029f5 <spawn+0x4d1>
		return -E_NO_MEM;
  802a67:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  802a6c:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802a72:	eb 81                	jmp    8029f5 <spawn+0x4d1>
	sys_page_unmap(0, UTEMP);
  802a74:	83 ec 08             	sub    $0x8,%esp
  802a77:	68 00 00 40 00       	push   $0x400000
  802a7c:	6a 00                	push   $0x0
  802a7e:	e8 0c ec ff ff       	call   80168f <sys_page_unmap>
  802a83:	83 c4 10             	add    $0x10,%esp
  802a86:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  802a8c:	e9 64 ff ff ff       	jmp    8029f5 <spawn+0x4d1>

00802a91 <spawnl>:
{
  802a91:	55                   	push   %ebp
  802a92:	89 e5                	mov    %esp,%ebp
  802a94:	56                   	push   %esi
  802a95:	53                   	push   %ebx
	va_start(vl, arg0);
  802a96:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  802a99:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  802a9e:	eb 05                	jmp    802aa5 <spawnl+0x14>
		argc++;
  802aa0:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  802aa3:	89 ca                	mov    %ecx,%edx
  802aa5:	8d 4a 04             	lea    0x4(%edx),%ecx
  802aa8:	83 3a 00             	cmpl   $0x0,(%edx)
  802aab:	75 f3                	jne    802aa0 <spawnl+0xf>
	const char *argv[argc+2];
  802aad:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  802ab4:	89 d3                	mov    %edx,%ebx
  802ab6:	83 e3 f0             	and    $0xfffffff0,%ebx
  802ab9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  802abf:	89 e1                	mov    %esp,%ecx
  802ac1:	29 d1                	sub    %edx,%ecx
  802ac3:	39 cc                	cmp    %ecx,%esp
  802ac5:	74 10                	je     802ad7 <spawnl+0x46>
  802ac7:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  802acd:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  802ad4:	00 
  802ad5:	eb ec                	jmp    802ac3 <spawnl+0x32>
  802ad7:	89 da                	mov    %ebx,%edx
  802ad9:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  802adf:	29 d4                	sub    %edx,%esp
  802ae1:	85 d2                	test   %edx,%edx
  802ae3:	74 05                	je     802aea <spawnl+0x59>
  802ae5:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  802aea:	8d 5c 24 03          	lea    0x3(%esp),%ebx
  802aee:	89 da                	mov    %ebx,%edx
  802af0:	c1 ea 02             	shr    $0x2,%edx
  802af3:	83 e3 fc             	and    $0xfffffffc,%ebx
	argv[0] = arg0;
  802af6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802af9:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802b00:	c7 44 83 04 00 00 00 	movl   $0x0,0x4(%ebx,%eax,4)
  802b07:	00 
	va_start(vl, arg0);
  802b08:	8d 4d 10             	lea    0x10(%ebp),%ecx
  802b0b:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  802b0d:	b8 00 00 00 00       	mov    $0x0,%eax
  802b12:	eb 0b                	jmp    802b1f <spawnl+0x8e>
		argv[i+1] = va_arg(vl, const char *);
  802b14:	83 c0 01             	add    $0x1,%eax
  802b17:	8b 31                	mov    (%ecx),%esi
  802b19:	89 34 83             	mov    %esi,(%ebx,%eax,4)
  802b1c:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  802b1f:	39 d0                	cmp    %edx,%eax
  802b21:	75 f1                	jne    802b14 <spawnl+0x83>
	return spawn(prog, argv);
  802b23:	83 ec 08             	sub    $0x8,%esp
  802b26:	53                   	push   %ebx
  802b27:	ff 75 08             	push   0x8(%ebp)
  802b2a:	e8 f5 f9 ff ff       	call   802524 <spawn>
}
  802b2f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b32:	5b                   	pop    %ebx
  802b33:	5e                   	pop    %esi
  802b34:	5d                   	pop    %ebp
  802b35:	c3                   	ret    

00802b36 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802b36:	55                   	push   %ebp
  802b37:	89 e5                	mov    %esp,%ebp
  802b39:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  802b3c:	68 06 3f 80 00       	push   $0x803f06
  802b41:	ff 75 0c             	push   0xc(%ebp)
  802b44:	e8 c5 e6 ff ff       	call   80120e <strcpy>
	return 0;
}
  802b49:	b8 00 00 00 00       	mov    $0x0,%eax
  802b4e:	c9                   	leave  
  802b4f:	c3                   	ret    

00802b50 <devsock_close>:
{
  802b50:	55                   	push   %ebp
  802b51:	89 e5                	mov    %esp,%ebp
  802b53:	53                   	push   %ebx
  802b54:	83 ec 10             	sub    $0x10,%esp
  802b57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802b5a:	53                   	push   %ebx
  802b5b:	e8 67 09 00 00       	call   8034c7 <pageref>
  802b60:	89 c2                	mov    %eax,%edx
  802b62:	83 c4 10             	add    $0x10,%esp
		return 0;
  802b65:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  802b6a:	83 fa 01             	cmp    $0x1,%edx
  802b6d:	74 05                	je     802b74 <devsock_close+0x24>
}
  802b6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b72:	c9                   	leave  
  802b73:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  802b74:	83 ec 0c             	sub    $0xc,%esp
  802b77:	ff 73 0c             	push   0xc(%ebx)
  802b7a:	e8 b7 02 00 00       	call   802e36 <nsipc_close>
  802b7f:	83 c4 10             	add    $0x10,%esp
  802b82:	eb eb                	jmp    802b6f <devsock_close+0x1f>

00802b84 <devsock_write>:
{
  802b84:	55                   	push   %ebp
  802b85:	89 e5                	mov    %esp,%ebp
  802b87:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802b8a:	6a 00                	push   $0x0
  802b8c:	ff 75 10             	push   0x10(%ebp)
  802b8f:	ff 75 0c             	push   0xc(%ebp)
  802b92:	8b 45 08             	mov    0x8(%ebp),%eax
  802b95:	ff 70 0c             	push   0xc(%eax)
  802b98:	e8 79 03 00 00       	call   802f16 <nsipc_send>
}
  802b9d:	c9                   	leave  
  802b9e:	c3                   	ret    

00802b9f <devsock_read>:
{
  802b9f:	55                   	push   %ebp
  802ba0:	89 e5                	mov    %esp,%ebp
  802ba2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802ba5:	6a 00                	push   $0x0
  802ba7:	ff 75 10             	push   0x10(%ebp)
  802baa:	ff 75 0c             	push   0xc(%ebp)
  802bad:	8b 45 08             	mov    0x8(%ebp),%eax
  802bb0:	ff 70 0c             	push   0xc(%eax)
  802bb3:	e8 ef 02 00 00       	call   802ea7 <nsipc_recv>
}
  802bb8:	c9                   	leave  
  802bb9:	c3                   	ret    

00802bba <fd2sockid>:
{
  802bba:	55                   	push   %ebp
  802bbb:	89 e5                	mov    %esp,%ebp
  802bbd:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  802bc0:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802bc3:	52                   	push   %edx
  802bc4:	50                   	push   %eax
  802bc5:	e8 d6 f0 ff ff       	call   801ca0 <fd_lookup>
  802bca:	83 c4 10             	add    $0x10,%esp
  802bcd:	85 c0                	test   %eax,%eax
  802bcf:	78 10                	js     802be1 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  802bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802bd4:	8b 0d 3c 50 80 00    	mov    0x80503c,%ecx
  802bda:	39 08                	cmp    %ecx,(%eax)
  802bdc:	75 05                	jne    802be3 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  802bde:	8b 40 0c             	mov    0xc(%eax),%eax
}
  802be1:	c9                   	leave  
  802be2:	c3                   	ret    
		return -E_NOT_SUPP;
  802be3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802be8:	eb f7                	jmp    802be1 <fd2sockid+0x27>

00802bea <alloc_sockfd>:
{
  802bea:	55                   	push   %ebp
  802beb:	89 e5                	mov    %esp,%ebp
  802bed:	56                   	push   %esi
  802bee:	53                   	push   %ebx
  802bef:	83 ec 1c             	sub    $0x1c,%esp
  802bf2:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  802bf4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802bf7:	50                   	push   %eax
  802bf8:	e8 53 f0 ff ff       	call   801c50 <fd_alloc>
  802bfd:	89 c3                	mov    %eax,%ebx
  802bff:	83 c4 10             	add    $0x10,%esp
  802c02:	85 c0                	test   %eax,%eax
  802c04:	78 43                	js     802c49 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802c06:	83 ec 04             	sub    $0x4,%esp
  802c09:	68 07 04 00 00       	push   $0x407
  802c0e:	ff 75 f4             	push   -0xc(%ebp)
  802c11:	6a 00                	push   $0x0
  802c13:	e8 f2 e9 ff ff       	call   80160a <sys_page_alloc>
  802c18:	89 c3                	mov    %eax,%ebx
  802c1a:	83 c4 10             	add    $0x10,%esp
  802c1d:	85 c0                	test   %eax,%eax
  802c1f:	78 28                	js     802c49 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  802c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c24:	8b 15 3c 50 80 00    	mov    0x80503c,%edx
  802c2a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c2f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802c36:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802c39:	83 ec 0c             	sub    $0xc,%esp
  802c3c:	50                   	push   %eax
  802c3d:	e8 e7 ef ff ff       	call   801c29 <fd2num>
  802c42:	89 c3                	mov    %eax,%ebx
  802c44:	83 c4 10             	add    $0x10,%esp
  802c47:	eb 0c                	jmp    802c55 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  802c49:	83 ec 0c             	sub    $0xc,%esp
  802c4c:	56                   	push   %esi
  802c4d:	e8 e4 01 00 00       	call   802e36 <nsipc_close>
		return r;
  802c52:	83 c4 10             	add    $0x10,%esp
}
  802c55:	89 d8                	mov    %ebx,%eax
  802c57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802c5a:	5b                   	pop    %ebx
  802c5b:	5e                   	pop    %esi
  802c5c:	5d                   	pop    %ebp
  802c5d:	c3                   	ret    

00802c5e <accept>:
{
  802c5e:	55                   	push   %ebp
  802c5f:	89 e5                	mov    %esp,%ebp
  802c61:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802c64:	8b 45 08             	mov    0x8(%ebp),%eax
  802c67:	e8 4e ff ff ff       	call   802bba <fd2sockid>
  802c6c:	85 c0                	test   %eax,%eax
  802c6e:	78 1b                	js     802c8b <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802c70:	83 ec 04             	sub    $0x4,%esp
  802c73:	ff 75 10             	push   0x10(%ebp)
  802c76:	ff 75 0c             	push   0xc(%ebp)
  802c79:	50                   	push   %eax
  802c7a:	e8 0e 01 00 00       	call   802d8d <nsipc_accept>
  802c7f:	83 c4 10             	add    $0x10,%esp
  802c82:	85 c0                	test   %eax,%eax
  802c84:	78 05                	js     802c8b <accept+0x2d>
	return alloc_sockfd(r);
  802c86:	e8 5f ff ff ff       	call   802bea <alloc_sockfd>
}
  802c8b:	c9                   	leave  
  802c8c:	c3                   	ret    

00802c8d <bind>:
{
  802c8d:	55                   	push   %ebp
  802c8e:	89 e5                	mov    %esp,%ebp
  802c90:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802c93:	8b 45 08             	mov    0x8(%ebp),%eax
  802c96:	e8 1f ff ff ff       	call   802bba <fd2sockid>
  802c9b:	85 c0                	test   %eax,%eax
  802c9d:	78 12                	js     802cb1 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  802c9f:	83 ec 04             	sub    $0x4,%esp
  802ca2:	ff 75 10             	push   0x10(%ebp)
  802ca5:	ff 75 0c             	push   0xc(%ebp)
  802ca8:	50                   	push   %eax
  802ca9:	e8 31 01 00 00       	call   802ddf <nsipc_bind>
  802cae:	83 c4 10             	add    $0x10,%esp
}
  802cb1:	c9                   	leave  
  802cb2:	c3                   	ret    

00802cb3 <shutdown>:
{
  802cb3:	55                   	push   %ebp
  802cb4:	89 e5                	mov    %esp,%ebp
  802cb6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  802cbc:	e8 f9 fe ff ff       	call   802bba <fd2sockid>
  802cc1:	85 c0                	test   %eax,%eax
  802cc3:	78 0f                	js     802cd4 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  802cc5:	83 ec 08             	sub    $0x8,%esp
  802cc8:	ff 75 0c             	push   0xc(%ebp)
  802ccb:	50                   	push   %eax
  802ccc:	e8 43 01 00 00       	call   802e14 <nsipc_shutdown>
  802cd1:	83 c4 10             	add    $0x10,%esp
}
  802cd4:	c9                   	leave  
  802cd5:	c3                   	ret    

00802cd6 <connect>:
{
  802cd6:	55                   	push   %ebp
  802cd7:	89 e5                	mov    %esp,%ebp
  802cd9:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  802cdf:	e8 d6 fe ff ff       	call   802bba <fd2sockid>
  802ce4:	85 c0                	test   %eax,%eax
  802ce6:	78 12                	js     802cfa <connect+0x24>
	return nsipc_connect(r, name, namelen);
  802ce8:	83 ec 04             	sub    $0x4,%esp
  802ceb:	ff 75 10             	push   0x10(%ebp)
  802cee:	ff 75 0c             	push   0xc(%ebp)
  802cf1:	50                   	push   %eax
  802cf2:	e8 59 01 00 00       	call   802e50 <nsipc_connect>
  802cf7:	83 c4 10             	add    $0x10,%esp
}
  802cfa:	c9                   	leave  
  802cfb:	c3                   	ret    

00802cfc <listen>:
{
  802cfc:	55                   	push   %ebp
  802cfd:	89 e5                	mov    %esp,%ebp
  802cff:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802d02:	8b 45 08             	mov    0x8(%ebp),%eax
  802d05:	e8 b0 fe ff ff       	call   802bba <fd2sockid>
  802d0a:	85 c0                	test   %eax,%eax
  802d0c:	78 0f                	js     802d1d <listen+0x21>
	return nsipc_listen(r, backlog);
  802d0e:	83 ec 08             	sub    $0x8,%esp
  802d11:	ff 75 0c             	push   0xc(%ebp)
  802d14:	50                   	push   %eax
  802d15:	e8 6b 01 00 00       	call   802e85 <nsipc_listen>
  802d1a:	83 c4 10             	add    $0x10,%esp
}
  802d1d:	c9                   	leave  
  802d1e:	c3                   	ret    

00802d1f <socket>:

int
socket(int domain, int type, int protocol)
{
  802d1f:	55                   	push   %ebp
  802d20:	89 e5                	mov    %esp,%ebp
  802d22:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802d25:	ff 75 10             	push   0x10(%ebp)
  802d28:	ff 75 0c             	push   0xc(%ebp)
  802d2b:	ff 75 08             	push   0x8(%ebp)
  802d2e:	e8 41 02 00 00       	call   802f74 <nsipc_socket>
  802d33:	83 c4 10             	add    $0x10,%esp
  802d36:	85 c0                	test   %eax,%eax
  802d38:	78 05                	js     802d3f <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802d3a:	e8 ab fe ff ff       	call   802bea <alloc_sockfd>
}
  802d3f:	c9                   	leave  
  802d40:	c3                   	ret    

00802d41 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802d41:	55                   	push   %ebp
  802d42:	89 e5                	mov    %esp,%ebp
  802d44:	53                   	push   %ebx
  802d45:	83 ec 04             	sub    $0x4,%esp
  802d48:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802d4a:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802d51:	74 26                	je     802d79 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802d53:	6a 07                	push   $0x7
  802d55:	68 00 90 80 00       	push   $0x809000
  802d5a:	53                   	push   %ebx
  802d5b:	ff 35 00 a0 80 00    	push   0x80a000
  802d61:	e8 d4 06 00 00       	call   80343a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802d66:	83 c4 0c             	add    $0xc,%esp
  802d69:	6a 00                	push   $0x0
  802d6b:	6a 00                	push   $0x0
  802d6d:	6a 00                	push   $0x0
  802d6f:	e8 5f 06 00 00       	call   8033d3 <ipc_recv>
}
  802d74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d77:	c9                   	leave  
  802d78:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802d79:	83 ec 0c             	sub    $0xc,%esp
  802d7c:	6a 02                	push   $0x2
  802d7e:	e8 0b 07 00 00       	call   80348e <ipc_find_env>
  802d83:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802d88:	83 c4 10             	add    $0x10,%esp
  802d8b:	eb c6                	jmp    802d53 <nsipc+0x12>

00802d8d <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802d8d:	55                   	push   %ebp
  802d8e:	89 e5                	mov    %esp,%ebp
  802d90:	56                   	push   %esi
  802d91:	53                   	push   %ebx
  802d92:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802d95:	8b 45 08             	mov    0x8(%ebp),%eax
  802d98:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802d9d:	8b 06                	mov    (%esi),%eax
  802d9f:	a3 04 90 80 00       	mov    %eax,0x809004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802da4:	b8 01 00 00 00       	mov    $0x1,%eax
  802da9:	e8 93 ff ff ff       	call   802d41 <nsipc>
  802dae:	89 c3                	mov    %eax,%ebx
  802db0:	85 c0                	test   %eax,%eax
  802db2:	79 09                	jns    802dbd <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  802db4:	89 d8                	mov    %ebx,%eax
  802db6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802db9:	5b                   	pop    %ebx
  802dba:	5e                   	pop    %esi
  802dbb:	5d                   	pop    %ebp
  802dbc:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802dbd:	83 ec 04             	sub    $0x4,%esp
  802dc0:	ff 35 10 90 80 00    	push   0x809010
  802dc6:	68 00 90 80 00       	push   $0x809000
  802dcb:	ff 75 0c             	push   0xc(%ebp)
  802dce:	e8 d1 e5 ff ff       	call   8013a4 <memmove>
		*addrlen = ret->ret_addrlen;
  802dd3:	a1 10 90 80 00       	mov    0x809010,%eax
  802dd8:	89 06                	mov    %eax,(%esi)
  802dda:	83 c4 10             	add    $0x10,%esp
	return r;
  802ddd:	eb d5                	jmp    802db4 <nsipc_accept+0x27>

00802ddf <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802ddf:	55                   	push   %ebp
  802de0:	89 e5                	mov    %esp,%ebp
  802de2:	53                   	push   %ebx
  802de3:	83 ec 08             	sub    $0x8,%esp
  802de6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802de9:	8b 45 08             	mov    0x8(%ebp),%eax
  802dec:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802df1:	53                   	push   %ebx
  802df2:	ff 75 0c             	push   0xc(%ebp)
  802df5:	68 04 90 80 00       	push   $0x809004
  802dfa:	e8 a5 e5 ff ff       	call   8013a4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802dff:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_BIND);
  802e05:	b8 02 00 00 00       	mov    $0x2,%eax
  802e0a:	e8 32 ff ff ff       	call   802d41 <nsipc>
}
  802e0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e12:	c9                   	leave  
  802e13:	c3                   	ret    

00802e14 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802e14:	55                   	push   %ebp
  802e15:	89 e5                	mov    %esp,%ebp
  802e17:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  802e1d:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.shutdown.req_how = how;
  802e22:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e25:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_SHUTDOWN);
  802e2a:	b8 03 00 00 00       	mov    $0x3,%eax
  802e2f:	e8 0d ff ff ff       	call   802d41 <nsipc>
}
  802e34:	c9                   	leave  
  802e35:	c3                   	ret    

00802e36 <nsipc_close>:

int
nsipc_close(int s)
{
  802e36:	55                   	push   %ebp
  802e37:	89 e5                	mov    %esp,%ebp
  802e39:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  802e3f:	a3 00 90 80 00       	mov    %eax,0x809000
	return nsipc(NSREQ_CLOSE);
  802e44:	b8 04 00 00 00       	mov    $0x4,%eax
  802e49:	e8 f3 fe ff ff       	call   802d41 <nsipc>
}
  802e4e:	c9                   	leave  
  802e4f:	c3                   	ret    

00802e50 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802e50:	55                   	push   %ebp
  802e51:	89 e5                	mov    %esp,%ebp
  802e53:	53                   	push   %ebx
  802e54:	83 ec 08             	sub    $0x8,%esp
  802e57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  802e5d:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802e62:	53                   	push   %ebx
  802e63:	ff 75 0c             	push   0xc(%ebp)
  802e66:	68 04 90 80 00       	push   $0x809004
  802e6b:	e8 34 e5 ff ff       	call   8013a4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802e70:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_CONNECT);
  802e76:	b8 05 00 00 00       	mov    $0x5,%eax
  802e7b:	e8 c1 fe ff ff       	call   802d41 <nsipc>
}
  802e80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e83:	c9                   	leave  
  802e84:	c3                   	ret    

00802e85 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802e85:	55                   	push   %ebp
  802e86:	89 e5                	mov    %esp,%ebp
  802e88:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  802e8e:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.listen.req_backlog = backlog;
  802e93:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e96:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_LISTEN);
  802e9b:	b8 06 00 00 00       	mov    $0x6,%eax
  802ea0:	e8 9c fe ff ff       	call   802d41 <nsipc>
}
  802ea5:	c9                   	leave  
  802ea6:	c3                   	ret    

00802ea7 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802ea7:	55                   	push   %ebp
  802ea8:	89 e5                	mov    %esp,%ebp
  802eaa:	56                   	push   %esi
  802eab:	53                   	push   %ebx
  802eac:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802eaf:	8b 45 08             	mov    0x8(%ebp),%eax
  802eb2:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.recv.req_len = len;
  802eb7:	89 35 04 90 80 00    	mov    %esi,0x809004
	nsipcbuf.recv.req_flags = flags;
  802ebd:	8b 45 14             	mov    0x14(%ebp),%eax
  802ec0:	a3 08 90 80 00       	mov    %eax,0x809008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802ec5:	b8 07 00 00 00       	mov    $0x7,%eax
  802eca:	e8 72 fe ff ff       	call   802d41 <nsipc>
  802ecf:	89 c3                	mov    %eax,%ebx
  802ed1:	85 c0                	test   %eax,%eax
  802ed3:	78 22                	js     802ef7 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  802ed5:	b8 3f 06 00 00       	mov    $0x63f,%eax
  802eda:	39 c6                	cmp    %eax,%esi
  802edc:	0f 4e c6             	cmovle %esi,%eax
  802edf:	39 c3                	cmp    %eax,%ebx
  802ee1:	7f 1d                	jg     802f00 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802ee3:	83 ec 04             	sub    $0x4,%esp
  802ee6:	53                   	push   %ebx
  802ee7:	68 00 90 80 00       	push   $0x809000
  802eec:	ff 75 0c             	push   0xc(%ebp)
  802eef:	e8 b0 e4 ff ff       	call   8013a4 <memmove>
  802ef4:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802ef7:	89 d8                	mov    %ebx,%eax
  802ef9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802efc:	5b                   	pop    %ebx
  802efd:	5e                   	pop    %esi
  802efe:	5d                   	pop    %ebp
  802eff:	c3                   	ret    
		assert(r < 1600 && r <= len);
  802f00:	68 12 3f 80 00       	push   $0x803f12
  802f05:	68 a6 38 80 00       	push   $0x8038a6
  802f0a:	6a 62                	push   $0x62
  802f0c:	68 27 3f 80 00       	push   $0x803f27
  802f11:	e8 53 db ff ff       	call   800a69 <_panic>

00802f16 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802f16:	55                   	push   %ebp
  802f17:	89 e5                	mov    %esp,%ebp
  802f19:	53                   	push   %ebx
  802f1a:	83 ec 04             	sub    $0x4,%esp
  802f1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802f20:	8b 45 08             	mov    0x8(%ebp),%eax
  802f23:	a3 00 90 80 00       	mov    %eax,0x809000
	assert(size < 1600);
  802f28:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802f2e:	7f 2e                	jg     802f5e <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802f30:	83 ec 04             	sub    $0x4,%esp
  802f33:	53                   	push   %ebx
  802f34:	ff 75 0c             	push   0xc(%ebp)
  802f37:	68 0c 90 80 00       	push   $0x80900c
  802f3c:	e8 63 e4 ff ff       	call   8013a4 <memmove>
	nsipcbuf.send.req_size = size;
  802f41:	89 1d 04 90 80 00    	mov    %ebx,0x809004
	nsipcbuf.send.req_flags = flags;
  802f47:	8b 45 14             	mov    0x14(%ebp),%eax
  802f4a:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SEND);
  802f4f:	b8 08 00 00 00       	mov    $0x8,%eax
  802f54:	e8 e8 fd ff ff       	call   802d41 <nsipc>
}
  802f59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f5c:	c9                   	leave  
  802f5d:	c3                   	ret    
	assert(size < 1600);
  802f5e:	68 33 3f 80 00       	push   $0x803f33
  802f63:	68 a6 38 80 00       	push   $0x8038a6
  802f68:	6a 6d                	push   $0x6d
  802f6a:	68 27 3f 80 00       	push   $0x803f27
  802f6f:	e8 f5 da ff ff       	call   800a69 <_panic>

00802f74 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802f74:	55                   	push   %ebp
  802f75:	89 e5                	mov    %esp,%ebp
  802f77:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802f7a:	8b 45 08             	mov    0x8(%ebp),%eax
  802f7d:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.socket.req_type = type;
  802f82:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f85:	a3 04 90 80 00       	mov    %eax,0x809004
	nsipcbuf.socket.req_protocol = protocol;
  802f8a:	8b 45 10             	mov    0x10(%ebp),%eax
  802f8d:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SOCKET);
  802f92:	b8 09 00 00 00       	mov    $0x9,%eax
  802f97:	e8 a5 fd ff ff       	call   802d41 <nsipc>
}
  802f9c:	c9                   	leave  
  802f9d:	c3                   	ret    

00802f9e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802f9e:	55                   	push   %ebp
  802f9f:	89 e5                	mov    %esp,%ebp
  802fa1:	56                   	push   %esi
  802fa2:	53                   	push   %ebx
  802fa3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802fa6:	83 ec 0c             	sub    $0xc,%esp
  802fa9:	ff 75 08             	push   0x8(%ebp)
  802fac:	e8 88 ec ff ff       	call   801c39 <fd2data>
  802fb1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802fb3:	83 c4 08             	add    $0x8,%esp
  802fb6:	68 3f 3f 80 00       	push   $0x803f3f
  802fbb:	53                   	push   %ebx
  802fbc:	e8 4d e2 ff ff       	call   80120e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802fc1:	8b 46 04             	mov    0x4(%esi),%eax
  802fc4:	2b 06                	sub    (%esi),%eax
  802fc6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802fcc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802fd3:	00 00 00 
	stat->st_dev = &devpipe;
  802fd6:	c7 83 88 00 00 00 58 	movl   $0x805058,0x88(%ebx)
  802fdd:	50 80 00 
	return 0;
}
  802fe0:	b8 00 00 00 00       	mov    $0x0,%eax
  802fe5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802fe8:	5b                   	pop    %ebx
  802fe9:	5e                   	pop    %esi
  802fea:	5d                   	pop    %ebp
  802feb:	c3                   	ret    

00802fec <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802fec:	55                   	push   %ebp
  802fed:	89 e5                	mov    %esp,%ebp
  802fef:	53                   	push   %ebx
  802ff0:	83 ec 0c             	sub    $0xc,%esp
  802ff3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802ff6:	53                   	push   %ebx
  802ff7:	6a 00                	push   $0x0
  802ff9:	e8 91 e6 ff ff       	call   80168f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802ffe:	89 1c 24             	mov    %ebx,(%esp)
  803001:	e8 33 ec ff ff       	call   801c39 <fd2data>
  803006:	83 c4 08             	add    $0x8,%esp
  803009:	50                   	push   %eax
  80300a:	6a 00                	push   $0x0
  80300c:	e8 7e e6 ff ff       	call   80168f <sys_page_unmap>
}
  803011:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803014:	c9                   	leave  
  803015:	c3                   	ret    

00803016 <_pipeisclosed>:
{
  803016:	55                   	push   %ebp
  803017:	89 e5                	mov    %esp,%ebp
  803019:	57                   	push   %edi
  80301a:	56                   	push   %esi
  80301b:	53                   	push   %ebx
  80301c:	83 ec 1c             	sub    $0x1c,%esp
  80301f:	89 c7                	mov    %eax,%edi
  803021:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  803023:	a1 14 60 80 00       	mov    0x806014,%eax
  803028:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80302b:	83 ec 0c             	sub    $0xc,%esp
  80302e:	57                   	push   %edi
  80302f:	e8 93 04 00 00       	call   8034c7 <pageref>
  803034:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  803037:	89 34 24             	mov    %esi,(%esp)
  80303a:	e8 88 04 00 00       	call   8034c7 <pageref>
		nn = thisenv->env_runs;
  80303f:	8b 15 14 60 80 00    	mov    0x806014,%edx
  803045:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  803048:	83 c4 10             	add    $0x10,%esp
  80304b:	39 cb                	cmp    %ecx,%ebx
  80304d:	74 1b                	je     80306a <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80304f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  803052:	75 cf                	jne    803023 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803054:	8b 42 58             	mov    0x58(%edx),%eax
  803057:	6a 01                	push   $0x1
  803059:	50                   	push   %eax
  80305a:	53                   	push   %ebx
  80305b:	68 46 3f 80 00       	push   $0x803f46
  803060:	e8 df da ff ff       	call   800b44 <cprintf>
  803065:	83 c4 10             	add    $0x10,%esp
  803068:	eb b9                	jmp    803023 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80306a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80306d:	0f 94 c0             	sete   %al
  803070:	0f b6 c0             	movzbl %al,%eax
}
  803073:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803076:	5b                   	pop    %ebx
  803077:	5e                   	pop    %esi
  803078:	5f                   	pop    %edi
  803079:	5d                   	pop    %ebp
  80307a:	c3                   	ret    

0080307b <devpipe_write>:
{
  80307b:	55                   	push   %ebp
  80307c:	89 e5                	mov    %esp,%ebp
  80307e:	57                   	push   %edi
  80307f:	56                   	push   %esi
  803080:	53                   	push   %ebx
  803081:	83 ec 28             	sub    $0x28,%esp
  803084:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  803087:	56                   	push   %esi
  803088:	e8 ac eb ff ff       	call   801c39 <fd2data>
  80308d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80308f:	83 c4 10             	add    $0x10,%esp
  803092:	bf 00 00 00 00       	mov    $0x0,%edi
  803097:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80309a:	75 09                	jne    8030a5 <devpipe_write+0x2a>
	return i;
  80309c:	89 f8                	mov    %edi,%eax
  80309e:	eb 23                	jmp    8030c3 <devpipe_write+0x48>
			sys_yield();
  8030a0:	e8 46 e5 ff ff       	call   8015eb <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8030a5:	8b 43 04             	mov    0x4(%ebx),%eax
  8030a8:	8b 0b                	mov    (%ebx),%ecx
  8030aa:	8d 51 20             	lea    0x20(%ecx),%edx
  8030ad:	39 d0                	cmp    %edx,%eax
  8030af:	72 1a                	jb     8030cb <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  8030b1:	89 da                	mov    %ebx,%edx
  8030b3:	89 f0                	mov    %esi,%eax
  8030b5:	e8 5c ff ff ff       	call   803016 <_pipeisclosed>
  8030ba:	85 c0                	test   %eax,%eax
  8030bc:	74 e2                	je     8030a0 <devpipe_write+0x25>
				return 0;
  8030be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8030c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8030c6:	5b                   	pop    %ebx
  8030c7:	5e                   	pop    %esi
  8030c8:	5f                   	pop    %edi
  8030c9:	5d                   	pop    %ebp
  8030ca:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8030cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8030ce:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8030d2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8030d5:	89 c2                	mov    %eax,%edx
  8030d7:	c1 fa 1f             	sar    $0x1f,%edx
  8030da:	89 d1                	mov    %edx,%ecx
  8030dc:	c1 e9 1b             	shr    $0x1b,%ecx
  8030df:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8030e2:	83 e2 1f             	and    $0x1f,%edx
  8030e5:	29 ca                	sub    %ecx,%edx
  8030e7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8030eb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8030ef:	83 c0 01             	add    $0x1,%eax
  8030f2:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8030f5:	83 c7 01             	add    $0x1,%edi
  8030f8:	eb 9d                	jmp    803097 <devpipe_write+0x1c>

008030fa <devpipe_read>:
{
  8030fa:	55                   	push   %ebp
  8030fb:	89 e5                	mov    %esp,%ebp
  8030fd:	57                   	push   %edi
  8030fe:	56                   	push   %esi
  8030ff:	53                   	push   %ebx
  803100:	83 ec 18             	sub    $0x18,%esp
  803103:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  803106:	57                   	push   %edi
  803107:	e8 2d eb ff ff       	call   801c39 <fd2data>
  80310c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80310e:	83 c4 10             	add    $0x10,%esp
  803111:	be 00 00 00 00       	mov    $0x0,%esi
  803116:	3b 75 10             	cmp    0x10(%ebp),%esi
  803119:	75 13                	jne    80312e <devpipe_read+0x34>
	return i;
  80311b:	89 f0                	mov    %esi,%eax
  80311d:	eb 02                	jmp    803121 <devpipe_read+0x27>
				return i;
  80311f:	89 f0                	mov    %esi,%eax
}
  803121:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803124:	5b                   	pop    %ebx
  803125:	5e                   	pop    %esi
  803126:	5f                   	pop    %edi
  803127:	5d                   	pop    %ebp
  803128:	c3                   	ret    
			sys_yield();
  803129:	e8 bd e4 ff ff       	call   8015eb <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80312e:	8b 03                	mov    (%ebx),%eax
  803130:	3b 43 04             	cmp    0x4(%ebx),%eax
  803133:	75 18                	jne    80314d <devpipe_read+0x53>
			if (i > 0)
  803135:	85 f6                	test   %esi,%esi
  803137:	75 e6                	jne    80311f <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  803139:	89 da                	mov    %ebx,%edx
  80313b:	89 f8                	mov    %edi,%eax
  80313d:	e8 d4 fe ff ff       	call   803016 <_pipeisclosed>
  803142:	85 c0                	test   %eax,%eax
  803144:	74 e3                	je     803129 <devpipe_read+0x2f>
				return 0;
  803146:	b8 00 00 00 00       	mov    $0x0,%eax
  80314b:	eb d4                	jmp    803121 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80314d:	99                   	cltd   
  80314e:	c1 ea 1b             	shr    $0x1b,%edx
  803151:	01 d0                	add    %edx,%eax
  803153:	83 e0 1f             	and    $0x1f,%eax
  803156:	29 d0                	sub    %edx,%eax
  803158:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80315d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803160:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  803163:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  803166:	83 c6 01             	add    $0x1,%esi
  803169:	eb ab                	jmp    803116 <devpipe_read+0x1c>

0080316b <pipe>:
{
  80316b:	55                   	push   %ebp
  80316c:	89 e5                	mov    %esp,%ebp
  80316e:	56                   	push   %esi
  80316f:	53                   	push   %ebx
  803170:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  803173:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803176:	50                   	push   %eax
  803177:	e8 d4 ea ff ff       	call   801c50 <fd_alloc>
  80317c:	89 c3                	mov    %eax,%ebx
  80317e:	83 c4 10             	add    $0x10,%esp
  803181:	85 c0                	test   %eax,%eax
  803183:	0f 88 23 01 00 00    	js     8032ac <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803189:	83 ec 04             	sub    $0x4,%esp
  80318c:	68 07 04 00 00       	push   $0x407
  803191:	ff 75 f4             	push   -0xc(%ebp)
  803194:	6a 00                	push   $0x0
  803196:	e8 6f e4 ff ff       	call   80160a <sys_page_alloc>
  80319b:	89 c3                	mov    %eax,%ebx
  80319d:	83 c4 10             	add    $0x10,%esp
  8031a0:	85 c0                	test   %eax,%eax
  8031a2:	0f 88 04 01 00 00    	js     8032ac <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  8031a8:	83 ec 0c             	sub    $0xc,%esp
  8031ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8031ae:	50                   	push   %eax
  8031af:	e8 9c ea ff ff       	call   801c50 <fd_alloc>
  8031b4:	89 c3                	mov    %eax,%ebx
  8031b6:	83 c4 10             	add    $0x10,%esp
  8031b9:	85 c0                	test   %eax,%eax
  8031bb:	0f 88 db 00 00 00    	js     80329c <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8031c1:	83 ec 04             	sub    $0x4,%esp
  8031c4:	68 07 04 00 00       	push   $0x407
  8031c9:	ff 75 f0             	push   -0x10(%ebp)
  8031cc:	6a 00                	push   $0x0
  8031ce:	e8 37 e4 ff ff       	call   80160a <sys_page_alloc>
  8031d3:	89 c3                	mov    %eax,%ebx
  8031d5:	83 c4 10             	add    $0x10,%esp
  8031d8:	85 c0                	test   %eax,%eax
  8031da:	0f 88 bc 00 00 00    	js     80329c <pipe+0x131>
	va = fd2data(fd0);
  8031e0:	83 ec 0c             	sub    $0xc,%esp
  8031e3:	ff 75 f4             	push   -0xc(%ebp)
  8031e6:	e8 4e ea ff ff       	call   801c39 <fd2data>
  8031eb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8031ed:	83 c4 0c             	add    $0xc,%esp
  8031f0:	68 07 04 00 00       	push   $0x407
  8031f5:	50                   	push   %eax
  8031f6:	6a 00                	push   $0x0
  8031f8:	e8 0d e4 ff ff       	call   80160a <sys_page_alloc>
  8031fd:	89 c3                	mov    %eax,%ebx
  8031ff:	83 c4 10             	add    $0x10,%esp
  803202:	85 c0                	test   %eax,%eax
  803204:	0f 88 82 00 00 00    	js     80328c <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80320a:	83 ec 0c             	sub    $0xc,%esp
  80320d:	ff 75 f0             	push   -0x10(%ebp)
  803210:	e8 24 ea ff ff       	call   801c39 <fd2data>
  803215:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80321c:	50                   	push   %eax
  80321d:	6a 00                	push   $0x0
  80321f:	56                   	push   %esi
  803220:	6a 00                	push   $0x0
  803222:	e8 26 e4 ff ff       	call   80164d <sys_page_map>
  803227:	89 c3                	mov    %eax,%ebx
  803229:	83 c4 20             	add    $0x20,%esp
  80322c:	85 c0                	test   %eax,%eax
  80322e:	78 4e                	js     80327e <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  803230:	a1 58 50 80 00       	mov    0x805058,%eax
  803235:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803238:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80323a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80323d:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  803244:	8b 55 f0             	mov    -0x10(%ebp),%edx
  803247:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  803249:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80324c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  803253:	83 ec 0c             	sub    $0xc,%esp
  803256:	ff 75 f4             	push   -0xc(%ebp)
  803259:	e8 cb e9 ff ff       	call   801c29 <fd2num>
  80325e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803261:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803263:	83 c4 04             	add    $0x4,%esp
  803266:	ff 75 f0             	push   -0x10(%ebp)
  803269:	e8 bb e9 ff ff       	call   801c29 <fd2num>
  80326e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803271:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803274:	83 c4 10             	add    $0x10,%esp
  803277:	bb 00 00 00 00       	mov    $0x0,%ebx
  80327c:	eb 2e                	jmp    8032ac <pipe+0x141>
	sys_page_unmap(0, va);
  80327e:	83 ec 08             	sub    $0x8,%esp
  803281:	56                   	push   %esi
  803282:	6a 00                	push   $0x0
  803284:	e8 06 e4 ff ff       	call   80168f <sys_page_unmap>
  803289:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80328c:	83 ec 08             	sub    $0x8,%esp
  80328f:	ff 75 f0             	push   -0x10(%ebp)
  803292:	6a 00                	push   $0x0
  803294:	e8 f6 e3 ff ff       	call   80168f <sys_page_unmap>
  803299:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80329c:	83 ec 08             	sub    $0x8,%esp
  80329f:	ff 75 f4             	push   -0xc(%ebp)
  8032a2:	6a 00                	push   $0x0
  8032a4:	e8 e6 e3 ff ff       	call   80168f <sys_page_unmap>
  8032a9:	83 c4 10             	add    $0x10,%esp
}
  8032ac:	89 d8                	mov    %ebx,%eax
  8032ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8032b1:	5b                   	pop    %ebx
  8032b2:	5e                   	pop    %esi
  8032b3:	5d                   	pop    %ebp
  8032b4:	c3                   	ret    

008032b5 <pipeisclosed>:
{
  8032b5:	55                   	push   %ebp
  8032b6:	89 e5                	mov    %esp,%ebp
  8032b8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8032bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8032be:	50                   	push   %eax
  8032bf:	ff 75 08             	push   0x8(%ebp)
  8032c2:	e8 d9 e9 ff ff       	call   801ca0 <fd_lookup>
  8032c7:	83 c4 10             	add    $0x10,%esp
  8032ca:	85 c0                	test   %eax,%eax
  8032cc:	78 18                	js     8032e6 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8032ce:	83 ec 0c             	sub    $0xc,%esp
  8032d1:	ff 75 f4             	push   -0xc(%ebp)
  8032d4:	e8 60 e9 ff ff       	call   801c39 <fd2data>
  8032d9:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8032db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8032de:	e8 33 fd ff ff       	call   803016 <_pipeisclosed>
  8032e3:	83 c4 10             	add    $0x10,%esp
}
  8032e6:	c9                   	leave  
  8032e7:	c3                   	ret    

008032e8 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8032e8:	55                   	push   %ebp
  8032e9:	89 e5                	mov    %esp,%ebp
  8032eb:	56                   	push   %esi
  8032ec:	53                   	push   %ebx
  8032ed:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8032f0:	85 f6                	test   %esi,%esi
  8032f2:	74 13                	je     803307 <wait+0x1f>
	e = &envs[ENVX(envid)];
  8032f4:	89 f3                	mov    %esi,%ebx
  8032f6:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8032fc:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8032ff:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  803305:	eb 1b                	jmp    803322 <wait+0x3a>
	assert(envid != 0);
  803307:	68 5e 3f 80 00       	push   $0x803f5e
  80330c:	68 a6 38 80 00       	push   $0x8038a6
  803311:	6a 09                	push   $0x9
  803313:	68 69 3f 80 00       	push   $0x803f69
  803318:	e8 4c d7 ff ff       	call   800a69 <_panic>
		sys_yield();
  80331d:	e8 c9 e2 ff ff       	call   8015eb <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  803322:	8b 43 48             	mov    0x48(%ebx),%eax
  803325:	39 f0                	cmp    %esi,%eax
  803327:	75 07                	jne    803330 <wait+0x48>
  803329:	8b 43 54             	mov    0x54(%ebx),%eax
  80332c:	85 c0                	test   %eax,%eax
  80332e:	75 ed                	jne    80331d <wait+0x35>
}
  803330:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803333:	5b                   	pop    %ebx
  803334:	5e                   	pop    %esi
  803335:	5d                   	pop    %ebp
  803336:	c3                   	ret    

00803337 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  803337:	55                   	push   %ebp
  803338:	89 e5                	mov    %esp,%ebp
  80333a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  80333d:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  803344:	74 0a                	je     803350 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  803346:	8b 45 08             	mov    0x8(%ebp),%eax
  803349:	a3 04 a0 80 00       	mov    %eax,0x80a004
}
  80334e:	c9                   	leave  
  80334f:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  803350:	e8 77 e2 ff ff       	call   8015cc <sys_getenvid>
  803355:	83 ec 04             	sub    $0x4,%esp
  803358:	68 07 0e 00 00       	push   $0xe07
  80335d:	68 00 f0 bf ee       	push   $0xeebff000
  803362:	50                   	push   %eax
  803363:	e8 a2 e2 ff ff       	call   80160a <sys_page_alloc>
		if (r < 0) {
  803368:	83 c4 10             	add    $0x10,%esp
  80336b:	85 c0                	test   %eax,%eax
  80336d:	78 2c                	js     80339b <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80336f:	e8 58 e2 ff ff       	call   8015cc <sys_getenvid>
  803374:	83 ec 08             	sub    $0x8,%esp
  803377:	68 ad 33 80 00       	push   $0x8033ad
  80337c:	50                   	push   %eax
  80337d:	e8 d3 e3 ff ff       	call   801755 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  803382:	83 c4 10             	add    $0x10,%esp
  803385:	85 c0                	test   %eax,%eax
  803387:	79 bd                	jns    803346 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  803389:	50                   	push   %eax
  80338a:	68 b4 3f 80 00       	push   $0x803fb4
  80338f:	6a 28                	push   $0x28
  803391:	68 ea 3f 80 00       	push   $0x803fea
  803396:	e8 ce d6 ff ff       	call   800a69 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  80339b:	50                   	push   %eax
  80339c:	68 74 3f 80 00       	push   $0x803f74
  8033a1:	6a 23                	push   $0x23
  8033a3:	68 ea 3f 80 00       	push   $0x803fea
  8033a8:	e8 bc d6 ff ff       	call   800a69 <_panic>

008033ad <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8033ad:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8033ae:	a1 04 a0 80 00       	mov    0x80a004,%eax
	call *%eax
  8033b3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8033b5:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  8033b8:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  8033bc:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  8033bf:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  8033c3:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  8033c7:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  8033c9:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  8033cc:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  8033cd:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  8033d0:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  8033d1:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  8033d2:	c3                   	ret    

008033d3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8033d3:	55                   	push   %ebp
  8033d4:	89 e5                	mov    %esp,%ebp
  8033d6:	56                   	push   %esi
  8033d7:	53                   	push   %ebx
  8033d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8033db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8033de:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8033e1:	85 c0                	test   %eax,%eax
  8033e3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8033e8:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8033eb:	83 ec 0c             	sub    $0xc,%esp
  8033ee:	50                   	push   %eax
  8033ef:	e8 c6 e3 ff ff       	call   8017ba <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8033f4:	83 c4 10             	add    $0x10,%esp
  8033f7:	85 f6                	test   %esi,%esi
  8033f9:	74 14                	je     80340f <ipc_recv+0x3c>
  8033fb:	ba 00 00 00 00       	mov    $0x0,%edx
  803400:	85 c0                	test   %eax,%eax
  803402:	78 09                	js     80340d <ipc_recv+0x3a>
  803404:	8b 15 14 60 80 00    	mov    0x806014,%edx
  80340a:	8b 52 74             	mov    0x74(%edx),%edx
  80340d:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  80340f:	85 db                	test   %ebx,%ebx
  803411:	74 14                	je     803427 <ipc_recv+0x54>
  803413:	ba 00 00 00 00       	mov    $0x0,%edx
  803418:	85 c0                	test   %eax,%eax
  80341a:	78 09                	js     803425 <ipc_recv+0x52>
  80341c:	8b 15 14 60 80 00    	mov    0x806014,%edx
  803422:	8b 52 78             	mov    0x78(%edx),%edx
  803425:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  803427:	85 c0                	test   %eax,%eax
  803429:	78 08                	js     803433 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  80342b:	a1 14 60 80 00       	mov    0x806014,%eax
  803430:	8b 40 70             	mov    0x70(%eax),%eax
}
  803433:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803436:	5b                   	pop    %ebx
  803437:	5e                   	pop    %esi
  803438:	5d                   	pop    %ebp
  803439:	c3                   	ret    

0080343a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80343a:	55                   	push   %ebp
  80343b:	89 e5                	mov    %esp,%ebp
  80343d:	57                   	push   %edi
  80343e:	56                   	push   %esi
  80343f:	53                   	push   %ebx
  803440:	83 ec 0c             	sub    $0xc,%esp
  803443:	8b 7d 08             	mov    0x8(%ebp),%edi
  803446:	8b 75 0c             	mov    0xc(%ebp),%esi
  803449:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  80344c:	85 db                	test   %ebx,%ebx
  80344e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  803453:	0f 44 d8             	cmove  %eax,%ebx
  803456:	eb 05                	jmp    80345d <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  803458:	e8 8e e1 ff ff       	call   8015eb <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80345d:	ff 75 14             	push   0x14(%ebp)
  803460:	53                   	push   %ebx
  803461:	56                   	push   %esi
  803462:	57                   	push   %edi
  803463:	e8 2f e3 ff ff       	call   801797 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  803468:	83 c4 10             	add    $0x10,%esp
  80346b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80346e:	74 e8                	je     803458 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  803470:	85 c0                	test   %eax,%eax
  803472:	78 08                	js     80347c <ipc_send+0x42>
	}while (r<0);

}
  803474:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803477:	5b                   	pop    %ebx
  803478:	5e                   	pop    %esi
  803479:	5f                   	pop    %edi
  80347a:	5d                   	pop    %ebp
  80347b:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80347c:	50                   	push   %eax
  80347d:	68 f8 3f 80 00       	push   $0x803ff8
  803482:	6a 3d                	push   $0x3d
  803484:	68 0c 40 80 00       	push   $0x80400c
  803489:	e8 db d5 ff ff       	call   800a69 <_panic>

0080348e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80348e:	55                   	push   %ebp
  80348f:	89 e5                	mov    %esp,%ebp
  803491:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  803494:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  803499:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80349c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8034a2:	8b 52 50             	mov    0x50(%edx),%edx
  8034a5:	39 ca                	cmp    %ecx,%edx
  8034a7:	74 11                	je     8034ba <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8034a9:	83 c0 01             	add    $0x1,%eax
  8034ac:	3d 00 04 00 00       	cmp    $0x400,%eax
  8034b1:	75 e6                	jne    803499 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8034b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8034b8:	eb 0b                	jmp    8034c5 <ipc_find_env+0x37>
			return envs[i].env_id;
  8034ba:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8034bd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8034c2:	8b 40 48             	mov    0x48(%eax),%eax
}
  8034c5:	5d                   	pop    %ebp
  8034c6:	c3                   	ret    

008034c7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8034c7:	55                   	push   %ebp
  8034c8:	89 e5                	mov    %esp,%ebp
  8034ca:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8034cd:	89 c2                	mov    %eax,%edx
  8034cf:	c1 ea 16             	shr    $0x16,%edx
  8034d2:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8034d9:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8034de:	f6 c1 01             	test   $0x1,%cl
  8034e1:	74 1c                	je     8034ff <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8034e3:	c1 e8 0c             	shr    $0xc,%eax
  8034e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8034ed:	a8 01                	test   $0x1,%al
  8034ef:	74 0e                	je     8034ff <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8034f1:	c1 e8 0c             	shr    $0xc,%eax
  8034f4:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8034fb:	ef 
  8034fc:	0f b7 d2             	movzwl %dx,%edx
}
  8034ff:	89 d0                	mov    %edx,%eax
  803501:	5d                   	pop    %ebp
  803502:	c3                   	ret    
  803503:	66 90                	xchg   %ax,%ax
  803505:	66 90                	xchg   %ax,%ax
  803507:	66 90                	xchg   %ax,%ax
  803509:	66 90                	xchg   %ax,%ax
  80350b:	66 90                	xchg   %ax,%ax
  80350d:	66 90                	xchg   %ax,%ax
  80350f:	90                   	nop

00803510 <__udivdi3>:
  803510:	f3 0f 1e fb          	endbr32 
  803514:	55                   	push   %ebp
  803515:	57                   	push   %edi
  803516:	56                   	push   %esi
  803517:	53                   	push   %ebx
  803518:	83 ec 1c             	sub    $0x1c,%esp
  80351b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80351f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  803523:	8b 74 24 34          	mov    0x34(%esp),%esi
  803527:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80352b:	85 c0                	test   %eax,%eax
  80352d:	75 19                	jne    803548 <__udivdi3+0x38>
  80352f:	39 f3                	cmp    %esi,%ebx
  803531:	76 4d                	jbe    803580 <__udivdi3+0x70>
  803533:	31 ff                	xor    %edi,%edi
  803535:	89 e8                	mov    %ebp,%eax
  803537:	89 f2                	mov    %esi,%edx
  803539:	f7 f3                	div    %ebx
  80353b:	89 fa                	mov    %edi,%edx
  80353d:	83 c4 1c             	add    $0x1c,%esp
  803540:	5b                   	pop    %ebx
  803541:	5e                   	pop    %esi
  803542:	5f                   	pop    %edi
  803543:	5d                   	pop    %ebp
  803544:	c3                   	ret    
  803545:	8d 76 00             	lea    0x0(%esi),%esi
  803548:	39 f0                	cmp    %esi,%eax
  80354a:	76 14                	jbe    803560 <__udivdi3+0x50>
  80354c:	31 ff                	xor    %edi,%edi
  80354e:	31 c0                	xor    %eax,%eax
  803550:	89 fa                	mov    %edi,%edx
  803552:	83 c4 1c             	add    $0x1c,%esp
  803555:	5b                   	pop    %ebx
  803556:	5e                   	pop    %esi
  803557:	5f                   	pop    %edi
  803558:	5d                   	pop    %ebp
  803559:	c3                   	ret    
  80355a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803560:	0f bd f8             	bsr    %eax,%edi
  803563:	83 f7 1f             	xor    $0x1f,%edi
  803566:	75 48                	jne    8035b0 <__udivdi3+0xa0>
  803568:	39 f0                	cmp    %esi,%eax
  80356a:	72 06                	jb     803572 <__udivdi3+0x62>
  80356c:	31 c0                	xor    %eax,%eax
  80356e:	39 eb                	cmp    %ebp,%ebx
  803570:	77 de                	ja     803550 <__udivdi3+0x40>
  803572:	b8 01 00 00 00       	mov    $0x1,%eax
  803577:	eb d7                	jmp    803550 <__udivdi3+0x40>
  803579:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803580:	89 d9                	mov    %ebx,%ecx
  803582:	85 db                	test   %ebx,%ebx
  803584:	75 0b                	jne    803591 <__udivdi3+0x81>
  803586:	b8 01 00 00 00       	mov    $0x1,%eax
  80358b:	31 d2                	xor    %edx,%edx
  80358d:	f7 f3                	div    %ebx
  80358f:	89 c1                	mov    %eax,%ecx
  803591:	31 d2                	xor    %edx,%edx
  803593:	89 f0                	mov    %esi,%eax
  803595:	f7 f1                	div    %ecx
  803597:	89 c6                	mov    %eax,%esi
  803599:	89 e8                	mov    %ebp,%eax
  80359b:	89 f7                	mov    %esi,%edi
  80359d:	f7 f1                	div    %ecx
  80359f:	89 fa                	mov    %edi,%edx
  8035a1:	83 c4 1c             	add    $0x1c,%esp
  8035a4:	5b                   	pop    %ebx
  8035a5:	5e                   	pop    %esi
  8035a6:	5f                   	pop    %edi
  8035a7:	5d                   	pop    %ebp
  8035a8:	c3                   	ret    
  8035a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8035b0:	89 f9                	mov    %edi,%ecx
  8035b2:	ba 20 00 00 00       	mov    $0x20,%edx
  8035b7:	29 fa                	sub    %edi,%edx
  8035b9:	d3 e0                	shl    %cl,%eax
  8035bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8035bf:	89 d1                	mov    %edx,%ecx
  8035c1:	89 d8                	mov    %ebx,%eax
  8035c3:	d3 e8                	shr    %cl,%eax
  8035c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8035c9:	09 c1                	or     %eax,%ecx
  8035cb:	89 f0                	mov    %esi,%eax
  8035cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8035d1:	89 f9                	mov    %edi,%ecx
  8035d3:	d3 e3                	shl    %cl,%ebx
  8035d5:	89 d1                	mov    %edx,%ecx
  8035d7:	d3 e8                	shr    %cl,%eax
  8035d9:	89 f9                	mov    %edi,%ecx
  8035db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8035df:	89 eb                	mov    %ebp,%ebx
  8035e1:	d3 e6                	shl    %cl,%esi
  8035e3:	89 d1                	mov    %edx,%ecx
  8035e5:	d3 eb                	shr    %cl,%ebx
  8035e7:	09 f3                	or     %esi,%ebx
  8035e9:	89 c6                	mov    %eax,%esi
  8035eb:	89 f2                	mov    %esi,%edx
  8035ed:	89 d8                	mov    %ebx,%eax
  8035ef:	f7 74 24 08          	divl   0x8(%esp)
  8035f3:	89 d6                	mov    %edx,%esi
  8035f5:	89 c3                	mov    %eax,%ebx
  8035f7:	f7 64 24 0c          	mull   0xc(%esp)
  8035fb:	39 d6                	cmp    %edx,%esi
  8035fd:	72 19                	jb     803618 <__udivdi3+0x108>
  8035ff:	89 f9                	mov    %edi,%ecx
  803601:	d3 e5                	shl    %cl,%ebp
  803603:	39 c5                	cmp    %eax,%ebp
  803605:	73 04                	jae    80360b <__udivdi3+0xfb>
  803607:	39 d6                	cmp    %edx,%esi
  803609:	74 0d                	je     803618 <__udivdi3+0x108>
  80360b:	89 d8                	mov    %ebx,%eax
  80360d:	31 ff                	xor    %edi,%edi
  80360f:	e9 3c ff ff ff       	jmp    803550 <__udivdi3+0x40>
  803614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803618:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80361b:	31 ff                	xor    %edi,%edi
  80361d:	e9 2e ff ff ff       	jmp    803550 <__udivdi3+0x40>
  803622:	66 90                	xchg   %ax,%ax
  803624:	66 90                	xchg   %ax,%ax
  803626:	66 90                	xchg   %ax,%ax
  803628:	66 90                	xchg   %ax,%ax
  80362a:	66 90                	xchg   %ax,%ax
  80362c:	66 90                	xchg   %ax,%ax
  80362e:	66 90                	xchg   %ax,%ax

00803630 <__umoddi3>:
  803630:	f3 0f 1e fb          	endbr32 
  803634:	55                   	push   %ebp
  803635:	57                   	push   %edi
  803636:	56                   	push   %esi
  803637:	53                   	push   %ebx
  803638:	83 ec 1c             	sub    $0x1c,%esp
  80363b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80363f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  803643:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  803647:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80364b:	89 f0                	mov    %esi,%eax
  80364d:	89 da                	mov    %ebx,%edx
  80364f:	85 ff                	test   %edi,%edi
  803651:	75 15                	jne    803668 <__umoddi3+0x38>
  803653:	39 dd                	cmp    %ebx,%ebp
  803655:	76 39                	jbe    803690 <__umoddi3+0x60>
  803657:	f7 f5                	div    %ebp
  803659:	89 d0                	mov    %edx,%eax
  80365b:	31 d2                	xor    %edx,%edx
  80365d:	83 c4 1c             	add    $0x1c,%esp
  803660:	5b                   	pop    %ebx
  803661:	5e                   	pop    %esi
  803662:	5f                   	pop    %edi
  803663:	5d                   	pop    %ebp
  803664:	c3                   	ret    
  803665:	8d 76 00             	lea    0x0(%esi),%esi
  803668:	39 df                	cmp    %ebx,%edi
  80366a:	77 f1                	ja     80365d <__umoddi3+0x2d>
  80366c:	0f bd cf             	bsr    %edi,%ecx
  80366f:	83 f1 1f             	xor    $0x1f,%ecx
  803672:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803676:	75 40                	jne    8036b8 <__umoddi3+0x88>
  803678:	39 df                	cmp    %ebx,%edi
  80367a:	72 04                	jb     803680 <__umoddi3+0x50>
  80367c:	39 f5                	cmp    %esi,%ebp
  80367e:	77 dd                	ja     80365d <__umoddi3+0x2d>
  803680:	89 da                	mov    %ebx,%edx
  803682:	89 f0                	mov    %esi,%eax
  803684:	29 e8                	sub    %ebp,%eax
  803686:	19 fa                	sbb    %edi,%edx
  803688:	eb d3                	jmp    80365d <__umoddi3+0x2d>
  80368a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803690:	89 e9                	mov    %ebp,%ecx
  803692:	85 ed                	test   %ebp,%ebp
  803694:	75 0b                	jne    8036a1 <__umoddi3+0x71>
  803696:	b8 01 00 00 00       	mov    $0x1,%eax
  80369b:	31 d2                	xor    %edx,%edx
  80369d:	f7 f5                	div    %ebp
  80369f:	89 c1                	mov    %eax,%ecx
  8036a1:	89 d8                	mov    %ebx,%eax
  8036a3:	31 d2                	xor    %edx,%edx
  8036a5:	f7 f1                	div    %ecx
  8036a7:	89 f0                	mov    %esi,%eax
  8036a9:	f7 f1                	div    %ecx
  8036ab:	89 d0                	mov    %edx,%eax
  8036ad:	31 d2                	xor    %edx,%edx
  8036af:	eb ac                	jmp    80365d <__umoddi3+0x2d>
  8036b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8036b8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8036bc:	ba 20 00 00 00       	mov    $0x20,%edx
  8036c1:	29 c2                	sub    %eax,%edx
  8036c3:	89 c1                	mov    %eax,%ecx
  8036c5:	89 e8                	mov    %ebp,%eax
  8036c7:	d3 e7                	shl    %cl,%edi
  8036c9:	89 d1                	mov    %edx,%ecx
  8036cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8036cf:	d3 e8                	shr    %cl,%eax
  8036d1:	89 c1                	mov    %eax,%ecx
  8036d3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8036d7:	09 f9                	or     %edi,%ecx
  8036d9:	89 df                	mov    %ebx,%edi
  8036db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8036df:	89 c1                	mov    %eax,%ecx
  8036e1:	d3 e5                	shl    %cl,%ebp
  8036e3:	89 d1                	mov    %edx,%ecx
  8036e5:	d3 ef                	shr    %cl,%edi
  8036e7:	89 c1                	mov    %eax,%ecx
  8036e9:	89 f0                	mov    %esi,%eax
  8036eb:	d3 e3                	shl    %cl,%ebx
  8036ed:	89 d1                	mov    %edx,%ecx
  8036ef:	89 fa                	mov    %edi,%edx
  8036f1:	d3 e8                	shr    %cl,%eax
  8036f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8036f8:	09 d8                	or     %ebx,%eax
  8036fa:	f7 74 24 08          	divl   0x8(%esp)
  8036fe:	89 d3                	mov    %edx,%ebx
  803700:	d3 e6                	shl    %cl,%esi
  803702:	f7 e5                	mul    %ebp
  803704:	89 c7                	mov    %eax,%edi
  803706:	89 d1                	mov    %edx,%ecx
  803708:	39 d3                	cmp    %edx,%ebx
  80370a:	72 06                	jb     803712 <__umoddi3+0xe2>
  80370c:	75 0e                	jne    80371c <__umoddi3+0xec>
  80370e:	39 c6                	cmp    %eax,%esi
  803710:	73 0a                	jae    80371c <__umoddi3+0xec>
  803712:	29 e8                	sub    %ebp,%eax
  803714:	1b 54 24 08          	sbb    0x8(%esp),%edx
  803718:	89 d1                	mov    %edx,%ecx
  80371a:	89 c7                	mov    %eax,%edi
  80371c:	89 f5                	mov    %esi,%ebp
  80371e:	8b 74 24 04          	mov    0x4(%esp),%esi
  803722:	29 fd                	sub    %edi,%ebp
  803724:	19 cb                	sbb    %ecx,%ebx
  803726:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80372b:	89 d8                	mov    %ebx,%eax
  80372d:	d3 e0                	shl    %cl,%eax
  80372f:	89 f1                	mov    %esi,%ecx
  803731:	d3 ed                	shr    %cl,%ebp
  803733:	d3 eb                	shr    %cl,%ebx
  803735:	09 e8                	or     %ebp,%eax
  803737:	89 da                	mov    %ebx,%edx
  803739:	83 c4 1c             	add    $0x1c,%esp
  80373c:	5b                   	pop    %ebx
  80373d:	5e                   	pop    %esi
  80373e:	5f                   	pop    %edi
  80373f:	5d                   	pop    %ebp
  803740:	c3                   	ret    
