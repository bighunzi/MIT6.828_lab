
obj/user/testshell.debug：     文件格式 elf32-i386


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
  80002c:	e8 54 04 00 00       	call   800485 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 e1 17 00 00       	call   801830 <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 d7 17 00 00       	call   801830 <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 a0 29 80 00 	movl   $0x8029a0,(%esp)
  800060:	e8 5b 05 00 00       	call   8005c0 <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 0b 2a 80 00 	movl   $0x802a0b,(%esp)
  80006c:	e8 4f 05 00 00       	call   8005c0 <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 57 0e 00 00       	call   800eda <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 4e 16 00 00       	call   8016e0 <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 1a 2a 80 00       	push   $0x802a1a
  8000a1:	e8 1a 05 00 00       	call   8005c0 <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 22 0e 00 00       	call   800eda <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 19 16 00 00       	call   8016e0 <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 15 2a 80 00       	push   $0x802a15
  8000d6:	e8 e5 04 00 00       	call   8005c0 <cprintf>
	exit();
  8000db:	e8 eb 03 00 00       	call   8004cb <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 a9 14 00 00       	call   8015a4 <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 9d 14 00 00       	call   8015a4 <close>
	opencons();
  800107:	e8 27 03 00 00       	call   800433 <opencons>
	opencons();
  80010c:	e8 22 03 00 00       	call   800433 <opencons>
	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 28 2a 80 00       	push   $0x802a28
  80011b:	e8 23 1a 00 00       	call   801b43 <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	0f 88 e7 00 00 00    	js     800214 <umain+0x129>
	if ((wfd = pipe(pfds)) < 0)
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	e8 8e 22 00 00       	call   8023c7 <pipe>
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	85 c0                	test   %eax,%eax
  80013e:	0f 88 e2 00 00 00    	js     800226 <umain+0x13b>
	wfd = pfds[1];
  800144:	8b 75 e0             	mov    -0x20(%ebp),%esi
	cprintf("running sh -x < testshell.sh | cat\n");
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	68 c4 29 80 00       	push   $0x8029c4
  80014f:	e8 6c 04 00 00       	call   8005c0 <cprintf>
	if ((r = fork()) < 0)
  800154:	e8 2c 11 00 00       	call   801285 <fork>
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	85 c0                	test   %eax,%eax
  80015e:	0f 88 d4 00 00 00    	js     800238 <umain+0x14d>
	if (r == 0) {
  800164:	75 6f                	jne    8001d5 <umain+0xea>
		dup(rfd, 0);
  800166:	83 ec 08             	sub    $0x8,%esp
  800169:	6a 00                	push   $0x0
  80016b:	53                   	push   %ebx
  80016c:	e8 85 14 00 00       	call   8015f6 <dup>
		dup(wfd, 1);
  800171:	83 c4 08             	add    $0x8,%esp
  800174:	6a 01                	push   $0x1
  800176:	56                   	push   %esi
  800177:	e8 7a 14 00 00       	call   8015f6 <dup>
		close(rfd);
  80017c:	89 1c 24             	mov    %ebx,(%esp)
  80017f:	e8 20 14 00 00       	call   8015a4 <close>
		close(wfd);
  800184:	89 34 24             	mov    %esi,(%esp)
  800187:	e8 18 14 00 00       	call   8015a4 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  80018c:	6a 00                	push   $0x0
  80018e:	68 65 2a 80 00       	push   $0x802a65
  800193:	68 32 2a 80 00       	push   $0x802a32
  800198:	68 68 2a 80 00       	push   $0x802a68
  80019d:	e8 b3 1f 00 00       	call   802155 <spawnl>
  8001a2:	89 c7                	mov    %eax,%edi
  8001a4:	83 c4 20             	add    $0x20,%esp
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	0f 88 9b 00 00 00    	js     80024a <umain+0x15f>
		close(0);
  8001af:	83 ec 0c             	sub    $0xc,%esp
  8001b2:	6a 00                	push   $0x0
  8001b4:	e8 eb 13 00 00       	call   8015a4 <close>
		close(1);
  8001b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001c0:	e8 df 13 00 00       	call   8015a4 <close>
		wait(r);
  8001c5:	89 3c 24             	mov    %edi,(%esp)
  8001c8:	e8 77 23 00 00       	call   802544 <wait>
		exit();
  8001cd:	e8 f9 02 00 00       	call   8004cb <exit>
  8001d2:	83 c4 10             	add    $0x10,%esp
	close(rfd);
  8001d5:	83 ec 0c             	sub    $0xc,%esp
  8001d8:	53                   	push   %ebx
  8001d9:	e8 c6 13 00 00       	call   8015a4 <close>
	close(wfd);
  8001de:	89 34 24             	mov    %esi,(%esp)
  8001e1:	e8 be 13 00 00       	call   8015a4 <close>
	rfd = pfds[0];
  8001e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  8001ec:	83 c4 08             	add    $0x8,%esp
  8001ef:	6a 00                	push   $0x0
  8001f1:	68 76 2a 80 00       	push   $0x802a76
  8001f6:	e8 48 19 00 00       	call   801b43 <open>
  8001fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001fe:	83 c4 10             	add    $0x10,%esp
  800201:	85 c0                	test   %eax,%eax
  800203:	78 57                	js     80025c <umain+0x171>
  800205:	be 01 00 00 00       	mov    $0x1,%esi
	nloff = 0;
  80020a:	bf 00 00 00 00       	mov    $0x0,%edi
  80020f:	e9 9a 00 00 00       	jmp    8002ae <umain+0x1c3>
		panic("open testshell.sh: %e", rfd);
  800214:	50                   	push   %eax
  800215:	68 35 2a 80 00       	push   $0x802a35
  80021a:	6a 13                	push   $0x13
  80021c:	68 4b 2a 80 00       	push   $0x802a4b
  800221:	e8 bf 02 00 00       	call   8004e5 <_panic>
		panic("pipe: %e", wfd);
  800226:	50                   	push   %eax
  800227:	68 5c 2a 80 00       	push   $0x802a5c
  80022c:	6a 15                	push   $0x15
  80022e:	68 4b 2a 80 00       	push   $0x802a4b
  800233:	e8 ad 02 00 00       	call   8004e5 <_panic>
		panic("fork: %e", r);
  800238:	50                   	push   %eax
  800239:	68 d8 2e 80 00       	push   $0x802ed8
  80023e:	6a 1a                	push   $0x1a
  800240:	68 4b 2a 80 00       	push   $0x802a4b
  800245:	e8 9b 02 00 00       	call   8004e5 <_panic>
			panic("spawn: %e", r);
  80024a:	50                   	push   %eax
  80024b:	68 6c 2a 80 00       	push   $0x802a6c
  800250:	6a 21                	push   $0x21
  800252:	68 4b 2a 80 00       	push   $0x802a4b
  800257:	e8 89 02 00 00       	call   8004e5 <_panic>
		panic("open testshell.key for reading: %e", kfd);
  80025c:	50                   	push   %eax
  80025d:	68 e8 29 80 00       	push   $0x8029e8
  800262:	6a 2c                	push   $0x2c
  800264:	68 4b 2a 80 00       	push   $0x802a4b
  800269:	e8 77 02 00 00       	call   8004e5 <_panic>
			panic("reading testshell.out: %e", n1);
  80026e:	53                   	push   %ebx
  80026f:	68 84 2a 80 00       	push   $0x802a84
  800274:	6a 33                	push   $0x33
  800276:	68 4b 2a 80 00       	push   $0x802a4b
  80027b:	e8 65 02 00 00       	call   8004e5 <_panic>
			panic("reading testshell.key: %e", n2);
  800280:	50                   	push   %eax
  800281:	68 9e 2a 80 00       	push   $0x802a9e
  800286:	6a 35                	push   $0x35
  800288:	68 4b 2a 80 00       	push   $0x802a4b
  80028d:	e8 53 02 00 00       	call   8004e5 <_panic>
			wrong(rfd, kfd, nloff);
  800292:	83 ec 04             	sub    $0x4,%esp
  800295:	57                   	push   %edi
  800296:	ff 75 d4             	push   -0x2c(%ebp)
  800299:	ff 75 d0             	push   -0x30(%ebp)
  80029c:	e8 92 fd ff ff       	call   800033 <wrong>
  8002a1:	83 c4 10             	add    $0x10,%esp
			nloff = off+1;
  8002a4:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002a8:	0f 44 fe             	cmove  %esi,%edi
  8002ab:	83 c6 01             	add    $0x1,%esi
		n1 = read(rfd, &c1, 1);
  8002ae:	83 ec 04             	sub    $0x4,%esp
  8002b1:	6a 01                	push   $0x1
  8002b3:	8d 45 e7             	lea    -0x19(%ebp),%eax
  8002b6:	50                   	push   %eax
  8002b7:	ff 75 d0             	push   -0x30(%ebp)
  8002ba:	e8 21 14 00 00       	call   8016e0 <read>
  8002bf:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  8002c1:	83 c4 0c             	add    $0xc,%esp
  8002c4:	6a 01                	push   $0x1
  8002c6:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  8002c9:	50                   	push   %eax
  8002ca:	ff 75 d4             	push   -0x2c(%ebp)
  8002cd:	e8 0e 14 00 00       	call   8016e0 <read>
		if (n1 < 0)
  8002d2:	83 c4 10             	add    $0x10,%esp
  8002d5:	85 db                	test   %ebx,%ebx
  8002d7:	78 95                	js     80026e <umain+0x183>
		if (n2 < 0)
  8002d9:	85 c0                	test   %eax,%eax
  8002db:	78 a3                	js     800280 <umain+0x195>
		if (n1 == 0 && n2 == 0)
  8002dd:	89 da                	mov    %ebx,%edx
  8002df:	09 c2                	or     %eax,%edx
  8002e1:	74 15                	je     8002f8 <umain+0x20d>
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002e3:	83 fb 01             	cmp    $0x1,%ebx
  8002e6:	75 aa                	jne    800292 <umain+0x1a7>
  8002e8:	83 f8 01             	cmp    $0x1,%eax
  8002eb:	75 a5                	jne    800292 <umain+0x1a7>
  8002ed:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002f1:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002f4:	75 9c                	jne    800292 <umain+0x1a7>
  8002f6:	eb ac                	jmp    8002a4 <umain+0x1b9>
	cprintf("shell ran correctly\n");
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	68 b8 2a 80 00       	push   $0x802ab8
  800300:	e8 bb 02 00 00       	call   8005c0 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800305:	cc                   	int3   
}
  800306:	83 c4 10             	add    $0x10,%esp
  800309:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030c:	5b                   	pop    %ebx
  80030d:	5e                   	pop    %esi
  80030e:	5f                   	pop    %edi
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  800311:	b8 00 00 00 00       	mov    $0x0,%eax
  800316:	c3                   	ret    

00800317 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
  80031a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80031d:	68 cd 2a 80 00       	push   $0x802acd
  800322:	ff 75 0c             	push   0xc(%ebp)
  800325:	e8 70 08 00 00       	call   800b9a <strcpy>
	return 0;
}
  80032a:	b8 00 00 00 00       	mov    $0x0,%eax
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <devcons_write>:
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80033d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800342:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800348:	eb 2e                	jmp    800378 <devcons_write+0x47>
		m = n - tot;
  80034a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80034d:	29 f3                	sub    %esi,%ebx
  80034f:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800354:	39 c3                	cmp    %eax,%ebx
  800356:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800359:	83 ec 04             	sub    $0x4,%esp
  80035c:	53                   	push   %ebx
  80035d:	89 f0                	mov    %esi,%eax
  80035f:	03 45 0c             	add    0xc(%ebp),%eax
  800362:	50                   	push   %eax
  800363:	57                   	push   %edi
  800364:	e8 c7 09 00 00       	call   800d30 <memmove>
		sys_cputs(buf, m);
  800369:	83 c4 08             	add    $0x8,%esp
  80036c:	53                   	push   %ebx
  80036d:	57                   	push   %edi
  80036e:	e8 67 0b 00 00       	call   800eda <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800373:	01 de                	add    %ebx,%esi
  800375:	83 c4 10             	add    $0x10,%esp
  800378:	3b 75 10             	cmp    0x10(%ebp),%esi
  80037b:	72 cd                	jb     80034a <devcons_write+0x19>
}
  80037d:	89 f0                	mov    %esi,%eax
  80037f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800382:	5b                   	pop    %ebx
  800383:	5e                   	pop    %esi
  800384:	5f                   	pop    %edi
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    

00800387 <devcons_read>:
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800392:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800396:	75 07                	jne    80039f <devcons_read+0x18>
  800398:	eb 1f                	jmp    8003b9 <devcons_read+0x32>
		sys_yield();
  80039a:	e8 d8 0b 00 00       	call   800f77 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80039f:	e8 54 0b 00 00       	call   800ef8 <sys_cgetc>
  8003a4:	85 c0                	test   %eax,%eax
  8003a6:	74 f2                	je     80039a <devcons_read+0x13>
	if (c < 0)
  8003a8:	78 0f                	js     8003b9 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8003aa:	83 f8 04             	cmp    $0x4,%eax
  8003ad:	74 0c                	je     8003bb <devcons_read+0x34>
	*(char*)vbuf = c;
  8003af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b2:	88 02                	mov    %al,(%edx)
	return 1;
  8003b4:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8003b9:	c9                   	leave  
  8003ba:	c3                   	ret    
		return 0;
  8003bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c0:	eb f7                	jmp    8003b9 <devcons_read+0x32>

008003c2 <cputchar>:
{
  8003c2:	55                   	push   %ebp
  8003c3:	89 e5                	mov    %esp,%ebp
  8003c5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cb:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8003ce:	6a 01                	push   $0x1
  8003d0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003d3:	50                   	push   %eax
  8003d4:	e8 01 0b 00 00       	call   800eda <sys_cputs>
}
  8003d9:	83 c4 10             	add    $0x10,%esp
  8003dc:	c9                   	leave  
  8003dd:	c3                   	ret    

008003de <getchar>:
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8003e4:	6a 01                	push   $0x1
  8003e6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003e9:	50                   	push   %eax
  8003ea:	6a 00                	push   $0x0
  8003ec:	e8 ef 12 00 00       	call   8016e0 <read>
	if (r < 0)
  8003f1:	83 c4 10             	add    $0x10,%esp
  8003f4:	85 c0                	test   %eax,%eax
  8003f6:	78 06                	js     8003fe <getchar+0x20>
	if (r < 1)
  8003f8:	74 06                	je     800400 <getchar+0x22>
	return c;
  8003fa:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8003fe:	c9                   	leave  
  8003ff:	c3                   	ret    
		return -E_EOF;
  800400:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800405:	eb f7                	jmp    8003fe <getchar+0x20>

00800407 <iscons>:
{
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
  80040a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80040d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800410:	50                   	push   %eax
  800411:	ff 75 08             	push   0x8(%ebp)
  800414:	e8 63 10 00 00       	call   80147c <fd_lookup>
  800419:	83 c4 10             	add    $0x10,%esp
  80041c:	85 c0                	test   %eax,%eax
  80041e:	78 11                	js     800431 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800420:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800423:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800429:	39 10                	cmp    %edx,(%eax)
  80042b:	0f 94 c0             	sete   %al
  80042e:	0f b6 c0             	movzbl %al,%eax
}
  800431:	c9                   	leave  
  800432:	c3                   	ret    

00800433 <opencons>:
{
  800433:	55                   	push   %ebp
  800434:	89 e5                	mov    %esp,%ebp
  800436:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800439:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80043c:	50                   	push   %eax
  80043d:	e8 ea 0f 00 00       	call   80142c <fd_alloc>
  800442:	83 c4 10             	add    $0x10,%esp
  800445:	85 c0                	test   %eax,%eax
  800447:	78 3a                	js     800483 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800449:	83 ec 04             	sub    $0x4,%esp
  80044c:	68 07 04 00 00       	push   $0x407
  800451:	ff 75 f4             	push   -0xc(%ebp)
  800454:	6a 00                	push   $0x0
  800456:	e8 3b 0b 00 00       	call   800f96 <sys_page_alloc>
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	85 c0                	test   %eax,%eax
  800460:	78 21                	js     800483 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800462:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800465:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80046b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80046d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800470:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800477:	83 ec 0c             	sub    $0xc,%esp
  80047a:	50                   	push   %eax
  80047b:	e8 85 0f 00 00       	call   801405 <fd2num>
  800480:	83 c4 10             	add    $0x10,%esp
}
  800483:	c9                   	leave  
  800484:	c3                   	ret    

00800485 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800485:	55                   	push   %ebp
  800486:	89 e5                	mov    %esp,%ebp
  800488:	56                   	push   %esi
  800489:	53                   	push   %ebx
  80048a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80048d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800490:	e8 c3 0a 00 00       	call   800f58 <sys_getenvid>
  800495:	25 ff 03 00 00       	and    $0x3ff,%eax
  80049a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80049d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004a2:	a3 00 50 80 00       	mov    %eax,0x805000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004a7:	85 db                	test   %ebx,%ebx
  8004a9:	7e 07                	jle    8004b2 <libmain+0x2d>
		binaryname = argv[0];
  8004ab:	8b 06                	mov    (%esi),%eax
  8004ad:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	56                   	push   %esi
  8004b6:	53                   	push   %ebx
  8004b7:	e8 2f fc ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8004bc:	e8 0a 00 00 00       	call   8004cb <exit>
}
  8004c1:	83 c4 10             	add    $0x10,%esp
  8004c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c7:	5b                   	pop    %ebx
  8004c8:	5e                   	pop    %esi
  8004c9:	5d                   	pop    %ebp
  8004ca:	c3                   	ret    

008004cb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004cb:	55                   	push   %ebp
  8004cc:	89 e5                	mov    %esp,%ebp
  8004ce:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004d1:	e8 fb 10 00 00       	call   8015d1 <close_all>
	sys_env_destroy(0);
  8004d6:	83 ec 0c             	sub    $0xc,%esp
  8004d9:	6a 00                	push   $0x0
  8004db:	e8 37 0a 00 00       	call   800f17 <sys_env_destroy>
}
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	c9                   	leave  
  8004e4:	c3                   	ret    

008004e5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e5:	55                   	push   %ebp
  8004e6:	89 e5                	mov    %esp,%ebp
  8004e8:	56                   	push   %esi
  8004e9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004ea:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ed:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8004f3:	e8 60 0a 00 00       	call   800f58 <sys_getenvid>
  8004f8:	83 ec 0c             	sub    $0xc,%esp
  8004fb:	ff 75 0c             	push   0xc(%ebp)
  8004fe:	ff 75 08             	push   0x8(%ebp)
  800501:	56                   	push   %esi
  800502:	50                   	push   %eax
  800503:	68 e4 2a 80 00       	push   $0x802ae4
  800508:	e8 b3 00 00 00       	call   8005c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050d:	83 c4 18             	add    $0x18,%esp
  800510:	53                   	push   %ebx
  800511:	ff 75 10             	push   0x10(%ebp)
  800514:	e8 56 00 00 00       	call   80056f <vcprintf>
	cprintf("\n");
  800519:	c7 04 24 18 2a 80 00 	movl   $0x802a18,(%esp)
  800520:	e8 9b 00 00 00       	call   8005c0 <cprintf>
  800525:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800528:	cc                   	int3   
  800529:	eb fd                	jmp    800528 <_panic+0x43>

0080052b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052b:	55                   	push   %ebp
  80052c:	89 e5                	mov    %esp,%ebp
  80052e:	53                   	push   %ebx
  80052f:	83 ec 04             	sub    $0x4,%esp
  800532:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800535:	8b 13                	mov    (%ebx),%edx
  800537:	8d 42 01             	lea    0x1(%edx),%eax
  80053a:	89 03                	mov    %eax,(%ebx)
  80053c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80053f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800543:	3d ff 00 00 00       	cmp    $0xff,%eax
  800548:	74 09                	je     800553 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80054a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80054e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800551:	c9                   	leave  
  800552:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	68 ff 00 00 00       	push   $0xff
  80055b:	8d 43 08             	lea    0x8(%ebx),%eax
  80055e:	50                   	push   %eax
  80055f:	e8 76 09 00 00       	call   800eda <sys_cputs>
		b->idx = 0;
  800564:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80056a:	83 c4 10             	add    $0x10,%esp
  80056d:	eb db                	jmp    80054a <putch+0x1f>

0080056f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80056f:	55                   	push   %ebp
  800570:	89 e5                	mov    %esp,%ebp
  800572:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800578:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80057f:	00 00 00 
	b.cnt = 0;
  800582:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800589:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80058c:	ff 75 0c             	push   0xc(%ebp)
  80058f:	ff 75 08             	push   0x8(%ebp)
  800592:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800598:	50                   	push   %eax
  800599:	68 2b 05 80 00       	push   $0x80052b
  80059e:	e8 14 01 00 00       	call   8006b7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a3:	83 c4 08             	add    $0x8,%esp
  8005a6:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8005ac:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005b2:	50                   	push   %eax
  8005b3:	e8 22 09 00 00       	call   800eda <sys_cputs>

	return b.cnt;
}
  8005b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005be:	c9                   	leave  
  8005bf:	c3                   	ret    

008005c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005c0:	55                   	push   %ebp
  8005c1:	89 e5                	mov    %esp,%ebp
  8005c3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005c9:	50                   	push   %eax
  8005ca:	ff 75 08             	push   0x8(%ebp)
  8005cd:	e8 9d ff ff ff       	call   80056f <vcprintf>
	va_end(ap);

	return cnt;
}
  8005d2:	c9                   	leave  
  8005d3:	c3                   	ret    

008005d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d4:	55                   	push   %ebp
  8005d5:	89 e5                	mov    %esp,%ebp
  8005d7:	57                   	push   %edi
  8005d8:	56                   	push   %esi
  8005d9:	53                   	push   %ebx
  8005da:	83 ec 1c             	sub    $0x1c,%esp
  8005dd:	89 c7                	mov    %eax,%edi
  8005df:	89 d6                	mov    %edx,%esi
  8005e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e7:	89 d1                	mov    %edx,%ecx
  8005e9:	89 c2                	mov    %eax,%edx
  8005eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ee:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005fa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800601:	39 c2                	cmp    %eax,%edx
  800603:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800606:	72 3e                	jb     800646 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800608:	83 ec 0c             	sub    $0xc,%esp
  80060b:	ff 75 18             	push   0x18(%ebp)
  80060e:	83 eb 01             	sub    $0x1,%ebx
  800611:	53                   	push   %ebx
  800612:	50                   	push   %eax
  800613:	83 ec 08             	sub    $0x8,%esp
  800616:	ff 75 e4             	push   -0x1c(%ebp)
  800619:	ff 75 e0             	push   -0x20(%ebp)
  80061c:	ff 75 dc             	push   -0x24(%ebp)
  80061f:	ff 75 d8             	push   -0x28(%ebp)
  800622:	e8 39 21 00 00       	call   802760 <__udivdi3>
  800627:	83 c4 18             	add    $0x18,%esp
  80062a:	52                   	push   %edx
  80062b:	50                   	push   %eax
  80062c:	89 f2                	mov    %esi,%edx
  80062e:	89 f8                	mov    %edi,%eax
  800630:	e8 9f ff ff ff       	call   8005d4 <printnum>
  800635:	83 c4 20             	add    $0x20,%esp
  800638:	eb 13                	jmp    80064d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	56                   	push   %esi
  80063e:	ff 75 18             	push   0x18(%ebp)
  800641:	ff d7                	call   *%edi
  800643:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800646:	83 eb 01             	sub    $0x1,%ebx
  800649:	85 db                	test   %ebx,%ebx
  80064b:	7f ed                	jg     80063a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	56                   	push   %esi
  800651:	83 ec 04             	sub    $0x4,%esp
  800654:	ff 75 e4             	push   -0x1c(%ebp)
  800657:	ff 75 e0             	push   -0x20(%ebp)
  80065a:	ff 75 dc             	push   -0x24(%ebp)
  80065d:	ff 75 d8             	push   -0x28(%ebp)
  800660:	e8 1b 22 00 00       	call   802880 <__umoddi3>
  800665:	83 c4 14             	add    $0x14,%esp
  800668:	0f be 80 07 2b 80 00 	movsbl 0x802b07(%eax),%eax
  80066f:	50                   	push   %eax
  800670:	ff d7                	call   *%edi
}
  800672:	83 c4 10             	add    $0x10,%esp
  800675:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800678:	5b                   	pop    %ebx
  800679:	5e                   	pop    %esi
  80067a:	5f                   	pop    %edi
  80067b:	5d                   	pop    %ebp
  80067c:	c3                   	ret    

0080067d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800683:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800687:	8b 10                	mov    (%eax),%edx
  800689:	3b 50 04             	cmp    0x4(%eax),%edx
  80068c:	73 0a                	jae    800698 <sprintputch+0x1b>
		*b->buf++ = ch;
  80068e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800691:	89 08                	mov    %ecx,(%eax)
  800693:	8b 45 08             	mov    0x8(%ebp),%eax
  800696:	88 02                	mov    %al,(%edx)
}
  800698:	5d                   	pop    %ebp
  800699:	c3                   	ret    

0080069a <printfmt>:
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8006a0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006a3:	50                   	push   %eax
  8006a4:	ff 75 10             	push   0x10(%ebp)
  8006a7:	ff 75 0c             	push   0xc(%ebp)
  8006aa:	ff 75 08             	push   0x8(%ebp)
  8006ad:	e8 05 00 00 00       	call   8006b7 <vprintfmt>
}
  8006b2:	83 c4 10             	add    $0x10,%esp
  8006b5:	c9                   	leave  
  8006b6:	c3                   	ret    

008006b7 <vprintfmt>:
{
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	57                   	push   %edi
  8006bb:	56                   	push   %esi
  8006bc:	53                   	push   %ebx
  8006bd:	83 ec 3c             	sub    $0x3c,%esp
  8006c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006c9:	eb 0a                	jmp    8006d5 <vprintfmt+0x1e>
			putch(ch, putdat);
  8006cb:	83 ec 08             	sub    $0x8,%esp
  8006ce:	53                   	push   %ebx
  8006cf:	50                   	push   %eax
  8006d0:	ff d6                	call   *%esi
  8006d2:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d5:	83 c7 01             	add    $0x1,%edi
  8006d8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006dc:	83 f8 25             	cmp    $0x25,%eax
  8006df:	74 0c                	je     8006ed <vprintfmt+0x36>
			if (ch == '\0')
  8006e1:	85 c0                	test   %eax,%eax
  8006e3:	75 e6                	jne    8006cb <vprintfmt+0x14>
}
  8006e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e8:	5b                   	pop    %ebx
  8006e9:	5e                   	pop    %esi
  8006ea:	5f                   	pop    %edi
  8006eb:	5d                   	pop    %ebp
  8006ec:	c3                   	ret    
		padc = ' ';
  8006ed:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8006f1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8006f8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8006ff:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800706:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80070b:	8d 47 01             	lea    0x1(%edi),%eax
  80070e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800711:	0f b6 17             	movzbl (%edi),%edx
  800714:	8d 42 dd             	lea    -0x23(%edx),%eax
  800717:	3c 55                	cmp    $0x55,%al
  800719:	0f 87 bb 03 00 00    	ja     800ada <vprintfmt+0x423>
  80071f:	0f b6 c0             	movzbl %al,%eax
  800722:	ff 24 85 40 2c 80 00 	jmp    *0x802c40(,%eax,4)
  800729:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80072c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800730:	eb d9                	jmp    80070b <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800732:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800735:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800739:	eb d0                	jmp    80070b <vprintfmt+0x54>
  80073b:	0f b6 d2             	movzbl %dl,%edx
  80073e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800741:	b8 00 00 00 00       	mov    $0x0,%eax
  800746:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800749:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80074c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800750:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800753:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800756:	83 f9 09             	cmp    $0x9,%ecx
  800759:	77 55                	ja     8007b0 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80075b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80075e:	eb e9                	jmp    800749 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800760:	8b 45 14             	mov    0x14(%ebp),%eax
  800763:	8b 00                	mov    (%eax),%eax
  800765:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8d 40 04             	lea    0x4(%eax),%eax
  80076e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800771:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800774:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800778:	79 91                	jns    80070b <vprintfmt+0x54>
				width = precision, precision = -1;
  80077a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80077d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800780:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800787:	eb 82                	jmp    80070b <vprintfmt+0x54>
  800789:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80078c:	85 d2                	test   %edx,%edx
  80078e:	b8 00 00 00 00       	mov    $0x0,%eax
  800793:	0f 49 c2             	cmovns %edx,%eax
  800796:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800799:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80079c:	e9 6a ff ff ff       	jmp    80070b <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8007a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8007a4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8007ab:	e9 5b ff ff ff       	jmp    80070b <vprintfmt+0x54>
  8007b0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8007b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b6:	eb bc                	jmp    800774 <vprintfmt+0xbd>
			lflag++;
  8007b8:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8007bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8007be:	e9 48 ff ff ff       	jmp    80070b <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8d 78 04             	lea    0x4(%eax),%edi
  8007c9:	83 ec 08             	sub    $0x8,%esp
  8007cc:	53                   	push   %ebx
  8007cd:	ff 30                	push   (%eax)
  8007cf:	ff d6                	call   *%esi
			break;
  8007d1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8007d4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8007d7:	e9 9d 02 00 00       	jmp    800a79 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8007dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007df:	8d 78 04             	lea    0x4(%eax),%edi
  8007e2:	8b 10                	mov    (%eax),%edx
  8007e4:	89 d0                	mov    %edx,%eax
  8007e6:	f7 d8                	neg    %eax
  8007e8:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007eb:	83 f8 0f             	cmp    $0xf,%eax
  8007ee:	7f 23                	jg     800813 <vprintfmt+0x15c>
  8007f0:	8b 14 85 a0 2d 80 00 	mov    0x802da0(,%eax,4),%edx
  8007f7:	85 d2                	test   %edx,%edx
  8007f9:	74 18                	je     800813 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8007fb:	52                   	push   %edx
  8007fc:	68 9d 2f 80 00       	push   $0x802f9d
  800801:	53                   	push   %ebx
  800802:	56                   	push   %esi
  800803:	e8 92 fe ff ff       	call   80069a <printfmt>
  800808:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80080b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80080e:	e9 66 02 00 00       	jmp    800a79 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800813:	50                   	push   %eax
  800814:	68 1f 2b 80 00       	push   $0x802b1f
  800819:	53                   	push   %ebx
  80081a:	56                   	push   %esi
  80081b:	e8 7a fe ff ff       	call   80069a <printfmt>
  800820:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800823:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800826:	e9 4e 02 00 00       	jmp    800a79 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80082b:	8b 45 14             	mov    0x14(%ebp),%eax
  80082e:	83 c0 04             	add    $0x4,%eax
  800831:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800834:	8b 45 14             	mov    0x14(%ebp),%eax
  800837:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800839:	85 d2                	test   %edx,%edx
  80083b:	b8 18 2b 80 00       	mov    $0x802b18,%eax
  800840:	0f 45 c2             	cmovne %edx,%eax
  800843:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800846:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80084a:	7e 06                	jle    800852 <vprintfmt+0x19b>
  80084c:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800850:	75 0d                	jne    80085f <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800852:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800855:	89 c7                	mov    %eax,%edi
  800857:	03 45 e0             	add    -0x20(%ebp),%eax
  80085a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80085d:	eb 55                	jmp    8008b4 <vprintfmt+0x1fd>
  80085f:	83 ec 08             	sub    $0x8,%esp
  800862:	ff 75 d8             	push   -0x28(%ebp)
  800865:	ff 75 cc             	push   -0x34(%ebp)
  800868:	e8 0a 03 00 00       	call   800b77 <strnlen>
  80086d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800870:	29 c1                	sub    %eax,%ecx
  800872:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800875:	83 c4 10             	add    $0x10,%esp
  800878:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80087a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80087e:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800881:	eb 0f                	jmp    800892 <vprintfmt+0x1db>
					putch(padc, putdat);
  800883:	83 ec 08             	sub    $0x8,%esp
  800886:	53                   	push   %ebx
  800887:	ff 75 e0             	push   -0x20(%ebp)
  80088a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80088c:	83 ef 01             	sub    $0x1,%edi
  80088f:	83 c4 10             	add    $0x10,%esp
  800892:	85 ff                	test   %edi,%edi
  800894:	7f ed                	jg     800883 <vprintfmt+0x1cc>
  800896:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800899:	85 d2                	test   %edx,%edx
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a0:	0f 49 c2             	cmovns %edx,%eax
  8008a3:	29 c2                	sub    %eax,%edx
  8008a5:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8008a8:	eb a8                	jmp    800852 <vprintfmt+0x19b>
					putch(ch, putdat);
  8008aa:	83 ec 08             	sub    $0x8,%esp
  8008ad:	53                   	push   %ebx
  8008ae:	52                   	push   %edx
  8008af:	ff d6                	call   *%esi
  8008b1:	83 c4 10             	add    $0x10,%esp
  8008b4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008b7:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008b9:	83 c7 01             	add    $0x1,%edi
  8008bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008c0:	0f be d0             	movsbl %al,%edx
  8008c3:	85 d2                	test   %edx,%edx
  8008c5:	74 4b                	je     800912 <vprintfmt+0x25b>
  8008c7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008cb:	78 06                	js     8008d3 <vprintfmt+0x21c>
  8008cd:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8008d1:	78 1e                	js     8008f1 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8008d3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8008d7:	74 d1                	je     8008aa <vprintfmt+0x1f3>
  8008d9:	0f be c0             	movsbl %al,%eax
  8008dc:	83 e8 20             	sub    $0x20,%eax
  8008df:	83 f8 5e             	cmp    $0x5e,%eax
  8008e2:	76 c6                	jbe    8008aa <vprintfmt+0x1f3>
					putch('?', putdat);
  8008e4:	83 ec 08             	sub    $0x8,%esp
  8008e7:	53                   	push   %ebx
  8008e8:	6a 3f                	push   $0x3f
  8008ea:	ff d6                	call   *%esi
  8008ec:	83 c4 10             	add    $0x10,%esp
  8008ef:	eb c3                	jmp    8008b4 <vprintfmt+0x1fd>
  8008f1:	89 cf                	mov    %ecx,%edi
  8008f3:	eb 0e                	jmp    800903 <vprintfmt+0x24c>
				putch(' ', putdat);
  8008f5:	83 ec 08             	sub    $0x8,%esp
  8008f8:	53                   	push   %ebx
  8008f9:	6a 20                	push   $0x20
  8008fb:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8008fd:	83 ef 01             	sub    $0x1,%edi
  800900:	83 c4 10             	add    $0x10,%esp
  800903:	85 ff                	test   %edi,%edi
  800905:	7f ee                	jg     8008f5 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800907:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80090a:	89 45 14             	mov    %eax,0x14(%ebp)
  80090d:	e9 67 01 00 00       	jmp    800a79 <vprintfmt+0x3c2>
  800912:	89 cf                	mov    %ecx,%edi
  800914:	eb ed                	jmp    800903 <vprintfmt+0x24c>
	if (lflag >= 2)
  800916:	83 f9 01             	cmp    $0x1,%ecx
  800919:	7f 1b                	jg     800936 <vprintfmt+0x27f>
	else if (lflag)
  80091b:	85 c9                	test   %ecx,%ecx
  80091d:	74 63                	je     800982 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80091f:	8b 45 14             	mov    0x14(%ebp),%eax
  800922:	8b 00                	mov    (%eax),%eax
  800924:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800927:	99                   	cltd   
  800928:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80092b:	8b 45 14             	mov    0x14(%ebp),%eax
  80092e:	8d 40 04             	lea    0x4(%eax),%eax
  800931:	89 45 14             	mov    %eax,0x14(%ebp)
  800934:	eb 17                	jmp    80094d <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800936:	8b 45 14             	mov    0x14(%ebp),%eax
  800939:	8b 50 04             	mov    0x4(%eax),%edx
  80093c:	8b 00                	mov    (%eax),%eax
  80093e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800941:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800944:	8b 45 14             	mov    0x14(%ebp),%eax
  800947:	8d 40 08             	lea    0x8(%eax),%eax
  80094a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80094d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800950:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800953:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800958:	85 c9                	test   %ecx,%ecx
  80095a:	0f 89 ff 00 00 00    	jns    800a5f <vprintfmt+0x3a8>
				putch('-', putdat);
  800960:	83 ec 08             	sub    $0x8,%esp
  800963:	53                   	push   %ebx
  800964:	6a 2d                	push   $0x2d
  800966:	ff d6                	call   *%esi
				num = -(long long) num;
  800968:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80096b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80096e:	f7 da                	neg    %edx
  800970:	83 d1 00             	adc    $0x0,%ecx
  800973:	f7 d9                	neg    %ecx
  800975:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800978:	bf 0a 00 00 00       	mov    $0xa,%edi
  80097d:	e9 dd 00 00 00       	jmp    800a5f <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800982:	8b 45 14             	mov    0x14(%ebp),%eax
  800985:	8b 00                	mov    (%eax),%eax
  800987:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80098a:	99                   	cltd   
  80098b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80098e:	8b 45 14             	mov    0x14(%ebp),%eax
  800991:	8d 40 04             	lea    0x4(%eax),%eax
  800994:	89 45 14             	mov    %eax,0x14(%ebp)
  800997:	eb b4                	jmp    80094d <vprintfmt+0x296>
	if (lflag >= 2)
  800999:	83 f9 01             	cmp    $0x1,%ecx
  80099c:	7f 1e                	jg     8009bc <vprintfmt+0x305>
	else if (lflag)
  80099e:	85 c9                	test   %ecx,%ecx
  8009a0:	74 32                	je     8009d4 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8009a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a5:	8b 10                	mov    (%eax),%edx
  8009a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009ac:	8d 40 04             	lea    0x4(%eax),%eax
  8009af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009b2:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8009b7:	e9 a3 00 00 00       	jmp    800a5f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8009bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bf:	8b 10                	mov    (%eax),%edx
  8009c1:	8b 48 04             	mov    0x4(%eax),%ecx
  8009c4:	8d 40 08             	lea    0x8(%eax),%eax
  8009c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009ca:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8009cf:	e9 8b 00 00 00       	jmp    800a5f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8009d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d7:	8b 10                	mov    (%eax),%edx
  8009d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009de:	8d 40 04             	lea    0x4(%eax),%eax
  8009e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009e4:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8009e9:	eb 74                	jmp    800a5f <vprintfmt+0x3a8>
	if (lflag >= 2)
  8009eb:	83 f9 01             	cmp    $0x1,%ecx
  8009ee:	7f 1b                	jg     800a0b <vprintfmt+0x354>
	else if (lflag)
  8009f0:	85 c9                	test   %ecx,%ecx
  8009f2:	74 2c                	je     800a20 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8009f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f7:	8b 10                	mov    (%eax),%edx
  8009f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009fe:	8d 40 04             	lea    0x4(%eax),%eax
  800a01:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a04:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800a09:	eb 54                	jmp    800a5f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800a0b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0e:	8b 10                	mov    (%eax),%edx
  800a10:	8b 48 04             	mov    0x4(%eax),%ecx
  800a13:	8d 40 08             	lea    0x8(%eax),%eax
  800a16:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a19:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800a1e:	eb 3f                	jmp    800a5f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800a20:	8b 45 14             	mov    0x14(%ebp),%eax
  800a23:	8b 10                	mov    (%eax),%edx
  800a25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a2a:	8d 40 04             	lea    0x4(%eax),%eax
  800a2d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a30:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800a35:	eb 28                	jmp    800a5f <vprintfmt+0x3a8>
			putch('0', putdat);
  800a37:	83 ec 08             	sub    $0x8,%esp
  800a3a:	53                   	push   %ebx
  800a3b:	6a 30                	push   $0x30
  800a3d:	ff d6                	call   *%esi
			putch('x', putdat);
  800a3f:	83 c4 08             	add    $0x8,%esp
  800a42:	53                   	push   %ebx
  800a43:	6a 78                	push   $0x78
  800a45:	ff d6                	call   *%esi
			num = (unsigned long long)
  800a47:	8b 45 14             	mov    0x14(%ebp),%eax
  800a4a:	8b 10                	mov    (%eax),%edx
  800a4c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800a51:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800a54:	8d 40 04             	lea    0x4(%eax),%eax
  800a57:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a5a:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800a5f:	83 ec 0c             	sub    $0xc,%esp
  800a62:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800a66:	50                   	push   %eax
  800a67:	ff 75 e0             	push   -0x20(%ebp)
  800a6a:	57                   	push   %edi
  800a6b:	51                   	push   %ecx
  800a6c:	52                   	push   %edx
  800a6d:	89 da                	mov    %ebx,%edx
  800a6f:	89 f0                	mov    %esi,%eax
  800a71:	e8 5e fb ff ff       	call   8005d4 <printnum>
			break;
  800a76:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800a79:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a7c:	e9 54 fc ff ff       	jmp    8006d5 <vprintfmt+0x1e>
	if (lflag >= 2)
  800a81:	83 f9 01             	cmp    $0x1,%ecx
  800a84:	7f 1b                	jg     800aa1 <vprintfmt+0x3ea>
	else if (lflag)
  800a86:	85 c9                	test   %ecx,%ecx
  800a88:	74 2c                	je     800ab6 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800a8a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8d:	8b 10                	mov    (%eax),%edx
  800a8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a94:	8d 40 04             	lea    0x4(%eax),%eax
  800a97:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a9a:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800a9f:	eb be                	jmp    800a5f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800aa1:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa4:	8b 10                	mov    (%eax),%edx
  800aa6:	8b 48 04             	mov    0x4(%eax),%ecx
  800aa9:	8d 40 08             	lea    0x8(%eax),%eax
  800aac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800aaf:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800ab4:	eb a9                	jmp    800a5f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800ab6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab9:	8b 10                	mov    (%eax),%edx
  800abb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac0:	8d 40 04             	lea    0x4(%eax),%eax
  800ac3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ac6:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800acb:	eb 92                	jmp    800a5f <vprintfmt+0x3a8>
			putch(ch, putdat);
  800acd:	83 ec 08             	sub    $0x8,%esp
  800ad0:	53                   	push   %ebx
  800ad1:	6a 25                	push   $0x25
  800ad3:	ff d6                	call   *%esi
			break;
  800ad5:	83 c4 10             	add    $0x10,%esp
  800ad8:	eb 9f                	jmp    800a79 <vprintfmt+0x3c2>
			putch('%', putdat);
  800ada:	83 ec 08             	sub    $0x8,%esp
  800add:	53                   	push   %ebx
  800ade:	6a 25                	push   $0x25
  800ae0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ae2:	83 c4 10             	add    $0x10,%esp
  800ae5:	89 f8                	mov    %edi,%eax
  800ae7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800aeb:	74 05                	je     800af2 <vprintfmt+0x43b>
  800aed:	83 e8 01             	sub    $0x1,%eax
  800af0:	eb f5                	jmp    800ae7 <vprintfmt+0x430>
  800af2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800af5:	eb 82                	jmp    800a79 <vprintfmt+0x3c2>

00800af7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	83 ec 18             	sub    $0x18,%esp
  800afd:	8b 45 08             	mov    0x8(%ebp),%eax
  800b00:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b03:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b06:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b0a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b0d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b14:	85 c0                	test   %eax,%eax
  800b16:	74 26                	je     800b3e <vsnprintf+0x47>
  800b18:	85 d2                	test   %edx,%edx
  800b1a:	7e 22                	jle    800b3e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b1c:	ff 75 14             	push   0x14(%ebp)
  800b1f:	ff 75 10             	push   0x10(%ebp)
  800b22:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b25:	50                   	push   %eax
  800b26:	68 7d 06 80 00       	push   $0x80067d
  800b2b:	e8 87 fb ff ff       	call   8006b7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b30:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b33:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b39:	83 c4 10             	add    $0x10,%esp
}
  800b3c:	c9                   	leave  
  800b3d:	c3                   	ret    
		return -E_INVAL;
  800b3e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b43:	eb f7                	jmp    800b3c <vsnprintf+0x45>

00800b45 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b4b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b4e:	50                   	push   %eax
  800b4f:	ff 75 10             	push   0x10(%ebp)
  800b52:	ff 75 0c             	push   0xc(%ebp)
  800b55:	ff 75 08             	push   0x8(%ebp)
  800b58:	e8 9a ff ff ff       	call   800af7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b5d:	c9                   	leave  
  800b5e:	c3                   	ret    

00800b5f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b65:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6a:	eb 03                	jmp    800b6f <strlen+0x10>
		n++;
  800b6c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800b6f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b73:	75 f7                	jne    800b6c <strlen+0xd>
	return n;
}
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b80:	b8 00 00 00 00       	mov    $0x0,%eax
  800b85:	eb 03                	jmp    800b8a <strnlen+0x13>
		n++;
  800b87:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b8a:	39 d0                	cmp    %edx,%eax
  800b8c:	74 08                	je     800b96 <strnlen+0x1f>
  800b8e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b92:	75 f3                	jne    800b87 <strnlen+0x10>
  800b94:	89 c2                	mov    %eax,%edx
	return n;
}
  800b96:	89 d0                	mov    %edx,%eax
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	53                   	push   %ebx
  800b9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ba4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba9:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800bad:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800bb0:	83 c0 01             	add    $0x1,%eax
  800bb3:	84 d2                	test   %dl,%dl
  800bb5:	75 f2                	jne    800ba9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bb7:	89 c8                	mov    %ecx,%eax
  800bb9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bbc:	c9                   	leave  
  800bbd:	c3                   	ret    

00800bbe <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	53                   	push   %ebx
  800bc2:	83 ec 10             	sub    $0x10,%esp
  800bc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bc8:	53                   	push   %ebx
  800bc9:	e8 91 ff ff ff       	call   800b5f <strlen>
  800bce:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800bd1:	ff 75 0c             	push   0xc(%ebp)
  800bd4:	01 d8                	add    %ebx,%eax
  800bd6:	50                   	push   %eax
  800bd7:	e8 be ff ff ff       	call   800b9a <strcpy>
	return dst;
}
  800bdc:	89 d8                	mov    %ebx,%eax
  800bde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be1:	c9                   	leave  
  800be2:	c3                   	ret    

00800be3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	8b 75 08             	mov    0x8(%ebp),%esi
  800beb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bee:	89 f3                	mov    %esi,%ebx
  800bf0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bf3:	89 f0                	mov    %esi,%eax
  800bf5:	eb 0f                	jmp    800c06 <strncpy+0x23>
		*dst++ = *src;
  800bf7:	83 c0 01             	add    $0x1,%eax
  800bfa:	0f b6 0a             	movzbl (%edx),%ecx
  800bfd:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c00:	80 f9 01             	cmp    $0x1,%cl
  800c03:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800c06:	39 d8                	cmp    %ebx,%eax
  800c08:	75 ed                	jne    800bf7 <strncpy+0x14>
	}
	return ret;
}
  800c0a:	89 f0                	mov    %esi,%eax
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
  800c15:	8b 75 08             	mov    0x8(%ebp),%esi
  800c18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1b:	8b 55 10             	mov    0x10(%ebp),%edx
  800c1e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c20:	85 d2                	test   %edx,%edx
  800c22:	74 21                	je     800c45 <strlcpy+0x35>
  800c24:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c28:	89 f2                	mov    %esi,%edx
  800c2a:	eb 09                	jmp    800c35 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c2c:	83 c1 01             	add    $0x1,%ecx
  800c2f:	83 c2 01             	add    $0x1,%edx
  800c32:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800c35:	39 c2                	cmp    %eax,%edx
  800c37:	74 09                	je     800c42 <strlcpy+0x32>
  800c39:	0f b6 19             	movzbl (%ecx),%ebx
  800c3c:	84 db                	test   %bl,%bl
  800c3e:	75 ec                	jne    800c2c <strlcpy+0x1c>
  800c40:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800c42:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c45:	29 f0                	sub    %esi,%eax
}
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c51:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c54:	eb 06                	jmp    800c5c <strcmp+0x11>
		p++, q++;
  800c56:	83 c1 01             	add    $0x1,%ecx
  800c59:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800c5c:	0f b6 01             	movzbl (%ecx),%eax
  800c5f:	84 c0                	test   %al,%al
  800c61:	74 04                	je     800c67 <strcmp+0x1c>
  800c63:	3a 02                	cmp    (%edx),%al
  800c65:	74 ef                	je     800c56 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c67:	0f b6 c0             	movzbl %al,%eax
  800c6a:	0f b6 12             	movzbl (%edx),%edx
  800c6d:	29 d0                	sub    %edx,%eax
}
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	53                   	push   %ebx
  800c75:	8b 45 08             	mov    0x8(%ebp),%eax
  800c78:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c7b:	89 c3                	mov    %eax,%ebx
  800c7d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c80:	eb 06                	jmp    800c88 <strncmp+0x17>
		n--, p++, q++;
  800c82:	83 c0 01             	add    $0x1,%eax
  800c85:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c88:	39 d8                	cmp    %ebx,%eax
  800c8a:	74 18                	je     800ca4 <strncmp+0x33>
  800c8c:	0f b6 08             	movzbl (%eax),%ecx
  800c8f:	84 c9                	test   %cl,%cl
  800c91:	74 04                	je     800c97 <strncmp+0x26>
  800c93:	3a 0a                	cmp    (%edx),%cl
  800c95:	74 eb                	je     800c82 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c97:	0f b6 00             	movzbl (%eax),%eax
  800c9a:	0f b6 12             	movzbl (%edx),%edx
  800c9d:	29 d0                	sub    %edx,%eax
}
  800c9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ca2:	c9                   	leave  
  800ca3:	c3                   	ret    
		return 0;
  800ca4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca9:	eb f4                	jmp    800c9f <strncmp+0x2e>

00800cab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cb5:	eb 03                	jmp    800cba <strchr+0xf>
  800cb7:	83 c0 01             	add    $0x1,%eax
  800cba:	0f b6 10             	movzbl (%eax),%edx
  800cbd:	84 d2                	test   %dl,%dl
  800cbf:	74 06                	je     800cc7 <strchr+0x1c>
		if (*s == c)
  800cc1:	38 ca                	cmp    %cl,%dl
  800cc3:	75 f2                	jne    800cb7 <strchr+0xc>
  800cc5:	eb 05                	jmp    800ccc <strchr+0x21>
			return (char *) s;
	return 0;
  800cc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cd8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800cdb:	38 ca                	cmp    %cl,%dl
  800cdd:	74 09                	je     800ce8 <strfind+0x1a>
  800cdf:	84 d2                	test   %dl,%dl
  800ce1:	74 05                	je     800ce8 <strfind+0x1a>
	for (; *s; s++)
  800ce3:	83 c0 01             	add    $0x1,%eax
  800ce6:	eb f0                	jmp    800cd8 <strfind+0xa>
			break;
	return (char *) s;
}
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cf3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cf6:	85 c9                	test   %ecx,%ecx
  800cf8:	74 2f                	je     800d29 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cfa:	89 f8                	mov    %edi,%eax
  800cfc:	09 c8                	or     %ecx,%eax
  800cfe:	a8 03                	test   $0x3,%al
  800d00:	75 21                	jne    800d23 <memset+0x39>
		c &= 0xFF;
  800d02:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d06:	89 d0                	mov    %edx,%eax
  800d08:	c1 e0 08             	shl    $0x8,%eax
  800d0b:	89 d3                	mov    %edx,%ebx
  800d0d:	c1 e3 18             	shl    $0x18,%ebx
  800d10:	89 d6                	mov    %edx,%esi
  800d12:	c1 e6 10             	shl    $0x10,%esi
  800d15:	09 f3                	or     %esi,%ebx
  800d17:	09 da                	or     %ebx,%edx
  800d19:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d1b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800d1e:	fc                   	cld    
  800d1f:	f3 ab                	rep stos %eax,%es:(%edi)
  800d21:	eb 06                	jmp    800d29 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d26:	fc                   	cld    
  800d27:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d29:	89 f8                	mov    %edi,%eax
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	8b 45 08             	mov    0x8(%ebp),%eax
  800d38:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d3b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d3e:	39 c6                	cmp    %eax,%esi
  800d40:	73 32                	jae    800d74 <memmove+0x44>
  800d42:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d45:	39 c2                	cmp    %eax,%edx
  800d47:	76 2b                	jbe    800d74 <memmove+0x44>
		s += n;
		d += n;
  800d49:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d4c:	89 d6                	mov    %edx,%esi
  800d4e:	09 fe                	or     %edi,%esi
  800d50:	09 ce                	or     %ecx,%esi
  800d52:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d58:	75 0e                	jne    800d68 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d5a:	83 ef 04             	sub    $0x4,%edi
  800d5d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d60:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d63:	fd                   	std    
  800d64:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d66:	eb 09                	jmp    800d71 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d68:	83 ef 01             	sub    $0x1,%edi
  800d6b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d6e:	fd                   	std    
  800d6f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d71:	fc                   	cld    
  800d72:	eb 1a                	jmp    800d8e <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d74:	89 f2                	mov    %esi,%edx
  800d76:	09 c2                	or     %eax,%edx
  800d78:	09 ca                	or     %ecx,%edx
  800d7a:	f6 c2 03             	test   $0x3,%dl
  800d7d:	75 0a                	jne    800d89 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d7f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d82:	89 c7                	mov    %eax,%edi
  800d84:	fc                   	cld    
  800d85:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d87:	eb 05                	jmp    800d8e <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800d89:	89 c7                	mov    %eax,%edi
  800d8b:	fc                   	cld    
  800d8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d98:	ff 75 10             	push   0x10(%ebp)
  800d9b:	ff 75 0c             	push   0xc(%ebp)
  800d9e:	ff 75 08             	push   0x8(%ebp)
  800da1:	e8 8a ff ff ff       	call   800d30 <memmove>
}
  800da6:	c9                   	leave  
  800da7:	c3                   	ret    

00800da8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
  800dad:	8b 45 08             	mov    0x8(%ebp),%eax
  800db0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db3:	89 c6                	mov    %eax,%esi
  800db5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800db8:	eb 06                	jmp    800dc0 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800dba:	83 c0 01             	add    $0x1,%eax
  800dbd:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800dc0:	39 f0                	cmp    %esi,%eax
  800dc2:	74 14                	je     800dd8 <memcmp+0x30>
		if (*s1 != *s2)
  800dc4:	0f b6 08             	movzbl (%eax),%ecx
  800dc7:	0f b6 1a             	movzbl (%edx),%ebx
  800dca:	38 d9                	cmp    %bl,%cl
  800dcc:	74 ec                	je     800dba <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800dce:	0f b6 c1             	movzbl %cl,%eax
  800dd1:	0f b6 db             	movzbl %bl,%ebx
  800dd4:	29 d8                	sub    %ebx,%eax
  800dd6:	eb 05                	jmp    800ddd <memcmp+0x35>
	}

	return 0;
  800dd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	8b 45 08             	mov    0x8(%ebp),%eax
  800de7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800dea:	89 c2                	mov    %eax,%edx
  800dec:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800def:	eb 03                	jmp    800df4 <memfind+0x13>
  800df1:	83 c0 01             	add    $0x1,%eax
  800df4:	39 d0                	cmp    %edx,%eax
  800df6:	73 04                	jae    800dfc <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800df8:	38 08                	cmp    %cl,(%eax)
  800dfa:	75 f5                	jne    800df1 <memfind+0x10>
			break;
	return (void *) s;
}
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    

00800dfe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	57                   	push   %edi
  800e02:	56                   	push   %esi
  800e03:	53                   	push   %ebx
  800e04:	8b 55 08             	mov    0x8(%ebp),%edx
  800e07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e0a:	eb 03                	jmp    800e0f <strtol+0x11>
		s++;
  800e0c:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800e0f:	0f b6 02             	movzbl (%edx),%eax
  800e12:	3c 20                	cmp    $0x20,%al
  800e14:	74 f6                	je     800e0c <strtol+0xe>
  800e16:	3c 09                	cmp    $0x9,%al
  800e18:	74 f2                	je     800e0c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800e1a:	3c 2b                	cmp    $0x2b,%al
  800e1c:	74 2a                	je     800e48 <strtol+0x4a>
	int neg = 0;
  800e1e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800e23:	3c 2d                	cmp    $0x2d,%al
  800e25:	74 2b                	je     800e52 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e27:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e2d:	75 0f                	jne    800e3e <strtol+0x40>
  800e2f:	80 3a 30             	cmpb   $0x30,(%edx)
  800e32:	74 28                	je     800e5c <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e34:	85 db                	test   %ebx,%ebx
  800e36:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e3b:	0f 44 d8             	cmove  %eax,%ebx
  800e3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e43:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e46:	eb 46                	jmp    800e8e <strtol+0x90>
		s++;
  800e48:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800e4b:	bf 00 00 00 00       	mov    $0x0,%edi
  800e50:	eb d5                	jmp    800e27 <strtol+0x29>
		s++, neg = 1;
  800e52:	83 c2 01             	add    $0x1,%edx
  800e55:	bf 01 00 00 00       	mov    $0x1,%edi
  800e5a:	eb cb                	jmp    800e27 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e5c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e60:	74 0e                	je     800e70 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800e62:	85 db                	test   %ebx,%ebx
  800e64:	75 d8                	jne    800e3e <strtol+0x40>
		s++, base = 8;
  800e66:	83 c2 01             	add    $0x1,%edx
  800e69:	bb 08 00 00 00       	mov    $0x8,%ebx
  800e6e:	eb ce                	jmp    800e3e <strtol+0x40>
		s += 2, base = 16;
  800e70:	83 c2 02             	add    $0x2,%edx
  800e73:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e78:	eb c4                	jmp    800e3e <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800e7a:	0f be c0             	movsbl %al,%eax
  800e7d:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e80:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e83:	7d 3a                	jge    800ebf <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800e85:	83 c2 01             	add    $0x1,%edx
  800e88:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800e8c:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800e8e:	0f b6 02             	movzbl (%edx),%eax
  800e91:	8d 70 d0             	lea    -0x30(%eax),%esi
  800e94:	89 f3                	mov    %esi,%ebx
  800e96:	80 fb 09             	cmp    $0x9,%bl
  800e99:	76 df                	jbe    800e7a <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800e9b:	8d 70 9f             	lea    -0x61(%eax),%esi
  800e9e:	89 f3                	mov    %esi,%ebx
  800ea0:	80 fb 19             	cmp    $0x19,%bl
  800ea3:	77 08                	ja     800ead <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ea5:	0f be c0             	movsbl %al,%eax
  800ea8:	83 e8 57             	sub    $0x57,%eax
  800eab:	eb d3                	jmp    800e80 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ead:	8d 70 bf             	lea    -0x41(%eax),%esi
  800eb0:	89 f3                	mov    %esi,%ebx
  800eb2:	80 fb 19             	cmp    $0x19,%bl
  800eb5:	77 08                	ja     800ebf <strtol+0xc1>
			dig = *s - 'A' + 10;
  800eb7:	0f be c0             	movsbl %al,%eax
  800eba:	83 e8 37             	sub    $0x37,%eax
  800ebd:	eb c1                	jmp    800e80 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ebf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ec3:	74 05                	je     800eca <strtol+0xcc>
		*endptr = (char *) s;
  800ec5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec8:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800eca:	89 c8                	mov    %ecx,%eax
  800ecc:	f7 d8                	neg    %eax
  800ece:	85 ff                	test   %edi,%edi
  800ed0:	0f 45 c8             	cmovne %eax,%ecx
}
  800ed3:	89 c8                	mov    %ecx,%eax
  800ed5:	5b                   	pop    %ebx
  800ed6:	5e                   	pop    %esi
  800ed7:	5f                   	pop    %edi
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	57                   	push   %edi
  800ede:	56                   	push   %esi
  800edf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ee0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eeb:	89 c3                	mov    %eax,%ebx
  800eed:	89 c7                	mov    %eax,%edi
  800eef:	89 c6                	mov    %eax,%esi
  800ef1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ef3:	5b                   	pop    %ebx
  800ef4:	5e                   	pop    %esi
  800ef5:	5f                   	pop    %edi
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	57                   	push   %edi
  800efc:	56                   	push   %esi
  800efd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800efe:	ba 00 00 00 00       	mov    $0x0,%edx
  800f03:	b8 01 00 00 00       	mov    $0x1,%eax
  800f08:	89 d1                	mov    %edx,%ecx
  800f0a:	89 d3                	mov    %edx,%ebx
  800f0c:	89 d7                	mov    %edx,%edi
  800f0e:	89 d6                	mov    %edx,%esi
  800f10:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f12:	5b                   	pop    %ebx
  800f13:	5e                   	pop    %esi
  800f14:	5f                   	pop    %edi
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	57                   	push   %edi
  800f1b:	56                   	push   %esi
  800f1c:	53                   	push   %ebx
  800f1d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f25:	8b 55 08             	mov    0x8(%ebp),%edx
  800f28:	b8 03 00 00 00       	mov    $0x3,%eax
  800f2d:	89 cb                	mov    %ecx,%ebx
  800f2f:	89 cf                	mov    %ecx,%edi
  800f31:	89 ce                	mov    %ecx,%esi
  800f33:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f35:	85 c0                	test   %eax,%eax
  800f37:	7f 08                	jg     800f41 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f3c:	5b                   	pop    %ebx
  800f3d:	5e                   	pop    %esi
  800f3e:	5f                   	pop    %edi
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f41:	83 ec 0c             	sub    $0xc,%esp
  800f44:	50                   	push   %eax
  800f45:	6a 03                	push   $0x3
  800f47:	68 ff 2d 80 00       	push   $0x802dff
  800f4c:	6a 2a                	push   $0x2a
  800f4e:	68 1c 2e 80 00       	push   $0x802e1c
  800f53:	e8 8d f5 ff ff       	call   8004e5 <_panic>

00800f58 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	57                   	push   %edi
  800f5c:	56                   	push   %esi
  800f5d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f63:	b8 02 00 00 00       	mov    $0x2,%eax
  800f68:	89 d1                	mov    %edx,%ecx
  800f6a:	89 d3                	mov    %edx,%ebx
  800f6c:	89 d7                	mov    %edx,%edi
  800f6e:	89 d6                	mov    %edx,%esi
  800f70:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f72:	5b                   	pop    %ebx
  800f73:	5e                   	pop    %esi
  800f74:	5f                   	pop    %edi
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    

00800f77 <sys_yield>:

void
sys_yield(void)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	57                   	push   %edi
  800f7b:	56                   	push   %esi
  800f7c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f82:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f87:	89 d1                	mov    %edx,%ecx
  800f89:	89 d3                	mov    %edx,%ebx
  800f8b:	89 d7                	mov    %edx,%edi
  800f8d:	89 d6                	mov    %edx,%esi
  800f8f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f91:	5b                   	pop    %ebx
  800f92:	5e                   	pop    %esi
  800f93:	5f                   	pop    %edi
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    

00800f96 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	57                   	push   %edi
  800f9a:	56                   	push   %esi
  800f9b:	53                   	push   %ebx
  800f9c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f9f:	be 00 00 00 00       	mov    $0x0,%esi
  800fa4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800faa:	b8 04 00 00 00       	mov    $0x4,%eax
  800faf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fb2:	89 f7                	mov    %esi,%edi
  800fb4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fb6:	85 c0                	test   %eax,%eax
  800fb8:	7f 08                	jg     800fc2 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fbd:	5b                   	pop    %ebx
  800fbe:	5e                   	pop    %esi
  800fbf:	5f                   	pop    %edi
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc2:	83 ec 0c             	sub    $0xc,%esp
  800fc5:	50                   	push   %eax
  800fc6:	6a 04                	push   $0x4
  800fc8:	68 ff 2d 80 00       	push   $0x802dff
  800fcd:	6a 2a                	push   $0x2a
  800fcf:	68 1c 2e 80 00       	push   $0x802e1c
  800fd4:	e8 0c f5 ff ff       	call   8004e5 <_panic>

00800fd9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	57                   	push   %edi
  800fdd:	56                   	push   %esi
  800fde:	53                   	push   %ebx
  800fdf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fe2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe8:	b8 05 00 00 00       	mov    $0x5,%eax
  800fed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ff0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ff3:	8b 75 18             	mov    0x18(%ebp),%esi
  800ff6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	7f 08                	jg     801004 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ffc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fff:	5b                   	pop    %ebx
  801000:	5e                   	pop    %esi
  801001:	5f                   	pop    %edi
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801004:	83 ec 0c             	sub    $0xc,%esp
  801007:	50                   	push   %eax
  801008:	6a 05                	push   $0x5
  80100a:	68 ff 2d 80 00       	push   $0x802dff
  80100f:	6a 2a                	push   $0x2a
  801011:	68 1c 2e 80 00       	push   $0x802e1c
  801016:	e8 ca f4 ff ff       	call   8004e5 <_panic>

0080101b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	57                   	push   %edi
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
  801021:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801024:	bb 00 00 00 00       	mov    $0x0,%ebx
  801029:	8b 55 08             	mov    0x8(%ebp),%edx
  80102c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80102f:	b8 06 00 00 00       	mov    $0x6,%eax
  801034:	89 df                	mov    %ebx,%edi
  801036:	89 de                	mov    %ebx,%esi
  801038:	cd 30                	int    $0x30
	if(check && ret > 0)
  80103a:	85 c0                	test   %eax,%eax
  80103c:	7f 08                	jg     801046 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80103e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801041:	5b                   	pop    %ebx
  801042:	5e                   	pop    %esi
  801043:	5f                   	pop    %edi
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801046:	83 ec 0c             	sub    $0xc,%esp
  801049:	50                   	push   %eax
  80104a:	6a 06                	push   $0x6
  80104c:	68 ff 2d 80 00       	push   $0x802dff
  801051:	6a 2a                	push   $0x2a
  801053:	68 1c 2e 80 00       	push   $0x802e1c
  801058:	e8 88 f4 ff ff       	call   8004e5 <_panic>

0080105d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	57                   	push   %edi
  801061:	56                   	push   %esi
  801062:	53                   	push   %ebx
  801063:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801066:	bb 00 00 00 00       	mov    $0x0,%ebx
  80106b:	8b 55 08             	mov    0x8(%ebp),%edx
  80106e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801071:	b8 08 00 00 00       	mov    $0x8,%eax
  801076:	89 df                	mov    %ebx,%edi
  801078:	89 de                	mov    %ebx,%esi
  80107a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80107c:	85 c0                	test   %eax,%eax
  80107e:	7f 08                	jg     801088 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801080:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801083:	5b                   	pop    %ebx
  801084:	5e                   	pop    %esi
  801085:	5f                   	pop    %edi
  801086:	5d                   	pop    %ebp
  801087:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801088:	83 ec 0c             	sub    $0xc,%esp
  80108b:	50                   	push   %eax
  80108c:	6a 08                	push   $0x8
  80108e:	68 ff 2d 80 00       	push   $0x802dff
  801093:	6a 2a                	push   $0x2a
  801095:	68 1c 2e 80 00       	push   $0x802e1c
  80109a:	e8 46 f4 ff ff       	call   8004e5 <_panic>

0080109f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	57                   	push   %edi
  8010a3:	56                   	push   %esi
  8010a4:	53                   	push   %ebx
  8010a5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b3:	b8 09 00 00 00       	mov    $0x9,%eax
  8010b8:	89 df                	mov    %ebx,%edi
  8010ba:	89 de                	mov    %ebx,%esi
  8010bc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	7f 08                	jg     8010ca <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c5:	5b                   	pop    %ebx
  8010c6:	5e                   	pop    %esi
  8010c7:	5f                   	pop    %edi
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ca:	83 ec 0c             	sub    $0xc,%esp
  8010cd:	50                   	push   %eax
  8010ce:	6a 09                	push   $0x9
  8010d0:	68 ff 2d 80 00       	push   $0x802dff
  8010d5:	6a 2a                	push   $0x2a
  8010d7:	68 1c 2e 80 00       	push   $0x802e1c
  8010dc:	e8 04 f4 ff ff       	call   8004e5 <_panic>

008010e1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	57                   	push   %edi
  8010e5:	56                   	push   %esi
  8010e6:	53                   	push   %ebx
  8010e7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010fa:	89 df                	mov    %ebx,%edi
  8010fc:	89 de                	mov    %ebx,%esi
  8010fe:	cd 30                	int    $0x30
	if(check && ret > 0)
  801100:	85 c0                	test   %eax,%eax
  801102:	7f 08                	jg     80110c <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801104:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801107:	5b                   	pop    %ebx
  801108:	5e                   	pop    %esi
  801109:	5f                   	pop    %edi
  80110a:	5d                   	pop    %ebp
  80110b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80110c:	83 ec 0c             	sub    $0xc,%esp
  80110f:	50                   	push   %eax
  801110:	6a 0a                	push   $0xa
  801112:	68 ff 2d 80 00       	push   $0x802dff
  801117:	6a 2a                	push   $0x2a
  801119:	68 1c 2e 80 00       	push   $0x802e1c
  80111e:	e8 c2 f3 ff ff       	call   8004e5 <_panic>

00801123 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	57                   	push   %edi
  801127:	56                   	push   %esi
  801128:	53                   	push   %ebx
	asm volatile("int %1\n"
  801129:	8b 55 08             	mov    0x8(%ebp),%edx
  80112c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112f:	b8 0c 00 00 00       	mov    $0xc,%eax
  801134:	be 00 00 00 00       	mov    $0x0,%esi
  801139:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80113c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80113f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801141:	5b                   	pop    %ebx
  801142:	5e                   	pop    %esi
  801143:	5f                   	pop    %edi
  801144:	5d                   	pop    %ebp
  801145:	c3                   	ret    

00801146 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	57                   	push   %edi
  80114a:	56                   	push   %esi
  80114b:	53                   	push   %ebx
  80114c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80114f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801154:	8b 55 08             	mov    0x8(%ebp),%edx
  801157:	b8 0d 00 00 00       	mov    $0xd,%eax
  80115c:	89 cb                	mov    %ecx,%ebx
  80115e:	89 cf                	mov    %ecx,%edi
  801160:	89 ce                	mov    %ecx,%esi
  801162:	cd 30                	int    $0x30
	if(check && ret > 0)
  801164:	85 c0                	test   %eax,%eax
  801166:	7f 08                	jg     801170 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801168:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116b:	5b                   	pop    %ebx
  80116c:	5e                   	pop    %esi
  80116d:	5f                   	pop    %edi
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801170:	83 ec 0c             	sub    $0xc,%esp
  801173:	50                   	push   %eax
  801174:	6a 0d                	push   $0xd
  801176:	68 ff 2d 80 00       	push   $0x802dff
  80117b:	6a 2a                	push   $0x2a
  80117d:	68 1c 2e 80 00       	push   $0x802e1c
  801182:	e8 5e f3 ff ff       	call   8004e5 <_panic>

00801187 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	56                   	push   %esi
  80118b:	53                   	push   %ebx
  80118c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80118f:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  801191:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801195:	0f 84 8e 00 00 00    	je     801229 <pgfault+0xa2>
  80119b:	89 f0                	mov    %esi,%eax
  80119d:	c1 e8 0c             	shr    $0xc,%eax
  8011a0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011a7:	f6 c4 08             	test   $0x8,%ah
  8011aa:	74 7d                	je     801229 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  8011ac:	e8 a7 fd ff ff       	call   800f58 <sys_getenvid>
  8011b1:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  8011b3:	83 ec 04             	sub    $0x4,%esp
  8011b6:	6a 07                	push   $0x7
  8011b8:	68 00 f0 7f 00       	push   $0x7ff000
  8011bd:	50                   	push   %eax
  8011be:	e8 d3 fd ff ff       	call   800f96 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	78 73                	js     80123d <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  8011ca:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  8011d0:	83 ec 04             	sub    $0x4,%esp
  8011d3:	68 00 10 00 00       	push   $0x1000
  8011d8:	56                   	push   %esi
  8011d9:	68 00 f0 7f 00       	push   $0x7ff000
  8011de:	e8 4d fb ff ff       	call   800d30 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  8011e3:	83 c4 08             	add    $0x8,%esp
  8011e6:	56                   	push   %esi
  8011e7:	53                   	push   %ebx
  8011e8:	e8 2e fe ff ff       	call   80101b <sys_page_unmap>
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	85 c0                	test   %eax,%eax
  8011f2:	78 5b                	js     80124f <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  8011f4:	83 ec 0c             	sub    $0xc,%esp
  8011f7:	6a 07                	push   $0x7
  8011f9:	56                   	push   %esi
  8011fa:	53                   	push   %ebx
  8011fb:	68 00 f0 7f 00       	push   $0x7ff000
  801200:	53                   	push   %ebx
  801201:	e8 d3 fd ff ff       	call   800fd9 <sys_page_map>
  801206:	83 c4 20             	add    $0x20,%esp
  801209:	85 c0                	test   %eax,%eax
  80120b:	78 54                	js     801261 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  80120d:	83 ec 08             	sub    $0x8,%esp
  801210:	68 00 f0 7f 00       	push   $0x7ff000
  801215:	53                   	push   %ebx
  801216:	e8 00 fe ff ff       	call   80101b <sys_page_unmap>
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	85 c0                	test   %eax,%eax
  801220:	78 51                	js     801273 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  801222:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801225:	5b                   	pop    %ebx
  801226:	5e                   	pop    %esi
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  801229:	83 ec 04             	sub    $0x4,%esp
  80122c:	68 2c 2e 80 00       	push   $0x802e2c
  801231:	6a 1d                	push   $0x1d
  801233:	68 a8 2e 80 00       	push   $0x802ea8
  801238:	e8 a8 f2 ff ff       	call   8004e5 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  80123d:	50                   	push   %eax
  80123e:	68 64 2e 80 00       	push   $0x802e64
  801243:	6a 29                	push   $0x29
  801245:	68 a8 2e 80 00       	push   $0x802ea8
  80124a:	e8 96 f2 ff ff       	call   8004e5 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  80124f:	50                   	push   %eax
  801250:	68 88 2e 80 00       	push   $0x802e88
  801255:	6a 2e                	push   $0x2e
  801257:	68 a8 2e 80 00       	push   $0x802ea8
  80125c:	e8 84 f2 ff ff       	call   8004e5 <_panic>
		panic("pgfault: page map failed (%e)", r);
  801261:	50                   	push   %eax
  801262:	68 b3 2e 80 00       	push   $0x802eb3
  801267:	6a 30                	push   $0x30
  801269:	68 a8 2e 80 00       	push   $0x802ea8
  80126e:	e8 72 f2 ff ff       	call   8004e5 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  801273:	50                   	push   %eax
  801274:	68 88 2e 80 00       	push   $0x802e88
  801279:	6a 32                	push   $0x32
  80127b:	68 a8 2e 80 00       	push   $0x802ea8
  801280:	e8 60 f2 ff ff       	call   8004e5 <_panic>

00801285 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801285:	55                   	push   %ebp
  801286:	89 e5                	mov    %esp,%ebp
  801288:	57                   	push   %edi
  801289:	56                   	push   %esi
  80128a:	53                   	push   %ebx
  80128b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  80128e:	68 87 11 80 00       	push   $0x801187
  801293:	e8 fb 12 00 00       	call   802593 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801298:	b8 07 00 00 00       	mov    $0x7,%eax
  80129d:	cd 30                	int    $0x30
  80129f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  8012a2:	83 c4 10             	add    $0x10,%esp
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	78 2d                	js     8012d6 <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  8012a9:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  8012ae:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8012b2:	75 73                	jne    801327 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  8012b4:	e8 9f fc ff ff       	call   800f58 <sys_getenvid>
  8012b9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012be:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012c1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012c6:	a3 00 50 80 00       	mov    %eax,0x805000
		return 0;
  8012cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  8012ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d1:	5b                   	pop    %ebx
  8012d2:	5e                   	pop    %esi
  8012d3:	5f                   	pop    %edi
  8012d4:	5d                   	pop    %ebp
  8012d5:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  8012d6:	50                   	push   %eax
  8012d7:	68 d1 2e 80 00       	push   $0x802ed1
  8012dc:	6a 78                	push   $0x78
  8012de:	68 a8 2e 80 00       	push   $0x802ea8
  8012e3:	e8 fd f1 ff ff       	call   8004e5 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  8012e8:	83 ec 0c             	sub    $0xc,%esp
  8012eb:	ff 75 e4             	push   -0x1c(%ebp)
  8012ee:	57                   	push   %edi
  8012ef:	ff 75 dc             	push   -0x24(%ebp)
  8012f2:	57                   	push   %edi
  8012f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8012f6:	56                   	push   %esi
  8012f7:	e8 dd fc ff ff       	call   800fd9 <sys_page_map>
	if(r<0) return r;
  8012fc:	83 c4 20             	add    $0x20,%esp
  8012ff:	85 c0                	test   %eax,%eax
  801301:	78 cb                	js     8012ce <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  801303:	83 ec 0c             	sub    $0xc,%esp
  801306:	ff 75 e4             	push   -0x1c(%ebp)
  801309:	57                   	push   %edi
  80130a:	56                   	push   %esi
  80130b:	57                   	push   %edi
  80130c:	56                   	push   %esi
  80130d:	e8 c7 fc ff ff       	call   800fd9 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  801312:	83 c4 20             	add    $0x20,%esp
  801315:	85 c0                	test   %eax,%eax
  801317:	78 76                	js     80138f <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801319:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80131f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801325:	74 75                	je     80139c <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  801327:	89 d8                	mov    %ebx,%eax
  801329:	c1 e8 16             	shr    $0x16,%eax
  80132c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801333:	a8 01                	test   $0x1,%al
  801335:	74 e2                	je     801319 <fork+0x94>
  801337:	89 de                	mov    %ebx,%esi
  801339:	c1 ee 0c             	shr    $0xc,%esi
  80133c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801343:	a8 01                	test   $0x1,%al
  801345:	74 d2                	je     801319 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  801347:	e8 0c fc ff ff       	call   800f58 <sys_getenvid>
  80134c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  80134f:	89 f7                	mov    %esi,%edi
  801351:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  801354:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80135b:	89 c1                	mov    %eax,%ecx
  80135d:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801363:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  801366:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  80136d:	f6 c6 04             	test   $0x4,%dh
  801370:	0f 85 72 ff ff ff    	jne    8012e8 <fork+0x63>
		perm &= ~PTE_W;
  801376:	25 05 0e 00 00       	and    $0xe05,%eax
  80137b:	80 cc 08             	or     $0x8,%ah
  80137e:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  801384:	0f 44 c1             	cmove  %ecx,%eax
  801387:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80138a:	e9 59 ff ff ff       	jmp    8012e8 <fork+0x63>
  80138f:	ba 00 00 00 00       	mov    $0x0,%edx
  801394:	0f 4f c2             	cmovg  %edx,%eax
  801397:	e9 32 ff ff ff       	jmp    8012ce <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  80139c:	83 ec 04             	sub    $0x4,%esp
  80139f:	6a 07                	push   $0x7
  8013a1:	68 00 f0 bf ee       	push   $0xeebff000
  8013a6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8013a9:	57                   	push   %edi
  8013aa:	e8 e7 fb ff ff       	call   800f96 <sys_page_alloc>
	if(r<0) return r;
  8013af:	83 c4 10             	add    $0x10,%esp
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	0f 88 14 ff ff ff    	js     8012ce <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8013ba:	83 ec 08             	sub    $0x8,%esp
  8013bd:	68 09 26 80 00       	push   $0x802609
  8013c2:	57                   	push   %edi
  8013c3:	e8 19 fd ff ff       	call   8010e1 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	0f 88 fb fe ff ff    	js     8012ce <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8013d3:	83 ec 08             	sub    $0x8,%esp
  8013d6:	6a 02                	push   $0x2
  8013d8:	57                   	push   %edi
  8013d9:	e8 7f fc ff ff       	call   80105d <sys_env_set_status>
	if(r<0) return r;
  8013de:	83 c4 10             	add    $0x10,%esp
	return envid;
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	0f 49 c7             	cmovns %edi,%eax
  8013e6:	e9 e3 fe ff ff       	jmp    8012ce <fork+0x49>

008013eb <sfork>:

// Challenge!
int
sfork(void)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8013f1:	68 e1 2e 80 00       	push   $0x802ee1
  8013f6:	68 a1 00 00 00       	push   $0xa1
  8013fb:	68 a8 2e 80 00       	push   $0x802ea8
  801400:	e8 e0 f0 ff ff       	call   8004e5 <_panic>

00801405 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801408:	8b 45 08             	mov    0x8(%ebp),%eax
  80140b:	05 00 00 00 30       	add    $0x30000000,%eax
  801410:	c1 e8 0c             	shr    $0xc,%eax
}
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    

00801415 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801418:	8b 45 08             	mov    0x8(%ebp),%eax
  80141b:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801420:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801425:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80142a:	5d                   	pop    %ebp
  80142b:	c3                   	ret    

0080142c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801434:	89 c2                	mov    %eax,%edx
  801436:	c1 ea 16             	shr    $0x16,%edx
  801439:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801440:	f6 c2 01             	test   $0x1,%dl
  801443:	74 29                	je     80146e <fd_alloc+0x42>
  801445:	89 c2                	mov    %eax,%edx
  801447:	c1 ea 0c             	shr    $0xc,%edx
  80144a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801451:	f6 c2 01             	test   $0x1,%dl
  801454:	74 18                	je     80146e <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801456:	05 00 10 00 00       	add    $0x1000,%eax
  80145b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801460:	75 d2                	jne    801434 <fd_alloc+0x8>
  801462:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801467:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80146c:	eb 05                	jmp    801473 <fd_alloc+0x47>
			return 0;
  80146e:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801473:	8b 55 08             	mov    0x8(%ebp),%edx
  801476:	89 02                	mov    %eax,(%edx)
}
  801478:	89 c8                	mov    %ecx,%eax
  80147a:	5d                   	pop    %ebp
  80147b:	c3                   	ret    

0080147c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801482:	83 f8 1f             	cmp    $0x1f,%eax
  801485:	77 30                	ja     8014b7 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801487:	c1 e0 0c             	shl    $0xc,%eax
  80148a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80148f:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801495:	f6 c2 01             	test   $0x1,%dl
  801498:	74 24                	je     8014be <fd_lookup+0x42>
  80149a:	89 c2                	mov    %eax,%edx
  80149c:	c1 ea 0c             	shr    $0xc,%edx
  80149f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014a6:	f6 c2 01             	test   $0x1,%dl
  8014a9:	74 1a                	je     8014c5 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ae:	89 02                	mov    %eax,(%edx)
	return 0;
  8014b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b5:	5d                   	pop    %ebp
  8014b6:	c3                   	ret    
		return -E_INVAL;
  8014b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014bc:	eb f7                	jmp    8014b5 <fd_lookup+0x39>
		return -E_INVAL;
  8014be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c3:	eb f0                	jmp    8014b5 <fd_lookup+0x39>
  8014c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ca:	eb e9                	jmp    8014b5 <fd_lookup+0x39>

008014cc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	53                   	push   %ebx
  8014d0:	83 ec 04             	sub    $0x4,%esp
  8014d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8014d6:	b8 74 2f 80 00       	mov    $0x802f74,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  8014db:	bb 20 40 80 00       	mov    $0x804020,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8014e0:	39 13                	cmp    %edx,(%ebx)
  8014e2:	74 32                	je     801516 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  8014e4:	83 c0 04             	add    $0x4,%eax
  8014e7:	8b 18                	mov    (%eax),%ebx
  8014e9:	85 db                	test   %ebx,%ebx
  8014eb:	75 f3                	jne    8014e0 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014ed:	a1 00 50 80 00       	mov    0x805000,%eax
  8014f2:	8b 40 48             	mov    0x48(%eax),%eax
  8014f5:	83 ec 04             	sub    $0x4,%esp
  8014f8:	52                   	push   %edx
  8014f9:	50                   	push   %eax
  8014fa:	68 f8 2e 80 00       	push   $0x802ef8
  8014ff:	e8 bc f0 ff ff       	call   8005c0 <cprintf>
	*dev = 0;
	return -E_INVAL;
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  80150c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80150f:	89 1a                	mov    %ebx,(%edx)
}
  801511:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801514:	c9                   	leave  
  801515:	c3                   	ret    
			return 0;
  801516:	b8 00 00 00 00       	mov    $0x0,%eax
  80151b:	eb ef                	jmp    80150c <dev_lookup+0x40>

0080151d <fd_close>:
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	57                   	push   %edi
  801521:	56                   	push   %esi
  801522:	53                   	push   %ebx
  801523:	83 ec 24             	sub    $0x24,%esp
  801526:	8b 75 08             	mov    0x8(%ebp),%esi
  801529:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80152c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80152f:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801530:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801536:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801539:	50                   	push   %eax
  80153a:	e8 3d ff ff ff       	call   80147c <fd_lookup>
  80153f:	89 c3                	mov    %eax,%ebx
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	85 c0                	test   %eax,%eax
  801546:	78 05                	js     80154d <fd_close+0x30>
	    || fd != fd2)
  801548:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80154b:	74 16                	je     801563 <fd_close+0x46>
		return (must_exist ? r : 0);
  80154d:	89 f8                	mov    %edi,%eax
  80154f:	84 c0                	test   %al,%al
  801551:	b8 00 00 00 00       	mov    $0x0,%eax
  801556:	0f 44 d8             	cmove  %eax,%ebx
}
  801559:	89 d8                	mov    %ebx,%eax
  80155b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80155e:	5b                   	pop    %ebx
  80155f:	5e                   	pop    %esi
  801560:	5f                   	pop    %edi
  801561:	5d                   	pop    %ebp
  801562:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801563:	83 ec 08             	sub    $0x8,%esp
  801566:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801569:	50                   	push   %eax
  80156a:	ff 36                	push   (%esi)
  80156c:	e8 5b ff ff ff       	call   8014cc <dev_lookup>
  801571:	89 c3                	mov    %eax,%ebx
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	85 c0                	test   %eax,%eax
  801578:	78 1a                	js     801594 <fd_close+0x77>
		if (dev->dev_close)
  80157a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80157d:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801580:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801585:	85 c0                	test   %eax,%eax
  801587:	74 0b                	je     801594 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801589:	83 ec 0c             	sub    $0xc,%esp
  80158c:	56                   	push   %esi
  80158d:	ff d0                	call   *%eax
  80158f:	89 c3                	mov    %eax,%ebx
  801591:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801594:	83 ec 08             	sub    $0x8,%esp
  801597:	56                   	push   %esi
  801598:	6a 00                	push   $0x0
  80159a:	e8 7c fa ff ff       	call   80101b <sys_page_unmap>
	return r;
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	eb b5                	jmp    801559 <fd_close+0x3c>

008015a4 <close>:

int
close(int fdnum)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	ff 75 08             	push   0x8(%ebp)
  8015b1:	e8 c6 fe ff ff       	call   80147c <fd_lookup>
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	79 02                	jns    8015bf <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8015bd:	c9                   	leave  
  8015be:	c3                   	ret    
		return fd_close(fd, 1);
  8015bf:	83 ec 08             	sub    $0x8,%esp
  8015c2:	6a 01                	push   $0x1
  8015c4:	ff 75 f4             	push   -0xc(%ebp)
  8015c7:	e8 51 ff ff ff       	call   80151d <fd_close>
  8015cc:	83 c4 10             	add    $0x10,%esp
  8015cf:	eb ec                	jmp    8015bd <close+0x19>

008015d1 <close_all>:

void
close_all(void)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	53                   	push   %ebx
  8015d5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015d8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015dd:	83 ec 0c             	sub    $0xc,%esp
  8015e0:	53                   	push   %ebx
  8015e1:	e8 be ff ff ff       	call   8015a4 <close>
	for (i = 0; i < MAXFD; i++)
  8015e6:	83 c3 01             	add    $0x1,%ebx
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	83 fb 20             	cmp    $0x20,%ebx
  8015ef:	75 ec                	jne    8015dd <close_all+0xc>
}
  8015f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f4:	c9                   	leave  
  8015f5:	c3                   	ret    

008015f6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015f6:	55                   	push   %ebp
  8015f7:	89 e5                	mov    %esp,%ebp
  8015f9:	57                   	push   %edi
  8015fa:	56                   	push   %esi
  8015fb:	53                   	push   %ebx
  8015fc:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015ff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801602:	50                   	push   %eax
  801603:	ff 75 08             	push   0x8(%ebp)
  801606:	e8 71 fe ff ff       	call   80147c <fd_lookup>
  80160b:	89 c3                	mov    %eax,%ebx
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	85 c0                	test   %eax,%eax
  801612:	78 7f                	js     801693 <dup+0x9d>
		return r;
	close(newfdnum);
  801614:	83 ec 0c             	sub    $0xc,%esp
  801617:	ff 75 0c             	push   0xc(%ebp)
  80161a:	e8 85 ff ff ff       	call   8015a4 <close>

	newfd = INDEX2FD(newfdnum);
  80161f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801622:	c1 e6 0c             	shl    $0xc,%esi
  801625:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80162b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80162e:	89 3c 24             	mov    %edi,(%esp)
  801631:	e8 df fd ff ff       	call   801415 <fd2data>
  801636:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801638:	89 34 24             	mov    %esi,(%esp)
  80163b:	e8 d5 fd ff ff       	call   801415 <fd2data>
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801646:	89 d8                	mov    %ebx,%eax
  801648:	c1 e8 16             	shr    $0x16,%eax
  80164b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801652:	a8 01                	test   $0x1,%al
  801654:	74 11                	je     801667 <dup+0x71>
  801656:	89 d8                	mov    %ebx,%eax
  801658:	c1 e8 0c             	shr    $0xc,%eax
  80165b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801662:	f6 c2 01             	test   $0x1,%dl
  801665:	75 36                	jne    80169d <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801667:	89 f8                	mov    %edi,%eax
  801669:	c1 e8 0c             	shr    $0xc,%eax
  80166c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801673:	83 ec 0c             	sub    $0xc,%esp
  801676:	25 07 0e 00 00       	and    $0xe07,%eax
  80167b:	50                   	push   %eax
  80167c:	56                   	push   %esi
  80167d:	6a 00                	push   $0x0
  80167f:	57                   	push   %edi
  801680:	6a 00                	push   $0x0
  801682:	e8 52 f9 ff ff       	call   800fd9 <sys_page_map>
  801687:	89 c3                	mov    %eax,%ebx
  801689:	83 c4 20             	add    $0x20,%esp
  80168c:	85 c0                	test   %eax,%eax
  80168e:	78 33                	js     8016c3 <dup+0xcd>
		goto err;

	return newfdnum;
  801690:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801693:	89 d8                	mov    %ebx,%eax
  801695:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801698:	5b                   	pop    %ebx
  801699:	5e                   	pop    %esi
  80169a:	5f                   	pop    %edi
  80169b:	5d                   	pop    %ebp
  80169c:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80169d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016a4:	83 ec 0c             	sub    $0xc,%esp
  8016a7:	25 07 0e 00 00       	and    $0xe07,%eax
  8016ac:	50                   	push   %eax
  8016ad:	ff 75 d4             	push   -0x2c(%ebp)
  8016b0:	6a 00                	push   $0x0
  8016b2:	53                   	push   %ebx
  8016b3:	6a 00                	push   $0x0
  8016b5:	e8 1f f9 ff ff       	call   800fd9 <sys_page_map>
  8016ba:	89 c3                	mov    %eax,%ebx
  8016bc:	83 c4 20             	add    $0x20,%esp
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	79 a4                	jns    801667 <dup+0x71>
	sys_page_unmap(0, newfd);
  8016c3:	83 ec 08             	sub    $0x8,%esp
  8016c6:	56                   	push   %esi
  8016c7:	6a 00                	push   $0x0
  8016c9:	e8 4d f9 ff ff       	call   80101b <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016ce:	83 c4 08             	add    $0x8,%esp
  8016d1:	ff 75 d4             	push   -0x2c(%ebp)
  8016d4:	6a 00                	push   $0x0
  8016d6:	e8 40 f9 ff ff       	call   80101b <sys_page_unmap>
	return r;
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	eb b3                	jmp    801693 <dup+0x9d>

008016e0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	56                   	push   %esi
  8016e4:	53                   	push   %ebx
  8016e5:	83 ec 18             	sub    $0x18,%esp
  8016e8:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ee:	50                   	push   %eax
  8016ef:	56                   	push   %esi
  8016f0:	e8 87 fd ff ff       	call   80147c <fd_lookup>
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	85 c0                	test   %eax,%eax
  8016fa:	78 3c                	js     801738 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fc:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8016ff:	83 ec 08             	sub    $0x8,%esp
  801702:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801705:	50                   	push   %eax
  801706:	ff 33                	push   (%ebx)
  801708:	e8 bf fd ff ff       	call   8014cc <dev_lookup>
  80170d:	83 c4 10             	add    $0x10,%esp
  801710:	85 c0                	test   %eax,%eax
  801712:	78 24                	js     801738 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801714:	8b 43 08             	mov    0x8(%ebx),%eax
  801717:	83 e0 03             	and    $0x3,%eax
  80171a:	83 f8 01             	cmp    $0x1,%eax
  80171d:	74 20                	je     80173f <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80171f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801722:	8b 40 08             	mov    0x8(%eax),%eax
  801725:	85 c0                	test   %eax,%eax
  801727:	74 37                	je     801760 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801729:	83 ec 04             	sub    $0x4,%esp
  80172c:	ff 75 10             	push   0x10(%ebp)
  80172f:	ff 75 0c             	push   0xc(%ebp)
  801732:	53                   	push   %ebx
  801733:	ff d0                	call   *%eax
  801735:	83 c4 10             	add    $0x10,%esp
}
  801738:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80173b:	5b                   	pop    %ebx
  80173c:	5e                   	pop    %esi
  80173d:	5d                   	pop    %ebp
  80173e:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80173f:	a1 00 50 80 00       	mov    0x805000,%eax
  801744:	8b 40 48             	mov    0x48(%eax),%eax
  801747:	83 ec 04             	sub    $0x4,%esp
  80174a:	56                   	push   %esi
  80174b:	50                   	push   %eax
  80174c:	68 39 2f 80 00       	push   $0x802f39
  801751:	e8 6a ee ff ff       	call   8005c0 <cprintf>
		return -E_INVAL;
  801756:	83 c4 10             	add    $0x10,%esp
  801759:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80175e:	eb d8                	jmp    801738 <read+0x58>
		return -E_NOT_SUPP;
  801760:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801765:	eb d1                	jmp    801738 <read+0x58>

00801767 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	57                   	push   %edi
  80176b:	56                   	push   %esi
  80176c:	53                   	push   %ebx
  80176d:	83 ec 0c             	sub    $0xc,%esp
  801770:	8b 7d 08             	mov    0x8(%ebp),%edi
  801773:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801776:	bb 00 00 00 00       	mov    $0x0,%ebx
  80177b:	eb 02                	jmp    80177f <readn+0x18>
  80177d:	01 c3                	add    %eax,%ebx
  80177f:	39 f3                	cmp    %esi,%ebx
  801781:	73 21                	jae    8017a4 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801783:	83 ec 04             	sub    $0x4,%esp
  801786:	89 f0                	mov    %esi,%eax
  801788:	29 d8                	sub    %ebx,%eax
  80178a:	50                   	push   %eax
  80178b:	89 d8                	mov    %ebx,%eax
  80178d:	03 45 0c             	add    0xc(%ebp),%eax
  801790:	50                   	push   %eax
  801791:	57                   	push   %edi
  801792:	e8 49 ff ff ff       	call   8016e0 <read>
		if (m < 0)
  801797:	83 c4 10             	add    $0x10,%esp
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 04                	js     8017a2 <readn+0x3b>
			return m;
		if (m == 0)
  80179e:	75 dd                	jne    80177d <readn+0x16>
  8017a0:	eb 02                	jmp    8017a4 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017a2:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8017a4:	89 d8                	mov    %ebx,%eax
  8017a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017a9:	5b                   	pop    %ebx
  8017aa:	5e                   	pop    %esi
  8017ab:	5f                   	pop    %edi
  8017ac:	5d                   	pop    %ebp
  8017ad:	c3                   	ret    

008017ae <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	56                   	push   %esi
  8017b2:	53                   	push   %ebx
  8017b3:	83 ec 18             	sub    $0x18,%esp
  8017b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017bc:	50                   	push   %eax
  8017bd:	53                   	push   %ebx
  8017be:	e8 b9 fc ff ff       	call   80147c <fd_lookup>
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	78 37                	js     801801 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ca:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8017cd:	83 ec 08             	sub    $0x8,%esp
  8017d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d3:	50                   	push   %eax
  8017d4:	ff 36                	push   (%esi)
  8017d6:	e8 f1 fc ff ff       	call   8014cc <dev_lookup>
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 1f                	js     801801 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017e2:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8017e6:	74 20                	je     801808 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	74 37                	je     801829 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017f2:	83 ec 04             	sub    $0x4,%esp
  8017f5:	ff 75 10             	push   0x10(%ebp)
  8017f8:	ff 75 0c             	push   0xc(%ebp)
  8017fb:	56                   	push   %esi
  8017fc:	ff d0                	call   *%eax
  8017fe:	83 c4 10             	add    $0x10,%esp
}
  801801:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801804:	5b                   	pop    %ebx
  801805:	5e                   	pop    %esi
  801806:	5d                   	pop    %ebp
  801807:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801808:	a1 00 50 80 00       	mov    0x805000,%eax
  80180d:	8b 40 48             	mov    0x48(%eax),%eax
  801810:	83 ec 04             	sub    $0x4,%esp
  801813:	53                   	push   %ebx
  801814:	50                   	push   %eax
  801815:	68 55 2f 80 00       	push   $0x802f55
  80181a:	e8 a1 ed ff ff       	call   8005c0 <cprintf>
		return -E_INVAL;
  80181f:	83 c4 10             	add    $0x10,%esp
  801822:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801827:	eb d8                	jmp    801801 <write+0x53>
		return -E_NOT_SUPP;
  801829:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80182e:	eb d1                	jmp    801801 <write+0x53>

00801830 <seek>:

int
seek(int fdnum, off_t offset)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801836:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801839:	50                   	push   %eax
  80183a:	ff 75 08             	push   0x8(%ebp)
  80183d:	e8 3a fc ff ff       	call   80147c <fd_lookup>
  801842:	83 c4 10             	add    $0x10,%esp
  801845:	85 c0                	test   %eax,%eax
  801847:	78 0e                	js     801857 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801849:	8b 55 0c             	mov    0xc(%ebp),%edx
  80184c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80184f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801852:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801857:	c9                   	leave  
  801858:	c3                   	ret    

00801859 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	56                   	push   %esi
  80185d:	53                   	push   %ebx
  80185e:	83 ec 18             	sub    $0x18,%esp
  801861:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801864:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801867:	50                   	push   %eax
  801868:	53                   	push   %ebx
  801869:	e8 0e fc ff ff       	call   80147c <fd_lookup>
  80186e:	83 c4 10             	add    $0x10,%esp
  801871:	85 c0                	test   %eax,%eax
  801873:	78 34                	js     8018a9 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801875:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801878:	83 ec 08             	sub    $0x8,%esp
  80187b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187e:	50                   	push   %eax
  80187f:	ff 36                	push   (%esi)
  801881:	e8 46 fc ff ff       	call   8014cc <dev_lookup>
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	85 c0                	test   %eax,%eax
  80188b:	78 1c                	js     8018a9 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80188d:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801891:	74 1d                	je     8018b0 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801893:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801896:	8b 40 18             	mov    0x18(%eax),%eax
  801899:	85 c0                	test   %eax,%eax
  80189b:	74 34                	je     8018d1 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80189d:	83 ec 08             	sub    $0x8,%esp
  8018a0:	ff 75 0c             	push   0xc(%ebp)
  8018a3:	56                   	push   %esi
  8018a4:	ff d0                	call   *%eax
  8018a6:	83 c4 10             	add    $0x10,%esp
}
  8018a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ac:	5b                   	pop    %ebx
  8018ad:	5e                   	pop    %esi
  8018ae:	5d                   	pop    %ebp
  8018af:	c3                   	ret    
			thisenv->env_id, fdnum);
  8018b0:	a1 00 50 80 00       	mov    0x805000,%eax
  8018b5:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018b8:	83 ec 04             	sub    $0x4,%esp
  8018bb:	53                   	push   %ebx
  8018bc:	50                   	push   %eax
  8018bd:	68 18 2f 80 00       	push   $0x802f18
  8018c2:	e8 f9 ec ff ff       	call   8005c0 <cprintf>
		return -E_INVAL;
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018cf:	eb d8                	jmp    8018a9 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8018d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018d6:	eb d1                	jmp    8018a9 <ftruncate+0x50>

008018d8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	56                   	push   %esi
  8018dc:	53                   	push   %ebx
  8018dd:	83 ec 18             	sub    $0x18,%esp
  8018e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e6:	50                   	push   %eax
  8018e7:	ff 75 08             	push   0x8(%ebp)
  8018ea:	e8 8d fb ff ff       	call   80147c <fd_lookup>
  8018ef:	83 c4 10             	add    $0x10,%esp
  8018f2:	85 c0                	test   %eax,%eax
  8018f4:	78 49                	js     80193f <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8018f9:	83 ec 08             	sub    $0x8,%esp
  8018fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ff:	50                   	push   %eax
  801900:	ff 36                	push   (%esi)
  801902:	e8 c5 fb ff ff       	call   8014cc <dev_lookup>
  801907:	83 c4 10             	add    $0x10,%esp
  80190a:	85 c0                	test   %eax,%eax
  80190c:	78 31                	js     80193f <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80190e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801911:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801915:	74 2f                	je     801946 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801917:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80191a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801921:	00 00 00 
	stat->st_isdir = 0;
  801924:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80192b:	00 00 00 
	stat->st_dev = dev;
  80192e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801934:	83 ec 08             	sub    $0x8,%esp
  801937:	53                   	push   %ebx
  801938:	56                   	push   %esi
  801939:	ff 50 14             	call   *0x14(%eax)
  80193c:	83 c4 10             	add    $0x10,%esp
}
  80193f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801942:	5b                   	pop    %ebx
  801943:	5e                   	pop    %esi
  801944:	5d                   	pop    %ebp
  801945:	c3                   	ret    
		return -E_NOT_SUPP;
  801946:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80194b:	eb f2                	jmp    80193f <fstat+0x67>

0080194d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	56                   	push   %esi
  801951:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801952:	83 ec 08             	sub    $0x8,%esp
  801955:	6a 00                	push   $0x0
  801957:	ff 75 08             	push   0x8(%ebp)
  80195a:	e8 e4 01 00 00       	call   801b43 <open>
  80195f:	89 c3                	mov    %eax,%ebx
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	85 c0                	test   %eax,%eax
  801966:	78 1b                	js     801983 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801968:	83 ec 08             	sub    $0x8,%esp
  80196b:	ff 75 0c             	push   0xc(%ebp)
  80196e:	50                   	push   %eax
  80196f:	e8 64 ff ff ff       	call   8018d8 <fstat>
  801974:	89 c6                	mov    %eax,%esi
	close(fd);
  801976:	89 1c 24             	mov    %ebx,(%esp)
  801979:	e8 26 fc ff ff       	call   8015a4 <close>
	return r;
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	89 f3                	mov    %esi,%ebx
}
  801983:	89 d8                	mov    %ebx,%eax
  801985:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801988:	5b                   	pop    %ebx
  801989:	5e                   	pop    %esi
  80198a:	5d                   	pop    %ebp
  80198b:	c3                   	ret    

0080198c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	56                   	push   %esi
  801990:	53                   	push   %ebx
  801991:	89 c6                	mov    %eax,%esi
  801993:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801995:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80199c:	74 27                	je     8019c5 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80199e:	6a 07                	push   $0x7
  8019a0:	68 00 60 80 00       	push   $0x806000
  8019a5:	56                   	push   %esi
  8019a6:	ff 35 00 70 80 00    	push   0x807000
  8019ac:	e8 e5 0c 00 00       	call   802696 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019b1:	83 c4 0c             	add    $0xc,%esp
  8019b4:	6a 00                	push   $0x0
  8019b6:	53                   	push   %ebx
  8019b7:	6a 00                	push   $0x0
  8019b9:	e8 71 0c 00 00       	call   80262f <ipc_recv>
}
  8019be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c1:	5b                   	pop    %ebx
  8019c2:	5e                   	pop    %esi
  8019c3:	5d                   	pop    %ebp
  8019c4:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019c5:	83 ec 0c             	sub    $0xc,%esp
  8019c8:	6a 01                	push   $0x1
  8019ca:	e8 1b 0d 00 00       	call   8026ea <ipc_find_env>
  8019cf:	a3 00 70 80 00       	mov    %eax,0x807000
  8019d4:	83 c4 10             	add    $0x10,%esp
  8019d7:	eb c5                	jmp    80199e <fsipc+0x12>

008019d9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019df:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8019ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ed:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f7:	b8 02 00 00 00       	mov    $0x2,%eax
  8019fc:	e8 8b ff ff ff       	call   80198c <fsipc>
}
  801a01:	c9                   	leave  
  801a02:	c3                   	ret    

00801a03 <devfile_flush>:
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a09:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a14:	ba 00 00 00 00       	mov    $0x0,%edx
  801a19:	b8 06 00 00 00       	mov    $0x6,%eax
  801a1e:	e8 69 ff ff ff       	call   80198c <fsipc>
}
  801a23:	c9                   	leave  
  801a24:	c3                   	ret    

00801a25 <devfile_stat>:
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	53                   	push   %ebx
  801a29:	83 ec 04             	sub    $0x4,%esp
  801a2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a32:	8b 40 0c             	mov    0xc(%eax),%eax
  801a35:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3f:	b8 05 00 00 00       	mov    $0x5,%eax
  801a44:	e8 43 ff ff ff       	call   80198c <fsipc>
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	78 2c                	js     801a79 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a4d:	83 ec 08             	sub    $0x8,%esp
  801a50:	68 00 60 80 00       	push   $0x806000
  801a55:	53                   	push   %ebx
  801a56:	e8 3f f1 ff ff       	call   800b9a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a5b:	a1 80 60 80 00       	mov    0x806080,%eax
  801a60:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a66:	a1 84 60 80 00       	mov    0x806084,%eax
  801a6b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a71:	83 c4 10             	add    $0x10,%esp
  801a74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a7c:	c9                   	leave  
  801a7d:	c3                   	ret    

00801a7e <devfile_write>:
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	83 ec 0c             	sub    $0xc,%esp
  801a84:	8b 45 10             	mov    0x10(%ebp),%eax
  801a87:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a8c:	39 d0                	cmp    %edx,%eax
  801a8e:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a91:	8b 55 08             	mov    0x8(%ebp),%edx
  801a94:	8b 52 0c             	mov    0xc(%edx),%edx
  801a97:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801a9d:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801aa2:	50                   	push   %eax
  801aa3:	ff 75 0c             	push   0xc(%ebp)
  801aa6:	68 08 60 80 00       	push   $0x806008
  801aab:	e8 80 f2 ff ff       	call   800d30 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801ab0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab5:	b8 04 00 00 00       	mov    $0x4,%eax
  801aba:	e8 cd fe ff ff       	call   80198c <fsipc>
}
  801abf:	c9                   	leave  
  801ac0:	c3                   	ret    

00801ac1 <devfile_read>:
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	56                   	push   %esi
  801ac5:	53                   	push   %ebx
  801ac6:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  801acc:	8b 40 0c             	mov    0xc(%eax),%eax
  801acf:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801ad4:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ada:	ba 00 00 00 00       	mov    $0x0,%edx
  801adf:	b8 03 00 00 00       	mov    $0x3,%eax
  801ae4:	e8 a3 fe ff ff       	call   80198c <fsipc>
  801ae9:	89 c3                	mov    %eax,%ebx
  801aeb:	85 c0                	test   %eax,%eax
  801aed:	78 1f                	js     801b0e <devfile_read+0x4d>
	assert(r <= n);
  801aef:	39 f0                	cmp    %esi,%eax
  801af1:	77 24                	ja     801b17 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801af3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801af8:	7f 33                	jg     801b2d <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801afa:	83 ec 04             	sub    $0x4,%esp
  801afd:	50                   	push   %eax
  801afe:	68 00 60 80 00       	push   $0x806000
  801b03:	ff 75 0c             	push   0xc(%ebp)
  801b06:	e8 25 f2 ff ff       	call   800d30 <memmove>
	return r;
  801b0b:	83 c4 10             	add    $0x10,%esp
}
  801b0e:	89 d8                	mov    %ebx,%eax
  801b10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b13:	5b                   	pop    %ebx
  801b14:	5e                   	pop    %esi
  801b15:	5d                   	pop    %ebp
  801b16:	c3                   	ret    
	assert(r <= n);
  801b17:	68 84 2f 80 00       	push   $0x802f84
  801b1c:	68 8b 2f 80 00       	push   $0x802f8b
  801b21:	6a 7c                	push   $0x7c
  801b23:	68 a0 2f 80 00       	push   $0x802fa0
  801b28:	e8 b8 e9 ff ff       	call   8004e5 <_panic>
	assert(r <= PGSIZE);
  801b2d:	68 ab 2f 80 00       	push   $0x802fab
  801b32:	68 8b 2f 80 00       	push   $0x802f8b
  801b37:	6a 7d                	push   $0x7d
  801b39:	68 a0 2f 80 00       	push   $0x802fa0
  801b3e:	e8 a2 e9 ff ff       	call   8004e5 <_panic>

00801b43 <open>:
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	56                   	push   %esi
  801b47:	53                   	push   %ebx
  801b48:	83 ec 1c             	sub    $0x1c,%esp
  801b4b:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801b4e:	56                   	push   %esi
  801b4f:	e8 0b f0 ff ff       	call   800b5f <strlen>
  801b54:	83 c4 10             	add    $0x10,%esp
  801b57:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b5c:	7f 6c                	jg     801bca <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801b5e:	83 ec 0c             	sub    $0xc,%esp
  801b61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b64:	50                   	push   %eax
  801b65:	e8 c2 f8 ff ff       	call   80142c <fd_alloc>
  801b6a:	89 c3                	mov    %eax,%ebx
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	78 3c                	js     801baf <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801b73:	83 ec 08             	sub    $0x8,%esp
  801b76:	56                   	push   %esi
  801b77:	68 00 60 80 00       	push   $0x806000
  801b7c:	e8 19 f0 ff ff       	call   800b9a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b81:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b84:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b89:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b8c:	b8 01 00 00 00       	mov    $0x1,%eax
  801b91:	e8 f6 fd ff ff       	call   80198c <fsipc>
  801b96:	89 c3                	mov    %eax,%ebx
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	78 19                	js     801bb8 <open+0x75>
	return fd2num(fd);
  801b9f:	83 ec 0c             	sub    $0xc,%esp
  801ba2:	ff 75 f4             	push   -0xc(%ebp)
  801ba5:	e8 5b f8 ff ff       	call   801405 <fd2num>
  801baa:	89 c3                	mov    %eax,%ebx
  801bac:	83 c4 10             	add    $0x10,%esp
}
  801baf:	89 d8                	mov    %ebx,%eax
  801bb1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb4:	5b                   	pop    %ebx
  801bb5:	5e                   	pop    %esi
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    
		fd_close(fd, 0);
  801bb8:	83 ec 08             	sub    $0x8,%esp
  801bbb:	6a 00                	push   $0x0
  801bbd:	ff 75 f4             	push   -0xc(%ebp)
  801bc0:	e8 58 f9 ff ff       	call   80151d <fd_close>
		return r;
  801bc5:	83 c4 10             	add    $0x10,%esp
  801bc8:	eb e5                	jmp    801baf <open+0x6c>
		return -E_BAD_PATH;
  801bca:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801bcf:	eb de                	jmp    801baf <open+0x6c>

00801bd1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bd7:	ba 00 00 00 00       	mov    $0x0,%edx
  801bdc:	b8 08 00 00 00       	mov    $0x8,%eax
  801be1:	e8 a6 fd ff ff       	call   80198c <fsipc>
}
  801be6:	c9                   	leave  
  801be7:	c3                   	ret    

00801be8 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	57                   	push   %edi
  801bec:	56                   	push   %esi
  801bed:	53                   	push   %ebx
  801bee:	81 ec 84 02 00 00    	sub    $0x284,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801bf4:	6a 00                	push   $0x0
  801bf6:	ff 75 08             	push   0x8(%ebp)
  801bf9:	e8 45 ff ff ff       	call   801b43 <open>
  801bfe:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	85 c0                	test   %eax,%eax
  801c09:	0f 88 aa 04 00 00    	js     8020b9 <spawn+0x4d1>
  801c0f:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c11:	83 ec 04             	sub    $0x4,%esp
  801c14:	68 00 02 00 00       	push   $0x200
  801c19:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c1f:	50                   	push   %eax
  801c20:	57                   	push   %edi
  801c21:	e8 41 fb ff ff       	call   801767 <readn>
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c2e:	75 57                	jne    801c87 <spawn+0x9f>
	    || elf->e_magic != ELF_MAGIC) {
  801c30:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c37:	45 4c 46 
  801c3a:	75 4b                	jne    801c87 <spawn+0x9f>
  801c3c:	b8 07 00 00 00       	mov    $0x7,%eax
  801c41:	cd 30                	int    $0x30
  801c43:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801c49:	85 c0                	test   %eax,%eax
  801c4b:	0f 88 5c 04 00 00    	js     8020ad <spawn+0x4c5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801c51:	25 ff 03 00 00       	and    $0x3ff,%eax
  801c56:	6b f0 7c             	imul   $0x7c,%eax,%esi
  801c59:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801c5f:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801c65:	b9 11 00 00 00       	mov    $0x11,%ecx
  801c6a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801c6c:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801c72:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c78:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801c7d:	be 00 00 00 00       	mov    $0x0,%esi
  801c82:	8b 7d 0c             	mov    0xc(%ebp),%edi
	for (argc = 0; argv[argc] != 0; argc++)
  801c85:	eb 4b                	jmp    801cd2 <spawn+0xea>
		close(fd);
  801c87:	83 ec 0c             	sub    $0xc,%esp
  801c8a:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801c90:	e8 0f f9 ff ff       	call   8015a4 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c95:	83 c4 0c             	add    $0xc,%esp
  801c98:	68 7f 45 4c 46       	push   $0x464c457f
  801c9d:	ff b5 e8 fd ff ff    	push   -0x218(%ebp)
  801ca3:	68 b7 2f 80 00       	push   $0x802fb7
  801ca8:	e8 13 e9 ff ff       	call   8005c0 <cprintf>
		return -E_NOT_EXEC;
  801cad:	83 c4 10             	add    $0x10,%esp
  801cb0:	c7 85 8c fd ff ff f2 	movl   $0xfffffff2,-0x274(%ebp)
  801cb7:	ff ff ff 
  801cba:	e9 fa 03 00 00       	jmp    8020b9 <spawn+0x4d1>
		string_size += strlen(argv[argc]) + 1;
  801cbf:	83 ec 0c             	sub    $0xc,%esp
  801cc2:	50                   	push   %eax
  801cc3:	e8 97 ee ff ff       	call   800b5f <strlen>
  801cc8:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801ccc:	83 c3 01             	add    $0x1,%ebx
  801ccf:	83 c4 10             	add    $0x10,%esp
  801cd2:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801cd9:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801cdc:	85 c0                	test   %eax,%eax
  801cde:	75 df                	jne    801cbf <spawn+0xd7>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801ce0:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801ce6:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801cec:	b8 00 10 40 00       	mov    $0x401000,%eax
  801cf1:	29 f0                	sub    %esi,%eax
  801cf3:	89 c7                	mov    %eax,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801cf5:	89 c2                	mov    %eax,%edx
  801cf7:	83 e2 fc             	and    $0xfffffffc,%edx
  801cfa:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801d01:	29 c2                	sub    %eax,%edx
  801d03:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801d09:	8d 42 f8             	lea    -0x8(%edx),%eax
  801d0c:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801d11:	0f 86 14 04 00 00    	jbe    80212b <spawn+0x543>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d17:	83 ec 04             	sub    $0x4,%esp
  801d1a:	6a 07                	push   $0x7
  801d1c:	68 00 00 40 00       	push   $0x400000
  801d21:	6a 00                	push   $0x0
  801d23:	e8 6e f2 ff ff       	call   800f96 <sys_page_alloc>
  801d28:	83 c4 10             	add    $0x10,%esp
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	0f 88 fd 03 00 00    	js     802130 <spawn+0x548>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801d33:	be 00 00 00 00       	mov    $0x0,%esi
  801d38:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801d3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d41:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801d47:	7e 32                	jle    801d7b <spawn+0x193>
		argv_store[i] = UTEMP2USTACK(string_store);
  801d49:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801d4f:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801d55:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801d58:	83 ec 08             	sub    $0x8,%esp
  801d5b:	ff 34 b3             	push   (%ebx,%esi,4)
  801d5e:	57                   	push   %edi
  801d5f:	e8 36 ee ff ff       	call   800b9a <strcpy>
		string_store += strlen(argv[i]) + 1;
  801d64:	83 c4 04             	add    $0x4,%esp
  801d67:	ff 34 b3             	push   (%ebx,%esi,4)
  801d6a:	e8 f0 ed ff ff       	call   800b5f <strlen>
  801d6f:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801d73:	83 c6 01             	add    $0x1,%esi
  801d76:	83 c4 10             	add    $0x10,%esp
  801d79:	eb c6                	jmp    801d41 <spawn+0x159>
	}
	argv_store[argc] = 0;
  801d7b:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801d81:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801d87:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801d8e:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801d94:	0f 85 8c 00 00 00    	jne    801e26 <spawn+0x23e>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801d9a:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801da0:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  801da6:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801da9:	89 c8                	mov    %ecx,%eax
  801dab:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  801db1:	89 79 f8             	mov    %edi,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801db4:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801db9:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801dbf:	83 ec 0c             	sub    $0xc,%esp
  801dc2:	6a 07                	push   $0x7
  801dc4:	68 00 d0 bf ee       	push   $0xeebfd000
  801dc9:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801dcf:	68 00 00 40 00       	push   $0x400000
  801dd4:	6a 00                	push   $0x0
  801dd6:	e8 fe f1 ff ff       	call   800fd9 <sys_page_map>
  801ddb:	89 c3                	mov    %eax,%ebx
  801ddd:	83 c4 20             	add    $0x20,%esp
  801de0:	85 c0                	test   %eax,%eax
  801de2:	0f 88 50 03 00 00    	js     802138 <spawn+0x550>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801de8:	83 ec 08             	sub    $0x8,%esp
  801deb:	68 00 00 40 00       	push   $0x400000
  801df0:	6a 00                	push   $0x0
  801df2:	e8 24 f2 ff ff       	call   80101b <sys_page_unmap>
  801df7:	89 c3                	mov    %eax,%ebx
  801df9:	83 c4 10             	add    $0x10,%esp
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	0f 88 34 03 00 00    	js     802138 <spawn+0x550>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e04:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801e0a:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801e11:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e17:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801e1e:	00 00 00 
  801e21:	e9 4e 01 00 00       	jmp    801f74 <spawn+0x38c>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801e26:	68 44 30 80 00       	push   $0x803044
  801e2b:	68 8b 2f 80 00       	push   $0x802f8b
  801e30:	68 f2 00 00 00       	push   $0xf2
  801e35:	68 d1 2f 80 00       	push   $0x802fd1
  801e3a:	e8 a6 e6 ff ff       	call   8004e5 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e3f:	83 ec 04             	sub    $0x4,%esp
  801e42:	6a 07                	push   $0x7
  801e44:	68 00 00 40 00       	push   $0x400000
  801e49:	6a 00                	push   $0x0
  801e4b:	e8 46 f1 ff ff       	call   800f96 <sys_page_alloc>
  801e50:	83 c4 10             	add    $0x10,%esp
  801e53:	85 c0                	test   %eax,%eax
  801e55:	0f 88 6c 02 00 00    	js     8020c7 <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e5b:	83 ec 08             	sub    $0x8,%esp
  801e5e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801e64:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801e6a:	50                   	push   %eax
  801e6b:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801e71:	e8 ba f9 ff ff       	call   801830 <seek>
  801e76:	83 c4 10             	add    $0x10,%esp
  801e79:	85 c0                	test   %eax,%eax
  801e7b:	0f 88 4d 02 00 00    	js     8020ce <spawn+0x4e6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e81:	83 ec 04             	sub    $0x4,%esp
  801e84:	89 f8                	mov    %edi,%eax
  801e86:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801e8c:	ba 00 10 00 00       	mov    $0x1000,%edx
  801e91:	39 d0                	cmp    %edx,%eax
  801e93:	0f 47 c2             	cmova  %edx,%eax
  801e96:	50                   	push   %eax
  801e97:	68 00 00 40 00       	push   $0x400000
  801e9c:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801ea2:	e8 c0 f8 ff ff       	call   801767 <readn>
  801ea7:	83 c4 10             	add    $0x10,%esp
  801eaa:	85 c0                	test   %eax,%eax
  801eac:	0f 88 23 02 00 00    	js     8020d5 <spawn+0x4ed>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801eb2:	83 ec 0c             	sub    $0xc,%esp
  801eb5:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801ebb:	56                   	push   %esi
  801ebc:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801ec2:	68 00 00 40 00       	push   $0x400000
  801ec7:	6a 00                	push   $0x0
  801ec9:	e8 0b f1 ff ff       	call   800fd9 <sys_page_map>
  801ece:	83 c4 20             	add    $0x20,%esp
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	78 7c                	js     801f51 <spawn+0x369>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801ed5:	83 ec 08             	sub    $0x8,%esp
  801ed8:	68 00 00 40 00       	push   $0x400000
  801edd:	6a 00                	push   $0x0
  801edf:	e8 37 f1 ff ff       	call   80101b <sys_page_unmap>
  801ee4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801ee7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801eed:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801ef3:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801ef9:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801eff:	76 65                	jbe    801f66 <spawn+0x37e>
		if (i >= filesz) {
  801f01:	39 df                	cmp    %ebx,%edi
  801f03:	0f 87 36 ff ff ff    	ja     801e3f <spawn+0x257>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801f09:	83 ec 04             	sub    $0x4,%esp
  801f0c:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801f12:	56                   	push   %esi
  801f13:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801f19:	e8 78 f0 ff ff       	call   800f96 <sys_page_alloc>
  801f1e:	83 c4 10             	add    $0x10,%esp
  801f21:	85 c0                	test   %eax,%eax
  801f23:	79 c2                	jns    801ee7 <spawn+0x2ff>
  801f25:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801f27:	83 ec 0c             	sub    $0xc,%esp
  801f2a:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801f30:	e8 e2 ef ff ff       	call   800f17 <sys_env_destroy>
	close(fd);
  801f35:	83 c4 04             	add    $0x4,%esp
  801f38:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801f3e:	e8 61 f6 ff ff       	call   8015a4 <close>
	return r;
  801f43:	83 c4 10             	add    $0x10,%esp
  801f46:	89 bd 8c fd ff ff    	mov    %edi,-0x274(%ebp)
  801f4c:	e9 68 01 00 00       	jmp    8020b9 <spawn+0x4d1>
				panic("spawn: sys_page_map data: %e", r);
  801f51:	50                   	push   %eax
  801f52:	68 dd 2f 80 00       	push   $0x802fdd
  801f57:	68 25 01 00 00       	push   $0x125
  801f5c:	68 d1 2f 80 00       	push   $0x802fd1
  801f61:	e8 7f e5 ff ff       	call   8004e5 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f66:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801f6d:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801f74:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801f7b:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801f81:	7e 67                	jle    801fea <spawn+0x402>
		if (ph->p_type != ELF_PROG_LOAD)
  801f83:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  801f89:	83 39 01             	cmpl   $0x1,(%ecx)
  801f8c:	75 d8                	jne    801f66 <spawn+0x37e>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801f8e:	8b 41 18             	mov    0x18(%ecx),%eax
  801f91:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801f97:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801f9a:	83 f8 01             	cmp    $0x1,%eax
  801f9d:	19 c0                	sbb    %eax,%eax
  801f9f:	83 e0 fe             	and    $0xfffffffe,%eax
  801fa2:	83 c0 07             	add    $0x7,%eax
  801fa5:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801fab:	8b 51 04             	mov    0x4(%ecx),%edx
  801fae:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801fb4:	8b 79 10             	mov    0x10(%ecx),%edi
  801fb7:	8b 59 14             	mov    0x14(%ecx),%ebx
  801fba:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801fc0:	8b 71 08             	mov    0x8(%ecx),%esi
	if ((i = PGOFF(va))) {
  801fc3:	89 f0                	mov    %esi,%eax
  801fc5:	25 ff 0f 00 00       	and    $0xfff,%eax
  801fca:	74 14                	je     801fe0 <spawn+0x3f8>
		va -= i;
  801fcc:	29 c6                	sub    %eax,%esi
		memsz += i;
  801fce:	01 c3                	add    %eax,%ebx
  801fd0:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801fd6:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801fd8:	29 c2                	sub    %eax,%edx
  801fda:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801fe0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fe5:	e9 09 ff ff ff       	jmp    801ef3 <spawn+0x30b>
	close(fd);
  801fea:	83 ec 0c             	sub    $0xc,%esp
  801fed:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801ff3:	e8 ac f5 ff ff       	call   8015a4 <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	envid_t this_envid = sys_getenvid();//父进程号
  801ff8:	e8 5b ef ff ff       	call   800f58 <sys_getenvid>
  801ffd:	89 c6                	mov    %eax,%esi
  801fff:	83 c4 10             	add    $0x10,%esp
	
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  802002:	bb 00 00 80 00       	mov    $0x800000,%ebx
  802007:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  80200d:	eb 12                	jmp    802021 <spawn+0x439>
  80200f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802015:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80201b:	0f 84 bb 00 00 00    	je     8020dc <spawn+0x4f4>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE ) ) {
  802021:	89 d8                	mov    %ebx,%eax
  802023:	c1 e8 16             	shr    $0x16,%eax
  802026:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80202d:	a8 01                	test   $0x1,%al
  80202f:	74 de                	je     80200f <spawn+0x427>
  802031:	89 d8                	mov    %ebx,%eax
  802033:	c1 e8 0c             	shr    $0xc,%eax
  802036:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80203d:	f6 c2 01             	test   $0x1,%dl
  802040:	74 cd                	je     80200f <spawn+0x427>
  802042:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802049:	f6 c6 04             	test   $0x4,%dh
  80204c:	74 c1                	je     80200f <spawn+0x427>
			//Copy the mappings
			if( (r=sys_page_map(this_envid , (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL ) )< 0 ) 
  80204e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802055:	83 ec 0c             	sub    $0xc,%esp
  802058:	25 07 0e 00 00       	and    $0xe07,%eax
  80205d:	50                   	push   %eax
  80205e:	53                   	push   %ebx
  80205f:	57                   	push   %edi
  802060:	53                   	push   %ebx
  802061:	56                   	push   %esi
  802062:	e8 72 ef ff ff       	call   800fd9 <sys_page_map>
  802067:	83 c4 20             	add    $0x20,%esp
  80206a:	85 c0                	test   %eax,%eax
  80206c:	79 a1                	jns    80200f <spawn+0x427>
		panic("copy_shared_pages: %e", r);
  80206e:	50                   	push   %eax
  80206f:	68 2b 30 80 00       	push   $0x80302b
  802074:	68 82 00 00 00       	push   $0x82
  802079:	68 d1 2f 80 00       	push   $0x802fd1
  80207e:	e8 62 e4 ff ff       	call   8004e5 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  802083:	50                   	push   %eax
  802084:	68 fa 2f 80 00       	push   $0x802ffa
  802089:	68 86 00 00 00       	push   $0x86
  80208e:	68 d1 2f 80 00       	push   $0x802fd1
  802093:	e8 4d e4 ff ff       	call   8004e5 <_panic>
		panic("sys_env_set_status: %e", r);
  802098:	50                   	push   %eax
  802099:	68 14 30 80 00       	push   $0x803014
  80209e:	68 89 00 00 00       	push   $0x89
  8020a3:	68 d1 2f 80 00       	push   $0x802fd1
  8020a8:	e8 38 e4 ff ff       	call   8004e5 <_panic>
		return r;
  8020ad:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8020b3:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
}
  8020b9:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8020bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020c2:	5b                   	pop    %ebx
  8020c3:	5e                   	pop    %esi
  8020c4:	5f                   	pop    %edi
  8020c5:	5d                   	pop    %ebp
  8020c6:	c3                   	ret    
  8020c7:	89 c7                	mov    %eax,%edi
  8020c9:	e9 59 fe ff ff       	jmp    801f27 <spawn+0x33f>
  8020ce:	89 c7                	mov    %eax,%edi
  8020d0:	e9 52 fe ff ff       	jmp    801f27 <spawn+0x33f>
  8020d5:	89 c7                	mov    %eax,%edi
  8020d7:	e9 4b fe ff ff       	jmp    801f27 <spawn+0x33f>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8020dc:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8020e3:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8020e6:	83 ec 08             	sub    $0x8,%esp
  8020e9:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8020ef:	50                   	push   %eax
  8020f0:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  8020f6:	e8 a4 ef ff ff       	call   80109f <sys_env_set_trapframe>
  8020fb:	83 c4 10             	add    $0x10,%esp
  8020fe:	85 c0                	test   %eax,%eax
  802100:	78 81                	js     802083 <spawn+0x49b>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802102:	83 ec 08             	sub    $0x8,%esp
  802105:	6a 02                	push   $0x2
  802107:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  80210d:	e8 4b ef ff ff       	call   80105d <sys_env_set_status>
  802112:	83 c4 10             	add    $0x10,%esp
  802115:	85 c0                	test   %eax,%eax
  802117:	0f 88 7b ff ff ff    	js     802098 <spawn+0x4b0>
	return child;
  80211d:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802123:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802129:	eb 8e                	jmp    8020b9 <spawn+0x4d1>
		return -E_NO_MEM;
  80212b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  802130:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802136:	eb 81                	jmp    8020b9 <spawn+0x4d1>
	sys_page_unmap(0, UTEMP);
  802138:	83 ec 08             	sub    $0x8,%esp
  80213b:	68 00 00 40 00       	push   $0x400000
  802140:	6a 00                	push   $0x0
  802142:	e8 d4 ee ff ff       	call   80101b <sys_page_unmap>
  802147:	83 c4 10             	add    $0x10,%esp
  80214a:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  802150:	e9 64 ff ff ff       	jmp    8020b9 <spawn+0x4d1>

00802155 <spawnl>:
{
  802155:	55                   	push   %ebp
  802156:	89 e5                	mov    %esp,%ebp
  802158:	56                   	push   %esi
  802159:	53                   	push   %ebx
	va_start(vl, arg0);
  80215a:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  80215d:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  802162:	eb 05                	jmp    802169 <spawnl+0x14>
		argc++;
  802164:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  802167:	89 ca                	mov    %ecx,%edx
  802169:	8d 4a 04             	lea    0x4(%edx),%ecx
  80216c:	83 3a 00             	cmpl   $0x0,(%edx)
  80216f:	75 f3                	jne    802164 <spawnl+0xf>
	const char *argv[argc+2];
  802171:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  802178:	89 d3                	mov    %edx,%ebx
  80217a:	83 e3 f0             	and    $0xfffffff0,%ebx
  80217d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  802183:	89 e1                	mov    %esp,%ecx
  802185:	29 d1                	sub    %edx,%ecx
  802187:	39 cc                	cmp    %ecx,%esp
  802189:	74 10                	je     80219b <spawnl+0x46>
  80218b:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  802191:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  802198:	00 
  802199:	eb ec                	jmp    802187 <spawnl+0x32>
  80219b:	89 da                	mov    %ebx,%edx
  80219d:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  8021a3:	29 d4                	sub    %edx,%esp
  8021a5:	85 d2                	test   %edx,%edx
  8021a7:	74 05                	je     8021ae <spawnl+0x59>
  8021a9:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  8021ae:	8d 5c 24 03          	lea    0x3(%esp),%ebx
  8021b2:	89 da                	mov    %ebx,%edx
  8021b4:	c1 ea 02             	shr    $0x2,%edx
  8021b7:	83 e3 fc             	and    $0xfffffffc,%ebx
	argv[0] = arg0;
  8021ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021bd:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  8021c4:	c7 44 83 04 00 00 00 	movl   $0x0,0x4(%ebx,%eax,4)
  8021cb:	00 
	va_start(vl, arg0);
  8021cc:	8d 4d 10             	lea    0x10(%ebp),%ecx
  8021cf:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  8021d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8021d6:	eb 0b                	jmp    8021e3 <spawnl+0x8e>
		argv[i+1] = va_arg(vl, const char *);
  8021d8:	83 c0 01             	add    $0x1,%eax
  8021db:	8b 31                	mov    (%ecx),%esi
  8021dd:	89 34 83             	mov    %esi,(%ebx,%eax,4)
  8021e0:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  8021e3:	39 d0                	cmp    %edx,%eax
  8021e5:	75 f1                	jne    8021d8 <spawnl+0x83>
	return spawn(prog, argv);
  8021e7:	83 ec 08             	sub    $0x8,%esp
  8021ea:	53                   	push   %ebx
  8021eb:	ff 75 08             	push   0x8(%ebp)
  8021ee:	e8 f5 f9 ff ff       	call   801be8 <spawn>
}
  8021f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021f6:	5b                   	pop    %ebx
  8021f7:	5e                   	pop    %esi
  8021f8:	5d                   	pop    %ebp
  8021f9:	c3                   	ret    

008021fa <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8021fa:	55                   	push   %ebp
  8021fb:	89 e5                	mov    %esp,%ebp
  8021fd:	56                   	push   %esi
  8021fe:	53                   	push   %ebx
  8021ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802202:	83 ec 0c             	sub    $0xc,%esp
  802205:	ff 75 08             	push   0x8(%ebp)
  802208:	e8 08 f2 ff ff       	call   801415 <fd2data>
  80220d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80220f:	83 c4 08             	add    $0x8,%esp
  802212:	68 6a 30 80 00       	push   $0x80306a
  802217:	53                   	push   %ebx
  802218:	e8 7d e9 ff ff       	call   800b9a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80221d:	8b 46 04             	mov    0x4(%esi),%eax
  802220:	2b 06                	sub    (%esi),%eax
  802222:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802228:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80222f:	00 00 00 
	stat->st_dev = &devpipe;
  802232:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802239:	40 80 00 
	return 0;
}
  80223c:	b8 00 00 00 00       	mov    $0x0,%eax
  802241:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802244:	5b                   	pop    %ebx
  802245:	5e                   	pop    %esi
  802246:	5d                   	pop    %ebp
  802247:	c3                   	ret    

00802248 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802248:	55                   	push   %ebp
  802249:	89 e5                	mov    %esp,%ebp
  80224b:	53                   	push   %ebx
  80224c:	83 ec 0c             	sub    $0xc,%esp
  80224f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802252:	53                   	push   %ebx
  802253:	6a 00                	push   $0x0
  802255:	e8 c1 ed ff ff       	call   80101b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80225a:	89 1c 24             	mov    %ebx,(%esp)
  80225d:	e8 b3 f1 ff ff       	call   801415 <fd2data>
  802262:	83 c4 08             	add    $0x8,%esp
  802265:	50                   	push   %eax
  802266:	6a 00                	push   $0x0
  802268:	e8 ae ed ff ff       	call   80101b <sys_page_unmap>
}
  80226d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802270:	c9                   	leave  
  802271:	c3                   	ret    

00802272 <_pipeisclosed>:
{
  802272:	55                   	push   %ebp
  802273:	89 e5                	mov    %esp,%ebp
  802275:	57                   	push   %edi
  802276:	56                   	push   %esi
  802277:	53                   	push   %ebx
  802278:	83 ec 1c             	sub    $0x1c,%esp
  80227b:	89 c7                	mov    %eax,%edi
  80227d:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80227f:	a1 00 50 80 00       	mov    0x805000,%eax
  802284:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802287:	83 ec 0c             	sub    $0xc,%esp
  80228a:	57                   	push   %edi
  80228b:	e8 93 04 00 00       	call   802723 <pageref>
  802290:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802293:	89 34 24             	mov    %esi,(%esp)
  802296:	e8 88 04 00 00       	call   802723 <pageref>
		nn = thisenv->env_runs;
  80229b:	8b 15 00 50 80 00    	mov    0x805000,%edx
  8022a1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8022a4:	83 c4 10             	add    $0x10,%esp
  8022a7:	39 cb                	cmp    %ecx,%ebx
  8022a9:	74 1b                	je     8022c6 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8022ab:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8022ae:	75 cf                	jne    80227f <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8022b0:	8b 42 58             	mov    0x58(%edx),%eax
  8022b3:	6a 01                	push   $0x1
  8022b5:	50                   	push   %eax
  8022b6:	53                   	push   %ebx
  8022b7:	68 71 30 80 00       	push   $0x803071
  8022bc:	e8 ff e2 ff ff       	call   8005c0 <cprintf>
  8022c1:	83 c4 10             	add    $0x10,%esp
  8022c4:	eb b9                	jmp    80227f <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8022c6:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8022c9:	0f 94 c0             	sete   %al
  8022cc:	0f b6 c0             	movzbl %al,%eax
}
  8022cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022d2:	5b                   	pop    %ebx
  8022d3:	5e                   	pop    %esi
  8022d4:	5f                   	pop    %edi
  8022d5:	5d                   	pop    %ebp
  8022d6:	c3                   	ret    

008022d7 <devpipe_write>:
{
  8022d7:	55                   	push   %ebp
  8022d8:	89 e5                	mov    %esp,%ebp
  8022da:	57                   	push   %edi
  8022db:	56                   	push   %esi
  8022dc:	53                   	push   %ebx
  8022dd:	83 ec 28             	sub    $0x28,%esp
  8022e0:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8022e3:	56                   	push   %esi
  8022e4:	e8 2c f1 ff ff       	call   801415 <fd2data>
  8022e9:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8022eb:	83 c4 10             	add    $0x10,%esp
  8022ee:	bf 00 00 00 00       	mov    $0x0,%edi
  8022f3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8022f6:	75 09                	jne    802301 <devpipe_write+0x2a>
	return i;
  8022f8:	89 f8                	mov    %edi,%eax
  8022fa:	eb 23                	jmp    80231f <devpipe_write+0x48>
			sys_yield();
  8022fc:	e8 76 ec ff ff       	call   800f77 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802301:	8b 43 04             	mov    0x4(%ebx),%eax
  802304:	8b 0b                	mov    (%ebx),%ecx
  802306:	8d 51 20             	lea    0x20(%ecx),%edx
  802309:	39 d0                	cmp    %edx,%eax
  80230b:	72 1a                	jb     802327 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80230d:	89 da                	mov    %ebx,%edx
  80230f:	89 f0                	mov    %esi,%eax
  802311:	e8 5c ff ff ff       	call   802272 <_pipeisclosed>
  802316:	85 c0                	test   %eax,%eax
  802318:	74 e2                	je     8022fc <devpipe_write+0x25>
				return 0;
  80231a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80231f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802322:	5b                   	pop    %ebx
  802323:	5e                   	pop    %esi
  802324:	5f                   	pop    %edi
  802325:	5d                   	pop    %ebp
  802326:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802327:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80232a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80232e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802331:	89 c2                	mov    %eax,%edx
  802333:	c1 fa 1f             	sar    $0x1f,%edx
  802336:	89 d1                	mov    %edx,%ecx
  802338:	c1 e9 1b             	shr    $0x1b,%ecx
  80233b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80233e:	83 e2 1f             	and    $0x1f,%edx
  802341:	29 ca                	sub    %ecx,%edx
  802343:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802347:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80234b:	83 c0 01             	add    $0x1,%eax
  80234e:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802351:	83 c7 01             	add    $0x1,%edi
  802354:	eb 9d                	jmp    8022f3 <devpipe_write+0x1c>

00802356 <devpipe_read>:
{
  802356:	55                   	push   %ebp
  802357:	89 e5                	mov    %esp,%ebp
  802359:	57                   	push   %edi
  80235a:	56                   	push   %esi
  80235b:	53                   	push   %ebx
  80235c:	83 ec 18             	sub    $0x18,%esp
  80235f:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802362:	57                   	push   %edi
  802363:	e8 ad f0 ff ff       	call   801415 <fd2data>
  802368:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80236a:	83 c4 10             	add    $0x10,%esp
  80236d:	be 00 00 00 00       	mov    $0x0,%esi
  802372:	3b 75 10             	cmp    0x10(%ebp),%esi
  802375:	75 13                	jne    80238a <devpipe_read+0x34>
	return i;
  802377:	89 f0                	mov    %esi,%eax
  802379:	eb 02                	jmp    80237d <devpipe_read+0x27>
				return i;
  80237b:	89 f0                	mov    %esi,%eax
}
  80237d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802380:	5b                   	pop    %ebx
  802381:	5e                   	pop    %esi
  802382:	5f                   	pop    %edi
  802383:	5d                   	pop    %ebp
  802384:	c3                   	ret    
			sys_yield();
  802385:	e8 ed eb ff ff       	call   800f77 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80238a:	8b 03                	mov    (%ebx),%eax
  80238c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80238f:	75 18                	jne    8023a9 <devpipe_read+0x53>
			if (i > 0)
  802391:	85 f6                	test   %esi,%esi
  802393:	75 e6                	jne    80237b <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  802395:	89 da                	mov    %ebx,%edx
  802397:	89 f8                	mov    %edi,%eax
  802399:	e8 d4 fe ff ff       	call   802272 <_pipeisclosed>
  80239e:	85 c0                	test   %eax,%eax
  8023a0:	74 e3                	je     802385 <devpipe_read+0x2f>
				return 0;
  8023a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8023a7:	eb d4                	jmp    80237d <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8023a9:	99                   	cltd   
  8023aa:	c1 ea 1b             	shr    $0x1b,%edx
  8023ad:	01 d0                	add    %edx,%eax
  8023af:	83 e0 1f             	and    $0x1f,%eax
  8023b2:	29 d0                	sub    %edx,%eax
  8023b4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8023b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023bc:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8023bf:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8023c2:	83 c6 01             	add    $0x1,%esi
  8023c5:	eb ab                	jmp    802372 <devpipe_read+0x1c>

008023c7 <pipe>:
{
  8023c7:	55                   	push   %ebp
  8023c8:	89 e5                	mov    %esp,%ebp
  8023ca:	56                   	push   %esi
  8023cb:	53                   	push   %ebx
  8023cc:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8023cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023d2:	50                   	push   %eax
  8023d3:	e8 54 f0 ff ff       	call   80142c <fd_alloc>
  8023d8:	89 c3                	mov    %eax,%ebx
  8023da:	83 c4 10             	add    $0x10,%esp
  8023dd:	85 c0                	test   %eax,%eax
  8023df:	0f 88 23 01 00 00    	js     802508 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023e5:	83 ec 04             	sub    $0x4,%esp
  8023e8:	68 07 04 00 00       	push   $0x407
  8023ed:	ff 75 f4             	push   -0xc(%ebp)
  8023f0:	6a 00                	push   $0x0
  8023f2:	e8 9f eb ff ff       	call   800f96 <sys_page_alloc>
  8023f7:	89 c3                	mov    %eax,%ebx
  8023f9:	83 c4 10             	add    $0x10,%esp
  8023fc:	85 c0                	test   %eax,%eax
  8023fe:	0f 88 04 01 00 00    	js     802508 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802404:	83 ec 0c             	sub    $0xc,%esp
  802407:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80240a:	50                   	push   %eax
  80240b:	e8 1c f0 ff ff       	call   80142c <fd_alloc>
  802410:	89 c3                	mov    %eax,%ebx
  802412:	83 c4 10             	add    $0x10,%esp
  802415:	85 c0                	test   %eax,%eax
  802417:	0f 88 db 00 00 00    	js     8024f8 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80241d:	83 ec 04             	sub    $0x4,%esp
  802420:	68 07 04 00 00       	push   $0x407
  802425:	ff 75 f0             	push   -0x10(%ebp)
  802428:	6a 00                	push   $0x0
  80242a:	e8 67 eb ff ff       	call   800f96 <sys_page_alloc>
  80242f:	89 c3                	mov    %eax,%ebx
  802431:	83 c4 10             	add    $0x10,%esp
  802434:	85 c0                	test   %eax,%eax
  802436:	0f 88 bc 00 00 00    	js     8024f8 <pipe+0x131>
	va = fd2data(fd0);
  80243c:	83 ec 0c             	sub    $0xc,%esp
  80243f:	ff 75 f4             	push   -0xc(%ebp)
  802442:	e8 ce ef ff ff       	call   801415 <fd2data>
  802447:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802449:	83 c4 0c             	add    $0xc,%esp
  80244c:	68 07 04 00 00       	push   $0x407
  802451:	50                   	push   %eax
  802452:	6a 00                	push   $0x0
  802454:	e8 3d eb ff ff       	call   800f96 <sys_page_alloc>
  802459:	89 c3                	mov    %eax,%ebx
  80245b:	83 c4 10             	add    $0x10,%esp
  80245e:	85 c0                	test   %eax,%eax
  802460:	0f 88 82 00 00 00    	js     8024e8 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802466:	83 ec 0c             	sub    $0xc,%esp
  802469:	ff 75 f0             	push   -0x10(%ebp)
  80246c:	e8 a4 ef ff ff       	call   801415 <fd2data>
  802471:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802478:	50                   	push   %eax
  802479:	6a 00                	push   $0x0
  80247b:	56                   	push   %esi
  80247c:	6a 00                	push   $0x0
  80247e:	e8 56 eb ff ff       	call   800fd9 <sys_page_map>
  802483:	89 c3                	mov    %eax,%ebx
  802485:	83 c4 20             	add    $0x20,%esp
  802488:	85 c0                	test   %eax,%eax
  80248a:	78 4e                	js     8024da <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80248c:	a1 3c 40 80 00       	mov    0x80403c,%eax
  802491:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802494:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802496:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802499:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8024a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8024a3:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8024a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024a8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8024af:	83 ec 0c             	sub    $0xc,%esp
  8024b2:	ff 75 f4             	push   -0xc(%ebp)
  8024b5:	e8 4b ef ff ff       	call   801405 <fd2num>
  8024ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024bd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8024bf:	83 c4 04             	add    $0x4,%esp
  8024c2:	ff 75 f0             	push   -0x10(%ebp)
  8024c5:	e8 3b ef ff ff       	call   801405 <fd2num>
  8024ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024cd:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8024d0:	83 c4 10             	add    $0x10,%esp
  8024d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024d8:	eb 2e                	jmp    802508 <pipe+0x141>
	sys_page_unmap(0, va);
  8024da:	83 ec 08             	sub    $0x8,%esp
  8024dd:	56                   	push   %esi
  8024de:	6a 00                	push   $0x0
  8024e0:	e8 36 eb ff ff       	call   80101b <sys_page_unmap>
  8024e5:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8024e8:	83 ec 08             	sub    $0x8,%esp
  8024eb:	ff 75 f0             	push   -0x10(%ebp)
  8024ee:	6a 00                	push   $0x0
  8024f0:	e8 26 eb ff ff       	call   80101b <sys_page_unmap>
  8024f5:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8024f8:	83 ec 08             	sub    $0x8,%esp
  8024fb:	ff 75 f4             	push   -0xc(%ebp)
  8024fe:	6a 00                	push   $0x0
  802500:	e8 16 eb ff ff       	call   80101b <sys_page_unmap>
  802505:	83 c4 10             	add    $0x10,%esp
}
  802508:	89 d8                	mov    %ebx,%eax
  80250a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80250d:	5b                   	pop    %ebx
  80250e:	5e                   	pop    %esi
  80250f:	5d                   	pop    %ebp
  802510:	c3                   	ret    

00802511 <pipeisclosed>:
{
  802511:	55                   	push   %ebp
  802512:	89 e5                	mov    %esp,%ebp
  802514:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802517:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80251a:	50                   	push   %eax
  80251b:	ff 75 08             	push   0x8(%ebp)
  80251e:	e8 59 ef ff ff       	call   80147c <fd_lookup>
  802523:	83 c4 10             	add    $0x10,%esp
  802526:	85 c0                	test   %eax,%eax
  802528:	78 18                	js     802542 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80252a:	83 ec 0c             	sub    $0xc,%esp
  80252d:	ff 75 f4             	push   -0xc(%ebp)
  802530:	e8 e0 ee ff ff       	call   801415 <fd2data>
  802535:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802537:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80253a:	e8 33 fd ff ff       	call   802272 <_pipeisclosed>
  80253f:	83 c4 10             	add    $0x10,%esp
}
  802542:	c9                   	leave  
  802543:	c3                   	ret    

00802544 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802544:	55                   	push   %ebp
  802545:	89 e5                	mov    %esp,%ebp
  802547:	56                   	push   %esi
  802548:	53                   	push   %ebx
  802549:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80254c:	85 f6                	test   %esi,%esi
  80254e:	74 13                	je     802563 <wait+0x1f>
	e = &envs[ENVX(envid)];
  802550:	89 f3                	mov    %esi,%ebx
  802552:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802558:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80255b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802561:	eb 1b                	jmp    80257e <wait+0x3a>
	assert(envid != 0);
  802563:	68 89 30 80 00       	push   $0x803089
  802568:	68 8b 2f 80 00       	push   $0x802f8b
  80256d:	6a 09                	push   $0x9
  80256f:	68 94 30 80 00       	push   $0x803094
  802574:	e8 6c df ff ff       	call   8004e5 <_panic>
		sys_yield();
  802579:	e8 f9 e9 ff ff       	call   800f77 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80257e:	8b 43 48             	mov    0x48(%ebx),%eax
  802581:	39 f0                	cmp    %esi,%eax
  802583:	75 07                	jne    80258c <wait+0x48>
  802585:	8b 43 54             	mov    0x54(%ebx),%eax
  802588:	85 c0                	test   %eax,%eax
  80258a:	75 ed                	jne    802579 <wait+0x35>
}
  80258c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80258f:	5b                   	pop    %ebx
  802590:	5e                   	pop    %esi
  802591:	5d                   	pop    %ebp
  802592:	c3                   	ret    

00802593 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802593:	55                   	push   %ebp
  802594:	89 e5                	mov    %esp,%ebp
  802596:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  802599:	83 3d 04 70 80 00 00 	cmpl   $0x0,0x807004
  8025a0:	74 0a                	je     8025ac <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8025a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8025a5:	a3 04 70 80 00       	mov    %eax,0x807004
}
  8025aa:	c9                   	leave  
  8025ab:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8025ac:	e8 a7 e9 ff ff       	call   800f58 <sys_getenvid>
  8025b1:	83 ec 04             	sub    $0x4,%esp
  8025b4:	68 07 0e 00 00       	push   $0xe07
  8025b9:	68 00 f0 bf ee       	push   $0xeebff000
  8025be:	50                   	push   %eax
  8025bf:	e8 d2 e9 ff ff       	call   800f96 <sys_page_alloc>
		if (r < 0) {
  8025c4:	83 c4 10             	add    $0x10,%esp
  8025c7:	85 c0                	test   %eax,%eax
  8025c9:	78 2c                	js     8025f7 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8025cb:	e8 88 e9 ff ff       	call   800f58 <sys_getenvid>
  8025d0:	83 ec 08             	sub    $0x8,%esp
  8025d3:	68 09 26 80 00       	push   $0x802609
  8025d8:	50                   	push   %eax
  8025d9:	e8 03 eb ff ff       	call   8010e1 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  8025de:	83 c4 10             	add    $0x10,%esp
  8025e1:	85 c0                	test   %eax,%eax
  8025e3:	79 bd                	jns    8025a2 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  8025e5:	50                   	push   %eax
  8025e6:	68 e0 30 80 00       	push   $0x8030e0
  8025eb:	6a 28                	push   $0x28
  8025ed:	68 16 31 80 00       	push   $0x803116
  8025f2:	e8 ee de ff ff       	call   8004e5 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  8025f7:	50                   	push   %eax
  8025f8:	68 a0 30 80 00       	push   $0x8030a0
  8025fd:	6a 23                	push   $0x23
  8025ff:	68 16 31 80 00       	push   $0x803116
  802604:	e8 dc de ff ff       	call   8004e5 <_panic>

00802609 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802609:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80260a:	a1 04 70 80 00       	mov    0x807004,%eax
	call *%eax
  80260f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802611:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802614:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802618:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  80261b:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  80261f:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802623:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  802625:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802628:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  802629:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  80262c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  80262d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  80262e:	c3                   	ret    

0080262f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80262f:	55                   	push   %ebp
  802630:	89 e5                	mov    %esp,%ebp
  802632:	56                   	push   %esi
  802633:	53                   	push   %ebx
  802634:	8b 75 08             	mov    0x8(%ebp),%esi
  802637:	8b 45 0c             	mov    0xc(%ebp),%eax
  80263a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80263d:	85 c0                	test   %eax,%eax
  80263f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802644:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802647:	83 ec 0c             	sub    $0xc,%esp
  80264a:	50                   	push   %eax
  80264b:	e8 f6 ea ff ff       	call   801146 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802650:	83 c4 10             	add    $0x10,%esp
  802653:	85 f6                	test   %esi,%esi
  802655:	74 14                	je     80266b <ipc_recv+0x3c>
  802657:	ba 00 00 00 00       	mov    $0x0,%edx
  80265c:	85 c0                	test   %eax,%eax
  80265e:	78 09                	js     802669 <ipc_recv+0x3a>
  802660:	8b 15 00 50 80 00    	mov    0x805000,%edx
  802666:	8b 52 74             	mov    0x74(%edx),%edx
  802669:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  80266b:	85 db                	test   %ebx,%ebx
  80266d:	74 14                	je     802683 <ipc_recv+0x54>
  80266f:	ba 00 00 00 00       	mov    $0x0,%edx
  802674:	85 c0                	test   %eax,%eax
  802676:	78 09                	js     802681 <ipc_recv+0x52>
  802678:	8b 15 00 50 80 00    	mov    0x805000,%edx
  80267e:	8b 52 78             	mov    0x78(%edx),%edx
  802681:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802683:	85 c0                	test   %eax,%eax
  802685:	78 08                	js     80268f <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  802687:	a1 00 50 80 00       	mov    0x805000,%eax
  80268c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80268f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802692:	5b                   	pop    %ebx
  802693:	5e                   	pop    %esi
  802694:	5d                   	pop    %ebp
  802695:	c3                   	ret    

00802696 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802696:	55                   	push   %ebp
  802697:	89 e5                	mov    %esp,%ebp
  802699:	57                   	push   %edi
  80269a:	56                   	push   %esi
  80269b:	53                   	push   %ebx
  80269c:	83 ec 0c             	sub    $0xc,%esp
  80269f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026a2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8026a8:	85 db                	test   %ebx,%ebx
  8026aa:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8026af:	0f 44 d8             	cmove  %eax,%ebx
  8026b2:	eb 05                	jmp    8026b9 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8026b4:	e8 be e8 ff ff       	call   800f77 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8026b9:	ff 75 14             	push   0x14(%ebp)
  8026bc:	53                   	push   %ebx
  8026bd:	56                   	push   %esi
  8026be:	57                   	push   %edi
  8026bf:	e8 5f ea ff ff       	call   801123 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8026c4:	83 c4 10             	add    $0x10,%esp
  8026c7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026ca:	74 e8                	je     8026b4 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8026cc:	85 c0                	test   %eax,%eax
  8026ce:	78 08                	js     8026d8 <ipc_send+0x42>
	}while (r<0);

}
  8026d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026d3:	5b                   	pop    %ebx
  8026d4:	5e                   	pop    %esi
  8026d5:	5f                   	pop    %edi
  8026d6:	5d                   	pop    %ebp
  8026d7:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8026d8:	50                   	push   %eax
  8026d9:	68 24 31 80 00       	push   $0x803124
  8026de:	6a 3d                	push   $0x3d
  8026e0:	68 38 31 80 00       	push   $0x803138
  8026e5:	e8 fb dd ff ff       	call   8004e5 <_panic>

008026ea <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8026ea:	55                   	push   %ebp
  8026eb:	89 e5                	mov    %esp,%ebp
  8026ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8026f0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8026f5:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8026f8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026fe:	8b 52 50             	mov    0x50(%edx),%edx
  802701:	39 ca                	cmp    %ecx,%edx
  802703:	74 11                	je     802716 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802705:	83 c0 01             	add    $0x1,%eax
  802708:	3d 00 04 00 00       	cmp    $0x400,%eax
  80270d:	75 e6                	jne    8026f5 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80270f:	b8 00 00 00 00       	mov    $0x0,%eax
  802714:	eb 0b                	jmp    802721 <ipc_find_env+0x37>
			return envs[i].env_id;
  802716:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802719:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80271e:	8b 40 48             	mov    0x48(%eax),%eax
}
  802721:	5d                   	pop    %ebp
  802722:	c3                   	ret    

00802723 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802723:	55                   	push   %ebp
  802724:	89 e5                	mov    %esp,%ebp
  802726:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802729:	89 c2                	mov    %eax,%edx
  80272b:	c1 ea 16             	shr    $0x16,%edx
  80272e:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802735:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80273a:	f6 c1 01             	test   $0x1,%cl
  80273d:	74 1c                	je     80275b <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  80273f:	c1 e8 0c             	shr    $0xc,%eax
  802742:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802749:	a8 01                	test   $0x1,%al
  80274b:	74 0e                	je     80275b <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80274d:	c1 e8 0c             	shr    $0xc,%eax
  802750:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802757:	ef 
  802758:	0f b7 d2             	movzwl %dx,%edx
}
  80275b:	89 d0                	mov    %edx,%eax
  80275d:	5d                   	pop    %ebp
  80275e:	c3                   	ret    
  80275f:	90                   	nop

00802760 <__udivdi3>:
  802760:	f3 0f 1e fb          	endbr32 
  802764:	55                   	push   %ebp
  802765:	57                   	push   %edi
  802766:	56                   	push   %esi
  802767:	53                   	push   %ebx
  802768:	83 ec 1c             	sub    $0x1c,%esp
  80276b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80276f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802773:	8b 74 24 34          	mov    0x34(%esp),%esi
  802777:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80277b:	85 c0                	test   %eax,%eax
  80277d:	75 19                	jne    802798 <__udivdi3+0x38>
  80277f:	39 f3                	cmp    %esi,%ebx
  802781:	76 4d                	jbe    8027d0 <__udivdi3+0x70>
  802783:	31 ff                	xor    %edi,%edi
  802785:	89 e8                	mov    %ebp,%eax
  802787:	89 f2                	mov    %esi,%edx
  802789:	f7 f3                	div    %ebx
  80278b:	89 fa                	mov    %edi,%edx
  80278d:	83 c4 1c             	add    $0x1c,%esp
  802790:	5b                   	pop    %ebx
  802791:	5e                   	pop    %esi
  802792:	5f                   	pop    %edi
  802793:	5d                   	pop    %ebp
  802794:	c3                   	ret    
  802795:	8d 76 00             	lea    0x0(%esi),%esi
  802798:	39 f0                	cmp    %esi,%eax
  80279a:	76 14                	jbe    8027b0 <__udivdi3+0x50>
  80279c:	31 ff                	xor    %edi,%edi
  80279e:	31 c0                	xor    %eax,%eax
  8027a0:	89 fa                	mov    %edi,%edx
  8027a2:	83 c4 1c             	add    $0x1c,%esp
  8027a5:	5b                   	pop    %ebx
  8027a6:	5e                   	pop    %esi
  8027a7:	5f                   	pop    %edi
  8027a8:	5d                   	pop    %ebp
  8027a9:	c3                   	ret    
  8027aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027b0:	0f bd f8             	bsr    %eax,%edi
  8027b3:	83 f7 1f             	xor    $0x1f,%edi
  8027b6:	75 48                	jne    802800 <__udivdi3+0xa0>
  8027b8:	39 f0                	cmp    %esi,%eax
  8027ba:	72 06                	jb     8027c2 <__udivdi3+0x62>
  8027bc:	31 c0                	xor    %eax,%eax
  8027be:	39 eb                	cmp    %ebp,%ebx
  8027c0:	77 de                	ja     8027a0 <__udivdi3+0x40>
  8027c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8027c7:	eb d7                	jmp    8027a0 <__udivdi3+0x40>
  8027c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027d0:	89 d9                	mov    %ebx,%ecx
  8027d2:	85 db                	test   %ebx,%ebx
  8027d4:	75 0b                	jne    8027e1 <__udivdi3+0x81>
  8027d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027db:	31 d2                	xor    %edx,%edx
  8027dd:	f7 f3                	div    %ebx
  8027df:	89 c1                	mov    %eax,%ecx
  8027e1:	31 d2                	xor    %edx,%edx
  8027e3:	89 f0                	mov    %esi,%eax
  8027e5:	f7 f1                	div    %ecx
  8027e7:	89 c6                	mov    %eax,%esi
  8027e9:	89 e8                	mov    %ebp,%eax
  8027eb:	89 f7                	mov    %esi,%edi
  8027ed:	f7 f1                	div    %ecx
  8027ef:	89 fa                	mov    %edi,%edx
  8027f1:	83 c4 1c             	add    $0x1c,%esp
  8027f4:	5b                   	pop    %ebx
  8027f5:	5e                   	pop    %esi
  8027f6:	5f                   	pop    %edi
  8027f7:	5d                   	pop    %ebp
  8027f8:	c3                   	ret    
  8027f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802800:	89 f9                	mov    %edi,%ecx
  802802:	ba 20 00 00 00       	mov    $0x20,%edx
  802807:	29 fa                	sub    %edi,%edx
  802809:	d3 e0                	shl    %cl,%eax
  80280b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80280f:	89 d1                	mov    %edx,%ecx
  802811:	89 d8                	mov    %ebx,%eax
  802813:	d3 e8                	shr    %cl,%eax
  802815:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802819:	09 c1                	or     %eax,%ecx
  80281b:	89 f0                	mov    %esi,%eax
  80281d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802821:	89 f9                	mov    %edi,%ecx
  802823:	d3 e3                	shl    %cl,%ebx
  802825:	89 d1                	mov    %edx,%ecx
  802827:	d3 e8                	shr    %cl,%eax
  802829:	89 f9                	mov    %edi,%ecx
  80282b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80282f:	89 eb                	mov    %ebp,%ebx
  802831:	d3 e6                	shl    %cl,%esi
  802833:	89 d1                	mov    %edx,%ecx
  802835:	d3 eb                	shr    %cl,%ebx
  802837:	09 f3                	or     %esi,%ebx
  802839:	89 c6                	mov    %eax,%esi
  80283b:	89 f2                	mov    %esi,%edx
  80283d:	89 d8                	mov    %ebx,%eax
  80283f:	f7 74 24 08          	divl   0x8(%esp)
  802843:	89 d6                	mov    %edx,%esi
  802845:	89 c3                	mov    %eax,%ebx
  802847:	f7 64 24 0c          	mull   0xc(%esp)
  80284b:	39 d6                	cmp    %edx,%esi
  80284d:	72 19                	jb     802868 <__udivdi3+0x108>
  80284f:	89 f9                	mov    %edi,%ecx
  802851:	d3 e5                	shl    %cl,%ebp
  802853:	39 c5                	cmp    %eax,%ebp
  802855:	73 04                	jae    80285b <__udivdi3+0xfb>
  802857:	39 d6                	cmp    %edx,%esi
  802859:	74 0d                	je     802868 <__udivdi3+0x108>
  80285b:	89 d8                	mov    %ebx,%eax
  80285d:	31 ff                	xor    %edi,%edi
  80285f:	e9 3c ff ff ff       	jmp    8027a0 <__udivdi3+0x40>
  802864:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802868:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80286b:	31 ff                	xor    %edi,%edi
  80286d:	e9 2e ff ff ff       	jmp    8027a0 <__udivdi3+0x40>
  802872:	66 90                	xchg   %ax,%ax
  802874:	66 90                	xchg   %ax,%ax
  802876:	66 90                	xchg   %ax,%ax
  802878:	66 90                	xchg   %ax,%ax
  80287a:	66 90                	xchg   %ax,%ax
  80287c:	66 90                	xchg   %ax,%ax
  80287e:	66 90                	xchg   %ax,%ax

00802880 <__umoddi3>:
  802880:	f3 0f 1e fb          	endbr32 
  802884:	55                   	push   %ebp
  802885:	57                   	push   %edi
  802886:	56                   	push   %esi
  802887:	53                   	push   %ebx
  802888:	83 ec 1c             	sub    $0x1c,%esp
  80288b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80288f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802893:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802897:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80289b:	89 f0                	mov    %esi,%eax
  80289d:	89 da                	mov    %ebx,%edx
  80289f:	85 ff                	test   %edi,%edi
  8028a1:	75 15                	jne    8028b8 <__umoddi3+0x38>
  8028a3:	39 dd                	cmp    %ebx,%ebp
  8028a5:	76 39                	jbe    8028e0 <__umoddi3+0x60>
  8028a7:	f7 f5                	div    %ebp
  8028a9:	89 d0                	mov    %edx,%eax
  8028ab:	31 d2                	xor    %edx,%edx
  8028ad:	83 c4 1c             	add    $0x1c,%esp
  8028b0:	5b                   	pop    %ebx
  8028b1:	5e                   	pop    %esi
  8028b2:	5f                   	pop    %edi
  8028b3:	5d                   	pop    %ebp
  8028b4:	c3                   	ret    
  8028b5:	8d 76 00             	lea    0x0(%esi),%esi
  8028b8:	39 df                	cmp    %ebx,%edi
  8028ba:	77 f1                	ja     8028ad <__umoddi3+0x2d>
  8028bc:	0f bd cf             	bsr    %edi,%ecx
  8028bf:	83 f1 1f             	xor    $0x1f,%ecx
  8028c2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8028c6:	75 40                	jne    802908 <__umoddi3+0x88>
  8028c8:	39 df                	cmp    %ebx,%edi
  8028ca:	72 04                	jb     8028d0 <__umoddi3+0x50>
  8028cc:	39 f5                	cmp    %esi,%ebp
  8028ce:	77 dd                	ja     8028ad <__umoddi3+0x2d>
  8028d0:	89 da                	mov    %ebx,%edx
  8028d2:	89 f0                	mov    %esi,%eax
  8028d4:	29 e8                	sub    %ebp,%eax
  8028d6:	19 fa                	sbb    %edi,%edx
  8028d8:	eb d3                	jmp    8028ad <__umoddi3+0x2d>
  8028da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028e0:	89 e9                	mov    %ebp,%ecx
  8028e2:	85 ed                	test   %ebp,%ebp
  8028e4:	75 0b                	jne    8028f1 <__umoddi3+0x71>
  8028e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8028eb:	31 d2                	xor    %edx,%edx
  8028ed:	f7 f5                	div    %ebp
  8028ef:	89 c1                	mov    %eax,%ecx
  8028f1:	89 d8                	mov    %ebx,%eax
  8028f3:	31 d2                	xor    %edx,%edx
  8028f5:	f7 f1                	div    %ecx
  8028f7:	89 f0                	mov    %esi,%eax
  8028f9:	f7 f1                	div    %ecx
  8028fb:	89 d0                	mov    %edx,%eax
  8028fd:	31 d2                	xor    %edx,%edx
  8028ff:	eb ac                	jmp    8028ad <__umoddi3+0x2d>
  802901:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802908:	8b 44 24 04          	mov    0x4(%esp),%eax
  80290c:	ba 20 00 00 00       	mov    $0x20,%edx
  802911:	29 c2                	sub    %eax,%edx
  802913:	89 c1                	mov    %eax,%ecx
  802915:	89 e8                	mov    %ebp,%eax
  802917:	d3 e7                	shl    %cl,%edi
  802919:	89 d1                	mov    %edx,%ecx
  80291b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80291f:	d3 e8                	shr    %cl,%eax
  802921:	89 c1                	mov    %eax,%ecx
  802923:	8b 44 24 04          	mov    0x4(%esp),%eax
  802927:	09 f9                	or     %edi,%ecx
  802929:	89 df                	mov    %ebx,%edi
  80292b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80292f:	89 c1                	mov    %eax,%ecx
  802931:	d3 e5                	shl    %cl,%ebp
  802933:	89 d1                	mov    %edx,%ecx
  802935:	d3 ef                	shr    %cl,%edi
  802937:	89 c1                	mov    %eax,%ecx
  802939:	89 f0                	mov    %esi,%eax
  80293b:	d3 e3                	shl    %cl,%ebx
  80293d:	89 d1                	mov    %edx,%ecx
  80293f:	89 fa                	mov    %edi,%edx
  802941:	d3 e8                	shr    %cl,%eax
  802943:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802948:	09 d8                	or     %ebx,%eax
  80294a:	f7 74 24 08          	divl   0x8(%esp)
  80294e:	89 d3                	mov    %edx,%ebx
  802950:	d3 e6                	shl    %cl,%esi
  802952:	f7 e5                	mul    %ebp
  802954:	89 c7                	mov    %eax,%edi
  802956:	89 d1                	mov    %edx,%ecx
  802958:	39 d3                	cmp    %edx,%ebx
  80295a:	72 06                	jb     802962 <__umoddi3+0xe2>
  80295c:	75 0e                	jne    80296c <__umoddi3+0xec>
  80295e:	39 c6                	cmp    %eax,%esi
  802960:	73 0a                	jae    80296c <__umoddi3+0xec>
  802962:	29 e8                	sub    %ebp,%eax
  802964:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802968:	89 d1                	mov    %edx,%ecx
  80296a:	89 c7                	mov    %eax,%edi
  80296c:	89 f5                	mov    %esi,%ebp
  80296e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802972:	29 fd                	sub    %edi,%ebp
  802974:	19 cb                	sbb    %ecx,%ebx
  802976:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80297b:	89 d8                	mov    %ebx,%eax
  80297d:	d3 e0                	shl    %cl,%eax
  80297f:	89 f1                	mov    %esi,%ecx
  802981:	d3 ed                	shr    %cl,%ebp
  802983:	d3 eb                	shr    %cl,%ebx
  802985:	09 e8                	or     %ebp,%eax
  802987:	89 da                	mov    %ebx,%edx
  802989:	83 c4 1c             	add    $0x1c,%esp
  80298c:	5b                   	pop    %ebx
  80298d:	5e                   	pop    %esi
  80298e:	5f                   	pop    %edi
  80298f:	5d                   	pop    %ebp
  802990:	c3                   	ret    
